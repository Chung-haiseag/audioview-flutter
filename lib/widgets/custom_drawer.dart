import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF141414),
      child: SafeArea(
        child: Column(
          children: [
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: LucideIcons.home,
                    label: '홈',
                    index: 0,
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.list,
                    label: '장르',
                    index: 1,
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.user,
                    label: '마이페이지',
                    index: 4, // MyPageScreen index in MainScreen
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.megaphone,
                    label: '공지/이벤트',
                    index: 5, // NoticeListScreen index in MainScreen
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.settings,
                    label: '설정',
                    index: 2, // SettingsScreen index in MainScreen
                    context: context,
                  ),
                ],
              ),
            ),

            // Optional: Footer or version info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFE50914) : Colors.grey[400],
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFE50914).withValues(alpha: 0.1),
      onTap: () {
        onItemTapped(index);
        Navigator.pop(context); // Close drawer
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
