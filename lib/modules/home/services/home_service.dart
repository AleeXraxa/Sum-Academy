import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/home/models/home_dashboard.dart';

class HomeService {
  HomeService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<HomeDashboard> fetchDashboard() async {
    final response = await _client.get('/student/dashboard', auth: true);
    final data = response['data'] ?? response;
    return HomeDashboard.fromAny(data);
  }
}
