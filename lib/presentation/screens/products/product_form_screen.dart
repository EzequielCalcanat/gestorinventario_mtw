import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:uuid/uuid.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final List<Branch> branches;
  final Future<void> Function() onSave;

  const ProductFormScreen({
    super.key,
    this.product,
    required this.branches,
    required this.onSave,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  Branch? _selectedBranch;  // Aquí seleccionas la sucursal
  late List<Branch> branches;

  @override
  void initState() {
    super.initState();
    branches = widget.branches;
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _selectedBranch = branches.firstWhere((branch) =>
      branch.id == widget.product!.branch_id,
          orElse: () => branches.first);
    }
  }

  final Uuid uuid = Uuid();
  void _saveProduct() async {
    if (_selectedBranch == null) return;
    final isEditing = widget.product != null;
    final product = Product(
      id: widget.product?.id ?? uuid.v4(),
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      branch_id: _selectedBranch!.id,
    );
    if (isEditing) {
      await ProductRepository.updateProduct(product);
    } else {
      await ProductRepository.addProduct(product);
    }
    await widget.onSave();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Formulario de Producto",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Información de Producto",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownSearch<Branch>(
                items: branches,
                itemAsString: (Branch branch) => branch.name,
                selectedItem: _selectedBranch,
                onChanged: (branch) {
                  setState(() {
                    _selectedBranch = branch!;
                  });
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Seleccionar Sucursal",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                filterFn: (branch, filter) {
                  return branch.name.toLowerCase().contains(filter.toLowerCase());
                },
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón de Cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Cancelar
                    child: const Text('Cancelar'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón de Guardar
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: const Text('Guardar'),
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
            ],
          ),
        ),
      ),
    );
  }
}