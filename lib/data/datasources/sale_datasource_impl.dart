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

      for (var item in sale.items) {
        final prodSnap = productSnaps[item.productId]!;
        final prodData = prodSnap.data() as Map<String, dynamic>;

        final List<dynamic> variantsData = List.from(prodData['variants'] ?? []);
        int variantIndex = -1;
        for (int i = 0; i < variantsData.length; i++) {
          if (variantsData[i]['name'] == item.variantName) {
            variantIndex = i;
            break;
          }
        }

        if (variantIndex == -1) {
          throw Exception('Variante no encontrada: ${item.variantName} para ${item.productName}');
        }

        final variantMap = Map<String, dynamic>.from(variantsData[variantIndex]);
        final currentStock = variantMap['stock'] as int;
        if (currentStock < item.quantity) {
          throw Exception('Stock insuficiente de ${item.productName} - ${item.variantName}');
        }

        final newStock = currentStock - item.quantity;
        variantMap['stock'] = newStock;
        variantsData[variantIndex] = variantMap;

        prodData['variants'] = variantsData;
        prodData['salesCount'] = (prodData['salesCount'] ?? 0) + item.quantity;
        prodData['updatedAt'] = FieldValue.serverTimestamp();

        transaction.set(prodSnap.reference, prodData);

        final movementModel = {
          'productId': item.productId,
          'productName': prodData['name'],
          'productSku': variantMap['sku'] ?? prodData['sku'],
          'variantName': item.variantName,
          'type': 'egreso',
          'quantity': item.quantity,
          'stockAfter': newStock,
          'reason': 'Venta $generatedNumber',
          'reference': '',
          'userId': sale.userId,
          'userName': sale.userName,
          'createdAt': Timestamp.fromDate(sale.createdAt),
        };
        stockMovementWrites.add(movementModel);
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
        sunatStatus: sale.sunatStatus,
        sunatDescription: sale.sunatDescription,
        sunatHash: sale.sunatHash,
        pdfUrl: sale.pdfUrl,
        xmlUrl: sale.xmlUrl,
        cdrUrl: sale.cdrUrl,
        motivoCodigo: sale.motivoCodigo,
        motivoDescripcion: sale.motivoDescripcion,
        refDocSerie: sale.refDocSerie,
        refDocNumero: sale.refDocNumero,
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
    final Map<String, dynamic> updates = {
      'sunatStatus': status,
    };
    if (description != null) updates['sunatDescription'] = description;
    if (hash != null) updates['sunatHash'] = hash;
    if (pdfUrl != null) updates['pdfUrl'] = pdfUrl;
    if (xmlUrl != null) updates['xmlUrl'] = xmlUrl;
    if (cdrUrl != null) updates['cdrUrl'] = cdrUrl;

    await _firestore
        .collection('businesses')
        .doc(businessSlug)
        .collection('sales')
        .doc(saleId)
        .update(updates);
  }
}
