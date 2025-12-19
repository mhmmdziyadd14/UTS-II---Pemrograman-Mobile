class ZisTransaction {
  final int? id;
  final String type; // 'Zakat', 'Infaq', 'Shadaqah'
  final int amount;
  final String date;
  final String status; // 'pending', 'verified'

  ZisTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory ZisTransaction.fromJson(Map<String, dynamic> json) {
    return ZisTransaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'] is int ? json['amount'] : int.parse(json['amount'].toString()),
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