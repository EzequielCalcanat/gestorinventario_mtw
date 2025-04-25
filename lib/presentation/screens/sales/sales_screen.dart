import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:shimmer/shimmer.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    _products = await ProductRepository.getAllProducts(isActive: true);
    setState(() {
      _isLoading = false;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Opciones de Filtro",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: const Text("Stock Bajo"),
                onTap: () {
                  setState(() {
                    _isFiltering = true;
                    _products = _products.where((p) => p.stock <= 5).toList();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_offer),
                title: const Text("En Promoción (precio < \$100)"),
                onTap: () {
                  setState(() {
                    _isFiltering = true;
                    _products = _products.where((p) => p.price < 100).toList();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text("Quitar Filtros"),
                onTap: () async {
                  Navigator.pop(context);
                  await _loadProducts();
                  setState(() {
                    _isFiltering = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();

    return BaseScaffold(
      title: "Ventas",
      currentNavIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.all(14),
                    minimumSize: const Size(50, 50),
                    backgroundColor: _isFiltering ? const Color(0xFF3491B3) : Colors.transparent,
                    foregroundColor: _isFiltering ? Colors.white : const Color(0xFF3491B3),
                    elevation: 0,
                  ),
                  onPressed: _openFilterSheet,
                  child: Icon(_isFiltering ? Icons.filter_alt_off : Icons.filter_list),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _isLoading
                ? Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (_, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 80.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            )
                : filteredProducts.isEmpty
                ? const Expanded(
              child: Center(
                child: Text("No se encontraron productos"),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (_, index) {
                  final product = filteredProducts[index];
                  return SalesRow(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
