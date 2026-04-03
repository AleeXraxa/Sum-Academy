import 'package:get/get.dart';
import 'package:sum_academy/modules/auth/services/auth_service.dart';
import 'package:sum_academy/modules/student/utils/student_navigation.dart';

class StudentShellController extends GetxController {
  StudentShellController(this._authService);

  final AuthService _authService;

  final navIndex = 0.obs;
  final activeLabel = studentNavItems.first.obs;
  final userName = 'Student'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    userName.value = await _authService.getCurrentUserName();
  }

  void setNavIndex(int index) {
    navIndex.value = index;
    activeLabel.value = studentActiveLabelForIndex(index);
  }

  void setActiveLabel(String label) {
    final index = studentNavIndexForLabel(label);
    if (index == null) {
      return;
    }
    navIndex.value = index;
    activeLabel.value = label;
  }
}
