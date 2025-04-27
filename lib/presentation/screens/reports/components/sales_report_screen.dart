import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/repositories/sale_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutterinventory/presentation/widgets/common/report_date_filter.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  List<Sale> sales = [];
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> _fetchSales() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    sales = await SaleRepository.getSalesBetweenDates(startDate!, endDate!);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Número de Venta", "Fecha", "Total"]
    ];

    for (var sale in sales) {
      rows.add([
        sale.saleNumber,
        sale.date?.substring(0, 10) ?? '',
        "\$${sale.total.toStringAsFixed(2)}"
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_ventas.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Ventas");
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
            onSearch: _fetchSales,
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: sales.isEmpty
                ? const Center(child: Text("No hay ventas en este rango."))
                : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  title: Text("Venta #${sale.saleNumber}"),
                  subtitle: Text(sale.date?.substring(0, 10) ?? ''),
                  trailing: Text("\$${sale.total.toStringAsFixed(2)}"),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: sales.isEmpty ? null : _exportCSV,
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar CSV'),
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
    );
  }
}
