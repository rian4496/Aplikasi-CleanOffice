// lib/models/message.dart
// Model untuk chat message

import 'package:intl/intl.dart';

/// Message types
enum MessageType {
  text,
  image,
  file;

  String toFirestore() {
    return name;
  }

  static MessageType fromFirestore(String value) {
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

  /// Create from Appwrite document
  factory Message.fromAppwrite(Map<String, dynamic> data) {
    // Parse reactions JSON string to Map
    Map<String, List<String>> reactionsMap = {};
    if (data['reactions'] != null && data['reactions'] is String) {
      try {
        final decoded = data['reactions'] as String;
        if (decoded.isNotEmpty && decoded != '{}') {
          // Simple JSON parsing for reactions
          // Format: {"👍": ["userId1"], "❤️": ["userId2"]}
          reactionsMap = {}; // TODO: Implement JSON parsing if needed
        }
      } catch (e) {
        reactionsMap = {};
      }
    }

    return Message(
      id: data['\$id'] ?? '',
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      senderAvatarUrl: data['senderAvatarUrl'],
      type: MessageType.fromFirestore(data['type'] ?? 'text'),
      content: data['content'] ?? '',
      mediaUrl: data['mediaUrl'],
      mediaFileName: data['mediaFileName'],
      mediaFileSize: data['mediaFileSize'],
      mediaMimeType: data['mediaMimeType'],
      replyToMessageId: data['replyToMessageId'],
      replyToText: data['replyToText'],
      reactions: reactionsMap,
      readBy: data['readBy'] != null
          ? List<String>.from(data['readBy'])
          : [],
      deliveredTo: data['deliveredTo'] != null
          ? List<String>.from(data['deliveredTo'])
          : [],
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'] != null
          ? DateTime.parse(data['editedAt'])
          : null,
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'] != null
          ? DateTime.parse(data['deletedAt'])
          : null,
      deletedBy: data['deletedBy'],
      createdAt: DateTime.parse(data['\$createdAt']),
      updatedAt: DateTime.parse(data['\$updatedAt']),
    );
  }

  /// Convert to Appwrite document data
  Map<String, dynamic> toAppwrite() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'senderAvatarUrl': senderAvatarUrl,
      'type': type.toFirestore(),
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaFileName': mediaFileName,
      'mediaFileSize': mediaFileSize,
      'mediaMimeType': mediaMimeType,
      'replyToMessageId': replyToMessageId,
      'replyToText': replyToText,
      'reactions': '{}', // JSON string
      'readBy': readBy,
      'deliveredTo': deliveredTo,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
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
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      // Today - show time only
      return DateFormat('HH:mm').format(createdAt);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(createdAt);
    } else {
      // Older - show date
      return DateFormat('dd/MM/yyyy').format(createdAt);
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
