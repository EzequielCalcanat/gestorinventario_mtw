import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ProductsReportScreen extends StatefulWidget {
  const ProductsReportScreen({super.key});

  @override
  State<ProductsReportScreen> createState() => _ProductsReportScreenState();
}

class _ProductsReportScreenState extends State<ProductsReportScreen> {
  List<Product> products = [];
  bool isLoading = false;

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    products = await ProductRepository.getAllProducts(isActive: 1);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Nombre", "Descripción", "Precio", "Stock"]
    ];

    for (var product in products) {
      rows.add([
        product.name,
        product.description ?? '',
        "\$${product.price.toStringAsFixed(2)}",
        product.stock,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_productos.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Productos");
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: products.isEmpty
                ? const Center(child: Text("No hay productos activos."))
                : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.description ?? "Sin descripción"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("\$${product.price.toStringAsFixed(2)}"),
                      Text("Stock: ${product.stock}"),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: products.isEmpty ? null : _exportCSV,
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar CSV'),
            style: _buttonStyle(),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3491B3),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
