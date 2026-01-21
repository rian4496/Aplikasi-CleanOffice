// lib/screens/chat/widgets/message_search_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageSearchPanel extends HookWidget {
  final VoidCallback onClose;
  final Function(String) onSearch;
  final VoidCallback onDateSelect;

  const MessageSearchPanel({
    super.key,
    required this.onClose,
    required this.onSearch,
    required this.onDateSelect,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return Container(
      width: 400, // Fixed width like WhatsApp Web
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
               color: const Color(0xFFF0F2F5), // WA Web Header Color
               border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF54656F)),
                  onPressed: onClose,
                ),
                const SizedBox(width: 16),
                Text(
                  'Cari Pesan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF54656F)),
                  onPressed: onDateSelect,
                  tooltip: 'Cari berdasarkan tanggal',
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                     decoration: BoxDecoration(
                       color: const Color(0xFFF0F2F5),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                     child: Row(
                       children: [
                         const Icon(Icons.search, size: 20, color: Color(0xFF54656F)), // Added Search icon inside box for better UI
                         const SizedBox(width: 8),
                         Expanded(
                           child: TextField(
                             controller: searchController,
                             onChanged: onSearch,
                             decoration: const InputDecoration(
                               hintText: 'Cari...',
                               border: InputBorder.none,
                               isDense: true,
                             ),
                             style: GoogleFonts.inter(fontSize: 14),
                           ),
                         ),
                         if (searchController.text.isNotEmpty)
                           IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                              onPressed: () {
                                 searchController.clear();
                                 onSearch('');
                              },
                           ),
                       ],
                     ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content Placeholder
          Expanded(
            child: Center(
              child: Text(
                'Cari pesan dalam obrolan ini',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
