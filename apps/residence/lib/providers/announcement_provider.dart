import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/announcement.dart';
import '../services/announcement_service.dart';

/// Announcement state
class AnnouncementState {
  final List<Announcement> announcements;
  final bool isLoading;
  final String? errorMessage;

  AnnouncementState({
    this.announcements = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AnnouncementState copyWith({
    List<Announcement>? announcements,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AnnouncementState(
      announcements: announcements ?? this.announcements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Get normal priority announcements
  List<Announcement> get normalAnnouncements {
    return announcements.where((a) => a.isNormal).toList();
  }

  /// Get high priority announcements
  List<Announcement> get highAnnouncements {
    return announcements.where((a) => a.isHigh).toList();
  }

  /// Get urgent announcements
  List<Announcement> get urgentAnnouncements {
    return announcements.where((a) => a.isUrgent).toList();
  }

  /// Get announcements with attachments
  List<Announcement> get announcementsWithAttachments {
    return announcements.where((a) => a.hasAttachment).toList();
  }
}

/// Announcement provider
class AnnouncementNotifier extends StateNotifier<AnnouncementState> {
  final AnnouncementService _service = AnnouncementService.instance;

  AnnouncementNotifier() : super(AnnouncementState()) {
    refreshAnnouncements();
  }

  /// Refresh announcements
  Future<void> refreshAnnouncements() async {
    developer.log('🔄 Starting refreshAnnouncements...', name: 'AnnouncementProvider');
    state = state.copyWith(isLoading: true, errorMessage: null);
    developer.log('📊 State set to loading', name: 'AnnouncementProvider');

    final result = await _service.fetchAnnouncements();
    developer.log('📊 Service result: success=${result.isSuccess}, error=${result.error}', name: 'AnnouncementProvider');

    if (result.isSuccess) {
      final announcements = result.data!;
      developer.log('✅ Successfully fetched ${announcements.length} announcements', name: 'AnnouncementProvider');
      state = state.copyWith(
        announcements: announcements,
        isLoading: false,
      );
      developer.log('📊 State updated with ${state.announcements.length} announcements', name: 'AnnouncementProvider');
      developer.log('📊 Normal announcements: ${state.normalAnnouncements.length}', name: 'AnnouncementProvider');
      developer.log('📊 High announcements: ${state.highAnnouncements.length}', name: 'AnnouncementProvider');
      developer.log('📊 Urgent announcements: ${state.urgentAnnouncements.length}', name: 'AnnouncementProvider');
    } else {
      developer.log('❌ Service failed with error: ${result.error}', name: 'AnnouncementProvider');
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      );
      developer.log('📊 State updated with error: ${state.errorMessage}', name: 'AnnouncementProvider');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Announcement state provider
final announcementProvider =
    StateNotifierProvider<AnnouncementNotifier, AnnouncementState>((ref) {
  return AnnouncementNotifier();
});
