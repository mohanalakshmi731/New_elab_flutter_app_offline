import '../../core/network/api_client.dart';

/// Port of `src/service/login.service.ts`.
class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<dynamic> login(String email, String password, String modelId) =>
      _api.post('/auth/login', data: {
        'email': email,
        'password': password,
        'model': modelId,
      });

  Future<dynamic> logout() => _api.post('/auth/logout', silent: true);

  Future<dynamic> changePassword(
          String oldPassword, String newPassword, String confirmPassword) =>
      _api.post('/auth/password/change', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });

  Future<dynamic> generateTwoFactorAuth(int userId) =>
      _api.post('/auth/2fa/generate', data: {'user_id': userId});

  Future<dynamic> registerTwoFactorAuth(String code) =>
      _api.post('/auth/2fa/register', data: {'code': code});

  /// Send OTP to the user's email.
  Future<dynamic> forgotPassword(String email) =>
      _api.post('/auth/password/auth/forgot-password', data: {'email': email});

  /// Reset password with OTP.
  Future<dynamic> resetPassword(String email, String otp, String password,
          String passwordConfirmation) =>
      _api.post('/auth/password/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

  Future<dynamic> verifyTwoFactorAuth(String code, String model) =>
      _api.post('/auth/2fa/verify', data: {'code': code, 'model': model});
}
