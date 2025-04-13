class SaleDetail {
  final String id;
  final double price;
  final int quantity;
  final String productId;
  final String saleId;

  SaleDetail({
    required this.id,
    required this.price,
    required this.quantity,
    required this.productId,
    required this.saleId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'quantity': quantity,
      'product_id': productId,
      'sale_id': saleId,
    };
  }

  factory SaleDetail.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw Exception("SaleDetail.fromMap error: 'id' is null. Map: $map");
    }

    return SaleDetail(
      id: map['id'],
      price: map['price'],
      quantity: map['quantity'],
      productId: map['product_id'],
      saleId: map['sale_id'],
    );
  }
}
