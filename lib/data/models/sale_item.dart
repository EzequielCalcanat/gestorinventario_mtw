class SaleItem {
  final String id;
  final String clientName;
  final String paymentMethodName;
  final double total;
  final int totalProducts;
  final String date;

  SaleItem({
    required this.id,
    required this.clientName,
    required this.paymentMethodName,
    required this.total,
    required this.totalProducts,
    required this.date,
  });
}
