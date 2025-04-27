import 'package:flutterinventory/data/models/sale_detail.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

class SaleDetailRepository extends Repository<SaleDetail> {
  SaleDetailRepository()
    : super(
        table: 'sale_details',
        moduleName: 'Detalles de Venta',
        fromMap: (map) => SaleDetail.fromMap(map),
        toMap: (saleDetail) => saleDetail.toMap(),
      );
}
