// lib/widgets/admin/verification/image_comparison_widget.dart
// 🖼️ Image Comparison Widget
// Side-by-side before/after image comparison with swipe and zoom

import 'package:flutter/material.dart';
import '../../../core/design/admin_colors.dart';
import '../../../core/design/admin_typography.dart';
import '../../../core/design/admin_constants.dart';

class ImageComparisonWidget extends StatefulWidget {
  final List<String> beforeImages;
  final List<String> afterImages;
  final double height;

  const ImageComparisonWidget({
    super.key,
    required this.beforeImages,
    required this.afterImages,
    this.height = 250,
  });

  @override
  State<ImageComparisonWidget> createState() => _ImageComparisonWidgetState();
}

class _ImageComparisonWidgetState extends State<ImageComparisonWidget> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxImages = widget.beforeImages.length > widget.afterImages.length
        ? widget.beforeImages.length
        : widget.afterImages.length;

    return Column(
      children: [
        // Images
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: maxImages,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  // Before Image
                  Expanded(
                    child: _buildImageContainer(
                      index < widget.beforeImages.length
                          ? widget.beforeImages[index]
                          : null,
                      'SEBELUM',
                      AdminColors.error,
                    ),
                  ),
                  const SizedBox(width: AdminConstants.spaceSm),
                  // After Image
                  Expanded(
                    child: _buildImageContainer(
                      index < widget.afterImages.length
                          ? widget.afterImages[index]
                          : null,
                      'SESUDAH',
                      AdminColors.success,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Dots Indicator
        if (maxImages > 1) ...[
          const SizedBox(height: AdminConstants.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              maxImages,
              (index) => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AdminConstants.spaceXs,
                ),
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AdminColors.primary
                      : AdminColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContainer(String? imageUrl, String label, Color labelColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AdminConstants.borderRadiusCard,
        border: Border.all(color: AdminColors.border),
      ),
      child: ClipRRect(
        borderRadius: AdminConstants.borderRadiusCard,
        child: Stack(
          children: [
            // Image
            if (imageUrl != null)
              GestureDetector(
                onTap: () => _showFullscreenImage(imageUrl),
                child: Container(
                  color: AdminColors.background,
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: AdminColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'No Image',
                  style: AdminTypography.body2.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ),

            // Label
            Positioned(
              top: AdminConstants.spaceSm,
              left: AdminConstants.spaceSm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminConstants.spaceSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                ),
                child: Text(
                  label,
                  style: AdminTypography.badge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Zoom icon hint
            if (imageUrl != null)
              Positioned(
                bottom: AdminConstants.spaceSm,
                right: AdminConstants.spaceSm,
                child: Container(
                  padding: const EdgeInsets.all(AdminConstants.spaceXs),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AdminConstants.radiusSm),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
