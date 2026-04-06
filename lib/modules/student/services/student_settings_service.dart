import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_settings.dart';

class StudentSettingsService {
  StudentSettingsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentSettings> fetchSettings() async {
    final response = await _client.get('/student/settings', auth: true);
    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      return StudentSettings.fromJson(data);
    }
    return const StudentSettings(
      fullName: '',
      email: '',
      phoneNumber: '',
      fatherName: '',
      fatherPhone: '',
      fatherOccupation: '',
      district: '',
      domicile: '',
      caste: '',
      address: '',
    );
  }

  Future<StudentSettings> updateSettings(StudentSettings settings) async {
    final response = await _client.put(
      '/student/settings',
      auth: true,
      body: settings.toUpdatePayload(),
    );
    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      return StudentSettings.fromJson(data);
    }
    return settings;
  }
}
