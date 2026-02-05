import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../movie/movie_detail_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final MovieService _movieService;
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
    _movieService = context.read<MovieService>();
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
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );
      debugPrint('STT is available: $available');
    } catch (e) {
      debugPrint('STT Initialization failed: $e');
    }
  }

  Future<void> _toggleListening() async {
    debugPrint('STT: _toggleListening called. current state _isListening: $_isListening');
    if (_isListening) {
      debugPrint('STT: Stopping listening...');
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
    } else {
      debugPrint('STT: Requesting permissions...');
      // iOS requires both Microphone and Speech permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.speech,
      ].request();

      debugPrint('STT: Permission statuses: $statuses');

      if (!mounted) return;

      if (statuses[Permission.microphone]!.isGranted &&
          statuses[Permission.speech]!.isGranted) {
        debugPrint('STT: Permissions granted. Initializing speech...');
        bool available = await _speech.initialize(
          onStatus: (status) => debugPrint('STT Status changed: $status'),
          onError: (error) => debugPrint('STT Error occurred: $error'),
        );
        debugPrint('STT: Initialization result: $available');
        
        if (available) {
          debugPrint('STT: Starting to listen...');
          setState(() => _isListening = true);
          await _speech.listen(
            onResult: (result) {
              debugPrint('STT Result: ${result.recognizedWords} (final: ${result.finalResult})');
              if (!mounted) return;
              setState(() {
                _searchController.text = result.recognizedWords;
                if (result.finalResult) {
                  _isListening = false;
                  _performSearch(result.recognizedWords);
                }
              });
            },
            localeId: 'ko_KR',
          );
        } else {
          debugPrint('STT: Speech not available on this device/environment');
          _showErrorSnackBar('음성 인식을 초기화할 수 없습니다. (시뮬레이터 미지원 가능성)');
        }
      } else {
        debugPrint('STT: Permissions denied');
        _showErrorSnackBar('마이크 및 음성 인식 권한이 필요합니다.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _onSearchChanged(String query) {
    debugPrint('UI: _onSearchChanged: "$query"');
    setState(() {}); // To update clear icon visibility immediately
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
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    if (isLiteMode) {
      return _buildLiteModeUI();
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Column(
            children: [
              // Search Input Area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.search, color: Colors.blue),
                          ),
                          Expanded(
                            child: Semantics(
                              label: "검색어 입력",
                              excludeSemantics: true,
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: '영화, 시리즈, 배우 검색',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            Semantics(
                              label: "검색어 지우기",
                              excludeSemantics: true,
                              child: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  debugPrint('UI: Search clear button pressed');
                                  setState(() {
                                    _searchController.clear();
                                    _searchResults = [];
                                  });
                                  _performSearch('');
                                },
                              ),
                            ),
                          Semantics(
                            label: _isListening ? "음성 검색 중지" : "음성 검색",
                            excludeSemantics: true,
                            child: IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: _isListening ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                debugPrint('UI: Mic button pressed');
                                _toggleListening();
                              },
                            ),
                          ),
                        ],
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
                color: Colors.black.withValues(alpha: 0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
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

  Widget _buildLiteModeUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            // Left: Back button as text
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Semantics(
                label: "뒤로가기",
                excludeSemantics: true,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(80, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    "뒤로가기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Center: Title with double-tap to reset
            Semantics(
              label: "음성 검색",
              excludeSemantics: true,
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _searchResults = [];
                    _searchController.clear();
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "음성 검색",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 80), // Balance for back button
          ],
        ),
      ),
      body: _searchResults.isEmpty && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: _isListening ? "듣고 있어요" : "음성 검색 시작",
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _toggleListening();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.red.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening ? Colors.red : Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.mic,
                          size: 80,
                          color: _isListening ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "영화제목이나 배우의 이름을\n이야기 하시면 영화를 찾아 드릴게요",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isListening) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "듣고 있어요...",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (_searchResults.length > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            "영화 ${_searchResults.length}개가 검색되었습니다",
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final movie = _searchResults[index];
                          // Auto-focus first item semantics
                          return Semantics(
                            focused: index == 0,
                            label: "${movie.title}, ${movie.duration}분",
                            excludeSemantics: true,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailScreen(movie: movie),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                constraints:
                                    const BoxConstraints(minHeight: 80),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 0.5)),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
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
                        },
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
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
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
              size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            '찾으시는 영화가 없나요?',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '입력하신 검색어 \'${_searchController.text}\'와(과)\n일치하는 결과가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
        return Semantics(
          label: movie.title,
          excludeSemantics: true,
          child: GestureDetector(
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
                          ? CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              fit: BoxFit.cover,
                              memCacheWidth:
                                  200, // Optimize memory usage for grid items
                              errorWidget: (context, url, error) =>
                                  const Center(
                                      child: Icon(Icons.movie,
                                          color: Colors.white54)),
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
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
          ),
        );
      },
    );
  }
}
