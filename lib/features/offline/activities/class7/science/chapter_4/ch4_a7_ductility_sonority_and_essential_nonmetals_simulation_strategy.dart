// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 4 • Activity 7
/// Ductility, Sonority and Essential Non-metals ("Wire and Bell").
///
/// Native Flutter port of
/// `Cl7S-Ch4-A7-Ductility_Sonority_and_Essential_Nonmetals_Simulation_Strategy.html`.
///
/// Scenario 1 (The Wire-Drawing Test): drag a material into the
/// wire-drawing machine and hold PULL. Metals (copper, aluminium, iron)
/// stretch into a thin wire; non-metals (sulfur, coal) crack and break.
/// Finally sort all five materials into the Ductile / Not Ductile trays.
///
/// Scenario 2 (The Sound Ring Test): drag an object onto the sound stand and
/// STRIKE it. Metals (bell, steel plate) ring with a long, decaying waveform;
/// wood and sulfur give a dull thud. A conclusion quiz ends the scenario.
class Ch4A7DuctilitySonorityAndEssentialNonmetalsSimulationStrategyPage extends StatefulWidget {
  const Ch4A7DuctilitySonorityAndEssentialNonmetalsSimulationStrategyPage({super.key});

  @override
  State<Ch4A7DuctilitySonorityAndEssentialNonmetalsSimulationStrategyPage> createState() =>
      _Ch4A7DuctilitySonorityAndEssentialNonmetalsSimulationStrategyPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects, bundled in `assets/audio/class7/`.
///
/// Mixkit IDs (mixkit.co, free licence): click 2568, toggle 166,
/// correct 2870, wrong 946, success 270, scenario 1107, curtain 2633,
/// drop 2364, pickup 2356, machine 859, crack 2945, ring 931, thud 2182.
/// `machine`, `crack`, `ring` and `thud` stand in for the HTML's
/// synthesised WebAudio effects (machine whir, breaking noise, bell ring and
/// dull thud).
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
  drop('drop.mp3'),
  pickup('pickup.mp3'),

  /// Wire-drawing machine starts pulling (HTML `playMachine`).
  machine('machine.mp3'),

  /// A brittle material cracks (HTML `playBreak`).
  crack('crack.mp3'),

  /// A sonorous object rings (HTML `playRing`).
  ring('ring.mp3'),

  /// A non-sonorous object thuds (HTML `playThud`).
  thud('thud.mp3');

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
      await player.play(AssetSource('audio/class7/${sound.file}'), volume: volume, mode: PlayerMode.lowLatency);
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
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color green = Color(0xFF22C55E);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green700 = Color(0xFF15803D);
  static const Color red = Color(0xFFEF4444);
  static const Color red400 = Color(0xFFF87171);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red900 = Color(0xFF7F1D1D);
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

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
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
const _font = LabFont(family: null, fallback: null, size: 15, minSize: 12, maxSize: 24);

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
    'appTitle': 'Wire and Bell',
    'appSubtitle': 'Class 7: The World of Metals and Non-metals',
    'scen1Opt': 'Scenario 1: The Wire-Drawing Test',
    'scen2Opt': 'Scenario 2: The Sound Ring Test',

    // Objective boards (shown before each scenario starts).
    's1_board_desc':
        "Copper and aluminium are used in electrical wiring. But can you draw sulfur or coal into a wire? Let's test the 'ductility' of different materials.",
    's1_board_btn': 'Start Testing',
    's2_board_desc':
        "Why are bells made of metal? Let's strike different objects and listen to the sound waves they produce to understand 'sonority'.",
    's2_board_btn': 'Start Listening',

    // HUD line of every step (HTML `hud`).
    's1_hud1': 'DRAG Copper to the machine and hold PULL to draw a wire.',
    's1_hud2': 'REPEAT with Aluminium and Iron.',
    's1_hud3': 'TEST Sulfur and Coal.',
    's1_hud4': 'SORT materials into the Ductile and Not Ductile trays.',
    's2_hud1': 'DRAG the Metal Bell to the stand and tap the STRIKE hammer.',
    's2_hud2': 'TEST the Steel Plate, Wood Block, and Sulfur.',
    's2_hud3': 'COMPLETE the conclusion quiz.',

    // Observation log.
    'data_log': 'Observation Log',
    'btn_clear': 'Clear',
    'th_action': 'Action',
    'th_result': 'Result',
    'no_data': 'No observations yet.',
    'log_pull': 'Pull {mat}',
    'log_strike': 'Strike {mat}',
    'log_wire_ductile': 'Drawn into wire',
    'log_wire_brittle': 'Crumbled/Broke',
    'log_sound_ring': 'Clear ringing sound',
    'log_sound_dull': 'Dull thud',

    // Materials.
    'mat_copper': 'Copper',
    'mat_aluminium': 'Aluminium',
    'mat_iron': 'Iron',
    'mat_sulfur': 'Sulfur',
    'mat_coal': 'Coal',
    'mat_bell': 'Metal Bell',
    'mat_plate': 'Steel Plate',
    'mat_wood': 'Wood Block',

    // Scenario 1 apparatus.
    'machine_title': 'Wire-Drawing Machine',
    'drop_material': 'Drop Material Here',
    'pull_btn': 'PULL',
    'tray_ductile': 'Ductile (Can form wires)',
    'tray_brittle': 'Not Ductile (Breaks)',

    // Scenario 2 apparatus.
    'sound_stand': 'Sound Test Stand',
    'drop_item': 'Drop Item Here',
    'waveform': 'Waveform',
    'strike_btn': 'Strike',
    'res_ring': 'RINGING (Sonorous)',
    'res_dull': 'DULL THUD (Non-sonorous)',

    // Conclusion quiz.
    'q2_title': 'Conclusion',
    'q2_desc': 'Based on the tests, complete the statement:',
    'q2_a': 'A. Metals are generally brittle and dull.',
    'q2_b': 'B. Metals are generally sonorous (produce a ringing sound).',
    'q2_c': 'C. Non-metals produce the clearest ringing sound.',

    // Feedback.
    'succ_ductile': 'Success! {mat} is ductile.',
    'err_brittle': '{mat} is brittle and breaks!',
    'inc_sort': 'Incorrect. Check the test results.',
    'inc_read': 'Incorrect. Re-read the observation.',

    // Summary popup.
    'observation_title': 'Key Takeaway',
    'sc_complete': 'Scenario Complete!',
    'btn_next_sc': 'Next Scenario',
    's1_summary':
        '<strong>Ductility Understood!</strong>\nMetals like copper and aluminium can be drawn into thin wires because they are ductile. Non-metals like sulfur and coal are brittle and break.',
    's2_summary':
        '<strong>Sonority Confirmed!</strong>\nMetals are sonorous; they produce a ringing sound when struck. Non-metals produce dull sounds.',
  },
  'hi': {
    'appTitle': 'तार और घंटी',
    'appSubtitle': 'कक्षा 7: धातु और अधातु की दुनिया',
    'scen1Opt': 'परिदृश्य 1: तार खींचने का परीक्षण',
    'scen2Opt': 'परिदृश्य 2: ध्वनि परीक्षण',

    's1_board_desc':
        "तांबे और एल्यूमीनियम का उपयोग बिजली के तारों में किया जाता है। लेकिन क्या आप सल्फर या कोयले को तार में खींच सकते हैं? आइए विभिन्न सामग्रियों की 'तन्यता' का परीक्षण करें।",
    's1_board_btn': 'परीक्षण शुरू करें',
    's2_board_desc':
        'घंटियां धातु की क्यों बनी होती हैं? आइए ध्वन्यात्मकता को समझने के लिए विभिन्न वस्तुओं पर प्रहार करें और उनकी ध्वनि तरंगों को सुनें।',
    's2_board_btn': 'सुनना शुरू करें',

    's1_hud1': 'तांबे को मशीन पर खींचें और तार बनाने के लिए "खींचें" बटन दबाए रखें।',
    's1_hud2': 'एल्यूमीनियम और लोहे के साथ दोहराएं।',
    's1_hud3': 'सल्फर और कोयले का परीक्षण करें।',
    's1_hud4': 'सामग्रियों को तन्य और गैर-तन्य ट्रे में छांटें।',
    's2_hud1': 'धातु की घंटी को स्टैंड पर खींचें और हथौड़े से प्रहार करें।',
    's2_hud2': 'स्टील प्लेट, लकड़ी के ब्लॉक और सल्फर का परीक्षण करें।',
    's2_hud3': 'निष्कर्ष प्रश्नोत्तरी पूरी करें।',

    'data_log': 'अवलोकन लॉग',
    'btn_clear': 'साफ़ करें',
    'th_action': 'कार्रवाई',
    'th_result': 'परिणाम',
    'no_data': 'अभी तक कोई अवलोकन नहीं।',
    'log_pull': '{mat} को खींचा',
    'log_strike': '{mat} पर प्रहार',
    'log_wire_ductile': 'तार में खींचा गया',
    'log_wire_brittle': 'टूट गया',
    'log_sound_ring': 'स्पष्ट बजने वाली ध्वनि',
    'log_sound_dull': 'मंद ध्वनि',

    'mat_copper': 'तांबा',
    'mat_aluminium': 'एल्यूमीनियम',
    'mat_iron': 'लोहा',
    'mat_sulfur': 'सल्फर',
    'mat_coal': 'कोयला',
    'mat_bell': 'धातु की घंटी',
    'mat_plate': 'स्टील प्लेट',
    'mat_wood': 'लकड़ी का ब्लॉक',

    'machine_title': 'तार खींचने की मशीन',
    'drop_material': 'सामग्री यहाँ छोड़ें',
    'pull_btn': 'खींचें',
    'tray_ductile': 'तन्य (तार बन सकता है)',
    'tray_brittle': 'गैर-तन्य (टूट जाता है)',

    'sound_stand': 'ध्वनि परीक्षण स्टैंड',
    'drop_item': 'वस्तु यहाँ छोड़ें',
    'waveform': 'तरंग',
    'strike_btn': 'प्रहार करें',
    'res_ring': 'बज रहा है (ध्वन्यात्मक)',
    'res_dull': 'मंद ध्वनि (गैर-ध्वन्यात्मक)',

    'q2_title': 'निष्कर्ष',
    'q2_desc': 'परीक्षणों के आधार पर, कथन पूरा करें:',
    'q2_a': 'A. धातुएं आमतौर पर भंगुर और सुस्त होती हैं।',
    'q2_b': 'B. धातुएं आमतौर पर ध्वन्यात्मक (बजने वाली ध्वनि) होती हैं।',
    'q2_c': 'C. अधातुएं सबसे स्पष्ट बजने वाली ध्वनि उत्पन्न करती हैं।',

    'succ_ductile': 'सफलता! {mat} तन्य है।',
    'err_brittle': '{mat} भंगुर है और टूट जाता है!',
    'inc_sort': 'गलत। परीक्षण के परिणामों की जांच करें।',
    'inc_read': 'गलत। अवलोकन को फिर से पढ़ें।',

    'observation_title': 'मुख्य निष्कर्ष',
    'sc_complete': 'परिदृश्य पूर्ण!',
    'btn_next_sc': 'अगला परिदृश्य',
    's1_summary':
        '<strong>तन्यता समझ में आई!</strong>\nतांबे और एल्यूमीनियम जैसी धातुओं को पतले तारों में खींचा जा सकता है क्योंकि वे तन्य होती हैं। सल्फर और कोयले जैसी अधातुएं भंगुर होती हैं और टूट जाती हैं।',
    's2_summary':
        '<strong>ध्वन्यात्मकता की पुष्टि!</strong>\nधातुएँ ध्वन्यात्मक होती हैं; टकराने पर वे बजने वाली ध्वनि उत्पन्न करती हैं। अधातुएँ मंद ध्वनि उत्पन्न करती हैं।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      title: 'Scenario 1: The Wire-Drawing Test',
      objective: 'Investigate ductility by testing which materials can be drawn into wires.',
      steps: [
        LabStep(
          concept: 'Ductility in Metals',
          action: 'DRAG Copper to the machine and hold PULL.',
          observation: 'Copper stretches into a continuous, thin wire. It is ductile.',
        ),
        LabStep(
          concept: 'Comparing Metals',
          action: 'TEST Aluminium and Iron.',
          observation: 'Aluminium and Iron also form wires, demonstrating that metals are generally ductile.',
        ),
        LabStep(
          concept: 'Brittleness of Non-metals',
          action: 'TEST Sulfur and Coal.',
          observation: 'These non-metals crack and break when pulled. They are brittle, not ductile.',
        ),
        LabStep(
          concept: 'Classification',
          action: 'DRAG materials from the trays to sort them.',
          observation: 'Metals are ductile, non-metals are generally non-ductile.',
        ),
      ],
    ),
    LabScenarioData(
      title: 'Scenario 2: The Sound Ring Test',
      objective: 'Investigate sonority by comparing the sounds produced when different materials are struck.',
      steps: [
        LabStep(
          concept: 'Sonority in Metals',
          action: 'TEST the Metal Bell.',
          observation: 'The bell produces a clear, sustained ringing sound (sonorous).',
        ),
        LabStep(
          concept: 'Comparing Materials',
          action: 'TEST the Steel Plate, Wood, and Sulfur.',
          observation: 'Metals (steel) ring, while non-metals (wood, sulfur) produce a dull thud.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'SELECT the correct conclusion statement.',
          observation: 'Metals are generally sonorous, making them ideal for bells and musical instruments.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      title: 'परिदृश्य 1: तार खींचने का परीक्षण',
      objective: 'परीक्षण करके तन्यता की जांच करें कि किन सामग्रियों को तारों में खींचा जा सकता है।',
      steps: [
        LabStep(
          concept: 'धातुओं में तन्यता',
          action: 'तांबे को मशीन पर खींचें और "खींचें" बटन दबाए रखें।',
          observation: 'तांबा एक पतले तार में खिंच जाता है। यह तन्य है।',
        ),
        LabStep(
          concept: 'धातुओं की तुलना',
          action: 'एल्यूमीनियम और लोहे का परीक्षण करें।',
          observation: 'एल्यूमीनियम और लोहा भी तार बनाते हैं, यह दर्शाता है कि धातुएँ तन्य हैं।',
        ),
        LabStep(
          concept: 'अधातुओं का भंगुर होना',
          action: 'सल्फर और कोयले का परीक्षण करें।',
          observation: 'खींचे जाने पर ये अधातुएं टूट जाती हैं। वे भंगुर हैं, तन्य नहीं।',
        ),
        LabStep(
          concept: 'वर्गीकरण',
          action: 'सामग्रियों को ट्रे से खींचकर छांटें।',
          observation: 'धातुएँ तन्य होती हैं, अधातुएँ आम तौर पर गैर-तन्य होती हैं।',
        ),
      ],
    ),
    LabScenarioData(
      title: 'परिदृश्य 2: ध्वनि परीक्षण',
      objective: 'विभिन्न सामग्रियों से उत्पन्न होने वाली ध्वनि की तुलना करके ध्वन्यात्मकता (Sonority) की जांच करें।',
      steps: [
        LabStep(
          concept: 'धातुओं में ध्वन्यात्मकता',
          action: 'धातु की घंटी का परीक्षण करें।',
          observation: 'घंटी एक स्पष्ट, बजने वाली ध्वनि उत्पन्न करती है।',
        ),
        LabStep(
          concept: 'सामग्रियों की तुलना',
          action: 'स्टील प्लेट, लकड़ी और सल्फर का परीक्षण करें।',
          observation: 'धातुएं (स्टील) बजती हैं, जबकि अधातुएं (लकड़ी, सल्फर) मंद ध्वनि उत्पन्न करती हैं।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'सही निष्कर्ष कथन का चयन करें।',
          observation: 'धातुएँ ध्वन्यात्मक होती हैं, जो उन्हें घंटियों और वाद्य यंत्रों के लिए आदर्श बनाती हैं।',
        ),
      ],
    ),
  ],
};

// ============================================================== MODEL

/// How a material is drawn (the HTML `.mat-3d-*` CSS shapes).
enum _Shape { cube, rock, plate, wood, bell }

/// A test material: its label, look and the property under test.
@immutable
class _Mat {
  const _Mat(
    this.id,
    this.labelKey,
    this.shape, {
    this.colors = const [],
    this.labelColor,
    this.ductile = false,
    this.sonorous = false,
    this.wireColor,
  });

  final String id;
  final String labelKey;
  final _Shape shape;

  /// Radial gradient (highlight, body, shadow) of cubes and rocks.
  final List<Color> colors;

  /// Tray label colour; `null` uses the palette's strong text colour.
  final Color? labelColor;
  final bool ductile;
  final bool sonorous;

  /// Colour of the drawn wire (ductile metals only).
  final Color? wireColor;
}

const List<Color> _sulfurColors = [Color(0xFFFEF08A), Color(0xFFCA8A04), Color(0xFF713F12)];

/// Scenario 1 materials (HTML `s1Mats`).
const List<_Mat> _wireMats = [
  _Mat(
    'copper',
    'mat_copper',
    _Shape.cube,
    colors: [Color(0xFFFBA94C), Color(0xFFC2410C), Color(0xFF7C2D12)],
    labelColor: Color(0xFFF97316),
    ductile: true,
    wireColor: Color(0xFFC2410C),
  ),
  _Mat(
    'aluminium',
    'mat_aluminium',
    _Shape.cube,
    colors: [Color(0xFFF8FAFC), Color(0xFF94A3B8), Color(0xFF334155)],
    labelColor: Color(0xFF9CA3AF),
    ductile: true,
    wireColor: Color(0xFF94A3B8),
  ),
  _Mat(
    'iron',
    'mat_iron',
    _Shape.cube,
    colors: [Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF0F172A)],
    labelColor: Color(0xFF64748B),
    ductile: true,
    wireColor: Color(0xFF475569),
  ),
  _Mat('sulfur', 'mat_sulfur', _Shape.rock, colors: _sulfurColors, labelColor: Color(0xFFEAB308)),
  _Mat(
    'coal',
    'mat_coal',
    _Shape.rock,
    colors: [Color(0xFF78716C), Color(0xFF292524), Color(0xFF000000)],
    labelColor: Color(0xFFA8A29E),
  ),
];

/// Scenario 2 objects (HTML `s2Mats`).
const List<_Mat> _soundMats = [
  _Mat('bell', 'mat_bell', _Shape.bell, sonorous: true),
  _Mat('plate', 'mat_plate', _Shape.plate, sonorous: true),
  _Mat('wood', 'mat_wood', _Shape.wood),
  _Mat('sulfur2', 'mat_sulfur', _Shape.rock, colors: _sulfurColors),
];

_Mat? _findMat(List<_Mat> list, String? id) {
  for (final m in list) {
    if (m.id == id) return m;
  }
  return null;
}

/// One row of the observation log: the action on a material and its result.
typedef _LogEntry = ({String actionKey, String matKey, String resultKey, bool positive});

/// The HTML `#interactive-ui-layer` box every scene is laid out in.
const Size _design = Size(1000, 700);

/// Tray, sorted and sound-tray card sizes (design units).
const Size _wireCard = Size(88, 104);
const Size _sortedCard = Size(76, 92);
const Size _soundCard = Size(116, 132);

// ============================================================== LOGIC

class _Ch4A7DuctilitySonorityAndEssentialNonmetalsSimulationStrategyPageState
    extends State<Ch4A7DuctilitySonorityAndEssentialNonmetalsSimulationStrategyPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();
  late final Ticker _ticker;
  double _time = 0;

  int _scenario = 0;

  /// 0 = objective board, 1..n = steps, n + 1 = scenario complete.
  int _step = 0;
  final List<_LogEntry> _log = [];

  // Scenario 1: wire drawing and sorting.
  final Set<String> _wireTested = {};
  String? _loaded;
  double _pull = 0;
  bool _pulling = false;
  bool _pullDone = false;
  bool _broke = false;

  /// Sorted material id -> placed in the Ductile tray.
  final Map<String, bool> _sorted = {};

  // Scenario 2: sound test.
  final Set<String> _soundTested = {};
  String? _onStand;
  bool _striking = false;
  double _strikeStart = -10;
  double _ringStart = -10;
  List<double> _bars = const [];
  String? _soundResult;

  /// Scale of the design box on screen (for the drag feedback).
  double _stageFit = 1;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];
  bool get _done => _step > _data.steps.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ ticker

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _time).clamp(0.0, 0.1);
    _time = now;
    if (_pulling) {
      final mat = _findMat(_wireMats, _loaded);
      if (mat == null) {
        _pulling = false;
      } else {
        // HTML pullLoop: progress += delta(ms) * 0.05, i.e. 50 units / s.
        _pull += dt * 50;
        if (mat.ductile ? _pull >= 100 : _pull > 30) _finishPull(mat);
      }
    }
    _frame.value = now;
  }

  // ------------------------------------------------------------ flow

  void _resetMachine() {
    _loaded = null;
    _pull = 0;
    _pulling = false;
    _pullDone = false;
    _broke = false;
  }

  void _resetStand() {
    _onStand = null;
    _striking = false;
    _strikeStart = -10;
    _ringStart = -10;
    _bars = const [];
    _soundResult = null;
  }

  /// HTML `changeScenario()` + `setupS1()` / `setupS2()`.
  void _resetScenarioState() {
    _lab.cancelPending();
    _step = 0;
    _log.clear();
    _wireTested.clear();
    _sorted.clear();
    _resetMachine();
    _soundTested.clear();
    _resetStand();
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _scenario = index;
      _resetScenarioState();
    });
  }

  /// HTML `resetApp()` (after the shell restored its own state).
  void _fullReset() {
    setState(() {
      _scenario = 0;
      _resetScenarioState();
    });
  }

  /// HTML `startActivityFromBoard()`.
  void _startActivity() {
    if (_step != 0) return;
    setState(() => _step = 1);
  }

  /// HTML `progressStep()`. Call inside `setState`.
  void _progressStep() {
    _step++;
    if (_done) _showSummary();
  }

  /// HTML `showSummary()`: the "Key Takeaway" popup.
  void _showSummary() {
    final index = _scenario;
    _lab.completedScenarios.add(index);
    _lab.openSidebar();
    _lab.showPopup(
      () => LabPopupContent(
        title: _lab.t('success'),
        icon: Icons.check_circle,
        accent: _Colors.blue,
        heading: _t('observation_title'),
        extra: _summaryBody(index),
        actions: [_nextAction(index)],
      ),
    );
  }

  /// "Next Scenario" after scenario 1, "Restart Lab" after scenario 2.
  LabAction _nextAction(int index, {bool highlight = false}) => index == 0
      ? LabAction(
          label: _t('btn_next_sc'),
          icon: Icons.arrow_forward,
          color: _Colors.blue600,
          foreground: Colors.white,
          highlight: highlight,
          onTap: () => _changeScenario(1),
        )
      : LabAction(
          label: _lab.t('btn_restart'),
          icon: Icons.restart_alt,
          highlight: highlight,
          onTap: _lab.requestFullReset,
        );

  void _addLog(String actionKey, _Mat mat, String resultKey, {required bool positive}) {
    _log.add((actionKey: actionKey, matKey: mat.labelKey, resultKey: resultKey, positive: positive));
  }

  void _clearLog() {
    _Audio.play(_Sound.click);
    setState(_log.clear);
  }

  // ------------------------------------------------- scenario 1: ductility

  bool get _machineOpen => _scenario == 0 && _step >= 1 && _step <= 3;

  bool _canLoadMachine(String id) =>
      _machineOpen && !_pulling && !_pullDone && !_wireTested.contains(id) && _findMat(_wireMats, id) != null;

  /// HTML `dropMat()`: a material is placed in the machine.
  void _loadMachine(String id) {
    if (!_canLoadMachine(id)) return;
    _Audio.play(_Sound.drop);
    setState(() {
      _loaded = id;
      _pull = 0;
      _broke = false;
    });
  }

  bool get _canPull => _machineOpen && _loaded != null && !_pullDone;

  /// HTML `startPulling()` (PULL pressed).
  void _startPull() {
    if (!_canPull || _pulling) return;
    _Audio.play(_Sound.machine);
    setState(() => _pulling = true);
  }

  /// HTML `stopPulling()` (PULL released): a ductile wire that was not fully
  /// drawn springs back to the start.
  void _stopPull() {
    if (!_pulling) return;
    setState(() {
      _pulling = false;
      final mat = _findMat(_wireMats, _loaded);
      if (mat != null && mat.ductile && _pull < 100) _pull = 0;
    });
  }

  /// HTML `finishPull(success)`.
  void _finishPull(_Mat mat) {
    final name = _t(mat.labelKey);
    setState(() {
      _pulling = false;
      _pullDone = true;
      _wireTested.add(mat.id);
      if (mat.ductile) {
        _pull = 100;
        _addLog('log_pull', mat, 'log_wire_ductile', positive: true);
      } else {
        _broke = true;
        _addLog('log_pull', mat, 'log_wire_brittle', positive: false);
      }
    });
    if (mat.ductile) {
      _Audio.play(_Sound.correct);
      _lab.showToast(labFormat(_t('succ_ductile'), {'mat': name}), sound: false);
    } else {
      _Audio.play(_Sound.crack);
      _lab.showToast(labFormat(_t('err_brittle'), {'mat': name}), isError: true, sound: false);
    }
    _lab.after(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        // The HTML checks run one after another, so a late test can
        // complete several steps at once.
        if (_step == 1 && mat.id == 'copper') _progressStep();
        if (_step == 2 && _wireTested.containsAll(const ['aluminium', 'iron'])) _progressStep();
        if (_step == 3 && _wireTested.containsAll(const ['sulfur', 'coal'])) _progressStep();
        _resetMachine();
      });
    });
  }

  /// HTML `dropSort(ev, isDuctileZone)`.
  void _sort(String id, {required bool ductileTray}) {
    final mat = _findMat(_wireMats, id);
    if (mat == null || _scenario != 0 || _step != 4 || _sorted.containsKey(id)) return;
    if (mat.ductile == ductileTray) {
      _Audio.play(_Sound.correct);
      setState(() {
        _sorted[id] = ductileTray;
        if (_sorted.length == _wireMats.length) _progressStep();
      });
    } else {
      _Audio.play(_Sound.wrong);
      _lab.showToast(_t('inc_sort'), isError: true, sound: false);
    }
  }

  // --------------------------------------------------- scenario 2: sonority

  bool get _standOpen => _scenario == 1 && (_step == 1 || _step == 2);

  bool _canLoadStand(String id) => _standOpen && !_striking && _findMat(_soundMats, id) != null;

  /// HTML `dropSoundMat()`.
  void _loadStand(String id) {
    if (!_canLoadStand(id)) return;
    _Audio.play(_Sound.drop);
    setState(() {
      _resetStand();
      _onStand = id;
    });
  }

  bool get _canStrike => _standOpen && _onStand != null && !_striking;

  /// HTML `strikeItem()`.
  void _strike() {
    final mat = _findMat(_soundMats, _onStand);
    if (!_canStrike || mat == null) return;
    setState(() {
      _striking = true;
      _strikeStart = _time;
      _soundTested.add(mat.id);
      _bars = _makeBars(sonorous: mat.sonorous);
      if (mat.sonorous) {
        _ringStart = _time;
        _soundResult = 'res_ring';
        _addLog('log_strike', mat, 'log_sound_ring', positive: true);
      } else {
        _soundResult = 'res_dull';
        _addLog('log_strike', mat, 'log_sound_dull', positive: false);
      }
    });
    _Audio.play(mat.sonorous ? _Sound.ring : _Sound.thud);
    _lab.after(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        if (_step == 1 && mat.id == 'bell') _progressStep();
        if (_step == 2 && _soundMats.every((m) => _soundTested.contains(m.id))) _progressStep();
        _resetStand();
      });
    });
  }

  /// HTML `drawWaveform()`: 30 bar heights (% of the screen). Sonorous
  /// objects decay slowly; dull ones die after a short burst.
  List<double> _makeBars({required bool sonorous}) {
    const n = 30;
    return [
      for (var i = 0; i < n; i++)
        sonorous ? (_rng.nextDouble() * 80 + 20) * (1 - i / n) : (i < 5 ? _rng.nextDouble() * 80 + 20 : 5),
    ];
  }

  /// HTML `checkS2Quiz(correct)`.
  void _answerQuiz({required bool correct}) {
    if (_scenario != 1 || _step != 3) return;
    if (correct) {
      _Audio.play(_Sound.correct);
      setState(_progressStep);
    } else {
      _Audio.play(_Sound.wrong);
      _lab.showToast(_t('inc_read'), isError: true, sound: false);
    }
  }

  // ------------------------------------------------------------ shell

  List<LabAction> _actions() {
    if (_step == 0) {
      return [
        LabAction(
          label: _t(_scenario == 0 ? 's1_board_btn' : 's2_board_btn'),
          icon: Icons.play_arrow_rounded,
          highlight: true,
          onTap: _startActivity,
        ),
      ];
    }
    if (_done) return [_nextAction(_scenario, highlight: true)];
    if (_canStrike) {
      return [LabAction(label: _t('strike_btn'), icon: Icons.hardware, highlight: true, silent: true, onTap: _strike)];
    }
    return const [];
  }

  /// Current objective: the board text, the step's HUD line or "complete".
  String _instruction() {
    if (_step == 0) return _t(_scenario == 0 ? 's1_board_desc' : 's2_board_desc');
    if (_done) return _t('sc_complete');
    return _t('s${_scenario + 1}_hud$_step');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.science,
          title: _t('appTitle'),
          subtitle: _t('appSubtitle'),
          scenarioNames: [_t('scen1Opt'), _t('scen2Opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: math.max(1, _step),
          instruction: _instruction(),
          actions: _actions(),
          sidebarExtraTitle: _t('data_log'),
          sidebarExtra: _logPanel(p, s),
          onReset: _fullReset,
          showHud: _step >= 1 && !_done,
          stage: LayoutBuilder(
            builder: (context, box) {
              if (box.hasBoundedWidth && box.hasBoundedHeight) {
                _stageFit = math.min(box.maxWidth / _design.width, box.maxHeight / _design.height);
              }
              return LabStage(
                designSize: _design,
                child: _step == 0 ? _board(p) : (_scenario == 0 ? _wireScene(p) : _soundScene(p)),
              );
            },
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------ common UI

  /// HTML `#ui-setup-board`: the objective card shown before each scenario.
  Widget _board(LabPalette p) {
    final first = _scenario == 0;
    return ColoredBox(
      color: p.isDark ? const Color(0xE6020617) : const Color(0xE6F1F5F9),
      child: Center(
        child: Container(
          width: 760,
          padding: const EdgeInsets.fromLTRB(40, 36, 40, 36),
          decoration: BoxDecoration(
            color: p.isDark ? _Colors.slate900 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _Colors.blue.withValues(alpha: 0.5), width: 4),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 16))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.track_changes, size: 64, color: _Colors.blue),
              const SizedBox(height: 16),
              Text(
                _data.objective,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textStrong, fontSize: 28, fontWeight: FontWeight.w900, height: 1.35),
              ),
              const SizedBox(height: 16),
              Text(
                _t(first ? 's1_board_desc' : 's2_board_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.isDark ? _Colors.blue100 : _Colors.slate600,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                key: const ValueKey('board-start'),
                onPressed: () {
                  _Audio.play(_Sound.click);
                  _startActivity();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _Colors.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _Colors.blue400, width: 2),
                  ),
                ),
                // Styled on the Text (not `textStyle`) so it keeps the app font.
                child: Text(
                  _t(first ? 's1_board_btn' : 's2_board_btn'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Blue pill title of an apparatus (hidden with the labels).
  Widget _badge(String text, {double size = 12}) {
    return Opacity(
      opacity: _lab.showLabels ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: _Colors.blue,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _Colors.blue300, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x993B82F6), blurRadius: 15, offset: Offset(0, 5))],
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: size, letterSpacing: 1.6),
        ),
      ),
    );
  }

  /// A material card (HTML `.glass-panel.custom-drag-item`).
  Widget _matCard(_Mat m, LabPalette p, Size size, {bool done = false, bool faded = false, double swatchScale = 1}) {
    return SizedBox.fromSize(
      size: size,
      child: Opacity(
        opacity: faded ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          decoration: BoxDecoration(
            color: p.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (m.labelColor ?? p.textMuted).withValues(alpha: 0.4), width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(3, 4))],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Transform.scale(scale: swatchScale, child: _Swatch(m)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Opacity(
                    opacity: _lab.showLabels ? 1 : 0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _t(m.labelKey),
                        maxLines: 1,
                        style: TextStyle(
                          // The HTML label colours are tuned for dark mode;
                          // darken them on the light theme for contrast.
                          color: m.labelColor == null
                              ? p.textStrong
                              : (p.isDark ? m.labelColor : labShade(m.labelColor!, -0.35)),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (done)
                const Positioned(top: -6, right: -2, child: Icon(Icons.check_circle, size: 20, color: _Colors.green)),
            ],
          ),
        ),
      ),
    );
  }

  /// A draggable material card (the HTML pointer drag with a ghost image).
  Widget _draggable(_Mat m, Size size, Widget card, {required bool enabled, required String key}) {
    return Draggable<String>(
      key: ValueKey(key),
      data: m.id,
      maxSimultaneousDrags: enabled ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => _Audio.play(_Sound.pickup),
      feedback: Builder(
        builder: (context) {
          // The stage is scaled to fit the canvas (and may be zoomed), but the
          // feedback lives in the app overlay, so scale it to match.
          final k = _stageFit * _lab.transform.value.getMaxScaleOnAxis() * 1.08;
          return FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: SizedBox(
              width: size.width * k,
              height: size.height * k,
              child: FittedBox(
                child: Material(
                  type: MaterialType.transparency,
                  child: Opacity(opacity: 0.92, child: card),
                ),
              ),
            ),
          );
        },
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: MouseRegion(cursor: enabled ? SystemMouseCursors.grab : MouseCursor.defer, child: card),
    );
  }

  /// Sidebar copy of the HTML `#observation-table`.
  Widget _logPanel(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final head = TextStyle(color: p.textStrong, fontSize: 11.5 * f, fontWeight: FontWeight.w800);
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
          Row(
            children: [
              Expanded(child: Text(_t('th_action'), style: head)),
              SizedBox(width: 8 * s),
              Expanded(child: Text(_t('th_result'), style: head)),
            ],
          ),
          Divider(height: 12 * s, color: p.cardBorder),
          if (_log.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6 * s),
              child: Text(
                _t('no_data'),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 11.5 * f, fontStyle: FontStyle.italic),
              ),
            )
          else
            for (final e in _log)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        labFormat(_t(e.actionKey), {'mat': _t(e.matKey)}),
                        style: TextStyle(color: p.text, fontSize: 11.5 * f, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        _t(e.resultKey),
                        style: TextStyle(
                          color: e.positive
                              ? (p.isDark ? _Colors.green400 : _Colors.green700)
                              : (p.isDark ? _Colors.red400 : _Colors.red700),
                          fontSize: 11.5 * f,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          if (_log.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const ValueKey('log-clear'),
                onPressed: _clearLog,
                icon: Icon(Icons.delete_sweep, size: 16 * s, color: _Colors.red),
                label: Text(
                  _t('btn_clear').toUpperCase(),
                  style: TextStyle(
                    color: _Colors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5 * s,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Body of the "Key Takeaway" popup (HTML `summary`).
  Widget _summaryBody(int index) {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Text.rich(
            TextSpan(children: _rich(_t(index == 0 ? 's1_summary' : 's2_summary'))),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text, fontSize: 13.5 * f, height: 1.55, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          _t('sc_complete'),
          textAlign: TextAlign.center,
          style: TextStyle(color: _Colors.blue, fontSize: 18 * s, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  // --------------------------------------------------- scenario 1: scene

  /// HTML `#ui-sc1`: tray + wire-drawing machine, then the sorting trays.
  Widget _wireScene(LabPalette p) {
    final sorting = _step >= 4;
    return Center(
      child: Padding(
        // Keeps the apparatus clear of the HUD chip at the bottom.
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: sorting
              ? [_sortPool(p), const SizedBox(height: 36), _sortTrays(p)]
              : [_wireTray(p), const SizedBox(height: 48), _machine()],
        ),
      ),
    );
  }

  Widget _wireTray(LabPalette p) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final m in _wireMats)
          _draggable(
            m,
            _wireCard,
            _matCard(
              m,
              p,
              _wireCard,
              done: _wireTested.contains(m.id),
              faded: _wireTested.contains(m.id) || _loaded == m.id,
            ),
            enabled: _canLoadMachine(m.id) && _loaded != m.id,
            key: 'wire-mat-${m.id}',
          ),
      ],
    );
  }

  /// HTML `#sc1-machine-container`.
  Widget _machine() {
    final mat = _findMat(_wireMats, _loaded);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _Colors.slate800,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _Colors.slate700, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 20))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _machineDropzone(mat),
              const SizedBox(width: 32),
              _forceMeter(),
              const SizedBox(width: 32),
              _pullButton(),
              const SizedBox(width: 32),
              _wireOutput(mat),
            ],
          ),
          Positioned(top: -54, left: -54, child: _badge(_t('machine_title'))),
        ],
      ),
    );
  }

  Widget _machineDropzone(_Mat? mat) {
    return DragTarget<String>(
      key: const ValueKey('machine-dropzone'),
      onWillAcceptWithDetails: (d) => _canLoadMachine(d.data),
      onAcceptWithDetails: (d) => _loadMachine(d.data),
      builder: (context, candidates, _) {
        final hot = candidates.isNotEmpty;
        return _Dashed(
          color: hot ? _Colors.blue : _Colors.slate500,
          width: 4,
          radius: 12,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 128,
            height: 128,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hot ? _Colors.blue.withValues(alpha: 0.2) : _Colors.slate900.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: hot ? [BoxShadow(color: _Colors.blue.withValues(alpha: 0.4), blurRadius: 20)] : null,
            ),
            child: mat == null
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _t('drop_material'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _Colors.slate500, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  )
                : Transform.scale(scale: 1.5, child: _Swatch(mat)),
          ),
        );
      },
    );
  }

  /// HTML `#force-meter`.
  Widget _forceMeter() {
    return Container(
      width: 16,
      height: 128,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: _Colors.slate900,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _Colors.slate700),
      ),
      child: ValueListenableBuilder<double>(
        valueListenable: _frame,
        builder: (context, _, _) => FractionallySizedBox(
          widthFactor: 1,
          heightFactor: _pull.clamp(0.0, 100.0) / 100,
          child: const ColoredBox(color: _Colors.red),
        ),
      ),
    );
  }

  /// HTML `#btn-pull`: hold to pull (pointer down / up, so a long press is
  /// never lost to another gesture).
  Widget _pullButton() {
    final enabled = _canPull;
    return Listener(
      key: const ValueKey('btn-pull'),
      onPointerDown: (_) => _startPull(),
      onPointerUp: (_) => _stopPull(),
      onPointerCancel: (_) => _stopPull(),
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 34),
            transform: Matrix4.translationValues(0, _pulling ? 8 : 0, 0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_Colors.red, _Colors.red700],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: _Colors.red900, offset: Offset(0, _pulling ? 2 : 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.keyboard_double_arrow_down, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _t('pull_btn'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HTML wire output box (`#wire-output` / `#crack-overlay`).
  Widget _wireOutput(_Mat? mat) {
    return Container(
      width: 256,
      height: 128,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _Colors.slate900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.slate700),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _frame,
            builder: (context, now, _) => CustomPaint(
              painter: _WirePainter(mat: mat, progress: _pull, broke: _broke, pulling: _pulling, time: now),
            ),
          ),
          if (_broke) const Center(child: Text('💥', style: TextStyle(fontSize: 40))),
        ],
      ),
    );
  }

  /// Step 4: the materials still to sort (HTML `#sc1-sort-pool`).
  Widget _sortPool(LabPalette p) {
    return SizedBox(
      height: _wireCard.height,
      child: Wrap(
        spacing: 16,
        alignment: WrapAlignment.center,
        children: [
          for (final m in _wireMats)
            if (!_sorted.containsKey(m.id))
              _draggable(m, _wireCard, _matCard(m, p, _wireCard), enabled: _step == 4, key: 'wire-mat-${m.id}'),
        ],
      ),
    );
  }

  /// Step 4: the Ductile / Not Ductile trays (HTML `#sorting-area`).
  Widget _sortTrays(LabPalette p) {
    // Narrower than the HTML's 896 px so the trays stay clear of the tool
    // column on the right of the canvas.
    return SizedBox(
      width: 800,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _sortTray(p, ductile: true)),
          const SizedBox(width: 24),
          Expanded(child: _sortTray(p, ductile: false)),
        ],
      ),
    );
  }

  Widget _sortTray(LabPalette p, {required bool ductile}) {
    final color = ductile ? _Colors.green : _Colors.red;
    final items = [
      for (final m in _wireMats)
        if (_sorted[m.id] == ductile) m,
    ];
    return DragTarget<String>(
      key: ValueKey(ductile ? 'tray-ductile' : 'tray-brittle'),
      onWillAcceptWithDetails: (d) => _step == 4 && !_sorted.containsKey(d.data),
      onAcceptWithDetails: (d) => _sort(d.data, ductileTray: ductile),
      builder: (context, candidates, _) {
        final hot = candidates.isNotEmpty;
        final tint = hot ? _Colors.blue : color;
        return _Dashed(
          color: tint,
          width: 2.5,
          radius: 16,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 190),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: hot ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: hot ? [BoxShadow(color: _Colors.blue.withValues(alpha: 0.4), blurRadius: 20)] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
                  ),
                  child: Text(
                    _t(ductile ? 'tray_ductile' : 'tray_brittle').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1.5),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final m in items)
                      KeyedSubtree(key: ValueKey('sorted-${m.id}'), child: _matCard(m, p, _sortedCard)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------- scenario 2: scene

  /// HTML `#ui-sc2`: tray + sound test stand, then the conclusion quiz.
  Widget _soundScene(LabPalette p) {
    if (_step >= 3) return Center(child: _quiz());
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_soundTray(p), const SizedBox(height: 28), _soundRig()],
        ),
      ),
    );
  }

  Widget _soundTray(LabPalette p) {
    return Wrap(
      spacing: 16,
      alignment: WrapAlignment.center,
      children: [
        for (final m in _soundMats)
          _draggable(
            m,
            _soundCard,
            _matCard(m, p, _soundCard, done: _soundTested.contains(m.id), faded: _onStand == m.id, swatchScale: 1.15),
            enabled: _canLoadStand(m.id),
            key: 'sound-mat-${m.id}',
          ),
      ],
    );
  }

  /// HTML `#sc2-machine-container`: stand, microphone, hammer and
  /// oscilloscope.
  Widget _soundRig() {
    final mat = _findMat(_soundMats, _onStand);
    return SizedBox(
      width: 700,
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Stand base.
          Positioned(
            left: 25,
            top: 340,
            width: 650,
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_Colors.slate400, _Colors.slate700, _Colors.slate900],
                  stops: [0, 0.82, 1],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0xCC000000), blurRadius: 30, offset: Offset(0, 20))],
              ),
            ),
          ),
          // Microphone arm and microphone.
          const Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _MicArmPainter())),
          ),
          Positioned(
            left: 92,
            top: 44,
            child: Transform.rotate(
              angle: 2.7,
              child: const Icon(
                Icons.mic,
                size: 46,
                color: _Colors.slate400,
                shadows: [Shadow(color: Color(0x99000000), blurRadius: 6, offset: Offset(2, 4))],
              ),
            ),
          ),
          // Pedestal.
          Positioned(
            left: 98,
            top: 292,
            width: 144,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_Colors.slate700, _Colors.slate500, _Colors.slate700]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border.all(color: _Colors.slate800, width: 3),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4))],
              ),
            ),
          ),
          Positioned(left: 80, top: 104, width: 180, height: 180, child: _soundDropzone(mat)),
          // Hammer stand and strike button.
          Positioned(
            left: 292,
            top: 212,
            width: 40,
            height: 128,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_Colors.slate600, _Colors.slate500, _Colors.slate800]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border.all(color: _Colors.slate900, width: 2),
              ),
            ),
          ),
          Positioned(left: 264, top: 104, width: 96, height: 96, child: _strikeButton()),
          // Oscilloscope and its stand.
          Positioned(left: 370, top: 36, width: 320, height: 212, child: _oscilloscope()),
          Positioned(
            left: 434,
            top: 248,
            width: 192,
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _Colors.slate700,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: _Colors.slate900, width: 3),
              ),
            ),
          ),
          const Positioned(
            left: 506,
            top: 278,
            width: 48,
            height: 62,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_Colors.slate800, _Colors.slate900],
                ),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, top: -12, child: Center(child: _badge(_t('sound_stand'), size: 13))),
        ],
      ),
    );
  }

  /// HTML `#sound-dropzone` with the sound waves.
  Widget _soundDropzone(_Mat? mat) {
    return DragTarget<String>(
      key: const ValueKey('sound-dropzone'),
      onWillAcceptWithDetails: (d) => _canLoadStand(d.data),
      onAcceptWithDetails: (d) => _loadStand(d.data),
      builder: (context, candidates, _) {
        final hot = candidates.isNotEmpty;
        return AnimatedScale(
          scale: hot ? 1.05 : 1,
          duration: const Duration(milliseconds: 200),
          child: _Dashed(
            circle: true,
            color: hot ? _Colors.blue400 : _Colors.slate400.withValues(alpha: 0.5),
            width: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (hot ? _Colors.slate700 : _Colors.slate800).withValues(alpha: 0.85),
                boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (mat == null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _t('drop_item'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _Colors.slate400, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    )
                  else
                    Transform.scale(scale: 2, child: _Swatch(mat)),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ValueListenableBuilder<double>(
                        valueListenable: _frame,
                        builder: (context, now, _) => CustomPaint(painter: _WavesPainter(now - _ringStart)),
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

  /// HTML `#btn-strike`: the hammer swings back and forth on a strike.
  Widget _strikeButton() {
    final enabled = _canStrike;
    return GestureDetector(
      key: const ValueKey('btn-strike'),
      onTap: enabled ? _strike : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_Colors.blue400, _Colors.blue700],
              ),
              border: Border.all(color: _Colors.blue900, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Center(
              child: ValueListenableBuilder<double>(
                valueListenable: _frame,
                builder: (context, now, _) {
                  final t = now - _strikeStart;
                  final swing = t < 0 || t > 0.2 ? 0.0 : (t < 0.1 ? t / 0.1 : (0.2 - t) / 0.1);
                  return Transform.rotate(
                    angle: -math.pi / 4 * swing,
                    alignment: Alignment.bottomRight,
                    child: const Icon(
                      Icons.hardware,
                      size: 48,
                      color: Colors.white,
                      shadows: [Shadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(2, 4))],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// HTML oscilloscope (`#waveform-display` + `#sound-result-text`).
  Widget _oscilloscope() {
    Widget led(Color c) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.8), blurRadius: 6)],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _Colors.slate900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Colors.slate800, width: 10),
        boxShadow: const [BoxShadow(color: Color(0xB3000000), blurRadius: 30, offset: Offset(15, 15))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _t('waveform').toUpperCase(),
                  style: const TextStyle(
                    color: _Colors.slate500,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              led(const Color(0xFFDC2626)),
              const SizedBox(width: 6),
              led(_Colors.green),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _Colors.slate800, width: 2),
              ),
              child: ValueListenableBuilder<double>(
                valueListenable: _frame,
                builder: (context, now, _) => CustomPaint(
                  painter: _ScopePainter(bars: _bars, age: now - _strikeStart),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 20,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _soundResult == null ? '' : _t(_soundResult!),
                key: const ValueKey('sound-result'),
                style: const TextStyle(
                  color: _Colors.cyan400,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: Color(0xE622D3EE), blurRadius: 8)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HTML `#s2-quiz`. Once answered, the right statement stays highlighted.
  Widget _quiz() {
    final answered = _done;
    Widget option(String key, {required bool correct}) {
      final reveal = answered && correct;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: reveal ? _Colors.green.withValues(alpha: 0.2) : _Colors.slate800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: reveal ? _Colors.green : _Colors.slate600),
          ),
          child: InkWell(
            key: ValueKey('quiz-${key.substring(3)}'),
            borderRadius: BorderRadius.circular(12),
            onTap: answered ? null : () => _answerQuiz(correct: correct),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _t(key),
                      style: const TextStyle(
                        color: _Colors.slate200,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (reveal) const Icon(Icons.check_circle, color: _Colors.green, size: 22),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 480,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _Colors.slate900,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _Colors.blue.withValues(alpha: 0.5), width: 2),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 16))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _t('q2_title').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: _Colors.blue, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            _t('q2_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: _Colors.slate300, fontSize: 15),
          ),
          const SizedBox(height: 24),
          option('q2_a', correct: false),
          option('q2_b', correct: true),
          option('q2_c', correct: false),
        ],
      ),
    );
  }
}

/// Turns the HTML `<strong>` markup into bold spans.
List<InlineSpan> _rich(String text) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'<strong>(.*?)</strong>');
  var i = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
    spans.add(
      TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    i = m.end;
  }
  if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
  return spans;
}

// ============================================================== PAINTERS

/// A material drawn like the HTML's CSS "3D" blocks.
class _Swatch extends StatelessWidget {
  const _Swatch(this.mat);

  final _Mat mat;

  static Size sizeOf(_Shape shape) => switch (shape) {
    _Shape.cube || _Shape.rock || _Shape.wood => const Size(48, 48),
    _Shape.plate => const Size(60, 34),
    _Shape.bell => const Size(48, 58),
  };

  @override
  Widget build(BuildContext context) => CustomPaint(size: sizeOf(mat.shape), painter: _SwatchPainter(mat));
}

/// Paints `.mat-3d-cube`, `.mat-3d-rock`, `.mat-3d-plate`, `.mat-3d-wood`
/// and `.mat-3d-bell`.
class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.mat);

  final _Mat mat;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (mat.shape) {
      case _Shape.cube:
        _block(canvas, size, RRect.fromRectAndRadius(rect, const Radius.circular(8)), const Alignment(-0.4, -0.4));
      case _Shape.rock:
        _block(
          canvas,
          size,
          RRect.fromRectAndCorners(
            rect,
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(24),
            bottomRight: const Radius.circular(8),
            bottomLeft: const Radius.circular(20),
          ),
          const Alignment(-0.2, -0.4),
          rock: true,
        );
      case _Shape.wood:
        _wood(canvas, size);
      case _Shape.plate:
        _plate(canvas, size);
      case _Shape.bell:
        _bell(canvas, size);
    }
  }

  static void _shadow(Canvas c, RRect rr, Offset offset, double blur, double alpha) {
    c.drawRRect(
      rr.shift(offset),
      Paint()
        ..color = Colors.black.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  /// Inset bevel: a light top-left edge and a dark bottom-right edge.
  static void _bevel(Canvas c, RRect rr, {required double light, required double dark}) {
    c.drawRRect(
      rr.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: light),
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: dark),
          ],
        ).createShader(rr.outerRect),
    );
  }

  /// Metal cube or non-metal rock lit from the top-left.
  void _block(Canvas c, Size size, RRect rr, Alignment light, {bool rock = false}) {
    _shadow(c, rr, const Offset(5, 5), 7, 0.4);
    c.drawRRect(
      rr,
      Paint()..shader = RadialGradient(center: light, radius: 1.0, colors: mat.colors).createShader(rr.outerRect),
    );
    _bevel(c, rr, light: rock ? 0.45 : 0.65, dark: rock ? 0.7 : 0.5);
    c.save();
    c.clipRRect(rr);
    if (rock) {
      c.translate(size.width * 0.3, size.height * 0.25);
      c.rotate(-math.pi / 6);
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: size.width * 0.3, height: size.height * 0.2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    } else {
      final gloss = Rect.fromLTWH(0, 0, size.width, size.height * 0.35);
      c.drawRect(
        gloss,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0)],
          ).createShader(gloss),
      );
    }
    c.restore();
  }

  /// Striped wooden block (45° grain).
  void _wood(Canvas c, Size size) {
    final rr = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6));
    _shadow(c, rr, const Offset(5, 5), 7, 0.5);
    c.save();
    c.clipRRect(rr);
    c.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF92400E));
    final grain = Paint()
      ..color = const Color(0xFF713F12)
      ..strokeWidth = 4;
    for (var x = -size.height; x < size.width + size.height; x += 8 * math.sqrt2) {
      c.drawLine(Offset(x, 0), Offset(x + size.height, size.height), grain);
    }
    final gloss = Rect.fromLTWH(0, 0, size.width, size.height * 0.4);
    c.drawRect(
      gloss,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0)],
        ).createShader(gloss),
    );
    c.restore();
    _bevel(c, rr, light: 0.2, dark: 0.8);
  }

  /// Steel plate seen slightly from above.
  void _plate(Canvas c, Size size) {
    final w = size.width;
    final side = Rect.fromLTWH(0, size.height - 18, w, 16);
    final top = Rect.fromLTWH(0, size.height - 25, w, 16);
    c.drawOval(
      Rect.fromLTWH(2, size.height - 10, w - 4, 10),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final rim = Paint()
      ..shader = const LinearGradient(
        colors: [_Colors.slate600, _Colors.slate300, _Colors.slate600],
      ).createShader(Rect.fromLTWH(0, top.top, w, side.bottom - top.top));
    c.drawOval(side, rim);
    c.drawRect(Rect.fromLTRB(0, top.center.dy, w, side.center.dy), rim);
    c.drawOval(top, Paint()..shader = const RadialGradient(colors: [Colors.white, _Colors.slate400]).createShader(top));
    c.drawOval(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _Colors.slate600,
    );
  }

  /// Brass bell with its hanging loop and lip.
  void _bell(Canvas c, Size size) {
    final w = size.width;
    c.drawOval(
      Rect.fromLTWH(4, size.height - 8, w - 8, 8),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    c.drawArc(
      Rect.fromCircle(center: Offset(w / 2, 9), radius: 6),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFB45309),
    );
    final lip = Rect.fromLTWH(0, 40, w, 12);
    c.drawOval(
      lip,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF92400E), Color(0xFFFCD34D), Color(0xFF92400E)],
        ).createShader(lip),
    );
    final dome = Rect.fromLTWH(2, 8, w - 4, 40);
    final rr = RRect.fromRectAndCorners(
      dome,
      topLeft: Radius.elliptical(dome.width / 2, 20),
      topRight: Radius.elliptical(dome.width / 2, 20),
      bottomLeft: const Radius.elliptical(4.4, 4),
      bottomRight: const Radius.elliptical(4.4, 4),
    );
    c.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFB45309), Color(0xFFFDE68A), Color(0xFFB45309)],
        ).createShader(dome),
    );
    c.save();
    c.clipRRect(rr);
    final low = Rect.fromLTRB(dome.left, dome.bottom - 12, dome.right, dome.bottom);
    c.drawRect(
      low,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.45), Colors.black.withValues(alpha: 0)],
        ).createShader(low),
    );
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _SwatchPainter old) => old.mat != mat;
}

/// Dashed outline around [child] (the HTML `border-dashed` drop zones).
class _Dashed extends StatelessWidget {
  const _Dashed({required this.color, required this.child, this.width = 2, this.radius = 12, this.circle = false});

  final Color color;
  final Widget child;
  final double width;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(color: color, width: width, radius: radius, circle: circle),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.width, required this.radius, required this.circle});

  final Color color;
  final double width;
  final double radius;
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final path = circle
        ? (Path()..addOval(rect))
        : (Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))));
    labDashedPath(
      canvas,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
      dash: width * 3,
      gap: width * 2,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.width != width || old.radius != radius || old.circle != circle;
}

/// The wire-drawing output: the die, the growing wire of a ductile metal or
/// the stub of a brittle non-metal that cracks and shatters.
class _WirePainter extends CustomPainter {
  const _WirePainter({
    required this.mat,
    required this.progress,
    required this.broke,
    required this.pulling,
    required this.time,
  });

  final _Mat? mat;
  final double progress;
  final bool broke;
  final bool pulling;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    // The die the material is pulled through.
    final die = Rect.fromLTWH(10, cy - 26, 12, 52);
    canvas.drawRRect(
      RRect.fromRectAndRadius(die, const Radius.circular(3)),
      Paint()..shader = const LinearGradient(colors: [_Colors.slate400, _Colors.slate600]).createShader(die),
    );
    canvas.drawCircle(Offset(16, cy), 3, Paint()..color = Colors.black);

    final m = mat;
    if (m == null) return;
    final t = (progress / 100).clamp(0.0, 1.0);
    if (m.ductile) {
      if (t <= 0) return;
      // HTML: the wire grows to 200 px while thinning from 10 to 2 px.
      final length = 200 * t;
      final thick = math.max(2.0, 10 - 8 * t);
      final base = m.wireColor ?? const Color(0xFFD97706);
      final wire = Rect.fromLTWH(16, cy - thick / 2, length, thick);
      canvas.drawRRect(
        RRect.fromRectAndRadius(wire, Radius.circular(thick / 2)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [labShade(base, 0.45), base, labShade(base, -0.4)],
          ).createShader(wire),
      );
      if (pulling) {
        final gx = 16 + (time * 120) % math.max(1.0, length);
        canvas.drawCircle(Offset(gx, cy - thick * 0.2), thick * 0.35, Paint()..color = const Color(0x80FFFFFF));
      }
      return;
    }

    // Brittle: strain grows until the HTML break point (30).
    final body = m.colors.length > 1 ? m.colors[1] : _Colors.slate500;
    if (!broke) {
      final strain = (progress / 30).clamp(0.0, 1.0);
      final shake = pulling ? math.sin(time * 70) * 1.5 * strain : 0.0;
      final stub = Rect.fromLTWH(22 + shake, cy - 10, 34, 20);
      canvas.drawRRect(RRect.fromRectAndRadius(stub, const Radius.circular(5)), Paint()..color = body);
      if (strain > 0.2) {
        final crack = Path()
          ..moveTo(stub.left + 10, stub.top)
          ..lineTo(stub.left + 16, stub.top + 7)
          ..lineTo(stub.left + 12, stub.top + 12)
          ..lineTo(stub.left + 18, stub.bottom);
        canvas.drawPath(
          crack,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 + strain
            ..color = Colors.black.withValues(alpha: 0.4 + 0.5 * strain),
        );
      }
      return;
    }
    // Shattered fragments.
    final rnd = math.Random(7);
    for (var i = 0; i < 10; i++) {
      final x = 40 + rnd.nextDouble() * 170;
      final y = cy + (rnd.nextDouble() - 0.5) * 80;
      final r = 3 + rnd.nextDouble() * 6;
      final a = rnd.nextDouble() * math.pi * 2;
      final shard = Path()
        ..moveTo(x + r * math.cos(a), y + r * math.sin(a))
        ..lineTo(x + r * math.cos(a + 2.2), y + r * math.sin(a + 2.2))
        ..lineTo(x + r * 0.7 * math.cos(a + 4.1), y + r * 0.7 * math.sin(a + 4.1))
        ..close();
      canvas.drawPath(shard, Paint()..color = labShade(body, (rnd.nextDouble() - 0.5) * 0.5));
    }
  }

  @override
  bool shouldRepaint(covariant _WirePainter old) =>
      old.mat != mat ||
      old.progress != progress ||
      old.broke != broke ||
      old.pulling != pulling ||
      (pulling && old.time != time);
}

/// Three expanding rings around a ringing object (HTML `.sound-wave`,
/// shown for 2 s).
class _WavesPainter extends CustomPainter {
  const _WavesPainter(this.elapsed);

  /// Seconds since the strike.
  final double elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    if (elapsed < 0 || elapsed > 2) return;
    final c = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final t = elapsed - i * 0.2;
      if (t < 0) continue;
      final phase = t % 1.0;
      final scale = 0.5 + 2.5 * phase;
      canvas.drawCircle(
        c,
        25 * scale,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * scale
          ..color = _Colors.blue.withValues(alpha: 1 - phase),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavesPainter old) => old.elapsed != elapsed;
}

/// The microphone arm of the sound test stand.
class _MicArmPainter extends CustomPainter {
  const _MicArmPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final arm = Path()
      ..moveTo(40, 340)
      ..lineTo(40, 80)
      ..arcToPoint(const Offset(80, 40), radius: const Radius.circular(40))
      ..lineTo(112, 40);
    canvas.drawPath(
      arm.shift(const Offset(3, 5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      arm,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = _Colors.slate600,
    );
  }

  @override
  bool shouldRepaint(covariant _MicArmPainter old) => false;
}

/// Oscilloscope screen: grid, idle trace and the strike's waveform bars.
class _ScopePainter extends CustomPainter {
  const _ScopePainter({required this.bars, required this.age});

  /// Bar heights in % of the screen height.
  final List<double> bars;

  /// Seconds since the strike (bars grow in over 0.12 s).
  final double age;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x2622D3EE)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 15) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final mid = size.height / 2;
    if (bars.isEmpty) {
      canvas.drawLine(
        Offset(0, mid),
        Offset(size.width, mid),
        Paint()
          ..color = _Colors.cyan400.withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );
      return;
    }
    final grow = (age / 0.12).clamp(0.0, 1.0);
    const barW = 6.0, gap = 2.0;
    final total = bars.length * (barW + gap) - gap;
    var x = (size.width - total) / 2;
    final glow = Paint()
      ..color = _Colors.cyan400.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final fill = Paint()..color = _Colors.cyan400;
    for (final pct in bars) {
      final h = size.height * pct / 100 * grow;
      final bar = RRect.fromRectAndRadius(Rect.fromLTWH(x, mid - h / 2, barW, h), const Radius.circular(2));
      canvas.drawRRect(bar, glow);
      canvas.drawRRect(bar, fill);
      x += barW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ScopePainter old) => old.bars != bars || old.age != age;
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
