import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/client_repository.dart';
import 'package:flutterinventory/presentation/screens/clients/client_form_screen.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:shimmer/shimmer.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    _clients = await ClientRepository.getAllClients(isActive: true);
    setState(() => _isLoading = false);
  }

  void _navigateToClientForm({Client? client}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientFormScreen(
          client: client,
          onSave: _loadClients,
        ),
      ),
    );

    if (result == true) _loadClients();
  }

  Future<void> _deleteClient(Client client) async {
    await ClientRepository.deleteClient(client);
    _loadClients();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredClients = _clients.where((client) {
      return client.name.toLowerCase().contains(query);
    }).toList();

    return BaseScaffold(
      title: "Clientes",
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
                      hintText: 'Buscar cliente...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
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
                : filteredClients.isEmpty
                ? const Expanded(child: Center(child: Text("No hay clientes")))
                : Expanded(
              child: ListView.builder(
                itemCount: filteredClients.length,
                itemBuilder: (_, index) {
                  final client = filteredClients[index];
                  return ClientRow(
                    client: client,
                    onEdit: () => _navigateToClientForm(client: client),
                    onDelete: () => _deleteClient(client),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToClientForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
