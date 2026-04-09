import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_certificate.dart';

class StudentCertificatesService {
  StudentCertificatesService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentCertificate>> fetchCertificates() async {
    final response = await _client.get('/student/certificates', auth: true);
    final data = response['data'] ?? response;
    return parseCertificates(data);
  }

  Future<void> verifyCertificate(String certId) async {
    if (certId.trim().isEmpty) {
      throw ApiException('Certificate ID is required.');
    }
    await _client.get('/verify/$certId', auth: false);
  }
}
