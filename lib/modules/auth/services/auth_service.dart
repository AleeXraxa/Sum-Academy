import 'dart:async';

class AuthService {
  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
  }

  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  Future<void> verifyOtp({required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }
}
