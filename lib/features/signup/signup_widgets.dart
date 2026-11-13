import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/form_fields.dart' show appMenuItemStyle;
import '../../widgets/glass.dart';
import '../../widgets/lucide_icon.dart';

/// Both sign-up routes force light mode on the web
/// (`beforeEnter: () => document.documentElement.classList.remove('dark')`).
final ThemeData signupLightTheme = AppTheme.light();

/// The `login-bg` page used by signup.vue / selfsignup.vue: `login.png`
/// cover image, `bg-black/40 backdrop-blur-[2px]` overlay and the
/// "Powered by ZeroScienceLab" footer.
///
/// [scrollWholePage] = selfsignup.vue (`min-h-screen`: the document
/// scrolls, the background image and overlay scroll with it, and the footer
/// follows the content); otherwise signup.vue (`h-screen`, only the centre
/// area scrolls and the footer is pinned).
class SignupBackground extends StatelessWidget {
  const SignupBackground({
    super.key,
    required this.child,
    required this.footer,
    this.scrollWholePage = false,
  });

  final Widget child;
  final Widget footer;
  final bool scrollWholePage;

  @override
  Widget build(BuildContext context) {
    final background = <Widget>[
      Positioned.fill(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
        ),
      ),
      const Positioned.fill(child: ColoredBox(color: Color(0x66000000))), // bg-black/40
    ];

    final Widget body;
    if (scrollWholePage) {
      // `min-h-screen flex flex-col`: at least one screen tall, the centre
      // area (`flex-1 items-center`) holds the card between the top and the
      // footer. No intrinsic sizing — the selects use LayoutBuilder.
      body = LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                ...background,
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const SizedBox.shrink(), child, footer],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      body = Stack(
        fit: StackFit.expand,
        children: [
          ...background,
          SafeArea(child: Column(children: [Expanded(child: child), footer])),
        ],
      );
    }

    return Theme(
      data: signupLightTheme,
      child: Scaffold(backgroundColor: Colors.black, body: body),
    );
  }
}

/// `<footer class="w-full text-center py-4 text-white/90 bg-white/10
/// backdrop-blur-lg border-t border-white/20 tracking-wide">`.
///
/// [responsive] = signup.vue (two short `leading-5` lines below `sm`, one
/// line above at the inherited 16px — `text-md` is not a Tailwind class);
/// otherwise selfsignup.vue (one `text-sm` line).
class SignupFooter extends StatelessWidget {
  const SignupFooter({super.key, this.responsive = false});
  final bool responsive;

  static final _white90 = Colors.white.withValues(alpha: 0.9);

  @override
  Widget build(BuildContext context) {
    // `opacity-80` on top of `text-white/90`.
    final dimColor = Colors.white.withValues(alpha: 0.72);
    const orange = AppColors.brandOrange; // text-orange-500
    // tracking-wide = 0.025em
    double tracking(double size) => size * 0.025;

    Widget content;
    if (responsive && !context.isSm) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('powered by',
                  style: TextStyle(fontSize: 10, color: dimColor, height: 2, letterSpacing: tracking(10))),
              const SizedBox(width: 4),
              Text('ZeroScienceLab',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: orange,
                    height: 20 / 14,
                    letterSpacing: tracking(14),
                  )),
            ],
          ),
          Text('Fall in love with Mathematics & Science',
              style: TextStyle(fontSize: 10, color: dimColor, height: 2, letterSpacing: tracking(10))),
        ],
      );
    } else {
      final size = responsive ? 16.0 : 14.0;
      content = Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Powered by', style: TextStyle(color: dimColor)),
          const TextSpan(text: ' ZeroScienceLab', style: TextStyle(color: orange, fontWeight: FontWeight.w700)),
          TextSpan(text: ' — Fall in love with Mathematics & Science', style: TextStyle(color: dimColor)),
        ]),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          // 16px inherits the body's 1.5; text-sm is 20px.
          height: responsive ? 1.5 : 20 / 14,
          color: _white90,
          letterSpacing: tracking(size),
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// `<Card class="glass-cards">` with `<CardHeader><CardTitle>Sign Up</CardTitle></CardHeader>`
/// and `<CardContent>` (shadcn card: `py-6 gap-6`, header/content `px-6`).
/// style.css forces the title white, `font-weight: 800` with a white glow.
class SignupGlassCard extends StatelessWidget {
  const SignupGlassCard({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: [Shadow(color: Color(0x40FFFFFF), blurRadius: 12, offset: Offset(0, 2))],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: child),
        ],
      ),
    );
  }
}

/// `<Label class="signininputs">` inside `.glass-cards` (white, `text-sm
/// leading-none font-medium`), with the red `*` as a flex child (`gap-2`).
/// [starSize] 14 = `<span>` (leading-none); 20 = selfsignup's
/// `<div class="text-xl">`, whose 28px line makes the label 28px tall.
class GlassLabel extends StatelessWidget {
  const GlassLabel(this.text, {super.key, this.required = false, this.starSize = 14});
  final String text;
  final bool required;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(text,
              style: const TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w500, color: Colors.white)),
        ),
        if (required) ...[
          const SizedBox(width: 8),
          Text('*',
              style: TextStyle(
                fontSize: starSize,
                height: starSize == 20 ? 28 / 20 : 1,
                fontWeight: FontWeight.w500,
                color: Tw.red500,
              )),
        ],
      ],
    );
  }
}

/// `<FormItem class="grid gap-2">` with a [GlassLabel].
class GlassFormItem extends StatelessWidget {
  const GlassFormItem({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.starSize = 14,
  });

  final String label;
  final Widget child;
  final bool required;
  final double starSize;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassLabel(label, required: required, starSize: starSize),
          const SizedBox(height: 8),
          child,
        ],
      );
}

/// Text style of a shadcn `<Input>` / `<Textarea>` inside `.glass-cards`:
/// white, `text-base md:text-sm`.
TextStyle glassInputTextStyle(BuildContext context) {
  final md = context.isMd;
  return TextStyle(
    color: Colors.white,
    fontSize: md ? 14 : 16,
    height: md ? 20 / 14 : 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// Decoration of `.glass-cards input/textarea`: `bg-white/12 text-white
/// border-white/20` (`!important`, so focus keeps the border and only adds
/// the kit's `ring-[3px] ring-ring/50`), `rounded-md`, `shadow-xs`, `h-9
/// px-3` (textarea: `min-h-16 px-3 py-2`), placeholder `white/65`.
InputDecoration glassInputDecoration(
  BuildContext context, {
  String? hint,
  Widget? suffix,
  bool textarea = false,
  EdgeInsetsGeometry? contentPadding,
}) {
  final style = glassInputTextStyle(context);
  final line = style.fontSize! * style.height!;
  RingInputBorder border({bool focused = false}) => RingInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ringColor: focused ? AppColors.ring.withValues(alpha: 0.5) : Colors.transparent,
        shadows: AppShadows.xs,
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: style.copyWith(color: Colors.white.withValues(alpha: 0.65)),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.12),
    contentPadding: contentPadding ??
        EdgeInsets.symmetric(horizontal: 12, vertical: textarea ? 8 : math.max(0.0, (36 - line) / 2)),
    constraints: textarea ? const BoxConstraints(minHeight: 64) : null,
    border: border(),
    enabledBorder: border(),
    focusedBorder: border(focused: true),
    suffixIcon: suffix,
    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
    counterText: '',
  );
}

/// shadcn `<Input>` / `<Textarea>` inside `.glass-cards`, with the optional
/// eye toggle of signup.vue's password fields (feather eye / eye-off 18px,
/// `text-gray-400 hover:text-primary transition-colors`).
class GlassInput extends StatefulWidget {
  const GlassInput({
    super.key,
    required this.controller,
    this.hint,
    this.password = false,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textarea = false,
    this.fixedTextareaHeight,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.obscured,
    this.onToggleObscured,
  });

  final TextEditingController controller;
  final String? hint;
  final bool password;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// `<Textarea>`: `min-h-16`, grows with the content (`field-sizing-content`).
  final bool textarea;

  /// A textarea with a fixed height (selfsignup's `h-[5px]`, held at the
  /// `min-h-16` = 64px; longer text scrolls).
  final double? fixedTextareaHeight;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;

  /// Controlled show/hide state for [password] fields (the page owns
  /// `showPassword` / `showConfirmPassword`).
  final bool? obscured;
  final VoidCallback? onToggleObscured;

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  bool _eyeHover = false;

  @override
  Widget build(BuildContext context) {
    final obscured = widget.password && (widget.obscured ?? true);
    Widget? suffix;
    if (widget.password) {
      suffix = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _eyeHover = true),
        onExit: (_) => setState(() => _eyeHover = false),
        child: GestureDetector(
          onTap: widget.onToggleObscured,
          child: TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 150),
            tween: ColorTween(end: _eyeHover ? context.colors.primary : Tw.gray400),
            builder: (context, color, _) =>
                FeatherEyeIcon(slashed: !obscured, size: 18, color: color ?? Tw.gray400),
          ),
        ),
      );
    }
    final fixed = widget.textarea && widget.fixedTextareaHeight != null;
    final field = TextField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      obscureText: obscured,
      keyboardType: widget.keyboardType ?? (widget.textarea ? TextInputType.multiline : null),
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textarea ? TextAlignVertical.top : TextAlignVertical.center,
      expands: fixed,
      minLines: fixed ? null : (widget.textarea ? 2 : 1),
      maxLines: widget.textarea ? null : 1,
      style: glassInputTextStyle(context),
      cursorColor: Colors.white,
      decoration: glassInputDecoration(
        context,
        hint: widget.hint,
        suffix: suffix,
        textarea: widget.textarea,
        contentPadding: widget.contentPadding,
      ),
    );
    return fixed ? SizedBox(height: widget.fixedTextareaHeight, child: field) : field;
  }
}

/// The feather `eye` / `eye-off` SVGs of signup.vue's password toggles
/// (24×24 viewBox, `stroke-width="2"`, round caps and joins).
class FeatherEyeIcon extends StatelessWidget {
  const FeatherEyeIcon({super.key, required this.slashed, this.size = 18, required this.color});
  final bool slashed;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _FeatherEyePainter(slashed, color));
}

class _FeatherEyePainter extends CustomPainter {
  _FeatherEyePainter(this.slashed, this.color);
  final bool slashed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (!slashed) {
      // M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z + circle r=3
      final eye = Path()
        ..moveTo(1, 12)
        ..cubicTo(1, 12, 5, 4, 12, 4)
        ..cubicTo(19, 4, 23, 12, 23, 12)
        ..cubicTo(23, 12, 19, 20, 12, 20)
        ..cubicTo(5, 20, 1, 12, 1, 12)
        ..close();
      canvas.drawPath(eye, paint);
      canvas.drawCircle(const Offset(12, 12), 3, paint);
      return;
    }
    final path = Path()
      ..moveTo(17.94, 17.94)
      ..arcToPoint(const Offset(12, 20), radius: const Radius.circular(10.07))
      ..cubicTo(5, 20, 1, 12, 1, 12)
      ..arcToPoint(const Offset(6.06, 6.06), radius: const Radius.circular(18.45))
      ..moveTo(9.9, 4.24)
      ..arcToPoint(const Offset(12, 4), radius: const Radius.circular(9.12))
      ..cubicTo(19, 4, 23, 12, 23, 12)
      ..arcToPoint(const Offset(20.84, 15.19), radius: const Radius.circular(18.5))
      ..moveTo(14.12, 14.12)
      ..arcToPoint(const Offset(9.88, 9.88), radius: const Radius.circular(3), largeArc: true)
      ..moveTo(1, 1)
      ..lineTo(23, 23);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FeatherEyePainter old) => old.slashed != slashed || old.color != color;
}

/// One `<SelectItem :value>` of a [GlassSelect].
class GlassSelectItem<T> {
  const GlassSelectItem(this.value, this.label);
  final T value;
  final String label;
}

/// shadcn `<Select>` inside `.glass-cards`: the trigger gets `bg-white/12
/// text-white border-white/20` (`!important`; the placeholder is `white/60`),
/// the chevron keeps the kit's `text-muted-foreground opacity-50`. The menu
/// is the normal light popover (`position="popper"`, 4px below, at least the
/// trigger's width and as wide as the longest item, `rounded-md border p-1
/// shadow-md`; items highlight `bg-accent`).
class GlassSelect<T> extends StatefulWidget {
  const GlassSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.menuMaxHeight = double.infinity,
  });

  final T? value;
  final List<GlassSelectItem<T>> items;
  final ValueChanged<T> onChanged;
  final String placeholder;

  /// `max-h-60` (240) on signup.vue's `<SelectContent>`; otherwise only the
  /// space left on screen limits the list.
  final double menuMaxHeight;

  @override
  State<GlassSelect<T>> createState() => _GlassSelectState<T>();
}

class _GlassSelectState<T> extends State<GlassSelect<T>> {
  final _menu = MenuController();
  bool _focused = false;

  void _toggle() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    GlassSelectItem<T>? selected;
    for (final it in widget.items) {
      if (it.value == widget.value) selected = it;
    }
    const mutedFg = AppColors.mutedForeground;
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : 220.0;
      final screenW = MediaQuery.sizeOf(context).width;
      final minW = math.max(128.0, width);
      final maxW = math.max(minW, screenW - 16);
      return MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(0, 4),
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(minW, 0)),
          maximumSize: WidgetStatePropertyAll(Size(maxW, widget.menuMaxHeight)),
          backgroundColor: const WidgetStatePropertyAll(AppColors.popover),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(2),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.5)),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: const BorderSide(color: AppColors.border),
          )),
        ),
        menuChildren: [
          for (final it in widget.items)
            MenuItemButton(
              onPressed: () => widget.onChanged(it.value),
              style: appMenuItemStyle(context),
              overflowAxis: Axis.vertical,
              child: Row(
                children: [
                  // signup.vue's items are `truncate`.
                  Expanded(child: Text(it.label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 10),
                  SizedBox.square(
                    dimension: 14,
                    child: it.value == widget.value
                        ? const OverflowBox(
                            maxWidth: 16,
                            maxHeight: 16,
                            child: LucideIcon(Lucide.check, size: 16, color: mutedFg),
                          )
                        : null,
                  ),
                ],
              ),
            ),
        ],
        builder: (context, controller, _) => FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
              _toggle();
              return null;
            }),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  ...AppShadows.xs,
                  if (_focused) BoxShadow(color: AppColors.ring.withValues(alpha: 0.5), spreadRadius: 3),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected?.label ?? widget.placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: selected == null ? Colors.white.withValues(alpha: 0.6) : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  LucideIcon(Lucide.chevronDown, size: 16, color: mutedFg.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// `<span class="w-4 h-4 border-2 border-white border-t-transparent
/// rounded-full animate-spin">`: a 16px ring missing its top quarter.
class BorderSpinner extends StatefulWidget {
  const BorderSpinner({super.key, this.size = 16, this.color = Colors.white});
  final double size;
  final Color color;

  @override
  State<BorderSpinner> createState() => _BorderSpinnerState();
}

class _BorderSpinnerState extends State<BorderSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
        turns: _c,
        child: CustomPaint(size: Size.square(widget.size), painter: _RingPainter(widget.color)),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    // The transparent top border spans the -135°…-45° quarter.
    canvas.drawArc(
      rect,
      -math.pi / 4,
      math.pi * 1.5,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}

/// CSS grid with equal columns (`grid grid-cols-N gap-4`): chunks
/// [children] into rows of [columns].
class SignupGrid extends StatelessWidget {
  const SignupGrid({super.key, required this.columns, required this.children, this.gap = 16});
  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      final cells = <Widget>[];
      for (var j = 0; j < columns; j++) {
        if (j > 0) cells.add(SizedBox(width: gap));
        final index = i + j;
        cells.add(Expanded(child: index < children.length ? children[index] : const SizedBox()));
      }
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}
