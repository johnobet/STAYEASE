import 'package:cloud_firestore/cloud_firestore.dart';

/// Statuses per spec section 18.
enum ReservationStatus { pending, approved, rejected, reserved, checkedIn, completed, cancelled }

extension ReservationStatusX on ReservationStatus {
  String get value {
    switch (this) {
      case ReservationStatus.checkedIn:
        return 'checkedIn';
      default:
        return name;
    }
  }

  static ReservationStatus fromString(String? value) {
    switch (value) {
      case 'approved':
        return ReservationStatus.approved;
      case 'rejected':
        return ReservationStatus.rejected;
      case 'reserved':
        return ReservationStatus.reserved;
      case 'checkedIn':
        return ReservationStatus.checkedIn;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'pending':
      default:
        return ReservationStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.approved:
        return 'Approved';
      case ReservationStatus.rejected:
        return 'Rejected';
      case ReservationStatus.reserved:
        return 'Reserved';
      case ReservationStatus.checkedIn:
        return 'Checked In';
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class ReservationModel {
  const ReservationModel({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.propertyId,
    required this.checkInDate,
    required this.status,
    this.paymentStatus = 'unpaid',
    this.createdAt,
    // Denormalized, written at creation time, so list screens don't need
    // an extra fetch per row.
    this.tenantName = '',
    this.propertyName = '',
    this.priceLabel = '',
  });

  final String id;
  final String tenantId;
  final String ownerId;
  final String propertyId;
  final DateTime checkInDate;
  final ReservationStatus status;
  final String paymentStatus; // unpaid | paid
  final DateTime? createdAt;

  final String tenantName;
  final String propertyName;
  final String priceLabel;

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'ownerId': ownerId,
      'propertyId': propertyId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'status': status.value,
      'paymentStatus': paymentStatus,
      'createdAt': FieldValue.serverTimestamp(),
      'tenantName': tenantName,
      'propertyName': propertyName,
      'priceLabel': priceLabel,
    };
  }

  factory ReservationModel.fromMap(String id, Map<String, dynamic> map) {
    final checkIn = map['checkInDate'];
    final createdAt = map['createdAt'];
    return ReservationModel(
      id: id,
      tenantId: map['tenantId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      propertyId: map['propertyId'] as String? ?? '',
      checkInDate: checkIn is Timestamp ? checkIn.toDate() : DateTime.now(),
      status: ReservationStatusX.fromString(map['status'] as String?),
      paymentStatus: map['paymentStatus'] as String? ?? 'unpaid',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      tenantName: map['tenantName'] as String? ?? '',
      propertyName: map['propertyName'] as String? ?? '',
      priceLabel: map['priceLabel'] as String? ?? '',
    );
  }
}
