import 'package:flutterinventory/data/database/database_helper.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepository {
  static final Repository<Product> _repository = Repository<Product>(
    table: 'products',
    fromMap: (map) => Product.fromMap(map),
    toMap: (product) => product.toMap(),
    moduleName: "Producto",
  );

  static Future<int> addProduct(Product product) async {
    return await _repository.insert(product);
  }

  // Método para obtener todos los productos con filtro opcional por is_active
  static Future<List<Product>> getAllProducts({int? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<List<Product>> getAllProductsByBranch({
    bool isActive = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('user_branch_id');
    List<Map<String, dynamic>> filters = [
      {'name': 'branch_id', 'operator': '==', 'value': branchId},
      {'name': 'is_active', 'operator': '==', 'value': isActive},
    ];
    List<Product> filteredProducts = await _repository.getFiltered(filters);
    return filteredProducts;
  }

  static Future<List<Product>> getAllProductsByBranchWithStock({
    bool isActive = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('user_branch_id');
    List<Map<String, dynamic>> filters = [
      {'name': 'branch_id', 'operator': '==', 'value': branchId},
      {'name': 'is_active', 'operator': '==', 'value': isActive},
      {'name': 'stock', 'operator': '>=', 'value': 1},
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

  static Future<List<Map<String, dynamic>>> getTopSellingProducts(
    DateTime start,
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
    SELECT 
      p.name as product_name, 
      b.name as branch_name, 
      IFNULL(SUM(sd.quantity), 0) as total_quantity, 
      IFNULL(SUM(sd.price * sd.quantity), 0) as total_sales
    FROM products p
    JOIN branches b ON p.branch_id = b.id
    LEFT JOIN sale_details sd ON p.id = sd.product_id
    LEFT JOIN sales s ON sd.sale_id = s.id AND s.date BETWEEN ? AND ? AND s.is_active = 1
    WHERE p.is_active = 1
    GROUP BY p.id
    ORDER BY total_quantity DESC
  ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return result;
  }
}
