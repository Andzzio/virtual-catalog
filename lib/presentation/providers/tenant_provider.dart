import 'package:flutter/material.dart';
import 'package:virtual_catalog_app/domain/usecases/get_business_by_domain.dart';

class TenantProvider extends ChangeNotifier {
  final GetBusinessByDomain getBusinessByDomain;

  bool isLoading = true;
  bool isCustomDomain = false;
  String? resolvedSlug;
  String? errorMessage;

  TenantProvider({required this.getBusinessByDomain}) {
    _resolveTenant();
  }

  Future<void> _resolveTenant() async {
    try {
      final host = Uri.base.host;
      
      // Check if it's a default platform domain
      if (host == 'localhost' || host == '127.0.0.1' || host.endsWith('.web.app') || host.endsWith('.firebaseapp.com')) {
        isCustomDomain = false;
        isLoading = false;
        notifyListeners();
        return;
      }

      // If we reach here, it's a custom domain (e.g. shurumba.com)
      isCustomDomain = true;
      final business = await getBusinessByDomain(host);

      if (business != null) {
        resolvedSlug = business.slug;
      } else {
        // Fallback for www. or non-www. variations
        String alternativeHost = host.startsWith('www.') ? host.substring(4) : 'www.$host';
        final altBusiness = await getBusinessByDomain(alternativeHost);
        if (altBusiness != null) {
          resolvedSlug = altBusiness.slug;
        } else {
          errorMessage = 'Dominio no configurado o no encontrado.';
        }
      }
    } catch (e) {
      errorMessage = 'Error al resolver el dominio: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
