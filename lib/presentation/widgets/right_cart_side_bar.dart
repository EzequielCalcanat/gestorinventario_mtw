import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:flutterinventory/data/models/product.dart';

class RightCartSidebar extends StatefulWidget {
  const RightCartSidebar({super.key});

  @override
  State<RightCartSidebar> createState() => _RightCartSidebarState();
}

class _RightCartSidebarState extends State<RightCartSidebar> {
  final Cart _cart = Cart();

  @override
  Widget build(BuildContext context) {
    final items = _cart.items.entries.toList();

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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
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
                    final Product product = entry.key;
                    final int quantity = entry.value;
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        "$quantity x \$${product.price.toStringAsFixed(2)} = \$${(quantity * product.price).toStringAsFixed(2)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _cart.clearProduct(product);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (items.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total: \$${_cart.total.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Aquí irá lógica de "proceder al pago"
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Procediendo al pago...")),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text("Proceder al Pago"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cerrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
