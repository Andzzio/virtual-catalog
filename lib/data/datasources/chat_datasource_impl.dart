import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/conversation_model.dart';
import 'package:virtual_catalog_app/data/models/chat_message_model.dart';
import 'package:virtual_catalog_app/domain/datasources/chat_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';

class ChatDatasourceImpl implements ChatDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Conversation>> getConversations(String businessSlug) {
    return _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ChatMessage>> getMessages(String businessSlug, String conversationId) {
    return _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> sendMessage(String businessSlug, String conversationId, ChatMessage message) async {
    final messageModel = ChatMessageModel(
      id: message.id,
      senderId: message.senderId,
      content: message.content,
      timestamp: message.timestamp,
      isRead: message.isRead,
      type: message.type,
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
        'clientName': conversationId.length >= 4 
            ? 'Cliente - ${conversationId.substring(conversationId.length - 4)}'
            : 'Cliente',
        'clientPhone': conversationId,
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'unreadCount': 0,
      });
    } else {
      batch.update(convRef, {
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
      });
    }

    final messageRef = convRef.collection('messages').doc(message.id.isEmpty ? null : message.id);
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
    if (convDoc.exists) {
      final data = convDoc.data() as Map<String, dynamic>;
      currentUnread = data['unreadCount'] ?? 0;
    }

    if (!convDoc.exists) {
      batch.set(convRef, {
        'clientName': conversationId.length >= 4 
            ? 'Cliente - ${conversationId.substring(conversationId.length - 4)}'
            : 'Cliente',
        'clientPhone': conversationId,
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCount': 1,
      });
    } else {
      batch.update(convRef, {
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCount': currentUnread + 1,
      });
    }

    final messageRef = convRef.collection('messages').doc();
    final messageModel = ChatMessageModel(
      id: messageRef.id,
      senderId: conversationId,
      content: content,
      timestamp: now,
      isRead: false,
      type: 'text',
    );

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
      'clientName': 'Carlos Mendoza',
      'clientPhone': '+51987654321',
      'lastMessage': 'Genial, mándame el enlace de pago por favor.',
      'lastMessageTime': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
      'unreadCount': 1,
    });

    final m1_1 = c1Ref.collection('messages').doc();
    batch.set(m1_1, {
      'senderId': '+51987654321',
      'content': 'Hola, ¿tienen stock del Polo Negro?',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
      'isRead': true,
      'type': 'text',
    });

    final m1_2 = c1Ref.collection('messages').doc();
    batch.set(m1_2, {
      'senderId': 'vendedor',
      'content': 'Hola Carlos, ¡sí! Nos quedan pocas unidades en talla M y L.',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 10))),
      'isRead': true,
      'type': 'text',
    });

    final m1_3 = c1Ref.collection('messages').doc();
    batch.set(m1_3, {
      'senderId': '+51987654321',
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
      'clientName': 'María Fe Torres',
      'clientPhone': '+51912345678',
      'lastMessage': 'Hola María Fe, sí, hacemos envíos a todo Lima Metropolitana.',
      'lastMessageTime': Timestamp.fromDate(now.subtract(const Duration(minutes: 30))),
      'unreadCount': 0,
    });

    final m2_1 = c2Ref.collection('messages').doc();
    batch.set(m2_1, {
      'senderId': '+51912345678',
      'content': 'Buenas tardes, ¿hacen envíos a Lima?',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      'isRead': true,
      'type': 'text',
    });

    final m2_2 = c2Ref.collection('messages').doc();
    batch.set(m2_2, {
      'senderId': 'vendedor',
      'content': 'Hola María Fe, sí, hacemos envíos a todo Lima Metropolitana.',
      'timestamp': Timestamp.fromDate(now.subtract(const Duration(minutes: 30))),
      'isRead': true,
      'type': 'text',
    });

    await batch.commit();
  }
}
