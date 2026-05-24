import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';

abstract class StockMovementDatasource {
  Future<List<StockMovement>> getMovements(String businessSlug);
  Future<void> registerMovement(String businessSlug, StockMovement movement);
}
