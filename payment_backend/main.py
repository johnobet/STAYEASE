import os

from fastapi import FastAPI, HTTPException, Request
from dotenv import load_dotenv

from firebase_service import db
from paymongo_service import create_checkout_session, verify_and_parse_webhook


load_dotenv()


app = FastAPI(
    title="StayEase Payment API",
    description="Payment backend for StayEase",
    version="1.0.0",
)


@app.get("/")
def root():
    return {
        "app": "StayEase Payment API",
        "status": "online",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
    }


@app.get("/firebase-check")
def firebase_check():
    try:
        test_ref = db.collection(
            "_backend_tests"
        ).document("connection")

        test_ref.set({
            "status": "connected",
        })

        return {
            "firebase": "connected",
            "firestore": "connected",
        }

    except Exception as e:
        return {
            "firebase": "error",
            "message": str(e),
        }


@app.get("/paymongo-check")
def paymongo_check():
    secret_key = os.getenv(
        "PAYMONGO_SECRET_KEY"
    )

    return {
        "paymongo_configured": bool(secret_key),
        "test_mode": (
            secret_key.startswith("sk_test_")
            if secret_key
            else False
        ),
    }


@app.post("/payments/test-checkout/{payment_id}")
async def create_test_checkout(payment_id: str):
    try:
        payment_ref = db.collection(
            "rentPayments"
        ).document(payment_id)

        payment_snapshot = payment_ref.get()

        if not payment_snapshot.exists:
            raise HTTPException(
                status_code=404,
                detail="Payment not found.",
            )

        payment = payment_snapshot.to_dict()

        if payment.get("isPaid") is True:
            raise HTTPException(
                status_code=400,
                detail="This payment is already paid.",
            )

        amount = payment.get("amount")

        if not isinstance(amount, int):
            raise HTTPException(
                status_code=400,
                detail="Payment amount must be an integer.",
            )

        checkout = await create_checkout_session(
            payment_id=payment_id,
            amount=amount,
            description="StayEase Rent Payment",
        )

        payment_ref.update({
            "status": "pending",
            "checkoutSessionId": checkout[
                "checkout_session_id"
            ],
            "referenceNumber": checkout[
                "reference_number"
            ],
        })

        return {
            "success": True,
            "payment_id": payment_id,
            "checkout_session_id": checkout[
                "checkout_session_id"
            ],
            "checkout_url": checkout[
                "checkout_url"
            ],
            "reference_number": checkout[
                "reference_number"
            ],
        }

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


@app.post("/webhooks/paymongo")
async def paymongo_webhook(request: Request):
    # Must read the raw body BEFORE any JSON parsing — the signature is
    # computed over the exact bytes PayMongo sent.
    raw_body = await request.body()
    signature_header = request.headers.get("Paymongo-Signature", "")

    try:
        event = verify_and_parse_webhook(raw_body, signature_header)
    except ValueError as e:
        # Wrong secret, tampered payload, or a request that didn't
        # actually come from PayMongo — reject it.
        raise HTTPException(status_code=400, detail=str(e))

    event_type = event.get("data", {}).get("attributes", {}).get("type")

    if event_type == "checkout_session.payment.paid":
        checkout_session = event["data"]["attributes"].get("data", {})
        metadata = checkout_session.get("attributes", {}).get("metadata", {})
        payment_id = metadata.get("payment_id")

        if payment_id:
            payment_ref = db.collection("rentPayments").document(payment_id)
            if payment_ref.get().exists:
                payment_ref.update({
                    "isPaid": True,
                    "status": "paid",
                })
            # If the doc doesn't exist (bad/old metadata), there's nothing
            # to update. We still return 200 below — returning an error
            # here would make PayMongo retry a webhook that can never
            # succeed.

    # Acknowledge quickly regardless of event type — PayMongo retries on
    # anything other than a fast 2xx.
    return {"received": True}