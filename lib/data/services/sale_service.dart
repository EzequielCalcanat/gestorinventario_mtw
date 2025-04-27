import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/models/sale_detail.dart';
import 'package:flutterinventory/data/repositories/payment_repository.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/data/repositories/sale_repository.dart';
import 'package:flutterinventory/data/repositories/sale_detail_repository.dart';
import 'package:flutterinventory/data/repositories/shared_prefs_repository.dart';
import 'package:uuid/uuid.dart';


class SaleService {
  static Future<void> createSaleTransaction({
    required Cart cart,
    required String paymentMethodName,
    required String clientId,
  }) async {
    final paymentRepo = PaymentRepository();
    final saleRepo = SaleRepository();
    final saleDetailRepo = SaleDetailRepository();

    final paymentMethod = await paymentRepo.getOrCreatePaymentMethod(paymentMethodName);

    final branchId = await SharedPrefsRepository.getBranchId();
    final userId = await SharedPrefsRepository.getUserId();

    final lastSaleNumber = await SaleRepository.getLastSaleNumber();
    final nextSaleNumber = lastSaleNumber + 1;

    final newSale = Sale(
      id: const Uuid().v4(),
      date: DateTime.now().toIso8601String(),
      saleNumber: nextSaleNumber,
      total: cart.total,
      branchId: branchId!,
      clientId: clientId,
      userId: userId!,
      paymentMethodId: paymentMethod.id,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    await saleRepo.insert(newSale);

    for (final entry in cart.items.entries) {
      final product = entry.key;
      final quantity = entry.value;

      final saleDetail = SaleDetail(
        id: const Uuid().v4(),
        price: product.price,
        quantity: quantity,
        productId: product.id,
        saleId: newSale.id,
      );

      await saleDetailRepo.insert(saleDetail);

      final newStock = product.stock - quantity;

      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        stock: newStock,
        branchId: product.branchId,
        isActive: product.isActive,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await ProductRepository.updateProduct(updatedProduct);
    }
  }
}
