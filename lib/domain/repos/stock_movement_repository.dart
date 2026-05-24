import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';

abstract class StockMovementRepository {
  Future<List<StockMovement>> getMovements(String businessSlug);
  Future<void> registerMovement(String businessSlug, StockMovement movement);
}
