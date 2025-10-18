/// Payment log model
class PaymentLog {
  final String id;
  final String permitRequestId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String? referenceNumber;
  final String? receiptUrl;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentLog({
    required this.id,
    required this.permitRequestId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.referenceNumber,
    this.receiptUrl,
    this.paidAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory PaymentLog.fromJson(Map<String, dynamic> json) {
    return PaymentLog(
      id: json['id'] as String,
      permitRequestId: json['permit_request_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      referenceNumber: json['reference_number'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permit_request_id': permitRequestId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'reference_number': referenceNumber,
      'receipt_url': receiptUrl,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  PaymentLog copyWith({
    String? id,
    String? permitRequestId,
    double? amount,
    String? paymentMethod,
    String? paymentStatus,
    String? referenceNumber,
    String? receiptUrl,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentLog(
      id: id ?? this.id,
      permitRequestId: permitRequestId ?? this.permitRequestId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Payment method display name
  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'gcash':
        return 'GCash';
      case 'paymaya':
        return 'PayMaya';
      case 'check':
        return 'Check';
      default:
        return paymentMethod;
    }
  }

  /// Payment status display name
  String get paymentStatusDisplay {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }

  /// Check if payment is pending
  bool get isPending => paymentStatus.toLowerCase() == 'pending';

  /// Check if payment is completed
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  /// Check if payment failed
  bool get isFailed => paymentStatus.toLowerCase() == 'failed';

  /// Check if payment was refunded
  bool get isRefunded => paymentStatus.toLowerCase() == 'refunded';

  /// Format amount as currency
  String get formattedAmount {
    return '₱${amount.toStringAsFixed(2)}';
  }

  /// Has receipt
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;
}

/// Payment method constants
class PaymentMethod {
  static const String cash = 'cash';
  static const String bankTransfer = 'bank_transfer';
  static const String gcash = 'gcash';
  static const String paymaya = 'paymaya';
  static const String check = 'check';

  static const List<String> all = [
    cash,
    bankTransfer,
    gcash,
    paymaya,
    check,
  ];

  static const Map<String, String> displayNames = {
    cash: 'Cash',
    bankTransfer: 'Bank Transfer',
    gcash: 'GCash',
    paymaya: 'PayMaya',
    check: 'Check',
  };
}

/// Payment status constants
class PaymentStatus {
  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String failed = 'failed';
  static const String refunded = 'refunded';

  static const List<String> all = [pending, paid, failed, refunded];

  static const Map<String, String> displayNames = {
    pending: 'Pending',
    paid: 'Paid',
    failed: 'Failed',
    refunded: 'Refunded',
  };
}
