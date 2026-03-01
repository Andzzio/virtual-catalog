import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_catalog_app/config/themes/font_names.dart';
import 'package:virtual_catalog_app/domain/entities/delivery_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_method.dart';
import 'package:virtual_catalog_app/domain/entities/payment_type.dart';
import 'package:virtual_catalog_app/presentation/providers/business_provider.dart';
import 'package:virtual_catalog_app/presentation/providers/cart_provider.dart';

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
  final noteCtrl = TextEditingController();
  String? _selectedCountry;
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Métodos de Entrega",
                    style: GoogleFonts.getFont(
                      FontNames.fontNameH2,
                      textStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: List.generate(deliveryMethods.length, (index) {
                      final DeliveryMethod method = deliveryMethods[index];
                      final bool isSelected = selectedDeliveryMethod == method;
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
                                              ? BorderSide(color: Colors.grey)
                                              : BorderSide.none,
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                          ),
                                          left: BorderSide(color: Colors.grey),
                                          right: BorderSide(color: Colors.grey),
                                        ),
                                  borderRadius:
                                      deliveryMethods.length == 1 && !isSelected
                                      ? BorderRadius.all(Radius.circular(8))
                                      // Último no seleccionado → solo abajo
                                      : index == deliveryMethods.length - 1 &&
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
                                              : Border.all(color: Colors.grey),
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
                                          textStyle: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        method.price == 0
                                            ? "Gratis"
                                            : "S/. ${method.price}",
                                        style: GoogleFonts.getFont(
                                          FontNames.fontNameH2,
                                          textStyle: TextStyle(fontSize: 16),
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
                                  height: 60,
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
                        controller: noteCtrl,
                        decoration: _inputDecoration("Notas (opcional)"),
                      ),
                    ],
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
                      final bool isSelected = selectedPaymentMethod == method;
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
                                              ? BorderSide(color: Colors.grey)
                                              : BorderSide.none,
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                          ),
                                          left: BorderSide(color: Colors.grey),
                                          right: BorderSide(color: Colors.grey),
                                        ),
                                  borderRadius:
                                      paymentMethods.length == 1 && !isSelected
                                      ? BorderRadius.all(Radius.circular(8))
                                      // Último no seleccionado → solo abajo
                                      : index == paymentMethods.length - 1 &&
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
                                          textStyle: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Spacer(),
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
                                  height: 60,
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
                        switch (selectedPaymentMethod?.type) {
                          case PaymentType.whatsapp:
                            if (phone == null) {
                              debugPrint("Phone es null");
                              return;
                            }

                            final String businessName =
                                businessProvider.business?.name ?? "Negocio";
                            final StringBuffer sb = StringBuffer();
                            sb.writeln(
                              "\u{1F6D2} *Nuevo Pedido - $businessName*",
                            );
                            sb.writeln();
                            sb.writeln("\u{1F464} *Datos del cliente:*");
                            sb.writeln(
                              "- Nombre: ${nameCtrl.text} ${lastNameCtrl.text}",
                            );
                            sb.writeln("- DNI: ${dniCtrl.text}");
                            sb.writeln("- Teléfono: ${phoneCtrl.text}");
                            sb.writeln("- Dirección: ${addressCtrl.text}");
                            sb.writeln("- País: $_selectedCountry");
                            sb.writeln("- Ciudad: ${cityCtrl.text}");
                            sb.writeln("- Región: ${regionCtrl.text}");
                            sb.writeln("- Código Postal: ${zipCtrl.text}");
                            sb.writeln();
                            sb.writeln("\u{1F4E6} *Productos:*");
                            for (
                              int i = 0;
                              i < cartProvider.checkItems.length;
                              i++
                            ) {
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
                            sb.writeln("\u{1F4B3} Método de pago: WhatsApp");
                            sb.writeln(
                              "\u{1F69A} Método de envío: ${cartProvider.selectedDeliveryMethod?.name}",
                            );
                            sb.writeln();
                            sb.writeln("\u{1F4DD} Notas: ${noteCtrl.text}");

                            final url = Uri.parse(
                              "https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(sb.toString())}",
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              debugPrint("No se pudo abrir whatsapp");
                            }
                            break;
                          case PaymentType.bankTransfer:
                            break;
                          case PaymentType.culqi:
                            break;
                          case PaymentType.yape:
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
                      overlayColor: WidgetStateProperty.resolveWith((states) {
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
                        PaymentType.whatsapp => "Finalizar por WhatsApp",
                        PaymentType.bankTransfer => "Finalizar Pedido",
                        PaymentType.culqi => "Pagar",
                        PaymentType.yape => "Finalizar Pedido",
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
    noteCtrl.dispose();
    super.dispose();
  }
}
