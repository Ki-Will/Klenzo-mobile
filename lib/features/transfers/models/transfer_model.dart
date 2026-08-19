class TransferRequest {
  final String fromWalletId;
  final String toAccount;
  final double amount;
  final String currency;
  final String? narration;
  final String? bankCode;

  const TransferRequest({
    required this.fromWalletId,
    required this.toAccount,
    required this.amount,
    required this.currency,
    this.narration,
    this.bankCode,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      fromWalletId: json['fromWalletId']?.toString() ?? '',
      toAccount: json['toAccount']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      narration: json['narration']?.toString(),
      bankCode: json['bankCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromWalletId': fromWalletId,
      'toAccount': toAccount,
      'amount': amount,
      'currency': currency,
      'narration': narration,
      'bankCode': bankCode,
    };
  }
}

class TransferResponse {
  final String transactionId;
  final String status;
  final double amount;
  final String currency;
  final String? reference;
  final DateTime createdAt;

  const TransferResponse({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    this.reference,
    required this.createdAt,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      transactionId: json['transactionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      reference: json['reference']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'reference': reference,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BankAccount {
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String? bankCode;

  const BankAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    this.bankCode,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      bankCode: json['bankCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankName': bankName,
      'bankCode': bankCode,
    };
  }
}
