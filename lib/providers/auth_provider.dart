import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hbitolar/models/user_model.dart';
import 'package:hbitolar/services/auth_service.dart';
import 'package:hbitolar/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _currentUser;
  User? _firebaseUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _currentUser = await _firestoreService.getUser(user.uid);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.signInWithEmailAndPassword(email, password);
      return credential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.createUserWithEmailAndPassword(email, password, name);
      return credential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final credential = await _authService.signInWithGoogle();
      return credential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestoreService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Erro ao atualizar perfil: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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

  void clearError() {
    _clearError();
  }
}