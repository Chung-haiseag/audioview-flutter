import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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

class VoiceHomeScreen extends StatefulWidget {
  const VoiceHomeScreen({super.key});

  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen> {
  @override
  void initState() {
    super.initState();

    // 화면 로드 완료 후 안전하게 음성 안내를 시작합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceMode();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 한국어 나레이션을 중첩 없이 안내합니다.
  /// assertiveness: Assertiveness.polite (기본값) - 현재 발화 후 안내
  /// assertiveness: Assertiveness.assertive - 현재 발화를 중단하고 즉시 안내
  void _announce(String message, {bool interrupt = false}) {
    // ignore: deprecated_member_use
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: interrupt ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  Future<void> _announceMode() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _announce(
      "간편모드입니다. "
      "메뉴를 열려면 왼쪽 상단의 메뉴를, "
      "영화를 검색하려면 오른쪽 상단의 음성검색을 누르세요. "
      "아래로 스와이프하여 영화 목록을 탐색할 수 있습니다.",
      interrupt: true,
    );
  }

  void _announceMenuButton() {
    _announce("메뉴. 메뉴를 엽니다.", interrupt: true);
  }

  void _announceSearchButton() {
    _announce("음성검색. 영화를 검색합니다.", interrupt: true);
  }

  void _announceMovieItem(Movie movie) {
    _announce(movie.title, interrupt: true);
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
                builder: (context) => Semantics(
                  label: "메뉴",
                  excludeSemantics: true,
                  container: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Scaffold.of(context).openDrawer();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.menu, size: 28, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "메뉴",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Right: Voice Search Button with Mic Icon
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Semantics(
                label: "음성검색",
                excludeSemantics: true,
                container: true,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.mic, size: 28, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "음성검색",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
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
        label: title,
        excludeSemantics: true,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.yellow,
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: "",
              container: true,
              excludeSemantics: true,
              onDidGainAccessibilityFocus: () {
                _announce("목록을 불러오는데 실패했습니다.", interrupt: true);
              },
              child: ExcludeSemantics(
                child: const Text(
                  "목록을 불러오는데 실패했습니다.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: "",
              container: true,
              excludeSemantics: true,
              onDidGainAccessibilityFocus: () {
                _announce("영화 목록을 불러오는 중입니다.", interrupt: true);
              },
              child: ExcludeSemantics(
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        // Filter only AD movies
        var movies = (snapshot.data ?? []).where((m) => m.hasAD).toList();

        // Apply limit if provided
        if (limit != null) {
          movies = movies.take(limit).toList();
        }

        if (movies.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: "",
              container: true,
              excludeSemantics: true,
              onDidGainAccessibilityFocus: () {
                _announce("화면해설 영화가 없습니다.", interrupt: true);
              },
              child: ExcludeSemantics(
                child: const Text(
                  "화면해설 영화가 없습니다.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        }

        return Column(
          children: movies.map((movie) => _buildMovieTile(movie)).toList(),
        );
      },
    );
  }

  String _buildMovieLabel(Movie movie) {
    final parts = <String>[movie.title];
    if (movie.hasAD) parts.add("화면해설 지원");
    if (movie.hasCC) parts.add("한글자막 지원");
    return parts.join(", ");
  }

  Widget _buildMovieTile(Movie movie) {
    return Semantics(
      label: _buildMovieLabel(movie),
      excludeSemantics: true,
      container: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
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
