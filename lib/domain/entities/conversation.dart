import 'package:virtual_catalog_app/domain/entities/contact_entity.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';

class ConversationEntity {
  final String id;
  final ContactEntity contact;
  final MessageEntity? lastMessage;
  final int unreadCount;
  final List<MessageEntity> messages;
  final bool isBotActive;

  ConversationEntity({
    required this.id,
    required this.contact,
    this.lastMessage,
    required this.unreadCount,
    List<MessageEntity>? messages,
    this.isBotActive = true,
  }) : messages = messages ?? [];

  ConversationEntity copyWith({
    String? id,
    ContactEntity? contact,
    MessageEntity? lastMessage,
    int? unreadCount,
    List<MessageEntity>? messages,
    bool? isBotActive,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      contact: contact ?? this.contact,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
      isBotActive: isBotActive ?? this.isBotActive,
    );
  }
}
