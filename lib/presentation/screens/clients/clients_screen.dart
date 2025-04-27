import 'package:flutter/material.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/client_repository.dart';
import 'package:flutterinventory/presentation/screens/clients/client_form_screen.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutterinventory/presentation/widgets/common/module_breadcrumb.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    final clients = await ClientRepository.getAllClients(isActive: 1);
    setState(() {
      _clients = clients;
      _filteredClients = clients;
      _isLoading = false;
    });
  }

  void _navigateToClientForm({Client? client}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientFormScreen(
          client: client,
          onSave: _loadClients,
        ),
      ),
    );

    if (result == true) {
      _loadClients();
    }
  }

  Future<void> _deleteClient(Client client) async {
    await ClientRepository.deleteClient(client);
    _loadClients();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        return client.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Clientes",
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModuleBreadcrumb(text: "/ Clientes"),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
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
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
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
                  : (_filteredClients.isEmpty
                  ? const Center(
                child: Text(
                  "No hay clientes",
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredClients.length,
                itemBuilder: (_, index) {
                  final client = _filteredClients[index];
                  return ClientRow(
                    client: client,
                    onEdit: () => _navigateToClientForm(client: client),
                    onDelete: () => _deleteClient(client),
                  );
                },
              )),
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
