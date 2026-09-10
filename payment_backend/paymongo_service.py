import hashlib
import hmac
import json
import os

import httpx
from dotenv import load_dotenv


load_dotenv()

PAYMONGO_API_URL = "https://api.paymongo.com/v2"


def get_paymongo_secret() -> str:
    secret_key = os.getenv("PAYMONGO_SECRET_KEY")

    if not secret_key:
        raise RuntimeError(
            "PAYMONGO_SECRET_KEY is not configured."
        )

    return secret_key


def get_paymongo_webhook_secret() -> str:
    webhook_secret = os.getenv("PAYMONGO_WEBHOOK_SECRET")

    if not webhook_secret:
        raise RuntimeError(
            "PAYMONGO_WEBHOOK_SECRET is not configured. "
            "Create a webhook endpoint in the PayMongo dashboard first."
        )

    return webhook_secret


async def create_checkout_session(
    payment_id: str,
    amount: int,
    description: str,
):
    secret_key = get_paymongo_secret()

    payload = {
        "data": {
            "attributes": {
                "line_items": [
                    {
                        "name": description,
                        "amount": amount,
                        "currency": "PHP",
                        "quantity": 1,
                    }
                ],
                "payment_method_types": [
                    "card",
                    "gcash",
                    "qrph",
                ],
                "reference_number": f"STAYEASE-{payment_id}",
                "description": description,
                "send_email_receipt": False,
                "show_description": True,
                "show_line_items": True,
                "metadata": {
                    "payment_id": payment_id,
                    "source": "stayease",
                },
            }
        }
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            f"{PAYMONGO_API_URL}/checkout_sessions",
            auth=(secret_key, ""),
            headers={
                "Content-Type": "application/json",
            },
            json=payload,
        )

    if response.status_code >= 400:
        raise RuntimeError(
            f"PayMongo error "
            f"{response.status_code}: "
            f"{response.text}"
        )

    response_data = response.json()

    checkout_data = response_data.get("data", {})
    attributes = checkout_data.get("attributes", {})

    checkout_url = attributes.get("checkout_url")

    if not checkout_url:
        raise RuntimeError(
            "PayMongo did not return a checkout URL."
        )

    return {
        "checkout_session_id": checkout_data.get("id"),
        "checkout_url": checkout_url,
        "reference_number": attributes.get(
            "reference_number"
        ),
    }


def verify_and_parse_webhook(raw_body: bytes, signature_header: str) -> dict:
    """
    Verifies a PayMongo webhook request against the Paymongo-Signature
    header and returns the parsed event as a dict.

    Raises ValueError if the header is missing/malformed or the computed
    signature doesn't match — callers should treat that as an untrusted
    request and reject it with a 400, not process it.
    """
    if not signature_header:
        raise ValueError("Missing Paymongo-Signature header.")

    parts: dict[str, str] = {}
    for chunk in signature_header.split(","):
        if "=" not in chunk:
            continue
        key, _, value = chunk.partition("=")
        parts[key.strip()] = value.strip()

    timestamp = parts.get("t")
    test_signature = parts.get("te")

    if not timestamp or not test_signature:
        raise ValueError("Malformed Paymongo-Signature header.")

    # Signed payload = "<timestamp>." + the exact raw bytes PayMongo sent.
    # Must use raw bytes here, not a re-serialized/parsed version, or the
    # HMAC will never match even for a legitimate request.
    signed_payload = f"{timestamp}.".encode("utf-8") + raw_body

    webhook_secret = get_paymongo_webhook_secret()
    computed_signature = hmac.new(
        webhook_secret.encode("utf-8"),
        signed_payload,
        hashlib.sha256,
    ).hexdigest()

    # `te` = test-mode signature. Switch to comparing `li` only once this
    # integration is using a live (sk_live_...) secret key.
    if not hmac.compare_digest(computed_signature, test_signature):
        raise ValueError("Signature verification failed.")

    return json.loads(raw_body)