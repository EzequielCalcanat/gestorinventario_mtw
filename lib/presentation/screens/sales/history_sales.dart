import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/sale_item.dart';
import 'package:flutterinventory/data/repositories/sale_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart'; // SaleRow
import 'package:shimmer/shimmer.dart';

class HistorySalesScreen extends StatelessWidget {
  const HistorySalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Historial de Ventas",
      body: const SalesBody(),
    );
  }
}

class SalesBody extends StatefulWidget {
  const SalesBody({super.key});

  @override
  State<SalesBody> createState() => _SalesBodyState();
}

class _SalesBodyState extends State<SalesBody> {
  final TextEditingController _searchController = TextEditingController();
  List<SaleItem> _sales = [];
  List<SaleItem> _filteredSales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
    });

    final sales = await SaleRepository.getSalesHistory();

    setState(() {
      _sales = sales;
      _filteredSales = sales;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _sales.where((sale) {
      return sale.clientName.toLowerCase().contains(query) ||
          sale.paymentMethodName.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredSales = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscador
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar cliente o método...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Contenido
          Expanded(
            child: _isLoading
                ? _buildShimmerList()
                : (_filteredSales.isEmpty
                ? const Center(child: Text("No hay ventas registradas."))
                : ListView.builder(
              itemCount: _filteredSales.length,
              itemBuilder: (_, index) {
                final sale = _filteredSales[index];
                return SaleRow(sale: sale);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}