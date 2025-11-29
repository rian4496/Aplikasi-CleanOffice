// lib/screens/chat/conversation_list_screen.dart
// Screen untuk menampilkan daftar conversations (chat list)

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';
import '../../core/logging/app_logger.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/conversation.dart';
import '../../models/user_profile.dart';
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/chat_providers.dart';
import '../../services/appwrite_database_service.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import 'chat_room_screen.dart';

final _logger = AppLogger('ConversationListScreen');

/// Conversation List Screen - Daftar semua conversations
class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProfileProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Total unread badge
          currentUser.when(
            data: (user) {
              if (user == null) return const SizedBox.shrink();

              final totalUnreadAsync = ref.watch(totalUnreadCountProvider(user.uid));
              return totalUnreadAsync.when(
                data: (count) {
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: AdminTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Hamburger Menu Icon to open endDrawer
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              tooltip: 'Menu',
            ),
        ],
      ),
      endDrawer: isDesktop
          ? null
          : Drawer(
              child: DrawerMenuWidget(
                userProfile: currentUser.asData?.value,
                roleTitle: 'Pengguna',
                menuItems: [
                  DrawerMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profil',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
                onLogout: () async {
                  await ref.read(authActionsProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
            ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Silakan login terlebih dahulu'),
            );
          }

          final conversationsAsync = ref.watch(conversationsStreamProvider(user.uid));

          return conversationsAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
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
                        'Belum ada percakapan',
                        style: AdminTypography.body1.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Filter conversations by search query
              final filteredConversations = _searchQuery.isEmpty
                  ? conversations
                  : conversations.where((conv) {
                      final query = _searchQuery.toLowerCase();
                      final displayName = conv.getDisplayName(user.uid).toLowerCase();
                      final lastMessage = conv.lastMessageText?.toLowerCase() ?? '';
                      return displayName.contains(query) || lastMessage.contains(query);
                    }).toList();

              return Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari percakapan...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Conversations list
                  Expanded(
                    child: filteredConversations.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada hasil pencarian',
                              style: AdminTypography.body1.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredConversations.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final conversation = filteredConversations[index];
                              return _ConversationListItem(
                                conversation: conversation,
                                currentUserId: user.uid,
                                onTap: () {
                                  _logger.info('Opening conversation: ${conversation.id}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        conversationId: conversation.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) {
              _logger.error('Error loading conversations', error);
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
                      'Gagal memuat percakapan',
                      style: AdminTypography.body1,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(conversationsStreamProvider);
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            },
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
      bottomNavigationBar: !isDesktop ? _buildBottomNavBar(context) : null,
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () => _showNewChatDialog(context, currentUser.asData?.value),
              backgroundColor: AppTheme.primary,
              tooltip: 'Obrolan Baru',
              child: const Icon(Icons.message, color: Colors.white),
            )
          : null,
    );
  }

  /// Build Bottom Navigation Bar
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: false,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeAdminRoute,
                  (route) => false,
                ),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.assessment_rounded,
                label: 'Laporan',
                isActive: false,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/reports_management',
                  (route) => false,
                ),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.chat_rounded,
                label: 'Chat',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                context: context,
                icon: Icons.more_horiz_rounded,
                label: 'Lainnya',
                isActive: false,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AdminMoreBottomSheet(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Navigation Item
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primary : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primary : Colors.grey[600],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to select user for new chat
  void _showNewChatDialog(BuildContext context, dynamic currentUser) {
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => _NewChatDialog(currentUserId: currentUser.uid),
    );
  }
}

/// Dialog for selecting user to start new chat
class _NewChatDialog extends HookConsumerWidget {
  final String currentUserId;

  const _NewChatDialog({required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.message, color: AppTheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Obrolan Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search box
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User list
            Expanded(
              child: FutureBuilder<List<UserProfile>>(
                future: AppwriteDatabaseService().getAllUserProfiles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat pengguna',
                        style: AdminTypography.body1.copyWith(color: Colors.grey[600]),
                      ),
                    );
                  }

                  final users = snapshot.data ?? [];

                  // Filter out current user and apply search
                  final filteredUsers = users
                      .where((user) => user.uid != currentUserId)
                      .where((user) {
                        if (searchQuery.value.isEmpty) return true;
                        final query = searchQuery.value.toLowerCase();
                        return user.displayName.toLowerCase().contains(query) ||
                            user.role.toLowerCase().contains(query);
                      })
                      .toList();

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada pengguna',
                        style: AdminTypography.body1.copyWith(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.displayName,
                          style: AdminTypography.body1,
                        ),
                        subtitle: Text(
                          user.role,
                          style: AdminTypography.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        onTap: () => _startConversation(context, ref, user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Start conversation with selected user
  Future<void> _startConversation(
    BuildContext context,
    WidgetRef ref,
    UserProfile otherUser,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final currentUser = ref.read(currentUserProfileProvider).value;
      if (currentUser == null) {
        Navigator.pop(context);
        return;
      }

      // Get or create conversation
      final chatService = ref.read(chatServiceProvider);
      final conversation = await chatService.getOrCreateDirectConversation(
        currentUserId: currentUser.uid,
        otherUserId: otherUser.uid,
        currentUser: currentUser,
        otherUser: otherUser,
      );

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (conversation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat obrolan'),
            backgroundColor: AdminColors.error,
          ),
        );
        return;
      }

      // Close user selection dialog
      Navigator.pop(context);

      // Navigate to chat room
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            conversationId: conversation.id,
          ),
        ),
      );
    } catch (e) {
      _logger.error('Error starting conversation', e);

      if (!context.mounted) return;

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AdminColors.error,
        ),
      );
    }
  }
}

/// Conversation List Item Widget
class _ConversationListItem extends HookConsumerWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationListItem({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    // Get other user ID for direct conversations
    final otherUserId = conversation.type == ConversationType.direct
        ? conversation.participantIds.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          )
        : null;

    // Watch online status for direct conversations
    final onlineStatusAsync = otherUserId != null
        ? ref.watch(userOnlineStatusProvider(otherUserId))
        : const AsyncValue<bool>.data(false);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online status indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
                  child: conversation.type == ConversationType.group
                      ? const Icon(
                          Icons.group,
                          size: 28,
                          color: AdminColors.primary,
                        )
                      : Text(
                          conversation.getDisplayName(currentUserId)[0].toUpperCase(),
                          style: AdminTypography.h3.copyWith(
                            color: AdminColors.primary,
                          ),
                        ),
                ),
                // Online status indicator (only for direct conversations)
                if (conversation.type == ConversationType.direct)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: onlineStatusAsync.when(
                      data: (isOnline) => Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isOnline ? AdminColors.success : Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (error, _) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          conversation.getDisplayName(currentUserId),
                          style: hasUnread
                              ? AdminTypography.body1.copyWith(fontWeight: FontWeight.bold)
                              : AdminTypography.body1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Timestamp
                      Text(
                        conversation.getFormattedLastMessageTime(),
                        style: AdminTypography.caption.copyWith(
                          color: hasUnread ? AdminColors.primary : Colors.grey[600],
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      // Last message preview
                      Expanded(
                        child: Text(
                          conversation.getLastMessagePreview(),
                          style: AdminTypography.body2.copyWith(
                            color: hasUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread badge
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AdminColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: AdminTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Context badge (if linked to report/request)
                  if (conversation.hasContext) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AdminColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AdminColors.info.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        conversation.getContextDisplay() ?? '',
                        style: AdminTypography.caption.copyWith(
                          color: AdminColors.info,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
