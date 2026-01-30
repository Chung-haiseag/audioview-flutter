import 'dart:async';
import 'package:flutter/material.dart';
import 'voice_search_screen.dart';
import '../../constants/mock_data.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';
import '../movie/movie_detail_screen.dart';
import '../help/request_content_screen.dart';
import '../../services/smart_search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Movie> _searchResults = [];
  Timer? _debounce;
  bool _isSmartSearch = false;
  bool _isAIAnalyzing = false;
  final _smartSearch = SmartSearchService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _searchQuery = query;
    });

    try {
      if (_isSmartSearch && _smartSearch.isAvailable) {
        setState(() => _isAIAnalyzing = true);
        final keywords = await _smartSearch.analyzeQuery(query);

        List<Movie> allAiResults = [];
        for (var keyword in keywords) {
          final res = await MovieService().searchMovies(keyword);
          allAiResults.addAll(res);
        }

        // Remove duplicates
        final uniqueIds = <String>{};
        _searchResults =
            allAiResults.where((m) => uniqueIds.add(m.id)).toList();
      } else {
        // Regular search
        _searchResults = await MovieService().searchMovies(query);
      }
    } catch (e) {
      _searchResults = [];
    } finally {
      if (mounted) {
        setState(() => _isAIAnalyzing = false);
      }
    }
  }

  void _onKeywordTap(String keyword) {
    _searchController.text = keyword;
    _performSearch(keyword);
    FocusScope.of(context).unfocus(); // Hide keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              // _onSearchChanged handles this via listener,
              // but we can also use onChanged directly if preferred.
            },
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText:
                  _isSmartSearch ? '무엇이든 물어보세요 (예: 슬픈 영화)' : '영화, 시리즈, 배우 검색',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search,
                  color: _isSmartSearch ? Colors.blueAccent : Colors.grey[600]),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    ),
                  IconButton(
                    icon:
                        const Icon(Icons.keyboard_voice, color: Colors.yellow),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoiceSearchScreen(),
                        ),
                      );
                      if (result != null &&
                          result is String &&
                          result.isNotEmpty) {
                        _searchController.text = result;
                        _performSearch(result);
                      }
                    },
                  ),
                ],
              ),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _isSmartSearch
                    ? const BorderSide(color: Colors.blueAccent, width: 1)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _isSmartSearch
                    ? const BorderSide(color: Colors.blueAccent, width: 1)
                    : BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Smart Search Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '스마트 AI 검색',
                style: TextStyle(
                  color: _isSmartSearch ? Colors.blueAccent : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: _isSmartSearch,
                  onChanged: (value) {
                    setState(() {
                      _isSmartSearch = value;
                      if (!value) {
                        _performSearch(_searchController.text);
                      }
                    });
                  },
                  activeColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),

        if (_isAIAnalyzing)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI가 취향을 분석하고 있어요...',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        // Content Area
        Expanded(
          child: _searchQuery.isEmpty
              ? _buildRecommendationSection()
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
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
            spacing: 8.0,
            runSpacing: 12.0,
            children: recommendationKeywords.map((keyword) {
              return GestureDetector(
                onTap: () => _onKeywordTap(keyword),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: const Icon(
                Icons.movie_outlined,
                size: 40,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '찾으시는 영화가 없나요?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "입력하신 검색어 '$_searchQuery'와(과)\n일치하는 결과가 없습니다.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestContentScreen(),
                  ),
                );
              },
              child: const Text(
                '작품 요청하기',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return MovieCard(
          movie: _searchResults[index],
          showNewBadge: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(
                  movie: _searchResults[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
