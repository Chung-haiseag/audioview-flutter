import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';

class SyncScreen extends StatefulWidget {
  final String syncType; // 'AD' or 'CC'

  const SyncScreen({
    super.key,
    required this.syncType,
  });

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  Timer? _progressTimer;
  String _statusMessage = '영화 스트림 분석 중...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _startSimulatedProgress();
  }

  void _startSimulatedProgress() {
    const duration = Duration(milliseconds: 50);
    _progressTimer = Timer.periodic(duration, (timer) {
      setState(() {
        if (_progress < 0.3) {
          _progress += 0.005;
          _statusMessage = '영화 스트림 분석 중...';
        } else if (_progress < 0.7) {
          _progress += 0.008;
          _statusMessage = '${widget.syncType == 'AD' ? '화면해설' : '문자해설'} 다운로드 중...';
        } else if (_progress < 1.0) {
          _progress += 0.012;
          _statusMessage = '최적의 자원을 설정하는 중...';
        } else {
          _progress = 1.0;
          _statusMessage = '완료되었습니다!';
          _progressTimer?.cancel();
          _onSyncComplete();
        }
      });
    });
  }

  void _onSyncComplete() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('동기화가 완료되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated audio visualizer
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer gradient circle
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.red.withValues(alpha: 0.3),
                              Colors.red.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Middle gradient circle
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.red.withValues(alpha: 0.4),
                              Colors.red.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),

                      // Audio bars animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(120, 80),
                            painter: AudioBarsPainter(
                              animation: _controller.value,
                            ),
                          );
                        },
                      ),

                      // Percentage text
                      Positioned(
                        bottom: 40,
                        child: Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  '실시간 동기화 중',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle / Status Message
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[900],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioBarsPainter extends CustomPainter {
  final double animation;

  AudioBarsPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    const barCount = 7;
    const barWidth = 8.0;
    const spacing = 6.0;
    const totalWidth = (barCount * barWidth) + ((barCount - 1) * spacing);
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < barCount; i++) {
      // Create wave effect with different phases for each bar
      final phase = (animation * 2 * math.pi) + (i * math.pi / 4);
      final heightFactor = (math.sin(phase).abs() * 0.6) + 0.4;

      final barHeight = size.height * heightFactor;
      final x = startX + (i * (barWidth + spacing));
      final y = (size.height - barHeight) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioBarsPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
