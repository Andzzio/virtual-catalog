import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_catalog_app/data/models/sale_model.dart';
import 'package:virtual_catalog_app/domain/datasources/sale_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/sale.dart';

class SaleDatasourceImpl implements SaleDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Sale>> getSales(String businessSlug) async {
    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SaleModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Sale> createSale(String businessSlug, Sale sale) async {
    final existingSalesQuery = await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .where('documentType', isEqualTo: sale.documentType)
        .get();
    final existingCount = existingSalesQuery.docs.length;

    final counterRef = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('counters')
        .doc(sale.documentType);

    final saleRef = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .doc();

    final resultSale = await _firestore.runTransaction<Sale>((transaction) async {
      final counterSnap = await transaction.get(counterRef);
      int count = existingCount;
      if (counterSnap.exists) {
        count = counterSnap.get('count') as int;
      }
      final nextCount = count + 1;

      final String prefix;
      if (sale.documentType == 'nota_venta') {
        prefix = 'NV01';
      } else if (sale.documentType == 'devolucion') {
        prefix = 'DV01';
      } else if (sale.documentType == 'nota_credito') {
        final isRefBoleta = sale.refDocSerie?.startsWith('B') ?? false;
        prefix = isRefBoleta ? 'BC01' : 'FC01';
      } else if (sale.documentType == 'nota_debito') {
        final isRefBoleta = sale.refDocSerie?.startsWith('B') ?? false;
        prefix = isRefBoleta ? 'BD01' : 'FD01';
      } else {
        prefix = sale.documentType == 'boleta' ? 'B001' : 'F001';
      }
      final generatedNumber = '$prefix-${nextCount.toString().padLeft(6, '0')}';

      final Map<String, DocumentSnapshot> productSnaps = {};
      for (var item in sale.items) {
        if (!productSnaps.containsKey(item.productId)) {
          final prodRef = _firestore.collection('products').doc(item.productId);
          final prodSnap = await transaction.get(prodRef);
          if (!prodSnap.exists) {
            throw Exception('Producto no encontrado: ${item.productName}');
          }
          productSnaps[item.productId] = prodSnap;
        }
      }

      final List<Map<String, dynamic>> stockMovementWrites = [];

      final isInternal = sale.documentType == 'nota_venta' || sale.documentType == 'devolucion';

      if (isInternal) {
        for (var item in sale.items) {
          final prodSnap = productSnaps[item.productId]!;
          final prodData = prodSnap.data() as Map<String, dynamic>;

          final List<dynamic> variantsData = List.from(prodData['variants'] ?? []);
          int variantIndex = -1;
          for (int i = 0; i < variantsData.length; i++) {
            final String varName = variantsData[i]['name'] ?? '';
            if (varName == item.variantName || item.variantName.startsWith('$varName,')) {
              variantIndex = i;
              break;
            }
          }

          if (variantIndex == -1) {
            throw Exception('Variante no encontrada: ${item.variantName} para ${item.productName}');
          }

          final variantMap = Map<String, dynamic>.from(variantsData[variantIndex]);
          final currentStock = (variantMap['stock'] as num).toInt();

          final int newStock;
          if (sale.documentType == 'nota_venta') {
            if (currentStock < item.quantity) {
              throw Exception('Stock insuficiente de ${item.productName} - ${item.variantName}');
            }
            newStock = currentStock - item.quantity;
            prodData['salesCount'] = (prodData['salesCount'] ?? 0) + item.quantity;
          } else {
            newStock = currentStock + item.quantity;
            prodData['salesCount'] = (prodData['salesCount'] ?? 0) - item.quantity;
          }

          variantMap['stock'] = newStock;
          variantsData[variantIndex] = variantMap;
          prodData['variants'] = variantsData;
          prodData['updatedAt'] = FieldValue.serverTimestamp();

          transaction.set(prodSnap.reference, prodData);

          final movementModel = {
            'productId': item.productId,
            'productName': prodData['name'],
            'productSku': variantMap['sku'] ?? prodData['sku'],
            'variantName': item.variantName,
            'type': sale.documentType == 'nota_venta' ? 'egreso' : 'ingreso',
            'quantity': item.quantity,
            'stockAfter': newStock,
            'reason': sale.documentType == 'nota_venta' ? 'Venta $generatedNumber' : 'Devolución Interna $generatedNumber',
            'reference': '',
            'userId': sale.userId,
            'userName': sale.userName,
            'createdAt': Timestamp.fromDate(sale.createdAt),
          };
          stockMovementWrites.add(movementModel);
        }
      }

      transaction.set(counterRef, {'count': nextCount});

      for (var movement in stockMovementWrites) {
        final movementRef = _firestore
            .collection('businesses')
            .doc(businessSlug)
            .collection('stock_movements')
            .doc();
        transaction.set(movementRef, movement);
      }

      if (sale.orderId != null && sale.orderId!.isNotEmpty) {
        final orderRef = _firestore.collection('orders').doc(sale.orderId);
        final businessOrderRef = _firestore
            .collection('businesses')
            .doc(businessSlug)
            .collection('orders')
            .doc(sale.orderId);

        final Map<String, dynamic> orderUpdates;
        if (sale.documentType == 'nota_venta') {
          orderUpdates = {
            'status': 'completed',
            'saleId': saleRef.id,
            'saleNumber': generatedNumber,
            'saleStatus': 'accepted',
            'paymentStatus': 'paid',
          };
        } else if (sale.documentType == 'devolucion') {
          orderUpdates = {
            'status': 'reverted',
            'saleId': saleRef.id,
            'saleNumber': generatedNumber,
            'saleStatus': 'accepted',
          };
        } else {
          orderUpdates = {
            'saleId': saleRef.id,
            'saleNumber': generatedNumber,
            'saleStatus': 'pending',
          };
        }

        transaction.update(orderRef, orderUpdates);
        transaction.update(businessOrderRef, orderUpdates);
      }

      final String updatedSunatStatus;
      if (isInternal) {
        updatedSunatStatus = 'accepted';
      } else {
        updatedSunatStatus = sale.sunatStatus ?? 'pending';
      }

      final updatedSale = Sale(
        id: saleRef.id,
        number: generatedNumber,
        documentType: sale.documentType,
        customerName: sale.customerName,
        customerDoc: sale.customerDoc,
        customerAddress: sale.customerAddress,
        customerPhone: sale.customerPhone,
        paymentMethod: sale.paymentMethod,
        subtotal: sale.subtotal,
        igv: sale.igv,
        total: sale.total,
        notes: sale.notes,
        userId: sale.userId,
        userName: sale.userName,
        createdAt: sale.createdAt,
        items: sale.items,
        sunatStatus: updatedSunatStatus,
        sunatDescription: sale.sunatDescription,
        sunatHash: sale.sunatHash,
        pdfUrl: sale.pdfUrl,
        xmlUrl: sale.xmlUrl,
        cdrUrl: sale.cdrUrl,
        motivoCodigo: sale.motivoCodigo,
        motivoDescripcion: sale.motivoDescripcion,
        refDocSerie: sale.refDocSerie,
        refDocNumero: sale.refDocNumero,
        orderId: sale.orderId,
      );

      final saleModel = SaleModel(
        id: updatedSale.id,
        number: updatedSale.number,
        documentType: updatedSale.documentType,
        customerName: updatedSale.customerName,
        customerDoc: updatedSale.customerDoc,
        customerAddress: updatedSale.customerAddress,
        customerPhone: updatedSale.customerPhone,
        paymentMethod: updatedSale.paymentMethod,
        subtotal: updatedSale.subtotal,
        igv: updatedSale.igv,
        total: updatedSale.total,
        notes: updatedSale.notes,
        userId: updatedSale.userId,
        userName: updatedSale.userName,
        createdAt: updatedSale.createdAt,
        items: updatedSale.items,
        sunatStatus: updatedSale.sunatStatus,
        sunatDescription: updatedSale.sunatDescription,
        sunatHash: updatedSale.sunatHash,
        pdfUrl: updatedSale.pdfUrl,
        xmlUrl: updatedSale.xmlUrl,
        cdrUrl: updatedSale.cdrUrl,
        motivoCodigo: updatedSale.motivoCodigo,
        motivoDescripcion: updatedSale.motivoDescripcion,
        refDocSerie: updatedSale.refDocSerie,
        refDocNumero: updatedSale.refDocNumero,
        orderId: updatedSale.orderId,
      );

      transaction.set(saleRef, saleModel.toFirestore());

      return updatedSale;
    });

    return resultSale;
  }

  @override
  Future<void> updateSaleSunatStatus(
    String businessSlug,
    String saleId, {
    required String status,
    String? description,
    String? hash,
    String? pdfUrl,
    String? xmlUrl,
    String? cdrUrl,
  }) async {
    final saleRef = _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .doc(saleId);

    await _firestore.runTransaction((transaction) async {
      final saleSnap = await transaction.get(saleRef);
      if (!saleSnap.exists) {
        throw Exception("Venta no encontrada");
      }

      final saleData = saleSnap.data()!;
      final currentSunatStatus = saleData['sunatStatus'] as String?;
      final documentType = saleData['documentType'] as String;
      final saleNumber = saleData['number'] as String;
      final orderId = saleData['orderId'] as String?;
      final rawItems = saleData['items'] as List<dynamic>? ?? [];

      if (currentSunatStatus == 'pending' && status == 'accepted') {
        if (documentType == 'boleta' || documentType == 'factura') {
          for (var itemMap in rawItems) {
            final productId = itemMap['productId'] as String;
            final variantName = itemMap['variantName'] as String;
            final quantity = itemMap['quantity'] as int;

            final prodRef = _firestore.collection('products').doc(productId);
            final prodSnap = await transaction.get(prodRef);
            if (!prodSnap.exists) {
              throw Exception("Producto no encontrado");
            }

            final prodData = prodSnap.data()!;
            final List<dynamic> variantsData = List.from(prodData['variants'] ?? []);
            int variantIndex = -1;
            for (int i = 0; i < variantsData.length; i++) {
              final String varName = variantsData[i]['name'] ?? '';
              if (varName == variantName || variantName.startsWith('$varName,')) {
                variantIndex = i;
                break;
              }
            }
            if (variantIndex == -1) {
              throw Exception("Variante no encontrada: $variantName");
            }

            final variantMap = Map<String, dynamic>.from(variantsData[variantIndex]);
            final currentStock = (variantMap['stock'] as num).toInt();
            if (currentStock < quantity) {
              throw Exception("Stock insuficiente de ${itemMap['productName']}");
            }

            final newStock = currentStock - quantity;
            variantMap['stock'] = newStock;
            variantsData[variantIndex] = variantMap;

            prodData['variants'] = variantsData;
            prodData['salesCount'] = (prodData['salesCount'] ?? 0) + quantity;
            prodData['updatedAt'] = FieldValue.serverTimestamp();

            transaction.set(prodRef, prodData);

            final movementRef = _firestore
                .collection('businesses')
                .doc(businessSlug)
                .collection('stock_movements')
                .doc();
            transaction.set(movementRef, {
              'productId': productId,
              'productName': itemMap['productName'],
              'productSku': variantMap['sku'] ?? prodData['sku'],
              'variantName': variantName,
              'type': 'egreso',
              'quantity': quantity,
              'stockAfter': newStock,
              'reason': 'Venta $saleNumber',
              'reference': '',
              'userId': saleData['userId'] ?? '',
              'userName': saleData['userName'] ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          if (orderId != null && orderId.isNotEmpty) {
            final orderRef = _firestore.collection('orders').doc(orderId);
            final businessOrderRef = _firestore
                .collection('businesses')
                .doc(businessSlug)
                .collection('orders')
                .doc(orderId);

            final orderUpdates = {
              'status': 'completed',
              'saleId': saleId,
              'saleNumber': saleNumber,
              'saleStatus': 'accepted',
              'paymentStatus': 'paid',
            };

            transaction.update(orderRef, orderUpdates);
            transaction.update(businessOrderRef, orderUpdates);
          }
        } else if (documentType == 'nota_credito') {
          for (var itemMap in rawItems) {
            final productId = itemMap['productId'] as String;
            final variantName = itemMap['variantName'] as String;
            final quantity = itemMap['quantity'] as int;

            final prodRef = _firestore.collection('products').doc(productId);
            final prodSnap = await transaction.get(prodRef);
            if (!prodSnap.exists) {
              throw Exception("Producto no encontrado");
            }

            final prodData = prodSnap.data()!;
            final List<dynamic> variantsData = List.from(prodData['variants'] ?? []);
            int variantIndex = -1;
            for (int i = 0; i < variantsData.length; i++) {
              final String varName = variantsData[i]['name'] ?? '';
              if (varName == variantName || variantName.startsWith('$varName,')) {
                variantIndex = i;
                break;
              }
            }
            if (variantIndex == -1) {
              throw Exception("Variante no encontrada: $variantName");
            }

            final variantMap = Map<String, dynamic>.from(variantsData[variantIndex]);
            final currentStock = (variantMap['stock'] as num).toInt();
            final newStock = currentStock + quantity;
            variantMap['stock'] = newStock;
            variantsData[variantIndex] = variantMap;

            prodData['variants'] = variantsData;
            prodData['salesCount'] = (prodData['salesCount'] ?? 0) - quantity;
            prodData['updatedAt'] = FieldValue.serverTimestamp();

            transaction.set(prodRef, prodData);

            final movementRef = _firestore
                .collection('businesses')
                .doc(businessSlug)
                .collection('stock_movements')
                .doc();
            transaction.set(movementRef, {
              'productId': productId,
              'productName': itemMap['productName'],
              'productSku': variantMap['sku'] ?? prodData['sku'],
              'variantName': variantName,
              'type': 'ingreso',
              'quantity': quantity,
              'stockAfter': newStock,
              'reason': 'Devolución Nota de Crédito $saleNumber',
              'reference': '',
              'userId': saleData['userId'] ?? '',
              'userName': saleData['userName'] ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          if (orderId != null && orderId.isNotEmpty) {
            final orderRef = _firestore.collection('orders').doc(orderId);
            final businessOrderRef = _firestore
                .collection('businesses')
                .doc(businessSlug)
                .collection('orders')
                .doc(orderId);

            final orderUpdates = {
              'status': 'reverted',
              'saleId': saleId,
              'saleNumber': saleNumber,
              'saleStatus': 'accepted',
            };

            transaction.update(orderRef, orderUpdates);
            transaction.update(businessOrderRef, orderUpdates);
          }
        }
      } else if (status == 'rejected') {
        if (orderId != null && orderId.isNotEmpty) {
          final orderRef = _firestore.collection('orders').doc(orderId);
          final businessOrderRef = _firestore
              .collection('businesses')
              .doc(businessSlug)
              .collection('orders')
              .doc(orderId);

          final orderUpdates = {
            'saleId': saleId,
            'saleNumber': saleNumber,
            'saleStatus': 'rejected',
          };

          transaction.update(orderRef, orderUpdates);
          transaction.update(businessOrderRef, orderUpdates);
        }
      }

      final Map<String, dynamic> updates = {
        'sunatStatus': status,
      };
      if (description != null) updates['sunatDescription'] = description;
      if (hash != null) updates['sunatHash'] = hash;
      if (pdfUrl != null) updates['pdfUrl'] = pdfUrl;
      if (xmlUrl != null) updates['xmlUrl'] = xmlUrl;
      if (cdrUrl != null) updates['cdrUrl'] = cdrUrl;

      transaction.update(saleRef, updates);
    });
  }
}
