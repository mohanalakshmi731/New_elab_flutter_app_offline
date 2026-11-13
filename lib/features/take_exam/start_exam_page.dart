import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import 'exam_proctor_panel.dart';
import 'exam_security_logic.dart';
import 'exam_style.dart';
import 'exam_toast.dart';
import 'exam_window.dart';
import 'proctor_logic.dart' show ProctorWarningPayload;
import 'start_exam_logic.dart';
import 'start_exam_view.dart';
import 'take_exam_controller.dart';

/// Port of `src/pages/exams/startexam.vue` (`/startexam`, a standalone route
/// outside the shell).
///
/// [query] is the route query; `redirect` is where to go after the exam
/// (`this.$route.query.redirect`, default `/exams`).
///
/// The attempt comes from lmsHandoff `currentExamAttempt` (the store's
/// `startExam` result written by the exam list / schedule screens).
class StartExamPage extends ConsumerStatefulWidget {
  const StartExamPage({super.key, this.query = const {}});

  final Map<String, String> query;

  @override
  ConsumerState<StartExamPage> createState() => _StartExamPageState();
}

class _StartExamPageState extends ConsumerState<StartExamPage>
    with SingleTickerProviderStateMixin, WindowListener {
  // ── data() ───────────────────────────────────────────────────────────────
  int _endTime = 0;
  // ignore: unused_field
  bool _isOffline = false;
  bool _securityDialog = false;
  bool _violationTriggered = false;
  int _exitCountdown = 5;
  final Set<Timer> _exitTimers = {};
  bool _isSubmitting = false;
  bool _screenBlocked = false;
  String _securityBlockReason = '';
  Timer? _securityGuardTimer;
  bool _exitPrompt = false;
  // ignore: unused_field
  int _exitAttempts = 0;
  bool _graceActive = false;
  // ignore: unused_field
  int _graceCountdown = 1;
  Timer? _graceTimer;
  String _proctorCloseReason = '';
  bool _proctorReady = false;
  bool _guidelinesAccepted = false;

  /// `proctorWarningCount` / `maxProctorWarnings` / `lastProctorWarningAt`
  final _ledger = ExamWarningLedger(maxWarnings: 3);
  String _examReturnPath = '/exams';
  Map<String, dynamic> _exam = const {};
  List<ExamQuestion> _questions = const [];
  int _timeRemaining = 0;
  int _currentStep = 1;
  final Map<Object?, Object?> _answers = {};
  bool _confirmOpen = false;
  Timer? _timer;

  // ── Flutter-only state ───────────────────────────────────────────────────
  /// The listeners `enableExamSecurity()` adds are active.
  bool _securityOn = false;

  /// The browser's "Leave site?" prompt for `onbeforeunload` (desktop close).
  bool _leavePrompt = false;
  bool _windowListening = false;
  bool _disposed = false;
  AppLifecycleListener? _lifecycle;
  final _touches = <int>{};
  final _focus = FocusNode(debugLabel: 'startexam');
  final _scroll = ScrollController();
  final _questionCardKey = GlobalKey();
  final _panelKey = GlobalKey();
  final _panel = ExamProctorPanelController();
  final _textControllers = <Object?, TextEditingController>{};
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  TakeExamController get _ctrl => ref.read(takeExamControllerProvider.notifier);
  int get _maxProctorWarnings => _ledger.maxWarnings;
  int get _proctorWarningCount => _ledger.count;
  static int get _now => DateTime.now().millisecondsSinceEpoch;

  void _set(VoidCallback fn) {
    if (!mounted || _disposed) {
      fn();
      return;
    }
    setState(fn);
  }

  // ── computed ─────────────────────────────────────────────────────────────
  bool get _timeWarning => isTimeWarning(_timeRemaining);
  bool get _timeCritical => isTimeCritical(_timeRemaining);

  ExamQuestion? get _currentQuestion {
    final i = _currentStep - 1;
    return i >= 0 && i < _questions.length ? _questions[i] : null;
  }

  int get _answeredCount => answeredCount(_questions, _answers);

  double get _progressPercent =>
      _questions.isNotEmpty ? (_answeredCount / _questions.length) * 100 : 0;

  double get _progressCircle =>
      _questions.isNotEmpty ? (_answeredCount / _questions.length) * 113 : 0;

  // ── lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mountedHook();
  }

  /// `mounted()`
  void _mountedHook() {
    _examReturnPath = _resolveExamReturnPath();
    final attempt = _ctrl.currentExamAttempt;
    if (!jsTruthy(attempt)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(_examReturnPath);
      });
      return;
    }
    _exam = asMap(asMap(attempt)?['exam']) ?? const {};
    _endTime = 0;
    _timeRemaining = examDurationSeconds(_exam);
    _questions = mapAttemptQuestions(attempt);
    // window.onbeforeunload → intercept the desktop window's close button.
    if (ExamWindow.isDesktop) {
      windowManager.addListener(this);
      _windowListening = true;
      ExamWindow.setPreventClose(true);
    }
    // window 'online' / 'offline' arrive through the proctor panel's page.
  }

  /// `unmounted()`
  @override
  void dispose() {
    _disposed = true;
    _disableExamSecurity();
    _timer?.cancel();
    for (final t in _exitTimers) {
      t.cancel();
    }
    _graceTimer?.cancel();
    if (_windowListening) {
      windowManager.removeListener(this);
      ExamWindow.setPreventClose(false);
    }
    // The browser leaves fullscreen when the user wants to; a native window
    // would stay locked, so it is always restored here.
    ExamWindow.exitFullscreen();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    _focus.dispose();
    _scroll.dispose();
    _shake.dispose();
    super.dispose();
  }

  // ── methods ──────────────────────────────────────────────────────────────

  void _updateTimer() {
    _timer?.cancel();
    if (_endTime == 0) return;
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final remaining = remainingSeconds(_endTime, _now);
      setState(() => _timeRemaining = remaining);
      // Auto submit 2 seconds before end
      if (remaining <= 2) {
        t.cancel();
        if (!_isSubmitting) _autoSubmit();
      }
    });
  }

  void _handleOffline() {
    _set(() {
      _isOffline = true;
      _screenBlocked = true;
    });
    _timer?.cancel();
    _triggerTermination();
  }

  void _handleOnline() {
    _set(() {
      _isOffline = false;
      _screenBlocked = false;
    });
    if (_proctorReady) _updateTimer();
  }

  void _handleVisibilityChange() {
    if (ExamWindow.ignoringLifecycle) return;
    _flagViolation('BACKGROUND_ACTIVITY', 'The exam tab was hidden or another application became active.');
  }

  void _handleBlur() {
    if (ExamWindow.ignoringLifecycle) return;
    _flagViolation('BACKGROUND_ACTIVITY', 'Another window or application became active during the exam.');
  }

  void _handlePageHide() {
    if (ExamWindow.ignoringLifecycle) return;
    _flagViolation('PAGE_HIDDEN', 'The exam page moved to the background.');
  }

  /// `blockKeys(e)` (plus Escape closing the confirm dialog, which the web's
  /// `<Dialog>` does on its own).
  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
      if (_leavePrompt) {
        setState(() => _leavePrompt = false);
        return KeyEventResult.handled;
      }
      if (_confirmOpen) {
        setState(() => _confirmOpen = false);
        return KeyEventResult.handled;
      }
    }
    if (!_securityOn) return KeyEventResult.ignored;
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final kb = HardwareKeyboard.instance;
    final decision = examKeyDecision(
      key: _domKey(e.logicalKey),
      alt: kb.isAltPressed,
      meta: kb.isMetaPressed,
      ctrl: kb.isControlPressed,
      shift: kb.isShiftPressed,
    );
    switch (decision.action) {
      case ExamKeyAction.allow:
        return KeyEventResult.ignored;
      case ExamKeyAction.block:
        return KeyEventResult.handled;
      case ExamKeyAction.blockAndFlag:
        final v = decision.violation!;
        _flagViolation(v.type, v.message);
        return KeyEventResult.handled;
    }
  }

  /// DOM `KeyboardEvent.key` for the keys `blockKeys` looks at.
  static String _domKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.printScreen) return 'PrintScreen';
    return key.keyLabel;
  }

  /// `preventTouch(e)` — more than one finger down.
  void _onPointerDown(PointerDownEvent e) {
    if (e.kind != ui.PointerDeviceKind.touch) return;
    _touches.add(e.pointer);
    if (_securityOn && _touches.length > 1) {
      _flagViolation('MULTI_TOUCH_ATTEMPT', 'Multi-touch activity was detected.');
    }
  }

  void _onPointerUp(PointerEvent e) => _touches.remove(e.pointer);

  void _triggerShake() => _shake.forward(from: 0);

  Future<void> _flagViolation([String type = '', String message = '']) async {
    if (!_proctorReady || _violationTriggered || _isSubmitting || _graceActive) return;

    _triggerShake();
    var violationType = type;
    var violationMessage = message;
    if (type.isEmpty || message.isEmpty) {
      final fallback = defaultViolation(fullscreen: await ExamWindow.isFullscreen());
      if (violationType.isEmpty) violationType = fallback.type;
      if (violationMessage.isEmpty) violationMessage = fallback.message;
    }
    _set(() => _securityBlockReason = violationMessage);
    await _registerProctorWarning(ProctorWarningPayload(
      type: violationType,
      message: violationMessage,
      source: 'local',
    ));

    if (_violationTriggered) return;

    _set(() {
      _exitAttempts++;
      _graceActive = true;
      _graceCountdown = 0;
      _screenBlocked = true;
    });
  }

  Future<void> _cancelViolation() async {
    _graceTimer?.cancel();
    final fullscreen = await ExamWindow.ensureFullscreen();
    if (fullscreen) {
      _set(() {
        _graceActive = false;
        _screenBlocked = false;
        _securityBlockReason = '';
      });
    }
  }

  void _triggerTermination([String reason = '']) {
    _set(() {
      if (reason.isNotEmpty) _proctorCloseReason = reason;
      _securityDialog = true;
      _exitCountdown = 5;
    });
    // A second call starts a second interval, like the web's setInterval.
    late final Timer timer;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _exitCountdown--);
      if (_exitCountdown <= 0) {
        timer.cancel();
        _exitTimers.remove(timer);
        _autoSubmit();
      }
    });
    _exitTimers.add(timer);
  }

  Future<void> _handleProctorReady() async {
    if (_proctorReady) return;
    final durationSeconds = examDurationSeconds(_exam);
    _set(() => _proctorReady = true);
    await _enableExamSecurity();
    if (_disposed) return;
    _endTime = _now + durationSeconds * 1000;
    _set(() => _timeRemaining = durationSeconds);
    _updateTimer();
    ExamToast.success('Reference photo accepted. Exam timer starts now.');
  }

  Future<void> _handleProctorWarning(ProctorWarningPayload payload) => _registerProctorWarning(payload);

  void _handleProctorVerificationError(String message) {
    ExamToast.error(message.isNotEmpty
        ? message
        : 'Reference photo was rejected. Please open the camera shutter and capture clearly.');
  }

  Future<void> _registerProctorWarning(ProctorWarningPayload payload) async {
    if (!_proctorReady || _violationTriggered || _isSubmitting) return;
    final outcome = _ledger.register(immediateClose: payload.immediateClose, nowMs: _now);
    if (outcome == ExamWarningOutcome.immediateClose) {
      await _closeExamForImmediateProctorViolation(payload);
      return;
    }
    if (outcome == ExamWarningOutcome.throttled) return;
    _set(() {});

    ExamToast.warning('${payload.message} Warning $_proctorWarningCount/$_maxProctorWarnings');

    if (outcome == ExamWarningOutcome.limitReached) {
      _violationTriggered = true;
      _timer?.cancel();
      _graceTimer?.cancel();
      _set(() {
        _screenBlocked = false;
        _graceActive = false;
      });
      _disableExamSecurity();
      await _finishProctorSession('warning_limit_${payload.type}');
      _triggerTermination('Three proctor warnings were detected.');
    }
  }

  /// The ledger already moved `lastProctorWarningAt` and the count to the
  /// limit.
  Future<void> _closeExamForImmediateProctorViolation(ProctorWarningPayload payload) async {
    _violationTriggered = true;
    _timer?.cancel();
    _graceTimer?.cancel();
    _set(() {
      _screenBlocked = false;
      _graceActive = false;
    });

    ExamToast.error(
        payload.message.isNotEmpty ? payload.message : 'Background speech detected. Exam will be submitted.');

    _disableExamSecurity();
    await _finishProctorSession('immediate_close_${payload.type}');
    _triggerTermination(payload.message.isNotEmpty
        ? payload.message
        : 'Exam closed because background speech was detected.');
  }

  Future<void> _ensureFullScreen() => ExamWindow.enterFullscreen();

  Future<void> _runSecurityHeartbeat() async {
    if (!_proctorReady || _isSubmitting || _violationTriggered || _graceActive) return;
    // Our own fullscreen switch (macOS animates it) is not a violation.
    if (ExamWindow.ignoringLifecycle) return;

    final fullscreen = await ExamWindow.isFullscreen();
    final hasFocus = await ExamWindow.hasFocus();
    if (!mounted) return;
    final state = WidgetsBinding.instance.lifecycleState;
    final hidden = state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached;
    final focused = hasFocus && (state == null || state == AppLifecycleState.resumed);
    final size = MediaQuery.sizeOf(context);
    final violation = heartbeatViolation(
      fullscreen: fullscreen,
      hidden: hidden,
      focused: focused,
      width: size.width,
      height: size.height,
    );
    if (violation != null) _flagViolation(violation.type, violation.message);
  }

  void _startSecurityGuard() {
    _stopSecurityGuard();
    _securityGuardTimer = Timer.periodic(const Duration(seconds: 1), (_) => _runSecurityHeartbeat());
  }

  void _stopSecurityGuard() {
    _securityGuardTimer?.cancel();
    _securityGuardTimer = null;
  }

  Future<void> _enableExamSecurity() async {
    await _ensureFullScreen();
    if (_disposed) return;
    // keyboard.lock(['Escape']), contextmenu, keydown, touch: see _securityOn.
    _set(() => _securityOn = true);
    _lifecycle?.dispose();
    // blur / visibilitychange / pagehide
    _lifecycle = AppLifecycleListener(
      onInactive: _handleBlur,
      onHide: _handleVisibilityChange,
      onPause: _handlePageHide,
    );
    _startSecurityGuard();
    // fullscreenchange → onWindowLeaveFullScreen (desktop).
    FocusManager.instance.removeListener(_focusGuard);
    FocusManager.instance.addListener(_focusGuard);
    _focusGuard();
  }

  /// `window.addEventListener('keydown')` sees every key; a Flutter key
  /// handler only sees keys while focus is inside it, so focus is pulled
  /// back into the page whenever it leaves (e.g. to the route's scope).
  void _focusGuard() {
    if (!_securityOn || !mounted || _focus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _securityOn && !_focus.hasFocus) _focus.requestFocus();
    });
  }

  void _disableExamSecurity() {
    _stopSecurityGuard();
    FocusManager.instance.removeListener(_focusGuard);
    _lifecycle?.dispose();
    _lifecycle = null;
    if (_securityOn) _set(() => _securityOn = false);
  }

  void _continueExam() {
    _set(() => _exitPrompt = false);
    _ensureFullScreen();
  }

  void _exitExam() => _autoSubmit();

  void _autoSubmit() {
    if (!_isSubmitting) _submitExam();
  }

  Future<void> _finishProctorSession([String reason = 'exam_submitted']) => _panel.finish(reason);

  String _resolveExamReturnPath() => resolveExamReturnPath(widget.query['redirect']);

  void _redirectAfterExam() {
    if (!mounted) return;
    context.go(_examReturnPath.isNotEmpty ? _examReturnPath : _resolveExamReturnPath());
  }

  Future<void> _submitExam() async {
    if (_isSubmitting) return;
    _set(() {
      _isSubmitting = true;
      _confirmOpen = false;
    });
    await _finishProctorSession('exam_submitted');
    _disableExamSecurity();
    final attempt = _ctrl.currentExamAttempt;
    if (!jsTruthy(attempt)) return;
    final attemptId = asMap(attempt)?['id'];
    try {
      for (final payload in buildAnswerSubmissions(attemptId, _questions, _answers)) {
        await _ctrl.submitExamAnswer(payload);
      }
      await _ctrl.submitExamAttempt(attemptId);
      await ExamWindow.exitFullscreen();
      _redirectAfterExam();
    } catch (_) {
      await _alert('Submission failed. Please check your connection.');
      _redirectAfterExam();
    }
  }

  /// `alert(message)`
  Future<void> _alert(String message) async {
    if (!mounted) return;
    await showAppDialog<void>(
      context,
      barrierDismissible: false,
      builder: (ctx) => AppDialogFrame(
        description: message,
        showClose: false,
        maxWidth: 420,
        actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
      ),
    );
  }

  /// `watch: currentStep` → scroll the question card into view.
  void _goToStep(int step) {
    setState(() => _currentStep = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _questionCardKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0);
      }
    });
  }

  TextEditingController _textController(ExamQuestion q) => _textControllers.putIfAbsent(
        q.id,
        () => TextEditingController(text: _answers[q.id] is String ? _answers[q.id] as String : ''),
      );

  // ── window events (desktop) ──────────────────────────────────────────────

  /// `window.onbeforeunload`
  @override
  void onWindowClose() {
    if (!_isSubmitting && !_violationTriggered) {
      _flagViolation();
      _set(() => _leavePrompt = true);
    } else {
      ExamWindow.forceClose();
    }
  }

  /// `fullscreenchange` → `fullscreenHandler`
  @override
  void onWindowLeaveFullScreen() {
    if (!_securityOn || _isSubmitting || _violationTriggered) return;
    _flagViolation('FULLSCREEN_EXITED', 'Exam must remain in fullscreen.');
  }

  // ── template ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final answered = _answeredCount;

    final page = Material(
      color: Ex.paper,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Ex.ink),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExamTopBar(
              name: _exam['name'] == null ? '' : '${_exam['name']}',
              code: _exam['code'] == null ? '' : '${_exam['code']}',
              currentStep: _currentStep,
              total: total,
              progressCircle: _progressCircle,
              timeText: formatExamTime(_timeRemaining),
              timeWarning: _timeWarning,
              timeCritical: _timeCritical,
            ),
            ExamSlimProgress(fraction: _progressPercent / 100),
            Expanded(child: _main(context)),
            if (_proctorReady)
              ExamFooter(
                answered: answered,
                total: total,
                onSubmit: () => setState(() => _confirmOpen = true),
              ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: false,
      // popstate → preventNavigation while secured; otherwise "back".
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _securityOn) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(_examReturnPath);
        }
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shake,
                  builder: (context, child) {
                    const xs = [0.0, -6.0, 6.0, -4.0, 4.0, 0.0];
                    final t = _shake.value * 5;
                    final i = t.floor().clamp(0, 4);
                    final dx = _shake.isAnimating
                        ? ui.lerpDouble(xs[i], xs[i + 1], Curves.ease.transform((t - i).clamp(0.0, 1.0).toDouble()))!
                        : 0.0;
                    return Transform.translate(offset: Offset(dx, 0), child: child);
                  },
                  child: page,
                ),
              ),
              // ══════ CONFIRM DIALOG ══════
              Positioned.fill(
                child: ExamFade(
                  visible: _confirmOpen,
                  builder: (_) => ExamDialog(
                    onClose: () => setState(() => _confirmOpen = false),
                    child: ExamSubmitConfirm(
                      answered: answered,
                      total: total,
                      onBack: () => setState(() => _confirmOpen = false),
                      onSubmit: _submitExam,
                    ),
                  ),
                ),
              ),
              // ══════ SECURITY GRACE OVERLAY ══════
              Positioned.fill(child: ExamFade(visible: _screenBlocked, builder: _graceOverlay)),
              // ══════ EXIT PROMPT ══════
              Positioned.fill(child: ExamFade(visible: _exitPrompt, builder: _exitOverlay)),
              // ══════ TERMINATION ══════
              Positioned.fill(child: ExamFade(visible: _securityDialog, builder: _terminationOverlay)),
              // window.onbeforeunload's browser prompt
              if (_leavePrompt)
                Positioned.fill(
                  child: ExamDialog(
                    maxWidth: 420,
                    onClose: () => setState(() => _leavePrompt = false),
                    child: _leaveSiteBody(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _main(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final xl = size.width >= 1280;
    final contentWidth = size.width * 0.94; // w-[94%] mx-auto
    final panelHeight = math.max(500.0, size.height - 210); // h-[calc(100vh-210px)] min-h-[500px]
    final current = _currentQuestion;

    final panel = current == null
        ? null
        : ExamProctorPanel(
            key: _panelKey,
            controller: _panel,
            attemptId: asMap(_ctrl.currentExamAttempt)?['id'],
            examName: _exam['name'] == null ? '' : '${_exam['name']}',
            warningCount: _proctorWarningCount,
            maxWarnings: _maxProctorWarnings,
            leftConfirmed: _guidelinesAccepted,
            onReady: _handleProctorReady,
            onWarning: _handleProctorWarning,
            onVerificationError: _handleProctorVerificationError,
            onNetworkChanged: (online) => online ? _handleOnline() : _handleOffline(),
          );

    Widget intro({required bool fill}) => ExamIntroCard(
          accepted: _guidelinesAccepted,
          onAccepted: (v) => setState(() => _guidelinesAccepted = v),
          fill: fill,
        );

    Widget? questionCard({required bool fill}) {
      if (current == null) return null;
      return ExamQuestionCard(
        key: _questionCardKey,
        fill: fill,
        question: current,
        currentStep: _currentStep,
        total: _questions.length,
        answer: _answers[current.id],
        answered: isQuestionAnswered(current, _answers[current.id]),
        onSelectOption: (id) => setState(() => _answers[current.id] = id),
        textController: current.isText ? _textController(current) : null,
        onTextChanged: (v) => setState(() => _answers[current.id] = v),
        allowTextMenu: !_securityOn,
        onPrevious: _currentStep == 1 ? null : () => _goToStep(_currentStep - 1),
        onNext: _currentStep == _questions.length ? null : () => _goToStep(_currentStep + 1),
      );
    }

    if (xl) {
      // grid-cols-[minmax(0,3fr)_minmax(300px,1fr)] gap-4 inside px-6
      final avail = contentWidth - 48 - 16;
      final right = math.max(300.0, avail / 4);
      final left = math.max(0.0, avail - right);

      if (!_proctorReady) {
        // xl:h-screen xl:overflow-hidden — both columns fill the height.
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: left, child: intro(fill: true)),
                  const SizedBox(width: 16),
                  SizedBox(width: right, child: panel ?? const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        );
      }

      return LayoutBuilder(builder: (context, c) {
        final card = questionCard(fill: true);
        final stretchedCard = card == null
            ? const SizedBox.shrink()
            : ConstrainedBox(
                constraints: BoxConstraints(minHeight: panelHeight),
                child: IntrinsicHeight(child: card),
              );
        final panelBox = SizedBox(width: right, height: panelHeight, child: panel);
        // The panel is `sticky top-[74px]`: keep it in place and scroll the
        // question when there is room, otherwise scroll everything.
        if (c.maxHeight >= panelHeight + 48) {
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: left + 24,
                    height: c.maxHeight,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
                      child: stretchedCard,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(padding: const EdgeInsets.only(top: 24), child: panelBox),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          controller: _scroll,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: left, child: stretchedCard),
                    const SizedBox(width: 16),
                    panelBox,
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }

    // Single column: card, then the panel.
    final card = _proctorReady ? questionCard(fill: false) : intro(fill: false);
    return SingleChildScrollView(
      controller: _scroll,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: contentWidth,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?card,
                if (card != null && panel != null) const SizedBox(height: 16),
                if (panel != null)
                  _proctorReady ? SizedBox(height: panelHeight, child: panel) : panel,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _graceOverlay(BuildContext context) => ExamSecurityOverlay(
        backdrop: Colors.black.withValues(alpha: 0.9),
        icon: '⚠️',
        title: 'Fullscreen Required',
        body: [
          Text.rich(
            TextSpan(
              style: examOverlayText(),
              children: [
                TextSpan(
                    text: _securityBlockReason.isNotEmpty
                        ? _securityBlockReason
                        : 'The exam cannot continue outside fullscreen.'),
                const TextSpan(text: '\nWarning '),
                TextSpan(
                  text: '$_proctorWarningCount/$_maxProctorWarnings',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Ex.amber300),
                ),
                const TextSpan(text: ' recorded.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16 + 24),
          ExamBlueButton(
            label: 'Resume Fullscreen',
            onPressed: _cancelViolation,
            expand: true,
            radius: 20,
            fontWeight: FontWeight.w600,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          const SizedBox(height: 12 + 24),
          Text('Third warning will auto-submit the exam.',
              textAlign: TextAlign.center, style: examOverlayHint()),
        ],
      );

  Widget _exitOverlay(BuildContext context) => ExamSecurityOverlay(
        backdrop: const Color.fromRGBO(0, 20, 40, 0.9),
        icon: '🚪',
        title: 'Exit Exam?',
        body: [
          Text('Your progress will be saved but the attempt will be submitted.',
              textAlign: TextAlign.center, style: examOverlayText()),
          const SizedBox(height: 24 + 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExamOutlineButton(label: 'Stay', onPressed: _continueExam, background: Colors.white),
              const SizedBox(width: 12),
              ExamBlueButton(
                label: 'Exit',
                onPressed: _exitExam,
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ],
      );

  Widget _terminationOverlay(BuildContext context) => ExamSecurityOverlay(
        backdrop: const Color.fromRGBO(30, 0, 0, 0.95),
        icon: '🚫',
        title: 'Exam Terminated',
        titleColor: Ex.red300,
        cardBorder: Ex.red900.withValues(alpha: 0.4),
        body: [
          Text(
            '${_proctorCloseReason.isNotEmpty ? _proctorCloseReason : 'Multiple security violations detected.'}'
            '\nYour attempt has been automatically submitted.',
            textAlign: TextAlign.center,
            style: examOverlayText(),
          ),
          const SizedBox(height: 24 + 24),
          Center(
            child: ExamPulse(
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Ex.red500, width: 3),
                ),
                child: Text('$_exitCountdown',
                    style: const TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: Ex.red300)),
              ),
            ),
          ),
          const SizedBox(height: 8 + 24 + 8),
          Text('Redirecting in ${_exitCountdown}s…', textAlign: TextAlign.center, style: examOverlayHint()),
        ],
      );

  Widget _leaveSiteBody() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Leave site?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Changes that you made may not be saved.',
              style: TextStyle(fontSize: 14, color: context.exMuted)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ExamOutlineButton(label: 'Cancel', onPressed: () => setState(() => _leavePrompt = false)),
              const SizedBox(width: 12),
              ExamBlueButton(
                label: 'Leave',
                onPressed: ExamWindow.forceClose,
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ],
      );
}
