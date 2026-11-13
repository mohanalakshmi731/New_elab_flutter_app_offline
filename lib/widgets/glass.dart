import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// CSS `saturate(180%)` as a colour matrix (Filter Effects spec).
const _saturate180 = ColorFilter.matrix(<double>[
  1.6296, -0.5720, -0.0576, 0, 0, //
  -0.1704, 1.2280, -0.0576, 0, 0, //
  -0.1704, -0.5720, 1.7424, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// `.glass-card` from style.css on a shadcn `<Card>` (`rounded-xl`):
/// `rgba(255,255,255,.08)`, `backdrop-filter: blur(20px) saturate(180%)`,
/// `border: 1px solid rgba(255,255,255,.15)`,
/// `box-shadow: 0 8px 32px rgba(0,0,0,.35)`.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = AppTheme.radiusXl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [cssShadow(0, 8, 32, 0, const Color(0x59000000))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.compose(outer: _saturate180, inner: ImageFilter.blur(sigmaX: 20, sigmaY: 20)),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// `<Label class="text-white">` + `<Input class="mt-1 …">` inside a glass
/// card. style.css forces `.glass-card input` to `rgba(255,255,255,.12)`,
/// white text, a `rgba(255,255,255,.2)` border and a `.65` placeholder
/// (`!important`, so the template's `bg-white/20 …` classes lose). Password
/// fields get the `bi-eye` / `bi-eye-slash` toggle (`right-3 text-white/80
/// hover:text-white`).
class GlassTextField extends StatefulWidget {
  const GlassTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onSubmitted,
    this.autofillHints,
    this.textInputAction,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  late bool _hidden = widget.obscure;
  bool _eyeHover = false;

  @override
  Widget build(BuildContext context) {
    final md = context.isMd;
    final style = TextStyle(
      color: Colors.white,
      fontSize: md ? 14 : 16,
      height: md ? 20 / 14 : 1.5,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final lineHeight = style.fontSize! * style.height!;
    RingInputBorder border({bool focused = false}) => RingInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ringColor: focused ? AppColors.ring.withValues(alpha: 0.5) : Colors.transparent,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1)),
        const SizedBox(height: 4),
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          style: style,
          cursorColor: Colors.white,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: style.copyWith(color: Colors.white.withValues(alpha: 0.65)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.12),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: (36 - lineHeight) / 2),
            border: border(),
            enabledBorder: border(),
            focusedBorder: border(focused: true),
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
            suffixIcon: widget.obscure
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _eyeHover = true),
                    onExit: (_) => setState(() => _eyeHover = false),
                    child: GestureDetector(
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Icon(
                        _hidden ? BootstrapIcons.eye : BootstrapIcons.eye_slash,
                        color: Colors.white.withValues(alpha: _eyeHover ? 1 : 0.8),
                        size: 16,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
