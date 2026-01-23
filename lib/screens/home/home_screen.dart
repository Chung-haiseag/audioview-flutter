import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
// import '../../services/firestore_seeder.dart'; // import removed
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
                  // ... (existing code)
                  return GestureDetector(
                    onTap: () {
                      // ...
                    },
                    child: Container(
                        // ...
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
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('오류 발생: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red)));
                    }
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
