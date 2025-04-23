import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: "Proceder a Pagar",
      body: Center(child: Text("Gestión del Pago")),
    );
  }
}