import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../schedules/schedule_exam_logic.dart' show jsStr;
import 'exam_style.dart';

/// `PanelLog`
class PanelLog {
  const PanelLog({required this.id, required this.time, required this.kind, required this.message});
  final int id;
  final String time;
  final String kind;
  final String message;
}

/// `statusBadgeClass`
enum BadgeTone { gray, red, green, blue }

/// The template of `ExamProctorPanel.vue` (all state lives in
/// `ExamProctorPanel`).
class ProctorPanelView extends StatelessWidget {
  const ProctorPanelView({
    super.key,
    required this.statusLabel,
    required this.statusTone,
    required this.warningCount,
    required this.maxWarnings,
    required this.activityLabel,
    required this.camera,
    required this.overlay,
    required this.cameraReady,
    required this.cameraMessage,
    required this.referenceCaptured,
    required this.environmentConfirmed,
    required this.onEnvironmentConfirmed,
    required this.captureDisabled,
    required this.captureLabel,
    required this.onCapture,
    required this.leftConfirmed,
    required this.faces,
    required this.persons,
    required this.gadgets,
    required this.head,
    required this.audio,
    required this.recording,
    required this.latestLogTime,
    required this.topEvents,
    required this.showPhoneLike,
    required this.logs,
  });

  final String statusLabel;
  final BadgeTone statusTone;
  final int warningCount;
  final int maxWarnings;
  final String activityLabel;
  final Widget camera;
  final Widget overlay;
  final bool cameraReady;
  final String cameraMessage;
  final bool referenceCaptured;
  final bool environmentConfirmed;
  final ValueChanged<bool> onEnvironmentConfirmed;
  final bool captureDisabled;
  final String captureLabel;
  final VoidCallback onCapture;
  final bool leftConfirmed;
  final String faces;
  final String persons;
  final String gadgets;
  final String head;
  final String audio;
  final String recording;
  final String latestLogTime;
  final List<Map<String, dynamic>> topEvents;
  final bool showPhoneLike;
  final List<PanelLog> logs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bounded = constraints.hasBoundedHeight;
      final video = _videoBox();

      Widget body;
      if (!referenceCaptured) {
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [video, const SizedBox(height: 10), _verification(context)],
        );
        body = bounded
            ? Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: content))
            : Padding(padding: const EdgeInsets.all(12), child: content);
      } else {
        final logsBox = _logsBox(context);
        body = Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              video,
              const SizedBox(height: 10),
              _statRow(context, [('Faces', faces), ('Persons', persons), ('Gadgets', gadgets)],
                  big: true),
              const SizedBox(height: 10),
              _statRow(context, [('Head', head), ('Audio', audio), ('Recording', recording)],
                  big: false),
              const SizedBox(height: 10),
              if (bounded) Expanded(child: logsBox) else SizedBox(height: 240, child: logsBox),
            ],
          ),
        );
        if (bounded) body = Expanded(child: body);
      }

      final card = Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Ex.panelBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Ex.panelBorder),
          boxShadow: exShadowSm,
        ),
        child: Column(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_header(), body],
        ),
      );
      return bounded ? card : ConstrainedBox(constraints: const BoxConstraints(minHeight: 500), child: card);
    });
  }

  Widget _header() {
    final (bg, fg) = switch (statusTone) {
      BadgeTone.gray => (Ex.gray100, Ex.gray700),
      BadgeTone.red => (Ex.red100, Ex.red700),
      BadgeTone.green => (Ex.green100, Ex.green700),
      BadgeTone.blue => (Ex.blue100, Ex.blue),
    };
    final rows = <Widget>[];
    for (var start = 1; start <= maxWarnings; start += 3) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 6));
      rows.add(Row(children: [
        for (var i = start; i < start + 3; i++) ...[
          if (i > start) const SizedBox(width: 6),
          Expanded(
            child: i <= maxWarnings
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= warningCount ? Ex.red500 : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  )
                : const SizedBox(height: 6),
          ),
        ],
      ]));
    }
    final small = TextStyle(fontSize: 10.88, height: 1.5, color: Colors.white.withValues(alpha: 0.55));
    return Container(
      color: Ex.ink,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Text(
                      'PROCTOR AI',
                      style: TextStyle(
                        fontSize: 9.92,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.38,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const Text(
                      'Identity Monitor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600, height: 1.25, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                child: Text(statusLabel,
                    style: TextStyle(fontSize: 10.88, height: 1.5, fontWeight: FontWeight.w700, color: fg)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$warningCount/$maxWarnings warnings', style: small),
              Text(activityLabel, style: small),
            ],
          ),
        ],
      ),
    );
  }

  Widget _videoBox() => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Ex.ink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Ex.panelBorder),
          boxShadow: exShadowSm,
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              camera,
              IgnorePointer(child: overlay),
              if (!cameraReady)
                Container(
                  color: Ex.ink.withValues(alpha: 0.9),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    cameraMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 16 / 12, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _verification(BuildContext context) {
    final muted = TextStyle(fontSize: 12, height: 1.625, color: context.exMuted);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Ex.panelBorder),
        boxShadow: exShadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Start verification',
              style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: Ex.ink)),
          const SizedBox(height: 4),
          Text('Close Teams, screen sharing, remote tools, and extra apps before capturing.',
              style: muted),
          const SizedBox(height: 8),
          Text(
            'Starting verification sends your camera photo to the proctoring service. During the exam, '
            'camera and microphone recordings, analysis data, and activity logs are sent to that service.',
            style: muted,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onEnvironmentConfirmed(!environmentConfirmed),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Ex.panelBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Ex.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ExamCheckbox(value: environmentConfirmed, onChanged: onEnvironmentConfirmed),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('I confirm only this exam browser is active.',
                        style: TextStyle(fontSize: 12, height: 16 / 12, color: Ex.ink)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CaptureButton(label: captureLabel, onPressed: captureDisabled ? null : onCapture),
          if (!leftConfirmed) ...[
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(BootstrapIcons.exclamation_circle_fill, size: 11, color: Ex.amber600),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Please accept the guidelines on the left.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.2, height: 1.5, fontWeight: FontWeight.w600, color: Ex.amber600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, List<(String, String)> items, {required bool big}) {
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(big ? 16 : 20),
                border: Border.all(color: Ex.line),
                boxShadow: big ? exShadowSm : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].$1.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 9.28,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.93,
                      color: context.exMuted,
                    ),
                  ),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: big
                        ? const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600, height: 1.25, color: Ex.ink)
                        : const TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Ex.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
      ),
    );
  }

  Widget _logsBox(BuildContext context) {
    final muted = context.exMuted;
    final chips = <Widget>[
      for (final event in topEvents) _eventChip(event),
      if (showPhoneLike)
        _chip('PHONE_LIKE_OBJECT', Ex.red100, Ex.red700),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Ex.line),
        boxShadow: exShadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Logs',
                  style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Ex.ink)),
              const SizedBox(width: 12),
              Text(latestLogTime, style: TextStyle(fontSize: 10.4, height: 1.5, color: muted)),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: chips),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.separated(
                padding: const EdgeInsets.only(right: 4),
                itemCount: logs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final log = logs[i];
                  return Container(
                    key: ValueKey(log.id),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Ex.panelBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Ex.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(log.time, style: TextStyle(fontSize: 9.92, height: 1.5, color: muted)),
                            const SizedBox(width: 8),
                            Text(
                              log.kind.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.28,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.93,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.52, height: 1.375, color: Ex.ink),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `eventClass(severity)`
  Widget _eventChip(Map<String, dynamic> event) {
    final severity = event['severity'];
    final (bg, fg) = severity == 'CRITICAL'
        ? (Ex.red100, Ex.red700)
        : severity == 'WARNING'
            ? (Ex.amber100, Ex.amber700)
            : (Ex.blue50, Ex.blue);
    final type = event['type'];
    return _chip(type == null ? '' : jsStr(type), bg, fg);
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: TextStyle(fontSize: 10.4, height: 1.5, fontWeight: FontWeight.w600, color: fg)),
      );
}

class _CaptureButton extends StatefulWidget {
  const _CaptureButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hover ? Ex.blueHover : Ex.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// `<input type="checkbox" class="h-4 w-4 accent-[#2563eb]">`
class ExamCheckbox extends StatelessWidget {
  const ExamCheckbox({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Checkbox(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        activeColor: Ex.blue,
        checkColor: Colors.white,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: const BorderSide(color: Color(0xFF767676), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}
