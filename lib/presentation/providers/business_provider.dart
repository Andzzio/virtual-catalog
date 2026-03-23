import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/entities/business.dart';
import 'package:virtual_catalog_app/domain/repos/business_repository.dart';

class BusinessProvider extends ChangeNotifier {
  final BusinessRepository repository;

  BusinessProvider({required this.repository});

  Business? business;
  bool isLoading = false;
  String? _currentSlug;

  Future<void> loadBusiness(String slug) async {
    if (_currentSlug == slug && business != null) return;

    isLoading = true;
    notifyListeners();

    _currentSlug = slug;
    business = await repository.getBusinessBySlug(slug);
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateBusiness(Business updated) async {
    final backup = business;
    business = updated;
    notifyListeners();
    try {
      await repository.updateBusiness(updated.slug, updated);
    } catch (e) {
      business = backup;
      notifyListeners();
      rethrow;
    }
  }

  void forceReload() {
    _currentSlug = null;
    business = null;
  }
}
