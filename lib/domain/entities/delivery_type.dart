import 'package:flutter/material.dart';

enum DeliveryType {
  shipping(label: "Envío", icon: Icons.local_shipping),
  pickup(label: "Recojo en tienda", icon: Icons.store),
  courier(label: "Agencia de envío", icon: Icons.inventory_2);

  final String label;
  final IconData icon;

  const DeliveryType({required this.label, required this.icon});
}
