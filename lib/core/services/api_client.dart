import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sum_academy/core/services/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://sumacademy.net/api';
  static const Duration _timeout = Duration(seconds: 20);

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
    bool retryNetwork = true,
  }) async {
    final headers = await _headers(auth: auth);
    final uri = _buildUri(path, query);
    final encodedBody = body == null ? null : jsonEncode(body);

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on SocketException {
      if (method == 'GET' && retryNetwork) {
        await Future.delayed(const Duration(milliseconds: 800));
        return _send(
          method,
          path,
          body: body,
          auth: auth,
          query: query,
          retryAuth: retryAuth,
          retryNetwork: false,
        );
      }
      throw ApiException(
        'No internet connection. Please check your connection and try again.',
        statusCode: 0,
      );
    } on TimeoutException {
      if (method == 'GET' && retryNetwork) {
        await Future.delayed(const Duration(milliseconds: 800));
        return _send(
          method,
          path,
          body: body,
          auth: auth,
          query: query,
          retryAuth: retryAuth,
          retryNetwork: false,
        );
      }
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
        retryNetwork: retryNetwork,
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        try {
          user = await FirebaseAuth.instance
              .authStateChanges()
              .firstWhere((u) => u != null)
              .timeout(const Duration(seconds: 3));
        } catch (_) {
          user = null;
        }
      }
      final token = await user?.getIdToken();
      if (token == null || token.isEmpty) {
        debugPrint(
          'API auth header missing token. user=${user?.uid ?? 'null'}',
        );
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
    Map<String, dynamic> data;
    try {
      data = _decodeBody(response.body);
    } catch (_) {
      debugPrint(
        'API ${response.request?.method ?? ''} ${response.request?.url ?? ''} '
        '-> ${response.statusCode} (non-JSON response)',
      );
      throw ApiException(
        'Unexpected server response. Please try again.',
        statusCode: response.statusCode,
      );
    }
    final success = data['success'];

    if (response.statusCode >= 400 || success == false) {
      debugPrint(
        'API ${response.request?.method ?? ''} ${response.request?.url ?? ''} '
        '-> ${response.statusCode} ${data['message'] ?? ''}',
      );
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
