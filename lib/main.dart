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
