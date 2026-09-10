import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/owner_models.dart';

/// Real data layer for the Owner side, backed by Cloud Firestore. Mirrors
/// TenantRepository's pattern: this is the only place Owner screens talk
/// to Firestore, everything else consumes plain domain models.
class OwnerRepository {
  OwnerRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _properties => _db.collection('properties');
  CollectionReference<Map<String, dynamic>> get _reservations => _db.collection('reservations');

  // ---------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------

  Stream<List<OwnerProperty>> watchMyProperties(String ownerId) {
    return _properties.where('ownerId', isEqualTo: ownerId).snapshots().map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return OwnerProperty(
              id: d.id,
              name: data['name'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
              pricePerMonth: (data['pricePerMonth'] ?? 0) as int,
              availableRooms: (data['availableRooms'] ?? 0) as int,
              isVerified: data['isVerified'] ?? false,
            );
          }).toList(),
        );
  }

  /// Creates a new listing owned by [ownerId]. `distanceMeters` and
  /// `rating` default to placeholder values since those normally come
  /// from geolocation (item 38, not built) and accumulated reviews
  /// (item 57, not built) respectively — an owner posting a brand-new
  /// property has neither yet.
  Future<void> createProperty({
    required String ownerId,
    required String ownerName,
    required String name,
    required String imageUrl,
    required int pricePerMonth,
    required int availableRooms,
    required String description,
    required List<String> amenities,
  }) async {
    await _properties.add({
      'ownerId': ownerId,
      'ownerName': ownerName,
      'name': name,
      'imageUrl': imageUrl,
      'gallery': <String>[],
      'pricePerMonth': pricePerMonth,
      'availableRooms': availableRooms,
      'distanceMeters': 1000, // placeholder until real geolocation (item 38)
      'rating': 0.0, // no reviews yet (item 57)
      'reviewCount': 0,
      'isVerified': false, // verification (item 56) is a separate, deliberate step
      'description': description,
      'amenities': amenities,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------
  // Reservation requests
  // ---------------------------------------------------------------------

  Stream<List<ReservationRequest>> watchPendingRequests(String ownerId) {
    return _reservations
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _requestFromDoc(d)).toList());
  }

  ReservationRequest _requestFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReservationRequest(
      id: doc.id,
      propertyName: data['propertyName'] ?? '',
      propertyImageUrl: data['propertyImageUrl'] ?? '',
      roomLabel: data['roomLabel'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tenantId: data['tenantId'] ?? '',
      status: ReservationRequestStatus.pending,
    );
  }

  /// Approving flips the reservation to `active` — this is what makes it
  /// show up as "Active" (not "Pending") on the tenant's Bookings tab,
  /// and is also what should eventually decrement `availableRooms` on
  /// the property (not yet wired — kept as a manual owner action for now).
  /// Also writes a notification to the tenant's inbox so they see it on
  /// Home without needing to check Bookings manually.
  Future<void> approveRequest(ReservationRequest request) async {
    await _reservations.doc(request.id).update({'status': 'active'});
    await _notifyTenant(
      tenantId: request.tenantId,
      kind: 'reservationApproved',
      title: 'Your reservation at ${request.propertyName} was approved',
    );
  }

  Future<void> rejectRequest(ReservationRequest request) async {
    await _reservations.doc(request.id).update({'status': 'cancelled'});
    await _notifyTenant(
      tenantId: request.tenantId,
      kind: 'maintenance', // reusing an existing NotificationKind; see tenant_models.dart
      title: 'Your reservation request at ${request.propertyName} was declined',
    );
  }

  /// Writes directly to users/{tenantId}/notifications — there's no
  /// Cloud Function relaying this yet, so the Owner client writes into
  /// the tenant's inbox directly. Firestore rules allow any signed-in
  /// user to CREATE (not read/update/delete) another user's notification
  /// doc specifically to support this pattern without a backend relay.
  Future<void> _notifyTenant({required String tenantId, required String kind, required String title}) async {
    await _db.collection('users').doc(tenantId).collection('notifications').add({
      'kind': kind,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
