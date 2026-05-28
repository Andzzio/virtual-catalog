import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';
import 'package:virtual_catalog_app/presentation/providers/order_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/utils/admin_theme.dart';

class AdminDashboardView extends StatefulWidget {
  final String businessSlug;
  const AdminDashboardView({super.key, required this.businessSlug});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String _filter = 'all'; // all, paid, pending

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().deleteStalePendingOrders(
        widget.businessSlug,
      );
      context.read<OrderProvider>().listenToBusinessOrders(widget.businessSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final productProvider = context.watch<ProductProvider>();

    final filteredOrders = _filter == 'all'
        ? orderProvider.orders
        : orderProvider.orders.where((o) => o.status == _filter).toList();

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
              "Dashboard",
              style: AdminTheme.appBarTitle(),
            ),
            Text(
              "Resumen de tu negocio en tiempo real.",
              style: AdminTheme.appBarSubtitle(),
            ),
          ],
        ),
      ),
      // Skill: Use LayoutBuilder for responsive decisions
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AdminTheme.breakpointMobile;
          final padding = isMobile ? 16.0 : 30.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiCards(orderProvider, productProvider, isMobile),
                const SizedBox(height: 24),
                _buildFilterTabs(),
                const SizedBox(height: 16),
                if (filteredOrders.isEmpty)
                  _buildEmptyOrders()
                else if (isMobile)
                  _buildOrderCards(filteredOrders)
                else
                  _buildOrdersTable(filteredOrders),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCards(
    OrderProvider orderProvider,
    ProductProvider productProvider,
    bool isMobile,
  ) {
    final cards = [
      _KpiData(
        icon: Icons.attach_money,
        label: "Ventas del mes",
        value: "S/. ${orderProvider.totalSalesThisMonth.toStringAsFixed(2)}",
        color: AdminTheme.success,
        bgColor: AdminTheme.success.withValues(alpha: 0.1),
      ),
      _KpiData(
        icon: Icons.shopping_bag_outlined,
        label: "Pedidos pagados",
        value: "${orderProvider.paidOrdersThisMonth}",
        color: AdminTheme.textSecondary,
        bgColor: AdminTheme.textSecondary.withValues(alpha: 0.1),
      ),
      _KpiData(
        icon: Icons.inventory_2_outlined,
        label: "Productos activos",
        value: "${productProvider.products.length}",
        color: AdminTheme.textPrimary,
        bgColor: AdminTheme.textPrimary.withValues(alpha: 0.08),
      ),
      _KpiData(
        icon: Icons.hourglass_bottom,
        label: "Pendientes",
        value: "${orderProvider.pendingOrdersCount}",
        color: AdminTheme.accent,
        bgColor: AdminTheme.accent.withValues(alpha: 0.08),
      ),
    ];

    if (isMobile) {
      // Skill: Use Wrap instead of GridView.count with fixed aspectRatio to avoid overflow
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards
            .map(
              (d) => SizedBox(
                width: (MediaQuery.sizeOf(context).width - 44) / 2,
                child: _buildKpiCard(d),
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: cards
          .map(
            (d) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildKpiCard(d),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKpiCard(_KpiData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(height: 10),
          // Skill: tabular nums for dynamic numbers
          Text(data.value, style: AdminTheme.kpiValue()),
          const SizedBox(height: 2),
          Text(data.label, style: AdminTheme.caption()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildTab("Todos", 'all'),
        const SizedBox(width: 8),
        _buildTab("Pagados", 'paid'),
        const SizedBox(width: 8),
        _buildTab("Pendientes", 'pending'),
      ],
    );
  }

  Widget _buildTab(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AdminTheme.accent : AdminTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AdminTheme.accent : AdminTheme.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AdminTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AdminTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            "No hay pedidos todavía",
            style: AdminTheme.heading2().copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Los pedidos de tus clientes aparecerán aquí en tiempo real.",
            style: AdminTheme.bodySmall(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<Order> orders) {
    return Container(
      width: double.infinity,
      decoration: AdminTheme.cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.max(950.0,
                  MediaQuery.sizeOf(context).width -
                  AdminTheme.sidebarWidth -
                  80),
            ),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStatePropertyAll(
                AdminTheme.cardBgElevated,
              ),
              columnSpacing: 24,
              columns: [
                _col("Pedido"),
                _col("Cliente"),
                _col("Total"),
                _col("Método"),
                _col("Estado"),
                _col("Fecha"),
              ],
              rows: orders.map((o) {
                return DataRow(
                  onSelectChanged: (_) => _showOrderDetailDialog(o),
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return AdminTheme.surface;
                    }
                    return AdminTheme.cardBg;
                  }),
                  cells: [
                    DataCell(
                      Text(
                        "#${o.id?.substring(0, 8) ?? '---'}",
                        style: _cellStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(
                      Text(
                        "${o.customerName} ${o.customerLastName}",
                        style: _cellStyle(),
                      ),
                    ),
                    DataCell(
                      Text(
                        "S/. ${o.total.toStringAsFixed(2)}",
                        style: _cellStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(
                      Text(o.paymentMethod, style: _cellStyle()),
                    ),
                    DataCell(_buildStatusBadge(o.status)),
                    DataCell(
                      Text(
                        "${o.createdAt.day.toString().padLeft(2, '0')}/${o.createdAt.month.toString().padLeft(2, '0')}/${o.createdAt.year.toString().substring(2)} ${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}",
                        style: _cellStyle(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCards(List<Order> orders) {
    return Column(
      children: orders.map((o) {
        return GestureDetector(
          onTap: () => _showOrderDetailDialog(o),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: AdminTheme.cardDecoration(elevated: false),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "#${o.id?.substring(0, 8) ?? '---'}",
                      style: _cellStyle(fontWeight: FontWeight.w600),
                    ),
                    _buildStatusBadge(o.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${o.customerName} ${o.customerLastName}",
                  style: _cellStyle(),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "S/. ${o.total.toStringAsFixed(2)}",
                      style: _cellStyle(fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        "${o.createdAt.day.toString().padLeft(2, '0')}/${o.createdAt.month.toString().padLeft(2, '0')}/${o.createdAt.year.toString().substring(2)} ${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}",
                        style: AdminTheme.caption(),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showOrderDetailDialog(Order o) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isPaid = o.status == 'paid';
        return StatefulBuilder(
          builder: (stContext, setStateLocal) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminTheme.radiusLg),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 540,
                  maxHeight: 700,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AdminTheme.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Detalle de Pedido",
                              style: AdminTheme.heading2(),
                            ),
                          ),
                          _buildStatusBadge(isPaid ? 'paid' : 'pending'),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    // Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID: #${o.id ?? '---'}",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              "Información del Cliente",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              "Nombre:",
                              "${o.customerName} ${o.customerLastName}",
                            ),
                            _infoRow("DNI:", o.customerDni),
                            _infoRow("Teléfono:", o.customerPhone),
                            if (o.customerEmail != null &&
                                o.customerEmail!.isNotEmpty)
                              _infoRow("Correo:", o.customerEmail!),
                            _infoRow(
                              "Dirección:",
                              "${o.customerAddress}, ${o.customerDepartamento}, ${o.customerProvincia}, ${o.customerDistrito}",
                            ),
                            _infoRow("Departamento:", o.customerDepartamento),
                            _infoRow("Provincia:", o.customerProvincia),
                            _infoRow("Distrito:", o.customerDistrito),
                            if (o.notes != null && o.notes!.isNotEmpty)
                              _infoRow("Notas:", o.notes!),
                            const SizedBox(height: 12),
                            Text(
                              "Información de Facturación",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              "Misma dirección que el envío:",
                              o.isBillingSameAsShipping ? "Sí" : "No",
                            ),
                            if (!o.isBillingSameAsShipping) ...[
                              if (o.billingName != null ||
                                  o.billingLastName != null)
                                _infoRow(
                                  "Nombre:",
                                  "${o.billingName ?? ''} ${o.billingLastName ?? ''}"
                                      .trim(),
                                ),
                              if (o.billingCompany != null &&
                                  o.billingCompany!.isNotEmpty)
                                _infoRow("Empresa:", o.billingCompany!),
                              if (o.billingAddress != null)
                                _infoRow(
                                  "Dirección:",
                                  "${o.billingAddress}, ${o.billingDepartamento ?? ''}, ${o.billingProvincia ?? ''}, ${o.billingDistrito ?? ''}"
                                      .trim(),
                                ),
                              if (o.billingDepartamento != null)
                                _infoRow("Departamento:", o.billingDepartamento!),
                              if (o.billingProvincia != null)
                                _infoRow("Provincia:", o.billingProvincia!),
                              if (o.billingDistrito != null)
                                _infoRow("Distrito:", o.billingDistrito!),
                              if (o.billingReference != null &&
                                  o.billingReference!.isNotEmpty)
                                _infoRow("Referencia:", o.billingReference!),
                              if (o.billingPhone != null &&
                                  o.billingPhone!.isNotEmpty)
                                _infoRow("Teléfono:", o.billingPhone!),
                              if (o.billingCountry != null &&
                                  o.billingCountry!.isNotEmpty)
                                _infoRow("País:", o.billingCountry!),
                            ],
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            Text(
                              "Productos Comprados",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...o.items.map((item) {
                              final variant = item.variant;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          // Variantes & SKU row
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              if (variant.name.isNotEmpty) ...[
                                                Text(
                                                  "Variante: ${variant.name}",
                                                  style: GoogleFonts.getFont(
                                                    FontNames.fontNameH2,
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: AdminTheme
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                if (variant.color != null) ...[
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        variant.color!,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            AdminTheme.border,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                              if (item.size.isNotEmpty) ...[
                                                Text(
                                                  "Talla: ${item.size}",
                                                  style: GoogleFonts.getFont(
                                                    FontNames.fontNameH2,
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: AdminTheme
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (variant.sku != null &&
                                                  variant.sku!.isNotEmpty) ...[
                                                Text(
                                                  "SKU: ${variant.sku}",
                                                  style: GoogleFonts.getFont(
                                                    FontNames.fontNameH2,
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AdminTheme.textMuted,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${item.quantity} x S/. ${item.unitPrice.toStringAsFixed(2)}",
                                      style: GoogleFonts.getFont(
                                        FontNames.fontNameH2,
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total del Pedido:",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  "S/. ${o.total.toStringAsFixed(2)}",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AdminTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _infoRow("Método de pago:", o.paymentMethod),
                            if (o.deliveryMethod != null &&
                                o.deliveryMethod!.isNotEmpty)
                              _infoRow("Método de envío:", o.deliveryMethod!),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                isPaid
                                    ? "Marcado como Pagado"
                                    : "Pendiente de Pago",
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              value: isPaid,
                              activeThumbColor: const Color(0xFF10B981),
                              onChanged: (val) async {
                                setStateLocal(() {
                                  isPaid = val;
                                });
                                final newStatus = val ? 'paid' : 'pending';
                                await context
                                    .read<OrderProvider>()
                                    .updateOrderStatus(
                                      widget.businessSlug,
                                      o.id!,
                                      newStatus,
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AdminTheme.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: dialogContext,
                                builder: (cfContext) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AdminTheme.radiusLg,
                                    ),
                                  ),
                                  title: Text(
                                    "¿Eliminar Pedido?",
                                    style: AdminTheme.heading2(),
                                  ),
                                  content: Text(
                                    "¿Estás seguro de que deseas eliminar este pedido permanentemente?",
                                    style: GoogleFonts.getFont(
                                      FontNames.fontNameH2,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(cfContext).pop(false),
                                      child: Text(
                                        "Cancelar",
                                        style: GoogleFonts.getFont(
                                          FontNames.fontNameH2,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(cfContext).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AdminTheme.danger,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        "Eliminar",
                                        style: GoogleFonts.getFont(
                                          FontNames.fontNameH2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && dialogContext.mounted) {
                                await dialogContext
                                    .read<OrderProvider>()
                                    .deleteOrder(widget.businessSlug, o.id!);
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              }
                            },
                            child: Text(
                              "Eliminar Pedido",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: TextStyle(
                                  color: AdminTheme.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: AdminTheme.primaryButton(),
                            child: Text(
                              "Cerrar",
                              style: GoogleFonts.getFont(FontNames.fontNameH2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AdminTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 13,
                  color: AdminTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'paid':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        label = "Pagado";
        break;
      case 'pending':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        label = "Pendiente";
        break;
      default:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.getFont(
          FontNames.fontNameH2,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AdminTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  TextStyle _cellStyle({FontWeight? fontWeight}) {
    return GoogleFonts.getFont(
      FontNames.fontNameH2,
      textStyle: TextStyle(fontSize: 13, fontWeight: fontWeight),
    );
  }


}

class _KpiData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _KpiData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });
}
