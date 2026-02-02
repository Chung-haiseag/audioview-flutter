import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme.dart';

class VoiceHomeScreen extends StatefulWidget {
  const VoiceHomeScreen({super.key});

  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Text
            Text(
              _isListening ? "듣고 있어요..." : "마이크를 눌러 말씀해주세요",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),

            // Microphone Button with Ripple Effect
            Center(
              child: GestureDetector(
                onTap: _toggleListening,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isListening)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            width: 200 + (_controller.value * 50),
                            height: 200 + (_controller.value * 50),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.brandRed
                                  .withOpacity(0.3 - (_controller.value * 0.2)),
                            ),
                          );
                        },
                      ),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? AppTheme.brandRed
                            : const Color(0xFF1E1E1E),
                        border: Border.all(
                          color: AppTheme.brandRed,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brandRed.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.mic,
                        size: 80,
                        color: _isListening ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Instructional Text (High Contrast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "영화 검색, 상영 시간표 확인 등\n원하는 기능을 말씀해주세요.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
