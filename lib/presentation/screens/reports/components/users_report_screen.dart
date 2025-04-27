import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';
import 'package:flutterinventory/presentation/widgets/common/report_date_filter.dart';
import 'package:flutterinventory/presentation/widgets/common/common_pie_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class UsersReportScreen extends StatefulWidget {
  const UsersReportScreen({super.key});

  @override
  State<UsersReportScreen> createState() => _UsersReportScreenState();
}

class _UsersReportScreenState extends State<UsersReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> sellers = [];
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

  Future<void> _fetchSellers() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    sellers = await LoginRepository.getTopSellingUsers(startDate!, endDate!);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      [
        "Vendedor",
        "Sucursal",
        "Cantidad de Ventas",
        "Total Vendido",
        "Periodo",
      ],
    ];

    for (var seller in sellers) {
      final period = "${_formatDate(startDate)} - ${_formatDate(endDate)}";

      rows.add([
        seller['user_name'],
        seller['branch_name'],
        seller['total_sales_count'],
        "\$${(seller['total_sales_amount'] as num).toStringAsFixed(2)}",
        period,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_vendedores.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Vendedores");
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
            onSearch: _fetchSellers,
          ),
          const SizedBox(height: 16),
          _buildSellersChart(),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                child: Scrollbar(
                  child:
                      sellers.isEmpty
                          ? const Center(
                            child: Text("No hay vendedores en este rango."),
                          )
                          : ListView.builder(
                            itemCount: sellers.length,
                            itemBuilder: (context, index) {
                              final seller = sellers[index];
                              final salesCount =
                                  seller['total_sales_count'] ?? 0;
                              final totalSales =
                                  (seller['total_sales_amount'] as num?) ?? 0.0;

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
                                            seller['user_name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            seller['branch_name'] ?? '',
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
                                          "x$salesCount ventas",
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
            onPressed: sellers.isEmpty ? null : _exportCSV,
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar CSV'),
            style: _buttonStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildSellersChart() {
    Map<String, double> chartData = {};

    for (var seller in sellers.take(10)) {
      chartData[seller['user_name']] =
          (seller['total_sales_amount'] as num?)?.toDouble() ?? 0.0;
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
