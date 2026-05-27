import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.clientName,
    required super.clientPhone,
    super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCount,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime parsedTime;
    try {
      final rawTime = data['lastMessageTime'];
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
    return ConversationModel(
      id: doc.id,
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageTime: parsedTime,
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientName': clientName,
      'clientPhone': clientPhone,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
    };
  }
}
