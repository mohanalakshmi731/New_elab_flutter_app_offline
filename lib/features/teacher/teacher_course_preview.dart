part of 'teacher_course_page.dart';

/// PREVIEW TAB — course outline sidebar (docked ≥1024px, overlay below) and
/// the preview pane (course card or the selected concept).
extension _PreviewView on _TeacherCoursePageState {
  Widget _previewTab() {
    final details = _selectedCourseDetails;
    if (details == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(children: [
          Icon(BootstrapIcons.hourglass_split, size: 30, color: Tw.slate400),
          SizedBox(height: 12),
          Text('Loading course details...', style: TextStyle(fontSize: 16, height: 1.5, color: Tw.slate400)),
        ]),
      );
    }
    final vh = MediaQuery.sizeOf(context).height;
    final main = _previewMain(details, vh);
    if (_isMobile) return main;
    // Closed = `w-0 overflow-hidden opacity-0`, but its `p-4` + border keep
    // 34px (border-box), and the `gap-4` stays; `transition-all duration-300`.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _sidebarOpen ? 288 : 34,
          height: vh * 0.8,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _sidebarOpen ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_sidebarOpen,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: 288,
                  maxWidth: 288,
                  child: _desktopSidebar(details, vh),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: main),
      ],
    );
  }

  BoxDecoration _paneDecoration({BorderRadius? radius}) {
    final dark = context.isDark;
    return BoxDecoration(
      color: dark ? Tw.slate800 : Colors.white,
      borderRadius: radius ?? BorderRadius.circular(16),
      border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
      boxShadow: TcShadows.sm,
    );
  }

  void _showCoursePreview(Map<String, dynamic> details, {bool closeSidebar = false}) => _set(() {
        _previewItem = (type: 'course', data: details);
        if (closeSidebar) _sidebarOpen = false;
      });

  Widget _sidebarTitle(Map<String, dynamic> details, {required bool mobile}) => Padding(
        padding: EdgeInsets.only(top: mobile ? 24 : 0, bottom: 16),
        child: _HoverText(
          text: '${details['title'] ?? ''}',
          onTap: () => _showCoursePreview(details, closeSidebar: mobile),
        ),
      );

  Widget _desktopSidebar(Map<String, dynamic> details, double vh) {
    final dark = context.isDark;
    return Container(
      width: 288,
      height: vh * 0.8,
      decoration: _paneDecoration(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sidebarTitle(details, mobile: false),
            Divider(height: 1, thickness: 1, color: dark ? Tw.slate700 : Tw.slate200),
            const SizedBox(height: 16),
            _previewTree(details, mobile: false),
          ],
        ),
      ),
    );
  }

  /// Sections → chapters → concepts. The mobile overlay omits the empty
  /// messages, the type icons and the selected highlight, like the web.
  Widget _previewTree(Map<String, dynamic> details, {required bool mobile}) {
    final dark = context.isDark;
    final sections = [for (final s in asList(details['sections'])) ?asMap(s)];
    const italic = TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Tw.slate400);

    if (!mobile && sections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text('No sections available.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Tw.slate400)),
      );
    }

    Widget contentItem(Map<String, dynamic> content) {
      if (mobile) {
        return _PreviewContentTile(
          selected: false,
          mobile: true,
          onTap: () => _set(() {
            _previewItem = (type: 'content', data: content);
            _sidebarOpen = false;
          }),
          child: Text('${content['name'] ?? ''}', style: const TextStyle(fontSize: 11.5)),
        );
      }
      final selected = _previewItem.data?['id'] == content['id'];
      final fg = selected ? Colors.white : (dark ? Tw.slate300 : Tw.slate600);
      return _PreviewContentTile(
        selected: selected,
        onTap: () => _set(() => _previewItem = (type: 'content', data: content)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? Tw.slate700 : Tw.slate100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: contentTypeIcon(content['type'], 10),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text('${content['name'] ?? ''}', style: TextStyle(fontSize: 11.5, height: 1.375, color: fg)),
            ),
          ],
        ),
      );
    }

    Widget chapterBlock(Map<String, dynamic> chapter) {
      final open = _openChapterId != null && _openChapterId == chapter['id'];
      final contents = [for (final c in asList(chapter['contents'])) ?asMap(c)];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Desktop: `text-emerald-700 dark:text-emerald-400 hover:text-emerald-900`,
          // truncated, `text-[11px] ml-1` chevron; mobile: `text-emerald-700`
          // only, wrapping, chevron at the row's 12px.
          _HoverBuilder(
            builder: (hover) {
              final color = !mobile && hover
                  ? Tw.emerald900
                  : (dark && !mobile ? Tw.emerald400 : Tw.emerald700);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _set(() => _openChapterId = open ? null : chapter['id']),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        '${chapter['name'] ?? ''}',
                        maxLines: mobile ? null : 1,
                        overflow: mobile ? null : TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w500, color: color),
                      ),
                    ),
                    SizedBox(width: mobile ? 0 : 4),
                    Icon(open ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
                        size: mobile ? 12 : 11, color: color),
                  ]),
                ),
              );
            },
          ),
          // `space-y-1.5` also separates the row from its open list.
          if (open) const SizedBox(height: 6),
          if (open)
            _FadeIn(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: dark && !mobile ? Tw.slate600 : Tw.slate200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!mobile && contents.isEmpty) const Text('No concepts.', style: italic),
                    for (var i = 0; i < contents.length; i++) ...[
                      if (i > 0) const SizedBox(height: 4),
                      contentItem(contents[i]),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          () {
            final section = sections[i];
            final open = _openSectionId != null && _openSectionId == section['id'];
            final chapters = [for (final c in asList(section['chapters'])) ?asMap(c)];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // `px-3 py-2 rounded-lg bg-slate-100 dark:bg-slate-700
                // hover:bg-slate-200 dark:hover:bg-slate-600` (the mobile copy
                // has no dark hover variant).
                Material(
                  color: dark ? Tw.slate700 : Tw.slate100,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    hoverColor: dark && !mobile ? Tw.slate600 : Tw.slate200,
                    onTap: () => _set(() => _openSectionId = open ? null : section['id']),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            '${section['name'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: dark ? Tw.slate200 : Tw.slate800,
                            ),
                          ),
                        ),
                        SizedBox(width: mobile ? 0 : 4),
                        Icon(open ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
                            size: mobile ? 12.5 : 11, color: dark ? Tw.slate200 : Tw.slate800),
                      ]),
                    ),
                  ),
                ),
                // `ml-3 mt-1` — the `mt-1` collapses into the `space-y-2` 8px.
                if (open)
                  _FadeIn(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12, top: 8),
                      padding: const EdgeInsets.only(left: 12),
                      decoration: const BoxDecoration(border: Border(left: BorderSide(color: Tw.emerald200, width: 2))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!mobile && chapters.isEmpty) const Text('No chapters.', style: italic),
                          for (var c = 0; c < chapters.length; c++) ...[
                            if (c > 0) const SizedBox(height: 6),
                            chapterBlock(chapters[c]),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }(),
        ],
      ],
    );
  }

  Widget _previewMain(Map<String, dynamic> details, double vh) {
    final dark = context.isDark;
    final item = _previewItem;
    final data = item.data;
    final label = item.type == 'content' && data != null ? '${data['name'] ?? ''}' : '${details['title'] ?? ''}';

    final toolbar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate100)),
      ),
      child: Row(children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            hoverColor: dark ? Tw.slate700 : Tw.slate100,
            onTap: () => _set(() => _sidebarOpen = !_sidebarOpen),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _sidebarOpen ? BootstrapIcons.layout_sidebar_inset : BootstrapIcons.list,
                size: _sidebarOpen ? 18 : 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Tw.slate400)),
        ),
      ]),
    );

    final hPad = context.isSm ? 32.0 : 16.0;
    final Widget body;
    if (item.type == 'course') {
      body = SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
        child: _coursePreview(details),
      );
    } else if (item.type == 'content' && data != null) {
      final title = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          '${data['name'] ?? ''}',
          style: TextStyle(
            fontSize: context.isSm ? 24 : 20,
            fontWeight: FontWeight.w700,
            color: dark ? Tw.emerald400 : Tw.emerald700,
          ),
        ),
      );
      final type = data['type'];
      if (type == 'html') {
        // `<div class="preview" v-html="content">` in a web view filling the pane.
        body = Padding(
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              Expanded(
                child: WebContentView(key: ValueKey(data['id']), html: previewHtml(data['content'], dark: dark)),
              ),
            ],
          ),
        );
      } else {
        final Widget content;
        if (type == 'url') {
          content = UrlMediaBox(
            key: ValueKey(data['id']),
            url: '${data['url']}',
            height: context.isLg ? 460 : (context.isSm ? 380 : 260),
            cannotPreviewText: 'Cannot preview this site.',
          );
        } else if (type == 'pdf') {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // `class="mb-3 gap-1.5"`
              AppButton(
                onPressed: () => showAppDialog<void>(
                  context,
                  builder: (_) => PdfFullScreenDialog(url: _previewItem.data?['url']),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(BootstrapIcons.fullscreen, size: 14),
                  SizedBox(width: 6),
                  Text('Full Screen'),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                height: vh * 0.7,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
                ),
                child: WebContentView(key: ValueKey(data['id']), url: pdfEmbedUrl(data['url'])),
              ),
            ],
          );
        } else {
          content = const Text('No preview available',
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Tw.slate400));
        }
        body = SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [title, content]),
        );
      }
    } else {
      body = const SizedBox.shrink();
    }

    return Container(
      height: vh * 0.82,
      clipBehavior: Clip.antiAlias,
      decoration: _paneDecoration(),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [toolbar, Expanded(child: body)],
          ),
          if (_isMobile && _sidebarOpen)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: context.isSm ? 288 : null,
              right: context.isSm ? null : 0,
              child: Container(
                // `rounded-l-2xl border-r shadow-xl`
                decoration: BoxDecoration(
                  color: dark ? Tw.slate800 : Colors.white,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  border: Border(right: BorderSide(color: dark ? Tw.slate700 : Tw.slate200)),
                  boxShadow: TcShadows.xl,
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sidebarTitle(details, mobile: true),
                          Divider(height: 1, thickness: 1, color: dark ? Tw.slate700 : Tw.slate200),
                          const SizedBox(height: 16),
                          _previewTree(details, mobile: true),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconTapButton(
                        icon: BootstrapIcons.x_lg,
                        size: 20,
                        color: dark ? Tw.slate300 : Tw.slate600,
                        onTap: () => _set(() => _sidebarOpen = false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _coursePreview(Map<String, dynamic> details) {
    final dark = context.isDark;
    final sm = context.isSm;
    final published = details['status'] == 'published';
    // `text-2xl sm:text-3xl font-extrabold tracking-tight` (-0.025em).
    final titleSize = sm ? 30.0 : 24.0;
    final title = Text(
      '${details['title'] ?? ''}',
      style: TextStyle(
        fontSize: titleSize,
        height: sm ? 1.2 : 1.333,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.025 * titleSize,
        color: dark ? Colors.white : Tw.slate900,
      ),
    );
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: published ? Tw.emerald100 : TcTw.rose100,
        borderRadius: BorderRadius.circular(999),
        boxShadow: TcShadows.sm,
      ),
      child: Text(
        published ? 'Published' : 'Unpublished',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: published ? Tw.emerald700 : TcTw.rose700,
        ),
      ),
    );
    final image = details['image'];
    final imageHeight = sm ? 240.0 : 192.0;
    final placeholder = Container(
      height: 160,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? Tw.slate700 : Tw.slate100,
        borderRadius: BorderRadius.circular(20), // rounded-xl
      ),
      child: const Icon(BootstrapIcons.image, size: 30, color: Tw.slate400),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate100)),
          ),
          child: sm
              ? Row(children: [Expanded(child: title), const SizedBox(width: 12), pill])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), pill],
                ),
        ),
        Center(
          child: jsTruthy(image)
              ? Container(
                  clipBehavior: Clip.antiAlias,
                  // `rounded-xl object-cover shadow-md`
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: TcShadows.md,
                  ),
                  child: Image.network(
                    '$image',
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => SizedBox(
                      height: imageHeight,
                      width: imageHeight,
                      child: const Icon(BootstrapIcons.image, size: 30, color: Tw.slate400),
                    ),
                  ),
                )
              : placeholder,
        ),
        const SizedBox(height: 24),
        Text(
          jsTruthy(details['description']) ? '${details['description']}' : 'No description available.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sm ? 15 : 14,
            height: 1.625,
            color: dark ? Tw.slate300 : Tw.slate600,
          ),
        ),
      ],
    );
  }
}

/// The sidebar's course title (`hover:text-emerald-600 cursor-pointer`).
class _HoverText extends StatefulWidget {
  const _HoverText({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  State<_HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<_HoverText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _hover ? Tw.emerald600 : (context.isDark ? Colors.white : Tw.slate900),
            ),
          ),
        ),
      );
}

/// A concept entry of the preview outline (`px-2 py-1.5 rounded-lg`
/// (16px) `hover:bg-emerald-50 dark:hover:bg-emerald-900/30`, selected
/// `bg-emerald-500 text-white`; the [mobile] copy has no dark hover variant).
class _PreviewContentTile extends StatelessWidget {
  const _PreviewContentTile({required this.selected, required this.onTap, required this.child, this.mobile = false});
  final bool selected;
  final bool mobile;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? Tw.emerald500 : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: context.isDark && !mobile ? TcTw.emerald900a30 : Tw.emerald50,
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: child),
        ),
      );
}

/// Hover state for a child built from it.
class _HoverBuilder extends StatefulWidget {
  const _HoverBuilder({required this.builder});
  final Widget Function(bool hover) builder;

  @override
  State<_HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<_HoverBuilder> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: widget.builder(_hover),
      );
}

/// `<transition name="fade">` enter: `opacity 0 → 1`, `translateY(-4px) → 0`
/// over 0.2s.
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
        child: child,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, -4 * (1 - t)), child: child),
        ),
      );
}
