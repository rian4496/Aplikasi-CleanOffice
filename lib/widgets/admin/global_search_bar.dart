// lib/widgets/admin/global_search_bar.dart
// Global search bar for filtering reports - REFACTORED

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/riverpod/filter_state_provider.dart';

class GlobalSearchBar extends ConsumerStatefulWidget {
  final bool autofocus;
  
  const GlobalSearchBar({
    this.autofocus = false,
    super.key,
  });

  @override
  ConsumerState<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends ConsumerState<GlobalSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search reports...',
          prefixIcon: Icon(Icons.search, color: AppTheme.primary),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                    ref.read(filterProvider.notifier).updateSearchQuery('');
                    _focusNode.requestFocus();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        autofocus: widget.autofocus,
        onChanged: (value) {
          // Update filter in real-time
          ref.read(filterProvider.notifier).updateSearchQuery(value);
          setState(() {}); // Update to show/hide clear button
        },
      ),
    );
  }
}

/// Compact search bar variant
class CompactSearchBar extends ConsumerStatefulWidget {
  const CompactSearchBar({super.key});

  @override
  ConsumerState<CompactSearchBar> createState() => _CompactSearchBarState();
}

class _CompactSearchBarState extends ConsumerState<CompactSearchBar> {
  late TextEditingController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() => _isExpanded = true);
        },
        tooltip: 'Search',
      );
    }

    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                ref.read(filterProvider.notifier).updateSearchQuery(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              _controller.clear();
              ref.read(filterProvider.notifier).updateSearchQuery('');
              setState(() => _isExpanded = false);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
