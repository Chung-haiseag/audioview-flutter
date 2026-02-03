import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    return Drawer(
      backgroundColor: isLiteMode ? Colors.black : const Color(0xFF141414),
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
                    isLiteMode: isLiteMode,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.list,
                    label: '장르',
                    index: 1,
                    context: context,
                    isLiteMode: isLiteMode,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.user,
                    label: '마이페이지',
                    index: 4, // MyPageScreen index in MainScreen
                    context: context,
                    isLiteMode: isLiteMode,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.megaphone,
                    label: '공지/이벤트',
                    index: 5, // NoticeListScreen index in MainScreen
                    context: context,
                    isLiteMode: isLiteMode,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.settings,
                    label: '설정',
                    index: 2, // SettingsScreen index in MainScreen
                    context: context,
                    isLiteMode: isLiteMode,
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
                  fontSize: isLiteMode ? 18 : 12,
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
    required bool isLiteMode,
  }) {
    final isSelected = currentIndex == index;

    // Lite Mode Styles
    final activeColor = isLiteMode ? Colors.yellow : const Color(0xFFE50914);
    final inactiveColor = isLiteMode ? Colors.white : Colors.grey[400];
    final fontSize = isLiteMode ? 26.0 : 16.0;
    final iconSize = isLiteMode ? 36.0 : 24.0;
    final verticalPadding = isLiteMode ? 12.0 : 4.0;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? activeColor : inactiveColor,
        size: iconSize,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (isLiteMode ? Colors.yellow : Colors.white)
              : inactiveColor,
          fontSize: fontSize,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: activeColor.withAlpha(
          25), // withValues(alpha: 0.1) replacement for older flutter if needed, but keeping simple
      onTap: () {
        onItemTapped(index);
        Navigator.pop(context); // Close drawer
      },
      contentPadding:
          EdgeInsets.symmetric(horizontal: 24, vertical: verticalPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
