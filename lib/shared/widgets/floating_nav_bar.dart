import 'package:flutter/material.dart';

import '../app_constants.dart';

class FloatingNavDestination {
  final IconData icon;
  final String label;

  const FloatingNavDestination({
    required this.icon,
    required this.label,
  });
}

/// Floating pill-shaped bottom navigation bar. Every destination renders as
/// an icon-over-label column; the selected one sits on a filled brand-green
/// capsule, unselected ones stay muted with no background. Replaces
/// [NavigationBar], which can't produce the floating-pill capsule look.
class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingNavDestination> destinations;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < destinations.length; i++)
              // Flexible (not a fixed size) so longer localized labels
              // shrink to fit instead of overflowing the Row on narrow
              // phones — labels are translated and vary in length per
              // language.
              Flexible(
                child: _FloatingNavItem(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  onTap: () => onDestinationSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final FloatingNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeOut;

  const _FloatingNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Icon-over-label column for every item (not just the selected one),
    // so widths stay near-uniform and the Row never needs to fight for
    // horizontal space the way the old icon-beside-label layout did.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                destination.icon,
                size: 22,
                color: selected ? Colors.white : Colors.grey[500],
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[500],
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
