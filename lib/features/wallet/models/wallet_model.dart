class Wallet {
  final String id;
  final String name;
  final String currency;
  final double balance;
  final String status;
  final String? accountNumber;
  final String? bankName;

  const Wallet({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    this.status = 'active',
    this.accountNumber,
    this.bankName,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'active',
      accountNumber: json['accountNumber']?.toString(),
      bankName: json['bankName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'balance': balance,
      'status': status,
      'accountNumber': accountNumber,
      'bankName': bankName,
    };
  }
}

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String description;
  final String? reference;
  final String? counterpartyName;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    this.reference,
    this.counterpartyName,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'debit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString() ?? '',
      reference: json['reference']?.toString(),
      counterpartyName: json['counterpartyName']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'description': description,
      'reference': reference,
      'counterpartyName': counterpartyName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
