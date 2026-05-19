import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/config/routers/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';
import 'package:virtual_catalog_app/domain/entities/product.dart';
import 'package:virtual_catalog_app/config/themes/app_theme_styles.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/quantity_selector.dart';

class ProductInfoSection extends StatefulWidget {
  final Product product;
  const ProductInfoSection({super.key, required this.product});

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  int selectedVariantIndex = 0;
  int quantity = 1;
  String? selectedSize;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = context.read<CartProvider>();
    final selectedVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants[selectedVariantIndex]
        : null;
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 600 ? 20 : 32,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: GoogleFonts.getFont(
              FontNames.fontNameH2,
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppPaddings.p12),
          if (selectedVariant == null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[800]),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      "Producto próximamente disponible",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameP,
                        textStyle: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "S/. ${selectedVariant.discountPrice ?? selectedVariant.price}",
                  style: GoogleFonts.getFont(
                    FontNames.fontNameH2,
                    textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ),
                if (selectedVariant.discountPrice != null) ...[
                  const SizedBox(width: AppPaddings.p12),
                  Text(
                    "S/. ${selectedVariant.price}",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: AppPaddings.p24),
          Divider(color: const Color.fromARGB(255, 226, 225, 225)),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            shape: Border(),
            title: Text(
              "DESCRIPCIÓN",
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.product.description,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      textStyle: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: const Color.fromARGB(255, 226, 225, 225)),
          if (selectedVariant != null) ...[
            const SizedBox(height: AppPaddings.p32),
            Text(
              "TALLA",
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: AppPaddings.p12),
            SelectionContainer.disabled(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedVariant.sizes.map((size) {
                  final isSizeSelected = selectedSize == size;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSizeSelected ? theme.primaryColor : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppBorders.radiusButton),
                          border: isSizeSelected
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          size,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameP,
                            fontSize: 14,
                            fontWeight: isSizeSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSizeSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppPaddings.p24),
            Text(
              "COLOR ${selectedVariant.name.toUpperCase()}",
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: AppPaddings.p12),
            Wrap(
              children: List.generate(widget.product.variants.length, (index) {
                final variant = widget.product.variants[index];
                final isSelected = selectedVariantIndex == index;

                final Color color = variant.color != null
                    ? Color(variant.color!)
                    : Colors.grey;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedVariantIndex = index;
                        final newVariant = widget.product.variants[index];
                        if (newVariant.sizes.contains(selectedSize)) {
                        } else {
                          selectedSize = null;
                        }
                        if (newVariant.stock < quantity) {
                          quantity = newVariant.stock;
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.all(2),
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? theme.primaryColor : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: !isSelected
                              ? Border.all(color: AppColors.border)
                              : null,
                          boxShadow: [
                            if (isSelected) AppShadows.soft
                          ]
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppPaddings.p12),
            Text(
              "STOCK DISPONIBLE: ${selectedVariant.stock}",
              style: GoogleFonts.getFont(
                FontNames.fontNameP,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.0),
              ),
            ),
            if (selectedVariant.stock <= 0) ...[
              const SizedBox(height: 5),
              Text(
                "Producto agotado",
                style: GoogleFonts.getFont(
                  FontNames.fontNameP,
                  textStyle: const TextStyle(fontSize: 14, color: AppColors.error),
                ),
              ),
            ],
            SizedBox(height: 20),
            Column(
              spacing: 20,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: size.width < 1200 && size.width > 900 ? 3 : 7,
                        child: FilledButton.icon(
                          onPressed: selectedVariant.stock <= 0
                              ? null
                              : () {
                                  if (selectedSize == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Selecciona una talla",
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.getFont(
                                            FontNames.fontNameP,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  cartProvider.addItem(
                                    widget.product,
                                    selectedVariant,
                                    selectedSize!,
                                    quantity,
                                  );
                                  setState(() {
                                    quantity = 1;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Producto agregado al carrito ✓",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.getFont(
                                          FontNames.fontNameP,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          icon: Icon(Icons.shopping_cart),
                          label: Text(
                            "Agregar al Carrito",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.getFont(
                              FontNames.fontNameP,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              theme.primaryColor.withValues(alpha: 0.1),
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              theme.primaryColor,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppBorders.radiusButton),
                              ),
                            ),
                            minimumSize: const WidgetStatePropertyAll(
                              Size(double.infinity, 56),
                            ),
                            elevation: const WidgetStatePropertyAll(0),
                            overlayColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.pressed)) {
                                return theme.primaryColor.withValues(alpha: 0.2);
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return theme.primaryColor.withValues(alpha: 0.15);
                              }
                              return null;
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppPaddings.p16),
                      Expanded(
                        flex: 3,
                        child: QuantitySelector(
                          quantity: quantity,
                          onDecrement: quantity > 1
                              ? () => setState(() {
                                  quantity--;
                                })
                              : null,
                          onIncrement: quantity < (selectedVariant.stock)
                              ? () => setState(() {
                                  quantity++;
                                })
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: selectedVariant.stock <= 0
                      ? null
                      : () {
                          final product = widget.product;
                          if (selectedSize == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Debes seleccionar una talla y una variante",
                                ),
                              ),
                            );
                            return;
                          }

                          final item = CartItem(
                            product: product,
                            variant: selectedVariant,
                            size: selectedSize!,
                            quantity: quantity,
                          );

                          final slug = NavigationHelper.getSlug(context);
                          final cartProvider = context.read<CartProvider>();
                          final deliveryMethods =
                              context
                                  .read<BusinessProvider>()
                                  .business
                                  ?.deliveryMethods ??
                              [];
                          final paymentMethods =
                              context
                                  .read<BusinessProvider>()
                                  .business
                                  ?.paymentMethods ??
                              [];
                          cartProvider.setBuyNow(
                            item,
                            deliveryMethods,
                            paymentMethods,
                          );
                          NavigationHelper.go(context, "/$slug/checkout");
                        },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(theme.primaryColor),
                    foregroundColor: const WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorders.radiusButton),
                      ),
                    ),
                    minimumSize: const WidgetStatePropertyAll(
                      Size(double.infinity, 56),
                    ),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                  child: Text(
                    "Comprar Ahora",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
