import 'package:virtual_catalog_app/domain/datasources/stock_movement_datasource.dart';
import 'package:virtual_catalog_app/domain/entities/stock_movement.dart';
import 'package:virtual_catalog_app/domain/repos/stock_movement_repository.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final StockMovementDatasource datasource;

  StockMovementRepositoryImpl({required this.datasource});

  @override
  Future<List<StockMovement>> getMovements(String businessSlug) {
    return datasource.getMovements(businessSlug);
  }

  @override
  Future<void> registerMovement(String businessSlug, StockMovement movement) {
    return datasource.registerMovement(businessSlug, movement);
  }
}
