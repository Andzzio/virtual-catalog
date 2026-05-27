class Conversation {
  final String id;
  final String clientName;
  final String clientPhone;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  Conversation copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
