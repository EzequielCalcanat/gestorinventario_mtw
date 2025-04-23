import 'package:flutter/material.dart';
import 'package:flutterinventory/presentation/screens/login/login_screen.dart';
import 'package:flutterinventory/presentation/screens/home/home_screen.dart';
import 'package:flutterinventory/presentation/screens/products/products_screen.dart';
import 'package:flutterinventory/presentation/screens/sales/sales_screen.dart';
import 'package:flutterinventory/presentation/screens/clients/clients_screen.dart';
import 'package:flutterinventory/presentation/screens/reports/reports_screen.dart';
import 'package:flutterinventory/presentation/screens/users/users_screen.dart';
import 'package:flutterinventory/presentation/screens/branch/branch_screen.dart';
import 'package:flutterinventory/presentation/screens/payment/payment_screen.dart';
import 'package:flutterinventory/data/models/cart.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Cart(),
      child: const MyApp(),
    ),
  );
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
        '/payment': (context) => const PaymentScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/branch': (context) => const BranchScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
