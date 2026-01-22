import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/downloads/downloads_screen.dart';
import 'screens/notice/notice_list_screen.dart';
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
          '/notice': (context) => const NoticeListScreen(),
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
        // REMOVED: Automatic redirect in build method causes loop

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: Stack(
            children: [
              // 1. Content Layer
              Column(
                children: [
                  // Spacer for Header (StatusBar + Header Height)
                  SizedBox(height: MediaQuery.of(context).padding.top + 68),
                  Expanded(child: _screens[_currentIndex]),
                ],
              ),

              // 2. Brightness Overlay Layer (Covers content below header)
              // Only covers content area, keeps header bright
              Positioned(
                top: MediaQuery.of(context).padding.top + 68,
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity((100 - _brightness) / 100),
                  ),
                ),
              ),

              // 3. Header Layer (Floating on top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CustomHeader(
                  isSubPage: _currentIndex != 0,
                  customTitle:
                      _currentIndex == 0 ? null : _titles[_currentIndex],
                  brightness: _brightness,
                  onBrightnessChanged: (value) {
                    setState(() {
                      _brightness = value;
                    });
                  },
                  onBackPressed: () {
                    if (_currentIndex != 0) {
                      setState(() {
                        _currentIndex = 0;
                      });
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _currentIndex,
            onTap: (index) async {
              // made async
              if (index == 3) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if (!auth.isAuthenticated) {
                  await Navigator.pushNamed(context, '/login');
                  // After returning from login screen, check authentication status again
                  if (mounted &&
                      Provider.of<AuthProvider>(context, listen: false)
                          .isAuthenticated) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }
                  return;
                }
              }
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
