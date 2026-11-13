part of 'course_list_view.dart';

/// `#toolbar=0&navpanes=0&scrollbar=0` PDF viewer URL.
String _pdfViewerUrl(Object? url) => '$url#toolbar=0&navpanes=0&scrollbar=0';

/// `h-[70vh] sm:h-[80vh]`
double _pdfHeight(BuildContext context) => MediaQuery.sizeOf(context).height * (context.isSm ? 0.8 : 0.7);

/// Height given to `v-html` concept bodies (the web lets them grow; a
/// WebView needs a fixed height).
double _htmlHeight(BuildContext context) => (MediaQuery.sizeOf(context).height * 0.7).clamp(320.0, 900.0);

/// The black `type === 'url'` preview box (image / video / YouTube / Vimeo /
/// PDF / iframe / "cannot be previewed").
class _UrlPreviewBox extends StatelessWidget {
  const _UrlPreviewBox({required this.url, required this.maxWidth, required this.heights, required this.blockedText});

  final String url;
  final double maxWidth;

  /// Heights for `< 380`, `xs` (380), `sm`, `md`, `lg`. The component's own
  /// unlayered `xs:h-[…]` rule beats the `sm:`/`md:`/`lg:` utilities, so the
  /// callers pass the `xs` height for every width from 380px up.
  final List<double> heights;
  final String blockedText;

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final height = w >= 1024
        ? heights[4]
        : w >= 768
        ? heights[3]
        : w >= 640
        ? heights[2]
        : w >= 380
        ? heights[1]
        : heights[0];
    final Widget content = switch (urlPreviewKind(url)) {
      UrlPreviewKind.image => Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
      UrlPreviewKind.video => WebContentView(
        html:
            '<video controls style="width:100%;height:100%;object-fit:contain;background:#000">'
            '<source src="${const HtmlEscape(HtmlEscapeMode.attribute).convert(url)}"></video>',
      ),
      UrlPreviewKind.youtube => WebContentView(url: 'https://www.youtube.com/embed/${youTubeId(url)}'),
      UrlPreviewKind.vimeo => WebContentView(url: 'https://player.vimeo.com/video/${vimeoId(url)}'),
      UrlPreviewKind.pdf => WebContentView(url: _pdfViewerUrl(url), showOpenExternally: true),
      UrlPreviewKind.embed => WebContentView(url: url),
      UrlPreviewKind.blocked => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                blockedText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _CC.red400, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _Hover(
                onTap: () => openExternal(url),
                builder: (_) => Text(
                  url,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _CC.blue300,
                    decoration: TextDecoration.underline,
                    decorationColor: _CC.blue300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    };
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
          child: content,
        ),
      ),
    );
  }
}

/// `<iframe :src="pdf#toolbar=0…" class="w-full h-[70vh] sm:h-[80vh] border rounded">`
Widget _pdfFrame(BuildContext context, Object? url) => Container(
  height: _pdfHeight(context),
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: context.isDark ? AppColors.darkBorder : AppColors.border),
  ),
  child: WebContentView(url: _pdfViewerUrl(url), showOpenExternally: true),
);

/// Preview tab: section / chapter / concept pickers and the course or
/// concept preview.
extension _PreviewUi on _CourseListViewState {
  Widget _buildPreviewTab() {
    final details = _selectedCourseDetails;
    final sm = context.isSm;
    final md = context.isMd;
    final lg = context.isLg;
    final dark = context.isDark;
    // `px-0 sm:px-6 md:px-10 lg:px-2`
    final pad = lg ? 8.0 : (md ? 40.0 : (sm ? 24.0 : 0.0));
    if (details == null) return const SizedBox.shrink();

    final sections = [for (final s in asList(details['sections'])) ?asMap(s)];
    final chapters = _previewChapters;
    final contents = _previewContents;

    Widget picker(String label, Widget select) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
            color: dark ? Tw.slate400 : Tw.slate500,
          ),
        ),
        const SizedBox(height: 6),
        select,
      ],
    );

    // `<SelectTrigger class="w-full bg-white dark:bg-card border-slate-200
    // dark:border-slate-800 rounded-xl h-10 text-xs sm:text-sm font-semibold
    // shadow-xs">` (the kit's `data-[size=default]:h-9` beats `h-10`).
    Widget select({
      required String value,
      required String placeholder,
      required List<Map<String, dynamic>> items,
      required ValueChanged<String?> onChanged,
      bool enabled = true,
    }) {
      final selected = items.where((e) => '${e['id']}' == value).firstOrNull;
      return _Dropdown(
        items: [
          for (final e in items)
            _menuItem(
              select: true,
              selected: '${e['id']}' == value,
              onPressed: () => onChanged('${e['id']}'),
              child: Text(vText(e['name'])),
            ),
        ],
        trigger: (toggle, _) => _OutlineTrigger(
          onTap: toggle,
          button: false,
          spaceBetween: true,
          enabled: enabled,
          background: dark ? AppColors.darkCard : Colors.white,
          borderColor: dark ? Tw.slate800 : Tw.slate200,
          placeholder: selected == null,
          text: selected == null ? placeholder : vText(selected['name']),
          textStyle: TextStyle(fontSize: sm ? 14 : 12, height: sm ? 20 / 14 : 16 / 12, fontWeight: FontWeight.w600),
        ),
      );
    }

    final pickers = _Grid(
      columns: md ? 3 : 1,
      children: [
        picker(
          'Section',
          select(
            value: _selectedPreviewSectionId,
            placeholder: 'Select Section',
            items: sections,
            onChanged: _onPreviewSectionChange,
          ),
        ),
        picker(
          'Chapter',
          select(
            value: _selectedPreviewChapterId,
            placeholder: chapters.isEmpty ? 'No chapters' : 'Select Chapter',
            enabled: _selectedPreviewSectionId.isNotEmpty && chapters.isNotEmpty,
            items: chapters,
            onChanged: _onPreviewChapterChange,
          ),
        ),
        picker(
          'Concept',
          select(
            value: _selectedPreviewContentId,
            placeholder: contents.isEmpty ? 'No concepts' : 'Select Concept',
            enabled: _selectedPreviewChapterId.isNotEmpty && contents.isNotEmpty,
            items: contents,
            onChanged: _onPreviewContentChange,
          ),
        ),
      ],
    );

    final item = _previewItem;
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 16, pad, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // `mb-6 pb-6 border-b border-slate-150` (no such colour → `--border`),
          // plus the card's `gap-6`.
          Container(
            margin: const EdgeInsets.only(bottom: 48),
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border)),
            ),
            child: pickers,
          ),
          if (item.type == 'course') _buildCoursePreview(details),
          if (item.type == 'content' && item.data != null) _buildContentPreview(item.data!),
        ],
      ),
    );
  }

  /// `previewItem.type === 'course'` (reads `selectedCourseDetails`).
  Widget _buildCoursePreview(Map<String, dynamic> details) {
    final sm = context.isSm;
    final dark = context.isDark;
    final published = details['status'] == 'published';
    final title = Text(
      vText(details['title']),
      style: TextStyle(
        fontSize: sm ? 30 : 24,
        height: (sm ? 36 : 32) / (sm ? 30 : 24),
        fontWeight: FontWeight.w800,
        letterSpacing: (sm ? 30 : 24) * -0.025,
        color: dark ? Colors.white : Tw.slate900,
      ),
    );
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: published ? Tw.emerald100 : _CC.rose100,
        borderRadius: BorderRadius.circular(999),
        boxShadow: _CC.shadowSm,
      ),
      child: Text(
        published ? 'Published' : 'UnPublished',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: published ? Tw.emerald700 : _CC.rose700),
      ),
    );
    final image = details['image'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `mb-6` + the card's `gap-6` after each block.
        Container(
          margin: const EdgeInsets.only(bottom: 48),
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border)),
          ),
          child: sm
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: title),
                    const SizedBox(width: 12),
                    pill,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), pill],
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Center(
            child: jsTruthy(image)
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      height: sm ? 240 : 192,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: _CC.shadowSm),
                      child: Image.network(
                        '$image',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  )
                : const Text(
                    'No Image',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Tw.gray400),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            vText(details['description']),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: sm ? 18 : 16, height: 1.625, color: Tw.slate700),
          ),
        ),
      ],
    );
  }

  /// `previewItem.type === 'content'`
  Widget _buildContentPreview(Map<String, dynamic> data) {
    final sm = context.isSm;
    final type = data['type'];
    final Widget body;
    if (type == 'html') {
      body = SizedBox(
        height: _htmlHeight(context),
        child: WebContentView(html: vText(data['content'])),
      );
    } else if (type == 'url') {
      body = _UrlPreviewBox(
        url: vText(data['url']),
        maxWidth: 1000,
        // `h-[200px] xs:h-[260px] sm:… lg:h-[420px]` → 260 from 380px up.
        heights: const [200, 260, 260, 260, 260],
        blockedText: 'Cannot preview this website.',
      );
    } else if (type == 'pdf') {
      body = Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'Full Screen',
                onPressed: () => unawaited(_showDialog(_buildPdfFullscreenDialog)),
              ),
            ),
            const SizedBox(height: 8),
            _pdfFrame(context, data['url']),
          ],
        ),
      );
    } else {
      body = const Text(
        'No preview available',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Tw.gray400),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `mb-4` + the card's `gap-6`.
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            vText(data['name']),
            style: TextStyle(
              fontSize: sm ? 24 : 20,
              height: (sm ? 32 : 28) / (sm ? 24 : 20),
              fontWeight: FontWeight.w700,
              color: Tw.blue700,
            ),
          ),
        ),
        body,
      ],
    );
  }

  /// Fullscreen PDF dialog (`isPDFopen`).
  /// `<DialogContent class="sm:max-w-6xl h-[90vh] flex flex-col overflow-auto">`
  Widget _buildPdfFullscreenDialog(BuildContext ctx) => AppDialogFrame(
    maxWidth: 1152,
    child: SizedBox(
      height: (MediaQuery.sizeOf(ctx).height * 0.9 - 48).clamp(0.0, double.infinity),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(padding: const EdgeInsets.only(top: 12), child: _pdfFrame(ctx, _previewItem.data?['url'])),
      ),
    ),
  );
}
