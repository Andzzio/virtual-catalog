import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';
import 'package:virtual_catalog_app/domain/entities/message_type.dart';
import 'package:virtual_catalog_app/domain/entities/contact_entity.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/repos/chat_repository.dart';
import 'package:virtual_catalog_app/domain/datasources/izipay_datasource.dart';
import 'package:virtual_catalog_app/presentation/providers/chat_provider.dart';
import 'package:virtual_catalog_app/data/models/message_model.dart';

class MockChatRepository implements ChatRepository {
  List<ConversationEntity> mockedConversations = [];
  List<MessageEntity> mockedMessages = [];
  bool markAsReadCalled = false;
  bool sendMessageCalled = false;
  bool simulateIncomingCalled = false;

  @override
  Stream<List<ConversationEntity>> getConversations(String businessSlug) {
    return Stream.value(mockedConversations);
  }

  @override
  Stream<List<MessageEntity>> getMessages(String businessSlug, String conversationId, {int? limit}) {
    return Stream.value(mockedMessages);
  }

  @override
  Future<void> sendMessage(String businessSlug, String conversationId, MessageEntity message) async {
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
    mockedMessages.add(MessageEntity(
      id: 'simulated',
      recipientId: 'vendedor',
      senderId: conversationId,
      senderName: 'Cliente',
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.text,
    ));
  }

  bool initializeMockDataCalled = false;

  @override
  Future<void> initializeMockData(String businessSlug) async {
    initializeMockDataCalled = true;
    mockedConversations = [
      ConversationEntity(
        id: '+51987654321',
        contact: ContactEntity(
          name: 'Carlos Mendoza',
          phoneId: '+51987654321',
        ),
        lastMessage: MessageEntity(
          recipientId: 'vendedor',
          senderId: '+51987654321',
          senderName: 'Carlos Mendoza',
          content: 'Genial, mándame el enlace de pago por favor.',
          timestamp: DateTime.now(),
          isRead: false,
          type: MessageType.text,
        ),
        unreadCount: 1,
      )
    ];
  }

  bool toggleBotStatusCalled = false;
  bool toggleBotStatusLastValue = false;

  @override
  Future<void> toggleBotStatus(String businessSlug, String conversationId, bool isActive) async {
    toggleBotStatusCalled = true;
    toggleBotStatusLastValue = isActive;
  }

  bool getAiSuggestionCalled = false;
  String mockAiSuggestion = 'Sugerencia mock de IA';
  bool throwErrorOnSuggestion = false;

  @override
  Future<String> getAiSuggestion(String businessSlug, String conversationId, String clientName) async {
    getAiSuggestionCalled = true;
    if (throwErrorOnSuggestion) {
      throw Exception('API Error');
    }
    return mockAiSuggestion;
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
        ConversationEntity(
          id: 'client1',
          contact: ContactEntity(
            name: 'Juan',
            phoneId: '999999999',
          ),
          lastMessage: MessageEntity(
            recipientId: 'vendedor',
            senderId: 'client1',
            senderName: 'Juan',
            content: 'Hola',
            timestamp: DateTime.now(),
            isRead: false,
            type: MessageType.text,
          ),
          unreadCount: 1,
        )
      ];

      provider.initConversations('test-business');
      await Future.delayed(Duration.zero);

      expect(provider.conversations.length, 1);
      expect(provider.conversations.first.contact.name, 'Juan');
    });

    test('selectConversation updates messages and marks as read', () async {
      final conv = ConversationEntity(
        id: 'client1',
        contact: ContactEntity(
          name: 'Juan',
          phoneId: '999999999',
        ),
        lastMessage: MessageEntity(
          recipientId: 'vendedor',
          senderId: 'client1',
          senderName: 'Juan',
          content: 'Hola',
          timestamp: DateTime.now(),
          isRead: false,
          type: MessageType.text,
        ),
        unreadCount: 1,
      );

      mockRepo.mockedMessages = [
        MessageEntity(
          id: 'msg1',
          recipientId: 'vendedor',
          senderId: 'client1',
          senderName: 'Juan',
          content: 'Hola',
          timestamp: DateTime.now(),
          isRead: false,
          type: MessageType.text,
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
      expect(mockRepo.mockedMessages.last.type, MessageType.paymentLink);
    });

    test('getAiSuggestion calls repository and returns suggestion', () async {
      mockRepo.mockAiSuggestion = 'Hola, sí tenemos Polo Negro disponible.';

      await provider.getAiSuggestion(
        businessSlug: 'test-business',
        conversationId: '+51987654321',
        clientName: 'Carlos Mendoza',
      );

      expect(mockRepo.getAiSuggestionCalled, isTrue);
      expect(provider.aiSuggestion, 'Hola, sí tenemos Polo Negro disponible.');
    });

    test('getAiSuggestion handles repository error gracefully', () async {
      mockRepo.throwErrorOnSuggestion = true;

      expect(
        () => provider.getAiSuggestion(
          businessSlug: 'test-business',
          conversationId: '+51987654321',
          clientName: 'Carlos Mendoza',
        ),
        throwsA(isA<Exception>()),
      );

      expect(mockRepo.getAiSuggestionCalled, isTrue);
      expect(provider.aiSuggestion, isNull);
    });

    test('initializeMockData calls repository and loads mock conversations', () async {
      expect(mockRepo.initializeMockDataCalled, isFalse);

      await provider.initializeMockData('test-business');

      expect(mockRepo.initializeMockDataCalled, isTrue);
    });

    test('toggleBot calls repository and updates state optimistically', () async {
      final conv = ConversationEntity(
        id: 'client1',
        contact: ContactEntity(
          name: 'Juan',
          phoneId: '999999999',
        ),
        unreadCount: 0,
        isBotActive: true,
      );
      provider.conversations = [conv];
      provider.selectedConversation = conv;

      await provider.toggleBot('test-business', 'client1', false);

      expect(provider.selectedConversation?.isBotActive, isFalse);
      expect(provider.conversations.first.isBotActive, isFalse);
      expect(mockRepo.toggleBotStatusCalled, isTrue);
      expect(mockRepo.toggleBotStatusLastValue, isFalse);
    });

    test('sendMessage passes senderName correct to repository', () async {
      await provider.sendMessage(
        businessSlug: 'test-business',
        conversationId: 'client1',
        content: 'Hola cliente',
        senderId: 'merchant',
        senderName: 'Vendedor Especializado',
      );

      expect(mockRepo.sendMessageCalled, isTrue);
      expect(mockRepo.mockedMessages.last.senderName, 'Vendedor Especializado');
    });

    test('loadMoreMessages increments limit and fetches messages again', () async {
      final conv = ConversationEntity(
        id: 'client1',
        contact: ContactEntity(
          name: 'Juan',
          phoneId: '999999999',
        ),
        lastMessage: MessageEntity(
          recipientId: 'vendedor',
          senderId: 'client1',
          senderName: 'Juan',
          content: 'Hola',
          timestamp: DateTime.now(),
          isRead: false,
          type: MessageType.text,
        ),
        unreadCount: 1,
      );

      provider.selectConversation('test-business', conv);
      expect(provider.messagesLimit, 30);

      provider.loadMoreMessages('test-business');
      expect(provider.messagesLimit, 60);
    });

    test('MessageModel serializes and deserializes status and whatsappMessageId correctly', () async {
      final now = DateTime.now();
      final model = MessageModel(
        recipientId: 'r1',
        senderId: 's1',
        senderName: 'n1',
        content: 'c1',
        timestamp: now,
        status: 'delivered',
        whatsappMessageId: 'wamid.123',
      );

      final map = model.toFirestore();
      expect(map['status'], 'delivered');
      expect(map['whatsappMessageId'], 'wamid.123');

      final deserialized = MessageModel.fromMap(map, id: 'id1');
      expect(deserialized.id, 'id1');
      expect(deserialized.status, 'delivered');
      expect(deserialized.whatsappMessageId, 'wamid.123');
    });

    test('MessageEntity copyWith copies status and whatsappMessageId correctly', () async {
      final entity = MessageEntity(
        recipientId: 'r1',
        senderId: 's1',
        senderName: 'n1',
        content: 'c1',
      );

      final copied = entity.copyWith(
        status: 'read',
        whatsappMessageId: 'wamid.456',
      );

      expect(copied.status, 'read');
      expect(copied.whatsappMessageId, 'wamid.456');
    });
  });
}
