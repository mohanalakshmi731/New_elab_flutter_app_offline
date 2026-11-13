import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import 'mathzoro_controller.dart';
import 'mz_ui.dart';

/// Port of `mathzoroclasschange.vue` (`/classchange`) — "Choose your arena".
/// Shown after login when a MathZoro student has several (or no) classes.
class MathZoroClassChangePage extends ConsumerStatefulWidget {
  const MathZoroClassChangePage({super.key});

  @override
  ConsumerState<MathZoroClassChangePage> createState() => _MathZoroClassChangePageState();
}

typedef _Json = Map<String, dynamic>;

// ── palette (<style scoped>) ────────────────────────────────────────────────
const _bg = Color(0xFF0D0D14);
const _fg = Color(0xFFE8E6F8);
const _violet = Color(0xFF7F77DD);
const _mint = Color(0xFF5DCAA5);
const _lilac = Color(0xFFAFA9EC);

Color _v(double a) => _violet.withValues(alpha: a);
Color _f(double a) => _fg.withValues(alpha: a);

const _easeOutQuint = Cubic(0.22, 1, 0.36, 1);
const _backOut = Cubic(0.34, 1.56, 0.64, 1);

class _MathZoroClassChangePageState extends ConsumerState<MathZoroClassChangePage>
    with TickerProviderStateMixin {
  Object? _selectedId;
  _Json? _selectedItem;
  List<dynamic> _localBatches = const [];
  late List<_Json> _classList;
  final Map<int, GlobalKey> _cardKeys = {};

  // Entrance animations (nav, logo, hero, staggered cards, footer).
  late final AnimationController _intro;
  late final int _introMs;

  // Particle canvas
  final _canvasKey = GlobalKey();
  final _frame = ValueNotifier<int>(0);
  final _rng = math.Random();
  final List<_Particle> _particles = [];
  final List<_Burst> _bursts = [];
  Size _canvasSize = Size.zero;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _acc = 0;

  // Selection flash overlay
  bool _flash = false;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();

    // window.__mz_batches and sessionStorage '_mz_raw_batches' are never
    // written by the current web app, so the store's rawStudentBatches
    // fallback is the source that is actually used.
    final raw = ref.read(sessionProvider).rawStudentBatches;
    if (raw.isNotEmpty) _localBatches = raw;
    _classList = _buildClassList(_localBatches);

    // cardVisible[i] at 120 + i*90 ms, then animation-delay i*90 ms, 450 ms long.
    final lastCard = _classList.isEmpty ? 0 : 120 + (_classList.length - 1) * 180 + 450;
    _introMs = math.max(1000, lastCard);
    _intro = AnimationController(vsync: this, duration: Duration(milliseconds: _introMs))
      ..forward();

    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initParticles());
  }

  @override
  void dispose() {
    _ticker.dispose(); // cancelAnimationFrame
    _intro.dispose();
    _frame.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  // ── computed ─────────────────────────────────────────────────────────────

  String get _userInitial {
    final name = ref.read(sessionProvider).userInfo?.username;
    if (name == null) return 'U';
    return name.isEmpty ? '' : name.substring(0, 1).toUpperCase();
  }

  static List<_Json> _buildClassList(List<dynamic> batches) {
    if (batches.isEmpty) return const [];
    final seen = <dynamic>{};
    final result = <_Json>[];
    for (final raw in batches) {
      final b = asMap(raw);
      final classes = asMap(b?['classes']);
      final courses = asList(classes?['courses']);
      for (final c in courses) {
        final course = asMap(c);
        final zslClassId = course?['zsl_class_id'];
        if (!jsTruthy(zslClassId) || seen.contains(zslClassId)) continue;
        seen.add(zslClassId);
        result.add({
          'id': zslClassId,
          'zsl_class_id': zslClassId,
          'zsl_subject_id': course?['zsl_subject_id'],
          'course_id': course?['id'],
          'course_title': course?['title'],
          'batch_id': b?['id'],
          'batch_name': b?['name'],
          'classes_id': b?['classes_id'],
          'curricula_id': classes?['curricula_id'],
          'exam_batch_id': b?['exam_batch_id'],
          'exam_course_id': course?['exam_course_id'],
          'name': 'Class ${asString(classes?['name']) ?? ''}',
          'courses': courses,
        });
      }
    }
    return result;
  }

  /// Progress (0‥1, curved) of an entrance animation that starts at
  /// [startMs] and lasts [durMs].
  double _seg(int startMs, int durMs, Curve curve) {
    final t = ((_intro.value * _introMs - startMs) / durMs).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  // ── particles ────────────────────────────────────────────────────────────

  void _initParticles() {
    if (!mounted) return;
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    _canvasSize = box?.size ?? MediaQuery.sizeOf(context);
    _particles
      ..clear()
      ..addAll(List.generate(28, (_) {
        return _Particle(
          x: _rng.nextDouble() * _canvasSize.width,
          y: _rng.nextDouble() * _canvasSize.height,
          r: _rng.nextDouble() * 1.5 + 0.5,
          dx: (_rng.nextDouble() - 0.5) * 0.3,
          dy: (_rng.nextDouble() - 0.5) * 0.3,
          o: _rng.nextDouble() * 0.4 + 0.1,
        );
      }));
    _ticker.start();
  }

  /// requestAnimationFrame loop, stepped at 60 Hz so speeds match the web.
  void _onTick(Duration elapsed) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) _canvasSize = box.size;

    _acc += (elapsed - _lastTick).inMicroseconds / 16667;
    _lastTick = elapsed;
    var steps = 0;
    while (_acc >= 1 && steps < 6) {
      _step();
      _acc -= 1;
      steps++;
    }
    if (_acc > 6) _acc = 0;
    if (steps > 0) _frame.value++;
  }

  void _step() {
    final w = _canvasSize.width, h = _canvasSize.height;
    for (final p in _particles) {
      p.x += p.dx;
      p.y += p.dy;
      if (p.x < 0 || p.x > w) p.dx *= -1;
      if (p.y < 0 || p.y > h) p.dy *= -1;
    }
    for (final burst in _bursts) {
      burst.frame++;
      for (final b in burst.dots) {
        b.x += b.dx;
        b.y += b.dy;
        b.o -= 0.04;
        b.dy += 0.12;
      }
    }
    _bursts.removeWhere((b) => b.frame >= 40);
  }

  void _spawnBurst(Offset c) {
    const colors = [Color(0xFF7F77DD), Color(0xFF1D9E75), Color(0xFF5DCAA5)];
    _bursts.add(_Burst(List.generate(14, (_) {
      return _Particle(
        x: c.dx,
        y: c.dy,
        dx: (_rng.nextDouble() - 0.5) * 5,
        dy: (_rng.nextDouble() - 0.5) * 5,
        r: _rng.nextDouble() * 3 + 1,
        o: 1,
        color: colors[_rng.nextInt(3)],
      );
    })));
  }

  // ── actions ──────────────────────────────────────────────────────────────

  void _selectClass(_Json item, int index) {
    setState(() {
      _selectedId = item['id'];
      _selectedItem = item;
    });

    final card = _cardKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
    final canvas = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (card != null && canvas != null) {
      final center = card.localToGlobal(card.size.center(Offset.zero));
      _spawnBurst(canvas.globalToLocal(center));
    }

    _flashTimer?.cancel();
    setState(() => _flash = true);
    _flashTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _flash = false);
    });
  }

  Future<void> _confirmSelection() async {
    final item = _selectedItem;
    if (item == null) return;
    final mz = ref.read(mathZoroProvider.notifier);
    await mz.ready;
    // get instituteMeta from store (set during login)
    final instituteMeta = ref.read(mathZoroProvider).instituteMeta ?? const <String, dynamic>{};
    mz.applyClassChangeSelection(item, instituteMeta);
    if (mounted) context.go(AppRoutes.mathzoroHome);
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.inter(color: _fg, fontSize: 14);
    return Scaffold(
      backgroundColor: _bg,
      body: DefaultTextStyle(
        style: base,
        child: Stack(
          children: [
            // Particle canvas
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: _canvasKey,
                    painter: _ParticlePainter(_particles, _bursts, repaint: _frame),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: AnimatedBuilder(
                animation: _intro,
                builder: (context, _) => Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        // The nav is `position: sticky` (57 px): the page
                        // scrolls underneath its translucent, blurred bar.
                        padding: const EdgeInsets.only(top: 57),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 48, 24, 60),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _hero(),
                                  const SizedBox(height: 40),
                                  if (_classList.isNotEmpty) ...[
                                    _grid(),
                                    const SizedBox(height: 40),
                                  ] else
                                    _empty(),
                                  _footer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(top: 0, left: 0, right: 0, child: _nav()),
                  ],
                ),
              ),
            ),
            // Selection flash overlay
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.ease,
                  color: _flash ? _v(0.08) : _v(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientText(String text, TextStyle style, List<Color> colors) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(colors: colors).createShader(r),
        child: Text(text, style: style.copyWith(color: Colors.white)),
      );

  Widget _nav() {
    final slide = _seg(0, 500, _easeOutQuint);
    final logo = _seg(200, 600, _backOut);
    final logoText = _seg(350, 400, Curves.ease);
    final avatar = _seg(400, 400, Curves.ease);

    return Opacity(
      opacity: slide.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, -14 * (1 - slide)),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 57,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(13, 13, 20, 0.85),
                border: Border(bottom: BorderSide(color: _v(0.15))),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Opacity(
                          opacity: logo.clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: -10 * (1 - logo) * math.pi / 180,
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * logo,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [_violet, _mint],
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const _HeroIcon(_Hero.bookOpen,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Opacity(
                          opacity: logoText,
                          child: _gradientText(
                            'MathZoro',
                            const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                            const [Color(0xFFC4C0F8), _mint],
                          ),
                        ),
                        const Spacer(),
                        Opacity(
                          opacity: avatar,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _v(0.15),
                              border: Border.all(color: _v(0.3)),
                            ),
                            child: Text(_userInitial,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: _lilac)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    final t = _seg(200, 600, _easeOutQuint);
    const titleStyle = TextStyle(
        fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.08, height: 1.15, color: _fg);
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - t)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                SizedBox(width: 7),
                Text('MISSION SELECT',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: _mint)),
              ],
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Choose your '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: _gradientText('arena', titleStyle, const [_violet, _mint]),
                ),
              ]),
              style: titleStyle,
            ),
            const SizedBox(height: 10),
            Text('Select a class to begin your journey. You can switch anytime.',
                style: TextStyle(fontSize: 14, color: _f(0.45))),
          ],
        ),
      ),
    );
  }

  /// `grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 16px`
  Widget _grid() {
    return LayoutBuilder(builder: (context, c) {
      final cols = math.max(1, ((c.maxWidth + 16) / (260 + 16)).floor());
      final rows = <Widget>[];
      for (var i = 0; i < _classList.length; i += cols) {
        if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < cols; j++) ...[
                if (j > 0) const SizedBox(width: 16),
                Expanded(
                  child: i + j < _classList.length ? _card(i + j) : const SizedBox(),
                ),
              ],
            ],
          ),
        ));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    });
  }

  Widget _card(int index) {
    final item = _classList[index];
    final t = _seg(120 + index * 180, 450, _easeOutQuint);
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 22 * (1 - t)),
        child: Transform.scale(
          scale: 0.96 + 0.04 * t,
          child: _ArenaCard(
            key: _cardKeys.putIfAbsent(index, GlobalKey.new),
            item: item,
            index: index,
            selected: _selectedId != null && _selectedId == item['id'],
            entered: t >= 1,
            onTap: () => _selectClass(item, index),
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Opacity(
      opacity: _seg(0, 500, Curves.ease),
      child: CustomPaint(
        painter: _DashedRRectPainter(color: _v(0.2), radius: 14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Column(
            children: [
              const _FloatingEmptyIcon(),
              const SizedBox(height: 16),
              const Text('No arenas available',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _fg)),
              const SizedBox(height: 6),
              Text('Contact your institute administrator to unlock classes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _f(0.35))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    final t = _seg(400, 500, _easeOutQuint);
    final n = _classList.length;
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - t)),
        child: Container(
          padding: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: _v(0.1)))),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: '$n',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _violet)),
                  TextSpan(text: '  arena${n != 1 ? 's' : ''} available'),
                ]),
                style: TextStyle(fontSize: 12, color: _f(0.35)),
              ),
              _CtaButton(
                ready: _selectedId != null,
                onTap: _confirmSelection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card ────────────────────────────────────────────────────────────────────

class _ArenaCard extends StatefulWidget {
  const _ArenaCard({
    super.key,
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
    this.entered = true,
  });

  final _Json item;
  final int index;
  final bool selected;

  /// The staggered `cardIn` entrance has finished.
  final bool entered;
  final VoidCallback onTap;

  @override
  State<_ArenaCard> createState() => _ArenaCardState();
}

class _ArenaCardState extends State<_ArenaCard> with TickerProviderStateMixin {
  bool _hover = false;

  /// `.mz-card--pulse` on the web: `animation: cardPulse … !important`
  /// replaces the card's forward-filled `cardIn`, so the card drops back to
  /// its base `opacity: 0`; 400 ms later the class is removed and `cardIn`
  /// restarts (with its `--delay`). When the click selects a *new* card,
  /// Vue's class re-render wipes the pulse class before a frame is painted
  /// (no visible pulse) — only re-clicking the selected card shows it.
  bool _hidden = false;
  Timer? _pulseTimer;
  late final AnimationController _reIn =
      AnimationController(vsync: this, value: 1, duration: _reInDuration);

  Duration get _reInDuration => Duration(milliseconds: widget.index * 90 + 450);

  /// `.mz-card:hover .mz-card-scan` (scanDown 0.5s).
  late final AnimationController _scan =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _reIn.dispose();
    _scan.dispose();
    super.dispose();
  }

  void _tap() {
    final pulseShows = widget.selected && widget.entered;
    widget.onTap();
    if (!pulseShows) return;
    _pulseTimer?.cancel();
    setState(() => _hidden = true);
    _pulseTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _hidden = false);
      _reIn
        ..duration = _reInDuration
        ..forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    final lit = sel || _hover;
    final courseCount = asList(widget.item['courses']).length;

    final border = sel ? _violet : (_hover ? _v(0.4) : _v(0.12));
    final bg = sel ? _v(0.1) : (_hover ? _v(0.06) : Colors.white.withValues(alpha: 0.03));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('#${(widget.index + 1).toString().padLeft(2, '0')}',
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _v(0.4))),
        const SizedBox(height: 16),
        AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: lit ? 1.08 : 1,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: lit ? -3 / 360 : 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lit ? _v(0.2) : _v(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _v(0.15)),
              ),
              alignment: Alignment.center,
              child: _HeroIcon(_Hero.bookOpen,
                  size: 22, stroke: 1.5, color: lit ? _violet : _lilac),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(jsDisplay(widget.item['name']),
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.15, color: _fg)),
        const SizedBox(height: 4),
        Text(jsDisplay(widget.item['batch_name']),
            style: TextStyle(fontSize: 12, color: _f(0.4))),
        const SizedBox(height: 18),
        Row(
          children: [
            _HeroIcon(_Hero.documentText, size: 12, color: _f(0.4)),
            const SizedBox(width: 5),
            Text('$courseCount course${courseCount != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 11, color: _f(0.4))),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: 2,
            color: _v(0.1),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: sel ? 1 : 0),
              duration: const Duration(milliseconds: 600),
              curve: _easeOutQuint,
              builder: (_, v, _) => FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_violet, _mint]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(22), child: content),
          // Scan line effect
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scan,
                builder: (_, _) => FractionalTranslation(
                  translation: Offset(0, -1 + 2 * Curves.ease.transform(_scan.value)),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x007F77DD), Color(0x0D7F77DD), Color(0x007F77DD)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Corner brackets
          for (final corner in _Corner.values)
            Positioned(
              top: corner.top ? 8 : null,
              bottom: corner.top ? null : 8,
              left: corner.left ? 8 : null,
              right: corner.left ? null : 8,
              child: IgnorePointer(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: lit ? 1 : 0),
                  duration: const Duration(milliseconds: 200),
                  builder: (_, v, _) => CustomPaint(
                    size: Size.square(10 + 4 * v),
                    painter: _CornerPainter(corner, Color.lerp(_v(0.3), _violet, v)!),
                  ),
                ),
              ),
            ),
          // Selected badge
          if (sel)
            Positioned(
              top: 14,
              right: 14,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (_, t, child) {
                  // badgePop: 0% scale .3 / 65% scale 1.2 / 100% scale 1 —
                  // the timing function applies to each keyframe interval.
                  final a = _backOut.transform((t / 0.65).clamp(0.0, 1.0));
                  final scale = t < 0.65
                      ? ui.lerpDouble(0.3, 1.2, a)!
                      : ui.lerpDouble(1.2, 1, _backOut.transform((t - 0.65) / 0.35))!;
                  return Opacity(
                    opacity: a.clamp(0.0, 1.0),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _violet,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    _HeroIcon(_Hero.checkSolid, size: 10, color: Colors.white),
                    SizedBox(width: 5),
                    Text('Active',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Colors.white)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        _scan.forward(from: 0);
      },
      onExit: (_) {
        setState(() => _hover = false);
        _scan.value = 0;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: AnimatedBuilder(
          animation: _reIn,
          builder: (_, child) {
            if (_hidden) return Opacity(opacity: 0, child: child);
            // cardIn re-run: animation-delay index*90 ms, then 450 ms.
            final ms = _reIn.value * _reInDuration.inMilliseconds;
            final e = _easeOutQuint.transform(((ms - widget.index * 90) / 450).clamp(0.0, 1.0));
            if (e >= 1) return child!;
            return Opacity(
              opacity: e.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 22 * (1 - e)),
                child: Transform.scale(scale: 0.96 + 0.04 * e, child: child),
              ),
            );
          },
          child: card,
        ),
      ),
    );
  }
}

enum _Corner {
  tl(true, true),
  tr(true, false),
  bl(false, true),
  br(false, false);

  const _Corner(this.top, this.left);
  final bool top;
  final bool left;
}

/// `.mz-corner` — two 1 px edges with a 2 px rounded corner.
class _CornerPainter extends CustomPainter {
  _CornerPainter(this.corner, this.color);
  final _Corner corner;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const r = 2.0;
    final x0 = corner.left ? 0.5 : w - 0.5;
    final y0 = corner.top ? 0.5 : h - 0.5;
    final x1 = corner.left ? w : 0.0;
    final y1 = corner.top ? h : 0.0;
    final sx = corner.left ? 1 : -1;
    final sy = corner.top ? 1 : -1;
    final path = Path()
      ..moveTo(x0, y1)
      ..lineTo(x0, y0 + sy * r)
      ..quadraticBezierTo(x0, y0, x0 + sx * r, y0)
      ..lineTo(x1, y0);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color || old.corner != corner;
}

// ── Footer CTA ──────────────────────────────────────────────────────────────

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.ready, required this.onTap});
  final bool ready;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready;
    final hover = ready && _hover;
    final fg = ready ? Colors.white : _f(0.35);

    final button = AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: ready && _pressed ? 0.97 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, hover && !_pressed ? -2 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          gradient: ready
              ? const CssLinearGradient(angle: 135, colors: [_violet, _mint])
              : null,
          color: ready ? null : _v(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ready ? Colors.transparent : _v(0.2)),
          boxShadow: ready
              ? [
                  BoxShadow(
                    color: _v(hover ? 0.45 : 0.3),
                    blurRadius: hover ? 28 : 20,
                    offset: Offset(0, hover ? 6 : 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ready ? 'Enter Arena' : 'Select a class',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.13, color: fg)),
            const SizedBox(width: 10),
            AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              offset: Offset(hover ? 3 / 16 : 0, 0),
              child: _HeroIcon(_Hero.arrowRight, size: 16, color: fg),
            ),
          ],
        ),
      ),
    );

    // `pointer-events: none` until a class is selected.
    if (!ready) return IgnorePointer(child: button);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: button,
      ),
    );
  }
}

// ── Inline SVG icons ────────────────────────────────────────────────────────

/// The page's inline Heroicons SVGs: outline icons on a 24×24 viewBox
/// (`stroke-linecap/linejoin: round`) and the solid 20×20 check.
enum _Hero { bookOpen, documentText, arrowRight, checkSolid }

class _HeroIcon extends StatelessWidget {
  const _HeroIcon(this.icon, {required this.size, required this.color, this.stroke = 2});
  final _Hero icon;
  final double size;
  final Color color;

  /// `stroke-width` in viewBox units.
  final double stroke;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _HeroPainter(icon, color, stroke),
      );
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.icon, this.color, this.stroke);
  final _Hero icon;
  final Color color;
  final double stroke;

  static Path _path(_Hero icon) {
    const r1 = Radius.circular(1), r2 = Radius.circular(2);
    switch (icon) {
      case _Hero.bookOpen:
        return Path()
          ..moveTo(12, 6.042)
          ..arcToPoint(const Offset(6, 3.75), radius: const Radius.circular(8.967), clockwise: false)
          ..cubicTo(4.948, 3.75, 3.938, 3.93, 3, 4.262)
          ..lineTo(3, 18.512)
          ..arcToPoint(const Offset(6, 18), radius: const Radius.circular(8.987))
          ..cubicTo(8.305, 18, 10.408, 18.867, 12, 20.292)
          ..moveTo(12, 6.042)
          ..arcToPoint(const Offset(18, 3.75), radius: const Radius.circular(8.966))
          ..cubicTo(19.052, 3.75, 20.062, 3.93, 21, 4.262)
          ..lineTo(21, 18.512)
          ..arcToPoint(const Offset(18, 18), radius: const Radius.circular(8.987), clockwise: false)
          ..arcToPoint(const Offset(12, 20.292),
              radius: const Radius.circular(8.966), clockwise: false)
          ..moveTo(12, 6.042)
          ..lineTo(12, 20.292);
      case _Hero.documentText:
        return Path()
          ..moveTo(9, 12)
          ..lineTo(15, 12)
          ..moveTo(9, 16)
          ..lineTo(15, 16)
          ..moveTo(17, 21)
          ..lineTo(7, 21)
          ..arcToPoint(const Offset(5, 19), radius: r2)
          ..lineTo(5, 5)
          ..arcToPoint(const Offset(7, 3), radius: r2)
          ..lineTo(12.586, 3)
          ..arcToPoint(const Offset(13.293, 3.293), radius: r1)
          ..lineTo(18.707, 8.707)
          ..arcToPoint(const Offset(19, 9.414), radius: r1)
          ..lineTo(19, 19)
          ..arcToPoint(const Offset(17, 21), radius: r2)
          ..close();
      case _Hero.arrowRight:
        return Path()
          ..moveTo(13, 7)
          ..lineTo(18, 12)
          ..lineTo(13, 17)
          ..moveTo(18, 12)
          ..lineTo(6, 12);
      case _Hero.checkSolid:
        return Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(16.707, 5.293)
          ..arcToPoint(const Offset(16.707, 6.707), radius: r1)
          ..lineTo(8.414, 15)
          ..lineTo(4.293, 10.879)
          ..arcToPoint(const Offset(5.707, 9.465), radius: r1, largeArc: true)
          ..lineTo(8.414, 12.172)
          ..lineTo(15.293, 5.293)
          ..arcToPoint(const Offset(16.707, 5.293), radius: r1)
          ..close();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final solid = icon == _Hero.checkSolid;
    canvas.scale(size.width / (solid ? 20 : 24));
    final paint = Paint()..color = color;
    if (!solid) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(_path(icon), paint);
  }

  @override
  bool shouldRepaint(_HeroPainter old) =>
      old.icon != icon || old.color != color || old.stroke != stroke;
}

// ── Small animated pieces ───────────────────────────────────────────────────

/// `.mz-tag-dot` with `pulse 2s ease-in-out infinite`.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final e = Curves.easeInOut.transform(_c.value);
          return Opacity(
            opacity: 1 - 0.5 * e,
            child: Transform.scale(
              scale: 1 - 0.15 * e,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: _mint, shape: BoxShape.circle),
              ),
            ),
          );
        },
      );
}

/// `.mz-empty-icon` with `float 3s ease-in-out infinite`.
class _FloatingEmptyIcon extends StatefulWidget {
  const _FloatingEmptyIcon();

  @override
  State<_FloatingEmptyIcon> createState() => _FloatingEmptyIconState();
}

class _FloatingEmptyIconState extends State<_FloatingEmptyIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -8 * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _v(0.08),
            border: Border.all(color: _v(0.15)),
          ),
          alignment: Alignment.center,
          child: _HeroIcon(_Hero.bookOpen, size: 28, color: _v(0.5), stroke: 1.5),
        ),
      );
}

/// `border: 1px dashed` around a rounded rectangle.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.5), Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    const dash = 4.0, gap = 4.0;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.color != color || old.radius != radius;
}

// ── Particle canvas ─────────────────────────────────────────────────────────

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.r,
    required this.dx,
    required this.dy,
    required this.o,
    this.color = _violet,
  });

  double x, y, r, dx, dy, o;
  final Color color;
}

class _Burst {
  _Burst(this.dots);
  final List<_Particle> dots;
  int frame = 0;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.bursts, {required Listenable repaint})
      : super(repaint: repaint);

  final List<_Particle> particles;
  final List<_Burst> bursts;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      paint.color = const Color.fromRGBO(127, 119, 221, 1).withValues(alpha: p.o);
      canvas.drawCircle(Offset(p.x, p.y), p.r, paint);
    }
    for (final burst in bursts) {
      for (final b in burst.dots) {
        if (b.o <= 0) continue;
        paint.color = b.color.withValues(alpha: b.o.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(b.x, b.y), b.r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => false;
}
