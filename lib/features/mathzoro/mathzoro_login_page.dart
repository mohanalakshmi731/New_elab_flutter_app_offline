import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../../widgets/app_loader.dart';
import 'mathzoro_controller.dart';
import 'mz_ui.dart';

/// Port of `mathzorostudentloginpage.vue` — MathZoro student login with the
/// forgot-password (OTP) flow.
class MathZoroLoginPage extends ConsumerStatefulWidget {
  const MathZoroLoginPage({super.key});

  @override
  ConsumerState<MathZoroLoginPage> createState() => _MathZoroLoginPageState();
}

/// The page asks for 'Nunito' / 'Fredoka One'; loaded through google_fonts.
TextStyle _nunito({double? size, FontWeight? weight, Color? color, double? spacing}) =>
    GoogleFonts.nunito(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

TextStyle _fredoka({double? size, Color? color, double? spacing, List<Shadow>? shadows}) =>
    GoogleFonts.fredoka(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: spacing,
        shadows: shadows);

class _MathZoroLoginPageState extends ConsumerState<MathZoroLoginPage>
    with TickerProviderStateMixin {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _resetEmail = TextEditingController();
  final _twoFACode = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _resetLinkSent = false;
  bool _showForgotPasswordForm = false;
  bool _isLoading = false;

  /// `floatDeco 7s ease-in-out infinite`.
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();

  /// `shiftBar 4s linear infinite`.
  late final AnimationController _bar =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  /// `cardPop 0.7s cubic-bezier(0.34, 1.56, 0.64, 1) 0.15s both`.
  late final AnimationController _pop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 850))
        ..forward();

  @override
  void dispose() {
    for (final c in [
      _username,
      _password,
      _resetEmail,
      _twoFACode,
      _newPassword,
      _confirmPassword,
    ]) {
      c.dispose();
    }
    _float.dispose();
    _bar.dispose();
    _pop.dispose();
    super.dispose();
  }

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);

  // ── actions ──────────────────────────────────────────────────────────────

  void _resetToLoginCard() {
    setState(() {
      _showForgotPasswordForm = false;
      _resetLinkSent = false;
    });
    _resetEmail.clear();
    _confirmPassword.clear();
    _newPassword.clear();
    _twoFACode.clear();
    _password.clear();
  }

  void _setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  /// API failures are already toasted by the ApiClient interceptor; only
  /// errors it does not toast (401, client-side) get the page's fallback.
  void _toastError(Object error, String fallback) {
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        AppToast.error(ApiClient.messageOf(error, fallback: fallback));
      }
      return;
    }
    AppToast.error(error is ApiError ? error.message : fallback);
  }

  Future<void> _sendResetLink() async {
    try {
      _setLoading(true);
      await _mz.forgotPassword(_resetEmail.text);
      if (mounted) setState(() => _resetLinkSent = true);
    } catch (e) {
      _toastError(e, 'Failed to send OTP');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleResetPassword() async {
    try {
      _setLoading(true);
      await _mz.resetPassword(
        email: _resetEmail.text,
        otp: _twoFACode.text,
        password: _newPassword.text,
        passwordConfirmation: _confirmPassword.text,
      );
      AppToast.success('Password reset successful!');
      if (mounted) _resetToLoginCard();
    } catch (e) {
      debugPrint('Reset password error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleLogin() async {
    try {
      _setLoading(true);

      // sessionStorage.clear() — also drops the previous class selection.
      _mz.reset();

      final response = await ref
          .read(authServiceProvider)
          .login(_username.text, _password.text, const Uuid().v4());

      // setUserInfo initialises all base state including rawStudentBatches
      ref.read(sessionProvider.notifier).setUserInfo(response);

      final institutes = asList(asMap(response)?['institutes']);
      final institute = asMap(institutes.cast<dynamic>().firstWhere(
            (i) => jsTruthy(asMap(i)?['is_default']),
            orElse: () => institutes.isNotEmpty ? institutes.first : null,
          ));

      final role = asString(dig(institute, ['roles', 0, 'name']));
      final isMathZoro = jsTruthy(institute?['is_math_zoro']);

      // ── STUDENT + MATH ZORO ──────────────────────────────────
      if (role == Role.student && isMathZoro) {
        final batches = asList(dig(institute, ['student', 'batches']));

        final subscriptions = asList(institute?['subscriptions']);
        final activeSubscription = asMap(subscriptions.cast<dynamic>().firstWhere(
              (s) => jsTruthy(asMap(s)?['is_active']),
              orElse: () => subscriptions.isNotEmpty ? subscriptions.first : null,
            ));
        final plan = asMap(activeSubscription?['subscription_plan']);

        final instituteMeta = <String, dynamic>{
          'name': institute?['name'],
          'logo': institute?['logo'],
          'institute_plan_id': institute?['institute_plan_id'],
          'plan': {
            'id': plan?['id'],
            'name': plan?['name'],
            'plan_type': plan?['plan_type'],
            'classes_id': plan?['classes_id'],
            'start_date': activeSubscription?['start_date'],
            'end_date': activeSubscription?['end_date'],
          },
        };

        // Build unique classes keyed by zsl_class_id
        final classMap = <dynamic, Map<String, dynamic>>{};
        for (final b in batches) {
          final batch = asMap(b);
          final classes = asMap(batch?['classes']);
          for (final c in asList(classes?['courses'])) {
            final course = asMap(c);
            final zslClassId = course?['zsl_class_id'];
            if (!jsTruthy(zslClassId)) continue;
            classMap.putIfAbsent(
              zslClassId,
              () => {
                'zsl_class_id': zslClassId,
                'zsl_subject_id': course?['zsl_subject_id'],
                'course_id': course?['id'],
                'course_title': course?['title'],
                'batch_id': batch?['id'],
                'batch_name': batch?['name'],
                'classes_id': batch?['classes_id'],
                'curricula_id': classes?['curricula_id'],
                'exam_batch_id': batch?['exam_batch_id'],
                'exam_course_id': course?['exam_course_id'],
                'courses': jsTruthy(classes?['courses']) ? classes!['courses'] : const [],
                'name': 'Class ${asString(classes?['name']) ?? ''}',
              },
            );
          }
        }

        _mz.setAvailableClasses(classMap.values.toList());

        // SINGLE CLASS → store everything and go to dashboard
        if (classMap.length == 1) {
          _mz.storeAllClassData(classMap.values.first, instituteMeta);
          AppToast.success('Login successful');
          if (mounted) context.go(AppRoutes.mathzoroHome);
          return;
        }

        _mz.setInstituteMeta(instituteMeta);

        // MULTIPLE or NO CLASS → classchange page handles selection
        AppToast.success('Login successful');
        if (mounted) context.go(AppRoutes.classChange);
        return;
      }

      // ── STUDENT (non math zoro) ──────────────────────────────
      if (role == Role.student) {
        AppToast.success('Login successful');
        if (mounted) context.go(AppRoutes.dashboard);
        return;
      }

      // ── INSTRUCTOR ───────────────────────────────────────────
      if (role == Role.instructor) {
        AppToast.success('Login successful');
        if (mounted) context.go('/newlayout/dashboard');
        return;
      }

      // ── FALLBACK ─────────────────────────────────────────────
      AppToast.success('Login successful');
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('$e');
      _toastError(e, 'Login failed');
    } finally {
      _setLoading(false);
    }
  }

  /// `@submit.prevent` of the form.
  void _submit() {
    if (_isLoading) return;
    if (_showForgotPasswordForm) {
      _resetLinkSent ? _handleResetPassword() : _sendResetLink();
    } else {
      _handleLogin();
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLg = size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF050A1E),
      body: LoadingOverlay(
        loading: _isLoading,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background (background-size: 100% 100%)
            Image.asset('assets/images/mathzoro_login_bg.png', fit: BoxFit.fill),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(5, 10, 30, 0.55),
                    Color.fromRGBO(5, 10, 30, 0.20),
                    Color.fromRGBO(5, 10, 30, 0.20),
                    Color.fromRGBO(5, 10, 30, 0.75),
                  ],
                  stops: [0, 0.35, 0.65, 1],
                ),
              ),
            ),

            // Floating math symbols decoration
            ..._decorations(size),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: isLg
                                ? const EdgeInsets.fromLTRB(24, 24, 60, 24)
                                : const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: Align(
                              alignment: isLg ? Alignment.centerRight : Alignment.center,
                              child: _animatedCard(size.width),
                            ),
                          ),
                        ),
                        _footer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _decorations(Size size) {
    Widget deco(String text, Color color, double fontSize, double delay,
        {double? top, double? bottom, double? left, double? right}) {
      return Positioned(
        top: top == null ? null : size.height * top,
        bottom: bottom == null ? null : size.height * bottom,
        left: left == null ? null : size.width * left,
        right: right == null ? null : size.width * right,
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              final phase = ((_float.value * 7 - delay) / 7) % 1;
              final seg = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
              final e = Curves.easeInOut.transform(seg);
              return Transform.translate(
                offset: Offset(0, -18 * e),
                child: Transform.rotate(angle: (-5 + 10 * e) * math.pi / 180, child: child),
              );
            },
            child: Opacity(
              opacity: 0.18,
              child: Text(text,
                  style: _fredoka(size: fontSize, color: color).copyWith(height: 1.2)),
            ),
          ),
        ),
      );
    }

    return [
      deco('+', const Color(0xFFFACC15), 48, 0, top: 0.12, left: 0.06),
      deco('π', const Color(0xFFF97316), 44.8, 1.5, top: 0.20, right: 0.05),
      deco('x²', const Color(0xFF34D399), 35.2, 3, bottom: 0.28, left: 0.04),
      deco('=', const Color(0xFFA78BFA), 48, 4.5, bottom: 0.18, right: 0.06),
    ];
  }

  Widget _animatedCard(double width) {
    const curve = Interval(150 / 850, 1, curve: Cubic(0.34, 1.56, 0.64, 1));
    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        final v = curve.transform(_pop.value);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - v)),
            child: Transform.scale(scale: 0.96 + 0.04 * v, child: child),
          ),
        );
      },
      child: _card(width),
    );
  }

  Widget _card(double width) {
    final mobile = width <= 480;
    final radius = mobile ? 22.0 : 28.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(color: Color(0x73000000), blurRadius: 60, offset: Offset(0, 24)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            // backdrop-filter: blur(22px) saturate(160%)
            filter: cssBackdrop(blur: 22, saturate: 1.6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(8, 16, 48, 0.58),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: mobile
                        ? const EdgeInsets.fromLTRB(20, 28, 20, 24)
                        : const EdgeInsets.fromLTRB(34, 36, 34, 32),
                    child: _cardBody(mobile),
                  ),
                  // Colourful top border
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 4,
                    child: AnimatedBuilder(
                      animation: _bar,
                      builder: (context, _) =>
                          CustomPaint(painter: _ShiftBarPainter(_bar.value)),
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

  Widget _cardBody(bool mobile) {
    final forgot = _showForgotPasswordForm;
    final children = <Widget>[
      // Logo
      Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset('assets/images/nobglogo.png',
              width: double.infinity, fit: BoxFit.contain),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        forgot ? 'Reset Password' : 'Welcome',
        textAlign: TextAlign.center,
        style: _fredoka(
          size: mobile ? 22 : 26,
          color: Colors.white,
          shadows: const [
            Shadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        forgot
            ? "Enter your email and we'll send you an OTP"
            : 'Sign in to continue your adventure',
        textAlign: TextAlign.center,
        style: _nunito(size: 13.5, color: Colors.white.withValues(alpha: 0.62)),
      ),
      const SizedBox(height: 24),
    ];

    if (forgot) {
      children.addAll([
        _MzField(
          label: 'Username',
          icon: BootstrapIcons.envelope,
          controller: _resetEmail,
          hint: 'Enter 10-digit mobile number',
          digitsOnly: true,
          onSubmitted: _submit,
        ),
        if (!_resetLinkSent)
          _GradientButton(label: 'Send OTP', mobile: mobile, onTap: _submit)
        else ...[
          _MzField(
            label: 'OTP Code',
            icon: BootstrapIcons.key,
            controller: _twoFACode,
            hint: 'Enter OTP',
            onSubmitted: _submit,
          ),
          _MzField(
            label: 'New Password',
            icon: BootstrapIcons.lock,
            controller: _newPassword,
            hint: 'New password',
            password: true,
            onSubmitted: _submit,
          ),
          _MzField(
            label: 'Confirm Password',
            icon: BootstrapIcons.lock_fill,
            controller: _confirmPassword,
            hint: 'Confirm password',
            password: true,
            onSubmitted: _submit,
          ),
          _GradientButton(
            label: 'Reset Password',
            mobile: mobile,
            success: true,
            onTap: _handleResetPassword,
          ),
        ],
        const SizedBox(height: 14),
        Center(child: _BackLink(onTap: _resetToLoginCard)),
      ]);
    } else {
      children.addAll([
        _MzField(
          label: 'Username',
          icon: BootstrapIcons.envelope,
          controller: _username,
          hint: 'Enter 10-digit mobile number',
          digitsOnly: true,
          autofillHints: const [AutofillHints.username],
          // Enter submits the <form> on the web (implicit submission).
          onSubmitted: _submit,
        ),
        _MzField(
          label: 'Password',
          icon: BootstrapIcons.lock,
          controller: _password,
          hint: 'Enter password',
          password: true,
          autofillHints: const [AutofillHints.password],
          onSubmitted: _submit,
          labelTrailing: _ForgotLink(
            onTap: () => setState(() => _showForgotPasswordForm = true),
          ),
        ),
        _GradientButton(label: 'Sign In →', mobile: mobile, onTap: _submit),
      ]);
    }

    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _footer() => Padding(
        padding: const EdgeInsets.all(16),
        child: Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Powered by '),
            TextSpan(
              text: 'ZeroScienceLab',
              style: _nunito(color: const Color(0xFF4ADE80), weight: FontWeight.w800),
            ),
          ]),
          textAlign: TextAlign.center,
          style: _nunito(
              size: 12.5,
              weight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
}

/// `linear-gradient(90deg, #f59e0b, #ef4444, #8b5cf6, #06b6d4, #22c55e)`
/// with `background-size: 200%` sliding left.
class _ShiftBarPainter extends CustomPainter {
  _ShiftBarPainter(this.t);
  final double t;

  static const _colors = [
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF22C55E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final tile = size.width * 2;
    final x0 = -tile * t;
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(x0, 0),
        Offset(x0 + tile, 0),
        _colors,
        const [0, 0.25, 0.5, 0.75, 1],
        TileMode.repeated,
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_ShiftBarPainter old) => old.t != t;
}

/// `.field` — uppercase label, icon-prefixed glass input, optional eye toggle.
class _MzField extends StatefulWidget {
  const _MzField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.password = false,
    this.digitsOnly = false,
    this.onSubmitted,
    this.labelTrailing,
    this.autofillHints,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool password;

  /// `maxlength="10" inputmode="numeric"` + `replace(/\D/g, '')`.
  final bool digitsOnly;
  final VoidCallback? onSubmitted;
  final Widget? labelTrailing;
  final Iterable<String>? autofillHints;

  @override
  State<_MzField> createState() => _MzFieldState();
}

class _MzFieldState extends State<_MzField> {
  final _focus = FocusNode();
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final label = Text(
      widget.label.toUpperCase(),
      style: _nunito(
        size: 12.5,
        weight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.8),
        spacing: 0.5,
      ),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: focused
            ? const Color.fromRGBO(250, 204, 21, 0.75)
            : Colors.white.withValues(alpha: 0.12),
        width: 1.5,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelTrailing != null) ...[
            // `.field-label-row` (margin-bottom 7) around a `.field-label`
            // that keeps its own 7px bottom margin; the link is centred on both.
            Row(children: [
              Padding(padding: const EdgeInsets.only(bottom: 7), child: label),
              const Spacer(),
              widget.labelTrailing!,
            ]),
            const SizedBox(height: 7),
          ] else ...[
            label,
            const SizedBox(height: 7),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: focused
                  ? const [
                      BoxShadow(color: Color.fromRGBO(250, 204, 21, 0.12), spreadRadius: 4),
                    ]
                  : const [],
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.password && !_show,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType:
                      widget.digitsOnly ? TextInputType.number : TextInputType.text,
                  inputFormatters: widget.digitsOnly
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ]
                      : null,
                  autofillHints: widget.autofillHints,
                  textInputAction: widget.onSubmitted != null ? TextInputAction.go : null,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  cursorColor: Colors.white,
                  style: _nunito(size: 14, color: Colors.white),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: focused ? 0.14 : 0.09),
                    hintText: widget.hint,
                    hintStyle:
                        _nunito(size: 14, color: Colors.white.withValues(alpha: 0.38)),
                    contentPadding:
                        EdgeInsets.fromLTRB(42, 14, widget.password ? 40 : 16, 14),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                ),
                Positioned(
                  left: 13,
                  child: IgnorePointer(
                    child: Icon(widget.icon,
                        size: 15, color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ),
                if (widget.password)
                  Positioned(
                    right: 12,
                    child: _HoverOpacity(
                      onTap: () => setState(() => _show = !_show),
                      child: Icon(
                        _show ? BootstrapIcons.eye_slash : BootstrapIcons.eye,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable child whose opacity changes on hover (`.eye-btn:hover`).
class _HoverOpacity extends StatefulWidget {
  const _HoverOpacity({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_HoverOpacity> createState() => _HoverOpacityState();
}

class _HoverOpacityState extends State<_HoverOpacity> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _hover ? 0.9 : 1,
            child: widget.child,
          ),
        ),
      );
}

/// `.btn-primary` (+ `.btn-success`) with the hover lift and shine sweep.
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.mobile,
    this.success = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool mobile;
  final bool success;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.success
        ? const CssLinearGradient(
            angle: 135,
            colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
          )
        : CssLinearGradient(
            // background-size: 200% 100% → position 0% (rest) / 100% (hover)
            angle: 135,
            sizeX: 2,
            positionX: _hover ? 1 : 0,
            colors: const [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6)],
          );
    final shadowColor = widget.success
        ? Color.fromRGBO(34, 197, 94, _hover ? 0.45 : 0.35)
        : Color.fromRGBO(239, 68, 68, _hover ? 0.45 : 0.35);
    final fontSize = widget.mobile ? 15.0 : 17.0;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            transform: Matrix4.translationValues(0, _hover && !_pressed ? -2 : 0, 0),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: _hover ? 30 : 24,
                  offset: Offset(0, _hover ? 10 : 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(widget.mobile ? 13 : 15),
                        child: Center(
                          child: Text(
                            widget.label,
                            style: _fredoka(
                                size: fontSize, color: Colors.white, spacing: fontSize * 0.04),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                        top: 0,
                        bottom: 0,
                        left: _hover ? w * 1.3 : -w * 0.8,
                        width: w * 0.6,
                        child: IgnorePointer(
                          child: Transform(
                            transform: Matrix4.skewX(-20 * math.pi / 180),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Color(0x00FFFFFF),
                                  Color(0x38FFFFFF),
                                  Color(0x00FFFFFF),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotLink extends StatefulWidget {
  const _ForgotLink({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ForgotLink> createState() => _ForgotLinkState();
}

class _ForgotLinkState extends State<_ForgotLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            'Forgot password?',
            style: _nunito(
              size: 12.5,
              weight: FontWeight.w700,
              color: _hover ? const Color(0xFFFEF08A) : const Color(0xFFFCD34D),
            ),
          ),
        ),
      );
}

class _BackLink extends StatefulWidget {
  const _BackLink({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BackLink> createState() => _BackLinkState();
}

class _BackLinkState extends State<_BackLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: _hover ? 0.9 : 0.6);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.arrow_left, size: 13, color: color),
            const SizedBox(width: 4),
            Text('Back to Login',
                style: _nunito(size: 13, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
