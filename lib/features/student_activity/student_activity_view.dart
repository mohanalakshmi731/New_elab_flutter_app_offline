part of 'student_activity_page.dart';

// CSS variables of src/style.css (.dark) that the template reads.
const _borderColorVar = Color(0xFF95A3FF); // --border-color
const _cardBorderVar = Color(0xFF2E3B5E); // --card-border

/// Main template of `studentactivitypage.vue`.
///
/// Note: `bg-card-bg` / `dark:bg-card-bg` isn't a Tailwind colour in the web
/// build (no `--color-card-bg`), so the tab bar and the content panel stay
/// `bg-white` in dark mode, and the tab buttons keep `bg-muted`.
extension _StudentActivityView on _StudentActivityPageState {
  double _viewerHeight(BuildContext context) =>
      math.max(240.0, MediaQuery.sizeOf(context).height - 56 - 64 - 48);

  Widget _buildPage(BuildContext context) {
    final viewerH = _viewerHeight(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _topNav(context),
          if (!_ready || _pageLoading)
            _loadingState(context, viewerH)
          else ...[
            if (_hasActivities) _viewer(context, viewerH) else _noActivityState(context, viewerH),
            if (_hasActivities) _tabsSection(context),
          ],
        ],
      ),
    );
  }

  // ===== TOP NAV =====

  Widget _topNav(BuildContext context) {
    final sm = context.isSm;
    final w = context.screenWidth;
    final title =
        _selectedActivity != null ? activityTitle(_selectedActivity) : 'Topic - $_topicName';
    // text-sm sm:text-base md:text-lg lg:text-xl (font-size / line-height).
    final titleSize = w >= 1024 ? 20.0 : (w >= 768 ? 18.0 : (sm ? 16.0 : 14.0));
    final titleLine = w >= 768 ? 28.0 : (sm ? 24.0 : 20.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _BackCircleButton(
            size: sm ? 40 : 32,
            iconSize: sm ? 18 : 16,
            onTap: () {
              final ctx = _zsl.selectedActivityContext;
              final returnPath = ctx?['returnPath'];
              context.go(jsTruthy(returnPath)
                  ? jsDisplay(returnPath)
                  : '/newlayout/teachersdashboardpage');
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleSize,
                  height: titleLine / titleSize,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          // RIGHT: Lightbulb + Folder — `hidden` in the web template.
          Visibility(
            visible: false,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SquareIconButton(
                  icon: BootstrapIcons.lightbulb,
                  size: sm ? 40 : 32,
                  onTap: _showLearningOutcomeModal,
                ),
                if (!_isFromPlayZone) ...[
                  const SizedBox(width: 8),
                  _SquareIconButton(
                    icon: BootstrapIcons.folder,
                    size: sm ? 40 : 32,
                    onTap: _showSidebar,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== MAIN CONTENT =====

  Widget _loadingState(BuildContext context, double height) {
    final dark = context.isDark;
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // `text-4xl` icon (40px line box) + mb-3
          const SizedBox(height: 40, child: SpinIcon(size: 36, color: AppColors.accent)),
          const SizedBox(height: 12),
          Text('Loading activity...',
              style: TextStyle(fontSize: 16, height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
        ],
      ),
    );
  }

  /// The activity player (`<iframe :src="signedUrl">`) — also hosted by the
  /// fullscreen layer, so it is keyed to move without reloading.
  Widget _activityFrame() => KeyedSubtree(
        key: _frameKey,
        child: BridgedWebView(
          url: _signedUrl,
          onMessage: _handleIframeMessage,
          onXpChannel: _onXpChannelMessage,
        ),
      );

  /// `bg-black/50 hover:bg-black/70 text-white rounded-lg text-sm px-3 py-2`
  /// (a native `<button>`: default cursor).
  Widget _fullscreenButton() => HoverBuilder(
        onTap: _toggleFullscreen,
        cursor: SystemMouseCursors.basic,
        builder: (context, hovered) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: hovered ? 0.7 : 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: SizedBox(
            height: 20,
            child: Icon(
              _isFullscreen ? BootstrapIcons.x_lg : BootstrapIcons.arrows_fullscreen,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget _viewer(BuildContext context, double height) {
    final md = context.isMd;
    return SizedBox(
      height: height,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: md ? 0.8 : 1,
          heightFactor: 1,
          child: Stack(
            children: [
              // While fullscreen the wrapper (player + button) lives in the
              // fullscreen layer.
              if (!_isFullscreen) ...[
                if (_signedUrl.isNotEmpty) Positioned.fill(child: _activityFrame()),
                Positioned(bottom: 8, right: 12, child: _fullscreenButton()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The wrapper element while it is the fullscreen element.
  Widget _fullscreenLayer(BuildContext context) {
    if (!mounted || !_isFullscreen) return const ColoredBox(color: Colors.black);
    return Material(
      color: Colors.black,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, e) {
          if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
            _exitFullscreen();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: Stack(
            children: [
              if (_signedUrl.isNotEmpty) Positioned.fill(child: _activityFrame()),
              Positioned(bottom: 8, right: 12, child: _fullscreenButton()),
            ],
          ),
        ),
      ),
    );
  }

  // NO ACTIVITY STATE
  Widget _noActivityState(BuildContext context, double height) {
    final dark = context.isDark;
    final sm = context.isSm;
    final browse = _PillButton(
      icon: BootstrapIcons.folder,
      label: 'Browse Other Topics',
      expand: !sm,
      onTap: _showSidebar,
    );
    final back = _PillButton(
      icon: BootstrapIcons.arrow_left,
      label: 'Back to Library',
      expand: !sm,
      onTap: () => context.go('/library'),
    );
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // text-6xl icon (line box 60px)
                  SizedBox(
                    height: 60,
                    child: Icon(BootstrapIcons.inboxes,
                        size: 60, color: dark ? Tw.gray600 : Tw.gray300),
                  ),
                  const SizedBox(height: 24),
                  Text('No Activities Available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          height: 28 / 20,
                          fontWeight: FontWeight.w600,
                          color: dark ? Tw.gray300 : Tw.gray700)),
                  const SizedBox(height: 8),
                  Text('There are no activities available for this topic.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
                  if (_topicName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'Topic: '),
                        TextSpan(text: _topicName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, height: 20 / 14, color: dark ? Tw.gray400 : Tw.gray500),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // sm+: inline buttons side by side (no whitespace between
                  // them in the template); below sm: stacked, space-y-3.
                  if (sm)
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 12,
                      children: [browse, back],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [browse, const SizedBox(height: 12), back],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== TABS + CONTENT =====

  Widget _tabsSection(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final tabs = _tabs.where((t) => !(_isFromPlayZone && t.key == 'quiz')).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TAB BUTTONS
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: dark ? _borderColorVar : Tw.gray100)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      tab: tabs[i],
                      active: _activeTab == tabs[i].key,
                      showLabel: sm,
                      onTap: () => _fire(() => _handleTabClick(tabs[i].key)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_activeTab != null && _activeTab != 'quiz') _tabContentPanel(context),
          if (_activeTab == 'quiz') _quizPanel(context),
        ],
      ),
    );
  }

  /// `rounded-xl border border-gray-200 dark:border-(--border-color) bg-white
  /// shadow-sm` (`dark:bg-card-bg` isn't generated).
  BoxDecoration _panelDecoration(BuildContext context) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: context.isDark ? _borderColorVar : Tw.gray200),
        boxShadow: AppShadows.sm,
      );

  // NON-QUIZ TAB CONTENT PANEL
  Widget _tabContentPanel(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final content = _activeTabContent;
    Widget body;
    if (_tabContentLoading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinIcon(size: 24, color: AppColors.accent),
            const SizedBox(width: 8),
            Text('Loading...',
                style: TextStyle(
                    fontSize: 14, height: 20 / 14, color: dark ? Tw.gray400 : Tw.gray500)),
          ],
        ),
      );
    } else if (content.text.isNotEmpty || content.url.isNotEmpty) {
      final vw = context.screenWidth;
      body = Padding(
        padding: EdgeInsets.all(sm ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (content.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: _cardDecoration(context),
                // IsolatedHtmlContent: a 500px `<iframe srcdoc>` on white.
                child: content.text.trim().isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 500,
                        child: ColoredBox(
                          color: Colors.white,
                          child: WebContentView(html: isolatedHtml(content.text)),
                        ),
                      ),
              ),
            if (content.url.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: _cardDecoration(context, border: true),
                child: SizedBox(
                  height: (vw * 0.5).clamp(300.0, 500.0),
                  child: WebContentView(url: content.url),
                ),
              ),
          ],
        ),
      );
    } else {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(BootstrapIcons.inbox, size: 48, color: dark ? Tw.gray500 : Tw.gray400),
            const SizedBox(height: 12),
            Text('No data to show',
                style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: dark ? Tw.gray500 : Tw.gray400)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: _panelDecoration(context),
        child: body,
      ),
    );
  }

  /// shadcn `<Card>` — `bg-card shadow-sm`, `rounded-none`; the text card is
  /// `border-0`, the iframe card keeps the kit's `border` (`--border`).
  BoxDecoration _cardDecoration(BuildContext context, {bool border = false}) => BoxDecoration(
        color: context.isDark ? AppColors.darkCard : Colors.white,
        border: border ? Border.all(color: context.borderColor) : null,
        boxShadow: AppShadows.sm,
      );

  // QUIZ PANEL (its tab is commented out in the web template)
  Widget _quizPanel(BuildContext context) {
    final dark = context.isDark;
    Widget body;
    if (_quizSubmitted) {
      final result = asMap(_quizResult);
      body = Column(
        children: [
          const Icon(BootstrapIcons.check_circle, size: 48, color: Tw.green500),
          const SizedBox(height: 12),
          Text(jsDisplay(result?['msg']),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: '🎟 Tickets Earned: '),
              TextSpan(
                text: jsDisplay(result?['tickets']),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ]),
            style: const TextStyle(fontSize: 14, color: Tw.gray500),
          ),
          const SizedBox(height: 16),
          _AccentButton(label: 'Retry Quiz', onTap: _resetQuiz),
        ],
      );
    } else if (!_quizStarted) {
      body = Column(
        children: [
          const Icon(BootstrapIcons.play_circle, size: 48, color: AppColors.accent),
          const SizedBox(height: 12),
          const Text('Start Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Click below to load questions',
              style: TextStyle(fontSize: 14, color: Tw.gray500)),
          const SizedBox(height: 16),
          _AccentButton(label: 'Start Quiz', onTap: () => _fire(_startQuiz)),
        ],
      );
    } else if (_quizLoading) {
      body = const Column(
        children: [
          SpinIcon(size: 30, color: AppColors.accent),
          SizedBox(height: 8),
          Text('Loading questions...', style: TextStyle(fontSize: 14)),
        ],
      );
    } else if (_quizQuestions.isEmpty) {
      body = Column(
        children: [
          Icon(BootstrapIcons.patch_question, size: 36, color: dark ? Tw.gray400 : Tw.gray500),
          const SizedBox(height: 12),
          Text('No quiz questions available.',
              style: TextStyle(fontSize: 14, color: dark ? Tw.gray400 : Tw.gray500)),
        ],
      );
    } else {
      body = const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: _panelDecoration(context),
        child: body,
      ),
    );
  }
}

/// `IsolatedHtmlContent` renders the HTML as its own document (browser
/// default black text on white), whatever the app or OS theme.
String isolatedHtml(String content) =>
    '<div style="color:#000;background:#fff">$content</div>';

// ── small widgets ─────────────────────────────────────────────────────────

/// `border rounded-full w-8 h-8 sm:w-10 sm:h-10 hover:bg-muted hover:text-primary`.
class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.size, required this.iconSize, required this.onTap});
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      onTap: onTap,
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hovered ? (dark ? AppColors.darkMuted : AppColors.muted) : Colors.transparent,
          border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Icon(
          BootstrapIcons.chevron_left,
          size: iconSize,
          color: hovered ? context.colors.primary : context.fgColor,
        ),
      ),
    );
  }
}

/// The hidden lightbulb / folder buttons of the top nav.
class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.size, required this.onTap});
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      onTap: onTap,
      builder: (context, hovered) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dark ? null : AppColors.muted,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: hovered ? AppColors.accent : (dark ? _borderColorVar : Tw.gray200)),
        ),
        child: Icon(icon,
            size: size >= 40 ? 24 : 20,
            color: hovered ? AppColors.accent : (dark ? Colors.white : null)),
      ),
    );
  }
}

/// A tab button of the tab bar.
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.active,
    required this.showLabel,
    required this.onTap,
  });
  final _TabDef tab;
  final bool active;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // A native `<button>` without `cursor-pointer`: default cursor.
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) {
        final Color fg;
        final Color bg;
        final Color border;
        if (active) {
          fg = Colors.white;
          bg = AppColors.accent;
          border = AppColors.accent;
        } else {
          fg = hovered ? AppColors.accent : (dark ? Tw.gray300 : Tw.gray600);
          bg = dark ? AppColors.darkMuted : AppColors.muted;
          border = hovered ? AppColors.accent : (dark ? _borderColorVar : Tw.gray200);
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // rounded-lg; `shadow-sm` (it also wins over the active
          // `shadow-md`: Tailwind emits shadow-sm after shadow-md).
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: border),
            boxShadow: AppShadows.sm,
          ),
          // The icon's `text-sm` line box (20px) sets the height.
          child: SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 14, color: fg),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tab.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: fg),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `<Button variant="outline|ghost" class="w-full sm:w-auto cursor-pointer
/// hover:bg-muted hover:text-primary p-3 rounded-full">`. The page never
/// registers the shadcn `Button`, so the browser renders a plain `<button>`
/// with only these classes: no border or background, inherited 16px text,
/// `hover:bg-muted hover:text-primary` (both variants look the same).
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.expand,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      onTap: onTap,
      builder: (context, hovered) {
        final fg = hovered ? context.colors.primary : context.fgColor;
        return Container(
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hovered ? context.mutedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // `<i class="bi … mr-2">`
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 16, height: 1.5, color: fg)),
            ],
          ),
        );
      },
    );
  }
}

/// `px-4 py-2 bg-accent text-white rounded-lg` (native `<button>`: default
/// cursor, no hover style).
class _AccentButton extends StatelessWidget {
  const _AccentButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        onTap: onTap,
        cursor: SystemMouseCursors.basic,
        builder: (context, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
        ),
      );
}
