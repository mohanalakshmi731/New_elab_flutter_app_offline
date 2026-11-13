import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/glass.dart';
import '../dashboard/web_style.dart';

/// Port of `src/pages/LoginPage.vue` (eLabs flavor).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Login
  final _username = TextEditingController();
  final _password = TextEditingController();
  // Forgot / reset
  final _resetEmail = TextEditingController();
  final _otp = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _showForgot = false;
  bool _resetLinkSent = false;
  bool _loading = false;

  /// The browser's validation bubble for the `type="email" required` reset
  /// email, shown when the form is submitted with an invalid value.
  String? _emailValidity;

  @override
  void initState() {
    super.initState();
    _resetEmail.addListener(() {
      if (_emailValidity != null) setState(() => _emailValidity = null);
    });
  }

  @override
  void dispose() {
    for (final c in [_username, _password, _resetEmail, _otp, _newPassword, _confirmPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetToLoginCard() {
    setState(() {
      _showForgot = false;
      _resetLinkSent = false;
      _emailValidity = null;
    });
    _resetEmail.clear();
    _confirmPassword.clear();
    _newPassword.clear();
    _otp.clear();
    _password.clear();
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() => _loading = true);
    try {
      await task();
    } catch (_) {
      // API errors are already toasted by the ApiClient interceptor.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendResetLink() => _run(() async {
        await ref.read(authServiceProvider).forgotPassword(_resetEmail.text.trim());
        if (mounted) setState(() => _resetLinkSent = true);
      });

  Future<void> _handleResetPassword() async {
    final newPass = _newPassword.text.trim();
    final confirmPass = _confirmPassword.text.trim();
    if (_otp.text.trim().isEmpty) {
      AppToast.error('OTP is required');
      return;
    }
    // The web's "Password cannot be empty" / "Passwords do not match" toasts
    // are commented out: it just returns.
    if (newPass.isEmpty || confirmPass.isEmpty) return;
    if (newPass != confirmPass) return;
    await _run(() async {
      await ref.read(authServiceProvider).resetPassword(
          _resetEmail.text.trim(), _otp.text.trim(), newPass, confirmPass);
      _resetToLoginCard();
    });
  }

  Future<void> _handleLogin() => _run(() async {
        final response = await ref
            .read(authServiceProvider)
            .login(_username.text.trim(), _password.text, const Uuid().v4());

        final institutes = asList(asMap(response)?['institutes']);
        final institute = asMap(institutes.cast<dynamic>().firstWhere(
              (i) => asBool(asMap(i)?['is_default']),
              orElse: () => institutes.isNotEmpty ? institutes.first : null,
            ));
        final role = asString(dig(institute, ['roles', 0, 'name']));
        final isMathZoro = asBool(institute?['is_math_zoro']);

        // MathZoro students must use the MathZoro app.
        if (role == Role.student && isMathZoro) {
          AppToast.error('No user found');
          return;
        }

        ref.read(sessionProvider.notifier).setUserInfo(response);
        AppToast.success('Login successful');
        if (mounted) context.go(AppRoutes.dashboard);
      });

  /// `<form @submit.prevent>`: Enter in any field, "Send OTP" and "Login".
  /// In the forgot view the browser first validates the `required`
  /// `type="email"` field.
  void _submit() {
    if (_loading) return;
    if (_showForgot) {
      final validity = _emailValidationMessage(_resetEmail.text.trim());
      if (validity != null) {
        setState(() => _emailValidity = validity);
        return;
      }
      _resetLinkSent ? _handleResetPassword() : _sendResetLink();
    } else {
      _handleLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: LoadingOverlay(
        loading: _loading,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // `.login-bg` (cover / center) + the `bg-black/40` overlay.
            Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
            const ColoredBox(color: Color(0x66000000)),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // `min-h-screen flex flex-col`: the footer sits at the
                  // bottom and the page scrolls when the card is taller.
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // CENTER AREA `flex-1 px-[4%] pt-[28%] md:pt-0`,
                            // the card centred in it.
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    width * 0.04, context.isMd ? 0 : width * 0.28, width * 0.04, 0),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 448), // max-w-md
                                    child: _card(context),
                                  ),
                                ),
                              ),
                            ),
                            const _PoweredByFooter(),
                          ],
                        ),
                        // Top bar `absolute top-6 left-6 right-6`.
                        Positioned(top: 24, left: 24, right: 24, child: _topBar(context)),
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

  Widget _topBar(BuildContext context) {
    final sm = context.isSm;
    final barWidth = MediaQuery.sizeOf(context).width - 48;
    // `h-15 w-[60%] sm:w-auto` — below sm the image is stretched to 60% of
    // the bar (an <img> with both sizes set and no object-fit).
    Image logoImage() => Image.asset(
          'assets/images/elabs_logo.png',
          height: 60,
          width: sm ? null : barWidth * 0.6,
          fit: sm ? BoxFit.contain : BoxFit.fill,
          errorBuilder: (_, _, _) => Image.asset('assets/images/logo.png', height: 60),
        );
    // `drop-shadow-lg`: `drop-shadow(0 4px 4px rgb(0 0 0 / .15))`. A CSS
    // drop-shadow's blur is the Gaussian's standard deviation (unlike
    // box-shadow's blur radius), so sigma = 4.
    final logo = Stack(children: [
      Transform.translate(
        offset: const Offset(0, 4),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4, tileMode: TileMode.decal),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Color(0x26000000), BlendMode.srcIn),
            child: logoImage(),
          ),
        ),
      ),
      logoImage(),
    ]);
    final dark = context.isDark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: logo),
        const SizedBox(width: 8),
        // `<Button variant="outline" class="bg-primary border-0 text-white">`:
        // the outline variant keeps its hover (`bg-accent
        // text-accent-foreground`) and dark (`bg-input/30`, hover `/50`)
        // colours.
        _WebButton(
          label: 'Sign Up',
          background: dark ? WebColors.inputDark.withValues(alpha: 0.3) : context.colors.primary,
          hoverBackground: dark ? WebColors.inputDark.withValues(alpha: 0.5) : WebColors.accent,
          hoverForeground: WebColors.accentForeground,
          onPressed: () => context.go('/signup'),
        ),
      ],
    );
  }

  Widget _card(BuildContext context) {
    final sm = context.isSm;
    // `glass-card p-3 sm:p-6` (tailwind-merge drops the Card's `py-6`),
    // `rounded-xl` (20px) and CardHeader/CardContent `px-6`.
    return GlassCard(
      radius: 20,
      padding: EdgeInsets.symmetric(horizontal: (sm ? 24 : 12) + 24, vertical: sm ? 24 : 12),
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // `.glass-card [data-slot=card-title]` overrides `text-indigo-400
            // font-semibold`: white, weight 800, soft white text-shadow.
            Text(
              _showForgot ? 'Forgot Password' : 'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sm ? 28.8 : 24,
                height: 1, // leading-none
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: const [Shadow(color: Color(0x40FFFFFF), blurRadius: 12, offset: Offset(0, 2))],
              ),
            ),
            const SizedBox(height: 24), // Card `gap-6`
            ..._showForgot ? _forgotView(context) : _loginView(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _loginView(BuildContext context) {
    final primary = context.colors.primary;
    return [
      _GlassInput(
        label: 'Email',
        hint: 'Enter email',
        controller: _username,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.username, AutofillHints.email],
        onSubmitted: _submit,
      ),
      const SizedBox(height: 16),
      _GlassInput(
        label: 'Password',
        hint: 'Enter password',
        controller: _password,
        obscure: true,
        autofillHints: const [AutofillHints.password],
        onSubmitted: _submit,
      ),
      const SizedBox(height: 16),
      // `flex justify-between flex-wrap` (items stretch, so the link's text
      // sits at the top of the row).
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          _LinkText('Forgot password?', onTap: () => setState(() => _showForgot = true)),
          _WebButton(
            label: 'Login',
            horizontalPadding: 24, // px-6
            background: primary,
            hoverBackground: primary.withValues(alpha: 0.9),
            onPressed: _submit,
          ),
        ],
      ),
    ];
  }

  List<Widget> _forgotView(BuildContext context) {
    final primary = context.colors.primary;
    return [
      _GlassInput(
        label: 'Email',
        hint: 'Enter your email',
        controller: _resetEmail,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        onSubmitted: _submit,
      ),
      if (_emailValidity != null) _ValidityBubble(message: _emailValidity!),
      const SizedBox(height: 16),
      if (!_resetLinkSent)
        _WebButton(
          label: 'Send OTP',
          expand: true,
          background: primary,
          hoverBackground: primary.withValues(alpha: 0.9),
          onPressed: _submit,
        )
      else ...[
        _GlassInput(label: 'OTP', hint: 'Enter OTP', controller: _otp, onSubmitted: _submit),
        const SizedBox(height: 16),
        _GlassInput(
          label: 'New Password',
          hint: 'New password',
          controller: _newPassword,
          obscure: true,
          onSubmitted: _submit,
        ),
        const SizedBox(height: 16),
        _GlassInput(
          label: 'Confirm Password',
          hint: 'Confirm password',
          controller: _confirmPassword,
          obscure: true,
          onSubmitted: _submit,
        ),
        // Block `mb-4` + the inline button's own `mt-4` (no collapsing).
        const SizedBox(height: 32),
        // `bg-green-600` replaces `bg-primary` but the default variant's
        // `hover:bg-primary/90` stays.
        _WebButton(
          label: 'Reset Password',
          expand: true,
          background: Tw.green600,
          hoverBackground: primary.withValues(alpha: 0.9),
          onPressed: () {
            if (!_loading) _handleResetPassword();
          },
        ),
      ],
      // The inline button's `mb-4` + the link's `mt-3`.
      const SizedBox(height: 28),
      Center(child: _LinkText('Back to Login', onTap: _resetToLoginCard, dim: true)),
    ];
  }
}

/// Chrome's constraint-validation message for a `required` `type="email"`
/// input, or null when the value passes.
String? _emailValidationMessage(String value) {
  if (value.isEmpty) return 'Please fill out this field.';
  final at = value.indexOf('@');
  if (at < 0) return "Please include an '@' in the email address. '$value' is missing an '@'.";
  if (at == 0) return "Please enter a part followed by '@'. '$value' is incomplete.";
  if (at == value.length - 1) return "Please enter a part following '@'. '$value' is incomplete.";
  return null;
}

/// The browser's validation bubble (approximated below the field).
class _ValidityBubble extends StatelessWidget {
  const _ValidityBubble({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Tw.gray300),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Tw.orange500, borderRadius: BorderRadius.circular(3)),
            child: const Text('!',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, height: 1)),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(message, style: const TextStyle(color: Colors.black, fontSize: 13))),
        ]),
      ),
    );
  }
}

/// `<Label class="text-white">` + `<Input class="mt-1 …">` in the glass card.
/// The `.glass-card input` rules (`!important`) set the colours: background
/// white/12, white text, border white/20, placeholder white/65. `h-9
/// rounded-md px-3 text-base md:text-sm shadow-xs`, focus `ring-[3px]
/// ring-ring/50`. Password fields get the `bi-eye` / `bi-eye-slash` toggle
/// (`absolute right-3`, white/80 → white on hover).
class _GlassInput extends StatefulWidget {
  const _GlassInput({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  @override
  State<_GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<_GlassInput> {
  late bool _hidden = widget.obscure;
  bool _eyeHover = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = context.isMd ? 14.0 : 16.0;
    final ring = context.colors.primary.withValues(alpha: 0.5); // ring-ring/50

    final field = TextField(
      controller: widget.controller,
      focusNode: _focus,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      onSubmitted: (_) => widget.onSubmitted(),
      style: TextStyle(color: Colors.white, fontSize: fontSize, height: 1.25),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: fontSize, height: 1.25),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.only(left: 12, right: widget.obscure ? 40 : 12),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4), // mt-1
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36, // h-9
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14), // rounded-md
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              if (_focus.hasFocus) BoxShadow(color: ring, spreadRadius: 3),
              ...WebShadow.xs,
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              field,
              if (widget.obscure)
                Positioned(
                  right: 12,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _eyeHover = true),
                    onExit: (_) => setState(() => _eyeHover = false),
                    child: GestureDetector(
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Icon(
                        _hidden ? BootstrapIcons.eye : BootstrapIcons.eye_slash,
                        size: 16,
                        color: _eyeHover ? Colors.white : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// shadcn `<Button>` (`h-9 rounded-md px-4 text-sm font-medium shadow-xs`)
/// with the page's colour classes and the hover colours they end up with.
class _WebButton extends StatefulWidget {
  const _WebButton({
    required this.label,
    required this.background,
    required this.hoverBackground,
    required this.onPressed,
    this.hoverForeground,
    this.horizontalPadding = 16,
    this.expand = false,
  });

  final String label;
  final Color background;
  final Color hoverBackground;
  final Color? hoverForeground;
  final VoidCallback onPressed;
  final double horizontalPadding;
  final bool expand;

  @override
  State<_WebButton> createState() => _WebButtonState();
}

class _WebButtonState extends State<_WebButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = _hover ? (widget.hoverForeground ?? Colors.white) : Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          width: widget.expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          alignment: widget.expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: _hover ? widget.hoverBackground : widget.background,
            borderRadius: BorderRadius.circular(14),
            boxShadow: WebShadow.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label,
                  style: TextStyle(color: fg, fontSize: 14, height: TwLeading.sm, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {required this.onTap, this.dim = false});
  final String text;
  final VoidCallback onTap;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final color = dim ? Colors.white.withValues(alpha: 0.8) : Colors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 14,
                height: TwLeading.sm,
                decoration: TextDecoration.underline,
                decorationColor: color)),
      ),
    );
  }
}

/// `<footer class="py-4 text-white/90 bg-white/10 backdrop-blur-lg border-t
/// border-white/20 text-sm tracking-wide">` — "Powered by ZeroScienceLab —
/// Fall in love with Mathematics & Science".
class _PoweredByFooter extends StatelessWidget {
  const _PoweredByFooter();

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 14, height: TwLeading.sm, letterSpacing: 0.35);
    // `opacity-80` on a `text-white/90` span → white at 72%.
    final dim = base.copyWith(color: Colors.white.withValues(alpha: 0.72));
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 16, bottom: 16 + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          ),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Powered by', style: dim),
              TextSpan(
                  text: ' ZeroScienceLab',
                  style: base.copyWith(color: AppColors.brandOrange, fontWeight: FontWeight.w700)),
              TextSpan(text: ' — Fall in love with Mathematics & Science', style: dim),
            ]),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
