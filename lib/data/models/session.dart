import '../../core/utils/json.dart';

/// Roles — port of `src/types/enums.ts`.
class Role {
  Role._();
  static const admin = 'admin';
  static const institute = 'institute';
  static const instructor = 'instructor';
  static const student = 'student';
}

/// `userInfo` from the Pinia store. JSON keys are kept identical to the web
/// app (snake_case) so ported code reads the same fields.
class UserInfo {
  const UserInfo({
    required this.id,
    required this.username,
    required this.token,
    this.role,
    this.instituteId,
    this.fullName,
    this.email,
    this.studentId,
    this.examUserId,
    this.institutePlanId,
    this.zsl,
    this.classesId,
    this.zslClassId,
    this.isMathZoro = false,
    this.phone,
    this.mathzoroClassId,
  });

  final int? id;
  final String username;
  final String token;
  final String? role;
  final int? instituteId;
  final String? fullName;
  final String? email;
  final int? studentId;
  final String? examUserId;
  final int? institutePlanId;

  /// ZSL sub-user id (`userInfo.zsl`).
  final dynamic zsl;
  final int? classesId;
  final int? zslClassId;
  final bool isMathZoro;
  final String? phone;
  final int? mathzoroClassId;

  UserInfo copyWith({int? mathzoroClassId, int? zslClassId, int? classesId}) =>
      UserInfo(
        id: id,
        username: username,
        token: token,
        role: role,
        instituteId: instituteId,
        fullName: fullName,
        email: email,
        studentId: studentId,
        examUserId: examUserId,
        institutePlanId: institutePlanId,
        zsl: zsl,
        classesId: classesId ?? this.classesId,
        zslClassId: zslClassId ?? this.zslClassId,
        isMathZoro: isMathZoro,
        phone: phone,
        mathzoroClassId: mathzoroClassId ?? this.mathzoroClassId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'token': token,
        'role': role,
        'institute_id': instituteId,
        'full_name': fullName,
        'email': email,
        'student_id': studentId,
        'exam_user_id': examUserId,
        'institute_plan_id': institutePlanId,
        'zsl': zsl,
        'classes_id': classesId,
        'zsl_class_id': zslClassId,
        'is_math_zoro': isMathZoro,
        'phone': phone,
        'mathzoroclassid': mathzoroClassId,
      };

  factory UserInfo.fromJson(Map<String, dynamic> j) => UserInfo(
        id: asInt(j['id']),
        username: asString(j['username']) ?? '',
        token: asString(j['token']) ?? '',
        role: asString(j['role']),
        instituteId: asInt(j['institute_id']),
        fullName: asString(j['full_name']),
        email: asString(j['email']),
        studentId: asInt(j['student_id']),
        examUserId: asString(j['exam_user_id']),
        institutePlanId: asInt(j['institute_plan_id']),
        zsl: j['zsl'],
        classesId: asInt(j['classes_id']),
        zslClassId: asInt(j['zsl_class_id']),
        isMathZoro: asBool(j['is_math_zoro']),
        phone: asString(j['phone']),
        mathzoroClassId: asInt(j['mathzoroclassid']),
      );
}

/// `studentLoginData` — full student snapshot saved at login (students only).
class StudentLoginData {
  const StudentLoginData(this.raw);

  /// Kept as a map with the exact web keys (`zsl_key`, `batch_id`, ...).
  final Map<String, dynamic> raw;

  dynamic operator [](String key) => raw[key];

  int? get id => asInt(raw['id']);
  int? get instituteId => asInt(raw['institute_id']);
  int? get userId => asInt(raw['user_id']);
  String? get examUserId => asString(raw['exam_user_id']);
  int? get zslId => asInt(raw['zsl_id']);
  String? get zslKey => asString(raw['zsl_key']);
  String? get syllabus => asString(raw['syllabus']);
  int? get stateId => asInt(raw['state_id']);
  int? get batchId => asInt(raw['batch_id']);
  String? get batchName => asString(raw['batch_name']);
  String? get examBatchId => asString(raw['exam_batch_id']);
  int? get classesId => asInt(raw['classes_id']);
  String? get className => asString(raw['class_name']);
  int? get curriculaId => asInt(raw['curricula_id']);
  int? get courseId => asInt(raw['course_id']);
  String? get courseTitle => asString(raw['course_title']);
  int? get zslClassId => asInt(raw['zsl_class_id']);
  int? get zslSubjectId => asInt(raw['zsl_subject_id']);
  String? get examCourseId => asString(raw['exam_course_id']);
}

/// `{ id, name }` pairs used for batchDetails / classDetails.
class IdName {
  const IdName(this.id, this.name, {this.extra = const {}});
  final int? id;
  final String name;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, ...extra};

  static IdName? fromJson(dynamic j) {
    final m = asMap(j);
    if (m == null) return null;
    final extra = Map<String, dynamic>.from(m)
      ..remove('id')
      ..remove('name');
    return IdName(asInt(m['id']), asString(m['name']) ?? '', extra: extra);
  }
}

/// Selected content language (`store.language`).
class AppLanguage {
  const AppLanguage({required this.id, required this.code, required this.name});
  final int id;
  final String code;
  final String name;

  static const english = AppLanguage(id: 1, code: 'en', name: 'ENGLISH');

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'name': name};

  factory AppLanguage.fromJson(Map<String, dynamic> j) => AppLanguage(
        id: asInt(j['id']) ?? 1,
        code: asString(j['code']) ?? 'en',
        name: asString(j['name']) ?? 'ENGLISH',
      );
}

/// Everything the web app persisted for the logged-in session.
class SessionState {
  const SessionState({
    this.userInfo,
    this.studentLoginData,
    this.expiresOn,
    this.instructorId,
    this.batchDetails,
    this.classDetails,
    this.rawStudentBatches = const [],
    this.language = AppLanguage.english,
  });

  final UserInfo? userInfo;
  final StudentLoginData? studentLoginData;
  final String? expiresOn;
  final int? instructorId;
  final IdName? batchDetails;
  final IdName? classDetails;
  final List<dynamic> rawStudentBatches;
  final AppLanguage language;

  // ── getters (Pinia `getters`) ──
  bool get isLoggedIn => (userInfo?.token ?? '').isNotEmpty;
  String get token => userInfo?.token ?? '';
  String get username => userInfo?.username ?? '';
  int? get userId => userInfo?.id;
  String get role => userInfo?.role ?? '';
  int? get instituteId => userInfo?.instituteId;
  int? get classId => classDetails?.id;
  String get className => classDetails?.name ?? '';
  int? get batchId => batchDetails?.id;
  String get batchName => batchDetails?.name ?? '';

  static const _unset = Object();

  SessionState copyWith({
    Object? userInfo = _unset,
    Object? studentLoginData = _unset,
    Object? expiresOn = _unset,
    Object? instructorId = _unset,
    Object? batchDetails = _unset,
    Object? classDetails = _unset,
    List<dynamic>? rawStudentBatches,
    AppLanguage? language,
  }) =>
      SessionState(
        userInfo: identical(userInfo, _unset) ? this.userInfo : userInfo as UserInfo?,
        studentLoginData: identical(studentLoginData, _unset)
            ? this.studentLoginData
            : studentLoginData as StudentLoginData?,
        expiresOn: identical(expiresOn, _unset) ? this.expiresOn : expiresOn as String?,
        instructorId:
            identical(instructorId, _unset) ? this.instructorId : instructorId as int?,
        batchDetails:
            identical(batchDetails, _unset) ? this.batchDetails : batchDetails as IdName?,
        classDetails:
            identical(classDetails, _unset) ? this.classDetails : classDetails as IdName?,
        rawStudentBatches: rawStudentBatches ?? this.rawStudentBatches,
        language: language ?? this.language,
      );

  Map<String, dynamic> toJson() => {
        'userInfo': userInfo?.toJson(),
        'studentLoginData': studentLoginData?.raw,
        'expires_on': expiresOn,
        'instructor_id': instructorId,
        'batchDetails': batchDetails?.toJson(),
        'classDetails': classDetails?.toJson(),
        'rawStudentBatches': rawStudentBatches,
        'language': language.toJson(),
      };

  factory SessionState.fromJson(Map<String, dynamic> j) {
    final ui = asMap(j['userInfo']);
    final sld = asMap(j['studentLoginData']);
    final lang = asMap(j['language']);
    return SessionState(
      userInfo: ui == null ? null : UserInfo.fromJson(ui),
      studentLoginData: sld == null ? null : StudentLoginData(sld),
      expiresOn: asString(j['expires_on']),
      instructorId: asInt(j['instructor_id']),
      batchDetails: IdName.fromJson(j['batchDetails']),
      classDetails: IdName.fromJson(j['classDetails']),
      rawStudentBatches: asList(j['rawStudentBatches']),
      language: lang == null ? AppLanguage.english : AppLanguage.fromJson(lang),
    );
  }
}
