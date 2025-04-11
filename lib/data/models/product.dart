class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String branch_id;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.branch_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'branch_id': branch_id,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      branch_id: map['branch_id'],
    );
  }
}
