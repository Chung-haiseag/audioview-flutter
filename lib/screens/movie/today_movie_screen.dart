import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';

class TodayMovieScreen extends StatefulWidget {
  const TodayMovieScreen({super.key});

  @override
  State<TodayMovieScreen> createState() => _TodayMovieScreenState();
}

class _TodayMovieScreenState extends State<TodayMovieScreen> {
  List<Map<String, dynamic>> _todayMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final String? moviesJson = prefs.getString('today_movies');
    if (moviesJson != null) {
      setState(() {
        _todayMovies = List<Map<String, dynamic>>.from(jsonDecode(moviesJson));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMovies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('today_movies', jsonEncode(_todayMovies));
  }

  void _addMovie() {
    // For MVP, we'll simulate adding a movie.
    // In production, this should navigate to SearchScreen or pick from Home.
    if (_todayMovies.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘의 관람 영화는 최대 2개까지만 등록 가능합니다.')),
      );
      return;
    }

    // Dummy movie data for demonstration
    final newMovie = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': '새로운 영화 ${_todayMovies.length + 1}',
      'posterUrl':
          'https://image.tmdb.org/t/p/w500/1E5baAaEse26fej7uHkjJDveYo_._V1_FMjpg_UX1000_.jpg', // Placeholder
      'releaseDate': '2024-02-02',
      'isDownloaded': false,
    };

    setState(() {
      _todayMovies.add(newMovie);
    });
    _saveMovies();
  }

  void _removeMovie(int index) {
    setState(() {
      _todayMovies.removeAt(index);
    });
    _saveMovies();
  }

  void _simulateDownload(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('보조 콘텐츠 다운로드를 시작합니다...')),
    );

    // Simulate caching/downloading logic
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _todayMovies[index]['isDownloaded'] = true;
        });
        _saveMovies();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('다운로드가 완료되었습니다. 오프라인에서 재생 가능합니다.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    if (isLiteMode) {
      return _buildLiteModeUI(context);
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오프라인 관람 준비',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '극장 방문 전, 보조 콘텐츠(해설/자막)를 미리 다운로드하세요.\n최대 2편까지 저장할 수 있습니다.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Movie Slots
                  Expanded(
                    child: _todayMovies.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _todayMovies.length,
                            itemBuilder: (context, index) {
                              final movie = _todayMovies[index];
                              return _buildMovieCard(movie, index);
                            },
                          ),
                  ),

                  // Add Button (if slots available)
                  if (_todayMovies.length < 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addMovie,
                          icon:
                              const Icon(LucideIcons.plus, color: Colors.black),
                          label: const Text('영화 추가하기',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFE50914), // Brand color
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.film, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            '등록된 영화가 없습니다.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 눌러 관람할 영화를 추가하세요.',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie, int index) {
    bool isDownloaded = movie['isDownloaded'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[900]!),
      ),
      child: Row(
        children: [
          // Poster (Placeholder)
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Container(
              width: 100,
              height: 150,
              color: Colors.grey[800],
              child: const Icon(Icons.movie, color: Colors.white24, size: 40),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          movie['title'] ?? '제목 없음',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x,
                            color: Colors.grey, size: 20),
                        onPressed: () => _removeMovie(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '관람 예정일: ${movie['releaseDate']}', // Placeholder data
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Download Status/Action
                  isDownloaded
                      ? Row(
                          children: [
                            const Icon(LucideIcons.checkCircle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '다운로드 완료',
                              style: TextStyle(
                                  color: Colors.green[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _simulateDownload(index),
                            icon: const Icon(LucideIcons.download,
                                size: 16, color: Colors.white),
                            label: const Text('보조 콘텐츠 다운로드',
                                style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildLiteModeUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/main', (route) => false);
                }
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
                  Icon(Icons.arrow_back, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "뒤로가기",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todayMovies.isEmpty
              ? const Center(
                  child: Text(
                    '등록된 영화가 없습니다',
                    style: TextStyle(color: Colors.grey, fontSize: 24),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: _todayMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _todayMovies[index];
                    return _buildLiteModeMovieItem(movie, index);
                  },
                ),
    );
  }

  Widget _buildLiteModeMovieItem(Map<String, dynamic> movie, int index) {
    return Semantics(
      label: movie['title'] ?? '제목 없음',
      button: true,
      child: InkWell(
        onTap: () {
          // Optional: Navigate to movie detail if needed
        },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Text(
            movie['title'] ?? '제목 없음',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
