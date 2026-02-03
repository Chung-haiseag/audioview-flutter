import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';
import '../movie/movie_detail_screen.dart';
import '../../widgets/custom_drawer.dart';
import '../search/search_screen.dart';
import '../category/genre_list_screen.dart';
import '../settings/settings_screen.dart';
import '../downloads/downloads_screen.dart';
import '../notice/notice_list_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceHomeScreen extends StatefulWidget {
  const VoiceHomeScreen({super.key});

  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _announceMode();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _announceMode() async {
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak("간편모드");
  }

  @override
  Widget build(BuildContext context) {
    final movieService = Provider.of<MovieService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: CustomDrawer(
        currentIndex: -1, // No active tab in Lite Mode
        onItemTapped: (index) {
          Navigator.pop(context); // Close drawer first
          _handleDrawerNavigation(index);
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Menu Button with Hamburger Icon
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(60, 48),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.menu, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "메뉴",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Right: Voice Search Button with Mic Icon
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 48),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.mic, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "음성검색",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionTitle("신규 영화"),
          _buildMovieSection(movieService.getNewMovies(), limit: 3),
          const SizedBox(height: 40),
          _buildSectionTitle("추천 영화"),
          _buildMovieSection(movieService.getPopularMovies(), limit: 4),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _handleDrawerNavigation(int index) {
    // Wait for drawer to close before navigating
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      Widget? page;
      switch (index) {
        case 0: // Home - Go to MainScreen (Lite Mode Home)
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          return;
        case 1: // Genre
          page = const GenreListScreen();
          break;
        case 2: // Settings
          page = const SettingsScreen();
          break;
        case 3: // Search (If accessible from drawer)
          page = const SearchScreen();
          break;
        case 4: // My Page
          page = const MyPageScreen();
          break;
        case 5: // Notice
          page = const NoticeListScreen();
          break;
      }

      if (page != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page!),
        );
      }
    });
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

  Widget _buildMovieSection(Stream<List<Movie>> movieStream, {int? limit}) {
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
        var movies = (snapshot.data ?? []).where((m) => m.hasAD).toList();

        // Apply limit if provided
        if (limit != null) {
          movies = movies.take(limit).toList();
        }

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
      container: true,
      explicitChildNodes:
          true, // Allow children (like the intro button) to be focused separately
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
          constraints: const BoxConstraints(minHeight: 100), // Increased height
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
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
