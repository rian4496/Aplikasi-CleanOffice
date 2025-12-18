import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/utils/global_search_result.dart';
import '../../../services/global_search_service.dart';

class GlobalSearchDialog extends HookConsumerWidget {
  final String initialQuery;
  const GlobalSearchDialog({super.key, this.initialQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller
    final searchController = useTextEditingController(text: initialQuery);
    final focusNode = useFocusNode();
    
    // State
    final isLoading = useState(false);
    final results = useState<List<GlobalSearchResult>>([]);

    // Debounce/Search Logic
    Future<void> performSearch(String query) async {
       if (query.trim().isEmpty) {
         results.value = [];
         return;
       }

       isLoading.value = true;
       try {
         final service = ref.read(globalSearchServiceProvider);
         final data = await service.search(query);
         results.value = data;
       } catch (e) {
         // ignore error
       } finally {
         isLoading.value = false;
       }
    }

    // Auto-search on init if query exists
    useEffect(() {
      focusNode.requestFocus();
      if (initialQuery.isNotEmpty) performSearch(initialQuery);
      return null;
    }, []);

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 100),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Cari aset, anggaran, pegawai, stok...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: GoogleFonts.inter(fontSize: 16),
                onChanged: (val) {
                   // Debounce manually or simple delay
                   // For now, search on submitted or after delay.
                   // Let's settle for onSubmitted for performance or short delay.
                },
                onSubmitted: performSearch,
              ),
            ),
            
            const Divider(height: 1),

            // Results
            Flexible(
              child: results.value.isEmpty && !isLoading.value
                  ? _buildEmptyState(searchController.text)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: results.value.length,
                      separatorBuilder: (c, i) => const Divider(height: 1, indent: 60),
                      itemBuilder: (context, index) {
                        final item = results.value[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.color.withOpacity(0.1),
                            child: Icon(item.icon, color: item.color, size: 20),
                          ),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                          onTap: () {
                             Navigator.pop(context); // Close dialog
                             context.go(item.route); // Navigate
                          },
                        );
                      },
                    ),
            ),
            
            // Footer Hints
            if (results.value.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50], 
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     Text('${results.value.length} hasil ditemukan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                   ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
     if (query.isEmpty) {
       return Container(
         padding: const EdgeInsets.all(32),
         alignment: Alignment.center,
         child: const Text('Ketik kata kunci untuk mencari...', style: TextStyle(color: Colors.grey)),
       );
     }
     
     return Container(
         padding: const EdgeInsets.all(32),
         alignment: Alignment.center,
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Icon(Icons.search_off, size: 48, color: Colors.grey),
             const SizedBox(height: 16),
             Text('Tidak ditemukan hasil untuk "$query"', style: const TextStyle(color: Colors.grey)),
           ],
         ),
       );
  }
}
