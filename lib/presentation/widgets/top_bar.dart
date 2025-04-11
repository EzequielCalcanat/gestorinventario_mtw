import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF3491B3),
      title: Text(title),
      actions: [
        GestureDetector(
          onTap: () {
            showMenuOptions(context);
          },
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/default_user.png'),
            radius: 20,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  void showMenuOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Ver Perfil'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuraciones'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () async {
                  // Cerrar sesión: eliminar datos de sesión
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('logged_user_id'); // Borra el ID de usuario

                  // Redirigir a la pantalla de inicio de sesión
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
