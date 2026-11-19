// Imported from new-elab-app-7; Class 7 local activity.
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

/// Class 7 Science • Chapter 10 • Activity 3
/// Role of Carbon Dioxide in Photosynthesis.
///
/// Native Flutter port of `Cl7S-Ch10-A3-Role_of_Carbon_Dioxide_in_Photosynthesis.html`.
/// Scenario 1 seals half of a destarched leaf inside a bottle of caustic soda,
/// then boils, decolorizes and iodine-tests it; scenario 2 compares four plants
/// kept with or without sunlight and carbon dioxide.
class Ch10A3RoleOfCarbonDioxideInPhotosynthesisPage extends StatefulWidget {
  const Ch10A3RoleOfCarbonDioxideInPhotosynthesisPage({super.key});

  @override
  State<Ch10A3RoleOfCarbonDioxideInPhotosynthesisPage> createState() =>
      _Ch10A3RoleOfCarbonDioxideInPhotosynthesisPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, drop 2364, bubble 732,
/// splash 1311, switchTap 2585.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / right answer.
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / success popup (HTML `playSound('success')`).
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// Object picked up (HTML `playSound('drag')`).
  pickup('pickup.mp3'),

  /// Object dropped in place (HTML `playSound('drop')`).
  drop('drop.mp3'),

  /// Boiling water bath (HTML `playSound('boil')`).
  bubble('bubble.mp3'),

  /// Caustic soda pouring into the bottle.
  splash('splash.mp3'),

  /// Scissors snipping the leaf (HTML `playSound('snip')`).
  snip('switch.mp3');

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

/// Tailwind / CSS colours used by this lab.
abstract final class _Colors {
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // --accent (dark)
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);
  static const Color emerald500 = Color(0xFF10B981); // --accent (light)
  static const Color emerald900 = Color(0xFF064E3B); // leaf outlines
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706); // iodine brown
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber900 = Color(0xFF78350F);
  static const Color yellow200 = Color(0xFFFEF08A); // decolorized leaf
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow400 = Color(0xFFFACC15); // sun
  static const Color indigo950 = Color(0xFF1E1B4B); // blue-black starch
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  // Wood of the lab bench and the cupboard.
  static const Color bench = Color(0xFF8B4513);
  static const Color benchEdge = Color(0xFF5C2E0B);
  static const Color benchLeg = Color(0xFF6F370F);
  static const Color closet = Color(0xFF3E2723);
  static const Color closetDoor = Color(0xFF4E342E);
  static const Color closetPanel = Color(0xFF5D4037);
  static const Color closetEdge = Color(0xFF1F1209);
}

/// This lab's light and dark palettes (the HTML `:root` / `.light-theme`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF21E293B),
    border: Color(0x99334155),
    card: Color(0x800F172A),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: _Colors.slate50,
    textMuted: _Colors.slate400,
    accent: _Colors.green500,
    onAccent: _Colors.slate900,
    primary: _Colors.blue500,
    onPrimary: Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4022C55E),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xF21E293B),
    labelText: _Colors.slate50,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate100,
    panel: Color(0xF2FFFFFF),
    border: _Colors.slate300,
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate900,
    primary: _Colors.blue500,
    onPrimary: Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue500,
    popupBg: _Colors.slate100,
    popupHeader: Colors.white,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4022C55E),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xF2FFFFFF),
    labelText: _Colors.slate900,
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

// =================================================================== STRINGS

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Role of Carbon Dioxide in Photosynthesis',
    'app_subtitle': 'Class 7 • Life Processes in Plants',
    'scen_1': '1. The Half-Leaf Experiment',
    'scen_2': '2. Four Conditions',
    'sci_obs': 'Scientific Conclusion',
    // HUD feedback (HTML `locales.hud`).
    'h_openCupboard': 'Cupboard open. Drag the plant to the lab bench.',
    'h_plantPlaced': 'Plant positioned perfectly.',
    'h_proceedChem': 'Proceed to chemicals.',
    'h_naohAdded': 'NaOH added. It will absorb CO₂.',
    'h_proceeding': 'Proceeding...',
    'h_corkAttached': 'Cork attached! Now drag the leaf tip to the cork.',
    'h_leafSealed': 'Leaf successfully sealed in the bottle.',
    'h_setupReady': 'Setup ready.',
    'h_timePass': 'Time passing...',
    'h_sim6h': 'Simulating 6 hours...',
    'h_leafCollected': 'Leaf snipped and collected.',
    'h_proceedStarch': 'Proceed to starch test.',
    'h_leafBoiled': 'Leaf boiled in water.',
    'h_dragAlc': 'Now drag leaf to alcohol tube.',
    'h_leafAlc': 'Leaf placed in alcohol.',
    'h_dragWater': 'Drag tube to boiling water.',
    'h_leafDecolor': 'Chlorophyll removed. Leaf decolorized.',
    'h_starchDone': 'Starch test complete.',
    'h_plantAPlaced': 'Plant A placed.',
    'h_proceedNext': 'Proceed to next.',
    'h_clickCO2B': 'Click the CO₂ Absorber to add it.',
    'h_co2AddedB': 'CO₂ Absorber added to Plant B.',
    'h_proceedNextPlant': 'Proceed to next plant.',
    'h_plantCPlaced': 'Plant C placed.',
    'h_clickCO2D': 'Click the CO₂ Absorber to add it.',
    'h_co2AddedD': 'CO₂ Absorber added to Plant D.',
    'h_sim48h': 'Simulating 48 hours...',
    'h_compare': 'Test complete. Compare the results.',
    'btn_startSim': 'Start Time-Lapse',
    'btn_beginExp': 'Begin 48-Hour Experiment',
    'btn_testAll': 'Test All Leaves',
    'btn_addAbsorber': 'Add CO₂ Absorber',
    // Scene labels.
    'lbl_destarch': 'Destarching for 48 hours',
    'lbl_tap_open': 'Tap the door to open',
    'lbl_caustic': 'Caustic Soda',
    'lbl_cork': 'Split Cork',
    'lbl_boil': 'Boiling Water',
    'lbl_alc': 'Alcohol Tube',
    'lbl_leaf': 'Leaf',
    'lbl_leaf_tip': 'Leaf tip',
    'lbl_water': 'Water',
    'lbl_iodine': 'Iodine Solution',
    'lbl_scissors': 'Scissors',
    'lbl_absorber': 'CO₂ Absorber',
    'lbl_plant': 'Plant {p}',
    'zone_a': 'A: Sunlight + CO₂',
    'zone_b': 'B: Sunlight, No CO₂',
    'zone_c': 'C: Dark + CO₂',
    'zone_d': 'D: Dark, No CO₂',
    'badge_co2': 'CO₂ Available',
    'badge_no_co2': 'No CO₂',
    'starch_present': 'STARCH PRESENT',
    'no_starch': 'NO STARCH',
    'blue_black': 'Blue-Black',
    'brown': 'Brown',
    'outside': 'OUTSIDE (Has CO₂)',
    'inside': 'INSIDE (No CO₂)',
    'hours': '{h} h',
    // Conclusions (HTML `s1_conclusion` / `s2_conclusion`).
    's1_head': 'The Half-Leaf Result',
    's1_body': 'The blue-black color indicates starch presence.',
    's1_p1a': 'Starch was ',
    's1_p1b': 'only',
    's1_p1c': ' produced in the half of the leaf that remained outside in the fresh air.',
    's1_p2':
        'The Caustic Soda inside the wide-mouthed bottle absorbed the CO₂, preventing photosynthesis in the inner half.',
    's1_conc': 'Conclusion: CO₂ is an essential raw material for photosynthesis.',
    's2_head': 'Comparative Analysis',
    's2_body': 'Iodine test results for the leaves of the four plants:',
    'th_plant': 'Plant',
    'th_cond': 'Condition',
    'th_result': 'Result',
    'cond_a': 'Sunlight + CO₂',
    'cond_b': 'Sunlight, No CO₂',
    'cond_c': 'Dark + CO₂',
    'cond_d': 'Dark, No CO₂',
    'res_present': 'Starch Present',
    'res_absent': 'Starch Absent',
    's2_conc': 'Conclusion: BOTH sunlight AND carbon dioxide are strictly required simultaneously.',
    // Extra feedback for wrong drops.
    'err_zone': 'Not here! Plant {p} goes to zone {p}.',
    'err_order': 'Follow the steps: place Plant {p} now.',
  },
  'hi': {
    'app_title': 'प्रकाश संश्लेषण में कार्बन डाइऑक्साइड की भूमिका',
    'app_subtitle': 'कक्षा 7 • पौधों में जैव प्रक्रम',
    'scen_1': '1. आधी-पत्ती प्रयोग',
    'scen_2': '2. चार परिस्थितियाँ',
    'sci_obs': 'वैज्ञानिक निष्कर्ष',
    'h_openCupboard': 'अलमारी खुल गई। पौधे को लैब बेंच पर खींचें।',
    'h_plantPlaced': 'पौधा सही जगह पर रख दिया गया।',
    'h_proceedChem': 'अब रसायनों की ओर बढ़ें।',
    'h_naohAdded': 'NaOH डाला गया। यह CO₂ को अवशोषित करेगा।',
    'h_proceeding': 'आगे बढ़ रहे हैं...',
    'h_corkAttached': 'कॉर्क लग गया! अब पत्ती की नोक को कॉर्क तक खींचें।',
    'h_leafSealed': 'पत्ती बोतल में सफलतापूर्वक सील हो गई।',
    'h_setupReady': 'सेटअप तैयार है।',
    'h_timePass': 'समय बीत रहा है...',
    'h_sim6h': '6 घंटों का अनुकरण...',
    'h_leafCollected': 'पत्ती काटकर एकत्र कर ली गई।',
    'h_proceedStarch': 'स्टार्च परीक्षण की ओर बढ़ें।',
    'h_leafBoiled': 'पत्ती को पानी में उबाला गया।',
    'h_dragAlc': 'अब पत्ती को ऐल्कोहॉल परखनली में खींचें।',
    'h_leafAlc': 'पत्ती ऐल्कोहॉल में रख दी गई।',
    'h_dragWater': 'परखनली को उबलते पानी में खींचें।',
    'h_leafDecolor': 'क्लोरोफिल निकल गया। पत्ती रंगहीन हो गई।',
    'h_starchDone': 'स्टार्च परीक्षण पूरा हुआ।',
    'h_plantAPlaced': 'पौधा A रख दिया गया।',
    'h_proceedNext': 'अगले चरण की ओर बढ़ें।',
    'h_clickCO2B': 'CO₂ अवशोषक जोड़ने के लिए उस पर क्लिक करें।',
    'h_co2AddedB': 'पौधे B के पास CO₂ अवशोषक रख दिया गया।',
    'h_proceedNextPlant': 'अगले पौधे की ओर बढ़ें।',
    'h_plantCPlaced': 'पौधा C रख दिया गया।',
    'h_clickCO2D': 'CO₂ अवशोषक जोड़ने के लिए उस पर क्लिक करें।',
    'h_co2AddedD': 'पौधे D के पास CO₂ अवशोषक रख दिया गया।',
    'h_sim48h': '48 घंटों का अनुकरण...',
    'h_compare': 'परीक्षण पूरा हुआ। परिणामों की तुलना करें।',
    'btn_startSim': 'टाइम-लैप्स शुरू करें',
    'btn_beginExp': '48 घंटे का प्रयोग शुरू करें',
    'btn_testAll': 'सभी पत्तियों का परीक्षण करें',
    'btn_addAbsorber': 'CO₂ अवशोषक जोड़ें',
    'lbl_destarch': '48 घंटे तक स्टार्च हटाना',
    'lbl_tap_open': 'खोलने के लिए दरवाज़े पर टैप करें',
    'lbl_caustic': 'कास्टिक सोडा',
    'lbl_cork': 'चिरा हुआ कॉर्क',
    'lbl_boil': 'उबलता पानी',
    'lbl_alc': 'ऐल्कोहॉल परखनली',
    'lbl_leaf': 'पत्ती',
    'lbl_leaf_tip': 'पत्ती की नोक',
    'lbl_water': 'पानी',
    'lbl_iodine': 'आयोडीन घोल',
    'lbl_scissors': 'कैंची',
    'lbl_absorber': 'CO₂ अवशोषक',
    'lbl_plant': 'पौधा {p}',
    'zone_a': 'A: धूप + CO₂',
    'zone_b': 'B: धूप, CO₂ नहीं',
    'zone_c': 'C: अंधेरा + CO₂',
    'zone_d': 'D: अंधेरा, CO₂ नहीं',
    'badge_co2': 'CO₂ उपलब्ध',
    'badge_no_co2': 'CO₂ नहीं',
    'starch_present': 'स्टार्च मौजूद',
    'no_starch': 'स्टार्च नहीं',
    'blue_black': 'नीला-काला',
    'brown': 'भूरा',
    'outside': 'बाहर (CO₂ मिली)',
    'inside': 'अंदर (CO₂ नहीं)',
    'hours': '{h} घंटे',
    's1_head': 'आधी-पत्ती का परिणाम',
    's1_body': 'नीला-काला रंग स्टार्च की उपस्थिति दर्शाता है।',
    's1_p1a': 'स्टार्च ',
    's1_p1b': 'केवल',
    's1_p1c': ' पत्ती के उस आधे भाग में बना जो बाहर ताज़ी हवा में रहा।',
    's1_p2':
        'चौड़े मुँह वाली बोतल के अंदर कास्टिक सोडा ने CO₂ को अवशोषित कर लिया, जिससे पत्ती के अंदर वाले आधे भाग में प्रकाश संश्लेषण नहीं हो सका।',
    's1_conc': 'निष्कर्ष: CO₂ प्रकाश संश्लेषण के लिए एक आवश्यक कच्चा माल है।',
    's2_head': 'तुलनात्मक विश्लेषण',
    's2_body': 'चारों पौधों की पत्तियों पर आयोडीन परीक्षण के परिणाम:',
    'th_plant': 'पौधा',
    'th_cond': 'परिस्थिति',
    'th_result': 'परिणाम',
    'cond_a': 'धूप + CO₂',
    'cond_b': 'धूप, CO₂ नहीं',
    'cond_c': 'अंधेरा + CO₂',
    'cond_d': 'अंधेरा, CO₂ नहीं',
    'res_present': 'स्टार्च मौजूद',
    'res_absent': 'स्टार्च अनुपस्थित',
    's2_conc': 'निष्कर्ष: धूप और कार्बन डाइऑक्साइड, दोनों का एक साथ होना आवश्यक है।',
    'err_zone': 'यहाँ नहीं! पौधा {p} क्षेत्र {p} में जाएगा।',
    'err_order': 'चरणों का पालन करें: अभी पौधा {p} रखें।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually demonstrate that the part of a leaf deprived of carbon dioxide cannot perform photosynthesis and produce starch.',
      steps: [
        LabStep(
          concept: 'Preparation',
          action:
              'The lab opens with a healthy potted plant inside a dark cupboard. CLICK the cupboard door to open it. DRAG the potted plant onto the lab bench.',
          observation: 'The plant is moved from the dark cupboard to the brightly lit lab bench.',
        ),
        LabStep(
          concept: 'Chemical Setup',
          action:
              "DRAG the bottle of 'Caustic Soda' and DROP it over the wide-mouthed bottle. The solution will automatically pour.",
          observation: 'The bottle is now filled with caustic soda (NaOH) to absorb CO₂.',
        ),
        LabStep(
          concept: 'Leaf Insertion',
          action:
              'DRAG the split cork and DROP it onto the bottle. Now, DRAG the target leaf tip and guide it into the cork.',
          observation:
              'Half of the leaf is sealed inside the bottle (CO₂-free), while the other half remains outside attached to the plant.',
        ),
        LabStep(
          concept: 'Photosynthesis Phase',
          action: "The setup is ready on the windowsill. CLICK the 'Start Time-Lapse' button.",
          observation: 'A 6-hour time-lapse is simulated showing sunlight exposure.',
        ),
        LabStep(
          concept: 'Leaf Collection',
          action: 'DRAG the scissors tool to the leaf to snip it off. The leaf is placed in a petri dish.',
          observation: 'The experimental leaf is detached for testing.',
        ),
        LabStep(
          concept: 'Decolorization',
          action:
              "First, DRAG the petri dish into the 'Boiling Water'. Second, DRAG the softened leaf into the 'Alcohol Tube'. Third, DRAG the tube back into the 'Boiling Water'.",
          observation: 'The leaf becomes pale and colorless, chlorophyll is removed.',
        ),
        LabStep(
          concept: 'Iodine Application',
          action: "The leaf is decolorized. DRAG the 'Iodine Solution' dropper and DROP it over the leaf.",
          observation: 'Iodine solution covers the entire leaf.',
        ),
        LabStep(
          concept: 'Observation',
          action: 'Observe the result. The outside part turns blue-black, inside part remains brown.',
          observation: 'Clear visual confirmation that starch requires CO₂.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To compare the effects of sunlight and carbon dioxide on photosynthesis by setting up four parallel experiments.',
      steps: [
        LabStep(
          concept: 'Control (Plant A)',
          action: "DRAG Plant A to the area labeled 'Sunlight + CO₂'.",
          observation: 'Plant A is placed in optimal conditions.',
        ),
        LabStep(
          concept: 'No CO₂ (Plant B)',
          action:
              "DRAG Plant B to 'Sunlight, No CO₂'. A glass bell jar will cover it. CLICK the 'CO₂ Absorber' dish to add it.",
          observation: 'Plant B has sunlight but is in a CO₂-free environment.',
        ),
        LabStep(
          concept: 'Dark (Plant C)',
          action: "DRAG Plant C to 'Dark + CO₂'. It will be placed inside a ventilated dark box.",
          observation: 'Plant C has CO₂ from the air, but no sunlight.',
        ),
        LabStep(
          concept: 'Deprived (Plant D)',
          action:
              "DRAG Plant D to 'Dark, No CO₂'. It enters a sealed dark box. CLICK the 'CO₂ Absorber' to add it.",
          observation: 'Plant D lacks both sunlight and CO₂.',
        ),
        LabStep(
          concept: 'Experiment Simulation',
          action: "CLICK the 'Begin 48-Hour Experiment' button.",
          observation: 'Time-lapse shows plant responses over two days.',
        ),
        LabStep(
          concept: 'Iodine Test',
          action: "Click 'Test All Leaves'.",
          observation: 'Starch presence is revealed simultaneously.',
        ),
        LabStep(
          concept: 'Conclusion',
          action: 'Analyze the comparative results.',
          observation: 'Determine which conditions are strictly necessary.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह दिखाना कि पत्ती का जो भाग कार्बन डाइऑक्साइड से वंचित रहता है, वह प्रकाश संश्लेषण नहीं कर पाता और स्टार्च नहीं बनाता।',
      steps: [
        LabStep(
          concept: 'तैयारी',
          action:
              'प्रयोगशाला एक अंधेरी अलमारी में रखे स्वस्थ गमले वाले पौधे के साथ शुरू होती है। अलमारी का दरवाज़ा खोलने के लिए उस पर क्लिक करें। फिर गमले वाले पौधे को लैब बेंच पर खींचें।',
          observation: 'पौधे को अंधेरी अलमारी से तेज़ रोशनी वाली लैब बेंच पर ले जाया जाता है।',
        ),
        LabStep(
          concept: 'रासायनिक सेटअप',
          action:
              "'कास्टिक सोडा' की बोतल को खींचें और चौड़े मुँह वाली बोतल के ऊपर छोड़ें। घोल अपने आप बोतल में डल जाएगा।",
          observation: 'अब बोतल में CO₂ को अवशोषित करने के लिए कास्टिक सोडा (NaOH) भरा है।',
        ),
        LabStep(
          concept: 'पत्ती डालना',
          action: 'चिरे हुए कॉर्क को खींचकर बोतल पर छोड़ें। अब पत्ती की नोक को खींचें और उसे कॉर्क में डालें।',
          observation:
              'पत्ती का आधा भाग बोतल के अंदर (CO₂-रहित) बंद हो जाता है, जबकि दूसरा आधा भाग पौधे से जुड़ा हुआ बाहर रहता है।',
        ),
        LabStep(
          concept: 'प्रकाश संश्लेषण चरण',
          action: "सेटअप खिड़की के पास तैयार है। 'टाइम-लैप्स शुरू करें' बटन पर क्लिक करें।",
          observation: 'धूप में रखे सेटअप का 6 घंटे का टाइम-लैप्स दिखाया जाता है।',
        ),
        LabStep(
          concept: 'पत्ती संग्रह',
          action: 'पत्ती को काटने के लिए कैंची को पत्ती तक खींचें। पत्ती पेट्री डिश में रखी जाती है।',
          observation: 'प्रायोगिक पत्ती परीक्षण के लिए अलग कर ली गई है।',
        ),
        LabStep(
          concept: 'रंग हटाना',
          action:
              "पहले, पेट्री डिश को 'उबलते पानी' में खींचें। दूसरा, नरम पत्ती को 'ऐल्कोहॉल परखनली' में खींचें। तीसरा, परखनली को वापस 'उबलते पानी' में खींचें।",
          observation: 'पत्ती पीली और रंगहीन हो जाती है, क्लोरोफिल निकल जाता है।',
        ),
        LabStep(
          concept: 'आयोडीन डालना',
          action: "पत्ती रंगहीन हो गई है। 'आयोडीन घोल' के ड्रॉपर को खींचकर पत्ती के ऊपर छोड़ें।",
          observation: 'आयोडीन का घोल पूरी पत्ती को ढक लेता है।',
        ),
        LabStep(
          concept: 'अवलोकन',
          action: 'परिणाम देखें। बाहर वाला भाग नीला-काला हो जाता है, अंदर वाला भाग भूरा रहता है।',
          observation: 'स्पष्ट दृश्य पुष्टि कि स्टार्च बनने के लिए CO₂ आवश्यक है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'चार समानांतर प्रयोग करके प्रकाश संश्लेषण पर धूप और कार्बन डाइऑक्साइड के प्रभावों की तुलना करना।',
      steps: [
        LabStep(
          concept: 'नियंत्रण (पौधा A)',
          action: "पौधे A को 'धूप + CO₂' वाले क्षेत्र में खींचें।",
          observation: 'पौधा A सबसे अनुकूल परिस्थितियों में रखा गया है।',
        ),
        LabStep(
          concept: 'CO₂ नहीं (पौधा B)',
          action:
              "पौधे B को 'धूप, CO₂ नहीं' में खींचें। काँच का बेल जार उसे ढक लेगा। 'CO₂ अवशोषक' डिश जोड़ने के लिए उस पर क्लिक करें।",
          observation: 'पौधे B को धूप मिलती है, लेकिन वह CO₂-रहित वातावरण में है।',
        ),
        LabStep(
          concept: 'अंधेरा (पौधा C)',
          action: "पौधे C को 'अंधेरा + CO₂' में खींचें। इसे हवादार अंधेरे बक्से के अंदर रखा जाएगा।",
          observation: 'पौधे C को हवा से CO₂ मिलती है, लेकिन धूप नहीं।',
        ),
        LabStep(
          concept: 'वंचित (पौधा D)',
          action:
              "पौधे D को 'अंधेरा, CO₂ नहीं' में खींचें। यह एक बंद अंधेरे बक्से में जाएगा। 'CO₂ अवशोषक' जोड़ने के लिए उस पर क्लिक करें।",
          observation: 'पौधे D को न धूप मिलती है, न CO₂।',
        ),
        LabStep(
          concept: 'प्रयोग अनुकरण',
          action: "'48 घंटे का प्रयोग शुरू करें' बटन पर क्लिक करें।",
          observation: 'टाइम-लैप्स दो दिनों में पौधों की प्रतिक्रिया दिखाता है।',
        ),
        LabStep(
          concept: 'आयोडीन परीक्षण',
          action: "'सभी पत्तियों का परीक्षण करें' पर क्लिक करें।",
          observation: 'स्टार्च की उपस्थिति एक साथ दिखाई देती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: 'तुलनात्मक परिणामों का विश्लेषण करें।',
          observation: 'तय करें कि कौन-सी परिस्थितियाँ पूरी तरह आवश्यक हैं।',
        ),
      ],
    ),
  ],
};

// ===================================================================== STATE

const Size _design = Size(900, 600);

/// Objects the learner can pick up and drag (HTML `.draggable` elements).
enum _Item {
  plant,
  caustic,
  cork,
  leafTip,
  scissors,
  petri,
  leaf,
  tube,
  dropper,
  plantA,
  plantB,
  plantC,
  plantD,
}

const List<_Item> _s2Plants = [_Item.plantA, _Item.plantB, _Item.plantC, _Item.plantD];
const List<String> _letters = ['A', 'B', 'C', 'D'];

/// Size of each draggable (design px); positions are their centres.
Size _itemSize(_Item it) => switch (it) {
      _Item.plant => const Size(140, 168),
      _Item.caustic => const Size(60, 84),
      _Item.cork => const Size(50, 40),
      _Item.leafTip => const Size(52, 52),
      _Item.scissors => const Size(64, 64),
      _Item.petri => const Size(146, 52),
      _Item.leaf => const Size(_dishLeafW, _dishLeafW / 2),
      _Item.tube => const Size(52, 144),
      _Item.dropper => const Size(85, 85),
      _ => const Size(100, 120),
    };

// ---- Scenario 1: cupboard, bench, bottle (HTML `render2DScene()` layout,
// enlarged so the half-leaf can really pass through the cork).
const Rect _closetRect = Rect.fromLTWH(30, 96, 300, 380);
const double _closetShelfY = 150;
const double _plantScaleS1 = 1.4;
const Offset _plantClosetCenter = Offset(180, 380);
const Offset _plantBenchCenter = Offset(370, 396);
const Rect _benchZone = Rect.fromLTWH(316, 196, 464, 284);
// Wide-mouthed bottle standing on a wooden block beside the plant, so its
// mouth is at the height of the experimental leaf.
const double _bottleX = 478;
const double _bottleBottom = 438;
const double _mouthY = 310;
const Rect _bottleBlock = Rect.fromLTWH(_bottleX - 54, _bottleBottom, 108, 38);
const Offset _corkSeat = Offset(_bottleX, _mouthY - 2);
const Rect _bottleRect = Rect.fromLTRB(_bottleX - 46, _mouthY - 12, _bottleX + 46, _bottleBottom + 30);
const Rect _bottleTopRect = Rect.fromLTRB(_bottleX - 38, _mouthY - 26, _bottleX + 38, _mouthY + 22);
const Offset _causticHome = Offset(732, 262);
const Offset _pourCenter = Offset(_bottleX + 49, _mouthY - 45);
const Offset _corkHome = Offset(728, 270);
const Offset _scissorsHome = Offset(726, 262);
const Rect _leafCutZone = Rect.fromLTRB(384, 268, 486, 352);
const Offset _snipPoint = Offset(396, 334);

// ---- Scenario 1: starch test bench.
const double _beakerK = 1.6; // HTML beaker (viewBox 100×150) scale
const Rect _beakerBox = Rect.fromLTWH(120, 256, 100 * _beakerK, 150 * _beakerK);
const Rect _beakerZone = Rect.fromLTWH(160, 268, 80, 134);
const Offset _petriHome = Offset(420, 452);
const Offset _leafDish = Offset(420, 447);
const double _dishLeafW = 100;
const Offset _leafBeaker = Offset(200, 370);
const double _beakerLeafW = 60;
const Offset _tubeHome = Offset(620, 380);
const Offset _tubeBath = Offset(200, 320);
const double _dropperK = 0.85;
const Offset _dropperHome = Offset(728, 386);
const Offset _dropperOverLeaf = Offset(422, 362);
const Offset _dropperTip = Offset(48 * _dropperK - 50 * _dropperK, 95 * _dropperK - 50 * _dropperK);

// ---- Scenario 2: four condition zones above a shelf of plants.
const List<Rect> _zones = [
  Rect.fromLTWH(45, 15, 380, 162),
  Rect.fromLTWH(445, 15, 380, 162),
  Rect.fromLTWH(45, 187, 380, 162),
  Rect.fromLTWH(445, 187, 380, 162),
];
const List<Offset> _shelfHomes = [Offset(200, 440), Offset(367, 440), Offset(533, 440), Offset(700, 440)];
const double _zonePlantScale = 0.65;

// ---- The experimental leaf of scenario 1, as a spine relative to the
// plant centre: free (pointing up), dragged by its tip, or bent through the
// split cork with its distal half inside the bottle.
const int _leafN = 40;
const Offset _stemRel = Offset(0, -50);
const Offset _baseRel = Offset(40, -66);
const Offset _corkRel = Offset(_bottleX - 370, _mouthY - 396 + 6);

final List<Offset> _insertedSpine = _resample([
  for (var i = 0; i <= 40; i++) _cubic(_baseRel, const Offset(50, -104), const Offset(108, -134), _corkRel, i / 40),
  for (var i = 1; i <= 24; i++) Offset.lerp(_corkRel, _corkRel + const Offset(0, 72), i / 24)!,
], _leafN);
final double _leafLen = _polyLength(_insertedSpine);
final Offset _freeTipRel = _baseRel + Offset(math.cos(1.0), -math.sin(1.0)) * (_leafLen * 0.95);
final List<Offset> _freeSpine = _arcSpine(_freeTipRel);

Offset _cubic(Offset a, Offset b, Offset c, Offset d, double t) {
  final u = 1 - t;
  return a * (u * u * u) + b * (3 * u * u * t) + c * (3 * u * t * t) + d * (t * t * t);
}

double _polyLength(List<Offset> pts) {
  var len = 0.0;
  for (var i = 1; i < pts.length; i++) {
    len += (pts[i] - pts[i - 1]).distance;
  }
  return len;
}

/// Resamples a polyline into [n] points evenly spaced along its length.
List<Offset> _resample(List<Offset> pts, int n) {
  final cum = <double>[0];
  for (var i = 1; i < pts.length; i++) {
    cum.add(cum.last + (pts[i] - pts[i - 1]).distance);
  }
  final total = cum.last;
  final out = <Offset>[];
  var j = 1;
  for (var i = 0; i < n; i++) {
    final d = total * i / (n - 1);
    while (j < pts.length - 1 && cum[j] < d) {
      j++;
    }
    final seg = cum[j] - cum[j - 1];
    final f = seg <= 0 ? 0.0 : ((d - cum[j - 1]) / seg).clamp(0.0, 1.0);
    out.add(Offset.lerp(pts[j - 1], pts[j], f)!);
  }
  return out;
}

/// Leaf spine from the base to [tipRel]: a bow that keeps the blade at its
/// natural length (it arches up when the tip is pushed towards the base).
List<Offset> _arcSpine(Offset tipRel) {
  var tip = tipRel;
  final d0 = tip - _baseRel;
  if (d0.distance > _leafLen) tip = _baseRel + d0 / d0.distance * _leafLen;
  final d = tip - _baseRel;
  final c = math.max(d.distance, 1.0);
  final s = math.sqrt(math.max(0.0, 3 * c * (_leafLen - c) / 8));
  final h = math.min(2 * s, 190.0);
  var n = Offset(d.dy, -d.dx) / c;
  if (n.dy > 0) n = -n;
  final ctrl = Offset.lerp(_baseRel, tip, 0.5)! + n * h;
  return _resample([
    for (var i = 0; i <= 48; i++) _quad(_baseRel, ctrl, tip, i / 48),
  ], _leafN);
}

Offset _quad(Offset a, Offset b, Offset c, double t) {
  final u = 1 - t;
  return a * (u * u) + b * (2 * u * t) + c * (t * t);
}

/// Linear tween between two positions (replaces the HTML CSS transitions).
class _Move {
  const _Move(this.from, this.to, this.start, this.dur, this.curve);
  final Offset from;
  final Offset to;
  final double start;
  final double dur;
  final Curve curve;

  double progress(double t) => dur <= 0 ? 1 : ((t - start) / dur).clamp(0.0, 1.0);
  Offset at(double t) => Offset.lerp(from, to, curve.transform(progress(t)))!;
}

/// Morph of the leaf spine (insert into the cork / spring back).
class _LeafAnim {
  const _LeafAnim(this.from, this.to, this.start, this.dur);
  final List<Offset> from;
  final List<Offset> to;
  final double start;
  final double dur;

  bool running(double t) => t < start + dur;

  List<Offset> at(double t) {
    final k = Curves.easeInOutCubic.transform(((t - start) / dur).clamp(0.0, 1.0));
    return [for (var i = 0; i < to.length; i++) Offset.lerp(from[i], to[i], k)!];
  }
}

/// Mutable scene model read by the painter every frame (HTML `state`).
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  /// True while an accepted action plays out (no new drags).
  bool busy = false;

  // ---- dragging
  final Map<_Item, Offset> pos = {};
  final Map<_Item, _Move> moves = {};
  _Item? drag;
  Offset grab = Offset.zero;
  Offset dragFrom = Offset.zero;

  // ---- scenario 1 (HTML `s1_prog` + transient DOM state)
  bool closetOpen = false;
  double? doorAt;
  bool plantOnBench = false;
  double? pourAt;
  bool causticDone = false;
  bool corkOn = false;
  Offset? tipDrag;
  _LeafAnim? leafAnim;
  bool leafIn = false;
  double? simAt;
  double? cutAt;
  bool leafBoiled = false;
  bool leafAlcohol = false;
  double? bathAt;
  bool decolorized = false;
  double? iodineAt;
  double? resultAt;

  // ---- scenario 2 (HTML `s2_prog`)
  final Map<int, double> placedAt = {};
  final Map<int, Offset> placedFrom = {};
  int? waitingDish;
  double? dishBAt;
  double? dishDAt;
  double? testAt;

  Offset posOf(_Item it) => moves[it]?.at(time) ?? pos[it] ?? Offset.zero;

  void moveTo(_Item it, Offset to, {double dur = 0.35, Curve curve = Curves.easeOutCubic}) {
    moves[it] = _Move(posOf(it), to, time, dur, curve);
    pos[it] = to;
  }

  /// 0..1 progress of a timed effect that started at [start].
  double prog(double? start, double dur) => start == null ? 0 : ((time - start) / dur).clamp(0.0, 1.0);

  /// The experimental leaf's spine relative to the plant centre.
  List<Offset> leafSpine() {
    final a = leafAnim;
    if (a != null && a.running(time)) return a.at(time);
    final tip = tipDrag;
    if (tip != null) return _arcSpine(tip - _plantBenchCenter);
    return leafIn ? _insertedSpine : _freeSpine;
  }

  Offset get leafTip => _plantBenchCenter + leafSpine().last;
}

/// Where a dragged scenario 1 item must be dropped (HTML `.dropzone`).
Rect? _s1Target(_Item it) => switch (it) {
      _Item.plant => _benchZone,
      _Item.caustic => _bottleRect,
      _Item.cork => _bottleTopRect,
      _Item.leafTip => Rect.fromCircle(center: _corkSeat, radius: 30),
      _Item.scissors => _leafCutZone,
      _Item.petri || _Item.tube => _beakerZone,
      _Item.leaf => Rect.fromCenter(center: _tubeHome, width: 52, height: 144),
      _Item.dropper => Rect.fromCenter(center: _leafDish, width: _dishLeafW, height: _dishLeafW / 2),
      _ => null,
    };

/// Index of the scenario 2 zone containing [p], if any.
int? _zoneAt(Offset p) {
  for (var i = 0; i < _zones.length; i++) {
    if (_zones[i].inflate(12).contains(p)) return i;
  }
  return null;
}

/// Centre of the CO₂ absorber dish waiting to be clicked in zone B / D.
Offset _dishWaitCenter(int zone) {
  final r = _zones[zone];
  return zone == 1 ? Offset(r.right - 62, r.bottom - 46) : Offset(r.left + 62, r.bottom - 46);
}

/// A pan recognizer that only claims pointers that land on a draggable.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch10A3RoleOfCarbonDioxideInPhotosynthesisPageState
    extends State<Ch10A3RoleOfCarbonDioxideInPhotosynthesisPage> with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  _Scene _scene = _Scene();
  final _Confetti _confetti = _Confetti();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _resetScene(0);
    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      _scene.time = t;
      _confetti.update(t);
      _frame.value = t;
    })..start();
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

  // ------------------------------------------------------------ logic

  /// HTML `loadScenario()`: fresh progress, every object back home.
  void _resetScene(int scenario) {
    final time = _scene.time;
    final s = _Scene()
      ..scenario = scenario
      ..time = time;
    if (scenario == 0) {
      s.pos
        ..[_Item.plant] = _plantClosetCenter
        ..[_Item.caustic] = _causticHome
        ..[_Item.cork] = _corkHome
        ..[_Item.scissors] = _scissorsHome
        ..[_Item.petri] = _petriHome
        ..[_Item.leaf] = _leafDish
        ..[_Item.tube] = _tubeHome
        ..[_Item.dropper] = _dropperHome;
    } else {
      for (var i = 0; i < 4; i++) {
        s.pos[_s2Plants[i]] = _shelfHomes[i];
      }
    }
    _scene = s;
    _confetti.clear();
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.cancelPending();
      _lab.hidePopup(sound: false);
      _resetScene(index);
      _lab.resetView(sound: false);
    });
  }

  void _fullReset() {
    setState(() => _resetScene(0));
  }

  /// Feedback chip of the HTML HUD (instruction + feedback joined).
  void _say(List<String> keys, {bool error = false, Map<String, Object> args = const {}}) {
    final text = labFormat(keys.map(_t).join(' '), args);
    _lab.showToast(text, isError: error, sound: error);
  }

  /// HTML `setTimeout`, ignored once the scenario has been reset.
  void _later(double seconds, VoidCallback fn) {
    final scene = _scene;
    _lab.after(Duration(milliseconds: (seconds * 1000).round()), () {
      if (!mounted || !identical(scene, _scene)) return;
      fn();
      setState(() {});
    });
  }

  /// HTML `completeStep(n)` after a delay.
  void _advanceAfter(double seconds, int step, [VoidCallback? then]) {
    final scene = _scene..busy = true;
    _later(seconds, () {
      scene
        ..step = step
        ..busy = false
        ..simAt = null;
      then?.call();
    });
  }

  // ---- scenario 1

  void _openCupboard() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 1 || s.closetOpen) return;
    _Audio.play(_Sound.click);
    setState(() {
      s.closetOpen = true;
      s.doorAt = s.time;
    });
    _say(['h_openCupboard']);
  }

  void _placePlantOnBench() {
    final s = _scene;
    _Audio.play(_Sound.drop);
    s.plantOnBench = true;
    s.moveTo(_Item.plant, _plantBenchCenter, dur: 0.35);
    _say(['h_plantPlaced', 'h_proceedChem']);
    _advanceAfter(1.0, 2);
  }

  void _pourCaustic() {
    final s = _scene;
    _Audio.play(_Sound.drop);
    s
      ..busy = true
      ..pourAt = s.time
      ..moveTo(_Item.caustic, _pourCenter, dur: 0.35);
    _later(0.35, () => _Audio.play(_Sound.splash, volume: 0.35));
    _later(1.85, () {
      s.causticDone = true;
      _say(['h_naohAdded', 'h_proceeding']);
      _advanceAfter(1.5, 3);
    });
  }

  void _attachCork() {
    final s = _scene;
    _Audio.play(_Sound.drop);
    s
      ..corkOn = true
      ..moveTo(_Item.cork, _corkSeat, dur: 0.3);
    _say(['h_corkAttached']);
  }

  void _insertLeaf(List<Offset> from) {
    final s = _scene;
    _Audio.play(_Sound.drop);
    s
      ..leafIn = true
      ..tipDrag = null
      ..leafAnim = _LeafAnim(from, _insertedSpine, s.time, 1.0);
    _say(['h_leafSealed', 'h_setupReady']);
    _advanceAfter(1.5, 4);
  }

  void _startS1Sim() {
    final s = _scene;
    if (s.scenario != 0 || s.step != 4 || s.simAt != null) return;
    setState(() => s.simAt = s.time);
    _say(['h_timePass', 'h_sim6h']);
    _advanceAfter(2.5, 5);
  }

  void _snipLeaf() {
    final s = _scene;
    _Audio.play(_Sound.snip);
    s
      ..cutAt = s.time
      ..moveTo(_Item.scissors, _snipPoint, dur: 0.25);
    _say(['h_leafCollected', 'h_proceedStarch']);
    _advanceAfter(1.5, 6);
  }

  void _boilLeaf() {
    final s = _scene;
    _Audio.play(_Sound.drop);
    _Audio.play(_Sound.bubble, volume: 0.45);
    final onDish = s.posOf(_Item.petri) + (_leafDish - _petriHome);
    s
      ..leafBoiled = true
      ..moveTo(_Item.petri, _petriHome, dur: 0.45);
    s.pos[_Item.leaf] = onDish;
    s.moveTo(_Item.leaf, _leafBeaker, dur: 0.5);
    _say(['h_leafBoiled', 'h_dragAlc']);
  }

  void _leafToAlcohol() {
    final s = _scene;
    _Audio.play(_Sound.drop);
    s.leafAlcohol = true;
    s.pos[_Item.leaf] = _tubeHome;
    s.moves.remove(_Item.leaf);
    _say(['h_leafAlc', 'h_dragWater']);
  }

  void _tubeToBath() {
    final s = _scene;
    _Audio.play(_Sound.drop);
    _Audio.play(_Sound.bubble, volume: 0.45);
    s
      ..busy = true
      ..bathAt = s.time
      ..moveTo(_Item.tube, _tubeBath, dur: 0.35);
    _later(1.5, () {
      s
        ..decolorized = true
        ..moveTo(_Item.tube, _tubeHome, dur: 0.5);
      s.pos[_Item.leaf] = _tubeBath + const Offset(0, 8);
      s.moveTo(_Item.leaf, _leafDish, dur: 0.6);
      _say(['h_leafDecolor', 'h_proceeding']);
      _advanceAfter(1.5, 7);
    });
  }

  void _applyIodine() {
    final s = _scene;
    _Audio.play(_Sound.click);
    s
      ..busy = true
      ..iodineAt = s.time
      ..moveTo(_Item.dropper, _dropperOverLeaf, dur: 0.5);
    _later(1.5, () {
      _Audio.play(_Sound.success);
      _say(['h_starchDone']);
      _advanceAfter(2.0, 8, () {
        s.resultAt = s.time;
        _finishScenario();
      });
    });
  }

  // ---- scenario 2

  void _dropPlant(int plant, Offset at) {
    final s = _scene;
    final item = _s2Plants[plant];
    final zone = _zoneAt(at);
    if (zone == null) {
      s.moveTo(item, s.dragFrom, dur: 0.3);
      return;
    }
    final expected = s.step - 1;
    if (zone != plant || plant != expected) {
      final letter = _letters[zone != plant ? plant : expected];
      _say([zone != plant ? 'err_zone' : 'err_order'], error: true, args: {'p': letter});
      s.moveTo(item, s.dragFrom, dur: 0.3);
      return;
    }
    _Audio.play(_Sound.drop);
    s.placedAt[plant] = s.time;
    s.placedFrom[plant] = at;
    switch (plant) {
      case 0:
        _say(['h_plantAPlaced', 'h_proceedNext']);
        _advanceAfter(1.0, 2);
      case 1:
        s.waitingDish = 1;
        _say(['h_clickCO2B']);
      case 2:
        _say(['h_plantCPlaced', 'h_proceedNext']);
        _advanceAfter(1.0, 4);
      default:
        s.waitingDish = 3;
        _say(['h_clickCO2D']);
    }
  }

  /// HTML `clickS2Dish(type)`.
  void _addDish() {
    final s = _scene;
    final zone = s.waitingDish;
    if (s.scenario != 1 || zone == null) return;
    _Audio.play(_Sound.drop);
    setState(() {
      s.waitingDish = null;
      if (zone == 1) {
        s.dishBAt = s.time;
        _say(['h_co2AddedB', 'h_proceedNextPlant']);
        _advanceAfter(1.0, 3);
      } else {
        s.dishDAt = s.time;
        _say(['h_co2AddedD']);
        _advanceAfter(1.0, 5);
      }
    });
  }

  /// HTML `triggerS2Sim()`.
  void _startS2Sim() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 5 || s.simAt != null) return;
    setState(() => s.simAt = s.time);
    _say(['h_sim48h']);
    _advanceAfter(3.0, 6);
  }

  /// HTML `applyIodineS2()`.
  void _testAll() {
    final s = _scene;
    if (s.scenario != 1 || s.step != 6 || s.testAt != null) return;
    setState(() {
      s
        ..testAt = s.time
        ..busy = true;
    });
    _later(1.0, () {
      _Audio.play(_Sound.success);
      _say(['h_compare']);
      _advanceAfter(2.5, 7, _finishScenario);
    });
  }

  /// HTML: `showObservation(conclusion)` + `confetti(...)` one second after
  /// the final step renders.
  void _finishScenario() {
    final scenario = _scene.scenario;
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 1000),
      title: () => _t('sci_obs'),
      heading: () => _t(scenario == 0 ? 's1_head' : 's2_head'),
      body: () => _t(scenario == 0 ? 's1_body' : 's2_body'),
      extra: () => scenario == 0 ? _s1Extra() : _s2Extra(),
    );
    _later(1.0, () {
      _confetti.burst(
        count: scenario == 0 ? 100 : 150,
        spread: scenario == 0 ? 70 : 90,
        originY: scenario == 0 ? 0.6 : 0.5,
      );
    });
  }

  // ---------------------------------------------------------- gestures

  List<_Item> _draggables() {
    final s = _scene;
    if (s.busy) return const [];
    if (s.scenario == 0) {
      return switch (s.step) {
        1 => [if (s.closetOpen && !s.plantOnBench) _Item.plant],
        2 => [if (s.pourAt == null) _Item.caustic],
        3 => [
            if (!s.corkOn) _Item.cork,
            if (s.corkOn && !s.leafIn && !(s.leafAnim?.running(s.time) ?? false)) _Item.leafTip,
          ],
        5 => [if (s.cutAt == null) _Item.scissors],
        6 => [
            if (!s.leafBoiled) _Item.petri,
            if (s.leafBoiled && !s.leafAlcohol) _Item.leaf,
            if (s.leafAlcohol && s.bathAt == null) _Item.tube,
          ],
        7 => [if (s.iodineAt == null) _Item.dropper],
        _ => const [],
      };
    }
    if (s.step > 4 || s.waitingDish != null) return const [];
    return [
      for (var i = 0; i < 4; i++)
        if (!s.placedAt.containsKey(i)) _s2Plants[i],
    ];
  }

  Rect _hitRect(_Item it) {
    final s = _scene;
    if (it == _Item.leafTip) return Rect.fromCircle(center: s.leafTip, radius: 32);
    final c = s.posOf(it);
    if (it == _Item.leaf) return Rect.fromCenter(center: c, width: _beakerLeafW, height: _beakerLeafW / 2).inflate(14);
    final size = _itemSize(it);
    return Rect.fromCenter(center: c, width: size.width, height: size.height).inflate(8);
  }

  _Item? _hitItem(Offset p) {
    for (final it in _draggables().reversed) {
      if (_hitRect(it).contains(p)) return it;
    }
    return null;
  }

  void _grab(Offset p) {
    final it = _hitItem(p);
    if (it == null) return;
    final s = _scene;
    _Audio.play(_Sound.pickup, volume: 0.5);
    setState(() {
      s.drag = it;
      if (it == _Item.leafTip) {
        final tip = s.leafTip;
        s
          ..tipDrag = tip
          ..leafAnim = null
          ..grab = p - tip;
      } else {
        final c = s.posOf(it);
        s.moves.remove(it);
        s.pos[it] = c;
        s
          ..grab = p - c
          ..dragFrom = c;
      }
    });
  }

  void _dragTo(Offset p) {
    final s = _scene;
    final it = s.drag;
    if (it == null) return;
    final q = Offset(
      (p.dx - s.grab.dx).clamp(0.0, _design.width),
      (p.dy - s.grab.dy).clamp(0.0, _design.height),
    );
    if (it == _Item.leafTip) {
      s.tipDrag = q;
    } else {
      s.pos[it] = q;
    }
  }

  void _release() {
    final s = _scene;
    final it = s.drag;
    if (it == null) return;
    s.drag = null;
    setState(() => _drop(it));
  }

  /// HTML `handleOrganicDrop(dragId, dropId)`: right target → action,
  /// otherwise the item glides back to where it was picked up.
  void _drop(_Item it) {
    final s = _scene;
    if (s.scenario == 1) {
      _dropPlant(_s2Plants.indexOf(it), s.pos[it]!);
      return;
    }
    if (it == _Item.leafTip) {
      final tip = s.tipDrag ?? s.leafTip;
      final from = _arcSpine(tip - _plantBenchCenter);
      if ((tip - _corkSeat).distance < 64) {
        _insertLeaf(from);
      } else {
        s
          ..tipDrag = null
          ..leafAnim = _LeafAnim(from, _freeSpine, s.time, 0.35);
      }
      return;
    }
    final c = s.pos[it]!;
    final target = _s1Target(it);
    if (target != null && target.inflate(24).contains(c)) {
      switch (it) {
        case _Item.plant:
          _placePlantOnBench();
        case _Item.caustic:
          _pourCaustic();
        case _Item.cork:
          _attachCork();
        case _Item.scissors:
          _snipLeaf();
        case _Item.petri:
          _boilLeaf();
        case _Item.leaf:
          _leafToAlcohol();
        case _Item.tube:
          _tubeToBath();
        case _Item.dropper:
          _applyIodine();
        default:
          break;
      }
      return;
    }
    s.moveTo(it, s.dragFrom, dur: 0.3);
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final s = _scene;
    final p = d.localPosition;
    if (s.scenario == 0 && s.step == 1 && !s.closetOpen && _closetRect.inflate(8).contains(p)) {
      _openCupboard();
      return;
    }
    final zone = s.waitingDish;
    if (s.scenario == 1 && zone != null) {
      final r = Rect.fromCenter(center: _dishWaitCenter(zone), width: 48, height: 22).inflate(22);
      if (r.contains(p)) _addDish();
    }
  }

  List<LabAction> _actions() {
    final s = _scene;
    if (s.scenario == 0) {
      if (s.step == 4) {
        return [
          LabAction(
            label: _t('btn_startSim'),
            icon: Icons.hourglass_top_rounded,
            foreground: _Colors.slate900,
            highlight: s.simAt == null,
            enabled: s.simAt == null,
            onTap: _startS1Sim,
          ),
        ];
      }
      return const [];
    }
    if (s.waitingDish != null) {
      return [
        LabAction(
          label: _t('btn_addAbsorber'),
          icon: Icons.add_circle_outline,
          color: _Colors.blue500,
          foreground: Colors.white,
          highlight: true,
          silent: true, // plays the HTML "drop" tone itself
          onTap: _addDish,
        ),
      ];
    }
    if (s.step == 5) {
      return [
        LabAction(
          label: _t('btn_beginExp'),
          icon: Icons.play_arrow_rounded,
          foreground: _Colors.slate900,
          highlight: s.simAt == null,
          enabled: s.simAt == null,
          onTap: _startS2Sim,
        ),
      ];
    }
    if (s.step == 6) {
      return [
        LabAction(
          label: _t('btn_testAll'),
          icon: Icons.water_drop,
          foreground: _Colors.slate900,
          highlight: s.testAt == null,
          enabled: s.testAt == null,
          onTap: _testAll,
        ),
      ];
    }
    return const [];
  }

  // --------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final data = _data;
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          actions: _actions(),
          onReset: _fullReset,
          overlays: [
            // canvas-confetti burst at the end of each scenario.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ConfettiPainter(confetti: _confetti, repaint: _frame)),
              ),
            ),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ItemPanRecognizer: GestureRecognizerFactoryWithHandlers<_ItemPanRecognizer>(
                  _ItemPanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _lab.isLabActive && _hitItem(local) != null)
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
                painter: _LabPainter(
                  scene: _scene,
                  repaint: _frame,
                  palette: p,
                  showLabels: _lab.showLabels,
                  tr: _t,
                  lang: _lab.lang,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `s1_conclusion`: explanation card and the green conclusion box.
  Widget _s1Extra() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final body = TextStyle(color: p.text, fontSize: 12.5 * f, height: 1.5, fontWeight: FontWeight.w500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: _t('s1_p1a')),
                  TextSpan(
                    text: _t('s1_p1b'),
                    style: TextStyle(fontWeight: FontWeight.w900, color: p.textStrong),
                  ),
                  TextSpan(text: _t('s1_p1c')),
                ]),
                style: body,
              ),
              SizedBox(height: 8 * s),
              Text(_t('s1_p2'), style: body),
            ],
          ),
        ),
        SizedBox(height: 10 * s),
        _conclusionBox(p, s, f, _t('s1_conc')),
      ],
    );
  }

  /// HTML `s2_conclusion`: Plant / Condition / Result table + conclusion.
  Widget _s2Extra() {
    final p = _Theme.of(_lab.isDark);
    final s = context.labScale;
    final f = s * _lab.fontScale.clamp(0.9, 1.4);
    final dark = _lab.isDark;
    Widget cell(String text, {Color? color, FontWeight weight = FontWeight.w600, double size = 12}) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
          child: Text(
            text,
            style: TextStyle(color: color ?? p.textStrong, fontSize: size * f, fontWeight: weight, height: 1.3),
          ),
        );
    final present = dark ? _Colors.green400 : _Colors.green700;
    final absent = dark ? _Colors.red400 : _Colors.red700;
    final head = TextStyle(color: p.textMuted, fontSize: 10.5 * f, fontWeight: FontWeight.w800, letterSpacing: 0.8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: p.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(0.7),
                1: FlexColumnWidth(1.7),
                2: FlexColumnWidth(1.5),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(horizontalInside: BorderSide(color: p.cardBorder)),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.popupHeader),
                  children: [
                    for (final k in ['th_plant', 'th_cond', 'th_result'])
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
                        child: Text(_t(k).toUpperCase(), style: head),
                      ),
                  ],
                ),
                for (var i = 0; i < 4; i++)
                  TableRow(
                    decoration: BoxDecoration(color: i.isEven ? p.card : Colors.transparent),
                    children: [
                      cell(_letters[i], weight: FontWeight.w800),
                      cell(_t('cond_${'abcd'[i]}'), color: p.text),
                      cell(
                        _t(i == 0 ? 'res_present' : 'res_absent'),
                        color: i == 0 ? present : absent,
                        weight: FontWeight.w800,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10 * s),
        _conclusionBox(p, s, f, _t('s2_conc')),
      ],
    );
  }

  Widget _conclusionBox(LabPalette p, double s, double f, String text) {
    final c = p.isDark ? _Colors.green400 : _Colors.green700;
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: _Colors.green500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.green500.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 13 * f, height: 1.4),
      ),
    );
  }
}

// ================================================================== PAINTING

const Color _leafGreen = _Colors.green500;
const Color _leafEdge = _Colors.emerald900;

/// Paints both scenarios (HTML `render2DScene()` + the SVG library `SVGS`).
class _LabPainter extends CustomPainter {
  _LabPainter({
    required this.scene,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.tr,
    required this.lang,
  }) : super(repaint: repaint);

  final _Scene scene;
  final LabPalette palette;
  final bool showLabels;
  final String Function(String key) tr;
  final LabLang lang;

  bool get isDark => palette.isDark;
  double get t => scene.time;

  /// The HTML `#scene-wrapper` dot grid.
  static final List<Offset> _dots = [
    for (var x = -440.0; x <= 1340; x += 22)
      for (var y = -440.0; y <= 1040; y += 22) Offset(x, y),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    if (scene.scenario == 0) {
      if (scene.step <= 5) {
        _paintS1Setup(canvas);
      } else {
        _paintS1Test(canvas, size);
      }
    } else {
      _paintS2(canvas, size);
    }
  }

  // ------------------------------------------------------------ helpers

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = c;

  /// HTML `.label-text` chip (hidden with the Labels tool).
  void _label(Canvas c, String key, Offset at, {Alignment anchor = Alignment.bottomCenter, double size = 14}) {
    if (!showLabels) return;
    labText(
      c,
      tr(key),
      at,
      size: size,
      weight: FontWeight.w700,
      color: palette.labelText,
      background: palette.labelBg,
      border: isDark ? _Colors.slate600 : _Colors.slate300,
      borderWidth: 1,
      radius: 7,
      anchor: anchor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }

  void _dropShadow(Canvas c, Path path, {double blur = 6, Offset offset = const Offset(0, 5), double alpha = 0.35}) {
    c.drawPath(
      path.shift(offset),
      Paint()
        ..color = Colors.black.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  /// Dashed outline of a drop zone; green and filled while hovered
  /// (HTML `.dropzone.dragover`).
  void _paintDropHint(Canvas c, Rect r, bool hover, {double radius = 14}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(radius));
    c.drawRRect(rr, _fill(_Colors.green500.withValues(alpha: hover ? 0.2 : 0.07)));
    if (hover) {
      c.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..color = _Colors.green500.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      c.drawRRect(rr, _stroke(_Colors.green500, 3));
    } else {
      labDashedPath(
        c,
        Path()..addRRect(rr),
        _stroke(_Colors.green500.withValues(alpha: 0.7), 2.5),
        dash: 10,
        gap: 7,
        phase: t * 24,
      );
    }
  }

  void _paintBackground(Canvas c, Size size) {
    c.drawRect(labBleed(size), _fill(palette.canvasBg));
    c.drawPoints(
      ui.PointMode.points,
      _dots,
      Paint()
        ..color = _Colors.slate400.withValues(alpha: isDark ? 0.12 : 0.28)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  // ------------------------------------------------------- shared art

  /// HTML `SVGS.sunIcon` with the `animate-sun-rays` spin.
  void _paintSun(Canvas c, Offset center, double r, double rot, {double glow = 1}) {
    labGlow(c, center, r * 3.2, _Colors.yellow300, intensity: 0.55 * glow);
    final ray = _stroke(_Colors.yellow400, r * 0.3);
    for (var i = 0; i < 8; i++) {
      final a = rot + i * math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a));
      c.drawLine(center + d * (r * 1.35), center + d * (r * 1.85), ray);
    }
    final disc = Rect.fromCircle(center: center, radius: r);
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFFEF9C3), _Colors.yellow400, Color(0xFFEAB308)],
          stops: [0, 0.55, 1],
        ).createShader(disc),
    );
  }

  /// HTML `SVGS.plant()` above `SVGS.pot()`: a potted plant whose 100×120
  /// container is centred on [center] and scaled by [k].
  void _paintPottedPlant(Canvas c, Offset center, double k, {double plantBottom = 50, bool rightLeaf = true}) {
    final left = center.dx - 50 * k;
    final top = center.dy - 60 * k;
    final ps = 0.8 * k;
    final potLeft = left + 10 * k;
    final potTop = top + 40 * k;
    final rimTop = potTop + 5 * ps;
    labGroundShadow(c, Offset(center.dx, top + 119 * k), 74 * k, 10 * k, opacity: 0.35);
    // Soil showing above the rim.
    c.drawOval(
      Rect.fromCenter(center: Offset(potLeft + 50 * ps, rimTop + 0.5 * ps), width: 62 * ps, height: 9 * ps),
      _fill(const Color(0xFF3B2416)),
    );
    // Plant (SVG viewBox 100×120 fitted into a 100×100 box), cut at the soil.
    final m = 100 * k / 120;
    final ox = left + (100 * k - 100 * m) / 2;
    final oy = top + (120 - plantBottom - 100) * k;
    c.save();
    c.clipRect(Rect.fromLTRB(left - 200 * k, top - 200 * k, left + 300 * k, rimTop + 2 * ps));
    c.translate(ox, oy);
    c.scale(m);
    _plantShape(c, rightLeaf: rightLeaf);
    c.restore();
    // Pot (SVG viewBox 100×100 in an 80×80 box).
    c.save();
    c.translate(potLeft, potTop);
    c.scale(ps);
    _potShape(c);
    c.restore();
  }

  /// [rightLeaf] false leaves out the right leaf: in scenario 1 the
  /// experimental leaf grows there instead.
  void _plantShape(Canvas c, {bool rightLeaf = true}) {
    final stems = Path()
      ..moveTo(50, 110)
      ..quadraticBezierTo(50, 80, 50, 40)
      ..moveTo(50, 90)
      ..quadraticBezierTo(30, 95, 15, 70)
      ..quadraticBezierTo(40, 60, 50, 85)
      ..moveTo(50, 40)
      ..quadraticBezierTo(25, 40, 35, 15)
      ..quadraticBezierTo(60, 15, 50, 40);
    if (rightLeaf) {
      stems
        ..moveTo(50, 65)
        ..quadraticBezierTo(75, 70, 85, 45)
        ..quadraticBezierTo(65, 35, 50, 60);
    }
    c.drawPath(stems, _stroke(_leafEdge, 4));
    final leaves = [
      (
        Path()
          ..moveTo(15, 70)
          ..cubicTo(10, 55, 30, 50, 45, 60)
          ..cubicTo(30, 80, 25, 80, 15, 70),
        const Offset(44, 61),
        const Offset(17, 69),
      ),
      (
        Path()
          ..moveTo(85, 45)
          ..cubicTo(95, 30, 75, 25, 60, 35)
          ..cubicTo(75, 55, 80, 55, 85, 45),
        const Offset(61, 36),
        const Offset(84, 44),
      ),
      (
        Path()
          ..moveTo(35, 15)
          ..cubicTo(30, 0, 55, -5, 65, 5)
          ..cubicTo(55, 25, 45, 25, 35, 15),
        const Offset(64, 6),
        const Offset(36, 15),
      ),
    ];
    if (!rightLeaf) leaves.removeAt(1);
    for (final (leaf, a, b) in leaves) {
      c.drawPath(
        leaf,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [labShade(_leafGreen, 0.2), _leafGreen, labShade(_leafGreen, -0.2)],
          ).createShader(leaf.getBounds()),
      );
      c.drawLine(a, b, _stroke(_leafEdge.withValues(alpha: 0.45), 1));
      c.drawPath(leaf, _stroke(_leafEdge, 1.5));
    }
  }

  void _potShape(Canvas c) {
    final body = Path()
      ..moveTo(20, 20)
      ..lineTo(80, 20)
      ..lineTo(72, 90)
      ..lineTo(28, 90)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9A3412), Color(0xFFC2410C), Color(0xFF7C2D12)],
        ).createShader(const Rect.fromLTWH(20, 20, 60, 70)),
    );
    c.drawPath(body, _stroke(const Color(0xFF431407), 3));
    final rim = RRect.fromRectAndRadius(const Rect.fromLTWH(15, 5, 70, 15), const Radius.circular(3));
    c.drawRRect(rim, _fill(const Color(0xFFEA580C)));
    c.drawLine(const Offset(19, 9), const Offset(81, 9), _stroke(const Color(0x55FFFFFF), 2));
    c.drawRRect(rim, _stroke(const Color(0xFF431407), 3));
  }

  /// HTML `SVGS.leaf()`: the flat 100×50 leaf, optionally split into a
  /// left (base) and right (tip) colour after the iodine test.
  void _flatLeaf(
    Canvas c,
    Offset center,
    double w, {
    required Color color,
    Color? right,
    double rot = 0,
    bool petiole = false,
    Color edge = _leafEdge,
  }) {
    c.save();
    c.translate(center.dx, center.dy);
    if (rot != 0) c.rotate(rot);
    c.scale(w / 100);
    c.translate(-50, -25);
    final leaf = Path()
      ..moveTo(0, 25)
      ..cubicTo(40, 0, 80, 0, 100, 25)
      ..cubicTo(80, 50, 40, 50, 0, 25)
      ..close();
    if (petiole) c.drawLine(const Offset(-14, 28), const Offset(2, 25), _stroke(edge, 3));
    _dropShadow(c, leaf, blur: 3, offset: const Offset(0, 3), alpha: 0.25);
    if (right == null) {
      c.drawPath(
        leaf,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, Color.lerp(color, Colors.black, 0.15)!],
          ).createShader(const Rect.fromLTWH(0, 0, 100, 50)),
      );
    } else {
      c.save();
      c.clipRect(const Rect.fromLTRB(-20, -10, 50, 60));
      c.drawPath(leaf, _fill(color));
      c.restore();
      c.save();
      c.clipRect(const Rect.fromLTRB(50, -10, 120, 60));
      c.drawPath(leaf, _fill(right));
      c.restore();
    }
    final vein = _stroke(edge.withValues(alpha: 0.4), 1.5);
    c.drawLine(const Offset(0, 25), const Offset(90, 25), vein);
    final side = _stroke(edge.withValues(alpha: 0.25), 1);
    for (final x in [22.0, 42.0, 62.0]) {
      c.drawLine(Offset(x, 25), Offset(x + 12, 12), side);
      c.drawLine(Offset(x, 25), Offset(x + 12, 38), side);
    }
    c.drawPath(leaf, _stroke(edge, 2));
    c.restore();
  }

  /// HTML `SVGS.testTube(color)` drawn into [r] (viewBox 40×100). The liquid
  /// fills from [top] to [bottom] (viewBox units).
  void _testTube(Canvas c, Rect r, {Color? liquid, double top = 40, double bottom = 96, void Function(Canvas)? inside}) {
    c.save();
    c.translate(r.left, r.top);
    c.scale(r.width / 40, r.height / 100);
    final glass = Path()
      ..moveTo(10, 10)
      ..lineTo(10, 85)
      ..arcToPoint(const Offset(30, 85), radius: const Radius.circular(10), clockwise: false)
      ..lineTo(30, 10);
    final closed = Path.from(glass)..close();
    c.drawPath(
      closed,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x80FFFFFF), Color(0x1AFFFFFF), Color(0x66FFFFFF)],
        ).createShader(const Rect.fromLTWH(10, 10, 20, 85)),
    );
    if (liquid != null && bottom > top) {
      c.save();
      c.clipPath(closed);
      c.drawRect(Rect.fromLTRB(10, top, 30, bottom), _fill(liquid));
      c.drawRect(Rect.fromLTRB(10, top, 30, top + 1.5), _fill(Colors.white.withValues(alpha: 0.35)));
      c.restore();
    }
    inside?.call(c);
    c.drawPath(glass, _stroke(_Colors.slate300, 2));
    c.drawOval(Rect.fromCenter(center: const Offset(20, 10), width: 20, height: 6), _stroke(_Colors.slate300, 2));
    c.drawLine(const Offset(14, 16), const Offset(14, 80), _stroke(Colors.white.withValues(alpha: 0.35), 2));
    c.restore();
  }

  /// HTML `SVGS.clock` with its spinning hand plus an hours counter.
  void _paintClock(Canvas c, Offset center, double r, double hours, double total) {
    labGroundShadow(c, center + Offset(0, r * 0.9), r * 1.6, r * 0.3, opacity: 0.3);
    c.drawCircle(
      center.translate(0, 6),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    final k = r / 46;
    c.drawCircle(center, r, _fill(_Colors.slate50));
    c.drawCircle(center, r, _stroke(_Colors.slate800, 6 * k));
    labDashedPath(
      c,
      Path()..addOval(Rect.fromCircle(center: center, radius: 40 * k)),
      _stroke(_Colors.slate200, 2 * k),
      dash: 4 * k,
      gap: 6 * k,
    );
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final d = Offset(math.sin(a), -math.cos(a));
      c.drawLine(center + d * (34 * k), center + d * (39 * k), _stroke(_Colors.slate500, (i % 3 == 0 ? 2.5 : 1.2) * k));
    }
    // Hour hand (follows the simulated hours) and the spinning red hand.
    final ha = hours / 12 * 2 * math.pi;
    c.drawLine(center, center + Offset(math.sin(ha), -math.cos(ha)) * (20 * k), _stroke(_Colors.slate800, 4.5 * k));
    final a = t * 2 * math.pi;
    c.drawLine(center, center + Offset(math.sin(a), -math.cos(a)) * (35 * k), _stroke(_Colors.red500, 4 * k));
    c.drawCircle(center, 5 * k, _fill(_Colors.slate800));
    labText(
      c,
      labFormat(tr('hours'), {'h': '${hours.round()} / ${total.round()}'}),
      center + Offset(0, r + 14),
      anchor: Alignment.topCenter,
      size: 15,
      weight: FontWeight.w800,
      color: Colors.white,
      background: const Color(0xE60F172A),
      border: _Colors.slate600,
      borderWidth: 1,
      radius: 8,
    );
  }

  // ------------------------------------------------------- scenario 1

  void _paintBench(Canvas c) {
    for (final x in [100.0, 760.0]) {
      final r = Rect.fromLTWH(x, 510, 40, 90);
      c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF7D4115), _Colors.benchLeg, Color(0xFF552A0A)],
          ).createShader(r),
      );
    }
    labGroundShadow(c, const Offset(450, 514), 820, 16, opacity: isDark ? 0.45 : 0.25);
    final top = Path()
      ..moveTo(58, 470)
      ..lineTo(842, 470)
      ..lineTo(850, 480)
      ..lineTo(50, 480)
      ..close();
    c.drawPath(top, _fill(const Color(0xFFA35D2C)));
    final front = Rect.fromLTWH(50, 480, 800, 30);
    c.drawRRect(
      RRect.fromRectAndCorners(front, topLeft: const Radius.circular(4), topRight: const Radius.circular(4)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9C5524), _Colors.bench, Color(0xFF773A0F)],
        ).createShader(front),
    );
    final grain = _stroke(const Color(0x22000000), 1);
    for (final y in [487.0, 494.0, 500.0]) {
      c.drawLine(Offset(60, y), Offset(840, y + 1), grain);
    }
    c.drawRect(const Rect.fromLTWH(50, 506, 800, 4), _fill(_Colors.benchEdge));
  }

  /// HTML `SVGS.closet` (one shelf, so the potted plant fits below it).
  void _paintCloset(Canvas c) {
    const r = _closetRect;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(5));
    _dropShadow(c, Path()..addRRect(rr), blur: 10, offset: const Offset(6, 8), alpha: 0.4);
    c.drawRRect(rr, _fill(_Colors.closet));
    c.drawRRect(rr, _stroke(_Colors.closetEdge, 4));
    final inner = r.deflate(12);
    c.drawRect(
      inner,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF080808), Color(0xFF17120F)],
        ).createShader(inner),
    );
    const y = _closetShelfY;
    final shelf = Rect.fromLTWH(inner.left, y, inner.width, 11);
    c.drawRect(shelf, _fill(_Colors.closetPanel));
    c.drawRect(shelf, _stroke(_Colors.closetEdge, 2));
    // Two jars on the upper shelf.
    for (final (x, h, col) in [(70.0, 26.0, const Color(0xFF7C5E3C)), (104.0, 20.0, const Color(0xFF4B5563))]) {
      final jar = RRect.fromRectAndRadius(Rect.fromLTWH(x, y - h, 24, h), const Radius.circular(4));
      c.drawRRect(jar, _fill(col));
      c.drawRect(Rect.fromLTWH(x + 3, y - h - 5, 18, 6), _fill(labShade(col, -0.3)));
    }
  }

  /// HTML `#closet-door` swinging open (`rotateY` about its left edge),
  /// drawn in perspective so it stays inside the stage.
  void _paintClosetDoor(Canvas c, double open, {bool hint = false}) {
    const r = _closetRect;
    final th = open * 80 * math.pi / 180;
    const f = 2000.0;
    final cy = r.top + r.height * 0.62;
    Offset proj(double u, double v) {
      final k = f / (f - u * math.sin(th));
      return Offset(r.left + u * math.cos(th) * k, cy + (r.top + v - cy) * k);
    }

    Path quad(double u0, double v0, double u1, double v1) =>
        Path()..addPolygon([proj(u0, v0), proj(u1, v0), proj(u1, v1), proj(u0, v1)], true);
    final w = r.width;
    final h = r.height;
    final shade = -0.35 * math.sin(th);
    final door = quad(0, 0, w, h);
    if (open == 0) _dropShadow(c, door, blur: 6, offset: const Offset(2, 3), alpha: 0.3);
    c.drawPath(door, _fill(labShade(_Colors.closetDoor, shade)));
    c.drawPath(door, _stroke(_Colors.closetEdge, 4));
    final px = 20 * w / 250;
    final py = 20 * h / 350;
    final panel = quad(px, py, w - px, h - py);
    c.drawPath(panel, _fill(labShade(_Colors.closetPanel, shade)));
    c.drawPath(panel, _stroke(_Colors.closet, 2));
    // Inner bevel lines for a carved panel look.
    final bevel = quad(px + 14, py + 14, w - px - 14, h - py - 14);
    c.drawPath(bevel, _stroke(labShade(_Colors.closetPanel, shade + 0.12).withValues(alpha: 0.6), 1.5));
    final handle = quad(210 * w / 250, 150 * h / 350, 220 * w / 250, 200 * h / 350);
    if (hint) {
      final pulse = 0.5 + 0.5 * math.sin(t * 4);
      labGlow(c, handle.getBounds().center, 34 + 8 * pulse, _Colors.yellow400, intensity: 0.5 + 0.4 * pulse);
    }
    c.drawPath(handle, _fill(const Color(0xFFFBBF24)));
    c.drawPath(handle, _stroke(_Colors.amber700, 1.5));
  }

  /// The wide-mouthed bottle outline (HTML `SVGS.bottle`, wider neck).
  Path _bottlePath({bool close = false}) {
    const x = _bottleX;
    const b = _bottleBottom;
    const m = _mouthY;
    final p = Path()
      ..moveTo(x - 22, m)
      ..lineTo(x - 22, m + 22)
      ..cubicTo(x - 22, m + 32, x - 40, m + 30, x - 40, m + 46)
      ..lineTo(x - 40, b - 12)
      ..quadraticBezierTo(x - 40, b, x - 28, b)
      ..lineTo(x + 28, b)
      ..quadraticBezierTo(x + 40, b, x + 40, b - 12)
      ..lineTo(x + 40, m + 46)
      ..cubicTo(x + 40, m + 30, x + 22, m + 32, x + 22, m + 22)
      ..lineTo(x + 22, m);
    if (close) p.close();
    return p;
  }

  double get _causticLevel {
    final s = scene;
    if (s.causticDone || s.step >= 3) return 1;
    return Curves.easeInOut.transform(s.prog(s.pourAt == null ? null : s.pourAt! + 0.5, 1.35));
  }

  double _liquidTop(double level) => _bottleBottom - 2 - 22 * level;

  /// Wooden block the bottle stands on.
  void _paintBottleBlock(Canvas c) {
    const r = _bottleBlock;
    labGroundShadow(c, Offset(r.center.dx + 4, r.bottom), r.width + 16, 10, opacity: 0.35);
    labBox3D(c, r, 10, const Color(0xFFA16207), radius: 3);
    final grain = _stroke(const Color(0x33000000), 1);
    for (final y in [r.top + 13, r.top + 26]) {
      c.drawLine(Offset(r.left + 6, y), Offset(r.right - 6, y + 2), grain);
    }
  }

  void _paintBottleBack(Canvas c) {
    _paintBottleBlock(c);
    final body = _bottlePath(close: true);
    c.drawPath(body, _fill((isDark ? Colors.white : _Colors.slate400).withValues(alpha: 0.06)));
    final level = _causticLevel;
    if (level > 0) {
      c.save();
      c.clipPath(body);
      final top = _liquidTop(level);
      final lr = Rect.fromLTRB(_bottleX - 44, top, _bottleX + 44, _bottleBottom);
      c.drawRect(
        lr,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xB3BFDBFE), Color(0xB393C5FD)],
          ).createShader(lr),
      );
      c.drawOval(Rect.fromCenter(center: Offset(_bottleX, top), width: 78, height: 5), _fill(const Color(0xCCDBEAFE)));
      c.restore();
    }
    // Pour stream from the tilted tube (HTML `.animate-pour`).
    final s = scene;
    if (s.pourAt != null && !s.causticDone) {
      final p = (t - s.pourAt! - 0.35) / 1.5;
      if (p > 0 && p < 1) {
        const mouth = Offset(_bottleX + 12, _mouthY - 26);
        final surface = _liquidTop(level);
        final y0 = p > 0.8 ? mouth.dy + (surface - mouth.dy) * ((p - 0.8) / 0.2) : mouth.dy;
        final y1 = mouth.dy + (surface - mouth.dy) * math.min(1.0, p / 0.25);
        if (y1 > y0) {
          c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTRB(mouth.dx - 2.5, y0, mouth.dx + 2.5, y1), const Radius.circular(3)),
            _fill(_Colors.blue300),
          );
        }
        if (p > 0.25 && p < 0.9) {
          for (var i = 0; i < 3; i++) {
            final ph = (t * 3 + i / 3) % 1;
            c.drawCircle(
              Offset(mouth.dx + (i - 1) * 6 * ph, surface - 6 * math.sin(ph * math.pi)),
              1.6,
              _fill(Colors.white.withValues(alpha: 0.7 * (1 - ph))),
            );
          }
        }
      }
    }
  }

  void _paintBottleFront(Canvas c) {
    final body = _bottlePath(close: true);
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x66FFFFFF), Color(0x12FFFFFF), Color(0x12FFFFFF), Color(0x80FFFFFF)],
          stops: [0, 0.2, 0.8, 1],
        ).createShader(const Rect.fromLTRB(_bottleX - 40, _mouthY, _bottleX + 40, _bottleBottom)),
    );
    c.drawPath(_bottlePath(), _stroke(_Colors.slate400, 3));
    final lip = Rect.fromCenter(center: const Offset(_bottleX, _mouthY), width: 54, height: 11);
    c.drawOval(lip, _fill(Colors.white.withValues(alpha: 0.2)));
    c.drawOval(lip, _stroke(_Colors.slate400, 3));
    final hl = Path()
      ..moveTo(_bottleX - 33, _mouthY + 56)
      ..quadraticBezierTo(_bottleX - 25, _mouthY + 50, _bottleX - 21, _mouthY + 64);
    c.drawPath(hl, _stroke(Colors.white.withValues(alpha: 0.8), 2.5));
    c.drawLine(
      const Offset(_bottleX - 32, _mouthY + 66),
      const Offset(_bottleX - 32, _bottleBottom - 14),
      _stroke(Colors.white.withValues(alpha: 0.22), 4),
    );
  }

  /// HTML `SVGS.cork` (cap, plug and the split down the middle).
  void _paintCork(Canvas c, Offset center, {bool shadow = true}) {
    final r = Rect.fromCenter(center: center, width: 50, height: 40);
    final plug = Path()
      ..moveTo(r.left + 6, r.top + 9)
      ..lineTo(r.right - 6, r.top + 9)
      ..lineTo(r.right - 9, r.bottom)
      ..lineTo(r.left + 9, r.bottom)
      ..close();
    final cap = RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width, 11), const Radius.circular(3));
    if (shadow) _dropShadow(c, Path()..addPath(plug, Offset.zero)..addRRect(cap), blur: 4, alpha: 0.3);
    c.drawPath(plug, _fill(_Colors.amber600));
    c.drawPath(plug, _stroke(_Colors.amber900, 2.5));
    final dots = _fill(_Colors.amber900.withValues(alpha: 0.35));
    for (final d in const [Offset(-12, 18), Offset(9, 24), Offset(-6, 31), Offset(13, 14), Offset(-14, 28)]) {
      c.drawCircle(r.topCenter + d, 1.4, dots);
    }
    c.drawRRect(cap, _fill(_Colors.amber700));
    c.drawRRect(cap, _stroke(_Colors.amber900, 2.5));
    final split = _stroke(const Color(0xFF451A03), 2.5);
    c.drawLine(r.topCenter, r.bottomCenter, split);
    c.drawLine(r.topCenter.translate(-5, 0), r.topCenter.translate(-5, 15), split);
    c.drawLine(r.topCenter.translate(5, 0), r.topCenter.translate(5, 15), split);
  }

  /// HTML `#caustic`: blue test tube with a warning sign and label.
  void _paintCaustic(Canvas c) {
    final s = scene;
    final center = s.posOf(_Item.caustic);
    final pour = s.pourAt;
    if (pour == null || s.drag == _Item.caustic) {
      final r = Rect.fromCenter(center: center, width: 32, height: 80);
      _dropShadow(c, Path()..addRect(r.deflate(6)), blur: 6, alpha: 0.3);
      _testTube(c, r, liquid: _Colors.blue400);
      // HTML `SVGS.warning`.
      final w = center + const Offset(0, -78);
      final tri = Path()
        ..moveTo(w.dx, w.dy - 13)
        ..lineTo(w.dx + 14, w.dy + 11)
        ..lineTo(w.dx - 14, w.dy + 11)
        ..close();
      c.drawPath(tri, _fill(_Colors.yellow400));
      c.drawPath(tri, _stroke(_Colors.amber700, 1.5));
      c.drawLine(w.translate(0, -4), w.translate(0, 4), _stroke(_Colors.slate900, 2.6));
      c.drawCircle(w.translate(0, 8), 1.6, _fill(_Colors.slate900));
      _label(c, 'lbl_caustic', center + const Offset(0, -46));
      return;
    }
    // Tilting over the mouth, then pouring.
    final tilt = Curves.easeOut.transform(((t - pour) / 0.35).clamp(0.0, 1.0));
    final p = ((t - pour - 0.35) / 1.5).clamp(0.0, 1.0);
    final fade = 1 - ((t - pour - 1.85) / 0.3).clamp(0.0, 1.0);
    if (fade <= 0) return;
    c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: fade));
    c.translate(center.dx, center.dy);
    c.rotate(-2.0 * tilt);
    final r = Rect.fromCenter(center: Offset.zero, width: 32, height: 80);
    if (tilt < 1) {
      _testTube(c, r, liquid: _Colors.blue400);
    } else {
      _testTube(c, r, liquid: _Colors.blue400, top: 10, bottom: 10 + 46 * (1 - p));
    }
    c.restore();
  }

  void _paintScissors(Canvas c, Offset center, {double alpha = 1}) {
    if (alpha <= 0) return;
    c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: alpha));
    c.translate(center.dx - 32, center.dy - 32);
    c.scale(0.64);
    final blades = Path()
      ..moveTo(25, 25)
      ..lineTo(85, 85)
      ..moveTo(25, 85)
      ..lineTo(85, 25);
    _dropShadow(c, blades, blur: 4, alpha: 0.3);
    c.drawPath(blades, _stroke(_Colors.slate300, 8));
    c.drawLine(const Offset(58, 58), const Offset(83, 83), _stroke(Colors.white.withValues(alpha: 0.5), 2));
    c.drawCircle(const Offset(55, 55), 5, _fill(_Colors.slate700));
    for (final y in [20.0, 90.0]) {
      c.drawCircle(Offset(20, y), 12, _stroke(_Colors.red500, 8));
    }
    c.restore();
  }

  /// The experimental leaf: petiole from the stem, blade along its spine.
  void _paintTargetLeaf(Canvas c, Offset plant) {
    final s = scene;
    final cut = s.prog(s.cutAt, 1.0);
    final stem = plant + _stemRel;
    final base = plant + _baseRel;
    final petiole = cut > 0 ? Offset.lerp(stem, base, 0.45)! : base;
    c.drawLine(stem, petiole, _stroke(_leafEdge, 4));
    c.drawLine(stem, petiole, _stroke(_Colors.green700, 1.6));
    if (cut >= 1) return;
    final spine = [for (final p in s.leafSpine()) plant + p];
    c.save();
    if (cut > 0) {
      c.translate(base.dx, base.dy);
      c.rotate(-math.pi / 4 * cut);
      c.scale(1 - cut);
      c.translate(-base.dx, -base.dy);
    }
    _spineLeaf(c, spine);
    c.restore();
  }

  /// A leaf blade built around [sp] (base → tip).
  void _spineLeaf(Canvas c, List<Offset> sp, {double width = 14}) {
    final n = sp.length;
    final left = <Offset>[];
    final right = <Offset>[];
    final normals = <Offset>[];
    for (var i = 0; i < n; i++) {
      final u = i / (n - 1);
      var d = sp[math.min(i + 1, n - 1)] - sp[math.max(i - 1, 0)];
      d = d.distance == 0 ? const Offset(1, 0) : d / d.distance;
      final nrm = Offset(-d.dy, d.dx);
      normals.add(nrm);
      // Widest about 40 % along the blade, like a real leaf.
      final w = width * math.pow(math.sin(math.pi * math.pow(u, 0.8)), 0.7) * (1 - 0.15 * u);
      left.add(sp[i] + nrm * w);
      right.add(sp[i] - nrm * w);
    }
    final path = Path()..addPolygon([sp.first, ...left.sublist(1, n - 1), sp.last, ...right.sublist(1, n - 1).reversed], true);
    _dropShadow(c, path, blur: 4, offset: const Offset(0, 4), alpha: 0.25);
    final b = path.getBounds();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [labShade(_leafGreen, 0.15), _leafGreen, labShade(_leafGreen, -0.18)],
        ).createShader(b),
    );
    // Lighter half of the blade for a little depth.
    final half = Path()..addPolygon([...sp, ...left.reversed], true);
    c.drawPath(half, _fill(Colors.white.withValues(alpha: 0.08)));
    final side = _stroke(_leafEdge.withValues(alpha: 0.28), 1);
    for (var i = 5; i < n - 4; i += 5) {
      final d = sp[i + 1] - sp[i - 1];
      final dir = d / math.max(d.distance, 0.001);
      final w = (left[i] - sp[i]).distance;
      c.drawLine(sp[i], sp[i] + dir * (w * 0.7) + normals[i] * (w * 0.8), side);
      c.drawLine(sp[i], sp[i] + dir * (w * 0.7) - normals[i] * (w * 0.8), side);
    }
    c.drawPath(Path()..addPolygon(sp.sublist(0, n - 2), false), _stroke(_leafEdge.withValues(alpha: 0.45), 1.4));
    c.drawPath(path, _stroke(_leafEdge, 1.6));
  }

  /// HTML window scene for steps 4–5 (sunlit windowsill).
  void _paintWindow(Canvas c) {
    const r = Rect.fromLTRB(50, 36, 850, 470);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(18));
    c.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0x8C1E3A8A), Color(0x4D0EA5E9)]
              : const [Color(0xFF93C5FD), Color(0xFFE0F2FE)],
        ).createShader(r),
    );
    final s = scene;
    final sim = s.step == 4 && s.simAt != null;
    const sun = Offset(724, 112);
    c.save();
    c.clipRRect(rr);
    labGlow(c, sun, 300, const Color(0xFFFDE68A), intensity: sim ? 0.65 : 0.5);
    // Distant ground (HTML bottom band).
    c.drawRect(const Rect.fromLTRB(50, 372, 850, 470), _fill(_Colors.blue200.withValues(alpha: isDark ? 0.14 : 0.35)));
    final hills = Path()..moveTo(50, 372);
    for (var x = 50.0; x <= 850; x += 10) {
      hills.lineTo(x, 372 - 18 - 12 * math.sin(x / 70) - 8 * math.sin(x / 23 + 1));
    }
    hills
      ..lineTo(850, 372)
      ..close();
    c.drawPath(hills, _fill((isDark ? const Color(0xFF14532D) : const Color(0xFF86EFAC)).withValues(alpha: 0.55)));
    // Sunbeams falling on the plant.
    for (final target in const [Offset(320, 470), Offset(430, 470), Offset(540, 470)]) {
      final d = target - sun;
      final n = Offset(-d.dy, d.dx) / d.distance;
      final beam = Path()
        ..moveTo(sun.dx + n.dx * 8, sun.dy + n.dy * 8)
        ..lineTo(target.dx + n.dx * 46, target.dy + n.dy * 46)
        ..lineTo(target.dx - n.dx * 46, target.dy - n.dy * 46)
        ..lineTo(sun.dx - n.dx * 8, sun.dy - n.dy * 8)
        ..close();
      c.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFFFDE68A).withValues(alpha: sim ? 0.32 : 0.22),
              const Color(0xFFFDE68A).withValues(alpha: 0),
            ],
          ).createShader(beam.getBounds()),
      );
    }
    c.restore();
    // Frame and glazing bars.
    final bar = _stroke(_Colors.blue200.withValues(alpha: 0.5), 3);
    c.drawLine(const Offset(450, 40), const Offset(450, 466), bar);
    c.drawLine(const Offset(54, 200), const Offset(846, 200), bar);
    c.drawRRect(rr, _stroke(_Colors.blue200.withValues(alpha: 0.5), 4));
    final spin = sim ? t * 3 : t * 2 * math.pi / 20;
    _paintSun(c, sun, 30 + 2 * math.sin(t * math.pi / 10), spin, glow: sim ? 1.3 : 1);
  }

  void _paintPlantS1(Canvas c) {
    final center = scene.posOf(_Item.plant);
    _paintPottedPlant(c, center, _plantScaleS1, rightLeaf: false);
    _paintTargetLeaf(c, center);
  }

  void _paintS1Setup(Canvas c) {
    final s = scene;
    final st = s.step;
    if (st == 4 || st == 5) _paintWindow(c);
    _paintBench(c);
    final dragging = s.drag;

    if (st <= 2) {
      if (st == 2) c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: 0.4));
      _paintCloset(c);
      if (st == 1 && !s.plantOnBench && dragging != _Item.plant) _paintPlantS1(c);
      final open = st == 2 ? 1.0 : Curves.easeInOutCubic.transform(s.prog(s.doorAt, 1.0));
      _paintClosetDoor(c, open, hint: st == 1 && !s.closetOpen);
      if (st == 2) c.restore();
      if (st == 1) {
        _label(c, 'lbl_destarch', Offset(_closetRect.center.dx, _closetRect.top - 8));
        if (!s.closetOpen) _label(c, 'lbl_tap_open', _closetRect.center.translate(10, 30), anchor: Alignment.center, size: 13);
      }
    }
    if (st >= 2) _paintBottleBack(c);
    if ((st >= 2 || s.plantOnBench) && dragging != _Item.plant) _paintPlantS1(c);
    if (st >= 2) {
      _paintBottleFront(c);
      if (s.corkOn && dragging != _Item.cork) _paintCork(c, s.posOf(_Item.cork), shadow: false);
    }
    if (st == 2 && !s.causticDone && dragging != _Item.caustic) _paintCaustic(c);
    if (st == 3 && !s.corkOn && dragging != _Item.cork) {
      _paintCork(c, s.posOf(_Item.cork));
      _label(c, 'lbl_cork', s.posOf(_Item.cork) + const Offset(0, -28));
    }
    if (st == 5 && dragging != _Item.scissors) {
      final fade = s.cutAt == null ? 1.0 : 1 - s.prog(s.cutAt! + 0.3, 0.5);
      _paintScissors(c, s.posOf(_Item.scissors), alpha: fade);
      if (s.cutAt == null) _label(c, 'lbl_scissors', s.posOf(_Item.scissors) + const Offset(0, -36));
    }
    if (st == 3 && s.corkOn && !s.leafIn) _paintTipHandle(c);

    if (dragging != null && dragging != _Item.leafTip) {
      final target = _s1Target(dragging);
      if (target != null) {
        _paintDropHint(c, target, target.inflate(24).contains(s.posOf(dragging)));
      }
      switch (dragging) {
        case _Item.plant:
          _paintPlantS1(c);
        case _Item.caustic:
          _paintCaustic(c);
        case _Item.cork:
          _paintCork(c, s.posOf(_Item.cork));
        case _Item.scissors:
          _paintScissors(c, s.posOf(_Item.scissors));
        default:
          break;
      }
    }
    if (st == 4 && s.simAt != null) {
      final p = s.prog(s.simAt, 2.5);
      _paintClock(c, const Offset(190, 180), 74, 6 * p, 6);
    }
  }

  /// Dashed, pulsing "drag me" ring on the leaf tip (HTML `#leaf-handle`)
  /// with a guide arrow to the cork.
  void _paintTipHandle(Canvas c) {
    final s = scene;
    final tip = s.leafTip;
    final dragging = s.drag == _Item.leafTip;
    final pulse = 0.5 + 0.5 * math.sin(t * 4);
    final near = (tip - _corkSeat).distance < 64;
    if (dragging) {
      final r = Rect.fromCircle(center: _corkSeat.translate(0, -6), radius: 34);
      _paintDropHint(c, r, near, radius: 34);
    } else {
      final to = _corkSeat.translate(0, -30);
      final d = to - tip;
      final u = d / d.distance;
      labArrow(
        c,
        tip + u * 30,
        to,
        color: _Colors.green400.withValues(alpha: 0.45 + 0.4 * pulse),
        width: 2.5,
        head: 11,
        dashed: true,
      );
    }
    final rad = 22 + 2 * pulse;
    c.drawCircle(tip, rad, _fill(_Colors.green500.withValues(alpha: 0.2)));
    labDashedPath(
      c,
      Path()..addOval(Rect.fromCircle(center: tip, radius: rad)),
      _stroke(_Colors.green500, 2.5),
      dash: 6,
      gap: 5,
      phase: t * 20,
    );
    if (!dragging) _label(c, 'lbl_leaf_tip', tip + const Offset(0, -30), size: 13);
  }

  // ---- starch test bench (steps 6–8)

  void _paintBeakerBack(Canvas c) {
    const b = _beakerBox;
    const k = _beakerK;
    c.save();
    c.translate(b.left, b.top);
    c.scale(k);
    c.drawPath(
      Path()
        ..moveTo(20, 90)
        ..lineTo(10, 140)
        ..moveTo(80, 90)
        ..lineTo(90, 140)
        ..moveTo(50, 90)
        ..lineTo(50, 140),
      _stroke(_Colors.slate700, 4),
    );
    c.drawRect(const Rect.fromLTWH(40, 125, 20, 15), _fill(_Colors.slate800));
    c.drawRect(const Rect.fromLTWH(44, 121, 12, 5), _fill(_Colors.slate600));
    c.restore();
    labFlame(c, Offset(b.left + 50 * k, b.top + 121 * k), 36, t);
    c.save();
    c.translate(b.left, b.top);
    c.scale(k);
    c.drawLine(const Offset(15, 90), const Offset(85, 90), _stroke(_Colors.slate600, 6)..strokeCap = StrokeCap.butt);
    final glass = _beakerGlass()..close();
    c.drawPath(
      glass,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x4DFFFFFF), Color(0x0DFFFFFF), Color(0x66FFFFFF)],
        ).createShader(const Rect.fromLTWH(25, 15, 50, 75)),
    );
    final water = Path()
      ..moveTo(27, 45)
      ..lineTo(27, 85)
      ..arcToPoint(const Offset(30, 88), radius: const Radius.circular(3), clockwise: false)
      ..lineTo(70, 88)
      ..arcToPoint(const Offset(73, 85), radius: const Radius.circular(3), clockwise: false)
      ..lineTo(73, 45)
      ..close();
    c.drawPath(water, _fill(_Colors.blue500.withValues(alpha: 0.7)));
    c.drawLine(const Offset(27, 45), const Offset(73, 45), _stroke(Colors.white.withValues(alpha: 0.45), 1.2));
    // HTML `.animate-bubble` bubbles rising in the boiling water.
    for (var i = 0; i < 7; i++) {
      final ph = (t * 0.8 + i / 7) % 1;
      final x = 32 + (i * 13.7) % 38 + math.sin(t * 3 + i) * 1.5;
      c.drawCircle(
        Offset(x, 86 - ph * 40),
        1.2 + ph * 1.6,
        _fill(Colors.white.withValues(alpha: 0.85 * math.sin(ph * math.pi))),
      );
    }
    c.restore();
  }

  Path _beakerGlass() => Path()
    ..moveTo(25, 15)
    ..lineTo(25, 85)
    ..arcToPoint(const Offset(30, 90), radius: const Radius.circular(5), clockwise: false)
    ..lineTo(70, 90)
    ..arcToPoint(const Offset(75, 85), radius: const Radius.circular(5), clockwise: false)
    ..lineTo(75, 15);

  void _paintBeakerFront(Canvas c) {
    const b = _beakerBox;
    const k = _beakerK;
    c.save();
    c.translate(b.left, b.top);
    c.scale(k);
    c.drawPath(_beakerGlass(), _stroke(_Colors.slate400, 3));
    c.drawLine(const Offset(20, 15), const Offset(80, 15), _stroke(_Colors.slate400, 3));
    c.drawLine(const Offset(30, 22), const Offset(30, 80), _stroke(Colors.white.withValues(alpha: 0.3), 2));
    // Steam above the hot water.
    for (var i = 0; i < 3; i++) {
      final ph = (t * 0.35 + i / 3) % 1;
      final steam = Path();
      for (var j = 0; j <= 10; j++) {
        final y = 12 - j * 3.2 - ph * 14;
        final x = 38 + i * 12 + math.sin(j * 0.8 + t * 2 + i) * 2.5;
        j == 0 ? steam.moveTo(x, y) : steam.lineTo(x, y);
      }
      c.drawPath(steam, _stroke((isDark ? Colors.white : _Colors.slate500).withValues(alpha: 0.22 * math.sin(ph * math.pi)), 2));
    }
    c.restore();
    labText(
      c,
      tr('lbl_water'),
      Offset(b.left + 50 * k, b.top + 82 * k),
      size: 13,
      weight: FontWeight.w800,
      color: Colors.white,
      shadows: const [Shadow(color: Color(0x80000000), blurRadius: 3, offset: Offset(0, 1))],
    );
  }

  void _paintPetri(Canvas c, Offset center) {
    final outer = Rect.fromCenter(center: center, width: 132, height: 46);
    _dropShadow(c, Path()..addOval(outer), blur: 4, offset: const Offset(0, 4), alpha: 0.3);
    c.drawOval(outer, _fill(const Color(0xB3F1F5F9)));
    c.drawOval(outer, _stroke(_Colors.slate400, 3));
    c.drawOval(Rect.fromCenter(center: center.translate(0, -5), width: 118, height: 34), _stroke(_Colors.slate200, 1.5));
  }

  /// Alcohol tube in its rack: faint alcohol that turns green as the
  /// chlorophyll leaves the leaf.
  void _paintAlcoholTube(Canvas c, Offset center) {
    final s = scene;
    final dp = s.decolorized ? 1.0 : s.prog(s.bathAt == null ? null : s.bathAt! + 0.35, 1.15);
    final liquid = Color.lerp(const Color(0x33FFFFFF), const Color(0xD922C55E), dp)!;
    final r = Rect.fromCenter(center: center, width: 52, height: 144);
    _testTube(
      c,
      r,
      liquid: liquid,
      top: 42,
      inside: s.leafAlcohol && !s.decolorized
          ? (cc) {
              cc.save();
              cc.translate(20, 68);
              cc.scale(40 / r.width, 100 / r.height);
              _flatLeaf(cc, Offset.zero, 62, color: Color.lerp(_leafGreen, _Colors.yellow200, dp)!, rot: -math.pi / 2);
              cc.restore();
            }
          : null,
    );
    // Hidden in the water bath, where it would cover "Boiling Water".
    if (s.bathAt == null || s.decolorized) _label(c, 'lbl_alc', center + const Offset(0, -78));
  }

  void _paintRack(Canvas c, {required bool front}) {
    const wood = Color(0xFFA16207);
    if (!front) {
      for (final x in [574.0, 660.0]) {
        c.drawRect(Rect.fromLTWH(x, 424, 6, 50), _fill(labShade(wood, -0.25)));
      }
      final base = RRect.fromRectAndRadius(const Rect.fromLTWH(564, 468, 112, 10), const Radius.circular(3));
      labGroundShadow(c, const Offset(620, 478), 120, 8, opacity: 0.3);
      c.drawRRect(base, _fill(wood));
      c.drawRRect(base, _stroke(const Color(0xFF713F12), 1.5));
      c.drawOval(Rect.fromCenter(center: _tubeHome.translate(0, 42), width: 42, height: 8), _fill(const Color(0xFF3F2A0A)));
      return;
    }
    final top = RRect.fromRectAndRadius(const Rect.fromLTWH(564, 420, 112, 12), const Radius.circular(3));
    c.drawRRect(top, _fill(wood));
    c.drawRRect(top, _stroke(const Color(0xFF713F12), 1.5));
  }

  void _paintIodineBottle(Canvas c) {
    const body = Rect.fromLTWH(702, 424, 52, 56);
    _dropShadow(c, Path()..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(8))), blur: 5, alpha: 0.3);
    c.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF92400E), Color(0xFFB45309), Color(0xFF78350F)],
        ).createShader(body),
    );
    c.drawRect(const Rect.fromLTWH(717, 412, 22, 14), _fill(const Color(0xFF78350F)));
    final tag = RRect.fromRectAndRadius(const Rect.fromLTWH(710, 444, 36, 20), const Radius.circular(3));
    c.drawRRect(tag, _fill(const Color(0xF2FFFFFF)));
    labText(c, 'I₂', tag.center, size: 12, weight: FontWeight.w900, color: _Colors.amber900);
  }

  /// HTML `SVGS.dropper` (red bulb, glass tube, bouncing drip).
  void _paintDropper(Canvas c, Offset center, {bool drip = true}) {
    c.save();
    c.translate(center.dx - 50 * _dropperK, center.dy - 50 * _dropperK);
    c.scale(_dropperK);
    final glass = Path()
      ..moveTo(42, 35)
      ..lineTo(42, 80)
      ..lineTo(48, 95)
      ..lineTo(54, 80)
      ..lineTo(54, 35)
      ..close();
    _dropShadow(c, glass, blur: 4, alpha: 0.3);
    c.drawPath(glass, _fill(Colors.white.withValues(alpha: 0.9)));
    final ink = Path()
      ..moveTo(43.5, 56)
      ..lineTo(43.5, 80)
      ..lineTo(48, 92)
      ..lineTo(52.5, 80)
      ..lineTo(52.5, 56)
      ..close();
    c.drawPath(ink, _fill(_Colors.amber700.withValues(alpha: 0.85)));
    c.drawPath(glass, _stroke(_Colors.slate400, 2));
    c.drawRect(const Rect.fromLTRB(35, 15, 61, 35), _fill(_Colors.red500));
    c.drawCircle(const Offset(48, 15), 13, _fill(_Colors.red500));
    c.drawCircle(const Offset(43, 10), 4, _fill(Colors.white.withValues(alpha: 0.35)));
    if (drip) {
      final bounce = -4 * math.sin((t % 1) * math.pi).abs();
      c.drawCircle(Offset(48, 100 + bounce), 4, _fill(_Colors.amber700));
    }
    c.restore();
  }

  Color get _leafNow {
    final s = scene;
    if (!s.decolorized) return _leafGreen;
    return _Colors.yellow200;
  }

  void _paintS1Test(Canvas c, Size size) {
    final s = scene;
    final st = s.step;
    final dragging = s.drag;
    _paintBench(c);
    final dm = s.moves[_Item.dropper];
    final dropperInBottle = st == 7 && s.iodineAt == null && dragging != _Item.dropper && (dm == null || dm.progress(t) >= 1);
    if (dropperInBottle) _paintDropper(c, s.posOf(_Item.dropper), drip: false);
    _paintIodineBottle(c);
    _paintRack(c, front: false);
    _paintBeakerBack(c);
    // Leaf softening in the boiling water.
    if (s.leafBoiled && !s.leafAlcohol && dragging != _Item.leaf) {
      final m = s.moves[_Item.leaf];
      final p = m == null ? 1.0 : m.progress(t);
      final bob = math.sin(t * 2.4) * 1.5;
      _flatLeaf(c, s.posOf(_Item.leaf).translate(0, bob * p), _dishLeafW + (_beakerLeafW - _dishLeafW) * p, color: _leafGreen);
    }
    final tubeInBath = s.bathAt != null && !s.decolorized;
    if (tubeInBath && dragging != _Item.tube) _paintAlcoholTube(c, s.posOf(_Item.tube));
    _paintBeakerFront(c);
    _label(c, 'lbl_boil', Offset(_beakerBox.center.dx, _beakerBox.top + 12));
    // Petri dish with the leaf on it (it rides along when the dish moves).
    if (dragging != _Item.petri) {
      _paintPetri(c, s.posOf(_Item.petri));
      if (!s.leafBoiled) _flatLeaf(c, s.posOf(_Item.petri) + (_leafDish - _petriHome), _dishLeafW, color: _leafGreen);
    }
    if (!tubeInBath && dragging != _Item.tube) _paintAlcoholTube(c, s.posOf(_Item.tube));
    _paintRack(c, front: true);
    // The decolorized leaf back on the dish, then the iodine test.
    if (s.decolorized) {
      final ip = s.prog(s.iodineAt == null ? null : s.iodineAt! + 1.0, 0.8);
      final m = s.moves[_Item.leaf];
      final p = m == null ? 1.0 : m.progress(t);
      _flatLeaf(
        c,
        s.posOf(_Item.leaf),
        _dishLeafW * (0.6 + 0.4 * p),
        color: Color.lerp(_leafNow, _Colors.indigo950, ip)!,
        right: ip > 0 ? Color.lerp(_leafNow, _Colors.amber600, ip)! : null,
        petiole: true,
        edge: ip > 0 ? _Colors.green800 : _leafEdge,
      );
    }
    if (st == 7) {
      if (dragging != _Item.dropper) {
        if (!dropperInBottle) _paintDropper(c, s.posOf(_Item.dropper));
        if (s.iodineAt == null) _label(c, 'lbl_iodine', s.posOf(_Item.dropper) + const Offset(0, -50));
      }
      final ia = s.iodineAt;
      if (ia != null) {
        for (var i = 0; i < 3; i++) {
          final p = (t - ia - 0.55 - i * 0.25) / 0.3;
          final from = _dropperOverLeaf + _dropperTip + const Offset(0, 4);
          if (p > 0 && p < 1) {
            c.drawCircle(Offset(from.dx, from.dy + 34 * p * p), 4.5, _fill(_Colors.amber700));
          } else if (p >= 1 && p < 1.6) {
            final q = (p - 1) / 0.6;
            c.drawOval(
              Rect.fromCenter(center: Offset(from.dx, from.dy + 36), width: 10 + 34 * q, height: 4 + 12 * q),
              _stroke(_Colors.amber700.withValues(alpha: 0.7 * (1 - q)), 2),
            );
          }
        }
      }
    }
    if (dragging != null) {
      final target = _s1Target(dragging);
      if (target != null) {
        _paintDropHint(c, target.inflate(6), target.inflate(24).contains(s.posOf(dragging)));
      }
      final p = s.posOf(dragging);
      switch (dragging) {
        case _Item.petri:
          _paintPetri(c, p);
          _flatLeaf(c, p + (_leafDish - _petriHome), _dishLeafW, color: _leafGreen);
        case _Item.leaf:
          _flatLeaf(c, p, _beakerLeafW, color: _leafGreen);
        case _Item.tube:
          _paintAlcoholTube(c, p);
        case _Item.dropper:
          _paintDropper(c, p);
        default:
          break;
      }
    }
    if (st == 8) _paintStarchResult(c, size);
  }

  /// HTML step 8: big two-tone leaf with "Blue-Black / Brown" tags.
  void _paintStarchResult(Canvas c, Size size) {
    final s = scene;
    final p = s.prog(s.resultAt, 0.45);
    if (p <= 0) return;
    c.drawRect(labBleed(size), _fill(palette.canvasBg.withValues(alpha: 0.6 * p)));
    c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: p));
    const center = Offset(450, 252);
    final sc = 0.92 + 0.08 * Curves.easeOutBack.transform(p);
    c.translate(center.dx, center.dy);
    c.scale(sc);
    c.translate(-center.dx, -center.dy);
    final card = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 700, height: 250), const Radius.circular(22));
    _dropShadow(c, Path()..addRRect(card), blur: 18, offset: const Offset(0, 12), alpha: 0.45);
    c.drawRRect(card, _fill(isDark ? _Colors.slate800 : Colors.white));
    c.drawRRect(card, _stroke(palette.cardBorder, 1.5));
    _flatLeaf(c, center, 300, color: _Colors.indigo950, right: _Colors.amber600, petiole: true, edge: _Colors.green800);
    _tag(c, center + const Offset(-168, 0), true, tr('blue_black'), tr('outside'), _Colors.blue400);
    _tag(c, center + const Offset(168, 0), false, tr('brown'), tr('inside'), _Colors.amber500);
    c.restore();
  }

  void _tag(Canvas c, Offset anchor, bool alignRight, String title, String sub, Color color) {
    TextPainter tp(String text, double size, FontWeight w, Color col) => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: size,
              fontWeight: w,
              color: col,
              height: 1.2,
              fontFamily: LabFont.active.family,
              fontFamilyFallback: LabFont.active.fallback,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        )..layout(maxWidth: 150);
    final a = tp(title, 22, FontWeight.w900, color);
    final b = tp(sub, 12, FontWeight.w700, palette.textMuted);
    final w = math.max(a.width, b.width) + 22;
    final h = a.height + b.height + 18;
    final left = alignRight ? anchor.dx - w : anchor.dx;
    final box = RRect.fromRectAndRadius(Rect.fromLTWH(left, anchor.dy - h / 2, w, h), const Radius.circular(10));
    _dropShadow(c, Path()..addRRect(box), blur: 8, alpha: 0.3);
    c.drawRRect(box, _fill(isDark ? _Colors.slate900 : _Colors.slate50));
    c.drawRRect(box, _stroke(palette.cardBorder, 1.2));
    final x = alignRight ? box.right - 11 : box.left + 11;
    a.paint(c, Offset(alignRight ? x - a.width : x, box.top + 8));
    b.paint(c, Offset(alignRight ? x - b.width : x, box.top + 10 + a.height));
  }

  // ------------------------------------------------------- scenario 2

  void _paintShelf(Canvas c) {
    for (final x in [150.0, 730.0]) {
      c.drawRect(Rect.fromLTWH(x, 520, 20, 80), _fill(_Colors.slate800));
    }
    final shelf = RRect.fromRectAndRadius(const Rect.fromLTWH(50, 500, 800, 20), const Radius.circular(4));
    _dropShadow(c, Path()..addRRect(shelf), blur: 10, offset: const Offset(0, 8), alpha: 0.4);
    c.drawRRect(shelf, _fill(_Colors.slate700));
    c.drawRect(const Rect.fromLTWH(50, 516, 800, 4), _fill(_Colors.slate900));
    c.drawLine(const Offset(54, 501), const Offset(846, 501), _stroke(Colors.white.withValues(alpha: 0.12), 1.5));
  }

  void _paintAbsorberDish(Canvas c, Offset center, double w) {
    final h = w * 24 / 70;
    c.save();
    c.translate(center.dx - w / 2, center.dy - h / 2);
    c.scale(w / 70, h / 24);
    c.translate(-15, -13);
    _dropShadow(c, Path()..addOval(Rect.fromCenter(center: const Offset(50, 25), width: 70, height: 24)), blur: 2, offset: const Offset(0, 2), alpha: 0.3);
    c.drawOval(Rect.fromCenter(center: const Offset(50, 25), width: 70, height: 24), _fill(_Colors.slate100));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 25), width: 70, height: 24), _stroke(_Colors.slate400, 2));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 22), width: 60, height: 18), _fill(_Colors.slate300));
    for (final (x, y, r) in [(40.0, 22.0, 3.0), (55.0, 20.0, 4.0), (48.0, 25.0, 2.0), (62.0, 24.0, 2.5), (34.0, 25.0, 2.0)]) {
      c.drawCircle(Offset(x, y), r, _fill(Colors.white));
    }
    c.restore();
  }

  /// HTML `SVGS.bellJar` (dome a little taller so the plant fits inside).
  void _paintBellJar(Canvas c, Offset base, double alpha) {
    const w = 132.0;
    const h = 136.0;
    c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: alpha));
    c.translate(base.dx - w / 2, base.dy - 0.9 * h);
    c.scale(w / 100, h / 100);
    final dome = Path()
      ..moveTo(15, 90)
      ..cubicTo(15, -10, 85, -10, 85, 90);
    c.drawPath(
      Path.from(dome)..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF), Color(0x4DFFFFFF)],
        ).createShader(const Rect.fromLTWH(15, 0, 70, 90)),
    );
    c.drawPath(dome, _stroke(_Colors.slate300, 2.4));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 90), width: 70, height: 12), _stroke(_Colors.slate400, 2.4));
    c.drawPath(
      Path()
        ..moveTo(42, 16)
        ..cubicTo(42, 11, 58, 11, 58, 16),
      _stroke(_Colors.slate300, 2.4),
    );
    c.drawCircle(const Offset(50, 10), 3, _fill(_Colors.slate300));
    final shine = Path()
      ..moveTo(24, 70)
      ..cubicTo(22, 40, 30, 22, 40, 16);
    c.drawPath(shine, _stroke(Colors.white.withValues(alpha: 0.55), 2.5));
    c.restore();
  }

  /// HTML `SVGS.ventBox` / `SVGS.sealedBox` covering a plant.
  void _paintDarkBox(Canvas c, Rect front, {required bool vent, required double alpha}) {
    c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: alpha));
    _dropShadow(c, Path()..addRect(front), blur: 8, alpha: 0.4);
    labBox3D(c, front, 12, vent ? const Color(0xFFA16207) : _Colors.slate950, radius: 4);
    c.drawRRect(
      RRect.fromRectAndRadius(front, const Radius.circular(4)),
      _stroke(vent ? const Color(0xFF713F12) : Colors.black, 3),
    );
    if (vent) {
      for (final fx in [0.3, 0.7]) {
        for (final fy in [0.3, 0.7]) {
          c.drawCircle(Offset(front.left + front.width * fx, front.top + front.height * fy), 5, _fill(const Color(0xFF1C1917)));
        }
      }
    } else {
      c.drawLine(front.topLeft.translate(10, 10), front.topLeft.translate(40, 10), _stroke(Colors.white.withValues(alpha: 0.08), 2));
    }
    c.restore();
  }

  void _paintZone(Canvas c, int i) {
    final s = scene;
    final r = _zones[i];
    final sun = i < 2;
    final co2 = i.isEven;
    final darkZone = i >= 2;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(16));
    final fill = darkZone
        ? const Color(0xCC0F172A)
        : (isDark ? const Color(0x4D1E293B) : const Color(0xB3FFFFFF));
    c.drawRRect(rr, _fill(fill));
    if (sun) {
      c.save();
      c.clipRRect(rr);
      labGlow(c, Offset(r.left + 30, r.top + 30), 240, const Color(0xFFFDE047), intensity: isDark ? 0.22 : 0.3);
      c.restore();
    }
    final dragged = s.drag;
    final hover = dragged != null && _s2Plants.contains(dragged) && r.inflate(12).contains(s.posOf(dragged));
    if (hover) {
      c.drawRRect(rr, _fill(_Colors.green500.withValues(alpha: 0.2)));
      c.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..color = _Colors.green500.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      c.drawRRect(rr.deflate(1.5), _stroke(_Colors.green500, 3));
    } else {
      labDashedPath(
        c,
        Path()..addRRect(rr.deflate(1.5)),
        _stroke((co2 ? _Colors.green500 : _Colors.red500).withValues(alpha: 0.55), 3),
        dash: 12,
        gap: 8,
      );
    }
    if (sun) _paintSun(c, Offset(r.left + 30, r.top + 30), 10, t * 2 * math.pi / 20);
    labText(
      c,
      tr(co2 ? 'badge_co2' : 'badge_no_co2'),
      Offset(r.right - 12, r.top + 12),
      anchor: Alignment.topRight,
      size: 12,
      weight: FontWeight.w800,
      color: co2 ? _Colors.green300 : _Colors.red300,
      background: (co2 ? _Colors.green900 : _Colors.red900).withValues(alpha: 0.85),
      border: co2 ? _Colors.green700 : _Colors.red700,
      borderWidth: 1,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
    labText(
      c,
      tr('zone_${'abcd'[i]}'),
      Offset(r.center.dx, r.bottom - 8),
      anchor: Alignment.bottomCenter,
      size: 15,
      weight: FontWeight.w900,
      color: darkZone || isDark ? _Colors.slate300 : _Colors.slate700,
      letterSpacing: 0.4,
    );
    if (s.placedAt.containsKey(i)) _paintPlacedPlant(c, i);
    if (s.waitingDish == i) {
      final pulse = 0.5 + 0.5 * math.sin(t * 4);
      final dc = _dishWaitCenter(i);
      labGlow(c, dc, 40 + 6 * pulse, _Colors.blue400, intensity: 0.45 + 0.35 * pulse);
      _paintAbsorberDish(c, dc, 48);
      _label(c, 'lbl_absorber', dc + const Offset(0, -16), size: 12);
    }
  }

  /// A plant settling into its zone, then its bell jar / box and dish.
  void _paintPlacedPlant(Canvas c, int i) {
    final s = scene;
    final r = _zones[i];
    final at = s.placedAt[i]!;
    final p = Curves.easeOutCubic.transform(((t - at) / 0.35).clamp(0.0, 1.0));
    final plantBottom = r.bottom - 30;
    final spot = Offset(r.center.dx, plantBottom - 60 * _zonePlantScale);
    final center = Offset.lerp(s.placedFrom[i] ?? spot, spot, p)!;
    final k = 1 + (_zonePlantScale - 1) * p;
    // Absorber dish inside the bell jar (B), next to the pot.
    final dishB = i == 1 && s.dishBAt != null;
    final dishD = i == 3 && s.dishDAt != null;
    Offset dishPos(double? at, Offset to) {
      final q = Curves.easeInOutCubic.transform(s.prog(at, 0.5));
      return Offset.lerp(_dishWaitCenter(i), to, q)!;
    }

    if (dishB) _paintAbsorberDish(c, dishPos(s.dishBAt, Offset(r.center.dx + 36, plantBottom - 5)), 48 - 20 * s.prog(s.dishBAt, 0.5));
    _paintPottedPlant(c, center, k, plantBottom: 40);
    final cp = Curves.easeOutCubic.transform(((t - at - 0.35) / 0.45).clamp(0.0, 1.0));
    if (cp > 0) {
      final drop = (1 - cp) * -110;
      if (i == 1) _paintBellJar(c, Offset(r.center.dx, plantBottom + 3 + drop), cp);
      if (i >= 2) {
        final front = Rect.fromLTWH(r.center.dx - 62, plantBottom + 4 - 112 + drop, 116, 112);
        _paintDarkBox(c, front, vent: i == 2, alpha: cp);
      }
    }
    if (dishD) _paintAbsorberDish(c, dishPos(s.dishDAt, Offset(r.center.dx - 34, plantBottom - 7)), 48 - 18 * s.prog(s.dishDAt, 0.5));
  }

  void _paintShelfPlant(Canvas c, int i) {
    final center = scene.posOf(_s2Plants[i]);
    _paintPottedPlant(c, center, 1, plantBottom: 40);
    if (showLabels) {
      labText(
        c,
        labFormat(tr('lbl_plant'), {'p': _letters[i]}),
        center + const Offset(0, 72),
        size: 12,
        weight: FontWeight.w800,
        color: _Colors.slate300,
        background: _Colors.slate900,
        border: _Colors.slate700,
        borderWidth: 1,
        radius: 6,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      );
    }
  }

  void _paintS2(Canvas c, Size size) {
    final s = scene;
    _paintShelf(c);
    if (s.step <= 5) {
      for (var i = 0; i < 4; i++) {
        _paintZone(c, i);
      }
      final dragged = s.drag;
      for (var i = 0; i < 4; i++) {
        if (!s.placedAt.containsKey(i) && dragged != _s2Plants[i]) _paintShelfPlant(c, i);
      }
      if (dragged != null && _s2Plants.contains(dragged)) _paintShelfPlant(c, _s2Plants.indexOf(dragged));
      if (s.step == 5 && s.simAt != null) {
        final p = s.prog(s.simAt, 3.0);
        c.drawRect(labBleed(size), _fill(_Colors.slate900.withValues(alpha: 0.6)));
        _paintClock(c, const Offset(440, 262), 100, 48 * p, 48);
      }
    } else {
      _paintResultCards(c);
    }
  }

  /// HTML steps 6–7: the four leaves before and after the iodine test.
  void _paintResultCards(Canvas c) {
    final s = scene;
    final done = s.step >= 7;
    const w = 360.0;
    const h = 188.0;
    for (var i = 0; i < 4; i++) {
      final r = Rect.fromLTWH(70 + (i % 2) * (w + 20), 54 + (i ~/ 2) * (h + 20), w, h);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(18));
      final starch = i == 0;
      Color fill;
      Color border;
      Color title;
      if (!done) {
        fill = isDark ? _Colors.slate800 : Colors.white;
        border = isDark ? _Colors.slate600 : _Colors.slate300;
        title = isDark ? _Colors.slate300 : _Colors.slate600;
      } else if (starch) {
        fill = isDark ? const Color(0x4D14532D) : const Color(0xFFF0FDF4);
        border = _Colors.green500;
        title = isDark ? _Colors.green300 : _Colors.green700;
      } else {
        fill = isDark ? const Color(0x4D7F1D1D) : const Color(0xFFFEF2F2);
        border = _Colors.red500.withValues(alpha: 0.5);
        title = isDark ? _Colors.slate400 : _Colors.slate500;
      }
      _dropShadow(c, Path()..addRRect(rr), blur: 12, offset: const Offset(0, 8), alpha: 0.35);
      c.drawRRect(rr, _fill(isDark ? _Colors.slate900 : Colors.white));
      c.drawRRect(rr, _fill(fill));
      c.drawRRect(rr, _stroke(border, done ? 2.5 : 1.2));
      labText(
        c,
        tr('zone_${'abcd'[i]}'),
        Offset(r.center.dx, r.top + 30),
        size: 15,
        weight: FontWeight.w800,
        color: title,
      );
      // Leaf colour: pale → iodine brown (1.5 s), then A → blue-black.
      final ta = s.testAt;
      Color leaf = _Colors.yellow200;
      if (done) {
        leaf = starch ? _Colors.indigo950 : _Colors.amber600;
      } else if (ta != null) {
        final brown = ((t - ta) / 1.5).clamp(0.0, 1.0);
        leaf = Color.lerp(_Colors.yellow200, _Colors.amber600, brown)!;
        if (starch) {
          final blue = ((t - ta - 1.0) / 1.5).clamp(0.0, 1.0);
          leaf = Color.lerp(leaf, _Colors.indigo950, blue)!;
        }
        final dp = (t - ta) / 0.45;
        if (dp > 0 && dp < 1) {
          c.drawCircle(Offset(r.center.dx, r.top + 50 + 50 * dp * dp), 4.5, _fill(_Colors.amber700));
        }
      }
      final leafC = Offset(r.center.dx, r.top + (done ? 94 : 104));
      _flatLeaf(c, leafC, 160, color: leaf);
      if (done) {
        labText(
          c,
          tr(starch ? 'starch_present' : 'no_starch'),
          Offset(r.center.dx, r.bottom - 24),
          size: 13,
          weight: FontWeight.w900,
          color: starch ? (isDark ? _Colors.green400 : _Colors.green700) : (isDark ? _Colors.red400 : _Colors.red700),
          background: isDark ? _Colors.slate900 : (starch ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2)),
          letterSpacing: 0.6,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LabPainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang;
}

// ================================================================ CONFETTI

/// One canvas-confetti particle (same physics as `confetti.browser.js`).
class _Confetto {
  _Confetto({
    required this.wobble,
    required this.wobbleSpeed,
    required this.velocity,
    required this.angle,
    required this.tilt,
    required this.color,
    required this.circle,
  });

  static const int total = 200;

  double x = 0;
  double y = 0;
  double wobble;
  final double wobbleSpeed;
  double velocity;
  final double angle;
  double tilt;
  final Color color;
  final bool circle;
  double random = 2;
  int tick = 0;

  double get wobbleX => x + 10 * math.cos(wobble);
  double get wobbleY => y + 10 * math.sin(wobble);

  void step(math.Random rng) {
    x += math.cos(angle) * velocity;
    y += math.sin(angle) * velocity + 3; // gravity 1 × 3
    velocity *= 0.9; // decay
    wobble += wobbleSpeed;
    tilt += 0.1;
    random = rng.nextDouble() + 2;
    tick++;
  }
}

/// A short native confetti burst (HTML `confetti({particleCount, spread,
/// origin})`), stepped at 60 Hz by the lab's ticker.
class _Confetti {
  final List<_Confetto> parts = [];
  final math.Random _rng = math.Random(7);
  Offset origin = const Offset(0.5, 0.5);
  double? _last;

  static const List<Color> _colors = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];

  void burst({required int count, required double spread, double originY = 0.5}) {
    origin = Offset(0.5, originY);
    final sp = spread * math.pi / 180;
    for (var i = 0; i < count; i++) {
      parts.add(_Confetto(
        wobble: _rng.nextDouble() * 10,
        wobbleSpeed: math.min(0.11, _rng.nextDouble() * 0.1 + 0.05),
        velocity: 45 * 0.5 + _rng.nextDouble() * 45,
        angle: -math.pi / 2 + (0.5 * sp - _rng.nextDouble() * sp),
        tilt: (_rng.nextDouble() * 0.5 + 0.25) * math.pi,
        color: _colors[i % _colors.length],
        circle: _rng.nextBool(),
      ));
    }
  }

  void clear() {
    parts.clear();
    _last = null;
  }

  void update(double time) {
    if (parts.isEmpty) {
      _last = null;
      return;
    }
    final last = _last ??= time;
    var n = ((time - last) * 60).floor();
    if (n <= 0) return;
    if (n > 12) {
      n = 12;
      _last = time;
    } else {
      _last = last + n / 60;
    }
    for (var i = 0; i < n; i++) {
      for (final p in parts) {
        p.step(_rng);
      }
    }
    parts.removeWhere((p) => p.tick >= _Confetto.total);
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.confetti, required Listenable repaint}) : super(repaint: repaint);

  final _Confetti confetti;

  @override
  void paint(Canvas canvas, Size size) {
    if (confetti.parts.isEmpty) return;
    // canvas-confetti works in window pixels: map a ~900 px tall browser
    // window onto the canvas for the flight, and keep the paper bits a
    // readable size on small screens.
    final k = size.height / 900;
    final ks = (size.height / 560).clamp(0.75, 1.3);
    final o = Offset(size.width * confetti.origin.dx, size.height * confetti.origin.dy);
    for (final p in confetti.parts) {
      final alpha = (1 - p.tick / _Confetto.total).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: alpha);
      final ts = math.sin(p.tilt);
      final tc = math.cos(p.tilt);
      final c = o + Offset(p.x, p.y) * k;
      // Shape points relative to the particle (wobble + tilt), in px.
      final w = Offset(p.wobbleX - p.x, p.wobbleY - p.y);
      final r = Offset(p.random * tc, p.random * ts);
      if (p.circle) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(math.pi / 10 * p.wobble);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: math.max(0.6, w.dx.abs() * 0.6 * 2 * ks),
            height: math.max(0.6, w.dy.abs() * 0.6 * 2 * ks),
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawPath(
          Path()
            ..addPolygon([
              c,
              c + Offset(w.dx, r.dy) * ks,
              c + (w + r) * ks,
              c + Offset(r.dx, w.dy) * ks,
            ], true),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.confetti != confetti;
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
