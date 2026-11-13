import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';

/// The `useUserStore` slice `startexam.vue` maps: state `currentExamAttempt`
/// and the actions `submitExamAnswer` / `submitExamAttempt` (`startExam` is
/// mapped too but never called by the page; it lives in
/// `ScheduleExamController.startExam`).
///
/// `currentExamAttempt` is shared through [lmsHandoffProvider] under its web
/// name — the screens that start an attempt write it there before going to
/// `/startexam`.
class TakeExamController extends Notifier<void> {
  @override
  void build() {}

  UserInfo? get _userInfo => ref.read(sessionProvider).userInfo;
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `mapState(useUserStore, ['currentExamAttempt'])`
  dynamic get currentExamAttempt => _handoff.get('currentExamAttempt');

  String _requireInstitute() {
    final id = _userInfo?.instituteId;
    if (!jsTruthy(id)) throw const ApiError('Institute ID not available');
    return '$id';
  }

  /// `submitExamAnswer(payload)` — adds `institute_id`.
  Future<dynamic> submitExamAnswer(Map<String, dynamic> payload) async {
    final finalPayload = {'institute_id': _requireInstitute(), ...payload};
    return ref.read(examsServiceProvider).submitExamAnswer(finalPayload);
  }

  /// `submitExamAttempt(exam_attempt_id)` — clears `currentExamAttempt` on
  /// success.
  Future<dynamic> submitExamAttempt(Object? examAttemptId) async {
    final payload = {'institute_id': _requireInstitute(), 'exam_attempt_id': examAttemptId};
    final res = await ref.read(examsServiceProvider).submitExamAttempt(payload);
    _handoff.set('currentExamAttempt', null);
    return res;
  }
}

final takeExamControllerProvider =
    NotifierProvider<TakeExamController, void>(TakeExamController.new);
