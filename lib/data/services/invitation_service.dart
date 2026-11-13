import '../../core/network/api_client.dart';
import 'js_compat.dart';

/// Port of src/service/invitation.service.ts.
class InvitationService {
  InvitationService(this._api);
  final ApiClient _api;

  Future<dynamic> getInvitations() => _api.get('/invitation/invitations');

  Future<dynamic> getInvitationById(Object id) =>
      _api.get('/invitation/invitations/$id');

  Future<dynamic> searchUsers(String term, [int paginate = 1]) =>
      _api.get('/search/user', query: {'term': term, 'paginate': paginate});

  /// `name` is trimmed (omitted when absent); `content` defaults to `''`.
  Future<dynamic> resendInvitation(Object id, Map<String, dynamic> payload) {
    final name = payload['name'] as String?;
    final content = payload['content'];
    return _api.post('/invitation/invitations/$id/resend', data: {
      if (name != null) 'name': name.trim(),
      'content': jsTruthy(content) ? content : '',
    });
  }
}
