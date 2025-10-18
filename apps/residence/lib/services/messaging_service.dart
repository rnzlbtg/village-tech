import '../models/message.dart';
import '../utils/api_result.dart';
import 'supabase_service.dart';

/// Messaging service
/// Handles sending messages to admin and fetching messages
class MessagingService {
  static MessagingService? _instance;

  MessagingService._();

  /// Singleton instance
  static MessagingService get instance {
    _instance ??= MessagingService._();
    return _instance!;
  }

  final _supabase = SupabaseService.instance.client;

  /// Send message to admin
  Future<ApiResult<Message>> sendMessageToAdmin({
    String? subject,
    required String content,
  }) async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      // Validation
      if (content.isEmpty) {
        return ApiResult.failure('Message content is required');
      }

      if (content.length > 1000) {
        return ApiResult.failure('Message content cannot exceed 1000 characters');
      }

      final data = await _supabase.from('messages').insert({
        'household_id': householdId,
        'message_type': MessageType.householdToAdmin,
        'subject': subject,
        'content': content,
        'is_read': false,
      }).select().single();

      final message = Message.fromJson(data);

      return ApiResult.success(message);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch all messages for household
  Future<ApiResult<List<Message>>> fetchMessages() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('messages')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);

      final messages =
          (data as List).map((json) => Message.fromJson(json)).toList();

      return ApiResult.success(messages);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch sent messages (household to admin)
  Future<ApiResult<List<Message>>> fetchSentMessages() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('messages')
          .select()
          .eq('household_id', householdId)
          .eq('message_type', MessageType.householdToAdmin)
          .order('created_at', ascending: false);

      final messages =
          (data as List).map((json) => Message.fromJson(json)).toList();

      return ApiResult.success(messages);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Fetch received messages (admin to household)
  Future<ApiResult<List<Message>>> fetchReceivedMessages() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('messages')
          .select()
          .eq('household_id', householdId)
          .eq('message_type', MessageType.adminToHousehold)
          .order('created_at', ascending: false);

      final messages =
          (data as List).map((json) => Message.fromJson(json)).toList();

      return ApiResult.success(messages);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Mark message as read
  Future<ApiResult<Message>> markAsRead(String messageId) async {
    try {
      final data = await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .select()
          .single();

      final message = Message.fromJson(data);

      return ApiResult.success(message);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  /// Get unread messages count
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final householdId = await SupabaseService.instance.getHouseholdId();
      if (householdId == null) {
        return ApiResult.failure('Household ID not found');
      }

      final data = await _supabase
          .from('messages')
          .select('id')
          .eq('household_id', householdId)
          .eq('message_type', MessageType.adminToHousehold)
          .eq('is_read', false);

      return ApiResult.success((data as List).length);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
