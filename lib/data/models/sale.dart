class Sale {
  final String id;
  final String date;
  final int saleNumber;
  final String paymentMethod;
  final double total;
  final String branchId;
  final String clientId;
  final String userId;
  final bool isActive;
  final String? createdAt;

  Sale({
    required this.id,
    required this.saleNumber,
    required this.date,
    required this.paymentMethod,
    required this.total,
    required this.branchId,
    required this.clientId,
    required this.userId,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_number': saleNumber,
      'date': date,
      'payment_method': paymentMethod,
      'total': total,
      'branch_id': branchId,
      'client_id': clientId,
      'user_id': userId,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw Exception("Sale.fromMap error: 'id' is null. Map: $map");
    }

    return Sale(
      id: map['id'],
      saleNumber: map['sale_number'],
      date: map['date'],
      paymentMethod: map['payment_method'],
      total: map['total'],
      branchId: map['branch_id'],
      clientId: map['client_id'],
      userId: map['user_id'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
    );
  }

}
