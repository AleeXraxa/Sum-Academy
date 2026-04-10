import 'dart:io';

import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/models/student_certificate.dart';
import 'package:sum_academy/modules/student/models/student_course.dart';
import 'package:sum_academy/modules/student/services/student_certificates_service.dart';

class StudentCertificatesController extends GetxController {
  StudentCertificatesController(this._service);

  final StudentCertificatesService _service;

  final certificates = <StudentCertificate>[].obs;
  final isLoading = false.obs;
  final coursesInProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCertificates();
    _linkCourses();
  }

  Future<void> fetchCertificates({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }
    try {
      certificates.assignAll(await _service.fetchCertificates());
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Certificates',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Certificates',
        message: 'Unable to load certificates. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchCertificates(silent: true);
  }

  int get totalEarned => certificates.length;

  Future<void> verifyCertificate(String certId) async {
    try {
      await _service.verifyCertificate(certId);
      await showAppSuccessDialog(
        title: 'Certificate Verified',
        message: 'This certificate is valid.',
      );
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showAppErrorDialog(
          title: 'Verification failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showAppErrorDialog(
        title: 'Verification failed',
        message: 'Unable to verify this certificate.',
      );
    }
  }

  Future<File> downloadCertificate(StudentCertificate certificate) async {
    return _service.downloadCertificate(
      url: certificate.pdfUrl,
      fileName: certificate.certificateId.isNotEmpty
          ? certificate.certificateId
          : certificate.id,
    );
  }

  void _linkCourses() {
    if (!Get.isRegistered<StudentCoursesController>()) return;
    final controller = Get.find<StudentCoursesController>();
    ever<List<StudentCourse>>(controller.courses, _updateProgressCount);
    _updateProgressCount(controller.courses);
  }

  void _updateProgressCount(List<StudentCourse> courses) {
    coursesInProgress.value = courses
        .where((course) => course.isEnrolled && !course.isCompleted)
        .length;
  }
}
