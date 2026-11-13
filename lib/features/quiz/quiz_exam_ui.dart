part of 'quiz_exam.dart';


/// The template of `QuizExam.vue`.
extension _QuizExamUi on _QuizExamViewState {
  Widget _buildOverlay(BuildContext context) {
    final dark = context.isDark;
    return PopScope(
      // popstate → history.pushState while the security listeners are on.
      canPop: !_securityOn,
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _blockKeys,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: Material(
            color: dark ? Tw.slate950 : Tw.slate50,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: dark ? Tw.slate100 : Tw.slate900),
              child: AnimatedBuilder(
                animation: _shake,
                builder: (context, child) =>
                    Transform.translate(offset: Offset(_shakeOffset(), 0), child: child),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _header(context),
                          if (!_isScannerPluginMode) _slimProgress(context),
                          Expanded(
                            child: _isScannerPluginMode
                                ? BridgedWebView(
                                    url: widget.scannerUrl,
                                    onMessage: _handleScannerPluginMessage,
                                  )
                                : _questionMain(context),
                          ),
                          if (!_isScannerPluginMode) _footer(context),
                        ],
                      ),
                      if (!_isScannerPluginMode) ...[
                        _layer(_confirmOpen,
                            barrier: Colors.black.withValues(alpha: 0.6),
                            blur: 8,
                            child: _confirmDialog(context)),
                        _layer(_screenBlocked,
                            barrier: Colors.black.withValues(alpha: 0.9),
                            blur: 24,
                            child: _graceBox(context)),
                        _layer(_securityDialog,
                            barrier: const Color.fromRGBO(30, 0, 0, 0.95),
                            blur: 24,
                            child: _terminatedBox(context)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `@keyframes shake` — 0, -6, 6, -4, 4, 0 px over 0.5s.
  double _shakeOffset() {
    if (!_shake.isAnimating) return 0;
    const xs = [0.0, -6.0, 6.0, -4.0, 4.0, 0.0];
    final t = _shake.value * 5;
    final i = t.floor().clamp(0, 4);
    return ui.lerpDouble(xs[i], xs[i + 1], Curves.ease.transform((t - i).clamp(0.0, 1.0)))!;
  }

  // ══════ TOPBAR ══════

  Widget _header(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final primary = context.colors.primary;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: 14),
          decoration: BoxDecoration(
            color: dark
                ? Tw.slate900.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                  color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary.withValues(alpha: 0.2)),
                      ),
                      child: Text('QUIZ',
                          style: TextStyle(
                              color: primary,
                              fontSize: 10.4,
                              height: 1.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.04)),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.quizTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: sm ? 16.8 : 15.2,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: dark ? Colors.white : Tw.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Opacity(
                            opacity: 0.6,
                            child: Text('$_total questions',
                                style: const TextStyle(
                                    fontSize: 10.4, height: 1.25, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isScannerPluginMode) ...[
                const SizedBox(width: 16),
                _progressRing(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// SVG ring (r=18, stroke 3, `stroke-dasharray: progressCircle 113`).
  Widget _progressRing(BuildContext context) {
    final dark = context.isDark;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: quizStepFraction(_currentStep, _total)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
            builder: (_, v, _) => CustomPaint(
              size: const Size(44, 44),
              painter: _QuizRingPainter(
                fraction: v,
                track: dark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                color: context.colors.primary,
              ),
            ),
          ),
          Text(
            '$_currentStep/$_total',
            style: TextStyle(
              fontSize: 10.4,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white.withValues(alpha: 0.9) : Tw.slate800,
            ),
          ),
        ],
      ),
    );
  }

  // ══════ SLIM PROGRESS ══════

  Widget _slimProgress(BuildContext context) {
    final dark = context.isDark;
    return Container(
      height: 3,
      color: dark ? Tw.slate900 : Tw.slate100,
      alignment: Alignment.centerLeft,
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        widthFactor: quizProgressPercent(_answeredCount, _total) / 100,
        heightFactor: 1,
        child: ColoredBox(color: context.colors.primary),
      ),
    );
  }

  // ══════ MAIN BODY ══════

  Widget _questionMain(BuildContext context) {
    final q = _currentQuestion;
    final sm = context.isSm;
    return SingleChildScrollView(
      controller: _scroll,
      padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: sm ? 32 : 24),
      child: q == null ? const SizedBox.shrink() : _questionCard(context, q),
    );
  }

  Widget _questionCard(BuildContext context, Map<String, dynamic> q) {
    final dark = context.isDark;
    final sm = context.isSm;
    final primary = context.colors.primary;
    final answered = _isAnswered(q);
    final options = quizOptions(q);

    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: answered
            ? (dark ? Tw.emerald950.withValues(alpha: 0.2) : Tw.emerald50)
            : (dark ? Tw.amber950.withValues(alpha: 0.2) : Tw.amber50),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: answered
              ? (dark ? Tw.emerald900.withValues(alpha: 0.4) : Tw.emerald100)
              : (dark ? Tw.amber900.withValues(alpha: 0.4) : Tw.amber100),
        ),
      ),
      child: Text(
        answered ? '✓ Answered' : '◯ Unanswered',
        style: TextStyle(
          fontSize: 12,
          height: 1.33,
          fontWeight: FontWeight.w700,
          color: answered
              ? (dark ? Tw.emerald400 : Tw.emerald600)
              : (dark ? Tw.amber400 : Tw.amber600),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sm ? 32 : 24),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200.withValues(alpha: 0.8)),
        // `shadow-xl` (the theme's; `shadow-slate-100` has no effect).
        boxShadow: AppShadows.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status row
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text('QUESTION',
                        style: TextStyle(
                            fontSize: 10.4,
                            height: 1.5,
                            letterSpacing: 1.04,
                            fontWeight: FontWeight.w700,
                            color: Tw.slate400)),
                    const SizedBox(width: 8),
                    Text(quizStepLabel(_currentStep),
                        style: TextStyle(
                            fontSize: 28, height: 1, fontWeight: FontWeight.w900, color: primary)),
                  ],
                ),
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100),
          const SizedBox(height: 24),
          // Question text (v-html)
          MzHtmlText(
            quizQuestionHtml(q),
            style: TextStyle(
              fontSize: 16.8,
              height: 1.625,
              fontWeight: FontWeight.w600,
              color: dark ? Tw.slate100 : Tw.slate800,
            ),
          ),
          const SizedBox(height: 24),
          // Options
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _optionTile(context, q, options[i], i),
          ],
          const SizedBox(height: 40),
          _navigation(context),
        ],
      ),
    );
  }

  Widget _optionTile(
      BuildContext context, Map<String, dynamic> q, Map<String, dynamic> option, int index) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final answered = _isAnswered(q);
    final correct = quizOptionIsCorrect(option);
    final chosen = _isChosen(q, option);
    final showRemarks = answered && (chosen || correct);

    return HoverBuilder(
      onTap: answered ? null : () => _onOptionSelect(q, option),
      cursor: answered ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: (context, hovered) {
        Color border;
        Color bg;
        var opacity = 1.0;
        var shadow = false;
        if (answered) {
          if (correct) {
            border = Tw.emerald500;
            bg = Tw.emerald500.withValues(alpha: 0.05);
            shadow = true;
          } else if (chosen) {
            border = Tw.red500;
            bg = Tw.red500.withValues(alpha: 0.05);
            shadow = true;
          } else {
            border = dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200;
            bg = dark ? Tw.slate900.withValues(alpha: 0.1) : Tw.slate50.withValues(alpha: 0.3);
            opacity = 0.6;
          }
        } else if (chosen) {
          border = primary;
          bg = primary.withValues(alpha: 0.05);
          shadow = true;
        } else if (dark) {
          border = hovered ? Tw.slate700 : Tw.slate800;
          bg = Tw.slate900.withValues(alpha: hovered ? 0.3 : 0.2);
        } else {
          border = hovered ? Tw.slate300 : Tw.slate200;
          bg = hovered ? Tw.slate100.withValues(alpha: 0.4) : Tw.slate50.withValues(alpha: 0.5);
        }

        // Letter badge
        Color badgeBg;
        Color badgeBorder;
        Color badgeFg;
        // `shadow-lg shadow-…/20`: only the theme's black shadow applies.
        var badgeShadow = false;
        if (answered && correct) {
          badgeBg = badgeBorder = Tw.emerald500;
          badgeFg = Colors.white;
          badgeShadow = true;
        } else if (answered && chosen) {
          badgeBg = badgeBorder = Tw.red500;
          badgeFg = Colors.white;
          badgeShadow = true;
        } else if (answered) {
          badgeBg = dark ? Tw.slate800 : Tw.slate100;
          // `border-slate-750` isn't a Tailwind colour → the base layer's
          // `border-border`.
          badgeBorder = dark ? AppColors.darkBorder : Tw.slate200;
          badgeFg = dark ? Tw.slate500 : Tw.slate400;
        } else if (chosen) {
          badgeBg = badgeBorder = primary;
          badgeFg = Colors.white;
          badgeShadow = true;
        } else {
          badgeBg = dark ? Tw.slate800 : Tw.slate100;
          badgeBorder = dark ? Tw.slate700 : Tw.slate200;
          badgeFg = dark ? Tw.slate400 : Tw.slate600;
        }

        final remarksColor = correct
            ? (dark ? Tw.emerald400 : Tw.emerald600)
            : (dark ? Tw.red400 : Tw.red600);

        final trailing = answered
            ? Text(
                correct ? '✓' : (chosen ? '✗' : ''),
                style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w700,
                  color: correct ? Tw.emerald500 : Tw.red500,
                ),
              )
            : AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: chosen ? 1 : 0,
                child: Text('✓', style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
              );

        return Opacity(
          opacity: opacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.5),
              boxShadow: shadow ? AppShadows.md : const [],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      // rounded-xl (20) on a 32px box → 16.
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: badgeBorder),
                      boxShadow: badgeShadow ? AppShadows.lg : const [],
                    ),
                    child: Text(
                      quizOptionLabel(option, index),
                      style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w900, color: badgeFg),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quizOptionText(option),
                            style: TextStyle(
                              fontSize: 15.68,
                              height: 1.625,
                              fontWeight: FontWeight.w500,
                              color: dark ? Tw.slate200 : null,
                            ),
                          ),
                          if (showRemarks) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (correct ? Tw.emerald500 : Tw.red500).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: (correct ? Tw.emerald500 : Tw.red500)
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Opacity(
                                    opacity: 0.8,
                                    child: Text(
                                      (correct ? 'Explanation (Correct)' : 'Explanation (Your Choice)')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        height: 1.5,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w900,
                                        color: remarksColor,
                                      ),
                                    ),
                                  ),
                                  // `gap-0.5` + `mt-0.5`
                                  const SizedBox(height: 4),
                                  Text(
                                    quizOptionRemarks(option),
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.625,
                                      fontWeight: FontWeight.w500,
                                      color: remarksColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [trailing],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navigation(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final last = _currentStep >= _total;
    return Row(
      children: [
        _QuizButton(
          label: '← Prev',
          onTap: _currentStep == 1 ? null : () => _goToStep(_currentStep - 1),
          background: dark ? Tw.slate800 : Tw.slate100,
          hoverBackground: dark ? Tw.slate700 : Tw.slate200,
          foreground: dark ? Tw.slate300 : Tw.slate700,
          border: dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate200.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          fontWeight: FontWeight.w900,
          disabledOpacity: 0.3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 1; i <= (_total < 9 ? _total : 9); i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep == i ? primary : (dark ? Tw.slate800 : Tw.slate200),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!last)
          _QuizButton(
            label: 'Next →',
            onTap: () => _goToStep(_currentStep + 1),
            background: primary,
            hoverBackground: primary.withValues(alpha: 0.9),
            foreground: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            fontWeight: FontWeight.w900,
            shadow: true,
          )
        else
          _QuizButton(
            label: 'Submit →',
            onTap: () => _set(() => _confirmOpen = true),
            background: Tw.emerald600,
            hoverBackground: Tw.emerald700,
            foreground: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            fontWeight: FontWeight.w900,
            shadow: true,
          ),
      ],
    );
  }

  // ══════ FOOTER ══════

  Widget _footer(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final primary = context.colors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: 16),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        border: Border(top: BorderSide(color: dark ? Tw.slate800 : Tw.slate200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$_answeredCount',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: dark ? Tw.emerald400 : Tw.emerald600),
                ),
                const TextSpan(text: ' of '),
                TextSpan(
                  text: '$_total',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: dark ? Colors.white : Tw.slate800),
                ),
                const TextSpan(text: ' answered'),
              ]),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: dark ? Tw.slate400 : Tw.slate500,
              ),
            ),
          ),
          _QuizButton(
            label: 'Submit Quiz',
            onTap: () => _set(() => _confirmOpen = true),
            background: primary,
            hoverBackground: primary.withValues(alpha: 0.9),
            foreground: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            fontWeight: FontWeight.w700,
            shadow: true,
          ),
        ],
      ),
    );
  }

  // ══════ OVERLAYS ══════

  /// A `fixed inset-0 … backdrop-blur` layer that fades in/out (200/150ms).
  Widget _layer(bool visible, {required Color barrier, required double blur, required Widget child}) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: visible ? 200 : 150),
          opacity: visible ? 1 : 0,
          child: visible
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: ColoredBox(
                      color: barrier,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// `rounded-3xl border shadow-2xl` (the theme's `0 1px 3px rgb(0 0 0/.25)`).
  BoxDecoration _boxDecoration({required Color color, required Color border}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: AppShadows.xl2,
      );

  Widget _confirmDialog(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final n = _total;
    final answered = _answeredCount;
    final strong = TextStyle(fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate800);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _boxDecoration(
          color: dark ? Tw.slate900 : Colors.white,
          border: dark ? Tw.slate800 : Tw.slate200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 36, height: 40 / 36)),
            const SizedBox(height: 12),
            Text('Submit Quiz?',
                style: TextStyle(
                    fontSize: 18,
                    height: 1.55,
                    fontWeight: FontWeight.w900,
                    color: dark ? Colors.white : Tw.slate900)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: "You've answered "),
                TextSpan(text: '$answered', style: strong),
                const TextSpan(text: ' of '),
                TextSpan(text: '$n', style: strong),
                const TextSpan(text: ' questions.'),
              ]),
              textAlign: TextAlign.center,
              // `text-slate-505` isn't a Tailwind colour → inherited.
              style: TextStyle(fontSize: 12, height: 1.625, color: dark ? Tw.slate400 : Tw.slate900),
            ),
            const SizedBox(height: 8),
            if (answered < n)
              Text('${n - answered} question(s) still unanswered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w700,
                      color: dark ? Tw.amber400 : Tw.amber600))
            else
              Text('All questions answered ✓',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w700,
                      color: dark ? Tw.emerald400 : Tw.emerald600)),
            const SizedBox(height: 8),
            const Text('This action cannot be undone.',
                style: TextStyle(fontSize: 10, height: 1.5, color: Tw.slate400)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuizButton(
                    label: 'Go Back',
                    onTap: () => _set(() => _confirmOpen = false),
                    background: Colors.transparent,
                    // `dark:hover:bg-slate-850` / `dark:text-slate-355` aren't
                    // Tailwind colours, so `hover:bg-slate-50 text-slate-700`
                    // apply in dark mode too.
                    hoverBackground: Tw.slate50,
                    foreground: Tw.slate700,
                    border: dark ? Tw.slate800 : Tw.slate200,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    fontWeight: FontWeight.w700,
                    expand: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuizButton(
                    label: _isSubmitting ? 'Submitting...' : 'Submit Now',
                    onTap: _isSubmitting ? null : _submitQuiz,
                    background: primary,
                    hoverBackground: primary.withValues(alpha: 0.9),
                    foreground: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    fontWeight: FontWeight.w700,
                    shadow: true,
                    disabledOpacity: 0.6,
                    expand: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownCircle(int value, {required Color border, required Color text}) => _Pulse(
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 3),
          ),
          child: Text('$value',
              style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w900, color: text)),
        ),
      );

  Widget _graceBox(BuildContext context) {
    final primary = context.colors.primary;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: _boxDecoration(color: Tw.slate900, border: Tw.slate800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48, height: 1)),
            const SizedBox(height: 16),
            const Text('Tab Switch Detected!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(children: [
                TextSpan(text: 'You left the quiz window.\nReturn now or the quiz will be '),
                TextSpan(
                    text: 'auto-submitted.',
                    style: TextStyle(color: Tw.red400, fontWeight: FontWeight.w700)),
              ]),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.625, color: Tw.slate400),
            ),
            const SizedBox(height: 24),
            _countdownCircle(_graceCountdown, border: Tw.amber400, text: Tw.amber300),
            const SizedBox(height: 8),
            Text('Auto-submitting in ${_graceCountdown}s…',
                style: const TextStyle(
                    fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.amber400)),
            const SizedBox(height: 24),
            _QuizButton(
              label: "I'm Back — Resume Quiz",
              onTap: _cancelViolation,
              background: primary,
              hoverBackground: primary.withValues(alpha: 0.9),
              foreground: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              shadow: true,
              expand: true,
            ),
            const SizedBox(height: 16),
            const Text('This is your only warning. Next violation = instant submission.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, height: 1.5, color: Tw.slate500)),
          ],
        ),
      ),
    );
  }

  Widget _terminatedBox(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: _boxDecoration(color: Tw.slate900, border: Tw.red900.withValues(alpha: 0.4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚫', style: TextStyle(fontSize: 48, height: 1)),
              const SizedBox(height: 16),
              const Text('Quiz Terminated',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w800, color: Tw.red400)),
              const SizedBox(height: 12),
              const Text(
                'Multiple security violations detected.\nYour attempt has been automatically submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.625, color: Tw.slate400),
              ),
              const SizedBox(height: 24),
              _countdownCircle(_exitCountdown, border: Tw.red500, text: Tw.red400),
              const SizedBox(height: 8 + 12),
              Text('Closing in ${_exitCountdown}s…',
                  style: const TextStyle(fontSize: 10, height: 1.5, color: Tw.slate500)),
            ],
          ),
        ),
      );
}

/// A `rounded-xl text-xs` button with a hover colour, `active:scale-95`,
/// the theme's `shadow-md` (its coloured `shadow-…/10` has no effect) and
/// `disabled:opacity-*`.
class _QuizButton extends StatefulWidget {
  const _QuizButton({
    required this.label,
    required this.onTap,
    required this.background,
    required this.hoverBackground,
    required this.foreground,
    required this.padding,
    this.border,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w700,
    this.shadow = false,
    this.disabledOpacity = 0.5,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Color background;
  final Color hoverBackground;
  final Color foreground;
  final EdgeInsets padding;
  final Color? border;
  final double fontSize;
  final FontWeight fontWeight;
  final bool shadow;
  final double disabledOpacity;
  final bool expand;

  @override
  State<_QuizButton> createState() => _QuizButtonState();
}

class _QuizButtonState extends State<_QuizButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final enabled = w.onTap != null;
    return Opacity(
      opacity: enabled ? 1 : w.disabledOpacity,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: w.onTap,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          child: AnimatedScale(
            scale: enabled && _pressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: w.expand ? double.infinity : null,
              padding: w.padding,
              decoration: BoxDecoration(
                color: enabled && _hover ? w.hoverBackground : w.background,
                borderRadius: BorderRadius.circular(20),
                border: w.border == null ? null : Border.all(color: w.border!),
                boxShadow: w.shadow ? AppShadows.md : const [],
              ),
              child: Text(
                w.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w.fontSize,
                  height: w.fontSize == 12 ? 16 / 12 : 20 / 14,
                  fontWeight: w.fontWeight,
                  color: w.foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `animate-pulse` (opacity 1 → .5 → 1 every 2s).
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final v = t < 0.5 ? t * 2 : (1 - t) * 2;
          return Opacity(opacity: 1 - 0.5 * Curves.easeInOut.transform(v), child: child);
        },
        child: widget.child,
      );
}

class _QuizRingPainter extends CustomPainter {
  _QuizRingPainter({required this.fraction, required this.track, required this.color});
  final double fraction;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 44;
    final c = Offset(size.width / 2, size.height / 2);
    final r = 18 * s;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s
        ..color = track,
    );
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -1.5707963267948966,
        // dasharray `progressCircle 113` on a 113.1-long circle.
        6.283185307179586 * (fraction.clamp(0.0, 1.0) * 113 / 113.097),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * s
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_QuizRingPainter old) =>
      old.fraction != fraction || old.track != track || old.color != color;
}
