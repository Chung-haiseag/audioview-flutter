import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';
import '../movie/movie_detail_screen.dart';

import '../../models/genre.dart'; // Add import

class CategoryListScreen extends StatelessWidget {
  final Genre genre; // Changed from String categoryName

  const CategoryListScreen({
    super.key,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          genre.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<Movie>>(
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
                  Text(
                    '이 카테고리에는 아직 콘텐츠가 없습니다',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
