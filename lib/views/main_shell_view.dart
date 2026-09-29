import 'package:flutter/material.dart';
import 'package:news_app/views/collection_view.dart';
import 'package:news_app/views/home_view.dart';
import 'package:news_app/views/notification_view.dart';
import 'package:news_app/views/profile_view.dart';
import 'package:news_app/views/search_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    SearchView(),
    CollectionView(),
    NotificationView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF16161D).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2A35)
                    : const Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded),
                _navItem(1, Icons.search_outlined, Icons.search_rounded),
                _navItem(2, Icons.bookmark_outline_rounded,
                    Icons.bookmark_rounded),
                _navItem(3, Icons.notifications_none_rounded,
                    Icons.notifications_rounded),
                _navItem(4, Icons.person_outline_rounded,
                    Icons.person_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 24,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}