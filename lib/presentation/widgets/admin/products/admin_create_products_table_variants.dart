import 'package:flutter/material.dart';

import 'admin_variant_card.dart';

class AdminCreateProductsTableVariants extends StatelessWidget {
  final List<Map<String, dynamic>> variants;
  final Function(int) onRemove;
  final Function(int, String, dynamic) onUpdate;
  const AdminCreateProductsTableVariants({
    super.key,
    required this.variants,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(variants.length, (index) {
        return AdminVariantCard(
          variant: variants[index],
          index: index,
          showDelete: variants.length > 1,
          onRemove: onRemove,
          onUpdate: onUpdate,
        );
      }),
    );
  }
}
