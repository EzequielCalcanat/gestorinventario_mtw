import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: "Inicio",
      currentNavIndex: 0,
      body: Center(child: Text("Bienvenido al sistema")),
    );
  }
}