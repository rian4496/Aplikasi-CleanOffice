import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import '../models/message.dart';
import '../models/conversation.dart';

/// Service for chat/messaging functionality using Supabase.
/// Updated to use 'chats' table with participant_ids array schema.
class ChatService {
  final SupabaseClient _supabase;
  final _logger = AppLogger('ChatService');
  
  ChatService([SupabaseClient? supabase]) 
      : _supabase = supabase ?? Supabase.instance.client;

  // ==================== CONVERSATIONS (using 'chats' table) ====================

  /// Get all conversations for a user as Stream
  Stream<List<Conversation>> getConversations(String userId) {
    return Stream.fromFuture(_getConversationsFuture(userId));
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
              participantNames.add('Unknown');
            }
          } catch (e) {
            _logger.error('Failed to fetch user $participantId', e);
            participantNames.add('Unknown');
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
            participantNames.add('Unknown');
          }
        } catch (e) {
          participantNames.add('Unknown');
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
        return Conversation.fromChatsTable(existing);
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
      return Conversation.fromChatsTable(response);
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

    // Load initial messages
    _getMessagesFuture(conversationId).then((messages) {
      currentMessages = messages;
      if (!controller.isClosed) {
        controller.add(currentMessages);
      }
    }).catchError((e) {
      _logger.error('Failed to load initial messages', e);
      if (!controller.isClosed) {
        controller.add([]);
      }
    });

    // Subscribe to realtime updates
    final channel = _supabase
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: conversationId,
          ),
          callback: (payload) {
            _logger.info('New message received: ${payload.newRecord}');
            final newMessage = Message.fromSupabase(payload.newRecord);
            currentMessages = [newMessage, ...currentMessages];
            if (!controller.isClosed) {
              controller.add(currentMessages);
            }
          },
        )
        .subscribe();

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
      final response = await _supabase
          .from('messages')
          .insert({
            'chat_id': conversationId,
            'sender_id': senderId,
            'sender_name': senderName,
            'content': content,
            'created_at': DateTime.now().toIso8601String(),
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
          .eq('id', conversationId);
      
      _logger.info('Sent message to chat: $conversationId');
      return Message.fromSupabase(response);
    } catch (e) {
      _logger.error('Failed to send message', e);
      rethrow;
    }
  }

  // ==================== TYPING INDICATOR ====================

  /// Get typing users (stub - not implemented)
  Stream<List<String>> getTypingUsers(String conversationId, String currentUserId) {
    // Typing indicators require realtime presence - stub for now
    return Stream.value([]);
  }

  // ==================== USER PRESENCE ====================

  /// Check if user is online (stub)
  Future<bool> isUserOnline(String userId) async {
    // User presence requires realtime presence - stub for now
    return false;
  }

  /// Get multiple users online status (stub)
  Future<Map<String, bool>> getUsersOnlineStatus(List<String> userIds) async {
    // Stub - all users offline
    return {for (var id in userIds) id: false};
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

  /// Set typing indicator (stub - requires realtime presence)
  Future<void> setTypingIndicator({
    required String conversationId,
    required String userId,
    required String userName,
    required bool isTyping,
  }) async {
    // Stub - typing indicators require realtime presence
    _logger.info('Typing indicator stub: $userName isTyping=$isTyping');
  }

  /// Send image message (stub)
  Future<Message?> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderRole,
    String? senderAvatarUrl,
    required String imagePath,
  }) async {
    // For now, send as text message with image URL
    try {
      return await sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: '[Image]',
        type: 'image',
        imageUrl: imagePath,
      );
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
}

/// Provider for ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});
