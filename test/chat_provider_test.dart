import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/domain/entities/product_variant.dart';
import 'package:virtual_catalog_app/domain/repos/chat_repository.dart';
import 'package:virtual_catalog_app/domain/datasources/izipay_datasource.dart';
import 'package:virtual_catalog_app/presentation/providers/chat_provider.dart';

class MockChatRepository implements ChatRepository {
  List<Conversation> mockedConversations = [];
  List<ChatMessage> mockedMessages = [];
  bool markAsReadCalled = false;
  bool sendMessageCalled = false;
  bool simulateIncomingCalled = false;

  @override
  Stream<List<Conversation>> getConversations(String businessSlug) {
    return Stream.value(mockedConversations);
  }

  @override
  Stream<List<ChatMessage>> getMessages(String businessSlug, String conversationId) {
    return Stream.value(mockedMessages);
  }

  @override
  Future<void> sendMessage(String businessSlug, String conversationId, ChatMessage message) async {
    sendMessageCalled = true;
    mockedMessages.add(message);
  }

  @override
  Future<void> markAsRead(String businessSlug, String conversationId) async {
    markAsReadCalled = true;
  }

  @override
  Future<void> simulateIncomingMessage(String businessSlug, String conversationId, String content) async {
    simulateIncomingCalled = true;
    mockedMessages.add(ChatMessage(
      id: 'simulated',
      senderId: conversationId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      type: 'text',
    ));
  }

  bool initializeMockDataCalled = false;

  @override
  Future<void> initializeMockData(String businessSlug) async {
    initializeMockDataCalled = true;
    mockedConversations = [
      Conversation(
        id: '+51987654321',
        clientName: 'Carlos Mendoza',
        clientPhone: '+51987654321',
        lastMessage: 'Genial, mándame el enlace de pago por favor.',
        lastMessageTime: DateTime.now(),
        unreadCount: 1,
      )
    ];
  }
}

class MockIzipayDataSource implements IzipayDataSource {
  bool createPaymentLinkCalled = false;
  String expectedLink = 'https://izipay.pe/pay/123';

  @override
  Future<String> createPaymentLink({
    required double amount,
    required String orderId,
    required String businessId,
    String? customerEmail,
    String? customerName,
    String? customerLastName,
  }) async {
    createPaymentLinkCalled = true;
    return expectedLink;
  }
}

void main() {
  late MockChatRepository mockRepo;
  late MockIzipayDataSource mockIzipay;
  late ChatProvider provider;

  setUp(() {
    mockRepo = MockChatRepository();
    mockIzipay = MockIzipayDataSource();
    provider = ChatProvider(
      chatRepository: mockRepo,
      izipayDataSource: mockIzipay,
    );
  });

  group('ChatProvider Unit Tests', () {
    test('initConversations listens and updates conversations', () async {
      mockRepo.mockedConversations = [
        Conversation(
          id: 'client1',
          clientName: 'Juan',
          clientPhone: '999999999',
          lastMessage: 'Hola',
          lastMessageTime: DateTime.now(),
          unreadCount: 1,
        )
      ];

      provider.initConversations('test-business');
      await Future.delayed(Duration.zero);

      expect(provider.conversations.length, 1);
      expect(provider.conversations.first.clientName, 'Juan');
    });

    test('selectConversation updates messages and marks as read', () async {
      final conv = Conversation(
        id: 'client1',
        clientName: 'Juan',
        clientPhone: '999999999',
        lastMessage: 'Hola',
        lastMessageTime: DateTime.now(),
        unreadCount: 1,
      );

      mockRepo.mockedMessages = [
        ChatMessage(
          id: 'msg1',
          senderId: 'client1',
          content: 'Hola',
          timestamp: DateTime.now(),
          isRead: false,
          type: 'text',
        )
      ];

      provider.selectConversation('test-business', conv);
      await Future.delayed(Duration.zero);

      expect(provider.selectedConversation, conv);
      expect(provider.messages.length, 1);
      expect(provider.messages.first.content, 'Hola');
      expect(mockRepo.markAsReadCalled, isTrue);
    });

    test('sendMessage calls repository', () async {
      await provider.sendMessage(
        businessSlug: 'test-business',
        conversationId: 'client1',
        content: 'Hola cliente',
        senderId: 'merchant',
      );

      expect(mockRepo.sendMessageCalled, isTrue);
      expect(mockRepo.mockedMessages.last.content, 'Hola cliente');
      expect(mockRepo.mockedMessages.last.senderId, 'merchant');
    });

    test('simulateIncomingMessage calls repository', () async {
      await provider.simulateIncomingMessage(
        businessSlug: 'test-business',
        conversationId: 'client1',
        content: 'Mensaje entrante',
      );

      expect(mockRepo.simulateIncomingCalled, isTrue);
      expect(mockRepo.mockedMessages.last.content, 'Mensaje entrante');
      expect(mockRepo.mockedMessages.last.senderId, 'client1');
    });

    test('generateIzipayLink generates payment link and sends message', () async {
      await provider.generateIzipayLink(
        businessId: 'test-business',
        amount: 50.0,
        orderId: 'PED-123456',
        conversationId: 'client1',
        senderId: 'merchant',
      );

      expect(mockIzipay.createPaymentLinkCalled, isTrue);
      expect(mockRepo.sendMessageCalled, isTrue);
      expect(mockRepo.mockedMessages.last.content, mockIzipay.expectedLink);
      expect(mockRepo.mockedMessages.last.type, 'payment_link');
    });

    test('getAiSuggestion matches catalog product by name and returns suggestion', () async {
      final catalog = [
        Product(
          id: 'prod1',
          name: 'Polo Negro',
          description: 'Polo de algodón',
          businessId: 'test-business',
          category: 'Ropa',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageUrl: [],
          variants: [
            ProductVariant(
              name: 'Estándar',
              price: 39.90,
              stock: 10,
              sizes: [],
            ),
          ],
        ),
      ];

      await provider.getAiSuggestion('¿Tienes polo negro en stock?', catalog);

      expect(provider.aiSuggestion, contains('Polo Negro'));
      expect(provider.aiSuggestion, contains('S/ 39.90'));
      expect(provider.aiSuggestion, contains('¿Te genero un enlace de cobro'));
    });

    test('getAiSuggestion returns generic suggestion if product is not in catalog', () async {
      final catalog = [
        Product(
          id: 'prod1',
          name: 'Polo Negro',
          description: 'Polo de algodón',
          businessId: 'test-business',
          category: 'Ropa',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageUrl: [],
          variants: [
            ProductVariant(
              name: 'Estándar',
              price: 39.90,
              stock: 10,
              sizes: [],
            ),
          ],
        ),
      ];

      await provider.getAiSuggestion('¿Hacen envíos a Lima?', catalog);

      expect(provider.aiSuggestion, contains('¿En qué producto de nuestro catálogo estás interesado hoy?'));
    });

    test('initializeMockData calls repository and loads mock conversations', () async {
      expect(mockRepo.initializeMockDataCalled, isFalse);

      await provider.initializeMockData('test-business');

      expect(mockRepo.initializeMockDataCalled, isTrue);
    });
  });
}
