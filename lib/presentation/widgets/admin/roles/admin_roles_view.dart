import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/role_entity.dart';
import 'package:virtual_catalog_app/presentation/providers/roles_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminRolesView extends StatefulWidget {
  final String businessSlug;
  const AdminRolesView({super.key, required this.businessSlug});

  @override
  State<AdminRolesView> createState() => _AdminRolesViewState();
}

class _AdminRolesViewState extends State<AdminRolesView> {
  final List<Color> _curatedColors = const [
    Color(0xFFE23D47),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF0D9488),
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF64748B),
    Color(0xFF06B6D4),
    Color(0xFF15803D),
  ];

  final Map<String, String> _permissionLabels = const {
    'administrator': 'Acceso Total (Administrador Maestro)',
    'catalog:view': 'Ver productos y categorías',
    'catalog:manage': 'Crear y modificar productos / stock',
    'chats:view_all': 'Ver todas las conversaciones del negocio',
    'chats:view_assigned': 'Ver solo conversaciones asignadas',
    'chats:respond': 'Responder mensajes a clientes',
    'chats:assign': 'Asignar conversaciones a otros vendedores',
    'users:manage': 'Gestionar subusuarios (Crear / Eliminar)',
    'roles:manage': 'Gestionar roles y autoridad',
    'settings:manage':
        'Configurar integraciones (APIs / WhatsApp / Facturación)',
    'analytics:view': 'Ver reportes de ventas y rendimiento',
  };

  final Map<String, String> _permissionSubtexts = const {
    'administrator':
        'Concede autoridad total. Omite todas las demás restricciones.',
    'catalog:view':
        'Permite visualizar los productos en el catálogo sin editarlos.',
    'catalog:manage':
        'Permite crear nuevos productos, modificar precios y ajustar inventario.',
    'chats:view_all':
        'Permite ver los chats de todos los vendedores en la bandeja de entrada.',
    'chats:view_assigned':
        'Limita la bandeja de entrada para mostrar solo los chats que tiene asignados.',
    'chats:respond':
        'Permite escribir y enviar mensajes a los clientes desde la bandeja de entrada.',
    'chats:assign': 'Permite derivar chats a otros asesores de venta.',
    'users:manage':
        'Permite invitar nuevos vendedores o remover asesores del negocio.',
    'roles:manage':
        'Permite crear, eliminar o reordenar los roles del negocio.',
    'settings:manage':
        'Permite configurar WhatsApp Business, credenciales Sunat e Izipay.',
    'analytics:view':
        'Permite visualizar gráficos de ventas, rendimiento y reportes financieros.',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolesProvider>().loadRoles(widget.businessSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rolesProvider = context.watch<RolesProvider>();

    return Scaffold(
      backgroundColor: AdminTheme.surface,
      appBar: AppBar(
        backgroundColor: AdminTheme.sidebarBg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withValues(alpha: 0.08),
            height: 1.0,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Roles y Autoridad", style: AdminTheme.appBarTitle()),
            Text(
              "Asigna niveles de autoridad y permisos autogestionados",
              style: AdminTheme.appBarSubtitle(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddRoleDialog(),
            icon: const Icon(Icons.add_moderator_rounded),
            style: AdminTheme.primaryButton(),
            label: Text(
              "Nuevo Rol",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: rolesProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AdminTheme.accent),
            )
          : rolesProvider.roles.isEmpty
          ? _buildEmptyState()
          : _buildRolesContent(rolesProvider.roles),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.security_rounded,
            size: 64,
            color: AdminTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            "Sin roles personalizados",
            style: AdminTheme.heading2().copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Crea roles con distintos permisos para organizar a tu equipo.",
            style: AdminTheme.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRolesContent(List<RoleEntity> roles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "El orden importa: los roles que estén más arriba en la lista tienen mayor nivel de autoridad y pueden supervisar o editar a los usuarios con roles ubicados más abajo.",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: AdminTheme.cardDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: roles.length,
                onReorderItem: (oldIndex, newIndex) {
                  _onReorderRoles(roles, oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return Container(
                    key: ValueKey(role.id),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AdminTheme.border),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.drag_indicator_rounded,
                            color: AdminTheme.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(role.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        role.name,
                        style: AdminTheme.heading2().copyWith(
                          color: Color(role.colorValue),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        key: ValueKey("sub_${role.id}"),
                        child: Text(
                          "${role.permissions.length} permisos activos",
                          style: AdminTheme.caption(),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AdminTheme.accent,
                            ),
                            onPressed: () => _showEditRoleDialog(role),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AdminTheme.danger,
                            ),
                            onPressed: () => _confirmDelete(role),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onReorderRoles(
    List<RoleEntity> currentRoles,
    int oldIndex,
    int newIndex,
  ) async {
    final List<RoleEntity> reorderedList = List.from(currentRoles);
    final role = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, role);

    final List<Map<String, dynamic>> positions = [];
    for (int i = 0; i < reorderedList.length; i++) {
      positions.add({'id': reorderedList[i].id, 'position': i});
    }

    final rolesProvider = context.read<RolesProvider>();
    final success = await rolesProvider.updateRolePositions(
      widget.businessSlug,
      positions,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jerarquía de roles actualizada"),
          backgroundColor: AdminTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${rolesProvider.errorMsg}"),
          backgroundColor: AdminTheme.danger,
        ),
      );
    }
  }

  void _confirmDelete(RoleEntity role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Eliminar Rol", style: AdminTheme.heading2()),
        content: Text(
          "¿Estás seguro de que deseas eliminar el rol ${role.name}? Esto dejará sin este rol a los usuarios asignados.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "Cancelar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Eliminar",
              style: GoogleFonts.getFont(FontNames.fontNameH2),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final rolesProvider = context.read<RolesProvider>();
      final success = await rolesProvider.deleteRole(
        widget.businessSlug,
        role.id,
      );
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rol eliminado con éxito"),
            backgroundColor: AdminTheme.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${rolesProvider.errorMsg}"),
            backgroundColor: AdminTheme.danger,
          ),
        );
      }
    }
  }

  void _showAddRoleDialog() {
    String selectedTemplate = 'blank';
    final nameCtrl = TextEditingController();
    Color selectedColor = _curatedColors.first;
    final List<String> activePermissions = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Crear Nuevo Rol", style: AdminTheme.heading2()),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paso 1: ¿Quieres empezar con una plantilla?",
                        style: AdminTheme.bodySmall(),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor: AdminTheme.cardBg,
                        initialValue: selectedTemplate,
                        style: AdminTheme.body(),
                        decoration: AdminTheme.inputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'blank',
                            child: Text("Comenzar en Blanco"),
                          ),
                          DropdownMenuItem(
                            value: 'vendedor',
                            child: Text("Plantilla: Vendedor Estándar"),
                          ),
                          DropdownMenuItem(
                            value: 'supervisor',
                            child: Text("Plantilla: Supervisor de Ventas"),
                          ),
                          DropdownMenuItem(
                            value: 'catalog',
                            child: Text("Plantilla: Gestor de Catálogo"),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text("Plantilla: Administrador"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedTemplate = val;
                              activePermissions.clear();
                              if (val == 'vendedor') {
                                nameCtrl.text = "Vendedor";
                                activePermissions.addAll([
                                  'chats:view_assigned',
                                  'chats:respond',
                                ]);
                                selectedColor = _curatedColors[5];
                              } else if (val == 'supervisor') {
                                nameCtrl.text = "Supervisor";
                                activePermissions.addAll([
                                  'chats:view_all',
                                  'chats:respond',
                                  'chats:assign',
                                  'analytics:view',
                                ]);
                                selectedColor = _curatedColors[6];
                              } else if (val == 'catalog') {
                                nameCtrl.text = "Gestor Catálogo";
                                activePermissions.addAll([
                                  'catalog:view',
                                  'catalog:manage',
                                ]);
                                selectedColor = _curatedColors[3];
                              } else if (val == 'admin') {
                                nameCtrl.text = "Administrador";
                                activePermissions.add('administrator');
                                selectedColor = _curatedColors[0];
                              } else {
                                nameCtrl.text = "";
                                selectedColor = _curatedColors.first;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Paso 2: Datos generales",
                        style: AdminTheme.bodySmall(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameCtrl,
                        style: AdminTheme.body(),
                        decoration: AdminTheme.inputDecoration(
                          hintText: "Ej. Ventas Nivel 2",
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Paso 3: Color identificador",
                        style: AdminTheme.bodySmall(),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _curatedColors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        const BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AdminTheme.radiusMd,
                          ),
                          border: Border.all(
                            color: selectedColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selectedColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                nameCtrl.text.isEmpty
                                    ? "VISTA PREVIA"
                                    : nameCtrl.text.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Así lucirá la etiqueta del usuario en las pantallas del Kipux.pe.",
                                style: AdminTheme.caption(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Paso 4: Permisos específicos",
                        style: AdminTheme.bodySmall(),
                      ),
                      const SizedBox(height: 8),
                      ..._permissionLabels.entries.map((entry) {
                        final key = entry.key;
                        final label = entry.value;
                        final subtext = _permissionSubtexts[key] ?? '';
                        final isChecked = activePermissions.contains(key);

                        return CheckboxListTile(
                          activeColor: AdminTheme.success,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            label,
                            style: AdminTheme.body().copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(subtext, style: AdminTheme.caption()),
                          value: isChecked,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                activePermissions.add(key);
                                if (key == 'catalog:manage' &&
                                    !activePermissions.contains(
                                      'catalog:view',
                                    )) {
                                  activePermissions.add('catalog:view');
                                }
                                if (key == 'chats:respond' &&
                                    !activePermissions.contains(
                                      'chats:view_assigned',
                                    )) {
                                  activePermissions.add('chats:view_assigned');
                                }
                                if (key == 'chats:assign' &&
                                    !activePermissions.contains(
                                      'chats:view_assigned',
                                    )) {
                                  activePermissions.add('chats:view_assigned');
                                }
                              } else {
                                activePermissions.remove(key);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "Cancelar",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    final newRole = RoleEntity(
                      id: UniqueKey().toString(),
                      businessId: widget.businessSlug,
                      name: nameCtrl.text,
                      colorValue: selectedColor.toARGB32(),
                      position: 0,
                      permissions: activePermissions,
                    );
                    context.read<RolesProvider>().createRole(
                      widget.businessSlug,
                      newRole,
                    );
                  },
                  style: AdminTheme.primaryButton(),
                  child: Text(
                    "Crear Rol",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditRoleDialog(RoleEntity role) {
    final nameCtrl = TextEditingController(text: role.name);
    Color selectedColor = Color(role.colorValue);
    final List<String> activePermissions = List.from(role.permissions);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Editar Rol", style: AdminTheme.heading2()),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nombre del rol", style: AdminTheme.bodySmall()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameCtrl,
                        style: AdminTheme.body(),
                        decoration: AdminTheme.inputDecoration(),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Color identificador",
                        style: AdminTheme.bodySmall(),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _curatedColors.map((color) {
                          final isSelected =
                              selectedColor.toARGB32() == color.toARGB32();
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        const BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AdminTheme.radiusMd,
                          ),
                          border: Border.all(
                            color: selectedColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selectedColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                nameCtrl.text.isEmpty
                                    ? "VISTA PREVIA"
                                    : nameCtrl.text.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Así lucirá la etiqueta del usuario en las pantallas del Kipux.pe.",
                                style: AdminTheme.caption(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Permisos específicos",
                        style: AdminTheme.bodySmall(),
                      ),
                      const SizedBox(height: 8),
                      ..._permissionLabels.entries.map((entry) {
                        final key = entry.key;
                        final label = entry.value;
                        final subtext = _permissionSubtexts[key] ?? '';
                        final isChecked = activePermissions.contains(key);

                        return CheckboxListTile(
                          activeColor: AdminTheme.success,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            label,
                            style: AdminTheme.body().copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(subtext, style: AdminTheme.caption()),
                          value: isChecked,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                activePermissions.add(key);
                                if (key == 'catalog:manage' &&
                                    !activePermissions.contains(
                                      'catalog:view',
                                    )) {
                                  activePermissions.add('catalog:view');
                                }
                                if (key == 'chats:respond' &&
                                    !activePermissions.contains(
                                      'chats:view_assigned',
                                    )) {
                                  activePermissions.add('chats:view_assigned');
                                }
                                if (key == 'chats:assign' &&
                                    !activePermissions.contains(
                                      'chats:view_assigned',
                                    )) {
                                  activePermissions.add('chats:view_assigned');
                                }
                              } else {
                                activePermissions.remove(key);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "Cancelar",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    final updatedRole = RoleEntity(
                      id: role.id,
                      businessId: widget.businessSlug,
                      name: nameCtrl.text,
                      colorValue: selectedColor.toARGB32(),
                      position: role.position,
                      permissions: activePermissions,
                    );
                    context.read<RolesProvider>().updateRole(
                      widget.businessSlug,
                      updatedRole,
                    );
                  },
                  style: AdminTheme.primaryButton(),
                  child: Text(
                    "Guardar Cambios",
                    style: GoogleFonts.getFont(FontNames.fontNameH2),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
