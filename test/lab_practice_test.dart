import 'package:dio/dio.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/features/lab_admin/lab_activity_host.dart';
import 'package:elab_app/state/lab_practice.dart';
import 'package:elab_app/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = UserInfo(id: 7, username: 'Lab', token: 'session',
    role: Role.instructor, instituteId: 1, isLabAdmin: true);

  test('lab admin flag survives persistence and class changes', () {
    final restored = UserInfo.fromJson(user.copyWith(classesId: 8).toJson());
    expect(restored.isLabAdmin, isTrue);
    expect(restored.role, Role.instructor);
    expect(SessionState(userInfo: restored).isLabAdmin, isTrue);
  });

  test('practice replaces every recording identity and requires a student', () {
    const waiting = LabPractice(token: 'session', practice: true);
    expect(() => waiting.apply({}), throwsStateError);
    const practice = LabPractice(token: 'session', practice: true,
      classId: 2, batchId: 3, student: {'id': 4, 'zsl_id': 40, 'zsl_class_id': 20});
    final payload = practice.apply({'instructor_id': 7, 'student_id': 99,
      'sub_user_id': 70, 'classes_id': 90, 'activity_id': 10});
    expect(payload['instructor_id'], isNull);
    expect(payload['student_id'], 4);
    expect(payload['sub_user_id'], 40);
    expect(payload['classes_id'], 20);
    expect(payload['lab_class_id'], 2);
    expect(payload['lab_batch_id'], 3);
    expect(payload['activity_id'], 10);
    expect(const LabPractice(token: 'session').apply({'instructor_id': 7}), {'instructor_id': 7});
  });

  test('all recording APIs use the selected student and ignore stale sessions', () async {
    final container = ProviderContainer(overrides: [
      initialSessionProvider.overrideWithValue(const SessionState(userInfo: user)),
    ]);
    addTearDown(container.dispose);
    final client = container.read(apiClientProvider);
    final requests = <RequestOptions>[];
    client.dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {}));
    }));
    container.read(labPracticeProvider.notifier).set(const LabPractice(
      token: 'session', practice: true, classId: 2, batchId: 3,
      student: {'id': 4, 'zsl_id': 40, 'zsl_class_id': 20}));
    for (final path in labIdentityPaths) {
      await client.post(path, data: {'instructor_id': 7, 'sub_user_id': 70});
      expect(requests.last.data['student_id'], 4, reason: path);
      expect(requests.last.data['instructor_id'], isNull, reason: path);
      expect(requests.last.data['sub_user_id'], 40, reason: path);
    }
    await client.post('/unrelated', data: {'instructor_id': 7});
    expect(requests.last.data, {'instructor_id': 7});
    container.read(labPracticeProvider.notifier).set(const LabPractice(token: 'old-session', practice: true));
    await client.post('/zsl/attempt-quiz', data: {'sub_user_id': 70});
    expect(requests.last.data, {'sub_user_id': 70});
  });

  testWidgets('mode gates activity, cascades selections, records student usage, and clears on exit', (tester) async {
    final container = ProviderContainer(overrides: [
      initialSessionProvider.overrideWithValue(const SessionState(userInfo: user)),
    ]);
    addTearDown(container.dispose);
    final requests = <RequestOptions>[];
    container.read(apiClientProvider).dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      dynamic response = {};
      if (options.path == '/lab-admin/practice-options') {
        response = options.queryParameters['batch_id'] != null
          ? {'students': [{'id': 4, 'name': 'Student One', 'zsl_id': 40, 'zsl_class_id': 20}, {'id': 5, 'name': 'Student Two', 'zsl_id': 50, 'zsl_class_id': 20}]}
          : options.queryParameters['class_id'] != null
            ? {'batches': [{'id': 3, 'name': 'Batch A'}]}
            : {'classes': [{'id': 2, 'name': 'Class A'}]};
      }
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: response));
    }));
    await tester.pumpWidget(UncontrolledProviderScope(container: container,
      child: MaterialApp(home: Scaffold(body: LabActivityHost(builder: (key) => Text('Activity player', key: key))))));
    expect(find.text('Activity player'), findsOneWidget);
    Future<void> choose(String current, String next) async {
      await tester.tap(find.text(current).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(next).last);
      await tester.pumpAndSettle();
    }
    await choose('Presentation mode', 'Practice mode');
    expect(find.text('Activity player'), findsNothing);
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class A').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batch A').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student One').last);
    await tester.pumpAndSettle();
    expect(find.text('Activity player'), findsOneWidget);
    final firstKey = tester.widget<Text>(find.text('Activity player')).key;
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    final usage = requests.lastWhere((r) => r.path == '/usage-tracking/record');
    expect(usage.data['student_id'], 4);
    expect(usage.data['instructor_id'], isNull);
    await choose('Student One', 'Student Two');
    expect(tester.widget<Text>(find.text('Activity player')).key, isNot(firstKey));
    expect(container.read(labPracticeProvider)?.student?['id'], 5);
    await choose('Practice mode', 'Presentation mode');
    expect(container.read(labPracticeProvider)?.practice, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(container.read(labPracticeProvider), isNull);
  });
}
