class ZisTransaction {
  final dynamic id; // Changed to dynamic to handle both int and String IDs
  final String type;
  final int amount;
  final String date;
  final String status;

  ZisTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory ZisTransaction.fromJson(Map<String, dynamic> json) {
    return ZisTransaction(
      id: json['id'], // Can be String "2db5" or int 1
      type: json['type'],
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount'].toString()) ?? 0,
      date: json['date'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'date': date,
      'status': status,
    };
  }
}