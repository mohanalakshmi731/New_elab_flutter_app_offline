import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mz_html_text.dart';
import '../mathzoro/mz_ui.dart' show HoverBuilder;
import 'bridged_web_view.dart';
import 'quiz_exam_logic.dart';

part 'quiz_exam_ui.dart';

/// Port of `src/components/QuizExam.vue` — the quiz overlay used by the
/// activity pages and the math/science zones:
/// `<QuizExam :visible :questions :quiz-title :scanner-url :scanner-title
///  @submitted @close>`.
///
/// The web toggles it with `visible` (a `fixed inset-0` full-screen layer
/// teleported to `<body>`); in Flutter call [showQuizExam] where the page
/// sets `visible = true`, and run the page's `@close` handler in [onClose]
/// (or after the returned future completes).
///
/// [onSubmitted] receives the `submitted` payload:
/// `{ 'answers': {questionId: optionId}, 'answersPayload':
/// [{question_id, option_id}] }` (ids stringified in the payload). The quiz
/// closes right after submitting (no result screen), so [onSubmitted] runs
/// first and [onClose] right after — as on the web.
///
/// With a non-empty [scannerUrl] the overlay shows the QuizSys scanner page
/// instead of the questions (no security, no footer); the scanner closes it
/// by posting `{ type: 'quizsys:back' }`.
Future<void> showQuizExam(
  BuildContext context, {
  required List<dynamic> questions,
  String quizTitle = 'Quiz',
  String scannerUrl = '',
  String scannerTitle = 'QuizSys Scanner',
  ValueChanged<Map<String, dynamic>>? onSubmitted,
  VoidCallback? onClose,
}) async {
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => QuizExamView(
        questions: questions,
        quizTitle: quizTitle,
        scannerUrl: scannerUrl,
        scannerTitle: scannerTitle,
        onSubmitted: onSubmitted,
      ),
      // enter: opacity-0 scale-95 → 1 (300ms ease-out); leave: 200ms ease-in.
      transitionsBuilder: (_, anim, _, child) {
        final a = CurvedAnimation(parent: anim, curve: Curves.easeOut, reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(a), child: child),
        );
      },
    ),
  );
  onClose?.call();
}

/// The quiz body (what the overlay shows). Pops its route on close, unless
/// [onClose] is given (then that is called instead).
class QuizExamView extends ConsumerStatefulWidget {
  const QuizExamView({
    super.key,
    required this.questions,
    this.quizTitle = 'Quiz',
    this.scannerUrl = '',
    this.scannerTitle = 'QuizSys Scanner',
    this.onSubmitted,
    this.onClose,
  });

  /// `questions` prop (array of question objects, as the parents pass them).
  final List<dynamic> questions;
  final String quizTitle;
  final String scannerUrl;

  /// `scannerTitle` prop — declared by the web component but never rendered
  /// (the scanner iframe's title is the fixed "QuizSys Scanner").
  final String scannerTitle;

  /// `$emit('submitted', {...})`
  final ValueChanged<Map<String, dynamic>>? onSubmitted;

  /// `$emit('close')` when the view is embedded instead of pushed as a route.
  final VoidCallback? onClose;

  @override
  ConsumerState<QuizExamView> createState() => _QuizExamViewState();
}

class _QuizExamViewState extends ConsumerState<QuizExamView>
    with SingleTickerProviderStateMixin, WindowListener {
  static const _maxViolations = 1;

  int _currentStep = 1;
  Map<String, dynamic> _answers = {};
  bool _confirmOpen = false;
  bool _isSubmitting = false;

  // Security
  int _violations = 0;
  bool _graceActive = false;
  int _graceCountdown = 10;
  Timer? _graceTimer;
  bool _screenBlocked = false;
  bool _securityDialog = false;
  int _exitCountdown = 5;
  Timer? _exitTimer;
  bool _violationTriggered = false;

  bool _securityOn = false;
  bool _fullscreenOn = false;
  bool _closed = false;
  AppLifecycleListener? _lifecycle;
  DateTime _ignoreFocusLossUntil = DateTime.fromMillisecondsSinceEpoch(0);
  final Set<int> _touches = {};

  final _scroll = ScrollController();
  final _focus = FocusNode(debugLabel: 'quiz-exam');
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ── computed ─────────────────────────────────────────────────────────────

  int get _total => widget.questions.length;

  bool get _isScannerPluginMode => widget.scannerUrl.isNotEmpty;

  /// `questions[currentStep - 1] || null`.
  Map<String, dynamic>? get _currentQuestion {
    final i = _currentStep - 1;
    if (i < 0 || i >= _total) return null;
    return asMap(widget.questions[i]);
  }

  /// `Object.keys(answers).length`.
  int get _answeredCount => _answers.length;

  /// `!!answers[q.id]`.
  bool _isAnswered(Map<String, dynamic> q) => jsTruthy(_answers[quizKey(q['id'])]);

  /// `answers[q.id] === option.id`.
  bool _isChosen(Map<String, dynamic> q, Map<String, dynamic> option) {
    final key = quizKey(q['id']);
    return _answers.containsKey(key) && _answers[key] == option['id'];
  }

  // ── lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // `visible` turned true → initQuiz()
    _initQuiz();
  }

  @override
  void dispose() {
    _teardown();
    _scroll.dispose();
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _initQuiz() {
    _currentStep = 1;
    _answers = {};
    _isSubmitting = false;
    _violations = 0;
    _violationTriggered = false;
    _screenBlocked = false;
    _graceActive = false;
    _securityDialog = false;
    _confirmOpen = false;
    if (_isScannerPluginMode) {
      _enterFullscreen();
      return;
    }
    _enableSecurity();
  }

  void _teardown() {
    _disableSecurity();
    _graceTimer?.cancel();
    _exitTimer?.cancel();
  }

  // ── answering ────────────────────────────────────────────────────────────

  void _onOptionSelect(Map<String, dynamic> question, Map<String, dynamic> option) {
    if (_isAnswered(question)) return;
    // v-model sets the answer, then @change shows the feedback toast.
    _set(() => _answers = {..._answers, quizKey(question['id']): option['id']});

    toastification.dismissAll(delayForAnimation: false);
    if (quizOptionIsCorrect(option)) {
      _feedbackToast('Correct answer! 🎉', const Color(0xFF28883F), ToastificationType.success,
          Icons.check_circle_rounded, const Duration(milliseconds: 4000));
    } else {
      _feedbackToast('Wrong answer. ❌', const Color(0xFFFF000D), ToastificationType.error, Icons.error_rounded,
          const Duration(milliseconds: 5000));
    }
  }

  /// `toast.success/error(…, { duration, style: { fontSize: '1rem', color:
  /// 'white', backgroundColor } })` in the kit's top-right `Toaster`.
  void _feedbackToast(String message, Color bg, ToastificationType type, IconData icon, Duration duration) {
    toastification.show(
      type: type,
      style: ToastificationStyle.fillColored,
      primaryColor: bg,
      // fillColored: `backgroundColor` is the text / close-icon colour.
      backgroundColor: Colors.white,
      icon: Icon(icon, color: Colors.white),
      title: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: duration,
      showProgressBar: false,
      dragToClose: true,
      closeOnClick: true,
    );
  }

  void _goToStep(int step) {
    _set(() => _currentStep = step);
    // watch currentStep → questionCard.scrollIntoView({ behavior: 'smooth' })
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  void _submitQuiz() {
    if (_isSubmitting) return;
    _set(() {
      _isSubmitting = true;
      _confirmOpen = false;
    });
    _disableSecurity();

    // Emit to parent so it can call submitZslQuiz store action
    widget.onSubmitted?.call({
      'answers': jsOrderedAnswers(_answers),
      'answersPayload': buildQuizAnswersPayload(_answers),
    });

    // Close immediately — no result screen
    _closeQuiz();
  }

  void _autoSubmit() {
    if (!_isSubmitting) _submitQuiz();
  }

  void _closeQuiz() {
    _teardown();
    if (_closed || !mounted) return;
    _closed = true;
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
    } else {
      // pop() (not maybePop) so the PopScope used while secured never blocks it.
      Navigator.of(context).pop();
    }
  }

  void _handleScannerPluginMessage(dynamic data) {
    final message = asMap(parseBridgeMessage(data));
    if (message == null) return;
    if (message['type'] == 'quizsys:back') _closeQuiz();
  }

  // ── security (fullscreen / focus loss / key blocking) ───────────────────

  static bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// `document.documentElement.requestFullscreen()`.
  Future<void> _enterFullscreen() async {
    _ignoreFocusLossUntil = DateTime.now().add(const Duration(milliseconds: 1500));
    _fullscreenOn = true;
    try {
      if (_isDesktop) {
        await windowManager.setFullScreen(true);
      } else if (!kIsWeb) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    } catch (_) {
      // Continue if fullscreen is unavailable or denied.
    }
  }

  /// `if (document.fullscreenElement) document.exitFullscreen()`.
  Future<void> _exitFullscreen() async {
    if (!_fullscreenOn) return;
    _fullscreenOn = false;
    try {
      if (_isDesktop) {
        if (await windowManager.isFullScreen()) await windowManager.setFullScreen(false);
      } else if (!kIsWeb) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    } catch (_) {
      // Allow teardown to finish if the fullscreen exit call throws.
    }
  }

  void _enableSecurity() {
    if (_securityOn) return;
    _securityOn = true;
    _enterFullscreen();
    // blur / visibilitychange / pagehide → app focus & lifecycle changes.
    _lifecycle = AppLifecycleListener(
      onInactive: _onFocusLost,
      onHide: _onFocusLost,
      onPause: _onFocusLost,
    );
    // fullscreenchange → the window leaving full screen.
    if (_isDesktop) windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _disableSecurity() {
    if (_securityOn) {
      _securityOn = false;
      _lifecycle?.dispose();
      _lifecycle = null;
      if (_isDesktop) windowManager.removeListener(this);
    }
    _exitFullscreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    // fullscreenHandler: leaving fullscreen while the quiz runs is a violation.
    if (!_securityOn || _isSubmitting || _violationTriggered) return;
    _fullscreenOn = false;
    _flagViolation();
  }

  void _onFocusLost() {
    if (!_securityOn || DateTime.now().isBefore(_ignoreFocusLossUntil)) return;
    _flagViolation();
  }

  /// `blockKeys(e)` — function keys, Ctrl/Meta/Alt shortcuts, Tab and
  /// PrintScreen (which also counts as a violation); Escape is held like
  /// `navigator.keyboard.lock(['Escape'])`.
  KeyEventResult _blockKeys(FocusNode node, KeyEvent e) {
    if (!_securityOn) return KeyEventResult.ignored;
    final key = e.logicalKey;
    final kb = HardwareKeyboard.instance;
    if (key == LogicalKeyboardKey.printScreen) {
      if (e is KeyDownEvent) _flagViolation();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.tab ||
        RegExp(r'^F\d{1,2}$').hasMatch(key.keyLabel) ||
        kb.isControlPressed ||
        kb.isMetaPressed ||
        kb.isAltPressed) {
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// `preventTouch(e)` — more than one finger is a violation.
  void _onPointerDown(PointerDownEvent e) {
    if (e.kind != ui.PointerDeviceKind.touch) return;
    _touches.add(e.pointer);
    if (_securityOn && _touches.length > 1) _flagViolation();
  }

  void _onPointerUp(PointerEvent e) => _touches.remove(e.pointer);

  void _triggerShake() => _shake.forward(from: 0);

  void _flagViolation() {
    if (_violationTriggered || _isSubmitting || _graceActive) return;
    _violations++;
    _triggerShake();

    if (_violations > _maxViolations) {
      _violationTriggered = true;
      _disableSecurity();
      _triggerTermination();
      return;
    }

    // First violation → grace period
    _set(() {
      _graceActive = true;
      _graceCountdown = 10;
      _screenBlocked = true;
    });

    _graceTimer?.cancel();
    _graceTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _set(() => _graceCountdown--);
      if (_graceCountdown <= 0) {
        t.cancel();
        _set(() {
          _graceActive = false;
          _violationTriggered = true;
          _screenBlocked = false;
        });
        _disableSecurity();
        _triggerTermination();
      }
    });
  }

  void _cancelViolation() {
    _graceTimer?.cancel();
    _set(() {
      _graceActive = false;
      _screenBlocked = false;
    });
    _enterFullscreen();
  }

  void _triggerTermination() {
    _set(() {
      _securityDialog = true;
      _exitCountdown = 5;
    });
    _exitTimer?.cancel();
    _exitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _set(() => _exitCountdown--);
      if (_exitCountdown <= 0) {
        t.cancel();
        _autoSubmit();
        Timer(const Duration(milliseconds: 800), () {
          _set(() => _securityDialog = false);
          _closeQuiz();
        });
      }
    });
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => _buildOverlay(context);
}
