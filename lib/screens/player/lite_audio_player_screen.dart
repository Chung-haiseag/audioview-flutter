import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class LiteAudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String title;

  const LiteAudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.title,
  });

  @override
  State<LiteAudioPlayerScreen> createState() => _LiteAudioPlayerScreenState();
}

class _LiteAudioPlayerScreenState extends State<LiteAudioPlayerScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  /// 한국어 나레이션을 중첩 없이 안내합니다.
  void _announce(String message, {bool interrupt = false}) {
    // ignore: deprecated_member_use
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: interrupt ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();

    // 화면 진입 시 안내
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announce("${widget.title} 오디오 플레이어입니다. 화면 아무 곳이나 탭하여 재생과 일시정지를 전환합니다. 상단의 종료 버튼을 눌러 나갈 수 있습니다.", interrupt: true);
    });
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
          if (state.processingState == ProcessingState.completed) {
            // Optional: Rewind or Close? User didn't specify. Keeping it paused at end.
            _player.seek(Duration.zero);
            _player.pause();
          }
        }
      });
      _player.play(); // Auto-play
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "오디오를 재생할 수 없습니다.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    HapticFeedback.mediumImpact();
    if (_player.playing) {
      _player.pause();
      _announce("일시정지", interrupt: true);
    } else {
      _player.play();
      _announce("재생", interrupt: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Exit Button (Top, Large)
            Semantics(
              label: "종료",
              button: true,
              excludeSemantics: true,
              onDidGainAccessibilityFocus: () {
                _announce("종료 버튼. 두 번 탭하여 플레이어를 닫습니다.", interrupt: true);
              },
              child: SizedBox(
                width: double.infinity,
                height: 120, // Very large
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _announce("플레이어를 종료합니다.", interrupt: true);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFE50914), // Red for clear visibility
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Full width block
                    ),
                  ),
                  child: const Text(
                    '종료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Semantics(
                label: _errorMessage != null
                    ? "오류: $_errorMessage"
                    : _isLoading
                        ? "로딩 중"
                        : _isPlaying
                            ? "재생 중. 두 번 탭하여 일시정지"
                            : "일시정지. 두 번 탭하여 재생",
                button: true,
                excludeSemantics: true,
                onDidGainAccessibilityFocus: () {
                  if (_errorMessage != null) {
                    _announce("오류가 발생했습니다. $_errorMessage", interrupt: true);
                  } else if (_isLoading) {
                    _announce("오디오를 불러오는 중입니다.", interrupt: true);
                  } else {
                    _announce("${widget.title}. ${_isPlaying ? '재생 중' : '일시정지'}. 두 번 탭하여 ${_isPlaying ? '일시정지' : '재생'}합니다.", interrupt: true);
                  }
                },
                onTap: _togglePlay,
                child: GestureDetector(
                  onTap: _togglePlay, // Tap anywhere to toggle
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black, // Ensure tap area
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style:
                                const TextStyle(color: Colors.red, fontSize: 24),
                          )
                        else if (_isLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else
                          Column(
                            children: [
                              Icon(
                                _isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 100,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _isPlaying ? "재생 중" : "일시정지",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 40),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "화면을 탭하여 재생/일시정지",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
