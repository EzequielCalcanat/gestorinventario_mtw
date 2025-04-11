// presentation/widgets/base_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/widgets/top_bar.dart';
import 'package:flutterinventory/presentation/widgets/side_bar.dart';
import 'package:flutterinventory/presentation/widgets/nav_bar.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentNavIndex;
  final FloatingActionButton? floatingActionButton;  // Parámetro opcional para el FAB

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentNavIndex = 0,
    this.floatingActionButton,  // Se pasa como parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      drawer: SideBar(
        onNavigate: (route) => Navigator.pushNamed(context, "/$route"),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: currentNavIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/sales');
              break;
            case 2:
              Navigator.pushNamed(context, '/reports');
              break;
          }
        },
      ),
      body: body,
      floatingActionButton: floatingActionButton,  // Se utiliza el parámetro aquí
    );
  }
}
