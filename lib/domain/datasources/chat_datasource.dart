import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';

abstract class ChatDatasource {
  Stream<List<Conversation>> getConversations(String businessSlug);
  Stream<List<ChatMessage>> getMessages(String businessSlug, String conversationId);
  Future<void> sendMessage(String businessSlug, String conversationId, ChatMessage message);
  Future<void> markAsRead(String businessSlug, String conversationId);
  Future<void> simulateIncomingMessage(String businessSlug, String conversationId, String content);
  Future<void> initializeMockData(String businessSlug);
}
