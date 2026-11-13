part of 'student_math_zone_page.dart';

/// The three teleported modals (Why Learn, Chapter Reference, No Questions):
/// a bottom sheet below 640px, a centred card above.
extension _Dialogs on _StudentMathZonePageState {
  void _showWhyModal() {
    final accent = _accent;
    showZoneModal<_WhyModal>(
      context,
      state: _whyModal,
      isOpen: (v) => v.open,
      onDismiss: () => _whyModal.value = _whyModal.value.copyWith(open: false),
      builder: (ctx, v) => _ZoneDialog(
        maxWidth: 512,
        limitHeight: true,
        compact: false,
        icon: const [ZoneIcons.lightBulb],
        iconBg: ctx.isDark ? op(Tw.indigo500, 0.2) : Tw.indigo50,
        iconBorder: ctx.isDark ? op(Tw.indigo500, 0.3) : Tw.indigo200,
        iconColor: ctx.isDark ? Tw.indigo400 : Tw.indigo600,
        eyebrow: 'WHY LEARN THIS?',
        title: jsDisplay(v.activity?['name']),
        onClose: () => _whyModal.value = _whyModal.value.copyWith(open: false),
        footerCenter: false,
        footer: _OutlineCloseButton(
          onTap: () => _whyModal.value = _whyModal.value.copyWith(open: false),
        ),
        body: _whyBody(ctx, v, accent),
      ),
    );
  }

  Widget _whyBody(BuildContext ctx, _WhyModal v, Color accent) {
    final dark = ctx.isDark;
    final sm = ctx.isSm;
    final pad = EdgeInsets.all(sm ? 24 : 20);
    if (v.loading) return _modalLoading(ctx, accent, 'Loading content…');
    if (v.content.isNotEmpty && v.contentType == 'html') {
      return SingleChildScrollView(
        padding: pad,
        child: MzHtmlText(
          v.content,
          style: TextStyle(fontSize: 14, height: 1.625, color: dark ? Tw.gray300 : Tw.gray700),
        ),
      );
    }
    if (v.content.isNotEmpty && v.contentType == 'iframe') {
      return SizedBox(height: 380, child: WebContentView(url: v.content));
    }
    return Padding(
      padding: pad,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          'No content available for this activity yet.',
          style: TextStyle(fontSize: 14, height: 1.625, color: dark ? Tw.gray300 : Tw.gray600),
        ),
      ),
    );
  }

  void _showChapterRefModal() {
    final accent = _accent;
    showZoneModal<_ChapterRefModal>(
      context,
      state: _chapterRefModal,
      isOpen: (v) => v.open,
      onDismiss: () => _chapterRefModal.value = _chapterRefModal.value.copyWith(open: false),
      builder: (ctx, v) => _ZoneDialog(
        maxWidth: 768,
        limitHeight: true,
        compact: false,
        icon: const [ZoneIcons.documentText],
        iconBg: accent.withValues(alpha: 0x22 / 255),
        iconBorder: accent.withValues(alpha: 0x44 / 255),
        iconColor: accent,
        eyebrow: 'CHAPTER REFERENCE',
        title: v.chapterName,
        onClose: () => _chapterRefModal.value = _chapterRefModal.value.copyWith(open: false),
        footerCenter: false,
        footer: _OutlineCloseButton(
          onTap: () => _chapterRefModal.value = _chapterRefModal.value.copyWith(open: false),
        ),
        body: _chapterRefBody(ctx, v, accent),
      ),
    );
  }

  Widget _chapterRefBody(BuildContext ctx, _ChapterRefModal v, Color accent) {
    final dark = ctx.isDark;
    final sm = ctx.isSm;
    if (v.loading) return _modalLoading(ctx, accent, 'Loading chapter reference…');
    final url = v.url;
    if (url != null && url.isNotEmpty) {
      return SizedBox(height: 480, child: WebContentView(url: url));
    }
    if (jsTruthy(v.htmlContent)) {
      // `prose prose-sm sm:prose-base` is not built (no typography plugin):
      // the body's 16px / 1.5 applies.
      return SingleChildScrollView(
        padding: EdgeInsets.all(sm ? 24 : 20),
        child: MzHtmlText(
          jsDisplay(v.htmlContent),
          style: TextStyle(fontSize: 16, height: 1.5, color: dark ? Tw.gray300 : Tw.gray700),
        ),
      );
    }
    final color = dark ? Colors.white : Tw.gray600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Opacity(
        opacity: 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZoneSvgIcon(
              const [ZoneIcons.documentText],
              size: sm ? 48 : 40,
              strokeWidth: 1.5,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              'No reference material available for this chapter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoQuestionsModal() {
    final accent = _accent;
    void close() => _noQuestionsModal.value = const _NoQuestionsModal();
    showZoneModal<_NoQuestionsModal>(
      context,
      state: _noQuestionsModal,
      isOpen: (v) => v.open,
      onDismiss: close,
      builder: (ctx, v) {
        final dark = ctx.isDark;
        return _ZoneDialog(
          maxWidth: 384,
          limitHeight: false,
          compact: true,
          icon: const [ZoneIcons.warning],
          iconRound: true,
          iconBg: dark ? op(Tw.amber500, 0.2) : Tw.amber50,
          iconBorder: dark ? op(Tw.amber500, 0.3) : Tw.amber200,
          iconColor: dark ? Tw.amber400 : Tw.amber500,
          eyebrow: 'QUIZ UNAVAILABLE',
          title: v.activityName,
          onClose: close,
          footerCenter: true,
          footer: ZonePress(
            onTap: close,
            builder: (context, hover, _) => AnimatedScale(
              scale: hover ? 1.05 : 1,
              duration: const Duration(milliseconds: 150),
              child: AnimatedOpacity(
                opacity: hover ? 0.9 : 1,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF161233),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: dark ? op(Tw.amber500, 0.1) : Tw.amber50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dark ? op(Tw.amber500, 0.2) : Tw.amber100),
                  ),
                  alignment: Alignment.center,
                  child: const ZoneSvgIcon(
                    [ZoneIcons.questionCircle],
                    size: 32,
                    strokeWidth: 1.5,
                    round: true,
                    color: Tw.amber400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Questions Yet',
                  style: TextStyle(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w900,
                    color: dark ? Colors.white : Tw.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Quiz questions for this activity haven't been added yet. "
                  'Please check back later or try another activity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.625,
                    color: dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modalLoading(BuildContext ctx, Color accent, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 64),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZoneRingSpinner(
          size: 32,
          stroke: 2,
          track: accent.withValues(alpha: 0x33 / 255),
          head: accent,
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: 0.5,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: ctx.fgColor,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The shared modal panel: header (icon box, eyebrow, title, close),
/// scrollable body, footer.
class _ZoneDialog extends StatelessWidget {
  const _ZoneDialog({
    required this.maxWidth,
    required this.limitHeight,
    required this.compact,
    required this.icon,
    this.iconRound = false,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.eyebrow,
    required this.title,
    required this.onClose,
    required this.footerCenter,
    required this.footer,
    required this.body,
  });

  final double maxWidth;

  /// `max-height: 90vh` with a scrolling body.
  final bool limitHeight;

  /// The "No Questions" modal has no `sm:` size steps.
  final bool compact;
  /// Heroicon path data of the header icon.
  final List<String> icon;
  final bool iconRound;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String eyebrow;
  final String title;
  final VoidCallback onClose;
  final bool footerCenter;
  final Widget footer;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final big = sm && !compact;
    final strong = dark ? Colors.white : Tw.gray900;
    final barBg = dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50;
    final barBorder = dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100;
    final radius = sm
        ? BorderRadius.circular(32)
        : const BorderRadius.vertical(top: Radius.circular(32));
    final iconBox = big ? 40.0 : 36.0;
    final closeBox = big ? 36.0 : 32.0;

    final header = Container(
      padding: EdgeInsets.symmetric(horizontal: big ? 24 : 20, vertical: big ? 20 : 16),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(bottom: BorderSide(color: barBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: iconBorder),
            ),
            alignment: Alignment.center,
            child: ZoneSvgIcon(
              icon,
              size: compact ? 20 : (big ? 20 : 16),
              round: iconRound,
              color: iconColor,
            ),
          ),
          SizedBox(width: big ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    eyebrow,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: context.fgColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: big ? 18 : 16,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: strong,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: big ? 16 : 12),
          ZonePress(
            onTap: onClose,
            builder: (context, hover, _) => AnimatedScale(
              scale: hover ? 1.1 : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: closeBox,
                height: closeBox,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? Colors.white.withValues(alpha: hover ? 0.2 : 0.1)
                      : (hover ? Tw.gray200 : Tw.gray100),
                  border: Border.all(
                    color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray200,
                  ),
                ),
                alignment: Alignment.center,
                child: ZoneSvgIcon(
                  const [ZoneIcons.x],
                  size: compact ? 16 : (big ? 16 : 14),
                  strokeWidth: 2.5,
                  color: dark ? Colors.white : Tw.gray600,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final footerBar = Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : (big ? 24 : 20),
        compact ? 16 : (big ? 16 : 12),
        compact ? 20 : (big ? 24 : 20),
        (compact ? 16 : (big ? 16 : 12)) + (sm ? 0 : MediaQuery.paddingOf(context).bottom),
      ),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: barBorder)),
      ),
      child: Align(
        alignment: footerCenter ? Alignment.center : Alignment.centerRight,
        child: footer,
      ),
    );

    final panel = Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      constraints: limitHeight
          ? BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9)
          : const BoxConstraints(),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1340) : Colors.white,
        borderRadius: radius,
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
        // shadow-2xl (the theme's light value)
        boxShadow: AppShadows.xl2,
      ),
      child: DefaultTextStyle.merge(
        // Teleported to <body>: the body's foreground.
        style: TextStyle(color: context.fgColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Flexible(child: body),
            footerBar,
          ],
        ),
      ),
    );

    return ZoneModalScaffold(
      backdrop: const Color(0x99000000),
      blur: 8,
      alignment: sm ? Alignment.center : Alignment.bottomCenter,
      padding: EdgeInsets.all(sm ? 16 : 0),
      maxWidth: sm ? maxWidth : double.infinity,
      child: panel,
    );
  }
}

/// The footer "Close" outline button of the Why / Chapter Reference modals.
class _OutlineCloseButton extends StatelessWidget {
  const _OutlineCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    return ZonePress(
      onTap: onTap,
      builder: (context, hover, _) => AnimatedScale(
        scale: hover ? 1.05 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sm ? 20 : 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: hover
                ? (dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100)
                : Colors.transparent,
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300),
          ),
          child: Text(
            'Close',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white.withValues(alpha: 0.7) : Tw.gray600,
            ),
          ),
        ),
      ),
    );
  }
}
