part of 'class_course_create_page.dart';

/// Header row: (empty `<h2>`), search box + search button, "Create Course".
///
/// The search `<input class="w-[70%] px-3 py-2 border rounded-md bg-white
/// dark:bg-card focus:ring-2 focus:ring-primary/20">` is 70% of its
/// shrink-to-fit wrapper, so the wrapper keeps a gap after the search button.
class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final controls = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 168,
              child: _NativeInput(
                controller: s._searchQueryCourse,
                hint: 'Search Course...',
                horizontalPadding: 12,
                fill: dark ? AppColors.darkCard : Colors.white,
                ring: context.colors.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: 8),
            AppButton(icon: BootstrapIcons.search, iconSize: 14, onPressed: s._searchCourseByName),
            const SizedBox(width: 18),
          ],
        ),
        if (s._canManage) AppButton(label: 'Create Course', onPressed: s._openCreateCourseDialog),
      ],
    );
    if (context.isSm) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Spacer(), Flexible(child: controls)],
      );
    }
    // flex-col gap-3 with the empty <h2> on top.
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(alignment: Alignment.centerLeft, child: controls),
    );
  }
}

/// "No courses available." empty state.
class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dark ? Tw.slate800 : Tw.slate100),
            alignment: Alignment.center,
            child: Icon(BootstrapIcons.journal_x, size: 30, color: dark ? Tw.slate500 : Tw.slate400),
          ),
          const SizedBox(height: 16),
          // `text-slate-850` is not a Tailwind colour: the card's foreground shows.
          Text(
            'No courses available.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: dark ? Tw.slate200 : null),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Attach courses to get started or create a new course.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.625, color: dark ? Tw.slate500 : Tw.slate400),
            ),
          ),
          if (s._canManage) ...[
            const SizedBox(height: 20),
            _FirstCourseButton(onTap: s._openCreateCourseDialog),
          ],
        ],
      ),
    );
  }
}

/// `border border-indigo-200 dark:border-slate-800 hover:border-indigo-500
/// hover:bg-slate-50 dark:hover:bg-slate-900/50 text-[#4f46e5]
/// dark:text-indigo-400 bg-white dark:bg-card rounded-xl px-5 py-2.5 text-xs
/// font-semibold shadow-xs`.
class _FirstCourseButton extends StatefulWidget {
  const _FirstCourseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_FirstCourseButton> createState() => _FirstCourseButtonState();
}

class _FirstCourseButtonState extends State<_FirstCourseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = _hover ? Tw.indigo500 : (dark ? Tw.slate800 : Tw.indigo200);
    final bg = _hover
        ? (dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50)
        : (dark ? AppColors.darkCard : Colors.white);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: _shadowXs,
          ),
          child: Text(
            'Create Your First Course',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: dark ? Tw.indigo400 : _C.indigoText,
            ),
          ),
        ),
      ),
    );
  }
}

/// `grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4
/// sm:gap-6 p-3 sm:p-4` of course cards.
class _CourseGrid extends StatelessWidget {
  const _CourseGrid({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  Widget build(BuildContext context) {
    final columns = context.isLg
        ? 4
        : context.isMd
            ? 3
            : context.isSm
                ? 2
                : 1;
    final sm = context.isSm;
    return Padding(
      padding: EdgeInsets.all(sm ? 16 : 12),
      child: _Grid(
        columns: columns,
        gap: sm ? 24 : 16,
        children: [
          for (var i = 0; i < s._coursess.length; i++)
            _CourseCard(
              course: s._coursess[i],
              canManage: s._canManage,
              onTap: () => s._onCourseSelect(s._coursess[i], i),
              onEdit: () => s._openUpdateCourseDialog(s._coursess[i]['id']),
              onDelete: () => s._openDeleteCourseDialog(s._coursess[i]),
            ),
        ],
      ),
    );
  }
}

/// `<Card class="pt-0 group rounded-2xl shadow-sm hover:shadow-xl
/// transition-all duration-300 cursor-pointer border border-slate-100
/// dark:border-slate-800 overflow-hidden">` (the card keeps its `pb-6`).
class _CourseCard extends StatefulWidget {
  const _CourseCard({
    required this.course,
    required this.canManage,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> course;
  final bool canManage;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final c = widget.course;
    final image = jsTruthy(c['image']) ? '${c['image']}' : (jsTruthy(c['attach']) ? '${c['attach']}' : null);
    final published = c['status'] == 'published';
    final primary = context.colors.primary;

    final thumbnail = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark ? const [Tw.slate800, Tw.slate900] : const [Tw.indigo50, Tw.purple50],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              ClipRect(
                child: AnimatedScale(
                  scale: _hover ? 1.05 : 1,
                  duration: const Duration(milliseconds: 500),
                  child: Image.network(image, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                ),
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(BootstrapIcons.journal_bookmark,
                      size: 36, color: dark ? Tw.slate600 : primary.withValues(alpha: 0.45)),
                  const SizedBox(height: 4),
                  Text(
                    'COURSE',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: dark ? Tw.slate600 : primary.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            Positioned(top: 8, left: 8, child: _StatusBadge(published: published)),
          ],
        ),
      ),
    );

    final footer = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c['title'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: _hover ? primary : (dark ? Tw.slate100 : Tw.slate800),
                  ),
                ),
                if (jsTruthy(c['course_code']))
                  Text(
                    '${c['course_code']}',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      color: dark ? Tw.slate500 : Tw.slate400,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.canManage) ...[
            // `justify-between gap-2` + the actions' `ml-2`.
            const SizedBox(width: 16),
            _RoundIconButton(
              icon: BootstrapIcons.pencil_square,
              tooltip: 'Edit Course',
              radius: 16,
              background: Colors.transparent,
              hoverBackground: dark ? Tw.slate800 : Tw.slate100,
              foreground: dark ? Tw.slate400 : Tw.slate500,
              hoverForeground: dark ? Colors.white : Tw.slate800,
              onTap: widget.onEdit,
            ),
            const SizedBox(width: 4),
            // `dark:text-rose-455` is not a Tailwind colour: rose-500 in both modes.
            _RoundIconButton(
              icon: BootstrapIcons.dash_circle_fill,
              tooltip: 'Delete Course',
              radius: 16,
              background: Colors.transparent,
              hoverBackground: dark ? Tw.rose500.withValues(alpha: 0.1) : Tw.rose50,
              foreground: Tw.rose500,
              onTap: widget.onDelete,
            ),
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkCard : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
            boxShadow: _hover ? _shadowXl : _shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [thumbnail, footer],
          ),
        ),
      ),
    );
  }
}

/// "Active" / "Draft" pill on the thumbnail (`inline-flex items-center gap-1
/// px-2.5 py-0.5 rounded-full text-[10px] font-semibold backdrop-blur-md
/// border shadow-xs`), with the pulsing dot when published.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.published});
  final bool published;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: (published ? Tw.emerald500 : Tw.amber500).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: published ? Tw.emerald400 : Tw.amber400),
            boxShadow: _shadowXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (published) ...[const _PulseDot(), const SizedBox(width: 4)],
              Text(
                published ? 'Active' : 'Draft',
                style: const TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
