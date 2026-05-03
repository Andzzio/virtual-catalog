import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';
import 'package:virtual_catalog_app/presentation/providers/order_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';

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
      context.read<OrderProvider>().deleteStalePendingOrders(widget.businessSlug);
      context.read<OrderProvider>().listenToBusinessOrders(widget.businessSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isMobile = MediaQuery.sizeOf(context).width < 800;

    final filteredOrders = _filter == 'all'
        ? orderProvider.orders
        : orderProvider.orders.where((o) => o.status == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E2E2), height: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Resumen de tu negocio en tiempo real.",
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 30,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            _buildKpiCards(orderProvider, productProvider, isMobile),
            const SizedBox(height: 24),
            // Filter tabs
            _buildFilterTabs(),
            const SizedBox(height: 16),
            // Orders
            if (filteredOrders.isEmpty)
              _buildEmptyOrders()
            else if (isMobile)
              _buildOrderCards(filteredOrders)
            else
              _buildOrdersTable(filteredOrders),
          ],
        ),
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
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
      ),
      _KpiData(
        icon: Icons.shopping_bag_outlined,
        label: "Pedidos pagados",
        value: "${orderProvider.paidOrdersThisMonth}",
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
      ),
      _KpiData(
        icon: Icons.inventory_2_outlined,
        label: "Productos activos",
        value: "${productProvider.products.length}",
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
      ),
      _KpiData(
        icon: Icons.hourglass_bottom,
        label: "Pendientes",
        value: "${orderProvider.pendingOrdersCount}",
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
      ),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: cards.map((d) => _buildKpiCard(d)).toList(),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
          Text(
            data.value,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
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
            color: isActive ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? Colors.black : const Color(0xFFE2E2E2),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[700],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "No hay pedidos todavía",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Los pedidos de tus clientes aparecerán aquí en tiempo real.",
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<Order> orders) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          showCheckboxColumn: false,
          headingRowColor: WidgetStatePropertyAll(Colors.grey[50]),
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
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFF3F4F6); // soft gray on hover
                }
                return Colors.white;
              }),
              cells: [
                _clickableCell(
                  Text(
                    "#${o.id?.substring(0, 8) ?? '---'}",
                    style: _cellStyle(fontWeight: FontWeight.w600),
                  ),
                  o,
                ),
                _clickableCell(
                  Text(
                    "${o.customerName} ${o.customerLastName}",
                    style: _cellStyle(),
                  ),
                  o,
                ),
                _clickableCell(
                  Text(
                    "S/. ${o.total.toStringAsFixed(2)}",
                    style: _cellStyle(fontWeight: FontWeight.w600),
                  ),
                  o,
                ),
                _clickableCell(Text(o.paymentMethod, style: _cellStyle()), o),
                _clickableCell(_buildStatusBadge(o.status), o),
                _clickableCell(
                  Text(
                    "${o.createdAt.day.toString().padLeft(2, '0')}/${o.createdAt.month.toString().padLeft(2, '0')}/${o.createdAt.year.toString().substring(2)} ${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}",
                    style: _cellStyle(),
                  ),
                  o,
                ),
              ],
            );
          }).toList(),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
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
                    Text(
                      "${o.createdAt.day.toString().padLeft(2, '0')}/${o.createdAt.month.toString().padLeft(2, '0')}/${o.createdAt.year.toString().substring(2)} ${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
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
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detalle de Pedido",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusBadge(isPaid ? 'paid' : 'pending'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID: #${o.id ?? '---'}",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        "Información del Cliente",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _infoRow("Nombre:", "${o.customerName} ${o.customerLastName}"),
                      _infoRow("DNI:", o.customerDni),
                      _infoRow("Teléfono:", o.customerPhone),
                      if (o.customerEmail != null && o.customerEmail!.isNotEmpty)
                        _infoRow("Correo:", o.customerEmail!),
                      _infoRow("Dirección:", "${o.customerAddress}, ${o.customerCity}, ${o.customerRegion}"),
                      if (o.notes != null && o.notes!.isNotEmpty)
                        _infoRow("Notas:", o.notes!),
                      const SizedBox(height: 12),
                      Text(
                        "Información de Facturación",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _infoRow("Misma dirección que el envío:", o.isBillingSameAsShipping ? "Sí" : "No"),
                      if (!o.isBillingSameAsShipping) ...[
                        if (o.billingName != null || o.billingLastName != null)
                          _infoRow("Nombre:", "${o.billingName ?? ''} ${o.billingLastName ?? ''}".trim()),
                        if (o.billingCompany != null && o.billingCompany!.isNotEmpty)
                          _infoRow("Empresa:", o.billingCompany!),
                        if (o.billingAddress != null)
                          _infoRow("Dirección:", "${o.billingAddress}, ${o.billingDistrict ?? ''}, ${o.billingRegion ?? ''}".trim()),
                        if (o.billingReference != null && o.billingReference!.isNotEmpty)
                          _infoRow("Referencia:", o.billingReference!),
                        if (o.billingPhone != null && o.billingPhone!.isNotEmpty)
                          _infoRow("Teléfono:", o.billingPhone!),
                        if (o.billingCountry != null && o.billingCountry!.isNotEmpty)
                          _infoRow("País:", o.billingCountry!),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        "Productos Comprados",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...o.items.map((item) {
                        final variant = item.variant;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: GoogleFonts.getFont(
                                        FontNames.fontNameH2,
                                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Variantes & SKU row
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        if (variant.name.isNotEmpty) ...[
                                          Text(
                                            "Variante: ${variant.name}",
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          if (variant.color != null) ...[
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Color(variant.color!),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.grey.shade300, width: 1),
                                              ),
                                            ),
                                          ],
                                        ],
                                        if (item.size.isNotEmpty) ...[
                                          Text(
                                            "Talla: ${item.size}",
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                        if (variant.sku != null && variant.sku!.isNotEmpty) ...[
                                          Text(
                                            "SKU: ${variant.sku}",
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            "S/. ${o.total.toStringAsFixed(2)}",
                            style: GoogleFonts.getFont(
                              FontNames.fontNameH2,
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      _infoRow("Método de pago:", o.paymentMethod),
                      if (o.deliveryMethod != null && o.deliveryMethod!.isNotEmpty)
                        _infoRow("Método de envío:", o.deliveryMethod!),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isPaid ? "Marcado como Pagado" : "Pendiente de Pago",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
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
                          await context.read<OrderProvider>().updateOrderStatus(
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
              actions: [
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: dialogContext,
                      builder: (cfContext) => AlertDialog(
                        title: Text(
                          "¿Eliminar Pedido?",
                          style: GoogleFonts.getFont(
                            FontNames.fontNameH2,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        content: Text(
                          "¿Estás seguro de que deseas eliminar este pedido permanentemente?",
                          style: GoogleFonts.getFont(FontNames.fontNameH2),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(cfContext).pop(false),
                            child: Text(
                              "Cancelar",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(cfContext).pop(true),
                            child: Text(
                              "Eliminar",
                              style: GoogleFonts.getFont(
                                FontNames.fontNameH2,
                                textStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && dialogContext.mounted) {
                      await dialogContext.read<OrderProvider>().deleteOrder(
                        widget.businessSlug,
                        o.id!,
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  child: Text(
                    "Eliminar Pedido",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "Cerrar",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
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
              textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.getFont(
                FontNames.fontNameH2,
                textStyle: const TextStyle(fontSize: 13, color: Colors.black),
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
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
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

  DataCell _clickableCell(Widget child, Order o) {
    return DataCell(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showOrderDetailDialog(o),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      ),
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
