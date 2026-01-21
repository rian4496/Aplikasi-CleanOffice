// lib/screens/chat/widgets/chat_room_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../models/conversation.dart';
import '../../../models/message.dart'; // Import Message
import '../../../riverpod/auth_providers.dart';
import '../../../riverpod/chat_providers.dart';
import '../../../services/realtime_presence_service.dart';
import '../../../widgets/chat/message_bubble.dart';
import '../../../widgets/chat/chat_input_bar.dart';

class ChatRoomPanel extends HookConsumerWidget {
  final String conversationId;
  final String? otherUserName;
  final VoidCallback onBack;
  final VoidCallback? onToggleSearch;

  const ChatRoomPanel({
    super.key,
    required this.conversationId,
    this.otherUserName,
    required this.onBack,
    this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProfileProvider);
    final conversationAsync = ref.watch(conversationProvider(conversationId));
    final messagesAsync = ref.watch(messagesStreamProvider(conversationId));
    final scrollController = useScrollController();
    final messageController = useTextEditingController();
    
    // Selection Mode State
    final isSelectionMode = useState(false);
    final selectedMessageIds = useState<Set<String>>({});

    // Auto scroll logic (only if not in selection mode to avoid disrupting user)
    useEffect(() {
      if (scrollController.hasClients && !isSelectionMode.value) {
        Future.delayed(const Duration(milliseconds: 100), () {
           if (scrollController.hasClients) {
             scrollController.jumpTo(scrollController.position.maxScrollExtent);
           }
        });
      }
      return null;
    }, [messagesAsync]);

    void toggleSelection(String id) {
      final newSet = Set<String>.from(selectedMessageIds.value);
      if (newSet.contains(id)) {
        newSet.remove(id);
      } else {
        newSet.add(id);
      }
      selectedMessageIds.value = newSet;
      
      // Auto exit selection mode if empty? Nah, WA keeps it until X is pressed.
      if (newSet.isEmpty && !isSelectionMode.value) {
         // Maybe close? user usually manually closes
      }
    }

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
             color: const Color(0xFFF0F2F5),
             border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
               IconButton(
                 icon: const Icon(Icons.arrow_back, color: Color(0xFF54656F)),
                 onPressed: onBack,
                 tooltip: 'Kembali',
               ),
               const CircleAvatar(
                 radius: 20,
                 backgroundColor: Colors.grey,
                 child: Icon(Icons.person, color: Colors.white),
               ),
               const SizedBox(width: 16),
               
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       otherUserName ?? 'Chat',
                       style: GoogleFonts.inter(
                         fontWeight: FontWeight.w600,
                         fontSize: 16,
                         color: const Color(0xFF111827),
                       ),
                     ),
                     // Online status - Real-time using Supabase Presence
                     conversationAsync.when(
                       data: (conversation) {
                         if (conversation == null || conversation.type != ConversationType.direct) {
                           return const SizedBox.shrink();
                         }
                         // Get other user ID
                         final currentUserId = currentUser.asData?.value?.uid;
                         if (currentUserId == null) return const SizedBox.shrink();
                         final otherUserId = conversation.participantIds.firstWhere(
                           (id) => id != currentUserId,
                           orElse: () => '',
                         );
                         if (otherUserId.isEmpty) return const SizedBox.shrink();
                         
                         // Use realtime presence stream
                         final onlineUsersAsync = ref.watch(onlineUsersStreamProvider);
                         return onlineUsersAsync.when(
                           data: (onlineUsers) {
                             final isOnline = onlineUsers.contains(otherUserId);
                             if (isOnline) {
                               return Text(
                                 'Online',
                                 style: GoogleFonts.inter(
                                   color: const Color(0xFF22C55E),
                                   fontSize: 12,
                                 ),
                               );
                             }
                             // Show last seen from database as fallback
                             final chatService = ref.read(chatServiceProvider);
                             return FutureBuilder<DateTime?>(
                               future: chatService.getLastSeen(otherUserId),
                               builder: (context, lastSeenSnapshot) {
                                 if (!lastSeenSnapshot.hasData || lastSeenSnapshot.data == null) {
                                   return Text(
                                     'Offline',
                                     style: GoogleFonts.inter(
                                       color: const Color(0xFF64748B),
                                       fontSize: 12,
                                     ),
                                   );
                                 }
                                 return Text(
                                   chatService.formatLastSeen(lastSeenSnapshot.data!),
                                   style: GoogleFonts.inter(
                                     color: const Color(0xFF64748B),
                                     fontSize: 12,
                                   ),
                                 );
                               },
                             );
                           },
                           loading: () => const SizedBox.shrink(),
                           error: (_, __) => const SizedBox.shrink(),
                         );
                       },
                       loading: () => const SizedBox.shrink(),
                       error: (_, __) => const SizedBox.shrink(),
                     ),
                   ],
                 ),
               ),
               
               // Actions
               IconButton(
                 icon: const Icon(Icons.search, color: Color(0xFF54656F)),
                 onPressed: onToggleSearch,
                 tooltip: 'Cari...',
               ),
               PopupMenuButton<String>(
                 icon: const Icon(Icons.more_vert, color: Color(0xFF54656F)),
                 onSelected: (value) async {
                   final chatService = ref.read(chatServiceProvider);
                   
                   switch (value) {
                     case 'close':
                       onBack();
                       break;
                     case 'select':
                       isSelectionMode.value = true;
                       selectedMessageIds.value = {};
                       break;
                     case 'clear':
                       final confirmed = await showDialog<bool>(
                         context: context,
                         builder: (ctx) => AlertDialog(
                           title: const Text('Bersihkan Obrolan'),
                           content: const Text('Yakin ingin menghapus semua pesan dalam obrolan ini?'),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                             TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Bersihkan', style: TextStyle(color: Colors.red))),
                           ],
                         ),
                       );
                       if (confirmed == true) {
                         await chatService.clearConversation(conversationId);
                       }
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
                         await chatService.deleteConversation(conversationId);
                         // Invalidate provider to refresh list
                         final user = currentUser.asData?.value;
                         if (user != null) {
                           ref.invalidate(conversationsStreamProvider(user.uid));
                         }
                         onBack(); // Close panel after delete
                       }
                       break;
                   }
                 },
                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                   const PopupMenuItem<String>(
                     value: 'info',
                     child: Text('Info kontak'),
                   ),
                   const PopupMenuItem<String>(
                     value: 'select',
                     child: Text('Pilih pesan'),
                   ),
                   const PopupMenuItem<String>(
                     value: 'disappear',
                     child: Text('Pesan sementara'),
                   ),
                   const PopupMenuItem<String>(
                     value: 'close',
                     child: Text('Tutup chat'),
                   ),
                   const PopupMenuItem<String>(
                     value: 'clear',
                     child: Text('Bersihkan obrolan'),
                   ),
                   const PopupMenuItem<String>(
                     value: 'delete',
                     child: Text('Hapus chat'),
                   ),
                 ],
               ),
            ],
          ),
        ),

        // Messages Area
        Expanded(
          child: Container(
            color: const Color(0xFFEFE7DE),
            child: currentUser.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();

                return messagesAsync.when(
                  data: (messages) {
                     if (messages.isEmpty) {
                       return Center(
                         child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFFFF5C4), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)]),
                            child: const Text('Belum ada pesan. Mulai percakapan!', style: TextStyle(fontSize: 12)),
                         )
                       );
                     }
                     
                     // Messages are already ordered newest first from provider
                     // ListView with reverse:true shows newest at bottom (correct WhatsApp behavior)
                     return ListView.builder(
                       controller: scrollController,
                       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                       itemCount: messages.length,
                       reverse: true,
                       itemBuilder: (context, index) {
                         final message = messages[index];
                         final isOwnMessage = message.senderId == user.uid;
                         final isSelected = selectedMessageIds.value.contains(message.id);
                         
                         // Check if we need a date separator
                         // Since list is reversed, we compare with NEXT item (which is previous in time)
                         bool showDateSeparator = false;
                         if (index == messages.length - 1) {
                           // First message (oldest) always shows date
                           showDateSeparator = true;
                         } else {
                           final nextMessage = messages[index + 1];
                           final currentDate = message.createdAt.toLocal();
                           final nextDate = nextMessage.createdAt.toLocal();
                           // Show separator if dates are different
                           showDateSeparator = currentDate.day != nextDate.day ||
                               currentDate.month != nextDate.month ||
                               currentDate.year != nextDate.year;
                         }

                         return Column(
                           children: [
                             if (showDateSeparator)
                               _buildDateSeparator(message.createdAt),
                             GestureDetector(
                               onTap: isSelectionMode.value 
                                   ? () => toggleSelection(message.id)
                                   : null,
                               child: Container(
                                 color: isSelected ? const Color(0xFFF0F2F5).withValues(alpha: 0.5) : Colors.transparent,
                                 padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                                 child: Row(
                                   children: [
                                     if (isSelectionMode.value)
                                       Padding(
                                         padding: const EdgeInsets.only(right: 12.0),
                                         child: Checkbox(
                                           value: isSelected,
                                           onChanged: (_) => toggleSelection(message.id),
                                           activeColor: const Color(0xFF00A884),
                                           side: const BorderSide(color: Color(0xFF8696A0), width: 2),
                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                         ),
                                       ),
                                     Expanded(
                                       child: AbsorbPointer(
                                         absorbing: isSelectionMode.value,
                                         child: MessageBubble(
                                           message: message,
                                           isOwnMessage: isOwnMessage,
                                           onLongPress: () {
                                             if (!isSelectionMode.value) {
                                                isSelectionMode.value = true;
                                                toggleSelection(message.id);
                                             }
                                           },
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           ],
                         );
                       },
                     );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error loading messages')),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),

        // Bottom Area (Input OR Selection Actions)
        if (isSelectionMode.value)
          Container(
             height: 60,
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
             decoration: BoxDecoration(
               color: const Color(0xFFF0F2F5),
               border: Border(top: BorderSide(color: Colors.grey[300]!)),
             ),
             child: Row(
               children: [
                 IconButton(
                   icon: const Icon(Icons.close, color: Color(0xFF54656F)),
                   onPressed: () {
                     isSelectionMode.value = false;
                     selectedMessageIds.value = {};
                   },
                 ),
                 const SizedBox(width: 16),
                 Text(
                   '${selectedMessageIds.value.length} terpilih',
                   style: GoogleFonts.inter(
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                     color: const Color(0xFF111827),
                   ),
                 ),
                 const Spacer(),
                 if (selectedMessageIds.value.isNotEmpty) ...[
                   IconButton(
                     icon: const Icon(Icons.delete_outline, color: Color(0xFF54656F)),
                     onPressed: () async {
                       final chatService = ref.read(chatServiceProvider);
                       final count = selectedMessageIds.value.length;
                       
                       final confirmed = await showDialog<bool>(
                         context: context,
                         builder: (ctx) => AlertDialog(
                           title: const Text('Hapus Pesan'),
                           content: Text('Yakin ingin menghapus $count pesan?'),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                             TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                           ],
                         ),
                       );
                       
                       if (confirmed == true) {
                         await chatService.deleteMessages(selectedMessageIds.value.toList());
                         isSelectionMode.value = false;
                         selectedMessageIds.value = {};
                       }
                     },
                     tooltip: 'Hapus pesan',
                   ),
                   IconButton(
                     icon: const Icon(Icons.forward, color: Color(0xFF54656F)),
                     onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Fitur teruskan pesan belum tersedia')),
                       );
                     },
                     tooltip: 'Teruskan',
                   ),
                 ]
               ],
             ),
          )
        else
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: const Color(0xFFF0F2F5),
               border: Border(top: BorderSide(color: Colors.grey[300]!)),
             ),
             child: currentUser.asData?.value != null ? ChatInputBar(
               controller: messageController,
               onSend: () async {
                  final text = messageController.text.trim();
                  if (text.isEmpty) return;
                  
                  final chatService = ref.read(chatServiceProvider);
                  final user = currentUser.asData!.value!;
                  
                  await chatService.sendMessage(
                    conversationId: conversationId,
                    senderId: user.uid,
                    senderName: user.displayName ?? 'User',
                    content: text,
                  );
                  messageController.clear();
               },
               onImageSelected: (path) {}, // TODO
               onFileSelected: (path, name) {}, // TODO
               onTypingChanged: (typing) {},
             ) : const SizedBox.shrink(),
          ),
      ],
    );
  }

  /// Build date separator widget
  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    // Convert UTC to local time for display
    final localDate = date.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localDate.year, localDate.month, localDate.day);
    
    String label;
    if (messageDate == today) {
      label = 'Hari ini';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      label = 'Kemarin';
    } else {
      label = '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
    }
    
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8EE),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF54656F),
          ),
        ),
      ),
    );
  }
}
