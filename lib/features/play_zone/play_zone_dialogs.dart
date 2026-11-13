part of 'play_zone_page.dart';

/// UNLOCK CONFIRM MODAL and TOAST.
extension _PlayDialogs on _PlayZonePageState {
  void _showUnlockModal() {
    showZoneModal<_UnlockModal>(
      context,
      state: _unlockModal,
      isOpen: (v) => v.visible,
      onDismiss: _closeUnlockModal,
      transition: ZoneModalTransition.pop,
      builder: (ctx, v) => ZoneModalScaffold(
        backdrop: const Color.fromRGBO(5, 5, 20, 0.75),
        blur: 10,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        maxWidth: 384,
        child: _UnlockPanel(
          modal: v,
          text: _t,
          onCancel: _closeUnlockModal,
          onConfirm: _confirmUnlock,
        ),
      ),
    );
  }

  // ══════════ TOAST ══════════
  Widget _toastView(bool dark) {
    final success = _toast.type == 'success';
    final visible = _toast.visible;
    final Color bg;
    final Color border;
    if (success) {
      bg = dark ? const Color(0xFF0D1F1A) : Colors.white;
      border = dark ? op(Tw.green400, 0.3) : op(Tw.green300, 0.6);
    } else {
      bg = dark ? const Color(0xFF1A0F0F) : Colors.white;
      border = dark ? op(Tw.red500, 0.3) : op(Tw.red300, 0.6);
    }

    final toast = Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 384),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        // shadow-2xl (the theme's value; colour modifiers have no effect)
        boxShadow: AppShadows.xl2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: success
                  ? (dark ? op(Tw.green400, 0.15) : Tw.green50)
                  : (dark ? op(Tw.red500, 0.15) : Tw.red50),
              // rounded-xl (20px) on a 32px box
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              success ? BootstrapIcons.unlock_fill : BootstrapIcons.x_circle_fill,
              size: 14,
              color: success ? Tw.green400 : Tw.red400,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  success ? 'Activity Unlocked!' : 'Unlock Failed',
                  style: _t(
                    12,
                    FontWeight.w900,
                    success ? (dark ? Tw.green300 : Tw.green700) : (dark ? Tw.red300 : Tw.red700),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _toast.message,
                  style: _t(11, FontWeight.w500, dark ? Tw.slate400 : Tw.gray500, height: 1.375),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ZonePress(
            onTap: _hideToast,
            builder: (context, hover, _) => SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                BootstrapIcons.x,
                size: 14,
                color: dark
                    ? (hover ? Tw.slate400 : Tw.slate600)
                    : (hover ? Tw.gray500 : Tw.gray300),
              ),
            ),
          ),
        ],
      ),
    );

    // enter: duration-300 ease-out from opacity-0 translate-y-4 scale-95;
    // leave: duration-200 ease-in back to it.
    return IgnorePointer(
      ignoring: !visible,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: visible ? 1 : 0),
          duration: Duration(milliseconds: visible ? 300 : 200),
          curve: visible ? const Cubic(0, 0, 0.2, 1) : const Cubic(0.4, 0, 1, 1),
          builder: (context, v, child) => v <= 0
              ? const SizedBox.shrink()
              : Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - v)),
                    child: Transform.scale(scale: 0.95 + 0.05 * v, child: child),
                  ),
                ),
          child: toast,
        ),
      ),
    );
  }
}

/// The unlock confirmation card.
class _UnlockPanel extends StatelessWidget {
  const _UnlockPanel({
    required this.modal,
    required this.text,
    required this.onCancel,
    required this.onConfirm,
  });

  final _UnlockModal modal;
  final _TextFn text;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final t = text;
    final activity = modal.activity;
    final loading = modal.loading;
    final error = modal.error;
    final required = jsDisplay(activity?['required_tickets_to_unlock']);

    final top = Container(
      height: 112,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [op(Tw.yellow400, 0.1), op(Tw.amber500, 0.1)]
              : const [Tw.amber50, Tw.yellow50],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          // opacity-8 background lock (font-size: 8rem; color #f59e0b)
          const Opacity(
            opacity: 0.08,
            child: Icon(BootstrapIcons.lock_fill, size: 128, color: Color(0xFFF59E0B)),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: dark ? op(Tw.yellow400, 0.15) : Tw.amber100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dark ? op(Tw.yellow400, 0.3) : op(Tw.amber300, 0.6)),
              // shadow-xl (the theme's value; colour modifiers have no effect)
              boxShadow: AppShadows.xl,
            ),
            child: const Icon(BootstrapIcons.lock_fill, size: 30, color: Tw.yellow400),
          ),
        ],
      ),
    );

    final info = Column(
      children: [
        Text(
          'Unlock Activity',
          style: t(16, FontWeight.w900, dark ? Colors.white : Tw.gray900, height: 1.5),
        ),
        const SizedBox(height: 6),
        Text(
          jsDisplay(activity?['name']),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: t(14, FontWeight.w600, dark ? Tw.slate400 : Tw.gray500, height: 20 / 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: dark ? op(Tw.yellow400, 0.08) : Tw.amber50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? op(Tw.yellow400, 0.25) : Tw.amber200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎟️', style: t(24, FontWeight.w400, null, height: 1)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(required, style: t(20, FontWeight.w900, Tw.yellow400, height: 1)),
                  const SizedBox(height: 2),
                  Text(
                    'TICKETS REQUIRED',
                    style: t(10, FontWeight.w900, op(Tw.yellow400, 0.6), height: 1.5, spacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final buttons = Row(
      children: [
        Expanded(
          child: ZonePress(
            onTap: onCancel,
            enabled: !loading,
            builder: (context, hover, pressed) => Opacity(
              opacity: loading ? 0.4 : 1,
              child: AnimatedScale(
                scale: pressed ? 0.95 : 1,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withValues(alpha: hover && !loading ? 0.08 : 0.04)
                        : (hover && !loading ? Tw.gray100 : Tw.gray50),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.black.withValues(alpha: 0.09),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: t(14, FontWeight.w700, dark ? Tw.slate300 : Tw.gray600, height: 20 / 14),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ZonePress(
            onTap: onConfirm,
            enabled: !loading,
            builder: (context, hover, pressed) {
              final fg = dark ? const Color(0xFF0D0D2B) : Tw.gray900;
              return Opacity(
                opacity: loading ? 0.6 : 1,
                child: AnimatedScale(
                  scale: pressed ? 0.95 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: hover && !loading ? Tw.yellow300 : Tw.yellow400,
                      borderRadius: BorderRadius.circular(16),
                      // shadow-lg (the theme's value)
                      boxShadow: AppShadows.lg,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: loading
                          ? [
                              ZoneButtonSpinner(size: 16, color: fg),
                              const SizedBox(width: 8),
                              Text(
                                'Unlocking…',
                                style: t(14, FontWeight.w900, fg, height: 20 / 14),
                              ),
                            ]
                          : [
                              Icon(BootstrapIcons.unlock_fill, size: 14, color: fg),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Confirm Unlock',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t(14, FontWeight.w900, fg, height: 20 / 14),
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF13133A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.09),
        ),
        // shadow-2xl (the theme's value; colour modifiers have no effect)
        boxShadow: AppShadows.xl2,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            top,
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  info,
                  if (error != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: dark ? op(Tw.red500, 0.1) : Tw.red50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dark ? op(Tw.red500, 0.25) : Tw.red200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              BootstrapIcons.exclamation_circle_fill,
                              size: 14,
                              color: dark ? Tw.red400 : Tw.red600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error,
                              style: t(
                                12,
                                FontWeight.w600,
                                dark ? Tw.red400 : Tw.red600,
                                height: 1.625,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  buttons,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
