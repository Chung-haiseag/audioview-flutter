import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/movie.dart';
import '../../constants/mock_data.dart';
import 'sync_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background with blurred movie posters
          Positioned.fill(
            child: Stack(
              children: [
                // Grid of movie posters
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.67,
                  ),
                  itemCount: mockMovies.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(mockMovies[index].posterUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                // Blur effect
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
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
                    onPressed: () {},
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
                  movie.title,
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
                      '${movie.year}',
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
                    const SizedBox(width: 12),
                    Text(
                      '${movie.duration}분',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                      isEnabled: movie.hasAD,
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
                      isEnabled: movie.hasCC,
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
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
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
    );
  }
}
