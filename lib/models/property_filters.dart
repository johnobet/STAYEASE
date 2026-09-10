import '../models/property_model.dart';

/// Filter criteria selected by the tenant. Matching happens client-side
/// against the already-fetched property list — the demo-scale dataset
/// doesn't need server-side compound queries for this, and it keeps the
/// filter combinations fully flexible without needing a new Firestore
/// index for every combination.
class PropertyFilters {
  const PropertyFilters({
    this.maxPrice,
    this.minRating = 0,
    this.maxDistanceMeters,
    this.verifiedOnly = false,
    this.amenities = const {},
  });

  final num? maxPrice;
  final double minRating;
  final int? maxDistanceMeters;
  final bool verifiedOnly;
  final Set<String> amenities;

  bool get isActive =>
      maxPrice != null || minRating > 0 || maxDistanceMeters != null || verifiedOnly || amenities.isNotEmpty;

  int get activeCount {
    var count = 0;
    if (maxPrice != null) count++;
    if (minRating > 0) count++;
    if (maxDistanceMeters != null) count++;
    if (verifiedOnly) count++;
    if (amenities.isNotEmpty) count++;
    return count;
  }

  bool matches(PropertyModel property) {
    if (maxPrice != null && property.pricePerMonth > maxPrice!) return false;
    if (property.rating < minRating) return false;
    if (maxDistanceMeters != null) {
      if (property.distanceMeters == null || property.distanceMeters! > maxDistanceMeters!) return false;
    }
    if (verifiedOnly && !property.isVerified) return false;
    if (amenities.isNotEmpty && !amenities.every((a) => property.amenities.contains(a))) return false;
    return true;
  }

  PropertyFilters copyWith({
    num? maxPrice,
    bool clearMaxPrice = false,
    double? minRating,
    int? maxDistanceMeters,
    bool clearMaxDistance = false,
    bool? verifiedOnly,
    Set<String>? amenities,
  }) {
    return PropertyFilters(
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minRating: minRating ?? this.minRating,
      maxDistanceMeters: clearMaxDistance ? null : (maxDistanceMeters ?? this.maxDistanceMeters),
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      amenities: amenities ?? this.amenities,
    );
  }
}

/// Amenity options — matches spec section 8, shared with the Add Property
/// form so filter chips and listing data always speak the same vocabulary.
const kAmenityOptions = [
  'Wi-Fi', 'Private bathroom', 'Shared bathroom', 'Kitchen', 'Laundry',
  'Parking', 'Air conditioning', 'Fan', 'Study area', 'Water supply',
  'Electricity inclusion',
];
