import 'package:get/get.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';

bool isNetworkErrorMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('internet') ||
      lower.contains('network') ||
      lower.contains('timeout') ||
      lower.contains('connection');
}

DateTime? _lastNoInternetShownAt;
bool _noInternetDialogShowing = false;

Future<void> showNoInternetDialogOnce({String? message}) async {
  if (_noInternetDialogShowing) return;
  final now = DateTime.now();
  if (_lastNoInternetShownAt != null &&
      now.difference(_lastNoInternetShownAt!).inSeconds < 2) {
    return;
  }
  final context = Get.context;
  if (context == null) {
    return;
  }
  _noInternetDialogShowing = true;
  _lastNoInternetShownAt = now;
  try {
    await showNoInternetDialog(
      context,
      message: message ??
          'No internet connection. Please check your connection and try again.',
    );
  } finally {
    _noInternetDialogShowing = false;
  }
}

Future<bool> handleNetworkError(ApiException exception) async {
  if (exception.statusCode == 0) {
    await showNoInternetDialogOnce(message: exception.message);
    return true;
  }
  return false;
}

Future<void> showAppErrorDialog({
  required String title,
  required String message,
}) async {
  final context = Get.context;
  if (context == null) return;
  await showErrorDialog(context, title: title, message: message);
}

Future<void> showAppSuccessDialog({
  required String title,
  required String message,
}) async {
  final context = Get.context;
  if (context == null) return;
  await showSuccessDialog(context, title: title, message: message);
}
