import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    _products = await ProductRepository.getAllProducts(isActive: true);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Ventas",
      currentNavIndex: 1,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text("No hay productos"))
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (_, index) => SalesRow(product: _products[index]),
      ),
    );
  }
}
