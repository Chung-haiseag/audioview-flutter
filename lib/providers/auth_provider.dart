import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  int get points => _userData?['points'] ?? 0;
  String? get lastCheckIn => _userData?['last_check_in'];

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    _auth.authStateChanges().listen((User? user) async {
      // Cancel previous subscription if it exists
      await _userSubscription?.cancel();
      _userSubscription = null;

      _user = user;
      _userData = null; // Always clear old data immediately to avoid flicker
      notifyListeners();

      if (user != null) {
        // Fetch user data from Firestore
        _userSubscription = _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            final newData = doc.data();

            // Auto-fix: Ensure points field and history exist
            if (newData != null) {
              if (newData['points'] == null) {
                doc.reference.update({
                  'points': 100,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              // Use a deterministic ID for signup history to prevent duplicates
              _firestore
                  .collection('point_history')
                  .doc('signup_${user.uid}')
                  .set({
                'user_id': user.uid,
                'points': 100,
                'type': 'signup',
                'description': '회원가입 축하 포인트',
                'created_at':
                    newData['createdAt'] ?? FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }

            _userData = newData;
            notifyListeners();
          } else {
            // User exists in Auth but not in Firestore -> Forced logout (Deleted by admin)
            logout();
          }
        });
        // Save token once outside the listener
        NotificationService.saveTokenToDatabase(user.uid);
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state listener will update _user and notify listeners
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String disabilityType,
  }) async {
    try {
      // 1. Create Auth User
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create Firestore User Document
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': name,
          'email': email,
          'disabilityType': disabilityType,
          'authProvider': 'email',
          'points': 100, // Initialize with signup points
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    // Also logout from Social SDKs if needed
    try {
      if (userData?['authProvider'] == 'kakao') {
        await kakao.UserApi.instance.logout();
      } else if (userData?['authProvider'] == 'naver') {
        await FlutterNaverLogin.logOut();
      } else if (userData?['authProvider'] == 'google') {
        await GoogleSignIn().signOut();
      }
    } catch (e) {
      // Ignore social logout errors
    }

    await _auth.signOut();
    await _userSubscription?.cancel();
    _userSubscription = null;
    _user = null;
    _userData = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    notifyListeners();
  }

  // Social Login: Kakao
  Future<void> signInWithKakao() async {
    try {
      // 1. Get Kakao Token
      kakao.OAuthToken token;
      print('DEBUG: Starting Kakao Login...');
      try {
        print('KAKAO_KEY_HASH: ${await kakao.KakaoSdk.origin}');
      } catch (e) {
        print('Could not get KeyHash: $e');
      }
      if (await kakao.isKakaoTalkInstalled()) {
        try {
          print('DEBUG: Attempting login with KakaoTalk...');
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          print('DEBUG: KakaoTalk login failed, trying account login: $error');
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        print('DEBUG: Attempting login with KakaoAccount...');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
      print(
          'DEBUG: Kakao Token obtained: ${token.accessToken.substring(0, 5)}...');

      // 2. Call Cloud Function to get Custom Token
      print('DEBUG: Calling Cloud Function verifyKakaoToken...');
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('verifyKakaoToken');
      final result = await callable.call({'accessToken': token.accessToken});

      final String customToken = result.data['customToken'];

      // 3. Sign in to Firebase
      await _auth.signInWithCustomToken(customToken);
    } catch (e) {
      print('CRITICAL: Kakao Login Error: $e');
      if (e is kakao.KakaoAuthException) {
        print('Kakao Auth Exception: ${e.message}');
      }
      rethrow;
    }
  }

  // Social Login: Naver
  Future<void> signInWithNaver() async {
    try {
      // 1. Get Naver Token
      final dynamic res = await FlutterNaverLogin.logIn();
      if (res.status != 'loggedIn' && res.status.toString() != 'loggedIn') {
        // We'll use toString() comparison as a fallback
        if (res.status.toString().contains('loggedIn')) {
          // Continue
        } else {
          throw Exception('Naver login failed or cancelled.');
        }
      }

      final dynamic accessToken =
          await FlutterNaverLogin.getCurrentAccessToken();

      // 2. Call Cloud Function
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('verifyNaverToken');
      final result =
          await callable.call({'accessToken': accessToken.accessToken});

      final String customToken = result.data['customToken'];

      // 3. Sign in to Firebase
      await _auth.signInWithCustomToken(customToken);
    } catch (e) {
      rethrow;
    }
  }

  // Social Login: Google
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 1. Web: Use Firebase's native popup sign-in
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        // 2. Update Firestore user record
        if (userCredential.user != null) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': userCredential.user!.displayName,
            'email': userCredential.user!.email,
            'profileImage': userCredential.user!.photoURL,
            'authProvider': 'google',
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
            'points': FieldValue.increment(
                0), // Ensure points field exists, logic handled by CF if merge:true but safer here
          }, SetOptions(merge: true));

          // For new users who don't have points, we can initialize it here if we can detect creation
          final userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
          if (!userDoc.exists || userDoc.data()?['points'] == null) {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({
              'points': 100,
            });
          }
        }
      } else {
        // 1. Native: Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // Cancelled

        // 2. Obtain the auth details from the request
        final googleAuth = await googleUser.authentication;

        // 3. Create a new credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. Sign in with credential
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // 5. Update Firestore user record
        if (userCredential.user != null) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': googleUser.displayName,
            'email': googleUser.email,
            'profileImage': googleUser.photoUrl,
            'authProvider': 'google',
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
          }, SetOptions(merge: true));

          final userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
          if (!userDoc.exists || userDoc.data()?['points'] == null) {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({
              'points': 100,
            });
          }
        }
      }
    } catch (e) {
      // print('Google Login Error: $e');
      rethrow;
    }
  }

  // 일일 체크인 실행
  Future<Map<String, dynamic>> performCheckIn() async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'us-central1')
              .httpsCallable('dailyCheckIn');
      final result = await callable.call();
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      return {'success': false, 'message': '체크인 실패: $e'};
    }
  }
}
