import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_catalog_app/data/models/cart_item_model.dart';
import 'package:virtual_catalog_app/domain/datasources/cart_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/cart_item.dart';

class CartDatasourceImpl implements CartDatasource {
  @override
  Future<List<CartItem>> loadCart(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString("cart_$slug");
    if (stored == null) return [];
    final List<dynamic> jsonList = jsonDecode(stored);
    return jsonList.map((j) => CartItemModel.fromJson(j).toEntity()).toList();
  }

  @override
  Future<void> saveCart(String slug, List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items
        .map((e) => CartItemModel.fromEntity(e).toJson())
        .toList();
    await prefs.setString("cart_$slug", jsonEncode(jsonList));
  }

  @override
  Future<void> clearCart(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("cart_$slug");
  }
}
