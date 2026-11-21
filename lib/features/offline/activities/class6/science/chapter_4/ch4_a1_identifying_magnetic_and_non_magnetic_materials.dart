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

/// Class 6 Science • Chapter 4 • Activity 1
/// Identifying Magnetic and Non-magnetic Materials.
///
/// Native Flutter port of
/// `Cl6S-Ch4-A1-Identifying_Magnetic_and_Non_magnetic_Materials.html`.
///
/// Scenario 1 (The Scientist's Desk): look at the five objects on the desk,
/// then drag the bar magnet close to each one. The iron nail
/// jumps to the magnet; the pencil, eraser, plastic scale and glass marble
/// stay put. The observation table records every test.
///
/// Scenario 2 (Recycling Plant Challenge): press and hold the electromagnet
/// above the moving conveyor belt to switch it on, pick up the iron nails,
/// carry them over the green (magnetic) bin and let go to drop them in.
/// Wooden blocks ride on into the red (non-magnetic) bin.
class Ch4A1IdentifyingMagneticAndNonMagneticMaterialsPage
    extends StatefulWidget {
  const Ch4A1IdentifyingMagneticAndNonMagneticMaterialsPage({super.key});

  @override
  State<Ch4A1IdentifyingMagneticAndNonMagneticMaterialsPage> createState() =>
      _MagnetLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML has no sounds of its own, so the
/// lab uses the shell tones plus pickup / drop for the magnets.
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

  /// Object attracted, item sorted.
  correct('audio/class6/science/correct.mp3'),

  /// Object not attracted, nail over the wrong bin.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / success popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// Magnet put down / electromagnet released with its load.
  drop('audio/class6/science/drop.mp3'),

  /// Bar magnet picked up / electromagnet switched on.
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

/// Colours of the HTML page (Tailwind classes) and of its Three.js scene
/// (material colours).
abstract final class _Colors {
  // ----------------------------------------------------------- page / UI
  static const Color zslYellow = Color(0xFFEAB308); // Enter Lab button
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo500 = Color(0xFF6366F1); // tailwind `primary`
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color white = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- scene
  /// `#canvas-wrapper` background (dark in both HTML themes).
  static const Color sceneBg = Color(0xFF0F172A);

  /// `.canvas-grid` lines (white / 3 %, dark theme only).
  static const Color grid = Color(0x08FFFFFF);
  static const Color desk = Color(0xFF5C4033);
  static const Color magnetRed = Color(0xFFE53E3E);
  static const Color magnetBlue = Color(0xFF3182CE);

  /// Bar-magnet glow box and the electromagnet's field lines.
  static const Color field = indigo500;
  static const Color iron = Color(0xFF888888);
  static const Color pencilYellow = Color(0xFFEAB308);
  static const Color pencilWood = Color(0xFFD2B48C);
  static const Color graphite = Color(0xFF222222);
  static const Color eraser = Color(0xFFF472B6);
  static const Color scale = Color(0xFF93C5FD);
  static const Color marble = Color(0xFF10B981);
  static const Color belt = Color(0xFF222222);
  static const Color beltEdge = Color(0x66475569);
  static const Color tread = Color(0x14FFFFFF);
  static const Color emCore = Color(0xFF333333);
  static const Color copper = Color(0xFFB87333);
  static const Color binGreen = Color(0xFF22C55E);
  static const Color binRed = Color(0xFFEF4444);
  static const Color woodBlock = Color(0xFF8B4513);

  /// Soft contact shadows on the desk.
  static const Color shadow = Color(0x59000000);

  /// `.html-label` chip: `bg-black/60 text-white`.
  static const Color labelBg = Color(0x99000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A), // slate-900/95
    border: Color(0x26FFFFFF), // white/15
    card: Color(0xCC1E293B), // slate-800/80
    cardBorder: _Colors.slate600,
    canvasBg: _Colors.sceneBg,
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
    info: _Colors.green500,
    popupBg: _Colors.slate800,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2F8FAFC), // slate-50/95
    border: Color(0x26000000), // black/15
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneBg,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo500,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.green600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC0F172A),
    buttonIcon: _Colors.indigo300,
    buttonBorder: Color(0xCC6366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar text size setting: 15 px, slider 12–32 px.
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
// From the HTML `i18n` table (Telugu dropped). Step numbers ("1. ") are
// dropped because the shell shows "Step n of N". Steps that did not say
// exactly what to do on a touch screen are spelled out (see the report);
// keys marked "added" are new texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Identifying Magnetic and Non-magnetic Materials',
    'app_subtitle': 'Class 6 • Exploring Magnets',
    'scen_1_opt': "Scenario 1: The Scientist's Desk",
    'scen_2_opt': 'Scenario 2: Recycling Plant Challenge',
    's1_desc':
        'To test various common objects with a bar magnet and classify them as magnetic or non-magnetic.',
    's2_desc':
        'To use an electromagnet to separate magnetic materials from non-magnetic materials on a moving conveyor belt.',
    'step_1_1':
        'Explore the desk. Identify the Iron Nail, Pencil, Eraser, Plastic Scale, and Glass Marble.',
    'step_1_2': 'Drag the Bar Magnet close to the Iron Nail and observe.',
    'step_1_3': 'Drag the Bar Magnet to the Pencil and observe.',
    'step_1_4':
        'Test the remaining objects: drag the Bar Magnet close to the Eraser, the Plastic Scale and the Glass Marble, one by one.',
    'step_1_5': 'Review the observation table.',
    'step_2_1': 'Observe the items moving on the conveyor belt.',
    'step_2_2': 'Press and hold the Electromagnet to ACTIVATE it.',
    'step_2_3':
        'Keep holding and hover the active magnet over the magnetic items (Iron Nails) to pick them up.',
    'step_2_4':
        'Keep holding and drag the electromagnet over the Green (Magnetic) Bin.',
    'step_2_5':
        'Release the electromagnet to deactivate it and drop the item into the bin.',
    'step_2_6':
        'Sort all items! Drop every Iron Nail into the Green Bin with the electromagnet; Wooden Blocks ride on into the Red Bin at the end of the belt.',
    'item_nail': 'Iron Nail',
    'item_pencil': 'Pencil',
    'item_eraser': 'Eraser',
    'item_scale': 'Plastic Scale',
    'item_marble': 'Glass Marble',
    'item_wood_block': 'Wooden Block',
    'lbl_electromagnet': 'Electromagnet',
    'lbl_mag_bin': 'Magnetic Bin',
    'lbl_non_mag_bin': 'Non-Magnetic Bin',
    'yes': 'Yes',
    'no': 'No',
    'obs_table': 'Observation Table',
    'tbl_obj': 'Object',
    'tbl_attract': 'Attracted?',
    'toast_attract': 'is Attracted!',
    'toast_no_attract': 'is NOT Attracted.',
    'toast_on': 'Electromagnet Activated!',
    'toast_off': 'Electromagnet Deactivated.',
    'toast_sort_mag': 'Magnetic item sorted!',
    'sum_s1_title': 'Investigation Complete!',
    'sum_s1_desc':
        'Materials attracted are Magnetic (Iron Nail). Materials not attracted are Non-Magnetic.',
    'sum_s2_title': 'Recycling Sorted!',
    'sum_s2_desc':
        'You successfully separated the materials using the electromagnet.',
    // Added.
    'tbl_empty': 'No object tested yet.',
    // Hindi needs the feminine verb after कील / पेंसिल; English is the same.
    'toast_attract_f': 'is Attracted!',
    'toast_no_attract_f': 'is NOT Attracted.',
    'toast_wrong_bin':
        'Iron Nails are magnetic! Drop them into the Green (Magnetic) Bin.',
    'toast_missed':
        'An Iron Nail was missed! It comes round on the belt again.',
    'sort_progress': 'Sorting Progress',
    'lbl_on_belt': 'Still on the belt',
    'scene_desk':
        'Desk with a bar magnet, an iron nail, a pencil, an eraser, a plastic scale and a glass marble',
    'scene_plant':
        'Conveyor belt with an electromagnet above it, a green magnetic bin and a red non-magnetic bin',
  },
  'hi': {
    'app_title': 'चुंबकीय पदार्थों की पहचान',
    'app_subtitle': 'कक्षा 6 • चुंबकों की खोज',
    'scen_1_opt': 'परिदृश्य 1: वैज्ञानिक की मेज',
    'scen_2_opt': 'परिदृश्य 2: रीसाइक्लिंग प्लांट चुनौती',
    's1_desc':
        'विभिन्न सामान्य वस्तुओं का छड़ चुंबक से परीक्षण करना और उन्हें चुंबकीय या अचुंबकीय के रूप में वर्गीकृत करना।',
    's2_desc':
        'चलती कन्वेयर बेल्ट पर चुंबकीय पदार्थों को अचुंबकीय पदार्थों से अलग करने के लिए विद्युत चुंबक का उपयोग करना।',
    'step_1_1':
        'मेज का अन्वेषण करें। लोहे की कील, पेंसिल, इरेज़र, प्लास्टिक स्केल और कांच के कंचे की पहचान करें।',
    'step_1_2': 'छड़ चुंबक को लोहे की कील के पास खींचें और निरीक्षण करें।',
    'step_1_3': 'छड़ चुंबक को पेंसिल के पास खींचें और निरीक्षण करें।',
    'step_1_4':
        'शेष वस्तुओं का परीक्षण करें: छड़ चुंबक को एक-एक करके इरेज़र, प्लास्टिक स्केल और कांच के कंचे के पास खींचें।',
    'step_1_5': 'अवलोकन तालिका की समीक्षा करें।',
    'step_2_1': 'कन्वेयर बेल्ट पर चलती हुई वस्तुओं का निरीक्षण करें।',
    'step_2_2': 'विद्युत चुंबक को सक्रिय करने के लिए उसे दबाकर रखें।',
    'step_2_3':
        'दबाए रखें और सक्रिय चुंबक को चुंबकीय वस्तुओं (लोहे की कीलों) के ऊपर ले जाएं ताकि वे उठ जाएं।',
    'step_2_4':
        'दबाए रखें और विद्युत चुंबक को हरे (चुंबकीय) डिब्बे के ऊपर खींचें।',
    'step_2_5':
        'विद्युत चुंबक को छोड़ दें, ताकि वह निष्क्रिय हो जाए और वस्तु डिब्बे में गिर जाए।',
    'step_2_6':
        'सभी वस्तुओं को छांटें! विद्युत चुंबक से हर लोहे की कील को हरे डिब्बे में डालें; लकड़ी के गुटके बेल्ट के अंत में लाल डिब्बे में चले जाते हैं।',
    'item_nail': 'लोहे की कील',
    'item_pencil': 'पेंसिल',
    'item_eraser': 'इरेज़र',
    'item_scale': 'प्लास्टिक स्केल',
    'item_marble': 'कांच का कंचा',
    'item_wood_block': 'लकड़ी का गुटका',
    'lbl_electromagnet': 'विद्युत चुंबक',
    'lbl_mag_bin': 'चुंबकीय डिब्बा',
    'lbl_non_mag_bin': 'अचुंबकीय डिब्बा',
    'yes': 'हां',
    'no': 'नहीं',
    'obs_table': 'अवलोकन तालिका',
    'tbl_obj': 'वस्तु',
    'tbl_attract': 'आकर्षित?',
    'toast_attract': 'आकर्षित हुआ!',
    'toast_no_attract': 'आकर्षित नहीं हुआ।',
    'toast_on': 'विद्युत चुंबक सक्रिय!',
    'toast_off': 'विद्युत चुंबक निष्क्रिय।',
    'toast_sort_mag': 'चुंबकीय वस्तु छंट गई!',
    'sum_s1_title': 'जांच पूरी हुई!',
    'sum_s1_desc':
        'आकर्षित होने वाले पदार्थ चुंबकीय हैं (लोहे की कील)। आकर्षित न होने वाले पदार्थ अचुंबकीय हैं।',
    'sum_s2_title': 'रीसाइक्लिंग छंट गई!',
    'sum_s2_desc':
        'आपने विद्युत चुंबक का उपयोग करके सामग्रियों को सफलतापूर्वक अलग किया।',
    'tbl_empty': 'अभी तक किसी वस्तु का परीक्षण नहीं हुआ।',
    'toast_attract_f': 'आकर्षित हुई!',
    'toast_no_attract_f': 'आकर्षित नहीं हुई।',
    'toast_wrong_bin':
        'लोहे की कीलें चुंबकीय हैं! उन्हें हरे (चुंबकीय) डिब्बे में डालें।',
    'toast_missed': 'एक लोहे की कील छूट गई! वह बेल्ट पर फिर से आएगी।',
    'sort_progress': 'छंटाई की प्रगति',
    'lbl_on_belt': 'अभी बेल्ट पर',
    'scene_desk':
        'छड़ चुंबक, लोहे की कील, पेंसिल, इरेज़र, प्लास्टिक स्केल और कांच के कंचे वाली मेज',
    'scene_plant':
        'कन्वेयर बेल्ट, उसके ऊपर विद्युत चुंबक, हरा चुंबकीय डिब्बा और लाल अचुंबकीय डिब्बा',
  },
};

/// Number of steps of each scenario (HTML `numSteps`).
const List<int> _stepCounts = [5, 6];

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCounts[n - 1]; i++)
            // The HTML steps carry one text each: the instruction.
            LabStep(concept: '', action: t('step_${n}_$i')),
        ],
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing the magnets (short drags must pick them up).
const double _dragSlop = 8;

/// Object labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's 10 px chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// Longest frame step used by the simulation (s), so a stalled frame does
/// not make the belt jump.
const double _maxFrameStep = 0.1;

/// While the sidebar is collapsed the view pans right (like the HTML
/// canvas re-centring when the Teacher Board closes) so the scene clears
/// the shell's floating mission card at the top left. The shell places that
/// card 76 px from the left, 36 % of the screen wide (200 … 380 px x UI
/// scale); [_cardGap] design px are kept free on each side.
const double _missionCardLeft = 76;
const double _missionCardFraction = 0.36;
const double _missionCardMin = 200;
const double _missionCardMax = 380;
const double _cardGap = 8;

/// The pan slides like the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the panned scene layer. Flows map scene design coordinates to the
/// screen through it, so they follow the pan (`ValueKey('ch4-a1-scene')`).
const ValueKey<String> _sceneKey = ValueKey('ch4-a1-scene');

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (position, `controls.target`, fov 45) as a
/// pinhole projection onto the design stage. [center] is where the look-at
/// point lands on the stage.
@immutable
class _Cam {
  factory _Cam(_V eye, _V target, Offset center) {
    final f = (target - eye).unit;
    final r = f.cross(_V.up).unit;
    return _Cam._(eye, center, f, r, r.cross(f));
  }

  const _Cam._(this.eye, this.center, this.f, this.r, this.u);

  /// Pixels per world unit at depth 1: half the stage height over
  /// tan(fov / 2), as in Three.js.
  static final double focal =
      _design.height / 2 / math.tan(_fovDegrees * math.pi / 360);

  final _V eye;
  final Offset center;
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray through a design-space point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where the ray through [s] meets the plane `n · x = d` (HTML
  /// `raycaster.ray.intersectPlane(intersectPlane, …)`).
  _V? onPlane(Offset s, _V n, double d) {
    final dir = ray(s);
    final den = dir.dot(n);
    if (den.abs() < 1e-6) return null;
    final t = (d - eye.dot(n)) / den;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// HTML key light `DirectionalLight` at (10, 20, 10), normalised.
const _V _light = _V(0.4082, 0.8165, 0.4082);

/// HTML `AmbientLight(0xffffff, 0.6)` and `DirectionalLight(0xffffff, 0.8)`.
const double _ambient = 0.6;
const double _diffuse = 0.8;

// ------------------------------------------------------- scenario 1: desk

/// Scenario 1 camera: `camera.position.set(0, 12, 15)` looking at the
/// origin. The look-at point is drawn 60 px below the stage centre so the
/// magnet stays clear of the mission card when the sidebar is collapsed.
final _Cam _camDesk = _Cam(
  const _V(0, 12, 15),
  _V.zero,
  const Offset(500, 340),
);

/// `magnetS1.position.set(-6, 0.5, 0)`.
const _V _magnetHome = _V(-6, 0.5, 0);

/// Drag plane of the bar magnet: `intersectPlane.setComponents(0, 1, 0,
/// -0.5)`, i.e. y = 0.5.
const double _magnetPlaneY = 0.5;

/// `checkInteractions`: an item closer than this to the magnet is tested.
const double _testRange = 2.5;

/// A snapped (attracted) item hangs here relative to the magnet.
const _V _snapOffset = _V(1.5, -0.2, 0);
const double _snapSeconds = 0.15;

/// Keeps the magnet on the 20 x 15 desk top.
const double _deskHalfX = 9;
const double _deskHalfZ = 6.5;

/// The five desk objects of `setupScenario1()`.
enum _Obj {
  nail('item_nail', _V(0, 0.1, -3), 1.2, 0.3),
  pencil('item_pencil', _V(2, 0.2, 2), 1.25, 0.18),
  eraser('item_eraser', _V(-2, 0.25, 3), 0.75, 0.4),
  scale('item_scale', _V(4, 0.05, -2), 2.0, 0.25),
  marble('item_marble', _V(0, 0.3, 4), 0.3, 0.3);

  const _Obj(this.key, this.home, this.halfLength, this.halfThickness);

  /// String key of the object's name (HTML `userData.label`).
  final String key;
  final _V home;

  /// Half length along x and half thickness (world units; contact shadows).
  final double halfLength;
  final double halfThickness;

  /// HTML `userData.isMagnetic`.
  bool get isMagnetic => this == _Obj.nail;

  /// Feminine in Hindi (कील, पेंसिल): the toast verb is हुई, not हुआ.
  bool get isFeminineHi => this == _Obj.nail || this == _Obj.pencil;
}

/// One desk object and what the learner has found out about it.
class _DeskItem {
  _DeskItem(this.obj) : pos = obj.home;

  final _Obj obj;
  _V pos;

  /// HTML `objectsTested[label]`: null until tested, then Yes / No.
  bool? attracted;

  /// HTML `userData.snapped`: stuck to the magnet.
  bool snapped = false;
  double snapStart = -1;
  _V snapFrom = _V.zero;

  /// Inside the test range during the current approach (one toast per
  /// approach instead of one per pointer move).
  bool inRange = false;
}

// -------------------------------------------- scenario 2: recycling plant

/// Scenario 2 camera: `camera.position.set(0, 10, 25)` looking at the
/// origin; drawn a little right of and below the stage centre so the
/// electromagnet clears the mission card when the sidebar is collapsed.
final _Cam _camPlant = _Cam(
  const _V(0, 10, 25),
  _V.zero,
  const Offset(540, 340),
);

/// Left and right ends (design x, un-panned) of what the learner touches in
/// Scenario 1: the bar magnet's left end at home and the plastic scale's
/// tap point (its centre plus one unit; its far tip may pass under the
/// tool column).
final (double, double) _deskExtent = (
  _camDesk.p(_magnetHome - const _V(2, 0, 0)).dx,
  _camDesk.p(_Obj.scale.home + const _V(1, 0, 0)).dx,
);

/// The same for Scenario 2: the bins and the electromagnet above them.
final (double, double) _plantExtent = (
  math.min(
    _camPlant.p(const _V(-_binX - _binHalf, 0, _binZ + _binHalf)).dx,
    _camPlant.p(const _V(-_binX - 1.6, _emY, 0)).dx,
  ),
  math.max(
    _camPlant.p(const _V(_binX + _binHalf, 0, _binZ + _binHalf)).dx,
    _camPlant.p(const _V(_binX + 1.6, _emY, 0)).dx,
  ),
);

/// `electromagnet.position.set(0, 8, 0)`; dragged along x only (y = 8,
/// z = 0 forced in `onPointerMove`).
const double _emY = 8;

/// Keeps the electromagnet on screen.
const double _emMaxX = 12;

/// Radius of the field-lines sphere (`SphereGeometry(2.5)`), also the
/// grab area (the HTML raycaster hits the invisible sphere too).
const double _fieldRadius = 2.5;

/// `checkInteractions`: xz distance at which a nail is picked up.
const double _pickRange = 3;

/// The field builds up for this long after the electromagnet is switched on
/// before it picks anything up (the HTML only picked up while the pointer
/// moved, never at the moment of the press).
const double _fieldRampSeconds = 0.5;

/// Picked-up items hang this far below the electromagnet and are pulled up
/// with `position.lerp(…, 0.2)` per pointer move (here: per 1/60 s).
const double _hangBelow = 1.5;
const double _pullRate = 0.2;

/// `item.position.x -= 0.05` per frame at 60 fps.
const double _beltSpeed = 3;

/// Items fall off the belt here (`item.position.x < -10`).
const double _beltEndX = -10;

/// The belt is drawn on past the right edge of the stage so items ride in
/// on it (the HTML belt ends at x = 10 and items start up to x = 30).
const double _beltDrawnEndX = 24;
const double _beltTopY = 2.25;
const double _beltHalfZ = 1.5;

/// `mesh.position.set(10 + i * 4, 2.5, 0)` for six items.
const int _itemCount = 6;
const double _firstItemX = 10;
const double _itemSpacing = 4;
const double _itemY = 2.5;

/// A missed nail comes back onto the belt here (just off the right edge).
const double _reentryX = 20;

/// `createBin(color, ∓5)` at z = 5: open boxes 4 wide, 3 high, 4 deep.
const double _binX = 5;
const double _binZ = 5;
const double _binHalf = 2;
const double _binHeight = 3;

/// Height of the bin labels, just under the bins' front edge.
const double _binLabelDrop = -0.9;

/// `dropAttachedItems`: the magnet must be within 2 of a bin's centre
/// (HTML `x < -3 && x > -7`).
const double _binCatch = 2;

/// Step 1 lasts until the first item reaches the middle of the belt.
const double _observeSeconds = _firstItemX / _beltSpeed;

/// Fall of a dropped nail into the green bin and pop-in of a block that
/// reached the red bin.
const double _dropSeconds = 0.5;
const double _popSeconds = 0.3;

/// Scale of the belt's iron nails (`mesh.scale.set(0.8, 0.8, 0.8)`).
const double _beltNailScale = 0.8;

/// One item on the recycling belt.
class _BeltItem {
  _BeltItem({required this.isMagnetic, required this.index, required this.x});

  /// Iron nail (true) or wooden block.
  final bool isMagnetic;
  final int index;
  double x;
  double y = _itemY;
  double z = 0;

  /// HTML `userData.attached`: hanging under the active electromagnet.
  bool attached = false;

  /// HTML `userData.sorted`: resting in a bin.
  bool sorted = false;

  /// Falling into the green bin (start time, or -1).
  double dropStart = -1;
  _V dropFrom = _V.zero;
  _V dropTo = _V.zero;

  /// Time the block popped into the red bin.
  double popStart = -10;

  bool get onBelt => !sorted && !attached && dropStart < 0;
  _V get pos => _V(x, y, z);
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// Scene time when the scenario was loaded.
  double startTime = 0;

  // ------------------------------------------------------------ scenario 1
  _V magnet = _magnetHome;

  /// The bar magnet is held (HTML glow mesh visible).
  bool holdingMagnet = false;

  /// The learner has moved the bar magnet at least once (ends step 1).
  bool magnetMoved = false;
  final List<_DeskItem> desk = [];

  /// Tested objects in the order they were first tested (the rows of the
  /// HTML observation table).
  final List<_DeskItem> tested = [];

  // ------------------------------------------------------------ scenario 2
  double emX = 0;

  /// HTML `appState.magnetActive` (pointer held on the electromagnet).
  bool emActive = false;
  bool everActivated = false;

  /// Scene time the electromagnet was last switched on.
  double activatedAt = -10;
  bool observed = false;

  /// A nail was released over the green bin at least once.
  bool firstDrop = false;
  final List<_BeltItem> belt = [];

  /// HTML `sortedItems.magnetic` / `.nonMagnetic`.
  int magnetic = 0;
  int nonMagnetic = 0;

  /// Bin places handed out so far (green bin, red bin).
  int greenSlots = 0;
  int redSlots = 0;

  /// Distance the belt surface has moved (for its tread lines).
  double beltTravel = 0;

  _DeskItem item(_Obj o) => desk[o.index];
  bool get allTested => desk.every((d) => d.attracted != null);

  bool get carrying => emActive && belt.any((b) => b.attached);

  /// How far the field has built up since switch-on (0 … 1).
  double get fieldStrength =>
      emActive ? ((time - activatedAt) / _fieldRampSeconds).clamp(0.0, 1.0) : 0;
  bool get overGreenBin => (emX + _binX).abs() < _binCatch;
  bool get overRedBin => (emX - _binX).abs() < _binCatch;
  bool get allSorted => belt.isNotEmpty && belt.every((b) => b.sorted);
  int get onBeltCount => belt.where((b) => !b.sorted).length;

  /// HTML `changeScenario(id)`: rebuilds the scene of [index].
  void load(int index, math.Random rnd) {
    scenario = index;
    startTime = time;
    magnet = _magnetHome;
    holdingMagnet = false;
    magnetMoved = false;
    desk
      ..clear()
      ..addAll([for (final o in _Obj.values) _DeskItem(o)]);
    tested.clear();
    emX = 0;
    emActive = false;
    everActivated = false;
    activatedAt = -10;
    observed = false;
    firstDrop = false;
    magnetic = 0;
    nonMagnetic = 0;
    greenSlots = 0;
    redSlots = 0;
    beltTravel = 0;
    belt.clear();
    if (index != 1) return;
    // HTML: `isMag = Math.random() > 0.5` per item. Re-rolled until two to
    // four of the six are nails, so there is always something to pick up
    // and something left for the red bin.
    List<bool> mags;
    do {
      mags = [for (var i = 0; i < _itemCount; i++) rnd.nextDouble() > 0.5];
    } while (mags.where((m) => m).length < 2 ||
        mags.where((m) => m).length > _itemCount - 2);
    for (var i = 0; i < _itemCount; i++) {
      belt.add(
        _BeltItem(
          isMagnetic: mags[i],
          index: i,
          x: _firstItemX + i * _itemSpacing,
        ),
      );
    }
  }
}

/// Resting place number [slot] in the green (nails) or red (blocks) bin.
_V _binSpot(bool green, int slot) {
  if (green) {
    // Nails lie along x, side by side across the bin floor.
    const zs = [-1.2, -0.4, 0.4, 1.2, 0.0];
    return _V(-_binX - 0.15, 0.25, _binZ + zs[slot % zs.length]);
  }
  const spots = [(-0.9, -0.9), (0.9, -0.9), (-0.9, 0.9), (0.9, 0.9), (0, 0)];
  final s = spots[slot % spots.length];
  return _V(_binX + s.$1, 0.5, _binZ + s.$2);
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on the scenario's magnet ([canGrab]), so other drags still pan / zoom
/// the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

/// Distance from [p] to the segment [a]–[b].
double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(
    0.0,
    1.0,
  );
  return (p - (a + ab * t)).distance;
}

class _MagnetLabState
    extends State<Ch4A1IdentifyingMagneticAndNonMagneticMaterialsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// 1-based current step, derived from the scene ([_deriveStep]).
  int _step = 1;

  /// The current scenario's conclusion has been scheduled.
  bool _concluded = false;

  /// Touch radius and label size in design pixels for the current stage
  /// scale (set while laying out the stage).
  double _touch = _touchDp;

  /// Pan of the scene layer in design px (0 while the sidebar is open).
  double _shiftTarget = 0;
  double _labelRight = double.infinity;
  double _labelSize = _labelPx;

  /// Scenario in which the current pointer grabbed its magnet (-1: none).
  int _grabScenario = -1;

  /// HTML `offset`: drag-plane hit minus the object's position at
  /// pointer-down.
  _V _grabOffset = _V.zero;

  /// The held bar magnet has actually been dragged (past the slop).
  bool _moved = false;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive));
    _scene.load(0, _rnd);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    _ticker.dispose();
    _frame.dispose();
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: belt, pick-up and drop motion, then one repaint.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, _maxFrameStep);
    s.time = now;
    if (s.scenario == 0) {
      _tickDesk();
    } else {
      _tickPlant(dt);
    }
    _frame.value = now;
  }

  /// A snapped nail glides onto the magnet's end, then follows it.
  void _tickDesk() {
    final s = _scene;
    for (final d in s.desk) {
      if (!d.snapped) continue;
      final target = s.magnet + _snapOffset;
      final t = ((s.time - d.snapStart) / _snapSeconds).clamp(0.0, 1.0);
      d.pos = t >= 1
          ? target
          : _V.lerp(d.snapFrom, target, Curves.easeOut.transform(t));
    }
  }

  void _tickPlant(double dt) {
    final s = _scene;
    var changed = false;
    s.beltTravel += _beltSpeed * dt;
    if (!s.observed && s.time - s.startTime >= _observeSeconds) {
      s.observed = true;
      changed = true;
    }
    final pull = 1 - math.pow(1 - _pullRate, dt * 60).toDouble();
    for (final b in s.belt) {
      if (b.sorted) continue;
      if (b.dropStart >= 0) {
        final t = ((s.time - b.dropStart) / _dropSeconds).clamp(0.0, 1.0);
        final fall = Curves.easeIn.transform(t);
        b
          ..x = b.dropFrom.x + (b.dropTo.x - b.dropFrom.x) * t
          ..z = b.dropFrom.z + (b.dropTo.z - b.dropFrom.z) * t
          ..y = b.dropFrom.y + (b.dropTo.y - b.dropFrom.y) * fall;
        if (t >= 1) {
          b
            ..dropStart = -1
            ..sorted = true;
          s.magnetic++;
          changed = true;
        }
        continue;
      }
      if (b.attached) {
        // HTML: x, z follow the electromagnet; y is pulled up under it.
        b
          ..x = s.emX
          ..z = 0
          ..y += (_emY - _hangBelow - b.y) * pull;
        continue;
      }
      b.x -= _beltSpeed * dt;
      if (b.x >= _beltEndX) continue;
      if (b.isMagnetic) {
        // A nail nobody picked up goes round again (the HTML dropped it in
        // the red bin and counted it as non-magnetic).
        b.x = _reentryFor(b);
        _lab.showToast(_t('toast_missed'), sound: false);
      } else {
        // HTML: `item.position.set(5, 1, 5); sorted = true; nonMagnetic++`.
        final at = _binSpot(false, s.redSlots++);
        b
          ..x = at.x
          ..y = at.y
          ..z = at.z
          ..sorted = true
          ..popStart = s.time;
        s.nonMagnetic++;
        changed = true;
      }
    }
    if (s.emActive && s.fieldStrength >= 1) {
      // HTML `checkInteractions`: an active magnet picks up nails below it.
      for (final b in s.belt) {
        if (b.isMagnetic && b.onBelt && (b.x - s.emX).abs() < _pickRange) {
          b.attached = true;
          changed = true;
        }
      }
    }
    if (changed || _deriveStep() != _step) _refresh();
  }

  /// Where a missed nail rejoins the belt: off the right edge, behind the
  /// last item still riding in.
  double _reentryFor(_BeltItem nail) {
    var x = _reentryX;
    for (final b in _scene.belt) {
      if (b != nail && b.onBelt) x = math.max(x, b.x + _itemSpacing);
    }
    return x;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(id)`: clears timers and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index, _rnd);
      _step = 1;
      _concluded = false;
      _grabScenario = -1;
      _moved = false;
    });
    _lab.resetView(sound: false);
  }

  /// The HTML step ladder (`updateUI`): each step is done when the learner
  /// has done what it says. Step 1 (look at the desk) needs no action; the
  /// lab moves on as soon as the learner starts moving the bar magnet (the
  /// HTML moved on at the first test, skipping step 2).
  int _deriveStep() {
    final s = _scene;
    if (s.scenario == 0) {
      if (!s.magnetMoved && s.tested.isEmpty) return 1;
      if (s.item(_Obj.nail).attracted == null) return 2;
      if (s.item(_Obj.pencil).attracted == null) return 3;
      if (!s.allTested) return 4;
      return 5;
    }
    if (!s.observed) return 1;
    if (!s.everActivated) return 2;
    if (!s.firstDrop) {
      if (!s.carrying) return 3;
      return s.overGreenBin ? 5 : 4;
    }
    return 6;
  }

  /// Rebuilds after a scene event and schedules the conclusion when the
  /// scenario is done.
  void _refresh() {
    if (!mounted) return;
    setState(() => _step = _deriveStep());
    if (_concluded) return;
    final s = _scene;
    final done = s.scenario == 0 ? _step == 5 : s.allSorted;
    if (!done) return;
    _concluded = true;
    final scenario = s.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _stepCounts.length,
      // HTML `setTimeout(() => validateInvestigation(), 1000)`.
      delay: const Duration(milliseconds: 1000),
      heading: () => _t(scenario == 0 ? 'sum_s1_title' : 'sum_s2_title'),
      body: () => _t(scenario == 0 ? 'sum_s1_desc' : 'sum_s2_desc'),
      extra: scenario == 0
          ? () => Builder(
              builder: (context) => _table(
                _lab.palette,
                context.labScale * _lab.fontScale.clamp(0.9, 1.4),
              ),
            )
          : null,
    );
  }

  // -------------------------------------------------------------- gestures

  bool _onBarMagnet(Offset at) {
    final m = _scene.magnet;
    const half = _V(2.1, 0, 0); // glow box 4.2 long
    final a = _camDesk.p(m - half);
    final b = _camDesk.p(m + half);
    final thick = 0.6 * _camDesk.scaleAt(m);
    return _segmentDistance(at, a, b) <= math.max(thick, _touch);
  }

  bool _onElectromagnet(Offset at) {
    final c = _V(_scene.emX, _emY, 0);
    final reach = math.max(_fieldRadius * _camPlant.scaleAt(c), _touch);
    return (at - _camPlant.p(c)).distance <= reach;
  }

  /// Pan that moves the scene's interactive part (magnet home, bins) clear
  /// of the floating mission card while the sidebar is collapsed, without
  /// pushing its right side under the tool column.
  double _collapsedShift(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return 0;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final card = (size.width * _missionCardFraction).clamp(
      _missionCardMin,
      _missionCardMax * context.labScale,
    );
    final cardRight = (_missionCardLeft + pad.left + card - stageLeft) / fit;
    // The shell's tool column (its right-hand clearance, padding included).
    final tools = labOverlayInsets(context, _lab).right;
    final toolsLeft = (size.width - tools - stageLeft) / fit;
    final (left, right) = _scene.scenario == 0 ? _deskExtent : _plantExtent;
    final room = math.max(0.0, toolsLeft - _cardGap - right);
    return (cardRight + _cardGap - left).clamp(0.0, room);
  }

  /// HTML `onPointerDown` raycast: only the scenario's magnet can be held.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _grabScenario >= 0) return false;
    return _scene.scenario == 0
        ? _onBarMagnet(event.localPosition)
        : _onElectromagnet(event.localPosition);
  }

  /// HTML `onPointerDown` on the magnet: grab offset, glow / activation.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    _grabScenario = s.scenario;
    _moved = false;
    if (s.scenario == 0) {
      final hit = _camDesk.onPlane(d.localPosition, _V.up, _magnetPlaneY);
      _grabOffset = hit == null ? _V.zero : hit - s.magnet;
      setState(() => s.holdingMagnet = true);
    } else {
      final hit = _plantHit(d.localPosition);
      _grabOffset = _V(hit == null ? 0 : hit.x - s.emX, 0, 0);
      _activate();
    }
  }

  /// Ray through [at] on the electromagnet's drag plane z = 0
  /// (`intersectPlane.setComponents(0, 0, 1, 0)`).
  _V? _plantHit(Offset at) => _camPlant.onPlane(at, const _V(0, 0, 1), 0);

  void _onDragStart(DragStartDetails d) {
    if (_grabScenario != _scene.scenario) return;
    _moved = true;
    if (_scene.scenario == 0) {
      _Sound.pickup.play();
      if (!_scene.magnetMoved) {
        _scene.magnetMoved = true;
        _refresh();
      }
    }
  }

  /// HTML `onPointerMove`: the held magnet follows the pointer on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    if (_grabScenario != s.scenario) return;
    if (s.scenario == 0) {
      final hit = _camDesk.onPlane(d.localPosition, _V.up, _magnetPlaneY);
      if (hit == null) return;
      final p = hit - _grabOffset;
      s.magnet = _V(
        p.x.clamp(-_deskHalfX, _deskHalfX),
        math.max(_magnetPlaneY, p.y),
        p.z.clamp(-_deskHalfZ, _deskHalfZ),
      );
      _checkDesk();
    } else {
      final hit = _plantHit(d.localPosition);
      if (hit == null) return;
      s.emX = (hit.x - _grabOffset.x).clamp(-_emMaxX, _emMaxX);
      if (_deriveStep() != _step) _refresh();
    }
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `onPointerUp`.
  void _release() {
    final s = _scene;
    final scenario = _grabScenario;
    _grabScenario = -1;
    if (scenario != s.scenario) return;
    if (scenario == 0) {
      if (_moved) _Sound.drop.play();
      setState(() => s.holdingMagnet = false);
    } else {
      _deactivate();
    }
    _moved = false;
  }

  /// HTML `checkInteractions()` for the bar magnet: each object coming
  /// within range is tested once per approach.
  void _checkDesk() {
    final s = _scene;
    var changed = false;
    for (final d in s.desk) {
      if (d.snapped) continue;
      final near = (s.magnet - d.pos).length < _testRange;
      if (near && !d.inRange) {
        d.inRange = true;
        if (d.attracted == null) s.tested.add(d);
        d.attracted = d.obj.isMagnetic;
        final name = _t(d.obj.key);
        final f = d.obj.isFeminineHi ? '_f' : '';
        if (d.obj.isMagnetic) {
          d
            ..snapped = true
            ..snapFrom = d.pos
            ..snapStart = s.time;
          _lab.showToast('$name ${_t('toast_attract$f')}');
        } else {
          _lab.showToast('$name ${_t('toast_no_attract$f')}', isError: true);
        }
        changed = true;
      } else if (!near && d.inRange) {
        d.inRange = false;
      }
    }
    if (changed) _refresh();
  }

  /// Pointer down on the electromagnet: switched on.
  void _activate() {
    final s = _scene;
    if (s.emActive) return;
    s
      ..emActive = true
      ..everActivated = true
      ..activatedAt = s.time;
    _Sound.pickup.play();
    _lab.showToast(_t('toast_on'), sound: false);
    _refresh();
  }

  /// HTML `onPointerUp` + `dropAttachedItems()`: switched off; the nails it
  /// carried fall into the bin below it, or back onto the belt.
  void _deactivate() {
    final s = _scene;
    if (!s.emActive) return;
    s.emActive = false;
    final carried = [
      for (final b in s.belt)
        if (b.attached) b,
    ];
    final intoGreen = s.overGreenBin;
    for (final b in carried) {
      b.attached = false;
      if (intoGreen) {
        b
          ..dropFrom = b.pos
          ..dropTo = _binSpot(true, s.greenSlots++)
          ..dropStart = s.time;
      } else {
        // HTML: `item.position.y = 2.5; item.position.z = 0`.
        b
          ..y = _itemY
          ..z = 0;
      }
    }
    if (carried.isEmpty) {
      _lab.showToast(_t('toast_off'), isError: true, sound: false);
    } else if (intoGreen) {
      s.firstDrop = true;
      _Sound.drop.play();
      _lab.showToast(_t('toast_sort_mag'));
    } else if (s.overRedBin) {
      _lab.showToast(_t('toast_wrong_bin'), isError: true);
    } else {
      _Sound.drop.play();
      _lab.showToast(_t('toast_off'), isError: true, sound: false);
    }
    _refresh();
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _lab.palette;
        final s = context.labScale;
        final f = s * _lab.fontScale;
        final data = _scenarioData;
        final desk = _scene.scenario == 0;
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.category,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          // HTML `enterLab()` and `resetApp()` (page reload) both start at
          // Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t(desk ? 'obs_table' : 'sort_progress'),
          sidebarExtra: desk ? _table(p, f) : _progress(p, f),
          overlays: [
            // HTML `#results-table-container` (top-right of the canvas, S1).
            // While the sidebar is open the table is in the sidebar.
            if (desk && _lab.isLabActive && !_lab.isSidebarOpen)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _tableCard(p, s),
              ),
          ],
          stage: _stage(),
        );
      },
    );
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / fit;
          _shiftTarget = _lab.isSidebarOpen ? 0 : _collapsedShift(context);
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          _labelRight = (box.maxWidth - tools - stageLeft) / fit - _shiftTarget;
        }
        return LabStage(
          designSize: _design,
          // The pan slides the whole scene layer (painting and hit tests),
          // so gestures arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(_shiftTarget / _design.width, 0),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags and taps on the scene are not screen-reader actions;
                // the scene is announced by its label instead.
                excludeFromSemantics: true,
                gestures: <Type, GestureRecognizerFactory>{
                  _GrabPanRecognizer:
                      GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                        () => _GrabPanRecognizer(debugOwner: this),
                        (r) => r
                          // RawGestureDetector does not apply MediaQuery's
                          // gesture settings; short drags must pick up.
                          ..gestureSettings = const DeviceGestureSettings(
                            touchSlop: _dragSlop,
                          )
                          ..canGrab = _canGrab
                          ..dragStartBehavior = DragStartBehavior.down
                          ..onDown = _onDown
                          ..onStart = _onDragStart
                          ..onUpdate = _onDragUpdate
                          ..onEnd = _onDragEnd
                          ..onCancel = _release,
                      ),
                },
                child: Semantics(
                  image: true,
                  label: _t(
                    _scene.scenario == 0 ? 'scene_desk' : 'scene_plant',
                  ),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: _design,
                      painter: _ScenePainter(
                        scene: _scene,
                        cache: _cache,
                        repaint: _frame,
                        isDark: _lab.isDark,
                        showLabels: _lab.showLabels,
                        lang: _lab.lang,
                        labelSize: _labelSize,
                        labelRight: _labelRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The observation table (sidebar, canvas card and conclusion popup).
  Widget _table(LabPalette p, double scale, {int maxLines = 2}) {
    return _ObsTable(
      rows: [
        for (final d in _scene.tested) (_t(d.obj.key), d.attracted ?? false),
      ],
      palette: p,
      scale: scale,
      objectLabel: _t('tbl_obj'),
      attractedLabel: _t('tbl_attract'),
      yes: _t('yes'),
      no: _t('no'),
      empty: _t('tbl_empty'),
      maxLines: maxLines,
    );
  }

  /// Floating copy of the table on the canvas (sidebar collapsed).
  Widget _tableCard(LabPalette p, double s) {
    return SizedBox(
      width: 176 * s,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(8 * s),
        borderColor: p.accent.withValues(alpha: 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabSectionLabel(
              _t('obs_table'),
              size: 9 * s,
              icon: Icons.table_chart,
            ),
            SizedBox(height: 6 * s),
            _table(p, s * 0.9, maxLines: 1),
          ],
        ),
      ),
    );
  }

  /// Scenario 2 sidebar readout: what is in each bin and what is left.
  Widget _progress(LabPalette p, double f) {
    final s = _scene;
    Widget row(Color dot, String label, int value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 3 * f),
        child: Row(
          children: [
            Container(
              width: 10 * f,
              height: 10 * f,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            SizedBox(width: 8 * f),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 12 * f,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 6 * f),
            Text(
              '$value',
              style: TextStyle(
                color: p.textStrong,
                fontSize: 13 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * f, vertical: 6 * f),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(_Colors.binGreen, _t('lbl_mag_bin'), s.magnetic),
          row(_Colors.binRed, _t('lbl_non_mag_bin'), s.nonMagnetic),
          row(p.textMuted, _t('lbl_on_belt'), s.onBeltCount),
        ],
      ),
    );
  }
}

/// HTML `#results-table-container` table: Object | Attracted? (Yes in
/// green, No in red), one row per tested object in testing order.
class _ObsTable extends StatelessWidget {
  const _ObsTable({
    required this.rows,
    required this.palette,
    required this.scale,
    required this.objectLabel,
    required this.attractedLabel,
    required this.yes,
    required this.no,
    required this.empty,
    this.maxLines = 2,
  });

  final List<(String, bool)> rows;
  final LabPalette palette;
  final double scale;
  final String objectLabel;
  final String attractedLabel;
  final String yes;
  final String no;
  final String empty;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    final head = TextStyle(
      color: p.textMuted,
      fontSize: 10.5 * f,
      fontWeight: FontWeight.w800,
    );
    final body = TextStyle(
      color: p.text,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w600,
    );
    Widget cell(String text, TextStyle style, {bool end = false}) => Text(
      text,
      style: style,
      textAlign: end ? TextAlign.end : TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
    Widget row(Widget a, Widget b, {Color? fill, bool divider = true}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 5 * f),
        decoration: BoxDecoration(
          color: fill,
          border: divider ? Border(top: BorderSide(color: p.cardBorder)) : null,
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: a),
            SizedBox(width: 6 * f),
            Expanded(flex: 2, child: b),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            cell(objectLabel, head),
            cell(attractedLabel, head, end: true),
            fill: p.cardBorder.withValues(alpha: 0.3),
            divider: false,
          ),
          if (rows.isEmpty)
            Padding(
              padding: EdgeInsets.all(8 * f),
              child: Text(
                empty,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: body.copyWith(color: p.textMuted),
              ),
            ),
          for (final (name, attracted) in rows)
            row(
              cell(name, body),
              cell(
                attracted ? yes : no,
                body.copyWith(
                  color: attracted ? p.success : p.danger,
                  fontWeight: FontWeight.w800,
                ),
                end: true,
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Paints and the path reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  /// Thick butt-ended lines (rods, cylinder shading bands).
  final Paint bar = Paint()..style = PaintingStyle.stroke;

  /// Thin round-ended lines (treads, ticks, rims).
  final Paint thin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  /// The bar magnet's glow box while it is held.
  final Paint glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background, grid, desk / belt), the marble's shading and the label text
/// painters. Owned by the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;
  Paint? _marble;

  double get labelSize => _labelSize;

  /// Drops the label painters when the language or label size changes.
  void prepare(LabLang lang, double labelSize) {
    if (lang == _lang && labelSize == _labelSize) return;
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
  }

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _Colors.white,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// The static part of [scenario]'s scene, recorded once.
  ui.Picture backdrop(int scenario, bool dark, Size size) {
    final cached = _backdrop;
    if (cached != null &&
        scenario == _backdropScenario &&
        dark == _backdropDark) {
      return cached;
    }
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), scenario, dark, size, pens);
    _backdropScenario = scenario;
    _backdropDark = dark;
    return _backdrop = recorder.endRecording();
  }

  /// Shading of the glass marble (`SphereGeometry(0.3)`, opacity 0.8); the
  /// marble never moves, so its gradient is made once.
  Paint marble(Offset c, double r) =>
      _marble ??= Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-0.35 * r, -0.4 * r),
          r * 1.35,
          [
            labShade(_Colors.marble, 0.55).withValues(alpha: 0.85),
            _Colors.marble.withValues(alpha: 0.8),
            labShade(_Colors.marble, -0.45).withValues(alpha: 0.85),
          ],
          const [0, 0.5, 1],
        );

  void _disposeLabels() {
    for (final tp in _labels.values) {
      tp.dispose();
    }
    _labels.clear();
  }

  void dispose() {
    _disposeLabels();
    _backdrop?.dispose();
    _backdrop = null;
  }
}

/// One face of a unit box: outward normal and corners (signs of x, y, z).
@immutable
class _Face {
  const _Face(this.normal, this.corners);

  final _V normal;
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

/// MeshStandardMaterial look: ambient light plus the key light's Lambert
/// term on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final i = _ambient + _diffuse * math.max(0.0, n.dot(_light));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Pop-in scale of a block landing in the red bin ([e] seconds after).
double _popScale(double e) {
  if (e < 0) return 0.01;
  if (e >= _popSeconds) return 1;
  return math.max(0.01, Curves.easeOutBack.transform(e / _popSeconds));
}

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  void _move(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Flat-shaded quad (already lit [color]); optional rim [edge] colour.
  void quad(_V a, _V b, _V c, _V d, Color color, {Color? edge}) {
    final path = pens.path..reset();
    final pts = [a, b, c, d];
    for (var i = 0; i < 4; i++) {
      _move(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = 1
          ..color = edge,
      );
    }
  }

  /// BoxGeometry centred at [c]: the faces turned to the camera.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.3,
    Paint? paint,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final n = face.normal;
      final mid = _V(c.x + n.x * hx, c.y + n.y * hy, c.z + n.z * hz);
      if (n.dot(cam.eye - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _move(
          path,
          i,
          cam.p(_V(c.x + k.x * hx, c.y + k.y * hy, c.z + k.z * hz)),
        );
      }
      path.close();
      canvas.drawPath(
        path,
        (paint ?? pens.fill)..color = _lit(color, n, opacity: opacity),
      );
      if (edge > 0) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = labShade(color, -0.5).withValues(alpha: edge * opacity),
        );
      }
    }
  }

  /// Round rod (CylinderGeometry lying along [a]–[b]): body, shaded
  /// underside and highlight.
  void rod(_V a, _V b, double radius, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) return;
    final w = math.max(1.5, 2 * radius * cam.scaleAt((a + b) * 0.5));
    var n = Offset(-d.dy / len, d.dx / len);
    if (n.dy > 0) n = -n; // towards the top of the screen (lit side)
    canvas.drawLine(
      pa,
      pb,
      pens.bar
        ..strokeWidth = w
        ..color = color,
    );
    canvas.drawLine(
      pa - n * (w * 0.32),
      pb - n * (w * 0.32),
      pens.bar
        ..strokeWidth = w * 0.36
        ..color = labShade(color, -0.4),
    );
    canvas.drawLine(
      pa + n * (w * 0.26),
      pb + n * (w * 0.26),
      pens.bar
        ..strokeWidth = w * 0.22
        ..color = labShade(color, 0.45),
    );
  }

  /// ConeGeometry from a base ring of [radius] at [base] to [tip].
  void cone(_V base, _V tip, double radius, Color color) {
    final pb = cam.p(base), pt = cam.p(tip);
    final d = pt - pb;
    final len = d.distance;
    if (len < 0.3) return;
    var n = Offset(-d.dy / len, d.dx / len) * (radius * cam.scaleAt(base));
    if (n.dy > 0) n = -n;
    final path = pens.path
      ..reset()
      ..moveTo(pb.dx + n.dx, pb.dy + n.dy)
      ..lineTo(pt.dx, pt.dy)
      ..lineTo(pb.dx - n.dx, pb.dy - n.dy)
      ..close();
    canvas.drawPath(path, pens.fill..color = labShade(color, -0.2));
    path
      ..reset()
      ..moveTo(pb.dx + n.dx, pb.dy + n.dy)
      ..lineTo(pt.dx, pt.dy)
      ..lineTo(pb.dx, pb.dy)
      ..close();
    canvas.drawPath(path, pens.fill..color = labShade(color, 0.2));
  }

  /// A flat disc of [radius] facing along x (nail head, pencil end).
  void discX(_V c, double radius, Color color, {int sides = 14}) {
    final path = pens.path..reset();
    for (var i = 0; i < sides; i++) {
      final a = i * 2 * math.pi / sides;
      _move(
        path,
        i,
        cam.p(c + _V(0, math.cos(a) * radius, math.sin(a) * radius)),
      );
    }
    path.close();
    final n = _V(cam.eye.x >= c.x ? 1 : -1, 0, 0);
    canvas.drawPath(path, pens.fill..color = _lit(color, n));
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.45),
    );
  }

  /// Half height of the ellipse a horizontal circle of [radius] at [c]
  /// projects to.
  double _ellipseHalf(_V c, double radius) =>
      (cam.p(c + _V(0, 0, radius)).dy - cam.p(c - _V(0, 0, radius)).dy).abs() /
      2;

  /// Upright CylinderGeometry standing on [bottom]: side with shading bands
  /// (and coil [windings]), then the top cap.
  void vCylinder(
    _V bottom,
    double radius,
    double height,
    Color color, {
    bool cap = true,
    int windings = 0,
  }) {
    final top = bottom + _V(0, height, 0);
    final pb = cam.p(bottom), pt = cam.p(top);
    final wb = radius * cam.scaleAt(bottom), wt = radius * cam.scaleAt(top);
    final bottomOval = Rect.fromCenter(
      center: pb,
      width: 2 * wb,
      height: 2 * _ellipseHalf(bottom, radius),
    );
    final topOval = Rect.fromCenter(
      center: pt,
      width: 2 * wt,
      height: 2 * _ellipseHalf(top, radius),
    );
    final path = pens.path
      ..reset()
      ..moveTo(pt.dx - wt, pt.dy)
      ..lineTo(pb.dx - wb, pb.dy)
      ..arcTo(bottomOval, math.pi, -math.pi, false)
      ..lineTo(pt.dx + wt, pt.dy)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
    canvas.drawPath(path, pens.fill..color = color);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(pt.dx - wt * 0.45, pt.dy),
      Offset(pb.dx - wb * 0.45, bottomOval.bottom),
      pens.bar
        ..strokeWidth = wb * 0.32
        ..color = labShade(color, 0.25),
    );
    canvas.drawLine(
      Offset(pt.dx + wt * 0.78, pt.dy),
      Offset(pb.dx + wb * 0.78, bottomOval.bottom),
      pens.bar
        ..strokeWidth = wb * 0.4
        ..color = labShade(color, -0.4),
    );
    for (var i = 1; i <= windings; i++) {
      final y = bottom.y + height * i / (windings + 1);
      final c = _V(bottom.x, y, bottom.z);
      final pc = cam.p(c);
      final w = radius * cam.scaleAt(c);
      canvas.drawArc(
        Rect.fromCenter(
          center: pc,
          width: 2 * w,
          height: 2 * _ellipseHalf(c, radius),
        ),
        0,
        math.pi,
        false,
        pens.stroke
          ..strokeWidth = 1.2
          ..color = labShade(color, -0.35).withValues(alpha: 0.7),
      );
    }
    canvas.restore();
    if (cap) {
      canvas.drawOval(topOval, pens.fill..color = labShade(color, 0.18));
      canvas.drawOval(
        topOval,
        pens.stroke
          ..strokeWidth = 1
          ..color = labShade(color, -0.35),
      );
    }
  }

  /// Soft blurred shadow of a footprint (centre, half sizes) on y = 0.
  void shadow(double x, double z, double halfX, double halfZ, {double y = 0}) {
    final path = pens.path..reset();
    final pts = [
      _V(x - halfX, y, z - halfZ),
      _V(x + halfX, y, z - halfZ),
      _V(x + halfX, y, z + halfZ),
      _V(x - halfX, y, z + halfZ),
    ];
    for (var i = 0; i < 4; i++) {
      _move(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }

  /// HTML field lines: wireframe SphereGeometry(2.5), indigo, translucent;
  /// they grow and brighten while the field builds up ([strength] 0 … 1).
  void fieldSphere(_V c, double radius, double strength) {
    final o = cam.p(c);
    final r = radius * cam.scaleAt(c) * (0.6 + 0.4 * strength);
    canvas.drawCircle(
      o,
      r,
      pens.fill..color = _Colors.field.withValues(alpha: 0.08 * strength),
    );
    final line = pens.stroke
      ..strokeWidth = 1.2
      ..color = _Colors.field.withValues(alpha: 0.2 + 0.3 * strength);
    canvas.drawCircle(o, r, line);
    for (final k in const [0.35, 0.72]) {
      canvas.drawOval(
        Rect.fromCenter(center: o, width: 2 * r * k, height: 2 * r),
        line,
      );
    }
    for (final k in const [-0.6, 0.0, 0.6]) {
      final w = 2 * r * math.sqrt(1 - k * k);
      canvas.drawOval(
        Rect.fromCenter(
          center: o + Offset(0, -k * r),
          width: w,
          height: w * 0.3,
        ),
        line,
      );
    }
  }
}

/// The scene's static layer: background, grid, and the desk (S1) or the
/// conveyor belt (S2).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  Size size,
  _Pens pens,
) {
  final bleed = labBleed(size);
  canvas.drawRect(bleed, pens.fill..color = _Colors.sceneBg);
  if (dark) {
    // `.canvas-grid`: 50 px lines, white / 3 % (invisible in light mode).
    const step = 50.0;
    final grid = pens.thin
      ..strokeWidth = 1
      ..color = _Colors.grid;
    for (
      var x = (bleed.left / step).floor() * step;
      x < bleed.right;
      x += step
    ) {
      canvas.drawLine(Offset(x, bleed.top), Offset(x, bleed.bottom), grid);
    }
    for (
      var y = (bleed.top / step).floor() * step;
      y < bleed.bottom;
      y += step
    ) {
      canvas.drawLine(Offset(bleed.left, y), Offset(bleed.right, y), grid);
    }
  }
  final g = _Gfx(canvas, scenario == 0 ? _camDesk : _camPlant, pens);
  if (scenario == 0) {
    // `new THREE.BoxGeometry(20, 1, 15)` desk at y = -0.5, with a faint grain.
    g.box(const _V(0, -0.5, 0), const _V(20, 1, 15), _Colors.desk, edge: 0.5);
    final grain = pens.thin
      ..strokeWidth = 1
      ..color = labShade(_Colors.desk, -0.35).withValues(alpha: 0.3);
    for (var z = -7.1; z < 7.5; z += 0.7) {
      final wobble = math.sin(z * 2.7) * 0.12;
      canvas.drawLine(
        g.cam.p(_V(-9.9, 0.002, z)),
        g.cam.p(_V(9.9, 0.002, z + wobble)),
        grain,
      );
    }
    return;
  }
  // `new THREE.BoxGeometry(20, 0.5, 3)` belt at (0, 2, 0), drawn on to the
  // right edge.
  g.box(
    const _V((_beltEndX + _beltDrawnEndX) / 2, _beltTopY - 0.25, 0),
    const _V(_beltDrawnEndX - _beltEndX, 0.5, 2 * _beltHalfZ),
    _Colors.belt,
    edge: 0,
  );
  final edge = pens.thin
    ..strokeWidth = 1.2
    ..color = _Colors.beltEdge;
  for (final e in const [
    (
      _V(_beltEndX, _beltTopY, _beltHalfZ),
      _V(_beltDrawnEndX, _beltTopY, _beltHalfZ),
    ),
    (
      _V(_beltEndX, _beltTopY, -_beltHalfZ),
      _V(_beltDrawnEndX, _beltTopY, -_beltHalfZ),
    ),
    (
      _V(_beltEndX, _beltTopY - 0.5, _beltHalfZ),
      _V(_beltDrawnEndX, _beltTopY - 0.5, _beltHalfZ),
    ),
    (
      _V(_beltEndX, _beltTopY, -_beltHalfZ),
      _V(_beltEndX, _beltTopY, _beltHalfZ),
    ),
    (
      _V(_beltEndX, _beltTopY, _beltHalfZ),
      _V(_beltEndX, _beltTopY - 0.5, _beltHalfZ),
    ),
  ]) {
    canvas.drawLine(g.cam.p(e.$1), g.cam.p(e.$2), edge);
  }
}

/// Paints the HTML Three.js scene of the current scenario: S1 the
/// scientist's desk with the bar magnet, S2 the recycling belt with the
/// electromagnet and the two bins. Static parts come from [_PaintCache].
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  /// Design x of the tool column's left edge (scene labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    if (scene.scenario == 0) {
      _paintDesk(canvas);
    } else {
      _paintPlant(canvas);
    }
  }

  // ---------------------------------------------------------- scenario 1

  void _paintDesk(Canvas canvas) {
    final g = _Gfx(canvas, _camDesk, _pens);
    final s = scene;

    // Contact shadows; the key light at (10, 20, 10) casts them towards
    // -x / -z by half the object's height.
    for (final d in s.desk) {
      if (d.snapped) continue;
      final lift = (d.pos.y + d.obj.halfThickness) * 0.5;
      g.shadow(
        d.pos.x - lift,
        d.pos.z - lift,
        d.obj.halfLength + 0.05,
        d.obj.halfThickness + 0.05,
        y: 0.002,
      );
    }
    g.shadow(s.magnet.x - 0.3, s.magnet.z - 0.3, 2.1, 0.6, y: 0.002);

    // Bodies, far to near; a snapped nail is drawn with the magnet.
    final order = <_DeskItem?>[
      for (final d in s.desk)
        if (!d.snapped) d,
      null, // the bar magnet
    ];
    double depth(_DeskItem? d) => _camDesk.depth(d?.pos ?? s.magnet);
    order.sort((a, b) => depth(b).compareTo(depth(a)));
    for (final d in order) {
      if (d != null) {
        _paintObject(g, d);
        continue;
      }
      _paintBarMagnet(g);
      for (final n in s.desk) {
        if (n.snapped) _paintObject(g, n);
      }
    }

    if (!showLabels) return;
    for (final d in s.desk) {
      if (d.obj == _Obj.marble) {
        // The marble is nearest the camera: a label above it would sit on
        // the eraser and its label, so it goes beside the marble instead.
        _chip(
          canvas,
          _camDesk.p(d.pos + const _V(0.45, 0, 0)),
          _t(d.obj.key),
          edge: -1,
        );
        continue;
      }
      _chip(canvas, _camDesk.p(d.pos + _V.up), _t(d.obj.key));
    }
  }

  void _paintObject(_Gfx g, _DeskItem d) {
    final p = d.pos;
    switch (d.obj) {
      case _Obj.nail:
        _paintNail(g, p, 1);
      case _Obj.pencil:
        _paintPencil(g, p);
      case _Obj.eraser:
        // BoxGeometry(1.5, 0.5, 0.8), #f472b6.
        g.box(p, const _V(1.5, 0.5, 0.8), _Colors.eraser, edge: 0.25);
      case _Obj.scale:
        // BoxGeometry(4, 0.1, 0.5), #93c5fd, opacity 0.6, with mm ticks.
        g.box(p, const _V(4, 0.1, 0.5), _Colors.scale, opacity: 0.6, edge: 0.5);
        final tick = _pens.thin
          ..strokeWidth = 1
          ..color = _Colors.slate700.withValues(alpha: 0.75);
        for (var i = 0; i <= 20; i++) {
          final x = p.x - 1.9 + i * 0.19;
          final len = i % 5 == 0 ? 0.22 : 0.12;
          g.canvas.drawLine(
            g.cam.p(_V(x, p.y + 0.051, p.z + 0.24)),
            g.cam.p(_V(x, p.y + 0.051, p.z + 0.24 - len)),
            tick,
          );
        }
      case _Obj.marble:
        // SphereGeometry(0.3), #10b981, opacity 0.8.
        final c = g.cam.p(p);
        final r = 0.3 * g.cam.scaleAt(p);
        g.canvas.drawCircle(c, r, cache.marble(c, r));
        g.canvas.drawCircle(
          c + Offset(-0.35 * r, -0.4 * r),
          r * 0.22,
          _pens.fill..color = _Colors.white.withValues(alpha: 0.7),
        );
    }
  }

  /// `createIronNail()` (scaled by [k]): body r 0.1 x 2, head r 0.3 at -1,
  /// point cone r 0.1 x 0.4 at the +x end; #888888.
  void _paintNail(_Gfx g, _V p, double k) {
    final head = p + _V(-1 * k, 0, 0);
    final end = p + _V(1 * k, 0, 0);
    // The head hides the body only when it is the end nearer the camera.
    final headBehind = g.cam.eye.x > head.x;
    if (headBehind) g.discX(head, 0.3 * k, _Colors.iron);
    g.rod(head, end, 0.1 * k, _Colors.iron);
    g.cone(end, p + _V(1.4 * k, 0, 0), 0.1 * k, _Colors.iron);
    if (!headBehind) g.discX(head, 0.3 * k, _Colors.iron);
  }

  /// `createPencil()`: yellow hexagonal body r 0.15 x 2, sharpened wood
  /// cone and graphite tip at the +x end.
  void _paintPencil(_Gfx g, _V p) {
    final back = p + const _V(-1, 0, 0);
    final front = p + const _V(1, 0, 0);
    final capBehind = g.cam.eye.x > back.x;
    final cap = labShade(_Colors.pencilYellow, -0.1);
    if (capBehind) g.discX(back, 0.15, cap, sides: 6);
    g.rod(back, front, 0.15, _Colors.pencilYellow);
    g.cone(front, p + const _V(1.5, 0, 0), 0.15, _Colors.pencilWood);
    g.cone(
      p + const _V(1.35, 0, 0),
      p + const _V(1.55, 0, 0),
      0.05,
      _Colors.graphite,
    );
    if (!capBehind) g.discX(back, 0.15, cap, sides: 6);
  }

  /// `createBarMagnet()`: red half (x -2..0) and blue half (0..2), each
  /// 2 x 1 x 1; the indigo glow box (4.2 x 1.2 x 1.2) while it is held.
  void _paintBarMagnet(_Gfx g) {
    final m = scene.magnet;
    if (scene.holdingMagnet) {
      g.box(
        m,
        const _V(4.2, 1.2, 1.2),
        _Colors.field,
        opacity: 0.45,
        edge: 0,
        paint: _pens.glow,
      );
    }
    final red = m + const _V(-1, 0, 0);
    final blue = m + const _V(1, 0, 0);
    const half = _V(2, 1, 1);
    // The half farther from the camera first.
    if ((red.x - g.cam.eye.x).abs() > (blue.x - g.cam.eye.x).abs()) {
      g.box(red, half, _Colors.magnetRed, edge: 0.45);
      g.box(blue, half, _Colors.magnetBlue, edge: 0.45);
    } else {
      g.box(blue, half, _Colors.magnetBlue, edge: 0.45);
      g.box(red, half, _Colors.magnetRed, edge: 0.45);
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintPlant(Canvas canvas) {
    final g = _Gfx(canvas, _camPlant, _pens);
    final s = scene;

    // Tread lines moving with the belt surface.
    const gap = 1.25;
    final tread = _pens.thin
      ..strokeWidth = 1.2
      ..color = _Colors.tread;
    for (var x = _beltDrawnEndX - s.beltTravel % gap; x > _beltEndX; x -= gap) {
      canvas.drawLine(
        g.cam.p(_V(x, _beltTopY + 0.002, -_beltHalfZ + 0.1)),
        g.cam.p(_V(x, _beltTopY + 0.002, _beltHalfZ - 0.1)),
        tread,
      );
    }

    for (final b in s.belt) {
      if (b.onBelt) _paintBeltItem(g, b, 1);
    }
    _paintBinBack(g, -_binX, _Colors.binGreen);
    _paintBinBack(g, _binX, _Colors.binRed);
    for (final b in s.belt) {
      if (b.sorted || b.dropStart >= 0) {
        _paintBeltItem(g, b, b.isMagnetic ? 1 : _popScale(s.time - b.popStart));
      }
    }
    _paintBinFront(g, -_binX, _Colors.binGreen);
    _paintBinFront(g, _binX, _Colors.binRed);

    for (final b in s.belt) {
      if (b.attached) _paintBeltItem(g, b, 1);
    }
    _paintElectromagnet(g);
    if (s.emActive) {
      g.fieldSphere(_V(s.emX, _emY, 0), _fieldRadius, s.fieldStrength);
    }

    if (!showLabels) return;
    // Beside the coil, on the side towards the middle of the scene: above
    // the electromagnet the label sat under the toasts at the top.
    final emLeft = s.emX < 0;
    _chip(
      canvas,
      g.cam.p(_V(s.emX + (emLeft ? 1.9 : -1.9), _emY - 0.4, 0)),
      _t('lbl_electromagnet'),
      edge: emLeft ? -1 : 1,
    );
    // The HTML puts the bin labels inside the bins (y = 1), where they hide
    // the sorted items; here they sit just under each bin's front edge.
    _chip(canvas, g.cam.p(_binLabelAt(-_binX)), _t('lbl_mag_bin'));
    _chip(canvas, g.cam.p(_binLabelAt(_binX)), _t('lbl_non_mag_bin'));
    for (final b in s.belt) {
      if (!b.onBelt) continue;
      // Smaller chips, every other one higher, so neighbours stay apart.
      final lift = b.index.isOdd ? 2.4 : 1.0;
      _chip(
        canvas,
        g.cam.p(b.pos + _V(0, lift, 0)),
        _t(b.isMagnetic ? 'item_nail' : 'item_wood_block'),
        scale: 0.85,
        // Items riding in under the tool column get their label once they
        // are clear of it.
        maxRight: labelRight,
      );
    }
  }

  static _V _binLabelAt(double cx) => _V(cx, _binLabelDrop, _binZ + _binHalf);

  /// A belt item at its position: iron nail (scale 0.8) or wooden block
  /// (`BoxGeometry(1, 1, 1)`, #8b4513), scaled by [k].
  void _paintBeltItem(_Gfx g, _BeltItem b, double k) {
    if (b.isMagnetic) {
      _paintNail(g, b.pos, _beltNailScale * k);
      return;
    }
    final p = b.pos;
    g.box(p, _V(k, k, k), _Colors.woodBlock, edge: 0.45);
    final grain = _pens.thin
      ..strokeWidth = 1
      ..color = labShade(_Colors.woodBlock, -0.4).withValues(alpha: 0.6);
    for (final y in const [-0.2, 0.15]) {
      g.canvas.drawLine(
        g.cam.p(p + _V(-0.42 * k, y * k, 0.5 * k)),
        g.cam.p(p + _V(0.42 * k, (y + 0.05) * k, 0.5 * k)),
        grain,
      );
    }
  }

  /// `createBin(color, x)`: floor, back wall and the far side wall (opacity
  /// 0.8, double-sided).
  void _paintBinBack(_Gfx g, double cx, Color color) {
    const z0 = _binZ - _binHalf, z1 = _binZ + _binHalf, h = _binHeight;
    final x0 = cx - _binHalf, x1 = cx + _binHalf;
    final edge = labShade(color, 0.3).withValues(alpha: 0.6);
    g.quad(
      _V(x0, 0, z0),
      _V(x1, 0, z0),
      _V(x1, 0, z1),
      _V(x0, 0, z1),
      _lit(color, _V.up, opacity: 0.8),
    );
    g.quad(
      _V(x0, 0, z0),
      _V(x1, 0, z0),
      _V(x1, h, z0),
      _V(x0, h, z0),
      _lit(color, const _V(0, 0, 1), opacity: 0.8),
      edge: edge,
    );
    final far = (x0 - g.cam.eye.x).abs() > (x1 - g.cam.eye.x).abs() ? x0 : x1;
    _binSide(g, far, color, edge);
  }

  /// The near side wall and the front wall, drawn over the bin's contents
  /// and lighter than the HTML's 0.8 so the sorted items show through.
  void _paintBinFront(_Gfx g, double cx, Color color) {
    const z1 = _binZ + _binHalf, h = _binHeight;
    final x0 = cx - _binHalf, x1 = cx + _binHalf;
    final edge = labShade(color, 0.3).withValues(alpha: 0.6);
    final near = (x0 - g.cam.eye.x).abs() > (x1 - g.cam.eye.x).abs() ? x1 : x0;
    _binSide(g, near, color, edge, opacity: 0.5);
    g.quad(
      _V(x0, 0, z1),
      _V(x1, 0, z1),
      _V(x1, h, z1),
      _V(x0, h, z1),
      _lit(color, const _V(0, 0, 1), opacity: 0.3),
      edge: edge,
    );
  }

  void _binSide(
    _Gfx g,
    double x,
    Color color,
    Color edge, {
    double opacity = 0.8,
  }) {
    const z0 = _binZ - _binHalf, z1 = _binZ + _binHalf, h = _binHeight;
    g.quad(
      _V(x, 0, z0),
      _V(x, 0, z1),
      _V(x, h, z1),
      _V(x, h, z0),
      _lit(color, _V(g.cam.eye.x > x ? 1 : -1, 0, 0), opacity: opacity),
      edge: edge,
    );
  }

  /// The electromagnet group: iron core `CylinderGeometry(1.5, 1.5, 2)`
  /// (#333333) inside the copper coil `CylinderGeometry(1.6, 1.6, 1.8)`
  /// (#b87333), centred at (x, 8, 0).
  void _paintElectromagnet(_Gfx g) {
    final x = scene.emX;
    g.vCylinder(_V(x, _emY - 1, 0), 1.5, 2, _Colors.emCore, cap: false);
    g.vCylinder(_V(x, _emY - 0.9, 0), 1.6, 1.8, _Colors.copper, windings: 7);
    final top = _V(x, _emY + 1, 0);
    final c = g.cam.p(top);
    final w = 1.5 * g.cam.scaleAt(top);
    final h = g._ellipseHalf(top, 1.5);
    final cap = Rect.fromCenter(center: c, width: 2 * w, height: 2 * h);
    g.canvas.drawOval(cap, _pens.fill..color = labShade(_Colors.emCore, 0.12));
    g.canvas.drawOval(
      cap,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = labShade(_Colors.emCore, 0.45),
    );
  }

  // ------------------------------------------------------------ labels

  /// HTML `.html-label`: dark chip with white bold text centred on [at].
  /// A label chip centred on [at]; with [edge] -1 its left edge sits on
  /// [at], with 1 its right edge. A chip that would reach past [maxRight]
  /// is not drawn.
  void _chip(
    Canvas canvas,
    Offset at,
    String text, {
    Color? border,
    double scale = 1,
    double edge = 0,
    double maxRight = double.infinity,
  }) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    if (at.dx + (1 - edge) * w / 2 * scale > maxRight) return;
    if (scale != 1) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.scale(scale);
      canvas.translate(-at.dx, -at.dy);
    }
    final rect = Rect.fromCenter(
      center: at.translate(-edge * w / 2, 0),
      width: w,
      height: tp.height + 2 * padY,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.35));
    canvas.drawRRect(rr, _pens.fill..color = _Colors.labelBg);
    if (border != null) {
      canvas.drawRRect(
        rr,
        _pens.stroke
          ..strokeWidth = 1.5
          ..color = border,
      );
    }
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
    if (scale != 1) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.isDark != isDark ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelSize != labelSize ||
      old.labelRight != labelRight;
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
