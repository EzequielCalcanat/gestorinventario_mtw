import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool success;

  const PaymentStatusScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: success ? "Pago Exitoso" : "Error en el Pago",
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.green : Colors.red,
              size: 120,
            ),
            const SizedBox(height: 20),
            Text(
              success ? "¡Tu pago se realizó correctamente!" : "Hubo un error al procesar el pago.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/sales");
              },
              child: const Text("Volver", style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3491B3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
