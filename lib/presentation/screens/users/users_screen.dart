import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: "Usuarios",
      body: Center(child: Text("Administración de usuarios")),
    );
  }
}