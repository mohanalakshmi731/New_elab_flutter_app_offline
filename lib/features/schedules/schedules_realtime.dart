part of 'schedules_page.dart';

/// Laravel Echo presence channel `schedule.{institute}.{schedule}` — online
/// users (`here` / `joining` / `leaving`), chat `.message` events and the
/// `user.join` / `user.left` broadcasts — plus the chat history and sending.
///
/// [EchoClient] has no presence callbacks, so `here` / `joining` / `leaving`
/// are rebuilt from the raw `pusher:subscription_succeeded`,
/// `pusher:member_added` and `pusher:member_removed` events (the member list
/// is cached per channel so `leaving` gets the member's info, like Echo).
extension _Realtime on _SchedulesPageState {
  /// `joinPresenceChannel(instituteId, scheduleId)`
  void _joinPresenceChannel(Object? instituteId, Object? scheduleId) {
    final channelName = 'schedule.${schString(instituteId)}.${schString(scheduleId)}';
    if (_joinedChannels.contains(channelName)) return;

    // Only reached when the active schedule differs — fetchBasicInfo() and
    // handleStart() set it beforehand, so earlier channels stay joined (web).
    if (jsTruthy(_activeScheduleId) && schNumber(_activeScheduleId) != schNumber(scheduleId)) {
      try {
        _leavePresenceChannel(instituteId, _activeScheduleId);
      } catch (e) {
        debugPrint('leavePresenceChannel failed during join $e');
      }
    }

    final EchoChannel chan;
    try {
      chan = _echo.join(channelName);
    } catch (e) {
      debugPrint('Echo not available: $e');
      return;
    }
    final members = _presenceMembers[channelName] = <String, SJson>{};
    final subs = <StreamSubscription<dynamic>>[
      // .here(users)
      chan.listen('.pusher:subscription_succeeded', (data) {
        members
          ..clear()
          ..addAll(presenceMembers(data));
        _set(() => _onlineUsers = [...members.values]);
      }),
      // .joining(user)
      chan.listen('.pusher:member_added', (data) {
        final id = presenceUserId(data);
        final user = presenceJoining(data);
        if (id == null || user == null) return;
        members[id] = user;
        if (!_onlineUsers.any((u) => u['id'] == user['id'])) {
          _set(() => _onlineUsers = [..._onlineUsers, user]);
        }
      }),
      // .leaving(user)
      chan.listen('.pusher:member_removed', (data) {
        final id = presenceUserId(data);
        final user = id == null ? null : members.remove(id);
        if (user == null) return;
        _set(() => _onlineUsers = [for (final u in _onlineUsers) if (u['id'] != user['id']) u]);
      }),
      chan.listen('.message', _handleIncomingMessage),
      chan.listen('.user.join', _addJoinedId),
      chan.listen('.user.left', _removeJoinedId),
      // Also the non-dotted (namespaced) names, like the web.
      chan.listen('user.join', _addJoinedId),
      chan.listen('user.left', _removeJoinedId),
    ];
    _channelSubs[channelName] = subs;
    _joinedChannels.add(channelName);
    _set(() {
      _publicChannel = channelName;
      _activeScheduleId = schNumber(scheduleId);
      _chatEnabled = true;
    });
  }

  /// `leavePresenceChannel(instituteId, scheduleId)`
  void _leavePresenceChannel(Object? instituteId, Object? scheduleId) {
    final channelName = 'schedule.${schString(instituteId)}.${schString(scheduleId)}';
    if (!_joinedChannels.contains(channelName)) return;
    try {
      for (final s in _channelSubs.remove(channelName) ?? const <StreamSubscription<dynamic>>[]) {
        s.cancel();
      }
      _echo.leave(channelName);
    } catch (e) {
      debugPrint('leavePresenceChannel error $e');
    } finally {
      _presenceMembers.remove(channelName);
      _joinedChannels.remove(channelName);
      _set(() {
        if (_activeScheduleId != null && schNumber(_activeScheduleId) == schNumber(scheduleId)) {
          _chatEnabled = false;
          _chatMessages = [];
          _activeScheduleId = null;
        }
        if (_publicChannel == channelName) _publicChannel = null;
      });
    }
  }

  /// `handleIncomingMessage(event)` — appends a broadcast chat message once.
  void _handleIncomingMessage(SJson? event) {
    final msg = chatFromEvent(event, _userInfo?.id);
    if (msg == null) return;
    if (_chatMessages.any((m) => schString(m.id) == schString(msg.id))) return;
    _set(() => _chatMessages = [..._chatMessages, msg]);
  }

  void _addJoinedId(SJson? raw) {
    final sid = joinedIdOf(raw);
    if (sid == null || _joinedStudentIds.contains(sid)) return;
    _set(() => _joinedStudentIds = [..._joinedStudentIds, sid]);
  }

  void _removeJoinedId(SJson? raw) {
    final sid = joinedIdOf(raw);
    if (sid == null || !_joinedStudentIds.contains(sid)) return;
    _set(() => _joinedStudentIds = [for (final s in _joinedStudentIds) if (s != sid) s]);
  }

  /// `loadChatMessages(scheduleId)`
  Future<void> _loadChatMessages(String scheduleId) async {
    try {
      final messages = await _ctrl.getScheduleMessages(scheduleId);
      if (messages is List) {
        final myId = _userInfo?.id;
        _set(() => _chatMessages = [for (final m in schMaps(messages)) chatFromHistory(m, myId)]);
      }
    } catch (e) {
      debugPrint('loadChatMessages failed: $e');
    }
  }

  /// `sendMessage()` — the message comes back through the `.message` event.
  Future<void> _sendMessage() async {
    final message = _chatInput.text.trim();
    if (message.isEmpty) return;
    try {
      await _ctrl.ScheduleMessages(schString(_activeScheduleId), message);
      _chatInput.clear();
      _set(() {});
    } catch (e) {
      debugPrint('Send message failed: $e');
    }
  }
}
