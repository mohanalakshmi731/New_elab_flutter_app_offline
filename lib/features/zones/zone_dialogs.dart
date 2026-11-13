part of 'zones_page.dart';

/// The "Quiz Unavailable" and "Start Quiz" modals (teleported overlays:
/// bottom sheet below 640px, centred `sm:max-w-sm` card above).
extension _Dialogs on _ZonePageState {
  /// `modal-fade`: opacity + scale(.96), 0.25s ease (translateY(40px) at
  /// `max-width: 640px`).
  Future<void> _showZoneModal(Widget Function(BuildContext dialogContext) builder) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, _, _) => builder(dialogContext),
      transitionBuilder: (dialogContext, anim, _, child) {
        final t = Curves.ease.transform(anim.value);
        return Opacity(
          opacity: t,
          child: dialogContext.screenWidth > 640
              ? Transform.scale(scale: 0.96 + 0.04 * t, child: child)
              : Transform.translate(offset: Offset(0, 40 * (1 - t)), child: child),
        );
      },
    );
  }

  /// `noQuestionsModal.open = true` + `activityName`.
  void _openNoQuestions(String activityName) {
    if (!mounted) return;
    final dark = context.isDark;
    final primary = context.colors.primary;
    final science = !_isMath;

    // Science: bg-green-500/20 border-green-500/30 text-green-400 (dark),
    // bg-green-50 border-green-200 text-green-500 (light).
    final iconColor = science ? (dark ? Tw.green400 : Tw.green500) : primary;
    _showZoneModal((dialogContext) => _ZoneModal(
          label: 'Quiz Unavailable',
          title: activityName,
          headerIcon: SvgStrokeIcon(ZoneSvg.warning, size: 20, color: iconColor, strokeWidth: 2, round: true),
          iconBg: science
              ? (dark ? Tw.green500.withValues(alpha: 0.2) : Tw.green50)
              : primary.withValues(alpha: dark ? 0.2 : 0.05),
          iconBorder: science
              ? (dark ? Tw.green500.withValues(alpha: 0.3) : Tw.green200)
              : primary.withValues(alpha: dark ? 0.3 : 0.2),
          bodyPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          body: Column(
            children: [
              // w-16 h-16 rounded-2xl (16px) border; svg w-8 h-8 text-yellow-400 / text-green-400
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: dark ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withValues(alpha: dark ? 0.2 : 0.1)),
                ),
                child: SvgStrokeIcon(ZoneSvg.question,
                    size: 32, color: science ? Tw.green400 : Tw.yellow400, strokeWidth: 1.5, round: true),
              ),
              const SizedBox(height: 16),
              Text('No Questions Yet',
                  style: zt(18, FontWeight.w900, dark ? Colors.white : Tw.gray900, height: 28 / 18)),
              const SizedBox(height: 4),
              Text(
                "Quiz questions for this activity haven't been added yet. "
                'Please check back later or try another activity.',
                textAlign: TextAlign.center,
                style: zt(14, FontWeight.w400,
                    dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray500,
                    height: 1.625),
              ),
            ],
          ),
          footerAlignment: MainAxisAlignment.center,
          footer: [
            _ModalPrimaryButton(
              label: 'Got it',
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              onTap: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ));
  }

  /// `goToQuiz(activity)` → `startQuizConfirmModal.open = true`.
  void _openStartQuizConfirm(Json activity) {
    if (!mounted) return;
    final dark = context.isDark;
    final primary = context.colors.primary;

    _showZoneModal((dialogContext) => _ZoneModal(
          label: 'Start Quiz',
          title: jsStr(activity['name']) ?? '',
          // bi-patch-question-fill text-lg
          headerIcon: Icon(BootstrapIcons.patch_question_fill, size: 18, color: primary),
          iconBg: primary.withValues(alpha: dark ? 0.2 : 0.05),
          iconBorder: primary.withValues(alpha: dark ? 0.3 : 0.2),
          bodyPadding: const EdgeInsets.all(24),
          body: Text(
            'Are you ready to start the quiz? You will be presented with questions to '
            'test your understanding of this activity.',
            textAlign: TextAlign.center,
            style: zt(14, FontWeight.w400,
                dark ? Colors.white.withValues(alpha: 0.75) : Tw.gray600,
                height: 1.625),
          ),
          footerAlignment: MainAxisAlignment.end,
          footer: [
            _ModalOutlineButton(
              label: 'Cancel',
              onTap: () => Navigator.of(dialogContext).pop(),
            ),
            const SizedBox(width: 12),
            _ModalPrimaryButton(
              label: "Let's Start",
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              onTap: () {
                // confirmStartQuiz(): close the modal, then start the quiz.
                Navigator.of(dialogContext).pop();
                _confirmStartQuiz(activity);
              },
            ),
          ],
        ));
  }
}

class _ZoneModal extends StatelessWidget {
  const _ZoneModal({
    required this.label,
    required this.title,
    required this.headerIcon,
    required this.iconBg,
    required this.iconBorder,
    required this.body,
    required this.bodyPadding,
    required this.footer,
    required this.footerAlignment,
  });

  final String label;
  final String title;

  /// The icon inside the `w-9 h-9` header box.
  final Widget headerIcon;
  final Color iconBg;
  final Color iconBorder;
  final Widget body;
  final EdgeInsets bodyPadding;
  final List<Widget> footer;
  final MainAxisAlignment footerAlignment;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    void close() => Navigator.of(context).pop();

    final barBg = dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50;
    final barBorder = dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100;
    final radius = sm
        ? BorderRadius.circular(32)
        : const BorderRadius.vertical(top: Radius.circular(32));
    final strong = dark ? Colors.white : Tw.gray900;

    final card = Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF13133A) : Colors.white,
          borderRadius: radius,
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
          boxShadow: AppShadows.xl2, // shadow-2xl (the theme's)
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: context.colors.onSurface),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: barBg, border: Border(bottom: BorderSide(color: barBorder))),
                child: Row(
                  children: [
                    // w-9 h-9 rounded-xl: 20px radii on a 36px box are
                    // scaled down to 18 (a circle), as in CSS.
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: iconBorder),
                      ),
                      child: headerIcon,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: 0.4,
                            child: Text(label.toUpperCase(),
                                style: zt(10, FontWeight.w900, context.colors.onSurface,
                                    spacing: 1, height: 1.5)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: zt(16, FontWeight.w900, strong, height: 1.25),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ZoneHover(
                      onTap: close,
                      builder: (context, hover) => AnimatedScale(
                        scale: hover ? 1.1 : 1,
                        duration: const Duration(milliseconds: 150),
                        curve: kTwEase,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark
                                ? Colors.white.withValues(alpha: hover ? 0.2 : 0.1)
                                : (hover ? Tw.gray200 : Tw.gray100),
                            border: Border.all(
                                color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray200),
                          ),
                          alignment: Alignment.center,
                          child: SvgStrokeIcon(ZoneSvg.close,
                              size: 16, color: dark ? Colors.white : Tw.gray600, strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: bodyPadding,
                  child: body,
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, 16 + (sm ? 0 : MediaQuery.paddingOf(context).bottom)),
                decoration: BoxDecoration(color: barBg, border: Border(top: BorderSide(color: barBorder))),
                child: Row(mainAxisAlignment: footerAlignment, children: footer),
              ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // @click.self → close; bg-black/60 + backdrop-filter: blur(8px)
        Positioned.fill(
          child: GestureDetector(
            onTap: close,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const ColoredBox(color: Color(0x99000000)),
            ),
          ),
        ),
        Align(
          alignment: sm ? Alignment.center : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(sm ? 16 : 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sm ? 384 : double.infinity),
              child: card,
            ),
          ),
        ),
      ],
    );
  }
}

/// `bg-primary text-primary-foreground font-black rounded-xl` with
/// `hover:scale-105 hover:opacity-90`.
class _ModalPrimaryButton extends StatelessWidget {
  const _ModalPrimaryButton({required this.label, required this.padding, required this.onTap});
  final String label;
  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ZonePressable(
      onTap: onTap,
      hoverScale: 1.05,
      pressScale: 1,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: zt(14, FontWeight.w900, colors.onPrimary, height: 20 / 14)),
      ),
    );
  }
}

/// The modal's bordered "Cancel" button.
class _ModalOutlineButton extends StatelessWidget {
  const _ModalOutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return ZoneHover(
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: kTwEase,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: hover
              ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
        ),
        child: Text(label,
            style: zt(14, FontWeight.w700, dark ? Colors.white : Tw.gray700, height: 20 / 14)),
      ),
    );
  }
}
