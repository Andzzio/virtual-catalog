import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.isRead,
    required super.type,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime parsedTime;
    try {
      final rawTime = data['timestamp'];
      if (rawTime is Timestamp) {
        parsedTime = rawTime.toDate();
      } else if (rawTime is String) {
        parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
      } else {
        parsedTime = DateTime.now();
      }
    } catch (_) {
      parsedTime = DateTime.now();
    }
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: parsedTime,
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
    };
  }
}
