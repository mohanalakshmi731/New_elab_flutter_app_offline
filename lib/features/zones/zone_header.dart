part of 'zones_page.dart';

/// HEADER BANNER + class dropdown / activity count row.
extension _Header on _ZonePageState {
  Widget _buildBanner() => _ZoneBanner(
        kind: widget.kind,
        title: _selectedClassName.isNotEmpty ? _selectedClassName : 'Select a Class',
        isGrid: _isGrid,
        onGrid: (v) => _update(() => _isGrid = v),
      );

  /// `flex items-center gap-3 flex-wrap`: the class dropdown
  /// (`flex-1 min-w-[200px] max-w-xs`, non-students) and the activity count
  /// badge (`shrink-0`), which wraps below when the dropdown's 200px minimum
  /// and the badge don't fit on one line.
  Widget _buildClassRow(bool isStudent) {
    final showBadge = _allActivitiesData.isNotEmpty;
    if (isStudent && !showBadge) return const SizedBox.shrink();
    if (isStudent) return Align(alignment: Alignment.centerLeft, child: _activityCountBadge());
    return LayoutBuilder(builder: (context, c) {
      final avail = c.maxWidth;
      final badgeW = showBadge ? _activityCountBadgeWidth() : 0.0;
      final inline = !showBadge || avail >= 200 + 12 + badgeW;
      final grow = inline && showBadge ? avail - 12 - badgeW : avail;
      final ddWidth = math.min(320.0, math.max(grow, math.min(200.0, avail)));
      final dropdown = SizedBox(width: ddWidth, child: _classDropdownButton(ddWidth));
      if (!showBadge) return Align(alignment: Alignment.centerLeft, child: dropdown);
      if (inline) {
        return Row(children: [dropdown, const SizedBox(width: 12), _activityCountBadge()]);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [dropdown, const SizedBox(height: 12), _activityCountBadge()],
      );
    });
  }

  TextStyle get _badgeStyle => zt(12, FontWeight.w700, context.isDark ? Tw.slate400 : Tw.gray500,
      height: 16 / 12);

  /// Rendered width of [_activityCountBadge] (`px-3` + border + text).
  double _activityCountBadgeWidth() {
    final tp = TextPainter(
      text: TextSpan(text: '$_totalActivityCount activities', style: _badgeStyle),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = tp.width;
    tp.dispose();
    return w + 2 + 24 + 2 + 1;
  }

  /// `{{ totalActivityCount }} <span class="opacity-50 ml-0.5">activities</span>`.
  Widget _activityCountBadge() {
    final dark = context.isDark;
    final style = _badgeStyle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07)),
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: '$_totalActivityCount '),
          const WidgetSpan(child: SizedBox(width: 2)),
          TextSpan(text: 'activities', style: TextStyle(color: style.color!.withValues(alpha: 0.5))),
        ]),
        maxLines: 1,
        style: style,
      ),
    );
  }

  /// `classOpen = !classOpen`. Closing plays the leave transition first; the
  /// panel is removed when it ends.
  void _toggleClassDropdown() {
    if (_classOpen) {
      _update(() => _classOpen = false);
    } else {
      _classDropdown.show();
      _update(() => _classOpen = true);
    }
  }

  void _closeClassDropdown() {
    if (_classOpen) _update(() => _classOpen = false);
  }

  Widget _classDropdownButton(double width) {
    final dark = context.isDark;
    final primary = context.colors.primary;

    final button = ZoneHover(
      onTap: _toggleClassDropdown,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: dark ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: dark ? 0.5 : 0.2)),
        ),
        child: Row(
          children: [
            Opacity(opacity: 0.7, child: Icon(BootstrapIcons.mortarboard_fill, size: 14, color: primary)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedClassName.isNotEmpty ? _selectedClassName : 'Select Class',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zt(14, FontWeight.w700, primary, height: 20 / 14),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _classOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              curve: kTwEase,
              child: Icon(BootstrapIcons.chevron_down, size: 12, color: primary),
            ),
          ],
        ),
      ),
    );

    return CompositedTransformTarget(
      link: _classDropdownLink,
      child: OverlayPortal(
        controller: _classDropdown,
        overlayChildBuilder: (overlayContext) => Positioned(
          width: width,
          child: CompositedTransformFollower(
            link: _classDropdownLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, 8),
            child: TapRegion(
              groupId: _classDropdownLink,
              onTapOutside: (_) => _closeClassDropdown(),
              child: _classDropdownPanel(),
            ),
          ),
        ),
        child: TapRegion(groupId: _classDropdownLink, child: button),
      ),
    );
  }

  Widget _classDropdownPanel() {
    final dark = context.isDark;
    final primary = context.colors.primary;

    final items = <Widget>[
      if (_loading && _allClasses.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('Loading classes…',
              style: zt(14, FontWeight.w600, dark ? Tw.slate500 : Tw.gray400, height: 20 / 14)),
        ),
      for (final c in _allClasses)
        ZoneHover(
          onTap: () => _selectClass(c['id']),
          builder: (context, hover) {
            final selected = _selectedClassId == c['id'];
            final Color bg;
            final Color fg;
            if (selected) {
              bg = primary.withValues(alpha: dark ? 0.15 : 0.05);
              fg = primary;
            } else {
              bg = hover
                  ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50)
                  : Colors.transparent;
              fg = dark ? (hover ? Tw.slate200 : Tw.slate400) : (hover ? Tw.gray800 : Tw.gray500);
            }
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: kTwEase,
              color: bg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? primary : (dark ? Tw.slate700 : Tw.gray300),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jsStr(c['name']) ?? '',
                      style: zt(14, selected ? FontWeight.w900 : FontWeight.w600, fg, height: 20 / 14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    ];

    // <Transition>: enter 150ms ease-out, leave 100ms ease-in, from/to
    // `opacity-0 scale-95 -translate-y-2`.
    final open = _classOpen;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? 1 : 0),
      duration: Duration(milliseconds: open ? 150 : 100),
      curve: open ? kTwEaseOut : kTwEaseIn,
      onEnd: () {
        if (!_classOpen && _classDropdown.isShowing) _classDropdown.hide();
      },
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, -8 * (1 - t)),
          child: Transform.scale(scale: 0.95 + 0.05 * t, child: child),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF13133A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.08),
            ),
            // shadow-2xl (the theme's; `shadow-black/70` / `/10` have no effect).
            boxShadow: AppShadows.xl2,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 256),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 100px gradient banner: pattern, glows, floating shapes, class name
/// and the Grid / List toggle.
class _ZoneBanner extends StatefulWidget {
  const _ZoneBanner({
    required this.kind,
    required this.title,
    required this.isGrid,
    required this.onGrid,
  });

  final ZoneKind kind;
  final String title;
  final bool isGrid;
  final ValueChanged<bool> onGrid;

  @override
  State<_ZoneBanner> createState() => _ZoneBannerState();
}

class _ZoneBannerState extends State<_ZoneBanner> with SingleTickerProviderStateMixin {
  /// `float-icon 4s infinite ease-in-out` (also drives the 2s `animate-pulse`).
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  /// 0 → 1 → 0 over one cycle, shifted by [delaySeconds].
  double _float(double delaySeconds) {
    final t = (_anim.value - delaySeconds / 4) % 1.0;
    return 0.5 - 0.5 * math.cos(2 * math.pi * t);
  }

  Widget _floating(double delay, Widget child) => AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final v = _float(delay);
          return Transform.translate(
            offset: Offset(0, -15 * v),
            child: Transform.rotate(angle: 5 * math.pi / 180 * v, child: child),
          );
        },
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = ZoneStyle.of(widget.kind);
    final sm = context.isSm;
    final md = context.isMd;
    final lg = context.isLg;
    final primary = colors.primary;
    final accent = colors.tertiary;
    final science = widget.kind == ZoneKind.science;

    final shapes = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _floating(
          0,
          science
              ? const SvgStrokeIcon(ZoneSvg.bulb, size: 56, color: Colors.white, strokeWidth: 1.5)
              : CustomPaint(
                  size: const Size.square(56),
                  painter: StarPainter(stroke: Colors.white, strokeWidth: 1.5),
                ),
        ),
        if (sm) ...[
          const SizedBox(width: 24),
          _floating(
            1.2,
            CustomPaint(size: const Size.square(40), painter: DashedCirclePainter(Colors.white)),
          ),
        ],
        if (md) ...[
          const SizedBox(width: 24),
          _floating(
            2.4,
            science
                ? const SvgStrokeIcon(ZoneSvg.beaker, size: 64, color: Colors.white, strokeWidth: 1.5)
                : CustomPaint(size: const Size.square(64), painter: RoundedSquarePainter(Colors.white)),
          ),
        ],
      ],
    );

    final pulseDot = AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Opacity(
        // animate-pulse: opacity 1 → .5 → 1 every 2s.
        opacity: 0.75 + 0.25 * math.cos(2 * math.pi * 2 * _anim.value),
        child: child,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent,
          // shadow-[0_0_10px_var(--accent)]
          boxShadow: [cssShadow(0, 0, 10, 0, accent)],
        ),
      ),
    );

    // rounded-2xl = 16px (Tailwind 4 default; the theme only redefines sm–xl).
    final iconBox = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: sm ? 48 : 44,
          height: sm ? 48 : 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(style.headerIcon, size: 20, color: accent),
        ),
      ),
    );

    final titleSize = lg ? 30.0 : (sm ? 24.0 : 20.0);
    final content = Row(
      children: [
        DecoratedBox(
          // shadow-lg (the theme's lighter value)
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.lg),
          child: iconBox,
        ),
        SizedBox(width: sm ? 16 : 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  pulseDot,
                  const SizedBox(width: 8),
                  Text(
                    style.label.toUpperCase(),
                    style: zt(10, FontWeight.w900, Colors.white.withValues(alpha: 0.7),
                        spacing: 1, height: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: zt(
                  titleSize,
                  FontWeight.w800,
                  Colors.white,
                  height: 1.25,
                  spacing: -0.025 * titleSize,
                  shadows: kDropShadowMd,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          // bg-gradient-to-br from-primary via-primary/90 to-secondary
          gradient: CssLinearGradient(
            corner: Alignment.bottomRight,
            colors: [primary, primary.withValues(alpha: 0.9), colors.secondary],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(opacity: 0.5, child: CustomPaint(painter: DotPatternPainter(style.patternDot))),
            ),
            Positioned(
              top: -150,
              left: -100,
              child: GlowBlob(color: primary, opacity: 0.3, diameter: 400, blur: 80, solid: false),
            ),
            Positioned(
              bottom: -150,
              right: -50,
              child: GlowBlob(color: accent, opacity: 0.25, diameter: 350, blur: 80, solid: false),
            ),
            // Floating shapes
            Positioned(
              right: 40,
              top: 0,
              bottom: 0,
              child: IgnorePointer(child: Center(child: Opacity(opacity: 0.2, child: shapes))),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: md ? 32 : (sm ? 24 : 16)),
                child: Align(alignment: Alignment.centerLeft, child: content),
              ),
            ),
            Positioned(
              top: sm ? 16 : 12,
              right: sm ? 20 : 16,
              child: _viewToggle(sm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewToggle(bool sm) {
    Widget button(bool grid) {
      final active = widget.isGrid == grid;
      return ZoneHover(
        onTap: () => widget.onGrid(grid),
        cursor: SystemMouseCursors.click,
        builder: (context, hover) {
          final fg = active
              ? Colors.white
              : Colors.white.withValues(alpha: hover ? 0.7 : 0.4);
          // px-3 py-1 rounded-lg (16px) text-xs: a 16px line even when the
          // label is hidden below `sm`.
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: kTwEase,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: active ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(grid ? BootstrapIcons.grid_3x3_gap_fill : BootstrapIcons.list_ul, size: 12, color: fg),
                  if (sm) ...[
                    const SizedBox(width: 6),
                    Text(grid ? 'Grid' : 'List', style: zt(12, FontWeight.w900, fg, height: 16 / 12)),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    // p-1 rounded-xl (20px) border-white/20 bg-black/20 backdrop-blur-md
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [button(true), const SizedBox(width: 4), button(false)],
          ),
        ),
      ),
    );
  }
}
