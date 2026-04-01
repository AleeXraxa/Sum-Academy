import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sum_academy/core/services/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://sumacademy.net/api';

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
    Map<String, dynamic>? query,
  }) async {
    return _send('GET', path, auth: auth, query: query);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, dynamic>? query,
  }) async {
    return _send('POST', path, body: body, auth: auth, query: query);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, dynamic>? query,
  }) async {
    return _send('PUT', path, body: body, auth: auth, query: query);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, dynamic>? query,
  }) async {
    return _send('PATCH', path, body: body, auth: auth, query: query);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, dynamic>? query,
  }) async {
    return _send('DELETE', path, body: body, auth: auth, query: query);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, dynamic>? query,
    bool retryAuth = true,
  }) async {
    final headers = await _headers(auth: auth);
    final uri = _buildUri(path, query);
    final encodedBody = body == null ? null : jsonEncode(body);

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        case 'DELETE':
          response = await _client.delete(
            uri,
            headers: headers,
            body: encodedBody,
          );
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your connection and try again.',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        'Network timeout. Please check your connection and try again.',
        statusCode: 0,
      );
    }

    if (auth && response.statusCode == 401 && retryAuth) {
      await _refreshToken();
      return _send(
        method,
        path,
        body: body,
        auth: auth,
        query: query,
        retryAuth: false,
      );
    }

    return _handleResponse(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalized');
    if (query == null || query.isEmpty) {
      return uri;
    }
    final params = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      final stringValue = value.toString().trim();
      if (stringValue.isEmpty) return;
      params[key] = stringValue;
    });
    return uri.replace(queryParameters: params);
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (auth) {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null || token.isEmpty) {
        throw ApiException('Authentication required.', statusCode: 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<void> _refreshToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException('Authentication required.', statusCode: 401);
    }
    await user.getIdToken(true);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = _decodeBody(response.body);
    final success = data['success'];

    if (response.statusCode >= 400 || success == false) {
      final message =
          data['message']?.toString() ?? 'Request failed. Please try again.';
      final errors = data['errors'];
      throw ApiException(
        message,
        statusCode: response.statusCode,
        errors: errors is Map<String, dynamic> ? errors : null,
      );
    }

    return data;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'data': decoded};
  }
}
