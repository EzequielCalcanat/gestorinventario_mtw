import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:uuid/uuid.dart';

class BranchFormScreen extends StatefulWidget {
  final Branch? branch;
  final Future<void> Function() onSave;

  const BranchFormScreen({
    super.key,
    this.branch,
    required this.onSave,
  });

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.branch != null) {
      _nameController.text = widget.branch!.name;
      _locationController.text = widget.branch!.location ?? '';
    }
  }

  final Uuid uuid = Uuid();

  void _saveBranch() async {
    final isEditing = widget.branch != null;
    final branch = Branch(
      id: widget.branch?.id ?? uuid.v4(),
      name: _nameController.text,
      location: _locationController.text,
    );
    if (isEditing) {
      await BranchRepository.updateBranch(branch);
    } else {
      await BranchRepository.insertBranch(branch);
    }
    await widget.onSave();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Formulario de Sucursal",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Información de Sucursal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Sucursal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación de la Sucursal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón de Cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Cancelar
                    child: const Text('Cancelar'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón de Guardar
                  ElevatedButton(
                    onPressed: _saveBranch,
                    child: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3491B3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
