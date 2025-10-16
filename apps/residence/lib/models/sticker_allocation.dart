/// Sticker allocation model
/// Represents the sticker allocation for a household
class StickerAllocation {
  final int total;
  final int used;
  final int available;

  StickerAllocation({
    required this.total,
    required this.used,
    required this.available,
  });

  /// Create from JSON
  factory StickerAllocation.fromJson(Map<String, dynamic> json) {
    return StickerAllocation(
      total: json['total'] as int,
      used: json['used'] as int,
      available: json['available'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'used': used,
      'available': available,
    };
  }

  /// Calculate usage percentage (0-100)
  double get usagePercentage {
    if (total == 0) return 0.0;
    return (used / total) * 100;
  }

  /// Check if allocation is exceeded
  bool get isExceeded => available <= 0;

  /// Check if allocation is almost full (>= 80%)
  bool get isAlmostFull => usagePercentage >= 80;

  /// Get allocation status
  String get allocationStatus {
    if (isExceeded) return 'Limit Reached';
    if (isAlmostFull) return 'Almost Full';
    return 'Available';
  }

  /// Copy with method
  StickerAllocation copyWith({
    int? total,
    int? used,
    int? available,
  }) {
    return StickerAllocation(
      total: total ?? this.total,
      used: used ?? this.used,
      available: available ?? this.available,
    );
  }

  @override
  String toString() {
    return 'StickerAllocation(total: $total, used: $used, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerAllocation &&
        other.total == total &&
        other.used == used &&
        other.available == available;
  }

  @override
  int get hashCode => Object.hash(total, used, available);
}
