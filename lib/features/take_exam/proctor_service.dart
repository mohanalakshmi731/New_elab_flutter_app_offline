import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../state/providers.dart';

/// Port of `src/service/proctor.service.ts`.
///
/// It uses the same API client as every other service (the web used the
/// shared `Axios` instance), so the bearer token is attached and response
/// `message`s / errors are toasted exactly like on the web. Every request
/// goes to `${VITE_API_ENDPOINT}/exam/proctor…` with a 15 s timeout.
///
/// Lives in the feature folder because `lib/data/services/` only takes new
/// methods on existing services; there was no `proctor_service.dart` yet.
class ProctorService {
  ProctorService(this._api);
  final ApiClient _api;

  static const _timeout = Duration(milliseconds: 15000);

  /// `VITE_PROCTOR_AI_ENABLED` — enabled unless set to something other than
  /// `1/true/yes/on` (unset or empty means enabled, like the web).
  static const String _enabledRaw = String.fromEnvironment('PROCTOR_AI_ENABLED');

  /// `VITE_PROCTOR_ANALYZE_INTERVAL_MS`
  static const String _intervalRaw = String.fromEnvironment('PROCTOR_ANALYZE_INTERVAL_MS');

  /// `proctorEnabled()`
  static bool parseEnabled(String configured) {
    if (configured.isEmpty) return true;
    return const ['1', 'true', 'yes', 'on'].contains(configured.toLowerCase());
  }

  /// `getAnalyzeIntervalMs()` — `Math.max(1200, Number(value || 2500))`,
  /// 2500 when not a finite number.
  static int parseAnalyzeIntervalMs(String configured) {
    final raw = configured.trim();
    final value = raw.isEmpty ? 2500.0 : double.tryParse(raw);
    if (value == null || !value.isFinite) return 2500;
    return value < 1200 ? 1200 : value.round();
  }

  bool isEnabled() => parseEnabled(_enabledRaw);

  /// `proctorBaseUrl()`
  String getBaseUrl() {
    var base = Env.apiEndpoint;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return '$base/exam/proctor';
  }

  int getAnalyzeIntervalMs() => parseAnalyzeIntervalMs(_intervalRaw);

  Options _options([Options? o]) =>
      (o ?? Options()).copyWith(sendTimeout: _timeout, receiveTimeout: _timeout);

  Future<Map<String, dynamic>> _postJson(String path, Object? payload) async {
    final body = await _api.post('${getBaseUrl()}$path', data: payload, options: _options());
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return body.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  /// `analyze(payload)` → `ProctorAnalyzeResponse`
  Future<Map<String, dynamic>> analyze(Map<String, dynamic> payload) =>
      _postJson('/analyze', payload);

  /// `analyzeAudio(payload)` → `ProctorAudioAnalyzeResponse`
  Future<Map<String, dynamic>> analyzeAudio(Map<String, dynamic> payload) =>
      _postJson('/audio', payload);

  /// `startSession(payload)` → `ProctorRecordingSession`
  /// (`{ source: 'new-elab-web-app', ...payload }`).
  Future<Map<String, dynamic>> startSession(Map<String, dynamic> payload) =>
      _postJson('/sessions', {'source': 'new-elab-web-app', ...payload});

  /// `appendLog(sessionId, payload)`
  Future<void> appendLog(String sessionId, Map<String, dynamic> payload) async {
    await _postJson('/sessions/$sessionId/logs', payload);
  }

  /// `appendVideoChunk(sessionId, chunk)` — the raw recorder chunk with its
  /// MIME type as `Content-Type`.
  Future<void> appendVideoChunk(String sessionId, Uint8List chunk, String type) async {
    await _api.post(
      '${getBaseUrl()}/sessions/$sessionId/video',
      data: chunk,
      options: _options(Options(
        contentType: type.isNotEmpty ? type : 'application/octet-stream',
      )),
    );
  }

  /// `finishSession(sessionId, payload)`
  Future<void> finishSession(String sessionId, Map<String, dynamic> payload) async {
    await _postJson('/sessions/$sessionId/finish', payload);
  }
}

final proctorServiceProvider =
    Provider<ProctorService>((ref) => ProctorService(ref.watch(apiClientProvider)));

/// `error instanceof Error ? error.message : fallback` for errors thrown by
/// the API client (axios messages) or the panel itself.
String errorMessage(Object error, String fallback) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'timeout of 15000ms exceeded';
      case DioExceptionType.connectionError:
        return 'Network Error';
      default:
        final m = error.message;
        return m != null && m.isNotEmpty ? m : fallback;
    }
  }
  if (error is ApiError) return error.message;
  final text = error.toString();
  if (error is Exception) {
    const prefix = 'Exception: ';
    final m = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return m.isNotEmpty ? m : fallback;
  }
  if (error is Error) return text.isNotEmpty ? text : fallback;
  return fallback;
}
