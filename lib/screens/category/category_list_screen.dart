import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';
import '../movie/movie_detail_screen.dart';
import '../../widgets/custom_header.dart';
import '../../widgets/custom_drawer.dart';

import '../../models/genre.dart'; // Add import

class CategoryListScreen extends StatelessWidget {
  final Genre genre; // Changed from String categoryName

  const CategoryListScreen({
    super.key,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Local state for brightness to work with CustomHeader
        double brightness = 100.0; // Default

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          drawer: CustomDrawer(
            currentIndex: 4, // 장르 선택된 상태로 표시
            onItemTapped: (index) {
              // 메인 화면으로 돌아가서 인덱스 변경 (MainScreen 로직에 맡김)
              Navigator.pop(context); // 드로어 닫기
              Navigator.pop(context); // 장르 서브메뉴 닫기
            },
          ),
          body: Column(
            children: [
              Builder(
                builder: (context) => CustomHeader(
                  isSubPage: true,
                  customTitle: genre.name,
                  brightness: brightness,
                  onBrightnessChanged: (value) {
                    setState(() {
                      brightness = value;
                    });
                  },
                  onBackPressed: null, // Shows hamburger menu
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Movie>>(
                  stream: MovieService().getMoviesByGenre(genre),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '오류가 발생했습니다',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    final movies = snapshot.data ?? [];

                    if (movies.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_outlined,
                              size: 64,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '이 카테고리에는 아직 콘텐츠가 없습니다',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.67,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          movie: movies[index],
                          showNewBadge: false,
                          removeMargin: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailScreen(
                                  movie: movies[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
