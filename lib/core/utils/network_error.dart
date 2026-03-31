bool isNetworkErrorMessage(String message) {
  final lower = message.toLowerCase();
  return lower.contains('internet') ||
      lower.contains('network') ||
      lower.contains('timeout') ||
      lower.contains('connection');
}
