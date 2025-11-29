// lib/screens/chat/chat_room_screen.dart
// Screen untuk chat room (conversation detail)

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';
import '../../core/logging/app_logger.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/chat_providers.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/typing_indicator.dart';

final _logger = AppLogger('ChatRoomScreen');

/// Chat Room Screen - Detail conversation dengan messages
class ChatRoomScreen extends HookConsumerWidget {
  final String conversationId;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider);
    final conversationAsync = ref.watch(conversationProvider(conversationId));
    final messagesAsync = ref.watch(messagesStreamProvider(conversationId));
    final scrollController = useScrollController();
    final messageController = useTextEditingController();

    // Typing indicator parameters
    final typingParams = currentUser.maybeWhen(
      data: (user) => user != null
          ? TypingIndicatorParams(
              conversationId: conversationId,
              currentUserId: user.uid,
            )
          : null,
      orElse: () => null,
    );

    // Watch typing users stream
    final typingUsersAsync = typingParams != null
        ? ref.watch(typingUsersStreamProvider(typingParams))
        : const AsyncValue<List<String>>.data([]);

    // Auto scroll to bottom when new messages arrive
    useEffect(() {
      if (scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
      return null;
    }, [messagesAsync]);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: conversationAsync.when(
          data: (conversation) {
            if (conversation == null) {
              return const Text('Chat', style: AdminTypography.h4);
            }

            return currentUser.when(
              data: (user) {
                if (user == null) return const Text('Chat');

                // Get other user ID for direct conversations
                final otherUserId = conversation.type == ConversationType.direct
                    ? conversation.participantIds.firstWhere(
                        (id) => id != user.uid,
                        orElse: () => '',
                      )
                    : null;

                // Watch online status
                final onlineStatusAsync = otherUserId != null
                    ? ref.watch(userOnlineStatusProvider(otherUserId))
                    : const AsyncValue<bool>.data(false);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.getDisplayName(user.uid),
                      style: AdminTypography.h4,
                    ),
                    // Online status or context badge
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Online status for direct conversations
                        if (conversation.type == ConversationType.direct)
                          onlineStatusAsync.when(
                            data: (isOnline) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isOnline ? AdminColors.success : Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: AdminTypography.caption.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (error, _) => const SizedBox.shrink(),
                          ),
                        // Context badge if linked
                        if (conversation.hasContext) ...[
                          if (conversation.type == ConversationType.direct) const SizedBox(width: 8),
                          Text(
                            conversation.getContextDisplay() ?? '',
                            style: AdminTypography.caption.copyWith(
                              color: AdminColors.info,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Text('Chat'),
              error: (error, _) => const Text('Chat'),
            );
          },
          loading: () => const Text('Loading...', style: AdminTypography.h4),
          error: (_, __) => const Text('Error', style: AdminTypography.h4),
        ),
        actions: [
          // More actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _logger.info('Show conversation info');
                  // TODO: Show conversation info
                  break;
                case 'archive':
                  _logger.info('Archive conversation');
                  // TODO: Archive conversation
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Text('Info Percakapan'),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Text('Arsipkan'),
              ),
            ],
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Silakan login terlebih dahulu'),
            );
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pesan',
                              style: AdminTypography.body1.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kirim pesan pertama Anda!',
                              style: AdminTypography.body2.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Mark messages as read
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final unreadMessageIds = messages
                          .where((msg) =>
                              msg.senderId != user.uid &&
                              !msg.isReadBy(user.uid))
                          .map((msg) => msg.id)
                          .toList();

                      if (unreadMessageIds.isNotEmpty) {
                        ref.read(chatServiceProvider).markMessagesAsRead(
                              conversationId: conversationId,
                              userId: user.uid,
                              messageIds: unreadMessageIds,
                            );
                      }
                    });

                    // Reverse messages (newest at bottom)
                    final reversedMessages = messages.reversed.toList();

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: reversedMessages.length,
                      itemBuilder: (context, index) {
                        final message = reversedMessages[index];
                        final isOwnMessage = message.senderId == user.uid;

                        // Show date divider if date changed
                        final showDateDivider = index == 0 ||
                            !_isSameDay(
                              message.createdAt,
                              reversedMessages[index - 1].createdAt,
                            );

                        return Column(
                          children: [
                            // Date divider
                            if (showDateDivider) _buildDateDivider(message.createdAt),

                            // Message bubble
                            MessageBubble(
                              message: message,
                              isOwnMessage: isOwnMessage,
                              onLongPress: () {
                                _showMessageOptions(context, ref, message, isOwnMessage);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) {
                    _logger.error('Error loading messages', error);
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: AdminColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat pesan',
                            style: AdminTypography.body1,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(messagesStreamProvider);
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Typing indicator
              typingUsersAsync.when(
                data: (typingUsers) => TypingIndicator(typingUserNames: typingUsers),
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
              ),

              // Chat input bar
              ChatInputBar(
                controller: messageController,
                onSend: () => _handleSendTextMessage(ref, user, messageController),
                onImageSelected: (imagePath) => _handleSendImage(ref, user, imagePath),
                onFileSelected: (filePath, fileName) => _handleSendFile(ref, user, filePath, fileName),
                onTypingChanged: (isTyping) => _handleTypingChanged(ref, user, isTyping),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) {
          _logger.error('Error loading user', error);
          return const Center(
            child: Text('Gagal memuat data pengguna'),
          );
        },
      ),
    );
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Build date divider
  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String dateText;

    if (_isSameDay(date, now)) {
      dateText = 'Hari Ini';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      dateText = 'Kemarin';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: AdminTypography.caption.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  // ==================== UI HELPERS ====================

  /// Show message options bottom sheet
  void _showMessageOptions(
    BuildContext context,
    WidgetRef ref,
    Message message,
    bool isOwnMessage,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Edit option (only for text messages sent by current user)
                if (isOwnMessage &&
                    message.type == MessageType.text &&
                    !message.isDeleted)
                  ListTile(
                    leading: const Icon(Icons.edit, color: AdminColors.primary),
                    title: const Text('Edit Pesan'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleEditMessage(context, ref, message);
                    },
                  ),

                // Delete option (only for messages sent by current user)
                if (isOwnMessage && !message.isDeleted)
                  ListTile(
                    leading: const Icon(Icons.delete, color: AdminColors.error),
                    title: const Text('Hapus Pesan'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleDeleteMessage(context, ref, message);
                    },
                  ),

                // Reply option (for all messages)
                if (!message.isDeleted)
                  ListTile(
                    leading: const Icon(Icons.reply, color: AdminColors.info),
                    title: const Text('Balas Pesan'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement reply functionality
                      _logger.info('Reply to message: ${message.id}');
                    },
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== MESSAGE HANDLERS ====================

  /// Handle typing changed
  void _handleTypingChanged(
    WidgetRef ref,
    dynamic user,
    bool isTyping,
  ) {
    _logger.info('Typing state changed: $isTyping');

    final chatService = ref.read(chatServiceProvider);
    chatService.setTypingIndicator(
      conversationId: conversationId,
      userId: user.uid,
      userName: user.displayName,
      isTyping: isTyping,
    );
  }

  /// Handle send text message
  void _handleSendTextMessage(
    WidgetRef ref,
    dynamic user,
    TextEditingController controller,
  ) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    _logger.info('Sending text message: $text');

    final chatService = ref.read(chatServiceProvider);
    final message = await chatService.sendMessage(
      conversationId: conversationId,
      senderId: user.uid,
      senderName: user.displayName,
      senderRole: user.role,
      senderAvatarUrl: user.photoURL,
      content: text,
    );

    if (message != null) {
      controller.clear();
      _logger.info('Text message sent successfully');
    } else {
      _logger.error('Failed to send text message');
    }
  }

  /// Handle send image
  void _handleSendImage(
    WidgetRef ref,
    dynamic user,
    String imagePath,
  ) async {
    _logger.info('Sending image: $imagePath');

    final chatService = ref.read(chatServiceProvider);
    final message = await chatService.sendImageMessage(
      conversationId: conversationId,
      senderId: user.uid,
      senderName: user.displayName,
      senderRole: user.role,
      senderAvatarUrl: user.photoURL,
      imagePath: imagePath,
    );

    if (message != null) {
      _logger.info('Image message sent successfully');
    } else {
      _logger.error('Failed to send image message');
    }
  }

  /// Handle send file
  void _handleSendFile(
    WidgetRef ref,
    dynamic user,
    String filePath,
    String fileName,
  ) async {
    _logger.info('Sending file: $filePath');

    final chatService = ref.read(chatServiceProvider);
    final message = await chatService.sendFileMessage(
      conversationId: conversationId,
      senderId: user.uid,
      senderName: user.displayName,
      senderRole: user.role,
      senderAvatarUrl: user.photoURL,
      filePath: filePath,
      fileName: fileName,
    );

    if (message != null) {
      _logger.info('File message sent successfully');
    } else {
      _logger.error('Failed to send file message');
    }
  }

  /// Handle delete message
  void _handleDeleteMessage(
    BuildContext context,
    WidgetRef ref,
    Message message,
  ) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final currentUser = ref.read(currentUserProfileProvider).value;
              if (currentUser == null) return;

              _logger.info('Deleting message: ${message.id}');

              final chatService = ref.read(chatServiceProvider);
              await chatService.deleteMessage(
                messageId: message.id,
                userId: currentUser.uid,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesan berhasil dihapus'),
                    backgroundColor: AdminColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AdminColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// Handle edit message
  void _handleEditMessage(
    BuildContext context,
    WidgetRef ref,
    Message message,
  ) {
    final editController = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pesan'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Ketik pesan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesan tidak boleh kosong'),
                    backgroundColor: AdminColors.error,
                  ),
                );
                return;
              }

              if (newContent == message.content) {
                Navigator.pop(context);
                return;
              }

              Navigator.pop(context);

              _logger.info('Editing message: ${message.id}');

              final chatService = ref.read(chatServiceProvider);
              await chatService.editMessage(
                messageId: message.id,
                newContent: newContent,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesan berhasil diubah'),
                    backgroundColor: AdminColors.success,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
