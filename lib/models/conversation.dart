// lib/models/conversation.dart
// Model untuk conversation (chat thread)

import 'dart:convert';
import 'package:intl/intl.dart';

/// Conversation types
enum ConversationType {
  direct,
  group;

  String toFirestore() {
    return name;
  }

  static ConversationType fromFirestore(String value) {
    return ConversationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConversationType.direct,
    );
  }
}

/// Context types for linking to Reports/Requests
enum ChatContextType {
  report,
  request;

  String toFirestore() {
    return name;
  }

  static ChatContextType? fromFirestore(String? value) {
    if (value == null) return null;
    return ChatContextType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatContextType.report,
    );
  }
}

/// Conversation Model
class Conversation {
  final String id;
  final ConversationType type;
  final String? name; // Group name (null for direct chat)
  final List<String> participantIds;
  final List<String> participantNames;
  final List<String> participantRoles;
  final String createdBy;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final String? groupAvatarUrl;
  final bool isArchived;
  final ChatContextType? contextType;
  final String? contextId;
  final Map<String, int> unreadCounts; // {"userId": count}
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.type,
    this.name,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    required this.createdBy,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageBy,
    this.groupAvatarUrl,
    this.isArchived = false,
    this.contextType,
    this.contextId,
    Map<String, int>? unreadCounts,
    required this.createdAt,
    required this.updatedAt,
  }) : unreadCounts = unreadCounts ?? {};

  /// Create from Appwrite document
  factory Conversation.fromAppwrite(Map<String, dynamic> data) {
    // Parse unreadCounts JSON string to Map
    Map<String, int> unreadCountsMap = {};
    if (data['unreadCounts'] != null && data['unreadCounts'] is String) {
      try {
        final decoded = jsonDecode(data['unreadCounts']) as Map<String, dynamic>;
        unreadCountsMap = decoded.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        unreadCountsMap = {};
      }
    }

    return Conversation(
      id: data['\$id'] ?? '',
      type: ConversationType.fromFirestore(data['type'] ?? 'direct'),
      name: data['name'],
      participantIds: data['participantIds'] != null
          ? List<String>.from(data['participantIds'])
          : [],
      participantNames: data['participantNames'] != null
          ? List<String>.from(data['participantNames'])
          : [],
      participantRoles: data['participantRoles'] != null
          ? List<String>.from(data['participantRoles'])
          : [],
      createdBy: data['createdBy'] ?? '',
      lastMessageText: data['lastMessageText'],
      lastMessageAt: data['lastMessageAt'] != null
          ? DateTime.parse(data['lastMessageAt'])
          : null,
      lastMessageBy: data['lastMessageBy'],
      groupAvatarUrl: data['groupAvatarUrl'],
      isArchived: data['isArchived'] ?? false,
      contextType: ChatContextType.fromFirestore(data['contextType']),
      contextId: data['contextId'],
      unreadCounts: unreadCountsMap,
      createdAt: DateTime.parse(data['\$createdAt']),
      updatedAt: DateTime.parse(data['\$updatedAt']),
    );
  }

  /// Create from Supabase (snake_case)
  factory Conversation.fromSupabase(Map<String, dynamic> data) {
    Map<String, int> unreadCountsMap = {};
    if (data['unread_counts'] != null) {
      try {
        if (data['unread_counts'] is String) {
          final decoded = jsonDecode(data['unread_counts']) as Map<String, dynamic>;
          unreadCountsMap = decoded.map((key, value) => MapEntry(key, value as int));
        } else if (data['unread_counts'] is Map) {
          unreadCountsMap = (data['unread_counts'] as Map).map(
            (key, value) => MapEntry(key.toString(), value as int));
        }
      } catch (e) {
        unreadCountsMap = {};
      }
    }

    return Conversation(
      id: data['id']?.toString() ?? '',
      type: ConversationType.fromFirestore(data['type'] ?? 'direct'),
      name: data['name'],
      participantIds: data['participant_ids'] != null
          ? List<String>.from(data['participant_ids'])
          : data['participant_1'] != null && data['participant_2'] != null
              ? [data['participant_1'], data['participant_2']]
              : [],
      participantNames: data['participant_names'] != null
          ? List<String>.from(data['participant_names'])
          : [],
      participantRoles: data['participant_roles'] != null
          ? List<String>.from(data['participant_roles'])
          : [],
      createdBy: data['created_by'] ?? '',
      lastMessageText: data['last_message'] ?? data['last_message_text'],
      lastMessageAt: data['last_message_at'] != null
          ? DateTime.parse(data['last_message_at'])
          : null,
      lastMessageBy: data['last_message_by'],
      groupAvatarUrl: data['group_avatar_url'],
      isArchived: data['is_archived'] ?? false,
      contextType: ChatContextType.fromFirestore(data['context_type']),
      contextId: data['context_id'],
      unreadCounts: unreadCountsMap,
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : DateTime.now(),
    );
  }

  /// Create from 'chats' table (simplified schema with participant_ids array)
  factory Conversation.fromChatsTable(Map<String, dynamic> data) {
    // Parse participant_ids from the array
    List<String> participantIds = [];
    if (data['participant_ids'] != null) {
      participantIds = (data['participant_ids'] as List).map((e) => e.toString()).toList();
    }

    // Determine context type from report_id or request_id
    ChatContextType? contextType;
    String? contextId;
    if (data['report_id'] != null) {
      contextType = ChatContextType.report;
      contextId = data['report_id'].toString();
    } else if (data['request_id'] != null) {
      contextType = ChatContextType.request;
      contextId = data['request_id'].toString();
    }

    return Conversation(
      id: data['id']?.toString() ?? '',
      type: participantIds.length == 2 ? ConversationType.direct : ConversationType.group,
      name: null, // No name column in chats table
      participantIds: participantIds,
      participantNames: [], // Not stored in chats table
      participantRoles: [], // Not stored in chats table
      createdBy: participantIds.isNotEmpty ? participantIds.first : '',
      lastMessageText: null,
      lastMessageAt: null,
      lastMessageBy: null,
      groupAvatarUrl: null,
      isArchived: false,
      contextType: contextType,
      contextId: contextId,
      unreadCounts: {},
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : DateTime.now(),
    );
  }

  /// Convert to Appwrite document data
  Map<String, dynamic> toAppwrite() {
    return {
      'type': type.toFirestore(),
      'name': name,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'createdBy': createdBy,
      'lastMessageText': lastMessageText,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessageBy': lastMessageBy,
      'groupAvatarUrl': groupAvatarUrl,
      'isArchived': isArchived,
      'contextType': contextType?.toFirestore(),
      'contextId': contextId,
      'unreadCounts': jsonEncode(unreadCounts),
    };
  }

  /// Copy with method
  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? name,
    List<String>? participantIds,
    List<String>? participantNames,
    List<String>? participantRoles,
    String? createdBy,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    String? groupAvatarUrl,
    bool? isArchived,
    ChatContextType? contextType,
    String? contextId,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantRoles: participantRoles ?? this.participantRoles,
      createdBy: createdBy ?? this.createdBy,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
      isArchived: isArchived ?? this.isArchived,
      contextType: contextType ?? this.contextType,
      contextId: contextId ?? this.contextId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get unread count for specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Get display name for conversation
  String getDisplayName(String currentUserId) {
    if (type == ConversationType.group) {
      return name ?? 'Group Chat';
    }

    // Direct chat - show other participant's name
    final otherParticipantIndex = participantIds.indexOf(
      participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => participantIds.first,
      ),
    );

    if (otherParticipantIndex >= 0 && otherParticipantIndex < participantNames.length) {
      final otherName = participantNames[otherParticipantIndex];
      final otherRole = participantRoles.length > otherParticipantIndex
          ? participantRoles[otherParticipantIndex]
          : '';

      // Show role in parentheses
      if (otherRole.isNotEmpty) {
        final roleDisplay = otherRole == 'cleaner'
            ? 'Petugas'
            : otherRole == 'admin'
                ? 'Admin'
                : 'Karyawan';
        return '$otherName ($roleDisplay)';
      }
      return otherName;
    }

    return 'Unknown';
  }

  /// Get last message preview
  String getLastMessagePreview() {
    if (lastMessageText == null || lastMessageText!.isEmpty) {
      return 'No messages yet';
    }

    // Truncate long messages
    if (lastMessageText!.length > 50) {
      return '${lastMessageText!.substring(0, 50)}...';
    }

    return lastMessageText!;
  }

  /// Format last message time
  String getFormattedLastMessageTime() {
    if (lastMessageAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(lastMessageAt!);
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(lastMessageAt!);
    } else {
      // Older - show date
      return DateFormat('dd/MM/yy').format(lastMessageAt!);
    }
  }

  /// Check if user is participant
  bool isParticipant(String userId) {
    return participantIds.contains(userId);
  }

  /// Check if conversation is group
  bool get isGroup => type == ConversationType.group;

  /// Check if conversation is direct
  bool get isDirect => type == ConversationType.direct;

  /// Check if conversation has context (linked to report/request)
  bool get hasContext => contextType != null && contextId != null;

  /// Get context display string
  String? getContextDisplay() {
    if (!hasContext) return null;

    if (contextType == ChatContextType.report) {
      return 'Tentang Laporan';
    } else if (contextType == ChatContextType.request) {
      return 'Tentang Permintaan';
    }

    return null;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, type: $type, participants: ${participantNames.join(', ')}, lastMessage: ${getLastMessagePreview()})';
  }
}
