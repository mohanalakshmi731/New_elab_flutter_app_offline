import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/env.dart';
import '../utils/toast.dart';
import 'upload_file.dart';

/// Port of `src/service/Axios.ts`.
///
/// Behaviour kept identical to the web interceptors:
///  * `Authorization: Bearer <token>` on every request,
///  * a success toast whenever the JSON body contains a `message`,
///  * on HTTP 401 the session is cleared (except for the logout call itself)
///    and the router sends the user back to the login screen,
///  * any other error shows `message` / `msg` / "Something went wrong".
///
/// Every method returns the decoded response **body** (axios `res.data`).
/// Pass `silent: true` to suppress the automatic toasts (e.g. polling).
class ApiClient {
  ApiClient({
    required String? Function() tokenReader,
    required Future<void> Function() onUnauthorized,
    String? baseUrl,
    this.prepareActivityPayload,
    this.onReachabilityChanged,
    this.isOffline,
    this.readOffline,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? Env.apiEndpoint,
           headers: const {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 120),
           // axios serialises arrays as `key[]=a&key[]=b` (Laravel friendly).
           listFormat: ListFormat.multiCompatible,
         ),
       ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (isOffline?.call() == true &&
              readOffline != null &&
              !options.path.startsWith('/offline/')) {
            try {
              final data = await readOffline!(options.path, {
                ...options.queryParameters,
                if (options.data is Map)
                  ...Map<String, dynamic>.from(options.data as Map),
              });
              handler.resolve(
                Response(requestOptions: options, data: data, statusCode: 200),
              );
            } catch (e) {
              handler.reject(
                DioException(requestOptions: options, error: e, message: '$e'),
              );
            }
            return;
          }
          final token = tokenReader() ?? '';
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (_provesInternetReachability(response.requestOptions) &&
              (response.requestOptions.path.startsWith('/zsl/') ||
                  response.requestOptions.path.startsWith('/offline/'))) {
            onReachabilityChanged?.call(true);
          }
          if (response.requestOptions.extra[_silentKey] != true) {
            final data = response.data;
            if (data is Map && data['message'] is String) {
              AppToast.success(data['message'] as String);
            }
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response == null &&
              [
                DioExceptionType.connectionError,
                DioExceptionType.connectionTimeout,
                DioExceptionType.receiveTimeout,
              ].contains(error.type)) {
            onReachabilityChanged?.call(false);
          }
          final providerUnavailable =
              ((error.response?.statusCode ?? 0) >= 500 &&
                  _offlineReadPaths.contains(error.requestOptions.path)) ||
              (error.response?.statusCode == 417 &&
                  RegExp(
                    r'cURL error (6|7|28)\b',
                  ).hasMatch(messageOf(error, fallback: '')));
          if (error.response != null &&
              _provesInternetReachability(error.requestOptions)) {
            // We reached the backend. Keep server errors separate from device
            // connectivity, while allowing this request to use saved content.
            onReachabilityChanged?.call(true);
          }
          final disconnected =
              error.response == null &&
              [
                DioExceptionType.connectionError,
                DioExceptionType.connectionTimeout,
                DioExceptionType.receiveTimeout,
              ].contains(error.type);
          if (disconnected || providerUnavailable) {
            // The backend can be reachable while its content provider is down.
            // Retry curriculum reads locally without replaying mutations.
            if (readOffline != null &&
                _offlineReadPaths.contains(error.requestOptions.path)) {
              final request = error.requestOptions;
              try {
                final data = await readOffline!(request.path, {
                  ...request.queryParameters,
                  if (request.data is Map)
                    ...Map<String, dynamic>.from(request.data as Map),
                });
                handler.resolve(
                  Response(
                    requestOptions: request,
                    data: data,
                    statusCode: 200,
                  ),
                );
                return;
              } catch (_) {
                // Preserve the original error if local storage is unavailable.
              }
            }
          }
          final status = error.response?.statusCode;
          if (status == 401) {
            final path = error.requestOptions.path;
            if (!path.contains('logout')) {
              await onUnauthorized();
            }
          } else if (error.requestOptions.extra[_silentKey] != true) {
            AppToast.error(messageOf(error));
          }
          handler.next(error);
        },
      ),
    );
  }

  static const _silentKey = 'silent';
  static const _offlineReadPaths = {
    '/lab-admin/practice-options',
    '/zsl/classes',
    '/zsl/classes/all',
    '/zsl/subjects',
    '/zsl/chapters',
    '/zsl/chapter/links',
    '/zsl/get-subject-performance',
    '/zsl/get-quiz-performance',
  };

  final Dio dio;
  final bool Function()? isOffline;
  final Future<dynamic> Function(String, Map<String, dynamic>)? readOffline;
  bool _provesInternetReachability(RequestOptions request) {
    final host = request.uri.host.toLowerCase();
    return host != 'localhost' && host != '127.0.0.1' && host != '::1';
  }

  final void Function(bool reachable)? onReachabilityChanged;

  /// Applies the transient lab practice identity to recording requests.
  final Map<String, dynamic> Function(String, Map<String, dynamic>)?
  prepareActivityPayload;

  /// Extracts a user-facing message from any error thrown by this client.
  static String messageOf(
    Object error, {
    String fallback = 'Something went wrong',
  }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final m = data['message'] ?? data['msg'] ?? data['error'];
        if (m is String && m.trim().isNotEmpty) return m;
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'Unable to reach the server. Check your internet connection.';
      }
      return fallback;
    }
    if (error is ApiError) return error.message;
    return fallback;
  }

  Options _opts(bool silent, [Options? options]) => (options ?? Options())
      .copyWith(extra: {...?options?.extra, _silentKey: silent});

  /// axios drops `undefined`/`null` query params; mirror that.
  static Map<String, dynamic>? _clean(Map<String, dynamic>? q) {
    if (q == null) return null;
    final out = <String, dynamic>{};
    q.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.isEmpty) {
        out[k] = v; // axios keeps empty strings
        return;
      }
      out[k] = v is bool ? v.toString() : v;
    });
    return out;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    final res = await dio.get<dynamic>(
      path,
      queryParameters: _clean(query),
      options: _opts(silent, options),
    );
    return res.data;
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    final res = await dio.post<dynamic>(
      path,
      data: data is Map<String, dynamic>
          ? (prepareActivityPayload?.call(path, data) ?? data)
          : data,
      queryParameters: _clean(query),
      options: _opts(silent, options),
    );
    return res.data;
  }

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    final res = await dio.put<dynamic>(
      path,
      data: data,
      queryParameters: _clean(query),
      options: _opts(silent, options),
    );
    return res.data;
  }

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    final res = await dio.patch<dynamic>(
      path,
      data: data,
      queryParameters: _clean(query),
      options: _opts(silent, options),
    );
    return res.data;
  }

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    final res = await dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: _clean(query),
      options: _opts(silent, options),
    );
    return res.data;
  }

  /// multipart/form-data request (replaces `new FormData()` + axios).
  /// See [buildFormData] for how values are encoded.
  Future<dynamic> postMultipart(
    String path,
    Map<String, dynamic> fields, {
    Map<String, dynamic>? query,
    bool silent = false,
  }) async {
    final form = await buildFormData(fields);
    final res = await dio.post<dynamic>(
      path,
      data: form,
      queryParameters: _clean(query),
      options: _opts(silent, Options(contentType: 'multipart/form-data')),
    );
    return res.data;
  }

  /// Downloads raw bytes (replaces axios `responseType: 'blob'`).
  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? query,
    bool silent = true,
  }) async {
    final res = await dio.get<List<int>>(
      path,
      queryParameters: _clean(query),
      options: _opts(silent, Options(responseType: ResponseType.bytes)),
    );
    return Uint8List.fromList(res.data ?? const []);
  }
}

/// Error raised by client-side validation inside services/controllers
/// (the web code used `throw new Error('Institute ID not available')`).
class ApiError implements Exception {
  const ApiError(this.message);
  final String message;
  @override
  String toString() => message;
}
