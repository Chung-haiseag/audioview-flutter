import 'package:flutter/material.dart';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '듣고 있습니다...';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )
      ..addListener(() {
        setState(() {
          for (int i = 0; i < _amplitudes.length; i++) {
            // More dynamic wave movement based on listening state
            double target = 0.1;
            if (_isListening) {
              target = 0.1 + _random.nextDouble() * 0.9;
            }
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

    // Start listening automatically
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // Request microphone permission specifically
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() {
        _text = '마이크 권한이 필요합니다.';
        _isListening = false;
      });
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        // print('onStatus: $status');
        if (status == 'notListening') {
          setState(() => _isListening = false);
          // If speech recognition stopped and we have text, return it
          if (_text != '듣고 있습니다...' && _text.isNotEmpty) {
            // Optionally auto-pop here, or wait for user to press confirm
            // For now, let's wait a bit and pop
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) Navigator.pop(context, _text);
            });
          }
        }
      },
      onError: (errorNotification) {
        // print('onError: $errorNotification');
        setState(() {
          _text = '오류가 발생했습니다. 다시 시도해주세요.';
          _isListening = false;
        });
      },
    );

    if (available) {
      if (mounted) setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (mounted) {
            setState(() {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });
          }
        },
        localeId: 'ko_KR', // Korean locale
        pauseFor: const Duration(seconds: 2), // Wait 2s silence before stopping
      );
    } else {
      if (mounted) {
        setState(() {
          _text = '음성 인식을 사용할 수 없습니다.';
          _isListening = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          if (_isListening) ...[
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
                          ],
                          // Main microphone circle
                          GestureDetector(
                            onTap: () {
                              if (_isListening) {
                                _speech.stop(); // Stop listening
                              } else {
                                _initSpeech(); // Start listening
                              }
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? const Color(0xFFE50914)
                                    : Colors.grey[800],
                                boxShadow: [
                                  if (_isListening)
                                    BoxShadow(
                                      color: const Color(0xFFE50914)
                                          .withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_off,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      _text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _isListening ? '듣고 있습니다...' : '버튼을 눌러 다시 말씀해주세요.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Audio Visualizer
                  if (_isListening)
                    SizedBox(
                      height: 80,
                      width: 240,
                      child: CustomPaint(
                        painter: AudioVisualizerPainter(
                          amplitudes: _amplitudes,
                          color: const Color(0xFFE50914),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 80,
                      width: 240,
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
