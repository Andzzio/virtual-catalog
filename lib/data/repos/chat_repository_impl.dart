import 'package:virtual_catalog_app/domain/datasources/chat_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/repos/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDatasource datasource;

  ChatRepositoryImpl({required this.datasource});

  @override
  Stream<List<Conversation>> getConversations(String businessSlug) {
    return datasource.getConversations(businessSlug);
  }

  @override
  Stream<List<ChatMessage>> getMessages(String businessSlug, String conversationId) {
    return datasource.getMessages(businessSlug, conversationId);
  }

  @override
  Future<void> sendMessage(String businessSlug, String conversationId, ChatMessage message) {
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
}
