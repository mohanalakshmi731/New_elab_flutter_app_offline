import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/web_content_view.dart';
import '../mathzoro/mz_html_text.dart' show parseHtmlSpans;

/// Small building blocks shared by `/questions` and `/newquestions`.

/// `<div v-html="html">` as rich text (light HTML subset: b/i/u, sup/sub,
/// br/p/div/li, img). [maxLines] + no soft wrap reproduce the table cells'
/// `whitespace-nowrap line-clamp-N` (each line clipped, never wrapped).
class HtmlText extends StatelessWidget {
  const HtmlText(this.html, {super.key, required this.style, this.maxLines, this.softWrap = true, this.prefix});

  final String? html;
  final TextStyle style;
  final int? maxLines;
  final bool softWrap;

  /// Inline content before the HTML (`<strong>Question:</strong> <span v-html>`).
  final InlineSpan? prefix;

  @override
  Widget build(BuildContext context) {
    final source = html ?? '';
    if (source.isEmpty && prefix == null) return const SizedBox.shrink();
    return Text.rich(
      TextSpan(style: style, children: [?prefix, ...parseHtmlSpans(source, style)]),
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.clip,
    );
  }
}

/// `<img :src class="max-h-… rounded-… border shadow">` — keeps the image's
/// own size up to [maxHeight] (and the available width).
class QuestionImage extends StatelessWidget {
  const QuestionImage({
    super.key,
    required this.url,
    required this.maxHeight,
    this.radius = 16,
    this.borderColor,
    this.shadow = true,
    this.fullWidth = false,
  });

  final String url;
  final double maxHeight;
  final double radius;
  final Color? borderColor;
  final bool shadow;

  /// `w-full object-contain`
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = borderColor ?? (dark ? AppColors.darkBorder : AppColors.border);
    Widget img = Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.broken_image_outlined, size: 24, color: dark ? Tw.slate500 : Tw.slate400),
      ),
    );
    img = ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight), child: img);
    final box = Container(
      width: fullWidth ? double.infinity : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        // `shadow` / `shadow-sm` (identical in this theme).
        boxShadow: shadow ? AppShadows.sm : null,
      ),
      child: img,
    );
    return Align(alignment: fullWidth ? Alignment.center : Alignment.centerLeft, child: box);
  }
}

/// The preview dialogs' video block (`videoData.type`): `iframe` →
/// `aspect-video` embed, `video` → `<video controls>`, `link` → "Open Video"
/// (only `questionslist.vue` renders that fallback: [showLinkFallback]).
class QuestionVideoView extends StatelessWidget {
  const QuestionVideoView({
    super.key,
    required this.type,
    required this.src,
    required this.radius,
    required this.videoMaxHeight,
    this.borderColor,
    this.showLinkFallback = false,
  });

  final String type;
  final String src;
  final double radius;
  final double videoMaxHeight;
  final Color? borderColor;
  final bool showLinkFallback;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = borderColor ?? (dark ? AppColors.darkBorder : AppColors.border);
    BoxDecoration deco() => BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border),
          boxShadow: AppShadows.sm,
        );
    if (type == 'iframe') {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: deco(),
        child: AspectRatio(aspectRatio: 16 / 9, child: WebContentView(url: src)),
      );
    }
    if (type == 'video') {
      final esc = const HtmlEscape(HtmlEscapeMode.attribute).convert(src);
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: deco(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: videoMaxHeight),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: WebContentView(
              html: '<video controls style="width:100%;height:auto;max-height:${videoMaxHeight.toInt()}px">'
                  '<source src="$esc" type="video/mp4"></video>',
            ),
          ),
        ),
      );
    }
    if (!showLinkFallback) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkMuted : AppColors.muted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => openExternal(src),
          child: const Text(
            'Open Video',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Tw.blue600,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Tw.blue600,
            ),
          ),
        ),
      ),
    );
  }
}

/// A bare icon `<button>` that grows on hover (`hover:scale-110 transition`);
/// inside a table its `bi` icon is 18px (style.css `table .bi`).
class HoverScaleIcon extends StatefulWidget {
  const HoverScaleIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 18,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final String? tooltip;

  @override
  State<HoverScaleIcon> createState() => _HoverScaleIconState();
}

class _HoverScaleIconState extends State<HoverScaleIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    Widget w = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.1 : 1,
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.4, 0, 0.2, 1),
          child: Icon(widget.icon, size: widget.size, color: widget.color),
        ),
      ),
    );
    if (widget.tooltip != null) w = Tooltip(message: widget.tooltip!, child: w);
    return w;
  }
}

/// shadcn `<Switch>`: `h-[1.15rem] w-8`, `bg-primary` when checked,
/// `bg-input` otherwise, `size-4` thumb.
class ShadSwitch extends StatelessWidget {
  const ShadSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final scheme = context.colors;
    final track = value
        ? scheme.primary
        : dark
            ? AppColors.darkBorder.withValues(alpha: 0.8)
            : AppColors.border;
    final thumb = dark ? (value ? scheme.onPrimary : AppColors.darkForeground) : Colors.white;
    return Semantics(
      toggled: value,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 18.4,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(99),
              boxShadow: AppShadows.xs,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: thumb, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `window.alert(message)`.
Future<void> showAlertMessage(BuildContext context, String message) => showAppDialog<void>(
      context,
      builder: (ctx) => AppDialogFrame(
        description: message,
        maxWidth: 384,
        actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
      ),
    );

/// `toast.success(message, { style: { background: 'red', color: '#ffffff' } })`
/// — the red "deleted" toast of `questionslist.vue` ([AppToast.success] is
/// always green).
void showRedSuccessToast(String message) {
  const red = Color(0xFFFF0000);
  toastification.show(
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    primaryColor: red,
    // fillColored: `backgroundColor` is the text colour (see AppToast).
    backgroundColor: Colors.white,
    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
    title: Text(
      message,
      style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    ),
    alignment: Alignment.bottomRight,
    autoCloseDuration: const Duration(seconds: 4),
    showProgressBar: false,
    dragToClose: true,
    closeOnClick: true,
  );
}

/// Which `<path>` the Tailwind-docs spinner SVG draws over its faint ring.
enum TwSpinnerShape {
  /// `questionslist.vue`: `M4 12a8 8 0 018-8v4l3-3-3-3v4a10 10 0 00-10 10h2z`.
  arrow,

  /// `newquestions.vue`: `M4 12a8 8 0 018-8v8z` (a quarter wedge).
  wedge,
}

/// The `animate-spin` SVG spinner (24×24 view box): a `circle` ring (r 10,
/// stroke 4) at `opacity-25` under a filled `path` at `opacity-75`, in
/// `currentColor`, one turn a second.
class TwSpinner extends StatefulWidget {
  const TwSpinner({super.key, this.size = 16, this.color, this.shape = TwSpinnerShape.wedge});

  final double size;

  /// `currentColor`; defaults to the ambient icon / text colour.
  final Color? color;
  final TwSpinnerShape shape;

  @override
  State<TwSpinner> createState() => _TwSpinnerState();
}

class _TwSpinnerState extends State<TwSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        context.colors.onSurface;
    return RotationTransition(
      turns: _c,
      child: CustomPaint(size: Size.square(widget.size), painter: _TwSpinnerPainter(color, widget.shape)),
    );
  }
}

class _TwSpinnerPainter extends CustomPainter {
  _TwSpinnerPainter(this.color, this.shape);
  final Color color;
  final TwSpinnerShape shape;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawCircle(
      const Offset(12, 12),
      10,
      Paint()
        ..color = color.withValues(alpha: color.a * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    final path = Path()
      ..moveTo(4, 12)
      ..arcToPoint(const Offset(12, 4), radius: const Radius.circular(8));
    if (shape == TwSpinnerShape.wedge) {
      path.lineTo(12, 12);
    } else {
      path
        ..lineTo(12, 8)
        ..lineTo(15, 5)
        ..lineTo(12, 2)
        ..lineTo(12, 6)
        ..arcToPoint(const Offset(2, 16), radius: const Radius.circular(10), clockwise: false)
        ..lineTo(4, 16);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: color.a * 0.75));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TwSpinnerPainter old) => old.color != color || old.shape != shape;
}

/// shadcn `<Input type="file">`: `h-9 rounded-md border border-input px-3
/// shadow-xs bg-transparent dark:bg-input/30`, the file button
/// (`file:text-sm file:font-medium file:text-foreground`, no border or
/// background, preflight's `margin-inline-end: 4px`) then the chosen file
/// name ("No file chosen") in the input's own text size ([fontSize]; default
/// `text-base md:text-sm`). A click anywhere opens the picker.
class ShadFileInput extends StatelessWidget {
  const ShadFileInput({super.key, required this.onPick, this.fileName, this.fontSize});

  final VoidCallback onPick;
  final String? fileName;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = context.fgColor;
    final size = fontSize ?? (context.isMd ? 14.0 : 16.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPick,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: dark ? context.inputColor.withValues(alpha: 0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: context.inputColor),
            boxShadow: AppShadows.xs,
          ),
          child: Row(
            children: [
              Text(
                'Choose File',
                style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: fg),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  fileName ?? 'No file chosen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: size, height: twLineHeight(size) / size, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tailwind's line height (px) for `text-xs` / `text-sm` / `text-base` /
/// `text-lg` / `text-xl` / `text-2xl` / `text-3xl` / `text-4xl`.
double twLineHeight(double fontSize) => switch (fontSize) {
      12 => 16,
      14 => 20,
      16 => 24,
      18 => 28,
      20 => 28,
      24 => 32,
      30 => 36,
      36 => 40,
      _ => fontSize * 1.5,
    };
