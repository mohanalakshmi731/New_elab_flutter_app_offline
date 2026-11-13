part of 'class_math_page.dart';

/// The chapter `<Sheet side="right">` (shadcn SheetContent + overlay),
/// rendered on the root overlay so it covers the whole shell like the web
/// portal. The panel slides in over 500 ms and out over 300 ms
/// (`ease-in-out`); the overlay fades over 150 ms (`ease`).
extension _ClassMathSheet on _ClassMathPageState {
  Widget _buildSheet(BuildContext context) {
    final dark = context.isDark;
    final screen = MediaQuery.sizeOf(context);
    // `!w-full sm:!w-[380px]`
    final width = context.isSm ? 380.0 : screen.width;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => _onSheetOpenChange(false),
      },
      child: Focus(
        autofocus: true,
        child: AnimatedBuilder(
          animation: _sheetAnim,
          builder: (context, child) {
            final v = _sheetAnim.value;
            final opening =
                _sheetAnim.status == AnimationStatus.forward || _sheetAnim.status == AnimationStatus.completed;
            // slide-in-from-right (500 ms) / slide-out-to-right (300 ms)
            final t = opening ? kTwEase.transform(v) : 1 - kTwEase.transform(1 - v);
            // fade-in-0 / fade-out-0, 150 ms
            final overlay = opening
                ? Curves.ease.transform((v * 500 / 150).clamp(0.0, 1.0))
                : 1 - Curves.ease.transform(((1 - v) * 300 / 150).clamp(0.0, 1.0));
            return Stack(
              children: [
                // SheetOverlay: fixed inset-0 bg-black/80; outside click closes.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onSheetOpenChange(false),
                    child: ColoredBox(color: Colors.black.withValues(alpha: 0.8 * overlay)),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: -width * (1 - t),
                  width: width,
                  child: child!,
                ),
              ],
            );
          },
          child: _sheetPanel(context, dark),
        ),
      ),
    );
  }

  Widget _sheetPanel(BuildContext context, bool dark) {
    final primary = dark ? AppColors.darkPrimary : AppColors.primary;
    final onPrimary = dark ? AppColors.darkPrimaryForeground : AppColors.primaryForeground;
    final chapter = _activeChapter;
    final n = _sheetActivities.length;
    final divider = dark ? Tw.slate800.withValues(alpha: 0.7) : Tw.gray100;

    final header = Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: divider))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary,
              // rounded-xl (20 px in this theme)
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.md,
            ),
            child: Text(chapter == null ? '' : '${chapter.number}',
                style: _nunito(
                    size: 14, weight: FontWeight.w900, spacing: 0.35, height: TwLeading.sm, color: onPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jsDisplay(chapter?.name),
                      style: _nunito(
                          size: 18,
                          weight: FontWeight.w900,
                          height: 1.375,
                          color: dark ? Tw.slate100 : primary)),
                  const SizedBox(height: 2),
                  Text('$n ${n == 1 ? 'activity' : 'activities'}',
                      style: _nunito(
                          size: 12,
                          weight: FontWeight.w600,
                          height: TwLeading.xs,
                          color: dark ? Tw.slate500 : primary.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget body;
    if (_sheetLoading) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // `w-8 h-8 rounded-full border-2 animate-spin` + `border-t-primary`
            BorderSpinner(
              size: 32,
              stroke: 2,
              track: dark ? Tw.slate800 : primary.withValues(alpha: 0.2),
              head: primary,
            ),
            const SizedBox(height: 12),
            Text('Loading activities…',
                style: _nunito(
                    size: 12,
                    weight: FontWeight.w700,
                    spacing: 0.3,
                    height: TwLeading.xs,
                    color: dark ? Tw.slate500 : primary.withValues(alpha: 0.5))),
          ],
        ),
      );
    } else if (_sheetActivities.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark ? Tw.slate900 : primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dark ? Tw.slate800 : primary.withValues(alpha: 0.1)),
                ),
                child: SvgIcon(SvgGlyph.image,
                    size: 28, strokeWidth: 1.5, color: dark ? Tw.slate700 : primary.withValues(alpha: 0.3)),
              ),
              const SizedBox(height: 12),
              Text('No activities yet',
                  style: _nunito(
                      size: 14,
                      weight: FontWeight.w700,
                      height: TwLeading.sm,
                      color: dark ? Tw.slate600 : primary.withValues(alpha: 0.4))),
            ],
          ),
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _sheetActivities.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, ai) {
          final act = _sheetActivities[ai];
          return _SheetActivityCard(
            key: ValueKey('act-${jsStr(act['id'])}'),
            activity: act,
            index: ai,
            dark: dark,
            onPlay: () => _goToActivity(act),
            onExam: () => _goToQuiz(act),
          );
        },
      );
    }

    // <SheetClose as-child><Button variant="outline" class="w-full h-10 …">
    final footer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: divider))),
      child: _KitButton(
        label: 'Close',
        height: 40,
        fontSize: 14,
        paddingX: 16,
        style: _KitButtonStyle.outline(
          dark: dark,
          primary: primary,
          darkForeground: Tw.slate400,
          darkHoverForeground: Tw.slate200,
        ),
        onTap: () => _onSheetOpenChange(false),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: dark ? Tw.slate950 : Colors.white.withValues(alpha: 0.9),
          border: Border(
            left: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.7) : Tw.gray200.withValues(alpha: 0.8)),
          ),
          boxShadow: AppShadows.lg,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 16),
                Expanded(child: body),
                const SizedBox(height: 16),
                footer,
              ],
            ),
            // SheetContent's built-in close button (absolute top-4 right-4
            // rounded-xs opacity-70 hover:opacity-100, lucide X size-4).
            Positioned(
              top: 16,
              right: 16,
              child: HoverBuilder(
                onTap: () => _onSheetOpenChange(false),
                builder: (context, hover) => AnimatedOpacity(
                  opacity: hover ? 1 : 0.7,
                  duration: const Duration(milliseconds: 150),
                  curve: kTwEase,
                  child: LucideIcon(Lucide.x, size: 16, color: context.fgColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One activity card of the sheet (`.act-card`).
class _SheetActivityCard extends StatefulWidget {
  const _SheetActivityCard({
    super.key,
    required this.activity,
    required this.index,
    required this.dark,
    required this.onPlay,
    required this.onExam,
  });

  final Json activity;
  final int index;
  final bool dark;
  final VoidCallback onPlay;
  final VoidCallback onExam;

  @override
  State<_SheetActivityCard> createState() => _SheetActivityCardState();
}

class _SheetActivityCardState extends State<_SheetActivityCard> with SingleTickerProviderStateMixin {
  // actSlide .28s ease both, delay index × .06s
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    _delay = Timer(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final act = widget.activity;
    final primary = dark ? AppColors.darkPrimary : AppColors.primary;
    final onPrimary = dark ? AppColors.darkPrimaryForeground : AppColors.primaryForeground;
    final filePath = jsStr(act['file_path']) ?? '';

    final card = HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: kTwEase,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark
              ? (hover ? Tw.slate900.withValues(alpha: 0.8) : Tw.slate950.withValues(alpha: 0.9))
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark
                ? (hover ? Tw.slate600.withValues(alpha: 0.6) : Tw.slate800.withValues(alpha: 0.7))
                : (hover ? primary.withValues(alpha: 0.4) : Tw.gray200.withValues(alpha: 0.8)),
          ),
          boxShadow: !dark && hover ? AppShadows.md : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // image
            SizedBox(
              height: 128,
              child: ColoredBox(
                color: dark ? Tw.slate900 : primary.withValues(alpha: 0.05),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (filePath.isNotEmpty)
                      ClipRect(
                        child: AnimatedScale(
                          scale: hover ? 1.05 : 1,
                          duration: const Duration(milliseconds: 300),
                          curve: kTwEase,
                          child: Image.network(
                            filePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: SvgIcon(SvgGlyph.image,
                            size: 40, strokeWidth: 1.5, color: dark ? Tw.slate700 : primary.withValues(alpha: 0.2)),
                      ),
                    if (jsTruthy(act['topic_name']))
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: dark ? Tw.slate950.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: dark ? Tw.slate700.withValues(alpha: 0.6) : primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(jsDisplay(act['topic_name']),
                              style: _nunito(
                                  size: 10, weight: FontWeight.w700, height: 1.5, color: dark ? Tw.slate300 : primary)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // name
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.6) : Tw.gray100),
                ),
              ),
              child: Text(
                jsDisplay(act['name']),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _nunito(size: 14, weight: FontWeight.w800, height: 1.25, color: dark ? Tw.slate100 : primary),
              ),
            ),
            // actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // <Button size="sm" class="flex-1 h-9 text-xs font-bold gap-1.5">
                  Expanded(
                    child: _KitButton(
                      label: 'Play',
                      glyph: SvgGlyph.play,
                      height: 36,
                      fontSize: 12,
                      paddingX: 10,
                      style: _KitButtonStyle(
                        background: primary,
                        hoverBackground: primary.withValues(alpha: 0.9),
                        foreground: onPrimary,
                        hoverForeground: onPrimary,
                      ),
                      onTap: widget.onPlay,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // <Button size="sm" variant="outline" …>
                  Expanded(
                    child: _KitButton(
                      label: 'Exam',
                      glyph: SvgGlyph.helpCircle,
                      glyphStroke: 2.5,
                      height: 36,
                      fontSize: 12,
                      paddingX: 10,
                      style: _KitButtonStyle.outline(
                        dark: dark,
                        primary: primary,
                        darkForeground: Tw.slate200,
                        // the kit's hover:text-accent-foreground survives
                        darkHoverForeground: AppColors.accentForeground,
                      ),
                      onTap: widget.onExam,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final v = Curves.ease.transform(_anim.value);
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
        );
      },
      child: card,
    );
  }
}

/// Colours of a shadcn `<Button>` after the page's class overrides.
class _KitButtonStyle {
  const _KitButtonStyle({
    required this.background,
    required this.hoverBackground,
    required this.foreground,
    required this.hoverForeground,
    this.border,
  });

  /// `variant="outline"` with the page's
  /// light `border-primary/20 text-primary hover:bg-primary/5` /
  /// dark `border-slate-* bg-slate-* text-slate-* hover:bg-slate-800`.
  /// tailwind-merge keeps the kit's `dark:bg-input/30 dark:border-input
  /// dark:hover:bg-input/50` (a different variant, and more specific), so
  /// those win in dark mode; the kit's `hover:text-accent-foreground` stays
  /// unless the page sets its own `hover:text-*`.
  factory _KitButtonStyle.outline({
    required bool dark,
    required Color primary,
    required Color darkForeground,
    required Color darkHoverForeground,
  }) =>
      dark
          ? _KitButtonStyle(
              background: AppColors.darkInput.withValues(alpha: 0.3),
              hoverBackground: AppColors.darkInput.withValues(alpha: 0.5),
              border: AppColors.darkInput,
              foreground: darkForeground,
              hoverForeground: darkHoverForeground,
            )
          : _KitButtonStyle(
              background: AppColors.background,
              hoverBackground: primary.withValues(alpha: 0.05),
              border: primary.withValues(alpha: 0.2),
              foreground: primary,
              hoverForeground: AppColors.accentForeground,
            );

  final Color background;
  final Color hoverBackground;
  final Color foreground;
  final Color hoverForeground;
  final Color? border;
}

/// shadcn `<Button>` (`rounded-md` = 14 px, `shadow-xs`, `font-bold`
/// override, lucide-size `[&_svg]:size-4` icons, `gap-1.5`).
class _KitButton extends StatelessWidget {
  const _KitButton({
    required this.label,
    required this.height,
    required this.fontSize,
    required this.paddingX,
    required this.style,
    required this.onTap,
    this.glyph,
    this.glyphStroke = 2,
  });

  final String label;
  final SvgGlyph? glyph;
  final double glyphStroke;
  final double height;
  final double fontSize;
  final double paddingX;
  final _KitButtonStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        onTap: onTap,
        builder: (context, hover) {
          final fg = hover ? style.hoverForeground : style.foreground;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: kTwEase,
            height: height,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: paddingX),
            decoration: BoxDecoration(
              color: hover ? style.hoverBackground : style.background,
              borderRadius: BorderRadius.circular(14),
              border: style.border == null ? null : Border.all(color: style.border!),
              boxShadow: AppShadows.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (glyph != null) ...[
                  SvgIcon(glyph!, size: 16, strokeWidth: glyphStroke, color: fg),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: _nunito(size: fontSize, weight: FontWeight.w700, color: fg)),
                ),
              ],
            ),
          );
        },
      );
}
