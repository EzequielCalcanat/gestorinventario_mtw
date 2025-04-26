import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/presentation/screens/products/product_form_screen.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:shimmer/shimmer.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Productos",
      body: const ProductsBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bodyState = context.findAncestorStateOfType<_ProductsBodyState>();
          bodyState?._navigateToProductForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductsBody extends StatefulWidget {
  const ProductsBody({super.key});

  @override
  State<ProductsBody> createState() => _ProductsBodyState();
}

class _ProductsBodyState extends State<ProductsBody> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ProductRepository.getAllProductsByBranch(isActive: true);
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _navigateToProductForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(
          product: product,
          onSave: _loadProducts,
        ),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    await ProductRepository.deleteProduct(product);
    _loadProducts();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
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
                    _filteredProducts = _products.where((p) => p.stock <= 5).toList();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_offer),
                title: const Text("Bajo Precio (precio < \$100)"),
                onTap: () {
                  setState(() {
                    _isFiltering = true;
                    _filteredProducts = _products.where((p) => p.price < 100).toList();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text("Quitar Filtros"),
                onTap: () {
                  setState(() {
                    _isFiltering = false;
                    _filteredProducts = _products;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  onChanged: (_) => _onSearchChanged(),
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
                  backgroundColor:
                  _isFiltering ? const Color(0xFF3491B3) : Colors.transparent,
                  foregroundColor:
                  _isFiltering ? Colors.white : const Color(0xFF3491B3),
                  elevation: 0,
                ),
                onPressed: _openFilterSheet,
                child: Icon(
                  _isFiltering ? Icons.filter_alt_off : Icons.filter_list,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _products.isEmpty
                ? ListView.builder(
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
            )
                : (_filteredProducts.isEmpty
                ? const Center(child: Text("No hay productos"))
                : ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (_, index) {
                final product = _filteredProducts[index];
                return ProductRow(
                  product: product,
                  onEdit: () => _navigateToProductForm(product: product),
                  onDelete: () => _deleteProduct(product),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
