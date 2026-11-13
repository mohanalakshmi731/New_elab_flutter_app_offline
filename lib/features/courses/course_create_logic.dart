import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';

/// Pure helpers shared by the course-create ports (`coursecreate.vue` and the
/// "New Course" dialog of `teachercoursepage.vue`) and the instructor lists.
/// They mirror `useUserStore` actions from `src/store/Userstore.ts`.

/// `resetCourseForm()` — the empty `courseForm` (status `draft`).
Map<String, dynamic> emptyCourseForm() => {
  'institute_id': '',
  'curriculum_id': '',
  'instructor_id': '',
  'title': '',
  'description': '',
  'short_name': '',
  'course_code': '',
  'allclass': '',
  'subject_id': '',
  'image': null,
  'status': 'draft',
  'is_math_zoro': false,
  'zone': '',
};

/// The `courseForm` `createCourse()` leaves behind after a successful create
/// (status `published`, unlike [emptyCourseForm]).
Map<String, dynamic> createdCourseForm() => {...emptyCourseForm(), 'status': 'published'};

/// The object `createCourse(classid)` hands to `courseService.createCourse`.
/// [form] is `courseForm` (its `institute_id` is overwritten with
/// [instituteId] first, like the action does).
Map<String, dynamic> buildCreateCourseData(Map<String, dynamic> form, {required String instituteId, String? classId}) {
  final instructorId = form['instructor_id'] == null ? '' : '${form['instructor_id']}';
  return {
    'institute_id': instituteId,
    'curriculum_id': form['curriculum_id'],
    'instructor_id': instructorId,
    'class_id': classId,
    'zsl_class_id': form['allclass'],
    'zsl_subject_id': form['subject_id'],
    'title': form['title'],
    'description': _or(form['description'], ''),
    'short_name': form['short_name'],
    'course_code': form['course_code'],
    'image': form['image'],
    'status': form['status'],
    'is_math_zoro': _or(form['is_math_zoro'], false),
    'zone': _or(form['zone'], ''),
  };
}

/// `response?.message === 'Course created successfully'`
bool isCourseCreated(dynamic response) => asMap(response)?['message'] == 'Course created successfully';

/// `fetchCurriculums()` mapping: `{ id, institute_id, name, status (lower-cased,
/// default 'draft'), created_at }`.
List<Map<String, dynamic>> mapCurriculums(dynamic data) => [
  for (final raw in asList(data))
    if (asMap(raw) case final item?)
      {
        'id': item['id'],
        'institute_id': item['institute_id'],
        'name': item['name'],
        'status': _truthy(item['status']) ? '${item['status']}'.toLowerCase() : 'draft',
        'created_at': item['created_at'],
      },
];

/// `curriculums.filter((c) => c.status === 'published')`
List<Map<String, dynamic>> publishedCurriculums(List<Map<String, dynamic>> all) => [
  for (final c in all)
    if (c['status'] == 'published') c,
];

/// `getAllInstructors()` mapping: `(res.data || []).map(inst => ({ ...inst,
/// user: inst.user || { first_name: '', … } }))`.
List<Map<String, dynamic>> mapInstructors(dynamic res) {
  final data = asMap(res)?['data'];
  return [
    for (final raw in asList(data))
      if (asMap(raw) case final inst?)
        {
          ...inst,
          'user': _truthy(inst['user'])
              ? inst['user']
              : const {'first_name': '', 'last_name': '', 'email': '', 'phone': '', 'country_code': ''},
        },
  ];
}

/// `instructorPagination` after `getAllInstructors()`.
PageMeta instructorPageMeta(dynamic res) {
  final m = asMap(res) ?? const {};
  return PageMeta(
    currentPage: asInt(m['current_page']) ?? 1,
    lastPage: asInt(m['last_page']) ?? 1,
    total: asInt(m['total']) ?? 0,
    perPage: asInt(m['per_page']) ?? 10,
  );
}

/// `` `${inst.user?.first_name || ''} ${inst.user?.last_name || ''}`.trim() ``
String instructorOptionLabel(Map<String, dynamic> inst) {
  final user = asMap(inst['user']);
  return '${_str(user?['first_name'])} ${_str(user?['last_name'])}'.trim();
}

/// `loadAllClasses()` / `getAllSubjects()`: `response.data || response || []`.
List<Map<String, dynamic>> dataOrSelfList(dynamic response) {
  final data = asMap(response)?['data'];
  final picked = _truthy(data) ? data : (_truthy(response) ? response : const []);
  return [for (final e in asList(picked)) ?asMap(e)];
}

/// `onSubmit()` guard of `coursecreate.vue`: every starred field is filled.
bool hasRequiredCourseFields(Map<String, dynamic> form, Object? selectedCurriculumId) =>
    _truthy(form['title']) &&
    _truthy(form['short_name']) &&
    _truthy(form['course_code']) &&
    _truthy(selectedCurriculumId) &&
    _truthy(form['instructor_id']);

String _str(Object? v) => _truthy(v) ? '$v' : '';

Object? _or(Object? v, Object? fallback) => _truthy(v) ? v : fallback;

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
