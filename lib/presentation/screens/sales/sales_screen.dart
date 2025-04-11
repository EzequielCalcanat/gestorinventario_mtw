import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: "Ventas",
      currentNavIndex: 1,
      body: Center(child: Text("Registro de ventas")),
    );
  }
}