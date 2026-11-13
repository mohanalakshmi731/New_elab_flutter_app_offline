import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/services.dart';
import 'signup_payloads.dart';

/// The sign-up slice of `useUserStore`: the `signupinstitute` state and the
/// `signform`, `fetchInstituteByCode` and `signupform` actions, ported 1:1.
/// (`states` / `countries` come from `features/common/lookups.dart`.)
class SignupController extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {...defaultSignupInstitute};

  /// `signform(form)` — `POST /signup/signup` (signup.vue).
  Future<dynamic> signform(Map<String, dynamic> form) =>
      ref.read(instituteServiceProvider).signupform(buildSignformFields(form));

  /// `fetchInstituteByCode(code)` — `GET /invitation/institute/{code}`.
  Future<dynamic> fetchInstituteByCode(String code) =>
      ref.read(instituteServiceProvider).code(code);

  /// `this.store.signupinstitute = {...}`
  void setSignupInstitute(Map<String, dynamic> value) => state = {...value};

  /// `signupform()` — `POST /signup/institute` with `signupinstitute`
  /// (selfsignup.vue).
  Future<dynamic> signupform() =>
      ref.read(instituteServiceProvider).signup(buildSelfSignupFields(state));
}

final signupControllerProvider =
    NotifierProvider<SignupController, Map<String, dynamic>>(SignupController.new);
