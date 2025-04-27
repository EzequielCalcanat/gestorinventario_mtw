import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/client_repository.dart';
import 'package:flutterinventory/presentation/widgets/common/common_pie_chart.dart';
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
  Map<String, double> salesByClient = {};
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

  Future<void> _fetchClients() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    clients = await ClientRepository.getClientsBetweenDates(
      startDate!,
      endDate!,
    );
    salesByClient = await ClientRepository.getSalesByClientBetweenDates(
      startDate!,
      endDate!,
    );

    clients.sort((a, b) {
      final aSales = salesByClient[a.name] ?? 0.0;
      final bSales = salesByClient[b.name] ?? 0.0;
      return bSales.compareTo(aSales);
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Nombre", "Email", "Teléfono", "Total Vendido", "Periodo"],
    ];

    for (var client in clients) {
      final totalSales = salesByClient[client.name] ?? 0.0;
      final period = "${_formatDate(startDate)} - ${_formatDate(endDate)}";

      rows.add([
        client.name,
        client.email,
        client.phone ?? '',
        "\$${totalSales.toStringAsFixed(2)}",
        period,
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
          CommonPieChart(data: salesByClient),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                child: Scrollbar(
                  child:
                      clients.isEmpty
                          ? const Center(
                            child: Text("No hay clientes en este rango."),
                          )
                          : ListView.builder(
                            itemCount: clients.length,
                            itemBuilder: (context, index) {
                              final client = clients[index];
                              final totalSales =
                                  salesByClient[client.name] ?? 0.0;

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
                                            client.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            client.phone ??
                                                "Teléfono no disponible",
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
                                            totalSales > 0
                                                ? const Color(0xFFD0F0C0)
                                                : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(20),
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
                              );
                            },
                          ),
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
