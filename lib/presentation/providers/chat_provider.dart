import 'package:flutter/material.dart';
import 'dart:async';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/repos/chat_repository.dart';
import 'package:virtual_catalog_app/domain/datasources/izipay_datasource.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository chatRepository;
  final IzipayDataSource izipayDataSource;

  ChatProvider({
    required this.chatRepository,
    required this.izipayDataSource,
  });

  List<Conversation> conversations = [];
  List<ChatMessage> messages = [];
  Conversation? selectedConversation;
  bool isLoading = false;
  bool isAiLoading = false;
  String? aiSuggestion;

  StreamSubscription<List<Conversation>>? _conversationsSub;
  StreamSubscription<List<ChatMessage>>? _messagesSub;

  void initConversations(String businessSlug) {
    _conversationsSub?.cancel();
    _conversationsSub = chatRepository.getConversations(businessSlug).listen((list) {
      conversations = list;
      notifyListeners();
    });
  }

  void selectConversation(String businessSlug, Conversation conversation) {
    selectedConversation = conversation;
    messages = [];
    aiSuggestion = null;
    notifyListeners();

    _messagesSub?.cancel();
    _messagesSub = chatRepository.getMessages(businessSlug, conversation.id).listen((list) {
      messages = list;
      notifyListeners();
    });

    chatRepository.markAsRead(businessSlug, conversation.id);
  }

  Future<void> sendMessage({
    required String businessSlug,
    required String conversationId,
    required String content,
    required String senderId,
    String type = 'text',
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
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
        type: 'payment_link',
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

  Future<void> getAiSuggestion(String lastClientMessage, List<Product> catalog) async {
    isAiLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final query = lastClientMessage.toLowerCase();
    Product? matchedProduct;
    for (var prod in catalog) {
      if (query.contains(prod.name.toLowerCase()) ||
          (prod.sku != null && query.contains(prod.sku!.toLowerCase()))) {
        matchedProduct = prod;
        break;
      }
    }

    if (matchedProduct != null) {
      aiSuggestion = "Hola. Sí tenemos ${matchedProduct.name} disponible en nuestro catálogo. El precio es S/ ${matchedProduct.variants.first.price.toStringAsFixed(2)}. ¿Te genero un enlace de cobro para realizar tu pedido?";
    } else {
      aiSuggestion = "Hola. Gracias por escribirnos. ¿En qué producto de nuestro catálogo estás interesado hoy?";
    }

    isAiLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
