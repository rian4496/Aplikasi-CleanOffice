import 'package:flutter/material.dart';

class ResponsiveStatsGrid extends StatelessWidget {
  final List<Widget> children;
  final double desktopSpacing;
  final double mobileSpacing;
  final double mobileAspectRatio;
  final int mobileCrossAxisCount;

  const ResponsiveStatsGrid({
    super.key,
    required this.children,
    this.desktopSpacing = 16,
    this.mobileSpacing = 12,
    this.mobileAspectRatio = 1.4, // Wider cards for mobile grid
    this.mobileCrossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Tablet: Use Row if enough space
        if (constraints.maxWidth > 800) {
          return Row(
            children: children
                .map((child) => Expanded(child: child))
                .fold<List<Widget>>([], (list, child) {
                  if (list.isNotEmpty) {
                    list.add(SizedBox(width: desktopSpacing));
                  }
                  list.add(child);
                  return list;
                }),
          );
        }

        // Mobile: Use Grid
        return GridView.count(
          crossAxisCount: mobileCrossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: mobileSpacing,
          crossAxisSpacing: mobileSpacing,
          childAspectRatio: mobileAspectRatio,
          children: children,
        );
      },
    );
  }
}
