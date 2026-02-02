import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';
import '../movie/movie_detail_screen.dart';

class VoiceHomeScreen extends StatefulWidget {
  const VoiceHomeScreen({super.key});

  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final movieService = Provider.of<MovieService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "간편 모드",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionTitle("추천 영화"),
          _buildMovieSection(movieService.getPopularMovies()),
          const SizedBox(height: 40),
          _buildSectionTitle("신규 영화"),
          _buildMovieSection(movieService.getNewMovies()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.yellow, // High contrast
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMovieSection(Stream<List<Movie>> movieStream) {
    return StreamBuilder<List<Movie>>(
      stream: movieStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("목록을 불러오는데 실패했습니다.",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // Filter only AD movies
        final movies = (snapshot.data ?? []).where((m) => m.hasAD).toList();

        if (movies.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("화면해설 영화가 없습니다.",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        }

        return Column(
          children: movies.map((movie) => _buildMovieTile(movie)).toList(),
        );
      },
    );
  }

  Widget _buildMovieTile(Movie movie) {
    return Semantics(
      label: "${movie.title}, ${movie.duration}분",
      button: true,
      hint: "두 번 탭하면 상세 정보를 확인합니다.",
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "${movie.duration}분",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
