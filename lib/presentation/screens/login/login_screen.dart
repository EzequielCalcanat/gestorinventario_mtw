import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onLoginPressed() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Ingresa tu correo y tu contraseña');
      return;
    }

    setState(() => _isLoading = true);

    final users = await LoginRepository.getAllUsers();

    User? matchingUser;
    try {
      matchingUser = users.firstWhere(
            (u) => u.email?.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      matchingUser = null;
    }

    await Future.delayed(const Duration(seconds: 1)); // Simulate loading

    if (matchingUser == null) {
      _showError('El usuario no está registrado en el sistema');
    } else if (matchingUser.password != password) {
      _showError('Contraseña Incorrecta');
    } else {
      final prefs = await SharedPreferences.getInstance();

      // Guardar tanto el user_id como el role del usuario
      await prefs.setString('logged_user_id', matchingUser.id);
      await prefs.setString('user_role', matchingUser.role ?? 'guest');  // Guarda el rol del usuario

      // Redirigir según el rol del usuario
      if (matchingUser.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/home');  // Admin tiene acceso a todas las rutas
      } else if (matchingUser.role == 'employee') {
        Navigator.of(context).pushReplacementNamed('/home');  // Empleado puede ver solo su sucursal
      } else if (matchingUser.role == 'sales') {
        Navigator.of(context).pushReplacementNamed('/sales');  // Sales solo puede ver ventas
      }

      if (!mounted) return;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimary = const Color(0xFF3491B3);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    height: 250,
                    color: colorPrimary,
                    child: const Center(
                      child: Icon(Icons.auto_graph_outlined, size: 60, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const Text('¡Hola!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Inicia sesión en tu cuenta', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Correo',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Derechos reservador de Ezequiel Calcanat © 2025',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom clipper (unchanged)
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
