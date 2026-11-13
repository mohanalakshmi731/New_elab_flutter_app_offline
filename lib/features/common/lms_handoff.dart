import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';

/// Web store fields that one classes/courses screen writes and another reads
/// after navigating (e.g. the class list sets a selected class/course, the
/// course-create screen reads it). Keys are the web store's field names, so
/// `this.someField = x` in one Vue page and `mapState(['someField'])` in
/// another become `set('someField', x)` / `get('someField')`.
///
/// Fields that are part of the persisted session (`userInfo`, `classDetails`,
/// `batchDetails`, `studentLoginData`, `language`, …) live in `sessionProvider`
/// instead — use the SessionController setters for those.
class LmsHandoff extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    // The web resets the store on logout; don't carry one user's selections
    // (persisted class/chapter ids, selected course, …) over to the next.
    ref.listen<bool>(sessionProvider.select((s) => s.isLoggedIn), (wasLoggedIn, loggedIn) {
      if (wasLoggedIn == true && !loggedIn) state = const {};
    });
    return const {};
  }

  dynamic get(String key) => state[key];

  void set(String key, dynamic value) => state = {...state, key: value};

  void remove(String key) {
    if (!state.containsKey(key)) return;
    state = {...state}..remove(key);
  }
}

final lmsHandoffProvider =
    NotifierProvider<LmsHandoff, Map<String, dynamic>>(LmsHandoff.new);
