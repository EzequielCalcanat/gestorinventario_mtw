import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideBar extends StatelessWidget {
  final Function(String) onNavigate;

  const SideBar({required this.onNavigate, super.key});

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
        return Drawer(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).padding.top + 100,
                decoration: BoxDecoration(color: Color(0xFF3491B3)),
              ),
              ListView(
                children: [
                  SizedBox(
                    height: 100,
                    child: DrawerHeader(
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Menú Principal',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                  if (role != 'sales')
                    _buildListTile(context, Icons.home, 'Inicio', 'home'),
                  if (role == 'admin')
                    _buildListTile(
                      context,
                      Icons.store,
                      'Sucursales',
                      'branch',
                    ),
                  if (role != 'sales')
                    _buildListTile(
                      context,
                      Icons.shopping_bag,
                      'Productos',
                      'products',
                    ),
                  if (role != 'sales')
                    _buildListTile(
                      context,
                      Icons.people,
                      'Clientes',
                      'clients',
                    ),
                  _buildListTile(context, Icons.store, 'Nueva Venta', 'sales'),
                  _buildListTile(
                    context,
                    Icons.store,
                    'Historial de Ventas',
                    'sales_history',
                  ),
                  if (role == 'admin')
                    _buildListTile(
                      context,
                      Icons.bar_chart,
                      'Reportes',
                      'reports',
                    ),
                  if (role == 'admin')
                    _buildListTile(
                      context,
                      Icons.supervised_user_circle,
                      'Usuarios',
                      'users',
                    ),
                  _buildListTile(
                    context,
                    Icons.settings,
                    'Configuraciones',
                    'settings',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    final bool isSelected = currentRoute == '/$route';

    return ListTile(
      title: Row(
        children: [
          Icon(icon, color: isSelected ? Color(0xFF3491B3) : Colors.grey[700]),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Color(0xFF3491B3) : Colors.black,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        onNavigate(route);
      },
      selected: isSelected,
    );
  }
}
