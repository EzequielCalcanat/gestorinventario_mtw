import 'package:flutterinventory/data/models/payment_method.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

class PaymentRepository extends Repository<PaymentMethod> {
  PaymentRepository()
      : super(
    table: 'payment_methods',
    moduleName: 'Métodos de Pago',
    fromMap: (map) => PaymentMethod.fromMap(map),
    toMap: (paymentMethod) => paymentMethod.toMap(),
  );

  Future<PaymentMethod> getOrCreatePaymentMethod(String name) async {
    final existing = await getFiltered([
      {'name': 'name', 'operator': '=', 'value': name}
    ]);

    if (existing.isNotEmpty) {
      return existing.first;
    }

    final newPayment = PaymentMethod.create(name: name);
    await insert(newPayment);
    return newPayment;
  }
}
