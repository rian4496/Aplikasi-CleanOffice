// lib/widgets/web_admin/search/search_bar_widget.dart
// 🔍 Search Bar Widget
// Search input with icon and clear button

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Cari...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AdminConstants.screenPaddingHorizontal,
        vertical: AdminConstants.spaceSm,
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: AdminTypography.body2,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AdminTypography.body2.copyWith(
            color: AdminColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AdminColors.textSecondary,
            size: AdminConstants.iconMd,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AdminColors.textSecondary,
                    size: AdminConstants.iconSm,
                  ),
                  onPressed: _clear,
                )
              : null,
          filled: true,
          fillColor: AdminColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AdminConstants.radiusMd),
            borderSide: const BorderSide(color: AdminColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AdminConstants.spaceMd,
            vertical: AdminConstants.spaceMd,
          ),
        ),
      ),
    );
  }
}

