/// Build-time configuration, the Flutter equivalent of the web app's `.env`
/// (`import.meta.env.VITE_*`).
///
/// Values come from the `.env` file in the project root, passed with
/// `--dart-define-from-file=.env` (add `--dart-define=IS_MATHZORO=true` for
/// the MathZoro app). See README.md.
class Env {
  Env._();

  static const String _baseUrl = String.fromEnvironment('BASE_URL');

  /// `BASE_URL` — the backend host, e.g. https://host (`VITE_API_BASE_URL`).
  static String get apiBaseUrl => _stripTrailingSlash(_baseUrl.trim());

  /// The REST API root, `BASE_URL` + `/api/v1` (`VITE_API_ENDPOINT`).
  static String get apiEndpoint => apiBaseUrl.isEmpty ? '' : '$apiBaseUrl/api/v1';

  static const String reverbAppKey = String.fromEnvironment('REVERB_APP_KEY');
  static const String reverbHost = String.fromEnvironment('REVERB_HOST');
  static const String _reverbPort =
      String.fromEnvironment('REVERB_PORT', defaultValue: '443');
  static const String _reverbScheme =
      String.fromEnvironment('REVERB_SCHEME', defaultValue: 'wss');

  static int get reverbPort => int.tryParse(_reverbPort) ?? 443;

  /// Whether the Reverb websocket uses TLS: `REVERB_SCHEME` may be given as
  /// `wss`/`ws` or, like the web's `VITE_REVERB_SCHEME`, `https`/`http`.
  static bool get reverbSecure {
    final s = _reverbScheme.trim().toLowerCase();
    return s == 'wss' || s == 'https';
  }

  /// The web front-end's own address (`window.location.origin` on the web),
  /// used for links the app generates for browsers, e.g. invite sign-up
  /// links `/signup?code=…`. Falls back to [apiBaseUrl] when not set.
  static const String _webAppOrigin = String.fromEnvironment('WEB_APP_ORIGIN');
  static String get webAppOrigin {
    final o = _stripTrailingSlash(_webAppOrigin.trim());
    return o.isEmpty ? apiBaseUrl : o;
  }

  /// `VITE_IS_MATHZORO` — selects the MathZoro student flavor.
  static const bool isMathzoro = bool.fromEnvironment('IS_MATHZORO');

  static const bool proctorAiEnabled =
      bool.fromEnvironment('PROCTOR_AI_ENABLED');
  static const String proctorAiUrl = String.fromEnvironment('PROCTOR_AI_URL');

  /// Whether the mandatory values were supplied at build time.
  static bool get isConfigured => apiEndpoint.isNotEmpty;

  static String get appName => isMathzoro ? 'MathZoro' : 'eLabs';

  static String _stripTrailingSlash(String v) =>
      v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}
