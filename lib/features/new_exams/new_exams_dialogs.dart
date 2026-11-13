part of 'new_exams_page.dart';

/// shadcn `<DialogContent class="!rounded-2xl !p-0 !overflow-hidden …">`:
/// the kit's frosted `bg-white/90 dark:bg-slate-900/90 backdrop-blur-xl`,
/// `border-white/40 dark:border-slate-800/80`, `shadow-2xl`, zoom-in-95 and
/// close X (`top-4 right-4`), with no padding and `gap-4` between the
/// header / body / footer blocks. [body] scrolls; header and footer don't.
/// `!max-w-[…]` (important) beats the kit's `max-w-[calc(100%-2rem)]`, so on
/// a phone the dialog spans the full width.
class _NxDialogShell extends StatelessWidget {
  const _NxDialogShell({required this.maxWidth, required this.header, required this.body, this.footer});
  final double maxWidth;
  final Widget header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // `!max-h-[88vh]` on the preview; the delete dialog never gets that tall.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    Widget frame = DecoratedBox(
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 16),
                    Flexible(child: SingleChildScrollView(child: body)),
                    if (footer != null) ...[const SizedBox(height: 16), footer!],
                  ],
                ),
                const Positioned(top: 16, right: 16, child: DialogCloseButton()),
              ],
            ),
          ),
        ),
      ),
    );
    // zoom-in-95 (the route itself fades in).
    final animation = ModalRoute.of(context)?.animation;
    if (animation != null) {
      frame = ScaleTransition(
        scale: Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: frame,
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: frame,
      ),
    );
  }
}

/// The delete dialog. `deleting` lives here because the dialog is its own
/// route; [onConfirm] is the page's `confirmDelete`.
class _NxDeleteDialog extends StatefulWidget {
  const _NxDeleteDialog({required this.exam, required this.onConfirm});
  final Json exam;
  final Future<void> Function(BuildContext dialogCtx, ValueSetter<bool> setDeleting) onConfirm;

  @override
  State<_NxDeleteDialog> createState() => _NxDeleteDialogState();
}

class _NxDeleteDialogState extends State<_NxDeleteDialog> {
  bool _deleting = false;

  void _setDeleting(bool v) {
    if (mounted) setState(() => _deleting = v);
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final muted = context.exMutedFg;

    Widget infoRow(String label, String value) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(label, style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: muted)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 12, height: 16 / 12))),
          ],
        );

    return _NxDialogShell(
      maxWidth: 400,
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          // `bg-rose-50` has no dark variant on the web.
          color: Tw.rose50,
          border: Border(bottom: BorderSide(color: context.exBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Tw.rose100, borderRadius: BorderRadius.circular(20)),
              child: const Icon(BootstrapIcons.exclamation_triangle, size: 17, color: Tw.rose500),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete Exam',
                      style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: Tw.rose700)),
                  SizedBox(height: 2),
                  Text('This action cannot be undone.',
                      style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.rose400)),
                ],
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Are you sure you want to delete this exam?',
                style: TextStyle(fontSize: 14, height: 20 / 14, color: context.exFg)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.exMuted.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.exBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  infoRow('Name', display(exam['name'])),
                  const SizedBox(height: 6),
                  infoRow('Course', display(jsOr(dig(exam, ['course', 'name']), '—'))),
                  const SizedBox(height: 6),
                  infoRow('Batch', display(jsOr(dig(exam, ['batch', 'name']), '—'))),
                ],
              ),
            ),
          ],
        ),
      ),
      footer: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: context.exMuted.withValues(alpha: 0.4),
          border: Border(top: BorderSide(color: context.exBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            // `bg-rose-500 hover:bg-rose-600 text-white gap-1.5`; the svg gets
            // the kit's `size-4` (16px) and `has-[>svg]:px-2.5`.
            AppButton(
              size: AppButtonSize.sm,
              backgroundColor: Tw.rose500,
              hoverBackgroundColor: Tw.rose600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: _deleting ? null : () => widget.onConfirm(context, _setDeleting),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _deleting
                      ? const AppSpinner(size: 16, color: Colors.white)
                      : const Icon(BootstrapIcons.trash, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(_deleting ? 'Deleting…' : 'Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The preview dialog (`previewCells`, `previewSettings`, sections).
class _NxPreviewDialog extends StatelessWidget {
  const _NxPreviewDialog({required this.exam});
  final Json exam;

  @override
  Widget build(BuildContext context) {
    final muted = context.exMutedFg;
    final open = jsTruthy(exam['is_open_anytime']);
    final duration = exam['duration_minutes'];
    final cells = <(String, String, Color?)>[
      ('Language', exam['locale'] == 'te' ? 'Telugu' : 'English', null),
      ('Course', display(jsOr(dig(exam, ['course', 'name']), '—')), Tw.indigo700),
      ('Batch', display(jsOr(dig(exam, ['batch', 'name']), '—')), Tw.violet700),
      ('Duration', jsTruthy(duration) ? '${display(duration)} min' : '—', null),
      ('Max Attempts', display(exam['max_attempts'] ?? '—'), null),
      ('Type', display(exam['exam_type']), null),
      ('Open Anytime', open ? 'Yes' : 'No', open ? Tw.emerald600 : null),
      ('Marks/Q', display(dig(exam, ['sections', 0, 'marks_per_question']) ?? '—'), null),
    ];
    final settings = <(String, bool)>[
      ('Negative Marking', jsTruthy(exam['allow_negative_marking'])),
      ('Randomize Questions', jsTruthy(exam['randomize_question_order'])),
      ('Randomize Options', jsTruthy(exam['randomize_option_order'])),
      ('Immediate Feedback', jsTruthy(exam['show_immediate_feedback'])),
    ];
    final sections = examMaps(exam['sections']);
    final box = BoxDecoration(
      color: context.exMuted.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.exBorder),
    );
    final capsLabel = TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w700, letterSpacing: 0.25, color: muted);
    final sectionTitle = TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: muted);

    Widget cell(String label, String value, Color? color) => Container(
          padding: const EdgeInsets.all(10),
          decoration: box,
          child: Column(
            children: [
              Text(label.toUpperCase(), textAlign: TextAlign.center, style: capsLabel),
              const SizedBox(height: 4),
              Text(value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        );

    Widget pairs(List<Widget> items, {double gap = 8}) => GapColumn(
          gap: gap,
          children: [
            for (var i = 0; i < items.length; i += 2)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: items[i]),
                    SizedBox(width: gap),
                    Expanded(child: i + 1 < items.length ? items[i + 1] : const SizedBox.shrink()),
                  ],
                ),
              ),
          ],
        );

    final body = Padding(
      padding: const EdgeInsets.all(20),
      child: GapColumn(
        gap: 16,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: box,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(display(exam['name']),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.375)),
                          const SizedBox(height: 4),
                          Text(
                            display(exam['code']),
                            style: TextStyle(
                              fontSize: 11,
                              height: 16 / 11,
                              color: muted,
                              fontFamily: 'monospace',
                              fontFamilyFallback: const ['Consolas', 'Menlo', 'Courier New'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(exam['status'], tracking: false),
                  ],
                ),
                if (jsTruthy(exam['description'])) ...[
                  const SizedBox(height: 8),
                  Text(display(exam['description']), style: TextStyle(fontSize: 12, height: 1.625, color: muted)),
                ],
              ],
            ),
          ),
          pairs([for (final (l, v, c) in cells) cell(l, v, c)]),
          if (!open)
            pairs([
              cell('Start Time', formatDateEnGb(exam['start_time']), null),
              cell('End Time', formatDateEnGb(exam['end_time']), null),
            ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('SETTINGS', style: sectionTitle),
              const SizedBox(height: 10),
              pairs([
                for (final (label, on) in settings)
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: on ? Tw.emerald100 : context.exMuted,
                          // rounded-md (14) on an 18px box.
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: LucideIcon(on ? Lucide.check : Lucide.x,
                              size: 10, strokeWidth: 3, color: on ? Tw.emerald600 : muted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label, style: TextStyle(fontSize: 11, height: 16 / 11, color: muted))),
                    ],
                  ),
              ]),
            ],
          ),
          if (sections.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('SECTIONS (${sections.length})', style: sectionTitle),
                const SizedBox(height: 10),
                GapColumn(
                  gap: 8,
                  children: [
                    for (var i = 0; i < sections.length; i++) _sectionRow(context, sections[i], i, box),
                  ],
                ),
              ],
            ),
        ],
      ),
    );

    return _NxDialogShell(
      maxWidth: 520,
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: context.exMuted.withValues(alpha: 0.4),
          border: Border(bottom: BorderSide(color: context.exBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Tw.blue100, borderRadius: BorderRadius.circular(20)),
              child: const Icon(BootstrapIcons.eye, size: 16, color: Tw.blue600),
            ),
            const SizedBox(width: 12),
            const Text('Exam Preview', style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: body,
    );
  }

  Widget _sectionRow(BuildContext context, Json section, int i, BoxDecoration box) {
    final muted = context.exMutedFg;
    final blueprints = examMaps(section['blueprints']);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: box,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            // rounded-lg (16) on a 24px box.
            decoration: BoxDecoration(color: context.exBorder, borderRadius: BorderRadius.circular(12)),
            child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: muted)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(display(section['name']),
                    style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700)),
                if (jsTruthy(section['description'])) ...[
                  const SizedBox(height: 4),
                  Text(display(section['description']), style: TextStyle(fontSize: 11, color: muted)),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    Text('${display(section['question_count'])} questions', style: TextStyle(fontSize: 11, color: muted)),
                    Text('${display(section['marks_per_question'])} marks each',
                        style: TextStyle(fontSize: 11, color: muted)),
                  ],
                ),
                if (blueprints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final bp in blueprints)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Tw.indigo50, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            '${display(bp['question_type'])} · ${display(bp['difficulty_level'])} · pick ${display(bp['questions_to_pick'])}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Tw.indigo700),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
