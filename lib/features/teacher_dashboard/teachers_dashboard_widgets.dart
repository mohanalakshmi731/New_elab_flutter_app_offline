import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/web_style.dart';

/// Building blocks of the teacher dashboard (`teachersdashboardpage.vue`),
/// also used by the student dashboard layout.
///
/// Notes from the web build: `font-urbanist` and `animate-slide-up` are not
/// defined anywhere (no Tailwind utility, no CSS), so headings use the app
/// font and the page has no entrance animation; `shadow-*` are the subtle
/// style.css shadows (coloured `shadow-<color>` modifiers have no effect).

/// Tailwind / arbitrary colours used by the page that `Tw` does not define.
class TdTw {
  TdTw._();
  static const sky600 = Color(0xFF0284C7);
  static const cyan50 = Color(0xFFECFEFF);
  static const cyan100 = Color(0xFFCFFAFE);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan600 = Color(0xFF0891B2);
  static const cyan900 = Color(0xFF164E63);
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald800 = Color(0xFF065F46);
  static const emerald900 = Color(0xFF064E3B);
  static const blue900 = Color(0xFF1E3A8A);
  static const purple400 = Color(0xFFC084FC);
  static const amber300 = Color(0xFFFCD34D);

  /// `dark:bg-[#1e1b4b]` cards.
  static const deepIndigo = Color(0xFF1E1B4B);

  /// `dark:hover:bg-[#25215c]`
  static const deepIndigoHover = Color(0xFF25215C);

  /// `from-[#0f0c29]`
  static const night = Color(0xFF0F0C29);
}

/// `font-black` headings (`font-urbanist` resolves to nothing on the web).
TextStyle blackHeading({required double size, Color? color, double? height, double? letterSpacing}) =>
    TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: color, height: height, letterSpacing: letterSpacing);

/// Tracks hover for the `hover:` variants.
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({super.key, required this.builder, this.cursor = MouseCursor.defer});
  final Widget Function(BuildContext context, bool hover) builder;
  final MouseCursor cursor;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.cursor,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: widget.builder(context, _hover),
      );
}

// ── banner skeleton ─────────────────────────────────────────────────────────

/// `.banner-skeleton` — shimmering placeholder while the banner loads.
class BannerSkeleton extends StatefulWidget {
  const BannerSkeleton({super.key});

  @override
  State<BannerSkeleton> createState() => _BannerSkeletonState();
}

class _BannerSkeletonState extends State<BannerSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // `@media (max-width: 640px)`
    final mobile = context.screenWidth <= 640;
    final (base, light) = dark
        ? (Tw.slate800, const Color(0xFF273549))
        : (Tw.slate200, Tw.slate100);

    Widget block(double w, double h, double r, double alpha) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(r),
          ),
        );

    final left = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        block(130, 22, 999, 0.08),
        const SizedBox(height: 10),
        block(mobile ? 200 : 280, 36, 10, 0.08),
        const SizedBox(height: 10),
        block(170, 18, 8, 0.06),
      ],
    );
    final btn = block(120, 44, 999, 0.08);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: EdgeInsets.all(mobile ? 20 : 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [base, light, base],
            stops: const [0.25, 0.5, 0.75],
            tileMode: TileMode.repeated,
            transform: _Slide(_c.value),
          ),
        ),
        child: child,
      ),
      // `flex items-center justify-between`; on phones a column with
      // `gap: 16px`, still centred.
      child: mobile
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [left, const SizedBox(height: 16), btn],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Flexible(child: left), btn],
            ),
    );
  }
}

/// `background-size: 200% 100%` (repeating) animated from
/// `background-position: 200% 0` to `-200% 0`: the tile moves from −2W to
/// +2W, so the highlight sweeps left → right twice per cycle.
class _Slide extends GradientTransform {
  const _Slide(this.t);
  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final w = bounds.width;
    final dx = -2 * w + 4 * w * t;
    return Matrix4.identity()
      ..translateByDouble(bounds.left + dx, 0, 0, 1)
      ..scaleByDouble(2, 1, 1, 1)
      ..translateByDouble(-bounds.left, 0, 0, 1);
  }
}

// ── schedule banners ───────────────────────────────────────────────────────

/// A blurred decorative circle (`rounded-full blur-3xl` / `blur-2xl`; CSS
/// `blur(N)` is a standard deviation of N).
class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.sigma});
  final double size;
  final Color color;
  final double sigma;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      );
}

/// The live / up-next class card: gradient, glows, chip, title, batch line,
/// camera circle and the white action button.
class ScheduleBannerCard extends StatelessWidget {
  const ScheduleBannerCard({
    super.key,
    required this.gradient,
    required this.glowColor,
    required this.chip,
    required this.title,
    required this.batchName,
    required this.className,
    required this.subtitleColor,
    required this.buttonLabel,
    required this.buttonTextColor,
    required this.buttonHoverColor,
    required this.onPressed,
    this.shadow = WebShadow.lg,
    this.circleGap = 12,
    this.titleLetterSpacing,
    this.subtitleIconSize,
  });

  final Gradient gradient;

  /// The batch line's `bi-people-fill`: `text-base` (teacher) or inherited
  /// `text-sm md:text-base` (student, null).
  final double? subtitleIconSize;

  /// `shadow-lg` (teacher) / `shadow-xl` (student).
  final List<BoxShadow> shadow;

  /// The second (bottom-left) glow.
  final Color glowColor;
  final Widget chip;
  final String title;
  final String batchName;
  final String? className;
  final Color subtitleColor;
  final String buttonLabel;
  final Color buttonTextColor;
  final Color buttonHoverColor;
  final VoidCallback onPressed;

  /// Space between the camera circle and the button (`gap-3` / `mb-4`).
  final double circleGap;

  /// `tracking-tight` (em) on the student page.
  final double? titleLetterSpacing;

  @override
  Widget build(BuildContext context) {
    final md = context.isMd;
    final inner = md ? 32.0 : 24.0;
    final titleSize = md ? 36.0 : 30.0;
    final subStyle = TextStyle(
        fontSize: md ? 16 : 14,
        height: md ? TwLeading.base : TwLeading.sm,
        fontWeight: FontWeight.w500,
        color: subtitleColor);

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chip,
        // chip `mb-3` + title `mt-2`
        const SizedBox(height: 12 + 8),
        Text(
          title,
          style: blackHeading(
            size: titleSize,
            color: Colors.white,
            height: md ? TwLeading.x4l : TwLeading.x3l,
            letterSpacing: titleLetterSpacing == null ? null : titleLetterSpacing! * titleSize,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Icon(BootstrapIcons.people_fill, size: subtitleIconSize ?? (md ? 16 : 14), color: subtitleColor),
            Text(batchName, style: subStyle),
            if (className != null) Text('• $className', style: subStyle),
          ],
        ),
      ],
    );

    final button = BannerActionButton(
      label: buttonLabel,
      textColor: buttonTextColor,
      hoverColor: buttonHoverColor,
      expand: !md,
      onPressed: onPressed,
    );

    final actions = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (md) ...[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(BootstrapIcons.camera_video_fill, size: 24, color: Colors.white),
          ),
          SizedBox(height: circleGap),
        ],
        button,
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        // passthrough: fills (and centres the content) when the grid row
        // stretches the card, sizes to the content otherwise.
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: _Glow(size: 192, color: Colors.white.withValues(alpha: 0.1), sigma: 64),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: _Glow(size: 128, color: glowColor, sigma: 40),
            ),
            // Card `py-6` + CardContent `p-6 md:p-8`.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: inner, vertical: 24 + inner),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: md
                    ? Row(
                        children: [
                          Expanded(child: Align(alignment: Alignment.centerLeft, child: info)),
                          const SizedBox(width: 24),
                          actions,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [info, const SizedBox(height: 24), actions],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white `JOIN NOW` / `GO LIVE` button (`font-black text-lg py-3 px-8
/// rounded-xl shadow-xl hover:scale-105 active:scale-95`).
class BannerActionButton extends StatefulWidget {
  const BannerActionButton({
    super.key,
    required this.label,
    required this.textColor,
    required this.hoverColor,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final Color textColor;
  final Color hoverColor;
  final VoidCallback onPressed;
  final bool expand;

  @override
  State<BannerActionButton> createState() => _BannerActionButtonState();
}

class _BannerActionButtonState extends State<BannerActionButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? 0.95 : (_hover ? 1.05 : 1.0);
    final row = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.label,
            style: TextStyle(
                fontSize: 18, height: TwLeading.lg, fontWeight: FontWeight.w900, color: widget.textColor)),
        const SizedBox(width: 8),
        Icon(BootstrapIcons.arrow_right, size: 20, color: widget.textColor),
      ],
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: _hover ? widget.hoverColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: WebShadow.xl,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// `animate-pulse` dot of the LIVE NOW chip.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 8});
  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
        ]).animate(CurvedAnimation(parent: _c, curve: const Cubic(0.4, 0, 0.6, 1))),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      );
}

/// The chip above the banner title (`bg-white/20 rounded-lg px-3 py-1.5
/// border-white/10 font-black uppercase`). The teacher page adds
/// `backdrop-blur-md shadow-sm` ([frosted]) and `md:text-xs` ([mdLarger]).
class BannerChip extends StatelessWidget {
  const BannerChip({
    super.key,
    required this.leading,
    required this.text,
    this.frosted = true,
    this.mdLarger = true,
  });
  final Widget leading;
  final String text;
  final bool frosted;
  final bool mdLarger;

  @override
  Widget build(BuildContext context) {
    final size = mdLarger && context.isMd ? 12.0 : 10.0;
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                  fontSize: size,
                  height: size == 12 ? TwLeading.xs : TwLeading.inherit,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (frosted) {
      chip = DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: WebShadow.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: chip),
        ),
      );
    }
    return chip;
  }
}

// ── empty banner (dashed border) ──────────────────────────────────────────

/// CSS `border-style: dashed` (Chromium: dashes and gaps of 3× the width).
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({required this.color, this.radius = 24, this.strokeWidth = 2});
  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final dash = 3 * strokeWidth;
    final gap = 3 * strokeWidth;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}

// ── metric cards / panels ─────────────────────────────────────────────────

/// `bg-white dark:bg-[#1e1b4b] p-5 rounded-2xl border shadow-sm` metric card
/// with its `hover:border-*-500/50`.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.hoverBorder,
    required this.value,
    required this.caption,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color hoverBorder;
  final String value;
  final Widget caption;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final labelSize = context.isMd ? 12.0 : 10.0;
    return HoverBuilder(
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? TdTw.deepIndigo : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hover ? hoverBorder : (dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate200),
          ),
          boxShadow: WebShadow.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: labelSize,
                      height: labelSize == 12 ? TwLeading.xs : TwLeading.inherit,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.05 * labelSize, // tracking-wider
                      color: dark ? Tw.slate400 : Tw.slate500,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 30,
                    height: TwLeading.x3l,
                    fontWeight: FontWeight.w900,
                    color: dark ? Colors.white : Tw.slate900)),
            const SizedBox(height: 4),
            caption,
          ],
        ),
      ),
    );
  }
}

/// Section heading of the bottom row (`font-black text-lg md:text-xl flex
/// items-center gap-2 mb-4`).
class PanelHeading extends StatelessWidget {
  const PanelHeading({super.key, required this.icon, required this.iconColor, required this.text, this.iconSize});
  final IconData icon;
  final Color iconColor;
  final String text;

  /// The teacher page pins the icon to `text-lg`; the student page lets it
  /// inherit the heading size.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final size = context.isMd ? 20.0 : 18.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: iconSize ?? size, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                // text-lg / text-xl both have a 28 px line height.
                style: blackHeading(size: size, height: 28 / size, color: dark ? Colors.white : Tw.slate900)),
          ),
        ],
      ),
    );
  }
}

/// The two static "Teacher Learning" cards.
const learningCards = [
  (
    imageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&q=80&w=600',
    badge: 'Pedagogy',
    badgeColor: Tw.indigo500,
    title: 'Visualizing Abstract Algebra',
    hoverBorder: Color(0x806366F1), // indigo-500/50
  ),
  (
    imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&q=80&w=600',
    badge: 'Wellbeing',
    badgeColor: Tw.emerald600,
    title: 'Mental Health Sessions',
    hoverBorder: Color(0x8010B981), // emerald-500/50
  ),
];

/// "Teacher Learning" row: `flex gap-4 overflow-x-auto pb-2 items-stretch`
/// of `min-w-[240px] md:min-w-[280px]` cards. A card is as wide as its
/// content (one-line title + `p-4`) but at least the min width, and the
/// cards shrink (not below the min) when the row is too narrow — CSS flex
/// sizing. With [stretch] the cards fill the row height (the desktop grid
/// row); otherwise they are 160 px high.
class LearningCardsRow extends StatelessWidget {
  const LearningCardsRow({
    super.key,
    required this.availableWidth,
    this.stretch = false,
    this.inlineBadge = false,
  });

  final double availableWidth;
  final bool stretch;
  final bool inlineBadge;

  @override
  Widget build(BuildContext context) {
    final md = context.isMd;
    final minW = md ? 280.0 : 240.0;
    final titleStyle = DefaultTextStyle.of(context)
        .style
        .merge(TextStyle(fontSize: md ? 18 : 16, fontWeight: FontWeight.w700, height: 1.25));
    final textScaler = MediaQuery.textScalerOf(context);
    final basis = <double>[];
    for (final c in learningCards) {
      final tp = TextPainter(
          text: TextSpan(text: c.title, style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaler: textScaler)
        ..layout();
      basis.add(tp.width.ceilToDouble() + 32 + 2);
      tp.dispose();
    }
    final widths = [for (final b in basis) math.max(b, minW)];
    final overflow = widths.fold<double>(0, (s, w) => s + w) + 16 * (widths.length - 1) - availableWidth;
    if (overflow > 0) {
      // flex-shrink weighted by the base size, never below min-width.
      final shrinkable = [for (var i = 0; i < widths.length; i++) if (widths[i] > minW) i];
      final total = shrinkable.fold<double>(0, (s, i) => s + basis[i]);
      for (final i in shrinkable) {
        widths[i] = math.max(minW, widths[i] - overflow * basis[i] / total);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: [
          for (final (i, c) in learningCards.indexed) ...[
            if (i > 0) const SizedBox(width: 16),
            LearningCard(
              imageUrl: c.imageUrl,
              badge: c.badge,
              badgeColor: c.badgeColor,
              title: c.title,
              hoverBorder: c.hoverBorder,
              width: widths[i],
              stretch: stretch,
              inlineBadge: inlineBadge,
            ),
          ],
        ],
      ),
    );
  }
}

/// A "Teacher Learning" card: image (`opacity-60`, `group-hover:scale-110
/// opacity-80`, 700 ms), night gradient, badge and title.
class LearningCard extends StatelessWidget {
  const LearningCard({
    super.key,
    required this.imageUrl,
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.hoverBorder,
    required this.width,
    this.stretch = false,
    this.inlineBadge = false,
  });

  final String imageUrl;
  final String badge;
  final Color badgeColor;
  final String title;
  final Color hoverBorder;
  final double width;

  /// Fill the (tight) height given by a stretched row instead of 160 px.
  final bool stretch;

  /// The student page's unregistered `<Badge>` renders as an inline element
  /// (no `inline-block mb-2`): it sits in a 24 px line box and the title
  /// follows 8 px below that line.
  final bool inlineBadge;

  @override
  Widget build(BuildContext context) {
    final md = context.isMd;
    final badgeBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: WebShadow.md,
      ),
      child: Text(badge.toUpperCase(),
          style: TextStyle(
              fontSize: 9,
              height: inlineBadge ? 1.25 : TwLeading.inherit,
              fontWeight: FontWeight.w900,
              color: Colors.white)),
    );
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        // `min-h-[160px]` — the content is shorter, so 160 unless stretched.
        height: stretch ? null : 160,
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          color: TdTw.deepIndigo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hover ? hoverBorder : Colors.white.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedScale(
                  scale: hover ? 1.1 : 1,
                  duration: const Duration(milliseconds: 700),
                  child: AnimatedOpacity(
                    opacity: hover ? 0.8 : 0.6,
                    duration: const Duration(milliseconds: 700),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [TdTw.night, TdTw.night.withValues(alpha: 0.6), TdTw.night.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
              // Card `py-6` + CardContent `p-4 mt-auto`.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16 + 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (inlineBadge)
                        SizedBox(height: 24, child: Align(alignment: Alignment.centerLeft, child: badgeBox))
                      else
                        badgeBox,
                      // `mb-2` + `mt-2` (teacher) / `mt-2` (student).
                      SizedBox(height: inlineBadge ? 8 : 16),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: md ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: Colors.white,
                          // drop-shadow-md: `0 3px 3px rgb(0 0 0 / .12)`. The CSS
                          // blur is a standard deviation (3); Flutter's sigma is
                          // blurRadius × 0.57735 + 0.5, so blurRadius ≈ 4.33.
                          shadows: const [Shadow(color: Color(0x1F000000), blurRadius: 4.33, offset: Offset(0, 3))],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
