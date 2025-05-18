class Transaction {
  final String id;
  final String userId;
  final double amount;
  final DateTime timestamp;
  final String status; // 'succeeded', 'failed', 'pending'
  final String paymentMethod; // 'stripe', 'paypal', etc.
  final String paymentIntentId;
  final Map<String, dynamic>
      items; // e.g. {'audioMinutes': 30, 'videoMinutes': 20}

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.paymentMethod,
    required this.paymentIntentId,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentIntentId': paymentIntentId,
      'items': items,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      userId: map['userId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentIntentId: map['paymentIntentId'] ?? '',
      items: Map<String, dynamic>.from(map['items'] ?? {}),
    );
  }
}
