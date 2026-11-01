import 'package:flutter/material.dart';

/// Shared breakpoints for the shell and content, based on the window width.
abstract final class AppLayout {
  static const mobile = 600.0;
  static const desktop = 1280.0;
  static const maxContent = 1320.0;
}

class LibraryDestination {
  const LibraryDestination(this.path, this.label, this.icon);
  final String path, label;
  final IconData icon;
}

class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });
  final List<LibraryDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppLayout.mobile) return child;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          child: IntrinsicHeight(
            child: NavigationRail(
              key: const ValueKey('library-navigation-rail'),
              extended: width >= AppLayout.desktop,
              minExtendedWidth: 200,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              destinations: [
                for (final entry in destinations)
                  NavigationRailDestination(
                    icon: Tooltip(
                      message: entry.label,
                      child: Icon(entry.icon),
                    ),
                    label: Text(entry.label),
                  ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: child),
      ],
    );
  }
}
