// lib/screens/chat/chat_room_screen.dart
// Screen untuk chat room (conversation detail)

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/logging/app_logger.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/chat_providers.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/typing_indicator.dart';

final _logger = AppLogger('ChatRoomScreen');

/// Chat Room Screen - Detail conversation dengan messages
class ChatRoomScreen extends HookConsumerWidget {
  final String conversationId;
  final String? otherUserName; // Optional - for when participant names aren't in DB

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    this.otherUserName,
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
        elevation: 1, // Subtle shadow for white header
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)), // Slate-800
          onPressed: () => Navigator.pop(context),
        ),
        title: conversationAsync.when(
          data: (conversation) {
            if (conversation == null) {
              return Text(
                'Chat', 
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return currentUser.when(
              data: (user) {
                if (user == null) return Text('Chat', style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold));

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

                return Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFEFF6FF), // Blue-50
                      child: const Icon(Icons.person, color: Color(0xFF3B82F6), size: 20), // Blue-500
                    ),
                    const SizedBox(width: 12),
                    // Name + Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Use passed otherUserName if available, otherwise try from conversation
                            otherUserName ?? conversation.getDisplayName(user.uid),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1E293B), // Slate-800
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Online status
                          if (conversation.type == ConversationType.direct)
                            onlineStatusAsync.when(
                              data: (isOnline) {
                                if (isOnline) {
                                  return Text(
                                    'Online',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF22C55E), // Green-500
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }
                                // Show last seen when offline
                                final chatService = ref.read(chatServiceProvider);
                                return FutureBuilder<DateTime?>(
                                  future: chatService.getLastSeen(otherUserId ?? ''),
                                  builder: (context, lastSeenSnapshot) {
                                    if (!lastSeenSnapshot.hasData || lastSeenSnapshot.data == null) {
                                      return Text(
                                        'Offline',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      );
                                    }
                                    return Text(
                                      chatService.formatLastSeen(lastSeenSnapshot.data!),
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF64748B), // Slate-500
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    );
                                  },
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (error, _) => const SizedBox.shrink(),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => Text('Chat', style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
              error: (error, _) => Text('Chat', style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
            );
          },
          loading: () => Text('Loading...', style: GoogleFonts.inter(color: const Color(0xFF1E293B))),
          error: (_, __) => Text('Error', style: GoogleFonts.inter(color: const Color(0xFF1E293B))),
        ),
        actions: [
          // Video call button
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Color(0xFF64748B)), // Slate-500
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur video call dalam pengembangan'),
                ),
              );
            },
            tooltip: 'Video Call',
          ),
          // Voice call button
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Color(0xFF64748B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur voice call dalam pengembangan'),
                ),
              );
            },
            tooltip: 'Voice Call',
          ),
          // More actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _logger.info('Show conversation info');
                  _showConversationInfoDialog(context, ref);
                  break;
                case 'archive':
                  _logger.info('Archive conversation');
                  // TODO: Archive conversation
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'info',
                child: Text('Info Percakapan', style: GoogleFonts.inter()),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Text('Arsipkan', style: GoogleFonts.inter()),
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
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5C4), // Yellow bubble
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                )
                              ],
                            ),
                            child: const Text(
                              'Belum ada pesan. Mulai percakapan!',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
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
                onSend: () => _handleSendTextMessage(context, ref, user, messageController),
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
      dateText = 'Hari ini';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      dateText = 'Kemarin';
    } else {
      // Format: 07/12/2025 with padded zeros
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      dateText = '$day/$month/${date.year}';
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          dateText,
          style: AdminTypography.caption.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
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
    BuildContext context,
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
      senderName: user.displayName ?? 'User',
      content: text,
    );

    if (message != null) {
      controller.clear();
      _logger.info('Text message sent successfully');
      
      // If this was a new conversation, navigate to the actual conversation
      if (conversationId.startsWith('new_')) {
        // Get the actual chat_id from the sent message
        final actualConversationId = message.conversationId;
        _logger.info('Redirecting to actual conversation: $actualConversationId');
        
        // Replace current screen with the new conversation
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                conversationId: actualConversationId,
                otherUserName: otherUserName,
              ),
            ),
          );
        }
      } else {
        // Regular refresh for existing conversations
        ref.invalidate(messagesStreamProvider(conversationId));
      }
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
              await chatService.deleteMessage(message.id);

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

  /// Show conversation info dialog
  void _showConversationInfoDialog(BuildContext context, WidgetRef ref) {
    final conversationAsync = ref.read(conversationProvider(conversationId));
    final currentUser = ref.read(currentUserProfileProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return conversationAsync.when(
          data: (conversation) {
            if (conversation == null) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Tidak ada data percakapan')),
              );
            }

            final currentUserId = currentUser.maybeWhen(
              data: (user) => user?.uid ?? '',
              orElse: () => '',
            );

            // Get other participant ID
            final otherParticipantId = conversation.participantIds
                .firstWhere((id) => id != currentUserId, orElse: () => '');

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Info Percakapan',
                      style: AdminTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(
                        conversation.type == ConversationType.group
                            ? Icons.group
                            : Icons.person,
                        color: AppTheme.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display name or other user name
                    Text(
                      otherUserName ?? conversation.getDisplayName(currentUserId),
                      style: AdminTypography.h3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Chat type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: conversation.type == ConversationType.group
                            ? AdminColors.info.withValues(alpha: 0.1)
                            : AdminColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        conversation.type == ConversationType.group
                            ? 'Grup Chat'
                            : 'Chat Pribadi',
                        style: TextStyle(
                          color: conversation.type == ConversationType.group
                              ? AdminColors.info
                              : AdminColors.success,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info items
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'Dibuat',
                      value: _formatDate(conversation.createdAt),
                    ),
                    const Divider(height: 24),
                    _buildInfoItem(
                      icon: Icons.people_outline,
                      label: 'Peserta',
                      value: '${conversation.participantIds.length} orang',
                    ),
                    if (conversation.contextType != null) ...[
                      const Divider(height: 24),
                      _buildInfoItem(
                        icon: conversation.contextType == ChatContextType.report
                            ? Icons.description
                            : Icons.task_alt,
                        label: 'Konteks',
                        value: conversation.contextType == ChatContextType.report
                            ? 'Laporan #${conversation.contextId?.substring(0, 8) ?? ''}'
                            : 'Permintaan #${conversation.contextId?.substring(0, 8) ?? ''}',
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Tutup'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text('Error: $e')),
          ),
        );
      },
    );
  }

  /// Build info item row
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

