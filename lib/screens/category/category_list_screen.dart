import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../constants/mock_data.dart';
import '../../widgets/movie_card.dart';

class CategoryListScreen extends StatelessWidget {
  final String categoryName;

  const CategoryListScreen({
    super.key,
    required this.categoryName,
  });

  List<Movie> _getMoviesByCategory() {
    // Filter movies by category (check if category name is in genres)
    final filteredMovies = mockMovies.where((movie) {
      return movie.genres
          .any((genre) => genre.toLowerCase() == categoryName.toLowerCase());
    }).toList();

    // Return up to 5 movies
    return filteredMovies.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final movies = _getMoviesByCategory();

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
          categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: movies.isEmpty
          ? Center(
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
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: movies[index],
                    showNewBadge:
                        index < 2, // Show NEW badge for first 2 movies
                  );
                },
              ),
            ),
    );
  }
}
