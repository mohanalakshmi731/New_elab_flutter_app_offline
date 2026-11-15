import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../courses/course_create_logic.dart' show instructorPageMeta, mapInstructors;

/// The `useUserStore` slice `batchlist.vue` maps: `instructors` and
/// `instructorPagination`.
class BatchListState {
  const BatchListState({this.instructors = const [], this.instructorPagination = PageMeta.empty});

  final List<Map<String, dynamic>> instructors;
  final PageMeta instructorPagination;

  BatchListState copyWith({List<Map<String, dynamic>>? instructors, PageMeta? instructorPagination}) => BatchListState(
    instructors: instructors ?? this.instructors,
    instructorPagination: instructorPagination ?? this.instructorPagination,
  );
}

/// Store actions used by `batchlist.vue` (`getAllInstructors`,
/// `addInstructor`), ported 1:1.
class BatchListController extends Notifier<BatchListState> {
  @override
  BatchListState build() => const BatchListState();

  /// `getAllInstructors(page?)`
  Future<void> getAllInstructors([int? page]) async {
    final currentPage = page ?? state.instructorPagination.currentPage;
    final res = await ref.read(instructorServiceProvider).getallInstructors(currentPage);
    state = state.copyWith(instructors: mapInstructors(res), instructorPagination: instructorPageMeta(res));
  }

  /// `addInstructor(payload)` — `POST /user`, then `POST /instructor` for the
  /// new user; the instructor response is appended to `instructors` as is.
  Future<void> addInstructor(Map<String, dynamic> payload) async {
    final service = ref.read(instructorServiceProvider);
    String? s(String key) => payload[key] == null ? null : '${payload[key]}';
    final res = await service.createUser(
      s('firstName') ?? '',
      s('lastName') ?? '',
      s('email') ?? '',
      payload['countryCode'],
      s('phone'),
      s('gender'),
      s('dob'),
      payload['photo'] is UploadFile ? payload['photo'] as UploadFile : null,
      s('password'),
      s('designation'),
      payload['enable_zoom'] == true,
    );

    final userId = dig(res, ['data', 'id']);
    if (!jsTruthy(userId)) return;

    final instructorRes = await service.createInstructor(
      userId as Object,
      s('joiningDate'),
      s('designation'),
      payload['enable_zoom'] == true,
      payload['is_labadmin'] == true,
    );
    state = state.copyWith(instructors: [...state.instructors, asMap(instructorRes) ?? const {}]);
  }
}

final batchListControllerProvider = NotifierProvider<BatchListController, BatchListState>(BatchListController.new);
