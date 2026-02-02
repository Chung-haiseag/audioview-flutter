import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../models/movie.dart';
import 'sync_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double _brightness = 0.5; // 0.0 (어두움) ~ 1.0 (밝음)

  void _showBrightnessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.brightness_low,
                        color: Colors.grey,
                        size: 24,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.red,
                            inactiveTrackColor: Colors.grey[700],
                            thumbColor: Colors.red,
                            overlayColor: Colors.red.withValues(alpha: 0.2),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _brightness,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              setDialogState(() {
                                _brightness = value;
                              });
                              setState(() {
                                _brightness = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.brightness_high,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '밝기: ${(_brightness * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background with blurred movie poster
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Current movie poster background
                CachedNetworkImage(
                  imageUrl: widget.movie.posterUrl,
                  fit: BoxFit.cover,
                  memCacheWidth:
                      600, // Slightly improved quality for background but still optimized
                  placeholder: (context, url) => Container(color: Colors.black),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.black),
                ),
                // Blur effect
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.black
                        .withValues(alpha: 0.5 + (_brightness * 0.3)),
                  ),
                ),
              ],
            ),
          ),

          // Top bar with back button and brightness
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    '영화선택',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.wb_sunny_outlined,
                        color: Colors.white, size: 28),
                    onPressed: () => _showBrightnessDialog(context),
                  ),
                ],
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Movie title
                Text(
                  widget.movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Year and HD badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.movie.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.movie.duration}분',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Director and Actors
                if (widget.movie.director != null &&
                    widget.movie.director!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      '감독: ${widget.movie.director}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (widget.movie.actors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 4),
                    child: Text(
                      '출연: ${widget.movie.actors.join(", ")}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 40),

                // AD and CC buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AD button
                    _buildAccessibilityButton(
                      icon: Icons.record_voice_over,
                      label: '화면해설(AD)',
                      isEnabled: widget.movie.hasAD,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SyncScreen(
                              syncType: 'AD',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 16),

                    // CC button
                    _buildAccessibilityButton(
                      icon: Icons.closed_caption,
                      label: '문자해설(CC)',
                      isEnabled: widget.movie.hasCC,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SyncScreen(
                              syncType: 'CC',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color:
                isEnabled ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isEnabled ? const Color(0xFF404040) : const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.grey[700],
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
