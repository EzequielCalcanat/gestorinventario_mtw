import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Inicio",
      currentNavIndex: 0,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección superior (tarjetas y gráfico) - altura fija
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

          // Sección de actividad reciente con scroll independiente
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
    final logs = [
      _LogItem(
        user: "Carlos Méndez",
        description: "Añadió nuevo producto: iPhone 15 Pro",
        module: "Productos",
        createdAt: "2023-11-15T09:30:00Z",
      ),
      _LogItem(
        user: "Lucía Fernández",
        description: "Realizó venta #1254 por \$1,250",
        module: "Ventas",
        createdAt: "2023-11-15T10:15:00Z",
      ),
      _LogItem(
        user: "Admin Sistema",
        description: "Actualizó stock de AirPods Pro",
        module: "Inventario",
        createdAt: "2023-11-14T16:45:00Z",
      ),
      _LogItem(
        user: "Sandra Gómez",
        description: "Editó información del cliente: TechSolutions SA",
        module: "Clientes",
        createdAt: "2023-11-14T14:20:00Z",
      ),
      _LogItem(
        user: "Pedro Ramírez",
        description: "Registró nueva sucursal en Guadalajara",
        module: "Sucursales",
        createdAt: "2023-11-13T11:10:00Z",
      ),
      _LogItem(
        user: "Daniel Castro",
        description: "Eliminó producto obsoleto: iPhone 11",
        module: "Productos",
        createdAt: "2023-11-13T10:05:00Z",
      ),
      _LogItem(
        user: "María Jiménez",
        description: "Revisión completa de inventario",
        module: "Inventario",
        createdAt: "2023-11-12T17:30:00Z",
      ),
      _LogItem(
        user: "Luis Navarro",
        description: "Editó detalles de venta #1248",
        module: "Ventas",
        createdAt: "2023-11-12T15:22:00Z",
      ),
      _LogItem(
        user: "Carmen Ruiz",
        description: "Agregó nuevo cliente: DiseñoWeb MX",
        module: "Clientes",
        createdAt: "2023-11-11T13:45:00Z",
      ),
      _LogItem(
        user: "Roberto Díaz",
        description: "Exportó reporte de inventario",
        module: "Reportes",
        createdAt: "2023-11-10T18:15:00Z",
      ),
      _LogItem(
        user: "Ana Beltrán",
        description: "Aplicó descuento especial a venta #1251",
        module: "Ventas",
        createdAt: "2023-11-10T12:30:00Z",
      ),
      _LogItem(
        user: "Jorge Silva",
        description: "Actualizó precios de categoría Accesorios",
        module: "Productos",
        createdAt: "2023-11-09T09:15:00Z",
      ),
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: logs.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) => logs[index],
    );
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
        // Aquí puedes navegar a detalles u otra acción
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14), // Más espaciado vertical
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Centrado vertical
          children: [
            Container(
              height: 40, // Altura fija para centrar mejor
              alignment: Alignment.center, // Centrado vertical
              child: const Icon(Icons.history, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15, // Tamaño de fuente ligeramente mayor
                    ),
                  ),
                  const SizedBox(height: 6), // Más espacio entre líneas
                  Text(
                    "$user • $module",
                    style: TextStyle(
                      fontSize: 13, // Tamaño un poco mayor
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
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
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}