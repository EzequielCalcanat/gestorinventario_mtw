import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepository {
  static final Repository<Product> _repository = Repository<Product>(
    table: 'products',
    fromMap: (map) => Product.fromMap(map),
    toMap: (product) => product.toMap(),
    moduleName: "Producto"
  );

  static Future<int> addProduct(Product product) async {
    return await _repository.insert(product);
  }

  // Método para obtener todos los productos con filtro opcional por is_active
  static Future<List<Product>> getAllProducts({bool? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<List<Product>> getAllProductsByBranch({bool isActive = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('user_branch_id');
    List<Map<String, dynamic>> filters = [
      {'name': 'branch_id', 'operator': '==', 'value': branchId},
      {'name': 'is_active', 'operator': '==', 'value': isActive},
    ];
    List<Product> filteredProducts = await _repository.getFiltered(filters);
    return filteredProducts;
  }

  static Future<int> updateProduct(Product product) async {
    return await _repository.update(product, product.id);
  }

  static Future<int> deleteProduct(Product product) async {
    return await _repository.delete(product, product.id);
  }
}
