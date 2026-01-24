import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
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
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Cleanup old legacy key if exists
    notifyListeners();
  }
}
