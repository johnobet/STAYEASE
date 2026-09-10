/// Domain models for 1:1 messaging between a tenant and a property
/// owner. One thread per (tenant, owner) pair — kept simple for now:
/// all conversation about any property between the same two people
/// lives in one thread, rather than a separate thread per property.

class ChatThread {
  const ChatThread({
    required this.id,
    required this.tenantId,
    required this.ownerId,
    required this.propertyName,
    required this.propertyImageUrl,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.lastSenderId,
  });

  final String id;
  final String tenantId;
  final String ownerId;
  final String propertyName;
  final String propertyImageUrl;
  final String lastMessageText;
  final DateTime? lastMessageAt;
  final String lastSenderId;

  /// From [viewerId]'s perspective, the label for who's on the other end.
  String otherPartyLabel(String viewerId) => viewerId == tenantId ? 'Owner' : 'Tenant';
}

class ChatMessage {
  const ChatMessage({required this.id, required this.senderId, required this.text, required this.createdAt});

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
}
