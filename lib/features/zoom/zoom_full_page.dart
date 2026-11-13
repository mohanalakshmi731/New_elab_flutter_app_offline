import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/surface_card.dart';
import '../common/lms_handoff.dart';

/// Port of `src/pages/schedules/ZoomFullClient.vue` (`/zoom-full`).
///
/// On the web this page embedded the Zoom Meeting SDK client full-screen and
/// joined the meeting stored in `userStore.zoomMeetingData`
/// (`{ meetingNumber, signature, passcode, userName, zak }`, set by the
/// schedules screens' `openFullClient` via `setZoomMeetingData` before they
/// opened `/zoom-full`). Without meeting data it went back to `/schedules`.
///
/// In the app the meeting opens in the installed Zoom app (or the browser)
/// through [openZoomMeeting]: this page shows the meeting info, triggers
/// "Join in Zoom" once on open, and offers Back.
///
/// The meeting comes from [meeting] when given (e.g. the router's `extra`),
/// otherwise from lmsHandoff `zoomMeetingData` (the web store field).
class ZoomFullPage extends ConsumerStatefulWidget {
  const ZoomFullPage({super.key, this.meeting});

  /// `{ meetingNumber, signature, passcode, userName, zak }`
  final Map<String, dynamic>? meeting;

  @override
  ConsumerState<ZoomFullPage> createState() => _ZoomFullPageState();
}

/// The SDK's `leaveUrl` (and the redirect when there is no meeting).
const _leaveRoute = '/schedules';

class _ZoomFullPageState extends ConsumerState<ZoomFullPage> {
  bool _opening = false;

  Map<String, dynamic>? get _meeting =>
      widget.meeting ?? asMap(ref.read(lmsHandoffProvider)['zoomMeetingData']);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // `if (!meeting) router.push('/schedules')`
      if (_meeting == null) {
        context.go(_leaveRoute);
        return;
      }
      _join(); // ZoomMtg.init → join, once on open
    });
  }

  String? _field(String key) {
    final v = _meeting?[key];
    return jsTruthy(v) ? '$v' : null;
  }

  Future<void> _join() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await openZoomMeeting(meetingNumber: _field('meetingNumber'), password: _field('passcode'));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_leaveRoute);
    }
  }

  Future<void> _copy(String value, String what) async {
    await Clipboard.setData(ClipboardData(text: value));
    AppToast.success('$what copied');
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final muted = dark ? AppColors.darkMutedForeground : Tw.slate500;
    final meeting = _meeting;
    final meetingNumber = _field('meetingNumber');
    final passcode = _field('passcode');
    final userName = _field('userName');
    final isHost = meeting != null && jsTruthy(meeting['zak']);

    Widget infoRow(String label, String? value, {bool copyable = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(label, style: TextStyle(fontSize: 14, color: muted)),
              ),
              Expanded(
                child: SelectableText(
                  value ?? '—',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (copyable && value != null)
                IconButton(
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  color: muted,
                  onPressed: () => _copy(value, label),
                  icon: const Icon(BootstrapIcons.copy),
                ),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isSm ? 24 : 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(BootstrapIcons.camera_video_fill, size: 22, color: context.colors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Zoom Meeting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            'The meeting opens in the Zoom app, or in your browser if Zoom is not installed.',
                            style: TextStyle(fontSize: 13, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: dark ? Tw.slate800 : Tw.slate100),
                const SizedBox(height: 12),
                infoRow('Meeting ID', meetingNumber, copyable: true),
                infoRow('Passcode', passcode, copyable: true),
                infoRow('Name', userName),
                if (isHost) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You are the host: sign in to the Zoom app with the host account to start the meeting.',
                    style: TextStyle(fontSize: 13, color: muted),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      label: 'Back',
                      icon: BootstrapIcons.arrow_left,
                      variant: AppButtonVariant.outline,
                      onPressed: _back,
                    ),
                    AppButton(
                      label: 'Join in Zoom',
                      loadingLabel: 'Opening Zoom...',
                      icon: BootstrapIcons.box_arrow_up_right,
                      loading: _opening,
                      onPressed: meeting == null ? null : _join,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
