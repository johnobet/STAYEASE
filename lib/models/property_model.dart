import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches the existing `properties` collection schema (already seeded
/// with p1–p8 for tenant browsing). New fields added here are additive
/// only — nothing existing was renamed or removed, so any tenant-side
/// screen already reading this collection keeps working unchanged.
///
/// New fields (won't exist on the old seed docs — that's fine, they
/// default safely below): ownerId, address, status, createdAt.
class PropertyModel {
  const PropertyModel({
    required this.id,
    required this.name,
    required this.description,
    this.ownerId = '',
    this.ownerName = '',
    this.address = '',
    this.amenities = const [],
    this.gallery = const [],
    this.imageUrl = '',
    this.isVerified = false,
    this.pricePerMonth = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.availableRooms = 0,
    this.distanceMeters,
    this.status = 'active',
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;

  // Existing fields (unchanged from the seeded schema)
  final String ownerName;
  final List<String> amenities;
  final List<String> gallery;
  final String imageUrl;
  final bool isVerified;
  final num pricePerMonth;
  final double rating;
  final int reviewCount;
  final int availableRooms;
  final int? distanceMeters;

  // New fields, only present on properties added through the Owner flow
  final String ownerId;
  final String address;
  final String status; // active | inactive
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'name': name,
      'description': description,
      'address': address,
      'amenities': amenities,
      'gallery': gallery,
      'imageUrl': gallery.isNotEmpty ? gallery.first : imageUrl,
      'isVerified': isVerified,
      'pricePerMonth': pricePerMonth,
      'rating': rating,
      'reviewCount': reviewCount,
      'availableRooms': availableRooms,
      'distanceMeters': distanceMeters,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PropertyModel.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];
    return PropertyModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      amenities: List<String>.from(map['amenities'] as List? ?? const []),
      gallery: List<String>.from(map['gallery'] as List? ?? const []),
      imageUrl: map['imageUrl'] as String? ?? '',
      isVerified: map['isVerified'] as bool? ?? false,
      pricePerMonth: (map['pricePerMonth'] as num?) ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      availableRooms: (map['availableRooms'] as num?)?.toInt() ?? 0,
      distanceMeters: (map['distanceMeters'] as num?)?.toInt(),
      status: map['status'] as String? ?? 'active',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
