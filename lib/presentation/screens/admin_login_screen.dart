import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  final String businessSlug;
  const AdminLoginScreen({super.key, required this.businessSlug});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool isObscure = true;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _resetPassword(BuildContext context) async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingresa tu correo en el campo superior primero"),
        ),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().authRepository.resetPassword(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Correo de recuperación enviado a $email"),
          backgroundColor: AdminTheme.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: no se pudo enviar el correo de recuperación."),
          backgroundColor: AdminTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AdminTheme.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: AdminTheme.cardDecoration(),
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo / Header ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminTheme.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 40,
                      color: AdminTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Admin Panel", style: AdminTheme.heading1()),
                  const SizedBox(height: 8),
                  Text(
                    "Inicia sesión para gestionar tu catálogo",
                    style: AdminTheme.bodySmall(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ── Form ───────────────────────────────
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel("Correo Electrónico"),
                        TextFormField(
                          controller: emailCtrl,
                          style: AdminTheme.body(),
                          validator: (v) => v == null || v.isEmpty
                              ? "Ingresa tu correo"
                              : null,
                          decoration: AdminTheme.inputDecoration(
                            hintText: "admin@email.com",
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _fieldLabel("Contraseña"),
                        TextFormField(
                          controller: passCtrl,
                          obscureText: isObscure,
                          style: AdminTheme.body(),
                          validator: (v) => v == null || v.isEmpty
                              ? "Ingresa tu contraseña"
                              : null,
                          decoration: AdminTheme.inputDecoration(
                            hintText: "••••••••",
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => isObscure = !isObscure),
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Submit Button ──────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: AdminTheme.primaryButton(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Ingresar", style: AdminTheme.body().copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => _resetPassword(context),
                    child: Text(
                      "¿Olvidaste tu contraseña?",
                      style: AdminTheme.bodySmall().copyWith(color: AdminTheme.accentLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AdminTheme.bodySmall().copyWith(
          fontWeight: FontWeight.bold,
          color: AdminTheme.textPrimary,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    final authProvider = context.read<AuthProvider>();
    final businessProvider = context.read<BusinessProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: AdminTheme.accent)),
    );

    final success = await authProvider.login(email, password);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMsg),
          backgroundColor: AdminTheme.danger,
        ),
      );
      return;
    }

    await businessProvider.loadBusiness(widget.businessSlug);
    final business = businessProvider.business;
    final user = authProvider.user;

    if (business != null && user != null && business.ownerId == user.uid) {
      if (!mounted) return;
      context.go("/${widget.businessSlug}/admin/dashboard");
    } else {
      await authProvider.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes permiso para administrar este negocio"),
          backgroundColor: AdminTheme.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
