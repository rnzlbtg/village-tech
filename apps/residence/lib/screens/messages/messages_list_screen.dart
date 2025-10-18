import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/message.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/messages/message_card.dart';

/// Messages list screen with tabs for sent and received messages
class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagingState = ref.watch(messagingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Received',
              icon: messagingState.unreadCount > 0
                  ? Badge(
                      label: Text(messagingState.unreadCount.toString()),
                      child: const Icon(Icons.inbox),
                    )
                  : const Icon(Icons.inbox),
            ),
            const Tab(
              text: 'Sent',
              icon: Icon(Icons.send),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(messagingProvider.notifier).refreshMessages(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedMessagesTab(messagingState),
          _buildSentMessagesTab(messagingState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeMessageDialog(),
        tooltip: 'New Message',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceivedMessagesTab(MessagingState state) {
    final receivedMessages = state.receivedMessages;

    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(messagingProvider.notifier).refreshMessages(),
      );
    }

    if (receivedMessages.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox,
        title: 'No messages received',
        subtitle: 'Messages from the admin will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(messagingProvider.notifier).refreshMessages(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: receivedMessages.length,
        itemBuilder: (context, index) {
          final message = receivedMessages[index];
          return MessageCard(
            message: message,
            onTap: () => _showMessageDetails(message),
            isReceived: true,
          );
        },
      ),
    );
  }

  Widget _buildSentMessagesTab(MessagingState state) {
    final sentMessages = state.sentMessages;

    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(messagingProvider.notifier).refreshMessages(),
      );
    }

    if (sentMessages.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send,
        title: 'No messages sent',
        subtitle: 'Your sent messages to the admin will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(messagingProvider.notifier).refreshMessages(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sentMessages.length,
        itemBuilder: (context, index) {
          final message = sentMessages[index];
          return MessageCard(
            message: message,
            onTap: () => _showMessageDetails(message),
            isReceived: false,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(Message message) {
    // Mark as read if it's a received message and unread
    if (message.isReceived && message.isUnread) {
      ref.read(messagingProvider.notifier).markAsRead(message.id);
    }

    showDialog(
      context: context,
      builder: (context) => MessageDetailsDialog(message: message),
    );
  }

  void _showComposeMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => const ComposeMessageDialog(),
    );
  }
}

/// Message details dialog
class MessageDetailsDialog extends StatelessWidget {
  final Message message;

  const MessageDetailsDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  message.isReceived ? Icons.inbox : Icons.send,
                  color: message.isReceived
                      ? Colors.blue
                      : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.displayTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Type: ${message.messageTypeDisplay}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y h:mm a').format(message.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (message.isRead && message.readAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Read at ${DateFormat('MMM d, y h:mm a').format(message.readAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compose message dialog
class ComposeMessageDialog extends ConsumerStatefulWidget {
  const ComposeMessageDialog({super.key});

  @override
  ConsumerState<ComposeMessageDialog> createState() =>
      _ComposeMessageDialogState();
}

class _ComposeMessageDialogState extends ConsumerState<ComposeMessageDialog> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.send, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Send Message to Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject (Optional)',
                  hintText: 'Enter message subject',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Message *',
                  hintText: 'Enter your message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message content is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Message must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendMessage,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    final success = await ref.read(messagingProvider.notifier).sendMessage(
          subject: _subjectController.text.trim().isEmpty
              ? null
              : _subjectController.text.trim(),
          content: _contentController.text.trim(),
        );

    setState(() {
      _isSending = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(messagingProvider).errorMessage ??
              'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}