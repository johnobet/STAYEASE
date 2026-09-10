import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant_models.dart';

/// Real data layer for the tenant side, backed by Cloud Firestore.
///
/// Collections used (see BACKEND.md for full schema):
/// - `properties/{propertyId}`      — public, read by all signed-in users
/// - `reservations/{reservationId}` — scoped to `tenantId`
/// - `rentPayments/{paymentId}`     — scoped to `tenantId`
/// - `users/{uid}/notifications/{notificationId}` — scoped to the user
///
/// This class is the ONLY place that talks to Firestore for tenant
/// features. Screens/widgets consume the plain domain models in
/// `tenant_models.dart` and never see a `DocumentSnapshot` — this keeps
/// the UI layer identical to when it ran on `MockTenantData`.
class TenantRepository {
  TenantRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _properties => _db.collection('properties');
  CollectionReference<Map<String, dynamic>> get _reservations => _db.collection('reservations');
  CollectionReference<Map<String, dynamic>> get _rentPayments => _db.collection('rentPayments');

  // ---------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------

  /// Live list of properties, ordered by distance (nearest first).
  /// Used by Home's "Places around you" row and as the base list Explore
  /// filters client-side. For now "distance" is a stored field on the
  /// property doc (computed at listing time) rather than a live geo
  /// query — swap for a geohash/Mapbox-based query when item 38/48 lands.
  Stream<List<Property>> watchNearbyProperties({int limit = 20}) {
    return _properties
        .orderBy('distanceMeters')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _propertyFromDoc(d)).toList());
  }

  /// Full catalog for the Explore tab — filtering (price/distance/
  /// verified/search text) happens client-side on this list, same as
  /// it did against MockTenantData. Move filters server-side once the
  /// catalog grows large enough that client-side filtering is wasteful.
  Stream<List<Property>> watchAllProperties() {
    return _properties.snapshots().map((snap) => snap.docs.map((d) => _propertyFromDoc(d)).toList());
  }

  Future<Property?> fetchProperty(String propertyId) async {
    final doc = await _properties.doc(propertyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return _propertyFromDoc(doc);
  }

  Property _propertyFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Property(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      gallery: List<String>.from(data['gallery'] ?? const []),
      pricePerMonth: (data['pricePerMonth'] ?? 0) as int,
      distanceMeters: (data['distanceMeters'] ?? 0) as int,
      rating: (data['rating'] ?? 0).toDouble(),
      isVerified: data['isVerified'] ?? false,
      availableRooms: (data['availableRooms'] ?? 0) as int,
      description: data['description'] ?? '',
      amenities: List<String>.from(data['amenities'] ?? const []),
      ownerName: data['ownerName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      reviewCount: (data['reviewCount'] ?? 0) as int,
    );
  }

  // ---------------------------------------------------------------------
  // AI Match — STUB. Real scoring (items 39-42) belongs in a Cloud
  // Function or backend endpoint that considers tenant preferences,
  // budget, and past behavior. For now this picks the closest verified
  // property under budget as a placeholder so the UI has something real
  // (not hardcoded) to render while the AI engine is built.
  // ---------------------------------------------------------------------

  Future<MatchRecommendation?> fetchTopMatch({required int tenantBudget}) async {
    final snap = await _properties
        .where('isVerified', isEqualTo: true)
        .where('pricePerMonth', isLessThanOrEqualTo: tenantBudget)
        .orderBy('pricePerMonth')
        .orderBy('distanceMeters')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final property = _propertyFromDoc(snap.docs.first);
    return MatchRecommendation(
      property: property,
      matchScore: 94, // placeholder until real scoring model is wired in
      reason: 'Fits your budget, preferred room type, and distance.',
    );
  }

  // ---------------------------------------------------------------------
  // Reservations
  // ---------------------------------------------------------------------

  /// The tenant's current active reservation, if any. `null` stream value
  /// means "no active reservation" — a legitimate, non-error state.
  Stream<ActiveReservation?> watchActiveReservation(String tenantId) {
    return _reservations
        .where('tenantId', isEqualTo: tenantId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final data = snap.docs.first.data();
      return ActiveReservation(
        propertyName: data['propertyName'] ?? '',
        roomLabel: data['roomLabel'] ?? '',
        checkInDate: (data['checkInDate'] as Timestamp).toDate(),
        propertyImageUrl: data['propertyImageUrl'] ?? '',
      );
    });
  }

  Future<void> createReservation({
    required String tenantId,
    required Property property,
    required String roomLabel,
    required DateTime checkInDate,
  }) async {
    await _reservations.add({
      'tenantId': tenantId,
      'ownerId': property.ownerId, // denormalized so Owner side can query its own requests directly
      'propertyId': property.id,
      'propertyName': property.name,
      'propertyImageUrl': property.imageUrl,
      'roomLabel': roomLabel,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'status': 'pending', // owner approval flow (item 44) flips this to 'active'/'cancelled'
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------
  // Rent / payments
  // ---------------------------------------------------------------------

  Stream<RentStatus?> watchRentStatus(String tenantId) {
    return _rentPayments
        .where('tenantId', isEqualTo: tenantId)
        .where('isPaid', isEqualTo: false)
        .orderBy('dueDate')
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final data = snap.docs.first.data();
      return RentStatus(
        amount: (data['amount'] ?? 0) as int,
        dueDate: (data['dueDate'] as Timestamp).toDate(),
        isPaid: data['isPaid'] ?? false,
      );
    });
  }

  // ---------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------

  Stream<List<TenantNotification>> watchNotifications(String uid, {int limit = 20}) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return TenantNotification(
                kind: _kindFromString(data['kind'] ?? ''),
                title: data['title'] ?? '',
                timeAgo: _timeAgo((data['createdAt'] as Timestamp?)?.toDate()),
              );
            }).toList());
  }

  NotificationKind _kindFromString(String s) {
    return NotificationKind.values.firstWhere(
      (k) => k.name == s,
      orElse: () => NotificationKind.maintenance,
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Full reservation history for the Bookings tab — pending, active,
  /// completed, cancelled, newest first.
  Stream<List<TenantReservation>> watchReservations(String tenantId) {
    return _reservations
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _reservationFromDoc(d)).toList());
  }

  Future<void> cancelReservation(String reservationId) async {
    await _reservations.doc(reservationId).update({'status': 'cancelled'});
  }

  TenantReservation _reservationFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TenantReservation(
      id: doc.id,
      propertyName: data['propertyName'] ?? '',
      propertyImageUrl: data['propertyImageUrl'] ?? '',
      roomLabel: data['roomLabel'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _statusFromString(data['status'] ?? 'pending'),
    );
  }

  ReservationStatus _statusFromString(String s) {
    return ReservationStatus.values.firstWhere(
      (v) => v.name == s,
      orElse: () => ReservationStatus.pending,
    );
  }

  // ---------------------------------------------------------------------
  // Favorites — stored at users/{uid}/favorites/{propertyId} (doc
  // existence = favorited; no fields needed beyond a timestamp for
  // sorting). Kept as a subcollection of the user, not a field on the
  // user doc, so it scales past Firestore's 1MB document limit and so
  // rules can restrict it to the owning user cleanly.
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> _favorites(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  Stream<Set<String>> watchFavoriteIds(String uid) {
    return _favorites(uid).snapshots().map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> setFavorite(String uid, String propertyId, bool isFavorite) async {
    final doc = _favorites(uid).doc(propertyId);
    if (isFavorite) {
      await doc.set({'savedAt': FieldValue.serverTimestamp()});
    } else {
      await doc.delete();
    }
  }

  /// Full [Property] objects for everything the tenant has favorited.
  /// Firestore's `whereIn` caps at 30 ids per query — fine for a
  /// favorites list at this app's scale; batch this if that changes.
  Future<List<Property>> fetchFavoriteProperties(Set<String> ids) async {
    if (ids.isEmpty) return [];
    final snap = await _properties.where(FieldPath.documentId, whereIn: ids.toList()).get();
    return snap.docs.map((d) => _propertyFromDoc(d)).toList();
  }
}
