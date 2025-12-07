class Payment {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      method: json['method'] ?? 'card',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
