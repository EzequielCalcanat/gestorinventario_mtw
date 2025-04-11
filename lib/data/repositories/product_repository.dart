import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/database/database_helper.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:flutterinventory/data/models/product.dart';

class ProductRepository {
  static final Repository<Product> _repository = Repository<Product>(
    table: 'products',
    fromMap: (map) => Product.fromMap(map),
    toMap: (product) => product.toMap(),
  );

  static Future<int> addProduct(Product product) async {
    return await _repository.insert(product);
  }

  static Future<List<Product>> getAllProducts() async {
    return await _repository.getAll();
  }

  static Future<int> updateProduct(Product product) async {
    return await _repository.update(product, product.id!);
  }

  static Future<int> deleteProduct(String productId) async {
    return await _repository.delete(productId);
  }
}
