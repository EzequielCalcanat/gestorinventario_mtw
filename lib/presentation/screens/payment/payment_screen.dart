import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Cart cart = Cart();
    final items = cart.items.entries.toList();

    return BaseScaffold(
      title: "Proceder a Pagar",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumen de la Compra", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...items.map((entry) {
              final Product product = entry.key;
              final int quantity = entry.value;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(product.name),
                subtitle: Text("$quantity x \$${product.price.toStringAsFixed(2)}"),
                trailing: Text("\$${(product.price * quantity).toStringAsFixed(2)}"),
              );
            }).toList(),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${cart.total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Información de Pago", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _styledTextField(
              label: "Nombre en la tarjeta",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),

            _styledTextField(
              label: "Número de tarjeta",
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _styledTextField(
                    label: "Vencimiento (MM/AA)",
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _styledTextField(
                    label: "CVV",
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/payment");
                    },
                    child: const Text("Confirmar Pago"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledTextField({
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
