import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/repositories/product_repository.dart';
import 'package:flutterinventory/presentation/widgets/common/report_date_filter.dart';
import 'package:flutterinventory/presentation/widgets/common/common_pie_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ProductsReportScreen extends StatefulWidget {
  const ProductsReportScreen({super.key});

  @override
  State<ProductsReportScreen> createState() => _ProductsReportScreenState();
}

class _ProductsReportScreenState extends State<ProductsReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> products = [];
  bool isLoading = false;

  Future<void> _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> _fetchProducts() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    products = await ProductRepository.getTopSellingProducts(
      startDate!,
      endDate!,
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Producto", "Sucursal", "Cantidad Vendida", "Total Vendido", "Periodo"],
    ];

    for (var product in products) {
      final period = "${_formatDate(startDate)} - ${_formatDate(endDate)}";

      rows.add([
        product['product_name'],
        product['branch_name'],
        product['total_quantity'],
        "\$${(product['total_sales'] as num).toStringAsFixed(2)}",
        period,
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ReportDateFilter(
            startDate: startDate,
            endDate: endDate,
            onPickStartDate: _pickStartDate,
            onPickEndDate: _pickEndDate,
            onSearch: _fetchProducts,
          ),
          const SizedBox(height: 16),
          _buildProductsChart(),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                child: Scrollbar(
                  child:
                      products.isEmpty
                          ? const Center(
                            child: Text("No hay productos en este rango."),
                          )
                          : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final quantity = product['total_quantity'] ?? 0;
                              final totalSales =
                                  (product['total_sales'] as num?) ?? 0.0;

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
                                            product['product_name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product['branch_name'] ?? '',
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "x$quantity vendidos",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                totalSales > 0
                                                    ? const Color(0xFFD0F0C0)
                                                    : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            totalSales > 0
                                                ? "\$${totalSales.toStringAsFixed(2)}"
                                                : "Sin ventas",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
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
            onPressed: products.isEmpty ? null : _exportCSV,
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar CSV'),
            style: _buttonStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsChart() {
    Map<String, double> chartData = {};

    for (var product in products.take(10)) {
      chartData[product['product_name']] =
          (product['total_quantity'] as num?)?.toDouble() ?? 0.0;
    }

    return CommonPieChart(data: chartData);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
