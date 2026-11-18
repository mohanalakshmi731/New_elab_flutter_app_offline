import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/app_dialog.dart';

/// Announces confirmed connection transitions without navigating the learner.
class ConnectionTransitionHost extends StatefulWidget {
  const ConnectionTransitionHost({
    super.key,
    required this.navigatorKey,
    required this.sessionIdentity,
    required this.reachable,
    required this.hasPrepared,
    required this.deviceHasNetwork,
    required this.child,
    this.localMode = false,
    this.onContinueOffline,
    this.onSwitchOnline,
    this.onOfflineDetected,
    this.stabilityDelay = const Duration(seconds: 2),
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final String? sessionIdentity;
  final bool? reachable;
  final bool hasPrepared;
  final bool localMode;
  final VoidCallback? onContinueOffline, onSwitchOnline, onOfflineDetected;
  final Future<bool> Function() deviceHasNetwork;
  final Widget child;
  final Duration stabilityDelay;
  @override
  State<ConnectionTransitionHost> createState() =>
      _ConnectionTransitionHostState();
}

class _ConnectionTransitionHostState extends State<ConnectionTransitionHost> {
  Timer? _timer;
  bool? _lastStable;
  int _generation = 0;
  RawDialogRoute<void>? _route;
  ValueNotifier<_ConnectionNotice>? _notice;
  @override
  void initState() {
    super.initState();
    _lastStable = widget.reachable == true ? true : null;
    _schedule();
  }

  @override
  void didUpdateWidget(ConnectionTransitionHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionIdentity != widget.sessionIdentity) {
      _lastStable = widget.reachable == true ? true : null;
      _closeOwnedRoute();
    }
    if (oldWidget.reachable != widget.reachable ||
        oldWidget.sessionIdentity != widget.sessionIdentity)
      _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final generation = ++_generation;
    final next = widget.reachable;
    if (widget.sessionIdentity == null || next == null) return;
    // Initial successful checks and repeated polls are not transitions.
    if (_lastStable == null && next) {
      _lastStable = true;
      return;
    }
    if (next == _lastStable) return;
    _timer = Timer(widget.stabilityDelay, () => _announce(next, generation));
  }

  Future<void> _announce(bool reachable, int generation) async {
    var hasNetwork = true;
    if (!reachable) {
      try {
        hasNetwork = await widget.deviceHasNetwork().timeout(
          const Duration(seconds: 2),
        );
      } catch (_) {
        /* Do not mislabel a service failure as no internet. */
      }
    }
    if (!mounted ||
        generation != _generation ||
        widget.sessionIdentity == null ||
        widget.reachable != reachable)
      return;
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null || !navigator.mounted) return;
    _lastStable = reachable;
    if (!reachable && widget.hasPrepared) widget.onOfflineDetected?.call();
    final data = _ConnectionNotice(
      reachable: reachable,
      hasNetwork: hasNetwork,
      hasPrepared: widget.hasPrepared,
      localMode: widget.localMode,
    );
    // A newer confirmed transition updates the one visible modal instead of stacking.
    if (_route?.isActive == true && _notice != null) {
      _notice!.value = data;
      return;
    }
    final notice = ValueNotifier(data);
    _notice = notice;
    final reducedMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    final route = RawDialogRoute<void>(
      barrierDismissible: true,
      barrierLabel: 'Dismiss connection message',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 240),
      pageBuilder: (context, _, __) => SafeArea(
        child: ValueListenableBuilder<_ConnectionNotice>(
          valueListenable: notice,
          builder: (context, value, _) => _ConnectionModal(
            notice: value,
            onContinueOffline: widget.onContinueOffline,
            onSwitchOnline: widget.onSwitchOnline,
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(
            Tween(
              begin: 0.95,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        ),
      ),
    );
    _route = route;
    unawaited(
      navigator.push<void>(route).whenComplete(() {
        if (identical(_route, route)) {
          _route = null;
          _notice = null;
        }
        notice.dispose();
      }),
    );
  }

  void _closeOwnedRoute() {
    final route = _route;
    final navigator = widget.navigatorKey.currentState;
    _route = null;
    _notice = null;
    if (route == null || navigator == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted && route.isActive) navigator.removeRoute(route);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _generation++;
    _closeOwnedRoute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ConnectionNotice {
  const _ConnectionNotice({
    required this.reachable,
    required this.hasNetwork,
    required this.hasPrepared,
    required this.localMode,
  });
  final bool reachable, hasNetwork, hasPrepared, localMode;
  bool get offerModeChoice => reachable && localMode && hasPrepared;
  String get title => reachable
      ? 'You’re back online!'
      : hasNetwork
      ? 'We can’t connect right now'
      : hasPrepared
      ? 'You’re offline. Keep learning!'
      : 'You’re offline';
  String get message => reachable
      ? offerModeChoice
            ? 'Would you like to continue learning offline or switch to online learning? Your saved progress will update automatically.'
            : 'You can access online lessons again. We’ll update any saved progress automatically.'
      : hasPrepared
      ? 'Your prepared lessons are available, and your progress will be saved automatically.'
      : 'Check your connection to get back to learning. You can prepare lessons for offline use when you’re online.';
  String get action => reachable
      ? 'Continue'
      : hasPrepared
      ? 'Continue offline learning'
      : 'Got it';
}

class _ConnectionModal extends StatelessWidget {
  const _ConnectionModal({
    required this.notice,
    this.onContinueOffline,
    this.onSwitchOnline,
  });
  final VoidCallback? onContinueOffline, onSwitchOnline;
  final _ConnectionNotice notice;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = notice.reachable ? const Color(0xFF16806A) : colors.primary;
    return AppDialogFrame(
      maxWidth: 420,
      radius: 28,
      showClose: false,
      padding: const EdgeInsets.all(28),
      backgroundColor: dark ? const Color(0xFF182139) : const Color(0xFFFCFBFF),
      borderColor: dark ? const Color(0xFF35415D) : const Color(0xFFE5E1F7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  accent.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.16)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                notice.reachable
                    ? Icons.wifi_rounded
                    : notice.hasNetwork
                    ? Icons.cloud_off_rounded
                    : Icons.wifi_off_rounded,
                key: ValueKey('${notice.reachable}:${notice.hasNetwork}'),
                size: 38,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            notice.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : const Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            notice.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.55,
              color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (!notice.reachable && notice.hasPrepared ||
                    notice.offerModeChoice)
                  onContinueOffline?.call();
              },
              icon: Icon(
                notice.reachable
                    ? Icons.check_rounded
                    : notice.hasPrepared
                    ? Icons.play_arrow_rounded
                    : Icons.check_rounded,
              ),
              label: Text(
                notice.offerModeChoice
                    ? 'Continue offline learning'
                    : notice.action,
              ),
            ),
          ),
          if (notice.offerModeChoice) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onSwitchOnline?.call();
                },
                icon: const Icon(Icons.wifi_rounded),
                label: const Text('Switch to online'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
