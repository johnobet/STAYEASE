/// Domain models for the Owner side. Kept separate from tenant_models.dart
/// even though some concepts overlap (e.g. a reservation) — the owner and
/// tenant see different shapes of the same underlying Firestore data, and
/// keeping them as distinct types avoids one screen accidentally depending
/// on fields that only make sense for the other role.

class OwnerProperty {
  const OwnerProperty({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerMonth,
    required this.availableRooms,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int pricePerMonth;
  final int availableRooms;
  final bool isVerified;

  String get formattedPrice => '₱${pricePerMonth.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';
}

enum ReservationRequestStatus { pending, approved, rejected }

class ReservationRequest {
  const ReservationRequest({
    required this.id,
    required this.propertyName,
    required this.propertyImageUrl,
    required this.roomLabel,
    required this.checkInDate,
    required this.tenantId,
    required this.status,
  });

  final String id;
  final String propertyName;
  final String propertyImageUrl;
  final String roomLabel;
  final DateTime checkInDate;
  final String tenantId;
  final ReservationRequestStatus status;

  /// Short, readable stand-in for the tenant's identity until the owner
  /// side has permission to read tenant profile names (would need a
  /// security rule change — out of scope for now; see BACKEND notes).
  String get tenantShortId => tenantId.length > 6 ? tenantId.substring(0, 6) : tenantId;
}
