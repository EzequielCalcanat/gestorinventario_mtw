import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/login_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:uuid/uuid.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  final List<Branch> branches;
  final Future<void> Function() onSave;

  const UserFormScreen({
    super.key,
    this.user,
    required this.branches,
    required this.onSave,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'employee';
  Branch? _selectedBranch;
  late List<Branch> branches;

  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    branches = widget.branches;
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email ?? '';
      _passwordController.text = widget.user!.password;
      _selectedRole = widget.user!.role;
      _selectedBranch = branches.firstWhere(
        (branch) => branch.id == widget.user!.branchId,
        orElse: () => branches.first,
      );
    }
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate() || _selectedBranch == null) {
      if (_selectedBranch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una sucursal.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final isEditing = widget.user != null;
    final user = User(
      id: widget.user?.id ?? uuid.v4(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password:
          _passwordController.text.isNotEmpty
              ? _passwordController.text
              : widget.user?.password ?? '',
      role: _selectedRole,
      branchId: _selectedBranch!.id,
    );

    if (isEditing) {
      await LoginRepository.updateUser(user);
    } else {
      await LoginRepository.insertUser(user);
    }

    await widget.onSave();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.user == null ? "Nuevo Usuario" : "Editar Usuario",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Información de Usuario",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo del Usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (widget.user == null &&
                        (value == null || value.isEmpty)) {
                      return 'La contraseña es obligatoria para nuevos usuarios';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownSearch<String>(
                  items: ['admin', 'employee', 'sales'],
                  selectedItem: _selectedRole,
                  itemAsString: (role) {
                    switch (role) {
                      case 'admin':
                        return 'Administrador';
                      case 'employee':
                        return 'Empleado';
                      case 'sales':
                        return 'Ventas';
                      default:
                        return '';
                    }
                  },
                  onChanged: (role) {
                    setState(() {
                      _selectedRole = role!;
                    });
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Rol",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownSearch<Branch>(
                  items: branches,
                  itemAsString: (Branch branch) => branch.name,
                  selectedItem: _selectedBranch,
                  onChanged: (branch) {
                    setState(() {
                      _selectedBranch = branch!;
                    });
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Sucursal",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  filterFn: (branch, filter) {
                    return branch.name.toLowerCase().contains(
                      filter.toLowerCase(),
                    );
                  },
                  popupProps: const PopupProps.menu(showSearchBox: true),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _saveUser,
                      child: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3491B3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
