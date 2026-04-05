import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_checkout_models.dart';

class StudentCheckoutService {
  StudentCheckoutService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentCheckoutClass>> fetchAvailableClasses({
    required String courseId,
  }) async {
    final response = await _client.get(
      '/classes/available',
      auth: false,
      query: {'courseId': courseId},
    );
    final data = response['data'] ?? response;
    final list = _extractList(data);
    return list.map(StudentCheckoutClass.fromJson).toList();
  }

  Future<StudentPaymentConfig> fetchPaymentConfig() async {
    final response = await _client.get('/payments/config', auth: true);
    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      return StudentPaymentConfig.fromJson(data);
    }
    return const StudentPaymentConfig(
      methods: ['JazzCash', 'EasyPaisa', 'Bank Transfer'],
      installmentOptions: [2, 3, 4],
      bankDetails: {},
    );
  }

  Future<Map<String, dynamic>> validatePromo({
    required String code,
    required String courseId,
  }) async {
    try {
      final response = await _client.post(
        '/payments/validate-promo',
        auth: true,
        body: {'code': code, 'courseId': courseId},
      );
      return _extractItem(response['data']);
    } on ApiException catch (e) {
      if (e.statusCode == 404 ||
          e.message.toLowerCase().contains('not found')) {
        final response = await _client.post(
          '/promo-codes/validate',
          auth: true,
          body: {'code': code, 'courseId': courseId},
        );
        return _extractItem(response['data']);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String courseId,
    required String classId,
    required String shiftId,
    required String method,
    String? promoCode,
    int? installmentCount,
  }) async {
    final body = <String, dynamic>{
      'courseId': courseId,
      'classId': classId,
      'shiftId': shiftId,
      'method': method,
    };
    if (promoCode != null && promoCode.trim().isNotEmpty) {
      body['promoCode'] = promoCode.trim();
    }
    if (installmentCount != null && installmentCount > 1) {
      body['installments'] = installmentCount;
      body['installmentCount'] = installmentCount;
    }

    final response = await _client.post(
      '/payments/initiate',
      auth: true,
      body: body,
    );
    return _extractItem(response['data']);
  }

  Future<Map<String, dynamic>> uploadReceipt({
    required String paymentId,
    required File receiptFile,
  }) async {
    try {
      final url = await _uploadReceiptToStorage(
        paymentId: paymentId,
        receiptFile: receiptFile,
      );
      final response = await _client.post(
        '/payments/$paymentId/receipt',
        auth: true,
        body: {'receiptUrl': url},
      );
      return _extractItem(response['data']);
    } on FirebaseException catch (e) {
      throw ApiException(
        _mapStorageError(e),
        statusCode: _mapStorageStatusCode(e),
      );
    }
  }

  Future<String> _uploadReceiptToStorage({
    required String paymentId,
    required File receiptFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException('Authentication required.', statusCode: 401);
    }
    final sizeBytes = await receiptFile.length();
    const maxBytes = 5 * 1024 * 1024;
    if (sizeBytes > maxBytes) {
      throw ApiException(
        'Receipt image must be 5MB or smaller.',
        statusCode: 413,
      );
    }
    final ext = _inferImageExt(receiptFile.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Use a simple receipts/{uid}/... path to match common storage rules.
    final path = 'receipts/${user.uid}/$paymentId-$timestamp.$ext';
    final ref = FirebaseStorage.instance.ref().child(path);
    final metadata = SettableMetadata(contentType: 'image/$ext');
    final uploadTask = ref.putFile(receiptFile, metadata);
    try {
      await uploadTask.timeout(const Duration(seconds: 40));
    } on TimeoutException {
      throw ApiException(
        'Upload timed out. Please try again.',
        statusCode: 0,
      );
    }
    return ref.getDownloadURL();
  }

  Future<Map<String, dynamic>> _uploadReceiptMultipart({
    required String paymentId,
    required File receiptFile,
  }) async {
    final sizeBytes = await receiptFile.length();
    const maxBytes = 5 * 1024 * 1024;
    if (sizeBytes > maxBytes) {
      throw ApiException(
        'Receipt image must be 5MB or smaller.',
        statusCode: 413,
      );
    }
    final token = await _resolveToken();
    final uri = Uri.parse('${ApiClient.baseUrl}/payments/$paymentId/receipt');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath('receipt', receiptFile.path),
      );

    http.StreamedResponse response;
    try {
      response = await request.send().timeout(const Duration(seconds: 25));
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

    final body = await response.stream.bytesToString();
    final data = _decodeBody(body);
    if (response.statusCode >= 400 || data['success'] == false) {
      final message =
          data['message']?.toString() ?? 'Failed to upload receipt.';
      throw ApiException(
        message,
        statusCode: response.statusCode,
        errors: data['errors'] is Map<String, dynamic>
            ? data['errors'] as Map<String, dynamic>
            : null,
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> _uploadReceiptBase64({
    required String paymentId,
    required File receiptFile,
  }) async {
    final sizeBytes = await receiptFile.length();
    const maxBytes = 5 * 1024 * 1024;
    if (sizeBytes > maxBytes) {
      throw ApiException(
        'Receipt image must be 5MB or smaller.',
        statusCode: 413,
      );
    }
    final bytes = await receiptFile.readAsBytes();
    final ext = _inferImageExt(receiptFile.path);
    final dataUrl = 'data:image/$ext;base64,${base64Encode(bytes)}';
    final response = await _client.post(
      '/payments/$paymentId/receipt',
      auth: true,
      body: {'receiptUrl': dataUrl},
    );
    return _extractItem(response['data']);
  }

  bool _shouldFallbackToBase64(ApiException error) {
    final status = error.statusCode ?? 0;
    if (status == 415) return true;
    if (status == 400 || status == 413 || status == 422) {
      final message = error.message.toLowerCase();
      return message.contains('receipturl') ||
          message.contains('receipt url') ||
          message.contains('unsupported') ||
          message.contains('invalid');
    }
    return false;
  }

  String _mapStorageError(FirebaseException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 'Please login again to upload the receipt.';
      case 'unauthorized':
      case 'permission-denied':
        return 'Permission denied while uploading. Please contact support.';
      case 'retry-limit-exceeded':
        return 'Network issue while uploading. Please try again.';
      case 'quota-exceeded':
        return 'Upload failed because storage quota was exceeded.';
      case 'canceled':
        return 'Upload was cancelled. Please try again.';
      case 'invalid-checksum':
        return 'Upload failed due to file integrity. Please try another image.';
      default:
        return 'Failed to upload receipt. Please try again.';
    }
  }

  int _mapStorageStatusCode(FirebaseException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 401;
      case 'unauthorized':
      case 'permission-denied':
        return 403;
      case 'retry-limit-exceeded':
        return 0;
      default:
        return 500;
    }
  }

  bool _shouldFallbackToMultipart(ApiException error) {
    final status = error.statusCode ?? 0;
    if (status == 400 || status == 415 || status == 422) {
      final message = error.message.toLowerCase();
      return message.contains('receipturl') ||
          message.contains('receipt url') ||
          message.contains('invalid') ||
          message.contains('url');
    }
    return false;
  }

  String _inferImageExt(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.gif')) return 'gif';
    return 'jpeg';
  }

  Future<String> _resolveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Authentication required.', statusCode: 401);
    }
    return token;
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

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['classes'] ?? data['data'] ?? data['items'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }

  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['payment'] is Map) {
        return Map<String, dynamic>.from(data['payment'] as Map);
      }
      if (data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return data;
    }
    return {};
  }
}
