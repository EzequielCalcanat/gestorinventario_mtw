import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/presentation/widgets/common/common_pie_chart.dart';
import 'package:flutterinventory/presentation/widgets/common/report_date_filter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class BranchesReportScreen extends StatefulWidget {
  const BranchesReportScreen({super.key});

  @override
  State<BranchesReportScreen> createState() => _BranchesReportScreenState();
}

class _BranchesReportScreenState extends State<BranchesReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  List<Branch> branches = [];
  Map<String, double> salesByBranch = {};
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
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> _fetchBranches() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    branches = await BranchRepository.getBranchesBetweenDates(startDate!, endDate!);
    salesByBranch = await BranchRepository.getSalesByBranchBetweenDates(startDate!, endDate!);

    branches.sort((a, b) {
      final aSales = salesByBranch[a.name] ?? 0.0;
      final bSales = salesByBranch[b.name] ?? 0.0;
      return bSales.compareTo(aSales);
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    if (startDate == null || endDate == null) return;

    List<List<dynamic>> rows = [
      ["Nombre de Sucursal", "Ubicación", "Total Vendido", "Periodo"]
    ];

    for (var branch in branches) {
      final totalSales = salesByBranch[branch.name] ?? 0.0;
      final period = "${_formatDate(startDate)} - ${_formatDate(endDate)}";

      rows.add([
        branch.name,
        branch.location ?? '',
        "\$${totalSales.toStringAsFixed(2)}",
        period,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_sucursales.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Sucursales");
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
            onSearch: _fetchBranches,
          ),
          const SizedBox(height: 16),
          CommonPieChart(data: salesByBranch),
          const SizedBox(height: 16),
          Expanded(
            child: Scrollbar(
              child: branches.isEmpty
                  ? const Center(child: Text("No hay sucursales en este rango."))
                  : ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  final totalSales = salesByBranch[branch.name] ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                branch.location ?? "Ubicación no disponible",
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: totalSales > 0 ? const Color(0xFFD0F0C0) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            totalSales > 0 ? "\$${totalSales.toStringAsFixed(2)}" : "Sin ventas",
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
            onPressed: branches.isEmpty ? null : _exportCSV,
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar CSV'),
            style: _buttonStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String branchName, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        branchName,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
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
