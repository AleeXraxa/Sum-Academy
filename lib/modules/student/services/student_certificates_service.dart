import 'dart:convert' as convert;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_certificate.dart';

class StudentCertificatesService {
  StudentCertificatesService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentCertificate>> fetchCertificates() async {
    final response = await _client.get('/student/certificates', auth: true);
    if (kDebugMode) {
      debugPrint('Certificates response: $response');
    }
    return parseCertificates(response);
  }

  Future<void> verifyCertificate(String certId) async {
    if (certId.trim().isEmpty) {
      throw ApiException('Certificate ID is required.');
    }
    await _client.get('/verify/$certId', auth: false);
  }

  Future<File> downloadCertificate({
    required String url,
    required String fileName,
  }) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      throw ApiException('Certificate link is unavailable.');
    }

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Authentication required.', statusCode: 401);
    }

    final resolvedUrl = trimmedUrl.startsWith('http')
        ? trimmedUrl
        : '${ApiClient.baseUrl}${trimmedUrl.startsWith('/') ? '' : '/'}$trimmedUrl';
    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) {
      throw ApiException('Invalid certificate link.');
    }

    http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    } on SocketException {
      throw ApiException(
        'No internet connection. Please try again.',
        statusCode: 0,
      );
    }

    if (response.statusCode >= 400) {
      if (kDebugMode) {
        debugPrint(
          'Certificate download failed: ${response.statusCode} ${response.body}',
        );
      }
      var message = 'Failed to download certificate.';
      try {
        final decoded = convert.jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw ApiException(message, statusCode: response.statusCode);
    }

    final directory = await getTemporaryDirectory();
    final safeName =
        fileName.trim().isNotEmpty ? fileName.trim() : 'certificate';
    final normalized = safeName.endsWith('.pdf') ? safeName : '$safeName.pdf';
    final file = File('${directory.path}/$normalized');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  }
}
