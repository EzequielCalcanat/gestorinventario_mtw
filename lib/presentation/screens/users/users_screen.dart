import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';
import 'package:flutterinventory/presentation/screens/users/user_form_screen.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:shimmer/shimmer.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<Branch> _branches = [];
  bool _isLoading = true;
  String _selectedRole = 'Todos';

  final List<String> _roles = ['Todos', 'admin', 'employee', 'sales'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadBranches();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _users = await LoginRepository.getAllUsers(isActive: true);
    setState(() => _isLoading = false);
  }

  Future<void> _loadBranches() async {
    _branches = await BranchRepository.getAllBranches(isActive: true);
  }

  void _navigateToUserForm({User? user}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(
          user: user,
          branches: _branches,
          onSave: _loadUsers,
        ),
      ),
    );

    if (result == true) _loadUsers();
  }

  Future<void> _deleteUser(User user) async {
    await LoginRepository.deleteUser(user);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredUsers = _users.where((user) {
      final matchName = user.name.toLowerCase().contains(query);
      final matchRole = _selectedRole == 'Todos' || user.role == _selectedRole;
      return matchName && matchRole;
    }).toList();

    return BaseScaffold(
      title: "Usuarios",
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar usuario...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
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
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF3491B3),
                    elevation: 0,
                  ),
                  onPressed: () {
                    print('Abrir opciones de filtro');
                  },
                  child: const Icon(Icons.filter_list),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (_, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(height: 80.0, color: Colors.white),
                    ),
                  );
                },
              ),
            )
                : filteredUsers.isEmpty
                ? const Expanded(child: Center(child: Text("No hay usuarios")))
                : Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (_, index) {
                  final user = filteredUsers[index];
                  return UserRow(
                    user: user,
                    onEdit: () => _navigateToUserForm(user: user),
                    onDelete: () => _deleteUser(user),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}