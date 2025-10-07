import 'dart:convert';

import 'package:http/http.dart' as http;

/// A generic API response wrapper
class ApiResult<T> {
  final bool status;
  final T? returnObject;
  final String? message;

  ApiResult({required this.status, this.returnObject, this.message});

  factory ApiResult.fromMap(
    Map<String, dynamic> map,
    T Function(dynamic) fromJson,
  ) {
    return ApiResult(
      status: map['status'] ?? false,
      message: map['message']?.toString(),
      returnObject:
          map['returnObject'] != null ? fromJson(map['returnObject']) : null,
    );
  }
}

/// Unified ApiService for GET and POST
class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  /// Generic GET method
  static Future<ApiResult<T>> get<T>({
    required String url,
    Map<String, String>? queryParams,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return ApiResult.fromMap(map, fromJson);
      } else {
        return ApiResult(status: false, message: parseErrorMessage(response));
      }
    } catch (e) {
      return ApiResult(status: false, message: "GET Exception: $e");
    }
  }

  /// Generic POST method
  static Future<ApiResult<T>> post<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return ApiResult.fromMap(map, fromJson);
      } else {
        return ApiResult(status: false, message: parseErrorMessage(response));
      }
    } catch (e) {
      return ApiResult(status: false, message: "POST Exception: $e");
    }
  }

  /// Parses backend error messages (Spring Boot, etc.)
  static String parseErrorMessage(http.Response response) {
    try {
      final errorJson = json.decode(response.body);
      if (errorJson is Map<String, dynamic>) {
        return errorJson['message']?.toString() ?? "Unexpected error";
      } else {
        return response.body.toString();
      }
    } catch (_) {
      return "HTTP ${response.statusCode}: ${response.reasonPhrase}";
    }
  }

  static Future<ApiResult<T>> postRaw<T>({
    required String url,
    required dynamic body, // can be List or Map
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return ApiResult.fromMap(map, fromJson);
      } else {
        return ApiResult(status: false, message: parseErrorMessage(response));
      }
    } catch (e) {
      return ApiResult(status: false, message: "POST Exception: $e");
    }
  }
}
