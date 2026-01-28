import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie/movie_detail_screen.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded movie data for the Hero section
    final heroMovie = Movie(
      id: 'hero_movie_01',
      title: '범죄도시4',
      year: 2024,
      country: '한국',
      duration: 109,
      genres: ['액션', '범죄'],
      description:
          '괴물형사 ‘마석도’(마동석)가 다시 돌아왔다! 대규모 온라인 불법 도박 조직을 소탕하기 위해 대한민국 광수대와 사이버팀이 뭉쳤다. 이번엔 더 커진 판, 더 강력해진 웃음으로 돌아왔다!',
      posterUrl: 'https://img.youtube.com/vi/rY2o7d-308A/hqdefault.jpg',
      hasAD: true,
      hasCC: true,
      hasMultiLang: false,
    );

    return SizedBox(
      height: 250, // Reduced height by half
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
              alignment: Alignment.center, // Thumbnails look better centered
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Image.network(
                'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=1280&auto=format&fit=crop',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie, size: 50, color: Colors.white24),
                      SizedBox(height: 8),
                      Text('이미지를 불러올 수 없습니다',
                          style:
                              TextStyle(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Gradient Overlay (Bottom to Top)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF0A0A0A), // Match scaffold background
                  const Color(0xFF0A0A0A).withValues(alpha: 0.0),
                ],
                stops: const [0.1, 0.6],
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
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  heroMovie.description ?? '',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${heroMovie.title} 재생을 시작합니다.'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFFE50914),
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
