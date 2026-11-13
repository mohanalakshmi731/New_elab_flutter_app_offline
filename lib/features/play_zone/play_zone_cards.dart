part of 'play_zone_page.dart';

typedef _TextFn =
    TextStyle Function(
      double size,
      FontWeight weight,
      Color? color, {
      double? height,
      double? spacing,
    });

/// Header badge pill (`flex items-center gap-1.5 text-xs font-black px-3
/// py-1.5 rounded-full border`).
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.fg,
    required this.bg,
    required this.border,
    required this.text,
    this.shadow = false,
  });

  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;
  final Color border;
  final _TextFn text;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: border),
      // shadow-sm (the theme's value)
      boxShadow: shadow ? AppShadows.sm : null,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: fg),
        const SizedBox(width: 6),
        Text(label, style: text(12, FontWeight.w900, fg, height: 16 / 12)),
      ],
    ),
  );
}

/// "{n} activities" badge.
class _ActivitiesBadge extends StatelessWidget {
  const _ActivitiesBadge({required this.count, required this.dark, required this.text});
  final int count;
  final bool dark;
  final _TextFn text;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Tw.slate400 : Tw.gray500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$count '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Opacity(
                  opacity: 0.5,
                  child: Text('activities', style: text(12, FontWeight.w700, fg, height: 16 / 12)),
                ),
              ),
            ),
          ],
        ),
        style: text(12, FontWeight.w700, fg, height: 16 / 12),
      ),
    );
  }
}

/// Chapter dropdown: the button plus its floating option list
/// (`absolute top-full left-0 right-0 mt-2 z-50`).
class _ChapterDropdown extends StatefulWidget {
  const _ChapterDropdown({
    required this.open,
    required this.options,
    required this.selected,
    required this.label,
    required this.tapGroup,
    required this.text,
    required this.onToggle,
    required this.onSelect,
  });

  final bool open;
  final List<({String value, String label})> options;
  final String selected;
  final String label;
  final Object tapGroup;
  final _TextFn text;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  @override
  State<_ChapterDropdown> createState() => _ChapterDropdownState();
}

class _ChapterDropdownState extends State<_ChapterDropdown> with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 100),
    value: widget.open ? 1 : 0,
  );
  double _width = 0;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  void didUpdateWidget(_ChapterDropdown old) {
    super.didUpdateWidget(old);
    if (old.open != widget.open) {
      widget.open ? _anim.forward() : _anim.reverse();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final t = widget.text;
    final active = widget.selected != 'all';

    final Color border;
    final Color bg;
    final Color fg;
    if (active) {
      border = dark ? op(Tw.yellow400, 0.5) : op(Tw.yellow500, 0.6);
      bg = dark ? op(Tw.yellow400, 0.1) : Tw.yellow50;
      fg = dark ? Tw.yellow300 : Tw.yellow700;
    } else if (dark) {
      border = Colors.white.withValues(alpha: _hover ? 0.15 : 0.09);
      bg = Colors.white.withValues(alpha: _hover ? 0.07 : 0.04);
      fg = Tw.slate300;
    } else {
      border = Colors.black.withValues(alpha: _hover ? 0.14 : 0.09);
      bg = _hover ? Tw.gray50 : Colors.white;
      fg = Tw.gray600;
    }

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Opacity(
                opacity: 0.7,
                child: Icon(BootstrapIcons.journal_bookmark_fill, size: 14, color: fg),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: t(14, FontWeight.w700, fg, height: 20 / 14),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: widget.open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(BootstrapIcons.chevron_down, size: 12, color: fg),
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        _width = c.maxWidth;
        return CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(controller: _portal, overlayChildBuilder: _panel, child: button),
        );
      },
    );
  }

  Widget _panel(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        if (_anim.value == 0 && !widget.open) return const SizedBox.shrink();
        final forward = _anim.status != AnimationStatus.reverse;
        final v = (forward ? Curves.easeOut : Curves.easeIn).transform(_anim.value);
        return Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, 8),
            child: TapRegion(
              groupId: widget.tapGroup,
              child: IgnorePointer(
                ignoring: !widget.open,
                child: Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, -8 * (1 - v)),
                    child: Transform.scale(
                      scale: 0.95 + 0.05 * v,
                      child: SizedBox(width: _width, child: _panelBox(context)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _panelBox(BuildContext context) {
    final dark = context.isDark;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF13133A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.09)
                : Colors.black.withValues(alpha: 0.08),
          ),
          // shadow-2xl (the theme's value; `shadow-black/70` has no effect)
          boxShadow: AppShadows.xl2,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 256),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final ch in widget.options)
                  _ChapterOption(
                    label: ch.label,
                    selected: widget.selected == ch.value,
                    text: widget.text,
                    onTap: () => widget.onSelect(ch.value),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterOption extends StatelessWidget {
  const _ChapterOption({
    required this.label,
    required this.selected,
    required this.text,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final _TextFn text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return ZonePress(
      onTap: onTap,
      builder: (context, hover, _) {
        final Color bg;
        final Color fg;
        if (selected) {
          bg = dark ? op(Tw.yellow400, 0.15) : Tw.yellow50;
          fg = dark ? Tw.yellow300 : Tw.yellow700;
        } else if (dark) {
          bg = hover ? Colors.white.withValues(alpha: 0.05) : Colors.transparent;
          fg = hover ? Tw.slate200 : Tw.slate400;
        } else {
          bg = hover ? Tw.gray50 : Colors.transparent;
          fg = hover ? Tw.gray800 : Tw.gray500;
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Tw.yellow400 : (dark ? Tw.slate700 : Tw.gray300),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: text(
                    14,
                    selected ? FontWeight.w900 : FontWeight.w600,
                    fg,
                    height: 20 / 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Lock status pill toggle (All / Free / Locked).
class _LockFilterPill extends StatelessWidget {
  const _LockFilterPill({required this.selected, required this.text, required this.onSelect});
  final String selected;
  final _TextFn text;
  final ValueChanged<String> onSelect;

  /// `LOCK_FILTER_OPTIONS` (`activeClass` → background / text colour).
  static const _options = <({String value, String label, IconData icon, Color active})>[
    (value: 'all', label: 'All', icon: BootstrapIcons.grid_fill, active: Tw.yellow400),
    (value: 'unlocked', label: 'Free', icon: BootstrapIcons.unlock_fill, active: Tw.green400),
    (value: 'locked', label: 'Locked', icon: BootstrapIcons.lock_fill, active: Tw.yellow400),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.09),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            ZonePress(
              onTap: () => onSelect(_options[i].value),
              builder: (context, hover, _) {
                final o = _options[i];
                final isOn = selected == o.value;
                final fg = isOn
                    ? o.active
                    : (dark
                          ? (hover ? Tw.slate300 : Tw.slate500)
                          : (hover ? Tw.gray600 : Tw.gray400));
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOn ? op(o.active, 0.15) : Colors.transparent,
                    // rounded-xl (20px) on a 28px-high button
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(o.icon, size: 12, color: fg),
                      const SizedBox(width: 6),
                      Text(o.label, style: text(12, FontWeight.w900, fg, height: 16 / 12)),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// One Play Zone card (locked / unlocked).
class _PlayActivityCard extends StatefulWidget {
  const _PlayActivityCard({
    super.key,
    required this.activity,
    required this.unlocking,
    required this.text,
    required this.onPlay,
    required this.onUnlock,
  });

  final Json activity;
  final bool unlocking;
  final _TextFn text;
  final VoidCallback onPlay;
  final VoidCallback onUnlock;

  @override
  State<_PlayActivityCard> createState() => _PlayActivityCardState();
}

class _PlayActivityCardState extends State<_PlayActivityCard> {
  bool _hover = false;

  /// `brightness-[0.3] saturate-0`.
  static const _lockedImageFilter = ColorFilter.matrix(<double>[
    0.3 * 0.2126, 0.3 * 0.7152, 0.3 * 0.0722, 0, 0, //
    0.3 * 0.2126, 0.3 * 0.7152, 0.3 * 0.0722, 0, 0, //
    0.3 * 0.2126, 0.3 * 0.7152, 0.3 * 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  /// `levelBadgeClass(level)` → (background, text, ring).
  (Color, Color, Color) _levelColors(dynamic level, bool dark) {
    switch (level) {
      case 'beginner':
        return dark
            ? (op(Tw.indigo500, 0.2), Tw.indigo300, op(Tw.indigo500, 0.3))
            : (Tw.indigo100, Tw.indigo700, op(Tw.indigo300, 0.5));
      case 'intermediate':
        return dark
            ? (op(Tw.purple500, 0.2), Tw.purple300, op(Tw.purple500, 0.3))
            : (Tw.purple100, Tw.purple700, op(Tw.purple300, 0.5));
      case 'expert':
        return dark
            ? (op(Tw.rose500, 0.2), Tw.rose300, op(Tw.rose500, 0.3))
            : (Tw.rose100, Tw.rose700, op(Tw.rose300, 0.5));
    }
    return dark
        ? (op(Tw.slate500, 0.2), Tw.slate300, op(Tw.slate500, 0.2))
        : (Tw.gray100, Tw.gray600, Tw.gray200);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final act = widget.activity;
    final t = widget.text;
    final unlocked = jsTruthy(act['is_unlocked']);
    final hover = _hover && unlocked;
    final required = jsDisplay(act['required_tickets_to_unlock']);
    final filePath = act['file_path'];
    final level = act['level'];

    final Color cardBg;
    final Color cardBorder;
    if (unlocked) {
      cardBg = dark ? const Color(0xFF13133A) : Colors.white;
      cardBorder = hover
          ? op(Tw.yellow400, dark ? 0.4 : 0.5)
          : (dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08));
    } else {
      cardBg = dark ? const Color(0xFF0F0F30) : Tw.gray50;
      cardBorder = dark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05);
    }

    // ── IMAGE AREA ──
    Widget image;
    if (jsTruthy(filePath)) {
      image = Image.network(
        jsDisplay(filePath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
      image = unlocked
          ? AnimatedScale(
              scale: hover ? 1.05 : 1,
              duration: const Duration(milliseconds: 500),
              child: image,
            )
          : ColorFiltered(colorFilter: _lockedImageFilter, child: image);
    } else {
      image = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF1A1A45), Color(0xFF13133A)]
                : const [Tw.indigo50, Tw.purple50],
          ),
        ),
        child: Center(
          child: Icon(BootstrapIcons.image, size: 36, color: dark ? Tw.slate700 : Tw.indigo200),
        ),
      );
    }

    final (levelBg, levelFg, levelRing) = _levelColors(level, dark);

    final imageArea = AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xBF000000), Color(0x26000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          // LOCKED OVERLAY
          if (!unlocked)
            ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: ColoredBox(
                  color: const Color.fromRGBO(8, 8, 30, 0.8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: dark ? op(Tw.yellow400, 0.1) : Tw.amber50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dark ? op(Tw.yellow400, 0.3) : op(Tw.amber300, 0.6),
                          ),
                        ),
                        child: const Icon(BootstrapIcons.lock_fill, size: 24, color: Tw.yellow400),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.black.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dark ? op(Tw.yellow400, 0.25) : op(Tw.amber300, 0.4),
                          ),
                        ),
                        // flex items-center gap-2: the emoji and the
                        // `leading-none` line (its `text-lg` span keeps a
                        // 28px line box); a collapsed space + ml-1 before
                        // "tickets".
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎟️', style: t(20, FontWeight.w400, null, height: 1)),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  required,
                                  style: t(18, FontWeight.w900, Tw.yellow400, height: 28 / 18),
                                ),
                                const SizedBox(width: 4 + 4),
                                Text(
                                  'TICKETS',
                                  style: t(
                                    10,
                                    FontWeight.w700,
                                    op(Tw.yellow400, 0.6),
                                    height: 1,
                                    spacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // UNLOCKED PLAY HOVER OVERLAY
          if (unlocked)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: hover ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: AnimatedScale(
                    scale: hover ? 1 : 0.75,
                    duration: const Duration(milliseconds: 300),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: op(Tw.yellow400, 0.2),
                            border: Border.all(color: op(Tw.yellow400, 0.6), width: 2),
                            // shadow-lg (the theme's value)
                            boxShadow: AppShadows.lg,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(BootstrapIcons.play_fill, size: 24, color: Tw.yellow400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Level Badge (top-left)
          if (jsTruthy(level))
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: levelBg,
                  // rounded-xl (20px) on a 24.5px-high badge
                  borderRadius: BorderRadius.circular(12.25),
                  // ring-1 (outside, no layout space)
                  boxShadow: [BoxShadow(color: levelRing, spreadRadius: 1)],
                ),
                child: Text(
                  capitalise(jsDisplay(level)),
                  style: t(11, FontWeight.w900, levelFg, height: 1.5, spacing: 0.275),
                ),
              ),
            ),
          // Unlock status badge (top-right, unlocked)
          if (unlocked)
            Positioned(
              top: 12,
              right: 12,
              child: ClipRRect(
                // rounded-xl (20px) on a 25px-high badge
                borderRadius: BorderRadius.circular(12.5),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: dark ? op(Tw.green400, 0.15) : op(Tw.green50, 0.9),
                      borderRadius: BorderRadius.circular(12.5),
                      border: Border.all(color: dark ? op(Tw.green400, 0.3) : op(Tw.green300, 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          BootstrapIcons.unlock_fill,
                          size: 10,
                          color: dark ? Tw.green400 : Tw.green600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Free',
                          style: t(
                            10,
                            FontWeight.w900,
                            dark ? Tw.green400 : Tw.green600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Chapter number (top-right, locked)
          if (jsTruthy(act['chapterNumber']) && !unlocked)
            Positioned(
              top: 12,
              right: 12,
              child: ClipRRect(
                // rounded-xl (20px) on a 28px box
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Text(
                      jsDisplay(act['chapterNumber']),
                      style: t(12, FontWeight.w900, Colors.white, height: 1),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // ── CARD BODY ──
    final topicName = act['topic_name'];
    final titleColor = unlocked
        ? (dark ? (hover ? Tw.yellow300 : Tw.slate100) : (hover ? Tw.yellow700 : Tw.gray900))
        : (dark ? Tw.slate500 : Tw.gray400);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (jsTruthy(topicName)) ...[
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: topicColor(topicName),
                  // rounded-lg (16px in this theme) on a 20px box
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(BootstrapIcons.hash, size: 9, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  jsDisplay(topicName).toUpperCase(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: t(
                    10,
                    FontWeight.w900,
                    dark ? Tw.slate500 : Tw.gray400,
                    height: 1.5,
                    spacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(
          jsDisplay(act['name']),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: t(13, FontWeight.w900, titleColor, height: 1.375),
        ),
      ],
    );

    final Widget actions;
    if (unlocked) {
      actions = ZonePress(
        onTap: widget.onPlay,
        builder: (context, btnHover, pressed) => AnimatedScale(
          scale: pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: btnHover ? Tw.yellow300 : Tw.yellow400,
              borderRadius: BorderRadius.circular(16),
              // shadow-md (the theme's value; colour modifiers have no effect)
              boxShadow: AppShadows.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  BootstrapIcons.play_fill,
                  size: 14,
                  color: dark ? const Color(0xFF0D0D2B) : Tw.gray900,
                ),
                const SizedBox(width: 8),
                Text(
                  'Play',
                  style: t(
                    12,
                    FontWeight.w900,
                    dark ? const Color(0xFF0D0D2B) : Tw.gray900,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      actions = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: dark ? op(Tw.yellow400, 0.07) : Tw.amber50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dark ? op(Tw.yellow400, 0.2) : op(Tw.amber200, 0.6)),
            ),
            child: Row(
              children: [
                Text('🎟️', style: t(16, FontWeight.w400, null, height: 1)),
                const SizedBox(width: 8),
                Text(required, style: t(14, FontWeight.w900, Tw.yellow400, height: 20 / 14)),
                const SizedBox(width: 8),
                Text('tickets', style: t(10, FontWeight.w600, op(Tw.yellow400, 0.6), height: 1.5)),
                const Spacer(),
                Text(
                  'TO UNLOCK',
                  style: t(
                    10,
                    FontWeight.w900,
                    dark ? Tw.slate600 : op(Tw.amber400, 0.8),
                    height: 1.5,
                    spacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _UnlockButton(
            required: required,
            unlocking: widget.unlocking,
            text: t,
            onTap: widget.onUnlock,
          ),
        ],
      );
    }

    final body = Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(alignment: Alignment.topLeft, child: info),
            ),
            const SizedBox(height: 12),
            actions,
          ],
        ),
      ),
    );

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, hover ? -8 : 0, 0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        // hover:shadow-2xl (dark) / hover:shadow-xl (light), the theme's
        // values (colour modifiers have no effect).
        boxShadow: hover ? (dark ? AppShadows.xl2 : AppShadows.xl) : const [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            imageArea,
            Expanded(child: body),
          ],
        ),
      ),
    );

    return MouseRegion(
      cursor: unlocked ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Opacity(opacity: unlocked ? 1 : 0.8, child: card),
    );
  }
}

/// "Unlock with N 🎟️" / "Unlocking…" button of a locked card.
class _UnlockButton extends StatelessWidget {
  const _UnlockButton({
    required this.required,
    required this.unlocking,
    required this.text,
    required this.onTap,
  });

  final String required;
  final bool unlocking;
  final _TextFn text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = dark ? Tw.yellow400 : Tw.amber700;
    return ZonePress(
      onTap: onTap,
      enabled: !unlocking,
      builder: (context, hover, pressed) {
        final h = hover && !unlocking;
        return Opacity(
          opacity: unlocking ? 0.6 : 1,
          child: AnimatedScale(
            scale: pressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: dark ? op(Tw.yellow400, h ? 0.2 : 0.1) : (h ? Tw.amber100 : Tw.amber50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark
                      ? op(Tw.yellow400, h ? 0.5 : 0.25)
                      : (h ? Tw.amber400 : op(Tw.amber300, 0.6)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: unlocking
                    ? [
                        ZoneButtonSpinner(size: 14, color: fg),
                        const SizedBox(width: 8),
                        Text('Unlocking…', style: text(12, FontWeight.w900, fg, height: 16 / 12)),
                      ]
                    : [
                        Icon(BootstrapIcons.lock_fill, size: 12, color: fg),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Unlock with $required 🎟️',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text(12, FontWeight.w900, fg, height: 16 / 12),
                          ),
                        ),
                      ],
              ),
            ),
          ),
        );
      },
    );
  }
}
