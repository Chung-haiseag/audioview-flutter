import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/login_screen.dart';

class AccessibilityOnboardingScreen extends StatefulWidget {
  const AccessibilityOnboardingScreen({super.key});

  @override
  State<AccessibilityOnboardingScreen> createState() =>
      _AccessibilityOnboardingScreenState();
}

class _AccessibilityOnboardingScreenState
    extends State<AccessibilityOnboardingScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Slight delay to ensure screen is mounted and user is ready
    Future.delayed(const Duration(milliseconds: 800), () {
      _speakGuidance();
    });
  }

  Future<void> _speakGuidance() async {
    const text =
        "안녕하세요, AudioView입니다. 시각장애인용 모드로 이용하시려면 화면을 두 번 두드려 주세요. 일반 모드는 오른쪽으로 밀어주세요.";
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text);
    setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _selectMode(bool visuallyImpaired) async {
    await _flutterTts.stop();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);
    await prefs.setBool('is_visually_impaired_mode', visuallyImpaired);

    if (!mounted) return;

    final message = visuallyImpaired
        ? "시각장애인 모드가 활성화되었습니다. 대화형 인터페이스를 준비합니다."
        : "일반 모드로 시작합니다.";

    await _flutterTts.speak(message);

    // Navigate to Login or Main depending on your app flow
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: GestureDetector(
        onDoubleTap: () => _selectMode(true),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 500) {
            _selectMode(false);
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                const Color(0xFFE50914).withValues(alpha: 0.1),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AudioView',
                style: TextStyle(
                  color: Color(0xFFE50914),
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _isSpeaking ? const Color(0xFFE50914) : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.mic,
                  size: 64,
                  color: _isSpeaking ? const Color(0xFFE50914) : Colors.white24,
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 2.seconds,
                  color: const Color(0xFFE50914).withValues(alpha: 0.3)),
              const SizedBox(height: 64),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  '화면을 두 번 두드리면 시각장애인 모드\n오른쪽으로 밀면 일반 모드',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.6,
                  ),
                ),
              ).animate().fadeIn(delay: 1.seconds),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _speakGuidance,
                child: const Text(
                  '다시 듣기',
                  style: TextStyle(color: Color(0xFFE50914)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
