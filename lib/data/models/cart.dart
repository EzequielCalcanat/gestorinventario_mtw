import 'package:flutter/foundation.dart';
import 'package:flutterinventory/data/models/product.dart';

class Cart with ChangeNotifier {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;

  final Map<Product, int> _items = {};

  Cart._internal();

  Map<Product, int> get items => Map.unmodifiable(_items);

  void addItem(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product]! < product.stock) {
        _items[product] = _items[product]! + 1;
        notifyListeners(); // Notificar a los oyentes del cambio
      }
    } else {
      _items[product] = 1;
      notifyListeners(); // Notificar a los oyentes del cambio
    }
  }

  void removeItem(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product]! > 1) {
        _items[product] = _items[product]! - 1;
      } else {
        _items.remove(product);
      }
      notifyListeners(); // Notificar a los oyentes del cambio
    }
  }

  void clearProduct(Product product) {
    if (_items.containsKey(product)) {
      _items.remove(product);
      notifyListeners(); // Notificar a los oyentes del cambio
    }
  }

  void clear() {
    _items.clear();
    notifyListeners(); // Notificar a los oyentes del cambio
  }

  double get total {
    double sum = 0.0;
    _items.forEach((product, quantity) {
      sum += product.price * quantity;
    });
    return sum;
  }

  int get totalItems => _items.values.fold(0, (sum, quantity) => sum + quantity);
}