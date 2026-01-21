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
      // Make height change more dramatic
      final barHeight = height * amplitude * 0.8;

      final x = i * itemWidth + spacing / 2;
      // Center vertically
      final y = (height - barHeight) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, itemWidth - spacing, barHeight),
        const Radius.circular(4),
      );

      // Add gradient opacity based on amplitude
      paint.color = color.withOpacity(0.5 + (amplitude * 0.5).clamp(0.0, 0.5));

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
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<double> _amplitudes = List.generate(20, (index) => 0.1);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )
      ..addListener(() {
        setState(() {
          for (int i = 0; i < _amplitudes.length; i++) {
            // More dynamic wave movement
            final target = 0.1 + _random.nextDouble() * 0.9;
            _amplitudes[i] = _amplitudes[i] * 0.7 + target * 0.3;
          }
        });
      })
      ..repeat();

    // Pulse animation for microphone
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                  // Animated Microphone with Pulse Effect
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow rings
                          Container(
                            width: 120 * _pulseAnimation.value,
                            height: 120 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE50914).withOpacity(0.2),
                            ),
                          ),
                          Container(
                            width: 120 * (_pulseAnimation.value * 0.85),
                            height: 120 * (_pulseAnimation.value * 0.85),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE50914).withOpacity(0.4),
                            ),
                          ),
                          // Main microphone circle
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE50914),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFE50914).withOpacity(0.6),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 60),

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
                    height: 80,
                    width: 240,
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
