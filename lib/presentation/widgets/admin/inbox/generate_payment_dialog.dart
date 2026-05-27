import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/chat_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';
import 'dart:math';

class GeneratePaymentDialog extends StatefulWidget {
  final String businessSlug;
  final String conversationId;
  final String senderId;

  const GeneratePaymentDialog({
    super.key,
    required this.businessSlug,
    required this.conversationId,
    required this.senderId,
  });

  @override
  State<GeneratePaymentDialog> createState() => _GeneratePaymentDialogState();
}

class _GeneratePaymentDialogState extends State<GeneratePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  late final String _generatedOrderId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _generatedOrderId = "PED-${100000 + random.nextInt(900000)}";
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.generateIzipayLink(
        businessId: widget.businessSlug,
        amount: double.parse(_amountCtrl.text.trim()),
        orderId: _generatedOrderId,
        conversationId: widget.conversationId,
        senderId: widget.senderId,
        customerEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        customerName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Enlace de pago generado y enviado")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error al generar pago: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdminTheme.cardBgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Generar Enlace Izipay",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Código de orden: $_generatedOrderId",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Monto (S/)",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.getFont(FontNames.fontNameH2, color: AdminTheme.textPrimary),
                decoration: AdminTheme.inputDecoration(hintText: "0.00"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Monto es requerido";
                  final numVal = double.tryParse(value.trim());
                  if (numVal == null || numVal <= 0) return "Ingrese un monto válido mayor a 0";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                "Nombre del cliente (Opcional)",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.getFont(FontNames.fontNameH2, color: AdminTheme.textPrimary),
                decoration: AdminTheme.inputDecoration(hintText: "Ej: Juan Pérez"),
              ),
              const SizedBox(height: 16),
              Text(
                "Correo electrónico (Opcional)",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.getFont(FontNames.fontNameH2, color: AdminTheme.textPrimary),
                decoration: AdminTheme.inputDecoration(hintText: "Ej: juan@gmail.com"),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancelar",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          color: AdminTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Generar",
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH2,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
