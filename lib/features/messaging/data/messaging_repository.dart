import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_models.dart';

/// Real data layer for 1:1 tenant-owner messaging, backed by Firestore.
/// Schema:
///   threads/{threadId}                     — metadata + last message preview
///   threads/{threadId}/messages/{messageId} — individual messages
///
/// threadId is deterministic: the two participant uids, sorted and
/// joined, so either side can compute the same id independently
/// without needing a lookup first.
class MessagingRepository {
  MessagingRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _threads => _db.collection('threads');

  String threadIdFor(String tenantId, String ownerId) {
    final sorted = [tenantId, ownerId]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Ensures a thread doc exists for this (tenant, owner) pair — creates
  /// it with an empty preview if it's the first contact, otherwise
  /// leaves the existing one untouched. Called before opening a chat
  /// from Property Details' "Message" button.
  Future<String> getOrCreateThread({
    required String tenantId,
    required String ownerId,
    required String propertyName,
    required String propertyImageUrl,
  }) async {
    final id = threadIdFor(tenantId, ownerId);
    final doc = _threads.doc(id);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'tenantId': tenantId,
        'ownerId': ownerId,
        'participantIds': [tenantId, ownerId],
        'propertyName': propertyName,
        'propertyImageUrl': propertyImageUrl,
        'lastMessageText': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': '',
      });
    }
    return id;
  }

  /// All threads the current user participates in, newest activity first.
  Stream<List<ChatThread>> watchThreads(String uid) {
    return _threads
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _threadFromDoc(d)).toList());
  }

  ChatThread _threadFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatThread(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      propertyName: data['propertyName'] ?? '',
      propertyImageUrl: data['propertyImageUrl'] ?? '',
      lastMessageText: data['lastMessageText'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastSenderId: data['lastSenderId'] ?? '',
    );
  }

  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _threads
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return ChatMessage(
                id: d.id,
                senderId: data['senderId'] ?? '',
                text: data['text'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }

  Future<void> sendMessage({required String threadId, required String senderId, required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final batch = _db.batch();
    final messageDoc = _threads.doc(threadId).collection('messages').doc();
    batch.set(messageDoc, {
      'senderId': senderId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_threads.doc(threadId), {
      'lastMessageText': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
    await batch.commit();
  }
}
