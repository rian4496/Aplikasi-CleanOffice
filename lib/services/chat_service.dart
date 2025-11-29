// lib/services/chat_service.dart
// Service for managing chat conversations and messages

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../core/config/appwrite_config.dart';
import '../core/services/appwrite_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

/// Chat Service - Manages conversations and messages
class ChatService {
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Logger _logger = Logger('ChatService');
  Databases get _databases => AppwriteClient().databases;
  Realtime get _realtime => AppwriteClient().realtime;
  Storage get _storage => AppwriteClient().storage;

  // ==================== CONVERSATIONS ====================

  /// Get all conversations for a specific user (with realtime updates)
  Stream<List<Conversation>> getConversations(String userId) async* {
    Future<List<Conversation>> fetchConversations() async {
      try {
        final response = await _databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.conversationsCollectionId,
          queries: [
            Query.equal('participantIds', [userId]),
            Query.equal('isArchived', [false]),
            Query.orderDesc('\$updatedAt'),
            Query.limit(100),
          ],
        );

        return response.documents
            .map((doc) => Conversation.fromAppwrite(doc.data))
            .toList();
      } catch (e) {
        _logger.severe('Error fetching conversations: $e');
        return [];
      }
    }

    // Emit initial data
    yield await fetchConversations();

    // Listen for realtime updates
    await for (final _ in _realtime
        .subscribe([AppwriteConfig.conversationsChannel]).stream) {
      yield await fetchConversations();
    }
  }

  /// Create a new conversation
  Future<Conversation?> createConversation({
    required ConversationType type,
    required List<String> participantIds,
    required List<String> participantNames,
    required List<String> participantRoles,
    required String createdBy,
    String? name, // For group chat
    ChatContextType? contextType,
    String? contextId,
  }) async {
    try {
      // Check if direct conversation already exists
      if (type == ConversationType.direct) {
        final existing = await _findExistingDirectConversation(participantIds);
        if (existing != null) {
          _logger.info('Direct conversation already exists: ${existing.id}');
          return existing;
        }
      }

      // Initialize unread counts for all participants
      final unreadCounts = <String, int>{};
      for (final participantId in participantIds) {
        unreadCounts[participantId] = 0;
      }

      final conversationData = {
        'type': type.toFirestore(),
        'name': name,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'participantRoles': participantRoles,
        'createdBy': createdBy,
        'lastMessageText': null,
        'lastMessageAt': null,
        'lastMessageBy': null,
        'groupAvatarUrl': null,
        'isArchived': false,
        'contextType': contextType?.toFirestore(),
        'contextId': contextId,
        'unreadCounts': '{}', // JSON string
      };

      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: ID.unique(),
        data: conversationData,
      );

      _logger.info('Conversation created successfully: ${response.$id}');
      return Conversation.fromAppwrite(response.data);
    } catch (e) {
      _logger.severe('Error creating conversation: $e');
      return null;
    }
  }

  /// Find existing direct conversation between two users
  Future<Conversation?> _findExistingDirectConversation(
      List<String> participantIds) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        queries: [
          Query.equal('type', ['direct']),
          Query.equal('participantIds', [participantIds[0]]),
          Query.equal('participantIds', [participantIds[1]]),
          Query.limit(1),
        ],
      );

      if (response.documents.isEmpty) return null;
      return Conversation.fromAppwrite(response.documents.first.data);
    } catch (e) {
      _logger.severe('Error finding existing conversation: $e');
      return null;
    }
  }

  /// Get or create direct conversation
  Future<Conversation?> getOrCreateDirectConversation({
    required String currentUserId,
    required String otherUserId,
    required UserProfile currentUser,
    required UserProfile otherUser,
  }) async {
    // Try to find existing
    final existing = await _findExistingDirectConversation([
      currentUserId,
      otherUserId,
    ]);

    if (existing != null) return existing;

    // Create new
    return await createConversation(
      type: ConversationType.direct,
      participantIds: [currentUserId, otherUserId],
      participantNames: [currentUser.displayName, otherUser.displayName],
      participantRoles: [currentUser.role, otherUser.role],
      createdBy: currentUserId,
    );
  }

  /// Update conversation's last message
  Future<void> updateConversationLastMessage({
    required String conversationId,
    required String messageText,
    required String messageBy,
    required DateTime messageAt,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
        data: {
          'lastMessageText': messageText,
          'lastMessageAt': messageAt.toIso8601String(),
          'lastMessageBy': messageBy,
        },
      );
    } catch (e) {
      _logger.severe('Error updating conversation last message: $e');
    }
  }

  /// Increment unread count for participants (except sender)
  Future<void> incrementUnreadCount({
    required String conversationId,
    required String senderId,
    required List<String> participantIds,
  }) async {
    try {
      // Get current conversation
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
      );

      final conversation = Conversation.fromAppwrite(doc.data);
      final unreadCounts = Map<String, int>.from(conversation.unreadCounts);

      // Increment for all participants except sender
      for (final participantId in participantIds) {
        if (participantId != senderId) {
          unreadCounts[participantId] = (unreadCounts[participantId] ?? 0) + 1;
        }
      }

      // Update document
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
        data: {
          'unreadCounts': _encodeUnreadCounts(unreadCounts),
        },
      );
    } catch (e) {
      _logger.severe('Error incrementing unread count: $e');
    }
  }

  /// Reset unread count for a specific user
  Future<void> resetUnreadCount({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Get current conversation
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
      );

      final conversation = Conversation.fromAppwrite(doc.data);
      final unreadCounts = Map<String, int>.from(conversation.unreadCounts);

      // Reset for this user
      unreadCounts[userId] = 0;

      // Update document
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
        data: {
          'unreadCounts': _encodeUnreadCounts(unreadCounts),
        },
      );
    } catch (e) {
      _logger.severe('Error resetting unread count: $e');
    }
  }

  /// Encode unread counts to JSON string
  String _encodeUnreadCounts(Map<String, int> unreadCounts) {
    final entries = unreadCounts.entries
        .map((e) => '"${e.key}":${e.value}')
        .join(',');
    return '{$entries}';
  }

  // ==================== MESSAGES ====================

  /// Get all messages for a conversation (with realtime updates)
  Stream<List<Message>> getMessages(String conversationId) async* {
    Future<List<Message>> fetchMessages() async {
      try {
        final response = await _databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          queries: [
            Query.equal('conversationId', [conversationId]),
            Query.equal('isDeleted', [false]),
            Query.orderDesc('\$createdAt'),
            Query.limit(100),
          ],
        );

        return response.documents
            .map((doc) => Message.fromAppwrite(doc.data))
            .toList();
      } catch (e) {
        _logger.severe('Error fetching messages: $e');
        return [];
      }
    }

    // Emit initial data
    yield await fetchMessages();

    // Listen for realtime updates
    await for (final _ in _realtime
        .subscribe([AppwriteConfig.messagesChannel]).stream) {
      yield await fetchMessages();
    }
  }

  /// Send a text message
  Future<Message?> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    String? senderAvatarUrl,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? mediaFileName,
    int? mediaFileSize,
    String? mediaMimeType,
    String? replyToMessageId,
    String? replyToText,
  }) async {
    try {
      final messageData = {
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
        'reactions': '{}',
        'readBy': [senderId], // Sender has read their own message
        'deliveredTo': <String>[],
        'isEdited': false,
        'editedAt': null,
        'isDeleted': false,
        'deletedAt': null,
        'deletedBy': null,
      };

      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: ID.unique(),
        data: messageData,
      );

      final message = Message.fromAppwrite(response.data);

      // Update conversation's last message
      await updateConversationLastMessage(
        conversationId: conversationId,
        messageText: content,
        messageBy: senderId,
        messageAt: message.createdAt,
      );

      // Get conversation to increment unread count
      final conversationDoc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
      );
      final conversation = Conversation.fromAppwrite(conversationDoc.data);

      // Increment unread count for other participants
      await incrementUnreadCount(
        conversationId: conversationId,
        senderId: senderId,
        participantIds: conversation.participantIds,
      );

      _logger.info('Message sent successfully: ${message.id}');
      return message;
    } catch (e) {
      _logger.severe('Error sending message: $e');
      return null;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
    required List<String> messageIds,
  }) async {
    try {
      for (final messageId in messageIds) {
        // Get current message
        final doc = await _databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          documentId: messageId,
        );

        final message = Message.fromAppwrite(doc.data);

        // Skip if already read
        if (message.readBy.contains(userId)) continue;

        // Add user to readBy list
        final readBy = List<String>.from(message.readBy)..add(userId);

        await _databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          documentId: messageId,
          data: {
            'readBy': readBy,
          },
        );
      }

      // Reset unread count for this conversation
      await resetUnreadCount(
        conversationId: conversationId,
        userId: userId,
      );

      _logger.info('Messages marked as read for user: $userId');
    } catch (e) {
      _logger.severe('Error marking messages as read: $e');
    }
  }

  /// Delete a message (soft delete)
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {
          'isDeleted': true,
          'deletedAt': DateTime.now().toIso8601String(),
          'deletedBy': userId,
          'content': 'Pesan telah dihapus',
        },
      );

      _logger.info('Message deleted: $messageId');
    } catch (e) {
      _logger.severe('Error deleting message: $e');
    }
  }

  /// Edit a message
  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {
          'content': newContent,
          'isEdited': true,
          'editedAt': DateTime.now().toIso8601String(),
        },
      );

      _logger.info('Message edited: $messageId');
    } catch (e) {
      _logger.severe('Error editing message: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        documentId: conversationId,
      );

      return Conversation.fromAppwrite(doc.data);
    } catch (e) {
      _logger.severe('Error getting conversation: $e');
      return null;
    }
  }

  /// Get message by ID
  Future<Message?> getMessage(String messageId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
      );

      return Message.fromAppwrite(doc.data);
    } catch (e) {
      _logger.severe('Error getting message: $e');
      return null;
    }
  }

  /// Get total unread count for a user (across all conversations)
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.conversationsCollectionId,
        queries: [
          Query.equal('participantIds', [userId]),
          Query.equal('isArchived', [false]),
        ],
      );

      int totalUnread = 0;
      for (final doc in response.documents) {
        final conversation = Conversation.fromAppwrite(doc.data);
        totalUnread += conversation.getUnreadCount(userId);
      }

      return totalUnread;
    } catch (e) {
      _logger.severe('Error getting total unread count: $e');
      return 0;
    }
  }

  // ==================== MEDIA UPLOAD ====================

  /// Upload image to storage and send as message
  Future<Message?> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    String? senderAvatarUrl,
    required String imagePath,
    String? caption,
  }) async {
    try {
      _logger.info('Uploading image: $imagePath');

      // Upload image to storage
      final file = File(imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';

      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConfig.mainBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imagePath, filename: fileName),
      );

      // Get file URL
      final fileUrl = '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.mainBucketId}/files/${uploadedFile.$id}/view?project=${AppwriteConfig.projectId}';

      _logger.info('Image uploaded: $fileUrl');

      // Send message with image
      return await sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        senderAvatarUrl: senderAvatarUrl,
        content: caption ?? '',
        type: MessageType.image,
        mediaUrl: fileUrl,
        mediaFileName: fileName,
        mediaFileSize: await file.length(),
        mediaMimeType: _getMimeType(imagePath),
      );
    } catch (e) {
      _logger.severe('Error uploading image: $e');
      return null;
    }
  }

  /// Upload file to storage and send as message
  Future<Message?> sendFileMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    String? senderAvatarUrl,
    required String filePath,
    required String fileName,
  }) async {
    try {
      _logger.info('Uploading file: $filePath');

      // Upload file to storage
      final file = File(filePath);
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConfig.mainBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath, filename: uniqueFileName),
      );

      // Get file URL
      final fileUrl = '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.mainBucketId}/files/${uploadedFile.$id}/view?project=${AppwriteConfig.projectId}';

      _logger.info('File uploaded: $fileUrl');

      // Send message with file
      return await sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        senderAvatarUrl: senderAvatarUrl,
        content: fileName,
        type: MessageType.file,
        mediaUrl: fileUrl,
        mediaFileName: fileName,
        mediaFileSize: await file.length(),
        mediaMimeType: _getMimeType(filePath),
      );
    } catch (e) {
      _logger.severe('Error uploading file: $e');
      return null;
    }
  }

  /// Get MIME type from file path
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  // ==================== TYPING INDICATOR ====================

  /// Set typing indicator for user in conversation
  Future<void> setTypingIndicator({
    required String conversationId,
    required String userId,
    required String userName,
    required bool isTyping,
  }) async {
    try {
      if (isTyping) {
        // Create or update typing indicator
        await _databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.typingIndicatorsCollectionId,
          documentId: '${conversationId}_$userId',
          data: {
            'conversationId': conversationId,
            'userId': userId,
            'userName': userName,
            'isTyping': true,
            'lastTypedAt': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Remove typing indicator
        try {
          await _databases.deleteDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.typingIndicatorsCollectionId,
            documentId: '${conversationId}_$userId',
          );
        } catch (e) {
          // Document might not exist, ignore error
        }
      }
    } catch (e) {
      _logger.warning('Error setting typing indicator: $e');
    }
  }

  /// Get typing users in conversation (stream)
  Stream<List<String>> getTypingUsers(String conversationId, String currentUserId) async* {
    Future<List<String>> fetchTypingUsers() async {
      try {
        final response = await _databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.typingIndicatorsCollectionId,
          queries: [
            Query.equal('conversationId', [conversationId]),
            Query.equal('isTyping', [true]),
          ],
        );

        return response.documents
            .where((doc) => doc.data['userId'] != currentUserId)
            .map((doc) => doc.data['userName'] as String)
            .toList();
      } catch (e) {
        _logger.warning('Error fetching typing users: $e');
        return [];
      }
    }

    // Emit initial data
    yield await fetchTypingUsers();

    // Listen for realtime updates
    await for (final _ in _realtime
        .subscribe([AppwriteConfig.typingIndicatorsChannel]).stream) {
      yield await fetchTypingUsers();
    }
  }

  // ==================== USER PRESENCE ====================

  /// Update user online status
  Future<void> updateUserPresence({
    required String userId,
    required String userName,
    required bool isOnline,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userPresenceCollectionId,
        documentId: userId,
        data: {
          'userId': userId,
          'userName': userName,
          'isOnline': isOnline,
          'lastSeenAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.warning('Error updating user presence: $e');
    }
  }

  /// Get user online status
  Future<bool> isUserOnline(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userPresenceCollectionId,
        documentId: userId,
      );

      final isOnline = doc.data['isOnline'] as bool? ?? false;
      final lastSeenAt = DateTime.parse(doc.data['lastSeenAt'] as String);
      final now = DateTime.now();

      // Consider user offline if last seen > 2 minutes ago
      if (now.difference(lastSeenAt).inMinutes > 2) {
        return false;
      }

      return isOnline;
    } catch (e) {
      return false;
    }
  }

  /// Get multiple users online status
  Future<Map<String, bool>> getUsersOnlineStatus(List<String> userIds) async {
    final statusMap = <String, bool>{};

    for (final userId in userIds) {
      statusMap[userId] = await isUserOnline(userId);
    }

    return statusMap;
  }

  // ==================== MESSAGE REACTIONS ====================

  /// Add reaction to message
  Future<void> addMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
      );

      final message = Message.fromAppwrite(doc.data);
      final reactions = Map<String, List<String>>.from(message.reactions);

      // Add user to emoji list
      if (reactions.containsKey(emoji)) {
        if (!reactions[emoji]!.contains(userId)) {
          reactions[emoji]!.add(userId);
        }
      } else {
        reactions[emoji] = [userId];
      }

      // Encode reactions to JSON string
      final reactionsJson = _encodeReactions(reactions);

      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {'reactions': reactionsJson},
      );
    } catch (e) {
      _logger.severe('Error adding message reaction: $e');
    }
  }

  /// Remove reaction from message
  Future<void> removeMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
      );

      final message = Message.fromAppwrite(doc.data);
      final reactions = Map<String, List<String>>.from(message.reactions);

      // Remove user from emoji list
      if (reactions.containsKey(emoji)) {
        reactions[emoji]!.remove(userId);
        if (reactions[emoji]!.isEmpty) {
          reactions.remove(emoji);
        }
      }

      // Encode reactions to JSON string
      final reactionsJson = _encodeReactions(reactions);

      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {'reactions': reactionsJson},
      );
    } catch (e) {
      _logger.severe('Error removing message reaction: $e');
    }
  }

  /// Encode reactions map to JSON string
  String _encodeReactions(Map<String, List<String>> reactions) {
    if (reactions.isEmpty) return '{}';

    final entries = reactions.entries.map((e) {
      final usersList = e.value.map((u) => '"$u"').join(',');
      return '"${e.key}":[$usersList]';
    }).join(',');

    return '{$entries}';
  }
}
