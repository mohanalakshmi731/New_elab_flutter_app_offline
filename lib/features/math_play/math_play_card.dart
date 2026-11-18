part of 'math_play_page.dart';

/// `brightness-[0.3] saturate-0` (brightness first, then luminance grey).
const ColorFilter _kLockedImageFilter = ColorFilter.matrix([
  0.3 * 0.2126, 0.3 * 0.7152, 0.3 * 0.0722, 0, 0, //
  0.3 * 0.2126, 0.3 * 0.7152, 0.3 * 0.0722, 0, 0, //
  0.3 * 0.2126, 0.3 * 0.7152, 0.3 * 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// One activity card of the grid.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    super.key,
    required this.activity,
    required this.dark,
    required this.unlocking,
    required this.onPlay,
    required this.onQuiz,
    required this.onUnlock,
  });

  final Json activity;
  final bool dark;
  final bool unlocking;
  final VoidCallback onPlay;
  final VoidCallback onQuiz;
  final VoidCallback onUnlock;

  bool get _unlocked => jsTruthy(activity['is_unlocked']);

  @override
  Widget build(BuildContext context) {
    final unlocked = _unlocked;
    return HoverBuilder(
      cursor: unlocked ? SystemMouseCursors.click : SystemMouseCursors.basic,
      builder: (context, rawHover) {
        final hover = unlocked && rawHover;
        final Color bg, border;
        List<BoxShadow>? shadow;
        if (unlocked) {
          bg = dark ? _C.card : Colors.white;
          border = hover
              ? Tw.yellow400.withValues(alpha: dark ? 0.4 : 0.5)
              : (dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08));
          // hover:shadow-2xl / hover:shadow-xl (colour modifiers have no effect)
          if (hover) shadow = dark ? AppShadows.xl2 : AppShadows.xl;
        } else {
          bg = dark ? _C.cardLocked : Tw.gray50;
          border = dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
        }

        final card = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: kTwEase,
          transform: Matrix4.translationValues(0, hover ? -8 : 0, 0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(aspectRatio: 16 / 10, child: _imageArea(hover)),
              Expanded(child: _body(context, hover)),
            ],
          ),
        );
        return unlocked ? card : Opacity(opacity: 0.8, child: card);
      },
    );
  }

  // ── IMAGE AREA ──
  Widget _imageArea(bool hover) {
    final unlocked = _unlocked;
    final filePath = jsStr(activity['file_path']) ?? '';
    final tickets = jsDisplay(activity['required_tickets_to_unlock']);

    Widget image = filePath.isNotEmpty
        ? contentImage(filePath, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
        : DecoratedBox(
            decoration: BoxDecoration(
              // bg-gradient-to-br on a 16:10 box
              gradient: CssLinearGradient(
                corner: Alignment.bottomRight,
                colors: dark ? const [_C.cardFallback, _C.card] : const [Tw.indigo50, Tw.purple50],
              ),
            ),
            child: Center(
              child: Icon(BootstrapIcons.image, size: 36, color: dark ? Tw.slate700 : Tw.indigo200),
            ),
          );
    if (filePath.isNotEmpty) {
      image = unlocked
          ? AnimatedScale(
              scale: hover ? 1.05 : 1, duration: const Duration(milliseconds: 500), curve: kTwEase, child: image)
          : ColorFiltered(colorFilter: _kLockedImageFilter, child: image);
    }

    final fade = const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color.fromRGBO(0, 0, 0, 0.75), Color.fromRGBO(0, 0, 0, 0.15), Colors.transparent],
        ),
      ),
    );

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // `backdrop-filter: blur(8px)` of the locked overlay, applied to
          // what lies beneath it (image + fade).
          if (unlocked)
            image
          else
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8, tileMode: TileMode.decal),
              child: Stack(fit: StackFit.expand, children: [image, fade]),
            ),
          if (unlocked) IgnorePointer(child: fade),

          // ══ LOCKED OVERLAY ══
          if (!unlocked)
            ColoredBox(
              color: const Color.fromRGBO(8, 8, 30, 0.80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: dark ? Tw.yellow400.withValues(alpha: 0.1) : Tw.amber50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: dark ? Tw.yellow400.withValues(alpha: 0.3) : Tw.amber300.withValues(alpha: 0.6)),
                    ),
                    child: const Icon(BootstrapIcons.lock_fill, size: 24, color: Tw.yellow400),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: dark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: dark ? Tw.yellow400.withValues(alpha: 0.25) : Tw.amber300.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎟️', style: TextStyle(fontSize: 20, height: 1)),
                        const SizedBox(width: 8),
                        // two inline spans on one baseline (`leading-none`)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(tickets,
                                style: _nunito(size: 18, weight: FontWeight.w900, height: 1, color: Tw.yellow400)),
                            const SizedBox(width: 4),
                            Text('TICKETS',
                                style: _nunito(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    height: 1,
                                    spacing: 0.5,
                                    color: Tw.yellow400.withValues(alpha: 0.6))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ══ UNLOCKED PLAY HOVER OVERLAY ══
          if (unlocked)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: hover ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: kTwEase,
                child: Center(
                  child: AnimatedScale(
                    scale: hover ? 1 : 0.75,
                    duration: const Duration(milliseconds: 300),
                    curve: kTwEase,
                    // (`backdrop-blur-sm` left out: a backdrop filter inside
                    // the fading opacity layer has nothing to blur.)
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Tw.yellow400.withValues(alpha: 0.2),
                        border: Border.all(color: Tw.yellow400.withValues(alpha: 0.6), width: 2),
                        // shadow-lg (its colour modifier has no effect)
                        boxShadow: AppShadows.lg,
                      ),
                      padding: const EdgeInsets.only(left: 4),
                      child: const Icon(BootstrapIcons.play_fill, size: 24, color: Tw.yellow400),
                    ),
                  ),
                ),
              ),
            ),

          // Level Badge (top-left). `ring-1` sits outside the box, so the
          // 1 px border here starts 1 px further out.
          if (jsTruthy(activity['level']))
            Positioned(top: 11, left: 11, child: _levelBadge(activity['level'])),

          // Unlock status badge (top-right)
          if (unlocked)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dark ? Tw.green400.withValues(alpha: 0.15) : Tw.green50.withValues(alpha: 0.9),
                  // rounded-xl (20 px in this theme)
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: dark ? Tw.green400.withValues(alpha: 0.3) : Tw.green300.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(BootstrapIcons.unlock_fill, size: 10, color: dark ? Tw.green400 : Tw.green600),
                    const SizedBox(width: 4),
                    Text('Free',
                        style: _nunito(
                            size: 10, weight: FontWeight.w900, height: 1.5, color: dark ? Tw.green400 : Tw.green600)),
                  ],
                ),
              ),
            ),

          // Chapter number (top-right, locked)
          if (jsTruthy(activity['chapterNumber']) && !unlocked)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  // rounded-xl (20 px) on a 28 px box: a circle
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(jsDisplay(activity['chapterNumber']),
                    style: _nunito(size: 12, weight: FontWeight.w900, height: TwLeading.xs, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  /// `levelBadgeClass(level)`.
  Widget _levelBadge(dynamic level) {
    final Color bg, fg, ring;
    switch (level) {
      case 'beginner':
        bg = dark ? Tw.indigo500.withValues(alpha: 0.2) : Tw.indigo100;
        fg = dark ? Tw.indigo300 : Tw.indigo700;
        ring = dark ? Tw.indigo500.withValues(alpha: 0.3) : Tw.indigo300.withValues(alpha: 0.5);
      case 'intermediate':
        bg = dark ? Tw.purple500.withValues(alpha: 0.2) : Tw.purple100;
        fg = dark ? Tw.purple300 : Tw.purple700;
        ring = dark ? Tw.purple500.withValues(alpha: 0.3) : Tw.purple300.withValues(alpha: 0.5);
      case 'expert':
        bg = dark ? Tw.rose500.withValues(alpha: 0.2) : Tw.rose100;
        fg = dark ? Tw.rose300 : Tw.rose700;
        ring = dark ? Tw.rose500.withValues(alpha: 0.3) : Tw.rose300.withValues(alpha: 0.5);
      default:
        bg = dark ? Tw.slate500.withValues(alpha: 0.2) : Tw.gray100;
        fg = dark ? Tw.slate300 : Tw.gray600;
        ring = dark ? Tw.slate500.withValues(alpha: 0.2) : Tw.gray200;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        // rounded-xl (20 px) + the 1 px ring
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: ring),
      ),
      child: Text(capitalise(level),
          style: _nunito(size: 11, weight: FontWeight.w900, spacing: 0.275, height: 1.5, color: fg)),
    );
  }

  // ── CARD BODY ──
  Widget _body(BuildContext context, bool hover) {
    final unlocked = _unlocked;
    final topic = activity['topic_name'];
    final tickets = jsDisplay(activity['required_tickets_to_unlock']);

    final titleColor = unlocked
        ? (dark ? (hover ? Tw.yellow300 : Tw.slate100) : (hover ? Tw.yellow700 : Tw.gray900))
        : (dark ? Tw.slate500 : Tw.gray400);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category label row
        if (jsTruthy(topic))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _kTopicColors[topicColorIndex(jsStr(topic))],
                    // rounded-lg (16 px) on a 20 px box: a circle
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(BootstrapIcons.hash, size: 9, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    jsDisplay(topic).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _nunito(
                        size: 10,
                        weight: FontWeight.w900,
                        spacing: 1.5,
                        height: 1.5,
                        color: dark ? Tw.slate500 : Tw.gray400),
                  ),
                ),
              ],
            ),
          ),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: kTwEase,
          style: _nunito(size: 13, weight: FontWeight.w900, height: 1.375, color: titleColor),
          child: Text(jsDisplay(activity['name']), maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    final Widget actions;
    if (unlocked) {
      // ══ UNLOCKED ACTIONS ══
      final playFg = dark ? _C.ink : Tw.gray900;
      actions = Row(
        children: [
          Expanded(
            child: PressHover(
              onTap: onPlay,
              builder: (context, h, pressed) => ActiveScale(
                pressed: pressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: kTwEase,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: h ? Tw.yellow300 : Tw.yellow400,
                    borderRadius: BorderRadius.circular(16),
                    // shadow-md (its colour modifier has no effect)
                    boxShadow: AppShadows.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(BootstrapIcons.play_fill, size: 14, color: playFg),
                      const SizedBox(width: 8),
                      Text('Play',
                          style: _nunito(size: 12, weight: FontWeight.w900, height: TwLeading.xs, color: playFg)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Take Quiz',
            waitDuration: const Duration(milliseconds: 500),
            child: PressHover(
              onTap: onQuiz,
              builder: (context, h, pressed) {
                final Color qbg, qborder, qfg;
                if (dark) {
                  qbg = h ? Tw.purple500.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05);
                  qborder = h ? Tw.purple500.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.09);
                  qfg = h ? Tw.purple400 : Tw.slate500;
                } else {
                  qbg = h ? Tw.purple50 : Tw.gray100;
                  qborder = h ? Tw.purple200 : Tw.gray200;
                  qfg = h ? Tw.purple600 : Tw.gray400;
                }
                return ActiveScale(
                  pressed: pressed,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: kTwEase,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: qbg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: qborder),
                    ),
                    child: Icon(BootstrapIcons.patch_question_fill, size: 14, color: qfg),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      // ══ LOCKED ACTIONS ══
      actions = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: dark ? Tw.yellow400.withValues(alpha: 0.07) : Tw.amber50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: dark ? Tw.yellow400.withValues(alpha: 0.2) : Tw.amber200.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Text('🎟️', style: TextStyle(fontSize: 16, height: 1)),
                const SizedBox(width: 8),
                Text(tickets,
                    style: _nunito(size: 14, weight: FontWeight.w900, height: TwLeading.sm, color: Tw.yellow400)),
                const SizedBox(width: 8),
                Text('tickets',
                    style: _nunito(
                        size: 10, weight: FontWeight.w600, height: 1.5, color: Tw.yellow400.withValues(alpha: 0.6))),
                const Spacer(),
                Text('TO UNLOCK',
                    style: _nunito(
                        size: 10,
                        weight: FontWeight.w900,
                        spacing: 0.5,
                        height: 1.5,
                        color: dark ? Tw.slate600 : Tw.amber400.withValues(alpha: 0.8))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          PressHover(
            onTap: unlocking ? null : onUnlock,
            cursor: unlocking ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            builder: (context, h, pressed) {
              final fg = dark ? Tw.yellow400 : Tw.amber700;
              return ActiveScale(
                pressed: pressed,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  curve: kTwEase,
                  opacity: unlocking ? 0.6 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: kTwEase,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: dark ? Tw.yellow400.withValues(alpha: h ? 0.2 : 0.1) : (h ? Tw.amber100 : Tw.amber50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dark
                            ? Tw.yellow400.withValues(alpha: h ? 0.5 : 0.25)
                            : (h ? Tw.amber400 : Tw.amber300.withValues(alpha: 0.6)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: unlocking
                          ? [
                              SvgSpinner(size: 14, color: fg),
                              const SizedBox(width: 8),
                              Text('Unlocking…',
                                  style: _nunito(size: 12, weight: FontWeight.w900, height: TwLeading.xs, color: fg)),
                            ]
                          : [
                              Icon(BootstrapIcons.lock_fill, size: 12, color: fg),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text('Unlock with $tickets 🎟️',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        _nunito(size: 12, weight: FontWeight.w900, height: TwLeading.xs, color: fg)),
                              ),
                            ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Align(alignment: Alignment.topLeft, child: info)),
          const SizedBox(height: 12),
          actions,
        ],
      ),
    );
    return unlocked ? body : Opacity(opacity: 0.55, child: body);
  }
}
