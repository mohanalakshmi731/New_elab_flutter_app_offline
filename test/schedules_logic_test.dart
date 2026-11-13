import 'package:elab_app/features/schedules/schedules_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JS coercions', () {
    test('schNumber follows Number()', () {
      expect(schNumber(null), 0);
      expect(schNumber(''), 0);
      expect(schNumber(' 12 '), 12);
      expect(schNumber('2.5'), 2.5);
      expect(schNumber('3.0'), 3);
      expect(schNumber('abc').isNaN, isTrue);
      expect(schNumber(true), 1);
    });

    test('schString / vText / jsFirst', () {
      expect(schString(null), 'null');
      expect(schString(12.0), '12');
      expect(vText(null), '');
      expect(jsFirst(['7', '8']), '7');
      expect(jsFirst('12'), '1'); // the filter's single batch id string
      expect(jsFirst(<String>[]), isNull);
      expect(jsFirst(''), isNull);
    });

    test('cleanPayload drops empty values', () {
      expect(cleanPayload({'a': null, 'b': '', 'c': '  ', 'd': 0, 'e': 'x'}), {'d': 0, 'e': 'x'});
    });
  });

  group('tab ranges', () {
    // Wednesday 2026-11-11
    final now = DateTime(2026, 11, 11, 15, 30);

    test('scheduleRange', () {
      expect(scheduleRange('today', now), (start: '2026-11-11', end: '2026-11-11'));
      expect(scheduleRange('thisweek', now), (start: '2026-11-09', end: '2026-11-15'));
      expect(scheduleRange('thismonth', now), (start: '2026-11-01', end: '2026-11-30'));
      expect(scheduleRange('nextweek', now), (start: '2026-11-16', end: '2026-11-22'));
      expect(scheduleRange('nextmonth', now), (start: '2026-12-01', end: '2026-12-31'));
      expect(scheduleRange('pastweek', now), (start: '2026-11-02', end: '2026-11-08'));
      expect(scheduleRange('pastmonth', now), (start: '2026-10-01', end: '2026-10-31'));
      expect(scheduleRange('OverAll', now), (start: '', end: ''));
    });

    test('nextmonth is the month of now + 4 weeks (web quirk)', () {
      expect(scheduleRange('nextmonth', DateTime(2026, 1, 1)), (start: '2026-01-01', end: '2026-01-31'));
    });

    test('pastmonth clamps the day (Mar 31 → Feb)', () {
      expect(scheduleRange('pastmonth', DateTime(2026, 3, 31)), (start: '2026-02-01', end: '2026-02-28'));
    });

    test('Sunday belongs to the week starting the Monday before', () {
      expect(scheduleRange('thisweek', DateTime(2026, 11, 15)), (start: '2026-11-09', end: '2026-11-15'));
    });

    test('batch watcher has no this-week / this-month ranges', () {
      expect(batchWatcherRange('thisweek', now), (start: '', end: ''));
      expect(batchWatcherRange('thismonth', now), (start: '', end: ''));
      expect(batchWatcherRange('today', now), scheduleRange('today', now));
    });

    test('scheduleFilters', () {
      expect(scheduleFilters((start: 'a', end: 'b'), ['5', '6']), {'start_date': 'a', 'end_date': 'b', 'batch_id': '5'});
      expect(scheduleFilters((start: '', end: ''), <String>[]), {'batch_id': null});
      expect(scheduleFilters((start: '', end: ''), '12'), {'batch_id': '1'});
    });
  });

  group('lists', () {
    test('ongoingFrom keeps items with a start_date', () {
      expect(ongoingFrom([
        {'id': 1, 'start_date': '2026-01-01'},
        {'id': 2},
        null,
      ]).map((e) => e['id']), [1]);
      expect(ongoingFrom({'id': 3, 'start_date': 'x'}).single['id'], 3);
    });

    test('groupByClassBatch groups in first-seen order', () {
      Map<String, dynamic> s(int id, String c, String b) => {
            'id': id,
            'batch': {
              'name': b,
              'classes': {'name': c},
            },
          };
      final groups = groupByClassBatch([s(1, 'C1', 'B1'), s(2, 'C2', 'B1'), s(3, 'C1', 'B1')]);
      expect(groups.length, 2);
      expect(groups.first.className, 'C1');
      expect(groups.first.items.map((e) => e['id']), [1, 3]);
    });

    test('isBadStatus', () {
      expect(isBadStatus('Missed'), isTrue);
      expect(isBadStatus('canceled'), isTrue);
      expect(isBadStatus('completed'), isFalse);
      expect(isBadStatus(null), isFalse);
    });
  });

  group('create drawer', () {
    final instructors = [
      {
        'id': 7,
        'user': {'email': 'a@x.com'},
      },
      {
        'id': 8,
        'user': {'email': 'b@x.com'},
      },
    ];
    final courses = [
      {'id': 3, 'title': 'Maths'},
    ];

    test('validatePage1 messages in order', () {
      String? v({
        String classType = 'eClass',
        Object? year = '1',
        List<String> batch = const ['2'],
        List<String> days = const ['monday'],
        String slots = '1',
        String minutes = '30',
        String start = '2026-01-01',
        String end = '2026-01-31',
      }) =>
          validatePage1(
            classType: classType,
            selectedYear: year,
            batch: batch,
            days: days,
            slots: slots,
            minutesPerDay: minutes,
            startDate: start,
            endDate: end,
          );
      expect(v(), isNull);
      expect(v(classType: ''), 'Please select Class Type');
      expect(v(year: ''), 'Please select a Class');
      expect(v(batch: []), 'Please select at least one Batch');
      expect(v(days: []), 'Please select Days');
      expect(v(slots: '0'), 'Please enter number of Slots');
      expect(v(minutes: ''), 'Please enter Minutes per slot');
      expect(v(end: ''), 'Please select Start and End Dates');
    });

    test('slotCount', () {
      expect(slotCount('3'), 3);
      expect(slotCount(''), 0);
      expect(slotCount('-2'), 0);
      expect(slotCount('2.5'), 2);
    });

    test('buildPreviewSlots crosses selected weekdays with slots', () {
      final r = buildPreviewSlots(
        startDate: '2026-11-09', // Monday
        endDate: '2026-11-22',
        days: ['monday', 'Sunday '],
        slotDetails: [SlotDetail(startAt: '10:00', subject: '3', instructor: '7', title: 'T')],
        instructors: instructors,
        courses: courses,
        classType: 'eClass',
      );
      expect(r.error, isNull);
      expect(r.slots.map((s) => s.date), ['2026-11-09', '2026-11-15', '2026-11-16', '2026-11-22']);
      expect(r.slots.first.instructor, 'a@x.com');
      expect(r.slots.first.subject, 'Maths');
      expect(r.slots.first.classType, 'eClass');
    });

    test('buildPreviewSlots reports conflicts and empty results', () {
      final conflict = buildPreviewSlots(
        startDate: '2026-11-09',
        endDate: '2026-11-09',
        days: ['monday'],
        slotDetails: [
          SlotDetail(startAt: '10:00', instructor: '7'),
          SlotDetail(startAt: '10:00', instructor: '7'),
        ],
        instructors: instructors,
        courses: courses,
        classType: '',
      );
      expect(conflict.error, 'Conflict: a@x.com already has a slot on 2026-11-09 at 10:00');

      final none = buildPreviewSlots(
        startDate: '2026-11-10',
        endDate: '2026-11-10',
        days: ['monday'],
        slotDetails: [SlotDetail()],
        instructors: instructors,
        courses: courses,
        classType: '',
      );
      expect(none.error, 'No slots generated. Please select valid days and slots.');

      expect(
        buildPreviewSlots(
          startDate: '',
          endDate: '2026-11-10',
          days: const [],
          slotDetails: const [],
          instructors: instructors,
          courses: courses,
          classType: '',
        ).error,
        'Select start and end dates',
      );
    });

    test('buildSlotsPayload maps emails / titles back to ids', () {
      final payload = buildSlotsPayload(
        previewSlots: [
          PreviewSlot(date: '2026-11-09', startAt: '10:00', subject: 'Maths', instructor: 'b@x.com', title: 'T'),
        ],
        instructors: instructors,
        courses: courses,
        minutesPerDay: '45',
        classType: 'eClass',
      );
      expect(payload.single, {
        'date': '2026-11-09',
        'start_time': '10:00',
        'duration': 45,
        'instructor_id': '8',
        'type': 'eClass',
        'title': 'T',
        'course_id': '3',
      });
    });
  });

  group('attendance / participants', () {
    test('flattenAttendance', () {
      expect(flattenAttendance([1, 2]), [1, 2]);
      expect(flattenAttendance({
        'a': [1],
        'b': 'x',
        'c': [2, 3],
      }), [1, 2, 3]);
      expect(flattenAttendance(null), isEmpty);
    });

    test('formatAttendanceTime shows IST hh:mm am/pm', () {
      expect(formatAttendanceTime(null), '-');
      expect(formatAttendanceTime(''), '-');
      expect(formatAttendanceTime('2026-01-01 10:00:00'), '03:30 pm');
      expect(formatAttendanceTime('2026-01-01T18:45:00.000000Z'), '12:15 am');
      expect(formatAttendanceTime('nonsense'), 'Invalid Date');
    });

    test('online / joined checks', () {
      final online = [
        {'id': 1, 'email': ' A@X.com'},
      ];
      final student = {
        'id': 9,
        'user_id': 5,
        'user': {'id': 5, 'email': 'a@x.com '},
      };
      expect(isStudentOnline(student, online), isTrue);
      expect(onlineStudentCount([student, {'user': {}}], online), 1);
      expect(onlineStudentCount('x', online), 0);
      expect(joinedStudentIdsHas(student, ['5']), isTrue);
      expect(joinedStudentIdsHas({'id': 9}, ['5']), isFalse);
      expect(joinedIdOf({'student_id': 4, 'user_id': 5}), '4');
      expect(joinedIdOf({'user': {'id': 6}}), '6');
      expect(joinedIdOf({}), isNull);
    });
  });

  group('presence', () {
    test('subscription data → members', () {
      final m = presenceMembers({
        'presence': {
          'ids': ['1', '2'],
          'hash': {
            '1': {'id': 1, 'email': 'a@x.com'},
            '2': {'id': 2, 'email': 'b@x.com'},
          },
          'count': 2,
        },
      });
      expect(m.keys, ['1', '2']);
      expect(m['2']!['email'], 'b@x.com');
      expect(presenceMembers(null), isEmpty);
    });

    test('member added / removed', () {
      expect(presenceJoining({'user_id': '3', 'user_info': {'id': 3}}), {'id': 3});
      expect(presenceUserId({'user_id': 3}), '3');
    });
  });

  group('chat', () {
    test('history mapping', () {
      final mine = chatFromHistory({'id': 1, 'user_id': 5, 'message': 'hi', 'created_at': '2026-01-01T10:00:00Z'}, 5);
      expect(mine.sender, 'You');
      expect(mine.mine, isTrue);
      final other = chatFromHistory({
        'id': 2,
        'user_id': 6,
        'message': 'yo',
        'user': {'first_name': 'Ann', 'last_name': ''},
      }, 5);
      expect(other.sender, 'Ann');
      expect(other.from, 'other');
      expect(other.time, 'Invalid Date');
      expect(chatFromHistory({'id': 3, 'user_id': 7}, 5).sender, 'User #7');
    });

    test('start mapping uses full_name / email / Unknown', () {
      expect(chatFromStart({'user': {'full_name': 'F', 'id': 5}}, 5).sender, 'F');
      expect(chatFromStart({'user': {'full_name': 'F', 'id': 5}}, 5).mine, isTrue);
      expect(chatFromStart({}, 5).sender, 'Unknown');
    });

    test('event mapping', () {
      expect(chatFromEvent(null, 1), isNull);
      expect(chatFromEvent({'message': ''}, 1), isNull);
      final e = chatFromEvent({'data': '{"message":"hey","user_id":2,"created_at":null}'}, 1)!;
      expect(e.text, 'hey');
      expect(e.id, '2_null');
      expect(chatFromEvent({'message': 'x'}, 1)!.id, 'undefined_undefined');
      expect(e.time, '');
      expect(e.sender, 'User #2');
      final mine = chatFromEvent({'id': 9, 'message': 'm', 'user_id': '1'}, 1)!;
      expect(mine.sender, 'You');
      expect(mine.id, 9);
    });
  });

  group('previews', () {
    test('viewedFields follows LMS content', () {
      final v = viewedFields({
        'type': 'course_content',
        'url': null,
        'course_content': {'type': 'url', 'url': 'https://x/a.pdf', 'content': null},
      });
      expect(v.type, 'url');
      expect(v.url, 'https://x/a.pdf');
      expect(v.content, '');
    });

    test('url checks', () {
      expect(isImageUrl('a/b.PNG'), isTrue);
      expect(isVideoUrl('a.mp4'), isTrue);
      expect(isPdfUrl('a.pdf'), isTrue);
      expect(isYouTubeUrl('https://youtu.be/abc'), isTrue);
      expect(youTubeId('https://www.youtube.com/watch?v=abc&t=1'), 'abc');
      expect(youTubeId('https://youtu.be/xyz?t=2'), 'xyz');
      expect(vimeoId('https://vimeo.com/12345'), '12345');
      expect(canEmbedUrl(''), isFalse);
      expect(canEmbedUrl('https://github.com/x'), isFalse);
      expect(canEmbedUrl('https://example.com'), isTrue);
      expect(pdfFrameUrl('u'), 'u#toolbar=0&navpanes=0&scrollbar=0');
    });
  });
}
