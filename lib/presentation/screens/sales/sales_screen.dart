import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Ventas",
      currentNavIndex: 1,
      body: const SalesBody(),
    );
  }
}

class SalesBody extends StatefulWidget {
  const SalesBody({super.key});

  @override
  State<SalesBody> createState() => _SalesBodyState();
}

class _SalesBodyState extends State<SalesBody> {
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
    _products = await ProductRepository.getAllProductsByBranchWithStock(
      isActive: true,
    );
    setState(() {
      _filteredProducts = _products;
    });
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
                    _filteredProducts =
                        _products.where((p) => p.stock <= 5).toList();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_offer),
                title: const Text("Bajo Precio (precio < \$50)"),
                onTap: () {
                  setState(() {
                    _isFiltering = true;
                    _filteredProducts =
                        _products.where((p) => p.price < 50).toList();
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
      _filteredProducts =
          _products.where((product) {
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
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.0,
                      ),
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
                      _isFiltering
                          ? const Color(0xFF3491B3)
                          : Colors.transparent,
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
          _filteredProducts.isEmpty
              ? const Expanded(
                child: Center(child: Text("No se encontraron productos")),
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (_, index) {
                    final product = _filteredProducts[index];
                    return SalesRow(product: product);
                  },
                ),
              ),
        ],
      ),
    );
  }
}
