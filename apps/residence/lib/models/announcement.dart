/// Announcement model
class Announcement {
  final String id;
  final String tenantId;
  final String title;
  final String content;
  final String priority;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Announcement({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.content,
    required this.priority,
    this.attachmentUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      priority: json['priority'] as String,
      attachmentUrl: json['attachment_url'] as String?,
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
      'tenant_id': tenantId,
      'title': title,
      'content': content,
      'priority': priority,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  Announcement copyWith({
    String? id,
    String? tenantId,
    String? title,
    String? content,
    String? priority,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Priority display name
  String get priorityDisplay {
    switch (priority.toLowerCase()) {
      case 'normal':
        return 'Normal';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  /// Check if priority is normal
  bool get isNormal => priority.toLowerCase() == 'normal';

  /// Check if priority is high
  bool get isHigh => priority.toLowerCase() == 'high';

  /// Check if priority is urgent
  bool get isUrgent => priority.toLowerCase() == 'urgent';

  /// Check if has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Get content preview
  String get contentPreview {
    return content.length > 150 ? '${content.substring(0, 150)}...' : content;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Announcement priority constants
class AnnouncementPriority {
  static const String normal = 'normal';
  static const String high = 'high';
  static const String urgent = 'urgent';

  static const List<String> all = [normal, high, urgent];

  static const Map<String, String> displayNames = {
    normal: 'Normal',
    high: 'High',
    urgent: 'Urgent',
  };
}
