import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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
  final FocusNode _searchFocusNode = FocusNode();

  List<Movie> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  bool _hasSearched = false; // 검색이 완료되었는지 추적

  // Voice Search states
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Timer? _listenTimeoutTimer;
  bool _isRetryListening = false; // 재시도 청취 여부

  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _movieService = context.read<MovieService>();
    _initSpeech();
    _loadRecommendations();

    // 간편모드에서 화면 진입 시 자동으로 음성검색 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLiteModeVoiceSearch();
    });
  }

  Future<void> _startLiteModeVoiceSearch() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    if (isLiteMode && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _announce("영화 제목이나 배우 이름을 말씀하시면 영화 찾아드립니다");
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted && !_isListening) {
          _isRetryListening = true; // 첫 진입 시에도 중복 나래이션 방지
          _toggleListening();
        }
      }
    }
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
      _listenTimeoutTimer?.cancel();
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

          // 재시도가 아닐 때만 나래이션
          if (!_isRetryListening) {
            _announce("영화 제목이나 배우 이름을 말씀하시면 영화 찾아드립니다");
          }
          _isRetryListening = false; // 플래그 리셋

          // 20초 타임아웃 타이머 시작
          _listenTimeoutTimer?.cancel();
          _listenTimeoutTimer = Timer(const Duration(seconds: 20), () {
            if (mounted && _isListening) {
              _speech.stop();
              setState(() => _isListening = false);
              // 입력된 텍스트가 없으면 "다시 말씀하세요" 안내 후 재시작
              if (_searchController.text.trim().isEmpty) {
                _announce("다시 말씀하세요");
                // 2초 후 비프음 + 음성청취 재시작
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted && !_isListening) {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.mediumImpact();
                    _isRetryListening = true; // 재시도 플래그 설정
                    _toggleListening();
                  }
                });
              }
            }
          });

          await _speech.listen(
            onResult: (result) {
              debugPrint('STT Result: ${result.recognizedWords} (final: ${result.finalResult}, confidence: ${result.confidence})');
              if (!mounted) return;
              setState(() {
                _searchController.text = result.recognizedWords;
                if (result.finalResult) {
                  _listenTimeoutTimer?.cancel();
                  _isListening = false;
                  _performSearch(result.recognizedWords);
                }
              });
            },
            localeId: 'ko_KR',
            listenFor: const Duration(seconds: 20),
            pauseFor: const Duration(seconds: 5),
            partialResults: true, // 중간 결과도 받기
            cancelOnError: false, // 에러 시 취소하지 않음
            listenMode: stt.ListenMode.search, // 검색 모드 (짧은 문구에 최적화)
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
        _hasSearched = false;
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
        _hasSearched = true;
      });
      // 검색 결과 나래이션
      if (results.isNotEmpty) {
        _announceSearchResults(results.length);
      } else {
        _announce("검색 결과가 없습니다");
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  void _announceSearchResults(int count) {
    _announce("영화 $count개가 검색되었습니다");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _listenTimeoutTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '검색어 입력',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onTap: () {
                                if (!_searchFocusNode.hasFocus) {
                                  _searchFocusNode.requestFocus();
                                }
                              },
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
        title: ExcludeSemantics(
          child: Center(
            child: Text(
              "음성 검색",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildLiteModeBody(),
    );
  }

  Widget _buildLiteModeBody() {
    // 검색 결과가 있는 경우
    if (_searchResults.isNotEmpty) {
      return Column(
        children: [
          // 검색 결과 개수 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(
                  liveRegion: true,
                  excludeSemantics: true,
                  container: true,
                  child: Text(
                    "영화 ${_searchResults.length}개가 검색되었습니다",
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 다시 검색 버튼
                Semantics(
                  label: "다시 검색",
                  excludeSemantics: true,
                  container: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                        _searchController.clear();
                      });
                      _toggleListening();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.mic, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "다시 검색",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 검색 결과 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final movie = _searchResults[index];
                return Semantics(
                  focused: index == 0,
                  label: "${movie.title}, ${movie.duration}분${movie.hasAD ? ', 화면해설 지원' : ''}${movie.hasCC ? ', 한글자막 지원' : ''}",
                  excludeSemantics: true,
                  container: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
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
              },
            ),
          ),
        ],
      );
    }

    // 검색했으나 결과가 없는 경우
    if (_hasSearched && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            Text(
              "'${_searchController.text}' 검색 결과가 없습니다",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Semantics(
              label: "다시 검색",
              excludeSemantics: true,
              container: true,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _hasSearched = false;
                    _searchController.clear();
                  });
                  _toggleListening();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.mic, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "다시 검색",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 초기 화면 (마이크 애니메이션)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 마이크 애니메이션
          Semantics(
            label: _isListening ? "듣고 있어요" : "음성 검색 시작",
            excludeSemantics: true,
            container: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _toggleListening();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isListening ? Colors.red : Colors.white,
                    width: _isListening ? 4 : 3,
                  ),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.mic,
                  size: 100,
                  color: _isListening ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _isListening
                  ? "듣고 있어요..."
                  : "영화 제목이나 배우 이름을\n말씀하시면 영화 찾아드립니다",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isListening ? Colors.red : Colors.white,
                fontSize: 24,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isListening) ...[
            const SizedBox(height: 30),
            Semantics(
              label: "취소",
              excludeSemantics: true,
              container: true,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _toggleListening();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "취소",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // 뒤로가기 버튼 (접근성 포커스 순서 마지막)
          const SizedBox(height: 40),
          Semantics(
            label: "뒤로가기",
            excludeSemantics: true,
            container: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  "뒤로가기",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                .map((tag) => Semantics(
                      label: tag,
                      excludeSemantics: true,
                      child: ActionChip(
                        label: Text(tag),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(color: Colors.white),
                        onPressed: () {
                          _searchController.text = tag;
                          _performSearch(tag);
                        },
                      ),
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
