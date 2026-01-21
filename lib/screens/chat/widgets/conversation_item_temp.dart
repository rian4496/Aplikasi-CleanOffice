// ... (imports remain mostly same, adding Material)

class _ConversationItem extends HookConsumerWidget {
  final Conversation conversation;
  final String currentUserId;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationItem({
    required this.conversation,
    required this.currentUserId,
    required this.isSelected,
    required this.onTap,
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
                         // Hover Menu or Unread Badge
                         if (isHovered.value || isSelected)
                           Theme(
                             data: Theme.of(context).copyWith(
                               useMaterial3: false, // Ensure compact menu
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
                                 onSelected: (value) {
                                   // Handle menu
                                   if (value == 'delete') {
                                     // TODO: Implement delete
                                   }
                                 },
                                 itemBuilder: (context) => [
                                   const PopupMenuItem(value: 'archive', child: Text('Arsipkan chat')),
                                   const PopupMenuItem(value: 'mute', child: Text('Bisukan notifikasi')),
                                   const PopupMenuItem(value: 'delete', child: Text('Hapus chat')),
                                   const PopupMenuItem(value: 'unread', child: Text('Tandai belum dibaca')),
                                   const PopupMenuItem(value: 'block', child: Text('Blokir')),
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
