import 'package:elab_app/features/teacher_schedules/teacher_schedules_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Thursday.
  final now = DateTime(2026, 11, 12, 15, 30);

  group('tabs', () {
    test('prev / next wrap around', () {
      expect(nextTabOf('ongoing'), 'today');
      expect(prevTabOf('ongoing'), 'OverAll');
      expect(nextTabOf('OverAll'), 'ongoing');
      expect(prevTabOf('pastweek'), 'nextweek');
      expect(tabLabelOf('thismonth'), 'This Month');
      expect(tabLabelOf('upcoming'), '');
    });

    test('scheduleRange follows date-fns (weekStartsOn: 1)', () {
      expect(scheduleRange('ongoing', now), isNull);
      expect(scheduleRange('today', now), (start: '2026-11-12', end: '2026-11-12'));
      expect(scheduleRange('thisweek', now), (start: '2026-11-09', end: '2026-11-15'));
      expect(scheduleRange('nextweek', now), (start: '2026-11-16', end: '2026-11-22'));
      expect(scheduleRange('pastweek', now), (start: '2026-11-02', end: '2026-11-08'));
      expect(scheduleRange('thismonth', now), (start: '2026-11-01', end: '2026-11-30'));
      expect(scheduleRange('nextmonth', now), (start: '2026-12-01', end: '2026-12-31'));
      expect(scheduleRange('pastmonth', now), (start: '2026-10-01', end: '2026-10-31'));
      expect(scheduleRange('OverAll', now), (start: '', end: ''));
    });

    test('filterBatchId watcher has no thismonth branch', () {
      expect(scheduleRange('thismonth', now, withThisMonth: false), (start: '', end: ''));
      expect(scheduleRange('today', now, withThisMonth: false), (start: '2026-11-12', end: '2026-11-12'));
    });

    test('"next month" is addWeeks(now, 4) (web quirk)', () {
      expect(scheduleRange('nextmonth', DateTime(2026, 1, 1)), (start: '2026-01-01', end: '2026-01-31'));
    });

    test('subMonths clamps the day', () {
      expect(subMonths(DateTime(2026, 3, 31), 1), DateTime(2026, 2, 28));
      expect(subMonths(DateTime(2026, 1, 15), 1), DateTime(2025, 12, 15));
    });

    test('scheduleFilters drops empty values', () {
      expect(scheduleFilters((start: '', end: ''), null), isEmpty);
      expect(scheduleFilters((start: 'a', end: 'b'), '5'), {'start_date': 'a', 'end_date': 'b', 'batch_id': '5'});
    });

    test('currentTabDate', () {
      expect(currentTabDate('ongoing', now), 'Live now');
      expect(currentTabDate('today', now), 'NOV 12, 2026');
      expect(currentTabDate('thisweek', now), 'NOV 9, 2026 – NOV 15, 2026');
      expect(currentTabDate('OverAll', now), 'All time');
    });
  });

  group('lists', () {
    test('groupByClassBatch keeps first-seen order', () {
      final groups = groupByClassBatch([
        {'id': 1, 'batch': {'name': 'A', 'classes': {'name': 'Grade 5'}}},
        {'id': 2, 'batch': {'name': 'B', 'classes': {'name': 'Grade 5'}}},
        {'id': 3, 'batch': {'name': 'A', 'classes': {'name': 'Grade 5'}}},
      ]);
      expect(groups.length, 2);
      expect(groups[0].className, 'Grade 5');
      expect(groups[0].batchName, 'A');
      expect(groups[0].items.map((e) => e['id']), [1, 3]);
      expect(groups[1].items.map((e) => e['id']), [2]);
    });

    test('ongoingFrom wraps objects and keeps items with start_date', () {
      expect(ongoingFrom({'id': 1, 'start_date': '2026-01-01'}), [
        {'id': 1, 'start_date': '2026-01-01'}
      ]);
      expect(ongoingFrom([null, {'id': 2}, {'id': 3, 'start_date': 'x'}]).length, 1);
      expect(ongoingFrom(null), isEmpty);
    });

    test('flattenAttendance', () {
      expect(flattenAttendance([1, 2]), [1, 2]);
      expect(flattenAttendance({'a': [1], 'b': 'x', 'c': [2, 3]}), [1, 2, 3]);
      expect(flattenAttendance(null), isEmpty);
    });

    test('formatAttendanceTime converts UTC to IST', () {
      expect(formatAttendanceTime(null), '-');
      expect(formatAttendanceTime(''), '-');
      expect(formatAttendanceTime('2026-11-12 09:00:00'), '02:30 pm');
      expect(formatAttendanceTime('2026-11-12T09:00:00Z'), '02:30 pm');
      expect(formatAttendanceTime('garbage'), 'Invalid Date');
    });

    test('isMissedOrCanceled', () {
      expect(isMissedOrCanceled('Missed'), isTrue);
      expect(isMissedOrCanceled('canceled'), isTrue);
      expect(isMissedOrCanceled('scheduled'), isFalse);
      expect(isMissedOrCanceled(null), isFalse);
    });
  });

  group('chat & presence', () {
    test('mapChatMessage names the sender', () {
      final mine = mapChatMessage({'id': 1, 'user_id': 7, 'message': 'hi', 'created_at': '2026-11-12T09:00:00Z'}, 7);
      expect(mine['sender'], 'You');
      expect(mine['from'], 'user');
      final other = mapChatMessage({
        'id': 2,
        'user_id': 8,
        'message': 'yo',
        'user': {'first_name': 'Ann', 'last_name': 'Lee'},
      }, 7);
      expect(other['sender'], 'Ann Lee');
      expect(other['from'], 'other');
      final anon = mapChatMessage({'id': 3, 'user_id': 9, 'message': 'x'}, 7);
      expect(anon['sender'], 'User #9');
      final email = mapChatMessage({'id': 4, 'user_id': 9, 'user': {'email': 'a@b.c'}}, 7);
      expect(email['sender'], 'a@b.c');
    });

    test('incomingChatMessage parses string data and dedupes', () {
      final first = incomingChatMessage({'data': '{"id":5,"message":"hello","user_id":7}'}, const [], 7);
      expect(first?['id'], 5);
      expect(first?['sender'], 'You');
      expect(first?['time'], '');
      expect(incomingChatMessage({'id': 5, 'message': 'again'}, [first!], 7), isNull);
      expect(incomingChatMessage({'id': 6, 'message': ''}, const [], 7), isNull);
      final noId = incomingChatMessage({'message': 'm', 'user_id': 3, 'created_at': 'c'}, const [], 7);
      expect(noId?['id'], '3_c');
    });

    test('presence helpers', () {
      final users = presenceHere({
        'presence': {
          'ids': ['1', '2'],
          'hash': {
            '1': {'id': 1, 'email': 'A@x.com '},
            '2': {'id': 2, 'email': 'b@x.com'},
          },
          'count': 2,
        },
      });
      expect(users.length, 2);
      expect(presenceJoining({'user_id': '3', 'user_info': {'id': 3}}), {'id': 3});
      expect(presenceUserId({'user_id': 3}), '3');

      final students = [
        {'id': 10, 'user': {'id': 1, 'email': 'a@x.com'}},
        {'id': 11, 'user': {'id': 4, 'email': 'z@x.com'}},
      ];
      expect(isStudentOnline(students[0], users), isTrue);
      expect(isStudentOnline(students[1], users), isFalse);
      expect(onlineStudentCount(students, users), 1);
      expect(onlineStudentCount({'data': students}, users), 0);

      expect(joinPayloadId({'student_id': 9, 'user_id': 1}), 9);
      expect(joinPayloadId({'user': {'id': 4}}), 4);
      expect(joinedStudentIdsHas(students[1], ['4']), isTrue);
      expect(joinedStudentIdsHas({'id': 0}, ['0']), isFalse);
    });
  });

  group('create drawer', () {
    test('validatePage1 messages in order', () {
      String? v({
        String classType = 'eClass',
        Object? year = '1',
        List<String> batch = const ['2'],
        List<String> days = const ['monday'],
        String slots = '1',
        String minutes = '60',
        DateTime? start,
        DateTime? end,
      }) =>
          validatePage1(
            classType: classType,
            selectedYear: year,
            batch: batch,
            days: days,
            slots: slots,
            minutesPerDay: minutes,
            startDate: start ?? now,
            endDate: end ?? now,
          );
      expect(v(classType: ''), 'Please select Class Type');
      expect(v(year: null), 'Please select a Class');
      expect(v(batch: const []), 'Please select at least one Batch');
      expect(v(days: const []), 'Please select Days');
      expect(v(slots: '0'), 'Please enter number of Slots');
      expect(v(minutes: ''), 'Please enter Minutes per slot');
      expect(
        validatePage1(
          classType: 'eClass',
          selectedYear: '1',
          batch: const ['2'],
          days: const ['monday'],
          slots: '1',
          minutesPerDay: '60',
          startDate: null,
          endDate: now,
        ),
        'Please select Start and End Dates',
      );
      expect(v(), isNull);
    });

    test('applySlotsCount grows but never shrinks slotDetails', () {
      final a = applySlotsCount('3', const []);
      expect(a.slotsArray, [0, 1, 2]);
      expect(a.slotDetails.length, 3);
      final b = applySlotsCount('1', a.slotDetails);
      expect(b.slotsArray, [0]);
      expect(b.slotDetails.length, 3);
      expect(applySlotsCount('', const []).slotsArray, isEmpty);
    });

    final instructors = [
      {'id': 3, 'user': {'email': 'a@x.com', 'first_name': 'Al', 'last_name': ''}},
      {'id': 4, 'user': {'email': 'b@x.com', 'first_name': 'Bo', 'last_name': 'Ng'}},
    ];
    final courses = [
      {'id': 7, 'title': 'Math'},
    ];
    final slot = {'startAt': '10:00', 'subject': '7', 'instructor': '3', 'classType': '', 'title': 'Algebra'};

    test('generatePreviewSlots picks the weekdays in range', () {
      final r = generatePreviewSlots(
        startDate: DateTime(2026, 11, 9),
        endDate: DateTime(2026, 11, 15),
        days: const ['monday', 'Wednesday '],
        slotDetails: [slot],
        instructors: instructors,
        courses: courses,
        formClassType: 'eClass',
      );
      expect(r.error, isNull);
      expect(r.slots.map((s) => s['date']), ['2026-11-09', '2026-11-11']);
      expect(r.slots.first, {
        'date': '2026-11-09',
        'startAt': '10:00',
        'subject': 'Math',
        'instructor': 'a@x.com',
        'classType': 'eClass',
        'title': 'Algebra',
      });

      final payload = buildSlotsPayload(
        previewSlots: r.slots,
        instructors: instructors,
        courses: courses,
        minutesPerDay: '60',
        formClassType: 'eClass',
      );
      expect(payload.first, {
        'date': '2026-11-09',
        'start_time': '10:00',
        'duration': 60,
        'instructor_id': '3',
        'type': 'eClass',
        'title': 'Algebra',
        'course_id': '7',
      });
    });

    test('generatePreviewSlots errors', () {
      expect(
        generatePreviewSlots(
          startDate: null,
          endDate: now,
          days: const ['monday'],
          slotDetails: [slot],
          instructors: instructors,
          courses: courses,
          formClassType: '',
        ).error,
        'Select start and end dates',
      );
      expect(
        generatePreviewSlots(
          startDate: DateTime(2026, 11, 9),
          endDate: DateTime(2026, 11, 9),
          days: const ['monday'],
          slotDetails: [slot, slot],
          instructors: instructors,
          courses: courses,
          formClassType: '',
        ).error,
        'Conflict: a@x.com already has a slot on 2026-11-09 at 10:00',
      );
      expect(
        generatePreviewSlots(
          startDate: DateTime(2026, 11, 9),
          endDate: DateTime(2026, 11, 11),
          days: const ['sunday'],
          slotDetails: [slot],
          instructors: instructors,
          courses: courses,
          formClassType: '',
        ).error,
        'No slots generated.',
      );
    });

    test('filteredInstructors / instructorFullName', () {
      expect(filteredInstructors(instructors, '').length, 2);
      expect(filteredInstructors(instructors, 'B@').map((i) => i['id']), [4]);
      expect(instructorFullName(instructors[0]), 'Al');
      expect(instructorFullName(instructors[1]), 'Bo Ng');
    });
  });

  group('misc', () {
    test('viewableContent unwraps course_content', () {
      expect(viewableContent({'type': 'url', 'url': 'u'}), (type: 'url', url: 'u', content: ''));
      expect(
        viewableContent({
          'type': 'course_content',
          'course_content': {'type': 'html', 'content': '<p>x</p>'},
        }),
        (type: 'html', url: '', content: '<p>x</p>'),
      );
      expect(lmsContentIdOf({'content_id': null, 'course_content': {'id': 5}}), 5);
      expect(lmsContentIdOf(const {}), '');
    });

    test('url helpers', () {
      expect(isImageUrl('a/b.PNG'), isTrue);
      expect(isVideoUrl('a.mp4'), isTrue);
      expect(isPdfUrl('x.pdf'), isTrue);
      expect(isYouTubeUrl('https://youtu.be/abc'), isTrue);
      expect(youTubeId('https://www.youtube.com/watch?v=abc&t=1'), 'abc');
      expect(youTubeId('https://youtu.be/xyz?si=1'), 'xyz');
      expect(youTubeId('https://example.com'), '');
    });

    test('cleanPayload / looseToNumber / jsNumberOr0', () {
      expect(cleanPayload({'a': null, 'b': '', 'c': '  ', 'd': 0, 'e': 'x'}), {'d': 0, 'e': 'x'});
      expect(looseToNumber('45'), 45);
      expect(looseToNumber('1.5'), 1.5);
      expect(looseToNumber(''), '');
      expect(jsNumberOr0('abc'), 0);
      expect(jsNumberOr0('60'), 60);
    });
  });
}
