import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../providers/announcement_provider.dart';
import '../../widgets/shared/error_widget.dart' as custom;
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/announcements/announcement_card.dart';

/// Announcements screen
/// Displays community announcements from admin
class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen>
    with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    developer.log('AnnouncementsScreen initialized', name: 'Announcements');
    _refreshAnnouncements();
  }

  Future<void> _refreshAnnouncements() async {
    developer.log('Refreshing announcements...', name: 'Announcements');
    await ref.read(announcementProvider.notifier).refreshAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementProvider);

    developer.log('Building announcements screen', name: 'Announcements');
    developer.log('Loading: ${state.isLoading}', name: 'Announcements');
    developer.log('Announcements count: ${state.announcements.length}', name: 'Announcements');
    developer.log('Error: ${state.errorMessage}', name: 'Announcements');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshAnnouncements,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AnnouncementState state) {
    if (state.isLoading && state.announcements.isEmpty) {
      return const LoadingWidget(message: 'Loading announcements...');
    }

    if (state.errorMessage != null && state.announcements.isEmpty) {
      return custom.AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _refreshAnnouncements,
      );
    }

    if (state.announcements.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshAnnouncements,
      child: CustomScrollView(
        slivers: [
          // High priority announcements header
          if (state.highAnnouncements.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildHighPrioritySection(state),
              ),
            ),
          ],

          // Normal announcements
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final announcement = state.normalAnnouncements[index];
                  return AnnouncementCard(
                    announcement: announcement,
                    onTap: () {
                      developer.log('Announcement tapped: ${announcement.id}', name: 'Announcements');
                      // Could navigate to details if needed in the future
                    },
                  );
                },
                childCount: state.normalAnnouncements.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding
          ),
        ],
      ),
    );
  }

  Widget _buildHighPrioritySection(AnnouncementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.priority_high, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Priority Announcements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Show high priority announcements as horizontal scroll
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.highAnnouncements.length,
            itemBuilder: (context, index) {
              final announcement = state.highAnnouncements[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 12),
                child: AnnouncementCard(
                  announcement: announcement,
                  onTap: () {
                    developer.log('High priority announcement tapped: ${announcement.id}', name: 'Announcements');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.announcement_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for community updates',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshAnnouncements,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}