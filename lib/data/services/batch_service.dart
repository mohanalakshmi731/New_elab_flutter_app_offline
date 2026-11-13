import '../../core/network/api_client.dart';

/// Port of src/service/batch.service.ts.
class BatchService {
  BatchService(this._api);
  final ApiClient _api;

  /// Note: the web sends `class_id` as `classes_id`.
  Future<dynamic> createBatch(Map<String, dynamic> payload) =>
      _api.post('/batch', data: {
        'institute_id': payload['institute_id'],
        'classes_id': payload['class_id'],
        'name': payload['name'],
      });

  Future<dynamic> getBatches(Object classId, Object instituteId) =>
      _api.get('/batch',
          query: {'class_id': classId, 'institute_id': instituteId});

  Future<dynamic> getBatchById(Object batchId, Object instituteId) =>
      _api.get('/batch/$batchId', query: {'institute_id': instituteId});

  Future<dynamic> updateBatch(Object batchId, Map<String, dynamic> payload) =>
      _api.put('/batch/$batchId', data: payload);

  Future<dynamic> deleteBatch(Object batchId, Object instituteId) =>
      _api.delete('/batch/$batchId', query: {'institute_id': instituteId});

  Future<dynamic> searchBatch(Object instituteId, String term, Object classId) =>
      _api.get('/search/batch', query: {
        'institute_id': instituteId,
        'term': term,
        'class_id': classId,
      });
}
