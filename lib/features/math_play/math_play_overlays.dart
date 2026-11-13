part of 'math_play_page.dart';

/// UNLOCK CONFIRM MODAL and TOAST (both `fixed` on the web, so they live in
/// the root overlay), plus the page's fixed dot grid / glow background.
extension _MathPlayOverlays on _MathPlayPageState {
  // ══════════ UNLOCK CONFIRM MODAL ══════════
  Widget _buildUnlockModal(BuildContext context) {
    final dark = context.isDark;
    // A leaving <Transition> child keeps its last rendered content.
    if (_modalVisible || _modalContent == null) _modalContent = _modalPanel(dark);
    final content = _modalContent!;

    // Only the outer <Transition> animates: the inner one (scale-90 /
    // translate-y-4) is mounted together with its child and has no
    // `appear`, and on leave the whole overlay is removed at once — so the
    // overlay and the panel just fade (200 ms ease-out in, 150 ms ease-in out).
    return AnimatedBuilder(
      animation: _modal.curved,
      builder: (context, child) {
        final v = _modal.curved.value.clamp(0.0, 1.0);
        return Stack(
          children: [
            // @click.self="closeUnlockModal"
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeUnlockModal,
                // The fading `backdrop-filter: blur(10px)` as a growing blur
                // (a backdrop filter inside an opacity layer blurs nothing).
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10 * v, sigmaY: 10 * v),
                  child: ColoredBox(color: Color.fromRGBO(5, 5, 20, 0.75 * v)),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Opacity(opacity: v, child: child),
              ),
            ),
          ],
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: GestureDetector(onTap: () {}, child: content),
      ),
    );
  }

  Widget _modalPanel(bool dark) {
    final activity = _modalActivity;
    final loading = _modalLoading;
    final tickets = jsDisplay(activity?['required_tickets_to_unlock']);
    final ink = dark ? _C.ink : Tw.gray900;

    final header = Container(
      height: 112,
      decoration: BoxDecoration(
        // bg-gradient-to-br on a wide box
        gradient: CssLinearGradient(
          corner: Alignment.bottomRight,
          colors: dark
              ? [Tw.yellow400.withValues(alpha: 0.1), Tw.amber500.withValues(alpha: 0.1)]
              : const [Tw.amber50, Tw.yellow50],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          const Opacity(
            opacity: 0.08,
            child: Icon(BootstrapIcons.lock_fill, size: 128, color: Color(0xFFF59E0B)),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: dark ? Tw.yellow400.withValues(alpha: 0.15) : Tw.amber100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: dark ? Tw.yellow400.withValues(alpha: 0.3) : Tw.amber300.withValues(alpha: 0.6)),
              // shadow-xl (its colour modifier has no effect)
              boxShadow: AppShadows.xl,
            ),
            child: const Icon(BootstrapIcons.lock_fill, size: 30, color: Tw.yellow400),
          ),
        ],
      ),
    );

    // Both buttons stretch to the bordered Cancel's 46 px (flex align stretch).
    final cancel = PressHover(
      onTap: loading ? null : _closeUnlockModal,
      builder: (context, h, pressed) {
        return ActiveScale(
          pressed: pressed,
          child: Opacity(
            opacity: loading ? 0.4 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: kTwEase,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: h ? 0.08 : 0.04) : (h ? Tw.gray100 : Tw.gray50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: dark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.09)),
              ),
              child: Text('Cancel',
                  style: _nunito(
                      size: 14, weight: FontWeight.w700, height: TwLeading.sm, color: dark ? Tw.slate300 : Tw.gray600)),
            ),
          ),
        );
      },
    );

    final confirm = PressHover(
      onTap: loading ? null : _confirmUnlock,
      builder: (context, h, pressed) {
        return ActiveScale(
          pressed: pressed,
          child: Opacity(
            opacity: loading ? 0.6 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: kTwEase,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: h ? Tw.yellow300 : Tw.yellow400,
                borderRadius: BorderRadius.circular(16),
                // shadow-lg (its colour modifier has no effect)
                boxShadow: AppShadows.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: loading
                    ? [
                        SvgSpinner(size: 16, color: ink),
                        const SizedBox(width: 8),
                        Text('Unlocking…',
                            style: _nunito(size: 14, weight: FontWeight.w900, height: TwLeading.sm, color: ink)),
                      ]
                    : [
                        Icon(BootstrapIcons.unlock_fill, size: 14, color: ink),
                        const SizedBox(width: 8),
                        Text('Confirm Unlock',
                            style: _nunito(size: 14, weight: FontWeight.w900, height: TwLeading.sm, color: ink)),
                      ],
              ),
            ),
          ),
        );
      },
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? _C.card : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: dark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.09)),
        // shadow-2xl (its colour modifier has no effect)
        boxShadow: AppShadows.xl2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Unlock Activity',
                    textAlign: TextAlign.center,
                    style: _nunito(
                        size: 16, weight: FontWeight.w900, height: TwLeading.base, color: dark ? Colors.white : Tw.gray900)),
                const SizedBox(height: 6),
                Text(jsDisplay(activity?['name']),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _nunito(
                        size: 14, weight: FontWeight.w600, height: TwLeading.sm, color: dark ? Tw.slate400 : Tw.gray500)),
                const SizedBox(height: 12),
                // Ticket cost callout
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: dark ? Tw.yellow400.withValues(alpha: 0.08) : Tw.amber50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dark ? Tw.yellow400.withValues(alpha: 0.25) : Tw.amber200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎟️', style: TextStyle(fontSize: 24, height: 1)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tickets,
                                style: _nunito(size: 20, weight: FontWeight.w900, height: 1, color: Tw.yellow400)),
                            const SizedBox(height: 2),
                            Text('TICKETS REQUIRED',
                                style: _nunito(
                                    size: 10,
                                    weight: FontWeight.w900,
                                    spacing: 0.5,
                                    height: 1.5,
                                    color: Tw.yellow400.withValues(alpha: 0.6))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Error message
                if (_modalError != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: dark ? Tw.red500.withValues(alpha: 0.1) : Tw.red50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dark ? Tw.red500.withValues(alpha: 0.25) : Tw.red200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(BootstrapIcons.exclamation_circle_fill,
                              size: 14, color: dark ? Tw.red400 : Tw.red600),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_modalError!,
                              style: _nunito(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  height: 1.625,
                                  color: dark ? Tw.red400 : Tw.red600)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Actions
                Row(
                  children: [
                    Expanded(child: cancel),
                    const SizedBox(width: 10),
                    Expanded(child: confirm),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════ TOAST ══════════
  Widget _buildToast(BuildContext context) {
    final dark = context.isDark;
    final success = _toastType == 'success';
    final bottom = 24 + MediaQuery.paddingOf(context).bottom;
    // `fixed left-1/2 -translate-x-1/2 min-w-[260px] max-w-sm`: shrink-to-fit
    // within the half of the viewport right of `left: 50%`.
    final halfWidth = MediaQuery.sizeOf(context).width / 2;
    final maxW = halfWidth < 260 ? 260.0 : (halfWidth > 384 ? 384.0 : halfWidth);

    // Shrink-to-fit width; the text column is `flex-1`, so the close button
    // sits at the right edge even at the 260 px minimum.
    final toast = IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 260, maxWidth: maxW),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: success
                ? (dark ? const Color(0xFF0D1F1A) : Colors.white)
                : (dark ? const Color(0xFF1A0F0F) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: success
                  ? (dark ? Tw.green400.withValues(alpha: 0.3) : Tw.green300.withValues(alpha: 0.6))
                  : (dark ? Tw.red500.withValues(alpha: 0.3) : Tw.red300.withValues(alpha: 0.6)),
            ),
            // shadow-2xl (its colour modifier has no effect)
            boxShadow: AppShadows.xl2,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: success
                      ? (dark ? Tw.green400.withValues(alpha: 0.15) : Tw.green50)
                      : (dark ? Tw.red500.withValues(alpha: 0.15) : Tw.red50),
                  // rounded-xl (20 px) on a 32 px box
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(success ? BootstrapIcons.unlock_fill : BootstrapIcons.x_circle_fill,
                    size: 14, color: success ? Tw.green400 : Tw.red400),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(success ? 'Activity Unlocked!' : 'Unlock Failed',
                        style: _nunito(
                          size: 12,
                          weight: FontWeight.w900,
                          height: 1,
                          color: success
                              ? (dark ? Tw.green300 : Tw.green700)
                              : (dark ? Tw.red300 : Tw.red700),
                        )),
                    const SizedBox(height: 2),
                    Text(_toastMessage,
                        style: _nunito(
                            size: 11, weight: FontWeight.w500, height: 1.375, color: dark ? Tw.slate400 : Tw.gray500)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              HoverBuilder(
                onTap: _hideToast,
                builder: (context, h) => SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(BootstrapIcons.x,
                      size: 14,
                      color: dark ? (h ? Tw.slate400 : Tw.slate600) : (h ? Tw.gray500 : Tw.gray300)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: 16,
          right: 16,
          bottom: bottom,
          child: Center(
            child: IgnorePointer(
              ignoring: !_toastVisible,
              child: AnimatedBuilder(
                animation: _toast.curved,
                builder: (context, child) {
                  final v = _toast.curved.value.clamp(0.0, 1.0);
                  return Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - v)),
                      child: Transform.scale(scale: 0.95 + 0.05 * v, child: child),
                    ),
                  );
                },
                child: toast,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The fixed dot grid and the two blurred glow blobs behind the page.
class _PageBackdrop extends StatelessWidget {
  const _PageBackdrop({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: ClipRect(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotGridPainter(
                        dark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.06)),
                  ),
                ),
                Positioned(
                  top: -200,
                  right: -100,
                  width: 600,
                  height: 600,
                  child: CustomPaint(
                    painter: _BlobPainter(
                        (dark ? Tw.purple700 : Tw.purple300).withValues(alpha: 0.2), 120),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: -100,
                  width: 400,
                  height: 400,
                  child: CustomPaint(
                    painter: _BlobPainter((dark ? Tw.indigo600 : Tw.indigo200).withValues(alpha: 0.1), 100),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// `radial-gradient(circle, color 1px, transparent 1px)` every 32 px.
class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      for (var y = 16.0; y < size.height; y += 32)
        for (var x = 16.0; x < size.width; x += 32) Offset(x, y),
    ];
    canvas.drawPoints(
      ui.PointMode.points,
      points,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

/// `rounded-full blur-[Npx]` blob.
class _BlobPainter extends CustomPainter {
  _BlobPainter(this.color, this.blur);
  final Color color;
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.color != color || old.blur != blur;
}
