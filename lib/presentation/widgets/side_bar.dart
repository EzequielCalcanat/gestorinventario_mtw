import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(String) onNavigate;

  const SideBar({required this.onNavigate, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // Fondo del Drawer (Color fijo para el fondo)
          Container(
            height: MediaQuery.of(context).padding.top + 100,
            decoration: BoxDecoration(
              color: Color(0xFF3491B3), // Color fijo para el fondo
            ),
          ),
          // Contenido del Drawer
          ListView(
            children: [
              // Header
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Menú Principal', // Título del Drawer
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ),
              // Menú de opciones
              _buildListTile(context, Icons.home, 'Inicio', 'home'),
              _buildListTile(context, Icons.store, 'Sucursal', 'branch'),
              _buildListTile(context, Icons.shopping_bag, 'Productos', 'products'),
              _buildListTile(context, Icons.people, 'Clientes', 'clients'),
              _buildListTile(context, Icons.store, 'Ventas', 'sales'),
              _buildListTile(context, Icons.bar_chart, 'Reportes', 'reports'),
              _buildListTile(context, Icons.supervised_user_circle, 'Usuarios', 'users'),
              _buildListTile(context, Icons.settings, 'Configuraciones', 'settings'),
            ],
          ),
        ],
      ),
    );
  }

  // Método para crear cada ListTile con ícono y texto
  Widget _buildListTile(BuildContext context, IconData icon, String title, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    final bool isSelected = currentRoute == '/$route';

    return ListTile(
      title: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFF3491B3) : Colors.grey[700], // Cambia de color si está seleccionado
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Color(0xFF3491B3) : Colors.black, // Cambia de color si está seleccionado
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context); // Cierra el drawer
        onNavigate(route); // Navega a la ruta correspondiente
      },
      selected: isSelected,
    );
  }
}
