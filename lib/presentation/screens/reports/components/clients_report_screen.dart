import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/client_repository.dart';
import 'package:flutterinventory/presentation/widgets/common/report_date_filter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ClientsReportScreen extends StatefulWidget {
  const ClientsReportScreen({super.key});

  @override
  State<ClientsReportScreen> createState() => _ClientsReportScreenState();
}

class _ClientsReportScreenState extends State<ClientsReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  List<Client> clients = [];
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

  Future<void> _fetchClients() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    clients = await ClientRepository.getClientsBetweenDates(startDate!, endDate!);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Nombre", "Email", "Teléfono", "Fecha de Registro"]
    ];

    for (var client in clients) {
      rows.add([
        client.name,
        client.email,
        client.phone ?? '',
        client.createdAt?.substring(0, 10) ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_clientes.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Clientes");
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
            onSearch: _fetchClients,
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: clients.isEmpty
                ? const Center(child: Text("No hay clientes en este rango."))
                : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.email),
                  trailing: Text(client.createdAt?.substring(0, 10) ?? ''),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: clients.isEmpty ? null : _exportCSV,
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
