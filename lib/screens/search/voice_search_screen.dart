import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';

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
      paint.color =
          color.withValues(alpha: 0.5 + (amplitude * 0.5).clamp(0.0, 0.5));

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
  Movie? _matchedMovie;
  final MovieService _movieService = MovieService();
  bool _isNavigating = false;
  Timer? _navigationTimer;

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
    // 1. Check permission status first to avoid unnecessary popups
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _text = '설정에서 마이크 권한을 켜주세요.';
          _isListening = false;
        });
        // Optional: show a dialog or button to openAppSettings()
        Future.delayed(const Duration(seconds: 2), () {
          openAppSettings();
        });
      }
      return;
    }

    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _text = '마이크 권한이 필요합니다.';
          _isListening = false;
        });
      }
      return;
    }

    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
            if (_text != '듣고 있습니다...' &&
                _text.isNotEmpty &&
                !_text.startsWith('오류')) {
              // Only navigate if we're not already doing so
              if (!_isNavigating) {
                _navigateToResults(_text);
              }
            }
          }
        },
        onError: (errorNotification) {
          if (mounted) {
            String errorMsg = errorNotification.errorMsg;
            if (errorMsg == 'network' && kIsWeb) {
              errorMsg =
                  '네트워크 상의 이유로 인식을 시작할 수 없습니다. 인터넷 연결을 확인하거나 잠시 후 다시 시도해 주세요.';
            }
            setState(() {
              _text = '오류: $errorMsg';
              _isListening = false;
            });
          }
        },
      );

      if (available) {
        // Find Korean locale safely
        var systemLocale = await _speech.systemLocale();
        var locales = await _speech.locales();

        String targetLocaleId =
            kIsWeb ? 'ko-KR' : 'ko_KR'; // Web usually uses hyphen

        if (locales.isNotEmpty) {
          try {
            var found = locales.firstWhere(
              (locale) => locale.localeId.contains('ko'),
              orElse: () => systemLocale ?? locales.first,
            );
            targetLocaleId = found.localeId;
          } catch (e) {
            // Fallback if anything goes wrong during selection
            if (systemLocale != null) {
              targetLocaleId = systemLocale.localeId;
            } else if (locales.isNotEmpty) {
              targetLocaleId = locales.first.localeId;
            }
          }
        } else if (systemLocale != null) {
          targetLocaleId = systemLocale.localeId;
        }

        if (mounted) {
          setState(() {
            _isListening = true;
            _text = '말씀해주세요...';
          });
        }

        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _text = val.recognizedWords;
              });
              _searchMovie(_text);

              // If it's the final result, navigate immediately
              if (val.finalResult && !_isNavigating) {
                _navigateToResults(_text);
              }
            }
          },
          localeId: targetLocaleId,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 10),
          // cancelOnError: true, // Deprecated in 6.x
          // listenMode: stt.ListenMode.search, // Deprecated in 6.x
        );
      } else {
        if (mounted) {
          setState(() {
            _text = '기기가 음성 인식을 지원하지 않습니다.';
            _isListening = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _text = '초기화 오류: $e';
          _isListening = false;
        });
      }
    }
  }

  Future<void> _searchMovie(String query) async {
    if (query.length < 2) return;

    try {
      final results = await _movieService.searchMovies(query);
      if (results.isNotEmpty) {
        if (mounted) {
          setState(() {
            _matchedMovie = results.first;
          });
        }

        // Reset and start timer for automatic navigation when a match is found
        _navigationTimer?.cancel();
        if (!_isNavigating) {
          _navigationTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted && !_isNavigating && _matchedMovie != null) {
              _navigateToResults(_text);
            }
          });
        }

        // 2글자 이상 일치하면 즉시 결과 화면으로 이동 (사용자 요청)
        if (query.length >= 2) {
          _navigateToResults(query);
        }
      }
    } catch (e) {
      // Ignore search errors during voice recognition
    }
  }

  void _navigateToResults(String resultText) {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    _navigationTimer?.cancel();

    // Stop speech if still listening
    if (_isListening) {
      _speech.stop();
    }

    // Brief delay for UX so user can see the poster if matched
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pop(context, resultText);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
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
                                color: const Color(0xFFE50914)
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            Container(
                              width: 120 * (_pulseAnimation.value * 0.85),
                              height: 120 * (_pulseAnimation.value * 0.85),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE50914)
                                    .withValues(alpha: 0.4),
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
                                          .withValues(alpha: 0.6),
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

                  const SizedBox(height: 32),

                  // Movie Poster Result
                  if (_matchedMovie != null)
                    Container(
                      height: 180,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _matchedMovie!.posterUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE50914),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 180),

                  const SizedBox(height: 24),

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
