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

/// Class 6 Science • Chapter 4 • Activity 2
/// Exploring Magnetic Poles and Their Properties.
///
/// Native Flutter port of
/// `Cl6S-Ch4-A2-Exploring_Magnetic_Poles_and_Their_Properties.html`.
///
/// Scenario 1 (Visualizing Magnetic Poles): move the iron-filings shaker over
/// the white paper until it is evenly sprinkled, drop the bar magnet in the
/// middle and watch the filings rush to its two ends; "Observe Poles" zooms in
/// and labels the North and South poles.
///
/// Scenario 2 (Attraction and Repulsion): Magnet A rests on pencil rollers.
/// Drag Magnet B towards it for the four pole pairs (S–N, N–N, N–S, S–S):
/// unlike poles pull Magnet A closer, like poles push it away.
class Ch4A2ExploringMagneticPolesAndTheirPropertiesPage extends StatefulWidget {
  const Ch4A2ExploringMagneticPolesAndTheirPropertiesPage({super.key});

  @override
  State<Ch4A2ExploringMagneticPolesAndTheirPropertiesPage> createState() =>
      _Ch4A2ExploringMagneticPolesAndTheirPropertiesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`. The HTML has no sounds of its own, so the lab
/// uses the shell tones plus pickup / drop for the drags.
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

  /// Correct action (feedback toasts).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action: the magnet missed the paper and goes back to the tray.
  wrong('audio/class6/science/error.mp3'),

  /// Scenario completed / success popup.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// An object is put down (magnet on the paper, shaker, Magnet B).
  drop('audio/class6/science/drop.mp3'),

  /// An object is picked up (shaker, bar magnet, Magnet B).
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

/// Tailwind colours used by the HTML (UI and Three.js materials).
abstract final class _Colors {
  /// ZSL yellow: the HTML "Enter Lab" button (`bg-[#eab308] text-slate-900`).
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1); // tailwind `primary`
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color red500 = Color(0xFFEF4444); // magnet N half
  static const Color blue500 = Color(0xFF3B82F6); // magnet S half
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color emerald500 = Color(0xFF10B981); // attraction lines
  static const Color orange500 = Color(0xFFF97316); // repulsion lines
  static const Color cyan500 = Color(0xFF06B6D4); // shaker body
  static const Color yellow400 = Color(0xFFFACC15); // pencil rollers
  static const Color slate50 = Color(0xFFF8FAFC); // white paper
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

  /// Scene label chip (`bg-slate-900/85`).
  static const Color labelBg = Color(0xD90F172A);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xD90F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts. The
/// HTML canvas (`#canvas-wrapper`, bg `#0f172a`) stays dark in both themes.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A), // sidebar dark:bg-slate-900/95
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate900,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    // Tailwind `primary` indigo; the HTML buttons are bg-indigo-600.
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400, // completed steps (dark:text-green-400)
    popupBg: _Colors.slate800,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2F8FAFC), // sidebar bg-slate-50/95
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate900,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green600, // completed steps (text-green-600)
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
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting (px): HTML default 15 px; its slider goes to 32 px, the
/// shell caps it at 24 px so the narrow sidebar never overflows.
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
// Copied from the HTML `i18n` table (Telugu dropped). The step texts lose
// their "1. " numbering (the shell numbers the steps). Changes: step 1.1 says
// to keep moving the shaker until the paper is evenly sprinkled; the S2 steps
// name the 'Reset / Next Combination' button exactly and write the poles as
// (N) / (S). The short HUD texts (sN_hud_M) go to the canvas HUD only.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Exploring Magnetic Poles and Their Properties',
    'app_subtitle': 'Class 6 • Exploring Magnets',
    'scen_1_opt': 'Scenario 1: Visualizing Magnetic Poles',
    'scen_2_opt': 'Scenario 2: Attraction and Repulsion',
    's1_desc':
        "To discover that a magnet's attractive force is concentrated at its ends, known as poles. Based on Activity 4.2.",
    's2_desc':
        'To demonstrate the fundamental laws of magnetic interaction: like poles repel and unlike poles attract. Based on Activity 4.5.',
    'step_1_1':
        'DRAG the shaker of iron filings and keep MOVING it over the white paper sheet until the filings are sprinkled evenly.',
    'step_1_2':
        'DRAG the bar magnet from the toolbox and DROP it onto the center of the sprinkled paper.',
    'step_1_3':
        "CLICK 'Observe Poles' button to zoom in and observe where filings cling most densely.",
    'step_2_1':
        'DRAG Magnet B so its North pole (N) approaches the South pole (S) of Magnet A on rollers.',
    'step_2_2':
        "CLICK 'Reset / Next Combination'. DRAG Magnet B North pole (N) towards North pole (N) of Magnet A.",
    'step_2_3':
        "CLICK 'Reset / Next Combination'. DRAG Magnet B South pole (S) towards North pole (N) of Magnet A.",
    'step_2_4':
        "CLICK 'Reset / Next Combination'. DRAG Magnet B South pole (S) towards South pole (S) of Magnet A.",
    's1_hud_1':
        'DRAG the iron filings shaker over the white paper to sprinkle filings.',
    's1_hud_2': 'DRAG the bar magnet and DROP it onto the center of the paper.',
    's1_hud_3':
        "CLICK 'Observe Poles' to highlight the areas with strongest force.",
    's2_hud_1': 'DRAG Magnet B North pole near South pole of Magnet A.',
    's2_hud_2': 'DRAG Magnet B North pole near North pole of Magnet A.',
    's2_hud_3': 'DRAG Magnet B South pole near North pole of Magnet A.',
    's2_hud_4': 'DRAG Magnet B South pole near South pole of Magnet A.',
    'btn_validate': 'Validate Investigation',
    'err_test_all':
        'Please complete all investigation steps before validating.',
    'btn_observe_poles': 'Observe Poles',
    'btn_next_combo': 'Reset / Next Combination',
    'toast_sprinkled': 'Paper sprinkled evenly with iron filings!',
    'toast_dropped': 'Iron filings clustered densely at the magnet ends!',
    'toast_observed': 'Magnetic force is strongest at the poles!',
    'toast_attract': 'Unlike poles attract! Magnet A rolls closer.',
    'toast_repel': 'Like poles repel! Magnet A rolls away.',
    'obs_table': 'Observation Table',
    'tbl_part': 'Magnet Part',
    'tbl_conc': 'Filings Density',
    'part_ends': 'Ends (Poles)',
    'part_mid': 'Middle Part',
    'conc_high': 'High (Dense Clumps)',
    'conc_low': 'Very Low / None',
    'tbl_combo': 'Poles Near',
    'tbl_inter': 'Interaction',
    'combo_1': 'South - North',
    'combo_2': 'North - North',
    'combo_3': 'North - South',
    'combo_4': 'South - South',
    'inter_attract': 'Attraction',
    'inter_repel': 'Repulsion',
    'pending': 'Testing...',
    'sum_s1_title': 'Magnetic Poles Discovered!',
    'sum_s1_desc':
        'Iron filings cluster densely at the two ends of the magnet where the magnetic force is strongest. These ends are called North and South poles.',
    'sum_s2_title': 'Law of Magnetism Verified!',
    'sum_s2_desc':
        'Unlike poles (N-S) attract each other. Like poles (N-N, S-S) repel each other. This interaction drives electric motors and Maglev trains!',
    'lbl_shaker': 'Iron Filings Shaker',
    'lbl_paper': 'White Paper Sheet',
    'lbl_magnet': 'Bar Magnet',
    'lbl_north_pole': 'North Pole (N)',
    'lbl_south_pole': 'South Pole (S)',
    'lbl_magnet_a': 'Magnet A (On Rollers)',
    'lbl_magnet_b': 'Magnet B (Draggable)',
    'lbl_rollers': 'Pencil Rollers',
    // Pole letters painted on the magnet faces (HTML canvas textures).
    'pole_n': 'N',
    'pole_s': 'S',
  },
  'hi': {
    'app_title': 'चुंबकीय ध्रुवों और उनके गुणों की खोज',
    'app_subtitle': 'कक्षा 6 • चुंबकों की खोज',
    'scen_1_opt': 'परिदृश्य 1: चुंबकीय ध्रुवों का दृश्य',
    'scen_2_opt': 'परिदृश्य 2: आकर्षण और प्रतिकर्षण',
    's1_desc':
        'यह जानना कि चुंबक का आकर्षण बल उसके सिरों पर केंद्रित होता है, जिन्हें ध्रुव कहा जाता है।',
    's2_desc':
        'दो चुंबकों के बीच आकर्षण और प्रतिकर्षण के नियम को प्रदर्शित करना: समान ध्रुव प्रतिकर्षित करते हैं और विपरीत ध्रुव आकर्षित करते हैं।',
    'step_1_1':
        'लोहे के चूर्ण के शेकर को खींचें और सफेद कागज पर तब तक घुमाते रहें जब तक चूर्ण समान रूप से न छिड़क जाए।',
    'step_1_2':
        'टूलबॉक्स से छड़ चुंबक को खींचें और चूर्ण से ढके कागज के केंद्र में छोड़ें।',
    'step_1_3':
        "ज़ूम इन करने और ध्रुवों का निरीक्षण करने के लिए 'ध्रुवों का निरीक्षण करें' बटन पर क्लिक करें।",
    'step_2_1':
        'चुंबक B के उत्तरी ध्रुव (N) को खींचकर रोलर्स पर रखे चुंबक A के दक्षिणी ध्रुव (S) के पास लाएं।',
    'step_2_2':
        "'रीसेट / अगला संयोजन' पर क्लिक करें। चुंबक B के उत्तरी ध्रुव (N) को खींचकर चुंबक A के उत्तरी ध्रुव (N) के पास लाएं।",
    'step_2_3':
        "'रीसेट / अगला संयोजन' पर क्लिक करें। चुंबक B के दक्षिणी ध्रुव (S) को खींचकर चुंबक A के उत्तरी ध्रुव (N) के पास लाएं।",
    'step_2_4':
        "'रीसेट / अगला संयोजन' पर क्लिक करें। चुंबक B के दक्षिणी ध्रुव (S) को खींचकर चुंबक A के दक्षिणी ध्रुव (S) के पास लाएं।",
    's1_hud_1': 'लोहे का चूर्ण छिड़कने के लिए शेकर को सफेद कागज पर घुमाएं।',
    's1_hud_2': 'छड़ चुंबक को खींचकर कागज के केंद्र में छोड़ें।',
    's1_hud_3':
        "सबसे मजबूत बल वाले क्षेत्रों को देखने के लिए 'ध्रुवों का निरीक्षण करें' पर क्लिक करें।",
    's2_hud_1':
        'चुंबक B के उत्तरी ध्रुव को चुंबक A के दक्षिणी ध्रुव के पास खींचें।',
    's2_hud_2':
        'चुंबक B के उत्तरी ध्रुव को चुंबक A के उत्तरी ध्रुव के पास खींचें।',
    's2_hud_3':
        'चुंबक B के दक्षिणी ध्रुव को चुंबक A के उत्तरी ध्रुव के पास खींचें।',
    's2_hud_4':
        'चुंबक B के दक्षिणी ध्रुव को चुंबक A के दक्षिणी ध्रुव के पास खींचें।',
    'btn_validate': 'जांच की पुष्टि करें',
    'err_test_all': 'कृपया मान्य करने से पहले सभी चरण पूरे करें।',
    'btn_observe_poles': 'ध्रुवों का निरीक्षण करें',
    'btn_next_combo': 'रीसेट / अगला संयोजन',
    'toast_sprinkled': 'कागज पर लोहे का चूर्ण समान रूप से छिड़क दिया गया!',
    'toast_dropped': 'लोहे के कण चुंबक के सिरों पर घने रूप से चिपक गए!',
    'toast_observed': 'चुंबकीय बल ध्रुवों पर सबसे अधिक होता है!',
    'toast_attract': 'विपरीत ध्रुव आकर्षित करते हैं! चुंबक A पास आता है।',
    'toast_repel': 'समान ध्रुव प्रतिकर्षित करते हैं! चुंबक A दूर जाता है।',
    'obs_table': 'अवलोकन तालिका',
    'tbl_part': 'चुंबक का भाग',
    'tbl_conc': 'कणों का घनत्व',
    'part_ends': 'सिरे (ध्रुव)',
    'part_mid': 'मध्य भाग',
    'conc_high': 'अधिक (घने गुच्छे)',
    'conc_low': 'बहुत कम / कुछ नहीं',
    'tbl_combo': 'पास लाए गए ध्रुव',
    'tbl_inter': 'परस्पर क्रिया',
    'combo_1': 'दक्षिण - उत्तर',
    'combo_2': 'उत्तर - उत्तर',
    'combo_3': 'उत्तर - दक्षिण',
    'combo_4': 'दक्षिण - दक्षिण',
    'inter_attract': 'आकर्षण',
    'inter_repel': 'प्रतिकर्षण',
    'pending': 'परीक्षण जारी...',
    'sum_s1_title': 'चुंबकीय ध्रुवों की खोज हुई!',
    'sum_s1_desc':
        'लोहे के कण चुंबक के दोनों सिरों पर घने रूप से चिपकते हैं जहाँ बल सबसे अधिक होता है। इन्हें उत्तरी और दक्षिणी ध्रुव कहते हैं।',
    'sum_s2_title': 'चुंबकत्व का नियम सत्यापित!',
    'sum_s2_desc':
        'विपरीत ध्रुव आकर्षित करते हैं और समान ध्रुव प्रतिकर्षित करते हैं। यह नियम मोटरों और मैगलेव ट्रेनों में काम आता है!',
    'lbl_shaker': 'लोहे के चूर्ण का शेकर',
    'lbl_paper': 'सफेद कागज की शीट',
    'lbl_magnet': 'छड़ चुंबक',
    'lbl_north_pole': 'उत्तरी ध्रुव (N)',
    'lbl_south_pole': 'दक्षिणी ध्रुव (S)',
    'lbl_magnet_a': 'चुंबक A (रोलर्स पर)',
    'lbl_magnet_b': 'चुंबक B (खिसकाने योग्य)',
    'lbl_rollers': 'पेंसिल रोलर्स',
    'pole_n': 'N',
    'pole_s': 'S',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML `step_X_Y`; the
/// observation is the toast each step ends with). The HTML has no concept
/// text per step.
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      LabStep step(String action, String observation) =>
          LabStep(concept: '', action: t(action), observation: t(observation));
      return [
        LabScenarioData(
          title: t('scen_1_opt'),
          objective: t('s1_desc'),
          steps: [
            step('step_1_1', 'toast_sprinkled'),
            step('step_1_2', 'toast_dropped'),
            step('step_1_3', 'toast_observed'),
          ],
        ),
        LabScenarioData(
          title: t('scen_2_opt'),
          objective: t('s2_desc'),
          steps: [
            step('step_2_1', 'toast_attract'),
            step('step_2_2', 'toast_repel'),
            step('step_2_3', 'toast_attract'),
            step('step_2_4', 'toast_repel'),
          ],
        ),
      ];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Smallest touch target for scene objects (logical px).
const double _minTouch = 48;

// ---------------------------------------------------------- scenario 1 setup
// HTML setupScenario1() and its pointer handlers.

const int _filingCount = 350;
const _V _shakerHome = _V(7, 0, 3);
const _V _magnetTray = _V(-8, 0.45, 3);
const _V _magnetOnPaper = _V(0, 0.45, 0);

/// Heights while carried: shaker y 2.5, bar magnet y 1.2.
const double _shakerLift = 2.5;
const double _magnetLift = 1.2;

/// The shaker sprinkles while |x| < 5 and |z| < 4 (over the paper).
const double _sprinkleHalfX = 5, _sprinkleHalfZ = 4;

/// Sprinkle progress (%) added per pointer move over the paper.
const double _sprinklePerMove = 1.2;

/// The magnet sticks when dropped within 4 units of the paper centre.
const double _dropRadius = 4;

/// Bar magnet half sizes (two 1.6 × 0.8 × 1.2 halves) and its hit / glow
/// box (3.4 × 1.0 × 1.4).
const _V _magnetHalf = _V(1.6, 0.4, 0.6);
const _V _magnetHitHalf = _V(1.7, 0.5, 0.7);

/// Pole cluster centres at x = ±1.3 on the magnet.
const double _poleX = 1.3;

// ---------------------------------------------------------- scenario 2 setup
// HTML setupScenario2() and its physics in animate().

const _V _aHome = _V(-2.9, 0.8, 0);
const _V _bHome = _V(5.5, 0.8, 0);
const List<double> _rollerX = [-5, -3.6, -2.2, -0.8];
const double _rollerY = 0.2, _rollerR = 0.2, _rollerLen = 5;

/// Magnet B's drag plane (HTML intersectPlane y = 0.8) and its x range.
const double _s2PlaneY = 0.8;
const double _bMaxX = 8.5;

/// Magnet length: the centres are 3.2 apart when the magnets touch.
const double _contact = 3.2;

/// The magnets interact within 5.2 units (centre to centre).
const double _range = 5.2;

/// Attraction is recorded at 3.25; repulsion when A passes −5.5 or the
/// gap closes below 3.8.
const double _attractDone = 3.25, _repelDone = 3.8, _repelDoneA = -5.5;

/// Repulsion pushes A towards B.x − 6, never past −7.5.
const double _repelPush = 6, _repelMinA = -7.5;

/// Lerp rate (per second) of Magnet A, and roller spin per unit moved.
const double _pullRate = 6, _rollerSpinRate = 4;

/// Reset / Next Combination tween (500 ms).
const double _resetTime = 0.5;

// ------------------------------------------------------------------ cameras
// HTML changeScenario() / triggerHudAction().

const _V _cam1 = _V(0, 13, 15), _tgt1 = _V(0, 0, 0);
const _V _camObserve = _V(0, 5.5, 6), _tgtObserve = _V(0, 0.45, 0);
const _V _cam2 = _V(0, 12, 22), _tgt2 = _V(0, 0, 0);

/// Pan recogniser that only claims pointers that start on a draggable
/// object (decided by [canGrab]), so other drags still reach the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _Ch4A2ExploringMagneticPolesAndTheirPropertiesPageState
    extends State<Ch4A2ExploringMagneticPolesAndTheirPropertiesPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px), for touch-sized hit areas.
  double _fit = 1;

  /// UI scale of the last build (popup table).
  double _uiScale = 1;

  /// Object under the finger at pointer-down (not yet dragging).
  _Obj? _grab;

  /// Canvas text (labels, pole letters), laid out once and reused.
  final _TextCache _texts = _TextCache();

  /// Last feedback toast and the language of the last build, so a toast
  /// still on screen after a language switch is shown again translated.
  String? _toastKey;
  LabLang _builtLang = LabLang.en;

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  /// Step whose HUD text is shown: in Scenario 2 the HTML keeps the pair
  /// just tested until 'Reset / Next Combination' is pressed.
  int get _hudStep {
    final s = _scene;
    final step = s.scenario == 1 && s.resetReady ? s.combo : s.step;
    return step.clamp(1, s.scenario == 0 ? 3 : 4);
  }

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarioData(_lab.lang)[_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.load(0, _rnd);
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
    _texts.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: TWEEN.update() then the Scenario 2 physics.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = math.max(0.0, now - s.time);
    s.time = now;
    s.updateTweens();
    if (s.scenario == 1) _magnetPhysics(dt);
    _frame.value = now;
  }

  /// HTML Scenario 2 physics: within 5.2 units unlike poles pull Magnet A
  /// up to Magnet B, like poles push it away; the rollers spin as A rolls.
  /// Paused while the Reset tween runs (HTML bug: right after an attraction
  /// the next repulsion was recorded on its first frame, with no drag).
  void _magnetPhysics(double dt) {
    final s = _scene;
    if (s.comboDone || s.time < s.pausedUntil) return;
    final dist = s.b.x - s.a.x;
    if (dist >= _range) {
      s.lines = null;
      return;
    }
    final attract = s.combo.isOdd; // combos 1 and 3: unlike poles
    s
      ..lines = attract ? _Result.attract : _Result.repel
      ..linesX = (s.a.x + s.b.x) / 2;
    final targetX = attract
        ? s.b.x - _contact
        : math.max(_repelMinA, s.b.x - _repelPush);
    final prev = s.a.x;
    final k = math.min(1.0, dt * _pullRate);
    s.a = _V(prev + (targetX - prev) * k, s.a.y, s.a.z);
    s.rollerSpin -= (s.a.x - prev) * _rollerSpinRate;
    final done = attract
        ? dist <= _attractDone
        : (s.a.x <= _repelDoneA || dist <= _repelDone);
    if (done) _completeCombo(attract ? _Result.attract : _Result.repel);
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(getText(key))`.
  void _toast(String key) {
    _toastKey = key;
    _lab.showToast(_t(key));
  }

  /// Re-shows the visible toast (this lab's or the shell's "Scenario
  /// Complete") in the new language after a switch from [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    if (shown == null || shown.isError) return;
    final key = _toastKey;
    final String translated;
    if (key != null && shown.text == labTr(_i18n, previous, key)) {
      translated = _t(key);
    } else if (shown.text ==
        labTr(kLabCommonStrings, previous, 'msg_scenario_complete')) {
      translated = _lab.t('msg_scenario_complete');
    } else {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, sound: false);
    });
  }

  /// HTML `changeScenario(id)` / `resetApp()`: rebuilds the bench for
  /// [index] at step 1 with its camera.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index, _rnd);
      _grab = null;
    });
    _lab.resetView(sound: false);
  }

  /// Step 1 complete (HTML: sprinkleProgress reached 100): the shaker goes
  /// back to its spot (600 ms Quadratic.Out, upright in 600 ms) and the bar
  /// magnet can be picked up.
  void _finishSprinkle() {
    final s = _scene;
    setState(() {
      s
        ..step = 2
        ..dragging = null
        ..shakerDraggable = false
        ..magnetDraggable = true
        ..shakerTween = _Tween(s.shaker, _shakerHome, s.time, 0.6, _quadOut)
        ..tiltTween = _NumTween(s.shakerTilt, 0, s.time, 0.6, _linear);
    });
    _toast('toast_sprinkled');
  }

  /// HTML `onPointerUp` for the bar magnet: within 4 units of the paper
  /// centre it snaps to the centre (500 ms Cubic.Out) and the filings rush
  /// to its poles; otherwise it goes back to the tray (500 ms, linear).
  void _dropMagnet() {
    final s = _scene;
    final m = s.magnet;
    if (math.sqrt(m.x * m.x + m.z * m.z) < _dropRadius && !s.magnetDropped) {
      _Sound.drop.play();
      setState(() {
        s
          ..magnetDropped = true
          ..magnetDraggable = false
          ..step = 3
          ..magnetTween = _Tween(m, _magnetOnPaper, s.time, 0.5, _cubicOut)
          ..clusterStart = s.time;
      });
      _toast('toast_dropped');
    } else {
      _Sound.wrong.play();
      s.magnetTween = _Tween(m, _magnetTray, s.time, 0.5, _linear);
    }
  }

  /// HTML "Observe Poles": zoom on the magnet (camera tween 1000 ms
  /// Cubic.Out), label its poles, fill the table and show the summary 1.5 s
  /// later.
  void _observePoles() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 3 || s.polesObserved) return;
    setState(() {
      s
        ..polesObserved = true
        ..step = 4;
    });
    s.moveCamera(_camObserve, _tgtObserve, 1.0);
    _toast('toast_observed');
    _showConclusion(0, const Duration(milliseconds: 1500));
  }

  /// A pole pair has been observed: record it and move to the next step.
  /// After the fourth pair the summary follows 1.2 s later.
  void _completeCombo(_Result result) {
    final s = _scene;
    final combo = s.combo;
    setState(() {
      s
        ..comboDone = true
        ..resetReady = combo < 4
        ..step = combo + 1;
      s.results[combo - 1] = result;
    });
    _toast(result == _Result.attract ? 'toast_attract' : 'toast_repel');
    if (combo == 4) _showConclusion(1, const Duration(milliseconds: 1200));
  }

  /// HTML "Reset / Next Combination": both magnets glide home (500 ms) and
  /// the next pole pair is set up by turning Magnet A or B round.
  void _nextCombo() {
    final s = _scene;
    if (s.scenario != 1 || !s.resetReady) return;
    setState(() {
      s
        ..resetReady = false
        ..comboDone = false
        ..combo += 1
        ..lines = null
        ..dragging = null
        ..pausedUntil = s.time + _resetTime
        ..aTween = _Tween(s.a, _aHome, s.time, _resetTime, _cubicOut)
        ..bTween = _Tween(s.b, _bHome, s.time, _resetTime, _cubicOut);
      switch (s.combo) {
        case 2: // N(A) – N(B): turn A round.
          s.aYawTween = _NumTween(s.aYaw, math.pi, s.time, _resetTime, _linear);
        case 3: // N(A) – S(B): turn B round.
          s.bYawTween = _NumTween(s.bYaw, math.pi, s.time, _resetTime, _linear);
        case 4: // S(A) – S(B): turn A back.
          s.aYawTween = _NumTween(s.aYaw, 0, s.time, _resetTime, _linear);
      }
    });
  }

  /// HTML "Validate Investigation": re-opens the summary once the scenario
  /// is done; before that, asks the learner to finish every step.
  void _validate() {
    final s = _scene;
    final done = s.scenario == 0
        ? s.polesObserved
        : s.results.every((r) => r != null);
    if (!done) {
      _lab.showToast(_t('err_test_all'), isError: true);
      return;
    }
    _lab.style.click.play();
    _showConclusion(s.scenario, Duration.zero);
  }

  /// HTML `validateInvestigation()` summary popup, with the table.
  void _showConclusion(int scenario, Duration delay) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: delay,
      heading: () => _t(scenario == 0 ? 'sum_s1_title' : 'sum_s2_title'),
      body: () => _t(scenario == 0 ? 'sum_s1_desc' : 'sum_s2_desc'),
      extra: () =>
          _table(_lab.palette, _uiScale * _lab.fontScale.clamp(0.9, 1.4)),
    );
  }

  // -------------------------------------------------------------- dragging

  /// The object the current step lets the learner drag (HTML
  /// `userData.draggable`).
  _Obj? get _draggable {
    final s = _scene;
    if (s.scenario == 0) {
      if (s.step == 1 && s.shakerDraggable) return _Obj.shaker;
      if (s.step == 2 && s.magnetDraggable) return _Obj.magnet;
      return null;
    }
    return s.time < s.pausedUntil ? null : _Obj.magnetB;
  }

  /// HTML raycast on pointer-down: the hit box of the draggable object,
  /// widened to a finger-sized target.
  bool _canGrab(PointerDownEvent event) {
    final obj = _draggable;
    if (obj == null || _scene.dragging != null) return false;
    final s = _scene;
    final (centre, half) = switch (obj) {
      // Glow cylinder r 0.85, h 2.8 around the shaker.
      _Obj.shaker => (
        s.shaker + const _V(0, 1.4, 0),
        const _V(0.85, 1.4, 0.85),
      ),
      _Obj.magnet => (s.magnet, _magnetHitHalf),
      _Obj.magnetB => (s.b, _magnetHitHalf),
    };
    var box = s.proj.bounds(centre, half);
    final min = _minTouch / _fit;
    if (box.width < min || box.height < min) {
      box = Rect.fromCenter(
        center: box.center,
        width: math.max(box.width, min),
        height: math.max(box.height, min),
      );
    }
    if (!box.contains(event.localPosition)) return false;
    _grab = obj;
    return true;
  }

  double get _planeY => _scenario == 0 ? 0 : _s2PlaneY;

  _V _positionOf(_Obj obj) => switch (obj) {
    _Obj.shaker => _scene.shaker,
    _Obj.magnet => _scene.magnet,
    _Obj.magnetB => _scene.b,
  };

  /// HTML `onPointerDown`: remember where the drag plane was hit relative
  /// to the object, so it keeps that offset under the finger.
  void _dragStart(DragStartDetails d) {
    final obj = _grab;
    if (obj == null) return;
    final s = _scene;
    final hit = s.proj.onPlane(d.localPosition, _planeY);
    _Sound.pickup.play();
    s
      ..dragging = obj
      ..dragOffset = hit == null ? _V.zero : hit - _positionOf(obj);
    switch (obj) {
      case _Obj.shaker:
        s
          ..shakerTween = null
          ..tiltTween = null;
      case _Obj.magnet:
        s.magnetTween = null;
      case _Obj.magnetB:
        break;
    }
  }

  /// HTML `onPointerMove`.
  void _dragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.dragging;
    if (obj == null) return;
    final hit = s.proj.onPlane(d.localPosition, _planeY);
    if (hit == null) return;
    final x = hit.x - s.dragOffset.x, z = hit.z - s.dragOffset.z;
    switch (obj) {
      case _Obj.shaker:
        _moveShaker(x.clamp(-6.0, 8.0), z.clamp(-5.0, 5.0));
      case _Obj.magnet:
        s.magnet = _V(x.clamp(-8.0, 8.0), _magnetLift, z.clamp(-5.0, 5.0));
      case _Obj.magnetB:
        // Along x only; it cannot pass through Magnet A.
        s.b = _V(x.clamp(s.a.x + _contact, _bMaxX), _s2PlaneY, 0);
    }
  }

  /// Shaking over the paper sprinkles filings: every move adds 1.2 %.
  void _moveShaker(double x, double z) {
    final s = _scene..shaker = _V(x, _shakerLift, z);
    if (x.abs() >= _sprinkleHalfX || z.abs() >= _sprinkleHalfZ) return;
    // HTML: rotation.z = sin(Date.now() * 0.02) * 0.3 (ms).
    s
      ..shakerTilt = math.sin(s.time * 1000 * 0.02) * 0.3
      ..sprinkle = math.min(100, s.sprinkle + _sprinklePerMove);
    if (s.sprinkle >= 100 && s.step == 1) _finishSprinkle();
  }

  /// HTML `onPointerUp` / `pointercancel`.
  void _dragEnd() {
    final s = _scene;
    final obj = s.dragging;
    _grab = null;
    if (obj == null) return;
    s.dragging = null;
    switch (obj) {
      case _Obj.shaker:
        // Put down where it is (y -> 0, upright, 300 ms).
        _Sound.drop.play();
        s
          ..shakerTween = _Tween(
            s.shaker,
            _V(s.shaker.x, 0, s.shaker.z),
            s.time,
            0.3,
            _linear,
          )
          ..tiltTween = _NumTween(s.shakerTilt, 0, s.time, 0.3, _linear);
      case _Obj.magnet:
        _dropMagnet();
      case _Obj.magnetB:
        _Sound.drop.play();
    }
  }

  // ------------------------------------------------------------------- UI

  /// The HTML HUD button: "Observe Poles" (S1 step 3) or "Reset / Next
  /// Combination" (after each of the first three pole pairs).
  List<LabAction> _actions(LabPalette p) {
    final s = _scene;
    return [
      if (s.scenario == 0 && s.step == 3 && !s.polesObserved)
        LabAction(
          label: _t('btn_observe_poles'),
          icon: Icons.zoom_in,
          color: p.primary,
          foreground: p.onPrimary,
          highlight: true,
          onTap: _observePoles,
        ),
      if (s.scenario == 1 && s.resetReady && s.combo < 4)
        LabAction(
          label: _t('btn_next_combo'),
          icon: Icons.restart_alt,
          color: p.primary,
          foreground: p.onPrimary,
          highlight: true,
          onTap: _nextCombo,
        ),
    ];
  }

  /// HTML observation table for the current scenario.
  Widget _table(LabPalette p, double scale) {
    final s = _scene;
    if (s.scenario == 0) {
      final seen = s.polesObserved;
      return _ObservationTable(
        palette: p,
        scale: scale,
        headLeft: _t('tbl_part'),
        headRight: _t('tbl_conc'),
        rows: [
          _ObservationRow(
            _t('part_ends'),
            _t(seen ? 'conc_high' : 'pending'),
            color: seen ? p.success : null,
          ),
          _ObservationRow(
            _t('part_mid'),
            _t(seen ? 'conc_low' : 'pending'),
            color: seen ? p.textMuted : null,
          ),
        ],
      );
    }
    return _ObservationTable(
      palette: p,
      scale: scale,
      headLeft: _t('tbl_combo'),
      headRight: _t('tbl_inter'),
      rows: [
        for (var i = 0; i < 4; i++)
          switch (s.results[i]) {
            _Result.attract => _ObservationRow(
              _t('combo_${i + 1}'),
              _t('inter_attract'),
              color: p.success,
              icon: Icons.close_fullscreen,
            ),
            _Result.repel => _ObservationRow(
              _t('combo_${i + 1}'),
              _t('inter_repel'),
              color: _Colors.orange500,
              icon: Icons.open_in_full,
            ),
            null => _ObservationRow(_t('combo_${i + 1}'), _t('pending')),
          },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        if (_lab.lang != _builtLang) {
          final previous = _builtLang;
          _builtLang = _lab.lang;
          _retranslateToast(previous);
        }
        final p = _lab.palette;
        final s = context.labScale;
        _uiScale = s;
        final data = _data;
        final actions = _actions(p);
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.compare_arrows,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _step,
          actions: actions,
          onReset: () => _loadScenario(0),
          // The last instruction no longer applies once the scenario is done.
          showHud: _step <= data.steps.length,
          hud: _t('s${_scenario + 1}_hud_$_hudStep'),
          sidebarExtraTitle: _t('obs_table'),
          // HTML `#results-table-container`: the table with the "Validate
          // Investigation" button under it.
          sidebarExtra: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _table(p, s * _lab.fontScale),
              SizedBox(height: 8 * s),
              LabActionButton(
                action: LabAction(
                  label: _t('btn_validate'),
                  icon: Icons.check_circle,
                  silent: true,
                  onTap: _validate,
                ),
                scale: s,
              ),
            ],
          ),
          overlays: [
            // HTML `#hud-action-btn`, above the HUD. While the sidebar is
            // collapsed the floating mission card carries the buttons.
            if (actions.isNotEmpty && _lab.isSidebarOpen && _lab.popup == null)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + 66 * s,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final a in actions)
                          ConstrainedBox(
                            // Finger-sized tap target.
                            constraints: const BoxConstraints(
                              minHeight: _minTouch,
                            ),
                            child: LabActionButton(
                              action: a,
                              scale: s,
                              expand: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          stage: LayoutBuilder(
            builder: (context, box) {
              final fit = math.min(
                box.maxWidth / _design.width,
                box.maxHeight / _design.height,
              );
              _fit = fit > 0 ? fit : 1;
              // Canvas labels stay readable when the stage is scaled down.
              final labelScale = (0.85 / _fit).clamp(1.0, 1.8);
              return LabStage(
                designSize: _design,
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: {
                    _GrabPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _GrabPanRecognizer
                        >(
                          () => _GrabPanRecognizer(debugOwner: this),
                          (r) => r
                            // Small slop: a short drag grabs the object before the zoom
                            // viewer claims it (RawGestureDetector ignores MediaQuery's).
                            ..gestureSettings = const DeviceGestureSettings(
                              touchSlop: 8,
                            )
                            ..canGrab = _canGrab
                            ..dragStartBehavior = DragStartBehavior.down
                            ..onStart = _dragStart
                            ..onUpdate = _dragUpdate
                            ..onEnd = ((_) => _dragEnd())
                            ..onCancel = _dragEnd,
                        ),
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: _design,
                      painter: _ScenePainter(
                        scene: _scene,
                        texts: _texts,
                        repaint: _frame,
                        palette: p,
                        showLabels: _lab.showLabels,
                        lang: _lab.lang,
                        labelScale: labelScale,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------- observation table

/// One row of the HTML observation table. A null [color] means "Testing...".
@immutable
class _ObservationRow {
  const _ObservationRow(this.label, this.value, {this.color, this.icon});

  final String label;
  final String value;
  final Color? color;
  final IconData? icon;
}

/// HTML `#results-table-container` table (sidebar and summary popup).
class _ObservationTable extends StatelessWidget {
  const _ObservationTable({
    required this.palette,
    required this.scale,
    required this.headLeft,
    required this.headRight,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final String headLeft;
  final String headRight;
  final List<_ObservationRow> rows;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    TextStyle style(Color color, FontWeight weight, {bool italic = false}) =>
        TextStyle(
          color: color,
          fontSize: 11.5 * f,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          height: 1.3,
        );

    Widget line(Widget left, Widget right, {Color? fill, bool last = false}) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * f, vertical: 6 * f),
        decoration: BoxDecoration(
          color: fill,
          border: last ? null : Border(bottom: BorderSide(color: p.cardBorder)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: 8 * f),
            Expanded(child: right),
          ],
        ),
      );
    }

    Widget value(_ObservationRow r) {
      final c = r.color;
      if (c == null) {
        return Text(
          r.value,
          style: style(p.textMuted, FontWeight.w500, italic: true),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r.icon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 1.5 * f),
              child: Icon(r.icon, size: 12 * f, color: c),
            ),
            SizedBox(width: 4 * f),
          ],
          Flexible(child: Text(r.value, style: style(c, FontWeight.w800))),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(
            Text(headLeft, style: style(p.textMuted, FontWeight.w800)),
            Text(headRight, style: style(p.textMuted, FontWeight.w800)),
            fill: p.bg.withValues(alpha: 0.6),
          ),
          for (var i = 0; i < rows.length; i++)
            line(
              Text(rows[i].label, style: style(p.text, FontWeight.w600)),
              value(rows[i]),
              last: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- scene model

/// Objects the learner can drag (HTML `userData.draggable` meshes).
enum _Obj { shaker, magnet, magnetB }

/// What a pole pair did (HTML `s2Results`).
enum _Result { attract, repel }

/// TWEEN.js easings used by the HTML.
typedef _Ease = double Function(double t);

double _linear(double t) => t;

/// TWEEN.Easing.Quadratic.Out.
double _quadOut(double t) => t * (2 - t);

/// TWEEN.Easing.Cubic.Out.
double _cubicOut(double t) {
  final u = 1 - t;
  return 1 - u * u * u;
}

/// A TWEEN.js tween of a position.
@immutable
class _Tween {
  const _Tween(this.from, this.to, this.start, this.duration, this.ease);

  final _V from;
  final _V to;
  final double start;
  final double duration;
  final _Ease ease;

  _V at(double now) =>
      _V.lerp(from, to, ease(((now - start) / duration).clamp(0.0, 1.0)));

  bool isDone(double now) => now >= start + duration;
}

/// A TWEEN.js tween of one number (a rotation).
@immutable
class _NumTween {
  const _NumTween(this.from, this.to, this.start, this.duration, this.ease);

  final double from;
  final double to;
  final double start;
  final double duration;
  final _Ease ease;

  double at(double now) =>
      from + (to - from) * ease(((now - start) / duration).clamp(0.0, 1.0));

  bool isDone(double now) => now >= start + duration;
}

/// One iron filing (HTML `filingParticles[i]` and its `userData`).
@immutable
class _Filing {
  const _Filing({
    required this.sprinkled,
    required this.cluster,
    required this.rotY,
    required this.clusterRotY,
    required this.delay,
    required this.duration,
  });

  /// Random spot on the paper and the spot it rushes to near a pole.
  final _V sprinkled;
  final _V cluster;

  /// rotation.y on the paper and once clustered.
  final double rotY;
  final double clusterRotY;

  /// Cluster tween: random delay (0–200 ms), 800–1200 ms, Cubic.Out.
  final double delay;
  final double duration;

  _V positionAt(double now, double clusterStart) {
    if (clusterStart < 0) return sprinkled;
    final t = ((now - clusterStart - delay) / duration).clamp(0.0, 1.0);
    return _V.lerp(sprinkled, cluster, _cubicOut(t));
  }

  /// Rotation tween: 800 ms, linear, no delay.
  double rotationAt(double now, double clusterStart) {
    if (clusterStart < 0) return rotY;
    final t = ((now - clusterStart) / 0.8).clamp(0.0, 1.0);
    return rotY + (clusterRotY - rotY) * t;
  }
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;
  int step = 1;

  // Camera (position + controls.target) and its tween.
  _V eye = _cam1, target = _tgt1;
  _Tween? eyeTween, targetTween;

  // -------------------------------------------------- scenario 1
  _V shaker = _shakerHome;
  double shakerTilt = 0; // rotation.z
  _Tween? shakerTween;
  _NumTween? tiltTween;
  bool shakerDraggable = true;

  _V magnet = _magnetTray;
  _Tween? magnetTween;
  bool magnetDraggable = false;

  /// HTML sprinkleProgress (0–100 %).
  double sprinkle = 0;
  bool magnetDropped = false;
  bool polesObserved = false;
  final List<_Filing> filings = [];

  /// Time the filings started clustering (−1: still scattered).
  double clusterStart = -1;

  // -------------------------------------------------- scenario 2
  _V a = _aHome, b = _bHome;
  double aYaw = 0, bYaw = 0; // rotation.y
  _Tween? aTween, bTween;
  _NumTween? aYawTween, bYawTween;
  double rollerSpin = 0;

  /// Pole pair under test (HTML s2Combo, 1–4) and its state.
  int combo = 1;
  bool comboDone = false;
  bool resetReady = false;

  /// Physics and dragging wait for the Reset tween to finish.
  double pausedUntil = -1;
  final List<_Result?> results = List.filled(4, null);

  /// Force lines shown (attraction / repulsion), centred at [linesX].
  _Result? lines;
  double linesX = 0;

  // -------------------------------------------------- dragging
  _Obj? dragging;
  _V dragOffset = _V.zero;

  /// Filings already on the paper (HTML: floor(progress / 100 × 350)).
  int get visibleFilings =>
      (sprinkle / 100 * _filingCount).floor().clamp(0, _filingCount);

  _Proj get proj => _Proj(eye, target);

  void moveCamera(_V toEye, _V toTarget, double duration) {
    eyeTween = _Tween(eye, toEye, time, duration, _cubicOut);
    targetTween = _Tween(target, toTarget, time, duration, _cubicOut);
  }

  /// HTML `changeScenario(id)`: clearScene() + setupScenarioN().
  void load(int index, math.Random rnd) {
    scenario = index;
    step = 1;
    eye = index == 0 ? _cam1 : _cam2;
    target = index == 0 ? _tgt1 : _tgt2;
    eyeTween = targetTween = null;

    shaker = _shakerHome;
    shakerTilt = 0;
    shakerTween = null;
    tiltTween = null;
    shakerDraggable = true;
    magnet = _magnetTray;
    magnetTween = null;
    magnetDraggable = false;
    sprinkle = 0;
    magnetDropped = false;
    polesObserved = false;
    clusterStart = -1;
    filings.clear();
    if (index == 0) _scatterFilings(rnd);

    a = _aHome;
    b = _bHome;
    aYaw = bYaw = 0;
    aTween = bTween = null;
    aYawTween = bYawTween = null;
    rollerSpin = 0;
    combo = 1;
    comboDone = false;
    resetReady = false;
    pausedUntil = -1;
    results.fillRange(0, 4, null);
    lines = null;
    linesX = 0;

    dragging = null;
    dragOffset = _V.zero;
  }

  /// HTML: 350 filings at random spots on the paper, each with a cluster
  /// spot around one pole (radius rand² × 0.9, dense near the pole).
  void _scatterFilings(math.Random rnd) {
    for (var i = 0; i < _filingCount; i++) {
      final rx = (rnd.nextDouble() - 0.5) * 9.5;
      final rz = (rnd.nextDouble() - 0.5) * 6.5;
      final pole = rnd.nextDouble() > 0.5 ? -_poleX : _poleX;
      final angle = rnd.nextDouble() * math.pi * 2;
      final radius = math.pow(rnd.nextDouble(), 2) * 0.9;
      final cx = pole + math.cos(angle) * radius;
      final cz = math.sin(angle) * radius;
      filings.add(
        _Filing(
          sprinkled: _V(rx, 0.05, rz),
          cluster: _V(cx, 0.45, cz),
          rotY: rnd.nextDouble() * math.pi,
          clusterRotY: math.atan2(cz, cx - pole),
          delay: rnd.nextDouble() * 0.2,
          duration: 0.8 + rnd.nextDouble() * 0.4,
        ),
      );
    }
  }

  /// TWEEN.update(): advances every running tween.
  void updateTweens() {
    final now = time;
    if (eyeTween case final t?) {
      eye = t.at(now);
      if (t.isDone(now)) eyeTween = null;
    }
    if (targetTween case final t?) {
      target = t.at(now);
      if (t.isDone(now)) targetTween = null;
    }
    if (shakerTween case final t?) {
      shaker = t.at(now);
      if (t.isDone(now)) shakerTween = null;
    }
    if (tiltTween case final t?) {
      shakerTilt = t.at(now);
      if (t.isDone(now)) tiltTween = null;
    }
    if (magnetTween case final t?) {
      magnet = t.at(now);
      if (t.isDone(now)) magnetTween = null;
    }
    if (aTween case final t?) {
      a = t.at(now);
      if (t.isDone(now)) aTween = null;
    }
    if (bTween case final t?) {
      b = t.at(now);
      if (t.isDone(now)) bTween = null;
    }
    if (aYawTween case final t?) {
      aYaw = t.at(now);
      if (t.isDone(now)) aYawTween = null;
    }
    if (bYawTween case final t?) {
      bYaw = t.at(now);
      if (t.isDone(now)) bYawTween = null;
    }
  }
}

// ------------------------------------------------------------------ 3D math

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
  _V get unit => this * (1 / length);

  /// Three.js `rotation.y = a` applied to this vector.
  _V rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }

  /// Three.js `rotation.z = a` applied to this vector.
  _V rotZ(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c - y * s, x * s + y * c, z);
  }

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML PerspectiveCamera (45° vertical field of view) at [eye]
/// looking at the OrbitControls target, projected onto the design stage.
@immutable
class _Proj {
  factory _Proj(_V eye, _V target) {
    final f = (target - eye).unit;
    final r = f.cross(const _V(0, 1, 0)).unit;
    return _Proj._(eye, f, r, r.cross(f));
  }

  const _Proj._(this.eye, this.f, this.r, this.u);

  /// 280 / tan(22.5°): the 45° fov over the 560 px stage height.
  static const double focal = 675.96;
  static const Offset center = Offset(500, 280);

  final _V eye;
  final _V f;
  final _V r;
  final _V u;

  double depth(_V w) => (w - eye).dot(f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  bool inFront(_V w) => depth(w) > 0.1;

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// World-space ray direction through a stage point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - center.dx) / focal) + u * (-(s.dy - center.dy) / focal))
          .unit;

  /// Where that ray crosses the horizontal plane y = [py] (drag plane).
  _V? onPlane(Offset s, double py) {
    final d = ray(s);
    if (d.y.abs() < 1e-6) return null;
    final t = (py - eye.y) / d.y;
    if (t <= 0) return null;
    return eye + d * t;
  }

  /// Screen bounds of the axis-aligned box centred at [c].
  Rect bounds(_V c, _V half) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (var i = 0; i < 8; i++) {
      final o = p(
        _V(
          c.x + (i & 1 == 0 ? -half.x : half.x),
          c.y + (i & 2 == 0 ? -half.y : half.y),
          c.z + (i & 4 == 0 ? -half.z : half.z),
        ),
      );
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Ray [o] + t·[d] against the box centred at [c] (half sizes [h], turned
/// by [yaw]): the entry t, or null when it misses (slab method).
double? _rayBox(_V o, _V d, _V c, _V h, double yaw) {
  final lo = (o - c).rotY(-yaw), ld = d.rotY(-yaw);
  var tMin = 0.0, tMax = double.infinity;
  for (var i = 0; i < 3; i++) {
    final oi = i == 0 ? lo.x : (i == 1 ? lo.y : lo.z);
    final di = i == 0 ? ld.x : (i == 1 ? ld.y : ld.z);
    final hi = i == 0 ? h.x : (i == 1 ? h.y : h.z);
    if (di.abs() < 1e-9) {
      if (oi < -hi || oi > hi) return null;
      continue;
    }
    var t1 = (-hi - oi) / di, t2 = (hi - oi) / di;
    if (t1 > t2) (t1, t2) = (t2, t1);
    tMin = math.max(tMin, t1);
    tMax = math.min(tMax, t2);
    if (tMin > tMax) return null;
  }
  return tMin;
}

/// Does the segment [o] → [o] + [d] pass through the upright cylinder
/// (radius [r], height [h]) standing at [base] and tilted by [tilt] about z?
bool _segmentHitsCylinder(
  _V o,
  _V d,
  _V base,
  double tilt,
  double r,
  double h,
) {
  final q = (o - base).rotZ(-tilt), v = d.rotZ(-tilt);
  const tEnd = 0.999; // stop just short of the point itself
  bool side(double t) {
    if (t <= 0 || t >= tEnd) return false;
    final y = q.y + v.y * t;
    return y >= 0 && y <= h;
  }

  bool cap(double capY) {
    final t = (capY - q.y) / v.y;
    if (t <= 0 || t >= tEnd) return false;
    final x = q.x + v.x * t, z = q.z + v.z * t;
    return x * x + z * z <= r * r;
  }

  final a = v.x * v.x + v.z * v.z;
  if (a > 1e-9) {
    final b = 2 * (q.x * v.x + q.z * v.z);
    final c = q.x * q.x + q.z * q.z - r * r;
    final disc = b * b - 4 * a * c;
    if (disc >= 0) {
      final sq = math.sqrt(disc);
      if (side((-b - sq) / (2 * a)) || side((-b + sq) / (2 * a))) return true;
    }
  }
  return v.y.abs() > 1e-9 && (cap(0) || cap(h));
}

/// Convex hull (Andrew's monotone chain) of projected points.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[], upper = <Offset>[];
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

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (12, 25, 15)).
const _V _light = _V(0.3806, 0.7929, 0.4757);

/// Box faces: outward normal, then the bottom-left, bottom-right and
/// top-left corners of the face's texture (Three.js BoxGeometry UVs), in
/// units of the half size.
const List<(_V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(1, 1, -1)),
];

/// Size of the HTML magnet face texture (256 × 128 canvas, bold 72 px).
const double _texW = 256, _texH = 128, _texFont = 72;

/// Label chip padding (HTML `px-2.5 py-1`, at the 12 px label size).
const double _labelPadX = 9, _labelPadY = 3.5;

/// Paints the HTML Three.js scene: desk, paper, toolbox tray, bar magnet,
/// shaker and iron filings (S1); desk, pencil rollers, Magnets A and B and
/// the force lines (S2); then the floating object labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path _path = Path();
  final Float64List _matrix = Float64List(16);
  final Float32List _filingPoints = Float32List(_filingCount * 4);
  Float32List? _grid;
  Size? _gridSize;

  late Canvas _c;
  late _Proj _p;

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _background(size);
    if (scene.scenario == 0) {
      _paintScenario1();
    } else {
      _paintScenario2();
    }
    if (showLabels) _paintLabels();
  }

  // ------------------------------------------------------------ background

  /// HTML `#canvas-wrapper` (#0f172a) with its 50 px `.canvas-grid`.
  void _background(Size size) {
    final bleed = labBleed(size);
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(bleed, _fill);
    if (_grid == null || _gridSize != size) {
      _gridSize = size;
      const step = 50.0;
      final pts = <double>[];
      for (
        var x = (bleed.left / step).ceil() * step;
        x < bleed.right;
        x += step
      ) {
        pts.addAll([x, bleed.top, x, bleed.bottom]);
      }
      for (
        var y = (bleed.top / step).ceil() * step;
        y < bleed.bottom;
        y += step
      ) {
        pts.addAll([bleed.left, y, bleed.right, y]);
      }
      _grid = Float32List.fromList(pts);
    }
    _stroke
      ..strokeWidth = 1
      ..color = (palette.isDark ? LabInk.white : LabInk.black).withValues(
        alpha: 0.03,
      );
    _c.drawRawPoints(ui.PointMode.lines, _grid!, _stroke);
  }

  // ------------------------------------------------------------ scenario 1

  void _paintScenario1() {
    final s = scene;
    // Desk 24 × 1 × 18, white paper 11 × 0.04 × 8, toolbox tray 4.5 × 0.1 × 3.5.
    _box(const _V(0, -0.5, 0), const _V(12, 0.5, 9), _Colors.slate600);
    _box(
      const _V(0, 0.02, 0),
      const _V(5.5, 0.02, 4),
      _Colors.slate50,
      edge: 0.2,
    );
    _box(const _V(-8, 0.05, 3), const _V(2.25, 0.05, 1.75), _Colors.slate700);

    _boxShadow(s.magnet, _magnetHalf, 0);
    _shakerShadow();

    // Far object first. Filings go over the magnet (hidden where the magnet
    // covers them) and under the see-through shaker body.
    final shakerFirst =
        _p.depth(s.shaker + const _V(0, 1.35, 0)) > _p.depth(s.magnet);
    if (shakerFirst) {
      _paintShaker();
      _barMagnet(s.magnet, 0, glow: s.dragging == _Obj.magnet);
      _paintFilings(testShakerCap: true);
    } else {
      _barMagnet(s.magnet, 0, glow: s.dragging == _Obj.magnet);
      _paintFilings(testShakerCap: false);
      _paintShaker();
    }
  }

  /// HTML iron filings: 0.12 × 0.02 × 0.04 dark boxes, drawn as short
  /// dashes in one call. Filings the magnet (or the shaker's cap) hides are
  /// skipped, like the WebGL depth test.
  void _paintFilings({required bool testShakerCap}) {
    final s = scene;
    final n = s.visibleFilings;
    if (n == 0) return;
    final eye = _p.eye;
    final capBase = s.shaker + const _V(0, 2.2, 0).rotZ(s.shakerTilt);
    var count = 0;
    for (var i = 0; i < n; i++) {
      final filing = s.filings[i];
      final pos = filing.positionAt(s.time, s.clusterStart);
      final toFiling = pos - eye;
      final hit = _rayBox(eye, toFiling, s.magnet, _magnetHalf, 0);
      if (hit != null && hit < 0.999) continue;
      if (testShakerCap &&
          _segmentHitsCylinder(
            eye,
            toFiling,
            capBase,
            s.shakerTilt,
            0.75,
            0.5,
          )) {
        continue;
      }
      final rot = filing.rotationAt(s.time, s.clusterStart);
      // Half length 0.06 along the filing's local x.
      final half = _V(math.cos(rot) * 0.06, 0, -math.sin(rot) * 0.06);
      final a = _p.p(pos - half), b = _p.p(pos + half);
      _filingPoints[count++] = a.dx;
      _filingPoints[count++] = a.dy;
      _filingPoints[count++] = b.dx;
      _filingPoints[count++] = b.dy;
    }
    if (count == 0) return;
    _stroke
      ..color = _Colors.slate800
      ..strokeWidth = math.max(1.5, 0.045 * _p.scaleAt(_magnetOnPaper));
    _c.drawRawPoints(
      ui.PointMode.lines,
      Float32List.sublistView(_filingPoints, 0, count),
      _stroke,
    );
  }

  /// HTML createShakerMesh(): see-through cyan body (r 0.7, h 2.2), metal
  /// cap (r 0.75, h 0.5) with six holes; tilted by rotation.z while shaking.
  void _paintShaker() {
    final s = scene;
    final base = s.shaker, tilt = s.shakerTilt;
    final axis = const _V(0, 1, 0).rotZ(tilt);
    _cylinder(base, axis, 0.7, 2.2, _Colors.cyan500, opacity: 0.65, sheen: 0.5);
    final capBase = base + axis * 2.2;
    _cylinder(capBase, axis, 0.75, 0.5, _Colors.slate400, sheen: 0.55);
    final top = base + axis * 2.71;
    if (axis.dot(_p.eye - top) > 0) {
      _fill.color = _Colors.slate800;
      for (var i = 0; i < 6; i++) {
        final angle = i / 6 * math.pi * 2;
        final hole =
            base +
            _V(math.cos(angle) * 0.4, 2.71, math.sin(angle) * 0.4).rotZ(tilt);
        final k = _p.scaleAt(hole);
        final squash = (hole - _p.eye).unit.dot(axis).abs();
        _c.drawOval(
          Rect.fromCenter(
            center: _p.p(hole),
            width: 0.12 * k,
            height: math.max(1, 0.12 * k * squash),
          ),
          _fill,
        );
      }
    }
    if (s.dragging == _Obj.shaker) _wireCylinder(base, axis, 0.85, 2.8);
  }

  void _shakerShadow() {
    final s = scene;
    final axis = const _V(0, 1, 0).rotZ(s.shakerTilt);
    final pts = <Offset>[];
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final rim = _V(math.cos(angle) * 0.72, 0, math.sin(angle) * 0.72);
      pts
        ..add(_p.p(_onTable(s.shaker + rim)))
        ..add(_p.p(_onTable(s.shaker + axis * 2.7 + rim)));
    }
    _shadowHull(pts, 0.28);
  }

  // ------------------------------------------------------------ scenario 2

  void _paintScenario2() {
    final s = scene;
    // Desk 26 × 1 × 18.
    _box(const _V(0, -0.5, 0), const _V(13, 0.5, 9), _Colors.slate700);
    for (final x in _rollerX) {
      _shadowHull([
        for (final z in const [-2.5, 2.5])
          for (final y in const [0.0, 0.4]) ...[
            _p.p(_onTable(_V(x - _rollerR, y, z))),
            _p.p(_onTable(_V(x + _rollerR, y, z))),
          ],
      ], 0.22);
    }
    _boxShadow(s.a, _magnetHalf, s.aYaw);
    _boxShadow(s.b, _magnetHalf, s.bYaw);
    for (final x in _rollerX) {
      _roller(x);
    }
    _barMagnet(s.a, s.aYaw, glow: false);
    _barMagnet(s.b, s.bYaw, glow: s.dragging == _Obj.magnetB);
    if (s.lines != null) _paintForceLines();
  }

  /// HTML pencil roller: yellow CylinderGeometry(0.2, 0.2, 5) along z.
  /// Pencil facet lines show the HTML's roller spin (rotation.y).
  void _roller(double x) {
    const axis = _V(0, 0, 1);
    final base = _V(x, _rollerY, -_rollerLen / 2);
    _cylinder(base, axis, _rollerR, _rollerLen, _Colors.yellow400, sheen: 0.45);
    _stroke
      ..strokeWidth = 1
      ..color = labShade(_Colors.yellow400, -0.45).withValues(alpha: 0.55);
    for (var k = 0; k < 6; k++) {
      final angle = scene.rollerSpin + k * math.pi / 3;
      final radial = _V(math.cos(angle), math.sin(angle), 0);
      final mid = _V(x, _rollerY, 0) + radial * _rollerR;
      if (radial.dot(_p.eye - mid) <= 0) continue;
      _c.drawLine(
        _p.p(mid + const _V(0, 0, -_rollerLen / 2)),
        _p.p(mid + const _V(0, 0, _rollerLen / 2)),
        _stroke,
      );
    }
  }

  /// HTML createForceLinesVFX(): six arcs between the magnet centres, green
  /// for attraction, orange for repulsion (opacity 0.7). Parts inside or
  /// behind a magnet are hidden, like the WebGL depth test.
  void _paintForceLines() {
    final s = scene;
    final color = s.lines == _Result.attract
        ? _Colors.emerald500
        : _Colors.orange500;
    _stroke
      ..strokeWidth = 2.2
      ..color = color.withValues(alpha: 0.7);
    final eye = _p.eye;
    const segments = 40;
    for (var i = 0; i < 6; i++) {
      final arc = (i - 2.5) * 0.4;
      _path.reset();
      var pen = false;
      for (var j = 0; j <= segments; j++) {
        final t = j / segments;
        final sn = math.sin(t * math.pi);
        final w = _V(
          s.linesX + (t - 0.5) * 3.2,
          0.8 + sn * (arc.abs() * 0.5 + 0.2),
          sn * arc,
        );
        final toPoint = w - eye;
        final hitA = _rayBox(eye, toPoint, s.a, _magnetHalf, s.aYaw);
        final hitB = _rayBox(eye, toPoint, s.b, _magnetHalf, s.bYaw);
        if ((hitA != null && hitA < 0.999) || (hitB != null && hitB < 0.999)) {
          pen = false;
          continue;
        }
        final o = _p.p(w);
        if (pen) {
          _path.lineTo(o.dx, o.dy);
        } else {
          _path.moveTo(o.dx, o.dy);
          pen = true;
        }
      }
      _c.drawPath(_path, _stroke);
    }
  }

  // ---------------------------------------------------------- bar magnet

  /// HTML createBarMagnetMesh('N', 'S'): red N half at local x −0.8, blue S
  /// half at +0.8, each face showing its letter; the indigo wire box while
  /// it is dragged.
  void _barMagnet(_V c, double yaw, {required bool glow}) {
    final axis = const _V(1, 0, 0).rotY(yaw); // N → S
    final northC = c - axis * 0.8, southC = c + axis * 0.8;
    const half = _V(0.8, 0.4, 0.6);
    final letterN = _letter('pole_n'), letterS = _letter('pole_s');
    // The half on the camera's side of the joint is drawn last.
    if (axis.dot(_p.eye - c) > 0) {
      _box(northC, half, _Colors.red500, yaw: yaw, letter: letterN);
      _box(southC, half, _Colors.blue500, yaw: yaw, letter: letterS);
    } else {
      _box(southC, half, _Colors.blue500, yaw: yaw, letter: letterS);
      _box(northC, half, _Colors.red500, yaw: yaw, letter: letterN);
    }
    if (glow) _wireBox(c, _magnetHitHalf, yaw);
  }

  /// The pole letter of the HTML face texture (white, bold 72 px).
  TextPainter _letter(String key) => texts.get(
    labTr(_i18n, lang, key),
    size: _texFont,
    color: _Colors.white,
    weight: FontWeight.w800,
  );

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (ambient 0.65 +
  /// directional 0.85 in the HTML, toned down to keep colours).
  Color _lit(Color c, _V n, {double opacity = 1}) {
    final i = 0.58 + 0.55 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: (c.a * opacity).clamp(0.0, 1.0),
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Box centred at [c] with half sizes [h], turned by [yaw]. With
  /// [letter], each visible face shows it like the HTML canvas texture.
  void _box(
    _V c,
    _V h,
    Color color, {
    double yaw = 0,
    double edge = 0.35,
    TextPainter? letter,
  }) {
    _V corner(_V s) => c + _V(s.x * h.x, s.y * h.y, s.z * h.z).rotY(yaw);
    for (final (n, bl, br, tl) in _boxFaces) {
      final normal = n.rotY(yaw);
      if (normal.dot(_p.eye - corner(n)) <= 0) continue;
      final pBL = _p.p(corner(bl)), pBR = _p.p(corner(br));
      final pTL = _p.p(corner(tl)), pTR = _p.p(corner(br + tl - bl));
      _path
        ..reset()
        ..moveTo(pBL.dx, pBL.dy)
        ..lineTo(pBR.dx, pBR.dy)
        ..lineTo(pTR.dx, pTR.dy)
        ..lineTo(pTL.dx, pTL.dy)
        ..close();
      _fill
        ..shader = null
        ..color = _lit(color, normal);
      _c.drawPath(_path, _fill);
      if (edge > 0) {
        _stroke
          ..strokeWidth = 0.8
          ..color = labShade(color, -0.5).withValues(alpha: edge);
        _c.drawPath(_path, _stroke);
      }
      if (letter != null) _faceLetter(letter, pTL, pTR, pBL);
    }
  }

  /// Draws [tp] in the middle of a face whose texture corners project to
  /// [tl], [tr] and [bl] (affine mapping of the 256 × 128 texture).
  void _faceLetter(TextPainter tp, Offset tl, Offset tr, Offset bl) {
    final ax = (tr - tl) / _texW, ay = (bl - tl) / _texH;
    final area = (ax.dx * ay.dy - ax.dy * ay.dx).abs() * _texW * _texH;
    if (area < 40) return; // seen edge-on
    _matrix
      ..fillRange(0, 16, 0)
      ..[0] = ax.dx
      ..[1] = ax.dy
      ..[4] = ay.dx
      ..[5] = ay.dy
      ..[10] = 1
      ..[12] = tl.dx
      ..[13] = tl.dy
      ..[15] = 1;
    _c
      ..save()
      ..transform(_matrix);
    tp.paint(_c, Offset((_texW - tp.width) / 2, (_texH - tp.height) / 2));
    _c.restore();
  }

  /// Indigo wireframe box (HTML glowMesh, MeshBasicMaterial wireframe).
  void _wireBox(_V c, _V h, double yaw) {
    final pts = [
      for (var i = 0; i < 8; i++)
        _p.p(
          c +
              _V(
                i & 1 == 0 ? -h.x : h.x,
                i & 2 == 0 ? -h.y : h.y,
                i & 4 == 0 ? -h.z : h.z,
              ).rotY(yaw),
        ),
    ];
    _stroke
      ..strokeWidth = 1.4
      ..color = _Colors.indigo500.withValues(alpha: 0.95);
    for (var i = 0; i < 8; i++) {
      for (final bit in const [1, 2, 4]) {
        if (i & bit == 0) _c.drawLine(pts[i], pts[i | bit], _stroke);
      }
    }
  }

  /// Indigo wireframe cylinder (the shaker's glowMesh).
  void _wireCylinder(_V base, _V axis, double r, double len) {
    final (a1, a2) = _ringAxes(axis);
    _stroke
      ..strokeWidth = 1.2
      ..color = _Colors.indigo500.withValues(alpha: 0.9);
    for (final y in [0.0, len]) {
      _path.reset();
      for (var i = 0; i <= 24; i++) {
        final angle = i * math.pi / 12;
        final o = _p.p(
          base + axis * y + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r,
        );
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _c.drawPath(_path, _stroke);
    }
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final rim = (a1 * math.cos(angle) + a2 * math.sin(angle)) * r;
      _c.drawLine(_p.p(base + rim), _p.p(base + axis * len + rim), _stroke);
    }
  }

  (_V, _V) _ringAxes(_V axis) {
    final helper = axis.y.abs() > 0.9 ? const _V(1, 0, 0) : const _V(0, 1, 0);
    final a1 = axis.cross(helper).unit;
    return (a1, axis.cross(a1).unit);
  }

  /// Cylinder from [base] along unit [axis] (CylinderGeometry look): side
  /// silhouette with a lit gradient and the cap that faces the camera.
  void _cylinder(
    _V base,
    _V axis,
    double r,
    double len,
    Color color, {
    double opacity = 1,
    double sheen = 0.3,
  }) {
    final (a1, a2) = _ringAxes(axis);
    final top = base + axis * len;
    final pts = <Offset>[];
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final rim = (a1 * math.cos(angle) + a2 * math.sin(angle)) * r;
      pts
        ..add(_p.p(base + rim))
        ..add(_p.p(top + rim));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    final mid = base + axis * (len / 2);
    final pm = _p.p(mid), along = _p.p(top) - _p.p(base);
    final l = along.distance;
    final perp = l < 0.001
        ? const Offset(1, 0)
        : Offset(-along.dy / l, along.dx / l);
    final half = r * _p.scaleAt(mid) * 1.1;
    Color shade(double k) =>
        labShade(color, k).withValues(alpha: color.a * opacity);
    _fill.shader = ui.Gradient.linear(
      pm - perp * half,
      pm + perp * half,
      [shade(-0.4), shade(sheen), shade(0), shade(-0.45)],
      const [0, 0.35, 0.62, 1],
    );
    _path
      ..reset()
      ..addPolygon(hull, true);
    _c.drawPath(_path, _fill);
    _fill.shader = null;

    final capAt = axis.dot(_p.eye - top) > 0
        ? top
        : ((axis * -1).dot(_p.eye - base) > 0 ? base : null);
    if (capAt == null) return;
    _path.reset();
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final o = _p.p(capAt + (a1 * math.cos(angle) + a2 * math.sin(angle)) * r);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    _fill.color = labShade(color, 0.22).withValues(alpha: color.a * opacity);
    _c.drawPath(_path, _fill);
  }

  /// Where the key light casts point [w] onto the table (y ≈ 0).
  _V _onTable(_V w) => _V(w.x - w.y * 12 / 25, 0.045, w.z - w.y * 15 / 25);

  /// Soft shadow of a box on the table.
  void _boxShadow(_V c, _V h, double yaw) {
    _shadowHull([
      for (var i = 0; i < 8; i++)
        _p.p(
          _onTable(
            c +
                _V(
                  i & 1 == 0 ? -h.x : h.x,
                  i & 2 == 0 ? -h.y : h.y,
                  i & 4 == 0 ? -h.z : h.z,
                ).rotY(yaw),
          ),
        ),
    ], 0.32);
  }

  void _shadowHull(List<Offset> pts, double opacity) {
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..addPolygon(hull, true);
    _shadow.color = LabInk.black.withValues(alpha: opacity);
    _c.drawPath(_path, _shadow);
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.html-label` chips (bottom-centre on the object's label point).
  void _paintLabels() {
    final s = scene;
    if (s.scenario == 0) {
      // On the back of the paper (the HTML puts it at the paper centre,
      // right where the magnet and its filings end up).
      _label(_layoutLabel('lbl_paper', const _V(0, 0.22, -3.2)));
      _label(_layoutLabel('lbl_magnet', s.magnet + const _V(0, 0.8, 0)));
      _label(_layoutLabel('lbl_shaker', s.shaker + const _V(0, 2.8, 0)));
      if (s.polesObserved) {
        // Pole markers at magnet-local (∓1.3, 0.6) + label offset 0.5.
        _label(
          _layoutLabel('lbl_north_pole', s.magnet + const _V(-_poleX, 1.1, 0)),
        );
        _label(
          _layoutLabel('lbl_south_pole', s.magnet + const _V(_poleX, 1.1, 0)),
        );
      }
      return;
    }
    // At the front of the rollers (the HTML anchors it at the roller
    // group's origin, x = 0, where it would cover Magnet B).
    _label(_layoutLabel('lbl_rollers', const _V(-2.9, 0, 3.6)));
    final a = _layoutLabel('lbl_magnet_a', s.a + const _V(0, 1, 0));
    final b = _layoutLabel('lbl_magnet_b', s.b + const _V(0, 1, 0));
    if (a == null || b == null) return;
    // Touching magnets: slide the two chips apart instead of overlapping.
    final overlap = a.$2.right + 4 - b.$2.left;
    if (overlap > 0) {
      _label((a.$1, a.$2.shift(Offset(-overlap / 2, 0))));
      _label((b.$1, b.$2.shift(Offset(overlap / 2, 0))));
    } else {
      _label(a);
      _label(b);
    }
  }

  /// The text and chip rect of label [key] anchored at [at], or null when
  /// the point is behind the camera.
  (TextPainter, Rect)? _layoutLabel(String key, _V at) {
    if (!_p.inFront(at)) return null;
    final k = labelScale;
    final tp = texts.get(
      labTr(_i18n, lang, key),
      size: 12 * k,
      color: palette.labelText,
      weight: FontWeight.w700,
      letterSpacing: 0.3,
    );
    final o = _p.p(at);
    final w = tp.width + 2 * _labelPadX * k, h = tp.height + 2 * _labelPadY * k;
    return (tp, Rect.fromLTWH(o.dx - w / 2, o.dy - h, w, h));
  }

  void _label((TextPainter, Rect)? label) {
    if (label == null) return;
    final (tp, rect) = label;
    final k = labelScale;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(6 * k));
    _fill
      ..shader = null
      ..color = palette.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.slate700;
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(rect.left + _labelPadX * k, rect.top + _labelPadY * k));
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale;
}

/// TextPainters for the canvas text, laid out once and reused every frame.
/// Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final key = '$text|$size|${color.toARGB32()}|${weight.value}';
    return _painters.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            letterSpacing: letterSpacing,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  void dispose() {
    for (final painter in _painters.values) {
      painter.dispose();
    }
    _painters.clear();
  }
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
