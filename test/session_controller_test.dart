import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/core/storage/secure_store.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/data/services/auth_service.dart';
import 'package:elab_app/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory replacement for the platform secure storage.
class FakeSecureStore extends SecureStore {
  final Map<String, Map<String, dynamic>> data = {};

  @override
  Future<Map<String, dynamic>?> readJson(String key) async => data[key];

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

class FakeAuthService extends AuthService {
  FakeAuthService()
      : super(ApiClient(tokenReader: () => null, onUnauthorized: () async {}));
  int logoutCalls = 0;

  @override
  Future<dynamic> logout() async {
    logoutCalls++;
    return {'ok': true};
  }
}

/// Shape of the `/auth/login` response for a student.
Map<String, dynamic> studentLogin() => {
      'token': 'tok-1',
      'token2': 'tok-2',
      'user': {
        'id': 7,
        'first_name': 'Asha',
        'last_name': 'Rao',
        'email': 'asha@example.com',
        'phone': '999',
      },
      'institutes': [
        {
          'id': 3,
          'is_default': false,
          'roles': [
            {'name': 'instructor'}
          ],
        },
        {
          'id': 5,
          'is_default': true,
          'is_math_zoro': 1,
          'expires_on': '2030-01-01',
          'institute_plan_id': '12',
          'roles': [
            {'name': 'student'}
          ],
          'student': {
            'id': 44,
            'institute_id': 5,
            'user_id': 7,
            'status': true,
            'exam_user_id': 'uuid-exam',
            'zsl_id': 900,
            'zsl_key': 'secret-key',
            'syllabus': 'STATE',
            'batches': [
              {
                'id': 1,
                'name': 'Old batch',
                'classes_id': 10,
                'pivot': {'status': false},
              },
              {
                'id': 2,
                'name': 'Active batch',
                'classes_id': 20,
                'exam_batch_id': 'uuid-batch',
                'pivot': {'status': true},
                'classes': {
                  'id': 20,
                  'name': 'Class 6',
                  'curricula_id': 4,
                  'institute_id': 5,
                  'courses': [
                    {
                      'id': 300,
                      'title': 'Maths',
                      'zsl_class_id': 61,
                      'zsl_subject_id': 71,
                      'exam_course_id': 'uuid-course',
                    }
                  ],
                },
              },
            ],
          },
        },
      ],
    };

void main() {
  late ProviderContainer container;
  late FakeSecureStore store;
  late FakeAuthService auth;

  setUp(() {
    store = FakeSecureStore();
    auth = FakeAuthService();
    container = ProviderContainer(overrides: [
      secureStoreProvider.overrideWithValue(store),
      authServiceProvider.overrideWithValue(auth),
    ]);
  });

  tearDown(() => container.dispose());

  test('setUserInfo picks the default institute and the active batch', () {
    container.read(sessionProvider.notifier).setUserInfo(studentLogin());
    final s = container.read(sessionProvider);

    expect(s.isLoggedIn, isTrue);
    expect(s.token, 'tok-2', reason: 'token2 wins over token, like the web');
    expect(s.role, Role.student);
    expect(s.instituteId, 5);
    expect(s.username, 'Asha Rao');
    expect(s.userInfo!.isMathZoro, isTrue);
    expect(s.userInfo!.studentId, 44);
    expect(s.userInfo!.zsl, 900);
    expect(s.userInfo!.classesId, 20);
    expect(s.userInfo!.zslClassId, 61);
    expect(s.userInfo!.institutePlanId, 12);
    expect(s.expiresOn, '2030-01-01');
    expect(s.batchId, 2);
    expect(s.batchName, 'Active batch');
    expect(s.classId, 20);
    expect(s.className, 'Class 6');

    final sld = s.studentLoginData!;
    expect(sld.zslKey, 'secret-key');
    expect(sld.batchId, 2);
    expect(sld.examBatchId, 'uuid-batch');
    expect(sld.courseId, 300);
    expect(sld.zslSubjectId, 71);
    expect(sld.examCourseId, 'uuid-course');
  });

  test('admin flag on the user overrides the institute role', () {
    container.read(sessionProvider.notifier).setUserInfo({
      'token': 't',
      'user': {'id': 1, 'isAdmin': true, 'username': 'root'},
      'institutes': <dynamic>[],
    });
    final s = container.read(sessionProvider);
    expect(s.role, Role.admin);
    expect(s.username, 'root');
    expect(s.studentLoginData, isNull);
  });

  test('session is persisted and can be restored', () async {
    container.read(sessionProvider.notifier).setUserInfo(studentLogin());
    await Future<void>.delayed(Duration.zero);
    final json = store.data['elab.session'];
    expect(json, isNotNull);
    final restored = SessionState.fromJson(json!);
    expect(restored.token, 'tok-2');
    expect(restored.studentLoginData?.zslKey, 'secret-key');
    expect(restored.batchDetails?.name, 'Active batch');
  });

  test('logout calls the API, clears the session and keeps the language', () async {
    final notifier = container.read(sessionProvider.notifier);
    notifier.setUserInfo(studentLogin());
    notifier.setLanguage(const AppLanguage(id: 2, code: 'te', name: 'TELUGU'));
    await notifier.logout();

    final s = container.read(sessionProvider);
    expect(auth.logoutCalls, 1);
    expect(s.isLoggedIn, isFalse);
    expect(s.userInfo, isNull);
    expect(s.language.code, 'te');
  });

  test('401 logout path skips the API call', () async {
    final notifier = container.read(sessionProvider.notifier);
    notifier.setUserInfo(studentLogin());
    await notifier.logout(callApi: false);
    expect(auth.logoutCalls, 0);
    expect(container.read(sessionProvider).isLoggedIn, isFalse);
  });
}
