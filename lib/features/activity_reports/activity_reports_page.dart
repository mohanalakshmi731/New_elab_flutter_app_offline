import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart' show AppSelectItem;
import '../library/library_widgets.dart' show GlowBlob, LibGrid, Pulse, libGlassContainer;
import '../mathzoro/mz_ui.dart' show CssLinearGradient;
import 'activity_reports_controller.dart';
import 'activity_reports_widgets.dart';

/// Port of `src/pages/library/ActivityReports.vue` (`/activityreport`, eLabs
/// shell): pick a class, batch, subject (course) and chapter — each also as
/// "All …" — and see the chapter's activities and every student's best quiz
/// score per activity as stars (1 star = 1 mark).
///
/// Data flow (see [ActivityReportsController]): classes → batches +
/// subjects (courses of the class with their ZSL class/subject) → ZSL
/// chapters → `zsl/get-quiz-performance` + the class's students (all
/// pages). The web page has no export, chart or pagination.
///
/// The header's `.pattern-overlay` div has no styles on this page (the
/// class only exists in other components' scoped CSS), so no dot pattern is
/// drawn, unlike the library banner.
class ActivityReportsPage extends ConsumerStatefulWidget {
  const ActivityReportsPage({super.key});

  @override
  ConsumerState<ActivityReportsPage> createState() => _ActivityReportsPageState();
}

class _ActivityReportsPageState extends ConsumerState<ActivityReportsPage> {
  late final ActivityReportsController _c;
  final _hoveredRow = ValueNotifier<int?>(null);

  @override
  void initState() {
    super.initState();
    _c = ActivityReportsController(
      api: ServiceActivityReportsApi(
        classService: ref.read(classServiceProvider),
        batchService: ref.read(batchServiceProvider),
        courseService: ref.read(courseServiceProvider),
        zslService: ref.read(zslServiceProvider),
        studentService: ref.read(studentServiceProvider),
      ),
      instituteId: () => reportInstituteId(ref.read(sessionProvider).instituteId),
    );
    // mounted()
    _c.refreshData();
  }

  @override
  void dispose() {
    _c.dispose();
    _hoveredRow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch: instituteId()
    ref.listen<String>(sessionProvider.select((s) => reportInstituteId(s.instituteId)), (prev, next) {
      if (prev != next) _c.onInstituteChanged();
    });

    final dark = context.isDark;
    final sm = context.isSm;
    return DefaultTextStyle.merge(
      style: GoogleFonts.nunito(),
      child: Container(
        color: dark ? AppColors.dashboardDark : Colors.transparent,
        child: Stack(children: [
          // Ambient glow blobs (`fixed`, behind the content).
          Positioned(
            top: -200,
            right: -100,
            // `bg-[#4f46e5]/10 dark:bg-[#4f46e5]/5 opacity-20 blur-[120px]`
            child: GlowBlob(
                size: 600, color: AppColors.primary.withValues(alpha: dark ? 0.05 : 0.1), opacity: 0.2),
          ),
          Positioned(
            bottom: 0,
            left: -100,
            child: GlowBlob(
                size: 400,
                color: dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo300.withValues(alpha: 0.1),
                opacity: 0.1),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 8, vertical: sm ? 24 : 16),
              child: Container(
                decoration: libGlassContainer(context),
                padding: EdgeInsets.all(context.isMd ? 24 : (sm ? 20 : 16)),
                child: ListenableBuilder(
                  listenable: _c,
                  builder: (context, _) => _content(context),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final Widget body;
    if (_c.hasActiveFilters) {
      body = ActivityReportView(controller: _c, hoveredRow: _hoveredRow);
    } else {
      body = const _StateCard(
        icon: BootstrapIcons.funnel,
        circle: 64,
        title: 'Select report filters',
        titleSize: 18,
        titleGap: 20,
        message: 'Select a class, batch, subject and chapter to view the activity progress report.',
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _Banner(),
      const SizedBox(height: 24),
      _filterCard(context),
      if (_c.errorMessage.isNotEmpty) ...[
        const SizedBox(height: 24),
        _ErrorBox(_c.errorMessage),
      ],
      const SizedBox(height: 24),
      body,
    ]);
  }

  // ── filter card ──

  Widget _filterCard(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final primary = ArColors.primary(context);
    final busy = _c.updatingFilters;

    final heading = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        // `h-8 w-8 rounded-lg` (16px radius → a circle).
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(ArRadius.lg)),
          child: Icon(BootstrapIcons.funnel, size: 14, color: primary),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text('Report Filters',
              style: arText(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: ArColors.fg(context))),
        ),
      ]),
      const SizedBox(height: 8),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 672),
        child: Text(
          'Choose a class, batch, subject and chapter to view the corresponding activity progress.',
          style: arText(fontSize: sm ? 14 : 12, height: 20 / (sm ? 14 : 12), color: ArColors.muted(context)),
        ),
      ),
    ]);

    // `<Button variant="outline" class="w-full rounded-xl border-border
    // bg-background text-foreground hover:bg-muted sm:w-auto
    // dark:border-[#414657] dark:bg-[#2d3240] dark:text-gray-100
    // dark:hover:bg-[#373d4d]">`; the kit's `hover:text-accent-foreground`
    // stays (#1f2430 = the light foreground) but loses to `dark:text-gray-100`.
    // `<i class="bi … mr-2">` + the button's `gap-2` = 16px before the label.
    Widget button({required String label, required Widget icon, required VoidCallback? onPressed}) => AppButton(
          variant: AppButtonVariant.outline,
          onPressed: onPressed,
          expand: !sm,
          radius: ArRadius.xl,
          backgroundColor: dark ? const Color(0xFF2D3240) : AppColors.background,
          foregroundColor: dark ? Tw.gray100 : AppColors.foreground,
          hoverBackgroundColor: dark ? const Color(0xFF373D4D) : AppColors.muted,
          hoverForegroundColor: dark ? Tw.gray100 : AppColors.accentForeground,
          borderColor: dark ? ArColors.darkTileBorder : AppColors.border,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            icon,
            const SizedBox(width: 16),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: arText(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
            ),
          ]),
        );

    final refresh = button(
      label: _c.isRefreshing ? 'Refreshing...' : 'Refresh',
      icon: _c.isRefreshing
          ? const ArSpin(child: Icon(BootstrapIcons.arrow_repeat, size: 14))
          : const Icon(BootstrapIcons.arrow_clockwise, size: 14),
      onPressed: _c.isRefreshing || busy ? null : _c.refreshData,
    );
    final clear = button(
      label: 'Clear Filters',
      icon: const Icon(BootstrapIcons.x_circle, size: 14),
      onPressed: _c.clearFilters,
    );
    final actions = sm
        ? Row(mainAxisSize: MainAxisSize.min, children: [refresh, const SizedBox(width: 8), clear])
        : Row(children: [Expanded(child: refresh), const SizedBox(width: 8), Expanded(child: clear)]);

    final header = context.isXl
        ? Row(children: [Expanded(child: Align(alignment: Alignment.centerLeft, child: heading)), actions])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            heading,
            const SizedBox(height: 16),
            sm ? actions : SizedBox(width: double.infinity, child: actions),
          ]);

    // ── selects ──
    final filteredBatches = _c.filteredBatches;
    final filteredSubjects = _c.filteredSubjects;
    final filteredChapters = _c.filteredChapters;
    final cls = _c.selectedClass;
    final subject = _c.selectedSubject;

    final classSelect = _select(
      label: 'Class',
      value: cls,
      placeholder: 'Select Class',
      enabled: !busy,
      items: [
        const AppSelectItem('all', 'All Classes'),
        for (final c in _c.classes) AppSelectItem(c.id, c.name),
      ],
      onChanged: _c.selectClass,
    );
    final batchSelect = _select(
      label: 'Batch',
      value: _c.selectedBatch,
      placeholder: cls.isNotEmpty && cls != 'all' && filteredBatches.isEmpty ? 'No batch available' : 'Select Batch',
      enabled: cls.isNotEmpty && !busy,
      items: [
        const AppSelectItem('all', 'All Batches'),
        if (cls != 'all' && filteredBatches.isEmpty)
          const AppSelectItem('none', 'No batches available', enabled: false),
        for (final b in filteredBatches) AppSelectItem(b.id, b.name),
      ],
      onChanged: _c.selectBatch,
    );
    final subjectSelect = _select(
      label: 'Subject',
      value: subject,
      placeholder:
          cls.isNotEmpty && cls != 'all' && filteredSubjects.isEmpty ? 'No subject available' : 'Select Subject',
      enabled: cls.isNotEmpty && !busy,
      items: [
        const AppSelectItem('all', 'All Subjects'),
        if (cls != 'all' && filteredSubjects.isEmpty)
          const AppSelectItem('none', 'No subjects available', enabled: false),
        for (final s in filteredSubjects) AppSelectItem(s.id, s.name),
      ],
      onChanged: _c.selectSubject,
    );
    final chapterSelect = _select(
      label: 'Chapter',
      value: _c.selectedChapter,
      placeholder: subject.isNotEmpty && subject != 'all' && filteredChapters.isEmpty
          ? 'No chapter available'
          : 'Select Chapter',
      enabled: subject.isNotEmpty && !busy,
      items: [
        const AppSelectItem('all', 'All Chapters'),
        if (subject != 'all' && filteredChapters.isEmpty)
          const AppSelectItem('none', 'No chapters available', enabled: false),
        for (final ch in filteredChapters) AppSelectItem(ch.id, ch.name),
      ],
      onChanged: _c.selectChapter,
      menuMinWidth: 260,
    );

    final columns = context.isXl ? 4 : (sm ? 2 : 1);

    return ArCard(
      child: Padding(
        padding: EdgeInsets.all(context.isLg ? 24 : (sm ? 20 : 16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          header,
          const SizedBox(height: 20),
          LibGrid(columns: columns, gap: 16, children: [classSelect, batchSelect, subjectSelect, chapterSelect]),
          if (_c.hasActiveFilters) _activeSummary(context),
        ]),
      ),
    );
  }

  Widget _select({
    required String label,
    required String value,
    required String placeholder,
    required bool enabled,
    required List<AppSelectItem<String>> items,
    required ValueChanged<String> onChanged,
    double menuMinWidth = 240,
  }) {
    final dark = context.isDark;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      // `<Label class="text-sm font-medium text-foreground dark:text-gray-200">`
      // (the kit adds `leading-none`).
      Text(label,
          style: arText(
              fontSize: 14,
              height: 1,
              fontWeight: FontWeight.w500,
              color: dark ? Tw.gray200 : AppColors.foreground)),
      const SizedBox(height: 8),
      ReportSelect(
        value: value.isEmpty ? null : value,
        items: items,
        placeholder: placeholder,
        enabled: enabled,
        menuMinWidth: menuMinWidth,
        onChanged: onChanged,
      ),
    ]);
  }

  /// "Viewing: Class › Batch › Subject › Chapter"
  Widget _activeSummary(BuildContext context) {
    final dark = context.isDark;
    Widget chevron() => Icon(BootstrapIcons.chevron_right, size: 10, color: dark ? Tw.gray500 : AppColors.foreground);
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dark ? const Color(0xFF383D4D) : AppColors.border)),
      ),
      child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('Viewing:',
            style: arText(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: ArColors.muted(context))),
        ArPill(_c.selectedClassName, primary: true),
        chevron(),
        ArPill(_c.selectedBatchName),
        chevron(),
        ArPill(_c.selectedSubjectName),
        chevron(),
        ArPill(_c.selectedChapterName, maxWidth: 220),
      ]),
    );
  }
}

/// The indigo header banner: `bg-gradient-to-br from-[#4f46e5]
/// via-[#4f46e5]/90 to-indigo-700 rounded-3xl shadow-lg border
/// border-white/20 p-4 sm:p-5 lg:p-6` with two blurred radial glows.
class _Banner extends StatelessWidget {
  const _Banner();

  /// `radial-gradient(circle, #818cf8 0%, transparent 70%)`
  static const _glow2 = Color(0xFF818CF8);

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    final lg = context.isLg;
    final titleSize = lg ? 30.0 : (sm ? 24.0 : 20.0);

    // `w-11 h-11 sm:w-12 sm:h-12 rounded-2xl shadow-lg border border-white/20`
    final iconBox = Container(
      width: sm ? 48 : 44,
      height: sm ? 48 : 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ArRadius.xl2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppShadows.lg,
      ),
      child: const Icon(BootstrapIcons.file_earmark_bar_graph_fill, size: 20, color: Colors.white),
    );

    final texts = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Pulse(
          child: Container(
              width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 6),
        Pulse(
          child: Text('REPORTS',
              style: arText(
                  fontSize: 9, height: 1.5, fontWeight: FontWeight.w900, letterSpacing: 0.9, color: Tw.indigo100)),
        ),
      ]),
      const SizedBox(height: 2),
      // `text-xl sm:text-2xl lg:text-3xl font-extrabold tracking-tight
      // drop-shadow-sm leading-tight`
      Text('Activity Reports',
          style: arText(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.25,
            letterSpacing: -0.025 * titleSize,
            shadows: const [Shadow(color: Color(0x26000000), blurRadius: 1, offset: Offset(0, 1))],
          )),
      const SizedBox(height: 4),
      Text('View student activity performance chapter-wise',
          style: arText(
              fontSize: sm ? 14 : 12,
              height: sm ? 20 / 14 : 16 / 12,
              fontWeight: FontWeight.w500,
              color: Tw.indigo100)),
    ]);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ArRadius.xl3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        gradient: CssLinearGradient(
          corner: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.9), Tw.indigo700],
        ),
        boxShadow: AppShadows.lg,
      ),
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        const Positioned(top: -150, left: -100, child: GlowBlob(size: 400, color: AppColors.primary, opacity: 0.4)),
        const Positioned(bottom: -150, right: -50, child: GlowBlob(size: 350, color: _glow2, opacity: 0.3)),
        Padding(
          padding: EdgeInsets.all(lg ? 24 : (sm ? 20 : 16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            iconBox,
            SizedBox(width: sm ? 16 : 12),
            Flexible(child: texts),
          ]),
        ),
      ]),
    );
  }
}

/// `<p role="alert">` error banner.
class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        // `rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-700
        // dark:bg-red-950 dark:text-red-200`
        decoration: BoxDecoration(
          color: dark ? ArColors.red950 : ArColors.red50,
          borderRadius: BorderRadius.circular(ArRadius.xl),
          border: Border.all(color: ArColors.red200),
        ),
        child: Text(message,
            style: arText(fontSize: 14, height: 20 / 14, color: dark ? ArColors.red200 : ArColors.red700)),
      ),
    );
  }
}

/// The centred loading / "Select report filters" cards (`min-h-[320px]`).
class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.circle,
    required this.title,
    required this.titleSize,
    required this.titleGap,
    required this.message,
    this.spin = false,
  });

  final IconData icon;
  final double circle;
  final String title;
  final double titleSize;
  final double titleGap;
  final String message;
  final bool spin;

  @override
  Widget build(BuildContext context) {
    final primary = ArColors.primary(context);
    final glyph = Icon(icon, size: 24, color: primary);
    return ArCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: spin ? ArSpin(child: glyph) : glyph),
            ),
            SizedBox(height: titleGap),
            Text(title,
                textAlign: TextAlign.center,
                style: arText(
                    fontSize: titleSize,
                    height: titleSize == 18 ? 28 / 18 : 1.5,
                    fontWeight: FontWeight.w600,
                    color: ArColors.fg(context))),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: arText(fontSize: 14, height: 24 / 14, color: ArColors.muted(context))),
            ),
          ]),
        ),
      ),
    );
  }
}
