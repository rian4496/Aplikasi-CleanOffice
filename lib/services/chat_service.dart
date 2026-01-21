import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import '../core/config/supabase_config.dart';
import '../models/message.dart';
import '../models/conversation.dart';

/// Service for chat/messaging functionality using Supabase.
/// Updated to use 'chats' table with participant_ids array schema.
class ChatService {
  final SupabaseClient _supabase;
  final _logger = AppLogger('ChatService');
  
  // Track active presence channels for cleanup
  final Map<String, RealtimeChannel> _typingChannels = {};
  final Map<String, StreamController<List<String>>> _typingControllers = {};
  
  ChatService([SupabaseClient? supabase]) 
      : _supabase = supabase ?? Supabase.instance.client;

  // ==================== SUPPORT CHAT CONFIG ====================
  
  /// Support Team Agent IDs - Add all support agent UIDs here
  /// These agents will all be added to the support group chat
  static const List<String> SUPPORT_AGENT_IDS = [
    'fb3e61f0-6c2d-48b8-b754-35fc5c9df260', // Fitri
    '320f1e14-230c-4081-b8fe-4d202d8f092b', // Hadianur
  ];
  static const String SUPPORT_CHAT_NAME = 'Tim Support BRIDA';

  /// Get or create a GROUP conversation with the support team
  /// All support agents will be added as participants
  Future<Conversation?> getOrCreateSupportConversation({
    required String currentUserId,
    required String currentUserName,
  }) async {
    try {
      _logger.info('Starting support conversation lookup for user: $currentUserId');
      
      // Build participant list: current user + all support agents
      final allParticipants = <String>[currentUserId, ...SUPPORT_AGENT_IDS];
      
      // Check if a support group chat already exists for this user
      _logger.info('Querying existing chats...');
      final existingChats = await _supabase
          .from('chats')
          .select()
          .contains('participant_ids', [currentUserId]);
      
      _logger.info('Found ${(existingChats as List).length} existing chats for user');
      
      // Find existing support chat (contains current user and at least one support agent)
      for (final chat in existingChats) {
        final participantIds = (chat['participant_ids'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [];
        
        // Check if this chat has any support agent
        final hasSupportAgent = SUPPORT_AGENT_IDS.any((agentId) => participantIds.contains(agentId));
        if (hasSupportAgent && participantIds.contains(currentUserId)) {
          _logger.info('Found existing support chat: ${chat['id']}');
          final conversation = Conversation.fromChatsTable(chat);
          _logger.info('Parsed conversation successfully: ${conversation.id}');
          return conversation;
        }
      }

      // Create new group chat with all participants
      _logger.info('No existing support chat found, creating new one...');
      final response = await _supabase
          .from('chats')
          .insert({
            'participant_ids': allParticipants,
            'name': SUPPORT_CHAT_NAME,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      _logger.info('Created support group chat: ${response['id']} with ${allParticipants.length} participants');
      final conversation = Conversation.fromChatsTable(response);
      _logger.info('Parsed new conversation successfully: ${conversation.id}');
      return conversation;
    } catch (e, stack) {
      _logger.error('Failed to get/create support conversation: $e\n$stack');
      return null;
    }
  }

  // ==================== CONVERSATIONS (using 'chats' table) ====================

  /// Get all conversations for a user as Stream with Supabase Realtime
  Stream<List<Conversation>> getConversations(String userId) {
    final controller = StreamController<List<Conversation>>();
    
    // Function to reload all conversations
    Future<void> reloadConversations() async {
      try {
        final conversations = await _getConversationsFuture(userId);
        if (!controller.isClosed) {
          controller.add(conversations);
        }
      } catch (e) {
        _logger.error('Failed to reload conversations', e);
        if (!controller.isClosed) {
          controller.add([]);
        }
      }
    }

    // Load initial conversations
    reloadConversations();

    // Subscribe to realtime updates on chats table
    final channel = _supabase
        .channel('chats:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chats',
          callback: (payload) {
            _logger.info('Chats change received: ${payload.eventType}');
            // Refetch all conversations for reliability
            reloadConversations();
          },
        )
        .subscribe((status, error) {
          _logger.info('Chats channel status: $status');
          if (error != null) {
            _logger.error('Chats channel error', error);
          }
        });

    // Cleanup when stream is closed
    controller.onCancel = () {
      _logger.info('Unsubscribing from chats channel');
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  /// Get all conversations for a user as Future (preferred for invalidation)
  Future<List<Conversation>> getConversationsFuture(String userId) {
    return _getConversationsFuture(userId);
  }

  Future<List<Conversation>> _getConversationsFuture(String userId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .contains('participant_ids', [userId])
          .order('updated_at', ascending: false);
      
      final conversations = <Conversation>[];
      
      for (final chatData in response as List) {
        // Get participant IDs
        final participantIds = (chatData['participant_ids'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [];
        
        // Fetch participant names from users table
        final participantNames = <String>[];
        for (final participantId in participantIds) {
          try {
            _logger.info('Fetching user for participant: $participantId');
            final userResponse = await _supabase
                .from('users')
                .select('display_name')
                .eq('id', participantId)
                .maybeSingle();
            _logger.info('User response for $participantId: $userResponse');
            if (userResponse != null && userResponse['display_name'] != null) {
              participantNames.add(userResponse['display_name']);
            } else {
              _logger.warning('No display_name found for user $participantId - response was: $userResponse');
              participantNames.add('User');
            }
          } catch (e) {
            _logger.error('Failed to fetch user $participantId', e);
            participantNames.add('User');
          }
        }
        
        // Fetch last message
        String? lastMessageText;
        DateTime? lastMessageTime;
        String? lastMessageSenderId;
        
        try {
          final lastMsgResponse = await _supabase
              .from('messages')
              .select('content, created_at, sender_id')
              .eq('chat_id', chatData['id'])
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
          
          if (lastMsgResponse != null) {
            lastMessageText = lastMsgResponse['content'];
            lastMessageTime = DateTime.tryParse(lastMsgResponse['created_at'] ?? '');
            lastMessageSenderId = lastMsgResponse['sender_id'];
          }
        } catch (e) {
          _logger.error('Failed to get last message', e);
        }
        
        // Create enriched conversation
        final enrichedData = Map<String, dynamic>.from(chatData);
        enrichedData['participant_names'] = participantNames;
        enrichedData['last_message_text'] = lastMessageText;
        enrichedData['last_message_time'] = lastMessageTime?.toIso8601String();
        enrichedData['last_message_sender_id'] = lastMessageSenderId;
        
        conversations.add(Conversation.fromChatsTable(enrichedData));
      }
      
      return conversations;
    } catch (e) {
      _logger.error('Failed to get conversations', e);
      return [];
    }
  }

  /// Get a single conversation by ID (with enriched participant names)
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .eq('id', conversationId)
          .maybeSingle();
      
      if (response == null) return null;
      
      // Get participant IDs
      final participantIds = (response['participant_ids'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [];
      
      // Fetch participant names from users table
      final participantNames = <String>[];
      for (final participantId in participantIds) {
        try {
          final userResponse = await _supabase
              .from('users')
              .select('display_name')
              .eq('id', participantId)
              .maybeSingle();
          if (userResponse != null && userResponse['display_name'] != null) {
            participantNames.add(userResponse['display_name']);
          } else {
            participantNames.add('User');
          }
        } catch (e) {
          participantNames.add('User');
        }
      }
      
      // Create enriched conversation data
      final enrichedData = Map<String, dynamic>.from(response);
      enrichedData['participant_names'] = participantNames;
      
      return Conversation.fromChatsTable(enrichedData);
    } catch (e) {
      _logger.error('Failed to get conversation', e);
      return null;
    }
  }

  /// Get or create a direct conversation between two users
  Future<Conversation?> getOrCreateDirectConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String otherUserName,
  }) async {
    try {
      // Check if conversation already exists by checking participant_ids contains both users
      final existingChats = await _supabase
          .from('chats')
          .select()
          .contains('participant_ids', [currentUserId, otherUserId]);
      
      // Filter to find exact 2-person chat
      final existing = (existingChats as List).cast<Map<String, dynamic>>().firstWhere(
        (chat) {
          final ids = (chat['participant_ids'] as List?)?.cast<String>() ?? [];
          return ids.length == 2 && 
                 ids.contains(currentUserId) && 
                 ids.contains(otherUserId);
        },
        orElse: () => <String, dynamic>{},
      );
      
      if (existing.isNotEmpty) {
        // Enrich with participant names
        final enrichedData = Map<String, dynamic>.from(existing);
        enrichedData['participant_names'] = [currentUserName, otherUserName];
        return Conversation.fromChatsTable(enrichedData);
      }

      // Create new chat
      final response = await _supabase
          .from('chats')
          .insert({
            'participant_ids': [currentUserId, otherUserId],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      _logger.info('Created chat: ${response['id']}');
      
      // Enrich with participant names
      final enrichedData = Map<String, dynamic>.from(response);
      enrichedData['participant_names'] = [currentUserName, otherUserName];
      return Conversation.fromChatsTable(enrichedData);
    } catch (e) {
      _logger.error('Failed to get/create conversation', e);
      return null;
    }
  }

  /// Get total unread count
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final conversations = await _getConversationsFuture(userId);
      final conversationIds = conversations.map((c) => c.id).toList();
      
      if (conversationIds.isEmpty) return 0;
      
      final response = await _supabase
          .from('messages')
          .select('id')
          .inFilter('chat_id', conversationIds)
          .neq('sender_id', userId)
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      _logger.error('Failed to get total unread count', e);
      return 0;
    }
  }

  // ==================== MESSAGES ====================

  /// Get messages for a conversation as Stream with Supabase Realtime
  Stream<List<Message>> getMessages(String conversationId) {
    final controller = StreamController<List<Message>>();
    List<Message> currentMessages = [];

    // Function to reload all messages
    Future<void> reloadMessages() async {
      try {
        final messages = await _getMessagesFuture(conversationId);
        currentMessages = messages;
        if (!controller.isClosed) {
          controller.add(currentMessages);
        }
      } catch (e) {
        _logger.error('Failed to reload messages', e);
      }
    }

    // Load initial messages
    reloadMessages();

    // Subscribe to realtime updates - ALL events
    final channel = _supabase
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Listen to INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: conversationId,
          ),
          callback: (payload) {
            _logger.info('Message change received: ${payload.eventType}');
            // Refetch all messages for reliability
            reloadMessages();
          },
        )
        .subscribe((status, error) {
          _logger.info('Messages channel status: $status');
          if (error != null) {
            _logger.error('Messages channel error', error);
          }
        });

    // Cleanup when stream is closed
    controller.onCancel = () {
      _logger.info('Unsubscribing from messages channel');
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Message>> _getMessagesFuture(String conversationId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', conversationId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((data) => Message.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.error('Failed to get messages', e);
      return [];
    }
  }

  /// Get single message
  Future<Message?> getMessage(String messageId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('id', messageId)
          .maybeSingle();
      
      if (response == null) return null;
      return Message.fromSupabase(response);
    } catch (e) {
      _logger.error('Failed to get message', e);
      return null;
    }
  }

  /// Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
    String? imageUrl,
  }) async {
    try {
      String actualConversationId = conversationId;
      
      // Handle "new_" prefix - create conversation first
      if (conversationId.startsWith('new_')) {
        final otherUserId = conversationId.replaceFirst('new_', '');
        _logger.info('Creating new conversation with user: $otherUserId');
        
        // Get other user's name
        String otherUserName = 'User';
        try {
          final userResponse = await _supabase
              .from('users')
              .select('display_name')
              .eq('id', otherUserId)
              .maybeSingle();
          if (userResponse != null && userResponse['display_name'] != null) {
            otherUserName = userResponse['display_name'];
          }
        } catch (e) {
          _logger.warning('Could not fetch other user name: $e');
        }
        
        // Create the conversation
        final newConversation = await getOrCreateDirectConversation(
          currentUserId: senderId,
          otherUserId: otherUserId,
          currentUserName: senderName,
          otherUserName: otherUserName,
        );
        
        if (newConversation == null) {
          throw Exception('Failed to create conversation');
        }
        
        actualConversationId = newConversation.id;
        _logger.info('Created conversation: $actualConversationId');
      }
      
      final response = await _supabase
          .from('messages')
          .insert({
            'chat_id': actualConversationId,
            'sender_id': senderId,
            'sender_name': senderName,
            'content': content,
            'created_at': DateTime.now().toUtc().toIso8601String(), // UTC with Z suffix for consistency
            'is_read': false,
          })
          .select()
          .single();
      
      // Update chat's updated_at
      await _supabase
          .from('chats')
          .update({
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', actualConversationId);
      
      _logger.info('Sent message to chat: $actualConversationId');
      return Message.fromSupabase(response);
    } catch (e) {
      _logger.error('Failed to send message', e);
      rethrow;
    }
  }

  // ==================== TYPING INDICATOR ====================

  /// Get typing users - simplified implementation
  /// Note: Full Presence API implementation requires version-specific handling
  Stream<List<String>> getTypingUsers(String conversationId, String currentUserId) {
    // Return empty stream for now - typing indicators work via setTypingIndicator
    // which broadcasts, but receiving requires matching Supabase Presence version
    return Stream.value(<String>[]);
  }

  // ==================== USER PRESENCE ====================

  /// Update user's last_seen timestamp (call this periodically)
  Future<void> updateLastSeen(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'last_seen': DateTime.now().toUtc().toIso8601String()})
          .eq('id', userId);
      _logger.info('Updated last_seen for user: $userId');
    } catch (e) {
      _logger.error('Failed to update last_seen', e);
    }
  }

  /// Check if user is online (last_seen within 2 minutes)
  Future<bool> isUserOnline(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('last_seen')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null || response['last_seen'] == null) return false;
      
      final lastSeen = DateTime.parse(response['last_seen']);
      final difference = DateTime.now().toUtc().difference(lastSeen);
      
      return difference.inMinutes < 2;
    } catch (e) {
      _logger.error('Failed to check online status', e);
      return false;
    }
  }

  /// Get last seen timestamp for a user
  Future<DateTime?> getLastSeen(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('last_seen')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null || response['last_seen'] == null) return null;
      return DateTime.parse(response['last_seen']);
    } catch (e) {
      _logger.error('Failed to get last seen', e);
      return null;
    }
  }

  /// Format last seen for display (like WhatsApp)
  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    
    if (diff.inMinutes < 1) return 'Baru saja aktif';
    if (diff.inMinutes < 60) return 'Aktif ${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return 'Aktif ${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Aktif kemarin';
    if (diff.inDays < 7) return 'Aktif ${diff.inDays} hari lalu';
    return 'Aktif lebih dari seminggu lalu';
  }

  /// Get multiple users online status
  Future<Map<String, bool>> getUsersOnlineStatus(List<String> userIds) async {
    final result = <String, bool>{};
    for (final userId in userIds) {
      result[userId] = await isUserOnline(userId);
    }
    return result;
  }

  // ==================== MARK AS READ ====================

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('id', messageId);
    } catch (e) {
      _logger.error('Failed to mark message as read', e);
    }
  }

  /// Mark all messages in conversation as read
  Future<void> markAllAsRead(String conversationId, String readerId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', conversationId)
          .neq('sender_id', readerId)
          .eq('is_read', false);
      
      _logger.info('Marked all messages as read in: $conversationId');
    } catch (e) {
      _logger.error('Failed to mark all as read', e);
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('id', messageId);
      
      _logger.info('Deleted message: $messageId');
    } catch (e) {
      _logger.error('Failed to delete message', e);
    }
  }

  // ==================== ADDITIONAL METHODS FOR CHAT SCREEN ====================

  /// Mark multiple messages as read
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
    required List<String> messageIds,
  }) async {
    try {
      for (final messageId in messageIds) {
        await markMessageAsRead(messageId);
      }
      _logger.info('Marked ${messageIds.length} messages as read');
    } catch (e) {
      _logger.error('Failed to mark messages as read', e);
    }
  }

  /// Set typing indicator using Supabase Presence
  Future<void> setTypingIndicator({
    required String conversationId,
    required String userId,
    required String userName,
    required bool isTyping,
  }) async {
    try {
      final channelName = 'typing:$conversationId';
      
      // Get or create channel
      RealtimeChannel channel;
      if (_typingChannels.containsKey(conversationId)) {
        channel = _typingChannels[conversationId]!;
      } else {
        channel = _supabase.channel(channelName);
        _typingChannels[conversationId] = channel;
        await channel.subscribe();
      }
      
      // Track presence with typing state
      await channel.track({
        'user_id': userId,
        'user_name': userName,
        'is_typing': isTyping,
        'online_at': DateTime.now().toIso8601String(),
      });
      
      _logger.info('Typing indicator: $userName isTyping=$isTyping');
    } catch (e) {
      _logger.error('Failed to set typing indicator', e);
    }
  }

  /// Send image message with upload to storage
  Future<Message?> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderRole,
    String? senderAvatarUrl,
    required String imagePath,
    Uint8List? imageBytes,
  }) async {
    try {
      String imageUrl = imagePath;
      
      // If bytes provided, upload to storage
      if (imageBytes != null) {
        final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storagePath = '$senderId/$fileName';
        
        await _supabase.storage
            .from(SupabaseConfig.chatImagesBucket)
            .uploadBinary(storagePath, imageBytes);
        
        imageUrl = _supabase.storage
            .from(SupabaseConfig.chatImagesBucket)
            .getPublicUrl(storagePath);
        
        _logger.info('Uploaded chat image: $imageUrl');
      }
      
      // Insert message with image_url
      final response = await _supabase
          .from('messages')
          .insert({
            'chat_id': conversationId,
            'sender_id': senderId,
            'sender_name': senderName,
            'content': '[Image]',
            'image_url': imageUrl,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': false,
          })
          .select()
          .single();
      
      // Update chat's updated_at
      await _supabase
          .from('chats')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);
      
      _logger.info('Sent image message to chat: $conversationId');
      return Message.fromSupabase(response);
    } catch (e) {
      _logger.error('Failed to send image message', e);
      return null;
    }
  }

  /// Send file message (stub)
  Future<Message?> sendFileMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderRole,
    String? senderAvatarUrl,
    required String filePath,
    required String fileName,
  }) async {
    try {
      return await sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: '[File: $fileName]',
        type: 'file',
      );
    } catch (e) {
      _logger.error('Failed to send file message', e);
      return null;
    }
  }

  /// Delete message with named parameters (overload)
  Future<void> deleteMessageWithParams({
    required String messageId,
    required String userId,
  }) async {
    await deleteMessage(messageId);
  }

  /// Edit message
  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'content': newContent,
          })
          .eq('id', messageId);
      
      _logger.info('Edited message: $messageId');
    } catch (e) {
      _logger.error('Failed to edit message', e);
    }
  }

  // ==================== CONVERSATION ACTIONS ====================

  /// Archive a conversation
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _supabase
          .from('chats')
          .update({'is_archived': true})
          .eq('id', conversationId);
      
      _logger.info('Archived conversation: $conversationId');
    } catch (e) {
      _logger.error('Failed to archive conversation', e);
      rethrow;
    }
  }

  /// Unarchive a conversation
  Future<void> unarchiveConversation(String conversationId) async {
    try {
      await _supabase
          .from('chats')
          .update({'is_archived': false})
          .eq('id', conversationId);
      
      _logger.info('Unarchived conversation: $conversationId');
    } catch (e) {
      _logger.error('Failed to unarchive conversation', e);
      rethrow;
    }
  }

  /// Delete a conversation (and optionally its messages)
  Future<void> deleteConversation(String conversationId, {bool deleteMessages = true}) async {
    try {
      if (deleteMessages) {
        // Delete all messages first
        await _supabase
            .from('messages')
            .delete()
            .eq('chat_id', conversationId);
        
        _logger.info('Deleted all messages in conversation: $conversationId');
      }
      
      // Delete the chat
      await _supabase
          .from('chats')
          .delete()
          .eq('id', conversationId);
      
      _logger.info('Delete command sent for conversation: $conversationId');
      
      // Verify deletion actually happened
      final verifyResponse = await _supabase
          .from('chats')
          .select('id')
          .eq('id', conversationId)
          .maybeSingle();
      
      if (verifyResponse != null) {
        _logger.warning('VERIFICATION FAILED: Chat $conversationId still exists after delete! This may be an RLS issue.');
        throw Exception('Failed to delete chat - RLS may be blocking. Please check Supabase RLS policies for "chats" table.');
      } else {
        _logger.info('Verified: Conversation $conversationId successfully deleted');
      }
    } catch (e) {
      _logger.error('Failed to delete conversation', e);
      rethrow;
    }
  }

  /// Clear all messages in a conversation (without deleting the chat itself)
  Future<void> clearConversation(String conversationId) async {
    try {
      await _supabase
          .from('messages')
          .delete()
          .eq('chat_id', conversationId);
      
      _logger.info('Cleared conversation: $conversationId');
    } catch (e) {
      _logger.error('Failed to clear conversation', e);
      rethrow;
    }
  }

  /// Delete multiple messages at once
  Future<void> deleteMessages(List<String> messageIds) async {
    try {
      for (final id in messageIds) {
        await _supabase
            .from('messages')
            .delete()
            .eq('id', id);
      }
      
      _logger.info('Deleted ${messageIds.length} messages');
    } catch (e) {
      _logger.error('Failed to delete messages', e);
      rethrow;
    }
  }

  /// Forward messages to another conversation
  Future<void> forwardMessages({
    required List<String> messageIds,
    required String targetConversationId,
    required String senderId,
    required String senderName,
  }) async {
    try {
      for (final id in messageIds) {
        final originalMessage = await getMessage(id);
        if (originalMessage != null) {
          await sendMessage(
            conversationId: targetConversationId,
            senderId: senderId,
            senderName: senderName,
            content: originalMessage.content,
          );
        }
      }
      
      _logger.info('Forwarded ${messageIds.length} messages to $targetConversationId');
    } catch (e) {
      _logger.error('Failed to forward messages', e);
      rethrow;
    }
  }
}

/// Provider for ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

