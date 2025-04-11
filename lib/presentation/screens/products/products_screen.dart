import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/presentation/screens/products/product_form_screen.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:shimmer/shimmer.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Branch> _branches = [];
  bool _isLoading = true; // Agregar un flag de carga

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadBranches();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true; // Iniciar carga
    });
    _products = await ProductRepository.getAllProducts();
    setState(() {
      _isLoading = false; // Fin de carga
    });
  }

  Future<void> _loadBranches() async {
    _branches = await BranchRepository.getAllBranches();
  }

  void _navigateToProductForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(
          product: product,
          branches: _branches,
          onSave: _loadProducts,
        ),
      ),
    );

    // Si el formulario fue guardado correctamente, recargar los productos
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(String id) async {
    await ProductRepository.deleteProduct(id);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      final query = _searchController.text.toLowerCase();
      return product.name.toLowerCase().contains(query);
    }).toList();

    return BaseScaffold(
      title: "Productos",
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
                          borderRadius: BorderRadius.circular(8)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {}); // Vuelve a construir la lista filtrada
                    },
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
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF3491B3),
                    elevation: 0,
                  ),
                  onPressed: () {
                    print('Abrir opciones de filtro');
                  },
                  child: const Icon(Icons.filter_list),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? Expanded(
              child: ListView.builder(
                itemCount: 10, // Muestra 10 elementos como ejemplo, ya que aún no se tienen los productos
                itemBuilder: (_, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 80.0, // Ajusta el tamaño del contenedor
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            )
                : filteredProducts.isEmpty
                ? Center(child: Text("No hay productos"))
                : Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (_, index) {
                  final product = filteredProducts[index];
                  return ProductRow(
                    product: product,
                    onEdit: () => _navigateToProductForm(product: product),
                    onDelete: () => _deleteProduct(product.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
