import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
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
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
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
            SizedBox(
              width: double.infinity,
              height: 120, // Very large
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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

            Expanded(
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
          ],
        ),
      ),
    );
  }
}
