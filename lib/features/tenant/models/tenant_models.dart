/// Domain models for the tenant dashboard and property discovery.
///
/// These mirror the shape data will eventually take in Firestore
/// (properties/{id}, reservations/{id}) so swapping the mock
/// TenantDashboardRepository for a Firestore-backed one later requires
/// no changes to the UI layer.

class Property {
  const Property({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerMonth,
    required this.distanceMeters,
    required this.rating,
    required this.isVerified,
    required this.availableRooms,
    this.gallery = const [],
    this.description = '',
    this.amenities = const [],
    this.ownerName = '',
    this.ownerId = '',
    this.reviewCount = 0,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int pricePerMonth;
  final int distanceMeters;
  final double rating;
  final bool isVerified;
  final int availableRooms;

  /// Additional photos beyond [imageUrl] for the details gallery.
  /// Empty is fine — the gallery falls back to just [imageUrl].
  final List<String> gallery;
  final String description;
  final List<String> amenities;
  final String ownerName;
  final String ownerId;
  final int reviewCount;

  List<String> get allPhotos => [imageUrl, ...gallery];

  String get formattedPrice => '₱${pricePerMonth.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';

  String get formattedDistance =>
      distanceMeters < 1000 ? '${distanceMeters}m away' : '${(distanceMeters / 1000).toStringAsFixed(1)}km away';
}

class MatchRecommendation {
  const MatchRecommendation({required this.property, required this.matchScore, required this.reason});

  final Property property;
  final int matchScore; // 0-100
  final String reason;
}

class ActiveReservation {
  const ActiveReservation({
    required this.propertyName,
    required this.roomLabel,
    required this.checkInDate,
    required this.propertyImageUrl,
  });

  final String propertyName;
  final String roomLabel;
  final DateTime checkInDate;
  final String propertyImageUrl;
}

class RentStatus {
  const RentStatus({required this.amount, required this.dueDate, required this.isPaid});

  final int amount;
  final DateTime dueDate;
  final bool isPaid;

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  String get formattedAmount => '₱${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';
}

enum NotificationKind { reservationApproved, paymentReceived, rentReminder, maintenance, checkInReminder }

class TenantNotification {
  const TenantNotification({required this.kind, required this.title, required this.timeAgo});

  final NotificationKind kind;
  final String title;
  final String timeAgo;
}

/// Status of a reservation, as stored on the Firestore doc's `status`
/// field. `pending` → awaiting owner approval (item 44, not yet built,
/// so requests stay pending until an owner flow can flip them).
/// `active` → approved and current. `completed` → stay has ended.
/// `cancelled` → tenant or owner cancelled before/during the stay.
enum ReservationStatus { pending, active, completed, cancelled }

extension ReservationStatusX on ReservationStatus {
  String get label => switch (this) {
        ReservationStatus.pending => 'Pending',
        ReservationStatus.active => 'Active',
        ReservationStatus.completed => 'Completed',
        ReservationStatus.cancelled => 'Cancelled',
      };

  bool get isUpcoming => this == ReservationStatus.pending || this == ReservationStatus.active;
}

class TenantReservation {
  const TenantReservation({
    required this.id,
    required this.propertyName,
    required this.propertyImageUrl,
    required this.roomLabel,
    required this.checkInDate,
    required this.status,
  });

  final String id;
  final String propertyName;
  final String propertyImageUrl;
  final String roomLabel;
  final DateTime checkInDate;
  final ReservationStatus status;
}
