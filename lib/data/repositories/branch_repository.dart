import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

class BranchRepository {
  static final Repository<Branch> _repository = Repository<Branch>(
    table: 'branches',
    fromMap: (map) => Branch.fromMap(map),
    toMap: (branch) => branch.toMap(),
    moduleName: "Sucursal"
  );

  static Future<List<Branch>> getAllBranches({bool? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<int> insertBranch(Branch branch) async {
    return await _repository.insert(branch);
  }

  static Future<int> updateBranch(Branch branch) async {
    return await _repository.update(branch, branch.id);
  }

  static Future<int> deleteBranch(Branch branch) async {
    return await _repository.delete(branch, branch.id);
  }
}
