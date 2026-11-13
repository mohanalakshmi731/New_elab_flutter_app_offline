part of 'class_course_create_page.dart';

/// "Preview" tab (`px-4 sm:px-6 md:px-10 lg:px-2`): Section / Chapter /
/// Concept selects, then the course card or the chosen concept.
///
/// The `<Card class="… h-[85vh] overflow-y-auto">` keeps shadcn's `flex
/// flex-col gap-6`, so its children's `mb-*` add to a 24px gap.
class _PreviewTab extends StatelessWidget {
  const _PreviewTab({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  Widget build(BuildContext context) {
    final details = s._selectedCourseDetails;
    if (details == null) return const SizedBox.shrink();
    final dark = context.isDark;
    final sm = context.isSm;
    final hPad = context.isLg
        ? 8.0
        : context.isMd
            ? 40.0
            : sm
                ? 24.0
                : 16.0;
    final height = MediaQuery.sizeOf(context).height * 0.85;
    final item = s._previewItem;

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: dark ? Tw.slate400 : Tw.slate500,
            ),
          ),
        );

    final selects = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.6) : Tw.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
      ),
      child: _Grid(
        columns: context.isMd ? 3 : 1,
        equalHeight: false,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            label('Section'),
            _CcSelect(
              value: s._openSectionId != null && s._openSectionId != 0 ? _numStr(s._openSectionId) : '',
              placeholder: 'Select Section',
              items: [
                for (final sec in mapsOf(details['sections'])) AppSelectItem('${sec['id']}', '${sec['name'] ?? ''}'),
              ],
              onChanged: s._handleSectionSelect,
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            label('Chapter'),
            _CcSelect(
              value: s._openChapterId != null && s._openChapterId != 0 ? _numStr(s._openChapterId) : '',
              placeholder: 'Select Chapter',
              enabled: s._openSectionId != null && s._openSectionId != 0,
              items: [
                for (final ch in s._currentSectionChapters) AppSelectItem('${ch['id']}', '${ch['name'] ?? ''}'),
              ],
              onChanged: s._handleChapterSelect,
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            label('Concept'),
            _CcSelect(
              value: jsTruthy(s._selectedConceptId) ? '${s._selectedConceptId}' : '',
              placeholder: 'Select Concept',
              enabled: s._openChapterId != null && s._openChapterId != 0,
              items: [
                for (final c in s._currentChapterContents) AppSelectItem('${c['id']}', '${c['name'] ?? ''}'),
              ],
              onChanged: s._handleConceptSelect,
            ),
          ]),
        ],
      ),
    );

    // `mb-6` + the card's `gap-6`.
    final children = <Widget>[selects, const SizedBox(height: 48)];
    if (item.type == 'course') children.addAll(_coursePreview(context, details));
    if (item.type == 'content' && item.data != null) children.addAll(_contentPreview(context, item.data!));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor(context)),
          boxShadow: _shadowLg,
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 12, vertical: sm ? 40 : 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }

  List<Widget> _coursePreview(BuildContext context, Map<String, dynamic> d) {
    final dark = context.isDark;
    final published = d['status'] == 'published';
    final image = d['image'];
    return [
      Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _borderColor(context)))),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${d['title'] ?? ''}',
                style: TextStyle(
                  fontSize: 30,
                  height: 36 / 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.75,
                  color: dark ? Colors.white : Tw.slate900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: published ? Tw.emerald100 : Tw.rose100,
                borderRadius: BorderRadius.circular(999),
                boxShadow: _shadowSm,
              ),
              child: Text(
                published ? 'Published' : 'UnPublished',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: published ? Tw.emerald700 : Tw.rose700,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 48),
      Center(
        child: jsTruthy(image)
            ? Container(
                width: 240,
                height: 160,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: _shadowSm),
                child: Image.network('$image', fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
              )
            : const Text('No Image', style: TextStyle(fontStyle: FontStyle.italic, color: Tw.gray400)),
      ),
      const SizedBox(height: 48),
      // `text-slate-700` has no dark variant.
      Text(
        d['description'] == null ? '' : '${d['description']}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, height: 1.625, color: Tw.slate700),
      ),
      const SizedBox(height: 40),
    ];
  }

  List<Widget> _contentPreview(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'];
    final url = data['url'] == null ? null : '${data['url']}';
    final h = MediaQuery.sizeOf(context).height;
    final Widget body;
    if (type == 'html') {
      body = SizedBox(height: h * 0.6, child: WebContentView(html: previewHtml(data['content'])));
    } else if (type == 'url') {
      final boxHeight = context.isLg
          ? 420.0
          : context.isMd
              ? 380.0
              : context.isSm
                  ? 320.0
                  : 260.0;
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            height: boxHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
            child: _UrlPreview(url: url, blockedText: 'Cannot preview this website.', textGap: 0),
          ),
        ),
      );
    } else if (type == 'pdf') {
      body = Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton(
              label: 'Full Screen',
              onPressed: () => showAppDialog<void>(context, builder: (_) => _PdfFullScreenDialog(url: data['url'])),
            ),
            const SizedBox(height: 8),
            _PdfFrame(url: data['url'], height: h * 0.8),
          ],
        ),
      );
    } else {
      body = const Text('No preview available', style: TextStyle(fontStyle: FontStyle.italic, color: Tw.gray400));
    }
    return [
      Text(
        '${data['name'] ?? ''}',
        style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, color: context.colors.primary),
      ),
      // `mb-4` + the card's `gap-6`.
      const SizedBox(height: 40),
      body,
    ];
  }
}

String _numStr(num? n) {
  if (n == null) return '';
  if (n is double && n == n.truncateToDouble()) return n.toInt().toString();
  return '$n';
}

/// The PDF iframe (`url#toolbar=0&navpanes=0&scrollbar=0`, `w-full border rounded`).
class _PdfFrame extends StatelessWidget {
  const _PdfFrame({required this.url, required this.height});
  final Object? url;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _borderColor(context)),
        ),
        child: WebContentView(url: pdfViewerUrl(url), showOpenExternally: true),
      );
}

/// The URL-type concept preview: image, raw video, YouTube, Vimeo, PDF,
/// embeddable site, or the "cannot be previewed" fallback with the link
/// (`text-center text-white p-4`; the message is `text-red-400
/// font-semibold`, plus `mb-2` in the dialog's version).
class _UrlPreview extends StatelessWidget {
  const _UrlPreview({required this.url, required this.blockedText, required this.textGap});
  final String? url;
  final String blockedText;
  final double textGap;

  @override
  Widget build(BuildContext context) {
    final u = url ?? 'undefined';
    switch (urlPreviewKind(url)) {
      case UrlPreviewKind.image:
        return Center(child: Image.network(u, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox.shrink()));
      case UrlPreviewKind.video:
        return WebContentView(
          html: '<video controls style="width:100%;height:100%;max-height:100vh;object-fit:contain;background:#000">'
              '<source src="${_attr(u)}"></video>',
        );
      case UrlPreviewKind.youTube:
        return WebContentView(url: 'https://www.youtube.com/embed/${getYouTubeId(u)}');
      case UrlPreviewKind.vimeo:
        return WebContentView(url: 'https://player.vimeo.com/video/${getVimeoId(u)}');
      case UrlPreviewKind.pdf:
        return WebContentView(url: pdfViewerUrl(u), showOpenExternally: true);
      case UrlPreviewKind.embed:
        return WebContentView(url: u, showOpenExternally: true);
      case UrlPreviewKind.blocked:
        final primary = context.colors.primary;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(blockedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Tw.red400, fontWeight: FontWeight.w600)),
                SizedBox(height: textGap),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => openExternal(u),
                    child: Text(
                      u,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: primary, decoration: TextDecoration.underline, decorationColor: primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  static String _attr(String v) => v.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');
}

/// Concept preview dialog opened from the Manage tab (`isContentPreviewOpen`):
/// `sm:max-w-8xl` is not a Tailwind size, so the dialog spans the screen
/// (`max-w-[calc(100%-2rem)]`); `max-h-[90vh] overflow-y-auto bg-white
/// dark:bg-primary-foreground text-slate-900 dark:text-white`.
///
/// The Close button is `block` (full width, `rounded`) with `mt-6`.
class _ContentPreviewDialog extends StatelessWidget {
  const _ContentPreviewDialog({required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final h = MediaQuery.sizeOf(context).height;
    final type = content['type'];
    final url = content['url'] == null ? null : '${content['url']}';

    final Widget body;
    // Space below the body: its `mb-6` (not for URLs) + `gap-4` + the button's `mt-6`.
    var below = 16.0 + 24;
    if (type == 'html') {
      body = SizedBox(height: h * 0.6, child: WebContentView(html: previewHtml(content['content'])));
      below += 24;
    } else if (type == 'url') {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            height: context.isMd ? 450 : 350,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: _UrlPreview(url: url, blockedText: 'This website cannot be previewed.', textGap: 8),
          ),
        ),
      );
    } else if (type == 'pdf') {
      body = _PdfFrame(url: content['url'], height: h * 0.8);
      below += 24;
    } else {
      body = const Text('No preview available');
      below += 24;
    }

    return _CcDialog(
      maxWidth: double.infinity,
      maxHeight: h * 0.9,
      solidLight: true,
      solidDark: true,
      textColor: dark ? Colors.white : Tw.slate900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // `<DialogHeader><h3 class="text-xl font-semibold mb-4">` + `gap-4`.
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(
              '${content['name'] ?? ''}',
              textAlign: _headerAlign(context),
              style: const TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32),
          body,
          SizedBox(height: below),
          AppButton(
            label: 'Close',
            expand: true,
            radius: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// "Full Screen" PDF dialog of the Preview tab (`isPDFopen`): `h-[90vh]
/// bg-white dark:bg-primary-foreground`, spanning the screen.
class _PdfFullScreenDialog extends StatelessWidget {
  const _PdfFullScreenDialog({required this.url});
  final Object? url;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return _CcDialog(
      maxWidth: double.infinity,
      height: h * 0.9,
      solidLight: true,
      solidDark: true,
      textColor: context.isDark ? Colors.white : Tw.slate900,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _PdfFrame(url: url, height: h * 0.8),
      ),
    );
  }
}
