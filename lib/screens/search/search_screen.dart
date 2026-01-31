import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../movie/movie_detail_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Voice Search states
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final terms = await _movieService.getRecommendedSearchTerms();
    if (mounted) {
      setState(() {
        _recommendations = terms;
      });
    }
  }

  void _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );
    } catch (e) {
      debugPrint('STT Initialization failed: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                _performSearch(result.recognizedWords);
              }
            });
          },
          localeId: 'ko_KR', // Ensure Korean recognition
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다.')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _movieService.searchMovies(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              // Search Input Area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '영화, 시리즈, 배우 검색',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.blue),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                  // Always show mic icon, color changes on state
                                  Icons.mic,
                                  color:
                                      _isListening ? Colors.red : Colors.white,
                                ),
                                onPressed: _toggleListening,
                              ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Results
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                        ? _searchController.text.isEmpty
                            ? _buildRecommendationSection()
                            : _buildEmptyState()
                        : _buildResultsGrid(),
              ),
            ],
          ),

          // Voice Listening Overlay
          if (_isListening)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 80,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '듣고 있어요...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _toggleListening,
                      child: const Text('취소',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                '추천 검색어',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendations
                .map((tag) => ActionChip(
                      label: Text(tag),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: () {
                        _searchController.text = tag;
                        _performSearch(tag);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter,
              size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            '찾으시는 영화가 없나요?',
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '입력하신 검색어 \'${_searchController.text}\'와(과)\n일치하는 결과가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: const Text('작품 요청하기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: movie),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.grey[900], // Fallback background
                    child: movie.posterUrl.isNotEmpty
                        ? Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.movie,
                                        color: Colors.white54)),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              // Avoid division by zero or null
                              final total = loadingProgress.expectedTotalBytes;
                              final current =
                                  loadingProgress.cumulativeBytesLoaded;
                              final progress = (total != null && total > 0)
                                  ? current / total
                                  : null;

                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Icons.movie, color: Colors.white54)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
