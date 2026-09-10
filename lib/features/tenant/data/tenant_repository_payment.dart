import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles payment transactions and status streams for Tenants.
class PaymentRepository {
  final FirebaseFirestore _firestore;

  PaymentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Submits a reference number to mark a rent payment as paid
  Future<void> submitRentPayment({
    required String paymentId,
    required String referenceNumber,
  }) async {
    await _firestore.collection('rentPayments').doc(paymentId).update({
      'isPaid': true,
      'referenceNumber': referenceNumber,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Real-time stream of all rent payments for a specific tenant
  Stream<QuerySnapshot> watchRentStatus(String tenantId) {
    return _firestore
        .collection('rentPayments')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('dueDate', descending: false)
        .snapshots();
  }
}
