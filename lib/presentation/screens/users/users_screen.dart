import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';
import 'package:flutterinventory/presentation/screens/users/user_form_screen.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/common/module_breadcrumb.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Usuarios",
      body: const UsersBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bodyState = context.findAncestorStateOfType<_UsersBodyState>();
          bodyState?._navigateToUserForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UsersBody extends StatefulWidget {
  const UsersBody({super.key});

  @override
  State<UsersBody> createState() => _UsersBodyState();
}

class _UsersBodyState extends State<UsersBody> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  List<Branch> _branches = [];
  bool _isFiltering = false;
  String _selectedRole = 'Todos';

  final List<String> _roles = ['Todos', 'admin', 'employee', 'sales'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await LoginRepository.getAllUsers(isActive: true);
    final branches = await BranchRepository.getAllBranches(isActive: true);
    setState(() {
      _users = users;
      _filteredUsers = users;
      _branches = branches;
    });
  }

  void _navigateToUserForm({User? user}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(
          user: user,
          branches: _branches,
          onSave: _loadData,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteUser(User user) async {
    await LoginRepository.deleteUser(user);
    _loadData();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _roles.map((role) {
              String displayName;
              IconData icon;

              switch (role) {
                case 'admin':
                  displayName = 'Administrador';
                  icon = Icons.admin_panel_settings;
                  break;
                case 'employee':
                  displayName = 'Empleado';
                  icon = Icons.badge;
                  break;
                case 'sales':
                  displayName = 'Ventas';
                  icon = Icons.point_of_sale;
                  break;
                case 'Todos':
                default:
                  displayName = 'Quitar Filtros';
                  icon = Icons.clear_all;
              }

              return ListTile(
                leading: Icon(icon),
                title: Text(displayName),
                onTap: () {
                  setState(() {
                    _isFiltering = role != 'Todos';
                    _selectedRole = role;
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchName = user.name.toLowerCase().contains(query);
        final matchRole = _selectedRole == 'Todos' || user.role == _selectedRole;
        return matchName && matchRole;
      }).toList();
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModuleBreadcrumb(text: "/ Usuarios"),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar usuario...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                    ),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.all(14),
                  minimumSize: const Size(50, 50),
                  backgroundColor:
                  _isFiltering ? const Color(0xFF3491B3) : Colors.transparent,
                  foregroundColor:
                  _isFiltering ? Colors.white : const Color(0xFF3491B3),
                  elevation: 0,
                ),
                onPressed: _openFilterSheet,
                child: Icon(
                  _isFiltering ? Icons.filter_alt_off : Icons.filter_list,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _users.isEmpty
                ? ListView.builder(
              itemCount: 10,
              itemBuilder: (_, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 80.0,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            )
                : (_filteredUsers.isEmpty
                ? const Center(child: Text("No hay usuarios"))
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (_, index) {
                final user = _filteredUsers[index];
                return UserRow(
                  user: user,
                  onEdit: () => _navigateToUserForm(user: user),
                  onDelete: () => _deleteUser(user),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
