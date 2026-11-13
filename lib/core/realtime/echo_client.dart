import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';

/// Minimal Laravel Echo replacement for the Reverb (Pusher protocol)
/// server configured in `main.ts`:
///
/// ```ts
/// new Echo({ broadcaster: 'reverb', key, wsHost, wsPort: 443, forceTLS: true,
///            authEndpoint: `${API}/broadcasting/auth`, auth: { headers: { Authorization } } })
/// ```
///
/// Usage mirrors Echo:
/// ```dart
/// final sub = echo.private('import.$id').listen('.update', (data) { ... });
/// ...
/// sub.cancel(); echo.leave('import.$id');
/// ```
class EchoClient {
  EchoClient({required this.tokenReader});

  final String? Function() tokenReader;

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connSub;
  bool _connected = false;
  final Map<String, Channel> _channels = {};

  PusherChannelsClient get _ensureClient {
    final existing = _client;
    if (existing != null) return existing;
    final options = PusherChannelsOptions.fromHost(
      scheme: Env.reverbSecure ? 'wss' : 'ws',
      host: Env.reverbHost,
      key: Env.reverbAppKey,
      port: Env.reverbPort,
      shouldSupplyMetadataQueries: true,
      metadata: PusherChannelsOptionsMetadata.byDefault(),
    );
    final client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        debugPrint('Echo connection error: $exception');
        refresh();
      },
    );
    _connSub = client.onConnectionEstablished.listen((_) {
      _connected = true;
      for (final ch in _channels.values) {
        ch.subscribeIfNotUnsubscribed();
      }
    });
    unawaited(client.connect());
    _client = client;
    return client;
  }

  Uri get _authEndpoint => Uri.parse('${Env.apiEndpoint}/broadcasting/auth');

  Map<String, String> get _authHeaders {
    final token = tokenReader() ?? '';
    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// `echo.channel(name)` — public channel.
  EchoChannel channel(String name) {
    final ch = _channels.putIfAbsent(name, () => _ensureClient.publicChannel(name));
    _subscribeIfConnected(ch);
    return EchoChannel._(ch);
  }

  /// `echo.private(name)` → `private-<name>`.
  EchoChannel private(String name) {
    final full = 'private-$name';
    final ch = _channels.putIfAbsent(
      full,
      () => _ensureClient.privateChannel(
        full,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
          authorizationEndpoint: _authEndpoint,
          headers: _authHeaders,
        ),
      ),
    );
    _subscribeIfConnected(ch);
    return EchoChannel._(ch);
  }

  /// `echo.join(name)` → `presence-<name>`.
  EchoChannel join(String name) {
    final full = 'presence-$name';
    final ch = _channels.putIfAbsent(
      full,
      () => _ensureClient.presenceChannel(
        full,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
          authorizationEndpoint: _authEndpoint,
          headers: _authHeaders,
        ),
      ),
    );
    _subscribeIfConnected(ch);
    return EchoChannel._(ch);
  }

  /// `echo.leave(name)` — leaves the public, private and presence variants.
  void leave(String name) {
    for (final key in [name, 'private-$name', 'presence-$name']) {
      _channels.remove(key)?.unsubscribe();
    }
  }

  void _subscribeIfConnected(Channel ch) {
    if (_connected) ch.subscribeIfNotUnsubscribed();
  }

  /// Called on logout: drops all channels and the socket.
  void disconnect() {
    for (final ch in _channels.values) {
      ch.unsubscribe();
    }
    _channels.clear();
    _connSub?.cancel();
    _connSub = null;
    _client?.dispose();
    _client = null;
    _connected = false;
  }
}

/// A subscribed channel; `listen` follows Laravel Echo's event-name rules.
class EchoChannel {
  EchoChannel._(this._channel);
  final Channel _channel;

  /// `.listen('.update', cb)` → raw event `update`;
  /// `.listen('UserJoined', cb)` → `App\Events\UserJoined` (Echo namespace).
  StreamSubscription<ChannelReadEvent> listen(
      String event, void Function(Map<String, dynamic>? data) callback) {
    final name = event.startsWith('.') ? event.substring(1) : 'App\\Events\\$event';
    return _channel.bind(name).listen((e) => callback(_decode(e.data)));
  }

  static Map<String, dynamic>? _decode(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    if (data is String) {
      try {
        final d = jsonDecode(data);
        if (d is Map<String, dynamic>) return d;
      } catch (_) {}
    }
    return {'data': data};
  }
}
