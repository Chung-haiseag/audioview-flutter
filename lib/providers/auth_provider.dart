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

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        // Fetch user data from Firestore
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            _userData = doc.data();
            // Update FCM Token
            NotificationService.saveTokenToDatabase(user.uid);
          }
        } catch (e) {
          // print('Error fetching user data: $e');
        }
      } else {
        _userData = null;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    notifyListeners();
  }

  // Social Login: Kakao
  Future<void> signInWithKakao() async {
    try {
      // 1. Get Kakao Token
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // User cancelled or other talk login error
          if (error is kakao.KakaoException &&
              error.toString().contains('cancel')) {
            rethrow;
          }
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 2. Call Cloud Function to get Custom Token
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('verifyKakaoToken');
      final result = await callable.call({'accessToken': token.accessToken});

      final String customToken = result.data['customToken'];

      // 3. Sign in to Firebase
      await _auth.signInWithCustomToken(customToken);
    } catch (e) {
      // print('Kakao Login Error: $e');
      rethrow;
    }
  }

  // Social Login: Naver
  Future<void> signInWithNaver() async {
    try {
      // 1. Get Naver Token
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      if (res.status != NaverLoginStatus.loggedIn) {
        throw Exception('Naver login failed or cancelled.');
      }

      final NaverAccessToken accessToken =
          await FlutterNaverLogin.currentAccessToken;

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
          }, SetOptions(merge: true));
        }
      } else {
        // 1. Native: Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // Cancelled

        // 2. Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

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
        }
      }
    } catch (e) {
      // print('Google Login Error: $e');
      rethrow;
    }
  }
}
