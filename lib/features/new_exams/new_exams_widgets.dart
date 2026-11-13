part of 'new_exams_page.dart';

/// `statusPillClass(status)` → (background, text).
(Color, Color) _statusPillColors(BuildContext context, Object? status) => switch (status) {
      'SCHEDULED' => (Tw.blue100, Tw.blue800),
      'ONGOING' => (Tw.emerald100, Tw.emerald800),
      'COMPLETED' => (Tw.slate100, Tw.slate600),
      'DRAFT' => (Tw.amber100, Tw.amber800),
      'ARCHIVED' => (Tw.orange100, Tw.orange800),
      _ => (context.exMuted, context.exMutedFg),
    };

/// `examCardBar(status)` — the 3px bar on top of a card.
Color _examCardBar(BuildContext context, Object? status) => switch (status) {
      'DRAFT' => Tw.amber400,
      'SCHEDULED' => Tw.blue500,
      'ONGOING' => Tw.emerald500,
      'COMPLETED' => Tw.slate400,
      'ARCHIVED' => Tw.orange400,
      _ => context.exMuted,
    };

/// A rounded pill (`text-[10px] font-bold px-2 py-0.5 rounded-full`).
class _Pill extends StatelessWidget {
  const _Pill(
    this.text, {
    required this.bg,
    required this.fg,
    this.upper = false,
    this.tracking = false,
    this.weight = FontWeight.w700,
  });
  final String text;
  final Color bg;
  final Color fg;

  /// `uppercase`
  final bool upper;

  /// `tracking-wide`
  final bool tracking;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(
          upper ? text.toUpperCase() : text,
          style: TextStyle(fontSize: 10, height: 1.5, fontWeight: weight, color: fg, letterSpacing: tracking ? 0.25 : 0),
        ),
      );
}

/// `statusPillClass` pill: `uppercase tracking-wide` on the cards, plain
/// `uppercase` in the preview dialog.
class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status, {this.tracking = true});
  final Object? status;
  final bool tracking;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _statusPillColors(context, status);
    return _Pill(display(status), bg: bg, fg: fg, upper: true, tracking: tracking);
  }
}

/// `<Button variant="outline" size="sm" class="gap-2">` + the arrow-left svg
/// (the kit's `size-4` rule makes it 16px; `has-[>svg]:px-2.5`).
class _BackButton extends StatelessWidget {
  const _BackButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
        variant: AppButtonVariant.outline,
        size: AppButtonSize.sm,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(BootstrapIcons.arrow_left, size: 16),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      );
}

/// The breadcrumb + title + back button header of the inner views.
class _ViewHeader extends StatelessWidget {
  const _ViewHeader({
    required this.crumbs,
    required this.current,
    required this.title,
    required this.subtitle,
    required this.backLabel,
    required this.onBack,
  });

  /// Clickable crumbs before [current].
  final List<(String, VoidCallback)> crumbs;
  final String current;
  final String title;
  final String subtitle;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final muted = context.exMutedFg;
    // `flex items-center gap-1.5 text-xs text-muted-foreground mb-1`
    final nav = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        for (final (label, onTap) in crumbs) ...[
          _CrumbButton(label: label, onTap: onTap),
          LucideIcon(Lucide.chevronRight, size: 12, strokeWidth: 2.5, color: muted),
        ],
        Text(current, style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: context.exFg)),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nav,
            const SizedBox(height: 4),
            // `text-2xl font-bold tracking-tight`
            Text(title,
                style: const TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
          ],
        ),
        _BackButton(label: backLabel, onPressed: onBack),
      ],
    );
  }
}

/// `hover:text-foreground font-semibold transition-colors`
class _CrumbButton extends StatefulWidget {
  const _CrumbButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_CrumbButton> createState() => _CrumbButtonState();
}

class _CrumbButtonState extends State<_CrumbButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: _hover ? context.exFg : context.exMutedFg,
            ),
            child: Text(widget.label),
          ),
        ),
      );
}

/// `rounded-2xl bg-muted border` icon box + title + text (+ optional
/// action) — the empty states.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.text, this.action});
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.exMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.exBorder),
              ),
              child: Icon(BootstrapIcons.file_earmark_text, size: 32, color: context.exMutedFg),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.625, color: context.exMutedFg),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      );
}

/// `Create Exam` — `<Button class="gap-2 bg-cyan-500 hover:bg-cyan-400
/// text-slate-900 font-bold shadow-lg shadow-cyan-200">` (the coloured
/// shadow modifier has no effect in this theme; the empty state's copy has
/// no `shadow-lg`, so it keeps the kit's `shadow-xs`).
class _CreateExamButton extends StatelessWidget {
  const _CreateExamButton({required this.onPressed, this.shadow = true});
  final VoidCallback onPressed;
  final bool shadow;

  @override
  Widget build(BuildContext context) => AppButton(
        backgroundColor: Tw.cyan500,
        hoverBackgroundColor: Tw.cyan400,
        foregroundColor: Tw.slate900,
        fontWeight: FontWeight.w700,
        shadow: shadow ? AppShadows.lg : null,
        // `has-[>svg]:px-3`
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onPressed: onPressed,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.plus_lg, size: 16),
            SizedBox(width: 8),
            Text('Create Exam'),
          ],
        ),
      );
}

/// A plain `<button>` whose background changes on hover (`transition-colors`).
class _HoverButton extends StatefulWidget {
  const _HoverButton({
    required this.bg,
    required this.hoverBg,
    required this.onTap,
    required this.child,
    this.disabledCursor = SystemMouseCursors.basic,
  });
  final Color bg;
  final Color hoverBg;
  final VoidCallback? onTap;
  final Widget child;
  final MouseCursor disabledCursor;

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : widget.disabledCursor,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: enabled && _hover ? widget.hoverBg : widget.bg,
            // rounded-lg
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// The small coloured action buttons on the cards
/// (`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs
/// font-bold`, `hover:bg-…-200`).
class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.hoverBg,
    this.icon,
    this.leading,
    this.hPad = 12,
  });
  final String label;
  final Color bg;
  final Color fg;
  final Color? hoverBg;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? leading;
  final double hPad;

  @override
  Widget build(BuildContext context) => _HoverButton(
        bg: bg,
        hoverBg: hoverBg ?? bg,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              if (leading == null && icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: fg)),
            ],
          ),
        ),
      );
}

/// The `w-[30px] h-[30px] rounded-lg` icon buttons of the staff cards.
class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.tooltip,
    this.hoverBg,
    this.onTap,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color? hoverBg;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: _HoverButton(
          bg: bg,
          hoverBg: hoverBg ?? bg,
          onTap: onTap,
          // `cursor-not-allowed` when disabled.
          disabledCursor: SystemMouseCursors.forbidden,
          child: SizedBox(width: 30, height: 30, child: Icon(icon, size: 13, color: fg)),
        ),
      );
}

/// The exam card: `relative bg-card border rounded-2xl p-4 flex flex-col
/// gap-3 overflow-hidden hover:shadow-lg hover:-translate-y-0.5` with the
/// coloured top bar.
class _ExamTile extends StatefulWidget {
  const _ExamTile({required this.status, required this.content, required this.actions});
  final Object? status;

  /// The card body blocks, `gap-3` apart.
  final List<Widget> content;

  /// The `border-t pt-3 mt-auto` action row, pushed to the bottom.
  final List<Widget> actions;

  @override
  State<_ExamTile> createState() => _ExamTileState();
}

class _ExamTileState extends State<_ExamTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final children = widget.content;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _hover ? AppShadows.lg : const [],
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.exCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.exBorder),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      children[i],
                    ],
                    const SizedBox(height: 12),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.exBorder))),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: widget.actions,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(height: 3, color: _examCardBar(context, widget.status)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `grid grid-cols-[repeat(auto-fill,minmax(260px,1fr))] gap-3.5`, rows
/// stretched to their tallest card.
class _AutoFillGrid extends StatelessWidget {
  const _AutoFillGrid({required this.children});
  final List<Widget> children;

  static const _min = 260.0;
  static const _gap = 14.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          final cols = math.max(1, ((c.maxWidth + _gap) / (_min + _gap)).floor());
          final rows = <Widget>[];
          for (var i = 0; i < children.length; i += cols) {
            rows.add(IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < cols; j++) ...[
                    if (j > 0) const SizedBox(width: _gap),
                    Expanded(child: i + j < children.length ? children[i + j] : const SizedBox.shrink()),
                  ],
                ],
              ),
            ));
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: _gap),
                rows[i],
              ],
            ],
          );
        },
      );
}

/// `w-8 h-8 border-[3px] border-cyan-100 border-t-cyan-500 rounded-full
/// animate-spin`: a pale ring with its top quarter cyan, turning once a
/// second.
class _RingSpinner extends StatefulWidget {
  const _RingSpinner();

  @override
  State<_RingSpinner> createState() => _RingSpinnerState();
}

class _RingSpinnerState extends State<_RingSpinner> with SingleTickerProviderStateMixin {
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
        child: const CustomPaint(size: Size.square(32), painter: _RingPainter()),
      );
}

class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = Tw.cyan100);
    // border-top: from the top-left to the top-right corner (-135° → -45°).
    canvas.drawArc(rect, -math.pi * 3 / 4, math.pi / 2, false, paint..color = Tw.cyan500);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `<Badge>` is not registered in `newexams.vue`, so the browser renders a
/// bare `<badge>` element: the colours apply, but there is no padding or
/// rounding, and it inherits the surrounding font size. Kept as such.
class _BareBadge extends StatelessWidget {
  const _BareBadge(this.text, {required this.bg, required this.fg, this.border, this.fontSize = 14});
  final String text;
  final Color bg;
  final Color fg;
  final Color? border;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: bg, border: border == null ? null : Border.all(color: border!)),
        child: Text(text, style: TextStyle(fontSize: fontSize, height: 1.5, color: fg)),
      );
}

/// shadcn `<SelectTrigger>` is `w-fit`: the trigger is only as wide as its
/// value + chevron (`px-3 gap-2`, chevron 16, 1px border), capped by the
/// space available.
class _FitWidth extends StatelessWidget {
  const _FitWidth({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = tp.width.ceilToDouble() + 12 * 2 + 8 + 16 + 2 + 1;
    tp.dispose();
    return LayoutBuilder(
      builder: (context, c) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: c.maxWidth.isFinite ? math.min(width, c.maxWidth) : width, child: child),
      ),
    );
  }
}

/// The page's `animate-in fade-in slide-in-from-bottom-2 duration-300`.
class _EnterAnimation extends StatelessWidget {
  const _EnterAnimation({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
        ),
        child: child,
      );
}
