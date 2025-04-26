import 'package:flutter/material.dart';
import 'package:flutterinventory/data/repositories/log_repository.dart';
import 'package:flutterinventory/data/models/log.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState  extends State<HomeScreen> {
  List<Log> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });
    _logs = await LogRepository.getAllLogs();
    _logs.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    if (_logs.length > 10) {
      _logs = _logs.sublist(0, 10);
    }
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Inicio",
      currentNavIndex: 0,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildSalesChart(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    "Actividad reciente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildRecentActivityList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return SizedBox(
      height: 110,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCardItem(
              title: "Ventas Hoy",
              value: "\$1,500",
              icon: Icons.attach_money,
              backgroundColor: const Color(0xFFEAFCEF),
              borderColor: const Color(0xFFA5D6A7),
              textColor: const Color(0xFF2E7D32),
            ),
            _buildStatCardItem(
              title: "Productos Activos",
              value: "320",
              icon: Icons.inventory,
              backgroundColor: const Color(0xFFE3F2FD),
              borderColor: const Color(0xFF90CAF9),
              textColor: const Color(0xFF1565C0),
            ),
            _buildStatCardItem(
              title: "Stock Bajo",
              value: "12",
              icon: Icons.warning,
              backgroundColor: const Color(0xFFFFF3E0),
              borderColor: const Color(0xFFFFCC80),
              textColor: const Color(0xFFEF6C00),
            ),
            _buildStatCardItem(
              title: "Sucursales",
              value: "4",
              icon: Icons.store,
              backgroundColor: const Color(0xFFF3E5F5),
              borderColor: const Color(0xFFCE93D8),
              textColor: const Color(0xFF6A1B9A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardItem({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            "Ventas de los últimos 7 días",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text("\$${value.toInt()}",
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final days = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt() % 7],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: Colors.teal.withOpacity(0.15)),
                    spots: [
                      FlSpot(0, 500),
                      FlSpot(1, 700),
                      FlSpot(2, 650),
                      FlSpot(3, 800),
                      FlSpot(4, 900),
                      FlSpot(5, 750),
                      FlSpot(6, 1100),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return const Center(child: Text("No hay actividad reciente."));
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _logs.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final log = _logs[index];

        Color borderColor;
        String textAction;
        switch (log.action) {
          case 'update':
            textAction = "ACTUALIZADO";
            borderColor = Colors.amber;
            break;
          case 'delete':
            textAction = "ELIMINADO";
            borderColor = Colors.red;
            break;
          case 'save':
            textAction = "GUARDADO";
            borderColor = Colors.green;
            break;
          default:
            textAction = "DESCONOCIDO";
            borderColor = Colors.grey;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Stack(
              children: [
                _LogItem(
                  user: log.userName,
                  description: _shortenText(log.description ?? "Descripción no disponible", 30),
                  module: log.module ?? "Módulo no disponible",
                  createdAt: log.createdAt
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      textAction.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  String _shortenText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
  }

}

class _LogItem extends StatelessWidget {
  final String user;
  final String description;
  final String module;
  final String? createdAt;

  const _LogItem({
    required this.user,
    required this.description,
    required this.module,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.history, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "$user • $module",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            _formatDate(createdAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}";
    } catch (e) {
      return dateString;
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}