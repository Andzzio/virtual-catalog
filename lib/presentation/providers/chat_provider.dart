import 'package:flutter/material.dart';
import 'dart:async';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';
import 'package:virtual_catalog_app/domain/entities/message_type.dart';
import 'package:virtual_catalog_app/domain/repos/chat_repository.dart';
import 'package:virtual_catalog_app/domain/datasources/izipay_datasource.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository chatRepository;
  final IzipayDataSource izipayDataSource;

  ChatProvider({
    required this.chatRepository,
    required this.izipayDataSource,
  });

  List<ConversationEntity> conversations = [];
  List<MessageEntity> messages = [];
  ConversationEntity? selectedConversation;
  bool isLoading = false;
  bool isAiLoading = false;
  String? aiSuggestion;

  StreamSubscription<List<ConversationEntity>>? _conversationsSub;
  StreamSubscription<List<MessageEntity>>? _messagesSub;

  void initConversations(String businessSlug) {
    _conversationsSub?.cancel();
    _conversationsSub = chatRepository.getConversations(businessSlug).listen((list) {
      conversations = list;
      notifyListeners();
    });
  }

  int messagesLimit = 30;

  void selectConversation(String businessSlug, ConversationEntity conversation) {
    selectedConversation = conversation;
    messages = [];
    aiSuggestion = null;
    messagesLimit = 30;
    notifyListeners();

    _subscribeToMessages(businessSlug, conversation.id);

    chatRepository.markAsRead(businessSlug, conversation.id);
  }

  void _subscribeToMessages(String businessSlug, String conversationId) {
    _messagesSub?.cancel();
    _messagesSub = chatRepository
        .getMessages(businessSlug, conversationId, limit: messagesLimit)
        .listen((list) {
      messages = list;
      notifyListeners();
    });
  }

  void loadMoreMessages(String businessSlug) {
    if (selectedConversation == null) return;
    messagesLimit += 30;
    _subscribeToMessages(businessSlug, selectedConversation!.id);
  }

  Future<void> sendMessage({
    required String businessSlug,
    required String conversationId,
    required String content,
    required String senderId,
    String? senderName,
    MessageType type = MessageType.text,
    String? media,
  }) async {
    final message = MessageEntity(
      id: '',
      recipientId: conversationId,
      senderId: senderId,
      senderName: senderName ?? 'Vendedor',
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
      media: media,
    );
    await chatRepository.sendMessage(businessSlug, conversationId, message);
  }

  Future<void> simulateIncomingMessage({
    required String businessSlug,
    required String conversationId,
    required String content,
  }) async {
    await chatRepository.simulateIncomingMessage(businessSlug, conversationId, content);
  }

  Future<void> toggleBot(String businessSlug, String conversationId, bool isActive) async {
    final originalConversations = List<ConversationEntity>.from(conversations);
    final originalSelected = selectedConversation;

    if (selectedConversation != null && selectedConversation!.id == conversationId) {
      selectedConversation = selectedConversation!.copyWith(isBotActive: isActive);
    }
    conversations = conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(isBotActive: isActive);
      }
      return c;
    }).toList();
    notifyListeners();

    try {
      await chatRepository.toggleBotStatus(businessSlug, conversationId, isActive);
    } catch (_) {
      conversations = originalConversations;
      selectedConversation = originalSelected;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> initializeMockData(String businessSlug) async {
    isLoading = true;
    notifyListeners();
    try {
      await chatRepository.initializeMockData(businessSlug);
    } catch (_) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateIzipayLink({
    required String businessId,
    required double amount,
    required String orderId,
    required String conversationId,
    required String senderId,
    String? customerEmail,
    String? customerName,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final paymentUrl = await izipayDataSource.createPaymentLink(
        amount: amount,
        orderId: orderId,
        businessId: businessId,
        customerEmail: customerEmail,
        customerName: customerName,
      );

      await sendMessage(
        businessSlug: businessId,
        conversationId: conversationId,
        content: paymentUrl,
        senderId: senderId,
        type: MessageType.paymentLink,
      );
    } catch (_) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSuggestion() {
    aiSuggestion = null;
    notifyListeners();
  }

  Future<void> getAiSuggestion({
    required String businessSlug,
    required String conversationId,
    required String clientName,
  }) async {
    isAiLoading = true;
    notifyListeners();

    try {
      aiSuggestion = await chatRepository.getAiSuggestion(
        businessSlug,
        conversationId,
        clientName,
      );
    } catch (e) {
      aiSuggestion = null;
      rethrow;
    } finally {
      isAiLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
