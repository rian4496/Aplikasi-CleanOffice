// lib/screens/chat/chat_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../riverpod/auth_providers.dart';
import '../../models/conversation.dart';
import 'widgets/chat_list_panel.dart';
import 'widgets/chat_room_panel.dart';

import 'widgets/message_search_panel.dart'; // Import Search Panel

/// WhatsApp-style Split View Dashboard
class ChatDashboardScreen extends HookConsumerWidget {
  final String? initialConversationId;

  const ChatDashboardScreen({
     super.key,
     this.initialConversationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConversation = useState<Conversation?>(null);
    final selectedId = useState<String?>(initialConversationId);
    final isSearchPanelOpen = useState(false); // Search Panel State
    
    // Determine screen size for responsiveness
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // Reset selectedConversation if initialConversationId provided and distinct
    useEffect(() {
      if (initialConversationId != null) {
         selectedId.value = initialConversationId;
      }
      return null;
    }, [initialConversationId]);

    // Close search panel when changing chat
    useEffect(() {
       isSearchPanelOpen.value = false;
       return null;
    }, [selectedId.value]);

    return Scaffold(
      body: Row(
        children: [
          // Left Panel: Chat List
          if (isDesktop || selectedId.value == null)
            Expanded(
              flex: isDesktop ? 4 : 1, 
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: ChatListPanel(
                  selectedConversationId: selectedId.value,
                  onConversationSelected: (conversation) {
                    selectedConversation.value = conversation;
                    selectedId.value = conversation.id;
                  },
                  onConversationDeleted: (deletedId) {
                    // If deleted conversation is currently selected, clear the right panel
                    if (selectedId.value == deletedId) {
                      selectedId.value = null;
                      selectedConversation.value = null;
                    }
                  },
                ),
              ),
            ),
          
          // Right Panel: Chat Room + Search Panel (Nested Row)
          if (isDesktop || selectedId.value != null)
             Expanded(
               flex: isDesktop ? 9 : 1, 
               child: Row(
                 children: [
                   Expanded(
                     child: selectedId.value != null
                         ? ChatRoomPanel(
                             conversationId: selectedId.value!,
                             otherUserName: selectedConversation.value?.getDisplayName(
                                ref.read(currentUserProfileProvider).asData?.value?.uid ?? ''
                             ),
                             onBack: () {
                               selectedId.value = null;
                               selectedConversation.value = null;
                             },
                             onToggleSearch: () {
                               isSearchPanelOpen.value = !isSearchPanelOpen.value;
                             },
                           )
                         : _buildEmptyState(),
                   ),
                   // Search Panel Sidebar
                   if (isSearchPanelOpen.value && selectedId.value != null && isDesktop)
                     MessageSearchPanel(
                       onClose: () => isSearchPanelOpen.value = false,
                       onSearch: (query) {
                         // TODO: Implement actual search
                       },
                       onDateSelect: () {
                          // Show Date Picker
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF00A884), // WA Green
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                       },
                     ),
                 ],
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // WA Web Style Empty State Image
             const Icon(Icons.chat_bubble_outline_rounded, size: 100, color: Colors.grey), // Placeholder
             const SizedBox(height: 32),
             const Text(
               'SIM ASET BRIDA Web Chat',
               style: TextStyle(fontSize: 32, color: Color(0xFF41525d), fontWeight: FontWeight.w300),
             ),
             const SizedBox(height: 16),
             const Text(
               'Kirim dan terima pesan untuk support dan koordinasi.',
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 14, color: Color(0xFF8696a0)),
             ),
             const SizedBox(height: 32),
             const Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.lock, size: 12, color: Color(0xFF8696a0)),
                 SizedBox(width: 4),
                 Text('End-to-end encrypted messaging (Mock)', style: TextStyle(fontSize: 12, color: Color(0xFF8696a0))),
               ],
             ),
             Container(
               margin: const EdgeInsets.only(top: 40),
               height: 6,
               width: 300,
               decoration: BoxDecoration(
                 color: const Color(0xFF25D366),
                 borderRadius: BorderRadius.circular(3),
               ),
             )
          ],
        ),
      ),
    );
  }
}
