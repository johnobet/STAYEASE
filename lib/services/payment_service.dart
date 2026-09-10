import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class PaymentException implements Exception {
  PaymentException(this.message);
  final String message;

  @override
  String toString() => message;
}

class PaymentService {
  PaymentService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _payments => _firestore.collection('rentPayments');

  /// One rentPayments doc per reservation — reusing the reservation's own
  /// Firestore ID keeps a stable 1:1 link without extra bookkeeping.
  /// Safe to call every time the payment screen opens: does nothing if a
  /// record already exists (so it never overwrites an in-progress or
  /// already-paid payment).
  Future<void> ensurePaymentDoc({
    required String reservationId,
    required String tenantId,
    required int amountCentavos,
  }) async {
    final ref = _payments.doc(reservationId);
    final existing = await ref.get();
    if (existing.exists) return;

    await ref.set({
      'tenantId': tenantId,
      'amount': amountCentavos,
      'isPaid': false,
      'status': 'unpaid',
      'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
    });
  }

  /// Live payment status — the webhook (via the backend's Admin SDK)
  /// flips `isPaid`/`status` here once PayMongo confirms the charge, and
  /// this stream pushes that update straight into the UI.
  Stream<Map<String, dynamic>?> watchPayment(String reservationId) {
    return _payments.doc(reservationId).snapshots().map((doc) => doc.data());
  }

  /// Calls the FastAPI backend to create a PayMongo checkout session for
  /// this reservation's payment record, returning the checkout URL to
  /// open in the browser.
  Future<String> requestCheckoutUrl(String reservationId) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/payments/test-checkout/$reservationId');

    http.Response response;
    try {
      response = await http.post(uri).timeout(const Duration(seconds: 20));
    } catch (_) {
      throw PaymentException(
        "Could not reach the payment server. Make sure it's running and the URL in AppConfig is current.",
      );
    }

    if (response.statusCode >= 400) {
      throw PaymentException('Payment server error (${response.statusCode}). Please try again.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final checkoutUrl = body['checkout_url'] as String?;
    if (checkoutUrl == null) {
      throw PaymentException('The payment server did not return a checkout link.');
    }
    return checkoutUrl;
  }
}
