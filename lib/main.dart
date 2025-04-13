import 'package:flutter/material.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/products/products_screen.dart';
import 'presentation/screens/sales/sales_screen.dart';
import 'presentation/screens/clients/clients_screen.dart';
import 'presentation/screens/reports/reports_screen.dart';
import 'presentation/screens/users/users_screen.dart';
import 'presentation/screens/branch/branch_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color(0xFF3491B3),
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3491B3),
          foregroundColor: Colors.white,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.white,
          scrimColor: Color(0xFF9E02171E),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductsScreen(),
        '/sales': (context) => const SalesScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/branch': (context) => const BranchScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
