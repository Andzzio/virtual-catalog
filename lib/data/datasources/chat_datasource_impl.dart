import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:virtual_catalog_app/data/models/conversation_model.dart';
import 'package:virtual_catalog_app/data/models/message_model.dart';
import 'package:virtual_catalog_app/domain/datasources/chat_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';
import 'package:virtual_catalog_app/domain/entities/message_type.dart';

class ChatDatasourceImpl implements ChatDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ConversationEntity>> getConversations(String businessSlug) {
    return _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<MessageEntity>> getMessages(String businessSlug, String conversationId, {int? limit}) {
    var query = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      return list.reversed.toList();
    });
  }

  @override
  Future<void> sendMessage(String businessSlug, String conversationId, MessageEntity message) async {
    final messageModel = MessageModel(
       id: message.id,
       recipientId: message.recipientId,
       senderId: message.senderId,
       senderName: message.senderName,
       content: message.content,
       timestamp: message.timestamp,
       isRead: message.isRead,
       type: message.type,
       media: message.media,
     );

    final convRef = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc(conversationId);

    final convDoc = await convRef.get();
    final batch = _firestore.batch();

    if (!convDoc.exists) {
      batch.set(convRef, {
        'contact': {
          'name': conversationId.length >= 4 
              ? 'Cliente - ${conversationId.substring(conversationId.length - 4)}'
              : 'Cliente',
          'phoneId': conversationId,
        },
        'lastMessage': messageModel.toFirestore(),
        'unreadCount': 0,
        'isBotActive': false,
      });
    } else {
      batch.update(convRef, {
        'lastMessage': messageModel.toFirestore(),
        'isBotActive': false,
      });
    }

    final messageRef = convRef.collection('messages').doc(message.id == null || message.id!.isEmpty ? null : message.id);
    batch.set(messageRef, messageModel.toFirestore());

    await batch.commit();
  }

  @override
  Future<void> simulateIncomingMessage(String businessSlug, String conversationId, String content) async {
    final convRef = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc(conversationId);

    final convDoc = await convRef.get();
    final batch = _firestore.batch();
    final now = DateTime.now();

    int currentUnread = 0;
    String clientName = conversationId.length >= 4 
        ? 'Cliente - ${conversationId.substring(conversationId.length - 4)}'
        : 'Cliente';

    if (convDoc.exists) {
      final data = convDoc.data() as Map<String, dynamic>;
      currentUnread = data['unreadCount'] ?? 0;
      final contactData = data['contact'] as Map<String, dynamic>? ?? {};
      clientName = contactData['name'] ?? clientName;
    }

    final messageRef = convRef.collection('messages').doc();
    final messageModel = MessageModel(
      id: messageRef.id,
      recipientId: 'vendedor',
      senderId: conversationId,
      senderName: clientName,
      content: content,
      timestamp: now,
      isRead: false,
      type: MessageType.text,
    );

    if (!convDoc.exists) {
      batch.set(convRef, {
        'contact': {
          'name': clientName,
          'phoneId': conversationId,
        },
        'lastMessage': messageModel.toFirestore(),
        'unreadCount': 1,
      });
    } else {
      batch.update(convRef, {
        'lastMessage': messageModel.toFirestore(),
        'unreadCount': currentUnread + 1,
      });
    }

    batch.set(messageRef, messageModel.toFirestore());
    await batch.commit();
  }

  @override
  Future<void> markAsRead(String businessSlug, String conversationId) async {
    await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc(conversationId)
        .update({'unreadCount': 0});
  }

  @override
  Future<void> initializeMockData(String businessSlug) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final c1Ref = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc('+51987654321');

    batch.set(c1Ref, {
      'contact': {
        'name': 'Carlos Mendoza',
        'phoneId': '+51987654321',
      },
      'lastMessage': {
        'recipientId': 'vendedor',
        'senderId': '+51987654321',
        'senderName': 'Carlos Mendoza',
        'content': 'Genial, mándame el enlace de pago por favor.',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
        'isRead': false,
        'type': 'text',
      },
      'unreadCount': 1,
    });

    final m1_1 = c1Ref.collection('messages').doc();
    batch.set(m1_1, {
      'recipientId': 'vendedor',
      'senderId': '+51987654321',
      'senderName': 'Carlos Mendoza',
      'content': 'Hola, ¿tienen stock del Polo Negro?',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
      'isRead': true,
      'type': 'text',
    });

    final m1_2 = c1Ref.collection('messages').doc();
    batch.set(m1_2, {
      'recipientId': '+51987654321',
      'senderId': 'vendedor',
      'senderName': 'Vendedor',
      'content': 'Hola Carlos, ¡sí! Nos quedan pocas unidades en talla M y L.',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 10))),
      'isRead': true,
      'type': 'text',
    });

    final m1_3 = c1Ref.collection('messages').doc();
    batch.set(m1_3, {
      'recipientId': 'vendedor',
      'senderId': '+51987654321',
      'senderName': 'Carlos Mendoza',
      'content': 'Genial, mándame el enlace de pago por favor.',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
      'isRead': false,
      'type': 'text',
    });

    final c2Ref = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc('+51912345678');

    batch.set(c2Ref, {
      'contact': {
        'name': 'María Fe Torres',
        'phoneId': '+51912345678',
      },
      'lastMessage': {
        'recipientId': '+51912345678',
        'senderId': 'vendedor',
        'senderName': 'Vendedor',
        'content': 'Hola María Fe, sí, hacemos envíos a todo Lima Metropolitana.',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 30))),
        'isRead': true,
        'type': 'text',
      },
      'unreadCount': 0,
    });

    final m2_1 = c2Ref.collection('messages').doc();
    batch.set(m2_1, {
      'recipientId': 'vendedor',
      'senderId': '+51912345678',
      'senderName': 'María Fe Torres',
      'content': 'Buenas tardes, ¿hacen envíos a Lima?',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      'isRead': true,
      'type': 'text',
    });

    final m2_2 = c2Ref.collection('messages').doc();
    batch.set(m2_2, {
      'recipientId': '+51912345678',
      'senderId': 'vendedor',
      'senderName': 'Vendedor',
      'content': 'Hola María Fe, sí, hacemos envíos a todo Lima Metropolitana.',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 30))),
      'isRead': true,
      'type': 'text',
    });

    await batch.commit();
  }

  @override
  Future<void> toggleBotStatus(String businessSlug, String conversationId, bool isActive) async {
    await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc(conversationId)
        .update({'isBotActive': isActive});
  }

  @override
  Future<String> getAiSuggestion(String businessSlug, String conversationId, String clientName) async {
    final doc = await _firestore
        .collection('whatsapp_settings')
        .doc(businessSlug)
        .get();

    if (!doc.exists) {
      throw Exception("Configuración no encontrada");
    }

    final data = doc.data() ?? {};
    final botUrl = data['botUrl'] as String?;

    if (botUrl == null || botUrl.isEmpty) {
      throw Exception("URL del Bot no configurada");
    }

    final cleanBotUrl = botUrl.endsWith('/')
        ? botUrl.substring(0, botUrl.length - 1)
        : botUrl;

    final dioClient = Dio();
    final response = await dioClient.post<Map<String, dynamic>>(
      "$cleanBotUrl/generate_suggestion",
      options: Options(
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
      ),
      data: {
        "businessId": businessSlug,
        "conversationId": conversationId,
        "clientName": clientName,
      },
    );

    if (response.statusCode == 200) {
      return response.data?["suggestion"] as String? ?? "";
    } else {
      throw Exception("Error de respuesta del bot: ${response.statusCode}");
    }
  }
}
