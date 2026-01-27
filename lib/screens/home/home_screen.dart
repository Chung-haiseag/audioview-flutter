import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../models/genre.dart';
import '../../services/movie_service.dart';
import '../../widgets/hero_section.dart';
import '../../widgets/movie_section.dart';
import '../category/category_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero, // Remove default padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Section (New)
            const HeroSection(),

            const SizedBox(height: 24),

            // 2. Category Chips (Existing but styled)
            SizedBox(
              height: 40,
              child: StreamBuilder<List<Genre>>(
                stream: MovieService().getGenres(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final genres = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryListScreen(genre: genre),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.white24, width: 1), // Removed border for cleaner look
                            color: Colors.white10, // Filled style
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // 3. New Movies Section
            StreamBuilder<List<Movie>>(
                stream: MovieService().getNewMovies(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  return MovieSection(
                      title: '새로 올라온 영화', movies: snapshot.data!);
                }),

            const SizedBox(height: 24),

            // 4. Popular Movies Section
            StreamBuilder<List<Movie>>(
                stream: MovieService().getPopularMovies(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return MovieSection(
                      title: '실시간 인기영화', movies: snapshot.data!);
                }),

            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}
