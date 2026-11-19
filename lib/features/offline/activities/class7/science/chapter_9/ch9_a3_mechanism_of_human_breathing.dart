// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 9 • Activity 3
/// Mechanism of Human Breathing.
///
/// Native Flutter lab built from the activity spec
/// `Class7-Biology-Chapter9-003-Mechanism_of_Human_Breathing.md` (the HTML
/// `Cl7S-Ch09-A2-Mechanism_of_Human_Breathing.html` only embedded an
/// external 3D viewer).
/// Scenario 1 builds the Activity 9.2 bottle lung model and pulls its rubber
/// "diaphragm" to inflate the balloon "lungs"; scenario 2 animates the rib
/// cage, diaphragm, lungs and a beating heart with a hold-to-inhale button.
class Ch9A3MechanismOfHumanBreathingPage extends StatefulWidget {
  const Ch9A3MechanismOfHumanBreathingPage({super.key});

  @override
  State<Ch9A3MechanismOfHumanBreathingPage> createState() => _Ch9A3MechanismOfHumanBreathingPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, drop 2364, pickup 2356, switchTap 2585,
/// magic 871, whoosh 1492.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer.
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / success popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// A part snapping into place (balloon, Y-tube, rubber sheet).
  drop('drop.mp3'),

  /// A part picked up from the workbench.
  pickup('pickup.mp3'),

  /// "Diaphragm Only" / "Rib Cage Only" switches.
  switchTap('switch.mp3'),

  /// Model finished / observation popups.
  magic('magic.mp3'),

  /// Air rushing in or out.
  whoosh('whoosh.mp3');

  const _Sound(this.file);
  final String file;

  @override
  void play() => _Audio.play(this);
}

/// Fire-and-forget player for this lab's tones. A small pool lets tones
/// overlap; it is created on the first tone and freed when the lab closes.
abstract final class _Audio {
  static const int _poolSize = 4;
  static final List<AudioPlayer> _players = [];
  static int _next = 0;

  /// Plays [sound] without blocking. Silent under `flutter test`, which has
  /// no audio plugin. Errors (missing plugin, unsupported platform) are
  /// swallowed so audio never breaks the lab.
  static void play(_Sound sound, {double volume = 0.6}) {
    if (WidgetsBinding.instance is! WidgetsFlutterBinding) return;
    unawaited(_play(sound, volume));
  }

  static Future<void> _play(_Sound sound, double volume) async {
    try {
      if (_players.isEmpty) await _createPlayers();
      final player = _players[_next];
      _next = (_next + 1) % _players.length;
      await player.stop();
      await player.play(
        AssetSource('audio/class7/${sound.file}'),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Audio: could not play ${sound.name}: $e');
    }
  }

  static Future<void> _createPlayers() async {
    for (var i = 0; i < _poolSize; i++) {
      _players.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
    }
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
    } catch (_) {
      // Not supported on every platform; tones still play.
    }
  }

  /// Frees the players; called by the controller when the lab closes.
  static void release() {
    for (final player in _players) {
      unawaited(player.dispose());
    }
    _players.clear();
    _next = 0;
  }
}

// ===================================================================== THEME

/// Brand and Tailwind colours used by this lab.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color latex = Color(0xFFF2C46D);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}

/// This lab's light and dark palettes (the standard ZSL lab theme):
/// sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static LabPalette of(bool isDark) => isDark ? dark : light;
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 24,
);

/// This lab's tones, palettes and font, handed to the shared shell.
const _style = LabStyle(
  click: _Sound.click,
  toggle: _Sound.toggle,
  correct: _Sound.correct,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.scenario,
  curtain: _Sound.curtain,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// ============================================================ STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Mechanism of Human Breathing',
    'app_subtitle': 'Class 7 • Life Processes in Animals',
    'scen_1_opt': 'Scenario 1: The Bottle Lung Model',
    'scen_2_opt': 'Scenario 2: The Human Breathing Mechanism',
    'sci_conclusion': 'Success!',
    'btn_continue': 'Continue',
    'objective_complete': 'Objective Complete! Keep exploring the model.',
    'conclusion_1':
        'This model shows that pulling the diaphragm (rubber sheet) down increases the space inside the chest cavity (bottle), so air rushes in and the lungs (balloons) inflate – this is inhalation. Releasing it makes the space smaller and pushes the air out – this is exhalation.',
    'conclusion_2':
        'Breathing is a coordinated effort of the diaphragm and the rib cage. During inhalation the diaphragm moves down and the ribs move up and out, increasing the chest volume and drawing air in. During exhalation the diaphragm moves up and the ribs move down and in, decreasing the chest volume and forcing air out.',
    // Scene labels: bottle model.
    'lbl_bottle': 'Plastic bottle',
    'lbl_ytube': 'Y-shaped tube',
    'lbl_balloon': 'Balloon',
    'lbl_balloons': 'Deflated balloons',
    'lbl_balloons_in': 'Balloons',
    'lbl_sheet': 'Rubber sheet',
    'lbl_bottle_a': 'Bottle = Chest cavity',
    'lbl_ytube_a': 'Y-tube = Windpipe',
    'lbl_balloons_a': 'Balloons = Lungs',
    'lbl_sheet_a': 'Rubber sheet = Diaphragm',
    'insert_here': 'Insert from below',
    'stretch_here': 'Stretch over the base',
    'pull_down': 'Pull down',
    'release': 'Release',
    'air_in': 'Air in',
    'air_out': 'Air out',
    // Scene labels: human chest.
    'lbl_trachea': 'Windpipe (trachea)',
    'lbl_bronchi': 'Bronchi',
    'lbl_lungs': 'Lungs',
    'lbl_heart': 'Heart',
    'lbl_ribs': 'Rib cage',
    'lbl_diaphragm': 'Diaphragm',
    'held_still': 'Held still',
    'ribs_up': 'Ribs: up & out',
    'ribs_down': 'Ribs: down & in',
    'dia_down': 'Contracts, moves down',
    'dia_up': 'Relaxes, moves up',
    'legend_in': 'Air breathed in',
    'legend_out': 'Air breathed out',
    'trace_title': 'Lung volume',
    'trace_time': 'time',
    // Readout cards.
    'meter_title': 'Model Meter',
    'space_bottle': 'Space inside bottle',
    'pressure_bottle': 'Air pressure inside bottle',
    'balloon_size': 'Balloon size',
    'controls_title': 'Breathing Controls',
    'btn_inhale': 'INHALE',
    'hold_hint': 'Press & hold',
    'release_hint': 'Release to exhale',
    'tog_diaphragm': 'Diaphragm Only',
    'tog_ribs': 'Rib Cage Only',
    'air_lungs': 'Air in lungs',
    'pressure_lungs': 'Air pressure in lungs',
    'breath_rate': 'Breathing rate',
    'heart_rate': 'Heart rate',
    'per_min': '/min',
    'litre': 'L',
    'p_lower': 'Lower: air rushes in',
    'p_higher': 'Higher: air is pushed out',
    'p_equal': 'Same as outside',
    // Sidebar cards.
    'map_title': 'Model and Human Body',
    'vol_title': 'Lung Volume Change',
    'mode_both': 'Diaphragm + rib cage',
    'mode_dia': 'Diaphragm only',
    'mode_ribs': 'Rib cage only',
    'breaths': 'Breaths taken',
    'part_balloons': 'Balloons',
    'part_ytube': 'Y-shaped tube',
    'part_sheet': 'Rubber sheet',
    'part_bottle': 'Plastic bottle',
    'body_lungs': 'Lungs',
    'body_windpipe': 'Windpipe & bronchi',
    'body_diaphragm': 'Diaphragm',
    'body_chest': 'Chest cavity',
    // Popups.
    'pop_model_title': 'Model Complete!',
    'pop_think': 'Think about it',
    'pop_model_body':
        'What part of the human body does the rubber sheet represent? What about the balloons? Next, pull the sheet down: what happens to the space inside the bottle, and to the balloons?',
    'th_model': 'Model',
    'th_body': 'Human body',
    'pop_breath_title': 'Inhalation vs Exhalation',
    'pop_breath_body':
        'Which way did the rib cage move when you inhaled? When was the diaphragm flatter, and when was it more dome-shaped?',
    'th_part': 'Part',
    'th_inhale': 'Inhalation',
    'th_exhale': 'Exhalation',
    'row_ribs': 'Rib cage',
    'row_dia': 'Diaphragm',
    'row_volume': 'Chest volume',
    'row_air': 'Air',
    'in_ribs': 'Moves up and out',
    'ex_ribs': 'Moves down and in',
    'in_dia': 'Contracts, moves down, flatter',
    'ex_dia': 'Relaxes, moves up, dome-shaped',
    'in_vol': 'Increases',
    'ex_vol': 'Decreases',
    'in_air': 'Rushes in',
    'ex_air': 'Pushed out',
    'vol_compare': 'Lung volume change you measured',
    // Feedback.
    'msg_balloon_on': 'Balloon attached – an airtight seal!',
    'msg_wrong_balloon': 'Drop the balloon onto an open end of the Y-tube.',
    'msg_need_balloons': 'First attach both balloons to the Y-tube.',
    'msg_wrong_tube': 'Insert the Y-tube into the open bottom of the bottle.',
    'msg_tube_in': 'Y-tube inserted – its end pokes out of the lid.',
    'msg_need_tube': 'First insert the Y-tube into the bottle.',
    'msg_wrong_sheet': 'Stretch the rubber sheet over the open base of the bottle.',
    'msg_drag_hint': 'Drag it and drop it in place.',
    'msg_pull_hint': 'Drag the centre of the rubber sheet downwards.',
    'msg_pull_more': 'Pull the sheet further down to see the balloons inflate.',
    'msg_inflated': 'The balloons inflate! Now release the sheet.',
    'msg_hold_longer': 'Keep holding INHALE until the lungs are full.',
    'msg_full_in': 'Lungs full! Now release the INHALE button.',
    'msg_need_dia': "Turn the 'Diaphragm Only' switch ON first.",
    'msg_need_ribs': "Turn the 'Rib Cage Only' switch ON first.",
    'msg_dia_done': 'With the diaphragm alone, the lungs expand only partly.',
    'msg_toggle_locked': 'The switches are used from step 3.',
  },
  'hi': {
    'app_title': 'मानव श्वसन की क्रियाविधि',
    'app_subtitle': 'कक्षा 7 • जंतुओं में जैव प्रक्रम',
    'scen_1_opt': 'परिदृश्य 1: बोतल फेफड़ा मॉडल',
    'scen_2_opt': 'परिदृश्य 2: मानव श्वसन की क्रियाविधि',
    'sci_conclusion': 'सफलता!',
    'btn_continue': 'जारी रखें',
    'objective_complete': 'उद्देश्य पूर्ण! मॉडल के साथ प्रयोग करते रहें।',
    'conclusion_1':
        'यह मॉडल दिखाता है कि डायाफ्राम (रबड़ की शीट) को नीचे खींचने से वक्ष गुहा (बोतल) के अंदर का स्थान बढ़ जाता है, इसलिए वायु अंदर आती है और फेफड़े (गुब्बारे) फूल जाते हैं – यह अंतःश्वसन है। शीट छोड़ने पर स्थान घट जाता है और वायु बाहर निकल जाती है – यह उच्छ्वसन है।',
    'conclusion_2':
        'श्वास लेना डायाफ्राम और पसली पिंजर का एक समन्वित प्रयास है। अंतःश्वसन में डायाफ्राम नीचे जाता है और पसलियाँ ऊपर व बाहर की ओर जाती हैं, जिससे वक्ष का आयतन बढ़ता है और वायु अंदर खिंचती है। उच्छ्वसन में डायाफ्राम ऊपर जाता है और पसलियाँ नीचे व अंदर आती हैं, जिससे वक्ष का आयतन घटता है और वायु बाहर निकलती है।',
    'lbl_bottle': 'प्लास्टिक की बोतल',
    'lbl_ytube': 'Y-आकार की नली',
    'lbl_balloon': 'गुब्बारा',
    'lbl_balloons': 'पिचके गुब्बारे',
    'lbl_balloons_in': 'गुब्बारे',
    'lbl_sheet': 'रबड़ की शीट',
    'lbl_bottle_a': 'बोतल = वक्ष गुहा',
    'lbl_ytube_a': 'Y-नली = श्वासनली',
    'lbl_balloons_a': 'गुब्बारे = फेफड़े',
    'lbl_sheet_a': 'रबड़ की शीट = डायाफ्राम',
    'insert_here': 'नीचे से अंदर डालें',
    'stretch_here': 'तले पर तानें',
    'pull_down': 'नीचे खींचें',
    'release': 'छोड़ें',
    'air_in': 'वायु अंदर',
    'air_out': 'वायु बाहर',
    'lbl_trachea': 'श्वासनली',
    'lbl_bronchi': 'श्वसनी',
    'lbl_lungs': 'फेफड़े',
    'lbl_heart': 'हृदय',
    'lbl_ribs': 'पसली पिंजर',
    'lbl_diaphragm': 'डायाफ्राम',
    'held_still': 'स्थिर',
    'ribs_up': 'पसलियाँ: ऊपर व बाहर',
    'ribs_down': 'पसलियाँ: नीचे व अंदर',
    'dia_down': 'सिकुड़कर नीचे जाता है',
    'dia_up': 'शिथिल होकर ऊपर जाता है',
    'legend_in': 'अंदर ली गई वायु',
    'legend_out': 'बाहर छोड़ी गई वायु',
    'trace_title': 'फेफड़ों का आयतन',
    'trace_time': 'समय',
    'meter_title': 'मॉडल मीटर',
    'space_bottle': 'बोतल के अंदर का स्थान',
    'pressure_bottle': 'बोतल के अंदर वायु दाब',
    'balloon_size': 'गुब्बारों का आकार',
    'controls_title': 'श्वसन नियंत्रण',
    'btn_inhale': 'श्वास लें',
    'hold_hint': 'दबाकर रखें',
    'release_hint': 'छोड़ें = श्वास छोड़ें',
    'tog_diaphragm': 'केवल डायाफ्राम',
    'tog_ribs': 'केवल पसली पिंजर',
    'air_lungs': 'फेफड़ों में वायु',
    'pressure_lungs': 'फेफड़ों में वायु दाब',
    'breath_rate': 'श्वसन दर',
    'heart_rate': 'हृदय गति',
    'per_min': '/मिनट',
    'litre': 'ली',
    'p_lower': 'कम: वायु अंदर आती है',
    'p_higher': 'अधिक: वायु बाहर निकलती है',
    'p_equal': 'बाहर के बराबर',
    'map_title': 'मॉडल और मानव शरीर',
    'vol_title': 'फेफड़ों के आयतन में परिवर्तन',
    'mode_both': 'डायाफ्राम + पसली पिंजर',
    'mode_dia': 'केवल डायाफ्राम',
    'mode_ribs': 'केवल पसली पिंजर',
    'breaths': 'ली गई श्वासें',
    'part_balloons': 'गुब्बारे',
    'part_ytube': 'Y-आकार की नली',
    'part_sheet': 'रबड़ की शीट',
    'part_bottle': 'प्लास्टिक की बोतल',
    'body_lungs': 'फेफड़े',
    'body_windpipe': 'श्वासनली व श्वसनी',
    'body_diaphragm': 'डायाफ्राम',
    'body_chest': 'वक्ष गुहा',
    'pop_model_title': 'मॉडल तैयार!',
    'pop_think': 'सोचिए',
    'pop_model_body':
        'रबड़ की शीट मानव शरीर के किस भाग को दर्शाती है? और गुब्बारे? अब शीट को नीचे खींचिए: बोतल के अंदर के स्थान का क्या होता है, और गुब्बारों का?',
    'th_model': 'मॉडल',
    'th_body': 'मानव शरीर',
    'pop_breath_title': 'अंतःश्वसन बनाम उच्छ्वसन',
    'pop_breath_body':
        'श्वास लेते समय पसली पिंजर किस दिशा में गया? डायाफ्राम कब अधिक चपटा था और कब अधिक गुंबद जैसा?',
    'th_part': 'भाग',
    'th_inhale': 'अंतःश्वसन',
    'th_exhale': 'उच्छ्वसन',
    'row_ribs': 'पसली पिंजर',
    'row_dia': 'डायाफ्राम',
    'row_volume': 'वक्ष का आयतन',
    'row_air': 'वायु',
    'in_ribs': 'ऊपर और बाहर जाता है',
    'ex_ribs': 'नीचे और अंदर आता है',
    'in_dia': 'सिकुड़ता है, नीचे जाता है, चपटा होता है',
    'ex_dia': 'शिथिल होता है, ऊपर जाता है, गुंबद जैसा',
    'in_vol': 'बढ़ता है',
    'ex_vol': 'घटता है',
    'in_air': 'अंदर आती है',
    'ex_air': 'बाहर निकलती है',
    'vol_compare': 'आपके द्वारा मापा गया आयतन परिवर्तन',
    'msg_balloon_on': 'गुब्बारा जुड़ गया – वायुरोधी जोड़ बना!',
    'msg_wrong_balloon': 'गुब्बारे को Y-नली के किसी खुले सिरे पर छोड़ें।',
    'msg_need_balloons': 'पहले दोनों गुब्बारे Y-नली पर लगाएँ।',
    'msg_wrong_tube': 'Y-नली को बोतल के खुले तले से अंदर डालें।',
    'msg_tube_in': 'Y-नली अंदर लग गई – उसका सिरा ढक्कन से बाहर निकला है।',
    'msg_need_tube': 'पहले Y-नली को बोतल में डालें।',
    'msg_wrong_sheet': 'रबड़ की शीट को बोतल के खुले तले पर तानें।',
    'msg_drag_hint': 'इसे खींचकर सही जगह पर छोड़ें।',
    'msg_pull_hint': 'रबड़ की शीट के केंद्र को नीचे की ओर खींचें।',
    'msg_pull_more': 'गुब्बारों को फूलते देखने के लिए शीट को और नीचे खींचें।',
    'msg_inflated': 'गुब्बारे फूल गए! अब शीट को छोड़ दें।',
    'msg_hold_longer': "फेफड़े भरने तक 'श्वास लें' बटन दबाए रखें।",
    'msg_full_in': "फेफड़े भर गए! अब 'श्वास लें' बटन छोड़ दें।",
    'msg_need_dia': "पहले 'केवल डायाफ्राम' स्विच चालू करें।",
    'msg_need_ribs': "पहले 'केवल पसली पिंजर' स्विच चालू करें।",
    'msg_dia_done': 'केवल डायाफ्राम से फेफड़े आंशिक रूप से ही फैलते हैं।',
    'msg_toggle_locked': 'ये स्विच चरण 3 से उपयोग होंगे।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To build a working model of the human respiratory system, as shown in Activity 9.2, to demonstrate how diaphragm movement causes breathing.',
      steps: [
        LabStep(
          concept: 'Attach Balloons',
          action:
              'The parts are on the workbench: a cut plastic bottle, a Y-shaped tube, two deflated balloons and a thin rubber sheet. DRAG the two deflated balloons and DROP them onto the two forked ends of the Y-shaped tube.',
          observation: 'The balloons are securely attached to the Y-tube, creating an airtight seal.',
        ),
        LabStep(
          concept: 'Insert into Bottle',
          action:
              'DRAG the Y-tube with the attached balloons and INSERT it into the open bottom of the plastic bottle until the straight end pokes through the hole in the lid.',
          observation:
              'The Y-tube sits inside the bottle: the balloons hang freely inside and the single tube end sticks out of the top.',
        ),
        LabStep(
          concept: 'Seal the Base',
          action: 'DRAG the thin rubber sheet and STRETCH it over the open base of the bottle to cover it completely.',
          observation: 'The rubber sheet is stretched taut across the bottom opening, forming an airtight seal.',
        ),
        LabStep(
          concept: 'Pull Down (Inhale)',
          action: 'CLICK and DRAG the centre of the rubber sheet downwards. Observe the balloons.',
          observation: 'Pulling the sheet down increases the space inside the bottle, and the two balloons inflate.',
        ),
        LabStep(
          concept: 'Release (Exhale)',
          action: 'RELEASE the rubber sheet to let it go back to its original position. Observe the balloons again.',
          observation: 'The sheet moves back up, the space inside the bottle decreases and the balloons deflate.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To observe and control the movements of the rib cage and diaphragm in a model of the human chest to understand the process of inhalation and exhalation.',
      steps: [
        LabStep(
          concept: 'Inhalation',
          action:
              "You can see the rib cage, the lungs and the dome-shaped diaphragm below the lungs. CLICK and HOLD the 'INHALE' button.",
          observation:
              'The rib cage moves up and out, the diaphragm contracts and flattens, the lungs expand and blue air particles flow in through the windpipe.',
        ),
        LabStep(
          concept: 'Exhalation',
          action: "Now, RELEASE the 'INHALE' button to simulate exhalation.",
          observation:
              'The rib cage moves down and in, the diaphragm relaxes back into a dome, the lungs shrink and grey air particles flow out.',
        ),
        LabStep(
          concept: 'Diaphragm Only',
          action:
              "CLICK the 'Diaphragm Only' switch to ON. Then CLICK and HOLD the 'INHALE' button again (release it to exhale).",
          observation: 'The rib cage stays still; only the diaphragm moves, so the lungs expand partially.',
        ),
        LabStep(
          concept: 'Rib Cage Only',
          action:
              "CLICK the 'Rib Cage Only' switch to ON (the other switch turns off). Then CLICK and HOLD the 'INHALE' button (release it to exhale).",
          observation: 'The diaphragm stays still; only the rib cage moves up and out, so the lungs expand partially.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'क्रियाकलाप 9.2 में दिखाए अनुसार मानव श्वसन तंत्र का एक कार्यशील मॉडल बनाना और यह दिखाना कि डायाफ्राम की गति से श्वास कैसे होता है।',
      steps: [
        LabStep(
          concept: 'गुब्बारे लगाएँ',
          action:
              'मेज़ पर सामग्री रखी है: कटी हुई प्लास्टिक की बोतल, Y-आकार की नली, दो पिचके गुब्बारे और रबड़ की पतली शीट। दोनों पिचके गुब्बारों को खींचकर Y-आकार की नली के दोनों शाखा-सिरों पर छोड़ें।',
          observation: 'गुब्बारे Y-नली से मज़बूती से जुड़ जाते हैं और वायुरोधी जोड़ बन जाता है।',
        ),
        LabStep(
          concept: 'बोतल में डालें',
          action:
              'गुब्बारों सहित Y-नली को खींचें और प्लास्टिक की बोतल के खुले तले से अंदर डालें, जब तक कि सीधा सिरा ढक्कन के छेद से बाहर न निकल आए।',
          observation: 'Y-नली बोतल के अंदर है: गुब्बारे अंदर लटकते हैं और नली का एक सिरा ऊपर से बाहर निकला है।',
        ),
        LabStep(
          concept: 'तला बंद करें',
          action: 'रबड़ की पतली शीट को खींचें और बोतल के खुले तले पर तानकर उसे पूरी तरह ढक दें।',
          observation: 'रबड़ की शीट बोतल के निचले मुँह पर कसकर तनी है और वायुरोधी सील बनाती है।',
        ),
        LabStep(
          concept: 'नीचे खींचें (अंतःश्वसन)',
          action: 'रबड़ की शीट के केंद्र को क्लिक करके नीचे की ओर खींचें। गुब्बारों का अवलोकन करें।',
          observation: 'शीट को नीचे खींचने पर बोतल के अंदर का स्थान बढ़ता है और दोनों गुब्बारे फूल जाते हैं।',
        ),
        LabStep(
          concept: 'छोड़ें (उच्छ्वसन)',
          action: 'रबड़ की शीट को छोड़ दें ताकि वह अपनी मूल स्थिति में लौट आए। गुब्बारों को फिर से देखें।',
          observation: 'शीट वापस ऊपर जाती है, बोतल के अंदर का स्थान घटता है और गुब्बारे पिचक जाते हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'अंतःश्वसन और उच्छ्वसन की प्रक्रिया को समझने के लिए मानव वक्ष के मॉडल में पसली पिंजर और डायाफ्राम की गति का अवलोकन और नियंत्रण करना।',
      steps: [
        LabStep(
          concept: 'अंतःश्वसन',
          action:
              "आप पसली पिंजर, फेफड़े और फेफड़ों के नीचे गुंबद के आकार का डायाफ्राम देख सकते हैं। 'श्वास लें' बटन को दबाकर रखें।",
          observation:
              'पसली पिंजर ऊपर और बाहर की ओर जाता है, डायाफ्राम सिकुड़कर चपटा हो जाता है, फेफड़े फैलते हैं और नीले वायु कण श्वासनली से अंदर आते हैं।',
        ),
        LabStep(
          concept: 'उच्छ्वसन',
          action: "अब उच्छ्वसन देखने के लिए 'श्वास लें' बटन को छोड़ दें।",
          observation:
              'पसली पिंजर नीचे और अंदर आता है, डायाफ्राम शिथिल होकर फिर गुंबद जैसा हो जाता है, फेफड़े सिकुड़ते हैं और धूसर वायु कण बाहर निकलते हैं।',
        ),
        LabStep(
          concept: 'केवल डायाफ्राम',
          action: "'केवल डायाफ्राम' स्विच को चालू करें। फिर 'श्वास लें' बटन को दोबारा दबाकर रखें (छोड़ने पर उच्छ्वसन)।",
          observation: 'पसली पिंजर स्थिर रहता है; केवल डायाफ्राम चलता है, इसलिए फेफड़े आंशिक रूप से फैलते हैं।',
        ),
        LabStep(
          concept: 'केवल पसली पिंजर',
          action:
              "'केवल पसली पिंजर' स्विच को चालू करें (दूसरा स्विच बंद हो जाएगा)। फिर 'श्वास लें' बटन को दबाकर रखें (छोड़ने पर उच्छ्वसन)।",
          observation: 'डायाफ्राम स्थिर रहता है; केवल पसली पिंजर ऊपर और बाहर जाता है, इसलिए फेफड़े आंशिक रूप से फैलते हैं।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 560);

// Scenario 1: the bottle lung model on a workbench (design px).
const double _tableY = 440; // back edge of the bench top
const double _benchFront = 486; // front edge of the bench top
const double _bx = 520; // bottle centre line
const double _capTop = 82;
const double _capBottom = 108;
const double _neckHalf = 23;
const double _neckBottom = 132;
const double _shoulderBottom = 192;
const double _bodyHalf = 92;
const double _baseY = 372; // the cut-open base of the bottle
const double _stemLen = 150;
const double _maxPull = 66;
const double _rodX = 680; // clamp stand
const Offset _tubeHome = Offset(250, 290); // Y-junction on its holder
const Offset _tubeEntry = Offset(_bx, 352); // just inside the open base
const Offset _tubeInside = Offset(_bx, 212); // final place in the bottle
const Offset _sheetHome = Offset(800, 466);
const Offset _sheetTarget = Offset(_bx, _baseY);

// Scenario 2: the human chest (design px).
const double _cx = 430;
const List<double> _ribW = [70, 98, 116, 127, 134, 138, 140, 139, 135, 128];

/// Open end of the left (0) or right (1) branch of a Y-tube whose junction
/// is at [j].
Offset _forkEnd(Offset j, int i) => j + Offset(i == 0 ? -46 : 46, 40);

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Balloon body width / height for an inflation of 0 (deflated) .. 1.
double _balloonW(double inf) => _lerp(26, 80, inf);
double _balloonH(double inf) => _lerp(50, 84, inf);

double _frac(double x) => x - x.floorToDouble();

double _smooth(double x) => x * x * (3 - 2 * x);

Offset _rotate(Offset v, double a) =>
    Offset(v.dx * math.cos(a) - v.dy * math.sin(a), v.dx * math.sin(a) + v.dy * math.cos(a));

/// Point at fraction [t] of the length of the polyline [pts].
Offset _along(List<Offset> pts, double t) {
  var total = 0.0;
  for (var i = 1; i < pts.length; i++) {
    total += (pts[i] - pts[i - 1]).distance;
  }
  var d = t.clamp(0.0, 1.0) * total;
  for (var i = 1; i < pts.length; i++) {
    final seg = (pts[i] - pts[i - 1]).distance;
    if (d <= seg || i == pts.length - 1) {
      return Offset.lerp(pts[i - 1], pts[i], seg == 0 ? 0 : (d / seg).clamp(0.0, 1.0))!;
    }
    d -= seg;
  }
  return pts.last;
}

/// "Lub-dub" pulse (0..1) of a heart beating 72 times a minute.
double _beat(double t) {
  final ph = (t * 1.2) % 1.0;
  double g(double c) => math.exp(-math.pow((ph - c) / 0.045, 2).toDouble());
  return (g(0.06) + 0.6 * g(0.27)).clamp(0.0, 1.0);
}

/// Top edge of the diaphragm at [x] when it has contracted by [d] (0 = a
/// relaxed dome, 1 = contracted, lower and flatter).
double _diaTop(double x, double d) {
  final u = ((x - _cx) / 142).clamp(-1.0, 1.0);
  final edge = 418 + 16 * d;
  final height = 76 - 48 * d;
  final f = math.pow(1 - u * u, 0.7).toDouble() * (1 - 0.06 * u) - 0.16 * math.exp(-u * u / 0.035);
  return edge - height * f;
}

/// Branches of a bronchial tree from a hilum at the origin; [s] is -1 for
/// the lung on the viewer's left, 1 for the one on the right.
List<(Offset, Offset, double)> _makeTree(double s) {
  final out = <(Offset, Offset, double)>[];
  void grow(Offset p, double ang, double len, double w, int depth) {
    final q = p + Offset(math.cos(ang), math.sin(ang)) * len;
    out.add((p, q, w));
    if (depth == 0) return;
    grow(q, ang - 0.45, len * 0.7, w * 0.68, depth - 1);
    grow(q, ang + 0.4, len * 0.72, w * 0.68, depth - 1);
  }

  double a(double deg) {
    final r = deg * math.pi / 180;
    return s > 0 ? r : math.pi - r;
  }

  grow(Offset.zero, a(-58), 46, 5, 3);
  grow(Offset.zero, a(8), 50, 5, 3);
  grow(Offset.zero, a(62), 60, 5.5, 3);
  return out;
}

final List<(Offset, Offset, double)> _treeRight = _makeTree(-1);
final List<(Offset, Offset, double)> _treeLeft = _makeTree(1);

/// Alveoli texture: fixed points in a lung's bounding box (0..1).
final List<Offset> _alveoli = () {
  final rng = math.Random(3);
  return [for (var i = 0; i < 70; i++) Offset(rng.nextDouble(), rng.nextDouble())];
}();

enum _Part { balloon0, balloon1, tube, sheet, pull }

enum _Mode { both, diaphragm, ribs }

/// A part sliding to a new place (snap back, insertion, attaching).
class _Glide {
  _Glide(this.from, this.to, this.start, this.duration, [this.onDone]);

  final Offset from;
  final Offset to;
  final double start;
  final double duration;
  final VoidCallback? onDone;

  double progress(double now) => ((now - start) / duration).clamp(0.0, 1.0);
}

class _Balloon {
  _Balloon(this.home, this.restAngle, this.color)
      : pos = home,
        angle = restAngle;

  final Offset home;
  final double restAngle;
  final Color color;

  /// The balloon's open neck.
  Offset pos;
  double angle;

  /// 0 = left, 1 = right branch of the Y-tube once attached.
  int? fork;
  double attachedAt = -10;
  _Glide? glide;
}

/// An air particle: which lung / balloon it goes to and where it ends.
class _Particle {
  const _Particle(this.side, this.phase, this.u, this.v);

  final int side;
  final double phase;
  final double u;
  final double v;
}

/// Mutable scene model read by the painters every frame.
class _BreathScene {
  _BreathScene() {
    final rng = math.Random(11);
    for (var i = 0; i < 36; i++) {
      particles.add(_Particle(i % 2, rng.nextDouble(), rng.nextDouble(), rng.nextDouble()));
    }
  }

  int scenario = 0;
  int step = 1;
  double time = 0;
  final List<_Particle> particles = [];

  // ---- Scenario 1: bottle lung model.
  final List<_Balloon> balloons = [
    _Balloon(const Offset(48, 462), -1.47, _Colors.rose500),
    _Balloon(const Offset(116, 458), -1.64, _Colors.pink500),
  ];
  Offset tube = _tubeHome;
  _Glide? tubeGlide;
  bool tubeInBottle = false;
  double holderAlpha = 1;
  Offset sheet = _sheetHome;
  _Glide? sheetGlide;
  bool sheetOn = false;
  double pull = 0;
  double pullVel = 0;
  bool pulling = false;

  /// Step 5: the sheet was let go after a full pull.
  bool releasedFull = false;
  double inflation = 0;

  /// Rate of change of the balloon size (+ air in, - air out).
  double airFlow = 0;
  double airPhase = 0;
  _Part? drag;
  Offset dragOffset = Offset.zero;
  Offset pointer = Offset.zero;

  // ---- Scenario 2: human chest.
  bool holding = false;
  double breath = 0;
  _Mode mode = _Mode.both;
  double wDia = 1;
  double wRib = 1;

  /// How far the diaphragm / ribs have moved (0 rest .. 1 full inhale).
  double dia = 0;
  double rib = 0;
  double diaVel = 0;
  double ribVel = 0;

  /// Litres of air above the resting volume, and its rate of change.
  double volume = 0;
  double flow = 0;
  double phase2 = 0;
  final List<double> trace = [];
  double traceClock = 0;
  bool fullThisBreath = false;
  _Mode? fullMode;
  final List<double> inhaleStarts = [];
  int breaths = 0;
  final Map<_Mode, double> measured = {};

  void reset() {
    for (final b in balloons) {
      b
        ..pos = b.home
        ..angle = b.restAngle
        ..fork = null
        ..attachedAt = -10
        ..glide = null;
    }
    tube = _tubeHome;
    tubeGlide = null;
    tubeInBottle = false;
    holderAlpha = 1;
    sheet = _sheetHome;
    sheetGlide = null;
    sheetOn = false;
    pull = 0;
    pullVel = 0;
    pulling = false;
    releasedFull = false;
    inflation = 0;
    airFlow = 0;
    airPhase = 0;
    drag = null;
    dragOffset = Offset.zero;
    pointer = Offset.zero;

    holding = false;
    breath = 0;
    mode = _Mode.both;
    wDia = 1;
    wRib = 1;
    dia = 0;
    rib = 0;
    diaVel = 0;
    ribVel = 0;
    volume = 0;
    flow = 0;
    phase2 = 0;
    trace.clear();
    traceClock = 0;
    fullThisBreath = false;
    fullMode = null;
    inhaleStarts.clear();
    breaths = 0;
    measured.clear();
  }
}

/// Pan recognizer that only claims touches starting on a draggable part
/// (so empty-canvas drags still pan the zoomed canvas) and starts after a
/// small slop.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch9A3MechanismOfHumanBreathingPageState extends State<Ch9A3MechanismOfHumanBreathingPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _BreathScene _scene = _BreathScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];
  bool get _complete => _scene.step > _data.steps.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- frame

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _scene.time).clamp(0.0, 0.1);
    _scene.time = t;
    if (dt > 0) {
      if (_scene.scenario == 0) {
        _tickModel(dt);
      } else {
        _tickChest(dt);
      }
    }
    _frame.value = t;
  }

  /// Moves a glide along; returns the new glide (null when finished).
  _Glide? _runGlide(_Glide? g, void Function(Offset p) apply, {Curve curve = Curves.easeOutCubic}) {
    if (g == null) return null;
    final k = g.progress(_scene.time);
    apply(Offset.lerp(g.from, g.to, curve.transform(k))!);
    return k >= 1 ? null : g;
  }

  /// Bottle model: glides, the held balloon, the rubber sheet's spring and
  /// the balloons following the space inside the bottle.
  void _tickModel(double dt) {
    final sc = _scene;
    double ease(double k) => 1 - math.exp(-dt * k);

    for (final b in sc.balloons) {
      final g = b.glide;
      b.glide = _runGlide(g, (p) => b.pos = p);
      if (g != null && b.glide == null) g.onDone?.call();
    }
    final tg = sc.tubeGlide;
    sc.tubeGlide = _runGlide(tg, (p) => sc.tube = p, curve: Curves.easeInOutCubic);
    if (tg != null && sc.tubeGlide == null) tg.onDone?.call();
    final sg = sc.sheetGlide;
    sc.sheetGlide = _runGlide(sg, (p) => sc.sheet = p);
    if (sg != null && sc.sheetGlide == null) sg.onDone?.call();

    // A held balloon hangs from the finger by its neck.
    final held = switch (sc.drag) {
      _Part.balloon0 => 0,
      _Part.balloon1 => 1,
      _ => -1,
    };
    if (held >= 0) {
      final b = sc.balloons[held];
      b.pos = Offset.lerp(b.pos, sc.pointer + const Offset(0, -14), ease(22))!;
    }
    for (var i = 0; i < 2; i++) {
      final b = sc.balloons[i];
      final upright = b.fork != null || held == i;
      b.angle += ((upright ? 0.0 : b.restAngle) - b.angle) * ease(10);
    }
    sc.holderAlpha += ((sc.tubeInBottle ? 0.0 : 1.0) - sc.holderAlpha) * ease(4);

    // The stretched rubber sheet springs back when let go.
    if (sc.sheetOn && !sc.pulling) {
      const n = 4;
      final h = dt / n;
      for (var i = 0; i < n; i++) {
        sc.pullVel += (-170 * sc.pull - 13 * sc.pullVel) * h;
        sc.pull = (sc.pull + sc.pullVel * h).clamp(-0.12, 1.0);
      }
      if (sc.pull.abs() < 0.002 && sc.pullVel.abs() < 0.02) {
        sc.pull = 0;
        sc.pullVel = 0;
      }
    }

    // The balloons fill the space made by the sheet.
    final before = sc.inflation;
    sc.inflation += (sc.pull.clamp(0.0, 1.0) - sc.inflation) * ease(9);
    sc.airFlow += ((sc.inflation - before) / dt - sc.airFlow) * ease(10);
    sc.airPhase += sc.airFlow * dt * 1.2;

    if (sc.step == 5 && sc.releasedFull && sc.inflation < 0.04 && sc.pull.abs() < 0.03) {
      sc.releasedFull = false;
      _advanceStep();
    }
  }

  /// Human chest: breath progress from the INHALE button, the diaphragm /
  /// rib cage share of the movement, lung volume, air flow and the trace.
  void _tickChest(double dt) {
    final sc = _scene;
    double ease(double k) => 1 - math.exp(-dt * k);
    final prev = sc.breath;
    sc.breath = sc.holding ? math.min(1.0, sc.breath + dt / 1.6) : math.max(0.0, sc.breath - dt / 2.0);
    final (tDia, tRib) = switch (sc.mode) {
      _Mode.both => (1.0, 1.0),
      _Mode.diaphragm => (1.0, 0.0),
      _Mode.ribs => (0.0, 1.0),
    };
    sc.wDia += (tDia - sc.wDia) * ease(6);
    sc.wRib += (tRib - sc.wRib) * ease(6);
    final e = _smooth(sc.breath);
    final dia = e * sc.wDia;
    final rib = e * sc.wRib;
    sc.diaVel += ((dia - sc.dia) / dt - sc.diaVel) * ease(10);
    sc.ribVel += ((rib - sc.rib) / dt - sc.ribVel) * ease(10);
    sc.dia = dia;
    sc.rib = rib;
    final v = 0.30 * dia + 0.20 * rib;
    sc.flow += ((v - sc.volume) / dt - sc.flow) * ease(10);
    sc.volume = v;
    sc.phase2 += sc.flow * dt * 1.4;
    sc.traceClock += dt;
    while (sc.traceClock >= 0.05) {
      sc.traceClock -= 0.05;
      sc.trace.add(v);
      if (sc.trace.length > 240) sc.trace.removeAt(0);
    }
    if (sc.holding && prev < 1 && sc.breath >= 1) _onFullInhale();
    if (!sc.holding && prev > 0 && sc.breath <= 0) _onFullExhale();
  }

  // ------------------------------------------------------------- logic

  void _buildScenario() {
    _lab.cancelPending();
    _scene.reset();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _scene.scenario = index;
      _scene.step = 1;
      _lab.hidePopup(sound: false);
      _buildScenario();
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _scene.step = 1;
      _buildScenario();
    });
  }

  void _advanceStep() {
    final n = _data.steps.length;
    if (_scene.step > n) return;
    setState(() => _scene.step++);
    if (_scene.step > n) _showConclusion();
  }

  void _showConclusion() {
    final scenario = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      title: () => _t('sci_conclusion'),
      body: () => _t('conclusion_${scenario + 1}'),
      extra: scenario == 1 ? _volumeBars : null,
    );
  }

  // ------------------------------------------- scenario 1: bottle model

  /// Hit test in design coordinates on the painted parts.
  _Part? _hitTest(Offset p) {
    final sc = _scene;
    if (sc.scenario != 0) return null;
    if (sc.sheetOn) {
      final knobY = _baseY + sc.pull * _maxPull;
      if ((p.dx - _bx).abs() < 100 && p.dy > _baseY - 30 && p.dy < knobY + 46) return _Part.pull;
    }
    for (var i = 1; i >= 0; i--) {
      final b = sc.balloons[i];
      if (b.fork != null || b.glide != null) continue;
      final local = _rotate(p - b.pos, -b.angle);
      if (local.dx.abs() < 32 && local.dy > -14 && local.dy < 66) {
        return i == 0 ? _Part.balloon0 : _Part.balloon1;
      }
    }
    if (!sc.tubeInBottle && sc.tubeGlide == null) {
      final j = sc.tube;
      final onStem = (p.dx - j.dx).abs() < 20 && p.dy > j.dy - _stemLen - 12 && p.dy < j.dy + 8;
      final reach = sc.balloons.any((b) => b.fork != null) ? 112.0 : 52.0;
      final onForks = (p.dx - j.dx).abs() < 90 && p.dy >= j.dy && p.dy < j.dy + reach;
      if (onStem || onForks) return _Part.tube;
    }
    if (!sc.sheetOn && sc.sheetGlide == null) {
      final d = p - sc.sheet;
      if (d.dx.abs() < 80 && d.dy.abs() < 34) return _Part.sheet;
    }
    return null;
  }

  /// Why [part] cannot be used yet (a string key), or null.
  String? _blockedReason(_Part part) => switch (part) {
        _Part.tube when _scene.step < 2 => 'msg_need_balloons',
        _Part.sheet when _scene.step < 2 => 'msg_need_balloons',
        _Part.sheet when _scene.step < 3 => 'msg_need_tube',
        _ => null,
      };

  /// Pointer down on a part. Returns true when a drag has begun.
  bool _grab(Offset p) {
    final sc = _scene;
    if (!_lab.isLabActive || sc.drag != null) return false;
    final part = _hitTest(p);
    if (part == null) return false;
    final reason = _blockedReason(part);
    if (reason != null) {
      _lab.showToast(_t(reason), isError: true);
      return false;
    }
    sc.pointer = p;
    switch (part) {
      case _Part.balloon0 || _Part.balloon1:
        sc.dragOffset = Offset.zero;
      case _Part.tube:
        sc.dragOffset = p - sc.tube;
      case _Part.sheet:
        sc.dragOffset = p - sc.sheet;
      case _Part.pull:
        sc.dragOffset = Offset(0, p.dy - (_baseY + sc.pull * _maxPull));
        sc.pulling = true;
        sc.pullVel = 0;
    }
    if (part == _Part.pull) {
      _Audio.play(_Sound.whoosh, volume: 0.4);
    } else {
      _Audio.play(_Sound.pickup);
    }
    setState(() => sc.drag = part);
    return true;
  }

  void _dragTo(Offset p) {
    final sc = _scene;
    final part = sc.drag;
    if (part == null) return;
    final q = Offset(p.dx.clamp(10.0, _design.width - 10), p.dy.clamp(10.0, _design.height - 10));
    sc.pointer = q;
    switch (part) {
      case _Part.tube:
        sc.tube = q - sc.dragOffset;
      case _Part.sheet:
        sc.sheet = q - sc.dragOffset;
      case _Part.pull:
        sc.pull = ((q.dy - sc.dragOffset.dy - _baseY) / _maxPull).clamp(0.0, 1.0);
        if (sc.step == 4 && sc.pull >= 0.8) {
          _lab.showToast(_t('msg_inflated'));
          _advanceStep();
        }
      case _Part.balloon0 || _Part.balloon1:
        break; // The ticker eases the balloon after the finger.
    }
  }

  /// Free branch of the Y-tube near the dropped balloon, if any.
  int? _freeForkNear(Offset neck, Offset finger) {
    int? best;
    var bestD = 56.0;
    for (var i = 0; i < 2; i++) {
      if (_scene.balloons.any((b) => b.fork == i)) continue;
      final end = _forkEnd(_scene.tube, i);
      final d = math.min((neck - end).distance, (finger - end).distance);
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  void _release() {
    final sc = _scene;
    final part = sc.drag;
    if (part == null) return;
    final now = sc.time;
    setState(() => sc.drag = null);
    switch (part) {
      case _Part.balloon0 || _Part.balloon1:
        final b = sc.balloons[part == _Part.balloon0 ? 0 : 1];
        b.pos = sc.pointer + const Offset(0, -14);
        final fork = _freeForkNear(b.pos, sc.pointer);
        if (fork != null) {
          setState(() {
            b
              ..fork = fork
              ..attachedAt = now
              ..angle = 0
              ..pos = _forkEnd(sc.tube, fork);
          });
          _Audio.play(_Sound.drop);
          _lab.showToast(_t('msg_balloon_on'), sound: false);
          if (sc.balloons.every((x) => x.fork != null)) _advanceStep();
        } else {
          b.glide = _Glide(b.pos, b.home, now, 0.45);
          _lab.showToast(_t('msg_wrong_balloon'), isError: true);
        }
      case _Part.tube:
        final j = sc.tube;
        if ((j.dx - _bx).abs() < 125 && j.dy > 140 && j.dy < _benchFront) {
          _insertTube();
        } else {
          sc.tubeGlide = _Glide(j, _tubeHome, now, 0.5);
          _lab.showToast(_t('msg_wrong_tube'), isError: true);
        }
      case _Part.sheet:
        if ((sc.sheet - _sheetTarget).distance < 95) {
          sc.sheetGlide = _Glide(sc.sheet, _sheetTarget, now, 0.28, _attachSheet);
        } else {
          sc.sheetGlide = _Glide(sc.sheet, _sheetHome, now, 0.45);
          _lab.showToast(_t('msg_wrong_sheet'), isError: true);
        }
      case _Part.pull:
        sc.pulling = false;
        if (sc.pull > 0.15) _Audio.play(_Sound.whoosh, volume: 0.3);
        if (sc.step == 4) _lab.showToast(_t('msg_pull_more'), sound: false);
        if (sc.step == 5) sc.releasedFull = true;
    }
  }

  /// Slides the Y-tube to the open base, then up into the bottle until the
  /// straight end pokes out of the lid.
  void _insertTube() {
    final sc = _scene;
    _Audio.play(_Sound.whoosh, volume: 0.5);
    sc.tubeGlide = _Glide(sc.tube, _tubeEntry, sc.time, 0.35, () {
      sc.tubeGlide = _Glide(_tubeEntry, _tubeInside, sc.time, 0.75, () {
        if (!mounted) return;
        _Audio.play(_Sound.drop);
        setState(() => sc.tubeInBottle = true);
        _lab.showToast(_t('msg_tube_in'), sound: false);
        _advanceStep();
      });
    });
  }

  void _attachSheet() {
    if (!mounted) return;
    final sc = _scene;
    _Audio.play(_Sound.drop);
    setState(() {
      sc
        ..sheetOn = true
        ..pull = 0
        ..pullVel = 0;
    });
    _advanceStep();
    _lab.after(const Duration(milliseconds: 350), _showModelPopup);
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive || _scene.drag != null) return;
    final part = _hitTest(d.localPosition);
    if (part == null) return;
    final reason = _blockedReason(part);
    if (reason != null) {
      _lab.showToast(_t(reason), isError: true);
      return;
    }
    _lab.showToast(_t(part == _Part.pull ? 'msg_pull_hint' : 'msg_drag_hint'), sound: false);
  }

  void _showModelPopup() {
    if (!mounted || _scene.scenario != 0) return;
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('pop_model_title'),
        heading: _t('pop_think'),
        body: _t('pop_model_body'),
        icon: Icons.lightbulb,
        extra: _mapTable(),
        actions: [
          LabAction(
            label: _t('btn_continue'),
            icon: Icons.arrow_forward,
            onTap: () => _lab.hidePopup(sound: false),
          ),
        ],
      ),
      sound: _Sound.magic,
    );
  }

  // ------------------------------------------- scenario 2: human chest

  void _holdStart() {
    final sc = _scene;
    if (!_lab.isLabActive || sc.scenario != 1 || sc.holding) return;
    if (sc.step == 3 && sc.mode != _Mode.diaphragm) {
      _lab.showToast(_t('msg_need_dia'), isError: true);
      return;
    }
    if (sc.step == 4 && sc.mode != _Mode.ribs) {
      _lab.showToast(_t('msg_need_ribs'), isError: true);
      return;
    }
    _Audio.play(_Sound.whoosh, volume: 0.45);
    setState(() {
      sc
        ..holding = true
        ..fullThisBreath = false
        ..breaths += 1;
      sc.inhaleStarts.add(sc.time);
      if (sc.inhaleStarts.length > 3) sc.inhaleStarts.removeAt(0);
    });
  }

  void _holdEnd() {
    final sc = _scene;
    if (!sc.holding) return;
    setState(() => sc.holding = false);
    _Audio.play(_Sound.whoosh, volume: 0.3);
    if (!sc.fullThisBreath && !_complete && const [1, 3, 4].contains(sc.step)) {
      _lab.showToast(_t('msg_hold_longer'), sound: false);
    }
  }

  void _toggleMode(_Mode m) {
    final sc = _scene;
    if (sc.step < 3) {
      _lab.showToast(_t('msg_toggle_locked'), isError: true);
      return;
    }
    _Audio.play(_Sound.switchTap);
    setState(() => sc.mode = sc.mode == m ? _Mode.both : m);
  }

  void _onFullInhale() {
    final sc = _scene;
    sc
      ..fullThisBreath = true
      ..fullMode = sc.mode;
    setState(() => sc.measured[sc.mode] = sc.volume);
    if (sc.step == 1) {
      _lab.showToast(_t('msg_full_in'));
      _advanceStep();
    }
  }

  void _onFullExhale() {
    final sc = _scene;
    final full = sc.fullThisBreath;
    final mode = sc.fullMode;
    sc
      ..fullThisBreath = false
      ..fullMode = null;
    switch (sc.step) {
      case 2:
        _advanceStep();
        _lab.after(const Duration(milliseconds: 400), _showBreathPopup);
      case 3 when full && mode == _Mode.diaphragm:
        _lab.showToast(_t('msg_dia_done'));
        _advanceStep();
      case 4 when full && mode == _Mode.ribs:
        _advanceStep();
    }
  }

  void _showBreathPopup() {
    if (!mounted || _scene.scenario != 1) return;
    _lab.showPopup(
      () => LabPopupContent(
        title: _t('pop_breath_title'),
        heading: _t('pop_think'),
        body: _t('pop_breath_body'),
        icon: Icons.compare_arrows,
        extra: _popupTable(
          [_t('th_part'), _t('th_inhale'), _t('th_exhale')],
          [
            [_t('row_ribs'), _t('in_ribs'), _t('ex_ribs')],
            [_t('row_dia'), _t('in_dia'), _t('ex_dia')],
            [_t('row_volume'), _t('in_vol'), _t('ex_vol')],
            [_t('row_air'), _t('in_air'), _t('ex_air')],
          ],
          headColors: const [null, _Colors.sky500, _Colors.amber500],
        ),
        actions: [
          LabAction(
            label: _t('btn_continue'),
            icon: Icons.arrow_forward,
            onTap: () => _lab.hidePopup(sound: false),
          ),
        ],
      ),
      sound: _Sound.magic,
    );
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final sc = _scene;
        final inset = labOverlayInsets(context, _lab);
        final size = MediaQuery.sizeOf(context);
        // Cards sit below the toast strip at the top of the canvas.
        final cardTop = inset.top + 40 * s;
        final maxCard = math.max(90.0, size.height - cardTop - inset.bottom);
        return LabShell(
          controller: _lab,
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: _complete ? _t('objective_complete') : null,
          sidebarExtraTitle: sc.scenario == 0 ? _t('map_title') : _t('vol_title'),
          sidebarExtra: sc.scenario == 0 ? _mapCard(p, s) : _volumeCard(p, s),
          onReset: _fullReset,
          overlays: [
            if (sc.scenario == 0 && sc.sheetOn)
              Positioned(
                top: cardTop,
                right: inset.right,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxCard),
                  child: _meterCard(p, s),
                ),
              ),
            if (sc.scenario == 1)
              Positioned(
                top: cardTop,
                right: inset.right,
                child: Container(
                  constraints: BoxConstraints(maxHeight: maxCard),
                  child: _controlCard(p, s),
                ),
              ),
          ],
          stage: LabStage(
            designSize: _design,
            child: sc.scenario == 0 ? _modelStage() : _chestStage(),
          ),
        );
      },
    );
  }

  Widget _modelStage() {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_ItemPanRecognizer>(
          _ItemPanRecognizer.new,
          (r) => r
            ..accepts = ((local) => _lab.isLabActive && _hitTest(local) != null)
            ..dragStartBehavior = DragStartBehavior.down
            ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
            ..onStart = ((d) => _grab(d.localPosition))
            ..onUpdate = ((d) => _dragTo(d.localPosition))
            ..onEnd = ((_) => _release())
            ..onCancel = _release,
        ),
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          TapGestureRecognizer.new,
          (r) => r.onTapUp = _onTapUp,
        ),
      },
      child: CustomPaint(
        size: _design,
        painter: _ModelPainter(
          scene: _scene,
          repaint: _frame,
          isDark: _lab.isDark,
          showLabels: _lab.showLabels,
          lang: _lab.lang,
          tr: _t,
        ),
      ),
    );
  }

  Widget _chestStage() {
    return CustomPaint(
      size: _design,
      painter: _ChestPainter(
        scene: _scene,
        repaint: _frame,
        isDark: _lab.isDark,
        showLabels: _lab.showLabels,
        lang: _lab.lang,
        tr: _t,
      ),
    );
  }

  // ------------------------------------------------------- overlay cards

  Widget _card(LabPalette p, double s, {required IconData icon, required String title, required List<Widget> children}) {
    final head = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    return Container(
      width: 160 * s,
      padding: EdgeInsets.all(9 * s),
      decoration: BoxDecoration(
        color: (p.isDark ? _Colors.slate800 : Colors.white).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: _Colors.indigo500, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 13 * s, color: head),
                SizedBox(width: 5 * s),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: head,
                      fontWeight: FontWeight.w800,
                      fontSize: 9.5 * s,
                      letterSpacing: 0.8,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 7 * s),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _bar(LabPalette p, double s, double fraction, Color color, {double height = 5}) {
    return Container(
      height: height * s,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate700 : _Colors.slate200,
        borderRadius: BorderRadius.circular(99),
      ),
      child: FractionallySizedBox(
        widthFactor: fraction.clamp(0.0, 1.0),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
        ),
      ),
    );
  }

  Widget _meter(LabPalette p, double s, String label, String value, double? fraction, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ),
              SizedBox(width: 4 * s),
              Text(
                value,
                style: TextStyle(
                  color: p.isDark ? color : labShade(color, -0.25),
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (fraction != null) ...[
            SizedBox(height: 3 * s),
            _bar(p, s, fraction, color),
          ],
        ],
      ),
    );
  }

  /// Air pressure inside compared with outside, from the air flow.
  Widget _pressure(LabPalette p, double s, String label, double flow, double threshold) {
    final state = flow > threshold
        ? -1
        : flow < -threshold
            ? 1
            : 0;
    final color = switch (state) {
      -1 => _Colors.sky500,
      1 => _Colors.amber500,
      _ => _Colors.slate500,
    };
    final text = _t(switch (state) {
      -1 => 'p_lower',
      1 => 'p_higher',
      _ => 'p_equal',
    });
    final icon = switch (state) {
      -1 => Icons.arrow_downward,
      1 => Icons.arrow_upward,
      _ => Icons.drag_handle,
    };
    final fg = p.isDark ? labShade(color, 0.25) : labShade(color, -0.3);
    return Padding(
      padding: EdgeInsets.only(bottom: 7 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w700, height: 1.2),
          ),
          SizedBox(height: 3 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 3 * s),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6 * s),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 11 * s, color: fg),
                SizedBox(width: 4 * s),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(color: fg, fontSize: 10 * s, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(LabPalette p, double s, IconData icon, Color iconColor, String label, String value,
      {double iconScale = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5 * s),
      child: Row(
        children: [
          SizedBox(
            width: 16 * s,
            child: Transform.scale(scale: iconScale, child: Icon(icon, size: 13 * s, color: iconColor)),
          ),
          SizedBox(width: 4 * s),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w700, height: 1.2),
            ),
          ),
          SizedBox(width: 4 * s),
          Text(
            value,
            style: TextStyle(color: p.textStrong, fontSize: 11 * s, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  /// Scenario 1 readouts: space inside the bottle, pressure, balloon size.
  Widget _meterCard(LabPalette p, double s) {
    return _card(
      p,
      s,
      icon: Icons.speed,
      title: _t('meter_title'),
      children: [
        ValueListenableBuilder<double>(
          valueListenable: _frame,
          builder: (context, t, _) {
            final sc = _scene;
            final extra = sc.pull.clamp(0.0, 1.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _meter(p, s, _t('space_bottle'), '+${(extra * 32).round()}%', extra, _Colors.indigo500),
                _pressure(p, s, _t('pressure_bottle'), sc.airFlow, 0.12),
                _meter(p, s, _t('balloon_size'), '${(sc.inflation * 100).round()}%', sc.inflation, _Colors.rose500),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Scenario 2: INHALE button, isolation switches and chest readouts.
  Widget _controlCard(LabPalette p, double s) {
    final sc = _scene;
    final st = sc.step;
    final needDia = st == 3 && sc.mode != _Mode.diaphragm;
    final needRibs = st == 4 && sc.mode != _Mode.ribs;
    final cue = !sc.holding && !needDia && !needRibs && !_complete && st != 2;
    return _card(
      p,
      s,
      icon: Icons.air,
      title: _t('controls_title'),
      children: [
        _inhaleButton(s, cue: cue),
        SizedBox(height: 8 * s),
        _toggleRow(p, s, _t('tog_diaphragm'), sc.mode == _Mode.diaphragm, () => _toggleMode(_Mode.diaphragm),
            cue: needDia, enabled: st >= 3),
        SizedBox(height: 5 * s),
        _toggleRow(p, s, _t('tog_ribs'), sc.mode == _Mode.ribs, () => _toggleMode(_Mode.ribs),
            cue: needRibs, enabled: st >= 3),
        Divider(height: 14 * s, color: p.cardBorder),
        ValueListenableBuilder<double>(
          valueListenable: _frame,
          builder: (context, t, _) => _chestReadouts(p, s, t),
        ),
      ],
    );
  }

  Widget _inhaleButton(double s, {required bool cue}) {
    final held = _scene.holding;
    return Listener(
      onPointerDown: (_) => _holdStart(),
      onPointerUp: (_) => _holdEnd(),
      onPointerCancel: (_) => _holdEnd(),
      child: ValueListenableBuilder<double>(
        valueListenable: _frame,
        builder: (context, t, child) {
          final glow = cue ? 0.5 + 0.5 * math.sin(t * 4) : 0.0;
          return AnimatedScale(
            scale: held ? 0.96 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              height: 54 * s,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: held ? const [_Colors.blue600, _Colors.blue800] : const [_Colors.sky400, _Colors.blue600],
                ),
                borderRadius: BorderRadius.circular(14 * s),
                border: Border.all(color: held ? _Colors.sky300 : const Color(0xFF1D4ED8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _Colors.sky400.withValues(alpha: held ? 0.8 : 0.2 + 0.55 * glow),
                    blurRadius: (held ? 22 : 6 + 16 * glow) * s,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 4 * s),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(held ? Icons.keyboard_double_arrow_down : Icons.air, color: Colors.white, size: 18 * s),
                    SizedBox(width: 5 * s),
                    Text(
                      _t('btn_inhale'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17 * s,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1 * s),
                Text(
                  held ? _t('release_hint') : _t('hold_hint'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 9.5 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(LabPalette p, double s, String label, bool on, VoidCallback onTap,
      {required bool cue, required bool enabled}) {
    return ValueListenableBuilder<double>(
      valueListenable: _frame,
      builder: (context, t, _) {
        final pulse = cue ? 0.5 + 0.5 * math.sin(t * 5) : 0.0;
        final border = cue
            ? _Colors.zslYellow.withValues(alpha: 0.35 + 0.65 * pulse)
            : on
                ? _Colors.indigo500.withValues(alpha: 0.7)
                : p.cardBorder;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9 * s),
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 5 * s),
              decoration: BoxDecoration(
                color: on ? _Colors.indigo500.withValues(alpha: 0.16) : Colors.transparent,
                borderRadius: BorderRadius.circular(9 * s),
                border: Border.all(color: border, width: cue ? 2 : 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: enabled ? p.text : p.textMuted,
                        fontSize: 10.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * s),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32 * s,
                    height: 18 * s,
                    padding: EdgeInsets.all(2 * s),
                    alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: (on ? _Colors.indigo500 : _Colors.slate500).withValues(alpha: enabled ? 1 : 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Container(
                      width: 14 * s,
                      height: 14 * s,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chestReadouts(LabPalette p, double s, double t) {
    final sc = _scene;
    var rate = '—';
    final starts = sc.inhaleStarts;
    if (starts.length >= 2) {
      final gap = starts.last - starts[starts.length - 2];
      if (gap > 0.5) rate = '${(60 / gap).round().clamp(1, 99)} ${_t('per_min')}';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _meter(p, s, _t('air_lungs'), '${(2.5 + sc.volume).toStringAsFixed(2)} ${_t('litre')}', sc.volume / 0.5,
            _Colors.sky500),
        _pressure(p, s, _t('pressure_lungs'), sc.flow, 0.04),
        _infoLine(p, s, Icons.air, _Colors.sky400, _t('breath_rate'), rate),
        _infoLine(p, s, Icons.favorite, _Colors.red, _t('heart_rate'), '72 ${_t('per_min')}',
            iconScale: 1 + 0.28 * _beat(t)),
      ],
    );
  }

  // ------------------------------------------------------- sidebar cards

  Widget _sideCard(LabPalette p, double s, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  /// Scenario 1: which model part stands for which body part (revealed as
  /// the model is assembled).
  Widget _mapCard(LabPalette p, double s) {
    final st = _scene.step;
    final f = s * _lab.fontScale;
    Widget row(String part, String body, bool shown) => LabInfoRow(
          palette: p,
          scale: f,
          label: _t(part),
          value: shown ? _t(body) : '?',
          valueColor: shown ? (p.isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)) : p.textMuted,
        );
    return _sideCard(p, s, [
      row('part_balloons', 'body_lungs', st >= 2),
      row('part_ytube', 'body_windpipe', st >= 3),
      row('part_sheet', 'body_diaphragm', st >= 4),
      row('part_bottle', 'body_chest', st >= 4),
    ]);
  }

  /// Scenario 2: lung volume change measured in each mode.
  Widget _volumeCard(LabPalette p, double s) {
    final m = _scene.measured;
    final f = s * _lab.fontScale;
    String v(_Mode mode) => m[mode] == null ? '—' : '+${m[mode]!.toStringAsFixed(2)} ${_t('litre')}';
    return _sideCard(p, s, [
      LabInfoRow(palette: p, scale: f, label: _t('mode_both'), value: v(_Mode.both), valueColor: _Colors.sky400),
      LabInfoRow(palette: p, scale: f, label: _t('mode_dia'), value: v(_Mode.diaphragm), valueColor: _Colors.red),
      LabInfoRow(palette: p, scale: f, label: _t('mode_ribs'), value: v(_Mode.ribs), valueColor: _Colors.amber500),
      Divider(color: p.cardBorder, height: 14 * s),
      LabInfoRow(palette: p, scale: f, label: _t('breaths'), value: '${_scene.breaths}'),
    ]);
  }

  // ------------------------------------------------------- popup extras

  Widget _popupTable(List<String> head, List<List<String>> rows, {List<Color?> headColors = const []}) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    final line = p.isDark ? const Color(0x33FFFFFF) : const Color(0x33000000);
    Widget cell(String text, TextStyle style) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 5 * s),
          child: Text(text, style: style),
        );
    Color? headColor(int i) {
      final c = i < headColors.length ? headColors[i] : null;
      if (c == null) return null;
      return p.isDark ? labShade(c, 0.2) : labShade(c, -0.25);
    }

    return Table(
      border: TableBorder.all(color: line, borderRadius: BorderRadius.circular(8)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: head.length == 3
          ? const {0: FlexColumnWidth(0.9), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.2)}
          : null,
      children: [
        TableRow(
          decoration: BoxDecoration(color: p.isDark ? const Color(0x14FFFFFF) : const Color(0x0D000000)),
          children: [
            for (var i = 0; i < head.length; i++)
              cell(
                head[i],
                TextStyle(color: headColor(i) ?? p.textStrong, fontSize: 11.5 * f, fontWeight: FontWeight.w800),
              ),
          ],
        ),
        for (final r in rows)
          TableRow(
            children: [
              for (var i = 0; i < r.length; i++)
                cell(
                  r[i],
                  TextStyle(
                    color: i == 0 ? p.textStrong : p.text,
                    fontSize: 11.5 * f,
                    fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                    height: 1.3,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _mapTable() => _popupTable(
        [_t('th_model'), _t('th_body')],
        [
          [_t('part_bottle'), _t('body_chest')],
          [_t('part_ytube'), _t('body_windpipe')],
          [_t('part_balloons'), _t('body_lungs')],
          [_t('part_sheet'), _t('body_diaphragm')],
        ],
      );

  /// Conclusion of scenario 2: the lung volume change in each mode.
  Widget _volumeBars() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    final m = _scene.measured;
    Widget bar(String label, double v, Color c) => Padding(
          padding: EdgeInsets.only(bottom: 8 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(color: p.text, fontSize: 11.5 * f, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '+${v.toStringAsFixed(2)} ${_t('litre')}',
                    style: TextStyle(
                      color: p.isDark ? labShade(c, 0.2) : labShade(c, -0.25),
                      fontSize: 12 * f,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4 * s),
              _bar(p, s, v / 0.5, c, height: 8),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t('vol_compare').toUpperCase(),
          style: TextStyle(color: p.accent, fontSize: 10 * s, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        SizedBox(height: 8 * s),
        bar(_t('mode_both'), m[_Mode.both] ?? 0.5, _Colors.sky500),
        bar(_t('mode_dia'), m[_Mode.diaphragm] ?? 0.3, _Colors.red),
        bar(_t('mode_ribs'), m[_Mode.ribs] ?? 0.2, _Colors.amber500),
      ],
    );
  }
}

// ============================================================ PAINTING

/// A pill label with a thin leader line to [anchor].
void _leaderTag(Canvas canvas, String text, Offset anchor, Offset at, bool isDark,
    {Alignment align = Alignment.centerRight, double opacity = 1}) {
  final rect = labPill(canvas, text, at, size: 14.5, anchor: align, opacity: opacity);
  final from = align == Alignment.centerRight
      ? Offset(rect.right, rect.center.dy)
      : align == Alignment.centerLeft
          ? Offset(rect.left, rect.center.dy)
          : rect.center;
  canvas.drawLine(
    from,
    anchor,
    Paint()
      ..strokeWidth = 1.5
      ..color = (isDark ? Colors.white : _Colors.slate700).withValues(alpha: 0.7 * opacity),
  );
  canvas.drawCircle(anchor, 3.2, Paint()..color = _Colors.zslYellow.withValues(alpha: opacity));
}

Paint _stroke(double width, Color color) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..color = color;

/// Scenario 1: workbench, clamp stand, transparent bottle, Y-tube, balloons
/// and rubber sheet, with air particles and drop-target cues.
class _ModelPainter extends CustomPainter {
  _ModelPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _BreathScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  Color get _glassEdge => isDark ? const Color(0xE667E8F9) : const Color(0xD90891B2);
  Color get _glassCore => isDark ? const Color(0xF0123A4A) : const Color(0xF2E0F7FC);
  Color get _bottleLine => isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1);
  Color get _airOut => isDark ? _Colors.slate300 : _Colors.slate500;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = scene;
    _room(canvas, size);
    _stand(canvas);
    if (sc.holderAlpha > 0.02) _holder(canvas, sc.holderAlpha);
    _bottleBack(canvas);
    if (sc.drag != _Part.tube) _assembly(canvas, sc.tube);
    _bottleFront(canvas);
    if (sc.sheetOn) {
      _membrane(canvas);
    } else if (sc.drag != _Part.sheet) {
      _looseSheet(canvas, sc.sheet);
    }
    for (var i = 0; i < 2; i++) {
      final b = sc.balloons[i];
      if (b.fork == null && sc.drag != (i == 0 ? _Part.balloon0 : _Part.balloon1)) {
        _balloon(canvas, b.pos, b.angle, 0, 1, b.color, resting: b.glide == null);
      }
    }
    if (sc.tubeInBottle && sc.sheetOn) _air(canvas);
    _targets(canvas);
    // The part in the hand is drawn on top.
    switch (sc.drag) {
      case _Part.tube:
        _assembly(canvas, sc.tube);
      case _Part.sheet:
        _looseSheet(canvas, sc.sheet, lifted: true);
      case _Part.balloon0 || _Part.balloon1:
        final b = sc.balloons[sc.drag == _Part.balloon0 ? 0 : 1];
        _balloon(canvas, b.pos, b.angle, 0, 1, b.color);
      default:
        break;
    }
    if (showLabels) _labels(canvas);
    _pullCue(canvas);
  }

  void _room(Canvas canvas, Size size) {
    final b = labBleed(size);
    canvas.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, _tableY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1222), Color(0xFF1B2638)]
              : const [Color(0xFFDDE6F0), Color(0xFFF4F7FB)],
        ).createShader(Rect.fromLTRB(0, 0, size.width, _tableY)),
    );
    // Wall tiles.
    final grid = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: isDark ? 0.04 : 0.09);
    for (var x = -440.0; x < 1500; x += 80) {
      canvas.drawLine(Offset(x, b.top), Offset(x, _tableY), grid);
    }
    for (var y = _tableY - 80; y > b.top; y -= 80) {
      canvas.drawLine(Offset(b.left, y), Offset(b.right, y), grid);
    }
    labGlow(canvas, const Offset(_bx, 250), 340, isDark ? _Colors.sky400 : Colors.white,
        intensity: isDark ? 0.12 : 0.55);
    // Bench top (seen slightly from above) and its front edge.
    final top = Rect.fromLTRB(b.left, _tableY, b.right, _benchFront);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF4A3A2E), Color(0xFF5E4838)]
              : const [Color(0xFFCFA97F), Color(0xFFDDB88E)],
        ).createShader(Rect.fromLTRB(0, _tableY, size.width, _benchFront)),
    );
    final grain = Paint()
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: isDark ? 0.12 : 0.06);
    for (var i = 1; i < 4; i++) {
      final y = _tableY + i * (_benchFront - _tableY) / 4;
      canvas.drawLine(Offset(b.left, y), Offset(b.right, y), grain);
    }
    canvas.drawRect(
      Rect.fromLTRB(b.left, _benchFront, b.right, b.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF33261D), Color(0xFF1A130E)]
              : const [Color(0xFFA67B52), Color(0xFF7D5A3A)],
        ).createShader(Rect.fromLTRB(0, _benchFront, size.width, size.height)),
    );
    canvas.drawLine(
      Offset(b.left, _benchFront),
      Offset(b.right, _benchFront),
      Paint()
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: isDark ? 0.10 : 0.35),
    );
  }

  void _stand(Canvas canvas) {
    const metal = Color(0xFF64748B);
    labGroundShadow(canvas, const Offset(_rodX, 474), 150, 14);
    labBox3D(canvas, Rect.fromLTRB(_rodX - 58, 460, _rodX + 58, 474), 9, _Colors.slate700);
    const rod = Rect.fromLTRB(_rodX - 4.5, 64, _rodX + 4.5, 462);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rod, const Radius.circular(4)),
      Paint()
        ..shader = LinearGradient(
          colors: [labShade(metal, -0.3), labShade(metal, 0.45), metal, labShade(metal, -0.4)],
          stops: const [0, 0.35, 0.6, 1],
        ).createShader(rod),
    );
    const arm = Rect.fromLTRB(_bx + _neckHalf + 6, 116, _rodX, 124);
    canvas.drawRect(
      arm,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(metal, 0.4), labShade(metal, -0.3)],
        ).createShader(arm),
    );
    labBox3D(canvas, Rect.fromCenter(center: const Offset(_rodX, 120), width: 20, height: 24), 6, _Colors.slate600);
    for (final s in [-1.0, 1.0]) {
      final jaw = Rect.fromCenter(center: Offset(_bx + s * (_neckHalf + 4), 120), width: 8, height: 22);
      canvas.drawRRect(RRect.fromRectAndRadius(jaw, const Radius.circular(3)), Paint()..color = const Color(0xFFB45309));
    }
  }

  /// Small stand that holds the Y-tube upright on the bench.
  void _holder(Canvas canvas, double a) {
    const postX = 196.0;
    labBox3D(canvas, const Rect.fromLTRB(170, 458, 330, 472), 8, const Color(0xFF92400E), opacity: a);
    const post = Rect.fromLTRB(postX - 4, 150, postX + 4, 460);
    canvas.drawRRect(
      RRect.fromRectAndRadius(post, const Radius.circular(3)),
      Paint()..color = _Colors.slate500.withValues(alpha: a),
    );
    canvas.drawRect(
      Rect.fromLTRB(postX, 164, _tubeHome.dx - 9, 172),
      Paint()..color = _Colors.slate500.withValues(alpha: a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(_tubeHome.dx, 168), width: 20, height: 12),
        const Radius.circular(3),
      ),
      _stroke(3, _Colors.slate600.withValues(alpha: a)),
    );
  }

  Path _bottlePath() => Path()
    ..moveTo(_bx - _neckHalf, _capBottom - 2)
    ..lineTo(_bx - _neckHalf, _neckBottom)
    ..cubicTo(_bx - _neckHalf, _neckBottom + 34, _bx - _bodyHalf, _shoulderBottom - 40, _bx - _bodyHalf,
        _shoulderBottom)
    ..lineTo(_bx - _bodyHalf, _baseY)
    ..lineTo(_bx + _bodyHalf, _baseY)
    ..lineTo(_bx + _bodyHalf, _shoulderBottom)
    ..cubicTo(_bx + _bodyHalf, _shoulderBottom - 40, _bx + _neckHalf, _neckBottom + 34, _bx + _neckHalf,
        _neckBottom)
    ..lineTo(_bx + _neckHalf, _capBottom - 2)
    ..close();

  Path _bottleOutline() => Path()
    ..moveTo(_bx - _bodyHalf, _baseY)
    ..lineTo(_bx - _bodyHalf, _shoulderBottom)
    ..cubicTo(_bx - _bodyHalf, _shoulderBottom - 40, _bx - _neckHalf, _neckBottom + 34, _bx - _neckHalf,
        _neckBottom)
    ..lineTo(_bx - _neckHalf, _capBottom)
    ..moveTo(_bx + _neckHalf, _capBottom)
    ..lineTo(_bx + _neckHalf, _neckBottom)
    ..cubicTo(_bx + _neckHalf, _neckBottom + 34, _bx + _bodyHalf, _shoulderBottom - 40, _bx + _bodyHalf,
        _shoulderBottom)
    ..lineTo(_bx + _bodyHalf, _baseY);

  void _bottleBack(Canvas canvas) {
    const r = Rect.fromLTRB(_bx - _bodyHalf, _capTop, _bx + _bodyHalf, _baseY);
    canvas.drawPath(
      _bottlePath(),
      Paint()
        ..shader = LinearGradient(
          colors: isDark
              ? const [Color(0x267DD3FC), Color(0x0F7DD3FC), Color(0x307DD3FC)]
              : const [Color(0x330EA5E9), Color(0x140EA5E9), Color(0x400EA5E9)],
        ).createShader(r),
    );
    final rim = Rect.fromCenter(center: const Offset(_bx, _baseY), width: _bodyHalf * 2, height: 16);
    canvas.drawArc(rim, math.pi, math.pi, false, _stroke(1.5, _bottleLine.withValues(alpha: 0.45)));
  }

  void _bottleFront(Canvas canvas) {
    final line = _bottleLine;
    canvas.drawPath(_bottleOutline(), _stroke(2.4, line.withValues(alpha: isDark ? 0.8 : 0.6)));
    // Moulded rings and highlights of the PET bottle.
    for (final y in [236.0, 318.0]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(_bx, y), width: _bodyHalf * 2, height: 12),
        0,
        math.pi,
        false,
        _stroke(1.4, line.withValues(alpha: 0.3)),
      );
    }
    canvas.drawLine(
      const Offset(_bx - 70, 208),
      const Offset(_bx - 70, 356),
      _stroke(7, Colors.white.withValues(alpha: isDark ? 0.10 : 0.4)),
    );
    canvas.drawLine(
      const Offset(_bx + 74, 216),
      const Offset(_bx + 74, 350),
      _stroke(3, Colors.white.withValues(alpha: isDark ? 0.08 : 0.3)),
    );
    if (!scene.sheetOn) {
      final rim = Rect.fromCenter(center: const Offset(_bx, _baseY), width: _bodyHalf * 2, height: 16);
      canvas.drawArc(rim, 0, math.pi, false, _stroke(2.2, line.withValues(alpha: 0.9)));
    }
    _cap(canvas);
    // The straight end of the Y-tube poking out through the lid.
    final j = scene.tube;
    if (scene.drag != _Part.tube && (j.dx - _bx).abs() < 1 && j.dy - _stemLen < _capTop) {
      _tubeSegment(canvas, j.dx, j.dy - _stemLen, _capTop + 2);
    }
  }

  void _cap(Canvas canvas) {
    const r = Rect.fromLTRB(_bx - 27, _capTop, _bx + 27, _capBottom);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E3A8A)],
          stops: [0, 0.35, 0.6, 1],
        ).createShader(r),
    );
    final ridge = Paint()
      ..strokeWidth = 1.5
      ..color = Colors.black.withValues(alpha: 0.22);
    for (var x = r.left + 6; x < r.right - 3; x += 6) {
      canvas.drawLine(Offset(x, r.top + 5), Offset(x, r.bottom - 3), ridge);
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_bx, _capTop), width: 54, height: 8),
      Paint()..color = const Color(0xFF60A5FA),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_bx, _capTop), width: 15, height: 4.5),
      Paint()..color = _Colors.slate900,
    );
  }

  Path _yPath(Offset j) => Path()
    ..moveTo(j.dx, j.dy - _stemLen)
    ..lineTo(j.dx, j.dy)
    ..moveTo(j.dx - 46, j.dy + 40)
    ..cubicTo(j.dx - 46, j.dy + 22, j.dx - 22, j.dy + 15, j.dx, j.dy)
    ..cubicTo(j.dx + 22, j.dy + 15, j.dx + 46, j.dy + 22, j.dx + 46, j.dy + 40);

  void _yTube(Canvas canvas, Offset j) {
    final path = _yPath(j);
    canvas.drawPath(path, _stroke(13, _glassEdge)..strokeCap = StrokeCap.butt);
    canvas.drawPath(path, _stroke(8, _glassCore)..strokeCap = StrokeCap.butt);
    canvas.drawLine(
      Offset(j.dx - 3, j.dy - _stemLen + 5),
      Offset(j.dx - 3, j.dy - 10),
      _stroke(1.6, Colors.white.withValues(alpha: 0.6)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(j.dx, j.dy - _stemLen), width: 13, height: 4),
      Paint()..color = _glassEdge,
    );
  }

  void _tubeSegment(Canvas canvas, double x, double top, double bottom) {
    canvas.drawLine(Offset(x, top), Offset(x, bottom), _stroke(13, _glassEdge)..strokeCap = StrokeCap.butt);
    canvas.drawLine(Offset(x, top), Offset(x, bottom), _stroke(8, _glassCore)..strokeCap = StrokeCap.butt);
    canvas.drawLine(Offset(x - 3, top + 4), Offset(x - 3, bottom), _stroke(1.6, Colors.white.withValues(alpha: 0.6)));
    canvas.drawOval(Rect.fromCenter(center: Offset(x, top), width: 13, height: 4), Paint()..color = _glassEdge);
  }

  /// The Y-tube with any balloons attached to it.
  void _assembly(Canvas canvas, Offset j) {
    _yTube(canvas, j);
    for (final b in scene.balloons) {
      final fork = b.fork;
      if (fork == null) continue;
      final age = scene.time - b.attachedAt;
      final wobble = age < 2 ? 0.22 * math.exp(-4 * age) * math.sin(15 * age) : 0.0;
      _balloon(canvas, _forkEnd(j, fork), 0, scene.inflation, 1 + wobble, b.color);
    }
  }

  /// Balloon hanging from its open neck at [neck]; [inf] 0 = deflated,
  /// 1 = fully inflated; [stretch] squashes / stretches it vertically.
  void _balloon(Canvas canvas, Offset neck, double angle, double inf, double stretch, Color color,
      {bool resting = false}) {
    final w = _balloonW(inf);
    final h = _balloonH(inf) * stretch;
    const top = 11.0;
    if (resting) {
      final c = neck + _rotate(Offset(0, top + h / 2), angle);
      labGroundShadow(canvas, c + const Offset(0, 10), h * 1.1, 8, opacity: 0.25);
    }
    canvas.save();
    canvas.translate(neck.dx, neck.dy);
    canvas.rotate(angle);
    // Neck and rolled lip.
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(-5.5, 0, 5.5, top + 3), const Radius.circular(3)),
      Paint()..color = labShade(color, -0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 1.5), width: 15, height: 5), const Radius.circular(2.5)),
      Paint()..color = labShade(color, 0.12),
    );
    final body = Path()
      ..moveTo(-4.5, top)
      ..cubicTo(-w * 0.62, top + h * 0.12, -w * 0.58, top + h, 0, top + h)
      ..cubicTo(w * 0.58, top + h, w * 0.62, top + h * 0.12, 4.5, top)
      ..close();
    final rect = Rect.fromLTRB(-w / 2, top, w / 2, top + h);
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.25),
          radius: 0.9,
          colors: [labShade(color, 0.35 + 0.15 * inf), color, labShade(color, -0.4)],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    // Wrinkles of the deflated rubber.
    if (inf < 0.6) {
      final a = 1 - inf / 0.6;
      final wr = _stroke(1.4, labShade(color, -0.45).withValues(alpha: 0.6 * a));
      canvas.drawPath(
        Path()
          ..moveTo(-w * 0.18, top + h * 0.25)
          ..quadraticBezierTo(-w * 0.05, top + h * 0.45, -w * 0.2, top + h * 0.7),
        wr,
      );
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.15, top + h * 0.2)
          ..quadraticBezierTo(w * 0.28, top + h * 0.5, w * 0.1, top + h * 0.8),
        wr,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-w * 0.2, top + h * 0.32), width: w * 0.18, height: h * 0.22),
      Paint()..color = Colors.white.withValues(alpha: 0.32 + 0.18 * inf),
    );
    canvas.drawPath(body, _stroke(1, labShade(color, -0.5).withValues(alpha: 0.5)));
    canvas.restore();
  }

  void _looseSheet(Canvas canvas, Offset c, {bool lifted = false}) {
    final d = (c - _sheetTarget).distance;
    final stretch = (1 - (d - 20) / 230).clamp(0.0, 1.0);
    final w = _lerp(126, _bodyHalf * 2 + 10, stretch);
    final h = _lerp(22, 14, stretch);
    if (!lifted) labGroundShadow(canvas, c + const Offset(0, 6), w * 0.95, 12, opacity: 0.25);
    final path = Path();
    for (var i = 0; i <= 48; i++) {
      final a = i / 48 * 2 * math.pi;
      final wave = 1 + (1 - stretch) * 0.06 * math.sin(a * 5 + 0.7);
      final x = c.dx + math.cos(a) * w / 2 * wave;
      final y = c.dy + math.sin(a) * h / 2 * wave;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final r = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(_Colors.latex, 0.3), _Colors.latex, labShade(_Colors.latex, -0.25)],
        ).createShader(r),
    );
    canvas.drawPath(path, _stroke(1.4 + stretch, labShade(_Colors.latex, -0.5)));
    canvas.drawLine(
      Offset(c.dx - w * 0.3, c.dy - h * 0.15),
      Offset(c.dx + w * 0.1, c.dy - h * 0.22),
      _stroke(2, Colors.white.withValues(alpha: 0.45)),
    );
  }

  /// The rubber sheet tied over the base; it bulges down with the pull.
  void _membrane(Canvas canvas) {
    final sc = scene;
    final sag = sc.pull * _maxPull;
    const l = _bx - _bodyHalf - 5;
    const r = _bx + _bodyHalf + 5;
    const top = _baseY - 13;
    const lip = _baseY + 2;
    if (sag > 1) {
      // The extra space made inside the bottle.
      final gain = Path()
        ..moveTo(_bx - _bodyHalf, _baseY)
        ..cubicTo(_bx - _bodyHalf + 40, _baseY + sag * 1.333, _bx + _bodyHalf - 40, _baseY + sag * 1.333,
            _bx + _bodyHalf, _baseY)
        ..close();
      canvas.drawPath(gain, Paint()..color = _Colors.sky400.withValues(alpha: 0.18));
      labDashedLine(
        canvas,
        const Offset(_bx - _bodyHalf + 6, _baseY),
        const Offset(_bx + _bodyHalf - 6, _baseY),
        Paint()
          ..strokeWidth = 1.5
          ..color = _bottleLine.withValues(alpha: 0.7),
        dash: 6,
        gap: 5,
      );
    }
    final sheet = Path()
      ..moveTo(l, top)
      ..lineTo(r, top)
      ..lineTo(r, lip)
      ..cubicTo(r - 44, lip + sag * 1.333, l + 44, lip + sag * 1.333, l, lip)
      ..close();
    canvas.drawPath(
      sheet,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(_Colors.latex, 0.25),
            _Colors.latex.withValues(alpha: 0.78),
            labShade(_Colors.latex, -0.2).withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromLTRB(l, top, r, lip + sag + 4)),
    );
    if (sag > 2) {
      final tension = _stroke(1.2, labShade(_Colors.latex, -0.4).withValues(alpha: 0.5 * sc.pull));
      for (final f in [-0.62, -0.32, 0.32, 0.62]) {
        canvas.drawLine(Offset(_bx + f * _bodyHalf, lip), Offset(_bx + f * 18, lip + sag * 0.92), tension);
      }
    }
    canvas.drawPath(sheet, _stroke(1.5, labShade(_Colors.latex, -0.45).withValues(alpha: 0.85)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(l - 1, top + 3, r + 1, top + 9), const Radius.circular(3)),
      Paint()..color = const Color(0xFF7C2D12),
    );
    final knob = Offset(_bx, lip + sag);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: knob + const Offset(0, 7), width: 9, height: 14), const Radius.circular(4)),
      Paint()..color = labShade(_Colors.latex, -0.2),
    );
    labSphere(canvas, knob + const Offset(0, 15), 6.5, labShade(_Colors.latex, -0.1));
  }

  /// Air rushing in through the tube into the balloons (blue) or back out
  /// (grey), with an arrow above the tube.
  void _air(Canvas canvas) {
    final sc = scene;
    final act = (sc.airFlow.abs() / 1.2).clamp(0.0, 1.0);
    if (act < 0.03) return;
    final inflow = sc.airFlow > 0;
    final color = inflow ? _Colors.sky400 : _airOut;
    const j = _tubeInside;
    final w = _balloonW(sc.inflation);
    final h = _balloonH(sc.inflation);
    for (final pt in sc.particles) {
      final s = _frac(pt.phase + sc.airPhase);
      final end = _forkEnd(j, pt.side);
      final inside = end + Offset((pt.u * 2 - 1) * w * 0.28, 11 + (0.25 + 0.6 * pt.v) * h);
      final pos = _along([const Offset(_bx, -6), Offset(_bx, j.dy - _stemLen), j, end, inside], s);
      final a = act * math.pow(math.sin(math.pi * s), 0.5).toDouble();
      canvas.drawCircle(pos, 6.5, Paint()..color = color.withValues(alpha: 0.2 * a));
      canvas.drawCircle(pos, 3.3, Paint()..color = color.withValues(alpha: 0.95 * a));
    }
    final top = Offset(_bx + 30, j.dy - _stemLen);
    labArrow(
      canvas,
      top + Offset(0, inflow ? -58 : -8),
      top + Offset(0, inflow ? -8 : -58),
      color: color.withValues(alpha: act),
      width: 4,
      head: 12,
    );
    if (showLabels) {
      labText(
        canvas,
        tr(inflow ? 'air_in' : 'air_out'),
        top + const Offset(14, -33),
        anchor: Alignment.centerLeft,
        size: 14,
        weight: FontWeight.w800,
        color: color,
        opacity: act,
      );
    }
  }

  /// Glowing drop targets for the part being dragged.
  void _targets(Canvas canvas) {
    final sc = scene;
    final pulse = 0.5 + 0.5 * math.sin(sc.time * 5);
    const y = _Colors.zslYellow;
    final ring = _stroke(2.5, y.withValues(alpha: 0.6 + 0.4 * pulse));
    switch (sc.drag) {
      case _Part.balloon0 || _Part.balloon1:
        for (var i = 0; i < 2; i++) {
          if (sc.balloons.any((b) => b.fork == i)) continue;
          final e = _forkEnd(sc.tube, i);
          labGlow(canvas, e, 34, y, intensity: 0.35 + 0.3 * pulse);
          labDashedPath(canvas, Path()..addOval(Rect.fromCircle(center: e, radius: 17 + 3 * pulse)), ring,
              dash: 5, gap: 4);
        }
      case _Part.tube || _Part.sheet:
        final r = Rect.fromCenter(
          center: const Offset(_bx, _baseY),
          width: _bodyHalf * 2 + 18,
          height: 26 + 6 * pulse,
        );
        final glow = sc.drag == _Part.tube ? 0.25 + 0.2 * pulse : 0.1 + 0.08 * pulse;
        labGlow(canvas, const Offset(_bx, _baseY), 130, y, intensity: glow);
        labDashedPath(canvas, Path()..addOval(r), ring);
        if (sc.drag == _Part.tube) {
          labArrow(canvas, const Offset(_bx - 120, _baseY + 50), const Offset(_bx - 120, _baseY + 6),
              color: y, width: 4);
        }
        if (showLabels) {
          labPill(
            canvas,
            tr(sc.drag == _Part.tube ? 'insert_here' : 'stretch_here'),
            const Offset(_bx - 132, _baseY + 30),
            anchor: Alignment.centerRight,
            background: const Color(0xE6713F12),
            border: y,
          );
        }
      default:
        break;
    }
  }

  void _labels(Canvas canvas) {
    final sc = scene;
    final done = sc.sheetOn;
    // Loose balloons on the bench.
    final loose = [
      for (final b in sc.balloons)
        if (b.fork == null && b.glide == null && sc.drag != (b == sc.balloons[0] ? _Part.balloon0 : _Part.balloon1)) b,
    ];
    if (loose.length == 2) {
      labPill(canvas, tr('lbl_balloons'), const Offset(108, 422), size: 14);
    } else if (loose.length == 1) {
      labPill(canvas, tr('lbl_balloon'), loose.first.pos + const Offset(30, -38), size: 14);
    }
    // Y-tube.
    if (sc.tubeInBottle) {
      _leaderTag(canvas, tr(done ? 'lbl_ytube_a' : 'lbl_ytube'), const Offset(_bx - 8, 74),
          const Offset(_bx - 104, 66), isDark);
    } else if (sc.drag != _Part.tube && sc.tubeGlide == null) {
      labPill(canvas, tr('lbl_ytube'), Offset(sc.tube.dx, sc.tube.dy - _stemLen - 20), size: 14);
    }
    // Bottle.
    _leaderTag(canvas, tr(done ? 'lbl_bottle_a' : 'lbl_bottle'), const Offset(_bx - 62, 180),
        const Offset(_bx - 104, 150), isDark);
    // Balloons in the bottle.
    if (sc.tubeInBottle) {
      final w = _balloonW(sc.inflation);
      _leaderTag(canvas, tr(done ? 'lbl_balloons_a' : 'lbl_balloons_in'), Offset(_bx - 46 - w * 0.42, 300),
          const Offset(_bx - 104, 266), isDark);
    }
    // Rubber sheet.
    if (done) {
      _leaderTag(canvas, tr('lbl_sheet_a'), Offset(_bx - 62, _baseY + sc.pull * _maxPull * 0.55 + 2),
          const Offset(_bx - 104, 412), isDark);
    } else if (sc.drag != _Part.sheet && sc.sheetGlide == null) {
      labPill(canvas, tr('lbl_sheet'), sc.sheet + const Offset(0, -34), size: 14);
    }
  }

  /// The "pull down" / "release" badge (indigo arrow icon from the spec).
  void _pullCue(Canvas canvas) {
    final sc = scene;
    if (!sc.sheetOn) return;
    final up = sc.step == 5 && sc.pulling;
    final down = sc.step == 4 && !sc.pulling;
    if (!up && !down) return;
    final bob = math.sin(sc.time * 5) * 4 * (up ? -1 : 1);
    final c = Offset(_bx + 62, _baseY + sc.pull * _maxPull * 0.6 + 34 + bob);
    labGlow(canvas, c, 30, _Colors.indigo500, intensity: 0.5);
    canvas.drawCircle(c, 15, Paint()..color = _Colors.indigo500);
    canvas.drawCircle(c, 15, _stroke(1.5, const Color(0xFFF8FAFC)));
    // 24x24 arrow icon: M12 4V20 M12 20L18 14 M12 20L6 14 (down) / mirrored (up).
    final o = c - const Offset(12, 12);
    final arrow = _stroke(2.4, const Color(0xFFF8FAFC));
    final tip = up ? 4.0 : 20.0;
    final tail = up ? 20.0 : 4.0;
    final wing = up ? 10.0 : 14.0;
    canvas.drawLine(o + Offset(12, tail), o + Offset(12, tip), arrow);
    canvas.drawLine(o + Offset(12, tip), o + Offset(18, wing), arrow);
    canvas.drawLine(o + Offset(12, tip), o + Offset(6, wing), arrow);
    if (showLabels) {
      labText(
        canvas,
        tr(up ? 'release' : 'pull_down'),
        c + const Offset(22, 0),
        anchor: Alignment.centerLeft,
        size: 13,
        weight: FontWeight.w800,
        color: Colors.white,
        background: _Colors.indigo600,
        radius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ModelPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

/// Scenario 2: front view of the human chest – rib cage, lungs, windpipe,
/// bronchi, diaphragm and a beating heart – with air particles, motion
/// cues, a legend and a lung volume trace.
class _ChestPainter extends CustomPainter {
  _ChestPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _BreathScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  static const double cx = _cx;

  Color get _bgTop => isDark ? const Color(0xFF0B1120) : const Color(0xFFEAF1F8);
  Color get _bgBottom => isDark ? const Color(0xFF111B2E) : const Color(0xFFDCE6F1);
  Color get _airOut => isDark ? _Colors.slate300 : _Colors.slate500;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = scene;
    final r = sc.rib;
    final d = sc.dia;
    _backdrop(canvas, size);
    _body(canvas, r);
    _spine(canvas);
    _lungs(canvas, r, d);
    _heart(canvas, d);
    _airways(canvas, d);
    _diaphragm(canvas, d);
    _ribCage(canvas, r);
    _fadeNeck(canvas);
    _particles(canvas, r, d);
    _cues(canvas, d);
    _legend(canvas);
    _trace(canvas);
    if (showLabels) _labels(canvas, d);
  }

  void _backdrop(Canvas canvas, Size size) {
    final b = labBleed(size);
    canvas.drawRect(
      b,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ).createShader(Rect.fromLTRB(0, 0, size.width, size.height)),
    );
    final grid = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? _Colors.sky400 : const Color(0xFF0369A1)).withValues(alpha: isDark ? 0.05 : 0.06);
    for (var x = -440.0; x <= 1480; x += 40) {
      canvas.drawLine(Offset(x, b.top), Offset(x, b.bottom), grid);
    }
    for (var y = -400.0; y <= 1000; y += 40) {
      canvas.drawLine(Offset(b.left, y), Offset(b.right, y), grid);
    }
    labGlow(canvas, const Offset(cx, 300), 330, isDark ? _Colors.indigo500 : Colors.white,
        intensity: isDark ? 0.2 : 0.75);
  }

  void _body(Canvas canvas, double r) {
    final skin = isDark ? const Color(0xFFE8B896) : const Color(0xFFF1C7A5);
    final a = isDark ? 0.16 : 0.5;
    final outline = _stroke(
      2,
      (isDark ? const Color(0xFFF5D0B5) : const Color(0xFFC0855E)).withValues(alpha: isDark ? 0.45 : 0.7),
    );
    for (final s in [-1.0, 1.0]) {
      final arm = Path()
        ..moveTo(cx + s * 142, 150)
        ..cubicTo(cx + s * 178, 150, cx + s * 202, 176, cx + s * 204, 222)
        ..cubicTo(cx + s * 208, 330, cx + s * 206, 470, cx + s * 204, 640)
        ..lineTo(cx + s * 162, 640)
        ..cubicTo(cx + s * 163, 470, cx + s * 162, 330, cx + s * 158, 236)
        ..close();
      canvas.drawPath(arm, Paint()..color = labShade(skin, -0.12).withValues(alpha: a));
      canvas.drawPath(arm, outline);
    }
    final e = 7 * r;
    final trunk = Path()
      ..moveTo(cx - 38, -90)
      ..lineTo(cx - 40, 94)
      ..cubicTo(cx - 58, 124, cx - 112, 128, cx - 146, 146)
      ..cubicTo(cx - 166, 156, cx - 160 - e, 200, cx - 157 - e, 250)
      ..cubicTo(cx - 154 - e, 330, cx - 150 - e * 0.5, 420, cx - 142, 470)
      ..lineTo(cx - 148, 640)
      ..lineTo(cx + 148, 640)
      ..lineTo(cx + 142, 470)
      ..cubicTo(cx + 150 + e * 0.5, 420, cx + 154 + e, 330, cx + 157 + e, 250)
      ..cubicTo(cx + 160 + e, 200, cx + 166, 156, cx + 146, 146)
      ..cubicTo(cx + 112, 128, cx + 58, 124, cx + 40, 94)
      ..lineTo(cx + 38, -90)
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 0.9,
          colors: [skin.withValues(alpha: math.min(1.0, a * 1.3)), skin.withValues(alpha: a * 0.7)],
        ).createShader(const Rect.fromLTRB(cx - 160, -90, cx + 160, 640)),
    );
    canvas.drawPath(trunk, outline);
  }

  void _spine(Canvas canvas) {
    final bone = isDark ? const Color(0xFFE7DCC8) : const Color(0xFFBFAA86);
    final paint = Paint()..color = bone.withValues(alpha: isDark ? 0.22 : 0.4);
    for (var y = 104.0; y < 600; y += 21) {
      final w = 22 + (y - 100) * 0.02;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, y), width: w, height: 15), const Radius.circular(5)),
        paint,
      );
    }
  }

  /// Outline of one lung; [s] = -1 is the lung on the viewer's left (the
  /// right lung), 1 the left lung with its cardiac notch.
  Path _lungPath(double s, double r, double d) {
    final apex = Offset(cx + s * 54, 122 - 5 * r);
    final lat = cx + s * (128 + 13 * r);
    final baseLat = cx + s * (134 + 8 * r);
    final medial = s < 0 ? 24.0 : 52.0;
    final p = Path()..moveTo(apex.dx, apex.dy);
    p.cubicTo(cx + s * (96 + 8 * r), apex.dy - 8, lat, 150, lat, 226);
    final yBase0 = _diaTop(baseLat, d) - 3;
    p.cubicTo(lat + s * 3, 300, baseLat + s * 2, yBase0 - 60, baseLat, yBase0);
    const n = 16;
    for (var i = 1; i <= n; i++) {
      final x = cx + s * _lerp(134 + 8 * r, medial, i / n);
      p.lineTo(x, _diaTop(x, d) - 3);
    }
    final yb = _diaTop(cx + s * medial, d) - 3;
    if (s < 0) {
      p.cubicTo(cx - 22, yb - 70, cx - 30, 230, cx - 30, 196);
      p.cubicTo(cx - 30, 150, apex.dx + 14, apex.dy, apex.dx, apex.dy);
    } else {
      p.cubicTo(cx + 64, yb - 22, cx + 92, 336 + 6 * d, cx + 82, 300 + 4 * d);
      p.cubicTo(cx + 72, 266, cx + 34, 252, cx + 32, 214);
      p.cubicTo(cx + 30, 160, apex.dx - 14, apex.dy, apex.dx, apex.dy);
    }
    p.close();
    return p;
  }

  void _lungs(Canvas canvas, double r, double d) {
    final air = (scene.volume / 0.5).clamp(0.0, 1.0);
    const edge = Color(0xFF9D174D);
    for (final s in [-1.0, 1.0]) {
      final path = _lungPath(s, r, d);
      final bounds = path.getBounds();
      canvas.drawPath(
        path.shift(const Offset(0, 4)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(s * 0.25, -0.35),
            radius: 0.95,
            colors: [
              Color.lerp(const Color(0xFFFBCFE8), const Color(0xFFFFF1F7), air)!,
              Color.lerp(const Color(0xFFF472B6), const Color(0xFFF9A8D4), air * 0.6)!,
              const Color(0xFFBE185D),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(bounds),
      );
      canvas.save();
      canvas.clipPath(path);
      final dot = _stroke(1, Colors.white.withValues(alpha: 0.16));
      for (var i = 0; i < _alveoli.length; i++) {
        final a = _alveoli[i];
        canvas.drawCircle(Offset(bounds.left + a.dx * bounds.width, bounds.top + a.dy * bounds.height), 3 + (i % 3), dot);
      }
      _tree(canvas, s, r, d);
      final fissure = _stroke(1.8, edge.withValues(alpha: 0.5));
      if (s < 0) {
        canvas.drawPath(
          Path()
            ..moveTo(cx - 140 - 13 * r, 236)
            ..quadraticBezierTo(cx - 100, 238, cx - 62, 250),
          fissure,
        );
        canvas.drawPath(
          Path()
            ..moveTo(cx - 122 - 10 * r, 186)
            ..quadraticBezierTo(cx - 70, 260, cx - 66, _diaTop(cx - 66, d) - 2),
          fissure,
        );
      } else {
        canvas.drawPath(
          Path()
            ..moveTo(cx + 124 + 10 * r, 190)
            ..quadraticBezierTo(cx + 92, 270, cx + 104, _diaTop(cx + 104, d) - 2),
          fissure,
        );
      }
      if (air > 0.01) {
        labGlow(canvas, bounds.center, bounds.width * 0.9, const Color(0xFFE0F2FE), intensity: 0.35 * air);
      }
      canvas.restore();
      canvas.drawPath(path, _stroke(2, edge.withValues(alpha: 0.85)));
    }
  }

  void _tree(Canvas canvas, double s, double r, double d) {
    final hil = Offset(cx + s * 52, 238 + 4 * d);
    final branches = s < 0 ? _treeRight : _treeLeft;
    final sx = 1 + 0.09 * r;
    final down = 1 + 0.2 * d;
    final up = 1 + 0.03 * r;
    Offset map(Offset o) => hil + Offset(o.dx * sx, o.dy * (o.dy > 0 ? down : up));
    final paint = _stroke(1, const Color(0xFFFDF2F8).withValues(alpha: 0.6));
    for (final b in branches) {
      paint.strokeWidth = b.$3;
      canvas.drawLine(map(b.$1), map(b.$2), paint);
    }
  }

  void _airways(Canvas canvas, double d) {
    final car = Offset(cx, 198 + 3 * d);
    final hr = Offset(cx - 52, 238 + 4 * d);
    final hl = Offset(cx + 52, 236 + 4 * d);
    final tube = Path()
      ..moveTo(cx, -100)
      ..lineTo(car.dx, car.dy);
    final br = Path()
      ..moveTo(hr.dx, hr.dy)
      ..quadraticBezierTo(cx - 24, car.dy + 6, car.dx, car.dy)
      ..quadraticBezierTo(cx + 28, car.dy + 4, hl.dx, hl.dy);
    const edge = Color(0xFFBE185D);
    const wall = Color(0xFFFCE7F3);
    canvas.drawPath(tube, _stroke(27, edge.withValues(alpha: 0.9)));
    canvas.drawPath(br, _stroke(18, edge.withValues(alpha: 0.9)));
    canvas.drawPath(tube, _stroke(23, wall));
    canvas.drawPath(br, _stroke(14, wall));
    final ring = _stroke(3, const Color(0xFFF0ABCB));
    for (var y = 76.0; y < car.dy - 10; y += 11) {
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, y), width: 22, height: 7), 0, math.pi, false, ring);
    }
    canvas.drawPath(tube, _stroke(7, const Color(0xFF9D174D).withValues(alpha: 0.28)));
    canvas.drawPath(br, _stroke(5, const Color(0xFF9D174D).withValues(alpha: 0.28)));
    // Larynx (voice box) with the Adam's apple notch.
    final lar = Path()
      ..moveTo(cx - 20, 30)
      ..lineTo(cx + 20, 30)
      ..lineTo(cx + 15, 64)
      ..quadraticBezierTo(cx, 72, cx - 15, 64)
      ..close();
    canvas.drawPath(lar, Paint()..color = const Color(0xFFFBCFE8));
    canvas.drawPath(lar, _stroke(2, edge.withValues(alpha: 0.8)));
    canvas.drawPath(
      Path()
        ..moveTo(cx - 7, 32)
        ..lineTo(cx, 44)
        ..lineTo(cx + 7, 32),
      _stroke(1.8, edge.withValues(alpha: 0.7)),
    );
  }

  void _heart(Canvas canvas, double d) {
    final beat = _beat(scene.time);
    final c = Offset(cx + 18, 298 + 12 * d);
    labGlow(canvas, c, 80, _Colors.red, intensity: (isDark ? 0.22 : 0.12) + 0.3 * beat);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    // Pulmonary arteries to the lungs, aorta and vena cava.
    final pa = Path()
      ..moveTo(10, -30)
      ..quadraticBezierTo(6, -48, -6, -54);
    canvas.drawPath(pa, _stroke(12, const Color(0xFF312E81)));
    canvas.drawPath(pa, _stroke(9, _Colors.indigo500));
    canvas.drawLine(const Offset(-32, -24), const Offset(-32, -76), _stroke(13, const Color(0xFF1E3A8A)));
    canvas.drawLine(const Offset(-32, -24), const Offset(-32, -76), _stroke(9.5, _Colors.blue));
    final ao = Path()
      ..moveTo(-4, -30)
      ..lineTo(-6, -64)
      ..cubicTo(-6, -92, 40, -94, 42, -64)
      ..lineTo(44, -34);
    for (final x in [6.0, 18.0, 30.0]) {
      canvas.drawLine(Offset(x, -80), Offset(x - 2, -106), _stroke(6, const Color(0xFF7F1D1D)));
      canvas.drawLine(Offset(x, -80), Offset(x - 2, -106), _stroke(4, const Color(0xFFDC2626)));
    }
    canvas.drawPath(ao, _stroke(15, const Color(0xFF7F1D1D)));
    canvas.drawPath(ao, _stroke(11.5, const Color(0xFFDC2626)));
    canvas.drawPath(ao.shift(const Offset(-2, -2)), _stroke(2.5, Colors.white.withValues(alpha: 0.25)));
    // Heart body (apex to the lower right), pulsing.
    canvas.scale(1 + 0.07 * beat);
    canvas.rotate(-0.42);
    final body = Path()
      ..moveTo(0, -40)
      ..cubicTo(26, -46, 46, -30, 44, -6)
      ..cubicTo(42, 20, 22, 40, 4, 50)
      ..cubicTo(-14, 42, -40, 22, -44, -4)
      ..cubicTo(-46, -28, -24, -46, 0, -40)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [Color(0xFFFCA5A5), Color(0xFFDC2626), Color(0xFF7F1D1D)],
          stops: [0, 0.45, 1],
        ).createShader(const Rect.fromLTRB(-46, -46, 46, 50)),
    );
    canvas.drawPath(body, _stroke(2, const Color(0xFF7F1D1D)));
    final groove = Path()
      ..moveTo(14, -38)
      ..cubicTo(24, -10, 18, 20, 6, 46);
    canvas.drawPath(groove, _stroke(2.4, const Color(0xFF7F1D1D).withValues(alpha: 0.7)));
    canvas.drawPath(groove, _stroke(1.2, const Color(0xFFFDE68A).withValues(alpha: 0.55)));
    canvas.drawPath(
      Path()
        ..moveTo(-30, -30)
        ..quadraticBezierTo(-36, 0, -20, 26),
      _stroke(1.2, const Color(0xFFFDE68A).withValues(alpha: 0.45)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-16, -18), width: 20, height: 12),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.restore();
  }

  void _diaphragm(Canvas canvas, double d) {
    final still = scene.wDia < 0.5;
    final top = <Offset>[];
    final bot = <Offset>[];
    for (var i = 0; i <= 40; i++) {
      final u = -1 + 2 * i / 40;
      final x = cx + u * 142;
      final y = _diaTop(x, d);
      top.add(Offset(x, y));
      bot.add(Offset(x, y + 13 + 9 * u * u));
    }
    // Crura reaching down to the spine.
    for (final s in [-1.0, 1.0]) {
      final cr = Path()
        ..moveTo(cx + s * 52, _diaTop(cx + s * 52, d) + 12)
        ..quadraticBezierTo(cx + s * 30, 462 + 8 * d, cx + s * 12, 500)
        ..lineTo(cx + s * 6, 500)
        ..quadraticBezierTo(cx + s * 20, 462 + 8 * d, cx + s * 34, _diaTop(cx + s * 34, d) + 12)
        ..close();
      canvas.drawPath(cr, Paint()..color = const Color(0xFFB91C1C).withValues(alpha: 0.5));
    }
    final band = Path()..addPolygon([...top, ...bot.reversed], true);
    final bounds = band.getBounds();
    canvas.drawPath(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF87171), Color(0xFFB91C1C)],
        ).createShader(bounds),
    );
    canvas.save();
    canvas.clipPath(band);
    final tendon = Rect.fromLTRB(cx - 44, bounds.top - 4, cx + 44, bounds.bottom + 4);
    canvas.drawRect(
      tendon,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x00FEE2E2), Color(0xCCFEE2E2), Color(0x00FEE2E2)],
        ).createShader(tendon),
    );
    final fibre = Paint()
      ..strokeWidth = 1.1
      ..color = const Color(0xFF7F1D1D).withValues(alpha: 0.35);
    for (var i = 1; i < 40; i += 2) {
      if ((i - 20).abs() > 5) canvas.drawLine(top[i], bot[i], fibre);
    }
    canvas.restore();
    canvas.drawPath(Path()..addPolygon(top, false), _stroke(2.2, const Color(0xFFFCA5A5)));
    canvas.drawPath(band, _stroke(1.2, const Color(0xFF7F1D1D).withValues(alpha: 0.7)));
    if (still) {
      canvas.drawPath(band, Paint()..color = (isDark ? Colors.black : Colors.white).withValues(alpha: 0.3));
    }
  }

  void _ribCage(Canvas canvas, double r) {
    final still = scene.wRib < 0.5;
    final bone = isDark ? const Color(0xFFF3EAD7) : const Color(0xFFEFE3CA);
    final edge = isDark ? const Color(0xFF8B7B5E) : const Color(0xFF9C8763);
    const cart = Color(0xFFD6E4F0);
    final alpha = still ? 0.5 : 1.0;
    final arch = <double, List<Offset>>{-1: [], 1: []};
    for (var i = 0; i < 10; i++) {
      for (final s in [-1.0, 1.0]) {
        final ay = (i < 7 ? 156 + i * 21.0 : 318 + (i - 7) * 26.0) - 5 * r;
        final ax = cx + s * (i < 7 ? 13.0 : 34.0 + (i - 7) * 34.0);
        final w = _ribW[i] + 10 * r;
        final drop = 26 + i * 2.2;
        final by = ay + drop - 15 * r * (0.6 + i * 0.05);
        final bx = cx + s * w;
        final front = Path()
          ..moveTo(ax, ay)
          ..cubicTo(ax + s * (w - (ax - cx).abs()) * 0.5, ay - 8, bx, by - drop * 0.9 - 6, bx, by);
        final back = Path()
          ..moveTo(bx, by)
          ..cubicTo(bx, by + 16, cx + s * (w - 4), by + 28, cx + s * (w - 22), by + 36);
        // The front of the cage is cut away (faded towards the breastbone)
        // so the lungs and heart behind it stay visible.
        final span = Rect.fromLTRB(math.min(ax, bx) - 1, ay - 12, math.max(ax, bx) + 1, by + 12);
        Paint fade(double width, Color c) => Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: s < 0 ? Alignment.centerRight : Alignment.centerLeft,
            end: s < 0 ? Alignment.centerLeft : Alignment.centerRight,
            colors: [c.withValues(alpha: c.a * 0.08), c.withValues(alpha: c.a * 0.5), c],
            stops: const [0, 0.5, 1],
          ).createShader(span);
        canvas.drawPath(back, _stroke(5, bone.withValues(alpha: 0.28 * alpha)));
        canvas.drawPath(front.shift(const Offset(0, 2.5)), fade(8, Colors.black.withValues(alpha: 0.22 * alpha)));
        canvas.drawPath(front, fade(8.5, edge.withValues(alpha: alpha)));
        canvas.drawPath(front, fade(6.2, bone.withValues(alpha: alpha)));
        canvas.drawPath(front.shift(const Offset(0, -1.4)), fade(1.5, Colors.white.withValues(alpha: 0.5 * alpha)));
        if (i >= 7) arch[s]!.add(Offset(ax, ay));
      }
    }
    // Costal margin: the cartilage arch of the lower ribs.
    for (final s in [-1.0, 1.0]) {
      final p = Path()..addPolygon([Offset(cx + s * 8, 316 - 5 * r), ...arch[s]!], false);
      canvas.drawPath(p, _stroke(6, cart.withValues(alpha: 0.3 * alpha)));
    }
    // Breastbone, faint like the cut-away front of the cage.
    final sy = -5 * r;
    final stern = Path()
      ..moveTo(cx - 16, 140 + sy)
      ..lineTo(cx + 16, 140 + sy)
      ..lineTo(cx + 12, 182 + sy)
      ..lineTo(cx + 10, 298 + sy)
      ..lineTo(cx + 4, 314 + sy)
      ..lineTo(cx, 326 + sy)
      ..lineTo(cx - 4, 314 + sy)
      ..lineTo(cx - 10, 298 + sy)
      ..lineTo(cx - 12, 182 + sy)
      ..close();
    canvas.drawPath(stern, Paint()..color = bone.withValues(alpha: 0.2 * alpha));
    canvas.drawPath(stern, _stroke(1.3, edge.withValues(alpha: 0.5 * alpha)));
    canvas.drawLine(Offset(cx - 12, 182 + sy), Offset(cx + 12, 182 + sy), _stroke(1.2, edge.withValues(alpha: 0.4)));
    // Collar bones.
    for (final s in [-1.0, 1.0]) {
      final cl = Path()
        ..moveTo(cx + s * 14, 146 + sy)
        ..cubicTo(cx + s * 60, 160, cx + s * 108, 124, cx + s * 152, 136);
      canvas.drawPath(cl, _stroke(11, edge));
      canvas.drawPath(cl, _stroke(8.5, bone));
      canvas.drawPath(cl.shift(const Offset(0, -1.5)), _stroke(1.8, Colors.white.withValues(alpha: 0.5)));
    }
  }

  /// Softens the top of the neck so it never ends in a hard edge.
  void _fadeNeck(Canvas canvas) {
    const r = Rect.fromLTRB(cx - 80, -140, cx + 80, 34);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgTop, _bgTop.withValues(alpha: 0)],
          stops: const [0, 0.55, 1],
        ).createShader(r),
    );
  }

  void _particles(Canvas canvas, double r, double d) {
    final sc = scene;
    final act = (sc.flow.abs() / 0.3).clamp(0.0, 1.0);
    if (act < 0.03) return;
    final color = sc.flow > 0 ? _Colors.sky400 : _airOut;
    final car = Offset(cx, 198 + 3 * d);
    for (final pt in sc.particles) {
      final s = pt.side == 0 ? -1.0 : 1.0;
      final hil = Offset(cx + s * 52, 237 + 4 * d);
      final dy = -78 + 175 * pt.v;
      final reach = 58 * (1 - 0.35 * math.max(0.0, -dy) / 78);
      final end = hil + Offset(s * (10 + reach * pt.u) * (1 + 0.1 * r), dy * (dy > 0 ? 1 + 0.18 * d : 1));
      final t = _frac(pt.phase + sc.phase2);
      final pos = _along([Offset(cx, -40), Offset(cx, 60), car, hil, end], t);
      final a = act * math.pow(math.sin(math.pi * t), 0.5).toDouble();
      canvas.drawCircle(pos, 7, Paint()..color = color.withValues(alpha: 0.2 * a));
      canvas.drawCircle(pos, 3.6, Paint()..color = color.withValues(alpha: 0.95 * a));
    }
  }

  /// Arrows for the air at the windpipe, the ribs and the diaphragm.
  void _cues(Canvas canvas, double d) {
    final sc = scene;
    final act = (sc.flow.abs() / 0.25).clamp(0.0, 1.0);
    if (act > 0.05) {
      final inflow = sc.flow > 0;
      final col = inflow ? _Colors.sky400 : _airOut;
      const a = Offset(cx + 48, 4);
      const b = Offset(cx + 48, 56);
      labArrow(canvas, inflow ? a : b, inflow ? b : a, color: col.withValues(alpha: act), width: 4, head: 12);
      if (showLabels) {
        labText(canvas, tr(inflow ? 'air_in' : 'air_out'), const Offset(cx + 62, 30),
            anchor: Alignment.centerLeft, size: 14, weight: FontWeight.w800, color: col, opacity: act);
      }
    }
    final ra = (sc.ribVel.abs() / 0.45).clamp(0.0, 1.0);
    if (ra > 0.05) {
      final up = sc.ribVel > 0;
      final col = up ? _Colors.sky400 : _Colors.amber400;
      for (final s in [-1.0, 1.0]) {
        final from = Offset(cx + s * 176, 300);
        final to = Offset(cx + s * 200, 260);
        labArrow(canvas, up ? from : to, up ? to : from, color: col.withValues(alpha: ra), width: 4, head: 12);
      }
      if (showLabels) {
        labText(canvas, tr(up ? 'ribs_up' : 'ribs_down'), const Offset(cx - 214, 262),
            anchor: Alignment.centerRight, size: 13.5, weight: FontWeight.w800, color: col, opacity: ra);
      }
    }
    final da = (sc.diaVel.abs() / 0.45).clamp(0.0, 1.0);
    if (da > 0.05) {
      final down = sc.diaVel > 0;
      final col = down ? _Colors.sky400 : _Colors.amber400;
      for (final s in [-1.0, 1.0]) {
        final x = cx + s * 86;
        final y0 = _diaTop(x, d) + 26;
        labArrow(canvas, Offset(x, down ? y0 : y0 + 36), Offset(x, down ? y0 + 36 : y0),
            color: col.withValues(alpha: da), width: 4, head: 11);
      }
      if (showLabels) {
        labText(canvas, tr(down ? 'dia_down' : 'dia_up'), Offset(cx, _diaTop(cx, d) + 80),
            size: 13.5, weight: FontWeight.w800, color: col, opacity: da);
      }
    }
  }

  void _panel(Canvas canvas, Rect r) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(12));
    canvas.drawRRect(
      rr.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(rr, Paint()..color = isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF));
    canvas.drawRRect(rr, _stroke(1.5, isDark ? _Colors.slate700 : _Colors.slate300));
  }

  void _legend(Canvas canvas) {
    const r = Rect.fromLTWH(20, 18, 200, 62);
    _panel(canvas, r);
    for (var i = 0; i < 2; i++) {
      final y = r.top + 18 + i * 26.0;
      final c = i == 0 ? _Colors.sky400 : _airOut;
      final dot = Offset(r.left + 18, y);
      labGlow(canvas, dot, 11, c, intensity: 0.6);
      canvas.drawCircle(dot, 5, Paint()..color = c);
      labText(
        canvas,
        tr(i == 0 ? 'legend_in' : 'legend_out'),
        Offset(r.left + 32, y),
        anchor: Alignment.centerLeft,
        size: 13,
        weight: FontWeight.w700,
        color: isDark ? _Colors.slate200 : _Colors.slate700,
        maxWidth: r.width - 40,
      );
    }
  }

  /// Lung volume over the last 12 seconds (one point every 0.05 s).
  void _trace(Canvas canvas) {
    const r = Rect.fromLTWH(20, 300, 206, 205);
    _panel(canvas, r);
    labText(canvas, tr('trace_title'), Offset(r.left + 12, r.top + 15),
        anchor: Alignment.centerLeft, size: 13, weight: FontWeight.w800, color: _Colors.zslYellow, maxWidth: r.width - 24);
    final plot = Rect.fromLTRB(r.left + 14, r.top + 34, r.right - 14, r.bottom - 26);
    final muted = isDark ? _Colors.slate400 : _Colors.slate500;
    final grid = Paint()
      ..strokeWidth = 1
      ..color = muted.withValues(alpha: 0.25);
    for (var i = 0; i <= 2; i++) {
      final y = plot.bottom - plot.height * i / 2;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
    }
    labText(canvas, '+0.5 ${tr('litre')}', Offset(plot.left + 2, plot.top + 1 + plot.height * (0.05 / 0.55)),
        anchor: Alignment.bottomLeft, size: 10.5, weight: FontWeight.w700, color: muted);
    final data = scene.trace;
    if (data.length > 1) {
      final path = Path();
      final fill = Path();
      for (var i = 0; i < data.length; i++) {
        final x = plot.right - (data.length - 1 - i) / 239 * plot.width;
        final y = plot.bottom - (data[i] / 0.55).clamp(0.0, 1.0) * plot.height;
        if (i == 0) {
          path.moveTo(x, y);
          fill
            ..moveTo(x, plot.bottom)
            ..lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fill.lineTo(x, y);
        }
      }
      fill
        ..lineTo(plot.right, plot.bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Colors.sky400.withValues(alpha: 0.35), _Colors.sky400.withValues(alpha: 0.02)],
          ).createShader(plot),
      );
      canvas.drawPath(path, _stroke(2.5, _Colors.sky400));
      final last = Offset(plot.right, plot.bottom - (data.last / 0.55).clamp(0.0, 1.0) * plot.height);
      labGlow(canvas, last, 12, _Colors.sky400, intensity: 0.7);
      canvas.drawCircle(last, 4, Paint()..color = _Colors.sky400);
    }
    labText(canvas, tr('trace_time'), Offset(plot.right - 18, r.bottom - 12),
        anchor: Alignment.centerRight, size: 11, weight: FontWeight.w700, color: muted);
    labArrow(canvas, Offset(plot.right - 15, r.bottom - 12), Offset(plot.right, r.bottom - 12),
        color: muted, width: 1.6, head: 6);
  }

  void _labels(Canvas canvas, double d) {
    final sc = scene;
    _leaderTag(canvas, tr('lbl_trachea'), const Offset(cx - 12, 100), const Offset(cx - 58, 96), isDark);
    _leaderTag(canvas, tr('lbl_bronchi'), Offset(cx - 30, 222 + 3 * d), const Offset(cx - 64, 192), isDark);
    _leaderTag(canvas, tr('lbl_ribs'), Offset(cx - 108, 196 - 4 * sc.rib), const Offset(cx - 150, 168), isDark);
    labPill(canvas, tr('lbl_lungs'), Offset(cx - 88, 304 + 8 * d), size: 14.5);
    _leaderTag(canvas, tr('lbl_heart'), Offset(cx + 50, 334 + 12 * d), Offset(cx + 100, 366 + 12 * d), isDark,
        align: Alignment.centerLeft);
    labPill(canvas, tr('lbl_diaphragm'), Offset(cx, _diaTop(cx, d) + 50), size: 14.5);
    if (sc.wRib < 0.5) {
      labPill(canvas, tr('held_still'), const Offset(cx - 150, 196), anchor: Alignment.centerRight, size: 12,
          background: const Color(0xE6475569));
    }
    if (sc.wDia < 0.5) {
      labPill(canvas, tr('held_still'), Offset(cx, _diaTop(cx, d) + 80), size: 12,
          background: const Color(0xE6475569));
    }
  }

  @override
  bool shouldRepaint(covariant _ChestPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

// ============================================================= LAB FRAMEWORK
// The lab screen used by every activity: shell (sidebar, curtain, canvas
// tools, popups, settings), controller, widgets, painting helpers and shell
// strings. Kept in this file so the activity stands alone.

// =========================================================== LAB STYLE TYPES

// The shapes of a lab's audio, theme and font. The values themselves (which
// tones, which colours, which font) live in every activity file, in its
// AUDIO / THEME / FONT sections; the shared shell only reads them.

/// A sound effect. Each activity declares its own tones (an enum that
/// implements this) and plays them with its own player.
abstract interface class LabTone {
  void play();
}

/// One lab's light or dark palette (the HTML `:root` / `.dark` variables).
@immutable
class LabPalette {
  const LabPalette({
    required this.isDark,
    required this.bg,
    required this.panel,
    required this.border,
    required this.card,
    required this.cardBorder,
    required this.canvasBg,
    required this.text,
    required this.textStrong,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.danger,
    required this.onDanger,
    required this.info,
    required this.popupBg,
    required this.popupHeader,
    required this.dialogBg,
    required this.toastBg,
    required this.toastText,
    required this.curtainBg,
    required this.curtainGlow,
    required this.curtainText,
    required this.curtainMuted,
    required this.curtainIcon,
    required this.buttonBg,
    required this.buttonIcon,
    required this.buttonBorder,
    required this.readoutBg,
    required this.readoutBorder,
    required this.readoutIcon,
    required this.labelBg,
    required this.labelText,
  });

  final bool isDark;

  /// Page background (`--bg-primary`).
  final Color bg;

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  final Color panel;
  final Color border;

  /// Inset cards inside panels.
  final Color card;
  final Color cardBorder;

  /// Canvas background (`bg-slate-100 dark:bg-slate-900`).
  final Color canvasBg;

  final Color text;
  final Color textStrong;
  final Color textMuted;

  /// Brand colour (ZSL yellow) and the text drawn on it.
  final Color accent;
  final Color onAccent;

  /// Secondary buttons (e.g. "Continue") and their text.
  final Color primary;
  final Color onPrimary;

  /// Completed scenario, error toast (and its text), completed step.
  final Color success;
  final Color danger;
  final Color onDanger;
  final Color info;

  /// Success popup body and header, settings dialog.
  final Color popupBg;
  final Color popupHeader;
  final Color dialogBg;

  /// Feedback toast.
  final Color toastBg;
  final Color toastText;

  /// Intro curtain with "Enter Lab".
  final Color curtainBg;
  final Color curtainGlow;
  final Color curtainText;
  final Color curtainMuted;
  final Color curtainIcon;

  /// Fixed menu and back buttons.
  final Color buttonBg;
  final Color buttonIcon;
  final Color buttonBorder;

  /// Dark HUD readouts (clocks, meters, timers).
  final Color readoutBg;
  final Color readoutBorder;
  final Color readoutIcon;

  /// Dark chip used for floating object labels in the scenes.
  final Color labelBg;
  final Color labelText;

  /// Material theme for the lab's widgets, in [font].
  ThemeData theme(LabFont font) => ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        useMaterial3: true,
        fontFamily: font.family,
        fontFamilyFallback: font.fallback,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: accent,
        ),
        scaffoldBackgroundColor: bg,
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          thumbColor: accent,
        ),
      );
}

/// One lab's font: family (`null` = the app's font, which on devices is the
/// platform font with Devanagari for Hindi) and the sidebar text size
/// setting (px).
@immutable
class LabFont {
  const LabFont({
    this.family,
    this.fallback,
    this.size = 15,
    this.minSize = 12,
    this.maxSize = 24,
  });

  final String? family;
  final List<String>? fallback;

  /// Default, smallest and largest sidebar text size (HTML
  /// `--sidebar-font-size`).
  final double size;
  final double minSize;
  final double maxSize;

  /// This font, or the app's font from [ambient] when [family] is null.
  LabFont orAmbient(TextStyle? ambient) => family != null
      ? this
      : LabFont(
          family: ambient?.fontFamily,
          fallback: fallback ?? ambient?.fontFamilyFallback,
          size: size,
          minSize: minSize,
          maxSize: maxSize,
        );

  /// The font of the lab on screen, used for canvas text. Set by the shell
  /// from the lab's [LabStyle].
  static LabFont active = const LabFont();
}

/// What an activity hands the shared shell: the tones it plays for shell
/// events, its light / dark palettes and its font.
@immutable
class LabStyle {
  const LabStyle({
    required this.click,
    required this.toggle,
    required this.correct,
    required this.wrong,
    required this.success,
    required this.scenario,
    required this.curtain,
    required this.dark,
    required this.light,
    this.font = const LabFont(),
    this.releaseAudio,
  });

  /// Button click, sidebar toggle, right / wrong feedback, success popup,
  /// scenario change and the intro curtain.
  final LabTone click;
  final LabTone toggle;
  final LabTone correct;
  final LabTone wrong;
  final LabTone success;
  final LabTone scenario;
  final LabTone curtain;

  final LabPalette dark;
  final LabPalette light;
  final LabFont font;

  /// Frees the lab's audio players; called when the lab closes.
  final VoidCallback? releaseAudio;

  LabPalette palette(bool isDark) => isDark ? dark : light;
}

/// Gives the shell's widgets the open lab's style and current palette.
class LabStyleScope extends InheritedWidget {
  const LabStyleScope({
    super.key,
    required this.style,
    required this.palette,
    required super.child,
  });

  final LabStyle style;
  final LabPalette palette;

  static LabStyleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LabStyleScope>();

  static LabStyleScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No LabStyleScope: build lab widgets inside a LabShell.');
    return scope!;
  }

  @override
  bool updateShouldNotify(LabStyleScope oldWidget) =>
      style != oldWidget.style || palette != oldWidget.palette;
}

/// Responsive helpers for landscape phones through to tablets.
extension LabResponsive on BuildContext {
  /// UI scale: ~0.8 on small landscape phones, 1.0 at 400dp short side,
  /// capped at 1.45 on large tablets.
  double get labScale {
    final shortest = MediaQuery.sizeOf(this).shortestSide;
    return (shortest / 400).clamp(0.8, 1.45);
  }
}

// ================================================================ LAB MODELS

/// One step of a scenario (matches the HTML `steps: [{id, concept, action,
/// observation}]` entries). Steps are numbered from 1 by their position.
@immutable
class LabStep {
  const LabStep({
    required this.concept,
    required this.action,
    this.observation = '',
  });

  final String concept;
  final String action;
  final String observation;
}

/// A scenario's mission objective and steps for one language.
@immutable
class LabScenarioData {
  const LabScenarioData({
    required this.objective,
    required this.steps,
    this.title = '',
  });

  final String title;
  final String objective;
  final List<LabStep> steps;
}

/// A dynamic action button. Shown in the sidebar's action area and, while
/// the sidebar is collapsed, inside the floating mission card.
@immutable
class LabAction {
  const LabAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.foreground,
    this.enabled = true,
    this.highlight = false,
    this.sound,
    this.silent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Button fill. Defaults to the ZSL yellow.
  final Color? color;

  /// Text / icon colour. Defaults to a readable colour for [color].
  final Color? foreground;
  final bool enabled;

  /// Pulsing glow, like the HTML `.action-btn` animation.
  final bool highlight;

  /// Played on tap; `null` plays the lab's click tone.
  final LabTone? sound;

  /// No tap sound (when [onTap] plays its own).
  final bool silent;
}

/// Content of the draggable, scrollable success / observation popup.
@immutable
class LabPopupContent {
  const LabPopupContent({
    required this.title,
    this.heading,
    this.body,
    this.extra,
    this.actions = const [],
    this.icon = Icons.check_circle,
    this.accent,
  });

  final String title;

  /// Small uppercase heading above [body] (e.g. "Observation").
  final String? heading;
  final String? body;

  /// Optional extra widget (tables, result chips...) below [body].
  final Widget? extra;
  final List<LabAction> actions;
  final IconData icon;
  final Color? accent;
}

/// Popup content is rebuilt on every frame so that a language switch
/// re-translates an open popup.
typedef LabPopupBuilder = LabPopupContent Function();

// ========================================================= LAB SHELL STRINGS

// English / Hindi localisation helpers.

enum LabLang {
  en('EN'),
  hi('हि');

  const LabLang(this.badge);

  /// Short text shown on the language toggle button.
  final String badge;

  /// Key used in the `{'en': {...}, 'hi': {...}}` string tables.
  String get code => name;

  LabLang get next => this == LabLang.en ? LabLang.hi : LabLang.en;
}

/// A string table in the same shape as the HTML `i18n` objects:
/// `{'en': {'key': 'text'}, 'hi': {'key': 'पाठ'}}`.
typedef LabStringTable = Map<String, Map<String, String>>;

/// Looks [key] up in [table] for [lang], falling back to English, then to
/// the key itself so a missing translation is visible but never crashes.
String labTr(LabStringTable table, LabLang lang, String key) {
  return table[lang.code]?[key] ?? table['en']?[key] ?? key;
}

/// Replaces `{name}` placeholders in [template] with [values].
String labFormat(String template, Map<String, Object> values) {
  var out = template;
  values.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
  return out;
}

/// Strings used by the shared lab shell (header, sidebar, tools, settings,
/// popups, footer). Activity specific strings live in each activity file.
const LabStringTable kLabCommonStrings = {
  'en': {
    'enter_lab': 'Enter Lab',
    'select_scenario': 'Select Scenario',
    'mission_obj': 'Mission Objective',
    'target_output': 'Target Output',
    'curr_obj': 'Current Objective',
    'step': 'Step',
    'of': 'of',
    'concept_focus': 'Concept Focus:',
    'action': 'Action:',
    'actions': 'Actions',
    'controls': 'Lab Controls',
    'settings': 'Settings',
    'theme': 'Theme',
    'light_mode': 'Light Mode',
    'dark_mode': 'Dark Mode',
    'font_size': 'Font Size',
    'on': 'On',
    'off': 'Off',
    'toggle_language': 'Toggle Language',
    'reset_lab': 'Reset Lab',
    'back_home': 'Back to Home',
    'menu': 'Menu',
    'tool_labels': 'Toggle Labels',
    'tool_lock': 'Lock / Unlock Camera',
    'tool_pan': 'Pan Mode',
    'tool_reset_view': 'Reset View',
    'tool_zoom_in': 'Zoom In',
    'tool_zoom_out': 'Zoom Out',
    'close': 'Close',
    'btn_continue': 'Continue',
    'btn_restart': 'Restart Lab',
    'obs_complete': 'Observation Complete',
    'sci_conclusion': 'Scientific Conclusion',
    'lbl_observation': 'Observation',
    'success': 'Success!',
    'msg_scenario_complete': 'Scenario Complete! Please select the next scenario.',
    'msg_all_complete': 'All scenarios complete! Great work.',
    'completed': 'Completed',
    'minimize': 'Minimize',
    'expand': 'Expand',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
  },
  'hi': {
    'enter_lab': 'लैब में प्रवेश करें',
    'select_scenario': 'परिदृश्य चुनें',
    'mission_obj': 'मिशन का उद्देश्य',
    'target_output': 'लक्ष्य परिणाम',
    'curr_obj': 'वर्तमान उद्देश्य',
    'step': 'चरण',
    'of': 'में से',
    'concept_focus': 'अवधारणा:',
    'action': 'कार्य:',
    'actions': 'कार्य',
    'controls': 'लैब नियंत्रण',
    'settings': 'सेटिंग्स',
    'theme': 'थीम',
    'light_mode': 'लाइट मोड',
    'dark_mode': 'डार्क मोड',
    'font_size': 'फ़ॉन्ट का आकार',
    'on': 'चालू',
    'off': 'बंद',
    'toggle_language': 'भाषा बदलें',
    'reset_lab': 'लैब रीसेट करें',
    'back_home': 'होम पर वापस जाएँ',
    'menu': 'मेनू',
    'tool_labels': 'लेबल दिखाएँ / छिपाएँ',
    'tool_lock': 'कैमरा लॉक / अनलॉक',
    'tool_pan': 'पैन मोड',
    'tool_reset_view': 'दृश्य रीसेट करें',
    'tool_zoom_in': 'ज़ूम इन',
    'tool_zoom_out': 'ज़ूम आउट',
    'close': 'बंद करें',
    'btn_continue': 'जारी रखें',
    'btn_restart': 'लैब फिर से शुरू करें',
    'obs_complete': 'अवलोकन पूर्ण',
    'sci_conclusion': 'वैज्ञानिक निष्कर्ष',
    'lbl_observation': 'अवलोकन',
    'success': 'सफलता!',
    'msg_scenario_complete': 'परिदृश्य पूर्ण! कृपया अगला परिदृश्य चुनें।',
    'msg_all_complete': 'सभी परिदृश्य पूर्ण! बहुत बढ़िया।',
    'completed': 'पूर्ण',
    'minimize': 'छोटा करें',
    'expand': 'बड़ा करें',
    'footer': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
  },
};

// ============================================================ LAB CONTROLLER

/// Transient feedback message (the HTML `#feedback-toast`).
@immutable
class LabToast {
  const LabToast(this.text, {this.isError = false, required this.id});
  final String text;
  final bool isError;
  final int id;
}

/// Shared UI state for one lab: language, theme, sidebar, labels, camera
/// tools, toast and popup. Owned by the activity's State and passed to
/// [LabShell]. Activities rebuild on changes with a `ListenableBuilder`.
class LabController extends ChangeNotifier {
  LabController({required this.style, this.camLocked = false})
      : fontSize = style.font.size;

  static const double minZoom = 0.5;
  static const double maxZoom = 5;

  /// The activity's own tones, palettes and font.
  final LabStyle style;

  LabLang lang = LabLang.en;
  bool isDark = true;

  /// Sidebar font size in px (HTML `--sidebar-font-size`), within the
  /// lab font's range.
  double fontSize;
  bool showLabels = true;
  bool isSidebarOpen = true;

  /// Sidebar width as a fraction of the screen; drag its edge to resize.
  static const double defaultSidebarFraction = 0.30;
  double sidebarFraction = defaultSidebarFraction;

  /// How far the user dragged each floating card, by card id (see
  /// [LabMovable]).
  final Map<String, Offset> cardOffsets = {};

  /// True once the curtain has lifted (HTML `State.isLabActive`).
  bool isLabActive = false;

  /// Locked: pinch / drag do not move the canvas (zoom buttons still work).
  bool camLocked;

  /// Pan mode: drags move the canvas instead of interacting with the scene.
  bool panMode = false;
  bool settingsOpen = false;

  /// Scenarios finished in this session (HTML `completedScenarios`).
  final Set<int> completedScenarios = {};

  /// Zoom / pan of the canvas (driven by InteractiveViewer and tool buttons).
  final TransformationController transform = TransformationController();

  LabToast? toast;
  LabPopupBuilder? popup;

  Timer? _toastTimer;
  int _toastId = 0;
  bool _disposed = false;
  final Set<Timer> _timers = {};

  // Hooks registered by the shell / zoom viewer.
  void Function(double factor)? _zoomHook;
  VoidCallback? _resetViewHook;
  VoidCallback? _fullResetHook;

  /// Common (shell) string for the current language.
  String t(String key) => labTr(kLabCommonStrings, lang, key);

  /// Activity string from [table] for the current language.
  String tr(LabStringTable table, String key) => labTr(table, lang, key);

  double get fontScale => fontSize / style.font.size;

  /// The lab's palette for the current theme.
  LabPalette get palette => style.palette(isDark);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool get isDisposed => _disposed;

  /// Runs [fn] after [delay] (the HTML `setTimeout`). Pending callbacks are
  /// cancelled when the lab is disposed, so they never touch a dead State.
  Timer after(Duration delay, VoidCallback fn) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      if (!_disposed) fn();
    });
    _timers.add(timer);
    return timer;
  }

  /// Cancels every pending [after] callback (e.g. on scenario change).
  void cancelPending() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  // ---------------------------------------------------------------- settings

  void toggleLanguage() {
    style.click.play();
    lang = lang.next;
    _notify();
  }

  void setLanguage(LabLang value) {
    if (lang == value) return;
    lang = value;
    _notify();
  }

  void toggleTheme() {
    style.click.play();
    isDark = !isDark;
    _notify();
  }

  void setFontSize(double value) {
    fontSize = value.clamp(style.font.minSize, style.font.maxSize).toDouble();
    _notify();
  }

  void toggleSettings() {
    style.click.play();
    settingsOpen = !settingsOpen;
    _notify();
  }

  // ----------------------------------------------------------------- sidebar

  void toggleSidebar() {
    style.toggle.play();
    isSidebarOpen = !isSidebarOpen;
    _notify();
  }

  void openSidebar() {
    if (isSidebarOpen) return;
    style.toggle.play();
    isSidebarOpen = true;
    _notify();
  }

  // ------------------------------------------------------------ canvas tools

  void toggleLabels() {
    style.click.play();
    showLabels = !showLabels;
    _notify();
  }

  void toggleCamLock() {
    style.click.play();
    camLocked = !camLocked;
    _notify();
  }

  void togglePanMode() {
    style.click.play();
    panMode = !panMode;
    _notify();
  }

  void zoomIn() {
    style.click.play();
    _zoomHook?.call(1.25);
  }

  void zoomOut() {
    style.click.play();
    _zoomHook?.call(0.8);
  }

  /// Animates the canvas back to 100% zoom, centred.
  void resetView({bool sound = true}) {
    if (sound) style.click.play();
    if (_resetViewHook != null) {
      _resetViewHook!();
    } else {
      transform.value = Matrix4.identity();
    }
  }

  // ---------------------------------------------------------------- feedback

  /// Shows the floating feedback toast for 3 seconds. Plays the lab's
  /// "correct" / "wrong" tone unless [sound] is false.
  void showToast(String text, {bool isError = false, bool sound = true}) {
    if (sound) (isError ? style.wrong : style.correct).play();
    _toastTimer?.cancel();
    toast = LabToast(text, isError: isError, id: ++_toastId);
    _notify();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toast = null;
      _notify();
    });
  }

  /// Opens the draggable, scrollable popup. [builder] runs on every rebuild
  /// so it should read strings through [tr] / [t] to follow language changes.
  /// Plays [sound] (default: the lab's success tone) unless [silent].
  void showPopup(LabPopupBuilder builder, {LabTone? sound, bool silent = false}) {
    if (!silent) (sound ?? style.success).play();
    popup = builder;
    _notify();
  }

  void hidePopup({bool sound = true}) {
    if (popup == null) return;
    if (sound) style.click.play();
    popup = null;
    _notify();
  }

  /// The standard end-of-scenario flow from the HTML `showConclusion()`:
  /// marks the scenario complete, re-opens the sidebar and shows the
  /// conclusion popup. When every scenario is done the popup offers
  /// "Restart Lab"; otherwise "Continue" closes it and shows the
  /// "Scenario Complete" toast.
  void showScenarioConclusion({
    required int scenarioIndex,
    required int totalScenarios,
    required String Function() body,
    String Function()? title,
    String Function()? heading,
    Widget Function()? extra,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    completedScenarios.add(scenarioIndex);
    final allDone = completedScenarios.length >= totalScenarios;
    after(delay, () {
      if (!isSidebarOpen) {
        isSidebarOpen = true;
        style.toggle.play();
      }
      showPopup(() => LabPopupContent(
            title: title?.call() ?? t('success'),
            heading: heading?.call() ?? t('lbl_observation'),
            body: body(),
            extra: extra?.call(),
            actions: [
              if (allDone)
                LabAction(
                  label: t('btn_restart'),
                  icon: Icons.restart_alt,
                  onTap: requestFullReset,
                )
              else
                LabAction(
                  label: t('btn_continue'),
                  icon: Icons.arrow_forward,
                  color: palette.primary,
                  foreground: palette.onPrimary,
                  onTap: () {
                    hidePopup(sound: false);
                    showToast(t('msg_scenario_complete'));
                  },
                ),
            ],
          ));
    });
  }

  /// Full "Reset Lab" (HTML `resetApp(false)`): closes the curtain, resets
  /// language, theme, font size, labels and sidebar, then calls the
  /// activity's `onReset`.
  void requestFullReset() => _fullResetHook?.call();

  /// Restores the shell defaults. Called by the shell during a full reset.
  void resetShellState() {
    cancelPending();
    _toastTimer?.cancel();
    toast = null;
    popup = null;
    settingsOpen = false;
    lang = LabLang.en;
    isDark = true;
    fontSize = style.font.size;
    showLabels = true;
    isSidebarOpen = true;
    sidebarFraction = defaultSidebarFraction;
    cardOffsets.clear();
    panMode = false;
    completedScenarios.clear();
    transform.value = Matrix4.identity();
    _notify();
  }

  void markLabActive(bool active) {
    isLabActive = active;
    _notify();
  }

  // ------------------------------------------------------- shell internals

  // ignore: use_setters_to_change_properties
  void attachZoomHooks({
    required void Function(double factor) zoom,
    required VoidCallback resetView,
  }) {
    _zoomHook = zoom;
    _resetViewHook = resetView;
  }

  void detachZoomHooks() {
    _zoomHook = null;
    _resetViewHook = null;
  }

  // ignore: use_setters_to_change_properties
  void attachResetHook(VoidCallback hook) => _fullResetHook = hook;

  void detachResetHook() => _fullResetHook = null;

  @override
  void dispose() {
    _disposed = true;
    style.releaseAudio?.call();
    _toastTimer?.cancel();
    cancelPending();
    transform.dispose();
    super.dispose();
  }
}

// ================================================================= LAB STAGE

/// Key of the design-size box inside [LabStage] (used by tests to convert
/// design coordinates to screen positions).
const ValueKey<String> labStageDesignKey = ValueKey('lab-stage-design');

/// A fixed "design size" scene that is scaled to fit the available canvas
/// area (BoxFit.contain) and centred. Everything inside [child] is laid out,
/// painted and hit-tested in design coordinates, so a `CustomPainter` can
/// draw at e.g. 1000x560 and `GestureDetector.localPosition` values come
/// back in the same coordinates at any screen size.
///
/// [background] fills the whole canvas area (including letterbox space)
/// behind the scaled scene.
class LabStage extends StatelessWidget {
  const LabStage({
    super.key,
    required this.designSize,
    required this.child,
    this.background,
  });

  final Size designSize;
  final Widget child;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ?background,
        FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            key: labStageDesignKey,
            width: designSize.width,
            height: designSize.height,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A rect that extends well past the design area. The stage is letterboxed
/// when the canvas aspect ratio differs from the design size, and nothing
/// clips the painter there, so fill sky / ground / water with this rect
/// (and extend tracks, tables, horizons) to avoid visible seams.
Rect labBleed(Size size) =>
    Rect.fromLTRB(-size.width * 1.5, -size.height * 1.5, size.width * 2.5, size.height * 2.5);

/// Converts a global position (e.g. `DragTargetDetails.offset`) into the
/// local coordinates of the widget owning [key] (e.g. a LabStage child),
/// accounting for zoom, pan and stage scaling.
Offset? labGlobalToLocal(GlobalKey key, Offset global) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.globalToLocal(global);
}

/// Zoomable / pannable canvas used by [LabShell]. Pinch and drag move the
/// canvas unless the camera is locked; in pan mode the scene ignores
/// touches so every drag pans. Tool buttons zoom about the centre.
class LabZoomViewer extends StatefulWidget {
  const LabZoomViewer({super.key, required this.controller, required this.child});

  final LabController controller;
  final Widget child;

  @override
  State<LabZoomViewer> createState() => _LabZoomViewerState();
}

class _LabZoomViewerState extends State<LabZoomViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Matrix4Tween? _tween;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(_onTick);
    widget.controller.attachZoomHooks(zoom: _zoomBy, resetView: _reset);
  }

  @override
  void didUpdateWidget(covariant LabZoomViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachZoomHooks();
      widget.controller.attachZoomHooks(zoom: _zoomBy, resetView: _reset);
    }
  }

  @override
  void dispose() {
    widget.controller.detachZoomHooks();
    _anim.dispose();
    super.dispose();
  }

  void _onTick() {
    final tween = _tween;
    if (tween == null) return;
    widget.controller.transform.value =
        tween.transform(Curves.easeOutCubic.transform(_anim.value));
  }

  void _animateTo(Matrix4 target) {
    _tween = Matrix4Tween(
      begin: widget.controller.transform.value.clone(),
      end: target,
    );
    _anim.forward(from: 0);
  }

  void _zoomBy(double factor) {
    if (_viewport.isEmpty) return;
    final current = widget.controller.transform.value;
    final scale = current.getMaxScaleOnAxis();
    final target =
        (scale * factor).clamp(LabController.minZoom, LabController.maxZoom);
    final f = target / scale;
    final cx = _viewport.width / 2;
    final cy = _viewport.height / 2;
    // Scale about the viewport centre: x' = f * x + c * (1 - f).
    final about = Matrix4.identity()
      ..setEntry(0, 0, f)
      ..setEntry(1, 1, f)
      ..setEntry(0, 3, cx * (1 - f))
      ..setEntry(1, 3, cy * (1 - f));
    _animateTo(about.multiplied(current));
  }

  void _reset() => _animateTo(Matrix4.identity());

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final gesturesOn = c.panMode || !c.camLocked;
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return InteractiveViewer(
          transformationController: c.transform,
          minScale: LabController.minZoom,
          maxScale: LabController.maxZoom,
          boundaryMargin: const EdgeInsets.all(400),
          panEnabled: gesturesOn,
          scaleEnabled: gesturesOn,
          child: IgnorePointer(
            ignoring: c.panMode,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ========================================================= LAB PAINT HELPERS

/// Painting helpers that stand in for the Three.js meshes and HTML labels of
/// the original labs. All take design-space coordinates.

/// Lightens (amount > 0) or darkens (amount < 0) [c] by mixing with white
/// or black.
Color labShade(Color c, double amount) {
  if (amount >= 0) return Color.lerp(c, Colors.white, amount.clamp(0, 1))!;
  return Color.lerp(c, Colors.black, (-amount).clamp(0, 1))!;
}

/// Draws [text] anchored at [at]. [anchor] picks which point of the text box
/// sits on [at] (centre by default). With [background] the text is drawn
/// inside a rounded pill (the HTML floating labels / distance badges).
/// Returns the painted rect.
Rect labText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 14,
  Color color = Colors.white,
  FontWeight weight = FontWeight.w600,
  Alignment anchor = Alignment.center,
  TextAlign align = TextAlign.center,
  double? maxWidth,
  Color? background,
  Color? border,
  double borderWidth = 1.5,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  double radius = 999,
  double opacity = 1,
  String? fontFamily,
  List<Shadow>? shadows,
  double letterSpacing = 0,
}) {
  if (opacity <= 0) return Rect.zero;
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        color: color.withValues(alpha: color.a * opacity),
        fontWeight: weight,
        fontFamily: fontFamily ?? LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
        shadows: shadows,
        letterSpacing: letterSpacing,
        height: 1.2,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth ?? double.infinity);

  final pad = background != null || border != null ? padding : EdgeInsets.zero;
  final w = tp.width + pad.horizontal;
  final h = tp.height + pad.vertical;
  final left = at.dx - (anchor.x + 1) / 2 * w;
  final top = at.dy - (anchor.y + 1) / 2 * h;
  final rect = Rect.fromLTWH(left, top, w, h);

  if (background != null || border != null) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(radius, h / 2)));
    if (background != null) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(rr, Paint()..color = background.withValues(alpha: background.a * opacity));
    }
    if (border != null) {
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = border.withValues(alpha: border.a * opacity),
      );
    }
  }
  tp.paint(canvas, Offset(left + pad.left, top + pad.top));
  return rect;
}

/// Floating object label like the HTML `.object-label` chips
/// (dark pill, white bold text).
Rect labPill(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 13,
  Color background = const Color(0xE61E293B),
  Color color = Colors.white,
  Color? border = const Color(0xFF475569),
  Alignment anchor = Alignment.center,
  double opacity = 1,
}) {
  return labText(
    canvas,
    text,
    at,
    size: size,
    color: color,
    weight: FontWeight.w700,
    background: background,
    border: border,
    borderWidth: 1,
    anchor: anchor,
    opacity: opacity,
  );
}

/// Straight arrow with a filled head.
void labArrow(
  Canvas canvas,
  Offset from,
  Offset to, {
  Color color = Colors.white,
  double width = 3,
  double head = 12,
  bool dashed = false,
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final dir = to - from;
  final len = dir.distance;
  if (len < 0.001) return;
  final u = dir / len;
  final base = to - u * head;
  if (dashed) {
    labDashedLine(canvas, from, base, paint);
  } else {
    canvas.drawLine(from, base, paint);
  }
  final n = Offset(-u.dy, u.dx);
  final path = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(base.dx + n.dx * head * 0.55, base.dy + n.dy * head * 0.55)
    ..lineTo(base.dx - n.dx * head * 0.55, base.dy - n.dy * head * 0.55)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
}

/// Dashed straight line.
void labDashedLine(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 8,
  double gap = 6,
  double phase = 0,
}) {
  final total = (b - a).distance;
  if (total <= 0) return;
  final u = (b - a) / total;
  var d = -(phase % (dash + gap));
  while (d < total) {
    final s = math.max(d, 0.0);
    final e = math.min(d + dash, total);
    if (e > s) canvas.drawLine(a + u * s, a + u * e, paint);
    d += dash + gap;
  }
}

/// Dashed version of any [path] (e.g. orbits, light rays).
void labDashedPath(Canvas canvas, Path path, Paint paint,
    {double dash = 8, double gap = 6, double phase = 0}) {
  for (final metric in path.computeMetrics()) {
    var d = -(phase % (dash + gap));
    while (d < metric.length) {
      final s = math.max(d, 0.0);
      final e = math.min(d + dash, metric.length);
      if (e > s) canvas.drawPath(metric.extractPath(s, e), paint);
      d += dash + gap;
    }
  }
}

/// Lit sphere (MeshStandardMaterial look) with a soft drop shadow option.
void labSphere(
  Canvas canvas,
  Offset c,
  double r,
  Color color, {
  Offset light = const Offset(-0.35, -0.4),
  double highlight = 0.45,
  double shade = 0.55,
  bool outline = false,
  double opacity = 1,
}) {
  final rect = Rect.fromCircle(center: c, radius: r);
  final paint = Paint()
    ..shader = RadialGradient(
      center: Alignment(light.dx, light.dy),
      radius: 1.05,
      colors: [
        labShade(color, highlight).withValues(alpha: opacity),
        color.withValues(alpha: opacity),
        labShade(color, -shade).withValues(alpha: opacity),
      ],
      stops: const [0, 0.5, 1],
    ).createShader(rect);
  canvas.drawCircle(c, r, paint);
  if (outline) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = labShade(color, -0.6).withValues(alpha: 0.6 * opacity),
    );
  }
}

/// Additive-looking radial glow (light bulbs, flames, sun, hot spots).
void labGlow(Canvas canvas, Offset c, double r, Color color, {double intensity = 1}) {
  if (intensity <= 0 || r <= 0) return;
  final rect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(colors: [
        color.withValues(alpha: (0.85 * intensity).clamp(0, 1)),
        color.withValues(alpha: (0.35 * intensity).clamp(0, 1)),
        color.withValues(alpha: 0),
      ], stops: const [0, 0.35, 1]).createShader(rect),
  );
}

/// Soft elliptical contact shadow under an object.
void labGroundShadow(Canvas canvas, Offset c, double w, double h, {double opacity = 0.3}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.35),
  );
}

/// Oblique "2.5D" cuboid: [front] face plus top and right faces receding by
/// [depth] towards the upper right. Approximates a Three.js BoxGeometry.
void labBox3D(
  Canvas canvas,
  Rect front,
  double depth,
  Color color, {
  double angle = -0.6,
  bool stroke = true,
  double opacity = 1,
  double radius = 0,
}) {
  final d = Offset(math.cos(angle), math.sin(angle)) * depth;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  final top = Path()
    ..moveTo(front.left, front.top)
    ..lineTo(front.left + d.dx, front.top + d.dy)
    ..lineTo(front.right + d.dx, front.top + d.dy)
    ..lineTo(front.right, front.top)
    ..close();
  final side = Path()
    ..moveTo(front.right, front.top)
    ..lineTo(front.right + d.dx, front.top + d.dy)
    ..lineTo(front.right + d.dx, front.bottom + d.dy)
    ..lineTo(front.right, front.bottom)
    ..close();
  canvas.drawPath(top, Paint()..color = a(labShade(color, 0.25)));
  canvas.drawPath(side, Paint()..color = a(labShade(color, -0.3)));
  final frontPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [a(labShade(color, 0.08)), a(labShade(color, -0.12))],
    ).createShader(front);
  if (radius > 0) {
    canvas.drawRRect(RRect.fromRectAndRadius(front, Radius.circular(radius)), frontPaint);
  } else {
    canvas.drawRect(front, frontPaint);
  }
  if (stroke) {
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = a(labShade(color, -0.45).withValues(alpha: 0.6));
    canvas.drawPath(top, edge);
    canvas.drawPath(side, edge);
    canvas.drawRect(front, edge);
  }
}

/// Upright cylinder seen slightly from above (CylinderGeometry look).
/// [rect] is the bounding box of the side; the top ellipse height is
/// `rect.width * tilt`.
void labCylinder(
  Canvas canvas,
  Rect rect,
  Color color, {
  double tilt = 0.28,
  double opacity = 1,
  bool drawTop = true,
}) {
  final eh = rect.width * tilt;
  Color a(Color c) => c.withValues(alpha: c.a * opacity);
  final body = Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.left, rect.bottom)
    ..arcTo(Rect.fromLTWH(rect.left, rect.bottom - eh / 2, rect.width, eh), math.pi, -math.pi, false)
    ..lineTo(rect.right, rect.top)
    ..close();
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(colors: [
        a(labShade(color, -0.35)),
        a(labShade(color, 0.25)),
        a(color),
        a(labShade(color, -0.45)),
      ], stops: const [0, 0.3, 0.6, 1]).createShader(rect),
  );
  if (drawTop) {
    canvas.drawOval(
      Rect.fromLTWH(rect.left, rect.top - eh / 2, rect.width, eh),
      Paint()..color = a(labShade(color, 0.3)),
    );
  }
}

/// Glass beaker with optional liquid. [fill] is 0..1 of the inner height.
void labBeaker(
  Canvas canvas,
  Rect rect, {
  double fill = 0,
  Color liquid = const Color(0xFF60A5FA),
  Color glass = const Color(0xFFBFDBFE),
  bool graduations = true,
  double liquidOpacity = 0.75,
}) {
  final r = rect.width * 0.08;
  final inner = rect.deflate(3);
  if (fill > 0) {
    final h = inner.height * fill.clamp(0, 1);
    final lr = Rect.fromLTRB(inner.left, inner.bottom - h, inner.right, inner.bottom);
    canvas.drawRRect(
      RRect.fromRectAndCorners(lr, bottomLeft: Radius.circular(r), bottomRight: Radius.circular(r)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(liquid, 0.15).withValues(alpha: liquidOpacity),
            labShade(liquid, -0.2).withValues(alpha: liquidOpacity),
          ],
        ).createShader(lr),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(lr.center.dx, lr.top), width: lr.width, height: lr.width * 0.12),
      Paint()..color = labShade(liquid, 0.3).withValues(alpha: liquidOpacity),
    );
  }
  final glassPath = Path()
    ..moveTo(rect.left - 4, rect.top)
    ..lineTo(rect.left, rect.top + 6)
    ..lineTo(rect.left, rect.bottom - r)
    ..quadraticBezierTo(rect.left, rect.bottom, rect.left + r, rect.bottom)
    ..lineTo(rect.right - r, rect.bottom)
    ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - r)
    ..lineTo(rect.right, rect.top);
  canvas.drawPath(glassPath, Paint()..color = glass.withValues(alpha: 0.12));
  canvas.drawPath(
    glassPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = glass.withValues(alpha: 0.85),
  );
  // Glass highlight.
  canvas.drawLine(
    Offset(rect.left + rect.width * 0.12, rect.top + 12),
    Offset(rect.left + rect.width * 0.12, rect.bottom - 12),
    Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.25),
  );
  if (graduations) {
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = glass.withValues(alpha: 0.7);
    for (var i = 1; i <= 4; i++) {
      final y = rect.bottom - rect.height * i / 5;
      canvas.drawLine(Offset(rect.right - rect.width * 0.25, y), Offset(rect.right - 3, y), g);
    }
  }
}

/// Test tube (rounded bottom) with optional liquid.
void labTestTube(
  Canvas canvas,
  Rect rect, {
  double fill = 0,
  Color liquid = const Color(0xFF60A5FA),
  Color glass = const Color(0xFFBFDBFE),
}) {
  final r = rect.width / 2;
  final path = Path()
    ..moveTo(rect.left, rect.top)
    ..lineTo(rect.left, rect.bottom - r)
    ..arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r), clockwise: false)
    ..lineTo(rect.right, rect.top);
  if (fill > 0) {
    canvas.save();
    canvas.clipPath(Path()..addPath(path, Offset.zero)..close());
    final h = rect.height * fill.clamp(0, 1);
    canvas.drawRect(
      Rect.fromLTRB(rect.left, rect.bottom - h, rect.right, rect.bottom),
      Paint()..color = liquid.withValues(alpha: 0.8),
    );
    canvas.restore();
  }
  canvas.drawPath(path, Paint()..color = glass.withValues(alpha: 0.12));
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = glass.withValues(alpha: 0.85),
  );
  canvas.drawLine(
    Offset(rect.left - 3, rect.top),
    Offset(rect.right + 3, rect.top),
    Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = glass,
  );
}

/// Flickering flame (candle / burner / combustion). [t] is time in seconds.
void labFlame(Canvas canvas, Offset base, double height, double t, {double intensity = 1}) {
  if (intensity <= 0) return;
  final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
  final h = height * flick * intensity;
  final w = height * 0.42 * intensity;
  labGlow(canvas, base.translate(0, -h * 0.45), h * 1.1, const Color(0xFFF97316), intensity: 0.55 * intensity);
  Path flame(double sx, double sy) => Path()
    ..moveTo(base.dx, base.dy - h * sy)
    ..cubicTo(base.dx + w * sx, base.dy - h * sy * 0.55, base.dx + w * sx * 0.9, base.dy,
        base.dx, base.dy)
    ..cubicTo(base.dx - w * sx * 0.9, base.dy, base.dx - w * sx, base.dy - h * sy * 0.55,
        base.dx, base.dy - h * sy)
    ..close();
  canvas.drawPath(flame(1, 1), Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.9));
  canvas.drawPath(flame(0.7, 0.75), Paint()..color = const Color(0xFFFACC15));
  canvas.drawPath(flame(0.35, 0.4), Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.9));
}

/// Wavy heat / airflow arrow (convection, breezes).
void labWavyArrow(Canvas canvas, Offset from, Offset to, double t,
    {Color color = const Color(0xFFF97316), double amp = 6, double width = 3}) {
  final dir = to - from;
  final len = dir.distance;
  if (len < 1) return;
  final u = dir / len;
  final n = Offset(-u.dy, u.dx);
  final path = Path()..moveTo(from.dx, from.dy);
  for (var d = 0.0; d <= len - 10; d += 4) {
    final p = from + u * d + n * (amp * math.sin(d / 14 - t * 6));
    path.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color,
  );
  labArrow(canvas, from + u * (len - 14), to, color: color, width: width, head: 11);
}

/// Minimal 3D -> 2D projector for orbit-style scenes (Earth / Sun / Moon,
/// rotating globes). Rotates by [yaw] about Y, then [pitch] about X, then
/// applies a perspective divide with camera distance [distance].
class LabProjector {
  const LabProjector({
    required this.center,
    this.scale = 1,
    this.yaw = 0,
    this.pitch = 0.35,
    this.distance = 900,
  });

  final Offset center;
  final double scale;
  final double yaw;
  final double pitch;
  final double distance;

  /// Returns the projected point and its depth (larger = closer to viewer).
  ({Offset p, double depth, double k}) project(double x, double y, double z) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = x * cy + z * sy;
    final z1 = -x * sy + z * cy;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final y2 = y * cp - z1 * sp;
    final z2 = y * sp + z1 * cp;
    final k = distance / (distance - z2 * scale);
    return (
      p: Offset(center.dx + x1 * scale * k, center.dy - y2 * scale * k),
      depth: z2,
      k: k,
    );
  }

  Offset point(double x, double y, double z) => project(x, y, z).p;
}

// =============================================================== LAB WIDGETS

/// Picks the palette's dark text or white for a coloured button fill.
Color labOnColor(Color fill, LabPalette palette) =>
    fill.computeLuminance() > 0.45 ? palette.onAccent : Colors.white;

/// Button for a [LabAction]; pulses when `action.highlight` is set.
class LabActionButton extends StatefulWidget {
  const LabActionButton({
    super.key,
    required this.action,
    this.scale = 1,
    this.expand = true,
    this.dense = false,
  });

  final LabAction action;
  final double scale;
  final bool expand;
  final bool dense;

  @override
  State<LabActionButton> createState() => _LabActionButtonState();
}

class _LabActionButtonState extends State<LabActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant LabActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final on = widget.action.highlight && widget.action.enabled;
    if (on && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!on && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    final s = widget.scale;
    final scope = LabStyleScope.of(context);
    final fill = a.color ?? scope.palette.accent;
    final fg = a.foreground ?? labOnColor(fill, scope.palette);
    final enabled = a.enabled && a.onTap != null;
    final vPad = (widget.dense ? 7.0 : 10.0) * s;

    final button = Material(
      color: enabled ? fill : fill.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * s),
        onTap: enabled
            ? () {
                if (!a.silent) (a.sound ?? scope.style.click).play();
                a.onTap!();
              }
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: vPad),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (a.icon != null) ...[
                Icon(a.icon, size: 16 * s, color: fg.withValues(alpha: enabled ? 1 : 0.6)),
                SizedBox(width: 6 * s),
              ],
              Flexible(
                child: Text(
                  a.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fg.withValues(alpha: enabled ? 1 : 0.6),
                    fontWeight: FontWeight.w700,
                    fontSize: (widget.dense ? 11.5 : 13) * s,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = a.highlight && enabled;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            boxShadow: [
              if (glow)
                BoxShadow(
                  color: fill.withValues(alpha: 0.35 + 0.4 * _pulse.value),
                  blurRadius: (12 + 12 * _pulse.value) * s,
                ),
            ],
          ),
          child: child,
        );
      },
      child: button,
    );
  }
}

/// Lays out a list of actions as full-width buttons (sidebar) or a wrap.
class LabActionList extends StatelessWidget {
  const LabActionList({
    super.key,
    required this.actions,
    this.scale = 1,
    this.dense = false,
  });

  final List<LabAction> actions;
  final double scale;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(height: 8 * scale),
          LabActionButton(action: actions[i], scale: scale, dense: dense),
        ],
      ],
    );
  }
}

/// A floating card the user can drag anywhere inside the area it fills.
/// Use it as `Positioned.fill(child: LabMovable(...))`: the card is placed
/// by [left] / [top] / [right] / [bottom] / [width] / [height] like a
/// [Positioned] (centred when none is set), then shifted by the drag. The
/// card itself moves, so it can be grabbed again wherever it is; taps on the
/// empty rest of the area pass through. Taps, sliders and drags on controls
/// inside the card still work; a drag that starts on the card moves it. The
/// card stays inside the area, and its position is kept per [id] in the
/// controller, so it comes back where it was left.
class LabMovable extends StatefulWidget {
  const LabMovable({
    super.key,
    required this.controller,
    required this.id,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.margin = const EdgeInsets.all(4),
  });

  final LabController controller;
  final String id;
  final Widget child;

  /// Space kept clear inside the area's edges (e.g. the canvas tool column).
  final EdgeInsets margin;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  @override
  State<LabMovable> createState() => _LabMovableState();
}

class _LabMovableState extends State<LabMovable> {
  final GlobalKey _cardKey = GlobalKey();
  bool _moving = false;
  Offset _startOffset = Offset.zero;
  Offset _startPointer = Offset.zero;

  /// The card's box without any drag, in area coordinates (taken at the
  /// start of each drag).
  Rect? _home;

  Offset get _offset => widget.controller.cardOffsets[widget.id] ?? Offset.zero;

  // Measured from the touch-down point, so the card follows the finger
  // exactly instead of lagging by the drag slop.
  void _down(DragDownDetails d) => _startPointer = d.globalPosition;

  void _start(DragStartDetails _) {
    _startOffset = _offset;
    final area = context.findRenderObject();
    final card = _cardKey.currentContext?.findRenderObject();
    _home = area is RenderBox && card is RenderBox && card.hasSize
        ? (card.localToGlobal(Offset.zero, ancestor: area) - _startOffset) & card.size
        : null;
    setState(() => _moving = true);
  }

  void _update(DragUpdateDetails d) {
    var offset = _startOffset + d.globalPosition - _startPointer;
    final area = context.findRenderObject();
    final home = _home;
    if (home != null && area is RenderBox && area.hasSize) {
      final bounds = widget.margin.deflateRect(Offset.zero & area.size);
      offset = Offset(
        _keepInside(offset.dx, home.left, home.right, bounds.left, bounds.right),
        _keepInside(offset.dy, home.top, home.bottom, bounds.top, bounds.bottom),
      );
    }
    setState(() => widget.controller.cardOffsets[widget.id] = offset);
  }

  /// Shift along one axis that keeps [start, end] inside [lo, hi]. A card
  /// bigger than the area may slide until its edges meet the area's.
  static double _keepInside(double shift, double start, double end, double lo, double hi) {
    final a = lo - start;
    final b = hi - end;
    return a <= b ? shift.clamp(a, b) : shift.clamp(b, a);
  }

  void _end() {
    if (_moving) setState(() => _moving = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final o = _offset;
    Widget grab(Widget card) => GestureDetector(
          key: _cardKey,
          onPanDown: _down,
          onPanStart: _start,
          onPanUpdate: _update,
          onPanEnd: (_) => _end(),
          onPanCancel: _end,
          child: AnimatedScale(
            scale: _moving ? 1.03 : 1,
            duration: const Duration(milliseconds: 120),
            child: card,
          ),
        );
    // Move the card itself, not a full-width Center / Align around it.
    final child = w.child;
    final placed = child is Align && child.child != null
        ? Align(
            key: child.key,
            alignment: child.alignment,
            widthFactor: child.widthFactor,
            heightFactor: child.heightFactor,
            child: grab(child.child!),
          )
        : grab(child);

    if (w.left == null && w.top == null && w.right == null && w.bottom == null) {
      return Center(child: Transform.translate(offset: o, child: placed));
    }
    final noX = w.left == null && w.right == null;
    final noY = w.top == null && w.bottom == null;
    return Stack(
      children: [
        Positioned(
          left: noX ? o.dx : (w.left == null ? null : w.left! + o.dx),
          right: w.right == null ? null : w.right! - o.dx,
          top: noY ? o.dy : (w.top == null ? null : w.top! + o.dy),
          bottom: w.bottom == null ? null : w.bottom! - o.dy,
          width: w.width,
          height: w.height,
          child: placed,
        ),
      ],
    );
  }
}

/// Frosted panel matching the HTML `.glass-panel`.
class LabGlassCard extends StatelessWidget {
  const LabGlassCard({
    super.key,
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 14,
    this.borderColor,
    this.color,
    this.shadow = true,
  });

  final LabPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? palette.panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? palette.border),
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 4))]
            : null,
      ),
      child: child,
    );
  }
}

/// Small uppercase section heading (HTML `uppercase tracking-widest`).
class LabSectionLabel extends StatelessWidget {
  const LabSectionLabel(this.text, {super.key, this.color, this.size = 11, this.icon});

  final String text;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LabStyleScope.of(context).palette.accent;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: size * 1.3, color: c),
          SizedBox(width: size * 0.45),
        ],
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: c,
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Labelled slider for sidebar controls (HTML `<input type="range">`).
class LabSliderControl extends StatelessWidget {
  const LabSliderControl({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueText,
    this.divisions,
    this.scale = 1,
    this.onChangeEnd,
    this.enabled = true,
    this.activeColor,
  });

  final LabPalette palette;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String? valueText;
  final int? divisions;
  final double scale;
  final bool enabled;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (valueText != null)
              Text(
                valueText!,
                style: TextStyle(
                  color: activeColor ?? palette.accent,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4 * scale,
            activeTrackColor: activeColor ?? palette.accent,
            thumbColor: activeColor ?? palette.accent,
            inactiveTrackColor: palette.cardBorder,
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14 * scale),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8 * scale),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}

/// A row of selectable chips (mode / material / option pickers).
class LabChoiceChips<T> extends StatelessWidget {
  const LabChoiceChips({
    super.key,
    required this.palette,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scale = 1,
    this.enabled = true,
  });

  final LabPalette palette;

  /// value -> label
  final Map<T, String> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final double scale;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6 * scale,
      runSpacing: 6 * scale,
      children: [
        for (final e in options.entries)
          ChoiceChip(
            label: Text(
              e.value,
              style: TextStyle(
                fontSize: 11.5 * scale,
                fontWeight: FontWeight.w700,
                color: e.key == selected ? palette.onAccent : palette.text,
              ),
            ),
            selected: e.key == selected,
            selectedColor: palette.accent,
            backgroundColor: palette.card,
            side: BorderSide(color: palette.cardBorder),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: enabled
                ? (_) {
                    LabStyleScope.of(context).style.click.play();
                    onSelected(e.key);
                  }
                : null,
          ),
      ],
    );
  }
}

/// "Label ........ value" row for sidebar readouts.
class LabInfoRow extends StatelessWidget {
  const LabInfoRow({
    super.key,
    required this.palette,
    required this.label,
    required this.value,
    this.valueColor,
    this.scale = 1,
  });

  final LabPalette palette;
  final String label;
  final String value;
  final Color? valueColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: palette.textMuted, fontSize: 12 * scale, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? palette.textStrong,
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark rounded display used for HUD readouts (clocks, meters, timers).
class LabReadout extends StatelessWidget {
  const LabReadout({
    super.key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF4ADE80),
    this.scale = 1,
    this.fontSize = 22,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final double scale;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Scales down instead of overflowing while the canvas resizes.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: _box(LabStyleScope.of(context).palette),
    );
  }

  Widget _box(LabPalette p) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: p.readoutBg,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: p.readoutBorder, width: 2.5 * scale),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: p.readoutIcon, size: fontSize * scale),
            SizedBox(width: 10 * scale),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'monospace',
              color: color,
              fontSize: fontSize * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================= LAB SHELL

/// The common screen used by every Class 7 Science lab:
///
/// * intro curtain with "Enter Lab" (animated, with sound),
/// * collapsible, scrollable left sidebar (30% of the width; drag its right
///   edge to resize it between 20% and half the screen) holding the
///   header (title, language, reset, settings), scenario selector,
///   target output (mission objective + current step), all action buttons,
///   optional activity controls and the footer,
/// * a fixed menu button (top-left) that expands / collapses the sidebar,
///   and a back button (top-right, above everything, also on the curtain)
///   that returns to the home page,
/// * a floating mission card with the dynamic action buttons while the
///   sidebar is collapsed,
/// * the zoomable canvas with tool buttons (labels, lock, pan, reset view,
///   zoom in / out), feedback toast, HUD objective and activity overlays,
/// * the scrollable success popup and the settings dialog.
///
/// Every floating card (popup, settings, mission card, HUD objective and the
/// activity's overlay cards) can be dragged anywhere on screen ([LabMovable]).
///
/// Tones, colours and font come from the activity's [LabStyle] (via the
/// controller), so every lab sounds and looks the way its own file says.
class LabShell extends StatefulWidget {
  const LabShell({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stage,
    this.scenarioNames = const [],
    this.scenarioIndex = 0,
    this.onScenarioChanged,
    this.objective = '',
    this.steps = const [],
    this.currentStep = 1,
    this.instruction,
    this.actions = const [],
    this.sidebarExtra,
    this.sidebarExtraTitle,
    this.overlays = const [],
    this.onEnterLab,
    this.onReset,
    this.showHud = true,
    this.showTools = true,
  });

  final LabController controller;
  final IconData icon;
  final String title;
  final String subtitle;

  /// The scene, usually a [LabStage]. Wrapped in the zoomable viewer.
  final Widget stage;

  /// Localised scenario names (the HTML `<select>` options).
  final List<String> scenarioNames;
  final int scenarioIndex;

  /// Called with the new index. The shell plays the scenario sound.
  final ValueChanged<int>? onScenarioChanged;

  /// Localised mission objective for the current scenario.
  final String objective;

  /// Localised steps of the current scenario.
  final List<LabStep> steps;

  /// 1-based current step (may be steps.length + 1 when finished).
  final int currentStep;

  /// Overrides the current objective text (defaults to the step's action).
  final String? instruction;

  /// Dynamic action buttons for the current state.
  final List<LabAction> actions;

  /// Extra activity controls / readouts shown in the sidebar.
  final Widget? sidebarExtra;
  final String? sidebarExtraTitle;

  /// Positioned widgets drawn above the canvas (not zoomed): readouts,
  /// trays, result panels...
  final List<Widget> overlays;

  /// Called once the curtain has lifted (HTML `enterLab()` / `initThreeJS`).
  final VoidCallback? onEnterLab;

  /// Called on a full reset (HTML `resetApp(false)`) after the shell state
  /// has been restored; the activity resets its scenario / step / scene.
  final VoidCallback? onReset;

  /// Shows the "Current Objective" HUD at the bottom of the canvas while
  /// the sidebar is open.
  final bool showHud;
  final bool showTools;

  @override
  State<LabShell> createState() => _LabShellState();
}

class _LabShellState extends State<LabShell> with TickerProviderStateMixin {
  late final AnimationController _curtain = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
    value: widget.controller.isLabActive ? 1 : 0,
  );
  late final AnimationController _iconPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  /// True while the sidebar's edge is being dragged (no width animation).
  bool _resizing = false;
  double _resizeStartX = 0;
  double _resizeStartWidth = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.attachResetHook(_fullReset);
    // The "Enter Lab" button is built outside the curtain's AnimatedBuilder,
    // so rebuild when the curtain starts or stops moving; otherwise it stays
    // disabled after a full reset.
    _curtain.addStatusListener(_onCurtainStatus);
  }

  void _onCurtainStatus(AnimationStatus _) {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant LabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detachResetHook();
      widget.controller.attachResetHook(_fullReset);
    }
  }

  @override
  void dispose() {
    widget.controller.detachResetHook();
    _curtain.dispose();
    _iconPulse.dispose();
    super.dispose();
  }

  void _enterLab() {
    if (_curtain.isAnimating) return;
    widget.controller.style.curtain.play();
    _curtain.forward().whenComplete(() {
      if (!mounted) return;
      _iconPulse.stop();
      widget.controller.markLabActive(true);
      widget.onEnterLab?.call();
    });
  }

  void _fullReset() {
    final c = widget.controller;
    c.style.curtain.play();
    c.resetShellState();
    c.markLabActive(false);
    _iconPulse.repeat(reverse: true);
    _curtain.reverse();
    widget.onReset?.call();
  }

  void _exit() {
    widget.controller.style.click.play();
    Navigator.of(context).maybePop();
  }

  /// Narrowest and widest sidebar for a screen of [width].
  (double, double) _sidebarRange(double width) {
    final min = math.max(180.0, width * 0.2);
    return (min, math.max(min, width * 0.5));
  }

  double _sidebarWidth(double width) {
    final (min, max) = _sidebarRange(width);
    return (width * widget.controller.sidebarFraction).clamp(min, max);
  }

  /// Grip on the sidebar's right edge: drag it to resize the sidebar.
  Widget _resizeHandle(LabPalette p, double width) {
    final c = widget.controller;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragDown: (d) {
          _resizeStartX = d.globalPosition.dx;
          _resizeStartWidth = _sidebarWidth(width);
        },
        onHorizontalDragStart: (_) => setState(() => _resizing = true),
        onHorizontalDragUpdate: (d) => setState(() {
          final (min, max) = _sidebarRange(width);
          final w = _resizeStartWidth + d.globalPosition.dx - _resizeStartX;
          c.sidebarFraction = w.clamp(min, max) / width;
        }),
        onHorizontalDragEnd: (_) => setState(() => _resizing = false),
        onHorizontalDragCancel: () => setState(() => _resizing = false),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 4,
            height: _resizing ? 64 : 40,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: _resizing ? 0.9 : 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  /// Room kept clear of canvas cards: the tool column on the right.
  EdgeInsets _canvasMargin(EdgeInsets pad) =>
      EdgeInsets.fromLTRB(4, 4, widget.showTools ? 56 + pad.right : 4, 4);

  /// Activity overlay cards can be dragged anywhere on the canvas. Full-size
  /// layers (Positioned.fill) stay put.
  Widget _movableOverlay(Widget overlay, int index, EdgeInsets margin) {
    if (overlay is! Positioned) return overlay;
    if (overlay.left == 0 && overlay.top == 0 && overlay.right == 0 && overlay.bottom == 0) {
      return overlay;
    }
    return Positioned.fill(
      key: overlay.key,
      child: LabMovable(
        controller: widget.controller,
        id: 'overlay-$index-${overlay.child.runtimeType}',
        margin: margin,
        left: overlay.left,
        top: overlay.top,
        right: overlay.right,
        bottom: overlay.bottom,
        width: overlay.width,
        height: overlay.height,
        child: overlay.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final p = c.palette;
        // Canvas text (labText) follows the lab's font.
        final font = c.style.font.orAmbient(Theme.of(context).textTheme.bodyMedium);
        LabFont.active = font;
        final size = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final s = context.labScale;
        final sidebarW = _sidebarWidth(size.width);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          },
          child: Theme(
            data: p.theme(font),
            child: LabStyleScope(
              style: c.style,
              palette: p,
              child: Scaffold(
                backgroundColor: p.bg,
                body: Stack(
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: _resizing ? Duration.zero : const Duration(milliseconds: 380),
                          curve: Curves.easeInOutCubic,
                          width: c.isSidebarOpen ? sidebarW : 0,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: sidebarW,
                                    maxWidth: sidebarW,
                                    child: _Sidebar(shell: widget, palette: p, scale: s),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                width: 10,
                                child: _resizeHandle(p, size.width),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildCanvas(context, p, s, pad)),
                      ],
                    ),
                    if (!c.isSidebarOpen && c.isLabActive)
                      Positioned.fill(
                        child: LabMovable(
                          controller: c,
                          id: 'mission',
                          top: 12 + pad.top,
                          left: 76 + pad.left,
                          child: _FloatingMissionCard(shell: widget, palette: p, scale: s),
                        ),
                      ),
                    // Menu button: fixed position, won't slide with the sidebar,
                    // always in front of the sidebar and canvas.
                    Positioned(
                      top: 16 + pad.top,
                      left: 16 + pad.left,
                      child: _fixedButton(
                        p,
                        tooltip: c.t('menu'),
                        icon: c.isSidebarOpen ? Icons.menu_open : Icons.menu,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          c.toggleSidebar();
                        },
                      ),
                    ),
                    if (c.popup != null) _PopupLayer(controller: c, palette: p, scale: s),
                    if (c.settingsOpen) _SettingsLayer(controller: c, palette: p, scale: s),
                    _buildCurtain(context, p, s, pad),
                    // Back button: top-right, above the tool column, in front of
                    // everything (curtain included) so it is always reachable.
                    Positioned(
                      top: 16 + pad.top,
                      right: 8 + pad.right,
                      child: _fixedButton(
                        p,
                        tooltip: c.t('back_home'),
                        icon: Icons.arrow_back_rounded,
                        onPressed: _exit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The menu / back button (48 px tap target).
  Widget _fixedButton(
    LabPalette p, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      color: p.buttonIcon,
      iconSize: 28,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: p.buttonBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.buttonBorder),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    final w = widget;
    final instruction = _currentInstruction(w);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: p.canvasBg),
          LabZoomViewer(controller: c, child: w.stage),
          for (var i = 0; i < w.overlays.length; i++) _movableOverlay(w.overlays[i], i, _canvasMargin(pad)),
          if (w.showHud && c.isSidebarOpen && instruction.isNotEmpty)
            Positioned.fill(
              child: LabMovable(
                controller: c,
                id: 'hud',
                margin: _canvasMargin(pad),
                left: 12,
                right: 60 + pad.right,
                bottom: 8 + pad.bottom,
                child: Center(
                  child: _HudChip(text: instruction, palette: p, scale: s, label: c.t('curr_obj')),
                ),
              ),
            ),
          if (w.showTools)
            Positioned(
              right: 8 + pad.right,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ToolsPanel(controller: c, palette: p, scale: s),
              ),
            ),
          // Kept clear of the floating mission card and the tool column.
          Positioned(
            top: 10 + pad.top,
            left: labOverlayInsets(context, c).left + 4,
            right: labOverlayInsets(context, c).right,
            child: Center(
              child: _ToastView(toast: c.toast, palette: p, scale: s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurtain(BuildContext context, LabPalette p, double s, EdgeInsets pad) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: _curtain,
      builder: (context, child) {
        if (_curtain.value >= 1) return const SizedBox.shrink();
        final dy = Curves.easeInOutCubic.transform(_curtain.value);
        return FractionalTranslation(translation: Offset(0, -dy), child: child);
      },
      child: Material(
        color: p.curtainBg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [p.curtainGlow, p.curtainBg.withValues(alpha: 0)], radius: 0.9),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32 * s, vertical: 24 * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween(begin: 0.55, end: 1.0).animate(_iconPulse),
                            child: Icon(widget.icon, size: 56 * s, color: p.accent),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainText,
                              fontSize: 30 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: p.curtainMuted, fontSize: 15 * s, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 24 * s),
                          FilledButton.icon(
                            onPressed: _curtain.isAnimating ? null : _enterLab,
                            icon: Icon(Icons.play_arrow_rounded, size: 22 * s),
                            label: Text(c.t('enter_lab')),
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: p.onAccent,
                              padding: EdgeInsets.symmetric(horizontal: 30 * s, vertical: 14 * s),
                              textStyle: TextStyle(fontSize: 17 * s, fontWeight: FontWeight.w800),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Left of the back button, which the shell draws above the curtain.
            Positioned(
              top: 20 + pad.top,
              right: 64 + pad.right,
              child: TextButton.icon(
                onPressed: c.toggleLanguage,
                icon: const Icon(Icons.translate, size: 18),
                label: Text(c.lang.badge, style: const TextStyle(fontWeight: FontWeight.w800)),
                style: TextButton.styleFrom(foregroundColor: p.curtainIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Width of the floating mission card shown while the sidebar is collapsed.
double _missionCardWidth(Size size, double s) => (size.width * 0.36).clamp(200.0, 380.0 * s);

/// Insets (relative to the canvas area) that keep activity overlays clear
/// of the shell's own canvas UI: the tool column on the right and, while
/// the sidebar is collapsed, the menu button + floating mission card on the
/// left. Use `left`/`right` for overlays placed along the top edge, e.g.
/// `Positioned(top: 10, left: i.left, right: i.right, child: Center(...))`.
EdgeInsets labOverlayInsets(BuildContext context, LabController c) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final s = context.labScale;
  final left = c.isSidebarOpen ? 8.0 : 76 + pad.left + _missionCardWidth(size, s) + 8;
  return EdgeInsets.fromLTRB(left, 8 + pad.top, 56 + pad.right, 8 + pad.bottom);
}

String _currentInstruction(LabShell w) {
  if (w.instruction != null) return w.instruction!;
  if (w.steps.isEmpty) return '';
  final i = (w.currentStep - 1).clamp(0, w.steps.length - 1);
  return w.steps[i].action;
}

// ============================================================== SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.shell, required this.palette, required this.scale});

  final LabShell shell;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = shell.controller;
    final p = palette;
    final s = scale;
    final f = s * c.fontScale;
    final pad = MediaQuery.paddingOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border(right: BorderSide(color: p.border)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(4, 0))],
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(12 * s + pad.left, 12 + pad.top, 12 * s, 8 * s),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _header(context, p, s),
                SizedBox(height: 12 * s),
                if (shell.scenarioNames.length > 1) ...[_scenarioSelector(p, s, f), SizedBox(height: 12 * s)],
                _targetOutput(p, s, f),
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(c.t('actions'), size: 10.5 * s, icon: Icons.touch_app),
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s),
                ],
                if (shell.sidebarExtra != null) ...[
                  SizedBox(height: 14 * s),
                  LabSectionLabel(shell.sidebarExtraTitle ?? c.t('controls'), size: 10.5 * s, icon: Icons.tune),
                  SizedBox(height: 8 * s),
                  shell.sidebarExtra!,
                ],
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10 * s + pad.left, 10 * s, 10 * s, 10 * s + pad.bottom),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: Text(
                  c.t('footer'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text.withValues(alpha: 0.85),
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, LabPalette p, double s) {
    final c = shell.controller;
    Widget headerBtn(IconData icon, String tip, VoidCallback onTap, {String? text}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17 * s, color: p.textStrong),
                if (text != null) ...[
                  SizedBox(width: 4 * s),
                  Text(
                    text,
                    style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12 * s),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Leaves room for the fixed menu button at top-left.
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Container(
                  width: 34 * s,
                  height: 34 * s,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(shell.icon, color: p.accent, size: 20 * s),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shell.title,
                        style: TextStyle(
                          color: p.textStrong,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5 * s,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        shell.subtitle,
                        style: TextStyle(color: p.textMuted, fontSize: 10 * s, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        Wrap(
          spacing: 6 * s,
          runSpacing: 6 * s,
          alignment: WrapAlignment.center,
          children: [
            headerBtn(Icons.translate, c.t('toggle_language'), c.toggleLanguage, text: c.lang.badge),
            headerBtn(Icons.restart_alt, c.t('reset_lab'), () {
              c.style.click.play();
              c.requestFullReset();
            }),
            headerBtn(Icons.settings, c.t('settings'), c.toggleSettings),
          ],
        ),
      ],
    );
  }

  Widget _scenarioSelector(LabPalette p, double s, double f) {
    final c = shell.controller;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c.t('select_scenario').toUpperCase(),
            style: TextStyle(color: p.textMuted, fontSize: 9.5 * s, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          SizedBox(height: 6 * s),
          for (var i = 0; i < shell.scenarioNames.length; i++) ...[
            if (i > 0) SizedBox(height: 6 * s),
            _scenarioTile(p, s, f, i),
          ],
        ],
      ),
    );
  }

  Widget _scenarioTile(LabPalette p, double s, double f, int i) {
    final c = shell.controller;
    final selected = i == shell.scenarioIndex;
    final done = c.completedScenarios.contains(i);
    return Material(
      color: selected ? p.accent.withValues(alpha: 0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: selected || shell.onScenarioChanged == null
            ? null
            : () {
                c.style.scenario.play();
                shell.onScenarioChanged!(i);
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.accent : p.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : (selected ? Icons.menu_book : Icons.radio_button_unchecked),
                size: 16 * s,
                color: done ? p.success : (selected ? p.accent : p.textMuted),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  shell.scenarioNames[i],
                  style: TextStyle(
                    color: selected ? p.textStrong : p.text,
                    fontSize: 11.5 * f,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetOutput(LabPalette p, double s, double f) {
    final c = shell.controller;
    final steps = shell.steps;
    final hasSteps = steps.isNotEmpty;
    final cur = shell.currentStep;
    final idx = hasSteps ? (cur - 1).clamp(0, steps.length - 1) : 0;
    final step = hasSteps ? steps[idx] : null;
    final instruction = _currentInstruction(shell);

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabSectionLabel(c.t('target_output'), size: 10.5 * s, icon: Icons.track_changes),
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              c.t('mission_obj'),
              style: TextStyle(color: p.textMuted, fontSize: 10 * f, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3 * s),
            Text(
              shell.objective,
              style: TextStyle(color: p.text, fontSize: 12.5 * f, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ],
          if (hasSteps) ...[
            SizedBox(height: 10 * s),
            Row(
              children: [
                Text(
                  '${c.t('step')} ${cur.clamp(1, steps.length)} ${c.t('of')} ${steps.length}',
                  style: TextStyle(color: p.textStrong, fontSize: 11 * f, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Wrap(
                    spacing: 4 * s,
                    runSpacing: 4 * s,
                    alignment: WrapAlignment.end,
                    children: [
                      for (var i = 1; i <= steps.length; i++)
                        Container(
                          width: 16 * s,
                          height: 16 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < cur
                                ? p.info.withValues(alpha: 0.25)
                                : (i == cur ? p.accent : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(color: i < cur ? p.info : (i == cur ? p.accent : p.cardBorder)),
                          ),
                          child: i < cur
                              ? Icon(Icons.check, size: 10 * s, color: p.info)
                              : Text(
                                  '$i',
                                  style: TextStyle(
                                    fontSize: 8.5 * s,
                                    fontWeight: FontWeight.w800,
                                    color: i == cur ? p.onAccent : p.textMuted,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (instruction.isNotEmpty) ...[
            SizedBox(height: 10 * s),
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.accent.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 14 * s, color: p.accent),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          c.t('curr_obj').toUpperCase(),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 9.5 * f,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step != null && step.concept.isNotEmpty && shell.instruction == null) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      '${c.t('concept_focus')} ${step.concept}',
                      style: TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w700),
                    ),
                  ],
                  SizedBox(height: 4 * s),
                  Text(
                    instruction,
                    style: TextStyle(color: p.textStrong, fontSize: 12.5 * f, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================= FLOATING MISSION CARD

class _FloatingMissionCard extends StatefulWidget {
  const _FloatingMissionCard({required this.shell, required this.palette, required this.scale});

  final LabShell shell;
  final LabPalette palette;
  final double scale;

  @override
  State<_FloatingMissionCard> createState() => _FloatingMissionCardState();
}

class _FloatingMissionCardState extends State<_FloatingMissionCard> {
  bool _minimized = false;

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    final c = shell.controller;
    final p = widget.palette;
    final s = widget.scale;
    final size = MediaQuery.sizeOf(context);
    final width = _missionCardWidth(size, s);
    final instruction = _currentInstruction(shell);
    final steps = shell.steps;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: size.height - 24),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(10 * s),
        borderColor: p.accent.withValues(alpha: 0.6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, size: 15 * s, color: p.accent),
                  SizedBox(width: 5 * s),
                  Expanded(
                    child: Text(
                      c.t('mission_obj').toUpperCase(),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      c.style.click.play();
                      setState(() => _minimized = !_minimized);
                    },
                    child: Tooltip(
                      message: _minimized ? c.t('expand') : c.t('minimize'),
                      child: Icon(_minimized ? Icons.expand_more : Icons.expand_less, size: 20 * s, color: p.textMuted),
                    ),
                  ),
                ],
              ),
              if (!_minimized) ...[
                if (shell.objective.isNotEmpty) ...[
                  SizedBox(height: 6 * s),
                  Text(
                    shell.objective,
                    style: TextStyle(color: p.text, fontSize: 11.5 * s, height: 1.35, fontWeight: FontWeight.w500),
                  ),
                ],
                if (instruction.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: p.accent.withValues(alpha: 0.5)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (steps.isNotEmpty)
                            TextSpan(
                              text: '${c.t('step')} ${shell.currentStep.clamp(1, steps.length)}/${steps.length} • ',
                              style: TextStyle(color: p.accent, fontWeight: FontWeight.w800),
                            ),
                          TextSpan(text: instruction),
                        ],
                      ),
                      style: TextStyle(
                        color: p.textStrong,
                        fontSize: 11.5 * s,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                if (shell.actions.isNotEmpty) ...[
                  SizedBox(height: 8 * s),
                  LabActionList(actions: shell.actions, scale: s, dense: true),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================ CANVAS UI

class _HudChip extends StatelessWidget {
  const _HudChip({required this.text, required this.palette, required this.scale, required this.label});

  final String text;
  final String label;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520 * s),
      child: LabGlassCard(
        palette: palette,
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
        borderColor: palette.accent.withValues(alpha: 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, size: 12 * s, color: palette.accent),
                SizedBox(width: 4 * s),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 9 * s,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2 * s),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textStrong, fontWeight: FontWeight.w700, fontSize: 11 * s, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale.clamp(0.85, 1.25);
    Widget tool(IconData icon, String tip, VoidCallback onTap, {bool active = false}) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 34 * s,
            height: 34 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: active ? p.accent.withValues(alpha: 0.18) : Colors.transparent,
            ),
            child: Icon(icon, size: 19 * s, color: active ? p.accent : p.textMuted),
          ),
        ),
      );
    }

    final divider = Container(
      width: 24 * s,
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 3 * s),
      color: p.cardBorder,
    );

    return LabGlassCard(
      palette: p,
      padding: EdgeInsets.all(4 * s),
      radius: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tool(c.showLabels ? Icons.label : Icons.label_off, c.t('tool_labels'), c.toggleLabels, active: c.showLabels),
          divider,
          tool(c.camLocked ? Icons.lock : Icons.lock_open, c.t('tool_lock'), c.toggleCamLock, active: c.camLocked),
          tool(Icons.pan_tool_alt, c.t('tool_pan'), c.togglePanMode, active: c.panMode),
          tool(Icons.center_focus_strong, c.t('tool_reset_view'), c.resetView),
          tool(Icons.zoom_in, c.t('tool_zoom_in'), c.zoomIn),
          tool(Icons.zoom_out, c.t('tool_zoom_out'), c.zoomOut),
        ],
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.toast, required this.palette, required this.scale});

  final LabToast? toast;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = toast;
    final s = scale;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: t == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(t.id),
                padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                decoration: BoxDecoration(
                  color: t.isError ? palette.danger : palette.toastBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.isError ? Icons.error : Icons.info,
                      size: 16 * s,
                      color: t.isError ? palette.onDanger : palette.toastText,
                    ),
                    SizedBox(width: 6 * s),
                    Flexible(
                      child: Text(
                        t.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.isError ? palette.onDanger : palette.toastText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5 * s,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ==================================================================== POPUP

class _PopupLayer extends StatelessWidget {
  const _PopupLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final builder = c.popup;
    if (builder == null) return const SizedBox.shrink();
    final content = builder();
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final accent = content.accent ?? p.accent;
    final width = (size.width * 0.6).clamp(260.0, 470.0 * s);

    return Positioned.fill(
      child: LabMovable(
        controller: c,
        id: 'popup',
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(scale: v, child: child),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: size.height * 0.86),
              decoration: BoxDecoration(
                color: p.popupBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (drag anywhere on the card to move it).
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                    decoration: BoxDecoration(
                      color: p.popupHeader,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Icon(content.icon, color: accent, size: 18 * s),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            content.title,
                            style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 14 * s),
                          ),
                        ),
                        Icon(Icons.drag_indicator, size: 18 * s, color: p.textMuted),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: c.t('close'),
                          onPressed: () => c.hidePopup(),
                          icon: Icon(Icons.close, size: 18 * s, color: p.text),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(14 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (content.heading != null) ...[
                            Container(
                              padding: EdgeInsets.only(bottom: 4 * s),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: p.cardBorder)),
                              ),
                              child: Text(
                                content.heading!.toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5 * s,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            SizedBox(height: 8 * s),
                          ],
                          if (content.body != null)
                            Text(
                              content.body!,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13 * s * c.fontScale.clamp(0.9, 1.4),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          if (content.extra != null) ...[SizedBox(height: 10 * s), content.extra!],
                          if (content.actions.isNotEmpty) ...[
                            SizedBox(height: 14 * s),
                            LabActionList(actions: content.actions, scale: s),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================= SETTINGS

class _SettingsLayer extends StatelessWidget {
  const _SettingsLayer({required this.controller, required this.palette, required this.scale});

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale;
    final size = MediaQuery.sizeOf(context);
    final label = TextStyle(color: p.textStrong, fontSize: 13 * s, fontWeight: FontWeight.w600);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: c.toggleSettings,
              child: const ColoredBox(color: Color(0x80000000)),
            ),
          ),
          Positioned.fill(
            child: LabMovable(
              controller: c,
              id: 'settings',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: (size.width * 0.5).clamp(260.0, 360.0 * s),
                  constraints: BoxConstraints(maxHeight: size.height * 0.88),
                  decoration: BoxDecoration(
                    color: p.dialogBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(18 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.t('settings'),
                                style: TextStyle(color: p.textStrong, fontSize: 17 * s, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: c.toggleSettings,
                              tooltip: c.t('close'),
                              icon: Icon(Icons.close, color: p.text),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('theme'), style: label)),
                            FilledButton.tonalIcon(
                              onPressed: c.toggleTheme,
                              icon: Icon(c.isDark ? Icons.dark_mode : Icons.light_mode, size: 18 * s),
                              label: Text(c.isDark ? c.t('light_mode') : c.t('dark_mode')),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * s),
                        Row(
                          children: [
                            Expanded(child: Text(c.t('font_size'), style: label)),
                            Text(
                              '${c.fontSize.round()}px',
                              style: TextStyle(color: p.textMuted, fontSize: 12 * s),
                            ),
                          ],
                        ),
                        Slider(
                          value: c.fontSize,
                          min: c.style.font.minSize,
                          max: c.style.font.maxSize,
                          divisions: (c.style.font.maxSize - c.style.font.minSize).round(),
                          onChanged: c.setFontSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
