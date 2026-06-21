import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';
import 'package:virtual_catalog_app/domain/entities/message_type.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.recipientId,
    required super.senderId,
    required super.senderName,
    required super.content,
    super.id,
    super.timestamp,
    super.isRead,
    super.type,
    super.media,
    super.status,
    super.whatsappMessageId,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedTime;
    try {
      final rawTime = map['timestamp'];
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

    return MessageModel(
      id: id,
      recipientId: map['recipientId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: parsedTime,
      isRead: map['isRead'] ?? false,
      type: MessageType.fromString(map['type'] ?? 'text'),
      media: map['media'] as String?,
      status: map['status'] as String?,
      whatsappMessageId: map['whatsappMessageId'] as String?,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'isRead': isRead,
      'type': type.name,
      'media': media,
      'status': status,
      'whatsappMessageId': whatsappMessageId,
    };
  }
}
