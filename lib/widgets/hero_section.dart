import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie/movie_detail_screen.dart';

class HeroSection extends StatelessWidget {
  final Movie? movie;
  final bool isLoading;

  const HeroSection({
    super.key,
    this.movie,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || movie == null) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    final heroMovie = movie!;

    return SizedBox(
      height: 450,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(movie: heroMovie),
                ),
              );
            },
            child: Image.network(
              heroMovie.posterUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[900],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie, size: 50, color: Colors.white24),
                    SizedBox(height: 8),
                    Text('이미지를 불러올 수 없습니다',
                        style: TextStyle(color: Colors.white24, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),

          // 2. Gradient Overlay (Bottom and Top)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF0A0A0A).withValues(alpha: 0.0),
                  const Color(0xFF0A0A0A).withValues(alpha: 0.0),
                  const Color(0xFF0A0A0A).withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // 3. Content
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroMovie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28, // Slighly smaller to avoid overflow
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                if (heroMovie.description != null &&
                    heroMovie.description!.isNotEmpty)
                  Text(
                    heroMovie.description!,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movie: heroMovie),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded,
                          color: Colors.black),
                      label: const Text('재생',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movie: heroMovie),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      label: const Text('상세 정보',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
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
}
