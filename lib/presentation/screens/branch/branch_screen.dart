import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/branch_repository.dart';
import 'package:flutterinventory/presentation/widgets/tables/item_row.dart';
import 'package:flutterinventory/presentation/widgets/base_scaffold.dart';
import 'package:flutterinventory/presentation/widgets/common/module_breadcrumb.dart';
import 'package:flutterinventory/presentation/screens/branch/branch_form_screen.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Branch> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
    });
    _branches = await BranchRepository.getAllBranches(isActive: true);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteBranch(Branch branch) async {
    await BranchRepository.deleteBranch(branch);
    _loadBranches();
  }

  void _navigateToBranchForm({Branch? branch}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BranchFormScreen(
          branch: branch,
          onSave: _loadBranches,
        ),
      ),
    );
    if (result == true) {
      _loadBranches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBranches = _branches.where((branch) {
      final query = _searchController.text.toLowerCase();
      return branch.name.toLowerCase().contains(query);
    }).toList();

    return BaseScaffold(
      title: "Sucursales",
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModuleBreadcrumb(text: "/ Sucursales"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar sucursal...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade400, width: 1.0),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
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
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                itemCount: 10,
                itemBuilder: (_, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        height: 80.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              )
                  : (filteredBranches.isEmpty
                  ? const Center(
                child: Text(
                  "No hay sucursales",
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: filteredBranches.length,
                itemBuilder: (_, index) {
                  final branch = filteredBranches[index];
                  return BranchRow(
                    branch: branch,
                    onEdit: () =>
                        _navigateToBranchForm(branch: branch),
                    onDelete: () => _deleteBranch(branch),
                  );
                },
              )),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToBranchForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
