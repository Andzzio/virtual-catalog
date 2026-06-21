import 'package:virtual_catalog_app/domain/datasources/chat_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';
import 'package:virtual_catalog_app/domain/repos/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDatasource datasource;

  ChatRepositoryImpl({required this.datasource});

  @override
  Stream<List<ConversationEntity>> getConversations(String businessSlug) {
    return datasource.getConversations(businessSlug);
  }

  @override
  Stream<List<MessageEntity>> getMessages(String businessSlug, String conversationId, {int? limit}) {
    return datasource.getMessages(businessSlug, conversationId, limit: limit);
  }

  @override
  Future<void> sendMessage(String businessSlug, String conversationId, MessageEntity message) {
    return datasource.sendMessage(businessSlug, conversationId, message);
  }

  @override
  Future<void> markAsRead(String businessSlug, String conversationId) {
    return datasource.markAsRead(businessSlug, conversationId);
  }

  @override
  Future<void> simulateIncomingMessage(String businessSlug, String conversationId, String content) {
    return datasource.simulateIncomingMessage(businessSlug, conversationId, content);
  }

  @override
  Future<void> initializeMockData(String businessSlug) {
    return datasource.initializeMockData(businessSlug);
  }

  @override
  Future<void> toggleBotStatus(String businessSlug, String conversationId, bool isActive) {
    return datasource.toggleBotStatus(businessSlug, conversationId, isActive);
  }

  @override
  Future<String> getAiSuggestion(String businessSlug, String conversationId, String clientName) {
    return datasource.getAiSuggestion(businessSlug, conversationId, clientName);
  }
}
