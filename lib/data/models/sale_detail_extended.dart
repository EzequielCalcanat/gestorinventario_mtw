class SaleDetailExtended {
  final String id;
  final double price;
  final int quantity;
  final String productId;
  final String saleId;
  final String productName;

  SaleDetailExtended({
    required this.id,
    required this.price,
    required this.quantity,
    required this.productId,
    required this.saleId,
    required this.productName,
  });

  factory SaleDetailExtended.fromMap(Map<String, dynamic> map) {
    return SaleDetailExtended(
      id: map['id'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as int),
      productId: map['product_id'] as String,
      saleId: map['sale_id'] as String,
      productName: map['product_name'] as String,
    );
  }
}
