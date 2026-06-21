import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/contact_model.dart';
import 'package:virtual_catalog_app/data/models/message_model.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required super.id,
    required super.contact,
    super.lastMessage,
    required super.unreadCount,
    super.messages,
    super.isBotActive,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final contactData = data['contact'] as Map<String, dynamic>? ?? {};
    final lastMessageData = data['lastMessage'] as Map<String, dynamic>?;

    return ConversationModel(
      id: doc.id,
      contact: ContactModel.fromMap(contactData),
      lastMessage: lastMessageData != null ? MessageModel.fromMap(lastMessageData) : null,
      unreadCount: data['unreadCount'] ?? 0,
      isBotActive: data['isBotActive'] ?? true,
    );
  }

  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      contact: entity.contact,
      lastMessage: entity.lastMessage,
      unreadCount: entity.unreadCount,
      messages: entity.messages,
      isBotActive: entity.isBotActive,
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      contact: contact,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      messages: messages,
      isBotActive: isBotActive,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'contact': (contact as ContactModel).toMap(),
      'lastMessage': lastMessage != null ? (lastMessage as MessageModel).toFirestore() : null,
      'unreadCount': unreadCount,
      'isBotActive': isBotActive,
    };
  }
}
