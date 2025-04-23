import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:provider/provider.dart';

class RightCartSidebar extends StatelessWidget {
  const RightCartSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final items = cart.items.entries.toList();

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Carrito",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text("Tu carrito está vacío."))
                    : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final entry = items[index];
                    final product = entry.key;
                    final quantity = entry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila 1: nombre + eliminar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.black54),
                                  onPressed: () => cart.clearProduct(product),
                                  tooltip: "Eliminar producto",
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            // Fila 2: botones de cantidad + total
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: quantity > 1 ? () => cart.removeItem(product) : null,
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: quantity < product.stock ? () => cart.addItem(product) : null,
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const Spacer(),
                                Text(
                                  "\$${(quantity * product.price).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (items.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total: \$${cart.total.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cerrar"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/payment');
                            },
                            icon: const Icon(Icons.payment),
                            label: const Text("Pagar"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
