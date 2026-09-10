import '../models/ai_preferences.dart';
import '../models/property_model.dart';

/// The per-criterion breakdown behind a match score — this is what makes
/// the recommendation *explainable* rather than a black-box number, per
/// spec section 10: "AI recommendation must be explainable and should
/// not simply return an unexplained score."
class MatchScoreResult {
  const MatchScoreResult({
    required this.percent,
    required this.budgetScore,
    required this.distanceScore,
    required this.amenitiesScore,
    required this.ratingScore,
    required this.availabilityScore,
  });

  final int percent;
  final int budgetScore;
  final int distanceScore;
  final int amenitiesScore;
  final int ratingScore;
  final int availabilityScore;
}

/// Rule-based weighted scoring — no ML model, no external AI API. This is
/// intentional: it's Level 1–2 of the spec's AI architecture (section 33),
/// "Rule-Based Recommendation" + "Weighted Recommendation". Level 3 (ML)
/// and Level 4 (LLM assistant) are future-phase work.
///
/// Weights are adapted from spec section 11. The original split includes
/// a 15% "Room preference" criterion; since the current data model has no
/// per-room type field (rooms were simplified to a single availableRooms
/// count on the property), that weight was folded into Amenities and
/// Rating instead of left unused.
class AIMatchService {
  static const _budgetWeight = 0.35;
  static const _distanceWeight = 0.20;
  static const _amenitiesWeight = 0.20;
  static const _ratingWeight = 0.15;
  static const _availabilityWeight = 0.10;

  MatchScoreResult score(PropertyModel property, AIPreferences prefs) {
    final budgetScore = _budgetScore(property, prefs);
    final distanceScore = _distanceScore(property, prefs);
    final amenitiesScore = _amenitiesScore(property, prefs);
    final ratingScore = ((property.rating / 5) * 100).clamp(0, 100).round();
    final availabilityScore = property.availableRooms > 0 ? 100 : 0;

    final weighted = budgetScore * _budgetWeight +
        distanceScore * _distanceWeight +
        amenitiesScore * _amenitiesWeight +
        ratingScore * _ratingWeight +
        availabilityScore * _availabilityWeight;

    return MatchScoreResult(
      percent: weighted.clamp(0, 100).round(),
      budgetScore: budgetScore,
      distanceScore: distanceScore,
      amenitiesScore: amenitiesScore,
      ratingScore: ratingScore,
      availabilityScore: availabilityScore,
    );
  }

  int _budgetScore(PropertyModel property, AIPreferences prefs) {
    if (prefs.maxBudget == null) return 100;
    final budget = prefs.maxBudget!;
    if (property.pricePerMonth <= budget) return 100;
    final overRatio = (property.pricePerMonth - budget) / budget;
    return (100 - overRatio * 100).clamp(0, 100).round();
  }

  int _distanceScore(PropertyModel property, AIPreferences prefs) {
    // No distance preference set, or the property has no distance data —
    // neither is a strike against it, so score neutrally rather than 0.
    if (prefs.maxDistanceMeters == null || property.distanceMeters == null) return 70;
    final maxDistance = prefs.maxDistanceMeters!;
    final distance = property.distanceMeters!;
    if (distance <= maxDistance) return 100;
    final overRatio = (distance - maxDistance) / maxDistance;
    return (100 - overRatio * 100).clamp(0, 100).round();
  }

  int _amenitiesScore(PropertyModel property, AIPreferences prefs) {
    if (prefs.preferredAmenities.isEmpty) return 100;
    final matched = prefs.preferredAmenities.where((a) => property.amenities.contains(a)).length;
    return ((matched / prefs.preferredAmenities.length) * 100).round();
  }

  /// Plain-language explanation matching the tone of spec section 10's
  /// worked example ("This property is recommended because..."). Only
  /// cites criteria that actually scored well — it doesn't claim a
  /// property fits a budget it doesn't fit.
  String explain(PropertyModel property, AIPreferences prefs, MatchScoreResult result) {
    final reasons = <String>[];

    if (prefs.maxBudget != null && result.budgetScore >= 90) {
      reasons.add('fits your ₱${prefs.maxBudget!.toStringAsFixed(0)} budget');
    }
    if (prefs.maxDistanceMeters != null &&
        property.distanceMeters != null &&
        result.distanceScore >= 90) {
      reasons.add('is about ${property.distanceMeters}m from your preferred location');
    }
    if (prefs.preferredAmenities.isNotEmpty && result.amenitiesScore >= 90) {
      reasons.add('includes ${prefs.preferredAmenities.join(", ")}');
    }
    if (result.availabilityScore == 100) {
      reasons.add('currently has rooms available');
    }
    if (result.ratingScore >= 90) {
      reasons.add('is highly rated by other tenants');
    }

    if (reasons.isEmpty) {
      return "This property doesn't closely match your stated preferences, "
          'but is shown here as one of the available options.';
    }

    final body = reasons.length == 1
        ? reasons.first
        : '${reasons.sublist(0, reasons.length - 1).join(", ")}, and ${reasons.last}';

    return 'This property is recommended because it $body.';
  }
}
