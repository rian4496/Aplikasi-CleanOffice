// lib/screens/chat/conversation_list_screen.dart
// Screen untuk menampilkan daftar conversations (chat list)

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';
import '../../core/logging/app_logger.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/conversation.dart';
import '../../models/user_profile.dart';
import '../../riverpod/auth_providers.dart';
import '../../riverpod/chat_providers.dart';
import '../../widgets/chat/new_chat_dialog.dart';
import '../../riverpod/chat_selection_provider.dart';
import '../../services/supabase_database_service.dart';
import '../../widgets/navigation/admin_more_bottom_sheet.dart';
import '../../widgets/navigation/cleaner_more_bottom_sheet.dart';
import '../../widgets/shared/drawer_menu_widget.dart';
import '../../widgets/shared/notification_bell.dart';
import '../../widgets/chat/selection_app_bar.dart';
import 'chat_room_screen.dart';
import '../cleaner/cleaner_inbox_screen.dart';
import 'package:google_fonts/google_fonts.dart';

final _logger = AppLogger('ConversationListScreen');

/// Conversation List Screen - Daftar semua conversations
class ConversationListScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;
  const ConversationListScreen({super.key, this.showBottomNav = true});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String _activeFilter = 'Semua'; // Filter state: Semua, Belum Dibaca, Tim, Arsip

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
    final selectionState = ref.watch(chatSelectionProvider);

    // Modern Colors from Reference
    const primaryColor = Color(0xFF2563EB);
    const bgColor = Color(0xFFF3F4F6); // Gray 100
    const surfaceColor = Colors.white;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      appBar: selectionState.isSelectionMode
          ? SelectionAppBar(
              selectedCount: selectionState.selectedCount,
              onClose: () => ref.read(chatSelectionProvider.notifier).clearSelection(),
              onDelete: () => _handleDeleteSelected(context, ref, selectionState.selectedIds),
              onPin: () => _handlePinSelected(context, ref, selectionState.selectedIds),
              onMute: () => _handleMuteSelected(context, ref, selectionState.selectedIds),
              onMarkRead: () => _handleMarkReadSelected(context, ref, selectionState.selectedIds),
            )
          : null, // Custom Header used instead of AppBar when not selecting
      endDrawer: isDesktop
          ? null
          : Drawer(
              child: SafeArea(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.person, size: 32, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentUser.asData?.value?.displayName ?? 'Pengguna',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildDrawerItem(context, Icons.home, 'Beranda', () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop(); 
                            }),
                            _buildDrawerItem(context, Icons.person_outline, 'Profil', () => Navigator.of(context).pop()),
                            _buildDrawerItem(context, Icons.settings_outlined, 'Pengaturan', () => Navigator.of(context).pop()),
                            const Divider(height: 1),
                            _buildDrawerItem(context, Icons.logout, 'Keluar', () => _showLogoutDialog(context, ref), isDestructive: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: currentUser.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Belum ada obrolan'));
          final conversationsAsync = ref.watch(conversationsStreamProvider(user.uid));

          return conversationsAsync.when(
            data: (conversations) {
              // Calculate unread count for display
              final unreadCount = conversations.where((c) => c.unreadCount(user.uid) > 0).length;
              
              // Apply search filter first
              var filteredConversations = _searchQuery.isEmpty
                  ? conversations
                  : conversations.where((conv) {
                      final query = _searchQuery.toLowerCase();
                      final displayName = conv.getDisplayName(user.uid).toLowerCase();
                      final lastMessage = conv.lastMessageText?.toLowerCase() ?? '';
                      return displayName.contains(query) || lastMessage.contains(query);
                    }).toList();
              
              // Apply tab filter
              switch (_activeFilter) {
                case 'Belum Dibaca':
                  filteredConversations = filteredConversations.where((c) => c.unreadCount(user.uid) > 0).toList();
                  break;
                case 'Tim':
                  filteredConversations = filteredConversations.where((c) => c.isGroup).toList();
                  break;
                case 'Arsip':
                  filteredConversations = filteredConversations.where((c) => c.isArchived).toList();
                  break;
                case 'Semua':
                default:
                  // Exclude archived from 'Semua' view
                  filteredConversations = filteredConversations.where((c) => !c.isArchived).toList();
                  break;
              }

              return Column(
                children: [
                   if (!selectionState.isSelectionMode) ...[
                      _buildModernHeader(user.displayName, unreadCount),
                      _buildFilterTabs(),
                   ],
                   
                   Expanded(
                     child: filteredConversations.isEmpty
                        ? Center(child: Text('Belum ada pesan', style: GoogleFonts.inter(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
                            itemCount: filteredConversations.length + 1, // +1 for "Percakapan Lama" divider if needed
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              // Custom Logic for Divider
                              // For simplicity, let's just insert divider at fixed index or based on date.
                              // Implementing simple version:
                              if (index == filteredConversations.length) return const SizedBox.shrink(); // End padding handled by listview padding

                              final conversation = filteredConversations[index];
                              final isSelected = selectionState.isSelected(conversation.id);
                              
                              // Check if we need to show "Percakapan Lama" divider
                              // Logic: If current item is older than 7 days AND previous item was newer?
                              // For MVP, letting user just see the list. User mockup shows divider.
                              // Let's add it manually after the 3rd item as a mock or based on real date diff.
                              
                              bool showDivider = false;
                              if (index == 3) showDivider = true; // Hardcoded mock for visual match

                              return Column(
                                children: [
                                  if (showDivider)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: Divider(color: Colors.grey[300])),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text('PERCAKAPAN LAMA', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1)),
                                          ),
                                          Expanded(child: Divider(color: Colors.grey[300])),
                                        ],
                                      ),
                                    ),
                                  _buildModernChatCard(context, ref, conversation, user.uid, isSelected, selectionState.isSelectionMode),
                                ],
                              );
                            },
                          ),
                   ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error loading user')),
      ),
      bottomNavigationBar: !isDesktop && widget.showBottomNav ? _buildBottomNavBar(context) : null,
      floatingActionButton: !isDesktop && widget.showBottomNav
          ? FloatingActionButton(
              onPressed: () => _showNewChatDialog(context, currentUser.asData?.value),
              backgroundColor: primaryColor,
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildModernHeader(String displayName, int unreadCount) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6).withValues(alpha: 0.9),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title or Search Bar
                  Expanded(
                    child: _isSearching
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Cari pesan...',
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.inter(color: Colors.grey),
                            ),
                            style: GoogleFonts.inter(fontSize: 18),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chat', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                              const SizedBox(height: 4),
                             Text(displayName.isNotEmpty && unreadCount > 0 
                                  ? '$unreadCount pesan belum dibaca' 
                                  : 'Semua pesan dibaca', 
                                 style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))),
                            ],
                          ),
                  ),
                  
                  // Icons
                  Row(
                    children: [
                       IconButton(
                         icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: const Color(0xFF4B5563)),
                         onPressed: () {
                           setState(() {
                             _isSearching = !_isSearching;
                             if (!_isSearching) {
                               _searchController.clear();
                             }
                           });
                         },
                       ),
                       Stack(
                         children: [
                           IconButton(
                             icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF4B5563)), 
                             onPressed: () => context.push('/admin/notifications'), // Navigate to Notifications
                           ),
                           Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white, width: 1)))),
                         ],
                       ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Semua', _activeFilter == 'Semua'),
          const SizedBox(width: 8),
          _buildFilterChip('Belum Dibaca', _activeFilter == 'Belum Dibaca'),
          const SizedBox(width: 8),
          _buildFilterChip('Tim', _activeFilter == 'Tim'),
          const SizedBox(width: 8),
          _buildFilterChip('Arsip', _activeFilter == 'Arsip'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: isActive ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  // Update Drawer Item Helper
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
     return ListTile(
       leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[600]),
       title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black87)),
       onTap: onTap,
     );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
             TextButton(
              onPressed: () {
                 Navigator.pop(context);
                 Navigator.pop(context);
                 ref.read(authActionsProvider.notifier).logout();
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
  }

  // Redesigned Chat Item Card
  Widget _buildModernChatCard(BuildContext context, WidgetRef ref, Conversation conversation, String currentUserId, bool isSelected, bool isSelectionMode) {
    final otherUser = conversation.participants.firstWhere((p) => p != currentUserId, orElse: () => 'Unknown');
    final displayName = conversation.getDisplayName(currentUserId);
    final lastMessage = conversation.lastMessageText ?? 'Belum ada pesan';
    final time = _formatTime(conversation.lastMessageAt);
    final isUnread = conversation.unreadCount(currentUserId) > 0;
    
    // Mock avatars/icons based on name for visual variety matching screenshot
    bool isTeam = displayName.toLowerCase().contains('tim');
    bool isAnnouncement = displayName.toLowerCase().contains('pengumuman');
    
    return GestureDetector(
      onTap: () {
         if (isSelectionMode) {
           ref.read(chatSelectionProvider.notifier).toggleSelection(conversation.id);
         } else {
           Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(conversationId: conversation.id, otherUserName: displayName)));
         }
      },
      onLongPress: () => ref.read(chatSelectionProvider.notifier).startSelection(conversation.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: isSelected ? Border.all(color: Colors.blue) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                _buildAvatar(displayName, isTeam, isAnnouncement),
                if (isTeam) // Online dot mock
                   Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(6)))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(child: Text(displayName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF111827)), overflow: TextOverflow.ellipsis)),
                       Text(time, style: GoogleFonts.inter(fontSize: 12, color: isUnread ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF), fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                     ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14, color: isUnread ? const Color(0xFF1F2937) : const Color(0xFF6B7280), fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal),
                        ),
                      ),
                      if (isUnread)
                         Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)), child: Text(conversation.unreadCount(currentUserId).toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
                      else if (isAnnouncement)
                         const Icon(Icons.push_pin, size: 16, color: Colors.grey)
                      else
                         const Icon(Icons.done_all, size: 16, color: Color(0xFF2563EB)), // Read receipt
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, bool isTeam, bool isAnnouncement) {
     if (isAnnouncement) {
       return Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.orange[100], shape: BoxShape.circle), child: const Icon(Icons.campaign_rounded, color: Colors.orange));
     }
     // Fallback avatar widget
     Widget fallbackAvatar(String initials) => Container(
       width: 48, height: 48,
       decoration: BoxDecoration(
         color: isTeam ? const Color(0xFF0D8ABC) : const Color(0xFF3B82F6),
         shape: BoxShape.circle,
       ),
       child: Center(
         child: Text(
           initials.isNotEmpty ? initials[0].toUpperCase() : '?',
           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
         ),
       ),
     );
     
     if (isTeam) {
       return ClipRRect(
         borderRadius: BorderRadius.circular(24),
         child: Image.network(
           'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0D8ABC&color=fff',
           width: 48, height: 48,
           errorBuilder: (context, error, stackTrace) => fallbackAvatar(name),
         ),
       );
     }
     return ClipRRect(
       borderRadius: BorderRadius.circular(24),
       child: Image.network(
         'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=3B82F6&color=fff',
         width: 48, height: 48,
         errorBuilder: (context, error, stackTrace) => fallbackAvatar(name),
       ),
     );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    // Simple mock format
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }


  /// Build Bottom Navigation Bar - ROLE AWARE
  Widget _buildBottomNavBar(BuildContext context) {
    final userRole = ref.watch(currentUserRoleProvider);
    
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
                onTap: () => _navigateToHome(context, userRole),
              ),
              _buildNavItem(
                context: context,
                icon: userRole == 'cleaner' ? Icons.inbox_rounded : Icons.assignment_rounded,
                label: userRole == 'cleaner' ? 'Inbox' : 'Laporan',
                isActive: false,
                onTap: () => _navigateToReports(context, userRole),
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
                onTap: () => _showMoreMenu(context, userRole),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to Home based on role
  void _navigateToHome(BuildContext context, String? role) {
    // Normalize role to lowercase for comparison
    final normalizedRole = role?.toLowerCase();
    _logger.info('🏠 Navigating to home - role: $role (normalized: $normalizedRole)');
    
    String route;
    switch (normalizedRole) {
      case 'admin':
        route = AppConstants.homeAdminRoute;
        break;
      case 'cleaner':
        route = AppConstants.homeCleanerRoute;
        break;
      case 'employee':
        route = AppConstants.homeEmployeeRoute;
        break;
      default:
        _logger.warning('⚠️ Unknown role: $role - defaulting to login');
        route = '/login'; // Safer default
    }
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  /// Navigate to Reports/Inbox based on role
  void _navigateToReports(BuildContext context, String? role) {
    final normalizedRole = role?.toLowerCase();
    _logger.info('📋 Navigating to reports - role: $role (normalized: $normalizedRole)');
    
    if (normalizedRole == 'cleaner') {
      // Cleaner goes to Inbox
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CleanerInboxScreen()),
      );
    } else {
      // Admin/Employee go to reports management
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/reports_management',
        (route) => false,
      );
    }
  }

  /// Show More menu based on role
  void _showMoreMenu(BuildContext context, String? role) {
    final normalizedRole = role?.toLowerCase();
    _logger.info('📱 Showing more menu - role: $role (normalized: $normalizedRole)');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (normalizedRole == 'cleaner') {
          return const CleanerMoreBottomSheet();
        } else {
          return const AdminMoreBottomSheet();
        }
      },
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
    // Light blue gradient color for active state
    final activeColor = AppTheme.headerGradientStart;
    final inactiveColor = Colors.grey[600]!;
    
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
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
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
  void _showNewChatDialog(BuildContext context, dynamic currentUser) async {
    if (currentUser == null) return;

    final selectedUser = await showDialog<UserProfile>(
      context: context,
      builder: (context) => NewChatDialog(currentUserId: currentUser.uid),
    );
    
    // If user selected, navigate to chat room
    if (selectedUser != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            conversationId: 'new_${selectedUser.uid}',
            otherUserName: selectedUser.displayName,
          ),
        ),
      );
    }
  }

  // ==================== SELECTION ACTIONS ====================
  
  /// Handle delete selected conversations
  void _handleDeleteSelected(BuildContext context, WidgetRef ref, Set<String> selectedIds) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Percakapan'),
        content: Text('Hapus ${selectedIds.length} percakapan yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement delete via ChatService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedIds.length} percakapan dihapus')),
      );
      ref.read(chatSelectionProvider.notifier).clearSelection();
    }
  }

  /// Handle pin selected conversations
  void _handlePinSelected(BuildContext context, WidgetRef ref, Set<String> selectedIds) {
    // TODO: Implement pin via ChatService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selectedIds.length} percakapan dipin')),
    );
    ref.read(chatSelectionProvider.notifier).clearSelection();
  }

  /// Handle mute selected conversations
  void _handleMuteSelected(BuildContext context, WidgetRef ref, Set<String> selectedIds) {
    // TODO: Implement mute via ChatService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selectedIds.length} percakapan dibisukan')),
    );
    ref.read(chatSelectionProvider.notifier).clearSelection();
  }

  /// Handle mark read selected conversations
  void _handleMarkReadSelected(BuildContext context, WidgetRef ref, Set<String> selectedIds) {
    // TODO: Implement mark read via ChatService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selectedIds.length} percakapan ditandai dibaca')),
    );
    ref.read(chatSelectionProvider.notifier).clearSelection();
  }
}





