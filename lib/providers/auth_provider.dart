import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuth();
  }

  // Initialize auth state listener
  void _initAuth() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // User is signed in
        _currentUser = UserModel.fromFirebaseUser(user);
        notifyListeners();
      } else {
        // User is signed out
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Start phone verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (String verificationId) {
        _verificationId = verificationId;
        _setLoading(false);
      },
      verificationFailed: (String error) {
        _setError(error);
        _setLoading(false);
      },
      verificationCompleted: (UserModel user) {
        _currentUser = user;
        _setLoading(false);
      },
    );
  }

  // Verify OTP
  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      _setError('Verification ID not found. Please request a new code.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          photoURL: photoURL ?? _currentUser!.photoURL,
        );
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Private methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
