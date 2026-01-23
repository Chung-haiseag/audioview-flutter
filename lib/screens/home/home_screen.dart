import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../constants/mock_data.dart'; // Keep for categoryChips if needed
import '../../widgets/movie_card.dart';
import '../category/category_list_screen.dart';
import '../movie/movie_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Category menu (horizontal scrollable chips)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoryChips.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryListScreen(
                            categoryName: categoryChips[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categoryChips[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 새로 올라온 영화 section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '새로 올라온 영화',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 240,
              child: StreamBuilder<List<Movie>>(
                  stream: MovieService().getNewMovies(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('새로 올라온 영화가 없습니다.',
                              style: TextStyle(color: Colors.grey)));
                    }
                    final movies = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          movie: movies[index],
                          showNewBadge: true,
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
                  }),
            ),

            const SizedBox(height: 32),

            // 실시간 인기영화 section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '실시간 인기영화',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 240,
              child: StreamBuilder<List<Movie>>(
                  stream: MovieService().getPopularMovies(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('인기 영화가 없습니다.',
                              style: TextStyle(color: Colors.grey)));
                    }
                    final movies = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          movie: movies[index],
                          showNewBadge: false,
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
                  }),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
