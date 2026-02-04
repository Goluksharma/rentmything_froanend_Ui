import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ui_rentmything/services/api_service.dart';

class ApiHelper {
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse("${ApiService.baseUrl}/$endpoint");
    final headers = await ApiService.buildHeaders(); // ✅ uses token

    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse("${ApiService.baseUrl}/$endpoint");
    final headers = await ApiService.buildHeaders(); // ✅ uses token

    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> delete(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse("${ApiService.baseUrl}/$endpoint");
    final headers = await ApiService.buildHeaders(); // ✅ uses token

    return await http.delete(uri, headers: headers, body: jsonEncode(body));
  }
}
