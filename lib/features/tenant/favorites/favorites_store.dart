import 'package:flutter/foundation.dart';

/// Temporary in-memory favorites store shared across Tenant screens.
///
/// This is intentionally persistence-agnostic. When Firestore is wired up,
/// the persistence layer can be replaced without changing the UI.
class FavoritesStore {
  FavoritesStore._();

  static final ValueNotifier<Set<String>> ids =
      ValueNotifier<Set<String>>(<String>{});

  static bool contains(String propertyId) => ids.value.contains(propertyId);

  static void toggle(String propertyId) {
    final next = Set<String>.from(ids.value);
    if (!next.add(propertyId)) {
      next.remove(propertyId);
    }
    ids.value = Set.unmodifiable(next);
  }

  static void clear() => ids.value = const <String>{};
}
