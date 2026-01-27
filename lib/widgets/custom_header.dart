import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool isSubPage;
  final String? customTitle;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;
  final VoidCallback? onBackPressed; // Added callback

  const CustomHeader({
    super.key,
    required this.isSubPage,
    this.customTitle,
    required this.brightness,
    required this.onBrightnessChanged,
    this.onBackPressed, // Added parameter
  });

  @override
  State<CustomHeader> createState() => _CustomHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

class _CustomHeaderState extends State<CustomHeader> {
  bool _showBrightness = false;

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
                    child: IconButton(
                      icon: Icon(
                        widget.isSubPage
                            ? LucideIcons.chevronLeft
                            : LucideIcons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        if (widget.isSubPage) {
                          if (widget.onBackPressed != null) {
                            widget.onBackPressed!();
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        } else {
                          Scaffold.of(context).openDrawer();
                        }
                      },
                    ),
                  ),

                  // Center - Title
                  Expanded(
                    child: Center(
                      child: widget.customTitle != null
                          ? Text(
                              widget.customTitle!,
                              style: const TextStyle(
                                color: Color(0xFFE50914),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            )
                          : Image.asset(
                              'assets/images/logo_horizontal.png',
                              height: 38,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to text if image fails
                                return const Text(
                                  '오디오뷰',
                                  style: TextStyle(
                                    color: Color(0xFFE50914),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  // Right side - Brightness button
                  SizedBox(
                    width: 60,
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
                    const Icon(LucideIcons.moon, size: 18, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFFE50914),
                          inactiveTrackColor: Colors.grey[600],
                          thumbColor: const Color(0xFFE50914),
                          overlayColor:
                              const Color(0xFFE50914).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: widget.brightness,
                          min: 10,
                          max: 100,
                          onChanged: widget.onBrightnessChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.sun, size: 18, color: Colors.grey),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
