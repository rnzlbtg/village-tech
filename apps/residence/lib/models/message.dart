/// Message model for household-to-admin communication
class Message {
  final String id;
  final String householdId;
  final String? adminId;
  final String messageType;
  final String? subject;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.householdId,
    this.adminId,
    required this.messageType,
    this.subject,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      adminId: json['admin_id'] as String?,
      messageType: json['message_type'] as String,
      subject: json['subject'] as String?,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'admin_id': adminId,
      'message_type': messageType,
      'subject': subject,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  Message copyWith({
    String? id,
    String? householdId,
    String? adminId,
    String? messageType,
    String? subject,
    String? content,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      adminId: adminId ?? this.adminId,
      messageType: messageType ?? this.messageType,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Message type display name
  String get messageTypeDisplay {
    switch (messageType.toLowerCase()) {
      case 'household_to_admin':
        return 'Sent';
      case 'admin_to_household':
        return 'Received';
      default:
        return messageType;
    }
  }

  /// Check if message is from household to admin
  bool get isSent => messageType.toLowerCase() == 'household_to_admin';

  /// Check if message is from admin to household
  bool get isReceived => messageType.toLowerCase() == 'admin_to_household';

  /// Check if message is unread
  bool get isUnread => !isRead;

  /// Get display title (subject or content preview)
  String get displayTitle {
    if (subject != null && subject!.isNotEmpty) {
      return subject!;
    }
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  /// Get content preview
  String get contentPreview {
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }
}

/// Message type constants
class MessageType {
  static const String householdToAdmin = 'household_to_admin';
  static const String adminToHousehold = 'admin_to_household';

  static const List<String> all = [householdToAdmin, adminToHousehold];

  static const Map<String, String> displayNames = {
    householdToAdmin: 'Sent',
    adminToHousehold: 'Received',
  };
}
