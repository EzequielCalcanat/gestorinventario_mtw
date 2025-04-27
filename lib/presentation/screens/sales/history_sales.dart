import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: "Historial de Ventas",
      body: Center(child: Text("Historial de Ventas")),
    );
  }
}