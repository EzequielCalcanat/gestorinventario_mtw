import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/client_repository.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';


class ClientFormScreen extends StatefulWidget {
  final Client? client;
  final Future<void> Function() onSave;

  const ClientFormScreen({
    super.key,
    this.client,
    required this.onSave,
  });

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _emailController.text = widget.client!.email;
      _phoneController.text = widget.client!.phone ?? '';
    }
  }

  void _saveClient() async {
    final isEditing = widget.client != null;
    final client = Client(
      id: widget.client?.id ?? uuid.v4(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      isActive: true,
    );

    if (isEditing) {
      await ClientRepository.updateClient(client);
    } else {
      await ClientRepository.insertClient(client);
    }

    await widget.onSave();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.client == null ? "Nuevo Cliente" : "Editar Cliente",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Información de Cliente",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo del Cliente',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (10 dígitos)',
                  prefixText: '+52 ',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saveClient,
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
