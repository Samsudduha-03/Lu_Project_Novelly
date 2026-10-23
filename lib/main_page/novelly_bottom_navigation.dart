import 'package:flutter/material.dart';

const Color _deepInk = Color(0xFF12343B);
const Color _gold = Color(0xFFE5AE4D);

enum NovellyNavigationDestination { discover, library, chat, profile }

class NovellyBottomNavigation extends StatelessWidget {
  const NovellyBottomNavigation({
    required this.libraryLabel,
    required this.selectedDestination,
    required this.compact,
    required this.onDestinationSelected,
    this.libraryIcon = Icons.menu_book_outlined,
    super.key,
  });

  final String libraryLabel;
  final IconData libraryIcon;
  final NovellyNavigationDestination selectedDestination;
  final bool compact;
  final ValueChanged<NovellyNavigationDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      (
        destination: NovellyNavigationDestination.discover,
        icon: Icons.explore_outlined,
        label: 'Discover',
      ),
      (
        destination: NovellyNavigationDestination.library,
        icon: libraryIcon,
        label: libraryLabel,
      ),
      (
        destination: NovellyNavigationDestination.chat,
        icon: Icons.chat_bubble_outline,
        label: 'Chat',
      ),
      (
        destination: NovellyNavigationDestination.profile,
        icon: Icons.person_outline,
        label: 'Profile',
      ),
    ];

    return Container(
      height: compact ? 68 : 92,
      decoration: BoxDecoration(
        color: _deepInk,
        borderRadius: BorderRadius.circular(compact ? 23 : 29),
      ),
      child: Row(
        children: [
          for (final item in destinations)
            Expanded(
              child: InkWell(
                onTap: () => onDestinationSelected(item.destination),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: selectedDestination == item.destination
                          ? _gold
                          : Colors.white,
                      size: compact ? 25 : 34,
                    ),
                    SizedBox(height: compact ? 2 : 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedDestination == item.destination
                            ? _gold
                            : Colors.white,
                        fontSize: compact ? 12 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
