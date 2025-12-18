// lib/widgets/chat/chat_input_bar.dart
// Widget untuk input bar di chat room

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design/admin_colors.dart';
import '../../core/design/admin_typography.dart';
import '../../core/logging/app_logger.dart';

final _logger = AppLogger('ChatInputBar');

/// Chat Input Bar Widget
/// Bottom bar for typing and sending messages
class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String)? onTyping;
  final Function(bool isTyping)? onTypingChanged;
  final Function(String imagePath)? onImageSelected;
  final Function(String filePath, String fileName)? onFileSelected;
  final bool enabled;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onTyping,
    this.onTypingChanged,
    this.onImageSelected,
    this.onFileSelected,
    this.enabled = true,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _isComposing = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    // Stop typing indicator on dispose
    if (_isTyping) {
      widget.onTypingChanged?.call(false);
    }
    super.dispose();
  }

  void _handleTextChanged() {
    final isComposing = widget.controller.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }

    // Notify typing (for legacy support)
    widget.onTyping?.call(widget.controller.text);

    // Notify typing state change
    final newTypingState = isComposing;
    if (newTypingState != _isTyping) {
      _isTyping = newTypingState;
      widget.onTypingChanged?.call(newTypingState);
    }
  }

  void _handleSend() {
    if (!_isComposing || !widget.enabled) return;
    widget.onSend();
  }

  Future<void> _handleAttachment() async {
    if (!widget.enabled) return;

    // Show bottom sheet with attachment options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pilih Lampiran',
                  style: AdminTypography.h4,
                ),
                const SizedBox(height: 20),

                // Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera
                    _AttachmentOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      color: AdminColors.info,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),

                    // Gallery
                    _AttachmentOption(
                      icon: Icons.photo,
                      label: 'Galeri',
                      color: AdminColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),

                    // File
                    _AttachmentOption(
                      icon: Icons.insert_drive_file,
                      label: 'File',
                      color: AdminColors.warning,
                      onTap: () {
                        Navigator.pop(context);
                        _pickFile();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        _logger.info('Image picked from camera: ${image.path}');
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      _logger.error('Error picking image from camera', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka kamera'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _logger.info('Image picked from gallery: ${image.path}');
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      _logger.error('Error picking image from gallery', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka galeri'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        _logger.info('File picked: ${file.name}');
        widget.onFileSelected?.call(file.path!, file.name);
      }
    } catch (e) {
      _logger.error('Error picking file', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih file'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  /// Show emoji picker bottom sheet
  void _showEmojiPicker() {
    // Common emojis organized by category
    final emojis = [
      // Smileys
      '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
      '🙂', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗',
      '😚', '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗',
      '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶',
      '😏', '😒', '🙄', '😬', '😮', '😯', '😲', '😳',
      '🥺', '😦', '😧', '😨', '😰', '😢', '😭', '😱',
      '😖', '😣', '😞', '😓', '😩', '😫', '🥱', '😤',
      '😡', '😠', '🤬', '😈', '👿', '💀', '☠️', '💩',
      // Gestures
      '👍', '👎', '👊', '✊', '🤛', '🤜', '🤝', '👏',
      '🙌', '👐', '🤲', '🙏', '✌️', '🤞', '🤟', '🤘',
      '👌', '🤌', '🤏', '👈', '👉', '👆', '👇', '☝️',
      '✋', '🤚', '🖐️', '🖖', '👋', '🤙', '💪', '🦾',
      // Hearts & Love
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘',
      // Objects
      '🎉', '🎊', '🎁', '🏆', '🏅', '🥇', '🥈', '🥉',
      '⭐', '🌟', '✨', '💫', '🔥', '💯', '✅', '❌',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pilih Emoji',
                style: AdminTypography.h4,
              ),
              const SizedBox(height: 12),
              // Emoji grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        // Insert emoji at cursor position
                        final text = widget.controller.text;
                        final selection = widget.controller.selection;
                        final newText = text.replaceRange(
                          selection.start,
                          selection.end,
                          emojis[index],
                        );
                        widget.controller.text = newText;
                        // Move cursor after emoji
                        widget.controller.selection = TextSelection.collapsed(
                          offset: selection.start + emojis[index].length,
                        );
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          emojis[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Emoji button
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              color: widget.enabled ? Colors.grey[600] : Colors.grey,
              onPressed: widget.enabled ? _showEmojiPicker : null,
              tooltip: 'Emoji',
            ),

            // Text input with attachment button inside
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.enabled ? Colors.white : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: widget.enabled,
                        cursorColor: Colors.grey[700],
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: AdminTypography.body2.copyWith(
                          color: Colors.black,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    // Attachment button (inside input field)
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Colors.grey[600],
                      iconSize: 20,
                      onPressed: widget.enabled ? _handleAttachment : null,
                      tooltip: 'Lampiran',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: _isComposing && widget.enabled
                    ? AdminColors.primary
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: _isComposing && widget.enabled ? _handleSend : null,
                tooltip: 'Kirim',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Attachment option widget
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AdminTypography.caption.copyWith(
                color: AdminColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

