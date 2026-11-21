// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 4 • Activity 5
/// Magnetic Fields Through Non-Magnetic Materials.
///
/// Native Flutter port of
/// `Cl6S-Ch4-A5-Magnetic_Fields_Through_Non_Magnetic_Materials.html`.
///
/// Scenario 1 (The Unseen Bridge): drag the bar magnet from the toolbox onto
/// the glowing testing spot; the compass needle swings by 35° and field lines
/// appear. A wooden block, a glass sheet and a plastic sheet placed between
/// the magnet and the compass leave the deflection unchanged (Observation
/// Table).
///
/// Scenario 2 (The Magnetic Maze Challenge): drag the magnet under a
/// cardboard maze to pull a steel ball from Start to Finish, then move it
/// near a glass water bowl to "fish" the steel pins inside.
class Ch4A5MagneticFieldsThroughNonMagneticMaterialsPage
    extends StatefulWidget {
  const Ch4A5MagneticFieldsThroughNonMagneticMaterialsPage({super.key});

  @override
  State<Ch4A5MagneticFieldsThroughNonMagneticMaterialsPage> createState() =>
      _Ch4A5MagneticFieldsThroughNonMagneticMaterialsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML has no sounds of its own; the lab
/// uses the shell tones plus pickup / drop for dragging the magnet.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// drop → `science/drop.mp3`, pickup → `science/pickup.mp3`.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Correct action / right answer.
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action / invalid move.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / success popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// Bar magnet released.
  drop('audio/class6/science/drop.mp3'),

  /// Bar magnet picked up.
  pickup('audio/class6/science/pickup.mp3');

  const _Sound(this.asset);
  final String asset;

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
        AssetSource(sound.asset),
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
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
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

/// Colours of this lab: the HTML's Tailwind UI colours and the Three.js
/// material colours of the scene.
abstract final class _Colors {
  // ---- UI (Tailwind classes used by the HTML).
  static const Color zslYellow = Color(0xFFEAB308); // "Enter Lab" button
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309); // "Wooden Block" button
  static const Color emerald600 = Color(0xFF059669); // "Glass Sheet" button
  static const Color cyan600 = Color(0xFF0891B2); // "Plastic Sheet" button
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1); // Tailwind `primary`
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900 = Color(0xFF312E81);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ---- Scene (Three.js materials).
  static const Color canvas = slate900; // #canvas-wrapper bg-[#0f172a]
  static const Color tableTop = Color(0xFF334155);
  static const Color tableRim = Color(0xFF94A3B8);
  static const Color tableLeg = Color(0xFF1E293B);
  static const Color toolbox = Color(0xFF64748B);
  static const Color spot = Color(0xFF6366F1); // rgba(99, 102, 241, .8)
  static const Color magnetN = Color(0xFFEF4444);
  static const Color magnetS = Color(0xFF3B82F6);
  static const Color brass = Color(0xFFD97706);
  static const Color dial = Color(0xFFF8FAFC);
  static const Color pivot = Color(0xFF475569);
  static const Color field = Color(0xFF06B6D4);
  static const Color wood = Color(0xFF854D0E);
  static const Color woodGrain = Color(0xFF5B3407);
  static const Color glass = Color(0xFFA7F3D0);
  static const Color plastic = Color(0xFF38BDF8);
  static const Color board = Color(0xFFD97706);
  static const Color wall = Color(0xFF78350F);
  static const Color pillar = Color(0xFF475569);
  static const Color start = Color(0xFF22C55E);
  static const Color finish = Color(0xFFEAB308);
  static const Color bowl = Color(0xFFBAE6FD);
  static const Color water = Color(0xFF0284C7);
  static const Color pin = Color(0xFFE2E8F0);
  static const Color pinEdge = Color(0xFF334155);
  static const Color fillLight = Color(0xFF6366F1); // PointLight 0x6366f1

  // ---- Floating object labels (`.html-label`).
  static const Color labelBg = Color(0xCC0F172A); // bg-slate-900/80
  static const Color labelBorder = slate700;
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
/// `accent` is the "Enter Lab" yellow (`bg-[#eab308] text-slate-900`) and
/// `primary` the Tailwind `primary` indigo in both themes. The canvas stays
/// navy in both themes, as in the HTML (`bg-[#0f172a]`).
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A),
    border: Color(0x26FFFFFF),
    card: Color(0xCC1E293B),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.canvas,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.indigo400,
    popupBg: _Colors.slate800,
    popupHeader: _Colors.indigo900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2F8FAFC),
    border: Color(0x26000000),
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.canvas,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.indigo600,
    popupBg: _Colors.white,
    popupHeader: _Colors.indigo50,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi. Sizes are the sidebar text size setting (px; the
/// HTML slider defaults to 15 px).
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

// =================================================================== STRINGS
//
// From the HTML `i18n` table (Telugu dropped). Step texts lose their "1."
// numbering (the shell numbers steps) and say "TAP" instead of "CLICK"; the
// step-5 text of Scenario 1 no longer mentions the dropped "Validate Model"
// button. English fragments inside Hindi strings ("(The Unseen Bridge)",
// "(confetti)") are removed. Scenario 1 is a predict-observe-record
// investigation (NCERT Activity 4.7): the sidebar asks a question instead of
// stating the result, the barrier toasts no longer say the field passes
// through, and the learner records each row; the step's outcome text
// confirms a correct record. Keys marked "added" are not in the HTML.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Magnetic Fields Through Non-Magnetic Materials',
    'app_subtitle': 'Class 6 • Exploring Magnets',
    'scen_1_opt': 'Scenario 1: The Unseen Bridge',
    'scen_2_opt': 'Scenario 2: The Magnetic Maze Challenge',
    's1_desc':
        "To test if a magnet's invisible field force can pass through "
        'non-magnetic barriers (wood, glass, plastic) to deflect a magnetic '
        'compass needle.',
    's2_desc':
        'To guide a steel ball through a cardboard maze using a magnet from '
        'underneath, and test magnetic fishing inside a glass water bowl.',
    'step_1_1':
        'DRAG the bar magnet from the toolbox and DROP it onto the glowing '
        'testing spot on the table.',
    'step_1_2':
        'OBSERVE the compass needle and RECORD in the Observation Table '
        "whether it is deflected. Then TAP 'Wooden Block' to place the "
        'wooden block between the magnet and the compass, and RECORD again.',
    'step_1_3':
        "TAP 'Remove Barrier', then TAP 'Glass Sheet' to place the thin "
        'glass sheet. RECORD whether the needle is still deflected.',
    'step_1_4':
        "TAP 'Remove Barrier', then TAP 'Plastic Sheet' to place the plastic "
        'sheet. RECORD whether the needle is still deflected.',
    'step_1_5':
        'REVIEW your Observation Table to confirm your conclusion. The '
        'conclusion opens automatically.',
    'step_2_1':
        'OBSERVE the cardboard maze board. DRAG the bar magnet underneath the '
        'green Start circle.',
    'step_2_2':
        'DRAG the magnet underneath the maze along the corridor path to pull '
        'the steel ball to the right.',
    'step_2_3':
        'Keep DRAGGING to guide the steel ball around the maze wall corners, '
        'without moving the magnet too fast.',
    'step_2_4':
        'DRAG the magnet under the gold glowing Finish circle to bring the '
        'steel ball there.',
    'step_2_5':
        'Bonus: DRAG the magnet near the glass water bowl on the right side '
        'of the table to fish the steel pins!',
    'step_2_6':
        'Challenge complete! Review the summary conclusion. It opens '
        'automatically.',
    // The HTML said the needle deflects "pointing its North pole away",
    // but the magnet's South pole faces the compass: unlike poles attract,
    // so the needle's North pole turns towards it (NCERT Activity 4.6).
    'out_1_1':
        'The bar magnet snaps into place. The compass needle deflects: its '
        "North pole turns towards the magnet's South pole (about 35°).",
    'out_1_2':
        'The wooden block is placed. Compass needle deflection angle remains '
        'exactly unchanged (35°).',
    'out_1_3':
        'The glass sheet is placed. Compass needle deflection angle remains '
        'exactly unchanged (35°).',
    'out_1_4':
        'The plastic sheet is placed. Compass needle deflection angle '
        'remains exactly unchanged (35°).',
    'out_1_5':
        "Investigation verified. The magnet's force field passes unimpeded "
        'through non-magnetic barriers.',
    'out_2_1':
        'The magnet snaps underneath the maze. The steel ball on top aligns '
        'with magnetic pull below.',
    'out_2_2':
        'As you drag the magnet below, the steel ball simultaneously follows '
        'its movement 1:1 above.',
    'out_2_3':
        'The steel ball smoothly navigates maze wall corners without losing '
        'connection.',
    'out_2_4':
        'The steel ball reaches the glowing Finish area and a success '
        'confetti animation triggers!',
    'out_2_5':
        'Steel pins inside the glass water bowl are attracted directly '
        'towards the magnet through glass!',
    'out_2_6':
        'Challenge verified. Magnetic force acts across distances and '
        'through non-magnetic containers.',
    'toast_snapped': 'Magnet snapped to testing position! Field lines active.',
    'toast_barrier_wood':
        'Wooden Block placed. Watch the compass needle, then record what you '
        'see.',
    'toast_barrier_glass':
        'Glass Sheet placed. Watch the compass needle, then record what you '
        'see.',
    'toast_barrier_plastic':
        'Plastic Sheet placed. Watch the compass needle, then record what you '
        'see.',
    'toast_barrier_cleared': 'Barrier removed. Air gap restored.',
    'toast_fast':
        'Magnet moved too fast! Move back under steel ball to recapture.',
    'toast_recaptured': 'Steel ball recaptured by magnetic field!',
    'toast_finish':
        'Congratulations! Steel ball reached Finish! Now move magnet near the '
        'glass water bowl on the right to fish pins!',
    'toast_fishing': 'Pins inside glass water bowl attracted towards magnet!',
    'observation_complete': 'Success!',
    'sum_s1_title': 'Unseen Bridge Confirmed!',
    'sum_s1_desc':
        'Conclusion: The compass needle deflected by 35° across air, wood, '
        'glass, and plastic alike. This proves magnetic field lines pass '
        'through non-magnetic materials unimpeded.',
    'sum_s2_title': 'Maze & Fishing Mastered!',
    'sum_s2_desc':
        'Conclusion: You guided the steel ball across cardboard and fished '
        'pins inside a glass bowl! Magnetic force acts across distances and '
        'penetrates non-magnetic barriers.',
    'obs_table': 'Observation Table',
    'tbl_barrier': 'Barrier Material',
    'tbl_deflected': 'Deflected?',
    'tbl_blocked': 'Blocked?',
    'mat_none': 'None (Air)',
    'mat_wood': 'Wooden Block',
    'mat_glass': 'Glass Sheet',
    'mat_plastic': 'Plastic Sheet',
    'yes': 'Yes (35°)',
    'no': 'No',
    'btn_remove_barrier': 'Remove Barrier',
    'tray_title': 'Barrier Materials Tray',
    'expected_outcome': 'Expected Outcome',
    // Added: recording the observations (Scenario 1).
    'predict_title': 'Predict and Observe',
    'ask_1_1':
        'What will the compass needle do when the bar magnet is placed near '
        'it? Drop the magnet on the glowing spot and watch the needle.',
    'ask_1_2':
        'Will a wooden block between the magnet and the compass change the '
        'deflection? Place it, watch the needle and record what you see.',
    'ask_1_3':
        'Will a thin glass sheet change the deflection? Place it, watch the '
        'needle and record what you see.',
    'ask_1_4':
        'Will a plastic sheet change the deflection? Place it, watch the '
        'needle and record what you see.',
    'btn_rec_yes': 'Needle deflected: Yes',
    'btn_rec_no': 'Needle deflected: No',
    'toast_record_wrong':
        'Look at the compass needle again: it still points about 35° away '
        'from North. Is it deflected?',
    'not_recorded': '?',
    'lbl_magnet': 'Bar Magnet',
    'lbl_compass': 'Magnetic Compass',
    'lbl_maze': 'Cardboard Maze',
    'lbl_ball': 'Steel Ball',
    'lbl_bowl': 'Glass Water Bowl',
    'pole_n': 'N',
    'pole_s': 'S',
  },
  'hi': {
    'app_title': 'अचुंबकीय पदार्थों के पार चुंबकीय क्षेत्र',
    'app_subtitle': 'कक्षा 6 • चुंबकों की खोज',
    'scen_1_opt': 'परिदृश्य 1: अदृश्य पुल',
    'scen_2_opt': 'परिदृश्य 2: चुंबकीय भूलभुलैया चुनौती',
    's1_desc':
        'यह परीक्षण करना कि क्या चुंबक का अदृश्य बल अचुंबकीय बाधाओं (लकड़ी, '
        'कांच, प्लास्टिक) के पार जाकर कंपास की सुई को विक्षेपित कर सकता है।',
    's2_desc':
        'नीचे से चुंबक का उपयोग करके स्टील की गेंद को कार्डबोर्ड भूलभुलैया में '
        'चलाना, और कांच के कटोरे में चुंबकीय मछली पकड़ने का परीक्षण करना।',
    'step_1_1':
        'टूलबॉक्स से छड़ चुंबक को खींचें और मेज के चमकते परीक्षण स्थान पर '
        'छोड़ें।',
    'step_1_2':
        'कंपास की सुई देखें और अवलोकन तालिका में दर्ज करें कि वह विक्षेपित है '
        "या नहीं। फिर चुंबक और कंपास के बीच लकड़ी का गुटका रखने के लिए 'लकड़ी "
        "का गुटका' पर टैप करें और फिर से दर्ज करें।",
    'step_1_3':
        "'बाधा हटाएं' पर टैप करें, फिर पतली कांच की शीट रखने के लिए "
        "'कांच की शीट' पर टैप करें। दर्ज करें कि सुई अब भी विक्षेपित है या "
        'नहीं।',
    'step_1_4':
        "'बाधा हटाएं' पर टैप करें, फिर प्लास्टिक शीट रखने के लिए "
        "'प्लास्टिक शीट' पर टैप करें। दर्ज करें कि सुई अब भी विक्षेपित है या "
        'नहीं।',
    'step_1_5':
        'अपने निष्कर्ष की पुष्टि के लिए अपनी अवलोकन तालिका की समीक्षा करें। '
        'निष्कर्ष अपने आप खुलेगा।',
    'step_2_1':
        'कार्डबोर्ड भूलभुलैया देखें। छड़ चुंबक को खींचकर हरे स्टार्ट घेरे के नीचे '
        'ले जाएं।',
    'step_2_2':
        'स्टील की गेंद को दाईं ओर खींचने के लिए भूलभुलैया के नीचे चुंबक को '
        'गलियारे के रास्ते पर खींचें।',
    'step_2_3':
        'चुंबक को बहुत तेज़ी से खींचे बिना स्टील की गेंद को भूलभुलैया की '
        'दीवारों के कोनों से आगे ले जाते रहें।',
    'step_2_4':
        'स्टील की गेंद को सुनहरे चमकते फिनिश घेरे तक लाने के लिए चुंबक को '
        'उसके नीचे खींचें।',
    'step_2_5':
        'बोनस: पिनें आकर्षित करने के लिए चुंबक को खींचकर मेज के दाईं ओर कांच '
        'के कटोरे के पास ले जाएं!',
    'step_2_6':
        'चुनौती पूरी हुई! सारांश निष्कर्ष की समीक्षा करें। यह अपने आप खुलेगा।',
    'out_1_1':
        'छड़ चुंबक सेट हो जाता है। कंपास की सुई विक्षेपित होती है: उसका उत्तरी '
        'ध्रुव चुंबक के दक्षिणी ध्रुव की ओर लगभग 35° घूम जाता है।',
    'out_1_2':
        'लकड़ी का गुटका रखा गया। कंपास सुई का विक्षेपण कोण बिल्कुल अपरिवर्तित '
        'रहता है (35°)।',
    'out_1_3':
        'कांच की शीट रखी गई। कंपास सुई का विक्षेपण कोण बिल्कुल अपरिवर्तित '
        'रहता है (35°)।',
    'out_1_4':
        'प्लास्टिक शीट रखी गई। कंपास सुई का विक्षेपण कोण बिल्कुल अपरिवर्तित '
        'रहता है (35°)।',
    'out_1_5':
        'जांच सत्यापित हुई। चुंबकीय बल रेखाएं अचुंबकीय बाधाओं के पार बिना रुके '
        'गुजरती हैं।',
    'out_2_1':
        'चुंबक भूलभुलैया के नीचे सेट हो जाता है। ऊपर रखी स्टील की गेंद नीचे के '
        'खिंचाव से संरेखित होती है।',
    'out_2_2':
        'जैसे ही आप नीचे चुंबक को खींचते हैं, स्टील की गेंद साथ-साथ 1:1 गति '
        'करती है।',
    'out_2_3':
        'स्टील की गेंद बिना संपर्क खोए भूलभुलैया के कोनों से सुगमता से निकलती '
        'है।',
    'out_2_4':
        'गेंद चमकते फिनिश क्षेत्र में पहुंचती है और सफलता का जश्न (रंगीन कागज़ '
        'की बौछार) सक्रिय होता है!',
    'out_2_5':
        'कांच के कटोरे में रखीं पिनें कांच की दीवारों के पार सीधे चुंबक की ओर '
        'आकर्षित होती हैं!',
    'out_2_6':
        'चुनौती सत्यापित हुई। चुंबकीय बल दूरी से और अचुंबकीय पात्रों के पार '
        'कार्य करता है।',
    'toast_snapped': 'चुंबक परीक्षण स्थान पर सेट हो गया! बल रेखाएं सक्रिय।',
    'toast_barrier_wood':
        'लकड़ी का गुटका रखा गया। कंपास की सुई देखें, फिर जो दिखे उसे दर्ज करें।',
    'toast_barrier_glass':
        'कांच की शीट रखी गई। कंपास की सुई देखें, फिर जो दिखे उसे दर्ज करें।',
    'toast_barrier_plastic':
        'प्लास्टिक शीट रखी गई। कंपास की सुई देखें, फिर जो दिखे उसे दर्ज करें।',
    'toast_barrier_cleared': 'बाधा हटा दी गई। हवा का अंतराल बहाल।',
    'toast_fast':
        'चुंबक बहुत तेज़ी से चला! गेंद को दोबारा पकड़ने के लिए वापस नीचे ले '
        'जाएं।',
    'toast_recaptured':
        'स्टील की गेंद चुंबकीय क्षेत्र द्वारा दोबारा पकड़ ली गई!',
    'toast_finish':
        'बधाई हो! गेंद फिनिश पर पहुंच गई! अब पिनें पकड़ने के लिए चुंबक को '
        'दाईं ओर कांच के कटोरे के पास ले जाएं!',
    'toast_fishing': 'कांच के कटोरे के अंदर की पिनें चुंबक की ओर आकर्षित हुईं!',
    'observation_complete': 'सफलता!',
    'sum_s1_title': 'अदृश्य पुल की पुष्टि हुई!',
    'sum_s1_desc':
        'निष्कर्ष: कंपास की सुई हवा, लकड़ी, कांच और प्लास्टिक सभी में 35° '
        'विक्षेपित हुई। यह साबित करता है कि चुंबकीय बल रेखाएं अचुंबकीय '
        'पदार्थों के पार बिना रुके गुजरती हैं।',
    'sum_s2_title': 'भूलभुलैया और मछली पकड़ना सफल!',
    'sum_s2_desc':
        'निष्कर्ष: आपने कार्डबोर्ड के आर-पार स्टील की गेंद चलाई और कांच के '
        'कटोरे में पिनें खींचीं! चुंबकीय बल दूरी से काम करता है और अचुंबकीय '
        'बाधाओं को पार करता है।',
    'obs_table': 'अवलोकन तालिका',
    'tbl_barrier': 'बाधा पदार्थ',
    'tbl_deflected': 'विक्षेपण?',
    'tbl_blocked': 'अवरुद्ध?',
    'mat_none': 'कोई नहीं (हवा)',
    'mat_wood': 'लकड़ी का गुटका',
    'mat_glass': 'कांच की शीट',
    'mat_plastic': 'प्लास्टिक शीट',
    'yes': 'हां (35°)',
    'no': 'नहीं',
    'btn_remove_barrier': 'बाधा हटाएं',
    'tray_title': 'बाधा सामग्री ट्रे',
    'expected_outcome': 'अपेक्षित परिणाम',
    'predict_title': 'अनुमान लगाएं और देखें',
    'ask_1_1':
        'जब छड़ चुंबक को कंपास के पास रखा जाएगा तो सुई क्या करेगी? चुंबक को '
        'चमकते स्थान पर छोड़ें और सुई को देखें।',
    'ask_1_2':
        'क्या चुंबक और कंपास के बीच लकड़ी का गुटका रखने से विक्षेपण बदलेगा? उसे '
        'रखें, सुई देखें और जो दिखे उसे दर्ज करें।',
    'ask_1_3':
        'क्या पतली कांच की शीट से विक्षेपण बदलेगा? उसे रखें, सुई देखें और जो '
        'दिखे उसे दर्ज करें।',
    'ask_1_4':
        'क्या प्लास्टिक शीट से विक्षेपण बदलेगा? उसे रखें, सुई देखें और जो दिखे '
        'उसे दर्ज करें।',
    'btn_rec_yes': 'सुई विक्षेपित: हां',
    'btn_rec_no': 'सुई विक्षेपित: नहीं',
    'toast_record_wrong':
        'कंपास की सुई को फिर से देखें: वह अब भी उत्तर से लगभग 35° हटी हुई है। '
        'क्या वह विक्षेपित है?',
    'not_recorded': '?',
    'lbl_magnet': 'छड़ चुंबक',
    'lbl_compass': 'चुंबकीय कंपास',
    'lbl_maze': 'कार्डबोर्ड भूलभुलैया',
    'lbl_ball': 'स्टील की गेंद',
    'lbl_bowl': 'कांच का कटोरा',
    'pole_n': 'उ',
    'pole_s': 'द',
  },
};

/// Steps per scenario (HTML `numSteps`: 5 and 6).
const List<int> _stepCounts = [5, 6];

/// The two scenarios for [lang] (HTML `step_x_y` / `out_x_y` keys). The HTML
/// steps have no concept text, so `concept` stays empty.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var sc = 1; sc <= _stepCounts.length; sc++)
      LabScenarioData(
        title: t('scen_${sc}_opt'),
        objective: t('s${sc}_desc'),
        steps: [
          for (var i = 1; i <= _stepCounts[sc - 1]; i++)
            LabStep(
              concept: '',
              action: t('step_${sc}_$i'),
              observation: t('out_${sc}_$i'),
            ),
        ],
      ),
  ];
}

/// Scenario data per language, built once.
final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the scene (stage coordinates).
const Size _design = Size(1000, 560);

/// Short drags must pick the magnet up (the default pan slop is large).
const double _touchSlop = 8;

/// Smallest touch target (magnet, tray buttons), in logical pixels.
const double _minTouch = 48;

/// Room kept for the shell's bottom HUD (two text lines) below the tray,
/// and for the toast row above it.
const double _hudClearance = 64;
const double _trayTop = 48;

/// Width of the barrier tray column.
const double _trayWidth = 118;

/// The tray shows its title only on screens at least this tall.
const double _trayTitleMinHeight = 360;

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  static const _V zero = _V(0, 0, 0);

  final double x;
  final double y;
  final double z;

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit {
    final l = length;
    return l == 0 ? this : this * (1 / l);
  }

  _V withY(double v) => _V(x, v, z);

  /// Distance in the horizontal plane (HTML `Vector2(x, z).distanceTo`).
  double distXZ(_V o) {
    final dx = x - o.x, dz = z - o.z;
    return math.sqrt(dx * dx + dz * dz);
  }

  double distTo(_V o) => (this - o).length;

  /// Three.js `rotation.y` by [a].
  _V rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }

  /// Three.js `rotation.z` by [a].
  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Pinhole projection of the HTML `PerspectiveCamera(45°)` at [eye] looking
/// at a target. The target is drawn 30 px below the stage centre so the
/// scene stays clear of the top cards (toast, mission card, table).
class _Proj {
  _Proj(this.eye, _V target) : f = (target - eye).unit {
    r = f.cross(const _V(0, 1, 0)).unit;
    u = r.cross(f);
  }

  /// Focal length for the 45° vertical field of view over the stage height.
  static final double focal = _design.height / 2 / math.tan(math.pi / 8);

  /// Three.js point-sprite scale (`size * (height / 2) / depth`).
  static const double pointScale = 280;

  static const Offset center = Offset(500, 310);

  final _V eye;
  final _V f;
  late final _V r;
  late final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a design point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray crosses the horizontal plane y = [py] (HTML
  /// `ray.intersectPlane(intersectPlane)`), or null.
  _V? onPlane(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }
}

// HTML cameras: setupScenario1 / setupScenario2.
const _V _eye1 = _V(0, 11, 14);
const _V _target1 = _V(0, 1, 0);
const _V _eye2 = _V(0, 12, 18);
const _V _target2 = _V(0, 2.5, 0);
final _Proj _proj1 = _Proj(_eye1, _target1);
final _Proj _proj2 = _Proj(_eye2, _target2);

// ---- Scenario 1 layout (HTML setupScenario1).
const double _tableW1 = 22, _tableD1 = 14; // createLabTable(22, 14)
const double _plane1 = 0.6; // intersectPlane y (magnet flat on table)
const _V _magnet1Home = _V(-7.5, 0.6, 0); // on the toolbox
const _V _spot = _V(-3, 0.6, 0); // glowing testing spot
const double _snapRadius = 2.0;
const _V _toolboxPos = _V(-7.5, 0.2, 0);
const _V _toolboxSize = _V(5.5, 0.4, 3);
const _V _compassPos = _V(4.5, 0.2, 0);
const _V _compassNeedle = _V(4.5, 0.6, 0); // needle-angle reference point
const _V _needleCenter = _V(4.5, 0.55, 0); // needle group y 0.35
const double _needleSnapped = 0.61; // ~35° away from N
const double _needleRange = 12; // deflection starts within 12 units
const double _needleGain = 0.08; // (12 - dist) * 0.08
const _V _barrierPos = _V(0.6, 1.4, 0);
const double _barrierH = 2.6, _barrierD = 4.5;

// ---- Scenario 2 layout (HTML setupScenario2).
const double _tableW2 = 24, _tableD2 = 16; // createLabTable(24, 16)
const double _plane2 = 1.6; // magnet confined underneath the maze board
const _V _magnet2Home = _V(-8, 1.6, 5.5);
const _V _ballHome = _V(-8, 3.5, 2.5);
const double _ballY = 3.5;
const double _ballR = 0.4;
const _V _mazePos = _V(-3.5, 3.0, 0);
const double _boardTop = 3.1; // board 0.2 thick at y 3.0
const _V _finishBall = _V(1.0, 3.5, -2.5); // finishWorldPos
const double _captureDist = 4.0;
const double _loseDist = 5.5;
const double _ballFollow = 0.4; // steelBall.position.lerp(target, 0.4)
const double _stepThreeX = -5.0; // ball.x milestone for step 3
const double _stepFourX = -1.0; // ball.x milestone for step 4
const double _finishDist = 2.5;
const double _fishMagnetX = 2.2;

/// Maze walls in world space: (centre, size). Boundary walls, then the
/// three internal obstacles (HTML `addWall(x, z, w, d)` + maze offset).
///
/// In the HTML the internal walls join the top boundary to the bottom one
/// (a closed chain, so Start and Finish are cut off from each other), and
/// the wall test never fires (its boxes are built before the maze group has
/// a world matrix). Here the wall at x = -2 stops at z = 2.4, leaving a gap
/// next to the bottom boundary: the path runs right along the lower
/// corridor, round that wall's end and up to Finish, and the ball cannot
/// pass through any wall ([_moveBall]).
const List<(_V, _V)> _mazeWalls = [
  (_V(-3.5, 3.4, -3.9), _V(12, 0.6, 0.2)),
  (_V(-3.5, 3.4, 3.9), _V(12, 0.6, 0.2)),
  (_V(-9.4, 3.4, 0), _V(0.2, 0.6, 8)),
  (_V(2.4, 3.4, 0), _V(0.2, 0.6, 8)),
  (_V(-6.0, 3.4, -1.8), _V(0.4, 0.6, 4.4)),
  (_V(-2.0, 3.4, 1.0), _V(0.4, 0.6, 2.8)),
  (_V(-4.0, 3.4, 0), _V(4.4, 0.6, 0.4)),
];

/// Largest move of the ball per collision sub-step.
const double _ballSubStep = 0.1;

/// Is the ball (radius [_ballR]) at x, z inside a maze wall?
bool _ballHitsWall(double x, double z) {
  for (final (c, size) in _mazeWalls) {
    if ((x - c.x).abs() < size.x / 2 + _ballR &&
        (z - c.z).abs() < size.z / 2 + _ballR) {
      return true;
    }
  }
  return false;
}

/// Moves the ball from [from] towards [to] on the board in small sub-steps;
/// a wall stops the blocked direction only, so the ball slides along it.
_V _moveBall(_V from, _V to) {
  final dx = to.x - from.x, dz = to.z - from.z;
  final n = math.max(1, (math.max(dx.abs(), dz.abs()) / _ballSubStep).ceil());
  var x = from.x, z = from.z;
  for (var i = 0; i < n; i++) {
    if (!_ballHitsWall(x + dx / n, z)) x += dx / n;
    if (!_ballHitsWall(x, z + dz / n)) z += dz / n;
  }
  return _V(x, from.y, z);
}

const _V _bowlPos = _V(6.5, 0.6, 0);
const _V _pinsStart = _V(0, -0.9, 0); // fishedPinsGroup.position
const _V _pinsEnd = _V(-1.2, 0.5, 0); // tween target
const double _pinsTween = 0.6; // 600 ms
const double _pinTilt = 1.2; // pin.rotation.z
const double _pinHalf = 0.45; // CylinderGeometry height 0.9

// ---- Confetti (HTML triggerConfetti).
const int _confettiCount = 300;
const double _confettiSize = 0.3;
const double _confettiFall = 0.12; // per 60 Hz frame
const double _confettiWrap = 20;

// ---- Timings.
const Duration _conclusionDelayS1 = Duration(milliseconds: 2500);
const Duration _conclusionDelayS2 = Duration(milliseconds: 1500);

/// The barrier between magnet and compass (HTML `placeBarrier(matType)`);
/// [air] is "no barrier" and names the first table row.
enum _Mat {
  air('mat_none', 0),
  wood('mat_wood', 0.8),
  glass('mat_glass', 0.3),
  plastic('mat_plastic', 0.4);

  const _Mat(this.key, this.thickness);

  /// Observation-table / button label key.
  final String key;

  /// Barrier thickness along x (HTML BoxGeometry width; 0 = no barrier).
  final double thickness;
}

/// Mutable simulation state read by the painter every frame.
class _Sim {
  int scenario = 0;
  int step = 1;
  double time = 0;

  bool dragging = false;
  _V grabOffset = _V.zero;

  // Scenario 1.
  _V magnet1 = _magnet1Home;
  bool snapped = false;
  _Mat barrier = _Mat.air;

  /// Tested materials in test order (HTML `barriersTested` keys).
  final List<_Mat> tested = [];

  /// Rows the learner has recorded ("Needle deflected: Yes").
  final Set<_Mat> recorded = {};
  double needle = 0;
  bool concluded = false;

  // Scenario 2.
  _V magnet2 = _magnet2Home;
  _V ball = _ballHome;
  bool captured = false;
  bool finished = false;
  bool fished = false;
  double fishStart = -1;
  bool confettiOn = false;
  final Float32List cx = Float32List(_confettiCount);
  final Float32List cy = Float32List(_confettiCount);
  final Float32List cz = Float32List(_confettiCount);
  final Int32List cColor = Int32List(_confettiCount);

  // Painting resources, created once and reused every frame.
  final _Pictures pictures = _Pictures();
  final _Draw draw = _Draw();
  final _TextCache text = _TextCache();
  final Float32List confettiPos = Float32List(_confettiCount * 12);
  final Int32List confettiColors = Int32List(_confettiCount * 6);
  final Path linesHidden = Path();
  final Path linesShown = Path();

  _Proj get proj => scenario == 0 ? _proj1 : _proj2;
  _V get magnet => scenario == 0 ? magnet1 : magnet2;
  double get planeY => scenario == 0 ? _plane1 : _plane2;

  set magnet(_V v) {
    if (scenario == 0) {
      magnet1 = v;
    } else {
      magnet2 = v;
    }
  }

  /// HTML animate(): target needle angle in Scenario 1.
  double get needleTarget {
    if (snapped) return _needleSnapped;
    final dist = magnet1.distTo(_compassNeedle);
    return dist < _needleRange ? (_needleRange - dist) * _needleGain : 0;
  }

  /// 0..1 progress of the pin "fishing" tween.
  double get fishProgress => fishStart < 0
      ? 0
      : ((time - fishStart) / _pinsTween).clamp(0.0, 1.0).toDouble();

  /// HTML `changeScenario(id)`: rebuilds the bench for [sc] at step 1.
  void reset(int sc) {
    scenario = sc;
    step = 1;
    dragging = false;
    grabOffset = _V.zero;
    magnet1 = _magnet1Home;
    snapped = false;
    barrier = _Mat.air;
    tested.clear();
    recorded.clear();
    needle = 0;
    concluded = false;
    magnet2 = _magnet2Home;
    ball = _ballHome;
    captured = false;
    finished = false;
    fished = false;
    fishStart = -1;
    confettiOn = false;
  }

  /// HTML `triggerConfetti()`: 300 points above the table, random colours.
  void startConfetti(math.Random rnd) {
    for (var i = 0; i < _confettiCount; i++) {
      cx[i] = (rnd.nextDouble() - 0.5) * 15;
      cy[i] = 15 + rnd.nextDouble() * 10;
      cz[i] = (rnd.nextDouble() - 0.5) * 15;
      cColor[i] = Color.from(
        alpha: 1,
        red: rnd.nextDouble(),
        green: rnd.nextDouble(),
        blue: rnd.nextDouble(),
      ).toARGB32();
    }
    confettiOn = true;
  }

  /// HTML animate(): confetti falls 0.12 per frame and wraps to y = 20.
  void fallConfetti(double dt) {
    final fall = _confettiFall * dt * 60;
    for (var i = 0; i < _confettiCount; i++) {
      cy[i] -= fall;
      if (cy[i] < 0) cy[i] = _confettiWrap;
    }
  }

  void dispose() {
    pictures.dispose();
    text.dispose();
  }
}

/// Pan recognizer that only claims pointers that start on the magnet
/// (decided by [canGrab]), so other drags still pan the zoomed canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _Ch4A5MagneticFieldsThroughNonMagneticMaterialsPageState
    extends State<Ch4A5MagneticFieldsThroughNonMagneticMaterialsPage>
    with SingleTickerProviderStateMixin {
  /// The HTML starts with the camera locked (`cameraLocked = true`).
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Sim _sim = _Sim();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  late final Ticker _ticker;

  /// Something changed since the last frame (repaint once).
  bool _dirty = true;

  /// Stage scale (screen px per design px) from the last layout.
  double _fit = 1;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_sim.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _sim.reset(0);
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
    _sim.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: needle easing, field-line rocking, falling confetti
  /// and the pin tween. Repaints only while something moves.
  void _onTick(Duration elapsed) {
    final s = _sim;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1).toDouble();
    s.time = now;
    var moving = _dirty || s.dragging;
    _dirty = false;
    if (s.scenario == 0) {
      // rotation.y += (target - rotation.y) * 0.1 per 60 Hz frame.
      final gap = s.needleTarget - s.needle;
      if (gap.abs() > 1e-4) {
        s.needle += gap * (1 - math.pow(0.9, dt * 60));
        moving = true;
      }
      if (s.snapped) moving = true; // field lines rock
    } else {
      if (s.confettiOn) {
        s.fallConfetti(dt);
        moving = true;
      }
      // The pin tween, plus a frame or two to land on its end pose.
      if (s.fishStart >= 0 && now - s.fishStart <= _pinsTween + 0.1) {
        moving = true;
      }
    }
    if (moving) _frame.value = now;
  }

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(id)` / Restart: cancels pending timers and
  /// rebuilds the scene for [scenario] at step 1.
  void _loadScenario(int scenario) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _sim.reset(scenario));
    _dirty = true;
    _lab.resetView(sound: false);
  }

  void _showConclusion(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _stepCounts.length,
      delay: scenario == 0 ? _conclusionDelayS1 : _conclusionDelayS2,
      title: () => _t('observation_complete'),
      heading: () => _t('sum_s${scenario + 1}_title'),
      body: () => _t('sum_s${scenario + 1}_desc'),
    );
  }

  /// Shows the new step's instruction as a toast (HTML
  /// `showToast(getText('step_2_n'))`).
  void _toastStep(int step) {
    final steps = _data.steps;
    _lab.showToast(steps[(step - 1).clamp(0, steps.length - 1)].action);
  }

  /// HTML `placeBarrier(matType)`: the barrier between magnet and compass.
  /// The deflection stays at 35°. Locked while the current barrier's row is
  /// still to be recorded.
  void _placeBarrier(_Mat m) {
    final s = _sim;
    if (s.scenario != 0 || !s.snapped || _recordPending) return;
    setState(() {
      s.barrier = m;
      if (!s.tested.contains(m)) s.tested.add(m);
    });
    _dirty = true;
    if (m == _Mat.air) {
      _lab.showToast(_t('toast_barrier_cleared'), sound: false);
    } else {
      _lab.showToast(_t('toast_barrier_${m.name}'));
    }
    _updateStepS1();
  }

  /// The barrier in place (air after the snap) has a row the learner has not
  /// recorded yet.
  bool get _recordPending {
    final s = _sim;
    return s.scenario == 0 &&
        s.snapped &&
        s.tested.contains(s.barrier) &&
        !s.recorded.contains(s.barrier);
  }

  /// The learner records the current barrier's row. Only "deflected" matches
  /// what the needle shows; the step's outcome text then confirms it.
  void _record(bool deflected) {
    final s = _sim;
    if (!_recordPending) return;
    if (!deflected) {
      _lab.showToast(_t('toast_record_wrong'), isError: true);
      return;
    }
    final m = s.barrier;
    setState(() => s.recorded.add(m));
    _lab.showToast(_t('out_1_${m.index + 1}'));
    _updateStepS1();
  }

  /// Step = the first material still to record (wood, glass, plastic); 5
  /// once all three are recorded, which opens the conclusion (the HTML
  /// `validateInvestigation()` condition).
  void _updateStepS1() {
    final s = _sim;
    if (!s.snapped) return;
    const order = [_Mat.wood, _Mat.glass, _Mat.plastic];
    final next = order.indexWhere((m) => !s.recorded.contains(m));
    final step = next < 0 ? 5 : 2 + next;
    if (step != s.step) setState(() => s.step = step);
    if (step == 5 && !s.concluded) {
      s.concluded = true;
      _showConclusion(0);
    }
  }

  /// The barrier button the current step asks for (pulses).
  _Mat? get _neededBarrier {
    final s = _sim;
    if (_recordPending) return null;
    final want = switch (s.step) {
      2 => _Mat.wood,
      3 => _Mat.glass,
      4 => _Mat.plastic,
      _ => null,
    };
    if (want == null || s.barrier == want) return null;
    return s.barrier == _Mat.air ? want : _Mat.air;
  }

  /// HTML `checkSimulationRules()` for Scenario 1: snap within 2 units.
  void _rulesS1() {
    final s = _sim;
    if (s.snapped || s.magnet1.distTo(_spot) >= _snapRadius) return;
    setState(() {
      s
        ..magnet1 = _spot
        ..snapped = true
        // Locked on the spot: the HTML let it be dragged off again while
        // the needle stayed at 35°.
        ..dragging = false
        ..step = 2;
      if (!s.tested.contains(_Mat.air)) s.tested.add(_Mat.air);
    });
    _Audio.play(_Sound.drop);
    _lab.showToast(_t('toast_snapped'));
  }

  /// HTML `checkSimulationRules()` for Scenario 2, run on every drag move.
  /// Unlike the HTML, the maze walls stop the ball (see [_mazeWalls]) and
  /// Finish needs the ball itself there (the HTML also finished once the
  /// magnet passed x = 0.2, even with the ball dropped behind).
  void _rulesS2() {
    final s = _sim;
    var changed = false;
    final dist = s.magnet2.distXZ(s.ball);

    // Step 1 -> 2: capture at the start.
    if (dist < _captureDist && !s.captured) {
      s.captured = true;
      if (s.step == 1) {
        s.step = 2;
        changed = true;
        _toastStep(2);
      } else {
        _lab.showToast(_t('toast_recaptured'));
      }
    }

    if (s.captured && !s.finished) {
      if (dist > _loseDist) {
        s.captured = false;
        _lab.showToast(_t('toast_fast'), isError: true);
      } else {
        s.ball = _moveBall(
          s.ball,
          _V.lerp(s.ball, _V(s.magnet2.x, _ballY, s.magnet2.z), _ballFollow),
        );
        if (s.step == 2 && s.ball.x > _stepThreeX) {
          s.step = 3;
          changed = true;
          _toastStep(3);
        }
        if (s.step == 3 && s.ball.x > _stepFourX) {
          s.step = 4;
          changed = true;
          _toastStep(4);
        }
      }
      // Finish (step 4 -> 5): the ball, still held, reaches the circle.
      if (s.captured &&
          s.ball.distTo(_finishBall) < _finishDist &&
          !s.finished) {
        s
          ..ball = _finishBall
          ..finished = true;
        if (s.step <= 4) s.step = 5;
        s.startConfetti(_rnd);
        changed = true;
        _lab.showToast(_t('toast_finish'));
      }
    }

    // Magnetic fishing (step 5 -> 6), conclusion 1.5 s later.
    if (s.finished && s.magnet2.x > _fishMagnetX && !s.fished) {
      s
        ..fished = true
        ..step = 6
        ..fishStart = s.time;
      changed = true;
      _lab.showToast(_t('toast_fishing'));
      _showConclusion(1);
    }
    if (changed) setState(() {});
  }

  // ---------------------------------------------------------------- drag

  /// Screen-space box around the magnet, at least [_minTouch] dp tall/wide.
  bool _hitMagnet(Offset at) {
    final s = _sim;
    final proj = s.proj;
    final m = s.magnet;
    var rect = Rect.zero;
    var first = true;
    for (final c in _wireCorners) {
      final o = proj.p(m + c);
      rect = first
          ? Rect.fromPoints(o, o)
          : rect.expandToInclude(Rect.fromPoints(o, o));
      first = false;
    }
    final zoom = _lab.transform.value.getMaxScaleOnAxis();
    final minSide = _minTouch / math.max(0.01, _fit * zoom);
    final growX = math.max(0.0, minSide - rect.width) / 2;
    final growY = math.max(0.0, minSide - rect.height) / 2;
    return Rect.fromLTRB(
      rect.left - growX,
      rect.top - growY,
      rect.right + growX,
      rect.bottom + growY,
    ).contains(at);
  }

  bool _canGrab(PointerDownEvent event) {
    final s = _sim;
    if (s.dragging) return false;
    if (s.scenario == 0 && s.snapped) return false;
    return _hitMagnet(event.localPosition);
  }

  /// HTML `onPointerDown`: keeps the offset between grab point and magnet.
  void _dragStart(DragStartDetails d) {
    final s = _sim;
    final hit = s.proj.onPlane(d.localPosition, s.planeY);
    if (hit == null) return;
    s
      ..grabOffset = (hit - s.magnet).withY(0)
      ..dragging = true;
    _dirty = true;
    _Audio.play(_Sound.pickup);
  }

  /// HTML `onPointerMove`: the magnet follows the finger on its plane.
  void _dragUpdate(DragUpdateDetails d) {
    final s = _sim;
    if (!s.dragging) return;
    final hit = s.proj.onPlane(d.localPosition, s.planeY);
    if (hit == null) return;
    final p = hit - s.grabOffset;
    // Kept on the table top (the HTML did not bound the drag).
    final halfW = (s.scenario == 0 ? _tableW1 : _tableW2) / 2 - 1;
    final halfD = (s.scenario == 0 ? _tableD1 : _tableD2) / 2 - 0.5;
    s.magnet = _V(
      p.x.clamp(-halfW, halfW).toDouble(),
      s.planeY,
      p.z.clamp(-halfD, halfD).toDouble(),
    );
    _dirty = true;
    if (s.scenario == 0) {
      _rulesS1();
    } else {
      _rulesS2();
    }
  }

  void _onDragEnd(DragEndDetails _) => _dragEnd();

  void _dragEnd() {
    final s = _sim;
    if (!s.dragging) return;
    s.dragging = false;
    _dirty = true;
    _Audio.play(_Sound.drop);
  }

  // ------------------------------------------------------------------- UI

  /// Scenario 1 steps 1–4: the sidebar shows a question, not the result.
  bool get _asking => _sim.scenario == 0 && _sim.step <= 4;

  /// HTML `#barrier-tray-panel` buttons, shown once the magnet has snapped.
  /// While a row waits to be recorded the tray holds the two record buttons
  /// instead (the barrier cannot be changed until then).
  List<LabAction> _actions() {
    final s = _sim;
    if (s.scenario != 0 || !s.snapped) return const [];
    final need = _neededBarrier;
    final pending = _recordPending;
    LabAction button(_Mat m, String key, IconData icon, Color fill) =>
        LabAction(
          label: _t(key),
          icon: icon,
          color: fill,
          foreground: _Colors.white,
          highlight: need == m,
          // Placing a barrier plays the toast's tone instead of a click.
          silent: m != _Mat.air,
          onTap: () => _placeBarrier(m),
        );
    LabAction record(bool deflected) => LabAction(
      label: _t(deflected ? 'btn_rec_yes' : 'btn_rec_no'),
      icon: deflected ? Icons.check : Icons.block,
      color: _Colors.indigo500,
      foreground: _Colors.white,
      silent: true,
      onTap: () => _record(deflected),
    );
    if (pending) return [record(true), record(false)];
    return [
      button(_Mat.wood, 'mat_wood', Icons.rectangle, _Colors.amber700),
      button(_Mat.glass, 'mat_glass', Icons.crop_square, _Colors.emerald600),
      button(_Mat.plastic, 'mat_plastic', Icons.filter_none, _Colors.cyan600),
      button(_Mat.air, 'btn_remove_barrier', Icons.close, _Colors.slate700),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final actions = _actions();
        return LabShell(
          controller: _lab,
          icon: Icons.waves,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _sim.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _sim.step,
          actions: actions,
          // Scenario 1 asks before the learner observes; the outcome of a
          // step is shown once its row has been recorded.
          sidebarExtraTitle: _t(_asking ? 'predict_title' : 'expected_outcome'),
          sidebarExtra: _OutcomeCard(
            palette: p,
            scale: s * _lab.fontScale,
            text: _asking
                ? _t('ask_1_${_sim.step}')
                : data
                      .steps[(_sim.step - 1).clamp(0, data.steps.length - 1)]
                      .observation,
          ),
          onReset: () => _loadScenario(0),
          overlays: [
            // HTML `#barrier-tray-panel`, docked on the canvas's left edge
            // (over the toolbox, empty once the magnet has snapped) while the
            // sidebar is open; the floating mission card carries the buttons
            // otherwise.
            if (actions.isNotEmpty && _lab.isSidebarOpen && _lab.popup == null)
              Positioned(
                left: inset.left,
                top: inset.top + _trayTop * s,
                bottom: inset.bottom + _hudClearance * s,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _BarrierTray(
                    palette: p,
                    scale: s,
                    title:
                        MediaQuery.sizeOf(context).height >= _trayTitleMinHeight
                        ? _t(_recordPending ? 'obs_table' : 'tray_title')
                        : null,
                    actions: actions,
                  ),
                ),
              ),
            // HTML `#results-table-container` (Scenario 1 only).
            if (_sim.scenario == 0)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _ObservationTable(
                  palette: p,
                  scale: s,
                  title: _t('obs_table'),
                  headers: [
                    _t('tbl_barrier'),
                    _t('tbl_deflected'),
                    _t('tbl_blocked'),
                  ],
                  rows: [
                    for (final m in _sim.tested)
                      _sim.recorded.contains(m)
                          ? [_t(m.key), _t('yes'), _t('no')]
                          : [_t(m.key), _t('not_recorded'), _t('not_recorded')],
                  ],
                ),
              ),
          ],
          stage: _buildStage(),
        );
      },
    );
  }

  Widget _buildStage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        _fit = fit.isFinite && fit > 0 ? fit : 1;
        // Labels keep a readable on-screen size on small phones.
        final labelScale =
            ((0.85 / _fit).clamp(1.0, 1.8) * 20).roundToDouble() / 20;
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      // Small slop: a short drag grabs the object before the zoom
                      // viewer claims it (RawGestureDetector ignores MediaQuery's).
                      ..gestureSettings = const DeviceGestureSettings(
                        touchSlop: _touchSlop,
                      )
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _dragStart
                      ..onUpdate = _dragUpdate
                      ..onEnd = _onDragEnd
                      ..onCancel = _dragEnd,
                  ),
            },
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  sim: _sim,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  labelScale: labelScale,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// HTML `#barrier-tray-panel`: the barrier buttons in a column on the
/// canvas, each at least [_minTouch] tall.
class _BarrierTray extends StatelessWidget {
  const _BarrierTray({
    required this.palette,
    required this.scale,
    required this.title,
    required this.actions,
  });

  final LabPalette palette;
  final double scale;
  final String? title;
  final List<LabAction> actions;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    // Scales down (never overflows) when the canvas is very short.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: _trayWidth * s,
        child: LabGlassCard(
          palette: p,
          padding: EdgeInsets.all(5 * s),
          radius: 14,
          borderColor: _Colors.indigo500.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Text(
                  title!.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: indigo,
                    fontSize: 8.5 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4 * s),
              ],
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) SizedBox(height: 4 * s),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _minTouch),
                  child: LabActionButton(
                    action: actions[i],
                    scale: s,
                    dense: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// HTML "Expected Outcome" box of the current step (sidebar).
class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({
    required this.palette,
    required this.scale,
    required this.text,
  });

  final LabPalette palette;
  final double scale;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: indigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: indigo.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bolt, size: 15 * scale, color: _Colors.amber500),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.textStrong,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// HTML `#results-table-container`: tested barriers, deflected? blocked?
class _ObservationTable extends StatelessWidget {
  const _ObservationTable({
    required this.palette,
    required this.scale,
    required this.title,
    required this.headers,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final indigo = p.isDark ? _Colors.indigo400 : _Colors.indigo600;
    final green = p.isDark ? _Colors.green400 : _Colors.green600;
    Widget cell(String text, Color color, {bool bold = true}) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 3 * s),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 9.5 * s,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
    return SizedBox(
      width: 200 * s,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(8 * s),
        radius: 12,
        borderColor: indigo.withValues(alpha: 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: indigo,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Icon(Icons.table_chart, size: 14 * s, color: indigo),
              ],
            ),
            SizedBox(height: 6 * s),
            DecoratedBox(
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.cardBorder),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.4),
                  1: FlexColumnWidth(1.1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    children: [for (final h in headers) cell(h, p.textMuted)],
                  ),
                  for (final r in rows)
                    TableRow(
                      children: [
                        cell(r[0], p.textStrong),
                        cell(r[1], green),
                        cell(r[2], indigo),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================== PAINTING

// Lighting (HTML: AmbientLight 0.65, DirectionalLight 0.85 at (15,25,15),
// PointLight 0x6366f1 0.5 range 30 at (-10,10,-5)), toned down so lit
// colours stay recognisable without tone mapping.
const _V _keyDir = _V(0.4575, 0.7625, 0.4575); // (15, 25, 15) normalised
const _V _fillPos = _V(-10, 10, -5);
const double _ambient = 0.55;
const double _keyGain = 0.6;
const double _fillGain = 0.5;
const double _fillRange = 30;

/// Metals look darker without an environment map (MeshStandardMaterial).
const double _metalDim = 0.5;

/// Shadows fall away from the key light: 0.6 units per unit of height
/// towards -x and -z.
const double _shadowSlope = 0.6;

const int _ringSegments = 28;

/// Flat-shaded colour of a face with normal [n] at [at].
Color _lit(Color c, _V n, _V at, {double metal = 0}) {
  final key = math.max(0.0, n.dot(_keyDir));
  final toFill = _fillPos - at;
  final dist = toFill.length;
  final fall = math.max(0.0, 1 - dist / _fillRange);
  final fill = dist == 0
      ? 0.0
      : math.max(0.0, n.dot(toFill) / dist) * _fillGain * fall;
  final i = (_ambient + _keyGain * key) * (1 - metal * _metalDim);
  return Color.from(
    alpha: c.a,
    red: (c.r * (i + fill * _Colors.fillLight.r)).clamp(0.0, 1.0),
    green: (c.g * (i + fill * _Colors.fillLight.g)).clamp(0.0, 1.0),
    blue: (c.b * (i + fill * _Colors.fillLight.b)).clamp(0.0, 1.0),
  );
}

/// A box face: outward normal and its corners as signs of the half size.
@immutable
class _Face {
  const _Face(this.n, this.corners);
  final _V n;
  final List<_V> corners;
}

const List<_Face> _boxFaces = [
  _Face(_V(1, 0, 0), [_V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1), _V(1, -1, 1)]),
  _Face(_V(-1, 0, 0), [
    _V(-1, -1, -1),
    _V(-1, -1, 1),
    _V(-1, 1, 1),
    _V(-1, 1, -1),
  ]),
  _Face(_V(0, 1, 0), [_V(-1, 1, -1), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1)]),
  _Face(_V(0, -1, 0), [
    _V(-1, -1, -1),
    _V(1, -1, -1),
    _V(1, -1, 1),
    _V(-1, -1, 1),
  ]),
  _Face(_V(0, 0, 1), [_V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)]),
  _Face(_V(0, 0, -1), [
    _V(-1, -1, -1),
    _V(-1, 1, -1),
    _V(1, 1, -1),
    _V(1, -1, -1),
  ]),
];

/// Corners of the magnet's selection glow box (4.2 x 1.0 x 1.2), also its
/// touch box.
const List<_V> _wireCorners = [
  _V(-2.1, -0.5, -0.6),
  _V(2.1, -0.5, -0.6),
  _V(2.1, -0.5, 0.6),
  _V(-2.1, -0.5, 0.6),
  _V(-2.1, 0.5, -0.6),
  _V(2.1, 0.5, -0.6),
  _V(2.1, 0.5, 0.6),
  _V(-2.1, 0.5, 0.6),
];

const List<(int, int)> _wireEdges = [
  (0, 1), (1, 2), (2, 3), (3, 0), //
  (4, 5), (5, 6), (6, 7), (7, 4), //
  (0, 4), (1, 5), (2, 6), (3, 7),
];

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  final upper = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [
    ...lower.sublist(0, lower.length - 1),
    ...upper.sublist(0, upper.length - 1),
  ];
}

/// Static layers recorded once (the camera never moves; zoom and pan are
/// the shell's 2D viewer) and replayed every frame.
class _Pictures {
  final Map<String, ui.Picture> _map = {};

  ui.Picture get(String key, _Proj proj, void Function(_Draw d) paint) {
    final cached = _map[key];
    if (cached != null) return cached;
    final recorder = ui.PictureRecorder();
    final d = _Draw()
      ..canvas = Canvas(recorder)
      ..proj = proj;
    paint(d);
    return _map[key] = recorder.endRecording();
  }

  void dispose() {
    for (final p in _map.values) {
      p.dispose();
    }
    _map.clear();
  }
}

/// Laid-out text reused across frames (labels, pole letters).
class _TextCache {
  final Map<String, TextPainter> _map = {};
  static const int _maxEntries = 48;

  TextPainter get(String text, double size, {bool heavy = false}) {
    final key = '$text|${size.toStringAsFixed(1)}|$heavy';
    final cached = _map[key];
    if (cached != null) return cached;
    if (_map.length >= _maxEntries) dispose();
    return _map[key] = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _Colors.white,
          fontSize: size,
          fontWeight: heavy ? FontWeight.w800 : FontWeight.w700,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void dispose() {
    for (final tp in _map.values) {
      tp.dispose();
    }
    _map.clear();
  }
}

/// Mesh drawing in the current projection with reused Paints and Path.
class _Draw {
  late Canvas canvas;
  late _Proj proj;

  final Paint fill = Paint();
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  Offset p(_V w) => proj.p(w);

  /// Fills with [shader]; the paint colour stays opaque so its alpha does
  /// not dim the shader.
  void shade(Shader shader) {
    fill
      ..color = _Colors.black
      ..shader = shader;
  }

  /// Sets [path] to the projected polygon [pts].
  void poly(List<_V> pts) {
    path.reset();
    for (var i = 0; i < pts.length; i++) {
      final o = proj.p(pts[i]);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    path.close();
  }

  void fillPath(Color c, {double opacity = 1}) {
    fill
      ..shader = null
      ..color = c.withValues(alpha: c.a * opacity);
    canvas.drawPath(path, fill);
  }

  void strokePath(Color c, double width, {double opacity = 1}) {
    line
      ..color = c.withValues(alpha: c.a * opacity)
      ..strokeWidth = width;
    canvas.drawPath(path, line);
  }

  /// Soft shadow of the polygon [pts] (on a table or the maze board).
  void shadow(List<_V> pts, {double opacity = 0.3}) {
    poly(pts);
    soft.color = _Colors.black.withValues(alpha: opacity);
    canvas.drawPath(path, soft);
  }

  /// Footprint shadow of a [w] x [d] block whose centre is [h] above the
  /// surface at height [y].
  void blockShadow(
    _V c,
    double w,
    double d,
    double h,
    double y, {
    double opacity = 0.3,
  }) {
    final dx = -h * _shadowSlope, dz = -h * _shadowSlope;
    shadow([
      _V(c.x - w / 2 + dx, y, c.z - d / 2 + dz),
      _V(c.x + w / 2 + dx, y, c.z - d / 2 + dz),
      _V(c.x + w / 2 + dx, y, c.z + d / 2 + dz),
      _V(c.x - w / 2 + dx, y, c.z + d / 2 + dz),
    ], opacity: opacity);
  }

  /// Three.js BoxGeometry centred at [c]: visible faces, flat shaded.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double metal = 0,
    double edge = 0.35,
    bool top = true,
    bool unlit = false,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.n;
      if (!top && n.y > 0) continue;
      final fc = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(proj.eye - fc) <= 0) continue;
      path.reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        final o = proj.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz));
        i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      path.close();
      fillPath(
        unlit ? color : _lit(color, n, fc, metal: metal),
        opacity: opacity,
      );
      if (edge > 0) {
        strokePath(labShade(color, -0.5), 1, opacity: edge * opacity);
      }
    }
  }

  /// Upright Three.js CylinderGeometry (or frustum) centred at [c].
  void cylinder(
    _V c,
    double rTop,
    double rBottom,
    double height,
    Color color, {
    Color? cap,
    double opacity = 1,
    double metal = 0,
    bool unlit = false,
  }) {
    final yTop = c.y + height / 2, yBottom = c.y - height / 2;
    final ring = <Offset>[];
    final all = <Offset>[];
    for (var i = 0; i < _ringSegments; i++) {
      final a = i * 2 * math.pi / _ringSegments;
      final ca = math.cos(a), sa = math.sin(a);
      final t = proj.p(_V(c.x + rTop * ca, yTop, c.z + rTop * sa));
      ring.add(t);
      all
        ..add(t)
        ..add(proj.p(_V(c.x + rBottom * ca, yBottom, c.z + rBottom * sa)));
    }
    Color side(_V n) => (unlit ? color : _lit(color, n, c, metal: metal))
        .withValues(alpha: color.a * opacity);
    final r = math.max(rTop, rBottom);
    shade(
      ui.Gradient.linear(
        proj.p(_V(c.x - r, c.y, c.z)),
        proj.p(_V(c.x + r, c.y, c.z)),
        [
          side(const _V(-1, 0, 0)),
          side(const _V(-0.7, 0, 0.7)),
          side(const _V(0, 0, 1)),
          side(const _V(0.7, 0, 0.7)),
          side(const _V(1, 0, 0)),
        ],
        const [0, 0.25, 0.5, 0.75, 1],
      ),
    );
    path
      ..reset()
      ..addPolygon(_hull(all), true);
    canvas.drawPath(path, fill);
    fill.shader = null;
    if (proj.eye.y > yTop) {
      path
        ..reset()
        ..addPolygon(ring, true);
      final top =
          cap ??
          (unlit ? color : _lit(color, const _V(0, 1, 0), c, metal: metal));
      fillPath(top, opacity: opacity);
    }
  }

  /// Upper hemisphere of radius [r] on [base], squashed by [yScale]
  /// (glass domes), with a highlight.
  void dome(_V base, double r, double yScale, Color color, double opacity) {
    final pts = <Offset>[];
    const lats = 6, longs = 24;
    for (var la = 0; la <= lats; la++) {
      final th = la * math.pi / 2 / lats;
      final rr = r * math.cos(th);
      final y = base.y + r * math.sin(th) * yScale;
      for (var i = 0; i < longs; i++) {
        final a = i * 2 * math.pi / longs;
        pts.add(
          proj.p(_V(base.x + rr * math.cos(a), y, base.z + rr * math.sin(a))),
        );
      }
    }
    final hull = _hull(pts);
    final top = proj.p(base.withY(base.y + r * yScale));
    final rim = proj.p(base + _V(0, 0, r));
    final shape = Rect.fromPoints(
      proj.p(base - _V(r, 0, 0)),
      proj.p(base + _V(r, 0, 0)),
    );
    path
      ..reset()
      ..addPolygon(hull, true);
    shade(
      ui.Gradient.linear(
        top,
        rim,
        [
          labShade(color, 0.6).withValues(alpha: opacity * 1.2),
          color.withValues(alpha: opacity),
          labShade(color, -0.2).withValues(alpha: opacity * 0.8),
        ],
        const [0, 0.55, 1],
      ),
    );
    canvas.drawPath(path, fill);
    fill.shader = null;
    strokePath(_Colors.white, 1.2, opacity: 0.35);
    // Specular glint on the upper left.
    final glint = Rect.fromCenter(
      center: Offset.lerp(top, shape.centerLeft, 0.45)!,
      width: shape.width * 0.22,
      height: math.max(3, (rim.dy - top.dy) * 0.18),
    );
    fill.color = _Colors.white.withValues(alpha: 0.35);
    canvas.drawOval(glint, fill);
  }

  /// Lines of the projected box [corners] (selection wireframe).
  void wire(_V c, Color color, double width) {
    line
      ..color = color
      ..strokeWidth = width;
    for (final (a, b) in _wireEdges) {
      canvas.drawLine(p(c + _wireCorners[a]), p(c + _wireCorners[b]), line);
    }
  }
}

/// Paints the HTML Three.js lab table scenes.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.sim,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Sim sim;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  /// Reused paints for the live layers.
  static final Paint _fieldPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round
    ..color = _Colors.field.withValues(alpha: 0.35); // opacity 0.35
  static final Paint _ballPaint = Paint()
    ..shader = ui.Gradient.radial(
      const Offset(-0.35, -0.45),
      1.5,
      const [
        _Colors.white,
        _Colors.slate200,
        _Colors.slate400,
        _Colors.slate700,
      ],
      const [0, 0.18, 0.62, 1],
    );
  static final Paint _vertexPaint = Paint();
  static final Paint _chipFill = Paint()..color = _Colors.labelBg;
  static final Paint _chipBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = _Colors.labelBorder;

  /// Local (x, z) points of the 8 field-line ellipses (HTML EllipseCurve(-3,
  /// 0, 3.8 + i * 0.4, 2 + i * 0.3).getPoints(60), rotated flat).
  static final List<Float64List> _ellipses = [
    for (var i = 0; i < 8; i++)
      Float64List.fromList([
        for (var j = 0; j <= 60; j++) ...[
          -3 + (3.8 + i * 0.4) * math.cos(j * 2 * math.pi / 60),
          (2 + i * 0.3) * math.sin(j * 2 * math.pi / 60),
        ],
      ]),
  ];

  String _t(String key) => labTr(_i18n, lang, key);

  ui.Picture _pic(String key, void Function(_Draw d) paint) =>
      sim.pictures.get(key, sim.proj, paint);

  @override
  void paint(Canvas canvas, Size size) {
    final d = sim.draw
      ..canvas = canvas
      ..proj = sim.proj;
    canvas.drawPicture(
      _pic(isDark ? 'bg-dark' : 'bg-light', (b) => _background(b, size)),
    );
    if (sim.scenario == 0) {
      _paintS1(d);
    } else {
      _paintS2(d);
    }
    if (showLabels) _paintLabels(d);
  }

  // ------------------------------------------------------------ backdrop

  /// `#canvas-wrapper` navy with the 50 px `.canvas-grid`.
  void _background(_Draw b, Size size) {
    final bleed = labBleed(size);
    b.canvas.drawRect(bleed, Paint()..color = _Colors.canvas);
    final grid = Paint()
      ..strokeWidth = 1
      ..color = (isDark ? _Colors.white : _Colors.black).withValues(
        alpha: 0.03,
      );
    const step = 50.0;
    for (
      var x = (bleed.left / step).floor() * step;
      x <= bleed.right;
      x += step
    ) {
      b.canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    for (
      var y = (bleed.top / step).floor() * step;
      y <= bleed.bottom;
      y += step
    ) {
      b.canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
  }

  /// HTML `createLabTable(w, d)`: top, metallic rim and legs.
  static void _table(_Draw d, double w, double depth) {
    for (final sz in const [-1.0, 1.0]) {
      for (final sx in const [-1.0, 1.0]) {
        d.cylinder(
          _V(sx * (w / 2 - 1), -4.3, sz * (depth / 2 - 1)),
          0.3,
          0.3,
          8,
          _Colors.tableLeg,
          metal: 0.5,
        );
      }
    }
    d.box(
      const _V(0, -0.3, 0),
      _V(w, 0.6, depth),
      _Colors.tableTop,
      metal: 0.1,
      edge: 0.5,
    );
    // Rim (w + 0.1) x 0.1 x (d + 0.1) at y -0.05; its top is flush with
    // the table top, so only its sides and a thin band show.
    d.box(
      const _V(0, -0.05, 0),
      _V(w + 0.1, 0.1, depth + 0.1),
      _Colors.tableRim,
      metal: 0.8,
      edge: 0.2,
      top: false,
    );
    d.poly([
      _V(-w / 2, 0, -depth / 2),
      _V(w / 2, 0, -depth / 2),
      _V(w / 2, 0, depth / 2),
      _V(-w / 2, 0, depth / 2),
    ]);
    d.strokePath(_Colors.tableRim, 1.6, opacity: 0.8);
  }

  // ---------------------------------------------------------- scenario 1

  /// Table, glowing spot, toolbox and the compass's contact shadow.
  static void _s1Base(_Draw d) {
    _table(d, _tableW1, _tableD1);
    // Glowing testing spot: 5 x 3 plane at (-3, 0.02, 0) with a radial
    // gradient rgba(99,102,241,.8) at r 10/64 -> 0 at r 60/64.
    const c = _V(-3, 0.02, 0);
    final o = d.p(c);
    final ax =
        (d.p(c + const _V(2.5, 0, 0)) - d.p(c - const _V(2.5, 0, 0))) / 2;
    final az =
        (d.p(c + const _V(0, 0, 1.5)) - d.p(c - const _V(0, 0, 1.5))) / 2;
    d.canvas
      ..save()
      ..transform(
        Float64List.fromList([
          ax.dx, ax.dy, 0, 0, //
          az.dx, az.dy, 0, 0, //
          0, 0, 1, 0, //
          o.dx, o.dy, 0, 1,
        ]),
      );
    d.shade(
      ui.Gradient.radial(
        Offset.zero,
        1,
        [
          _Colors.spot.withValues(alpha: 0.8),
          _Colors.spot.withValues(alpha: 0.8),
          _Colors.spot.withValues(alpha: 0),
        ],
        const [0, 10 / 64, 60 / 64],
      ),
    );
    d.canvas
      ..drawRect(const Rect.fromLTRB(-1, -1, 1, 1), d.fill)
      ..restore();
    d.fill.shader = null;
    // Compass base shadow (castShadow), toolbox (receiveShadow).
    final cs = _compassPos;
    d.shadow([
      for (var i = 0; i < 16; i++)
        _V(
          cs.x - 0.12 + 2.1 * math.cos(i * math.pi / 8),
          0.002,
          cs.z - 0.12 + 2.1 * math.sin(i * math.pi / 8),
        ),
    ], opacity: 0.35);
    d.box(_toolboxPos, _toolboxSize, _Colors.toolbox, edge: 0.5);
  }

  /// Brass base and white dial (drawn below the needle).
  static void _s1CompassBase(_Draw d) {
    d.cylinder(_compassPos, 2, 2.1, 0.4, _Colors.brass, metal: 0.8);
    d.cylinder(
      _compassPos.withY(0.2),
      1.8,
      1.8,
      0.42,
      _Colors.dial,
      unlit: true,
    );
    // Dial edge.
    d.path.reset();
    final ring = <Offset>[
      for (var i = 0; i < _ringSegments; i++)
        d.p(
          _V(
            _compassPos.x + 1.8 * math.cos(i * 2 * math.pi / _ringSegments),
            0.41,
            _compassPos.z + 1.8 * math.sin(i * 2 * math.pi / _ringSegments),
          ),
        ),
    ];
    d.path.addPolygon(ring, true);
    d.strokePath(_Colors.slate400, 1.2, opacity: 0.8);
  }

  /// Pivot and the flattened glass dome (drawn above the needle).
  static void _s1CompassTop(_Draw d) {
    d.cylinder(_needleCenter, 0.15, 0.15, 0.2, _Colors.pivot);
    d.dome(_compassPos.withY(0.4), 1.9, 0.25, _Colors.white, 0.3);
  }

  void _paintS1(_Draw d) {
    final s = sim;
    final canvas = d.canvas;
    canvas.drawPicture(_pic('s1-base', _s1Base));
    if (s.barrier == _Mat.wood) _barrierShadow(d);
    d.blockShadow(s.magnet1, 4, 1, s.magnet1.y, 0.002, opacity: 0.32);

    final magnetBehind = d.proj.depth(s.magnet1) > d.proj.depth(_compassPos);
    if (magnetBehind) _magnet(d, s.magnet1);
    canvas.drawPicture(_pic('s1-compass-base', _s1CompassBase));
    _needle(d);
    canvas.drawPicture(_pic('s1-compass-top', _s1CompassTop));
    if (!magnetBehind) _magnet(d, s.magnet1);

    if (s.snapped) {
      _buildFieldLines(d);
      canvas.drawPath(s.linesHidden, _fieldPaint);
    }
    _barrier(d);
    if (s.snapped) canvas.drawPath(s.linesShown, _fieldPaint);
  }

  /// Wooden block shadow (castShadow): footprint plus its top edge cast by
  /// the key light.
  void _barrierShadow(_Draw d) {
    const c = _barrierPos;
    const w = 0.8, hd = _barrierD / 2; // the wooden block
    final top = c.y + _barrierH / 2;
    final dx = -top * _shadowSlope;
    final pts = [
      for (final (x, z) in const [
        (-1.0, -1.0),
        (1.0, -1.0),
        (1.0, 1.0),
        (-1.0, 1.0),
      ])
        d.p(_V(c.x + x * w / 2, 0.002, c.z + z * hd)),
      for (final (x, z) in const [
        (-1.0, -1.0),
        (1.0, -1.0),
        (1.0, 1.0),
        (-1.0, 1.0),
      ])
        d.p(_V(c.x + x * w / 2 + dx, 0.002, c.z + z * hd + dx)),
    ];
    d.path
      ..reset()
      ..addPolygon(_hull(pts), true);
    d.soft.color = _Colors.black.withValues(alpha: 0.3);
    d.canvas.drawPath(d.path, d.soft);
  }

  /// HTML `createBarMagnetMesh()`: red N half, blue S half, pole marks and
  /// the indigo selection wireframe while dragging.
  void _magnet(_Draw d, _V m) {
    d.box(
      m + const _V(-1, 0, 0),
      const _V(2, 0.8, 1),
      _Colors.magnetN,
      metal: 0.4,
      edge: 0.45,
    );
    d.box(
      m + const _V(1, 0, 0),
      const _V(2, 0.8, 1),
      _Colors.magnetS,
      metal: 0.4,
      edge: 0.45,
    );
    _poleMark(d, m + const _V(-1.3, 0.41, 0), _Colors.magnetN, _t('pole_n'));
    _poleMark(d, m + const _V(1.3, 0.41, 0), _Colors.magnetS, _t('pole_s'));
    if (sim.dragging) {
      d.wire(m, _Colors.indigo500.withValues(alpha: 0.8), 1.6);
    }
  }

  /// 0.6 x 0.6 pole plate with a white letter (canvas texture in the HTML).
  void _poleMark(_Draw d, _V c, Color color, String letter) {
    d.poly([
      c + const _V(-0.3, 0, -0.3),
      c + const _V(0.3, 0, -0.3),
      c + const _V(0.3, 0, 0.3),
      c + const _V(-0.3, 0, 0.3),
    ]);
    d.fillPath(color);
    final o = d.p(c);
    final k = d.proj.scaleAt(c);
    final squash =
        ((d.p(c + const _V(0, 0, 0.3)) - d.p(c - const _V(0, 0, 0.3))).dy /
                (0.6 * k))
            .clamp(0.2, 1.0);
    final tp = sim.text.get(letter, (0.42 * k).roundToDouble(), heavy: true);
    d.canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(1, squash);
    tp.paint(d.canvas, Offset(-tp.width / 2, -tp.height / 2));
    d.canvas.restore();
  }

  /// Two 4-sided cones (red N tip towards -z, blue S tip towards +z),
  /// turned by the needle angle (rotation.y).
  void _needle(_Draw d) {
    final a = sim.needle;
    const base = [
      _V(0, 0.25, 0),
      _V(0.25, 0, 0),
      _V(0, -0.25, 0),
      _V(-0.25, 0, 0),
    ];
    for (final (tipZ, color) in const [
      (-1.4, _Colors.magnetN),
      (1.4, _Colors.magnetS),
    ]) {
      final tip = _needleCenter + _V(0, 0, tipZ).rotY(a);
      final mid = _needleCenter + _V(0, 0, tipZ / 2).rotY(a);
      for (var i = 0; i < 4; i++) {
        final b0 = _needleCenter + base[i].rotY(a);
        final b1 = _needleCenter + base[(i + 1) % 4].rotY(a);
        var n = (b0 - tip).cross(b1 - tip).unit;
        final fc = (tip + b0 + b1) * (1 / 3);
        if (n.dot(fc - mid) < 0) n = n * -1;
        if (n.dot(d.proj.eye - fc) <= 0) continue;
        d.poly([tip, b0, b1]);
        d.fillPath(_lit(color, n, fc));
      }
    }
  }

  /// HTML `placeBarrier()` meshes: wood, glass (opacity 0.6) and plastic
  /// (opacity 0.85) slabs, 2.6 tall and 4.5 deep.
  void _barrier(_Draw d) {
    const c = _barrierPos;
    final size = _V(sim.barrier.thickness, _barrierH, _barrierD);
    switch (sim.barrier) {
      case _Mat.air:
        return;
      case _Mat.wood:
        d.box(c, size, _Colors.wood, edge: 0.6);
        // Grain on the face towards the camera (-x).
        d.line
          ..strokeWidth = 1
          ..color = _Colors.woodGrain.withValues(alpha: 0.45);
        for (final f in const [-0.3, -0.05, 0.2, 0.38]) {
          final y = c.y + f * _barrierH;
          d.path.reset();
          for (var i = 0; i <= 12; i++) {
            final z = -_barrierD / 2 + _barrierD * i / 12;
            final o = d.p(
              _V(c.x - size.x / 2, y + 0.05 * math.sin(i * 1.7 + f * 9), z),
            );
            i == 0 ? d.path.moveTo(o.dx, o.dy) : d.path.lineTo(o.dx, o.dy);
          }
          d.canvas.drawPath(d.path, d.line);
        }
      case _Mat.glass:
        d.box(c, size, _Colors.glass, opacity: 0.6, edge: 0.7);
        _glint(d, c.x - size.x / 2);
      case _Mat.plastic:
        d.box(c, size, _Colors.plastic, opacity: 0.85, edge: 0.6);
        _glint(d, c.x - size.x / 2);
    }
  }

  /// Diagonal highlight on a transparent sheet's camera-facing face.
  void _glint(_Draw d, double x) {
    const c = _barrierPos;
    d.line
      ..strokeWidth = 2
      ..color = _Colors.white.withValues(alpha: 0.4);
    d.canvas.drawLine(
      d.p(_V(x, c.y + 0.9, -1.6)),
      d.p(_V(x, c.y - 0.5, 0.4)),
      d.line,
    );
  }

  /// HTML `fieldLinesS1`: 8 flat ellipses at y 0.6 rocking about z
  /// (rotation.z = sin(t_ms * 0.002) * 0.05). Segments inside or right
  /// behind the barrier go into [_Sim.linesHidden] (drawn before it), the
  /// rest into [_Sim.linesShown].
  void _buildFieldLines(_Draw d) {
    final s = sim;
    final a = math.sin(s.time * 2) * 0.05;
    final ca = math.cos(a), sa = math.sin(a);
    final hidden = s.linesHidden..reset();
    final shown = s.linesShown..reset();
    final half = s.barrier.thickness / 2;
    final x0 = _barrierPos.x - half - 0.05;
    // Seen from the camera, the slab also hides a strip behind it.
    final x1 = (_barrierPos.x + half) * 1.3 + 0.1;
    const front = _barrierD / 2;
    for (final e in _ellipses) {
      var prev = Offset.zero;
      double prevX = 0, prevZ = 0;
      var hiddenAt = -2, shownAt = -2;
      for (var j = 0; j <= 60; j++) {
        final lx = e[j * 2], lz = e[j * 2 + 1];
        final x = lx * ca;
        final o = d.p(_V(x, _plane1 + lx * sa, lz));
        if (j > 0) {
          final mx = (x + prevX) / 2, mz = (lz + prevZ) / 2;
          final isHidden = half > 0 && mx > x0 && mx < x1 && mz < front;
          if (isHidden) {
            if (hiddenAt != j - 1) hidden.moveTo(prev.dx, prev.dy);
            hidden.lineTo(o.dx, o.dy);
            hiddenAt = j;
          } else {
            if (shownAt != j - 1) shown.moveTo(prev.dx, prev.dy);
            shown.lineTo(o.dx, o.dy);
            shownAt = j;
          }
        }
        prev = o;
        prevX = x;
        prevZ = lz;
      }
    }
  }

  // ---------------------------------------------------------- scenario 2

  static void _s2Base(_Draw d) => _table(d, _tableW2, _tableD2);

  /// Maze pillars (local (±5.5, -1.5, ±3.5)).
  static const List<_V> _pillars = [
    _V(-9, 1.5, -3.5),
    _V(2, 1.5, -3.5),
    _V(-9, 1.5, 3.5),
    _V(2, 1.5, 3.5),
  ];

  static const List<(_V, _V)> _walls = _mazeWalls;

  /// Semi-transparent cardboard board, wall shadows, Start and Finish.
  static void _s2Board(_Draw d) {
    d.box(
      _mazePos,
      const _V(12, 0.2, 8),
      _Colors.board,
      opacity: 0.65,
      edge: 0.5,
    );
    for (final (c, size) in _walls) {
      d.blockShadow(
        c.withY(_boardTop),
        size.x,
        size.z,
        size.y / 2,
        _boardTop + 0.002,
        opacity: 0.25,
      );
    }
    d.cylinder(
      const _V(-8, 3.1, 2.5),
      0.8,
      0.8,
      0.22,
      _Colors.start,
      unlit: true,
    );
    d.cylinder(
      const _V(1.0, 3.1, -2.5),
      0.9,
      0.9,
      0.22,
      _Colors.finish,
      unlit: true,
    );
  }

  /// Water body above the table top (CylinderGeometry(2.3, 1.5, 1.2) at
  /// y 0.1; the part below the table top is hidden).
  static void _s2Water(_Draw d) {
    d.cylinder(
      _bowlPos.withY(0.35),
      2.3,
      1.833,
      0.7,
      _Colors.water.withValues(alpha: 0.75),
      cap: _Colors.water.withValues(alpha: 0.6),
    );
  }

  /// Glass hemisphere r 2.5 (opacity 0.4) on the bowl group.
  static void _s2Dome(_Draw d) => d.dome(_bowlPos, 2.5, 1, _Colors.bowl, 0.4);

  void _paintS2(_Draw d) {
    final s = sim;
    final canvas = d.canvas;
    final proj = d.proj;
    canvas.drawPicture(_pic('s2-base', _s2Base));
    d.blockShadow(s.magnet2, 4, 1, s.magnet2.y, 0.002, opacity: 0.28);

    // Below the board: magnet, pillars and the bowl, far to near.
    final under = <(double, int)>[
      (proj.depth(s.magnet2), -1),
      for (var i = 0; i < _pillars.length; i++) (proj.depth(_pillars[i]), i),
      (proj.depth(_bowlPos.withY(1.2)), _pillars.length),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, id) in under) {
      if (id < 0) {
        _magnet(d, s.magnet2);
      } else if (id < _pillars.length) {
        canvas.drawPicture(
          _pic('s2-pillar-$id', (b) {
            b.cylinder(_pillars[id], 0.3, 0.3, 3, _Colors.pillar);
          }),
        );
      } else {
        canvas.drawPicture(_pic('s2-water', _s2Water));
        _pins(d);
        canvas.drawPicture(_pic('s2-dome', _s2Dome));
      }
    }

    canvas.drawPicture(_pic('s2-board', _s2Board));
    // Ball shadow on the board (receiveShadow).
    d.shadow([
      for (var i = 0; i < 12; i++)
        _V(
          s.ball.x - _ballR * _shadowSlope + _ballR * math.cos(i * math.pi / 6),
          _boardTop + 0.005,
          s.ball.z - _ballR * _shadowSlope + _ballR * math.sin(i * math.pi / 6),
        ),
    ], opacity: 0.35);

    // Walls the ball is behind are drawn after it.
    final front = <int>[];
    for (var i = 0; i < _walls.length; i++) {
      if (_wallInFront(i, s.ball)) {
        front.add(i);
      } else {
        canvas.drawPicture(_wallPicture(i));
      }
    }
    _ball(d);
    for (final i in front) {
      canvas.drawPicture(_wallPicture(i));
    }
    _confetti(d);
  }

  ui.Picture _wallPicture(int i) => _pic('s2-wall-$i', (b) {
    final (c, size) = _walls[i];
    b.box(c, size, _Colors.wall, edge: 0.5);
  });

  /// Is wall [i] between the camera and the ball?
  static bool _wallInFront(int i, _V ball) {
    final (c, size) = _walls[i];
    final alongX = size.x > size.z;
    if (alongX) {
      final overlaps = (ball.x - c.x).abs() < size.x / 2 + _ballR;
      return overlaps && ball.z < c.z - size.z / 2;
    }
    final overlaps = (ball.z - c.z).abs() < size.z / 2 + _ballR;
    final camX = _eye2.x;
    return overlaps &&
        (c.x < camX ? ball.x < c.x - size.x / 2 : ball.x > c.x + size.x / 2);
  }

  /// Metallic steel ball (SphereGeometry(0.4), metalness 0.9).
  void _ball(_Draw d) {
    final o = d.p(sim.ball);
    final r = _ballR * d.proj.scaleAt(sim.ball);
    d.canvas
      ..save()
      ..translate(o.dx, o.dy)
      ..scale(r)
      ..drawCircle(Offset.zero, 1, _ballPaint)
      ..restore();
  }

  /// Steel pins in the bowl; fishing tweens them up towards the magnet
  /// (position Back.Out, rotation.z linear, 600 ms).
  void _pins(_Draw d) {
    final t = sim.fishProgress;
    final gp = _V.lerp(_pinsStart, _pinsEnd, Curves.easeOutBack.transform(t));
    final gr = -math.pi / 4 * t;
    final axis = const _V(0, 1, 0).rotZ(_pinTilt) * _pinHalf;
    final k = d.proj.scaleAt(_bowlPos);
    final w = math.max(1.6, 0.08 * k);
    // Resting pins are seen through the water.
    final color = t == 0
        ? Color.lerp(_Colors.pin, _Colors.water, 0.3)!
        : _Colors.pin;
    for (var p = 0; p < 4; p++) {
      final c = _V(-0.5 + p * 0.4, 0, -0.3 + p * 0.2);
      final a = d.p(_bowlPos + gp + (c + axis).rotZ(gr));
      final b = d.p(_bowlPos + gp + (c - axis).rotZ(gr));
      d.line
        ..strokeWidth = w + 1.4
        ..color = _Colors.pinEdge;
      d.canvas.drawLine(a, b, d.line);
      d.line
        ..strokeWidth = w
        ..color = color;
      d.canvas.drawLine(a, b, d.line);
    }
  }

  /// HTML confetti Points: one quad per particle (size 0.3, attenuated).
  void _confetti(_Draw d) {
    final s = sim;
    if (!s.confettiOn) return;
    final pos = s.confettiPos;
    final col = s.confettiColors;
    var n = 0;
    for (var i = 0; i < _confettiCount; i++) {
      final w = _V(s.cx[i], s.cy[i], s.cz[i]);
      final depth = d.proj.depth(w);
      if (depth < 0.5) continue;
      final o = d.p(w);
      final h = _confettiSize * _Proj.pointScale / depth / 2;
      final l = o.dx - h, r = o.dx + h, t = o.dy - h, b = o.dy + h;
      final j = n * 12;
      pos
        ..[j] = l
        ..[j + 1] = t
        ..[j + 2] = r
        ..[j + 3] = t
        ..[j + 4] = r
        ..[j + 5] = b
        ..[j + 6] = l
        ..[j + 7] = t
        ..[j + 8] = r
        ..[j + 9] = b
        ..[j + 10] = l
        ..[j + 11] = b;
      for (var v = 0; v < 6; v++) {
        col[n * 6 + v] = s.cColor[i];
      }
      n++;
    }
    if (n == 0) return;
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      Float32List.sublistView(pos, 0, n * 12),
      colors: Int32List.sublistView(col, 0, n * 6),
    );
    d.canvas.drawVertices(vertices, BlendMode.dst, _vertexPaint);
    vertices.dispose();
  }

  // -------------------------------------------------------------- labels

  /// HTML `.html-label` chips at the object + labelOffsetY.
  void _paintLabels(_Draw d) {
    final s = sim;
    if (s.scenario == 0) {
      _label(d, _t('lbl_magnet'), s.magnet1 + const _V(0, 1.0, 0));
      _label(d, _t('lbl_compass'), _compassPos + const _V(0, 1.2, 0));
    } else {
      _label(d, _t('lbl_maze'), _mazePos + const _V(0, 1.5, 0));
      _label(d, _t('lbl_bowl'), _bowlPos + const _V(0, 1.8, 0));
      _label(d, _t('lbl_magnet'), s.magnet2 + const _V(0, 1.0, 0));
      _label(d, _t('lbl_ball'), s.ball + const _V(0, 1.2, 0));
    }
  }

  void _label(_Draw d, String text, _V at) {
    final k = labelScale;
    final tp = sim.text.get(text, 11.5 * k);
    final o = d.p(at);
    final w = tp.width + 20 * k, h = tp.height + 8 * k;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: o, width: w, height: h),
      Radius.circular(6 * k),
    );
    d.canvas
      ..drawRRect(rr, _chipFill)
      ..drawRRect(rr, _chipBorder);
    tp.paint(d.canvas, Offset(o.dx - tp.width / 2, o.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.sim != sim ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

// ============================================================= LAB FRAMEWORK
// The lab screen used by every activity: shell (sidebar, curtain, canvas
// tools, popups), controller, widgets, painting helpers and shell
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

  /// Success popup body and header.
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

  /// [color] used as text or a small icon on this palette's panels and
  /// cards: unchanged in the dark theme; in the light theme a colour too
  /// bright to read on white (ZSL yellow is about 2:1) is darkened to about
  /// 5:1.
  Color ink(Color color) =>
      isDark || color.computeLuminance() < _inkMaxLuminance
      ? color
      : Color.lerp(color, LabInk.black, _inkDarken)!;

  /// The accent as a text colour (see [ink]).
  Color get accentInk => ink(accent);

  /// Brighter colours than this are darkened by [_inkDarken] for light-theme
  /// text.
  static const double _inkMaxLuminance = 0.3;
  static const double _inkDarken = 0.42;

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
    sliderTheme: SliderThemeData(activeTrackColor: accent, thumbColor: accent),
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
    assert(
      scope != null,
      'No LabStyleScope: build lab widgets inside a LabShell.',
    );
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

/// Neutral colours the shell itself uses (shadows, scrims, clear fills,
/// pure white / black for shading). Activity colours come from the
/// activity's own palette.
abstract final class LabInk {
  static const Color clear = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Card shadows, from light to heavy (HTML `shadow-lg` / `shadow-2xl`).
  static const Color shadowSoft = Color(0x40000000);
  static const Color shadow = Color(0x55000000);
  static const Color shadowStrong = Color(0x66000000);

  /// Dimmed backdrop behind dialogs and the popup's drop shadow.
  static const Color scrim = Color(0x80000000);
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

/// Strings used by the shared lab shell (header, sidebar, tools,
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
    'msg_scenario_complete':
        'Scenario Complete! Please select the next scenario.',
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

  // ------------------------------------------------- language, theme, font

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
  void showPopup(
    LabPopupBuilder builder, {
    LabTone? sound,
    bool silent = false,
  }) {
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
  /// conclusion popup. After the last scenario (or once every scenario is
  /// done) the popup offers "Restart Lab"; otherwise "Continue" closes it
  /// and shows the "Scenario Complete" toast.
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
    final allDone =
        scenarioIndex >= totalScenarios - 1 ||
        completedScenarios.length >= totalScenarios;
    after(delay, () {
      if (!isSidebarOpen) {
        isSidebarOpen = true;
        style.toggle.play();
      }
      showPopup(
        () => LabPopupContent(
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
        ),
      );
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
Rect labBleed(Size size) => Rect.fromLTRB(
  -size.width * 1.5,
  -size.height * 1.5,
  size.width * 2.5,
  size.height * 2.5,
);

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
  const LabZoomViewer({
    super.key,
    required this.controller,
    required this.child,
  });

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
    widget.controller.transform.value = tween.transform(
      Curves.easeOutCubic.transform(_anim.value),
    );
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
    final target = (scale * factor).clamp(
      LabController.minZoom,
      LabController.maxZoom,
    );
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
  if (amount >= 0) return Color.lerp(c, LabInk.white, amount.clamp(0, 1))!;
  return Color.lerp(c, LabInk.black, (-amount).clamp(0, 1))!;
}

/// Letter spacing is inserted between glyph clusters, which splits Devanagari
/// conjuncts and vowel signs apart ('वर्तमान उद्दे श्य'). Text that contains
/// Devanagari is therefore always drawn with normal spacing.
double labLetterSpacing(String text, double spacing) =>
    _labDevanagari.hasMatch(text) ? 0 : spacing;

final RegExp _labDevanagari = RegExp('[\u0900-\u097F]');

/// Draws [text] anchored at [at]. [anchor] picks which point of the text box
/// sits on [at] (centre by default). With [background] the text is drawn
/// inside a rounded pill (the HTML floating labels / distance badges).
/// Returns the painted rect.
Rect labText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 14,
  Color color = LabInk.white,
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
        letterSpacing: labLetterSpacing(text, letterSpacing),
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
    final rr = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.min(radius, h / 2)),
    );
    if (background != null) {
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = LabInk.black.withValues(alpha: 0.25 * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        rr,
        Paint()..color = background.withValues(alpha: background.a * opacity),
      );
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
  Color color = LabInk.white,
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
  Color color = LabInk.white,
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
void labDashedPath(
  Canvas canvas,
  Path path,
  Paint paint, {
  double dash = 8,
  double gap = 6,
  double phase = 0,
}) {
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
void labGlow(
  Canvas canvas,
  Offset c,
  double r,
  Color color, {
  double intensity = 1,
}) {
  if (intensity <= 0 || r <= 0) return;
  final rect = Rect.fromCircle(center: c, radius: r);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: (0.85 * intensity).clamp(0, 1)),
          color.withValues(alpha: (0.35 * intensity).clamp(0, 1)),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.35, 1],
      ).createShader(rect),
  );
}

/// Soft elliptical contact shadow under an object.
void labGroundShadow(
  Canvas canvas,
  Offset c,
  double w,
  double h, {
  double opacity = 0.3,
}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = LabInk.black.withValues(alpha: opacity)
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(front, Radius.circular(radius)),
      frontPaint,
    );
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
    ..arcTo(
      Rect.fromLTWH(rect.left, rect.bottom - eh / 2, rect.width, eh),
      math.pi,
      -math.pi,
      false,
    )
    ..lineTo(rect.right, rect.top)
    ..close();
  canvas.drawPath(
    body,
    Paint()
      ..shader = LinearGradient(
        colors: [
          a(labShade(color, -0.35)),
          a(labShade(color, 0.25)),
          a(color),
          a(labShade(color, -0.45)),
        ],
        stops: const [0, 0.3, 0.6, 1],
      ).createShader(rect),
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
    final lr = Rect.fromLTRB(
      inner.left,
      inner.bottom - h,
      inner.right,
      inner.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        lr,
        bottomLeft: Radius.circular(r),
        bottomRight: Radius.circular(r),
      ),
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
      Rect.fromCenter(
        center: Offset(lr.center.dx, lr.top),
        width: lr.width,
        height: lr.width * 0.12,
      ),
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
      ..color = LabInk.white.withValues(alpha: 0.25),
  );
  if (graduations) {
    final g = Paint()
      ..strokeWidth = 1.2
      ..color = glass.withValues(alpha: 0.7);
    for (var i = 1; i <= 4; i++) {
      final y = rect.bottom - rect.height * i / 5;
      canvas.drawLine(
        Offset(rect.right - rect.width * 0.25, y),
        Offset(rect.right - 3, y),
        g,
      );
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
    ..arcToPoint(
      Offset(rect.right, rect.bottom - r),
      radius: Radius.circular(r),
      clockwise: false,
    )
    ..lineTo(rect.right, rect.top);
  if (fill > 0) {
    canvas.save();
    canvas.clipPath(
      Path()
        ..addPath(path, Offset.zero)
        ..close(),
    );
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
void labFlame(
  Canvas canvas,
  Offset base,
  double height,
  double t, {
  double intensity = 1,
}) {
  if (intensity <= 0) return;
  final flick = 1 + 0.08 * math.sin(t * 17) + 0.05 * math.sin(t * 29 + 1.3);
  final h = height * flick * intensity;
  final w = height * 0.42 * intensity;
  labGlow(
    canvas,
    base.translate(0, -h * 0.45),
    h * 1.1,
    const Color(0xFFF97316),
    intensity: 0.55 * intensity,
  );
  Path flame(double sx, double sy) => Path()
    ..moveTo(base.dx, base.dy - h * sy)
    ..cubicTo(
      base.dx + w * sx,
      base.dy - h * sy * 0.55,
      base.dx + w * sx * 0.9,
      base.dy,
      base.dx,
      base.dy,
    )
    ..cubicTo(
      base.dx - w * sx * 0.9,
      base.dy,
      base.dx - w * sx,
      base.dy - h * sy * 0.55,
      base.dx,
      base.dy - h * sy,
    )
    ..close();
  canvas.drawPath(
    flame(1, 1),
    Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.9),
  );
  canvas.drawPath(flame(0.7, 0.75), Paint()..color = const Color(0xFFFACC15));
  canvas.drawPath(
    flame(0.35, 0.4),
    Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.9),
  );
}

/// Wavy heat / airflow arrow (convection, breezes).
void labWavyArrow(
  Canvas canvas,
  Offset from,
  Offset to,
  double t, {
  Color color = const Color(0xFFF97316),
  double amp = 6,
  double width = 3,
}) {
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
  labArrow(
    canvas,
    from + u * (len - 14),
    to,
    color: color,
    width: width,
    head: 11,
  );
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
    fill.computeLuminance() > 0.45 ? palette.onAccent : LabInk.white;

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
        child: ConstrainedBox(
          // 48 dp tap target however small the scale.
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: vPad),
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (a.icon != null) ...[
                  Icon(
                    a.icon,
                    size: 16 * s,
                    color: fg.withValues(alpha: enabled ? 1 : 0.6),
                  ),
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

/// Lays out a list of actions as full-width buttons, [columns] per row (a
/// last odd button spans its row; buttons in a row share its height).
class LabActionList extends StatelessWidget {
  const LabActionList({
    super.key,
    required this.actions,
    this.scale = 1,
    this.dense = false,
    this.columns = 1,
  });

  final List<LabAction> actions;
  final double scale;
  final bool dense;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final gap = 8 * scale;
    final rows = <Widget>[
      for (var i = 0; i < actions.length; i += columns)
        if (columns <= 1)
          LabActionButton(action: actions[i], scale: scale, dense: dense)
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var j = i;
                  j < math.min(i + columns, actions.length);
                  j++
                ) ...[
                  if (j > i) SizedBox(width: gap),
                  Expanded(
                    child: LabActionButton(
                      action: actions[j],
                      scale: scale,
                      dense: dense,
                    ),
                  ),
                ],
              ],
            ),
          ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
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
        ? (card.localToGlobal(Offset.zero, ancestor: area) - _startOffset) &
              card.size
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
        _keepInside(
          offset.dx,
          home.left,
          home.right,
          bounds.left,
          bounds.right,
        ),
        _keepInside(
          offset.dy,
          home.top,
          home.bottom,
          bounds.top,
          bounds.bottom,
        ),
      );
    }
    setState(() => widget.controller.cardOffsets[widget.id] = offset);
  }

  /// Shift along one axis that keeps [start, end] inside [lo, hi]. A card
  /// bigger than the area may slide until its edges meet the area's.
  static double _keepInside(
    double shift,
    double start,
    double end,
    double lo,
    double hi,
  ) {
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

    if (w.left == null &&
        w.top == null &&
        w.right == null &&
        w.bottom == null) {
      // Centred card: the whole layer is shifted by the drag offset, so the
      // card is laid out (and therefore hit-tested) exactly where it is drawn.
      return Stack(
        children: [
          Positioned(
            left: o.dx,
            top: o.dy,
            right: -o.dx,
            bottom: -o.dy,
            child: Center(child: placed),
          ),
        ],
      );
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
            ? const [
                BoxShadow(
                  color: LabInk.shadowSoft,
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Small uppercase section heading (HTML `uppercase tracking-widest`).
class LabSectionLabel extends StatelessWidget {
  const LabSectionLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 11,
    this.icon,
  });

  final String text;
  final Color? color;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = LabStyleScope.of(context).palette;
    final c = palette.ink(color ?? palette.accent);
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
              letterSpacing: labLetterSpacing(text, 1.1),
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
            materialTapTargetSize: MaterialTapTargetSize.padded,
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
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
              ),
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
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: p.readoutBg,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: p.readoutBorder, width: 2.5 * scale),
        boxShadow: const [
          BoxShadow(color: LabInk.shadowStrong, blurRadius: 16),
        ],
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
              letterSpacing: labLetterSpacing(text, 2),
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
///   header (title, language, reset), scenario selector,
///   target output (mission objective + current step), all action buttons,
///   optional activity controls and the footer,
/// * a fixed menu button (top-left) that expands / collapses the sidebar,
///   and a back button (top-right, above everything, also on the curtain)
///   that returns to the home page,
/// * a floating mission card with the dynamic action buttons while the
///   sidebar is collapsed,
/// * the zoomable canvas with tool buttons (labels, lock, pan, reset view,
///   zoom in / out), feedback toast, HUD objective and activity overlays,
/// * the scrollable success popup.
///
/// Every floating card (popup, mission card, HUD objective and the
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
    this.hud,
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

  /// Short task line for the canvas HUD only (the HTML `sN_hud_M` texts);
  /// defaults to the current objective. The sidebar keeps the step text.
  final String? hud;

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
  EdgeInsets _canvasMargin(EdgeInsets pad) => EdgeInsets.fromLTRB(
    4,
    4,
    widget.showTools ? _kToolColumnClearance + pad.right : 4,
    4,
  );

  /// Activity overlay cards can be dragged anywhere on the canvas. Full-size
  /// layers (Positioned.fill) stay put.
  Widget _movableOverlay(Widget overlay, int index, EdgeInsets margin) {
    if (overlay is! Positioned) return overlay;
    if (overlay.left == 0 &&
        overlay.top == 0 &&
        overlay.right == 0 &&
        overlay.bottom == 0) {
      return overlay;
    }
    return Positioned.fill(
      key: overlay.key,
      child: LabMovable(
        controller: widget.controller,
        // Keyed overlays keep their dragged offset even when an earlier
        // overlay appears or disappears (the index would shift).
        id: overlay.key != null
            ? 'overlay-${overlay.key}'
            : 'overlay-$index-${overlay.child.runtimeType}',
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
        final font = c.style.font.orAmbient(
          Theme.of(context).textTheme.bodyMedium,
        );
        LabFont.active = font;
        final size = MediaQuery.sizeOf(context);
        final pad = MediaQuery.paddingOf(context);
        final s = context.labScale;
        final sidebarW = _sidebarWidth(size.width);

        // Any tap re-hides the system bars; not a control, so it stays out
        // of the semantics tree.
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
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
                          duration: _resizing
                              ? Duration.zero
                              : const Duration(milliseconds: 380),
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
                                    child: _Sidebar(
                                      shell: widget,
                                      palette: p,
                                      scale: s,
                                    ),
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
                          child: _FloatingMissionCard(
                            shell: widget,
                            palette: p,
                            scale: s,
                          ),
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
                    if (c.popup != null)
                      _PopupLayer(controller: c, palette: p, scale: s),
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

  Widget _buildCanvas(
    BuildContext context,
    LabPalette p,
    double s,
    EdgeInsets pad,
  ) {
    final c = widget.controller;
    final w = widget;
    final instruction = w.hud ?? _currentInstruction(w);
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: p.canvasBg),
          LabZoomViewer(controller: c, child: w.stage),
          for (var i = 0; i < w.overlays.length; i++)
            _movableOverlay(w.overlays[i], i, _canvasMargin(pad)),
          if (w.showHud && c.isSidebarOpen && instruction.isNotEmpty)
            Positioned.fill(
              child: LabMovable(
                controller: c,
                id: 'hud',
                margin: _canvasMargin(pad),
                left: 12,
                right: _kToolColumnClearance + 4 + pad.right,
                bottom: 8 + pad.bottom,
                child: Center(
                  child: _HudChip(
                    text: instruction,
                    palette: p,
                    scale: s,
                    label: c.t('curr_obj'),
                  ),
                ),
              ),
            ),
          // Below the Back button; scrolls on screens too short for all
          // six 48 dp tools.
          if (w.showTools)
            Positioned(
              right: 8 + pad.right,
              top: _kToolColumnTop + pad.top,
              bottom: 8 + pad.bottom,
              child: Center(
                child: SingleChildScrollView(
                  child: _ToolsPanel(controller: c, palette: p, scale: s),
                ),
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

  Widget _buildCurtain(
    BuildContext context,
    LabPalette p,
    double s,
    EdgeInsets pad,
  ) {
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
                gradient: RadialGradient(
                  colors: [p.curtainGlow, p.curtainBg.withValues(alpha: 0)],
                  radius: 0.9,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32 * s,
                        vertical: 24 * s,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: Tween(
                              begin: 0.55,
                              end: 1.0,
                            ).animate(_iconPulse),
                            child: Icon(
                              widget.icon,
                              size: 56 * s,
                              color: p.accent,
                            ),
                          ),
                          SizedBox(height: 12 * s),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainText,
                              fontSize: 30 * s,
                              fontWeight: FontWeight.w800,
                              letterSpacing: labLetterSpacing(
                                widget.title,
                                -0.5,
                              ),
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.curtainMuted,
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 24 * s),
                          FilledButton.icon(
                            onPressed: _curtain.isAnimating ? null : _enterLab,
                            icon: Icon(Icons.play_arrow_rounded, size: 22 * s),
                            label: Text(c.t('enter_lab')),
                            style: FilledButton.styleFrom(
                              backgroundColor: p.accent,
                              foregroundColor: p.onAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30 * s,
                                vertical: 14 * s,
                              ),
                              textStyle: TextStyle(
                                fontSize: 17 * s,
                                fontWeight: FontWeight.w800,
                              ),
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
                label: Text(
                  c.lang.badge,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(foregroundColor: p.curtainIcon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top of the canvas tool column: just below the Back button (16 + 48 dp).
const double _kToolColumnTop = 72;

/// Room kept free of canvas cards on the right for the tool column (8 dp
/// margin + 48 dp tools + card padding + a small gap).
const double _kToolColumnClearance = 72;

/// Screens shorter than this (phones in landscape) get the compact floating
/// mission card.
const double _kCompactMissionCardBelow = 480;

/// Tallest the compact mission card gets, as a fraction of the screen height
/// (its text scrolls beyond that).
const double _kCompactMissionCardMaxHeight = 0.55;

/// Width of the floating mission card shown while the sidebar is collapsed.
double _missionCardWidth(Size size, double s) =>
    (size.width * 0.36).clamp(200.0, 380.0 * s);

/// Insets (relative to the canvas area) that keep activity overlays clear
/// of the shell's own canvas UI: the tool column on the right and, while
/// the sidebar is collapsed, the menu button + floating mission card on the
/// left. Use `left`/`right` for overlays placed along the top edge, e.g.
/// `Positioned(top: 10, left: i.left, right: i.right, child: Center(...))`.
EdgeInsets labOverlayInsets(BuildContext context, LabController c) {
  final size = MediaQuery.sizeOf(context);
  final pad = MediaQuery.paddingOf(context);
  final s = context.labScale;
  final left = c.isSidebarOpen
      ? 8.0
      : 76 + pad.left + _missionCardWidth(size, s) + 8;
  return EdgeInsets.fromLTRB(
    left,
    8 + pad.top,
    _kToolColumnClearance + pad.right,
    8 + pad.bottom,
  );
}

String _currentInstruction(LabShell w) {
  if (w.instruction != null) return w.instruction!;
  if (w.steps.isEmpty) return '';
  final i = (w.currentStep - 1).clamp(0, w.steps.length - 1);
  return w.steps[i].action;
}

// ============================================================== SIDEBAR

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.shell,
    required this.palette,
    required this.scale,
  });

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
        boxShadow: const [
          BoxShadow(color: LabInk.shadow, blurRadius: 18, offset: Offset(4, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The title row is pinned above the scroll view. The fixed menu
          // button sits over its left end, so nothing that scrolls passes
          // under the button (the band ends below the button's 64 px).
          Padding(
            padding: EdgeInsets.fromLTRB(
              12 * s + pad.left,
              12 + pad.top,
              12 * s,
              8,
            ),
            child: _titleRow(p, s),
          ),
          Expanded(child: _scrollBody(context, p, s, f, pad)),
        ],
      ),
    );
  }

  Widget _scrollBody(
    BuildContext context,
    LabPalette p,
    double s,
    double f,
    EdgeInsets pad,
  ) {
    final c = shell.controller;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12 * s + pad.left, 2 * s, 12 * s, 8 * s),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _header(context, p, s),
              SizedBox(height: 12 * s),
              if (shell.scenarioNames.length > 1) ...[
                _scenarioSelector(p, s, f),
                SizedBox(height: 12 * s),
              ],
              _targetOutput(p, s, f),
              if (shell.actions.isNotEmpty) ...[
                SizedBox(height: 14 * s),
                LabSectionLabel(
                  c.t('actions'),
                  size: 10.5 * s,
                  icon: Icons.touch_app,
                ),
                SizedBox(height: 8 * s),
                LabActionList(actions: shell.actions, scale: s),
              ],
              if (shell.sidebarExtra != null) ...[
                SizedBox(height: 14 * s),
                LabSectionLabel(
                  shell.sidebarExtraTitle ?? c.t('controls'),
                  size: 10.5 * s,
                  icon: Icons.tune,
                ),
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
              padding: EdgeInsets.fromLTRB(
                10 * s + pad.left,
                10 * s,
                10 * s,
                10 * s + pad.bottom,
              ),
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
                  letterSpacing: labLetterSpacing(c.t('footer'), 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Activity icon, title and subtitle. Leaves room for the fixed menu
  /// button at top-left.
  Widget _titleRow(LabPalette p, double s) {
    return Padding(
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
              child: Icon(shell.icon, color: p.accentInk, size: 20 * s),
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
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 10 * s,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, LabPalette p, double s) {
    final c = shell.controller;
    Widget headerBtn(
      IconData icon,
      String tip,
      VoidCallback onTap, {
      String? text,
    }) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.cardBorder),
            ),
            // Scales down instead of overflowing while the page is still
            // portrait and the sidebar is very narrow.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 17 * s, color: p.textStrong),
                  if (text != null) ...[
                    SizedBox(width: 4 * s),
                    Text(
                      text,
                      style: TextStyle(
                        color: p.textStrong,
                        fontWeight: FontWeight.w800,
                        fontSize: 12 * s,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Language and Reset share one row and split the sidebar width, so they
    // stay side by side at every sidebar width (20% to 50%). The row is
    // indented like the title row above it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: Row(
            children: [
              Expanded(
                child: headerBtn(
                  Icons.translate,
                  c.t('toggle_language'),
                  c.toggleLanguage,
                  text: c.lang.badge,
                ),
              ),
              SizedBox(width: 6 * s),
              Expanded(
                child: headerBtn(Icons.restart_alt, c.t('reset_lab'), () {
                  c.style.click.play();
                  c.requestFullReset();
                }),
              ),
            ],
          ),
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
            style: TextStyle(
              color: p.textMuted,
              fontSize: 9.5 * s,
              fontWeight: FontWeight.w800,
              letterSpacing: labLetterSpacing(c.t('select_scenario'), 1),
            ),
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
      color: selected ? p.accent.withValues(alpha: 0.16) : LabInk.clear,
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
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.accent : p.cardBorder),
          ),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle
                    : (selected
                          ? Icons.menu_book
                          : Icons.radio_button_unchecked),
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
          LabSectionLabel(
            c.t('target_output'),
            size: 10.5 * s,
            icon: Icons.track_changes,
          ),
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 8 * s),
            Text(
              c.t('mission_obj'),
              style: TextStyle(
                color: p.textMuted,
                fontSize: 10 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3 * s),
            Text(
              shell.objective,
              style: TextStyle(
                color: p.text,
                fontSize: 12.5 * f,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          if (hasSteps) ...[
            SizedBox(height: 10 * s),
            Row(
              children: [
                // Flexible: "चरण 1 में से 3" at the largest font is wider than a
                // narrow sidebar; it wraps instead of overflowing.
                Flexible(
                  child: Text(
                    '${c.t('step')} ${cur.clamp(1, steps.length)} ${c.t('of')} ${steps.length}',
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11 * f,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                                : (i == cur
                                      ? p.accent
                                      : p.cardBorder.withValues(alpha: 0.5)),
                            border: Border.all(
                              color: i < cur
                                  ? p.info
                                  : (i == cur ? p.accent : p.cardBorder),
                            ),
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
                      Icon(Icons.info, size: 14 * s, color: p.accentInk),
                      SizedBox(width: 5 * s),
                      Expanded(
                        child: Text(
                          c.t('curr_obj').toUpperCase(),
                          style: TextStyle(
                            color: p.accentInk,
                            fontSize: 9.5 * f,
                            fontWeight: FontWeight.w800,
                            letterSpacing: labLetterSpacing(c.t('curr_obj'), 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (step != null &&
                      step.concept.isNotEmpty &&
                      shell.instruction == null) ...[
                    SizedBox(height: 5 * s),
                    Text(
                      '${c.t('concept_focus')} ${step.concept}',
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 10.5 * f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  SizedBox(height: 4 * s),
                  Text(
                    instruction,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 12.5 * f,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
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
  const _FloatingMissionCard({
    required this.shell,
    required this.palette,
    required this.scale,
  });

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
    // Phones in landscape: a compact card (step + instruction beside the
    // minimize button, no objective) of at most 55% of the screen height, so
    // it leaves the scene free.
    final compact = size.height < _kCompactMissionCardBelow;

    final stepSpan = steps.isEmpty
        ? null
        : TextSpan(
            text:
                '${c.t('step')} ${shell.currentStep.clamp(1, steps.length)}/${steps.length} • ',
            style: TextStyle(color: p.accentInk, fontWeight: FontWeight.w800),
          );
    final instructionStyle = TextStyle(
      color: p.textStrong,
      fontSize: 11.5 * s,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
    final toggle = InkWell(
      onTap: () {
        c.style.click.play();
        setState(() => _minimized = !_minimized);
      },
      child: Tooltip(
        message: _minimized ? c.t('expand') : c.t('minimize'),
        child: SizedBox.square(
          dimension: kMinInteractiveDimension,
          child: Icon(
            _minimized ? Icons.expand_more : Icons.expand_less,
            size: 20 * s,
            color: p.textMuted,
          ),
        ),
      ),
    );
    final actions = [
      if (!_minimized && shell.actions.isNotEmpty) ...[
        SizedBox(height: 6 * s),
        LabActionList(
          actions: shell.actions,
          scale: s,
          dense: true,
          // Two per row in the compact card, so they stay in view.
          columns: compact && shell.actions.length >= 3 ? 2 : 1,
        ),
      ],
    ];

    final List<Widget> children;
    if (compact) {
      children = [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4 * s),
                child: Text.rich(
                  TextSpan(
                    children: [
                      ?stepSpan,
                      TextSpan(
                        text: instruction.isEmpty
                            ? c.t('mission_obj')
                            : instruction,
                      ),
                    ],
                  ),
                  maxLines: _minimized ? 1 : null,
                  overflow: _minimized ? TextOverflow.ellipsis : null,
                  style: instructionStyle,
                ),
              ),
            ),
            toggle,
          ],
        ),
        ...actions,
      ];
    } else {
      children = [
        Row(
          children: [
            Icon(Icons.flag_rounded, size: 15 * s, color: p.accentInk),
            SizedBox(width: 5 * s),
            Expanded(
              child: Text(
                c.t('mission_obj').toUpperCase(),
                style: TextStyle(
                  color: p.accentInk,
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: labLetterSpacing(c.t('mission_obj'), 1),
                ),
              ),
            ),
            toggle,
          ],
        ),
        if (!_minimized) ...[
          if (shell.objective.isNotEmpty) ...[
            SizedBox(height: 6 * s),
            Text(
              shell.objective,
              style: TextStyle(
                color: p.text,
                fontSize: 11.5 * s,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
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
                    ?stepSpan,
                    TextSpan(text: instruction),
                  ],
                ),
                style: instructionStyle,
              ),
            ),
          ],
          ...actions,
        ],
      ];
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: compact
            ? size.height * _kCompactMissionCardMaxHeight
            : size.height - 24,
      ),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all((compact ? 7 : 10) * s),
        borderColor: p.accent.withValues(alpha: 0.6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

// ================================================================ CANVAS UI

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.text,
    required this.palette,
    required this.scale,
    required this.label,
  });

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
                Icon(Icons.info, size: 12 * s, color: palette.accentInk),
                SizedBox(width: 4 * s),
                // Flexible: while the page is still rotating to landscape
                // the chip can be narrower than the label.
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.accentInk,
                      fontWeight: FontWeight.w800,
                      fontSize: 9 * s,
                      letterSpacing: labLetterSpacing(label, 1),
                    ),
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
              style: TextStyle(
                color: palette.textStrong,
                fontWeight: FontWeight.w700,
                fontSize: 11 * s,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsPanel extends StatelessWidget {
  const _ToolsPanel({
    required this.controller,
    required this.palette,
    required this.scale,
  });

  final LabController controller;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final p = palette;
    final s = scale.clamp(0.85, 1.25);
    // Visible highlight inside each 48 dp tap target.
    final highlight = (34 * s).clamp(30.0, 42.0);
    Widget tool(
      IconData icon,
      String tip,
      VoidCallback onTap, {
      bool active = false,
    }) {
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox.square(
            dimension: kMinInteractiveDimension,
            child: Center(
              child: Container(
                width: highlight,
                height: highlight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? p.accent.withValues(alpha: 0.18)
                      : LabInk.clear,
                ),
                child: Icon(
                  icon,
                  size: 19 * s,
                  color: active ? p.accentInk : p.textMuted,
                ),
              ),
            ),
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
          tool(
            c.showLabels ? Icons.label : Icons.label_off,
            c.t('tool_labels'),
            c.toggleLabels,
            active: c.showLabels,
          ),
          divider,
          tool(
            c.camLocked ? Icons.lock : Icons.lock_open,
            c.t('tool_lock'),
            c.toggleCamLock,
            active: c.camLocked,
          ),
          tool(
            Icons.pan_tool_alt,
            c.t('tool_pan'),
            c.togglePanMode,
            active: c.panMode,
          ),
          tool(Icons.center_focus_strong, c.t('tool_reset_view'), c.resetView),
          tool(Icons.zoom_in, c.t('tool_zoom_in'), c.zoomIn),
          tool(Icons.zoom_out, c.t('tool_zoom_out'), c.zoomOut),
        ],
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({
    required this.toast,
    required this.palette,
    required this.scale,
  });

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
            position: Tween(
              begin: const Offset(0, -0.4),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: t == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey(t.id),
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * s,
                  vertical: 8 * s,
                ),
                decoration: BoxDecoration(
                  color: t.isError ? palette.danger : palette.toastBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(color: LabInk.shadow, blurRadius: 12),
                  ],
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
                          color: t.isError
                              ? palette.onDanger
                              : palette.toastText,
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
  const _PopupLayer({
    required this.controller,
    required this.palette,
    required this.scale,
  });

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
    final accentInk = p.ink(accent);
    final width = (size.width * 0.6).clamp(260.0, 470.0 * s);

    return Positioned.fill(
      child: LabMovable(
        controller: c,
        id: 'popup',
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Material(
            color: LabInk.clear,
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: size.height * 0.86),
              decoration: BoxDecoration(
                color: p.popupBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.6)),
                boxShadow: const [
                  BoxShadow(
                    color: LabInk.scrim,
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (drag anywhere on the card to move it).
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * s,
                      vertical: 8 * s,
                    ),
                    decoration: BoxDecoration(
                      color: p.popupHeader,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      border: Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        Icon(content.icon, color: accentInk, size: 18 * s),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            content.title,
                            style: TextStyle(
                              color: accentInk,
                              fontWeight: FontWeight.w800,
                              fontSize: 14 * s,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.drag_indicator,
                          size: 18 * s,
                          color: p.textMuted,
                        ),
                        IconButton(
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
                                border: Border(
                                  bottom: BorderSide(color: p.cardBorder),
                                ),
                              ),
                              child: Text(
                                content.heading!.toUpperCase(),
                                style: TextStyle(
                                  color: accentInk,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5 * s,
                                  letterSpacing: labLetterSpacing(
                                    content.heading!,
                                    1,
                                  ),
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
                          if (content.extra != null) ...[
                            SizedBox(height: 10 * s),
                            content.extra!,
                          ],
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
