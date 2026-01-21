// lib/screens/chat/widgets/chat_list_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design/admin_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/conversation.dart';
import '../../../models/user_profile.dart'; // Import UserProfile
import '../../../riverpod/auth_providers.dart';
import '../../../riverpod/chat_providers.dart';
import '../../../widgets/chat/new_chat_dialog.dart';

class ChatListPanel extends HookConsumerWidget {
  final String? selectedConversationId;
  final Function(Conversation) onConversationSelected;
  final Function(String)? onConversationDeleted; // Callback when a conversation is deleted

  const ChatListPanel({
    super.key,
    required this.selectedConversationId,
    required this.onConversationSelected,
    this.onConversationDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final activeFilter = useState('Semua');

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header & Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50], // WA Style slight gray header
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    currentUser.when(
                      data: (user) => Row(
                        children: [
                          if (Navigator.of(context).canPop())
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(),
                                tooltip: 'Kembali',
                              ),
                            ),
                          // Avatar removed as requested
                          Text(
                            'Chat Support',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_comment_outlined, color: Color(0xFF54656F)),
                          onPressed: () {
                             final user = currentUser.asData?.value;
                             if (user != null) _showNewChatDialog(context, user);
                          },
                          tooltip: 'Chat Baru',
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Color(0xFF54656F)),
                          onSelected: (value) {
                            // Handle menu selection
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'new_group',
                              child: Text('Grup baru'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'select',
                              child: Text('Pilih obrolan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (val) => searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Cari atau mulai chat baru',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Tabs (Optional - simplified for WA feel)
          Container(
             height: 40, // Height for tabs
             margin: const EdgeInsets.symmetric(vertical: 8),
             child: ListView(
               scrollDirection: Axis.horizontal,
               padding: const EdgeInsets.symmetric(horizontal: 16),
               children: [
                 _buildTab('Semua', activeFilter),
                 _buildTab('Belum Dibaca', activeFilter),
                 _buildTab('Tim', activeFilter),
                 _buildTab('Arsip', activeFilter),
               ],
             ),
          ),

          // Conversation List
          Expanded(
            child: currentUser.when(
              data: (user) {
                if (user == null) return const Center(child: Text('Login required'));

                final conversationsAsync = ref.watch(conversationsStreamProvider(user.uid));

                return conversationsAsync.when(
                  data: (conversations) {
                    // Filter Logic
                    var filtered = conversations;
                    
                    // Search
                    if (searchQuery.value.isNotEmpty) {
                      final q = searchQuery.value.toLowerCase();
                      filtered = filtered.where((c) {
                        return c.getDisplayName(user.uid).toLowerCase().contains(q);
                      }).toList();
                    }

                    // Tabs
                    if (activeFilter.value == 'Belum Dibaca') {
                      filtered = filtered.where((c) => c.unreadCount(user.uid) > 0).toList();
                    } else if (activeFilter.value == 'Tim') {
                       filtered = filtered.where((c) => c.isGroup).toList();
                    } else if (activeFilter.value == 'Arsip') {
                       filtered = filtered.where((c) => c.isArchived).toList();
                    } else {
                       filtered = filtered.where((c) => !c.isArchived).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada percakapan',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final conversation = filtered[index];
                        final isSelected = conversation.id == selectedConversationId;
                        return _ConversationItem(
                          conversation: conversation, 
                          currentUserId: user.uid, 
                          isSelected: isSelected,
                          onTap: () => onConversationSelected(conversation),
                          onDeleted: onConversationDeleted,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, ValueNotifier<String> activeFilter) {
    final isActive = activeFilter.value == label;
    return GestureDetector(
      onTap: () => activeFilter.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE7F3FF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? const Color(0xFF007BFF) : Colors.grey[700],
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, UserProfile currentUser) async {
     final selectedUser = await showDialog<UserProfile>(
       context: context,
       builder: (context) => NewChatDialog(currentUserId: currentUser.uid),
     );
     
     // If user selected, create a new chat via callback
     if (selectedUser != null) {
       // Create a placeholder conversation for the selected user
       final tempConversation = Conversation(
         id: 'new_${selectedUser.uid}',
         type: ConversationType.direct,
         participantIds: [currentUser.uid, selectedUser.uid],
         participantNames: [currentUser.displayName, selectedUser.displayName],
         participantRoles: [currentUser.role, selectedUser.role],
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
         createdBy: currentUser.uid,
       );
       onConversationSelected(tempConversation);
     }
  }
}

class _ConversationItem extends HookConsumerWidget {
  final Conversation conversation;
  final String currentUserId;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(String)? onDeleted;

  const _ConversationItem({
    required this.conversation,
    required this.currentUserId,
    required this.isSelected,
    required this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    final displayName = conversation.getDisplayName(currentUserId);
    final lastMessage = conversation.lastMessageText ?? '';
    final time = _formatTime(conversation.lastMessageAt);
    final unreadCount = conversation.unreadCount(currentUserId);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected ? const Color(0xFFF0F2F5) : (isHovered.value ? const Color(0xFFF5F6F6) : Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
               CircleAvatar(
                 radius: 24,
                 backgroundColor: Colors.grey[300],
                 child: Text(
                   displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Text(
                             displayName,
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                             style: GoogleFonts.inter(
                               fontWeight: FontWeight.w600,
                               fontSize: 16,
                               color: const Color(0xFF111827),
                             ),
                           ),
                         ),
                         Text(
                           time,
                           style: GoogleFonts.inter(
                             fontSize: 12,
                             color: unreadCount > 0 ? const Color(0xFF25D366) : Colors.grey[500],
                             fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                             height: 1.0, // Adjust line height
                           ),
                         ),
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
                             style: GoogleFonts.inter(
                               fontSize: 14,
                               color: Colors.grey[600],
                             ),
                           ),
                         ),
                          if (isHovered.value || isSelected)
                            Theme(
                              data: Theme.of(context).copyWith(
                                useMaterial3: false, 
                                popupMenuTheme: const PopupMenuThemeData(
                                  color: Colors.white,
                                  surfaceTintColor: Colors.white,
                                ),
                              ),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8696A0), size: 24),
                                  offset: const Offset(0, 30),
                                  onSelected: (value) async {
                                    final chatService = ref.read(chatServiceProvider);
                                    
                                    switch (value) {
                                      case 'archive':
                                        if (conversation.isArchived) {
                                          await chatService.unarchiveConversation(conversation.id);
                                        } else {
                                          await chatService.archiveConversation(conversation.id);
                                        }
                                        // Invalidate to refresh list
                                        ref.invalidate(conversationsStreamProvider(currentUserId));
                                        break;
                                      case 'delete':
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Hapus Chat'),
                                            content: const Text('Yakin ingin menghapus percakapan ini? Semua pesan akan dihapus.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await chatService.deleteConversation(conversation.id);
                                          // Invalidate to refresh list
                                          ref.invalidate(conversationsStreamProvider(currentUserId));
                                          // Notify parent to reset selection
                                          onDeleted?.call(conversation.id);
                                        }
                                        break;
                                      case 'mute':
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Fitur bisukan belum tersedia')),
                                        );
                                        break;
                                      case 'unread':
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Ditandai sebagai belum dibaca')),
                                        );
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'archive', 
                                      child: Text(conversation.isArchived ? 'Batalkan arsip' : 'Arsipkan chat'),
                                    ),
                                    const PopupMenuItem(value: 'mute', child: Text('Bisukan notifikasi')),
                                    const PopupMenuItem(value: 'delete', child: Text('Hapus chat')),
                                    const PopupMenuItem(value: 'unread', child: Text('Tandai belum dibaca')),
                                  ],
                                ),
                              ),
                            )
                         else if (unreadCount > 0)
                           Container(
                             padding: const EdgeInsets.all(6),
                             decoration: const BoxDecoration(
                               color: Color(0xFF25D366),
                               shape: BoxShape.circle,
                             ),
                             child: Text(
                               unreadCount.toString(),
                               style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                             ),
                           ),
                       ],
                     ),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
