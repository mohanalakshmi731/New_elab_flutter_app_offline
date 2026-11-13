import 'package:elab_app/core/utils/json.dart';
import 'package:elab_app/features/dashboard/dashboard_data.dart';
import 'package:elab_app/widgets/web_content_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('json helpers', () {
    test('unwrapList handles raw arrays, {data: []} and paginated {data: {data: []}}', () {
      expect(unwrapList([1, 2]), [1, 2]);
      expect(unwrapList({'data': [3]}), [3]);
      expect(unwrapList({
        'data': {'data': [4], 'current_page': 1}
      }), [4]);
      expect(unwrapList({'message': 'x'}), isEmpty);
      expect(unwrapList(null), isEmpty);
    });

    test('dig walks maps and lists safely', () {
      final j = {
        'roles': [
          {'name': 'student'}
        ]
      };
      expect(dig(j, ['roles', 0, 'name']), 'student');
      expect(dig(j, ['roles', 5, 'name']), isNull);
      expect(dig(null, ['a']), isNull);
    });

    test('asInt / asBool accept API quirks', () {
      expect(asInt('12'), 12);
      expect(asInt(3.0), 3);
      expect(asInt('x'), isNull);
      expect(asBool(1), isTrue);
      expect(asBool('true'), isTrue);
      expect(asBool('0'), isFalse);
      expect(asBool(null, fallback: true), isTrue);
    });
  });

  group('dashboard helpers', () {
    test('convertToMinutes parses "1h 20m 40s"', () {
      expect(convertToMinutes('1h 20m 40s'), 81);
      expect(convertToMinutes('45m'), 45);
      expect(convertToMinutes('29s'), 0);
      expect(convertToMinutes(''), 0);
    });

    test('formatMinutes matches the chart.js tick callback', () {
      expect(formatMinutes(0), '0m');
      expect(formatMinutes(45), '45m');
      expect(formatMinutes(125), '2h 5m');
    });

    test('initials uses the first two words', () {
      expect(initials('Dr. Suresh Kumar'), 'DS');
      expect(initials('Arjun Sharma'), 'AS');
    });

    // Wednesday 12 Nov 2025 → JS getDay() = 3, week starts Sunday 9 Nov.
    final clock = DateTime(2025, 11, 12, 15, 30);

    test('dateRange this_week starts on Sunday', () {
      final r = dateRange(UsageFilter.thisWeek, clock);
      expect(r.from, '2025-11-09');
      expect(r.to, '2025-11-12');
    });

    test('dateRange past_week is the previous Sunday..Saturday', () {
      final r = dateRange(UsageFilter.pastWeek, clock);
      expect(r.from, '2025-11-02');
      expect(r.to, '2025-11-08');
    });

    test('dateRange month filters', () {
      expect(dateRange(UsageFilter.thisMonth, clock), (from: '2025-11-01', to: '2025-11-30'));
      expect(dateRange(UsageFilter.pastMonth, clock), (from: '2025-10-01', to: '2025-10-31'));
      final jan = DateTime(2026, 1, 15);
      expect(dateRange(UsageFilter.pastMonth, jan), (from: '2025-12-01', to: '2025-12-31'));
    });
  });

  group('embedded content', () {
    test('YouTube links become embed URLs', () {
      expect(normalizeEmbedUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          'https://www.youtube.com/embed/dQw4w9WgXcQ');
      expect(normalizeEmbedUrl('https://youtu.be/dQw4w9WgXcQ?t=3'),
          'https://www.youtube.com/embed/dQw4w9WgXcQ');
      expect(normalizeEmbedUrl(' https://example.com/sim/index.html '),
          'https://example.com/sim/index.html');
    });
  });
}
