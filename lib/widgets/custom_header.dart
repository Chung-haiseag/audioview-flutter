import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool isSubPage;
  final String? customTitle;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;
  final VoidCallback? onSearchPressed; // Added callback
  final VoidCallback? onBackPressed;

  const CustomHeader({
    super.key,
    required this.isSubPage,
    this.customTitle,
    required this.brightness,
    required this.onBrightnessChanged,
    this.onSearchPressed, // Added parameter
    this.onBackPressed,
  });

  @override
  State<CustomHeader> createState() => _CustomHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

class _CustomHeaderState extends State<CustomHeader> {
  bool _showBrightness = false;

  String _getSemanticLabel(String text) {
    switch (text.toUpperCase()) {
      case 'AUDIOVIEW':
        return 'AudioView';
      case '공지사항':
        return '공지사항';
      case '마이페이지':
        return '마이 페이지';
      case '오늘의 관람':
        return '오늘의 관람'; // Spacing seems fine, but explicit is good
      case '장르':
        return '장르';
      case '고객센터':
        return '고객센터';
      case '검색':
        return '검색';
      default:
        return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141414),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 68,
              child: Row(
                children: [
                  // Left side - Back button or Menu button
                  SizedBox(
                    width: 60,
                    child: Semantics(
                      label: widget.isSubPage && widget.onBackPressed != null
                          ? "뒤로 가기"
                          : "메뉴",
                      excludeSemantics: true,
                      child: IconButton(
                        icon: Icon(
                          widget.isSubPage && widget.onBackPressed == null
                              ? LucideIcons.menu
                              : (widget.isSubPage
                                  ? LucideIcons.chevronLeft
                                  : LucideIcons.menu),
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          if (widget.isSubPage &&
                              widget.onBackPressed != null) {
                            widget.onBackPressed!();
                          } else if (widget.isSubPage &&
                              widget.onBackPressed == null) {
                            Scaffold.of(context).openDrawer();
                          } else {
                            Scaffold.of(context).openDrawer();
                          }
                        },
                      ),
                    ),
                  ),

                  // Center - Title
                  Expanded(
                    child: Center(
                      child: widget.customTitle != null
                          ? Text(
                              widget.customTitle!,
                              semanticsLabel:
                                  _getSemanticLabel(widget.customTitle!),
                              style: const TextStyle(
                                color: Color(0xFFE50914),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            )
                          : const Text(
                              'AudioView',
                              semanticsLabel: 'AudioView',
                              style: TextStyle(
                                color: Color(0xFFE50914),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                    ),
                  ),

                  // Right side - Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search button (New)
                      if (widget.onSearchPressed != null)
                        SizedBox(
                          width: 48,
                          child: Semantics(
                            label: "영화검색",
                            excludeSemantics: true,
                            child: IconButton(
                              icon: const Icon(
                                LucideIcons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: widget.onSearchPressed,
                            ),
                          ),
                        ),
                      // Brightness button
                      SizedBox(
                        width: 48, // Adjusted width slightly
                        child: Semantics(
                          label: _showBrightness ? "밝기 조절 닫기" : "밝기 조절",
                          excludeSemantics: true,
                          child: IconButton(
                            icon: Icon(
                              LucideIcons.sun,
                              color: _showBrightness
                                  ? const Color(0xFFE50914)
                                  : Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _showBrightness = !_showBrightness;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Right Padding
                    ],
                  ),
                ],
              ),
            ),

            // Brightness slider
            if (_showBrightness)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                color: const Color(0xFF141414),
                child: Row(
                  children: [
                    Semantics(
                      label: "어둡게",
                      excludeSemantics: true,
                      child: const Icon(LucideIcons.moon, size: 18, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        label: "화면 밝기 조절 슬라이더, 현재 ${widget.brightness.round()}%",
                        slider: true,
                        value: "${widget.brightness.round()}%",
                        increasedValue: "${(widget.brightness + 10).clamp(10, 100).round()}%",
                        decreasedValue: "${(widget.brightness - 10).clamp(10, 100).round()}%",
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: const Color(0xFFE50914),
                            inactiveTrackColor: Colors.grey[600],
                            thumbColor: const Color(0xFFE50914),
                            overlayColor:
                                const Color(0xFFE50914).withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: widget.brightness,
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: "${widget.brightness.round()}%",
                            onChanged: widget.onBrightnessChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      label: "밝게",
                      excludeSemantics: true,
                      child: const Icon(LucideIcons.sun, size: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
