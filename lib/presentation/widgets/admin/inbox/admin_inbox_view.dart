import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/conversation.dart';
import 'package:virtual_catalog_app/domain/entities/chat_message.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/chat_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/inbox/generate_payment_dialog.dart';
import 'package:virtual_catalog_app/presentation/widgets/admin/sales/create_sale_dialog.dart';

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
  String _searchText = '';

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
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isMobile = MediaQuery.of(context).size.width < 800;

    final filteredConversations = chatProvider.conversations.where((conv) {
      final name = conv.clientName.toLowerCase();
      final phone = conv.clientPhone.toLowerCase();
      return name.contains(_searchText) || phone.contains(_searchText);
    }).toList();

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      body: isMobile
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
                Expanded(
                  child: _buildChatThread(chatProvider),
                ),
              ],
            ),
    );
  }

  Widget _buildConversationsList(List<Conversation> list) {
    final chatProvider = context.read<ChatProvider>();

    return Container(
      color: AdminTheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _searchCtrl,
              style: GoogleFonts.getFont(FontNames.fontNameH2, color: AdminTheme.textPrimary),
              decoration: AdminTheme.inputDecoration(
                hintText: "Buscar cliente...",
                prefixIcon: const Icon(Icons.search, size: 20, color: AdminTheme.textMuted),
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
                                const Icon(Icons.forum_outlined, size: 48, color: AdminTheme.textMuted),
                                const SizedBox(height: 16),
                                Text(
                                  "No hay conversaciones",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(color: AdminTheme.textMuted),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<ChatProvider>().initializeMockData(widget.businessSlug);
                                  },
                                  icon: const Icon(Icons.bolt, size: 18),
                                  label: Text(
                                    "Crear chats de prueba",
                                    style: GoogleFonts.getFont(
                                      FontNames.fontNameH2,
                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminTheme.accent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AdminTheme.border),
                    itemBuilder: (context, index) {
                      final conv = list[index];
                      final isSelected = chatProvider.selectedConversation?.id == conv.id;
                      final initials = conv.clientName.isNotEmpty
                          ? conv.clientName.substring(0, 1).toUpperCase()
                          : "C";

                      return ListTile(
                        onTap: () {
                          context.read<ChatProvider>().selectConversation(widget.businessSlug, conv);
                        },
                        selected: isSelected,
                        selectedColor: Colors.transparent,
                        tileColor: isSelected ? Colors.white.withValues(alpha: 0.05) : null,
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AdminTheme.accent : AdminTheme.border,
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
                                conv.clientName,
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: TextStyle(
                                    fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                    color: AdminTheme.textPrimary,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${conv.lastMessageTime.hour.toString().padLeft(2, '0')}:${conv.lastMessageTime.minute.toString().padLeft(2, '0')}",
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
                                conv.lastMessage ?? "Sin mensajes",
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            const Icon(Icons.chat_bubble_outline, size: 64, color: AdminTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              "Bandeja de Entrada",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

    final catalog = context.watch<ProductProvider>().products;
    _scrollToBottom();

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
                    provider.selectConversation(widget.businessSlug, activeConv);
                    setState(() {
                      provider.selectedConversation = null;
                    });
                  },
                ),
              CircleAvatar(
                backgroundColor: AdminTheme.border,
                child: Text(
                  activeConv.clientName.isNotEmpty
                      ? activeConv.clientName.substring(0, 1).toUpperCase()
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
                      activeConv.clientName,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Text(
                      activeConv.clientPhone,
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(fontSize: 11, color: AdminTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CreateSaleDialog(
                      businessSlug: widget.businessSlug,
                      initialClientName: activeConv.clientName,
                      initialClientPhone: activeConv.clientPhone,
                    ),
                  );
                },
                icon: const Icon(Icons.point_of_sale_rounded, size: 16),
                label: Text(
                  "Registrar Venta",
                  style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
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
                  style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.border,
                  foregroundColor: AdminTheme.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
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
        if (provider.aiSuggestion != null) _buildAiSuggestionBanner(provider),
        const Divider(height: 1, color: AdminTheme.border),
        _buildChatInputArea(provider, activeConv, catalog),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMerchant) {
    final bubbleBg = isMerchant ? AdminTheme.accent : AdminTheme.surface;
    final textStyle = GoogleFonts.getFont(
      FontNames.fontNameH2,
      textStyle: TextStyle(
        fontSize: 13,
        color: isMerchant ? Colors.white : AdminTheme.textPrimary,
      ),
    );

    return Align(
      alignment: isMerchant ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMerchant ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isMerchant ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.type == 'payment_link')
              _buildPaymentLinkBubble(msg.content, isMerchant)
            else
              Text(msg.content, style: textStyle),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                style: GoogleFonts.courierPrime(
                  textStyle: TextStyle(
                    fontSize: 9,
                    color: isMerchant ? Colors.white70 : AdminTheme.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLinkBubble(String paymentUrl, bool isMerchant) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMerchant ? Colors.white.withValues(alpha: 0.1) : AdminTheme.surface,
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
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.aiSuggestion!,
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(fontSize: 12, color: AdminTheme.textPrimary),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        "Usar sugerencia",
                        style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => provider.clearSuggestion(),
                      child: Text(
                        "Rechazar",
                        style: GoogleFonts.getFont(FontNames.fontNameH2, fontSize: 11, textStyle: const TextStyle(color: AdminTheme.textMuted)),
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

  Widget _buildChatInputArea(ChatProvider provider, Conversation activeConv, List catalog) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.user?.uid ?? "vendedor";

    return Container(
      color: AdminTheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.payment_outlined, color: Colors.orange),
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
                    : const Icon(Icons.auto_awesome_outlined, color: Colors.blue),
                tooltip: "Sugerir respuesta con IA",
                onPressed: () {
                  final lastClientMsg = provider.messages.isNotEmpty
                      ? provider.messages.lastWhere((m) => m.senderId == activeConv.id,
                          orElse: () => ChatMessage(
                                id: '',
                                senderId: '',
                                content: '',
                                timestamp: DateTime.now(),
                                isRead: true,
                                type: 'text',
                              )).content
                      : '';
                  if (lastClientMsg.isNotEmpty) {
                    provider.getAiSuggestion(lastClientMsg, catalog.cast());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No hay mensajes recientes del cliente para sugerir")),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _messageCtrl,
                  style: GoogleFonts.getFont(FontNames.fontNameH2, color: AdminTheme.textPrimary),
                  decoration: AdminTheme.inputDecoration(
                    hintText: "Escribe tu mensaje aquí...",
                  ),
                  onFieldSubmitted: (v) {
                    final txt = _messageCtrl.text.trim();
                    if (txt.isNotEmpty) {
                      provider.sendMessage(
                        businessSlug: widget.businessSlug,
                        conversationId: activeConv.id,
                        content: txt,
                        senderId: userId,
                      );
                      _messageCtrl.clear();
                      _scrollToBottom();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final txt = _messageCtrl.text.trim();
                  if (txt.isNotEmpty) {
                    provider.sendMessage(
                      businessSlug: widget.businessSlug,
                      conversationId: activeConv.id,
                      content: txt,
                      senderId: userId,
                    );
                    _messageCtrl.clear();
                    _scrollToBottom();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AdminTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
