import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/network/content_cache.dart';

/// Port of src/service/activitytracking.ts.
class ActivityTrackingService {
  ActivityTrackingService(this._api, {ContentCache? cache}) : _cache = cache;
  final ApiClient _api;
  final ContentCache? _cache;

  /// Errors are swallowed and nothing is returned, like the web.
  Future<dynamic> trackActivity(Object trackingId) async {
    try {
      await _api.post('/tracking/activity', data: {'tracking_id': trackingId});
    } catch (e) {
      debugPrint('Error tracking activity: $e');
    }
    return null;
  }

  Future<dynamic> getInstitutionTracking(Object instituteId,
          [Object? classId]) =>
      _api.get('/tracking/activity/get/institution', query: {
        'institute_id': instituteId,
        'class_id': classId,
      });

  Future<dynamic> getIndividualTracking(Object instituteId) =>
      _api.get('/tracking/activity/get/individual',
          query: {'institute_id': instituteId});

  /// The language list is the same for everyone and rarely changes: cached
  /// for a day (see [ContentCache]).
  Future<dynamic> getZslLanguages() {
    Future<dynamic> load({required bool background}) =>
        _api.get('/zsl/languages', silent: background);
    final cache = _cache;
    if (cache == null) return load(background: false);
    return cache.fetch('zsl/languages', load, ttl: const Duration(hours: 24));
  }
}
