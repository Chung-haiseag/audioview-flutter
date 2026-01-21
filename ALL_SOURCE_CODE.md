# AudioView Flutter - 전체 소스코드

## 압축 파일 위치
```
C:\Users\정해석\Downloads\audioview_flutter_complete.tar.gz
```

---

## 📄 lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/downloads/downloads_screen.dart';
import 'widgets/custom_header.dart';
import 'widgets/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'AudioView',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  double _brightness = 100.0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SettingsScreen(),
    SearchScreen(),
    DownloadsScreen(),
  ];

  final List<String> _titles = [
    'AUDIOVIEW',
    '설정',
    '검색',
    'MY AUDIOVIEW',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // If on Downloads and not authenticated, redirect to login
        if (_currentIndex == 3 && !auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/login');
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: CustomHeader(
            isSubPage: _currentIndex != 0,
            customTitle: _currentIndex == 0 ? null : _titles[_currentIndex],
            brightness: _brightness,
            onBrightnessChanged: (value) {
              setState(() {
                _brightness = value;
              });
            },
          ),
          body: Stack(
            children: [
              _screens[_currentIndex],
              // Brightness overlay
              IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity((100 - _brightness) / 100),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
```

## 📄 lib/config/theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color brandRed = Color(0xFFE50914);
  static const Color brandDark = Color(0xFF141414);
  static const Color brandBlack = Colors.black;
  static const Color brandGray = Color(0xFF808080);
  static const Color brandLightGray = Color(0xFFB3B3B3);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: brandDark,
      primaryColor: brandRed,
      colorScheme: const ColorScheme.dark(
        primary: brandRed,
        secondary: brandRed,
        surface: brandDark,
        background: brandBlack,
      ),
      textTheme: GoogleFonts.notoSansKrTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandDark,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF333333),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: brandRed, width: 2),
        ),
        labelStyle: const TextStyle(color: brandGray),
        hintStyle: const TextStyle(color: brandGray),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
```

## 📄 lib/constants/mock_data.dart
```dart
import '../models/movie.dart';
import '../models/category.dart';

final List<Movie> mockMovies = [
  Movie(
    id: '1',
    title: '거룩한 밤: 데몬 헌터스',
    year: 2025,
    country: '대한민국',
    duration: 92,
    genres: ['영화', '액션', '판타지'],
    posterUrl: 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: '2',
    title: '검은 수녀들',
    year: 2025,
    country: '대한민국',
    duration: 115,
    genres: ['영화', '공포', '미스터리'],
    posterUrl: 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: '3',
    title: '큘레큘레',
    year: 2025,
    country: '대한민국',
    duration: 108,
    genres: ['영화', '드라마', '로맨스'],
    posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: '4',
    title: '지구의 신비: 심해',
    year: 2024,
    country: '대한민국',
    duration: 60,
    genres: ['시사교양', '다큐멘터리'],
    posterUrl: 'https://images.unsplash.com/photo-1518467166778-b88f373ffec7?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: '5',
    title: '우주로 가는 길',
    year: 2024,
    country: '대한민국',
    duration: 55,
    genres: ['시사교양', '과학'],
    posterUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: 's1',
    title: '나 혼자 즐거운 여행',
    year: 2024,
    country: '한국',
    duration: 80,
    genres: ['예능', '리얼리티'],
    posterUrl: 'https://images.unsplash.com/photo-1533107862482-0e6974b06ec4?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: 's2',
    title: '뉴욕의 밤: 수사대',
    year: 2023,
    country: '미국',
    duration: 45,
    genres: ['드라마', '범죄', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: 's3',
    title: '런던 로열 오피스',
    year: 2024,
    country: '영국',
    duration: 55,
    genres: ['드라마', '역사', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1513151233558-d860c5398176?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: 'a1',
    title: '푸른 숲의 요정',
    year: 2024,
    country: '일본',
    duration: 25,
    genres: ['애니', '판타지'],
    posterUrl: 'https://images.unsplash.com/photo-1578632292335-df3abbb0d586?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: 'a2',
    title: '사이버 펑크 2099',
    year: 2025,
    country: '미국',
    duration: 30,
    genres: ['애니', 'SF', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: 'e1',
    title: '요리 대첩: 파이널',
    year: 2025,
    country: '한국',
    duration: 90,
    genres: ['예능', '서바이벌'],
    posterUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: 'e2',
    title: '웃음 사냥꾼',
    year: 2024,
    country: '한국',
    duration: 70,
    genres: ['예능', '코미디'],
    posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: 'd1',
    title: '청춘의 기록',
    year: 2024,
    country: '대한민국',
    duration: 60,
    genres: ['드라마', '청춘'],
    posterUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: 'd2',
    title: '비밀의 숲 3',
    year: 2025,
    country: '대한민국',
    duration: 70,
    genres: ['드라마', '범죄', '스릴러'],
    posterUrl: 'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: false,
  ),
  Movie(
    id: '6',
    title: '인사이드 아웃 2',
    year: 2024,
    country: '미국',
    duration: 96,
    genres: ['영화', '애니', '가족', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
  Movie(
    id: '9',
    title: '까칠한 강래씨',
    year: 2024,
    country: '대한민국',
    duration: 17,
    genres: ['영화', '일상성', '장애'],
    posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
    hasMultiLang: true,
  ),
];

final List<Category> categories = [
  Category(
    id: 'all',
    name: '전체',
    count: 394,
    imageUrl: mockMovies[0].posterUrl,
  ),
  Category(
    id: 'movie',
    name: '영화',
    count: 393,
    imageUrl: mockMovies[0].posterUrl,
  ),
  Category(
    id: 'series',
    name: '시리즈',
    count: 1,
    imageUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=300&h=450&auto=format&fit=crop',
  ),
];

const List<String> categoryChips = ['예능', '드라마', '영화', '시사교양', '애니', '해외'];
```

## 📄 lib/models/category.dart
```dart
class Category {
  final String id;
  final String name;
  final int count;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.count,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'imageUrl': imageUrl,
    };
  }
}
```

## 📄 lib/models/movie.dart
```dart
class Movie {
  final String id;
  final String title;
  final int year;
  final String country;
  final int duration; // minutes
  final List<String> genres;
  final String? description;
  final String posterUrl;
  final bool hasAD; // Audio Description
  final bool hasCC; // Closed Caption
  final bool hasMultiLang; // Multi-language subtitles

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.country,
    required this.duration,
    required this.genres,
    this.description,
    required this.posterUrl,
    required this.hasAD,
    required this.hasCC,
    required this.hasMultiLang,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      year: json['year'],
      country: json['country'],
      duration: json['duration'],
      genres: List<String>.from(json['genres']),
      description: json['description'],
      posterUrl: json['posterUrl'],
      hasAD: json['hasAD'],
      hasCC: json['hasCC'],
      hasMultiLang: json['hasMultiLang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'country': country,
      'duration': duration,
      'genres': genres,
      'description': description,
      'posterUrl': posterUrl,
      'hasAD': hasAD,
      'hasCC': hasCC,
      'hasMultiLang': hasMultiLang,
    };
  }
}
```

## 📄 lib/providers/auth_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    _isAuthenticated = false;
    notifyListeners();
  }
}
```

## 📄 lib/widgets/badges.dart
```dart
import 'package:flutter/material.dart';

class ADBadge extends StatelessWidget {
  const ADBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0051C4),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text(
        'AD',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class CCBadge extends StatelessWidget {
  const CCBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text(
        'CC',
        style: TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
```

## 📄 lib/widgets/bottom_navigation.dart
```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414).withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(LucideIcons.home, '홈', 0),
              _buildNavItem(LucideIcons.settings, '설정', 1),
              _buildNavItem(LucideIcons.search, '검색', 2),
              _buildNavItem(LucideIcons.user, 'MY', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📄 lib/widgets/custom_header.dart
```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool isSubPage;
  final String? customTitle;
  final double brightness;
  final ValueChanged<double> onBrightnessChanged;

  const CustomHeader({
    super.key,
    required this.isSubPage,
    this.customTitle,
    required this.brightness,
    required this.onBrightnessChanged,
  });

  @override
  State<CustomHeader> createState() => _CustomHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

class _CustomHeaderState extends State<CustomHeader> {
  bool _showBrightness = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141414),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 68,
              child: Row(
                children: [
                  // Left side - Back button or spacer
                  SizedBox(
                    width: 60,
                    child: widget.isSubPage
                        ? IconButton(
                            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 28),
                            onPressed: () => Navigator.of(context).maybePop(),
                          )
                        : null,
                  ),

                  // Center - Title
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.customTitle ?? 'AUDIOVIEW',
                        style: const TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  // Right side - Brightness button
                  SizedBox(
                    width: 60,
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.sun,
                        color: _showBrightness ? const Color(0xFFE50914) : Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _showBrightness = !_showBrightness;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Brightness slider
            if (_showBrightness)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                color: const Color(0xFF141414),
                child: Row(
                  children: [
                    const Icon(LucideIcons.moon, size: 18, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFFE50914),
                          inactiveTrackColor: Colors.grey[600],
                          thumbColor: const Color(0xFFE50914),
                          overlayColor: const Color(0xFFE50914).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: widget.brightness,
                          min: 10,
                          max: 100,
                          onChanged: widget.onBrightnessChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.sun, size: 18, color: Colors.grey),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## 📄 lib/screens/auth/login_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);
      
      if (mounted) {
        // Navigate or let the AuthWrapper handle it
       // In Flutter, usually AuthWrapper listens to AuthProvider and switches pages.
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Layer
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  return Image.network(
                    'https://picsum.photos/seed/${index + 50}/300/450',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.black45, Colors.black],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AUDIOVIEW',
                        style: TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: '이메일 주소 또는 전화번호',
                            prefixIcon: Icon(LucideIcons.mail, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            prefixIcon: const Icon(LucideIcons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, 
                                  height: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(height: 24),
                        
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('비밀번호를 잊으셨나요?', style: TextStyle(color: Colors.grey)),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('AudioView 회원이 아닌가요?', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('지금 가입하세요.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.helpCircle, size: 16, color: Colors.grey),
                        label: const Text('문의 사항이 있으신가요? 고객 센터에 문의하세요.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}
```

## 📄 lib/screens/downloads/downloads_screen.dart
```dart
import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              '다운로드한 콘텐츠가 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📄 lib/screens/home/home_screen.dart
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured section
            Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/featured/800/400'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0A0A0A).withOpacity(0.7),
                      const Color(0xFF0A0A0A),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '추천 콘텐츠',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '배리어프리 영상 감상',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('재생하기'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '인기 카테고리',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage('https://picsum.photos/seed/${index}/250/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📄 lib/screens/search/search_screen.dart
```dart
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '영화, 드라마 검색...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '검색어를 입력하세요',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 📄 lib/screens/settings/settings_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: auth.isAuthenticated
                    ? Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFE50914),
                            child: Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '배리어프리 회원님',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'premium_user@audioview.kr',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.grey),
                            onPressed: () => auth.logout(),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '로그인이 필요합니다',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '로그인하고 시청 기록을 동기화하세요.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE50914),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('로그인 하러가기'),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Settings list
              _buildSettingItem('일반 설정', Icons.settings),
              _buildSettingItem('접근성 기능', Icons.accessibility),
              _buildSettingItem('자막 스타일', Icons.subtitles),
              _buildSettingItem('알림 설정', Icons.notifications),
              _buildSettingItem('고객센터', Icons.help_outline),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
```


---

# Android 설정 파일

## 📄 pubspec.yaml
```yaml
name: audioview_flutter
description: A new Flutter project for AudioView.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  shared_preferences: ^2.2.0
  lucide_icons: ^1.0.0
  google_fonts: ^6.1.0
  flutter_animate: ^4.2.0
  intl: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

## 📄 android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.audioview.app">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <application
        android:label="AudioView"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## 📄 android/app/build.gradle
```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.audioview.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```
