import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
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

  Future<void> _fetchBranches() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    branches = await BranchRepository.getBranchesBetweenDates(startDate!, endDate!);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Nombre de Sucursal", "Ubicación", "Fecha de Creación"]
    ];

    for (var branch in branches) {
      rows.add([
        branch.name,
        branch.location ?? '',
        branch.createdAt?.substring(0, 10) ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_sucursales.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Sucursales");
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
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: branches.isEmpty
                ? const Center(child: Text("No hay sucursales en este rango."))
                : ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return ListTile(
                  title: Text(branch.name),
                  subtitle: Text(branch.location ?? "Ubicación no disponible"),
                  trailing: Text(branch.createdAt?.substring(0, 10) ?? ''),
                );
              },
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
