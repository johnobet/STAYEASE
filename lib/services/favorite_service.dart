import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  FavoriteService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _favorites => _firestore.collection('favorites');

  // Deterministic doc ID (userId_propertyId) — makes "is this favorited"
  // a plain doc existence check instead of a query, and makes toggling
  // idempotent without needing to look anything up first.
  String _docId(String userId, String propertyId) => '${userId}_$propertyId';

  /// Live set of favorited property IDs for this tenant.
  Stream<Set<String>> watchFavoritePropertyIds(String userId) {
    return _favorites
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()['propertyId'] as String).toSet());
  }

  Future<void> toggleFavorite({
    required String userId,
    required String propertyId,
    required bool currentlyFavorited,
  }) async {
    final ref = _favorites.doc(_docId(userId, propertyId));
    if (currentlyFavorited) {
      await ref.delete();
    } else {
      await ref.set({
        'userId': userId,
        'propertyId': propertyId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
