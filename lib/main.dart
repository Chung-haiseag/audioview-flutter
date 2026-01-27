import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/downloads/downloads_screen.dart'; // Contains MyPageScreen class
import 'screens/notice/notice_list_screen.dart';
import 'widgets/custom_header.dart';
import 'widgets/custom_drawer.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize push notifications
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler);

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
    MyPageScreen(),
  ];

  final List<String> _titles = [
    'AUDIOVIEW',
    '설정',
    '검색',
    '마이페이지',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          drawer: CustomDrawer(
            currentIndex: _currentIndex,
            onItemTapped: (index) async {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
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
                    color: Colors.black
                        .withValues(alpha: (100 - _brightness) / 100),
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
                  onSearchPressed: _currentIndex == 2
                      ? null
                      : () {
                          setState(() {
                            _currentIndex = 2;
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
        );
      },
    );
  }
}
