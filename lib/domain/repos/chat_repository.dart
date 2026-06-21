import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ConversationEntity>> getConversations(String businessSlug);
  Stream<List<MessageEntity>> getMessages(String businessSlug, String conversationId, {int? limit});
  Future<void> sendMessage(String businessSlug, String conversationId, MessageEntity message);
  Future<void> markAsRead(String businessSlug, String conversationId);
  Future<void> simulateIncomingMessage(String businessSlug, String conversationId, String content);
  Future<void> initializeMockData(String businessSlug);
  Future<void> toggleBotStatus(String businessSlug, String conversationId, bool isActive);
  Future<String> getAiSuggestion(String businessSlug, String conversationId, String clientName);
}
