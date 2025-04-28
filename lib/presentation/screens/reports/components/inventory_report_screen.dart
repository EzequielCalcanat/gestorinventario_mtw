import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  List<Product> _products = [];
  List<Branch> _branches = [];

  String? selectedBranchId;
  bool isLoading = false;

  static const int lowStockThreshold = 10;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    final branchList = await BranchRepository.getAllBranches();
    setState(() {
      _branches = branchList;
      if (_branches.isNotEmpty) {
        selectedBranchId = _branches.first.id;
        _fetchInventory();
      }
    });
  }

  Future<void> _fetchInventory() async {
    if (selectedBranchId == null) return;

    setState(() {
      isLoading = true;
    });

    final products = await ProductRepository.getAllProductsBySpecificBranch(
      isActive: true,
      branchId: selectedBranchId ?? "",
    );
    setState(() {
      _products = products;
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Producto", "Stock Actual"],
    ];

    for (var item in _products) {
      rows.add([item.name, item.stock]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_inventario.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Inventario");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedBranchId,
            hint: const Text("Seleccione una Sucursal"),
            items:
                _branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch.id,
                    child: Text(branch.name),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBranchId = value;
              });
              _fetchInventory();
            },
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                child: Scrollbar(
                  child:
                      _products.isEmpty
                          ? const Center(
                            child: Text("No hay productos en esta sucursal."),
                          )
                          : ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              final stock = product.stock ?? 0;
                              final isLowStock = stock < lowStockThreshold;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '', // No branch name, ya se selecciona
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isLowStock
                                                ? Colors.red[100]
                                                : const Color(0xFFD0F0C0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$stock en stock",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _products.isEmpty ? null : _exportCSV,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
