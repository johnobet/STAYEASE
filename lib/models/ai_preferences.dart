/// What the tenant tells the recommendation engine they're looking for.
/// Deliberately simple and session-only for now (not persisted to
/// Firestore) — matches spec section 10's "AI Assistant" input shape
/// without needing a new collection yet.
class AIPreferences {
  const AIPreferences({
    this.maxBudget,
    this.maxDistanceMeters,
    this.preferredAmenities = const {},
  });

  final num? maxBudget;
  final int? maxDistanceMeters;
  final Set<String> preferredAmenities;

  bool get isSet => maxBudget != null || maxDistanceMeters != null || preferredAmenities.isNotEmpty;
}
