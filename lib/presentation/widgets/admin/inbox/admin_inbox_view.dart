import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/message_entity.dart';
import 'package:virtual_catalog_app/domain/entities/message_type.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/chat_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/inbox/generate_payment_dialog.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/sales/create_sale_dialog.dart';
import 'package:virtual_catalog_app/config/utils/chat_media_helper.dart';

class AdminInboxView extends StatefulWidget {
  final String businessSlug;

  const AdminInboxView({super.key, required this.businessSlug});

  @override
  State<AdminInboxView> createState() => _AdminInboxViewState();
}

class _AdminInboxViewState extends State<AdminInboxView> {
  final _messageCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  String _searchText = '';

  bool _isFetchingMore = false;
  double _oldMaxScroll = 0.0;
  int _lastMessageCount = 0;
  String? _activeConversationId;

  bool _isInputEmpty = true;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _isUploadingMedia = false;
  String _uploadProgressText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initConversations(widget.businessSlug);
    });
    _searchCtrl.addListener(() {
      setState(() {
        _searchText = _searchCtrl.text.toLowerCase();
      });
    });
    _messageCtrl.addListener(_onMessageCtrlChanged);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.hasClients &&
        _scrollCtrl.position.pixels <= 0 &&
        !_isFetchingMore) {
      final provider = context.read<ChatProvider>();
      if (provider.messages.length >= 30) {
        _oldMaxScroll = _scrollCtrl.position.maxScrollExtent;
        setState(() {
          _isFetchingMore = true;
        });
        provider.loadMoreMessages(widget.businessSlug);
      }
    }
  }

  void _onMessageCtrlChanged() {
    final isEmpty = _messageCtrl.text.trim().isEmpty;
    if (isEmpty != _isInputEmpty) {
      setState(() {
        _isInputEmpty = isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _messageCtrl.removeListener(_onMessageCtrlChanged);
    _messageCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _handleSendTextMessage(
    ChatProvider provider,
    String conversationId,
    String userId,
    String? senderName,
  ) async {
    final txt = _messageCtrl.text.trim();
    if (txt.isEmpty) return;

    _messageCtrl.clear();
    _scrollToBottom();
    _focusNode.requestFocus();

    try {
      await provider.sendMessage(
        businessSlug: widget.businessSlug,
        conversationId: conversationId,
        content: txt,
        senderId: userId,
        senderName: senderName,
      );
    } catch (e) {
      if (!mounted) return;
      _messageCtrl.text = txt;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al enviar mensaje: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isMobile = MediaQuery.of(context).size.width < 800;

    final filteredConversations = chatProvider.conversations.where((conv) {
      final name = conv.contact.name.toLowerCase();
      final phone = conv.contact.phoneId.toLowerCase();
      return name.contains(_searchText) || phone.contains(_searchText);
    }).toList();

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      body: Stack(
        children: [
          isMobile
              ? (chatProvider.selectedConversation == null
                    ? _buildConversationsList(filteredConversations)
                    : _buildChatThread(chatProvider))
              : Row(
                  children: [
                    SizedBox(
                      width: 320,
                      child: _buildConversationsList(filteredConversations),
                    ),
                    const VerticalDivider(width: 1, color: AdminTheme.border),
                    Expanded(child: _buildChatThread(chatProvider)),
                  ],
                ),
          if (_isUploadingMedia)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AdminTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _uploadProgressText,
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationEntity> list) {
    final chatProvider = context.read<ChatProvider>();

    return Container(
      color: AdminTheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _searchCtrl,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                color: AdminTheme.textPrimary,
              ),
              decoration: AdminTheme.inputDecoration(
                hintText: "Buscar cliente...",
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AdminTheme.textMuted,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AdminTheme.border),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: chatProvider.isLoading
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.forum_outlined,
                                  size: 48,
                                  color: AdminTheme.textMuted,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No hay conversaciones",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(
                                      color: AdminTheme.textMuted,
                                    ),
                                  ),
                                ),
                                if (!kReleaseMode) ...[
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context
                                          .read<ChatProvider>()
                                          .initializeMockData(
                                            widget.businessSlug,
                                          );
                                    },
                                    icon: const Icon(Icons.bolt, size: 18),
                                    label: Text(
                                      "Crear chats de prueba",
                                      style: GoogleFonts.getFont(
                                        FontNames.fontNameH2,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AdminTheme.accent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AdminTheme.border),
                    itemBuilder: (context, index) {
                      final conv = list[index];
                      final isSelected =
                          chatProvider.selectedConversation?.id == conv.id;
                      final initials = conv.contact.name.isNotEmpty
                          ? conv.contact.name.substring(0, 1).toUpperCase()
                          : "C";

                      return ListTile(
                        onTap: () {
                          context.read<ChatProvider>().selectConversation(
                            widget.businessSlug,
                            conv,
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _focusNode.requestFocus();
                            _scrollToBottom();
                          });
                        },
                        selected: isSelected,
                        selectedColor: Colors.transparent,
                        tileColor: isSelected
                            ? Colors.white.withValues(alpha: 0.05)
                            : null,
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AdminTheme.accent
                              : AdminTheme.border,
                          child: Text(
                            initials,
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH2,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                conv.contact.name,
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: TextStyle(
                                    fontWeight: conv.unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 14,
                                    color: AdminTheme.textPrimary,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              conv.lastMessage?.timestamp != null
                                  ? "${conv.lastMessage!.timestamp!.hour.toString().padLeft(2, '0')}:${conv.lastMessage!.timestamp!.minute.toString().padLeft(2, '0')}"
                                  : "",
                              style: GoogleFonts.courierPrime(
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  color: AdminTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                conv.lastMessage?.content ?? "Sin mensajes",
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    color: AdminTheme.textSecondary,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conv.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AdminTheme.accent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${conv.unreadCount}",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatThread(ChatProvider provider) {
    final activeConv = provider.selectedConversation;
    if (activeConv == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AdminTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              "Bandeja de Entrada",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Selecciona un cliente para comenzar a chatear",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(color: AdminTheme.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    if (activeConv.id != _activeConversationId) {
      _activeConversationId = activeConv.id;
      _lastMessageCount = 0;
      _isFetchingMore = false;
      _scrollToBottom();
    }

    if (provider.messages.length != _lastMessageCount) {
      final oldLength = _lastMessageCount;
      _lastMessageCount = provider.messages.length;
      if (_isFetchingMore && provider.messages.length > oldLength) {
        final oldMaxScroll = _oldMaxScroll;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollCtrl.hasClients) {
            final newMaxScroll = _scrollCtrl.position.maxScrollExtent;
            final diff = newMaxScroll - oldMaxScroll;
            if (diff > 0) {
              _scrollCtrl.jumpTo(diff);
            }
            setState(() {
              _isFetchingMore = false;
            });
          }
        });
      }
    }

    final catalog = context.watch<ProductProvider>().products;

    return Column(
      children: [
        Container(
          color: AdminTheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (MediaQuery.of(context).size.width < 800)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    provider.selectConversation(
                      widget.businessSlug,
                      activeConv,
                    );
                    setState(() {
                      provider.selectedConversation = null;
                    });
                  },
                ),
              CircleAvatar(
                backgroundColor: AdminTheme.border,
                child: Text(
                  activeConv.contact.name.isNotEmpty
                      ? activeConv.contact.name.substring(0, 1).toUpperCase()
                      : "C",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeConv.contact.name,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      activeConv.contact.phoneId,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 11,
                          color: AdminTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.smart_toy,
                  color: activeConv.isBotActive
                      ? Colors.blue
                      : AdminTheme.textMuted,
                ),
                tooltip: activeConv.isBotActive
                    ? "Silenciar Bot"
                    : "Activar Bot",
                onPressed: () {
                  context.read<ChatProvider>().toggleBot(
                    widget.businessSlug,
                    activeConv.id,
                    !activeConv.isBotActive,
                  );
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CreateSaleDialog(
                      businessSlug: widget.businessSlug,
                      initialClientName: activeConv.contact.name,
                      initialClientPhone: activeConv.contact.phoneId,
                    ),
                  );
                },
                icon: const Icon(Icons.point_of_sale_rounded, size: 16),
                label: Text(
                  "Registrar Venta",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              if (!kReleaseMode) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.simulateIncomingMessage(
                      businessSlug: widget.businessSlug,
                      conversationId: activeConv.id,
                      content: "Hola, quisiera consultar stock de este producto.",
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined, size: 16),
                  label: Text(
                    "Simular Recibir",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.border,
                    foregroundColor: AdminTheme.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: AdminTheme.border),
        Expanded(
          child: Container(
            color: AdminTheme.surface,
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final msg = provider.messages[index];
                final isMerchant = msg.senderId != activeConv.id;
                return _buildMessageBubble(msg, isMerchant);
              },
            ),
          ),
        ),
        if (provider.isAiLoading)
          _buildAiSuggestionLoadingBanner()
        else if (provider.aiSuggestion != null)
          _buildAiSuggestionBanner(provider),
        const Divider(height: 1, color: AdminTheme.border),
        _buildChatInputArea(provider, activeConv, catalog),
      ],
    );
  }

  Widget _buildMessageBubble(MessageEntity msg, bool isMerchant) {
    final bubbleBg = isMerchant ? AdminTheme.accent : AdminTheme.surface;
    final textStyle = GoogleFonts.getFont(
      FontNames.fontNameH2,
      textStyle: TextStyle(
        fontSize: 13,
        color: isMerchant ? Colors.white : AdminTheme.textPrimary,
      ),
    );

    final bubbleChild = Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isMerchant
              ? const Radius.circular(12)
              : const Radius.circular(0),
          bottomRight: isMerchant
              ? const Radius.circular(0)
              : const Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMerchant && msg.senderName.isNotEmpty) ...[
            Text(
              msg.senderName,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (msg.type == MessageType.paymentLink)
            _buildPaymentLinkBubble(msg.content, isMerchant)
          else if (msg.type == MessageType.image)
            _buildImageBubble(msg, isMerchant)
          else if (msg.type == MessageType.audio)
            _buildAudioBubble(msg, isMerchant)
          else if (msg.type == MessageType.video)
            _buildVideoBubble(msg, isMerchant)
          else if (msg.type == MessageType.file)
            _buildFileBubble(msg, isMerchant)
          else
            Text(msg.content, style: textStyle),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${(msg.timestamp ?? DateTime.now()).hour.toString().padLeft(2, '0')}:${(msg.timestamp ?? DateTime.now()).minute.toString().padLeft(2, '0')}",
                  style: GoogleFonts.courierPrime(
                    textStyle: TextStyle(
                      fontSize: 9,
                      color: isMerchant ? Colors.white70 : AdminTheme.textMuted,
                    ),
                  ),
                ),
                if (isMerchant) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(msg.status),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: isMerchant ? Alignment.centerRight : Alignment.centerLeft,
      child: _buildBubbleWithContextMenu(bubbleChild, msg),
    );
  }

  Widget _buildStatusIcon(String? status) {
    if (status == 'read') {
      return const Icon(
        Icons.done_all,
        size: 13,
        color: Colors.blueAccent,
      );
    } else if (status == 'delivered') {
      return const Icon(
        Icons.done_all,
        size: 13,
        color: Colors.white60,
      );
    } else {
      return const Icon(
        Icons.done,
        size: 13,
        color: Colors.white60,
      );
    }
  }

  Widget _buildImageBubble(MessageEntity msg, bool isMerchant) {
    final imageUrl = msg.media ?? msg.content;
    final caption = msg.content;
    final hasCaption =
        msg.media != null && msg.media!.isNotEmpty && caption.isNotEmpty;

    final textStyle = GoogleFonts.getFont(
      FontNames.fontNameH2,
      textStyle: TextStyle(
        fontSize: 13,
        color: isMerchant ? Colors.white : AdminTheme.textPrimary,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            _showFullScreenImage(imageUrl, caption);
          },
          child: Container(
            constraints: const BoxConstraints(maxHeight: 250, maxWidth: 250),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 180,
                    height: 180,
                    color: AdminTheme.border,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    color: AdminTheme.border,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          color: AdminTheme.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Imagen no disponible",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              color: AdminTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (hasCaption) ...[
          const SizedBox(height: 8),
          Text(caption, style: textStyle),
        ],
      ],
    );
  }

  Widget _buildPaymentLinkBubble(String paymentUrl, bool isMerchant) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMerchant
            ? Colors.white.withValues(alpha: 0.1)
            : AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Enlace de pago generado",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isMerchant ? Colors.white : AdminTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(paymentUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                "Pagar con Izipay",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionBanner(ChatProvider provider) {
    return Container(
      color: Colors.blue.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sugerencia de respuesta IA",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 120,
                    minWidth: double.infinity,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      provider.aiSuggestion!,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: AdminTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _messageCtrl.text = provider.aiSuggestion!;
                        });
                        provider.clearSuggestion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Text(
                        "Usar y Editar",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final userId = authProvider.user?.uid ?? "vendedor";
                        final displayName = authProvider.user?.displayName;
                        final suggestion = provider.aiSuggestion!;
                        provider.clearSuggestion();

                        try {
                          setState(() {
                            _isUploadingMedia = true;
                            _uploadProgressText = "Enviando sugerencia...";
                          });
                          await provider.sendMessage(
                            businessSlug: widget.businessSlug,
                            conversationId: provider.selectedConversation!.id,
                            content: suggestion,
                            senderId: userId,
                            senderName: displayName,
                          );
                          _scrollToBottom();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al enviar sugerencia: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingMedia = false;
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.send, size: 12),
                      label: Text(
                        "Enviar directo",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => provider.clearSuggestion(),
                      child: Text(
                        "Rechazar",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          fontSize: 11,
                          textStyle: const TextStyle(
                            color: AdminTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInputArea(
    ChatProvider provider,
    ConversationEntity activeConv,
    List catalog,
  ) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.user?.uid ?? "vendedor";

    return Container(
      color: AdminTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (_isRecording)
            _buildRecordingRow(provider, activeConv)
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.payment_outlined,
                    color: Colors.orange,
                  ),
                  tooltip: "Generar link de pago Izipay",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => GeneratePaymentDialog(
                        businessSlug: widget.businessSlug,
                        conversationId: activeConv.id,
                        senderId: userId,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: provider.isAiLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.auto_awesome_outlined,
                          color: Colors.blue,
                        ),
                  tooltip: "Sugerir respuesta con IA",
                  onPressed: () async {
                    try {
                      await provider.getAiSuggestion(
                        businessSlug: widget.businessSlug,
                        conversationId: activeConv.id,
                        clientName: activeConv.contact.name,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error al generar sugerencia de IA: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.attach_file,
                    color: AdminTheme.textMuted,
                  ),
                  tooltip: "Adjuntar archivo",
                  onPressed: () =>
                      _showAttachmentMenu(context, provider, activeConv),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _messageCtrl,
                    focusNode: _focusNode,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      color: AdminTheme.textPrimary,
                    ),
                    decoration: AdminTheme.inputDecoration(
                      hintText: "Escribe tu mensaje aquí...",
                    ),
                    onFieldSubmitted: (v) => _handleSendTextMessage(
                      provider,
                      activeConv.id,
                      userId,
                      authProvider.user?.displayName,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isInputEmpty
                    ? IconButton(
                        icon: const Icon(Icons.mic, color: AdminTheme.accent),
                        tooltip: "Esta opción está en progreso de mejora",
                        onPressed: () async {
                          final hasPerm = await audioRecorder
                              .requestPermissions();
                          if (hasPerm) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Esta opción está en progreso de mejora",
                                  ),
                                ),
                              );
                            }
                            await audioRecorder.startRecording();
                            setState(() {
                              _isRecording = true;
                              _recordSeconds = 0;
                            });
                            _recordTimer = Timer.periodic(
                              const Duration(seconds: 1),
                              (t) {
                                setState(() {
                                  _recordSeconds++;
                                });
                              },
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Permiso de micrófono denegado"),
                              ),
                            );
                          }
                        },
                      )
                    : GestureDetector(
                        onTap: () => _handleSendTextMessage(
                          provider,
                          activeConv.id,
                          userId,
                          authProvider.user?.displayName,
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AdminTheme.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBubbleWithContextMenu(Widget child, MessageEntity msg) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showBubbleContextMenu(details.globalPosition, msg);
      },
      onLongPressStart: (details) {
        _showBubbleContextMenu(details.globalPosition, msg);
      },
      child: child,
    );
  }

  void _showBubbleContextMenu(Offset position, MessageEntity msg) {
    final mediaUrl = msg.media ?? msg.content;
    final isMedia =
        msg.type != MessageType.text && msg.type != MessageType.paymentLink;
    if (!isMedia || mediaUrl.isEmpty) return;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
      ),
      color: Colors.white,
      elevation: 8,
      items: [
        PopupMenuItem(
          onTap: () {
            Clipboard.setData(ClipboardData(text: mediaUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Enlace copiado al portapapeles")),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.copy, size: 16, color: AdminTheme.textPrimary),
              SizedBox(width: 8),
              Text(
                "Copiar enlace",
                style: TextStyle(color: AdminTheme.textPrimary),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            final uri = Uri.parse(mediaUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: const Row(
            children: [
              Icon(Icons.download, size: 16, color: AdminTheme.textPrimary),
              SizedBox(width: 8),
              Text(
                "Descargar",
                style: TextStyle(color: AdminTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(String url, String caption) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              maxScale: 4.0,
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            if (caption.isNotEmpty && caption != '[Imagen]')
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    caption,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingRow(
    ChatProvider provider,
    ConversationEntity activeConv,
  ) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid ?? "vendedor";

    final minutes = _recordSeconds ~/ 60;
    final seconds = _recordSeconds % 60;
    final timeStr = "$minutes:${seconds.toString().padLeft(2, '0')}";

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: "Cancelar grabación",
          onPressed: () {
            audioRecorder.cancelRecording();
            _recordTimer?.cancel();
            setState(() {
              _isRecording = false;
              _recordSeconds = 0;
            });
          },
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "Grabando nota de voz... $timeStr",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.green),
          tooltip: "Enviar nota de voz",
          onPressed: () async {
            _recordTimer?.cancel();
            setState(() {
              _isRecording = false;
              _recordSeconds = 0;
            });

            await audioRecorder.stopRecording((bytes, mimeType) async {
              try {
                setState(() {
                  _isUploadingMedia = true;
                  _uploadProgressText = "Subiendo nota de voz...";
                });
                final fileName =
                    "voice_${DateTime.now().millisecondsSinceEpoch}.ogg";
                final url = await uploadChatMedia(
                  bytes: bytes,
                  fileName: fileName,
                  mimeType: mimeType,
                  businessSlug: widget.businessSlug,
                );
                if (mounted) {
                  setState(() {
                    _uploadProgressText = "Enviando nota de voz...";
                  });
                }
                await provider.sendMessage(
                  businessSlug: widget.businessSlug,
                  conversationId: activeConv.id,
                  content: '',
                  senderId: userId,
                  senderName: authProvider.user?.displayName,
                  type: MessageType.audio,
                  media: url,
                );
                _scrollToBottom();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error al enviar nota de voz: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isUploadingMedia = false;
                  });
                }
              }
            });
          },
        ),
      ],
    );
  }

  void _showAttachmentMenu(
    BuildContext menuContext,
    ChatProvider provider,
    ConversationEntity activeConv,
  ) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid ?? "vendedor";

    showModalBottomSheet(
      context: menuContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enviar contenido multimedia",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AdminTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image,
                  color: Colors.purple,
                  label: "Imágenes",
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      final bytes = file.bytes;
                      if (bytes != null) {
                        try {
                          setState(() {
                            _isUploadingMedia = true;
                            _uploadProgressText = "Subiendo imagen...";
                          });
                          final url = await uploadChatMedia(
                            bytes: bytes,
                            fileName: file.name,
                            mimeType: _getMimeTypeForExtension(
                              file.extension ?? "",
                            ),
                            businessSlug: widget.businessSlug,
                          );
                          if (mounted) {
                            setState(() {
                              _uploadProgressText = "Enviando imagen...";
                            });
                          }
                          await provider.sendMessage(
                            businessSlug: widget.businessSlug,
                            conversationId: activeConv.id,
                            content: '',
                            senderId: userId,
                            senderName: authProvider.user?.displayName,
                            type: MessageType.image,
                            media: url,
                          );
                          _scrollToBottom();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al enviar imagen: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingMedia = false;
                            });
                          }
                        }
                      }
                    }
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  color: Colors.blue,
                  label: "Documentos",
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                      allowMultiple: false,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      final bytes = file.bytes;
                      if (bytes != null) {
                        try {
                          setState(() {
                            _isUploadingMedia = true;
                            _uploadProgressText = "Subiendo documento...";
                          });
                          final url = await uploadChatMedia(
                            bytes: bytes,
                            fileName: file.name,
                            mimeType: _getMimeTypeForExtension(
                              file.extension ?? "",
                            ),
                            businessSlug: widget.businessSlug,
                          );
                          if (mounted) {
                            setState(() {
                              _uploadProgressText = "Enviando documento...";
                            });
                          }
                          await provider.sendMessage(
                            businessSlug: widget.businessSlug,
                            conversationId: activeConv.id,
                            content: '',
                            senderId: userId,
                            senderName: authProvider.user?.displayName,
                            type: MessageType.file,
                            media: url,
                          );
                          _scrollToBottom();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al enviar archivo: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingMedia = false;
                            });
                          }
                        }
                      }
                    }
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.video_library,
                  color: Colors.orange,
                  label: "Videos",
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.video,
                      allowMultiple: false,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      final bytes = file.bytes;
                      if (bytes != null) {
                        try {
                          setState(() {
                            _isUploadingMedia = true;
                            _uploadProgressText = "Subiendo video...";
                          });
                          final url = await uploadChatMedia(
                            bytes: bytes,
                            fileName: file.name,
                            mimeType: _getMimeTypeForExtension(
                              file.extension ?? "",
                            ),
                            businessSlug: widget.businessSlug,
                          );
                          if (mounted) {
                            setState(() {
                              _uploadProgressText = "Enviando video...";
                            });
                          }
                          await provider.sendMessage(
                            businessSlug: widget.businessSlug,
                            conversationId: activeConv.id,
                            content: '',
                            senderId: userId,
                            senderName: authProvider.user?.displayName,
                            type: MessageType.video,
                            media: url,
                          );
                          _scrollToBottom();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al enviar video: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingMedia = false;
                            });
                          }
                        }
                      }
                    }
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.music_note,
                  color: Colors.green,
                  label: "Audio",
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.audio,
                      allowMultiple: false,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      final bytes = file.bytes;
                      if (bytes != null) {
                        try {
                          setState(() {
                            _isUploadingMedia = true;
                            _uploadProgressText = "Subiendo audio...";
                          });
                          final url = await uploadChatMedia(
                            bytes: bytes,
                            fileName: file.name,
                            mimeType: _getMimeTypeForExtension(
                              file.extension ?? "",
                            ),
                            businessSlug: widget.businessSlug,
                          );
                          if (mounted) {
                            setState(() {
                              _uploadProgressText = "Enviando audio...";
                            });
                          }
                          await provider.sendMessage(
                            businessSlug: widget.businessSlug,
                            conversationId: activeConv.id,
                            content: '',
                            senderId: userId,
                            senderName: authProvider.user?.displayName,
                            type: MessageType.audio,
                            media: url,
                          );
                          _scrollToBottom();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al enviar audio: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploadingMedia = false;
                            });
                          }
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(
                fontSize: 12,
                color: AdminTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMimeTypeForExtension(String ext) {
    final cleanExt = ext.toLowerCase();
    if (cleanExt == "jpg" || cleanExt == "jpeg") return "image/jpeg";
    if (cleanExt == "png") return "image/png";
    if (cleanExt == "webp") return "image/webp";
    if (cleanExt == "gif") return "image/gif";
    if (cleanExt == "pdf") return "application/pdf";
    if (cleanExt == "doc" || cleanExt == "docx") return "application/msword";
    if (cleanExt == "xls" || cleanExt == "xlsx") return "application/vnd.ms-excel";
    if (cleanExt == "txt") return "text/plain";
    if (cleanExt == "mp4") return "video/mp4";
    if (cleanExt == "mov") return "video/quicktime";
    if (cleanExt == "avi") return "video/x-msvideo";
    if (cleanExt == "mp3") return "audio/mpeg";
    if (cleanExt == "wav") return "audio/wav";
    if (cleanExt == "ogg") return "audio/ogg";
    if (cleanExt == "m4a") return "audio/mp4";
    return "application/octet-stream";
  }

  String _getFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.pathSegments.last;
      final decodedPath = Uri.decodeComponent(path);
      return decodedPath.split('/').last;
    } catch (_) {
      return 'documento.pdf';
    }
  }

  Widget _buildAudioBubble(MessageEntity msg, bool isMerchant) {
    return _AudioBubble(message: msg, isMerchant: isMerchant);
  }

  Widget _buildVideoBubble(MessageEntity msg, bool isMerchant) {
    final videoUrl = msg.media ?? msg.content;
    final textStyle = GoogleFonts.getFont(
      FontNames.fontNameH2,
      textStyle: TextStyle(
        fontSize: 13,
        color: isMerchant ? Colors.white : AdminTheme.textPrimary,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(videoUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  size: 48,
                  color: AdminTheme.textMuted,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.accent.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (msg.content.isNotEmpty && msg.content != '[Video]') ...[
          const SizedBox(height: 8),
          Text(msg.content, style: textStyle),
        ],
      ],
    );
  }

  Widget _buildFileBubble(MessageEntity msg, bool isMerchant) {
    final fileUrl = msg.media ?? msg.content;
    String fileName = "Documento.pdf";
    if (msg.content.isNotEmpty && msg.content != '[Archivo]') {
      fileName = msg.content;
    } else if (msg.media != null && msg.media!.isNotEmpty) {
      fileName = _getFilenameFromUrl(msg.media!);
    }
    final isPdf = fileName.toLowerCase().endsWith(".pdf");

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMerchant
            ? Colors.white.withValues(alpha: 0.1)
            : AdminTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: isPdf ? Colors.red : Colors.blue,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isMerchant ? Colors.white : AdminTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Descargar Documento"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPdf ? Colors.red : AdminTheme.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionLoadingBanner() {
    return Container(
      color: Colors.blue.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Claude IA está pensando en una sugerencia...",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  final MessageEntity message;
  final bool isMerchant;

  const _AudioBubble({required this.message, required this.isMerchant});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  bool _isPlaying = false;
  double _position = 0.0;

  @override
  void initState() {
    super.initState();
    final url = widget.message.media ?? widget.message.content;
    if (audioPlayer.isPlaying(url)) {
      _isPlaying = true;
      _position = audioPlayer.getPosition(url);
      audioPlayer.play(url, _onUpdate);
    }
  }

  void _onUpdate(double duration, double position, bool isPlaying) {
    if (!mounted) return;
    setState(() {
      _isPlaying = isPlaying;
      _position = position;
    });
  }

  String _formatDuration(double seconds) {
    if (seconds.isNaN || seconds.isInfinite) return "0:00";
    final intSecs = seconds.round();
    final mins = intSecs ~/ 60;
    final secs = intSecs % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.message.media ?? widget.message.content;
    final totalDuration = audioPlayer.getDuration(url);
    final currentPos = audioPlayer.getPosition(url);

    final playerColor = widget.isMerchant ? Colors.white : AdminTheme.accent;
    final textColor = widget.isMerchant ? Colors.white70 : AdminTheme.textMuted;

    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: playerColor,
              size: 38,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (url.isEmpty) return;
              audioPlayer.play(url, _onUpdate);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: playerColor,
                    inactiveTrackColor: playerColor.withValues(alpha: 0.3),
                    thumbColor: playerColor,
                    overlayColor: playerColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _isPlaying ? _position : currentPos,
                    max: totalDuration > 0 ? totalDuration : 1.0,
                    onChanged: (v) {
                      audioPlayer.seek(v);
                      setState(() {
                        _position = v;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_isPlaying ? _position : currentPos),
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
