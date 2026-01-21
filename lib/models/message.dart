// lib/models/message.dart
// Model untuk chat message

import 'package:intl/intl.dart';

/// Message types
enum MessageType {
  text,
  image,
  file;

  String toDatabase() {
    return name;
  }

  static MessageType fromDatabase(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }
}

/// Message status (for UI display)
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;
}

/// Chat Message Model
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String? senderAvatarUrl;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? mediaFileName;
  final int? mediaFileSize;
  final String? mediaMimeType;
  final String? replyToMessageId;
  final String? replyToText;
  final Map<String, List<String>> reactions; // {"👍": ["userId1", "userId2"]}
  final List<String> readBy;
  final List<String> deliveredTo;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? deletedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderAvatarUrl,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.mediaFileName,
    this.mediaFileSize,
    this.mediaMimeType,
    this.replyToMessageId,
    this.replyToText,
    Map<String, List<String>>? reactions,
    List<String>? readBy,
    List<String>? deliveredTo,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    required this.createdAt,
    required this.updatedAt,
  })  : reactions = reactions ?? {},
        readBy = readBy ?? [],
        deliveredTo = deliveredTo ?? [];

  /// Create from Supabase (snake_case)
  factory Message.fromSupabase(Map<String, dynamic> data) {
    return Message(
      id: data['id']?.toString() ?? '',
      conversationId: data['chat_id']?.toString() ?? data['conversation_id']?.toString() ?? '',
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? '',
      senderRole: data['sender_role'] ?? '',
      senderAvatarUrl: data['sender_avatar_url'],
      type: MessageType.fromDatabase(data['type'] ?? 'text'),
      content: data['content'] ?? '',
      mediaUrl: data['media_url'] ?? data['image_url'],
      mediaFileName: data['media_file_name'],
      mediaFileSize: data['media_file_size'],
      mediaMimeType: data['media_mime_type'],
      replyToMessageId: data['reply_to_message_id'],
      replyToText: data['reply_to_text'],
      reactions: {},
      readBy: data['read_by'] != null ? List<String>.from(data['read_by']) : [],
      deliveredTo: data['delivered_to'] != null ? List<String>.from(data['delivered_to']) : [],
      isEdited: data['is_edited'] ?? false,
      editedAt: data['edited_at'] != null ? DateTime.parse(data['edited_at']) : null,
      isDeleted: data['is_deleted'] ?? false,
      deletedAt: data['deleted_at'] != null ? DateTime.parse(data['deleted_at']) : null,
      deletedBy: data['deleted_by'],
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : DateTime.now(),
    );
  }


  /// Convert to Supabase document data (snake_case)
  Map<String, dynamic> toSupabase() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'sender_avatar_url': senderAvatarUrl,
      'type': type.toDatabase(),
      'content': content,
      'media_url': mediaUrl,
      'media_file_name': mediaFileName,
      'media_file_size': mediaFileSize,
      'media_mime_type': mediaMimeType,
      'reply_to_message_id': replyToMessageId,
      'reply_to_text': replyToText,
      'read_by': readBy,
      'delivered_to': deliveredTo,
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  /// Copy with method for immutability
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? senderAvatarUrl,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? mediaFileName,
    int? mediaFileSize,
    String? mediaMimeType,
    String? replyToMessageId,
    String? replyToText,
    Map<String, List<String>>? reactions,
    List<String>? readBy,
    List<String>? deliveredTo,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaFileName: mediaFileName ?? this.mediaFileName,
      mediaFileSize: mediaFileSize ?? this.mediaFileSize,
      mediaMimeType: mediaMimeType ?? this.mediaMimeType,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      reactions: reactions ?? this.reactions,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if message is read by user
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  /// Get message status for specific user
  MessageStatus getStatus(String currentUserId) {
    // Own message
    if (senderId == currentUserId) {
      if (readBy.isNotEmpty) return MessageStatus.read;
      if (deliveredTo.isNotEmpty) return MessageStatus.delivered;
      return MessageStatus.sent;
    }
    // Other's message
    return isReadBy(currentUserId) ? MessageStatus.read : MessageStatus.delivered;
  }

  /// Format timestamp
  String getFormattedTime() {
    final now = DateTime.now();
    // Convert UTC to local time for display
    final localTime = createdAt.toLocal();
    final difference = now.difference(localTime);

    if (difference.inDays == 0) {
      // Today - show time only
      return DateFormat('HH:mm').format(localTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(localTime);
    } else {
      // Older - show date
      return DateFormat('dd/MM/yyyy').format(localTime);
    }
  }

  /// Check if message can be edited (within 15 minutes)
  bool canEdit(String currentUserId) {
    if (senderId != currentUserId) return false;
    if (isDeleted) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inMinutes <= 15;
  }

  /// Check if message can be deleted
  bool canDelete(String currentUserId) {
    return senderId == currentUserId && !isDeleted;
  }

  @override
  String toString() {
    return 'Message(id: $id, sender: $senderName, type: $type, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content})';
  }
}

