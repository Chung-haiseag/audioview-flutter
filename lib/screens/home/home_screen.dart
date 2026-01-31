import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../models/genre.dart';
import '../../models/featured_list.dart';
import '../../services/movie_service.dart';
import '../../widgets/hero_section.dart';
import '../../widgets/movie_section.dart';
import '../category/category_list_screen.dart';
import '../../widgets/shimmer_loading.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movieService = MovieService();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: StreamBuilder<List<FeaturedList>>(
          stream: movieService.getFeaturedLists(),
          builder: (context, listSnapshot) {
            final lists = listSnapshot.data ?? [];
            final firstListId = lists.isNotEmpty ? lists.first.listId : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Section (Dynamic from first list)
                if (firstListId != null)
                  StreamBuilder<List<Movie>>(
                    stream: movieService.getMoviesByFeaturedList(firstListId),
                    builder: (context, movieSnapshot) {
                      final movie = (movieSnapshot.data != null &&
                              movieSnapshot.data!.isNotEmpty)
                          ? movieSnapshot.data!.first
                          : null;
                      return HeroSection(
                        movie: movie,
                        isLoading: movieSnapshot.connectionState ==
                            ConnectionState.waiting,
                      );
                    },
                  )
                else
                  const HeroSection(isLoading: true),

                const SizedBox(height: 24),

                // 2. Category Chips
                SizedBox(
                  height: 40,
                  child: StreamBuilder<List<Genre>>(
                    stream: movieService.getGenres(),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white10,
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

                // 3. Featured Lists (Admin Managed)
                if (listSnapshot.connectionState == ConnectionState.waiting)
                  const Column(
                    children: [
                      MovieSectionShimmer(),
                      SizedBox(height: 24),
                      MovieSectionShimmer(),
                    ],
                  )
                else if (lists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        '추천 목록이 없습니다.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Column(
                    children: lists.map((list) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: StreamBuilder<List<Movie>>(
                          stream:
                              movieService.getMoviesByFeaturedList(list.listId),
                          builder: (context, movieSnapshot) {
                            if (!movieSnapshot.hasData) {
                              return const MovieSectionShimmer();
                            }

                            if (movieSnapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final displayTitle =
                                list.type != null && list.type!.isNotEmpty
                                    ? '${list.type} ${list.title}'
                                    : list.title;

                            return MovieSection(
                              title: displayTitle,
                              movies: movieSnapshot.data!,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}
