import 'package:flutter/material.dart';
import 'voice_search_screen.dart';
import '../../constants/mock_data.dart';
import '../../models/movie.dart';
import '../../widgets/movie_card.dart';
import '../movie/movie_detail_screen.dart';
import '../help/request_content_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Movie> _searchResults = [];
  // bool _isSearching = false; // Removed unused variable

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      if (_searchQuery.isNotEmpty) {
        _performSearch(_searchQuery);
      } else {
        // _isSearching = false;
        _searchResults = [];
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      // _isSearching = true;
      _searchResults = mockMovies.where((movie) {
        final title = movie.title.toLowerCase();
        final genres = movie.genres.map((g) => g.toLowerCase()).toList();
        final searchLower = query.toLowerCase();

        return title.contains(searchLower) ||
            genres.any((g) => g.contains(searchLower));
      }).toList();
    });
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
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: '영화, 시리즈, 배우 검색',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.keyboard_voice,
                          color: Colors.yellow),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceSearchScreen(),
                          ),
                        );
                      },
                    ),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        childAspectRatio: 0.67,
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
