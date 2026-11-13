/// Pure lock-down rules of `src/pages/exams/startexam.vue`: key blocking,
/// the 1-second security heartbeat and the warning counter of
/// `registerProctorWarning` (unit-tested in `test/take_exam_logic_test.dart`).
library;

import 'dart:math' as math;

/// `{ type, message }` passed to `flagViolation(type, message)`.
class ExamViolation {
  const ExamViolation(this.type, this.message);
  final String type;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is ExamViolation && other.type == type && other.message == message;

  @override
  int get hashCode => Object.hash(type, message);

  @override
  String toString() => 'ExamViolation($type, $message)';
}

/// Window minimum of the heartbeat (`innerWidth < 900 || innerHeight < 560`).
const examMinWindowWidth = 900.0;
const examMinWindowHeight = 560.0;

/// `registerProctorWarning` ignores warnings closer than this.
const examWarningThrottleMs = 1700;

/// `flagViolation()` without arguments: the type/message depend on whether
/// the page is still fullscreen.
ExamViolation defaultViolation({required bool fullscreen}) => fullscreen
    ? const ExamViolation('WINDOW_FOCUS_LOST', 'Exam window lost focus.')
    : const ExamViolation('FULLSCREEN_EXITED', 'Exam must remain in fullscreen.');

const fullscreenExitedViolation =
    ExamViolation('FULLSCREEN_EXITED', 'Exam must remain in fullscreen.');

/// `runSecurityHeartbeat()` — the first failing check wins.
ExamViolation? heartbeatViolation({
  required bool fullscreen,
  required bool hidden,
  required bool focused,
  required double width,
  required double height,
}) {
  if (!fullscreen) return fullscreenExitedViolation;
  if (hidden || !focused) {
    return const ExamViolation(
        'BACKGROUND_ACTIVITY', 'Another window, app, or screen-sharing tool became active.');
  }
  if (width < examMinWindowWidth || height < examMinWindowHeight) {
    return const ExamViolation(
        'WINDOW_TOO_SMALL', 'Exam window size changed below the allowed area.');
  }
  return null;
}

/// What `blockKeys(e)` does with a keydown.
enum ExamKeyAction {
  /// Not handled — the key reaches the page.
  allow,

  /// `e.preventDefault()` only.
  block,

  /// `e.preventDefault()` + `flagViolation(…)` ([ExamKeyDecision.violation]).
  blockAndFlag,
}

class ExamKeyDecision {
  const ExamKeyDecision(this.action, [this.violation]);
  final ExamKeyAction action;
  final ExamViolation? violation;

  static const allow = ExamKeyDecision(ExamKeyAction.allow);
  static const block = ExamKeyDecision(ExamKeyAction.block);
}

const _blockedKeys = {'F12', 'F11', 'F10', 'F5'};
const _ctrlShiftKeys = {'I', 'J', 'C', 'K'};
const _ctrlKeys = {'U', 'S', 'P', 'A', 'L', 'R', 'T', 'W'};

/// `blockKeys(e)` — [key] is the DOM `KeyboardEvent.key` name (`F12`,
/// `PrintScreen`, `a`/`A`, `Alt`, …).
ExamKeyDecision examKeyDecision({
  required String key,
  required bool alt,
  required bool meta,
  required bool ctrl,
  required bool shift,
}) {
  if (_blockedKeys.contains(key)) return ExamKeyDecision.block;
  if (alt || meta) {
    return const ExamKeyDecision(
      ExamKeyAction.blockAndFlag,
      ExamViolation('SYSTEM_SHORTCUT_ATTEMPT', 'System or browser shortcut activity was detected.'),
    );
  }
  final upper = key.toUpperCase();
  if ((ctrl && shift && _ctrlShiftKeys.contains(upper)) ||
      (ctrl && _ctrlKeys.contains(upper)) ||
      (meta && shift)) {
    return ExamKeyDecision.block;
  }
  if (key == 'PrintScreen') {
    return const ExamKeyDecision(
      ExamKeyAction.blockAndFlag,
      ExamViolation('SCREENSHOT_ATTEMPT', 'Screenshot activity was detected.'),
    );
  }
  return ExamKeyDecision.allow;
}

/// Outcome of [ExamWarningLedger.register].
enum ExamWarningOutcome {
  /// Within [examWarningThrottleMs] of the previous one — not counted.
  throttled,

  /// Counted, still below the limit (a warning toast is shown).
  counted,

  /// Counted and the limit is reached → terminate.
  limitReached,

  /// `payload.immediateClose` → count jumps to the limit, terminate.
  immediateClose,
}

/// `proctorWarningCount` / `lastProctorWarningAt` bookkeeping of
/// `registerProctorWarning` and `closeExamForImmediateProctorViolation`
/// (the `proctorReady / violationTriggered / isSubmitting` guards stay in the
/// page).
class ExamWarningLedger {
  ExamWarningLedger({this.maxWarnings = 3});

  /// `maxProctorWarnings`
  final int maxWarnings;

  /// `proctorWarningCount`
  int count = 0;

  /// `lastProctorWarningAt`
  int lastAt = 0;

  ExamWarningOutcome register({required bool immediateClose, required int nowMs}) {
    if (immediateClose) {
      lastAt = nowMs;
      count = maxWarnings;
      return ExamWarningOutcome.immediateClose;
    }
    if (nowMs - lastAt < examWarningThrottleMs) return ExamWarningOutcome.throttled;
    lastAt = nowMs;
    count = math.min(maxWarnings, count + 1);
    return count >= maxWarnings ? ExamWarningOutcome.limitReached : ExamWarningOutcome.counted;
  }
}
