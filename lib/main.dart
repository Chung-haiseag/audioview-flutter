// Audioview - Flutter Web Deployment
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/downloads/downloads_screen.dart'; // Contains MyPageScreen class
import 'screens/notice/notice_list_screen.dart';
import 'screens/category/genre_list_screen.dart';
import 'widgets/custom_header.dart';
import 'widgets/custom_drawer.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environmental variables
  await dotenv.load(fileName: "assets/env.txt");

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '4538351b8dd330e9f41491a83effc087');

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
        navigatorKey: NotificationService.navigatorKey,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Check if the app was opened via a notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.checkInitialMessage();
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    GenreListScreen(),
    SettingsScreen(),
    SearchScreen(),
    MyPageScreen(),
    NoticeListScreen(),
  ];

  final List<String> _titles = [
    'AUDIOVIEW',
    '장르',
    '설정',
    '검색',
    '마이페이지',
    '공지/이벤트',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;

            // 1. If drawer is open, close it
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
              return;
            }

            // 2. If not on Home tab, go to Home (Prevent exit)
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
              });
              return;
            }

            // 3. If on Home tab, show exit confirmation
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text('앱 종료',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                content: const Text('앱을 종료하시겠습니까?',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child:
                        const Text('취소', style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child:
                        const Text('종료', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (shouldExit == true) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
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
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      color:
                          Colors.black.withOpacity((100 - _brightness) / 100),
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
                    onSearchPressed: _currentIndex == 3
                        ? null
                        : () {
                            setState(() {
                              _currentIndex = 3;
                            });
                          },
                    onBackPressed: null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
