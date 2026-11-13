import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import 'mz_html_text.dart';
import 'mz_ui.dart';

/// Payload of the `submitted` event of `mathzoroquiz.vue`.
class QuizSubmission {
  const QuizSubmission({
    required this.answers,
    required this.answersPayload,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.scorePercent,
    required this.timeTakenSec,
    required this.onResult,
  });

  final Map<String, dynamic> answers;

  /// `[{ question_id, option_id }]` (both stringified).
  final List<Map<String, String>> answersPayload;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int scorePercent;
  final int timeTakenSec;

  /// Lets the caller push the server result (`{ percentage, tickets }`).
  final void Function(Map<String, dynamic> result) onResult;
}

/// Opens the full-screen quiz (`<QuizExam :visible="true">`). Completes when
/// the quiz is closed (`@close`).
Future<void> showMathZoroQuiz(
  BuildContext context, {
  required List<dynamic> questions,
  required String quizTitle,
  required void Function(QuizSubmission submission) onSubmitted,
  bool timerEnabled = false,
  int timeLimitSeconds = 600,
  bool showPalette = true,
  bool showReview = true,
  bool showTickets = true,
  int passMark = 60,
  bool securityEnabled = true,
  int ticketsPerCorrect = 1,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => MathZoroQuiz(
        questions: questions,
        quizTitle: quizTitle,
        onSubmitted: onSubmitted,
        timerEnabled: timerEnabled,
        timeLimitSeconds: timeLimitSeconds,
        showPalette: showPalette,
        showReview: showReview,
        showTickets: showTickets,
        passMark: passMark,
        securityEnabled: securityEnabled,
        ticketsPerCorrect: ticketsPerCorrect,
      ),
      transitionsBuilder: (_, anim, _, child) {
        final a = CurvedAnimation(parent: anim, curve: Curves.ease);
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(a), child: child),
        );
      },
    ),
  );
}

// ── palette (mathzoroquiz.vue <style>) ──────────────────────────────────────
const _bg = Color(0xFF0C0C0F);
const _card = Color(0xFF17171C);
const _fg = Color(0xFFF0EEE8);
const _lime = Color(0xFFE8FF47);
const _limeHover = Color(0xFFF2FF6E);
const _green = Color(0xFF22C55E);
const _greenText = Color(0xFF86EFAC);
const _green400 = Color(0xFF4ADE80);
const _red = Color(0xFFEF4444);
const _redText = Color(0xFFFCA5A5);
const _red400 = Color(0xFFF87171);
const _amber = Color(0xFFFBD24B);

Color _w(double a) => Colors.white.withValues(alpha: a);

TextStyle _serif(double size, Color color) =>
    GoogleFonts.instrumentSerif(fontSize: size, color: color, height: 1);

/// Port of `src/components/Mathzoro/mathzoroquiz.vue`.
class MathZoroQuiz extends StatefulWidget {
  const MathZoroQuiz({
    super.key,
    required this.questions,
    required this.quizTitle,
    required this.onSubmitted,
    this.timerEnabled = false,
    this.timeLimitSeconds = 600,
    this.showPalette = true,
    this.showReview = true,
    this.showTickets = true,
    this.passMark = 60,
    this.securityEnabled = true,
    this.ticketsPerCorrect = 1,
  });

  final List<dynamic> questions;
  final String quizTitle;
  final void Function(QuizSubmission submission) onSubmitted;
  final bool timerEnabled;
  final int timeLimitSeconds;
  final bool showPalette;
  final bool showReview;
  final bool showTickets;
  final int passMark;
  final bool securityEnabled;
  final int ticketsPerCorrect;

  @override
  State<MathZoroQuiz> createState() => _MathZoroQuizState();
}

class _MathZoroQuizState extends State<MathZoroQuiz> with SingleTickerProviderStateMixin {
  static const _maxViolations = 1;

  String _phase = 'quiz';
  int _currentStep = 1;
  Map<String, dynamic> _answers = {};
  bool _confirmOpen = false;
  bool _isSubmitting = false;

  bool _toastVisible = false;
  Timer? _toastTimer;
  int _toastSeq = 0;

  late int _timeLeft = widget.timeLimitSeconds;
  int _timeTakenSec = 0;
  Timer? _timerHandle;
  DateTime? _startTime;

  Map<String, dynamic>? _serverResult;
  String _reviewFilter = 'all';

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
  bool _closed = false;
  AppLifecycleListener? _lifecycle;
  DateTime _ignoreLifecycleUntil = DateTime.fromMillisecondsSinceEpoch(0);
  final Set<int> _touches = {};

  final _scroll = ScrollController();
  final _focus = FocusNode(debugLabel: 'mathzoro-quiz');
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  List<Map<String, dynamic>> get _questions =>
      widget.questions.map(asMap).whereType<Map<String, dynamic>>().toList();

  @override
  void initState() {
    super.initState();
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

  // ── computed ─────────────────────────────────────────────────────────────

  static String _key(dynamic id) => jsStr(id) ?? 'undefined';

  static List<Map<String, dynamic>> _options(Map<String, dynamic>? q) =>
      asList(q?['options']).map(asMap).whereType<Map<String, dynamic>>().toList();

  Map<String, dynamic>? get _currentQuestion {
    final qs = _questions;
    final i = _currentStep - 1;
    return i >= 0 && i < qs.length ? qs[i] : null;
  }

  bool _isAnswered(Map<String, dynamic>? q) => jsTruthy(_answers[_key(q?['id'])]);

  int get _answeredCount => _questions.where(_isAnswered).length;

  double get _progressFraction =>
      _questions.isEmpty ? 0 : _answeredCount / _questions.length;

  String get _formattedTime {
    final m = _timeLeft ~/ 60;
    final s = _timeLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _timeTakenFormatted {
    final m = _timeTakenSec ~/ 60;
    final s = _timeTakenSec % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  bool _isQuestionAnswerCorrect(Map<String, dynamic>? q) {
    final picked = _answers[_key(q?['id'])];
    return jsTruthy(picked) &&
        _options(q).any((o) => o['id'] == picked && jsTruthy(o['is_correct']));
  }

  int get _correctCount => _questions.where(_isQuestionAnswerCorrect).length;

  int get _wrongCount => _questions.where((q) {
        final picked = _answers[_key(q['id'])];
        if (!jsTruthy(picked)) return false;
        final o = _options(q).where((o) => o['id'] == picked).firstOrNull;
        return !jsTruthy(o?['is_correct']);
      }).length;

  int get _skippedCount => _questions.where((q) => !jsTruthy(_answers[_key(q['id'])])).length;

  int get _scorePercent {
    if (_questions.isEmpty) return 0;
    final p = _serverResult?['percentage'];
    if (p != null) return (asDouble(p) ?? 0).round();
    return (_correctCount / _questions.length * 100).round();
  }

  num get _earnedTickets {
    final t = _serverResult?['tickets'];
    if (t != null) return asDouble(t) ?? 0;
    return _correctCount * widget.ticketsPerCorrect;
  }

  String get _resultStatus {
    if (widget.passMark == 0) return 'neutral';
    return _scorePercent >= widget.passMark ? 'pass' : 'fail';
  }

  String get _resultSummaryText {
    final pct = _scorePercent;
    final n = _questions.length;
    if (widget.passMark == 0) return '$_correctCount of $n correct ($pct%)';
    if (pct >= widget.passMark) return 'You passed! $_correctCount of $n correct — $pct%';
    return '$_correctCount of $n correct — $pct%. Pass mark is ${widget.passMark}%.';
  }

  String _getQuestionResult(Map<String, dynamic> q) {
    final picked = _answers[_key(q['id'])];
    if (!jsTruthy(picked)) return 'skipped';
    final o = _options(q).where((o) => o['id'] == picked).firstOrNull;
    return jsTruthy(o?['is_correct']) ? 'correct' : 'wrong';
  }

  List<Map<String, dynamic>> get _filteredReviewQuestions => _reviewFilter == 'all'
      ? _questions
      : _questions.where((q) => _getQuestionResult(q) == _reviewFilter).toList();

  /// '' | 'opt-correct' | 'opt-wrong-pick' | 'opt-dim'
  String _getOptionState(Map<String, dynamic> q, Map<String, dynamic> option) {
    final picked = _answers[_key(q['id'])];
    if (!jsTruthy(picked)) return '';
    final correct = jsTruthy(option['is_correct']);
    if (correct) return 'opt-correct';
    if (picked == option['id']) return 'opt-wrong-pick';
    return 'opt-dim';
  }

  String _getCorrectRemark(Map<String, dynamic>? q) {
    final o = _options(q).where((o) => jsTruthy(o['is_correct'])).firstOrNull;
    return jsTruthy(o?['remarks']) ? jsDisplay(o!['remarks']) : '';
  }

  String _getCorrectOptionLabel(Map<String, dynamic>? q) {
    final opts = _options(q);
    final idx = opts.indexWhere((o) => jsTruthy(o['is_correct']));
    if (idx == -1) return '';
    final letter = String.fromCharCode(65 + idx);
    return '$letter. ${_optionText(opts[idx])}';
  }

  static String _optionText(Map<String, dynamic> o) =>
      jsTruthy(o['text']) ? jsDisplay(o['text']) : jsDisplay(o['option_text']);

  static String _questionHtml(Map<String, dynamic> q) =>
      jsTruthy(q['text']) ? jsDisplay(q['text']) : jsDisplay(q['stem']);

  static int _ticketsToStars(num tickets) {
    if (tickets <= 0) return 0;
    return math.min(5, tickets.floor());
  }

  List<Map<String, String>> _buildAnswersPayload() => [
        for (final e in _answers.entries)
          {'question_id': e.key, 'option_id': jsStr(e.value) ?? ''},
      ];

  // ── lifecycle ────────────────────────────────────────────────────────────

  void _initQuiz() {
    _phase = 'quiz';
    _currentStep = 1;
    _answers = {};
    _isSubmitting = false;
    _violations = 0;
    _violationTriggered = false;
    _screenBlocked = false;
    _graceActive = false;
    _securityDialog = false;
    _confirmOpen = false;
    _serverResult = null;
    _reviewFilter = 'all';
    _timeLeft = widget.timeLimitSeconds;
    _timeTakenSec = 0;
    _startTime = DateTime.now();
    _toastVisible = false;
    _toastTimer?.cancel();

    if (widget.timerEnabled) _startTimer();
    if (widget.securityEnabled) _enableSecurity();
  }

  void _teardown() {
    if (widget.securityEnabled) _disableSecurity();
    _graceTimer?.cancel();
    _exitTimer?.cancel();
    _timerHandle?.cancel();
    _toastTimer?.cancel();
  }

  void _showTokenToast() {
    _toastTimer?.cancel();
    // A fresh <Transition> enter (re-runs the icon spin / badge pop).
    if (!_toastVisible) _toastSeq++;
    setState(() => _toastVisible = true);
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _toastVisible = false);
    });
  }

  void _selectAnswer(Map<String, dynamic> question, Map<String, dynamic> option) {
    if (_isAnswered(question)) return;
    setState(() => _answers = {..._answers, _key(question['id']): option['id']});
    if (jsTruthy(option['is_correct'])) _showTokenToast();
  }

  void _goTo(int step) {
    setState(() => _currentStep = step);
    // Scroll the main scrollable area to top when changing questions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _startTimer() {
    _timerHandle?.cancel();
    _timerHandle = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _autoSubmit();
      }
    });
  }

  void _recordTimeTaken() {
    final start = _startTime ?? DateTime.now();
    _timeTakenSec = (DateTime.now().difference(start).inMilliseconds / 1000).round();
    _timerHandle?.cancel();
  }

  void _submitQuiz() {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _confirmOpen = false;
    });
    _recordTimeTaken();
    if (widget.securityEnabled) _disableSecurity();

    widget.onSubmitted(QuizSubmission(
      answers: Map.unmodifiable(_answers),
      answersPayload: _buildAnswersPayload(),
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      skippedCount: _skippedCount,
      scorePercent: _scorePercent,
      timeTakenSec: _timeTakenSec,
      onResult: (result) {
        if (mounted) setState(() => _serverResult = result);
      },
    ));

    setState(() {
      _phase = 'results';
      _isSubmitting = false;
    });
  }

  void _autoSubmit() {
    if (!_isSubmitting) _submitQuiz();
  }

  void _closeQuiz() {
    if (_closed || !mounted) return;
    _closed = true;
    _teardown();
    // pop() (not maybePop) so the PopScope used while secured never blocks it.
    Navigator.of(context).pop();
  }

  // ── security (fullscreen / focus loss / key blocking) ───────────────────

  static bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  Future<void> _enterFullscreen() async {
    _ignoreLifecycleUntil = DateTime.now().add(const Duration(milliseconds: 1500));
    try {
      if (_isDesktop) {
        await windowManager.setFullScreen(true);
      } else if (!kIsWeb) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    } catch (_) {}
  }

  Future<void> _exitFullscreen() async {
    try {
      if (_isDesktop) {
        if (await windowManager.isFullScreen()) await windowManager.setFullScreen(false);
      } else if (!kIsWeb) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    } catch (_) {}
  }

  void _enableSecurity() {
    if (_securityOn) return;
    _securityOn = true;
    _enterFullscreen();
    // visibilitychange / blur / pagehide → app focus & lifecycle changes.
    _lifecycle = AppLifecycleListener(
      onInactive: _onFocusLost,
      onHide: _onFocusLost,
      onPause: _onFocusLost,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _disableSecurity() {
    if (!_securityOn) return;
    _securityOn = false;
    _lifecycle?.dispose();
    _lifecycle = null;
    _exitFullscreen();
  }

  void _onFocusLost() {
    if (!_securityOn || DateTime.now().isBefore(_ignoreLifecycleUntil)) return;
    _flagViolation();
  }

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
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        RegExp(r'^F\d{1,2}$').hasMatch(key.keyLabel) ||
        kb.isControlPressed ||
        kb.isMetaPressed ||
        kb.isAltPressed) {
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onPointerDown(PointerDownEvent e) {
    if (e.kind != ui.PointerDeviceKind.touch) return;
    _touches.add(e.pointer);
    if (_securityOn && _touches.length > 1) _flagViolation();
  }

  void _onPointerUp(PointerEvent e) => _touches.remove(e.pointer);

  void _flagViolation() {
    if (_violationTriggered || _isSubmitting || _graceActive) return;
    _violations++;
    _shake.forward(from: 0);

    if (_violations > _maxViolations) {
      _violationTriggered = true;
      _disableSecurity();
      _triggerTermination();
      return;
    }

    setState(() {
      _graceActive = true;
      _graceCountdown = 10;
      _screenBlocked = true;
    });

    _graceTimer?.cancel();
    _graceTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _graceCountdown--);
      if (_graceCountdown <= 0) {
        t.cancel();
        setState(() {
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
    setState(() {
      _graceActive = false;
      _screenBlocked = false;
    });
    _enterFullscreen();
  }

  void _triggerTermination() {
    setState(() {
      _securityDialog = true;
      _exitCountdown = 5;
    });
    _exitTimer?.cancel();
    _exitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _exitCountdown--);
      if (_exitCountdown <= 0) {
        t.cancel();
        _autoSubmit();
        Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() => _securityDialog = false);
          _closeQuiz();
        });
      }
    });
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width <= 480;
    final base = GoogleFonts.dmSans(color: _fg, fontSize: 14);

    return PopScope(
      canPop: !_securityOn,
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _blockKeys,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: Material(
            color: _bg,
            child: DefaultTextStyle(
              style: base,
              child: AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  const xs = [0.0, -7.0, 7.0, -5.0, 5.0, 0.0];
                  final t = _shake.value * 5;
                  final i = t.floor().clamp(0, 4);
                  final dx = _shake.isAnimating
                      ? ui.lerpDouble(xs[i], xs[i + 1], Curves.ease.transform(t - i))!
                      : 0.0;
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _topBar(mobile),
                          _progressTrack(),
                          Expanded(
                            child: _phase == 'quiz' ? _quizMain(mobile) : _resultsMain(mobile),
                          ),
                          if (_phase == 'quiz') _footer(mobile),
                        ],
                      ),
                      _tokenToast(),
                      _modalLayer(_confirmOpen, _confirmDialog(), barrier: 0.7, blur: 8),
                      _modalLayer(_screenBlocked, _graceOverlay(),
                          barrier: 0.92, blur: 20, color: Colors.black),
                      _modalLayer(_securityDialog, _terminatedOverlay(),
                          barrier: 0.97, blur: 20, color: const Color(0xFF140000)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── top bar / progress ──

  Widget _topBar(bool mobile) {
    final n = _questions.length;
    return Container(
      padding: mobile
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _w(0.07))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _lime, borderRadius: BorderRadius.circular(4)),
            child: const Text('QUIZ',
                style: TextStyle(
                    color: _bg, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.35)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.quizTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: mobile ? 13 : 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 1),
                Text('$n questions', style: TextStyle(fontSize: 11, color: _w(0.35))),
              ],
            ),
          ),
          SizedBox(width: mobile ? 10 : 16),
          if (widget.timerEnabled && _phase == 'quiz') ...[
            // `.qe-timer.danger` pulses (timer-pulse 1s infinite).
            _OpacityPulse(enabled: _timeLeft <= 30, min: 0.5, child: _timerChip()),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: _progressFraction),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease,
                  builder: (_, v, _) => CustomPaint(size: const Size(44, 44), painter: _RingPainter(v)),
                ),
                Text('$_currentStep/$n',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _w(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerChip() {
    final danger = _timeLeft <= 30;
    final warning = _timeLeft <= 60 && _timeLeft > 30;
    final bg = danger
        ? const Color.fromRGBO(239, 68, 68, 0.15)
        : warning
            ? const Color.fromRGBO(251, 191, 36, 0.12)
            : _w(0.06);
    final fg = danger ? _red400 : (warning ? _amber : _w(0.6));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // transition: all .3s
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(BootstrapIcons.clock, size: 14, color: fg),
        const SizedBox(width: 6),
        Text(_formattedTime,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
                fontFeatures: const [ui.FontFeature.tabularFigures()])),
      ]),
    );
  }

  Widget _progressTrack() => SizedBox(
        height: 2,
        child: LayoutBuilder(
          builder: (context, c) => Stack(children: [
            Positioned.fill(child: ColoredBox(color: _w(0.08))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              width: c.maxWidth * _progressFraction,
              color: _lime,
            ),
          ]),
        ),
      );

  // ── quiz phase ──

  Widget _quizMain(bool mobile) {
    final q = _currentQuestion;
    final n = _questions.length;
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        children: [
          if (q != null)
            _constrained(
              640,
              Container(
                padding: mobile
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 18)
                    : const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _w(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _questionHeader(q, mobile),
                    const SizedBox(height: 20),
                    Container(height: 1, color: _w(0.07)),
                    const SizedBox(height: 20),
                    MzHtmlText(_questionHtml(q),
                        style: TextStyle(
                            fontSize: mobile ? 15 : 16,
                            height: 1.65,
                            color: const Color(0xFFE8E6DF))),
                    const SizedBox(height: 20),
                    for (final (oi, o) in _options(q).indexed) ...[
                      if (oi > 0) const SizedBox(height: 8),
                      _optionTile(q, o, oi, mobile),
                    ],
                    // `<Transition name="remark-fade">` has only enter classes:
                    // it fades in (opacity + translateY(-6px), .25s) when the
                    // remark appears and is removed at once; moving between
                    // two answered questions reuses the element (no animation).
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      reverseDuration: Duration.zero,
                      switchInCurve: Curves.ease,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: AnimatedBuilder(
                          animation: a,
                          builder: (_, c) =>
                              Transform.translate(offset: Offset(0, -6 * (1 - a.value)), child: c),
                          child: child,
                        ),
                      ),
                      child: _isAnswered(q)
                          ? Padding(
                              key: const ValueKey('remark'),
                              padding: const EdgeInsets.only(top: 20),
                              child: _instantRemark(q),
                            )
                          : const SizedBox.shrink(key: ValueKey('no-remark')),
                    ),
                    const SizedBox(height: 20),
                    _nav(n, mobile),
                  ],
                ),
              ),
            ),
          if (widget.showPalette) ...[
            const SizedBox(height: 20),
            _constrained(640, _palette()),
          ],
        ],
      ),
    );
  }

  static Widget _constrained(double max, Widget child) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: max),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );

  Widget _questionHeader(Map<String, dynamic> q, bool mobile) {
    final answered = _isAnswered(q);
    final correct = _isQuestionAnswerCorrect(q);
    final (pillText, pillBg, pillFg) = !answered
        ? ('◯ Pending', const Color.fromRGBO(251, 191, 36, 0.1), _amber)
        : correct
            ? ('✓ Correct', const Color.fromRGBO(34, 197, 94, 0.14), _greenText)
            : ('✗ Wrong', const Color.fromRGBO(239, 68, 68, 0.14), _redText);
    return Row(
      children: [
        // `.qe-q-number { align-items: baseline }`
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('QUESTION',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: _w(0.3))),
            const SizedBox(width: 8),
            Text(_currentStep.toString().padLeft(2, '0'), style: _serif(mobile ? 28 : 36, _fg)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(100)),
          child: Text(pillText,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pillFg)),
        ),
      ],
    );
  }

  Widget _optionTile(Map<String, dynamic> q, Map<String, dynamic> o, int oi, bool mobile) {
    final st = _getOptionState(q, o);
    final clickable = !_isAnswered(q);
    return HoverBuilder(
      onTap: clickable ? () => _selectAnswer(q, o) : null,
      cursor: clickable
          ? SystemMouseCursors.click
          : (st == 'opt-dim' ? SystemMouseCursors.forbidden : MouseCursor.defer),
      builder: (context, hover) {
        Color border = _w(0.08);
        Color bg = _w(0.02);
        List<BoxShadow>? shadow;
        if (st == 'opt-correct') {
          border = _green;
          bg = const Color.fromRGBO(34, 197, 94, 0.1);
          shadow = const [BoxShadow(color: Color.fromRGBO(34, 197, 94, 0.25), spreadRadius: 1)];
        } else if (st == 'opt-wrong-pick') {
          border = _red;
          bg = const Color.fromRGBO(239, 68, 68, 0.1);
          shadow = const [BoxShadow(color: Color.fromRGBO(239, 68, 68, 0.25), spreadRadius: 1)];
        } else if (clickable && hover) {
          border = const Color.fromRGBO(232, 255, 71, 0.3);
          bg = const Color.fromRGBO(232, 255, 71, 0.04);
        }

        Color letterBg = _w(0.04);
        Color letterBorder = _w(0.15);
        Color letterFg = _w(0.5);
        if (st == 'opt-correct') {
          letterBg = letterBorder = _green;
          letterFg = Colors.white;
        } else if (st == 'opt-wrong-pick') {
          letterBg = letterBorder = _red;
          letterFg = Colors.white;
        }

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: st == 'opt-dim' ? 0.38 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.5),
              boxShadow: shadow,
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: st == 'opt-dim' ? 0.5 : 1,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: letterBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: letterBorder, width: 1.5),
                    ),
                    child: Text(String.fromCharCode(65 + oi),
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: letterFg)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_optionText(o),
                      style: TextStyle(
                          fontSize: mobile ? 13 : 14,
                          height: 1.5,
                          color: const Color(0xFFD8D6CF))),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: st == 'opt-correct'
                        ? const Text('✓',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700, color: _green400))
                        : st == 'opt-wrong-pick'
                            ? const Text('✗',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: _red400))
                            : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _instantRemark(Map<String, dynamic> q) {
    final correct = _isQuestionAnswerCorrect(q);
    final remark = _getCorrectRemark(q);
    final fg = correct ? _greenText : _redText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: correct
            ? const Color.fromRGBO(34, 197, 94, 0.08)
            : const Color.fromRGBO(239, 68, 68, 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1.5,
          color: correct
              ? const Color.fromRGBO(34, 197, 94, 0.3)
              : const Color.fromRGBO(239, 68, 68, 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              correct ? BootstrapIcons.check_circle_fill : BootstrapIcons.x_circle_fill,
              size: 18,
              color: correct ? _green : _red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(correct ? 'Correct!' : 'Wrong answer!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
                if (!correct) ...[
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(children: [
                      const TextSpan(text: 'Correct answer: '),
                      TextSpan(
                        text: _getCorrectOptionLabel(q),
                        style: const TextStyle(color: _fg, fontWeight: FontWeight.w600),
                      ),
                    ]),
                    style: TextStyle(fontSize: 13, color: _w(0.55)),
                  ),
                ],
                if (remark.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(remark, style: TextStyle(fontSize: 13, height: 1.5, color: _w(0.45))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(int n, bool mobile) {
    final qs = _questions;
    return Row(
      children: [
        _NavBtn(
          label: '← Prev',
          mobile: mobile,
          onTap: _currentStep == 1 ? null : () => _goTo(_currentStep - 1),
        ),
        const Spacer(),
        Wrap(
          spacing: 5,
          children: [
            for (var i = 1; i <= math.min(n, 9); i++)
              Builder(builder: (_) {
                final q = qs[i - 1];
                final active = _currentStep == i;
                Color c = _w(0.15);
                if (active) {
                  c = _lime;
                } else if (jsTruthy(_answers[_key(q['id'])])) {
                  c = _isQuestionAnswerCorrect(q)
                      ? const Color.fromRGBO(34, 197, 94, 0.6)
                      : const Color.fromRGBO(239, 68, 68, 0.6);
                }
                return AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: active ? 1.3 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                );
              }),
          ],
        ),
        const Spacer(),
        if (_currentStep < n)
          _NavBtn(
            label: 'Next →',
            mobile: mobile,
            kind: _NavKind.primary,
            onTap: () => _goTo(_currentStep + 1),
          )
        else
          _NavBtn(
            label: 'Submit →',
            mobile: mobile,
            kind: _NavKind.success,
            onTap: () => setState(() => _confirmOpen = true),
          ),
      ],
    );
  }

  Widget _palette() {
    final qs = _questions;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _w(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUESTIONS',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: _w(0.3))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (qi, q) in qs.indexed)
                HoverBuilder(
                  onTap: () => _goTo(qi + 1),
                  builder: (context, hover) {
                    final active = _currentStep == qi + 1;
                    final done = jsTruthy(_answers[_key(q['id'])]) && !active;
                    final ok = done && _isQuestionAnswerCorrect(q);
                    Color bg = _w(0.04), border = _w(0.1), fg = _w(0.5);
                    if (hover) {
                      border = const Color.fromRGBO(232, 255, 71, 0.4);
                      fg = _lime;
                    }
                    if (active) {
                      bg = border = _lime;
                      fg = _bg;
                    } else if (done && ok) {
                      bg = const Color.fromRGBO(34, 197, 94, 0.12);
                      border = const Color.fromRGBO(34, 197, 94, 0.5);
                      fg = _greenText;
                    } else if (done) {
                      bg = const Color.fromRGBO(239, 68, 68, 0.12);
                      border = const Color.fromRGBO(239, 68, 68, 0.5);
                      fg = _redText;
                    }
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Text('${qi + 1}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footer(bool mobile) {
    final n = _questions.length;
    final answered = _answeredCount;
    final count = Text.rich(
      TextSpan(children: [
        TextSpan(
            text: '$answered',
            style: const TextStyle(color: _fg, fontWeight: FontWeight.w700)),
        const TextSpan(text: ' of '),
        TextSpan(text: '$n', style: const TextStyle(color: _fg, fontWeight: FontWeight.w700)),
        const TextSpan(text: ' answered'),
        if (answered > 0) ...[
          TextSpan(
            style: const TextStyle(fontSize: 12),
            children: [
              const TextSpan(text: ' · '),
              TextSpan(
                  text: '$_correctCount correct',
                  style: const TextStyle(color: _greenText, fontWeight: FontWeight.w600)),
              if (_wrongCount > 0) ...[
                const TextSpan(text: ' · '),
                TextSpan(
                    text: '$_wrongCount wrong',
                    style: const TextStyle(color: _redText, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ],
      ]),
      style: TextStyle(fontSize: mobile ? 12 : 13, color: _w(0.4)),
    );
    final submit = _PillButton(
      label: 'Submit Quiz',
      lift: true, // .qe-submit-btn:hover translateY(-1px)
      onTap: () => setState(() => _confirmOpen = true),
    );
    return Container(
      padding: mobile
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _w(0.07))),
      ),
      child: mobile
          ? Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [count, submit],
            )
          : Row(children: [Expanded(child: count), submit]),
    );
  }

  // ── results phase ──

  Widget _resultsMain(bool mobile) {
    final status = _resultStatus;
    final ringColor = switch (status) {
      'pass' => _green,
      'fail' => _red,
      _ => _lime,
    };
    final numColor = switch (status) {
      'pass' => _greenText,
      'fail' => _redText,
      _ => _lime,
    };
    final title = status == 'pass'
        ? '🎉 Well Done!'
        : status == 'fail'
            ? '📚 Keep Practicing'
            : '✅ Completed';
    final tickets = _earnedTickets;
    final stars = _ticketsToStars(tickets);
    final ringSize = mobile ? 80.0 : 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        children: [
          _constrained(
            720,
            Container(
              padding: mobile
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
                  : const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _w(0.08)),
              ),
              child: LayoutBuilder(builder: (context, c) {
                final gap = mobile ? 18.0 : 28.0;
                // `.qe-result-info { flex: 1; min-width: 200px }` inside a wrapping row
                final sideBySide = c.maxWidth - ringSize - gap >= 200;
                final ring = AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: ringSize,
                    height: ringSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: 4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$_scorePercent%', style: _serif(mobile ? 22 : 28, numColor)),
                        const SizedBox(height: 2),
                        Text('SCORE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: _w(0.3))),
                      ],
                    ),
                  );
                final info = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _serif(mobile ? 20 : 26, _fg).copyWith(height: 1.2)),
                        const SizedBox(height: 12),
                        Text(_resultSummaryText,
                            style: TextStyle(fontSize: 13, height: 1.6, color: _w(0.45))),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _statChip(BootstrapIcons.check_circle_fill, '$_correctCount', 'Correct',
                                const Color.fromRGBO(34, 197, 94, 0.08),
                                const Color.fromRGBO(34, 197, 94, 0.2), _greenText),
                            _statChip(BootstrapIcons.x_circle_fill, '$_wrongCount', 'Wrong',
                                const Color.fromRGBO(239, 68, 68, 0.08),
                                const Color.fromRGBO(239, 68, 68, 0.2), _redText),
                            _statChip(BootstrapIcons.dash_circle_fill, '$_skippedCount', 'Skipped',
                                _w(0.04), _w(0.1), _w(0.45)),
                            if (widget.timerEnabled)
                              _statChip(BootstrapIcons.clock_fill, _timeTakenFormatted, 'Time Taken',
                                  const Color.fromRGBO(232, 255, 71, 0.06),
                                  const Color.fromRGBO(232, 255, 71, 0.15), _lime),
                          ],
                        ),
                        if (widget.showTickets) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(251, 191, 36, 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color.fromRGBO(251, 191, 36, 0.2)),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(BootstrapIcons.ticket_perforated_fill,
                                    size: 15, color: _amber),
                                Text(jsDisplay(tickets),
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.w700, color: _amber)),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text('tickets earned',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: _amber.withValues(alpha: 0.65))),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var s = 1; s <= 5; s++)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 3),
                                        child: Icon(
                                          s <= stars
                                              ? BootstrapIcons.star_fill
                                              : BootstrapIcons.star,
                                          size: 15,
                                          color: s <= stars ? _amber : _w(0.2),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                if (sideBySide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ring, SizedBox(width: gap), Expanded(child: info)],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ring, SizedBox(height: gap), info],
                );
              }),
            ),
          ),
          if (widget.showReview) ...[
            const SizedBox(height: 20),
            _constrained(720, _review(mobile)),
          ],
          const SizedBox(height: 20),
          _constrained(
            720,
            Align(
              alignment: Alignment.centerRight,
              child: _CloseAction(onTap: _closeQuiz),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color bg, Color border, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: fg.withValues(alpha: fg.a * 0.7))),
      ]),
    );
  }

  Widget _review(bool mobile) {
    const filters = [
      ('all', 'All'),
      ('correct', 'Correct'),
      ('wrong', 'Wrong'),
      ('skipped', 'Skipped'),
    ];
    final list = _filteredReviewQuestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            const Text('Answer Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _fg)),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (val, label) in filters)
                  HoverBuilder(
                    onTap: () => setState(() => _reviewFilter = val),
                    builder: (context, hover) {
                      final active = _reviewFilter == val;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? const Color.fromRGBO(232, 255, 71, 0.12) : _w(0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1.5,
                            color: active ? _lime : (hover ? _w(0.2) : _w(0.1)),
                          ),
                        ),
                        child: Text(label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: active ? _lime : (hover ? Colors.white : _w(0.45)))),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final (qi, q) in list.indexed) ...[
          if (qi > 0) const SizedBox(height: 12),
          _reviewCard(qi, q, mobile),
        ],
      ],
    );
  }

  Widget _reviewCard(int qi, Map<String, dynamic> q, bool mobile) {
    final result = _getQuestionResult(q);
    final (accent, badgeBg, badgeFg, badgeIcon, badgeText) = switch (result) {
      'correct' => (
          _green,
          const Color.fromRGBO(34, 197, 94, 0.12),
          _greenText,
          BootstrapIcons.check_circle_fill,
          'Correct'
        ),
      'wrong' => (
          _red,
          const Color.fromRGBO(239, 68, 68, 0.12),
          _redText,
          BootstrapIcons.x_circle_fill,
          'Wrong'
        ),
      _ => (_w(0.15), _w(0.06), _w(0.4), BootstrapIcons.dash_circle_fill, 'Skipped'),
    };
    final picked = _answers[_key(q['id'])];
    final remark = _getCorrectRemark(q);

    return AccentBorderBox(
      radius: 18,
      borderColor: _w(0.08),
      borderWidth: 1.5,
      leftColor: accent,
      leftWidth: 3,
      color: _card,
      // AccentBorderBox already insets by the borders (3 px left, 1.5 px
      // elsewhere); this is the card's padding (20 18 / mobile 16 12).
      child: Padding(
        padding: mobile
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Q${qi + 1}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: _w(0.3))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration:
                      BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(100)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(badgeIcon, size: 12, color: badgeFg),
                    const SizedBox(width: 5),
                    Text(badgeText,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: badgeFg)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 14),
            MzHtmlText(_questionHtml(q),
                style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFFE8E6DF))),
            const SizedBox(height: 14),
            for (final (oi, opt) in _options(q).indexed) ...[
              if (oi > 0) const SizedBox(height: 8),
              _reviewOption(oi, opt, picked),
            ],
            if (remark.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 255, 71, 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromRGBO(232, 255, 71, 0.12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(BootstrapIcons.lightbulb_fill, size: 13, color: _lime),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(remark,
                          style: const TextStyle(
                              fontSize: 13,
                              height: 1.55,
                              color: Color.fromRGBO(232, 255, 71, 0.8))),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _reviewOption(int oi, Map<String, dynamic> opt, dynamic picked) {
    final isCorrect = jsTruthy(opt['is_correct']);
    final isPick = jsTruthy(picked) && picked == opt['id'];
    final wrongPick = isPick && !isCorrect;
    final correctPick = isPick && isCorrect;

    Color border = _w(0.06), bg = _w(0.02);
    List<BoxShadow>? shadow;
    Color lBg = _w(0.05), lBorder = _w(0.12), lFg = _w(0.4);
    if (isCorrect) {
      border = const Color.fromRGBO(34, 197, 94, 0.35);
      bg = const Color.fromRGBO(34, 197, 94, 0.07);
      lBg = const Color.fromRGBO(34, 197, 94, 0.2);
      lBorder = _green;
      lFg = _greenText;
    }
    if (wrongPick) {
      border = const Color.fromRGBO(239, 68, 68, 0.4);
      bg = const Color.fromRGBO(239, 68, 68, 0.08);
      lBg = const Color.fromRGBO(239, 68, 68, 0.2);
      lBorder = _red;
      lFg = _redText;
    }
    if (correctPick) {
      border = _green;
      bg = const Color.fromRGBO(34, 197, 94, 0.12);
      shadow = const [BoxShadow(color: Color.fromRGBO(34, 197, 94, 0.2), spreadRadius: 1)];
      lBg = lBorder = _green;
      lFg = Colors.white;
    }

    Widget tag(IconData icon, String text, Color tbg, Color tfg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: tbg, borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 11, color: tfg),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tfg)),
          ]),
        );

    final tags = <Widget>[
      if (isCorrect)
        tag(BootstrapIcons.check2, 'Correct answer', const Color.fromRGBO(34, 197, 94, 0.15),
            _greenText),
      if (wrongPick)
        tag(BootstrapIcons.x, 'Your answer', const Color.fromRGBO(239, 68, 68, 0.15), _redText),
      if (correctPick)
        tag(BootstrapIcons.check2, 'Your answer ✓', const Color.fromRGBO(34, 197, 94, 0.2),
            _green400),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: lBg,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: lBorder, width: 1.5),
                ),
                child: Text(String.fromCharCode(65 + oi),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: lFg)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_optionText(opt),
                    style: const TextStyle(
                        fontSize: 13, height: 1.55, color: Color(0xFFD8D6CF))),
              ),
            ],
          ),
          // `.qe-review-opt-tags` (width 100%, margin-top 2) is always
          // rendered, so it always wraps onto its own flex line (+10 gap).
          const SizedBox(height: 12),
          if (tags.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: tags),
        ],
      ),
    );
  }

  // ── overlays ──

  Widget _modalLayer(bool visible, Widget box,
      {required double barrier, required double blur, Color color = Colors.black}) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: visible ? 1 : 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: visible ? 1 : 0.94,
            child: visible
                ? ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: ColoredBox(
                        color: color.withValues(alpha: barrier),
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: box,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _dialogBox({required double maxWidth, required EdgeInsets padding, required double radius,
      required List<Widget> children}) {
    final confirm = maxWidth == 380;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: _w(confirm ? 0.1 : 0.08)),
          boxShadow: confirm
              // .qe-modal-box
              ? const [BoxShadow(color: Color(0x99000000), blurRadius: 80, offset: Offset(0, 32))]
              // .qe-sec-box
              : const [BoxShadow(color: Color(0xB3000000), blurRadius: 100, offset: Offset(0, 40))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _confirmDialog() {
    final n = _questions.length;
    final answered = _answeredCount;
    return _dialogBox(
      maxWidth: 380,
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      children: [
        const Text('⚠', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 12),
        Text('Submit Quiz?', style: _serif(24, _fg)),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: "You've answered "),
            TextSpan(text: '$answered', style: const TextStyle(color: _fg, fontWeight: FontWeight.w700)),
            const TextSpan(text: ' of '),
            TextSpan(text: '$n', style: const TextStyle(color: _fg, fontWeight: FontWeight.w700)),
            const TextSpan(text: ' questions.'),
          ]),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: _w(0.5)),
        ),
        const SizedBox(height: 6),
        if (answered < n)
          Text('${n - answered} question(s) still unanswered.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _amber))
        else
          const Text('All questions answered ✓',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _greenText)),
        if (answered > 0) ...[
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: '$_correctCount correct',
                  style: const TextStyle(color: _greenText, fontWeight: FontWeight.w600)),
              const TextSpan(text: ' · '),
              TextSpan(
                  text: '$_wrongCount wrong',
                  style: const TextStyle(color: _redText, fontWeight: FontWeight.w600)),
            ]),
            style: TextStyle(fontSize: 13, color: _w(0.5)),
          ),
        ],
        // Collapsed margins: max(4, 6) above the note.
        const SizedBox(height: 6),
        Text('This action cannot be undone.', style: TextStyle(fontSize: 11, color: _w(0.2))),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _OutlineAction(label: 'Go Back', onTap: () => setState(() => _confirmOpen = false)),
            _PillButton(
              label: _isSubmitting ? 'Submitting…' : 'Submit Now',
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              onTap: _isSubmitting ? null : _submitQuiz,
            ),
          ],
        ),
      ],
    );
  }

  Widget _graceOverlay() => _dialogBox(
        maxWidth: 360,
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          Text('Tab Switch Detected!', textAlign: TextAlign.center, style: _serif(22, _fg)),
          const SizedBox(height: 10),
          Text.rich(
            const TextSpan(children: [
              TextSpan(text: 'You left the quiz window.\nReturn now or the quiz will be '),
              TextSpan(
                  text: 'auto-submitted.',
                  style: TextStyle(color: _amber, fontWeight: FontWeight.w700)),
            ]),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.7, color: _w(0.45)),
          ),
          const SizedBox(height: 16),
          _Countdown(value: _graceCountdown, color: _amber),
          const SizedBox(height: 8),
          Text('Auto-submitting in ${_graceCountdown}s…',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _amber)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _PillButton(
              label: "I'm Back — Resume Quiz",
              padding: const EdgeInsets.all(13),
              fontSize: 14,
              radius: 12,
              onTap: _cancelViolation,
            ),
          ),
          const SizedBox(height: 12),
          Text('This is your only warning. Next violation = instant submission.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: _w(0.2))),
        ],
      );

  Widget _terminatedOverlay() => _dialogBox(
        maxWidth: 360,
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        children: [
          const Text('🚫', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          Text('Quiz Terminated', textAlign: TextAlign.center, style: _serif(22, _redText)),
          const SizedBox(height: 10),
          Text(
            'Multiple security violations detected.\nYour attempt has been automatically submitted.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.7, color: _w(0.45)),
          ),
          const SizedBox(height: 16),
          _Countdown(value: _exitCountdown, color: _redText),
          const SizedBox(height: 8),
          Text('Closing in ${_exitCountdown}s…', style: TextStyle(fontSize: 11, color: _w(0.2))),
        ],
      );

  Widget _tokenToast() {
    return Positioned(
      top: 76,
      right: 20,
      child: IgnorePointer(
        // toast-slide: translateX(30px) scale(.92) + fade.
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _toastVisible ? 0 : 1),
          duration: const Duration(milliseconds: 300),
          curve: _toastVisible ? const Cubic(0.34, 1.56, 0.64, 1) : Curves.ease,
          builder: (_, v, child) => Transform.translate(
            offset: Offset(30 * v, 0),
            child: Transform.scale(scale: 1 - 0.08 * v, child: child),
          ),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: _toastVisible ? 250 : 300),
            curve: Curves.ease,
            opacity: _toastVisible ? 1 : 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 230),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2918),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _green, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color.fromRGBO(34, 197, 94, 0.2), spreadRadius: 1),
                  BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 16)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToastIconSpin(
                    key: ValueKey('spin-$_toastSeq'),
                    child: const Text('🪙', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Token Earned!',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: _green400)),
                      SizedBox(height: 2),
                      Text('+1 token for correct answer',
                          style: TextStyle(
                              fontSize: 12, color: Color.fromRGBO(74, 222, 128, 0.6))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // toast-pop 0.4s cubic-bezier(.34,1.56,.64,1)
                  TweenAnimationBuilder<double>(
                    key: ValueKey('pop-$_toastSeq'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 400),
                    curve: const Cubic(0.34, 1.56, 0.64, 1),
                    builder: (_, s, child) => Transform.scale(scale: s, child: child),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                      child: const Text('+1',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF052E16))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── small widgets ───────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction);
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 44;
    final c = Offset(size.width / 2, size.height / 2);
    final r = 18 * s;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * s
          ..color = _w(0.12));
    if (fraction <= 0) {
      // `stroke-dasharray: 0 113` + round caps → a dot at 12 o'clock.
      canvas.drawCircle(c - Offset(0, r), 1.5 * s, Paint()..color = _lime);
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * fraction.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * s
          ..strokeCap = StrokeCap.round
          ..color = _lime,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

enum _NavKind { normal, primary, success }

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.label,
    required this.mobile,
    required this.onTap,
    this.kind = _NavKind.normal,
  });

  final String label;
  final bool mobile;
  final VoidCallback? onTap;
  final _NavKind kind;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return HoverBuilder(
      onTap: onTap,
      cursor: disabled ? SystemMouseCursors.forbidden : null,
      builder: (context, hover) {
        final h = hover && !disabled;
        Color bg, border, fg;
        switch (kind) {
          // The hover rules only swap the background; the generic
          // `.qe-nav-btn:hover { color: #fff }` still applies (same
          // specificity, no colour in `.primary:hover`).
          case _NavKind.primary:
            bg = h ? _limeHover : _lime;
            border = _lime;
            fg = h ? Colors.white : _bg;
          case _NavKind.success:
            bg = h ? const Color(0xFF16A34A) : _green;
            border = _green;
            fg = Colors.white;
          case _NavKind.normal:
            bg = h ? _w(0.1) : _w(0.05);
            border = _w(0.12);
            fg = h ? Colors.white : const Color(0xFFD8D6CF);
        }
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: disabled ? 0.3 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(horizontal: mobile ? 14 : 18, vertical: 9),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: mobile ? 12 : 13, fontWeight: FontWeight.w600, color: fg)),
          ),
        );
      },
    );
  }
}

/// Lime filled button (`.qe-submit-btn`, `.qe-modal-confirm`, `.qe-sec-btn`).
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
    this.fontSize = 13,
    this.radius = 10,
    this.lift = false,
  });

  final String label;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double fontSize;
  final double radius;

  /// Hover lifts by 1 px (only `.qe-submit-btn`).
  final bool lift;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return HoverBuilder(
      onTap: onTap,
      cursor: disabled ? SystemMouseCursors.forbidden : null,
      builder: (context, hover) => AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: disabled ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: padding,
          transform: Matrix4.translationValues(0, lift && hover && !disabled ? -1 : 0, 0),
          decoration: BoxDecoration(
            color: hover && !disabled ? _limeHover : _lime,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: _bg)),
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        onTap: onTap,
        builder: (context, hover) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            color: hover ? _w(0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _w(0.15), width: 1.5),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hover ? Colors.white : _w(0.6))),
        ),
      );
}

class _CloseAction extends StatelessWidget {
  const _CloseAction({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        onTap: onTap,
        builder: (context, hover) {
          final fg = hover ? Colors.white : _w(0.5);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: hover ? _w(0.1) : _w(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _w(0.12), width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(BootstrapIcons.x_lg, size: 14, color: fg),
              const SizedBox(width: 8),
              Text('Close',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
            ]),
          );
        },
      );
}

/// `.qe-toast-icon` — `toast-spin 0.5s ease` when the toast enters.
class _ToastIconSpin extends StatefulWidget {
  const _ToastIconSpin({super.key, required this.child});
  final Widget child;

  @override
  State<_ToastIconSpin> createState() => _ToastIconSpinState();
}

class _ToastIconSpinState extends State<_ToastIconSpin> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          // 0% rotate(-20deg) scale(.8) / 60% rotate(10deg) scale(1.15) / 100% 0deg 1
          final t = _c.value;
          final double deg, scale;
          if (t < 0.6) {
            final e = Curves.ease.transform(t / 0.6);
            deg = ui.lerpDouble(-20, 10, e)!;
            scale = ui.lerpDouble(0.8, 1.15, e)!;
          } else {
            final e = Curves.ease.transform((t - 0.6) / 0.4);
            deg = ui.lerpDouble(10, 0, e)!;
            scale = ui.lerpDouble(1.15, 1, e)!;
          }
          return Transform.rotate(
            angle: deg * math.pi / 180,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: widget.child,
      );
}

/// Opacity 1 → [min] → 1 every second while [enabled] (`timer-pulse`).
class _OpacityPulse extends StatefulWidget {
  const _OpacityPulse({required this.enabled, required this.min, required this.child});
  final bool enabled;
  final double min;
  final Widget child;

  @override
  State<_OpacityPulse> createState() => _OpacityPulseState();
}

class _OpacityPulseState extends State<_OpacityPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_OpacityPulse old) {
    super.didUpdateWidget(old);
    if (old.enabled != widget.enabled) _sync();
  }

  void _sync() {
    if (widget.enabled) {
      _c.repeat(reverse: true);
    } else {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Opacity(
          opacity: 1 - (1 - widget.min) * Curves.easeInOut.transform(_c.value),
          child: child,
        ),
        child: widget.child,
      );
}

/// `.qe-countdown` with the `pulse-ring` animation.
class _Countdown extends StatefulWidget {
  const _Countdown({required this.value, required this.color});
  final int value;
  final Color color;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500), lowerBound: 0.55)
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.color, width: 3),
          ),
          child: Text('${widget.value}', style: _serif(26, widget.color)),
        ),
      );
}
