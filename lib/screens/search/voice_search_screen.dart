import 'package:flutter/material.dart';
import 'dart:math';

// Custom painter for audio visualizer
class AudioVisualizerPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  AudioVisualizerPainter({
    required this.amplitudes,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    final width = size.width;
    final height = size.height;
    final count = amplitudes.length;
    final itemWidth = width / count;
    final spacing = itemWidth * 0.4; // Space between bars

    for (int i = 0; i < count; i++) {
      final amplitude = amplitudes[i];
      final barHeight = height * amplitude;

      final x = i * itemWidth + spacing / 2;
      final y = (height - barHeight) / 2;

      // Draw rounded rectangle for better visual
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, itemWidth - spacing, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioVisualizerPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<double> _amplitudes = List.generate(20, (index) => 0.1);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )
      ..addListener(() {
        setState(() {
          // Update amplitudes randomly to simulate audio input
          for (int i = 0; i < _amplitudes.length; i++) {
            // Smoothly transition to new random value
            final target = 0.2 + _random.nextDouble() * 0.8;
            _amplitudes[i] = _amplitudes[i] * 0.8 + target * 0.2;
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full screen black background
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Muted animated rings effect (optional, simplified here)
                  // Red Microphone Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE50914), // Netflix Red
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE50914).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Status Text
                  const Text(
                    '듣고 있습니다...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '찾으시는 작품의 이름을 말씀해주세요.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Audio Visualizer
                  SizedBox(
                    height: 60,
                    width: 200,
                    child: CustomPaint(
                      painter: AudioVisualizerPainter(
                        amplitudes: _amplitudes,
                        color: const Color(0xFFE50914),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Cancel Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
