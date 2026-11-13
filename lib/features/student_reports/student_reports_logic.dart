/// Pure logic of
/// `src/components/new_ui_student_teacher_for_both_labs/studentreports.vue`
/// (date ranges, usage parsing, report aggregation, chart axes), kept free of
/// Flutter so it can be unit tested.
library;

import 'dart:math' as math;

import '../../core/utils/json.dart';
import '../upgrade/upgrade_plan_logic.dart' show jsNumber, jsRound, jsNumberString;

// ── date ranges ──────────────────────────────────────────────────────────

/// `rangeOptions` (key + label).
const reportRangeOptions = <({String key, String label})>[
  (key: 'today', label: 'Today'),
  (key: 'this_week', label: 'This Week'),
  (key: 'last_week', label: 'Last Week'),
  (key: 'past_30', label: 'Past 30 Days'),
  (key: 'this_month', label: 'This Month'),
  (key: 'last_month', label: 'Last Month'),
];

/// `rangeOptions.find(o => o.key === key)?.label ?? 'This Week'`
String reportRangeLabel(String key) {
  for (final o in reportRangeOptions) {
    if (o.key == key) return o.label;
  }
  return 'This Week';
}

/// `fmt(d)` = `d.toISOString().split('T')[0]` — the **UTC** date of a local
/// date-time (so in IST the start of a local day is the previous date, as
/// on the web). [utcOffset] replaces the device time zone (tests only).
String _isoUtcDate(DateTime local, Duration? utcOffset) {
  final utc = utcOffset == null
      ? local.toUtc()
      : DateTime.utc(local.year, local.month, local.day, local.hour, local.minute, local.second,
              local.millisecond)
          .subtract(utcOffset);
  String two(int v) => v.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-${two(utc.day)}';
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

/// `opt.getRange()` → `{ from, to }` for a [reportRangeOptions] key.
({String from, String to}) reportRange(String key, DateTime now, {Duration? utcOffset}) {
  String f(DateTime d) => _isoUtcDate(d, utcOffset);
  DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
  // `(now.getDay() + 6) % 7` — days since Monday.
  final sinceMonday = now.weekday - 1;
  switch (key) {
    case 'today':
      return (from: f(_startOfDay(now)), to: f(_endOfDay(now)));
    case 'this_week':
      return (from: f(_startOfDay(day(-sinceMonday))), to: f(_endOfDay(now)));
    case 'last_week':
      return (from: f(_startOfDay(day(-sinceMonday - 7))), to: f(_endOfDay(day(-sinceMonday - 1))));
    case 'past_30':
      return (from: f(_startOfDay(day(-29))), to: f(_endOfDay(now)));
    case 'this_month':
      return (from: f(_startOfDay(DateTime(now.year, now.month, 1))), to: f(_endOfDay(now)));
    case 'last_month':
      return (
        from: f(_startOfDay(DateTime(now.year, now.month - 1, 1))),
        to: f(_endOfDay(DateTime(now.year, now.month, 0))),
      );
    default:
      throw ArgumentError.value(key, 'key');
  }
}

/// `fetchYearlyUsage()` range: `${year}-01-01` … `${year}-12-31`.
({String from, String to}) yearRange(DateTime now) => (from: '${now.year}-01-01', to: '${now.year}-12-31');

// ── formatting ───────────────────────────────────────────────────────────

/// `formatMinutes(mins)` → `0m`, `45m`, `2h`, `1h 5m`.
String formatReportMinutes(num mins) {
  if (mins == 0 || (mins is double && mins.isNaN)) return '0m';
  final h = (mins / 60).floor();
  final m = mins % 60;
  if (h == 0) return '${jsNumberString(m)}m';
  if (m == 0) return '${h}h';
  return '${h}h ${jsNumberString(m)}m';
}

/// `parseUsageString(usage)` — `"1h 20m 40s"` → 81 (minutes; seconds are
/// rounded to whole minutes).
int parseUsageString(Object? usage) {
  if (usage == null || usage == '' || usage == 0 || usage == false) return 0;
  final s = '$usage';
  var total = 0;
  final hours = RegExp(r'(\d+)\s*h').firstMatch(s);
  final minutes = RegExp(r'(\d+)\s*m').firstMatch(s);
  final seconds = RegExp(r'(\d+)\s*s').firstMatch(s);
  if (hours != null) total += int.parse(hours.group(1)!) * 60;
  if (minutes != null) total += int.parse(minutes.group(1)!);
  if (seconds != null) total += jsRound(int.parse(seconds.group(1)!) / 60).toInt();
  return total;
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// The x label of a `YYYY-MM-DD` day: `toLocaleDateString('en', { weekday:
/// 'short' })` when the series has ≤ 7 days, else `M/D`.
String dayLabel(String isoDay, int dayCount) {
  final parts = isoDay.split('-').map(int.tryParse).toList();
  final y = parts.isNotEmpty ? parts[0] : null;
  final mo = parts.length > 1 ? parts[1] : null;
  final d = parts.length > 2 ? parts[2] : null;
  if (dayCount <= 7) {
    if (y == null || mo == null || d == null) return 'Invalid Date';
    return _weekdays[DateTime(y, mo, d).weekday - 1];
  }
  return '${mo ?? 'NaN'}/${d ?? 'NaN'}';
}

// ── usage (student self usage) ───────────────────────────────────────────

/// `mapApiResponse(data)` → chart labels and minutes per day.
({List<String> labels, List<int> minutes}) mapUsageResponse(dynamic data) {
  final rows = data is List ? data : const [];
  if (rows.isEmpty) return (labels: const [], minutes: const []);
  final dayCount = rows.length;
  return (
    labels: [for (final r in rows) dayLabel('${asMap(r)?['period'] ?? ''}', dayCount)],
    minutes: [for (final r in rows) parseUsageString(asMap(r)?['total_usage'])],
  );
}

/// `fetchYearlyUsage()` → `totalMinutes`.
int yearlyTotalMinutes(dynamic data) {
  final rows = data is List ? data : const [];
  return rows.fold<int>(0, (acc, r) => acc + parseUsageString(asMap(r)?['total_usage']));
}

// ── activity chart stats ─────────────────────────────────────────────────

/// One summary pill under the activity chart.
class ActivityPill {
  const ActivityPill(this.label, this.value, this.color);
  final String label;
  final String value;

  /// ARGB (`#f59e0b` / `#4ade80` / `#8b5cf6`).
  final int color;
}

/// `mapActivityResponse(data)` result.
class ActivityReport {
  const ActivityReport({
    required this.labels,
    required this.minutes,
    required this.counts,
    required this.summary,
  });

  final List<String> labels;
  final List<double> minutes;
  final List<int> counts;
  final List<ActivityPill> summary;
}

final _isoDay = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// `Object.entries(v)` for maps and arrays (index keys).
Iterable<MapEntry<String, dynamic>> _entries(dynamic v) {
  if (v is Map) return v.entries.map((e) => MapEntry('${e.key}', e.value));
  if (v is List) return [for (var i = 0; i < v.length; i++) MapEntry('$i', v[i])];
  return const [];
}

/// `Math.round(Number(x?.duration ?? 0) / 60)`
double _durationMinutes(dynamic dayData) {
  final duration = dayData is Map ? (dayData['duration'] ?? 0) : 0;
  return jsRound(jsNumber(duration) / 60);
}

/// `mapActivityResponse(data)` — sums `duration` (seconds → rounded minutes)
/// per `YYYY-MM-DD` key over every user block / activity (one or two levels
/// deep), sorted by date, plus the Total Time / Active Days / Peak Day pills.
ActivityReport mapActivityResponse(dynamic data) {
  // Insertion-ordered like a JS object with non-numeric keys.
  final dateMap = <String, double>{};
  if (data is Map) {
    for (final userBlock in data.values) {
      if (userBlock is! Map && userBlock is! List) continue;
      for (final entry in _entries(userBlock)) {
        final value = entry.value;
        if (entry.key == 'user' || value is! Map && value is! List) continue;
        for (final day in _entries(value)) {
          if (_isoDay.hasMatch(day.key)) {
            dateMap[day.key] = (dateMap[day.key] ?? 0) + _durationMinutes(day.value);
          } else if (day.value is Map || day.value is List) {
            for (final inner in _entries(day.value)) {
              if (_isoDay.hasMatch(inner.key)) {
                dateMap[inner.key] = (dateMap[inner.key] ?? 0) + _durationMinutes(inner.value);
              }
            }
          }
        }
      }
    }
  }

  final sortedDates = dateMap.keys.toList()..sort();
  final dayCount = sortedDates.length;
  final labels = [for (final d in sortedDates) dayLabel(d, dayCount)];
  final minutes = [for (final d in sortedDates) dateMap[d]!];
  final counts = [for (final d in sortedDates) dateMap[d]! > 0 ? 1 : 0];

  final totalMins = dateMap.values.fold<double>(0, (a, b) => a + b);
  // reduce over the sorted dates, starting from the first *inserted* key;
  // ties keep the earlier winner.
  var peakDate = dateMap.isEmpty ? '' : dateMap.keys.first;
  for (final d in sortedDates) {
    if (dateMap[d]! > (dateMap[peakDate] ?? 0)) peakDate = d;
  }

  return ActivityReport(
    labels: labels,
    minutes: minutes,
    counts: counts,
    summary: [
      ActivityPill('Total Time', formatReportMinutes(totalMins), 0xFFF59E0B),
      ActivityPill('Active Days', '${sortedDates.length}', 0xFF4ADE80),
      if (peakDate.isNotEmpty) ActivityPill('Peak Day', peakDate, 0xFF8B5CF6),
    ],
  );
}

// ── chart axes ───────────────────────────────────────────────────────────

/// Chart.js `niceNum(range)` (non-rounding variant used for tick spacing).
double niceNum(double range) {
  if (range <= 0 || range.isNaN || range.isInfinite) return 1;
  final exponent = (math.log(range) / math.ln10).floor();
  final fraction = range / math.pow(10, exponent);
  final double niceFraction;
  if (fraction <= 1) {
    niceFraction = 1;
  } else if (fraction <= 2) {
    niceFraction = 2;
  } else if (fraction <= 5) {
    niceFraction = 5;
  } else {
    niceFraction = 10;
  }
  return niceFraction * math.pow(10, exponent);
}

/// The y axis of a chart: `0 … max`, ticks every [interval].
class ReportAxis {
  const ReportAxis(this.max, this.interval);
  final double max;
  final double interval;
}

/// Usage chart y axis (`beginAtZero`, `grace: '15%'`, Chart.js auto ticks
/// with at most 11 ticks).
ReportAxis usageAxis(List<num> data, {int maxTicks = 11}) {
  var dataMax = data.isEmpty ? 0.0 : data.map((e) => e.toDouble()).reduce(math.max);
  if (dataMax.isNaN || dataMax <= 0) dataMax = 1; // min === max → max + 1
  final graced = dataMax * 1.15;
  final maxSpaces = maxTicks - 1;
  var spacing = niceNum(graced / maxSpaces);
  final numSpaces = (graced / spacing).ceil();
  if (numSpaces > maxSpaces) spacing = niceNum(numSpaces * spacing / maxSpaces);
  final niceMax = (graced / spacing).ceil() * spacing;
  return ReportAxis(_clean(niceMax), _clean(spacing));
}

/// Activity chart y axis: `max: Math.max(...minutes, 10)`,
/// `stepSize: Math.ceil(max / 5)`.
ReportAxis activityAxis(List<num> minutes) {
  var max = 10.0;
  for (final m in minutes) {
    if (m.isNaN) return const ReportAxis(10, 2);
    if (m > max) max = m.toDouble();
  }
  return ReportAxis(max, (max / 5).ceilToDouble());
}

/// Removes floating-point noise (`0.30000000000000004` → `0.3`).
double _clean(double v) => double.parse(v.toStringAsPrecision(12));
