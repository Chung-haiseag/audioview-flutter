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
      child: Column(
        children: [
          // Drawer Header
          SizedBox(
            height: 180, // Adjust height as needed
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF000000), // Slightly darker header
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF222222),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_horizontal.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'AUDIOVIEW',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

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
                  icon: LucideIcons.search,
                  label: '검색',
                  index: 2, // SearchScreen index in MainScreen
                  context: context,
                ),
                _buildDrawerItem(
                  icon: LucideIcons.download,
                  label: '보관함',
                  index: 3, // DownloadsScreen index in MainScreen
                  context: context,
                ),
                _buildDrawerItem(
                  icon: LucideIcons.settings,
                  label: '설정',
                  index: 1, // SettingsScreen index in MainScreen
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
      selectedTileColor: const Color(0xFFE50914).withOpacity(0.1),
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
