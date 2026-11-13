/// Pure Proctor-AI logic of `src/components/proctor/ExamProctorPanel.vue`:
/// reference-photo checks, how analyze/audio responses become warnings, the
/// audio features sent to `/exam/proctor/audio`, log texts and overlay boxes.
///
/// Responses are kept as the raw JSON maps (`ProctorAnalyzeResponse`,
/// `ProctorAudioAnalyzeResponse` in `src/types/proctor.ts`) because the panel
/// sends them back verbatim in `/logs` and `/finish`.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../schedules/schedule_exam_logic.dart' show jsNumber, jsStr;

/// `IDENTITY_DISTANCE_WARNING_THRESHOLD`
const identityDistanceWarningThreshold = 0.42;

/// `ENABLE_LOCAL_PHONE_HEURISTIC` (off on the web too).
const enableLocalPhoneHeuristic = false;

/// `throw new Error(message)` inside the panel.
class ProctorError implements Exception {
  const ProctorError(this.message);
  final String message;
  @override
  String toString() => message;
}

/// `ProctorWarningPayload` emitted with `warning`.
class ProctorWarningPayload {
  const ProctorWarningPayload({
    required this.type,
    required this.message,
    required this.source,
    this.immediateClose = false,
    this.data,
  });

  final String type;
  final String message;

  /// `'server' | 'local'`
  final String source;
  final bool immediateClose;
  final Map<String, dynamic>? data;
}

// ── JSON access ────────────────────────────────────────────────────────────

List<Map<String, dynamic>> listOfMaps(Object? v) => [for (final e in asList(v)) ?asMap(e)];

/// `data.events ?? []`
List<Map<String, dynamic>> eventsOf(Map<String, dynamic>? data) => listOfMaps(data?['events']);

/// `String(event.type || '')`
String eventType(Map<String, dynamic> event) {
  final t = event['type'];
  return jsTruthy(t) ? jsStr(t) : '';
}

/// JS `a || b` for display strings.
Object? _or(Object? a, Object? b) => jsTruthy(a) ? a : b;

String _str(Object? v) => v == null ? '' : jsStr(v);

bool _isFiniteNumber(Object? v) => v is num && v.isFinite;

/// `typeof value === 'number' && Number.isFinite(value) ? value : boxes?.length ?? 0`
num normalizedCount(Object? value, Object? boxes) {
  if (_isFiniteNumber(value)) return value as num;
  return asList(boxes).length;
}

/// `valueText(value)` — `'-'` for null/undefined, otherwise `String(value)`.
String valueText(Object? value) => value == null ? '-' : jsStr(value);

/// JS `Number(x).toFixed(digits)`.
String toFixed(Object? x, int digits) {
  final n = jsNumber(x);
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n > 0 ? 'Infinity' : '-Infinity';
  return n.toDouble().toStringAsFixed(digits);
}

// ── reference photo ────────────────────────────────────────────────────────

/// Pixel statistics of the last captured frame (`lastFrameData`), sampled on
/// the same 8-px grid `validateCapturedPixels` walks: `sums[i]` is `r+g+b` of
/// sample `i` in row-major order. Collected by the camera page's JS.
class FrameStats {
  const FrameStats({required this.width, required this.height, required this.sums});
  final int width;
  final int height;
  final List<int> sums;
}

/// `validateCapturedPixels()`
void validateCapturedPixels(FrameStats? frame) {
  if (frame == null) {
    throw const ProctorError('Camera frame is not ready. Please try again.');
  }
  var samples = 0;
  var brightnessSum = 0.0;
  var brightnessSquares = 0.0;
  var veryDark = 0;
  var veryBright = 0;
  for (final sum in frame.sums) {
    final brightness = sum / 3;
    samples += 1;
    brightnessSum += brightness;
    brightnessSquares += brightness * brightness;
    if (brightness < 18) veryDark += 1;
    if (brightness > 245) veryBright += 1;
  }
  final n = math.max(1, samples);
  final mean = brightnessSum / n;
  final variance = brightnessSquares / n - mean * mean;
  final darkRatio = veryDark / n;
  final brightRatio = veryBright / n;

  if (mean < 22 || darkRatio > 0.82) {
    throw const ProctorError(
        'Camera looks covered or shutter is closed. Open the camera and capture a clear face photo.');
  }
  if (brightRatio > 0.92 || variance < 28) {
    throw const ProctorError(
        'Camera photo is not clear enough. Sit in front of the camera and capture again.');
  }
}

/// `isReferenceBlockingEvent(event)`
bool isReferenceBlockingEvent(Map<String, dynamic> event) {
  final type = eventType(event);
  return const [
        'FACE_MISSING',
        'MULTIPLE_FACES',
        'UNREGISTERED_PERSON_DETECTED',
        'FACE_NOT_CONFIRMED',
        'EYES_NOT_VISIBLE',
        'REFERENCE_FACE_MISSING',
        'REFERENCE_MULTIPLE_FACES',
        'REFERENCE_MULTIPLE_PERSONS',
        'REFERENCE_GADGET_VISIBLE',
      ].contains(type) ||
      type.startsWith('REFERENCE_LOW_LIGHT') ||
      type.startsWith('REFERENCE_OVER_EXPOSED') ||
      type.startsWith('REFERENCE_BLURRY_FRAME') ||
      type.startsWith('REFERENCE_FACE_TOO_FAR') ||
      type.startsWith('REFERENCE_FACE_OCCLUDED') ||
      type.startsWith('REFERENCE_EYES_NOT_VISIBLE');
}

/// `validateReferenceAnalysis(data)` — throws [ProctorError] with the web's
/// messages.
void validateReferenceAnalysis(Map<String, dynamic> data) {
  final faceCount = normalizedCount(data['faceCount'], data['faces']);
  final personCount = normalizedCount(data['personCount'], data['persons']);
  final blockingEvent = eventsOf(data).where(isReferenceBlockingEvent).firstOrNull;
  const invalid = 'Reference photo is not valid. Please capture a clear face photo.';

  if (data['ok'] == false) {
    throw ProctorError(_str(_or(blockingEvent?['message'], invalid)));
  }
  if (blockingEvent != null) {
    throw ProctorError(_str(_or(blockingEvent['message'], invalid)));
  }
  if (faceCount < 1) {
    throw const ProctorError(
        'No face found in the reference photo. Open the camera shutter and capture your face clearly.');
  }
  if (faceCount > 1) {
    throw const ProctorError(
        'Multiple faces found in the reference photo. Only the exam student should be visible.');
  }
  if (personCount > 1) {
    throw const ProctorError(
        'Multiple persons found in the reference photo. Please sit alone and capture again.');
  }
  final firstFace = listOfMaps(data['faces']).firstOrNull;
  final faceConfidence = jsNumber(firstFace?['confidence'] ?? 0);
  if (jsTruthy(faceConfidence) && faceConfidence < 0.72) {
    throw const ProctorError(
        'Face is not clear enough for identity verification. Please look at the camera and capture again.');
  }
  if (asList(data['gadgets']).isNotEmpty) {
    throw const ProctorError(
        'Remove electronic gadgets from the camera view before starting the exam.');
  }
}

// ── warnings ───────────────────────────────────────────────────────────────

/// `isExamWarningEvent(event)`
bool isExamWarningEvent(Map<String, dynamic> event) => const [
      'FACE_MISSING',
      'MULTIPLE_FACES',
      'UNREGISTERED_PERSON_DETECTED',
      'IDENTITY_MISMATCH',
      'ELECTRONIC_GADGET_DETECTED',
      'BACKGROUND_SPEECH_DETECTED',
    ].contains(eventType(event));

/// `isHeadPoseEvent(event)`
bool isHeadPoseEvent(Map<String, dynamic> event) {
  final type = eventType(event);
  return type.startsWith('FACE_TURNED') || type.startsWith('FACE_ANGLE');
}

/// `identityDistanceWarningEvent(data)`
Map<String, dynamic>? identityDistanceWarningEvent(Map<String, dynamic> data) {
  final distance = data['identityDistance'];
  if (!_isFiniteNumber(distance)) return null;
  if ((distance as num) < identityDistanceWarningThreshold) return null;
  return {
    'type': 'IDENTITY_MISMATCH',
    'severity': 'CRITICAL',
    'message': 'Current face does not match the captured reference photo.',
    'metadata': {
      'identityDistance': distance,
      'threshold': identityDistanceWarningThreshold,
    },
  };
}

/// The payload `emitWarningIfNeeded(data)` would emit, before its
/// same-type 1.8 s throttle (see [ProctorWarningGate]).
ProctorWarningPayload? visualWarningPayload(
  Map<String, dynamic> data,
  List<Map<String, dynamic>> localPhoneCandidates,
) {
  if (asList(data['gadgets']).isNotEmpty) {
    return ProctorWarningPayload(
      type: 'ELECTRONIC_GADGET_DETECTED',
      message: 'Electronic gadget detected in camera.',
      source: 'server',
      data: data,
    );
  }
  if (localPhoneCandidates.isNotEmpty) {
    return ProctorWarningPayload(
      type: 'PHONE_LIKE_OBJECT',
      message: 'Phone-like object visible in camera.',
      source: 'local',
      data: data,
    );
  }
  final proctorEvent = eventsOf(data).where(isExamWarningEvent).firstOrNull;
  final identityEvent = identityDistanceWarningEvent(data);
  if (proctorEvent != null || identityEvent != null || jsTruthy(data['shouldClose'])) {
    return ProctorWarningPayload(
      type: _str(_or(_or(_or(proctorEvent?['type'], identityEvent?['type']), data['closeType']),
          'PROCTOR_WARNING')),
      message: _str(_or(
          _or(_or(proctorEvent?['message'], identityEvent?['message']), data['closeReason']),
          'Proctor AI detected a warning.')),
      source: 'server',
      data: data,
    );
  }
  return null;
}

/// `isBackgroundAudioWarningEvent(type)`
bool isBackgroundAudioWarningEvent(String type) => const [
      'BACKGROUND_SPEECH_DETECTED',
      'BACKGROUND_AUDIO_DETECTED',
      'LOUD_BACKGROUND_AUDIO',
    ].contains(type);

/// `isSuspiciousAudioActivityEvent(event)`
bool isSuspiciousAudioActivityEvent(Map<String, dynamic> event) {
  if (eventType(event) != 'AUDIO_ACTIVITY_DETECTED') return false;
  final metadata = asMap(event['metadata']) ?? const <String, dynamic>{};
  final mouthActivity = jsNumber(metadata['studentMouthActivity'] ?? 0);
  final mouthThreshold = jsNumber(metadata['mouthThreshold'] ?? 0.16);
  final activeMs = jsNumber(metadata['activeMs'] ?? 0);
  return activeMs >= 800 && mouthActivity < mouthThreshold;
}

/// `shouldCloseForAudioEvent(event)`
bool shouldCloseForAudioEvent(Map<String, dynamic> event) =>
    isBackgroundAudioWarningEvent(eventType(event)) || isSuspiciousAudioActivityEvent(event);

/// The payload `emitAudioWarningIfNeeded(data)` would emit, before its
/// throttles (see [ProctorWarningGate]).
ProctorWarningPayload? audioWarningPayload(Map<String, dynamic> data) {
  final event = eventsOf(data).where(shouldCloseForAudioEvent).firstOrNull;
  if (event == null) return null;
  final audio = asMap(data['audio']) ?? const <String, dynamic>{};
  if (audio['visualContext'] != 'active' || audio['studentMouthActivity'] == null) return null;
  return ProctorWarningPayload(
    type: _str(_or(_or(event['type'], data['closeType']), 'BACKGROUND_AUDIO_DETECTED')),
    message: _str(_or(_or(event['message'], data['closeReason']),
        'Suspicious background audio detected.')),
    source: 'server',
    immediateClose: false,
    data: data,
  );
}

/// `lastWarningType` / `lastWarningAt` / `lastAudioWarningAt` throttles.
class ProctorWarningGate {
  String lastWarningType = '';
  int lastWarningAt = 0;
  int lastAudioWarningAt = 0;

  /// `emitWarningIfNeeded` — same type within 1.8 s is dropped.
  bool allowVisual(String type, int nowMs) {
    if (type == lastWarningType && nowMs - lastWarningAt < 1800) return false;
    lastWarningType = type;
    lastWarningAt = nowMs;
    return true;
  }

  /// `emitAudioWarningIfNeeded` — at most one audio warning per 8 s, plus
  /// the same-type 1.8 s rule.
  bool allowAudio(String type, int nowMs) {
    if (nowMs - lastAudioWarningAt < 8000) return false;
    if (type == lastWarningType && nowMs - lastWarningAt < 1800) return false;
    lastAudioWarningAt = nowMs;
    lastWarningType = type;
    lastWarningAt = nowMs;
    return true;
  }
}

// ── face quality ───────────────────────────────────────────────────────────

Map<String, dynamic>? _firstQualityFace(Map<String, dynamic>? data) =>
    listOfMaps(asMap(data?['faceQuality'])?['faces']).firstOrNull;

/// `extractMouthActivity(data)`
double? extractMouthActivity(Map<String, dynamic>? data) {
  final v = _firstQualityFace(data)?['mouthActivity'];
  return _isFiniteNumber(v) ? (v as num).toDouble() : null;
}

/// `extractHeadDirection(data)`
String? extractHeadDirection(Map<String, dynamic>? data) {
  final v = _firstQualityFace(data)?['headDirection'];
  return v is String && v.trim().isNotEmpty ? v.trim() : null;
}

/// `formatHeadDirection('looking-left')` → `Looking Left`.
String formatHeadDirection(String direction) => direction
    .split('-')
    .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
    .join(' ');

// ── audio features ─────────────────────────────────────────────────────────

/// Result of `calculateFrequencyShape`.
class FrequencyShape {
  const FrequencyShape({
    required this.speechRatio,
    required this.lowFrequencyRatio,
    required this.highFrequencyRatio,
    required this.dominantFrequency,
  });
  final double speechRatio;
  final double lowFrequencyRatio;
  final double highFrequencyRatio;
  final double? dominantFrequency;
}

/// `calculateFrequencyShape(frequencyData, sampleRate, fftSize)`
FrequencyShape calculateFrequencyShape(Uint8List frequencyData, double sampleRate, int fftSize) {
  var totalEnergy = 0.0;
  var speechEnergy = 0.0;
  var lowFrequencyEnergy = 0.0;
  var highFrequencyEnergy = 0.0;
  var dominantEnergy = 0.0;
  double? dominantFrequency;

  for (var index = 0; index < frequencyData.length; index += 1) {
    final frequency = (index * sampleRate) / fftSize;
    final amplitude = frequencyData[index] / 255;
    final energy = amplitude * amplitude;
    totalEnergy += energy;
    if (frequency > 0 && energy > dominantEnergy) {
      dominantEnergy = energy;
      dominantFrequency = frequency;
    }
    if (frequency > 0 && frequency < 300) lowFrequencyEnergy += energy;
    if (frequency >= 300 && frequency <= 3400) speechEnergy += energy;
    if (frequency > 3400) highFrequencyEnergy += energy;
  }

  if (totalEnergy <= 0) {
    return const FrequencyShape(
        speechRatio: 0, lowFrequencyRatio: 0, highFrequencyRatio: 0, dominantFrequency: null);
  }
  return FrequencyShape(
    speechRatio: speechEnergy / totalEnergy,
    lowFrequencyRatio: lowFrequencyEnergy / totalEnergy,
    highFrequencyRatio: highFrequencyEnergy / totalEnergy,
    dominantFrequency: dominantFrequency,
  );
}

/// `calculateZeroCrossingRate(timeData)`
double calculateZeroCrossingRate(Uint8List timeData) {
  if (timeData.length < 2) return 0;
  var crossings = 0;
  var previous = timeData[0] - 128;
  for (var index = 1; index < timeData.length; index += 1) {
    final current = timeData[index] - 128;
    if ((previous < 0 && current >= 0) || (previous >= 0 && current < 0)) crossings += 1;
    previous = current;
  }
  return crossings / (timeData.length - 1);
}

/// The features `analyzeAudioWindow` derives from one analyser snapshot.
class AudioWindow {
  const AudioWindow({
    required this.rms,
    required this.peak,
    required this.shape,
    required this.zeroCrossingRate,
  });
  final double rms;
  final double peak;
  final FrequencyShape shape;
  final double zeroCrossingRate;

  /// `rms >= 0.006 && speechRatio >= 0.14`
  bool get speechLike => rms >= 0.006 && shape.speechRatio >= 0.14;
}

/// `getByteTimeDomainData` / `getByteFrequencyData` → [AudioWindow].
AudioWindow analyzeAudioSamples(
    Uint8List timeData, Uint8List frequencyData, double sampleRate, int fftSize) {
  var sumSquares = 0.0;
  var peak = 0.0;
  for (final value in timeData) {
    final sample = (value - 128) / 128;
    sumSquares += sample * sample;
    peak = math.max(peak, sample.abs());
  }
  final rms = timeData.isEmpty ? double.nan : math.sqrt(sumSquares / timeData.length);
  return AudioWindow(
    rms: rms,
    peak: peak,
    shape: calculateFrequencyShape(frequencyData, sampleRate, fftSize),
    zeroCrossingRate: calculateZeroCrossingRate(timeData),
  );
}

/// `audioSpeechActiveMs` update (+1000 while speech-like, −1500 otherwise).
int nextSpeechActiveMs(int current, bool speechLike) =>
    speechLike ? current + 1000 : math.max(0, current - 1500);

// ── log texts ──────────────────────────────────────────────────────────────

/// `summaryText(data, durationMs)`
String summaryText(Map<String, dynamic> data, int durationMs, int totalGadgetCount) {
  final hasEvents = data['events'] is List;
  final events = eventsOf(data).where((e) => !isHeadPoseEvent(e)).map(_typeText).join(', ');
  final eventText = hasEvents && events.isNotEmpty ? ' events=$events' : '';
  final head = extractHeadDirection(data);
  final headText = head != null ? ' head=${formatHeadDirection(head)}' : '';
  return 'faces=${valueText(data['faceCount'])} persons=${valueText(data['personCount'])} '
      'gadgets=$totalGadgetCount$headText$eventText time=${durationMs}ms';
}

/// `event.type` as `Array.join` prints it (`undefined`/`null` → `''`).
String _typeText(Map<String, dynamic> e) => e['type'] == null ? '' : jsStr(e['type']);

/// `referenceSummaryText(data, durationMs)`
String referenceSummaryText(Map<String, dynamic> data, int durationMs) {
  final events = eventsOf(data).map(_typeText).join(', ');
  final eventText = events.isNotEmpty ? ' events=$events' : '';
  return 'reference check: faces=${jsStr(normalizedCount(data['faceCount'], data['faces']))} '
      'persons=${jsStr(normalizedCount(data['personCount'], data['persons']))} '
      'gadgets=${asList(data['gadgets']).length}$eventText time=${durationMs}ms';
}

/// `audioSummaryText(data)`
String audioSummaryText(Map<String, dynamic> data) {
  final list = eventsOf(data);
  final joined = list.map(_typeText).join(', ');
  final events = joined.isNotEmpty ? joined : 'listening';
  final audio = asMap(data['audio']) ?? const <String, dynamic>{};
  final messages = list
      .map((e) => e['message'])
      .where(jsTruthy)
      .map((m) => jsStr(m))
      .join(' ');
  final mouthRaw = audio['studentMouthActivity'];
  final mouth = mouthRaw == null ? '-' : toFixed(mouthRaw, 3);
  final rms = jsTruthy(audio['rms']) ? audio['rms'] : 0;
  final speech = jsTruthy(audio['speechRatio']) ? audio['speechRatio'] : 0;
  return '${messages.isNotEmpty ? '$messages ' : ''}rms=${toFixed(rms, 3)} '
      'speech=${toFixed(speech, 2)} mouth=$mouth activeMs=${valueText(audio['activeMs'])} '
      'events=$events';
}

// ── overlay & local phone heuristic ────────────────────────────────────────

/// One rectangle `drawBoxes` strokes, in capture-frame pixels.
class OverlayBox {
  const OverlayBox({required this.bbox, required this.label, required this.color});

  /// `[x, y, width, height]`
  final List<double> bbox;
  final String label;

  /// ARGB, e.g. `0xFF2563EB`.
  final int color;
}

List<double>? _bbox(Object? v) {
  final list = asList(v);
  if (list.length != 4) return null;
  final out = <double>[];
  for (final e in list) {
    final n = jsNumber(e);
    out.add(n.toDouble());
  }
  return out;
}

/// `drawOverlay(data)` — candidates, persons, faces, gadgets, local phones,
/// in that paint order.
List<OverlayBox> overlayBoxes(
    Map<String, dynamic> data, List<Map<String, dynamic>> localPhoneCandidates) {
  final out = <OverlayBox>[];
  void add(List<Map<String, dynamic>> boxes, int color, String fallbackClass) {
    for (final item in boxes) {
      final bbox = _bbox(item['bbox']);
      if (bbox == null) continue;
      final cls = jsTruthy(item['class']) ? jsStr(item['class']) : fallbackClass;
      final conf = jsTruthy(item['confidence']) ? item['confidence'] : 0;
      out.add(OverlayBox(bbox: bbox, label: '$cls ${toFixed(conf, 2)}', color: color));
    }
  }

  add(
    listOfMaps(data['objects'])
        .where((o) => o['category'] == 'candidate' && !jsTruthy(o['ignoredReason']))
        .toList(),
    0xFFB76B00,
    'candidate',
  );
  add(listOfMaps(data['persons']), 0xFF20A060, 'person');
  add(listOfMaps(data['faces']), 0xFF2563EB, 'face');
  add(listOfMaps(data['gadgets']), 0xFFDC2626, 'gadget');
  add(localPhoneCandidates, 0xFFDC2626, 'gadget');
  return out;
}

/// `overlapRatio(innerBox, outerBox)`
double overlapRatio(List<num>? innerBox, List<num>? outerBox) {
  if (innerBox == null || outerBox == null || innerBox.length != 4 || outerBox.length != 4) {
    return 0;
  }
  final ix = innerBox[0], iy = innerBox[1], iw = innerBox[2], ih = innerBox[3];
  final ox = outerBox[0], oy = outerBox[1], ow = outerBox[2], oh = outerBox[3];
  final innerArea = math.max(0, iw) * math.max(0, ih);
  if (innerArea == 0) return 0;
  final left = math.max(ix, ox);
  final top = math.max(iy, oy);
  final right = math.min(ix + iw, ox + ow);
  final bottom = math.min(iy + ih, oy + oh);
  return (math.max(0, right - left) * math.max(0, bottom - top)) / innerArea;
}

/// Raw RGBA pixels of a captured frame (`ImageData`).
class RgbaFrame {
  const RgbaFrame({required this.width, required this.height, required this.data});
  final int width;
  final int height;
  final Uint8List data;
}

/// `detectPhoneLikeObjects(data)` — returns `[]` while
/// [enableLocalPhoneHeuristic] is off (as on the web), so the camera page
/// never has to ship full RGBA frames to Dart.
List<Map<String, dynamic>> detectPhoneLikeObjects(Map<String, dynamic> data, RgbaFrame? image,
    {bool enabled = enableLocalPhoneHeuristic}) {
  if (!enabled || image == null || asList(data['gadgets']).isNotEmpty) return const [];

  final width = image.width;
  final height = image.height;
  final total = width * height;
  final visited = Uint8List(total);
  final candidates = <Map<String, dynamic>>[];

  bool isDark(int index) {
    final offset = index * 4;
    final red = image.data[offset];
    final green = image.data[offset + 1];
    final blue = image.data[offset + 2];
    final maxC = math.max(red, math.max(green, blue));
    final minC = math.min(red, math.min(green, blue));
    return maxC < 78 && maxC - minC < 46;
  }

  final faces = listOfMaps(data['faces']);
  bool overlapsFace(List<num> bbox) =>
      faces.any((face) => overlapRatio(bbox, _bbox(face['bbox'])) > 0.28);

  for (var start = 0; start < total; start += 2) {
    if (visited[start] == 1 || !isDark(start)) continue;
    final stack = <int>[start];
    visited[start] = 1;
    var count = 0;
    var minX = width, minY = height, maxX = 0, maxY = 0;

    while (stack.isNotEmpty) {
      final index = stack.removeLast();
      final x = index % width;
      final y = index ~/ width;
      count++;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
      for (final next in [index - 1, index + 1, index - width, index + width]) {
        if (next < 0 || next >= total || visited[next] == 1) continue;
        if (((next % width) - x).abs() > 1) continue;
        if (!isDark(next)) continue;
        visited[next] = 1;
        stack.add(next);
      }
    }

    final boxWidth = maxX - minX + 1;
    final boxHeight = maxY - minY + 1;
    final boxArea = boxWidth * boxHeight;
    final fillRatio = count / math.max(1, boxArea);
    final areaRatio = boxArea / total;
    final aspect = boxWidth / math.max(1, boxHeight);
    final bbox = <num>[minX, minY, boxWidth, boxHeight];

    if (boxWidth < 34 || boxHeight < 48) continue;
    if (areaRatio < 0.006 || areaRatio > 0.22) continue;
    if (fillRatio < 0.3) continue;
    if (aspect < 0.28 || aspect > 2.4) continue;
    if (overlapsFace(bbox)) continue;

    final raw = 0.56 + fillRatio * 0.26 + math.min(areaRatio, 0.08);
    candidates.add({
      'class': 'phone-like object',
      'rawClass': 'local_dark_rectangle',
      'confidence': math.min(0.92, double.parse(raw.toStringAsFixed(2))),
      'bbox': bbox,
      'category': 'gadget',
    });
  }

  candidates.sort((a, b) =>
      ((b['confidence'] as num?) ?? 0).compareTo((a['confidence'] as num?) ?? 0));
  return candidates.take(2).toList();
}
