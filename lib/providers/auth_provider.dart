import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // Storage keys
  static const String _userKey = 'synfin_user';
  static const String _usersDbKey = 'synfin_users_db';

  AuthProvider() {
    _loadUser();
  }

  // Load user from SharedPreferences
  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user to SharedPreferences
  Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Get all users from "database" (SharedPreferences)
  Future<Map<String, dynamic>> _getUsersDb() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersDbKey);
    if (usersJson == null) {
      return {};
    }
    return json.decode(usersJson) as Map<String, dynamic>;
  }

  // Save users database
  Future<void> _saveUsersDb(Map<String, dynamic> usersDb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersDbKey, json.encode(usersDb));
  }

  // Sign up new user
  Future<bool> signup(String name, String email, String password) async {
    try {
      // Check if email already exists
      final usersDb = await _getUsersDb();
      if (usersDb.containsKey(email.toLowerCase())) {
        return false; // Email already exists
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email.toLowerCase(),
        createdAt: DateTime.now(),
      );

      // Save user to database with password
      usersDb[email.toLowerCase()] = {
        'user': user.toJson(),
        'password': password, // In production, this should be hashed!
      };
      await _saveUsersDb(usersDb);

      return true;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      final usersDb = await _getUsersDb();
      final userData = usersDb[email.toLowerCase()];

      if (userData == null) {
        return false; // User not found
      }

      // Check password
      if (userData['password'] != password) {
        return false; // Invalid password
      }

      // Load user
      final user = User.fromJson(userData['user']);
      await _saveUser(user);

      return true;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile(String name) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(name: name);

      // Update in users database
      final usersDb = await _getUsersDb();
      final userData = usersDb[_currentUser!.email];
      if (userData != null) {
        userData['user'] = updatedUser.toJson();
        await _saveUsersDb(usersDb);
      }

      // Update current user
      await _saveUser(updatedUser);
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }
}
