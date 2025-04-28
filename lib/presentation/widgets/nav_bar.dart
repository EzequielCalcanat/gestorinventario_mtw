import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error al cargar los datos"));
        }

        final prefs = snapshot.data!;
        final role = prefs.getString('user_role') ?? 'employee';

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Inicio",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: "Venta",
            ),
            if (role == 'admin')
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: "Reportes",
              ),
          ],
        );
      },
    );
  }
}
