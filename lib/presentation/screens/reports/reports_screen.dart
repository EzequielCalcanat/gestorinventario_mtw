import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'components/clients_report_screen.dart';
import 'components/branches_report_screen.dart';
import 'components/products_report_screen.dart';
import 'components/users_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int currentIndex = 0;

  final List<Widget> reportScreens = const [
    ClientsReportScreen(),
    BranchesReportScreen(),
    ProductsReportScreen(),
    UsersReportScreen(),
  ];

  final List<String> reportTitles = [
    "Reporte de Ventas",
    "Reporte de Clientes",
    "Reporte de Sucursales",
    "Reporte de Productos",
    "Reporte de Usuarios",
  ];

  void _previousReport() {
    setState(() {
      currentIndex = (currentIndex - 1 + reportScreens.length) % reportScreens.length;
    });
  }

  void _nextReport() {
    setState(() {
      currentIndex = (currentIndex + 1) % reportScreens.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: reportTitles[currentIndex],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _previousReport,
                ),
                Text(
                  reportTitles[currentIndex],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _nextReport,
                ),
              ],
            ),
          ),
          Expanded(
            child: reportScreens[currentIndex],
          ),
        ],
      ),
    );
  }
}

