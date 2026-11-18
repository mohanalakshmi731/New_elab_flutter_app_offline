import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/toast.dart';
import '../../state/providers.dart';
import 'offline_service.dart';

class OfflineRuntimeState {
  const OfflineRuntimeState({
    this.reachable,
    this.preparing = false,
    this.message = '',
    this.revision = 0,
  });
  final bool? reachable;
  final bool preparing;
  final String message;

  /// Changes to installed learning content or account scope, not upload acknowledgments.
  final int revision;
}

final offlineNetworkAdaptersProvider = Provider<Future<String> Function()>(
  (ref) => () async {
    final interfaces = await NetworkInterface.list(includeLoopback: false);
    final addresses = [
      for (final adapter in interfaces)
        for (final address in adapter.addresses)
          '${adapter.name}:${address.address}',
    ]..sort();
    return addresses.join('|');
  },
);

/// Local servers and virtual adapters can remain reachable without internet.
/// No account data or authorization headers are sent to these endpoints.
Future<bool> checkOfflineInternet(Dio client) async {
  for (final url in [
    'https://www.gstatic.com/generate_204',
    'https://cp.cloudflare.com/generate_204',
  ]) {
    try {
      final response = await client.head<void>(
        url,
        options: Options(
          validateStatus: (_) => true,
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      if (response.statusCode == 204) return true;
    } catch (_) {
      // A network may block one connectivity endpoint; try the other.
    }
  }
  return false;
}

final offlineReachabilityProvider = Provider<Future<bool> Function()>((ref) {
  final probe = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ),
  );
  ref.onDispose(() => probe.close(force: true));
  return () async {
    try {
      if ((await ref.read(offlineNetworkAdaptersProvider)()).isEmpty)
        return false;
      final host = Uri.tryParse(Env.apiBaseUrl)?.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
        if (!await checkOfflineInternet(probe)) return false;
      }
      final session = ref.read(sessionProvider);
      // A localhost health check stays up when the internet is disconnected.
      // Probe a real curriculum read through the configured dev/prod backend.
      final response = await probe.post(
        '${Env.apiEndpoint}/zsl/classes',
        data: {'institute_id': session.instituteId},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.token}',
            'Accept': 'application/json',
          },
        ),
      );
      final status = response.statusCode ?? 0;
      // An HTTP error is a server problem, not proof of an internet loss.
      // The local backend can also report an upstream network failure.
      final body = response.data;
      final message = body is Map ? body['message']?.toString() ?? '' : '';
      if (RegExp(r'cURL error (6|7|28)\b').hasMatch(message)) return false;
      return status > 0;
    } catch (_) {
      return false;
    }
  };
});
final offlineNoticeProvider = Provider<void Function(String, bool)>(
  (ref) =>
      (message, success) =>
          success ? AppToast.success(message) : AppToast.info(message),
);

final offlineRuntimeProvider =
    NotifierProvider<OfflineRuntime, OfflineRuntimeState>(OfflineRuntime.new);

final offlineWorkspaceOwnerProvider = StateProvider<Object?>((ref) => null);
final offlineWorkspaceFocusProvider = StateProvider<bool>((ref) => false);

final offlineLocalModeProvider = StateProvider<bool>((ref) {
  ref.watch(
    sessionProvider.select((s) => '${s.token}:${s.instituteId}:${s.userId}'),
  );
  return false;
});

final offlineBrowsingProvider = Provider<bool>(
  (ref) =>
      ref.watch(offlineLocalModeProvider) ||
      ref.watch(offlineRuntimeProvider.select((s) => s.reachable == false)),
);

String offlinePreparationError(Object error) {
  const fallback =
      'We couldn’t finish preparing your content. Please try again. Anything prepared earlier is still available.';
  if (error is DioException) {
    final message = ApiClient.messageOf(error, fallback: '');
    if (message.isNotEmpty) return message;
    final status = error.response?.statusCode;
    if (status == 503) {
      return 'Offline preparation is unavailable on the server. Please contact your administrator.';
    }
    if (status != null) {
      return 'The server could not prepare your content (HTTP $status). Please contact your administrator.';
    }
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Preparing content timed out. Please try again. Anything prepared earlier is still available.';
    }
  }
  if (error is StateError) return error.message.toString();
  if (error is ApiError) return error.message;
  return fallback;
}

/// Owned by the app, so navigating away does not cancel preparation or sync.
class OfflineRuntime extends Notifier<OfflineRuntimeState>
    with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _adapterTimer;
  String? _adapterFingerprint;
  bool _pollingAdapters = false, _recheckRequested = false;
  bool _checking = false;
  int _generation = 0;
  int _job = 0;
  int _reachabilityRevision = 0;
  int _failedProbes = 0;

  @override
  OfflineRuntimeState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.listen(
      sessionProvider.select((s) => '${s.token}:${s.instituteId}:${s.userId}'),
      (_, _) {
        _generation++;
        _job++;
        _failedProbes = 0;
        state = OfflineRuntimeState(revision: state.revision + 1);
        Future.microtask(check);
      },
    );
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => check());
    _adapterTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkAdapters(),
    );
    ref.onDispose(() {
      _generation++;
      _job++;
      _timer?.cancel();
      _adapterTimer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    Future.microtask(check);
    return const OfflineRuntimeState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(check());
  }

  void reportReachability(bool reachable, {bool confirmed = false}) {
    if (!ref.read(sessionProvider).isLoggedIn) return;
    if (reachable && _adapterFingerprint == '') return;
    if (!reachable && !confirmed) {
      // Request timeouts are suspicions; only independent probes confirm them.
      Future.microtask(check);
      return;
    }
    _failedProbes = 0;
    _reachabilityRevision++;
    if (state.reachable == reachable) return;
    final recovered = reachable && state.reachable == false;
    state = OfflineRuntimeState(
      reachable: reachable,
      preparing: state.preparing,
      message: state.message,
      revision: state.revision,
    );
    if (recovered) Future.microtask(check);
  }

  Future<void> _checkAdapters() async {
    if (_pollingAdapters || !ref.read(sessionProvider).isLoggedIn) return;
    _pollingAdapters = true;
    final generation = _generation;
    try {
      final current = await ref.read(offlineNetworkAdaptersProvider)();
      if (generation != _generation) return;
      final previous = _adapterFingerprint;
      _adapterFingerprint = current;
      if (current.isEmpty) {
        reportReachability(false, confirmed: true);
      } else if (previous != null && previous != current) {
        _reachabilityRevision++;
        if (_checking) {
          _recheckRequested = true;
        } else {
          unawaited(check());
        }
      }
    } catch (_) {
      // Adapter enumeration is only a signal; the content probe still runs.
    } finally {
      _pollingAdapters = false;
    }
  }

  Future<void> check() async {
    if (_checking || !ref.read(sessionProvider).isLoggedIn) return;
    _checking = true;
    final generation = _generation;
    final reachabilityRevision = _reachabilityRevision;
    try {
      // A successful HTTP exchange establishes backend reachability. HTTP 503
      // is unavailable; authentication and missing migration responses don't
      // mean that the device has lost its internet connection.
      final online =
          _adapterFingerprint != '' &&
          await ref.read(offlineReachabilityProvider)();
      if (generation != _generation ||
          reachabilityRevision != _reachabilityRevision) {
        return;
      }
      if (!online && _adapterFingerprint != '' && ++_failedProbes < 2) {
        return;
      }
      if (online) _failedProbes = 0;
      if (state.reachable != online) {
        state = OfflineRuntimeState(
          reachable: online,
          preparing: state.preparing,
          message: state.message,
          revision: state.revision,
        );
      }
      if (online) {
        // Sync has its own concurrency guard and can take much longer than a
        // connection check. It must not block detection of a real disconnect.
        unawaited(_sync());
      }
    } catch (_) {
      if (generation == _generation &&
          reachabilityRevision == _reachabilityRevision &&
          ++_failedProbes >= 2) {
        state = OfflineRuntimeState(
          reachable: false,
          preparing: state.preparing,
          message: state.message,
          revision: state.revision,
        );
      }
    } finally {
      _checking = false;
      if (_recheckRequested && generation == _generation) {
        _recheckRequested = false;
        Future.microtask(check);
      }
    }
  }

  Future<void> _sync() async {
    try {
      await ref.read(offlineServiceProvider).sync();
    } catch (_) {
      // Keep unacknowledged events for the next attempt.
    }
  }

  Future<void> prepare(int classId, int languageId) async {
    if (state.preparing) return;
    final job = ++_job;
    final service = ref.read(offlineServiceProvider);
    final scope = service.scope;
    state = OfflineRuntimeState(
      reachable: state.reachable,
      preparing: true,
      message:
          'We’re getting your content ready. You can continue using the app—we’ll let you know when it’s ready.',
      revision: state.revision,
    );
    ref.read(offlineNoticeProvider)(
      'We’re getting your content ready. You can continue using the app—we’ll let you know when it’s ready.',
      false,
    );
    try {
      await service.refreshContext();
      await service.prepare(classId, languageId, (message) {
        if (job != _job) return;
        state = OfflineRuntimeState(
          reachable: state.reachable,
          preparing: true,
          message: message,
          revision: state.revision,
        );
      }, cancelled: () => job != _job || !service.ownsScope(scope));
      if (job != _job) return;
      state = OfflineRuntimeState(
        reachable: state.reachable,
        message: 'You’re ready! Keep learning anytime, even without internet.',
        revision: state.revision + 1,
      );
      ref.read(offlineNoticeProvider)(
        'You’re ready! Keep learning anytime, even without internet.',
        true,
      );
    } catch (error) {
      if (job != _job) return;
      final message = offlinePreparationError(error);
      if (error is DioException) {
        final path = Uri.tryParse(error.requestOptions.path)?.path ?? '';
        debugPrint(
          'Offline preparation request failed: '
          '${error.requestOptions.method} $path '
          '(HTTP ${error.response?.statusCode ?? 'no response'}, ${error.type.name})',
        );
      } else {
        debugPrint('Offline preparation failed: ${error.runtimeType}');
      }
      state = OfflineRuntimeState(
        reachable: state.reachable,
        message: message,
        revision: state.revision + 1,
      );
      ref.read(offlineNoticeProvider)(message, false);
    }
  }
}
