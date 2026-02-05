import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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

  /// 한국어 나레이션을 중첩 없이 안내합니다.
  void _announce(String message, {bool interrupt = false}) {
    // ignore: deprecated_member_use
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: interrupt ? Assertiveness.assertive : Assertiveness.polite,
    );
  }


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
                    label: '공지사항',
                    index: 5, // NoticeListScreen index in MainScreen
                    context: context,
                    isLiteMode: isLiteMode,
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.headphones,
                    label: '고객센터',
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
              child: Semantics(
                label: "버전 1.0.0",
                excludeSemantics: true,
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isLiteMode ? 18 : 12,
                  ),
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

    // 접근성 라벨 구성
    String accessibilityLabel = label;
    if (isSelected) {
      accessibilityLabel += ", 현재 선택됨";
    }

    return Semantics(
      label: accessibilityLabel,
      hint: isSelected ? null : "선택하려면 두 번 탭하세요",
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          _announce("$label 선택됨", interrupt: true);
          onItemTapped(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: verticalPadding + 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: iconSize,
                semanticLabel: null, // 아이콘 시맨틱 라벨 제거
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isLiteMode ? Colors.yellow : Colors.white)
                      : inactiveColor,
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
