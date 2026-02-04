import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ui_rentmything/models/user.dart';
import 'package:ui_rentmything/services/api_helper.dart';

class ApiService {
  static const String baseUrl = "http://localhost:32768/api";

  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';

  static const Map<String, String> _jsonHeaders = {
    "Content-Type": "application/json",
  };

  static String? _cachedToken;

  // -----------------------
  // Token helpers
  // -----------------------

  static Future<String?> getToken() async => await _readToken();

  static Future<void> clearToken() async => await _clearToken();

  static Future<String?> _readToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) return _cachedToken;
    _cachedToken = await _secureStorage.read(key: _accessTokenKey);
    return _cachedToken;
  }

  static Future<void> _saveToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  static Future<void> _clearToken() async {
    _cachedToken = null;
    await _secureStorage.delete(key: _accessTokenKey);
  }

  // ✅ Public so ApiHelper can use it
  static Future<Map<String, String>> buildHeaders() async {
    final headers = Map<String, String>.from(_jsonHeaders);
    final token = await _readToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // -----------------------
  // API methods
  // -----------------------

  static Future<String> sendOtp(String email) async {
    final response = await ApiHelper.post("sendotp", {"email": email});
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _extractMessageFromBody(response.body);
    } else {
      throw Exception("Send OTP failed: ${response.body}");
    }
  }

  static Future<String> verifyOtp(String email, String otp) async {
    final response = await ApiHelper.post("verifyotp", {
      "email": email,
      "otp": otp,
    });
    if (response.statusCode == 200) {
      return _extractMessageFromBody(response.body);
    } else {
      throw Exception("Verify OTP failed: ${response.body}");
    }
  }

  static Future<String> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
    required String password,
  }) async {
    final response = await ApiHelper.post("register", {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "role": role,
      "password": password,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _extractMessageFromBody(response.body);
    } else {
      throw Exception("Registration failed: ${response.body}");
    }
  }

  static Future<User> login(String email, String password) async {
    final uri = Uri.parse("$baseUrl/login");
    final response = await http
        .post(
          uri,
          headers: _jsonHeaders,
          body: jsonEncode({"email": email, "password": password}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      String? token;
      Map<String, dynamic>? userMap;

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('token')) {
          token = decoded['token'].toString();
        }
        final wrappers = ['data', 'user', 'userdetail', 'payload'];
        for (final key in wrappers) {
          if (decoded.containsKey(key) &&
              decoded[key] is Map<String, dynamic>) {
            userMap = Map<String, dynamic>.from(decoded[key]);
            if (userMap.containsKey('token')) {
              token = userMap['token'].toString();
            }
            break;
          }
        }
        if (userMap == null &&
            (decoded.containsKey('email') ||
                decoded.containsKey('name') ||
                decoded.containsKey('role'))) {
          userMap = Map<String, dynamic>.from(decoded);
        }
      }

      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
      }

      if (userMap != null) {
        return User.fromMap(userMap);
      } else {
        throw Exception("Login succeeded but no user data returned");
      }
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  static Future<void> logout() async {
    await _clearToken();
  }

  static String _extractMessageFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message')) {
          return decoded['message'].toString();
        }
        if (decoded.containsKey('msg')) return decoded['msg'].toString();
        if (decoded.containsKey('error')) return decoded['error'].toString();
        return decoded.toString();
      } else if (decoded is String) {
        return decoded;
      } else {
        return body;
      }
    } catch (_) {
      return body;
    }
  }

  static Future<List<String>> getCategories() async {
    final response = await ApiHelper.get("categories");
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<String>.from(decoded);
      } else if (decoded is Map && decoded.containsKey('data')) {
        return List<String>.from(decoded['data']);
      } else {
        throw Exception("Unexpected categories format: $decoded");
      }
    } else {
      throw Exception("Failed to load categories: ${response.body}");
    }
  }

  static Future<List<dynamic>> searchOwners({
    required String email,
    required String role,
    required String category,
    required double radius,
  }) async {
    final response = await ApiHelper.post("serch", {
      "email": email,
      "role": role,
      "category": category,
      "radius": radius,
    });
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] as List<dynamic>;
    } else {
      throw Exception("Search failed: ${response.body}");
    }
  }

  static Future<String> saveLocation({
    required String email,
    required double latitude,
    required double longitude,
  }) async {
    final response = await ApiHelper.post("save-location", {
      "email": email,
      "latitude": latitude,
      "longitude": longitude,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"] ?? "Location saved successfully!";
    } else {
      throw Exception("Failed to save location: ${response.body}");
    }
  }

  static Future<String> deleteAccount(String email) async {
    final response = await ApiHelper.delete("delete-account", {"email": email});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"] ?? "Account deleted successfully!";
    } else {
      throw Exception("Failed to delete account: ${response.body}");
    }
  } // inside ApiService class

  static Future<Map<String, dynamic>> fetchOwnerProfile({
    required String email,
    required String role,
  }) async {
    final response = await ApiHelper.post("fetching", {
      "email": email,
      "role": role,
    });
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data']; // OwnerProfileDto
    } else {
      throw Exception("Failed to fetch owner profile: ${response.body}");
    }
  }

  static Future<void> deleteItem({
    required String email,
    required String title,
  }) async {
    final response = await ApiHelper.delete("deleteItem", {
      "email": email,
      "title": title,
    });
    if (response.statusCode != 200) {
      throw Exception("Failed to delete item: ${response.body}");
    }
  }

  static Future<String> addService({
    required String email,
    required String role, // ✅ include role
    required String title,
    required String description,
    required double price,
    required String category,
    required String address,
  }) async {
    final response = await ApiHelper.post("add-service", {
      "email": email,
      "role": role, // ✅ send role to backend
      "title": title,
      "description": description,
      "price": price,
      "category": category,
      "address": address,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return decoded["message"] ?? "Item added successfully!";
    } else {
      throw Exception("Failed to add item: ${response.body}");
    }
  }
}
