import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';
import 'package:flutterinventory/presentation/widgets/common/report_date_filter.dart';
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
  List<User> users = [];
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

  Future<void> _fetchUsers() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
    });

    users = await LoginRepository.getUsersBetweenDates(startDate!, endDate!);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCSV() async {
    List<List<dynamic>> rows = [
      ["Nombre", "Email", "Rol", "Sucursal", "Fecha de Registro"]
    ];

    for (var user in users) {
      rows.add([
        user.name,
        user.email,
        user.role,
        user.branchId,
        user.createdAt?.substring(0, 10) ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/reporte_usuarios.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: "Reporte de Usuarios");
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
            onSearch: _fetchUsers,
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: users.isEmpty
                ? const Center(child: Text("No hay usuarios en este rango."))
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Text(user.role),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: users.isEmpty ? null : _exportCSV,
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
  ButtonStyle _dateButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Color(0xFFBDBDBD)), // Borde gris claro
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 0, // Sin sombra
    );
  }

  ButtonStyle _searchButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3491B3),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

}
