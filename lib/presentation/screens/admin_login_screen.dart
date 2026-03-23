import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';


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
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: no se pudo enviar el correo de recuperación."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 100, horizontal: 20),
            padding: EdgeInsets.all(50),
            constraints: BoxConstraints(maxWidth: 550),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.grey,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Bienvenido",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Inicia sesión para gestionar tu catálogo",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Correo Electrónico",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: emailCtrl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor, ingresa tu correo electrónico";
                            }
                            return null;
                          },
                          decoration: _inputDecoration(isPassword: false),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Contraseña",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: passCtrl,
                          obscureText: isObscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor, ingresa tu contraseña";
                            }
                            return null;
                          },
                          decoration: _inputDecoration(isPassword: true),
                        ),
                        SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final email = emailCtrl.text.trim();
                            final password = passCtrl.text.trim();

                            if (email.isEmpty || password.isEmpty) return;

                            final authProvider = context.read<AuthProvider>();

                            final businessProvider = context
                                .read<BusinessProvider>();

                            final success = await authProvider.login(
                              email,
                              password,
                            );

                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.errorMsg),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            if (success && context.mounted) {
                              await businessProvider.loadBusiness(
                                widget.businessSlug,
                              );
                              final business = businessProvider.business;
                              final user = authProvider.user;

                              if (business != null &&
                                  user != null &&
                                  business.ownerId == user.uid) {
                                // ignore: use_build_context_synchronously
                                context.go(
                                  "/${widget.businessSlug}/admin/dashboard",
                                );
                              } else {
                                await authProvider.logout();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "No tienes permiso para administrar este negocio",
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Ingresar",
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.input_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => _resetPassword(context),
                  child: Text(
                    "Olvidé mi contraseña",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required bool isPassword}) {
    return InputDecoration(
      hintText: isPassword ? "Contraseña" : "admin@email.com",
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(color: Colors.grey),
      ),
      prefixIcon: isPassword
          ? Icon(Icons.lock_outline, color: Colors.grey)
          : Icon(Icons.email_outlined, color: Colors.grey),
      suffixIcon: isPassword
          ? IconButton(
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
              icon: Icon(
                isObscure
                    ? Icons.remove_red_eye_outlined
                    : Icons.visibility_off_outlined,
              ),
            )
          : null,
      filled: true,
      fillColor: Color.fromARGB(255, 238, 239, 240),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
