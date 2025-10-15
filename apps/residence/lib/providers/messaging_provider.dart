import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';

/// Messaging state
class MessagingState {
  final List<Message> messages;
  final bool isLoading;
  final String? errorMessage;
  final int unreadCount;

  MessagingState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.unreadCount = 0,
  });

  MessagingState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
  }) {
    return MessagingState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Get sent messages
  List<Message> get sentMessages {
    return messages.where((msg) => msg.isSent).toList();
  }

  /// Get received messages
  List<Message> get receivedMessages {
    return messages.where((msg) => msg.isReceived).toList();
  }

  /// Get unread messages
  List<Message> get unreadMessages {
    return messages.where((msg) => msg.isUnread && msg.isReceived).toList();
  }
}

/// Messaging provider
class MessagingNotifier extends StateNotifier<MessagingState> {
  final MessagingService _service = MessagingService.instance;

  MessagingNotifier() : super(MessagingState()) {
    refreshMessages();
  }

  /// Refresh messages
  Future<void> refreshMessages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.fetchMessages();

    if (result.isSuccess) {
      // Get unread count
      final unreadResult = await _service.getUnreadCount();
      final unreadCount = unreadResult.isSuccess ? unreadResult.data! : 0;

      state = state.copyWith(
        messages: result.data!,
        isLoading: false,
        unreadCount: unreadCount,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
    }
  }

  /// Send message to admin
  Future<bool> sendMessage({
    String? subject,
    required String content,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.sendMessageToAdmin(
      subject: subject,
      content: content,
    );

    if (result.isSuccess) {
      await refreshMessages();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      return false;
    }
  }

  /// Mark message as read
  Future<bool> markAsRead(String messageId) async {
    final result = await _service.markAsRead(messageId);

    if (result.isSuccess) {
      await refreshMessages();
      return true;
    } else {
      state = state.copyWith(errorMessage: result.error);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Messaging state provider
final messagingProvider =
    StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
  return MessagingNotifier();
});
