import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Static demo data that DashboardPage.vue currently ships with
/// (INSTITUTE_STATIC, INSTRUCTOR_STATIC, STATIC_STUDENTS, STATIC_INSTRUCTORS).
/// Kept identical so the Flutter dashboard matches the web one.

class UsagePoint {
  const UsagePoint(this.name, {this.students = 0, this.instructors = 0, this.total = 0});
  final String name;
  final num students;
  final num instructors;
  final num total;
}

const instituteStatic = <UsagePoint>[
  UsagePoint('Jan', students: 40, instructors: 10),
  UsagePoint('Feb', students: 55, instructors: 14),
  UsagePoint('Mar', students: 35, instructors: 8),
  UsagePoint('Apr', students: 60, instructors: 15),
  UsagePoint('May', students: 80, instructors: 20),
  UsagePoint('Jun', students: 65, instructors: 17),
  UsagePoint('Jul', students: 50, instructors: 12),
  UsagePoint('Aug', students: 70, instructors: 18),
  UsagePoint('Sep', students: 45, instructors: 11),
  UsagePoint('Oct', students: 55, instructors: 13),
  UsagePoint('Nov', students: 75, instructors: 19),
  UsagePoint('Dec', students: 60, instructors: 15),
];

const instructorStatic = <UsagePoint>[
  UsagePoint('Jan', students: 12),
  UsagePoint('Feb', students: 18),
  UsagePoint('Mar', students: 10),
  UsagePoint('Apr', students: 22),
  UsagePoint('May', students: 30),
  UsagePoint('Jun', students: 25),
  UsagePoint('Jul', students: 17),
  UsagePoint('Aug', students: 28),
  UsagePoint('Sep', students: 14),
  UsagePoint('Oct', students: 20),
  UsagePoint('Nov', students: 32),
  UsagePoint('Dec', students: 24),
];

class Person {
  const Person(this.id, this.name, this.sub, this.score, this.badge);
  final int id;
  final String name;
  final String sub;
  final int score;
  final String badge;
}

const staticStudents = <Person>[
  Person(1, 'Arjun Sharma', 'Web Development · Batch A', 92, 'Top Performer'),
  Person(2, 'Priya Mehta', 'Data Science · Batch B', 88, 'Active'),
  Person(3, 'Rahul Verma', 'UI/UX Design · Batch A', 74, 'Active'),
  Person(4, 'Sneha Iyer', 'Cloud Computing · Batch C', 95, 'Top Performer'),
  Person(5, 'Karan Patel', 'Machine Learning · Batch B', 67, 'Needs Attention'),
  Person(6, 'Divya Nair', 'Cybersecurity · Batch A', 81, 'Active'),
  Person(7, 'Amit Joshi', 'Web Development · Batch C', 59, 'Needs Attention'),
  Person(8, 'Meera Pillai', 'Data Science · Batch A', 90, 'Top Performer'),
  Person(9, 'Rohit Singh', 'DevOps · Batch B', 76, 'Active'),
  Person(10, 'Anjali Gupta', 'UI/UX Design · Batch C', 83, 'Active'),
  Person(11, 'Vikram Reddy', 'Machine Learning · Batch A', 71, 'Active'),
  Person(12, 'Pooja Desai', 'Cloud Computing · Batch B', 96, 'Top Performer'),
];

const staticInstructors = <Person>[
  Person(1, 'Dr. Suresh Kumar', 'Web Development · 5 yrs', 98, 'Expert'),
  Person(2, 'Prof. Anita Rao', 'Data Science · 8 yrs', 95, 'Expert'),
  Person(3, 'Mr. Rajesh Nair', 'UI/UX Design · 4 yrs', 87, 'Senior'),
  Person(4, 'Ms. Kavita Pillai', 'Machine Learning · 6 yrs', 93, 'Expert'),
  Person(5, 'Dr. Arun Bhat', 'Cybersecurity · 10 yrs', 99, 'Expert'),
  Person(6, 'Ms. Rekha Menon', 'Cloud Computing · 3 yrs', 79, 'Senior'),
  Person(7, 'Mr. Sanjay Tiwari', 'DevOps · 5 yrs', 84, 'Senior'),
  Person(8, 'Prof. Leela Sharma', 'Data Science · 9 yrs', 96, 'Expert'),
];

Color badgeBg(String badge) => switch (badge) {
      'Top Performer' => const Color(0xFFEEEDFE),
      'Expert' => const Color(0xFFE1F5EE),
      'Senior' => const Color(0xFFE6F1FB),
      'Active' => const Color(0xFFEAF3DE),
      'Needs Attention' => const Color(0xFFFAECE7),
      _ => const Color(0xFFF1EFE8),
    };

Color badgeText(String badge) => switch (badge) {
      'Top Performer' => const Color(0xFF3C3489),
      'Expert' => const Color(0xFF085041),
      'Senior' => const Color(0xFF0C447C),
      'Active' => const Color(0xFF27500A),
      'Needs Attention' => const Color(0xFF993C1D),
      _ => const Color(0xFF5F5E5A),
    };

String initials(String name) => name
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();

/// "1h 20m 30s" → minutes (convertToMinutes).
int convertToMinutes(String time) {
  int part(String unit) =>
      int.tryParse(RegExp('(\\d+)$unit').firstMatch(time)?.group(1) ?? '') ?? 0;
  return part('h') * 60 + part('m') + (part('s') / 60).round();
}

/// Y-axis tick label: minutes → "2h 5m" / "45m" (`Math.floor(val / 60)`,
/// `val % 60`; fractional ticks print like JS numbers, e.g. "0.5m").
String formatMinutes(double value) {
  final h = (value / 60).floor();
  final m = value % 60;
  final ms = m == m.roundToDouble() ? m.toInt().toString() : m.toString();
  return h > 0 ? '${h}h ${ms}m' : '${ms}m';
}

/// chart.js `LinearScale` ticks for a `beginAtZero` axis whose data max is
/// [dataMax] (no data / all zero → 0..1), with at most [maxTicks] ticks:
/// the axis max and the tick step.
({double max, double step}) chartJsNiceScale(double dataMax, {int maxTicks = 11}) {
  var max = dataMax;
  if (!max.isFinite || max <= 0) max = 1;
  double niceNum(double range) {
    final rounded = range.roundToDouble();
    if ((range - rounded).abs() <= range / 1000) range = rounded;
    final exp = (math.log(range) / math.ln10).floor();
    final niceRange = math.pow(10, exp).toDouble();
    final fraction = range / niceRange;
    final niceFraction = fraction <= 1
        ? 1
        : fraction <= 2
            ? 2
            : fraction <= 5
                ? 5
                : 10;
    return niceFraction * niceRange;
  }

  final maxSpaces = maxTicks - 1;
  var spacing = niceNum(max / maxSpaces);
  final numSpaces = (max / spacing).ceil();
  if (numSpaces > maxSpaces) spacing = niceNum(numSpaces * spacing / maxSpaces);
  // Round away float noise the way chart.js does (`decimalPlaces(spacing)`).
  final decimals = spacing >= 1 ? 0 : (-(math.log(spacing) / math.ln10).floor());
  double round(double v) => double.parse(v.toStringAsFixed(decimals));
  return (max: round((max / spacing).ceil() * spacing), step: round(spacing));
}

enum UsageFilter {
  thisWeek('this_week', 'This Week'),
  pastWeek('past_week', 'Past Week'),
  thisMonth('this_month', 'This Month'),
  pastMonth('past_month', 'Past Month'),
  overall('overall', 'Overall');

  const UsageFilter(this.value, this.label);
  final String value;
  final String label;
}

/// Port of `getDateRange(filter)` (JS Date semantics: week starts Sunday).
({String from, String to}) dateRange(UsageFilter filter, [DateTime? clock]) {
  final now = clock ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final jsDay = now.weekday % 7; // Sunday = 0
  DateTime from;
  DateTime to = today;
  switch (filter) {
    case UsageFilter.thisWeek:
      from = today.subtract(Duration(days: jsDay));
    case UsageFilter.pastWeek:
      final startOfThisWeek = today.subtract(Duration(days: jsDay));
      from = startOfThisWeek.subtract(const Duration(days: 7));
      to = startOfThisWeek.subtract(const Duration(days: 1));
    case UsageFilter.thisMonth:
      from = DateTime(now.year, now.month, 1);
      to = DateTime(now.year, now.month + 1, 0);
    case UsageFilter.pastMonth:
      from = DateTime(now.year, now.month - 1, 1);
      to = DateTime(now.year, now.month, 0);
    case UsageFilter.overall:
      from = today;
  }
  final f = DateFormat('yyyy-MM-dd');
  return (from: f.format(from), to: f.format(to));
}
