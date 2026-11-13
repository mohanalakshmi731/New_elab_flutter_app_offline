import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/services.dart';
import '../../core/utils/json.dart';

/// Shared reference data the web keeps in the user store (`countries`,
/// `states`, `dailCodes`). Loaded once and cached for the session.

/// `loadCountries()`: `res.data.data || res.data`.
final countriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final body = await ref.read(instituteServiceProvider).fetchCountries();
  return _maps(unwrapList(body));
});

/// `loadStates()`: the array itself or `res.data`.
final statesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final body = await ref.read(userServiceProvider).getStates();
  return _maps(unwrapList(body));
});

/// `loadDialCodes()` / `loadUserDialCodes()` / `loadDialCodesForInstitute()`:
/// items look like `{code: '+91', …}`. The web pre-selects the first entry's
/// `code` in the form — do that in the screen.
final dialCodesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final body = await ref.read(userServiceProvider).getDailCodes();
  return _maps(unwrapList(body));
});

List<Map<String, dynamic>> _maps(List<dynamic> list) =>
    [for (final e in list) ?asMap(e)];
