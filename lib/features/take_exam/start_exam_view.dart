import 'dart:math' as math;
import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_dialog.dart' show DialogCloseButton;
import '../mathzoro/mz_html_text.dart';
import '../schedules/schedule_exam_logic.dart' show jsStr;
import 'exam_style.dart';
import 'proctor_panel_view.dart' show ExamCheckbox;
import 'start_exam_logic.dart';

String _text(Object? v) => v == null ? '' : jsStr(v);

// ══════ TOPBAR ══════

class ExamTopBar extends StatelessWidget {
  const ExamTopBar({
    super.key,
    required this.name,
    required this.code,
    required this.currentStep,
    required this.total,
    required this.progressCircle,
    required this.timeText,
    required this.timeWarning,
    required this.timeCritical,
  });

  final String name;
  final String code;
  final int currentStep;
  final int total;

  /// `progressCircle` (0…113)
  final double progressCircle;
  final String timeText;
  final bool timeWarning;
  final bool timeCritical;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = timeCritical
        ? (Ex.red900.withValues(alpha: 0.3), Ex.red500, Ex.red300)
        : timeWarning
            ? (Ex.amber900.withValues(alpha: 0.2), Ex.amber400, Ex.amber400)
            : (Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.15), Colors.white);

    Widget timer = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⏱', style: TextStyle(fontSize: 14, height: 20 / 14, color: fg)),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.45,
              color: fg,
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Consolas', 'Menlo', 'Courier New'],
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    if (timeCritical) timer = ExamPulse(child: timer);

    return Container(
      color: Ex.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          // `flex items-center justify-between gap-4`: the ring sits halfway
          // between the title block and the timer.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Ex.blue, borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                        'EXAM',
                        style: TextStyle(
                          fontSize: 9.6,
                          letterSpacing: 0.96,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600, height: 1.25, color: Colors.white)),
                          Text(code,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10.4, height: 1.25, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProgressRing(progress: progressCircle, label: '$currentStep/$total'),
              ),
              timer,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.label});
  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress),
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
        builder: (_, value, child) => CustomPaint(painter: _RingPainter(value), child: child),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 9.6, color: Colors.white)),
        ),
      ),
    );
  }
}

/// `<circle r="18" stroke-dasharray="${progressCircle} 113">` rotated −90°.
class _RingPainter extends CustomPainter {
  const _RingPainter(this.dash);
  final double dash;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 44;
    final center = Offset(22 * scale, 22 * scale);
    final r = 18 * scale;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * scale
        ..color = Colors.white.withValues(alpha: 0.15),
    );
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round
      ..color = Ex.blue;
    final circumference = 2 * math.pi * 18;
    final len = dash.clamp(0, circumference).toDouble();
    if (len <= 0.0001) {
      // A zero-length dash with a round cap still paints a dot.
      canvas.drawCircle(Offset(center.dx, center.dy - r), 1.5 * scale, arc..style = PaintingStyle.fill);
      return;
    }
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2, len / 18, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.dash != dash;
}

/// `animate-pulse` — opacity 1 → .5 → 1 every 2 s.
class ExamPulse extends StatefulWidget {
  const ExamPulse({super.key, required this.child});
  final Widget child;

  @override
  State<ExamPulse> createState() => _ExamPulseState();
}

class _ExamPulseState extends State<ExamPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final k = const Cubic(0.4, 0, 0.6, 1).transform(t < 0.5 ? t * 2 : (1 - t) * 2);
        return Opacity(opacity: 1 - 0.5 * k, child: child);
      },
      child: widget.child,
    );
  }
}

/// `h-[3px] bg-[#e2dfd8]` with the answered-percentage bar.
class ExamSlimProgress extends StatelessWidget {
  const ExamSlimProgress({super.key, required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: Ex.line,
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: fraction.clamp(0, 1).toDouble()),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (_, v, _) => FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: const ColoredBox(color: Ex.blue),
        ),
      ),
    );
  }
}

// ══════ CARDS ══════

/// shadcn `<Card>` with the page's classes.
class ExamCard extends StatelessWidget {
  const ExamCard({super.key, required this.child, required this.padding, required this.radius});
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.exCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Ex.line),
        boxShadow: AppShadows.sm,
      ),
      child: DefaultTextStyle.merge(style: TextStyle(color: context.exCardForeground), child: child),
    );
  }
}

/// The identity-verification card shown until the proctor panel is ready.
class ExamIntroCard extends StatelessWidget {
  const ExamIntroCard({super.key, required this.accepted, required this.onAccepted, this.fill = false});

  final bool accepted;
  final ValueChanged<bool> onAccepted;

  /// `h-full` inside the xl two-column layout.
  final bool fill;

  static const _rules = [
    'Do NOT exit Fullscreen mode.',
    'Do NOT switch tabs or minimize browser.',
    'Do NOT use mobile phones or tablets.',
    'Do NOT let others enter camera view.',
    'Do NOT use system shortcuts (Alt+Tab).',
    'Do NOT look away or cover your face.',
  ];

  @override
  Widget build(BuildContext context) {
    final muted = context.exMuted;
    final twoCols = context.isSm;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Ex.blueSoft, borderRadius: BorderRadius.circular(20)),
              child: const Icon(BootstrapIcons.camera_video, size: 20, color: Ex.blue),
            ),
          ),
          Text(
            'IDENTITY VERIFICATION REQUIRED',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.4, height: 1.5, fontWeight: FontWeight.w600, letterSpacing: 1.04, color: muted),
          ),
          const SizedBox(height: 4),
          const Text(
            'Capture your reference photo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: Ex.ink),
          ),
          const SizedBox(height: 6),
          Text(
            'The exam will unlock after you capture a clear face photo from the Proctor AI panel. '
            'Keep the browser in fullscreen for the entire attempt.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: muted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Ex.red50.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Ex.red200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(BootstrapIcons.exclamation_triangle_fill, size: 12, color: Ex.red700),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Prohibited Actions (What NOT to do)',
                              style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Ex.red700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Ex.red100, borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                        '3 WARNINGS = AUTO-SUBMIT',
                        style: TextStyle(
                          fontSize: 9.92,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Ex.red800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(builder: (context, c) {
                  final w = twoCols ? (c.maxWidth - 24) / 2 : c.maxWidth;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      for (final rule in _rules)
                        SizedBox(
                          width: w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•',
                                  style: TextStyle(
                                      fontSize: 11.52, height: 1.5, fontWeight: FontWeight.w700, color: Ex.red500)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(rule,
                                    style: TextStyle(
                                        fontSize: 11.52, height: 1.5, color: Ex.ink.withValues(alpha: 0.85))),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _HoverTile(
            onTap: () => onAccepted(!accepted),
            child: Row(
              children: [
                ExamCheckbox(value: accepted, onChanged: onAccepted),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'I agree to follow the guidelines and understand the warning policies.',
                    style: TextStyle(fontSize: 11.2, fontWeight: FontWeight.w600, height: 1, color: Ex.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return ExamCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: fill
          ? Center(child: SingleChildScrollView(child: content))
          : Center(child: content),
    );
  }
}

class _HoverTile extends StatefulWidget {
  const _HoverTile({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<_HoverTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? Color.alphaBlend(Ex.line.withValues(alpha: 0.3), Ex.paper) : Ex.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Ex.line),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// The question card (`<Card v-else-if="currentQuestion" ref="questionCard">`).
class ExamQuestionCard extends StatelessWidget {
  const ExamQuestionCard({
    super.key,
    required this.question,
    required this.currentStep,
    required this.total,
    required this.answer,
    required this.answered,
    required this.onSelectOption,
    required this.textController,
    required this.onTextChanged,
    required this.allowTextMenu,
    required this.onPrevious,
    required this.onNext,
    this.fill = false,
  });

  /// Pushes the navigation row to the bottom (`mt-auto`) — only when the
  /// card is given a fixed height (wrap it in `IntrinsicHeight`).
  final bool fill;

  final ExamQuestion question;
  final int currentStep;
  final int total;
  final Object? answer;
  final bool answered;
  final ValueChanged<Object?> onSelectOption;
  final TextEditingController? textController;
  final ValueChanged<String> onTextChanged;

  /// False while the exam security is on (`contextmenu` is blocked).
  final bool allowTextMenu;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final muted = context.exMuted;
    final q = question;
    return ExamCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // `flex items-baseline gap-2`
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('QUESTION', style: TextStyle(fontSize: 10.4, height: 1.5, letterSpacing: 1.04, color: muted)),
                  const SizedBox(width: 8),
                  Text(
                    currentStep.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: answered ? Ex.green100 : Ex.yellow100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  answered ? '✓ Answered' : '◯ Unanswered',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: answered ? Ex.green700 : Ex.yellow800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: context.exBorder),
          if (jsTruthy(q.stem)) ...[
            const SizedBox(height: 20),
            MzHtmlText(
              _text(q.stem),
              style: const TextStyle(fontSize: 16.32, height: 1.625, color: Ex.ink),
            ),
          ],
          if (q.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            for (var i = 0; i < q.images.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _ExamImage(url: _text(q.images[i]['image_url']), maxHeight: 288, radius: 16, expand: true),
            ],
          ],
          if (q.isMcq) ...[
            const SizedBox(height: 20),
            for (var i = 0; i < q.options.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _OptionTile(
                option: q.options[i],
                selected: answer != null && answer == q.options[i]['id'],
                onTap: () => onSelectOption(q.options[i]['id']),
              ),
            ],
          ] else if (q.isText) ...[
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              onChanged: onTextChanged,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              contextMenuBuilder: allowTextMenu
                  ? (context, state) => AdaptiveTextSelectionToolbar.editableText(editableTextState: state)
                  : null,
              style: TextStyle(
                fontSize: context.isMd ? 14 : 15.2,
                height: 1.625,
                color: context.exCardForeground,
              ),
              decoration: InputDecoration(
                hintText: 'Write your answer here…',
                hintStyle: const TextStyle(color: AppColors.placeholder),
                filled: true,
                fillColor: context.isDark ? AppColors.darkInput.withValues(alpha: 0.3) : Ex.paper,
                isDense: true,
                constraints: const BoxConstraints(minHeight: 64),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                enabledBorder: RingInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: context.isDark ? AppColors.darkInput : AppColors.input),
                  shadows: AppShadows.xs,
                ),
                focusedBorder: RingInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Ex.blue),
                  ringColor: Ex.blue,
                  shadows: AppShadows.xs,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (fill) const Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                ExamBlueButton(label: '← Previous', onPressed: onPrevious, disabledOpacity: 0.3, fontWeight: FontWeight.w600),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= math.min(total, 7); i++) ...[
                        if (i > 1) const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: currentStep == i ? Ex.blue : Ex.line,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ExamBlueButton(label: 'Next →', onPressed: onNext, disabledOpacity: 0.3, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option, required this.selected, required this.onTap});
  final Map<String, dynamic> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = option['option_text'];
    final image = option['image_url'];
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Ex.blueSoft : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? Ex.blue : Ex.line, width: 1.5),
            boxShadow: selected ? const [BoxShadow(color: Ex.blue, spreadRadius: 2)] : null,
          ),
          // IntrinsicHeight lets the trailing ✓ be `self-center`.
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Ex.blue : Ex.paper,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? Ex.blue : Ex.line),
                ),
                child: Text(
                  _text(option['display_label']),
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Ex.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (jsTruthy(text))
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(_text(text), style: const TextStyle(fontSize: 15.2, height: 1.625)),
                  ),
                ),
              if (jsTruthy(image)) ...[
                if (jsTruthy(text)) const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _ExamImage(url: _text(image), maxHeight: 112, radius: 4, expand: false),
                ),
              ],
              if (!jsTruthy(text)) const Spacer(),
              const SizedBox(width: 12),
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selected ? 1 : 0,
                  child: const Text('✓', style: TextStyle(fontWeight: FontWeight.w700, color: Ex.blue)),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamImage extends StatelessWidget {
  const _ExamImage({required this.url, required this.maxHeight, required this.radius, required this.expand});
  final String url;
  final double maxHeight;
  final double radius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: expand ? double.infinity : 240),
      width: expand ? double.infinity : null,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: expand ? Ex.line : context.exBorder),
      ),
      child: Image.network(
        getDirectImage(url),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(BootstrapIcons.image, size: 20, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}

/// `<Button class="bg-[#2563eb] text-white … hover:bg-[#2563eb]">`: the kit's
/// `h-9` (36), `shadow-xs` and `disabled:opacity-50` (the nav buttons use
/// `disabled:opacity-30`), with the page's padding / radius / weight.
class ExamBlueButton extends StatelessWidget {
  const ExamBlueButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.radius = 16,
    this.disabledOpacity = 0.5,
    this.expand = false,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  /// `rounded-lg` (16) by default; `rounded-md` = 14, `rounded-xl` = 20.
  final double radius;
  final double disabledOpacity;
  final bool expand;

  /// `font-medium` (kit) unless the page adds `font-semibold`.
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : disabledOpacity,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 36,
            width: expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Ex.blue,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: AppShadows.xs,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: Colors.white, height: 20 / 14),
            ),
          ),
        ),
      ),
    );
  }
}

/// `<Button variant="outline" class="border-[#2563eb] text-[#2563eb]
/// hover:bg-white hover:text-[#2563eb]">` — in dark mode the kit's
/// `dark:bg-input/30 dark:border-input` still win.
class ExamOutlineButton extends StatefulWidget {
  const ExamOutlineButton({super.key, required this.label, required this.onPressed, this.background});
  final String label;
  final VoidCallback onPressed;

  /// `bg-white` (light mode only); defaults to `bg-background`.
  final Color? background;

  @override
  State<ExamOutlineButton> createState() => _ExamOutlineButtonState();
}

class _ExamOutlineButtonState extends State<ExamOutlineButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final bg = dark
        ? AppColors.darkInput.withValues(alpha: _hover ? 0.5 : 0.3)
        : (widget.background ?? AppColors.background);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: dark ? AppColors.darkInput : Ex.blue),
            boxShadow: AppShadows.xs,
          ),
          child: Text(widget.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Ex.blue, height: 20 / 14)),
        ),
      ),
    );
  }
}

// ══════ FOOTER ══════

class ExamFooter extends StatelessWidget {
  const ExamFooter({super.key, required this.answered, required this.total, required this.onSubmit});
  final int answered;
  final int total;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Ex.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 14, height: 20 / 14, color: context.exMuted),
                    children: [
                      TextSpan(
                          text: '$answered',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Ex.green600)),
                      const TextSpan(text: ' of '),
                      TextSpan(text: '$total', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' answered'),
                    ],
                  ),
                ),
              ),
              ExamBlueButton(
                label: 'Submit Exam',
                onPressed: onSubmit,
                fontWeight: FontWeight.w600,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════ DIALOG / OVERLAYS ══════

/// shadcn `<Dialog>` drawn inside the page (so the security overlays can
/// stay above it, like the web's `z-[99999]` teleports over `z-50`): the
/// kit's overlay (`bg-black/45 dark:bg-black/65 backdrop-blur-xs`) and
/// frosted content (`bg-white/90 dark:bg-slate-900/90 backdrop-blur-xl`,
/// `shadow-2xl`, `p-6`, close X at `top-4 right-4`) with `rounded-2xl`.
/// `max-w-sm` replaces the kit's `max-w-[calc(100%-2rem)]` but its
/// `sm:max-w-lg` stays, so from 640px the dialog is 512 wide.
class ExamDialog extends StatelessWidget {
  const ExamDialog({super.key, required this.onClose, required this.child, this.maxWidth});
  final VoidCallback onClose;
  final Widget child;

  /// Defaults to the confirm dialog's `max-w-sm sm:max-w-lg`.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final width = maxWidth ?? (context.isSm ? 512.0 : 384.0);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: ColoredBox(color: Colors.black.withValues(alpha: dark ? 0.65 : 0.45)),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.xl2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: dark ? Tw.slate900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Padding(padding: const EdgeInsets.all(24), child: child),
                          Positioned(top: 16, right: 16, child: DialogCloseButton(onPressed: onClose)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The "Submit Exam?" confirm dialog body.
class ExamSubmitConfirm extends StatelessWidget {
  const ExamSubmitConfirm({
    super.key,
    required this.answered,
    required this.total,
    required this.onBack,
    required this.onSubmit,
  });
  final int answered;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final muted = context.isDark ? AppColors.darkMutedForeground : AppColors.foreground;
    final fg = context.isDark ? AppColors.darkForeground : AppColors.foreground;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // `text-4xl mb-1`, then the header's `gap-2`.
        const Text('⚠', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, height: 40 / 36)),
        const SizedBox(height: 12),
        Text('Submit Exam?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24, color: fg)),
        // `gap-2` + `mt-1`
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 14, height: 1.625, color: muted),
            children: [
              const TextSpan(text: "You've answered "),
              TextSpan(text: '$answered', style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
              const TextSpan(text: ' of '),
              TextSpan(text: '$total', style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
              const TextSpan(text: ' questions.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          answered < total ? '${total - answered} question(s) still unanswered.' : 'All questions answered ✓',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: answered < total ? Ex.amber600 : Ex.green600,
          ),
        ),
        const SizedBox(height: 8),
        Text('This action cannot be undone.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 16 / 12, color: muted)),
        const SizedBox(height: 20),
        // `<DialogFooter class="flex gap-3 justify-center">`: a row from
        // 640px, otherwise the kit's `flex-col-reverse` (Submit Now on top).
        if (context.isSm)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExamOutlineButton(label: 'Go Back', onPressed: onBack),
              const SizedBox(width: 12),
              ExamBlueButton(
                label: 'Submit Now',
                onPressed: onSubmit,
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          )
        else ...[
          ExamBlueButton(
            label: 'Submit Now',
            onPressed: onSubmit,
            radius: 14,
            expand: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const SizedBox(height: 12),
          ExamOutlineButton(label: 'Go Back', onPressed: onBack),
        ],
      ],
    );
  }
}

/// The full-screen `<Teleport to="body">` overlays (grace, exit, termination).
class ExamSecurityOverlay extends StatelessWidget {
  const ExamSecurityOverlay({
    super.key,
    required this.backdrop,
    required this.icon,
    required this.title,
    required this.body,
    this.titleColor = Colors.white,
    this.cardBorder,
  });

  final Color backdrop;
  final String icon;
  final String title;
  final Color titleColor;
  final Color? cardBorder;
  final List<Widget> body;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: backdrop,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Ex.overlayCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder ?? Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [cssShadow(0, 30, 80, 0, Colors.black.withValues(alpha: 0.6))],
                  ),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // `text-5xl mb-4` + the card's `gap-6`
                        Text(icon, textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, height: 1)),
                        const SizedBox(height: 16 + 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: titleColor),
                        ),
                        // `mb-3` + `gap-6`
                        const SizedBox(height: 12 + 24),
                        ...body,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `text-white/60 text-sm leading-relaxed`
TextStyle examOverlayText() =>
    TextStyle(fontSize: 14, height: 1.625, color: Colors.white.withValues(alpha: 0.6));

/// `text-white/30 text-xs`
TextStyle examOverlayHint() => TextStyle(fontSize: 12, height: 16 / 12, color: Colors.white.withValues(alpha: 0.3));

/// Fade in 200 ms / out 150 ms (`<Transition>`).
class ExamFade extends StatelessWidget {
  const ExamFade({super.key, required this.visible, required this.builder});
  final bool visible;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.passthrough,
        children: [...previous, ?current],
      ),
      child: visible
          ? KeyedSubtree(key: const ValueKey('on'), child: Stack(children: [builder(context)]))
          : const SizedBox.shrink(key: ValueKey('off')),
    );
  }
}
