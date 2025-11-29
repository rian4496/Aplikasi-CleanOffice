// lib/providers/riverpod/chat_providers.dart
// Riverpod providers for chat feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/conversation.dart';
import '../../models/message.dart';
import '../../services/chat_service.dart';

// ==================== SERVICE PROVIDER ====================

/// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// ==================== CONVERSATIONS PROVIDERS ====================

/// Stream of conversations for current user
final conversationsStreamProvider = StreamProvider.family<List<Conversation>, String>(
  (ref, userId) {
    final chatService = ref.watch(chatServiceProvider);
    return chatService.getConversations(userId);
  },
);

/// Get single conversation by ID
final conversationProvider = FutureProvider.family<Conversation?, String>(
  (ref, conversationId) async {
    final chatService = ref.watch(chatServiceProvider);
    return await chatService.getConversation(conversationId);
  },
);

/// Total unread count for current user
final totalUnreadCountProvider = FutureProvider.family<int, String>(
  (ref, userId) async {
    final chatService = ref.watch(chatServiceProvider);
    return await chatService.getTotalUnreadCount(userId);
  },
);

// ==================== MESSAGES PROVIDERS ====================

/// Stream of messages for a specific conversation
final messagesStreamProvider = StreamProvider.family<List<Message>, String>(
  (ref, conversationId) {
    final chatService = ref.watch(chatServiceProvider);
    return chatService.getMessages(conversationId);
  },
);

/// Get single message by ID
final messageProvider = FutureProvider.family<Message?, String>(
  (ref, messageId) async {
    final chatService = ref.watch(chatServiceProvider);
    return await chatService.getMessage(messageId);
  },
);

// ==================== TYPING INDICATOR PROVIDERS ====================

/// Typing indicator parameters
class TypingIndicatorParams {
  final String conversationId;
  final String currentUserId;

  const TypingIndicatorParams({
    required this.conversationId,
    required this.currentUserId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypingIndicatorParams &&
          conversationId == other.conversationId &&
          currentUserId == other.currentUserId;

  @override
  int get hashCode => conversationId.hashCode ^ currentUserId.hashCode;
}

/// Stream of typing users in conversation (excluding current user)
final typingUsersStreamProvider = StreamProvider.family<List<String>, TypingIndicatorParams>(
  (ref, params) {
    final chatService = ref.watch(chatServiceProvider);
    return chatService.getTypingUsers(
      params.conversationId,
      params.currentUserId,
    );
  },
);

// ==================== USER PRESENCE PROVIDERS ====================

/// Check if user is online
final userOnlineStatusProvider = FutureProvider.family<bool, String>(
  (ref, userId) async {
    final chatService = ref.watch(chatServiceProvider);
    return await chatService.isUserOnline(userId);
  },
);

/// Check multiple users online status
final usersOnlineStatusProvider = FutureProvider.family<Map<String, bool>, List<String>>(
  (ref, userIds) async {
    final chatService = ref.watch(chatServiceProvider);
    return await chatService.getUsersOnlineStatus(userIds);
  },
);
