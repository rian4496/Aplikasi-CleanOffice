// lib/widgets/chat/message_bubble.dart
// Widget untuk menampilkan message bubble

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';
import '../../models/message.dart';
import 'image_preview_modal.dart';

/// Message Bubble Widget
/// Displays a single message in the chat room
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Align(
        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Grey background for both
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
              bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender name (if not own message)
              if (!isOwnMessage) ...[
                Text(
                  message.senderName,
                  style: AdminTypography.caption.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Reply-to preview (if replying to a message)
              if (message.replyToMessageId != null &&
                  message.replyToText != null) ...[
                _buildReplyPreview(),
                const SizedBox(height: 8),
              ],

              // Message content based on type
              _buildMessageContent(),

              const SizedBox(height: 2),

              // Time and status row (INSIDE bubble)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edited indicator inline
                  if (message.isEdited) ...[
                    Text(
                      'diedit ',
                      style: AdminTypography.caption.copyWith(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  Text(
                    message.getFormattedTime(),
                    style: AdminTypography.caption.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  if (isOwnMessage) ...[
                    const SizedBox(width: 4),
                    _buildReadStatus(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build reply-to preview
  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOwnMessage
            ? Colors.white.withValues(alpha: 0.2)
            : AdminColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isOwnMessage ? Colors.white : AdminColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        message.replyToText!,
        style: AdminTypography.caption.copyWith(
          color: isOwnMessage ? Colors.white : AdminColors.textSecondary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build message content based on type
  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.file:
        return _buildFileMessage();
    }
  }

  /// Build text message
  Widget _buildTextMessage() {
    return Text(
      message.content,
      style: AdminTypography.body2.copyWith(
        color: Colors.black, // Black text on grey background
      ),
    );
  }

  /// Build image message
  Widget _buildImageMessage() {
    if (message.mediaUrl == null) {
      return _buildTextMessage();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              // Open image preview
              ImagePreviewModal.show(
                context,
                imageUrl: message.mediaUrl!,
                caption: message.content,
              );
            },
            child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: message.mediaUrl!,
              width: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 250,
                height: 200,
                color: isOwnMessage
                    ? Colors.white.withValues(alpha: 0.2)
                    : AdminColors.background,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 250,
                height: 200,
                color: isOwnMessage
                    ? Colors.white.withValues(alpha: 0.2)
                    : AdminColors.background,
                child: Icon(
                  Icons.broken_image,
                  color: isOwnMessage ? Colors.white70 : Colors.grey,
                  size: 48,
                ),
              ),
            ),
          ),
          ),
        ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTextMessage(),
        ],
      ],
    );
  }

  /// Build file message
  Widget _buildFileMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwnMessage
            ? Colors.white.withValues(alpha: 0.2)
            : AdminColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: isOwnMessage ? Colors.white : AdminColors.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.mediaFileName ?? 'File',
                  style: AdminTypography.body2.copyWith(
                    color: isOwnMessage ? Colors.white : AdminColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.mediaFileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(message.mediaFileSize!),
                    style: AdminTypography.caption.copyWith(
                      color: isOwnMessage ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build read status icons
  Widget _buildReadStatus() {
    final isRead = message.readBy.length > 1; // More than just sender

    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: 12,
      color: isRead ? AdminColors.info : (isOwnMessage ? Colors.white60 : Colors.grey[600]),
    );
  }

  /// Format file size to human-readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
