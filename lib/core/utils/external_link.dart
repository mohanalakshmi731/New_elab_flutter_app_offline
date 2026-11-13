import 'package:url_launcher/url_launcher.dart';

import 'toast.dart';

/// Opens a URL outside the app (browser, Zoom app, payment page …).
///
/// Replaces `window.open(url, '_blank')` and `window.location.href = url`.
/// Zoom meeting links (`https://zoom.us/j/...`) are handed to the OS, which
/// opens the installed Zoom app when present, otherwise the browser.
Future<bool> openExternal(String? url) async {
  if (url == null || url.trim().isEmpty) {
    AppToast.error('Link is not available');
    return false;
  }
  final uri = Uri.tryParse(url.trim());
  if (uri == null) {
    AppToast.error('Invalid link');
    return false;
  }
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) AppToast.error('Could not open the link');
    return ok;
  } catch (_) {
    AppToast.error('Could not open the link');
    return false;
  }
}

/// Converts a Zoom web-client link into the `zoommtg://` deep link so the
/// desktop / mobile Zoom app opens directly. Falls back to the https link.
Future<bool> openZoomMeeting({String? joinUrl, String? meetingNumber, String? password}) async {
  if (meetingNumber != null && meetingNumber.isNotEmpty) {
    final deep = Uri.parse(
        'zoommtg://zoom.us/join?confno=$meetingNumber${password != null && password.isNotEmpty ? '&pwd=$password' : ''}');
    try {
      if (await launchUrl(deep, mode: LaunchMode.externalApplication)) return true;
    } catch (_) {
      // Zoom app not installed — fall back to the browser link below.
    }
  }
  return openExternal(joinUrl ??
      (meetingNumber != null ? 'https://zoom.us/j/$meetingNumber' : null));
}
