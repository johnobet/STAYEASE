import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import '../models/reservation_model.dart';

class ReservationService {
  ReservationService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reservations => _firestore.collection('reservations');

  /// All reservations across every property this owner has. Filter client
  /// side by status for the Pending/All tabs — keeps this to a single
  /// index (ownerId + createdAt) instead of one per status.
  Stream<List<ReservationModel>> watchOwnerReservations(String ownerId) {
    return _reservations
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ReservationModel.fromMap(d.id, d.data())).toList());
  }

  /// A tenant's own reservation history, newest first.
  Stream<List<ReservationModel>> watchTenantReservations(String tenantId) {
    return _reservations
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ReservationModel.fromMap(d.id, d.data())).toList());
  }

  /// Tenant creates a reservation request — always starts 'pending'; the
  /// Firestore rules only allow tenant-created docs at that status, so an
  /// owner has to explicitly approve before it becomes real.
  Future<void> createReservation({
    required String tenantId,
    required String tenantName,
    required PropertyModel property,
    required DateTime checkInDate,
  }) async {
    final reservation = ReservationModel(
      id: '',
      tenantId: tenantId,
      ownerId: property.ownerId,
      propertyId: property.id,
      checkInDate: checkInDate,
      status: ReservationStatus.pending,
      tenantName: tenantName,
      propertyName: property.name,
      priceLabel: '₱${property.pricePerMonth.toStringAsFixed(0)}',
    );
    await _reservations.add(reservation.toMap());
  }

  Future<void> approve(String reservationId) {
    return _reservations.doc(reservationId).update({'status': ReservationStatus.approved.value});
  }

  Future<void> reject(String reservationId) {
    return _reservations.doc(reservationId).update({'status': ReservationStatus.rejected.value});
  }
}

