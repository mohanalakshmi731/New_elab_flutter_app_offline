import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/web_content_view.dart';
import '../users/users_widgets.dart' show ShadCard;

/// Port of `src/pages/schedules/recordings.vue`, embedded by the schedules
/// screens as `<Recordings v-if="recordings" />` (no props).
///
/// Sizes itself to its content; scrolls when the parent bounds its height.
///
/// The web page shows a hard-coded list of sample batches/videos (no API);
/// "View Recording" opens a full-screen player (`<video controls autoplay>`).
class RecordingsView extends ConsumerStatefulWidget {
  const RecordingsView({super.key});

  @override
  ConsumerState<RecordingsView> createState() => _RecordingsViewState();
}

typedef _Video = ({int id, String title, String date, String duration, String url});
typedef _BatchGroup = ({int id, String title, List<_Video> videos});

const _sample = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample';

/// `data().batchGroups` (verbatim, including the duplicated entries).
const List<_BatchGroup> _batchGroups = [
  (
    id: 1,
    title: 'MBBS FIRST YEAR – ANATOMY BATCH',
    videos: [
      (id: 11, title: 'Lecture 1 – Bones & Joints', date: '2025-01-04', duration: '55 min', url: '$_sample/BigBuckBunny.mp4'),
      (id: 12, title: 'Lecture 2 – Muscles', date: '2025-01-10', duration: '1 hr 10 min', url: '$_sample/Sintel.mp4'),
      (id: 22, title: 'Lecture – Cardiovascular', date: '2025-01-14', duration: '1 hr 05 min', url: '$_sample/TearsOfSteel.mp4'),
    ],
  ),
  (
    id: 2,
    title: 'MBBS FIRST YEAR – PHYSIOLOGY BATCH',
    videos: [
      (id: 21, title: 'Lecture – Nervous System', date: '2025-01-08', duration: '45 min', url: '$_sample/ElephantsDream.mp4'),
      (id: 22, title: 'Lecture – Cardiovascular', date: '2025-01-14', duration: '1 hr 05 min', url: '$_sample/TearsOfSteel.mp4'),
      (id: 22, title: 'Lecture – Cardiovascular', date: '2025-01-14', duration: '1 hr 05 min', url: '$_sample/TearsOfSteel.mp4'),
    ],
  ),
];

class _RecordingsViewState extends ConsumerState<RecordingsView> {
  // `showModal` / `currentVideoUrl` live in the dialog route.

  /// `openModal(item)` — full-screen player; `×` (`closeModal`) closes it.
  Future<void> _openModal(_Video item) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      pageBuilder: (ctx, _, _) => _VideoModal(url: item.url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _batchGroups;
    // `text-gray-500` (no dark variant).
    const muted = Tw.gray500;

    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: ShadCard(
        padding: const EdgeInsets.all(20),
        child: groups.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const Text('No recordings found', textAlign: TextAlign.center, style: TextStyle(color: muted)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final g in groups) _group(context, g)],
              ),
      ),
    );

    // Sizes to its content; scrolls when the parent bounds its height.
    return LayoutBuilder(
      builder: (context, c) => c.hasBoundedHeight ? SingleChildScrollView(child: content) : content,
    );
  }

  Widget _group(BuildContext context, _BatchGroup group) {
    final columns = context.isLg ? 3 : (context.isSm ? 2 : 1);
    final rows = <List<_Video>>[];
    for (var i = 0; i < group.videos.length; i += columns) {
      rows.add(group.videos.sublist(i, (i + columns).clamp(0, group.videos.length)));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            group.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: 16),
                    Expanded(
                      child: c < rows[r].length
                          ? _RecordingCard(video: rows[r][c], onView: () => _openModal(rows[r][c]))
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `<Card class="p-4 border cursor-pointer hover:shadow-lg transition
/// dark:border-white">` (Card = `flex flex-col gap-6`).
class _RecordingCard extends StatefulWidget {
  const _RecordingCard({required this.video, required this.onView});
  final _Video video;
  final VoidCallback onView;

  @override
  State<_RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<_RecordingCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final v = widget.video;
    final meta = TextStyle(fontSize: 14, color: dark ? context.colors.secondary : Tw.gray600);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Colors.white : AppColors.border),
          // The app's `--shadow-sm` / `--shadow-lg` tokens.
          boxShadow: [
            const BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
            _hover
                ? const BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4))
                : const BoxShadow(color: Color(0x1A000000), blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // h3 `mb-2` + the card's `gap-6`
            Text(v.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.primary)),
            const SizedBox(height: 8 + 24),
            Text('Date: ${v.date}', style: meta),
            const SizedBox(height: 4 + 24),
            Text('Duration: ${v.duration}', style: meta),
            const SizedBox(height: 8 + 24),
            AppButton(label: 'View Recording', expand: true, onPressed: widget.onView),
          ],
        ),
      ),
    );
  }
}

/// The `fixed inset-0 bg-black` overlay with the autoplaying video and the
/// white `×` close button.
class _VideoModal extends StatelessWidget {
  const _VideoModal({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final src = const HtmlEscape(HtmlEscapeMode.attribute).convert(url);
    final html = '<style>html,body{margin:0!important;height:100%;background:#000;overflow:hidden}'
        'video{width:100%!important;height:100%!important;max-width:none!important;object-fit:cover}</style>'
        '<video controls autoplay><source src="$src" type="video/mp4">'
        'Your browser does not support the video tag.</video>';

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: WebContentView(html: html)),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text(
                    '×',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, height: 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
