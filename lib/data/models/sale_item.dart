class SaleItem {
  final String id;
  final int saleNumber;
  final String clientName;
  final String paymentMethodName;
  final double total;
  final int totalProducts;
  final String date;
  final String branchId;

  SaleItem({
    required this.id,
    required this.saleNumber,
    required this.clientName,
    required this.paymentMethodName,
    required this.total,
    required this.totalProducts,
    required this.date,
    required this.branchId,
  });
}
