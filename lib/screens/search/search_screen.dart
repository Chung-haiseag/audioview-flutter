import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../services/smart_search_service.dart';
import '../movie/movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MovieService _movieService = MovieService();
  final SmartSearchService _smartSearch = SmartSearchService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Smart Search states
  bool _isSmartSearchEnabled = false;
  List<String> _aiKeywords = [];
  bool _isAnalyzing = false;

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
        _aiKeywords = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _aiKeywords = [];
    });

    try {
      List<Movie> results = [];

      if (_isSmartSearchEnabled && _smartSearch.isAvailable) {
        setState(() => _isAnalyzing = true);
        // AI 의도 분석
        final keywords = await _smartSearch.analyzeQuery(query);
        setState(() {
          _aiKeywords = keywords;
          _isAnalyzing = false;
        });

        // 분석된 키워드들로 검색 결과 취합
        Set<Movie> combinedResults = {};
        for (var keyword in keywords) {
          final res = await _movieService.searchMovies(keyword);
          combinedResults.addAll(res);
        }
        results = combinedResults.toList();
      } else {
        // 일반 부분 검색
        results = await _movieService.searchMovies(query);
      }

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isAnalyzing = false;
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
      body: Column(
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
                    hintText: _isSmartSearchEnabled
                        ? '영화 분위기나 감정을 입력해보세요 (예: 슬픈 영화)'
                        : '영화, 시리즈, 배우 검색',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : const Icon(Icons.mic, color: Colors.yellow),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // Smart Search Toggle
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '스마트 AI 검색',
                      style: TextStyle(
                        color:
                            _isSmartSearchEnabled ? Colors.blue : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _isSmartSearchEnabled,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        if (value && !_smartSearch.isAvailable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('AI 검색을 위해 Gemini API 키 설정이 필요합니다.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _isSmartSearchEnabled = value;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AI Analysis Feedback
          if (_isAnalyzing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(backgroundColor: Colors.transparent),
                  SizedBox(height: 8),
                  Text(
                    'AI가 검색 의도를 분석하고 있습니다...',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Search Results
          Expanded(
            child: _isLoading && !_isAnalyzing
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _searchController.text.isEmpty
                        ? _buildRecommendationSection()
                        : _buildEmptyState()
                    : _buildResultsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    final recommendations = ['액션', '가치봄', '한국 영화', '인사이드 아웃', '데몬 헌터스', '공포'];
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
            children: recommendations
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
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.movie)),
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
