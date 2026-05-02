import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_type.dart';

class AdminSettingsPaymentSection extends StatefulWidget {
  final List<PaymentMethod> methods;
  final ValueChanged<List<PaymentMethod>> onChanged;
  final String? izipayUsername;
  final String? izipayPassword;
  final String? izipayPublicKey;
  final ValueChanged<Map<String, String?>> onIzipayCredentialsChanged;

  const AdminSettingsPaymentSection({
    super.key,
    required this.methods,
    required this.onChanged,
    this.izipayUsername,
    this.izipayPassword,
    this.izipayPublicKey,
    required this.onIzipayCredentialsChanged,
  });

  @override
  State<AdminSettingsPaymentSection> createState() =>
      _AdminSettingsPaymentSectionState();
}

class _AdminSettingsPaymentSectionState
    extends State<AdminSettingsPaymentSection> {
  bool _showUsername = false;
  bool _showPassword = false;
  bool _showPublicKey = false;

  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _publicKeyCtrl;
  bool _initialized = false;

  @override
  void didUpdateWidget(covariant AdminSettingsPaymentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) {
      _initControllers();
    }
  }

  void _initControllers() {
    if (_initialized) return;
    _usernameCtrl =
        TextEditingController(text: widget.izipayUsername ?? "");
    _passwordCtrl =
        TextEditingController(text: widget.izipayPassword ?? "");
    _publicKeyCtrl =
        TextEditingController(text: widget.izipayPublicKey ?? "");
    _initialized = true;
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    if (_initialized) {
      _usernameCtrl.dispose();
      _passwordCtrl.dispose();
      _publicKeyCtrl.dispose();
    }
    super.dispose();
  }

  void _emitCredentials() {
    widget.onIzipayCredentialsChanged({
      "izipayUsername": _usernameCtrl.text.trim().isEmpty
          ? null
          : _usernameCtrl.text.trim(),
      "izipayPassword": _passwordCtrl.text.trim().isEmpty
          ? null
          : _passwordCtrl.text.trim(),
      "izipayPublicKey": _publicKeyCtrl.text.trim().isEmpty
          ? null
          : _publicKeyCtrl.text.trim(),
    });
  }

  bool get _hasIzipay =>
      widget.methods.any((m) => m.type == PaymentType.izipay);

  void _addMethod() {
    final updated = List<PaymentMethod>.from(widget.methods)
      ..add(PaymentMethod(name: "", type: PaymentType.whatsapp));
    widget.onChanged(updated);
  }

  void _removeMethod(int index) {
    final updated = List<PaymentMethod>.from(widget.methods)..removeAt(index);
    widget.onChanged(updated);
  }

  void _updateMethod(int index, PaymentMethod method) {
    final updated = List<PaymentMethod>.from(widget.methods);
    updated[index] = method;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payment_outlined, color: Colors.grey[700]),
            const SizedBox(width: 10),
            Text(
              "Métodos de Pago",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addMethod,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                "Agregar",
                style: GoogleFonts.getFont(FontNames.fontNameH2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.methods.isEmpty)
          _buildEmptyHint("No hay métodos de pago configurados.")
        else
          ...List.generate(widget.methods.length, (i) {
            return _buildMethodRow(i, widget.methods[i]);
          }),
        if (_hasIzipay) ...[
          const SizedBox(height: 16),
          _buildIzipayCredentialsPanel(),
        ],
      ],
    );
  }

  Widget _buildIzipayCredentialsPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 14, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 4),
                    Text(
                      "Credenciales Izipay",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                "Requerido para pagos con Izipay",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecureField(
            controller: _usernameCtrl,
            label: "Shop ID (Usuario)",
            hint: "Ej: 14324588",
            isVisible: _showUsername,
            onToggle: () =>
                setState(() => _showUsername = !_showUsername),
            onChanged: (_) => _emitCredentials(),
            validator: _hasIzipay
                ? (v) => (v == null || v.trim().isEmpty)
                    ? "Requerido si usas Izipay"
                    : null
                : null,
          ),
          const SizedBox(height: 12),
          _buildSecureField(
            controller: _passwordCtrl,
            label: "Contraseña de Producción",
            hint: "Clave API REST",
            isVisible: _showPassword,
            onToggle: () =>
                setState(() => _showPassword = !_showPassword),
            onChanged: (_) => _emitCredentials(),
            validator: _hasIzipay
                ? (v) => (v == null || v.trim().isEmpty)
                    ? "Requerido si usas Izipay"
                    : null
                : null,
          ),
          const SizedBox(height: 12),
          _buildSecureField(
            controller: _publicKeyCtrl,
            label: "Llave Pública",
            hint: "Clave pública para el formulario de pago",
            isVisible: _showPublicKey,
            onToggle: () =>
                setState(() => _showPublicKey = !_showPublicKey),
            onChanged: (_) => _emitCredentials(),
            validator: _hasIzipay
                ? (v) => (v == null || v.trim().isEmpty)
                    ? "Requerido si usas Izipay"
                    : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSecureField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          onChanged: onChanged,
          style: GoogleFonts.getFont(FontNames.fontNameH2,
              textStyle: const TextStyle(fontSize: 13)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMethodRow(int index, PaymentMethod method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            final nameField = TextFormField(
              initialValue: method.name,
              decoration: _inputDecoration("Nombre"),
              style: GoogleFonts.getFont(FontNames.fontNameH2,
                  textStyle: const TextStyle(fontSize: 13)),
              onChanged: (val) => _updateMethod(
                index,
                PaymentMethod(
                  name: val,
                  type: method.type,
                  description: method.description,
                ),
              ),
            );
            final typeField = DropdownButtonFormField<PaymentType>(
              initialValue: method.type,
              decoration: _inputDecoration("Tipo"),
              style: GoogleFonts.getFont(FontNames.fontNameH2,
                  textStyle:
                      const TextStyle(fontSize: 13, color: Colors.black)),
              items: PaymentType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                _updateMethod(
                  index,
                  PaymentMethod(
                    name: method.name,
                    type: val,
                    description: method.description,
                  ),
                );
              },
            );
            final descField = TextFormField(
              initialValue: method.description ?? "",
              decoration: _inputDecoration("Descripción (opcional)"),
              style: GoogleFonts.getFont(FontNames.fontNameH2,
                  textStyle: const TextStyle(fontSize: 13)),
              onChanged: (val) => _updateMethod(
                index,
                PaymentMethod(
                  name: method.name,
                  type: method.type,
                  description: val.isEmpty ? null : val,
                ),
              ),
            );
            final deleteBtn = IconButton(
              onPressed: () => _removeMethod(index),
              icon: const Icon(Icons.close, size: 18),
              style: IconButton.styleFrom(foregroundColor: Colors.redAccent),
            );

            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: nameField),
                      deleteBtn,
                    ],
                  ),
                  const SizedBox(height: 8),
                  typeField,
                  const SizedBox(height: 8),
                  descField,
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: nameField),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: typeField),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: descField),
                const SizedBox(width: 8),
                deleteBtn,
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}
