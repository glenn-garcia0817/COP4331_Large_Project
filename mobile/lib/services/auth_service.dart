import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _base = 'http://165.232.145.102:5000';

const _sessionKey = 'garnish_token';
const _userKey = 'garnish_user';


class UserProfile {
  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id']?.toString() ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        isEmailVerified: map['isEmailVerified'] == true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'isEmailVerified': isEmailVerified,
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class AuthResult {
  final UserProfile? user;
  final String? message;
  final String? error;
  final bool needsVerification;

  AuthResult._({
    this.user,
    this.message,
    this.error,
    this.needsVerification = false,
  });

  factory AuthResult.success(UserProfile user, {String? message}) =>
      AuthResult._(user: user, message: message);

  factory AuthResult.pending(String message) =>
      AuthResult._(message: message, needsVerification: true);

  factory AuthResult.error(String error) => AuthResult._(error: error);

  bool get isSuccess => user != null;
  bool get isError => error != null;
}

class SimpleResult {
  final String? message;
  final String? error;
  SimpleResult.success(this.message) : error = null;
  SimpleResult.error(this.error) : message = null;
  bool get isSuccess => error == null;
}

Map<String, String> _headers({String? token}) => {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

String _parseError(http.Response res) {
  try {
    final body = json.decode(res.body);
    return body['message'] ?? 'Something went wrong.';
  } catch (_) {
    return 'Something went wrong (${res.statusCode}).';
  }
}

class AuthService {
  static Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    try {
      return UserProfile.fromMap(json.decode(data));
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<void> _persist(UserProfile user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
    await prefs.setString(_userKey, json.encode(user.toMap()));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_userKey);
  }

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/register'),
        headers: _headers(),
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      final body = json.decode(res.body);
      if (res.statusCode == 201) {
        return AuthResult.pending(
          body['message'] ??
              'Account created. Please check your email to verify your account before logging in.',
        );
      }
      return AuthResult.error(_parseError(res));
    } catch (_) {
      return AuthResult.error('Could not reach the server. Check your connection.');
    }
  }

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/login'),
        headers: _headers(),
        body: json.encode({'email': email, 'password': password}),
      );
      final body = json.decode(res.body);
      if (res.statusCode == 200) {
        final user = UserProfile.fromMap(body['user']);
        await _persist(user, body['token']);
        return AuthResult.success(user);
      }
      if (res.statusCode == 403) {
        return AuthResult.error(
            'Your email has not been verified yet. Please check your inbox.');
      }
      return AuthResult.error(_parseError(res));
    } catch (_) {
      return AuthResult.error('Could not reach the server. Check your connection.');
    }
  }

  static Future<SimpleResult> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/auth/forgot-password'),
        headers: _headers(),
        body: json.encode({'email': email}),
      );
      final body = json.decode(res.body);
      if (res.statusCode == 200) {
        return SimpleResult.success(
          body['message'] ?? 'If that account exists, a reset link has been sent.',
        );
      }
      return SimpleResult.error(_parseError(res));
    } catch (_) {
      return SimpleResult.error('Could not reach the server. Check your connection.');
    }
  }

  static Future<UserProfile?> refreshCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final res = await http.get(
        Uri.parse('$_base/api/auth/me'),
        headers: _headers(token: token),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final user = UserProfile.fromMap(body['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toMap()));
        return user;
      }
      await logout();
      return null;
    } catch (_) {
      return getCurrentUser();
    }
  }
}
