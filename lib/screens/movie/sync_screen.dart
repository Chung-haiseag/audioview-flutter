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
  Timer? _captionTimer;
  String _statusMessage = '영화 스트림 분석 중...';
  bool _isSynced = false;
  int _captionIndex = 0;

  final List<String> _sampleCaptions = [
    "저 멀리 어둠 속에서 누군가 걸어옵니다.",
    "바람 소리가 점점 거세집니다.",
    "이곳은 예전부터 숨겨진 공간이었습니다.",
    "조심하세요, 뒤를 돌아보지 마세요.",
    "문이 끼익 소리를 내며 열립니다.",
    "우리는 이미 늦었을지도 모릅니다.",
    "하지만 아직 희망은 남아있습니다.",
    "빛이 서서히 어둠을 몰아냅니다."
  ];

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
          _statusMessage = '동기화 완료';
          _progressTimer?.cancel();
          _onSyncComplete();
        }
      });
    });
  }

  void _onSyncComplete() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isSynced = true;
      if (widget.syncType == 'CC') {
        _startCaptionSimulation();
      }
    });
  }

  void _startCaptionSimulation() {
    _captionTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _captionIndex = (_captionIndex + 1) % _sampleCaptions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    _captionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show the minimal UI (both AD and CC)
    final bool isSyncedMinimalUI = _isSynced;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Close button (Subtle when synced)
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
                      color: Colors.grey[900]?.withOpacity(isSyncedMinimalUI ? 0.3 : 1.0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(isSyncedMinimalUI ? 0.3 : 1.0),
                      size: 24,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isSyncedMinimalUI) ...[
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
                                  (_isSynced ? Colors.green : Colors.red).withValues(alpha: 0.1),
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
                                  (_isSynced ? Colors.green : Colors.red).withValues(alpha: 0.4),
                                  (_isSynced ? Colors.green : Colors.red).withValues(alpha: 0.2),
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
                                  color: _isSynced ? Colors.green : Colors.red,
                                ),
                              );
                            },
                          ),

                          // Percentage or Synced Icon
                          if (!_isSynced)
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
                            )
                          else
                            const Positioned(
                              bottom: 40,
                              child: Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 64,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      _isSynced ? '실시간 동기화 완료' : '실시간 동기화 중',
                      style: TextStyle(
                        color: _isSynced ? Colors.green : Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],

                  // Subtitle / Status / Captions
                  if (!_isSynced)
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else if (widget.syncType == 'AD') ...[
                    // Minimal AD UI
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.graphic_eq, color: Colors.green, size: 24),
                          SizedBox(width: 12),
                          Text(
                            "화면해설 중",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "동기화 종료",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else
                    // Large caption on black background
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      width: double.infinity,
                      child: Text(
                        _sampleCaptions[_captionIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (!isSyncedMinimalUI) ...[
                    const SizedBox(height: 60),

                    // Progress Bar (Only during sync)
                    if (!_isSynced)
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
                ],
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
  final Color color;

  AudioBarsPainter({required this.animation, this.color = Colors.red});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
    return animation != oldDelegate.animation || color != oldDelegate.color;
  }
}
