import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_type.dart';
import 'package:virtual_catalog_app/domain/entities/order.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/izipay_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/order_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/product_provider.dart';
import 'package:virtual_catalog_app/presentation/widgets/checkout/summary_item_tile.dart';
import 'package:virtual_catalog_app/presentation/widgets/checkout/summary_footer.dart';
import 'package:virtual_catalog_app/presentation/widgets/catalog_footer.dart';

class CheckoutFormView extends StatefulWidget {
  const CheckoutFormView({super.key});

  @override
  State<CheckoutFormView> createState() => _CheckoutFormViewState();
}

class _CheckoutFormViewState extends State<CheckoutFormView> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final dniCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final regionCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String? _selectedCountry;
  bool _isBillingSameAsShipping = true;
  final bNameCtrl = TextEditingController();
  final bLastNameCtrl = TextEditingController();
  final bCompanyCtrl = TextEditingController();
  final bAddressCtrl = TextEditingController();
  final bRefCtrl = TextEditingController();
  final bDistrictCtrl = TextEditingController();
  final bRegionCtrl = TextEditingController();
  final bZipCtrl = TextEditingController();
  final bPhoneCtrl = TextEditingController();
  String? _selectedBillingCountry;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final businessProvider = context.read<BusinessProvider>();
    final phone = businessProvider.business?.whatsappNumber;
    final selectedDeliveryMethod = context
        .watch<CartProvider>()
        .selectedDeliveryMethod;
    final deliveryMethods = businessProvider.business?.deliveryMethods ?? [];
    final paymentMethods = businessProvider.business?.paymentMethods ?? [];
    final selectedPaymentMethod = context
        .watch<CartProvider>()
        .selectedPaymentMethod;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 800;
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 40,
                vertical: 20,
              ),
              child: Align(
                alignment: isMobile ? Alignment.center : Alignment.centerRight,
                child: SizedBox(
                  width: isMobile ? double.infinity : 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile)
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          shape: Border(),
                          title: Text(
                            "RESUMEN DEL PEDIDO",
                            style: GoogleFonts.getFont(
                              FontNames.fontNameP,
                              textStyle: TextStyle(fontSize: 12),
                            ),
                          ),
                          subtitle: Text(
                            "S/. ${cartProvider.checkoutGrandTotal.toStringAsFixed(2)}",
                            style: GoogleFonts.getFont(
                              FontNames.fontNameP,
                              textStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cartProvider.checkItems.length,
                              itemBuilder: (context, index) {
                                final item = cartProvider.checkItems[index];
                                return SummaryItemTile(item: item);
                              },
                            ),
                            SummaryFooter(),
                          ],
                        ),
                      Text(
                        "Métodos de Entrega",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: List.generate(deliveryMethods.length, (
                          index,
                        ) {
                          final DeliveryMethod method = deliveryMethods[index];
                          final bool isSelected =
                              selectedDeliveryMethod == method;
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                context.read<CartProvider>().setDeliveryMethod(
                                  method,
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.grey.shade100
                                          : Colors.transparent,
                                      border: isSelected
                                          ? Border.all(color: Colors.black)
                                          : Border(
                                              top: index == 0
                                                  ? BorderSide(
                                                      color: Colors.grey,
                                                    )
                                                  : BorderSide.none,
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                              ),
                                              left: BorderSide(
                                                color: Colors.grey,
                                              ),
                                              right: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                      borderRadius:
                                          deliveryMethods.length == 1 &&
                                              !isSelected
                                          ? BorderRadius.all(Radius.circular(8))
                                          // Último no seleccionado → solo abajo
                                          : index ==
                                                    deliveryMethods.length -
                                                        1 &&
                                                !isSelected
                                          ? BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            )
                                          // Primero → solo arriba
                                          : index == 0
                                          ? BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            )
                                          // El resto → sin redondeo
                                          : BorderRadius.zero,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.transparent,
                                              border: isSelected
                                                  ? null
                                                  : Border.all(
                                                      color: Colors.grey,
                                                    ),
                                            ),
                                            child: isSelected
                                                ? Center(
                                                    child: Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          SizedBox(width: 16),
                                          Text(
                                            method.name,
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            method.price == 0
                                                ? "Gratis"
                                                : "S/. ${method.price}",
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            method.type.icon,
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isSelected && method.description != null)
                                    Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        minHeight: 60,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.grey.shade100
                                            : Colors.transparent,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            index == deliveryMethods.length - 1
                                            ? BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              )
                                            : BorderRadius.zero,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          method.description ?? "",
                                          style: GoogleFonts.getFont(
                                            FontNames.fontNameH2,
                                            textStyle: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 30),
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, seleccione un país";
                              }
                              return null;
                            },
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            decoration: _inputDecoration("País / Región"),
                            items: [
                              DropdownMenuItem(
                                value: "Perú",
                                child: Text(
                                  "Perú",
                                  style: GoogleFonts.getFont(
                                    FontNames.fontNameH2,
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCountry = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          if (isMobile) ...[
                            TextFormField(
                              controller: nameCtrl,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor, ingrese su nombre";
                                }
                                return null;
                              },
                              decoration: _inputDecoration("Nombre"),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: lastNameCtrl,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor, ingrese su apellido";
                                }
                                return null;
                              },
                              decoration: _inputDecoration("Apellido"),
                            ),
                          ] else
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: nameCtrl,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Por favor, ingrese su nombre";
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration("Nombre"),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: lastNameCtrl,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Por favor, ingrese su apellido";
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration("Apellido"),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: dniCtrl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su DNI";
                              }
                              if (value.length != 8) {
                                return "El DNI debe tener 8 dígitos";
                              }
                              return null;
                            },
                            decoration: _inputDecoration("DNI"),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 8,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: addressCtrl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su dirección";
                              }
                              return null;
                            },
                            decoration: _inputDecoration("Dirección"),
                          ),
                          SizedBox(height: 10),
                          if (isMobile) ...[
                            TextFormField(
                              controller: cityCtrl,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor, ingrese su ciudad";
                                }
                                return null;
                              },
                              decoration: _inputDecoration("Ciudad"),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: regionCtrl,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor, ingrese su región";
                                }
                                return null;
                              },
                              decoration: _inputDecoration("Región"),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: zipCtrl,
                              decoration: _inputDecoration(
                                "Código postal (opcional)",
                              ),
                            ),
                          ] else
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cityCtrl,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Por favor, ingrese su ciudad";
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration("Ciudad"),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: regionCtrl,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Por favor, ingrese su región";
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration("Región"),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: zipCtrl,
                                    decoration: _inputDecoration(
                                      "Código postal (opcional)",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: phoneCtrl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su teléfono";
                              }
                              if (value.length != 9) {
                                return "El teléfono debe tener 9 dígitos";
                              }
                              return null;
                            },
                            decoration: _inputDecoration("Teléfono"),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 9,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: emailCtrl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese su correo";
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return "Ingrese un correo válido";
                              }
                              return null;
                            },
                            decoration: _inputDecoration("Correo electrónico"),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: noteCtrl,
                            decoration: _inputDecoration("Notas (opcional)"),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Dirección de facturación",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            RadioListTile<bool>(
                              value: true,
                              groupValue: _isBillingSameAsShipping,
                              onChanged: (value) {
                                setState(() {
                                  _isBillingSameAsShipping = value!;
                                });
                              },
                              title: Text(
                                "La misma dirección de envío",
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade300),
                            RadioListTile<bool>(
                              value: false,
                              groupValue: _isBillingSameAsShipping,
                              onChanged: (value) {
                                setState(() {
                                  _isBillingSameAsShipping = value!;
                                });
                              },
                              title: Text(
                                "Usar una dirección de facturación distinta",
                                style: GoogleFonts.getFont(
                                  FontNames.fontNameH2,
                                  textStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            if (!_isBillingSameAsShipping)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      validator: (value) {
                                        if (!_isBillingSameAsShipping &&
                                            (value == null || value.isEmpty)) {
                                          return "Seleccione un país";
                                        }
                                        return null;
                                      },
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      decoration: _inputDecoration(
                                        "País / Región",
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: "Perú",
                                          child: Text(
                                            "Perú",
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedBillingCountry = value;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    if (isMobile) ...[
                                      TextFormField(
                                        controller: bNameCtrl,
                                        validator: (value) =>
                                            !_isBillingSameAsShipping &&
                                                (value == null || value.isEmpty)
                                            ? "Requerido"
                                            : null,
                                        decoration: _inputDecoration("Nombre"),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: bLastNameCtrl,
                                        validator: (value) =>
                                            !_isBillingSameAsShipping &&
                                                (value == null || value.isEmpty)
                                            ? "Requerido"
                                            : null,
                                        decoration: _inputDecoration(
                                          "Apellidos",
                                        ),
                                      ),
                                    ] else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: bNameCtrl,
                                              validator: (value) =>
                                                  !_isBillingSameAsShipping &&
                                                      (value == null ||
                                                          value.isEmpty)
                                                  ? "Requerido"
                                                  : null,
                                              decoration: _inputDecoration(
                                                "Nombre",
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextFormField(
                                              controller: bLastNameCtrl,
                                              validator: (value) =>
                                                  !_isBillingSameAsShipping &&
                                                      (value == null ||
                                                          value.isEmpty)
                                                  ? "Requerido"
                                                  : null,
                                              decoration: _inputDecoration(
                                                "Apellidos",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: bCompanyCtrl,
                                      decoration: _inputDecoration(
                                        "Empresa (opcional)",
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: bAddressCtrl,
                                      validator: (value) =>
                                          !_isBillingSameAsShipping &&
                                              (value == null || value.isEmpty)
                                          ? "Requerido"
                                          : null,
                                      decoration: _inputDecoration("Dirección"),
                                    ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: bRefCtrl,
                                      decoration: _inputDecoration(
                                        "Referencia",
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    if (isMobile) ...[
                                      TextFormField(
                                        controller: bDistrictCtrl,
                                        validator: (value) =>
                                            !_isBillingSameAsShipping &&
                                                (value == null || value.isEmpty)
                                            ? "Requerido"
                                            : null,
                                        decoration: _inputDecoration(
                                          "Distrito",
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: bRegionCtrl,
                                        validator: (value) =>
                                            !_isBillingSameAsShipping &&
                                                (value == null || value.isEmpty)
                                            ? "Requerido"
                                            : null,
                                        decoration: _inputDecoration("Región"),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: bZipCtrl,
                                        decoration: _inputDecoration(
                                          "Código postal (opcional)",
                                        ),
                                      ),
                                    ] else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: bDistrictCtrl,
                                              validator: (value) =>
                                                  !_isBillingSameAsShipping &&
                                                      (value == null ||
                                                          value.isEmpty)
                                                  ? "Requerido"
                                                  : null,
                                              decoration: _inputDecoration(
                                                "Distrito",
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextFormField(
                                              controller: bRegionCtrl,
                                              validator: (value) =>
                                                  !_isBillingSameAsShipping &&
                                                      (value == null ||
                                                          value.isEmpty)
                                                  ? "Requerido"
                                                  : null,
                                              decoration: _inputDecoration(
                                                "Región",
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextFormField(
                                              controller: bZipCtrl,
                                              decoration: _inputDecoration(
                                                "Código postal (opcional)",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: bPhoneCtrl,
                                      decoration: _inputDecoration(
                                        "Teléfono (opcional)",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Métodos de Pago",
                        style: GoogleFonts.getFont(
                          FontNames.fontNameH2,
                          textStyle: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: List.generate(paymentMethods.length, (index) {
                          final PaymentMethod method = paymentMethods[index];
                          final bool isSelected =
                              selectedPaymentMethod == method;
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                context.read<CartProvider>().setPaymentMethod(
                                  method,
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.grey.shade100
                                          : Colors.transparent,
                                      border: isSelected
                                          ? Border.all(color: Colors.black)
                                          : Border(
                                              top: index == 0
                                                  ? BorderSide(
                                                      color: Colors.grey,
                                                    )
                                                  : BorderSide.none,
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                              ),
                                              left: BorderSide(
                                                color: Colors.grey,
                                              ),
                                              right: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                      borderRadius:
                                          paymentMethods.length == 1 &&
                                              !isSelected
                                          ? BorderRadius.all(Radius.circular(8))
                                          // Último no seleccionado → solo abajo
                                          : index ==
                                                    paymentMethods.length - 1 &&
                                                !isSelected
                                          ? BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            )
                                          // Primero → solo arriba
                                          : index == 0
                                          ? BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            )
                                          // El resto → sin redondeo
                                          : BorderRadius.zero,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            method.name,
                                            style: GoogleFonts.getFont(
                                              FontNames.fontNameH2,
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          if (method.type == PaymentType.izipay)
                                            SelectionContainer.disabled(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _buildCardBadge("VISA"),
                                                  const SizedBox(width: 4),
                                                  _buildCardBadge("Mastercard"),
                                                  const SizedBox(width: 4),
                                                  _buildCardBadge("Amex"),
                                                  const SizedBox(width: 4),
                                                  _buildCardBadge("+2"),
                                                ],
                                              ),
                                            )
                                          else
                                            Icon(
                                              method.type.faIcon.icon,
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isSelected && method.description != null)
                                    Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        minHeight: 60,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.grey.shade100
                                            : Colors.transparent,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            index == paymentMethods.length - 1
                                            ? BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              )
                                            : BorderRadius.zero,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          method.description ?? "",
                                          style: GoogleFonts.getFont(
                                            FontNames.fontNameH2,
                                            textStyle: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 30),
                      FilledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) =>
                                  Center(child: CircularProgressIndicator()),
                            );

                            final productRepo = context
                                .read<ProductProvider>()
                                .repository;
                            final latestProducts = await productRepo
                                .getProducts(businessProvider.business!.slug);

                            bool priceChanged = false;

                            for (var cartItem in cartProvider.checkItems) {
                              final realProduct = latestProducts.firstWhere(
                                (p) => p.id == cartItem.product.id,
                                orElse: () => cartItem.product,
                              );

                              final realVariant = realProduct.variants
                                  .firstWhere(
                                    (v) => v.name == cartItem.variant.name,
                                    orElse: () => cartItem.variant,
                                  );

                              if (realVariant.price != cartItem.variant.price) {
                                priceChanged = true;
                                break;
                              }
                            }

                            if (priceChanged) {
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Los precios han sido actualizados por el vendedor. Por favor revisa tu carrito nuevamente",
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              return;
                            }

                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            switch (selectedPaymentMethod?.type) {
                              case PaymentType.whatsapp:
                              case PaymentType.bankTransfer:
                              case PaymentType.yape:
                                await _finishPayment(
                                  phone: phone,
                                  paymentType: selectedPaymentMethod?.name,
                                  businessProvider: businessProvider,
                                  cartProvider: cartProvider,
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                );
                                break;
                              case PaymentType.culqi:
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "💳 Pago con tarjeta próximamente disponible",
                                      ),
                                    ),
                                  );
                                }
                                break;
                              case PaymentType.izipay:
                                if (!context.mounted) return;
                                await _processIzipayPayment(
                                  context,
                                  cartProvider.checkoutGrandTotal,
                                  businessProvider,
                                  cartProvider,
                                );
                                break;
                              default:
                                break;
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          minimumSize: WidgetStatePropertyAll(
                            Size(double.infinity, 70),
                          ),
                          overlayColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.grey.shade700;
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.grey.shade800;
                            }
                            return null;
                          }),
                        ),
                        child: Text(
                          switch (selectedPaymentMethod?.type) {
                            PaymentType.whatsapp => "Finalizar Pedido",
                            PaymentType.bankTransfer => "Finalizar Pedido",
                            PaymentType.culqi => "Pagar",
                            PaymentType.yape => "Finalizar Pedido",
                            PaymentType.izipay => "Pagar",
                            null => "Pagar",
                          },
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.getFont(
                            FontNames.fontNameP,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            const CatalogFooter(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      counterText: "",
      hintStyle: GoogleFonts.getFont(
        FontNames.fontNameH2,
        textStyle: TextStyle(fontSize: 13, color: Colors.grey.shade800),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildCardBadge(String brand) {
    if (brand == "VISA") {
      return Container(
        width: 40,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          "VISA",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F71),
              height: 1.0,
            ),
          ),
        ),
      );
    }
    if (brand == "Mastercard") {
      return Container(
        width: 40,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: const Offset(-3, 0),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFF79E1B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (brand == "Amex") {
      return Container(
        width: 42,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF01A6DD),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          "AMEX",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      );
    }
    if (brand == "+2") {
      return Container(
        width: 32,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          "+2",
          style: GoogleFonts.getFont(
            FontNames.fontNameH2,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _finishPayment({
    String? phone,
    required String? paymentType,
    required BusinessProvider businessProvider,
    required CartProvider cartProvider,
    required BuildContext context,
  }) async {
    if (!context.mounted) return;
    if (phone == null) {
      debugPrint("Phone es null");
      return;
    }
    if (paymentType == null) {
      debugPrint("PaymentType es null");
      return;
    }

    final String businessName = businessProvider.business?.name ?? "Negocio";
    final StringBuffer sb = StringBuffer();
    sb.writeln("\u{1F6D2} *Nuevo Pedido - $businessName*");
    sb.writeln();
    sb.writeln("\u{1F464} *Datos del cliente:*");
    sb.writeln("- Nombre: ${nameCtrl.text} ${lastNameCtrl.text}");
    sb.writeln("- DNI: ${dniCtrl.text}");
    sb.writeln("- Teléfono: ${phoneCtrl.text}");
    sb.writeln("- Dirección: ${addressCtrl.text}");
    sb.writeln("- País: $_selectedCountry");
    sb.writeln("- Ciudad: ${cityCtrl.text}");
    sb.writeln("- Región: ${regionCtrl.text}");
    sb.writeln("- Código Postal: ${zipCtrl.text}");
    sb.writeln();
    
    sb.writeln("\u{1F4C4} *Datos de Facturación:*");
    sb.writeln("- Misma dirección que el envío: ${_isBillingSameAsShipping ? 'Sí' : 'No'}");
    if (!_isBillingSameAsShipping) {
      if (bNameCtrl.text.isNotEmpty || bLastNameCtrl.text.isNotEmpty) {
        sb.writeln("- Nombre: ${bNameCtrl.text} ${bLastNameCtrl.text}".trim());
      }
      if (bCompanyCtrl.text.isNotEmpty) sb.writeln("- Empresa: ${bCompanyCtrl.text}");
      if (bAddressCtrl.text.isNotEmpty) {
        final dist = bDistrictCtrl.text.isNotEmpty ? ", ${bDistrictCtrl.text}" : "";
        final reg = bRegionCtrl.text.isNotEmpty ? ", ${bRegionCtrl.text}" : "";
        sb.writeln("- Dirección: ${bAddressCtrl.text}$dist$reg");
      }
      if (bRefCtrl.text.isNotEmpty) sb.writeln("- Referencia: ${bRefCtrl.text}");
      if (bPhoneCtrl.text.isNotEmpty) sb.writeln("- Teléfono: ${bPhoneCtrl.text}");
      if (_selectedBillingCountry != null && _selectedBillingCountry!.isNotEmpty) {
        sb.writeln("- País: $_selectedBillingCountry");
      }
    }
    sb.writeln();

    sb.writeln("\u{1F4E6} *Productos:*");
    for (int i = 0; i < cartProvider.checkItems.length; i++) {
      final item = cartProvider.checkItems[i];

      sb.writeln(
        "${i + 1}. ${item.product.name} - ${item.variant.name}, ${item.size} x ${item.quantity} -> S/. ${item.subTotal.toStringAsFixed(2)}",
      );
    }
    sb.writeln();
    sb.writeln("\u{1F4B0} *Resumen:*");
    sb.writeln(
      "- Subtotal: S/. ${cartProvider.checkItemsTotalWithDiscounts.toStringAsFixed(2)}",
    );
    sb.writeln(
      "- Envío: S/. ${cartProvider.selectedDeliveryMethod?.price.toStringAsFixed(2)}",
    );
    sb.writeln(
      "- Total: S/. ${cartProvider.checkoutGrandTotal.toStringAsFixed(2)}",
    );
    sb.writeln();
    sb.writeln("\u{1F4B3} Método de pago: $paymentType");
    sb.writeln(
      "\u{1F69A} Método de entrega: ${cartProvider.selectedDeliveryMethod?.name}",
    );
    sb.writeln();
    sb.writeln("\u{1F4DD} Notas: ${noteCtrl.text}");

    final orderProvider = context.read<OrderProvider>();
    final newOrder = Order(
      businessId: businessProvider.business!.slug,
      customerName: nameCtrl.text,
      customerLastName: lastNameCtrl.text,
      customerPhone: phoneCtrl.text,
      customerDni: dniCtrl.text,
      customerCountry: _selectedCountry,
      customerAddress: addressCtrl.text,
      customerCity: cityCtrl.text,
      customerRegion: regionCtrl.text,
      customerZip: zipCtrl.text,
      customerEmail: emailCtrl.text,
      notes: noteCtrl.text,
      items: cartProvider.checkItems,
      total: cartProvider.checkoutGrandTotal,
      status: 'pending',
      paymentMethod: paymentType,
      deliveryMethod: cartProvider.selectedDeliveryMethod?.name,
      createdAt: DateTime.now(),
      isBillingSameAsShipping: _isBillingSameAsShipping,
      billingName: _isBillingSameAsShipping ? null : bNameCtrl.text,
      billingLastName: _isBillingSameAsShipping ? null : bLastNameCtrl.text,
      billingCompany: _isBillingSameAsShipping ? null : bCompanyCtrl.text,
      billingCountry: _isBillingSameAsShipping ? null : _selectedBillingCountry,
      billingAddress: _isBillingSameAsShipping ? null : bAddressCtrl.text,
      billingReference: _isBillingSameAsShipping ? null : bRefCtrl.text,
      billingDistrict: _isBillingSameAsShipping ? null : bDistrictCtrl.text,
      billingRegion: _isBillingSameAsShipping ? null : bRegionCtrl.text,
      billingZip: _isBillingSameAsShipping ? null : bZipCtrl.text,
      billingPhone: _isBillingSameAsShipping ? null : bPhoneCtrl.text,
    );

    try {
      await orderProvider.createOrder(newOrder);
    } catch (e) {
      debugPrint("Error al guardar la orden: $e");
    }

    final url = Uri.parse(
      "https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(sb.toString())}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      cartProvider.clearBuy();
      if (cartProvider.mode == CartMode.buyCart) {
        cartProvider.clearCart();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ ¡Pedido enviado por WhatsApp!")),
      );
      final slug = businessProvider.business?.slug ?? "";
      context.go("/$slug");
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No se pudo abrir WhatsApp en este dispositivo."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _processIzipayPayment(
    BuildContext context,
    double amount,
    BusinessProvider businessProvider,
    CartProvider cartProvider,
  ) async {
    final izipayProvider = context.read<IzipayProvider>();
    final orderProvider = context.read<OrderProvider>();

    final newOrder = Order(
      businessId: businessProvider.business!.slug,
      customerName: nameCtrl.text,
      customerLastName: lastNameCtrl.text,
      customerPhone: phoneCtrl.text,
      customerDni: dniCtrl.text,
      customerCountry: _selectedCountry,
      customerAddress: addressCtrl.text,
      customerCity: cityCtrl.text,
      customerRegion: regionCtrl.text,
      customerZip: zipCtrl.text,
      customerEmail: emailCtrl.text,
      notes: noteCtrl.text,
      items: cartProvider.checkItems,
      total: amount,
      status: 'pending',
      paymentMethod: 'izipay',
      deliveryMethod: cartProvider.selectedDeliveryMethod?.name,
      createdAt: DateTime.now(),
      isBillingSameAsShipping: _isBillingSameAsShipping,
      billingName: _isBillingSameAsShipping ? null : bNameCtrl.text,
      billingLastName: _isBillingSameAsShipping ? null : bLastNameCtrl.text,
      billingCompany: _isBillingSameAsShipping ? null : bCompanyCtrl.text,
      billingCountry: _isBillingSameAsShipping ? null : _selectedBillingCountry,
      billingAddress: _isBillingSameAsShipping ? null : bAddressCtrl.text,
      billingReference: _isBillingSameAsShipping ? null : bRefCtrl.text,
      billingDistrict: _isBillingSameAsShipping ? null : bDistrictCtrl.text,
      billingRegion: _isBillingSameAsShipping ? null : bRegionCtrl.text,
      billingZip: _isBillingSameAsShipping ? null : bZipCtrl.text,
      billingPhone: _isBillingSameAsShipping ? null : bPhoneCtrl.text,
    );

    try {
      final orderId = await orderProvider.createOrder(newOrder);

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StreamBuilder<Order>(
          stream: orderProvider.listenToOrder(orderId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.status == 'paid') {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "¡Pago Confirmado!",
                      style: GoogleFonts.getFont(
                        FontNames.fontNameH2,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tu pedido ha sido procesado con éxito.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () {
                        cartProvider.clearBuy();
                        if (cartProvider.mode == CartMode.buyCart) {
                          cartProvider.clearCart();
                        }
                        Navigator.of(context, rootNavigator: true).pop();
                        context.go("/${businessProvider.business!.slug}");
                      },
                      child: const Text("VOLVER A LA TIENDA"),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: const Text("🔒 Procesando Pago"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.black),
                  const SizedBox(height: 16),
                  Text(
                    'Hemos abierto una pestaña segura para tu pago.\n\n'
                    'Una vez completes el pago, esta pantalla se actualizará automáticamente.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(
                      FontNames.fontNameP,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final paymentUrl = await izipayProvider.createPaymentLink(
        amount: amount,
        orderId: orderId,
        businessId: businessProvider.business!.slug,
        customerEmail: emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
        customerName: nameCtrl.text.isNotEmpty ? nameCtrl.text : null,
        customerLastName: lastNameCtrl.text.isNotEmpty
            ? lastNameCtrl.text
            : null,
      );

      if (paymentUrl != null) {
        final url = Uri.parse(paymentUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: "_blank",
          );
        } else {
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ No se pudo abrir la pestaña de pago."),
            ),
          );
        }
      } else {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Error al generar el link de pago.")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error al crear la orden: $e")));
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    lastNameCtrl.dispose();
    dniCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    regionCtrl.dispose();
    zipCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    noteCtrl.dispose();
    bNameCtrl.dispose();
    bLastNameCtrl.dispose();
    bCompanyCtrl.dispose();
    bAddressCtrl.dispose();
    bRefCtrl.dispose();
    bDistrictCtrl.dispose();
    bRegionCtrl.dispose();
    bZipCtrl.dispose();
    bPhoneCtrl.dispose();
    super.dispose();
  }
}
