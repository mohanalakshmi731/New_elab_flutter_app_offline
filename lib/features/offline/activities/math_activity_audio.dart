import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound effects for the Math Zone activities that share this helper.
enum MathSound {
  click('audio/math/click.mp3'),
  success('audio/math/success.mp3'),
  error('audio/math/error.mp3'),
  start('audio/math/shutter.mp3');

  const MathSound(this.asset);

  final String asset;
}

/// When set, sounds are recorded here instead of played, so tests can run
/// without the audio plugin.
@visibleForTesting
List<MathSound>? mathSoundLog;

// One player per sound, so a player never has to switch its source.
final Map<MathSound, AudioPlayer> _players = {};

MathSound? _pendingSound;

void playMathClick() => _request(MathSound.click);

void playMathSuccess() => _request(MathSound.success);

void playMathError() => _request(MathSound.error);

void playMathStart() => _request(MathSound.start);

/// Keeps one sound per tap. A single tap often makes two feedback calls, such
/// as a click and then a success, and the more meaningful one should be heard.
void _request(MathSound sound) {
  if (_pendingSound == null) {
    _pendingSound = sound;
    scheduleMicrotask(_playPendingSound);
  } else if (sound != MathSound.click) {
    _pendingSound = sound;
  }
}

void _playPendingSound() {
  final sound = _pendingSound!;
  _pendingSound = null;

  final log = mathSoundLog;
  if (log != null) {
    log.add(sound);
  } else {
    _play(sound);
  }
}

Future<void> _play(MathSound sound) async {
  final player = _players[sound] ??= AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  try {
    await player.stop();
    await player.play(AssetSource(sound.asset));
  } catch (error) {
    debugPrint('Audio play error: $error');
  }
}
