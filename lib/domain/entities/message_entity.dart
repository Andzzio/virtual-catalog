import 'package:virtual_catalog_app/domain/entities/message_type.dart';

class MessageEntity {
  final String? id;
  final String recipientId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime? timestamp;
  final bool isRead;
  final MessageType type;
  final String? media;
  final String? status;
  final String? whatsappMessageId;

  MessageEntity({
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.id,
    this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.media,
    this.status,
    this.whatsappMessageId,
  });

  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    String? recipientId,
    String? media,
    String? status,
    String? whatsappMessageId,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      recipientId: recipientId ?? this.recipientId,
      media: media ?? this.media,
      status: status ?? this.status,
      whatsappMessageId: whatsappMessageId ?? this.whatsappMessageId,
    );
  }
}
