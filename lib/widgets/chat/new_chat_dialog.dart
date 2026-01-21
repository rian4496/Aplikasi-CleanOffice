// lib/widgets/chat/new_chat_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_profile.dart'; // Adjust path as needed
import '../../services/supabase_database_service.dart';
import '../../screens/chat/chat_room_screen.dart'; // Adjust path
import '../../riverpod/auth_providers.dart';
import '../../riverpod/chat_providers.dart';

// Make sure to match the HookConsumerWidget import
class NewChatDialog extends HookConsumerWidget {
  final String currentUserId;

  const NewChatDialog({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded-2xl
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1E293B), size: 24), // Slate-800
                const SizedBox(width: 12),
                Text(
                  'Obrolan Baru',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search box
            TextField(
              controller: searchController,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC), // Slate-50
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), // Rounded-xl
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // User list
            Expanded(
              child: FutureBuilder<List<UserProfile>>(
                future: SupabaseDatabaseService().getAllUserProfiles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat', style: GoogleFonts.inter(color: Colors.red)));
                  }

                  final users = snapshot.data ?? [];
                  // Show all users except current user and employees (employees cannot be contacted)
                  // Kasubbag can chat with admin, cleaner, teknisi - but NOT with employee
                  final filteredUsers = users
                      .where((user) => user.uid != currentUserId)
                      .where((user) => user.role != 'employee') // Only exclude employees
                      .where((user) {
                        if (searchQuery.value.isEmpty) return true;
                        final query = searchQuery.value.toLowerCase();
                        return user.displayName.toLowerCase().contains(query) ||
                            user.role.toLowerCase().contains(query);
                      })
                      .toList();

                  if (filteredUsers.isEmpty) {
                    return Center(child: Text('Tidak ada pengguna', style: GoogleFonts.inter(color: Colors.grey)));
                  }

                  return ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      // Randomize mock colors for avatars to match screenshots (F - Blue,  E - Slate, etc or just sticking to one nicely)
                      // Screenshot has Light Blue avatars for F, E, F, A.
                      
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE), // Blue-100
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1E40AF), // Blue-800
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          user.displayName,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF1E293B)),
                        ),
                        subtitle: Text(
                          user.role,
                          style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14), // Slate-500
                        ),
                        onTap: () {
                           // Return selected user - parent will handle navigation
                           Navigator.pop(context, user);
                        },
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
}
