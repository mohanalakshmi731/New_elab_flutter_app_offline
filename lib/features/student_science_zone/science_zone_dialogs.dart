part of 'student_science_zone_page.dart';

const _dialogDarkBg = Color(0xFF1A1340);

/// The Why-to-Learn and Chapter-Reference dialogs (teleported
/// `fixed inset-0` layers: a bottom sheet below 640px, centred above).
/// Teleported to `<body>`, they use the app font and `--foreground` text,
/// not the page's Inter / white text.
extension _ScienceZoneDialogs on _StudentScienceZonePageState {
  Widget _live(Widget Function(BuildContext context) builder) => ValueListenableBuilder<int>(
        valueListenable: _rev,
        builder: (context, _, _) => builder(context),
      );

  /// `bg-black/60` + `backdrop-filter: blur(8px)`, click outside closes;
  /// `modal-fade` (opacity + scale .96, or translateY(40px) below 640px).
  Route<void> _modalRoute(Widget Function(BuildContext context) builder) => PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'Close',
        barrierColor: Colors.black.withValues(alpha: 0.6),
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => _live(builder),
        transitionsBuilder: (context, anim, _, child) {
          final a = CurvedAnimation(parent: anim, curve: Curves.ease);
          final sm = context.isSm;
          return FadeTransition(
            opacity: a,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: a,
                  builder: (context, child) => sm
                      ? Transform.scale(scale: 0.96 + 0.04 * a.value, child: child)
                      : Transform.translate(offset: Offset(0, 40 * (1 - a.value)), child: child),
                  child: child,
                ),
              ],
            ),
          );
        },
      );

  void _showWhyRoute() {
    if (_whyRoute != null) return;
    final route = _modalRoute(_whyBox);
    _whyRoute = route;
    Navigator.of(context, rootNavigator: true).push(route).then((_) {
      if (identical(_whyRoute, route)) _whyRoute = null;
      _set(() => _whyModal.open = false);
    });
  }

  void _closeWhy() {
    final r = _whyRoute;
    _whyRoute = null;
    _set(() => _whyModal.open = false);
    if (r != null && r.isActive) r.navigator?.pop();
  }

  void _showChapterRefRoute() {
    if (_chapterRefRoute != null) return;
    final route = _modalRoute(_chapterRefBox);
    _chapterRefRoute = route;
    Navigator.of(context, rootNavigator: true).push(route).then((_) {
      if (identical(_chapterRefRoute, route)) _chapterRefRoute = null;
      _set(() => _chapterRefModal.open = false);
    });
  }

  void _closeChapterRef() {
    final r = _chapterRefRoute;
    _chapterRefRoute = null;
    _set(() => _chapterRefModal.open = false);
    if (r != null && r.isActive) r.navigator?.pop();
  }

  /// Shared dialog frame: header (icon, eyebrow, title, ×), body, Close.
  /// `w-full sm:max-w-* rounded-t-[2rem] sm:rounded-[2rem] shadow-2xl border`,
  /// `max-height: 90vh`.
  Widget _dialogFrame(
    BuildContext context, {
    required double maxWidth,
    required Widget icon,
    required String eyebrow,
    required String title,
    required VoidCallback onClose,
    required Widget body,
  }) {
    final dark = context.isDark;
    final sm = context.isSm;
    final size = MediaQuery.sizeOf(context);
    final barBg = dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50;
    final barBorder = BorderSide(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100);
    final radius = sm
        ? BorderRadius.circular(32)
        : const BorderRadius.vertical(top: Radius.circular(32));
    final gap = sm ? 16.0 : 12.0;

    final box = Container(
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(maxHeight: size.height * 0.9),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: dark ? _dialogDarkBg : Colors.white,
        borderRadius: radius,
        boxShadow: AppShadows.xl2,
      ),
      // The border stays above the clipped header/footer bars.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: context.fgColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 20, vertical: sm ? 20 : 16),
                decoration: BoxDecoration(color: barBg, border: Border(bottom: barBorder)),
                child: Row(
                  children: [
                    icon,
                    SizedBox(width: gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: 0.4,
                            child: Text(eyebrow.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    height: 1.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: sm ? 18 : 16,
                              height: 1.25,
                              fontWeight: FontWeight.w900,
                              color: dark ? Colors.white : Tw.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: gap),
                    _RoundCloseButton(onTap: onClose, size: sm ? 36 : 32),
                  ],
                ),
              ),
              Flexible(child: SingleChildScrollView(child: body)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 20, vertical: sm ? 16 : 12),
                decoration: BoxDecoration(color: barBg, border: Border(top: barBorder)),
                alignment: Alignment.centerRight,
                child: _DialogCloseButton(onTap: onClose),
              ),
            ],
          ),
        ),
      ),
    );

    // Taps outside the box fall through to the dismissible barrier.
    return sm
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: box),
            ),
          )
        : Align(alignment: Alignment.bottomCenter, child: box);
  }

  /// `w-9 h-9 sm:w-10 sm:h-10 rounded-xl border` header icon tile.
  Widget _iconTile(BuildContext context,
      {required String icon, required Color bg, required Color border, required Color fg}) {
    final sm = context.isSm;
    return Container(
      width: sm ? 40 : 36,
      height: sm ? 40 : 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        color: bg,
        border: Border.all(color: border),
      ),
      child: _HeroIcon(icon, size: sm ? 20 : 16, color: fg),
    );
  }

  Widget _loadingBody(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            const _AccentSpinner(size: 32, stroke: 2),
            const SizedBox(height: 16),
            Opacity(
              opacity: 0.5,
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  // ══ WHY TO LEARN DIALOG ══

  Widget _whyBox(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final m = _whyModal;
    Widget body;
    if (m.loading) {
      body = _loadingBody('Loading content…');
    } else if (m.content.isNotEmpty && m.contentType == 'html') {
      body = Padding(
        padding: EdgeInsets.all(sm ? 24 : 20),
        child: MzHtmlText(
          m.content,
          style: TextStyle(fontSize: 14, height: 1.625, color: dark ? Tw.gray300 : Tw.gray700),
        ),
      );
    } else if (m.content.isNotEmpty && m.contentType == 'iframe') {
      body = SizedBox(height: 380, child: WebContentView(url: m.content));
    } else {
      body = Padding(
        padding: EdgeInsets.all(sm ? 24 : 20),
        child: Opacity(
          opacity: 0.6,
          child: Text('No content available for this activity yet.',
              style: TextStyle(fontSize: 14, height: 1.625, color: dark ? Tw.gray300 : Tw.gray600)),
        ),
      );
    }
    return _dialogFrame(
      context,
      maxWidth: 512,
      icon: _iconTile(
        context,
        icon: HeroPaths.lightBulb,
        bg: dark ? Tw.indigo500.withValues(alpha: 0.2) : Tw.indigo50,
        border: dark ? Tw.indigo500.withValues(alpha: 0.3) : Tw.indigo200,
        fg: dark ? Tw.indigo400 : Tw.indigo600,
      ),
      eyebrow: 'Why Learn This?',
      title: jsDisplay(m.activity?['name']),
      onClose: _closeWhy,
      body: body,
    );
  }

  // ══ CHAPTER REFERENCE DIALOG ══

  Widget _chapterRefBox(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final m = _chapterRefModal;
    Widget body;
    if (m.loading) {
      body = _loadingBody('Loading chapter reference…');
    } else if (jsTruthy(m.url)) {
      body = SizedBox(height: 480, child: WebContentView(url: m.url!));
    } else if (jsTruthy(m.htmlContent)) {
      body = SizedBox(
        height: 480,
        child: WebContentView(html: _referenceDocument(m.htmlContent!, dark: dark, sm: sm)),
      );
    } else {
      final color = dark ? Colors.white : Tw.gray600;
      body = Opacity(
        opacity: 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            children: [
              _HeroIcon(HeroPaths.document, size: sm ? 48 : 40, strokeWidth: 1.5, color: color),
              const SizedBox(height: 12),
              Text('No reference material available for this chapter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      );
    }
    return _dialogFrame(
      context,
      maxWidth: 768,
      icon: _iconTile(
        context,
        icon: HeroPaths.document,
        bg: _accent.withValues(alpha: 0x22 / 255),
        border: _accent.withValues(alpha: 0x44 / 255),
        fg: _accent,
      ),
      eyebrow: 'Chapter Reference',
      title: jsDisplay(_activeChapter?['name']),
      onClose: _closeChapterRef,
      body: body,
    );
  }
}

/// `v-html` of the chapter reference inside the dialog: `p-5 sm:p-6
/// text-gray-700 dark:text-gray-300` on the dialog background. The `prose`
/// classes do nothing (no typography plugin), so the HTML keeps Tailwind's
/// preflight reset plus the global `ul`/`ol` rules, at the body's 16px / 1.5.
String _referenceDocument(String html, {required bool dark, required bool sm}) {
  final bg = dark ? '#1a1340' : '#ffffff';
  final color = dark ? '#d1d5db' : '#374151';
  final font = dark
      ? 'Inter, ui-sans-serif, sans-serif, system-ui'
      : "'Plus Jakarta Sans', 'Outfit', Inter, ui-sans-serif, sans-serif, system-ui";
  final pad = sm ? 24 : 20;
  return '<!doctype html><html><head><meta charset="utf-8">'
      '<meta name="viewport" content="width=device-width, initial-scale=1"><style>'
      '*,::before,::after{box-sizing:border-box;margin:0;padding:0;border:0 solid}'
      'html,body{background:$bg}'
      'body{padding:${pad}px;color:$color;font-family:$font;font-size:16px;line-height:1.5}'
      'h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}'
      'a{color:inherit;text-decoration:inherit}'
      'img,svg,video,canvas,iframe{display:block;vertical-align:middle}'
      'img,video{max-width:100%;height:auto}'
      'table{border-collapse:collapse;text-indent:0;border-color:inherit}'
      'ul{list-style-type:disc;margin-left:2rem}ol{list-style-type:decimal;margin-left:2rem}'
      '</style></head><body>$html</body></html>';
}

/// The round × button of the dialog headers (`rounded-full border
/// hover:scale-110`, × `w-3.5 h-3.5 sm:w-4 sm:h-4` stroke 2.5).
class _RoundCloseButton extends StatelessWidget {
  const _RoundCloseButton({required this.onTap, required this.size});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedScale(
        scale: hovered ? 1.1 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dark
                ? Colors.white.withValues(alpha: hovered ? 0.2 : 0.1)
                : (hovered ? Tw.gray200 : Tw.gray100),
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray200),
          ),
          child: _HeroIcon(HeroPaths.x,
              size: size >= 36 ? 16 : 14, strokeWidth: 2.5, color: dark ? Colors.white : Tw.gray600),
        ),
      ),
    );
  }
}

/// The footer "Close" button (`px-4 sm:px-5 py-2 rounded-xl text-sm
/// font-bold border hover:scale-105`).
class _DialogCloseButton extends StatelessWidget {
  const _DialogCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedScale(
        scale: hovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sm ? 20 : 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            color: hovered
                ? (dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100)
                : Colors.transparent,
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300),
          ),
          child: Text('Close',
              style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white.withValues(alpha: 0.7) : Tw.gray600)),
        ),
      ),
    );
  }
}
