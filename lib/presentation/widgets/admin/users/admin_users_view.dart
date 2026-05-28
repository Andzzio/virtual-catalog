import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/user_entity.dart';
import 'package:virtual_catalog_app/presentation/providers/auth_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/users_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminUsersView extends StatefulWidget {
  final String businessSlug;
  const AdminUsersView({super.key, required this.businessSlug});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers(widget.businessSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = context.watch<UsersProvider>();
    final currentFirebaseUser = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.sidebarBg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white.withValues(alpha: 0.08), height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Usuarios",
              style: AdminTheme.appBarTitle(),
            ),
            Text(
              "Gestión de accesos y roles (Admin / Vendedor)",
              style: AdminTheme.appBarSubtitle(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Nuevo Usuario",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: usersProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AdminTheme.accent))
          : usersProvider.users.isEmpty
              ? _buildEmptyState()
              : _buildUsersList(usersProvider.users, currentFirebaseUser?.uid),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline_rounded, size: 64, color: AdminTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            "Sin usuarios creados",
            style: AdminTheme.heading2().copyWith(color: AdminTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            "Crea cuentas de vendedores para que accedan al panel.",
            style: AdminTheme.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<UserEntity> users, String? currentUid) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AdminTheme.cardDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.2),
              3: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: AdminTheme.cardBg,
                  border: Border(bottom: BorderSide(color: AdminTheme.border)),
                ),
                children: [
                  _headerCell("Nombre"),
                  _headerCell("Email"),
                  _headerCell("Rol"),
                  _headerCell("Acciones"),
                ],
              ),
              ...users.map((user) {
                final isSelf = user.id == currentUid;
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AdminTheme.border)),
                  ),
                  children: [
                    _cell(user.name, isBold: true),
                    _cell(user.email, isMono: true),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.role == "admin"
                                  ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                                  : const Color(0xFF64748B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: user.role == "admin"
                                      ? const Color(0xFF818CF8)
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: isSelf
                            ? const SizedBox(width: 96, height: 40)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: AdminTheme.accent),
                                    onPressed: () => _showEditRoleDialog(user),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.danger),
                                    onPressed: () => _confirmDelete(user),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _cell(String text, {bool isBold = false, bool isMono = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: GoogleFonts.getFont(
            isMono ? FontNames.fontNameP : FontNames.fontNameH2,
            textStyle: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: isMono ? 'monospace' : null,
              color: AdminTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(UserEntity user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AdminTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
        title: Text(
          "Eliminar Usuario",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
          ),
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar la cuenta de ${user.name}?",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(color: AdminTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text("Cancelar", style: GoogleFonts.getFont(FontNames.fontNameH2)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Eliminar", style: GoogleFonts.getFont(FontNames.fontNameH2)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final usersProvider = context.read<UsersProvider>();
      final success = await usersProvider.deleteUser(widget.businessSlug, user.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado correctamente"), backgroundColor: AdminTheme.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${usersProvider.errorMsg}"), backgroundColor: AdminTheme.danger),
        );
      }
    }
  }

  void _showEditRoleDialog(UserEntity user) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminTheme.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
              title: Text(
                "Modificar Permisos",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Usuario: ${user.name}",
                    style: AdminTheme.bodySmall(),
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel("Rol / Permiso"),
                  DropdownButtonFormField<String>(
                    dropdownColor: AdminTheme.cardBg,
                    initialValue: selectedRole,
                    style: AdminTheme.body(),
                    decoration: AdminTheme.inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                      DropdownMenuItem(value: "vendedor", child: Text("Vendedor")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedRole = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text("Cancelar", style: GoogleFonts.getFont(FontNames.fontNameH2)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    _updateRole(user.id, selectedRole);
                  },
                  style: AdminTheme.primaryButton(),
                  child: Text("Guardar", style: GoogleFonts.getFont(FontNames.fontNameH2)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateRole(String userId, String role) async {
    final success = await context.read<UsersProvider>().updateUserRole(
          widget.businessSlug,
          userId,
          role,
        );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rol actualizado correctamente"), backgroundColor: AdminTheme.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${context.read<UsersProvider>().errorMsg}"), backgroundColor: AdminTheme.danger),
        );
      }
    }
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String selectedRole = "vendedor";
    final formKey = GlobalKey<FormState>();
    bool obscurePass = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminTheme.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminTheme.radiusLg)),
              title: Text(
                "Crear Usuario",
                style: GoogleFonts.getFont(
                  FontNames.fontNameH2,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Nombre Completo"),
                      TextFormField(
                        controller: nameCtrl,
                        style: AdminTheme.body(),
                        validator: (v) => v == null || v.isEmpty ? "Ingresa el nombre" : null,
                        decoration: AdminTheme.inputDecoration(hintText: "Ej. Juan Pérez"),
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel("Correo Electrónico"),
                      TextFormField(
                        controller: emailCtrl,
                        style: AdminTheme.body(),
                        validator: (v) => v == null || v.isEmpty ? "Ingresa el correo" : null,
                        decoration: AdminTheme.inputDecoration(hintText: "Ej. juan@email.com"),
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel("Contraseña"),
                      TextFormField(
                        controller: passCtrl,
                        style: AdminTheme.body(),
                        obscureText: obscurePass,
                        validator: (v) => v == null || v.length < 6 ? "Mínimo 6 caracteres" : null,
                        decoration: AdminTheme.inputDecoration(
                          hintText: "••••••••",
                          suffixIcon: IconButton(
                            icon: Icon(obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                            onPressed: () {
                              setDialogState(() {
                                obscurePass = !obscurePass;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel("Confirmar Contraseña"),
                      TextFormField(
                        controller: confirmPassCtrl,
                        style: AdminTheme.body(),
                        obscureText: obscureConfirm,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Confirma la contraseña";
                          if (v != passCtrl.text) return "Las contraseñas no coinciden";
                          return null;
                        },
                        decoration: AdminTheme.inputDecoration(
                          hintText: "••••••••",
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel("Rol"),
                      DropdownButtonFormField<String>(
                        dropdownColor: AdminTheme.cardBg,
                        initialValue: selectedRole,
                        style: AdminTheme.body(),
                        decoration: AdminTheme.inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: "admin", child: Text("Admin")),
                          DropdownMenuItem(value: "vendedor", child: Text("Vendedor")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedRole = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text("Cancelar", style: GoogleFonts.getFont(FontNames.fontNameH2)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop();
                      _createUser(nameCtrl.text, emailCtrl.text, passCtrl.text, selectedRole);
                    }
                  },
                  style: AdminTheme.primaryButton(),
                  child: Text("Crear", style: GoogleFonts.getFont(FontNames.fontNameH2)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createUser(String name, String email, String password, String role) async {
    final usersProvider = context.read<UsersProvider>();
    final success = await usersProvider.createUser(
          businessSlug: widget.businessSlug,
          name: name,
          email: email,
          password: password,
          role: role,
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado con éxito"), backgroundColor: AdminTheme.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${usersProvider.errorMsg}"), backgroundColor: AdminTheme.danger),
      );
    }
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
