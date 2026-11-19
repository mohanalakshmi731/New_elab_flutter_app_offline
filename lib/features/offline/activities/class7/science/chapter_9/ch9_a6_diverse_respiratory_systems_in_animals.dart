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

/// Class 7 Science • Chapter 9 • Activity 6
/// Diverse Respiratory Systems in Animals.
///
/// Native Flutter port of `Cl7S-Ch9-A6-Diverse_Respiratory_Systems_in_Animals.html`.
/// Scenario 1 drops a fish into an aquarium and zooms into its gills, where
/// dissolved O₂ passes from the water into the blood. Scenario 2 X-rays a
/// frog: its lungs breathe air on land, its moist skin absorbs O₂ in a pond.
class Ch9A6DiverseRespiratorySystemsInAnimalsPage extends StatefulWidget {
  const Ch9A6DiverseRespiratorySystemsInAnimalsPage({super.key});

  @override
  State<Ch9A6DiverseRespiratorySystemsInAnimalsPage> createState() =>
      _Ch9A6DiverseRespiratorySystemsInAnimalsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, pickup 2356, splash 1311.
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

  /// HTML `playSound('pop')`: drops, X-ray and summary buttons.
  pop('pop.mp3'),

  /// A tool or animal picked up for dragging.
  pickup('pickup.mp3'),

  /// The fish or the frog entering the water.
  splash('splash.mp3');

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

/// Tailwind colours (`bio` / sky palette) and Three.js material colours used
/// by this lab.
abstract final class _Colors {
  static const Color sky100 = Color(0xFFE0F2FE); // bio.light
  static const Color sky200 = Color(0xFFBAE6FD);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky500 = Color(0xFF0EA5E9); // bio.main
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky700 = Color(0xFF0369A1); // bio.dark
  static const Color sky900 = Color(0xFF0C4A6E);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color red500 = Color(0xFFEF4444);
  static const Color orange500 = Color(0xFFF97316);
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

  // Three.js materials.
  static const Color fishBody = Color(0xFFFF6B00);
  static const Color fishGill = Color(0xFFC2410C);
  static const Color filament = Color(0xFFFCA5A5);
  static const Color gillArch = Color(0xFFE2E8F0);
  static const Color bloodDeoxy = Color(0xFF4C1D95);
  static const Color bloodOxy = Color(0xFFDC2626);
  static const Color frogSkin = Color(0xFF22C55E);
  static const Color frogXray = Color(0xFFA7F3D0);
  static const Color frogEye = Color(0xFFFDE047);
  static const Color lilypad = Color(0xFF4ADE80);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB020617),
    border: Color(0x26FFFFFF),
    card: Color(0xCC0F172A),
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.sky500,
    onAccent: _Colors.slate950,
    primary: _Colors.sky600,
    onPrimary: Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.sky400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.sky100,
    toastText: _Colors.sky900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x660C4A6E),
    curtainText: Colors.white,
    curtainMuted: Color(0xCC7DD3FC),
    curtainIcon: _Colors.sky400,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE60F172A),
    labelText: Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate50,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate50,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.sky600,
    onAccent: Colors.white,
    primary: _Colors.sky600,
    onPrimary: Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.sky600,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x660C4A6E),
    curtainText: Colors.white,
    curtainMuted: Color(0xCC7DD3FC),
    curtainIcon: _Colors.sky400,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFFFFAB40),
    buttonBorder: Color(0xCCFF9800),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE60F172A),
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
    'app_title': 'Diverse Respiratory Systems in Animals',
    'app_subtitle': 'Class 7 • Life Processes in Animals',
    'scen_1_opt': 'Scenario 1: Gills: Breathing Underwater',
    'scen_2_opt': 'Scenario 2: Amphibian Adaptations: Lungs and Skin',
    'welcome_lab': 'Welcome to the Biology Lab.',
    'board_desc_1':
        "Fish live underwater, where there is no air! Let's see how they breathe using special organs called gills.",
    'board_desc_2':
        "Frogs are amphibians—they live on land and in water. Let's look inside to see how they manage to breathe in both places!",
    'btn_setup': 'Setup Activity',
    'btn_summary': 'View Summary',
    'btn_xray': 'X-Ray Vision',
    'lbl_fish': 'Fish',
    'lbl_mag': 'Inspect',
    'lbl_frog': 'Frog',
    'tools': 'Tools',
    'success': 'Success!',
    'observation_title': 'Key Takeaway',
    'sc_complete': 'Scenario {n} Complete!',
    'next_sc': 'Please select the next scenario from the sidebar!',
    'sum_title_1': 'The Gill Advantage!',
    'sum_text_1':
        'Gills are highly efficient organs for aquatic life. As water flows over the feathery gill filaments, dissolved oxygen is absorbed directly into the extensive network of blood vessels, instantly oxygenating the blood.',
    'sum_title_2': 'Dual Breathing Mechanisms!',
    'sum_text_2':
        'Amphibians like frogs have adapted to life in two worlds. On land, they use simple sac-like lungs. In water, their lungs shut down, and they absorb dissolved oxygen directly through their highly vascular, moist skin (cutaneous respiration).',
    // Feedback that was hard-coded in the HTML drag handler.
    'msg_fish_in': 'Fish already in the aquarium.',
    'msg_not_needed': 'Not needed right now.',
    'msg_land_first': 'Watch the breathing on land first.',
    'msg_drop_tank': 'Drop the fish inside the aquarium.',
    'msg_drop_gills': "Drop the Inspect tool over the fish's gills.",
    'msg_drop_pond': 'Drop the frog into the pond.',
    // Scene labels and legend.
    'lbl_aquarium': 'Aquarium',
    'lbl_mouth': 'Mouth',
    'lbl_gills': 'Gills (under the gill cover)',
    'lbl_water_in': 'Water in',
    'lbl_water_out': 'Water out',
    'lbl_gill_arch': 'Gill arch',
    'lbl_filaments': 'Gill filaments',
    'lbl_capillaries': 'Blood capillaries',
    'lbl_rich': 'O₂-rich water',
    'lbl_poor': 'O₂-poor water',
    'lbl_land': 'Land',
    'lbl_pond': 'Pond',
    'lbl_lungs': 'Lungs',
    'lbl_skin_caps': 'Skin capillaries',
    'lbl_nostrils': 'Nostrils',
    'lbl_air': 'Air',
    'lbl_dissolved': 'Dissolved O₂',
    'lbl_drop_here': 'Drop here',
    'mode_gills': 'Breathing with gills',
    'mode_land': 'On land: lungs',
    'mode_water': 'In water: moist skin',
    'leg_deoxy': 'Deoxygenated blood',
    'leg_oxy': 'Oxygenated blood',
    'leg_o2': 'Dissolved oxygen (O₂)',
    'leg_air': 'Air (O₂)',
  },
  'hi': {
    'app_title': 'जानवरों में विविध श्वसन प्रणालियाँ',
    'app_subtitle': 'कक्षा 7 • जंतुओं में जैव प्रक्रम',
    'scen_1_opt': 'परिदृश्य 1: गलफड़े: पानी के नीचे साँस लेना',
    'scen_2_opt': 'परिदृश्य 2: उभयचर अनुकूलन: फेफड़े और त्वचा',
    'welcome_lab': 'जीव विज्ञान लैब में आपका स्वागत है।',
    'board_desc_1': 'मछलियाँ पानी के नीचे रहती हैं! आइए देखें कि वे गलफड़ों का उपयोग करके कैसे साँस लेती हैं।',
    'board_desc_2': 'मेंढक उभयचर हैं। आइए देखें कि वे हवा और पानी दोनों में कैसे साँस लेते हैं!',
    'btn_setup': 'गतिविधि सेट करें',
    'btn_summary': 'सारांश देखें',
    'btn_xray': 'एक्स-रे दृष्टि',
    'lbl_fish': 'मछली',
    'lbl_mag': 'निरीक्षण करें',
    'lbl_frog': 'मेंढक',
    'tools': 'उपकरण',
    'success': 'सफलता!',
    'observation_title': 'मुख्य निष्कर्ष',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'next_sc': 'कृपया अगला परिदृश्य चुनें!',
    'sum_title_1': 'गलफड़ों का लाभ!',
    'sum_text_1':
        'गलफड़े जलीय जीवन के लिए अत्यधिक कुशल अंग हैं। ऑक्सीजन सीधे रक्त वाहिकाओं के नेटवर्क में अवशोषित हो जाती है, जिससे रक्त तुरंत ऑक्सीजन युक्त हो जाता है।',
    'sum_title_2': 'दोहरी श्वास प्रणाली!',
    'sum_text_2':
        'मेंढक जैसे उभयचरों ने दो दुनियाओं में रहने के लिए अनुकूलन किया है। ज़मीन पर, वे फेफड़ों का उपयोग करते हैं। पानी में, वे सीधे अपनी नम त्वचा (त्वचीय श्वसन) के माध्यम से ऑक्सीजन को अवशोषित करते हैं।',
    'msg_fish_in': 'मछली पहले से ही एक्वेरियम में है।',
    'msg_not_needed': 'अभी इसकी ज़रूरत नहीं है।',
    'msg_land_first': 'पहले ज़मीन पर साँस लेना देखें।',
    'msg_drop_tank': 'मछली को एक्वेरियम के अंदर छोड़ें।',
    'msg_drop_gills': "'निरीक्षण' टूल को मछली के गलफड़ों पर छोड़ें।",
    'msg_drop_pond': 'मेंढक को तालाब में छोड़ें।',
    'lbl_aquarium': 'एक्वेरियम',
    'lbl_mouth': 'मुँह',
    'lbl_gills': 'गलफड़े (गलफड़ा ढक्कन के नीचे)',
    'lbl_water_in': 'पानी अंदर',
    'lbl_water_out': 'पानी बाहर',
    'lbl_gill_arch': 'गलफड़ा चाप',
    'lbl_filaments': 'गलफड़ा तंतु',
    'lbl_capillaries': 'रक्त केशिकाएँ',
    'lbl_rich': 'O₂ युक्त पानी',
    'lbl_poor': 'कम O₂ वाला पानी',
    'lbl_land': 'ज़मीन',
    'lbl_pond': 'तालाब',
    'lbl_lungs': 'फेफड़े',
    'lbl_skin_caps': 'त्वचा की केशिकाएँ',
    'lbl_nostrils': 'नासिका छिद्र',
    'lbl_air': 'हवा',
    'lbl_dissolved': 'घुली हुई O₂',
    'lbl_drop_here': 'यहाँ छोड़ें',
    'mode_gills': 'गलफड़ों से श्वसन',
    'mode_land': 'ज़मीन पर: फेफड़े',
    'mode_water': 'पानी में: नम त्वचा',
    'leg_deoxy': 'ऑक्सीजन रहित रक्त',
    'leg_oxy': 'ऑक्सीजन युक्त रक्त',
    'leg_o2': 'घुली हुई ऑक्सीजन (O₂)',
    'leg_air': 'हवा (O₂)',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective: 'To investigate how a fish uses gills to extract dissolved oxygen from water.',
      steps: [
        LabStep(
          concept: 'Aquatic Environment',
          action: 'DRAG the 3D model of a fish into the virtual aquarium.',
          observation: 'Water flows into its mouth and out through the gill slits.',
        ),
        LabStep(
          concept: 'Gill Structure',
          action: "DRAG the 'Inspect' tool over the fish's gills.",
          observation: 'The view zooms into a cross-section of feathery gill filaments with blood vessels.',
        ),
        LabStep(
          concept: 'Gas Exchange',
          action: 'OBSERVE the flow.',
          observation: 'Blue O2 particles move from water to blood. The blood instantly turns bright red (oxygenated).',
        ),
        LabStep(
          concept: 'Conclusion',
          action: "CLICK 'View Summary'.",
          observation: 'Gills are specifically adapted to filter dissolved oxygen from passing water.',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'To explore how a frog uses two different methods of respiration to survive on land and in water.',
      steps: [
        LabStep(
          concept: 'Internal Structure',
          action: "CLICK the 'X-Ray Vision' button.",
          observation: "The frog's simple lungs and a dense network of blood vessels under its skin become visible.",
        ),
        LabStep(
          concept: 'Terrestrial Breathing',
          action: 'OBSERVE the frog on land.',
          observation: 'Air enters nostrils. Lungs inflate. Oxygen is absorbed into lung blood vessels (turning red).',
        ),
        LabStep(
          concept: 'Changing Environment',
          action: 'DRAG the frog into the pond.',
          observation: 'The lung animation stops. Lungs deflate and revert to purplish-blue blood.',
        ),
        LabStep(
          concept: 'Aquatic Breathing',
          action: 'OBSERVE the frog in water.',
          observation:
              'Dissolved oxygen is absorbed directly through the moist skin into the capillary network (turning red).',
        ),
        LabStep(
          concept: 'Conclusion',
          action: "CLICK 'View Summary'.",
          observation: 'Frogs utilize dual mechanisms: lungs for air and moist skin for water.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह जाँचने के लिए कि मछली पानी से घुली हुई ऑक्सीजन निकालने के लिए गलफड़ों (gills) का उपयोग कैसे करती है।',
      steps: [
        LabStep(
          concept: 'जलीय पर्यावरण',
          action: 'मछली को एक्वेरियम में खींचें।',
          observation: 'पानी इसके मुंह में जाता है और गलफड़ों से बाहर निकलता है।',
        ),
        LabStep(
          concept: 'गलफड़ों की संरचना',
          action: "'निरीक्षण' टूल को गलफड़ों पर खींचें।",
          observation: 'दृश्य गलफड़ों के फिलामेंट्स और रक्त वाहिकाओं में ज़ूम होता है।',
        ),
        LabStep(
          concept: 'गैस विनिमय',
          action: 'प्रवाह का निरीक्षण करें।',
          observation: 'O2 कण पानी से रक्त में जाते हैं। रक्त तुरंत लाल (ऑक्सीजन युक्त) हो जाता है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: "'सारांश देखें' पर क्लिक करें।",
          observation: 'गलफड़े बहते पानी से घुली हुई ऑक्सीजन को अवशोषित करने के लिए अनुकूलित होते हैं।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह पता लगाने के लिए कि मेंढक भूमि और पानी में जीवित रहने के लिए श्वसन के दो अलग-अलग तरीकों का उपयोग कैसे करता है।',
      steps: [
        LabStep(
          concept: 'आंतरिक संरचना',
          action: "'एक्स-रे दृष्टि' बटन पर क्लिक करें।",
          observation: 'मेंढक के फेफड़े और उसकी त्वचा के नीचे रक्त वाहिकाओं का एक घना नेटवर्क दिखाई देता है।',
        ),
        LabStep(
          concept: 'स्थलीय श्वसन',
          action: 'जमीन पर मेंढक का निरीक्षण करें।',
          observation: 'हवा नासिका से प्रवेश करती है। फेफड़े फूलते हैं। ऑक्सीजन फेफड़ों की रक्त वाहिकाओं में अवशोषित होती है।',
        ),
        LabStep(
          concept: 'बदलता पर्यावरण',
          action: 'मेंढक को तालाब में खींचें।',
          observation: 'फेफड़ों की गति रुक जाती है। फेफड़े पिचक जाते हैं।',
        ),
        LabStep(
          concept: 'जलीय श्वसन',
          action: 'पानी में मेंढक का निरीक्षण करें।',
          observation: 'घुली हुई ऑक्सीजन सीधे नम त्वचा के माध्यम से केशिका नेटवर्क में अवशोषित होती है।',
        ),
        LabStep(
          concept: 'निष्कर्ष',
          action: "'सारांश देखें' पर क्लिक करें।",
          observation: 'मेंढक दोहरे तंत्र का उपयोग करते हैं: हवा के लिए फेफड़े और पानी के लिए नम त्वचा।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 600);

// Scenario 1: an aquarium on a table (design px).
const Rect _tank = Rect.fromLTRB(190, 150, 750, 450);
const Offset _tankDepth = Offset(42, -28);
const double _waterTop = 178;
const double _gravelTop = 414;
const Rect _tankZone = Rect.fromLTRB(170, 100, 800, 470);
const Offset _bagCenter = Offset(100, 318);
const Offset _bagFish = Offset(100, 340);
const Offset _fishHome = Offset(462, 300);
const double _fishLen = 250;
const double _bagScale = 0.42;
const double _heldScale = 0.6;
const Offset _gillPoint = Offset(462 + 0.225 * 250, 300);
const double _gillRadius = 95;

// Scenario 2: a grassy bank and a pond.
const double _groundY = 342;
const double _pondY = 382;
const double _shoreX = 384;
const double _frogLen = 190;
const Offset _frogLand = Offset(200, _groundY - 0.40 * _frogLen);
const Offset _frogPond = Offset(612, _pondY - 8);
const Offset _padCenter = Offset(818, _pondY + 4);
const Rect _pondZone = Rect.fromLTRB(400, 300, 930, 590);

/// Draggable things: the fish and the frog (tray or scene) and the
/// 'Inspect' magnifier.
enum _Item { fish, mag, frog }

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;

  /// HTML `State.step`: 0 = setup board, then 1..steps, steps + 1 = done.
  int step = 0;
  double time = 0;

  /// Item being dragged (tray or scene); its drop zone is highlighted.
  _Item? dragging;

  /// Fish / frog held directly in the scene and where it is.
  _Item? held;
  Offset? pointer;

  // Scenario 1: fish and gills (HTML State.s1).
  double fishStart = -1;
  Offset fishFrom = _bagFish;
  double fishFromScale = _bagScale;
  bool fishInWater = false;
  double zoomStart = -1;
  Offset lensAt = _gillPoint;
  bool magnified = false;

  // Scenario 2: frog (HTML State.s2).
  double xrayStart = -1;
  bool xrayOn = false;
  double jumpStart = -1;
  Offset frogFrom = _frogLand;
  bool frogInWater = false;
  double deflateFrom = 1;
  double waterO2Start = -1;

  // Effects.
  double splashStart = -1;
  Offset splashAt = Offset.zero;
  double confettiStart = -1;

  void reset(int index) {
    scenario = index;
    step = 0;
    dragging = null;
    held = null;
    pointer = null;
    fishStart = -1;
    fishFrom = _bagFish;
    fishFromScale = _bagScale;
    fishInWater = false;
    zoomStart = -1;
    lensAt = _gillPoint;
    magnified = false;
    xrayStart = -1;
    xrayOn = false;
    jumpStart = -1;
    frogFrom = _frogLand;
    frogInWater = false;
    deflateFrom = 1;
    waterO2Start = -1;
    splashStart = -1;
    confettiStart = -1;
  }

  double progress(double start, double seconds) =>
      start < 0 ? 0 : ((time - start) / seconds).clamp(0.0, 1.0);

  /// Camera zoom onto the gills (HTML 1.5 s camera tween).
  double get zoom => progress(zoomStart, 1.5);

  /// Cross-fade from the aquarium to the magnified gill cross-section.
  double get magFade => zoomStart < 0 ? 0 : ((time - zoomStart - 1.15) / 0.4).clamp(0.0, 1.0);

  /// X-ray transition of the frog's skin (HTML 1 s material tween).
  double get xray => progress(xrayStart, 1.0);

  /// HTML `Math.sin(time * 0.003)` with time in ms.
  double get breath => math.sin(time * 3);

  bool get frogLanded => jumpStart >= 0 && time - jumpStart >= 1;

  /// Where the fish is and how big (the bag is drawn smaller).
  ({Offset pos, double scale}) get fishPose {
    if (held == _Item.fish && pointer != null) return (pos: pointer!, scale: _heldScale);
    if (fishStart < 0) return (pos: _bagFish + Offset(0, math.sin(time * 2) * 3), scale: _bagScale);
    final t = progress(fishStart, 1.0);
    final scale = fishFromScale + (1 - fishFromScale) * Curves.easeOutCubic.transform(t);
    if (_tank.contains(fishFrom)) {
      // Dropped inside the tank: settle with a bounce (TWEEN Bounce.Out).
      return (pos: Offset.lerp(fishFrom, _fishHome, Curves.bounceOut.transform(t))!, scale: scale);
    }
    // Out of the bag, over the glass and down into the water.
    final apex = Offset(fishFrom.dx + (_fishHome.dx - fishFrom.dx) * 0.45, 72);
    if (t < 0.35) {
      return (pos: Offset.lerp(fishFrom, apex, Curves.easeOutQuad.transform(t / 0.35))!, scale: scale);
    }
    final q = (t - 0.35) / 0.65;
    return (
      pos: Offset(
        apex.dx + (_fishHome.dx - apex.dx) * Curves.easeOutCubic.transform(q),
        apex.dy + (_fishHome.dy - apex.dy) * Curves.bounceOut.transform(q),
      ),
      scale: scale,
    );
  }

  /// Where the frog is and how far its hind legs are stretched.
  ({Offset pos, double legs}) get frogPose {
    if (held == _Item.frog && pointer != null) return (pos: pointer!, legs: 0.6);
    if (jumpStart < 0) return (pos: _frogLand, legs: 0);
    final t = progress(jumpStart, 1.0);
    final fromLand = !_pondZone.contains(frogFrom);
    final apex = Offset(
      (frogFrom.dx + _frogPond.dx) / 2,
      math.min(frogFrom.dy, _frogPond.dy) - (fromLand ? 150 : 60),
    );
    // HTML: up to the apex (500 ms, Quadratic.Out), down to the pond
    // (500 ms, Bounce.Out).
    if (t < 0.5) {
      return (pos: Offset.lerp(frogFrom, apex, Curves.easeOutQuad.transform(t / 0.5))!, legs: t / 0.5);
    }
    final q = (t - 0.5) / 0.5;
    return (pos: Offset.lerp(apex, _frogPond, Curves.bounceOut.transform(q))!, legs: 1 - 0.1 * q);
  }

  double get lungScale {
    if (frogInWater) return deflateFrom + (0.5 - deflateFrom) * progress(jumpStart, 1.0);
    if (xrayOn) return 1 + 0.2 * breath;
    return 1;
  }

  Color get lungColor => xrayOn && !frogInWater
      ? Color.lerp(_Colors.bloodDeoxy, _Colors.bloodOxy, (breath + 1) / 2)!
      : _Colors.bloodDeoxy;

  double get throat => xrayOn && !frogInWater ? breath : -1;

  double get capOpacity => 0.6 * xray;

  Color get capColor => xrayOn && frogInWater
      ? Color.lerp(_Colors.bloodDeoxy, _Colors.bloodOxy, (breath + 1) / 2)!
      : _Colors.bloodDeoxy;
}

/// Pan recognizer that only joins the gesture arena when the touch starts
/// on the fish / frog, so canvas pan / zoom still works elsewhere.
class _AnimalPanRecognizer extends PanGestureRecognizer {
  _AnimalPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch9A6DiverseRespiratorySystemsInAnimalsPageState extends State<Ch9A6DiverseRespiratorySystemsInAnimalsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final GlobalKey _stageKey = GlobalKey();
  late final Ticker _ticker;

  // HTML interactive UI state.
  bool _boardOpen = true; // #ui-setup-board
  bool _showXray = false; // #s2-btn-xray
  bool _showSummary = false; // #s1-btn-summary / #s2-btn-summary
  final Set<_Item> _tray = {}; // #s1-tools / #s2-tools items

  int get _scenario => _scene.scenario;
  int get _step => _scene.step;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      _scene.time = elapsed.inMicroseconds / 1e6;
      _frame.value = _scene.time;
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

  /// HTML `changeScenario()` + `initScenario3D()`: fresh scene, setup
  /// board open, no pending timers.
  void _buildScenario(int index) {
    _lab.cancelPending();
    _scene.reset(index);
    _boardOpen = true;
    _showXray = false;
    _showSummary = false;
    _tray.clear();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _buildScenario(index);
    });
  }

  void _fullReset() => setState(() => _buildScenario(0));

  bool _still(int scenario, int step) => mounted && _scenario == scenario && _step == step;

  /// HTML board button: hides the board and starts step 1 with the
  /// scenario's tools (`resetS1UI` / `resetS2UI`).
  void _startActivity() {
    if (!_boardOpen) return;
    setState(() {
      _boardOpen = false;
      _scene.step = 1;
      if (_scenario == 0) {
        _tray.add(_Item.fish);
      } else {
        _showXray = true;
      }
    });
  }

  /// HTML `s1ActionDropFish()`: the fish drops into the tank; after 1 s the
  /// water starts flowing through it and the 'Inspect' tool appears.
  void _dropFish({Offset? from, double fromScale = _bagScale}) {
    if (_scenario != 0 || _step != 1 || _scene.fishStart >= 0) return;
    _Audio.play(_Sound.pop);
    final start = from ?? _bagFish;
    final inside = _tank.contains(start);
    setState(() {
      _tray.remove(_Item.fish);
      _scene
        ..fishFrom = start
        ..fishFromScale = fromScale
        ..fishStart = _scene.time;
    });
    _lab.after(Duration(milliseconds: inside ? 60 : 520), () {
      if (!_still(0, 1)) return;
      _Audio.play(_Sound.splash);
      _scene
        ..splashStart = _scene.time
        ..splashAt = Offset(_scene.fishPose.pos.dx, _waterTop);
    });
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!_still(0, 1)) return;
      setState(() {
        _scene
          ..fishInWater = true
          ..step = 2;
        _tray.add(_Item.mag);
      });
    });
  }

  /// HTML `s1ActionMagnify()`: the camera zooms onto the gills (1.5 s),
  /// the cross-section appears, and after 3.5 s of observing the
  /// 'View Summary' button shows.
  void _magnify(Offset at) {
    if (_scenario != 0 || _step != 2 || _scene.zoomStart >= 0) return;
    _Audio.play(_Sound.pop);
    setState(() {
      _tray.remove(_Item.mag);
      _scene
        ..lensAt = at
        ..zoomStart = _scene.time;
    });
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!_still(0, 2)) return;
      setState(() {
        _scene
          ..magnified = true
          ..step = 3;
      });
      _lab.after(const Duration(milliseconds: 3500), () {
        if (!_still(0, 3)) return;
        setState(() {
          _scene.step = 4;
          _showSummary = true;
        });
      });
    });
  }

  /// HTML `s2ActionXRay()`: the skin turns translucent (1 s), the frog
  /// breathes on land, and 2.5 s later it can be dragged to the pond.
  void _xray() {
    if (!_showXray || _scenario != 1 || _step != 1) return;
    _Audio.play(_Sound.pop);
    setState(() {
      _showXray = false;
      _scene.xrayStart = _scene.time;
    });
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!_still(1, 1)) return;
      setState(() {
        _scene
          ..xrayOn = true
          ..step = 2;
      });
      _lab.after(const Duration(milliseconds: 2500), () {
        if (!_still(1, 2)) return;
        setState(() {
          _scene.step = 3;
          _tray.add(_Item.frog);
        });
      });
    });
  }

  /// HTML `s2ActionDropFrog()`: the frog jumps into the pond, its lungs
  /// deflate; 1.5 s later dissolved O₂ flows to its skin, and after 3.5 s
  /// more the 'View Summary' button shows.
  void _dropFrog({Offset? from}) {
    if (_scenario != 1 || _step != 3 || _scene.jumpStart >= 0) return;
    _Audio.play(_Sound.pop);
    setState(() {
      _tray.remove(_Item.frog);
      _scene
        ..deflateFrom = _scene.lungScale
        ..frogFrom = from ?? _frogLand
        ..jumpStart = _scene.time
        ..frogInWater = true;
    });
    _lab.after(const Duration(milliseconds: 560), () {
      if (!_still(1, 3)) return;
      _Audio.play(_Sound.splash);
      _scene
        ..splashStart = _scene.time
        ..splashAt = Offset(_frogPond.dx, _pondY);
    });
    _lab.after(const Duration(milliseconds: 1500), () {
      if (!_still(1, 3)) return;
      setState(() {
        _scene
          ..waterO2Start = _scene.time
          ..step = 4;
      });
      _lab.after(const Duration(milliseconds: 3500), () {
        if (!_still(1, 4)) return;
        setState(() {
          _scene.step = 5;
          _showSummary = true;
        });
      });
    });
  }

  /// HTML `s1ActionSummary()` / `s2ActionSummary()` +
  /// `triggerConclusionState()`: confetti, then the summary popup.
  void _viewSummary() {
    if (!_showSummary) return;
    _Audio.play(_Sound.pop);
    final n = _scenario + 1;
    setState(() {
      _showSummary = false;
      _scene
        ..step += 1
        ..confettiStart = _scene.time;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: _scenario,
      totalScenarios: 2,
      title: () => _t('success'),
      heading: () => _t('observation_title'),
      body: () => '${_t('sum_title_$n')} ${_t('sum_text_$n')}',
      extra: () => _conclusionExtra(n),
      delay: const Duration(milliseconds: 1000),
    );
  }

  // ------------------------------------------------------- drag & drop

  bool _onFish(Offset p) {
    if (_scenario != 0) return false;
    if (_scene.fishStart < 0) return (p - _bagCenter).distance < 90;
    if (_scene.zoomStart >= 0) return false;
    final c = _scene.fishPose.pos;
    return (p.dx - c.dx).abs() < 130 && (p.dy - c.dy).abs() < 70;
  }

  bool _onFrog(Offset p) {
    if (_scenario != 1 || _scene.jumpStart >= 0) return false;
    final d = p - (_scene.frogPose.pos + const Offset(0, 0.05 * _frogLen));
    return (d.dx * d.dx) / (110 * 110) + (d.dy * d.dy) / (85 * 85) < 1;
  }

  bool _canGrab(Offset p) => _lab.isLabActive && !_boardOpen && (_onFish(p) || _onFrog(p));

  /// HTML `startUiDrag()` guards, for the 3D animal dragged in the scene.
  void _grab(Offset p) {
    final item = _onFish(p) ? _Item.fish : _Item.frog;
    if (item == _Item.fish && (_step != 1 || _scene.fishStart >= 0)) {
      _lab.showToast(_t('msg_fish_in'), isError: true);
      return;
    }
    if (item == _Item.frog && _step != 3) {
      _lab.showToast(_t('msg_land_first'), isError: true);
      return;
    }
    _Audio.play(_Sound.pickup);
    setState(() {
      _scene
        ..held = item
        ..dragging = item
        ..pointer = p;
    });
  }

  void _dragTo(Offset p) {
    if (_scene.held != null) _scene.pointer = p;
  }

  void _release({bool cancelled = false}) {
    final item = _scene.held;
    final p = _scene.pointer;
    if (item == null) return;
    setState(() {
      _scene
        ..held = null
        ..dragging = null
        ..pointer = null;
    });
    if (cancelled || p == null) return;
    if (item == _Item.fish) {
      if (_tankZone.contains(p)) {
        _dropFish(from: p, fromScale: _heldScale);
      } else {
        _lab.showToast(_t('msg_drop_tank'), isError: true);
      }
    } else {
      if (_pondZone.contains(p)) {
        _dropFrog(from: p);
      } else {
        _lab.showToast(_t('msg_drop_pond'), isError: true);
      }
    }
  }

  /// Drop from the tool tray (HTML `upH` drop-zone tests).
  void _onTrayDrop(_Item item, Offset global) {
    if (!mounted) return;
    setState(() => _scene.dragging = null);
    final p = labGlobalToLocal(_stageKey, global);
    switch (item) {
      case _Item.fish:
        if (_step != 1) return _lab.showToast(_t('msg_fish_in'), isError: true);
        if (p != null && _tankZone.contains(p)) return _dropFish();
        _lab.showToast(_t('msg_drop_tank'), isError: true);
      case _Item.mag:
        if (_step != 2) return _lab.showToast(_t('msg_not_needed'), isError: true);
        if (p != null && (p - _gillPoint).distance < _gillRadius) return _magnify(p);
        _lab.showToast(_t('msg_drop_gills'), isError: true);
      case _Item.frog:
        if (_step != 3) return _lab.showToast(_t('msg_land_first'), isError: true);
        if (p != null && _pondZone.contains(p)) return _dropFrog();
        _lab.showToast(_t('msg_drop_pond'), isError: true);
    }
  }

  /// Tapping a tray item does what dropping it on its target does.
  void _onTrayTap(_Item item) {
    switch (item) {
      case _Item.fish:
        _dropFish();
      case _Item.mag:
        _magnify(_gillPoint);
      case _Item.frog:
        _dropFrog();
    }
  }

  List<LabAction> _actions() {
    if (_boardOpen) {
      return [
        LabAction(
          label: _t('btn_setup'),
          icon: Icons.play_arrow_rounded,
          highlight: true,
          onTap: _startActivity,
        ),
      ];
    }
    if (_showXray) {
      return [
        LabAction(
          label: _t('btn_xray'),
          icon: Icons.document_scanner,
          color: _Colors.indigo600,
          foreground: Colors.white,
          highlight: true,
          silent: true,
          onTap: _xray,
        ),
      ];
    }
    if (_showSummary) {
      return [
        LabAction(
          label: _t('btn_summary'),
          icon: Icons.insert_chart,
          color: _Colors.sky600,
          foreground: Colors.white,
          highlight: true,
          silent: true,
          onTap: _viewSummary,
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
        final s = context.labScale;
        final data = _data;
        final inset = labOverlayInsets(context, _lab);
        final finished = _step > data.steps.length;
        final legend = (_scenario == 0 && _scene.magnified) || (_scenario == 1 && _scene.xrayOn);
        return LabShell(
          controller: _lab,
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: math.max(1, _step),
          // The HTML hides its task HUD on the setup board and once done.
          instruction: _boardOpen || finished ? '' : null,
          actions: _actions(),
          onEnterLab: () => _lab.showToast(_t('welcome_lab'), sound: false),
          onReset: _fullReset,
          overlays: [
            if (legend) _legend(p, s, inset),
            if (_tray.isNotEmpty) _toolTray(context, p, s, inset),
            if (_boardOpen) Positioned.fill(child: _setupBoard(p, s)),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _AnimalPanRecognizer: GestureRecognizerFactoryWithHandlers<_AnimalPanRecognizer>(
                  _AnimalPanRecognizer.new,
                  (r) => r
                    ..accepts = _canGrab
                    ..dragStartBehavior = DragStartBehavior.down
                    ..gestureSettings = const DeviceGestureSettings(touchSlop: 4)
                    ..onStart = ((d) => _grab(d.localPosition))
                    ..onUpdate = ((d) => _dragTo(d.localPosition))
                    ..onEnd = ((_) => _release())
                    ..onCancel = (() => _release(cancelled: true)),
                ),
              },
              child: CustomPaint(
                key: _stageKey,
                size: _design,
                painter: _RespPainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang.code,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// HTML `#ui-setup-board`: objective, description and "Setup Activity".
  Widget _setupBoard(LabPalette p, double s) {
    final n = _scenario + 1;
    final card = Container(
      padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 18 * s),
      decoration: BoxDecoration(
        color: _Colors.slate800,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Colors.sky500.withValues(alpha: 0.5), width: 3),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 84 * s,
            height: 60 * s,
            child: CustomPaint(painter: _ItemIconPainter(_scenario == 0 ? _Item.fish : _Item.frog)),
          ),
          SizedBox(height: 10 * s),
          Text(
            _data.objective,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 15 * s, fontWeight: FontWeight.w800, height: 1.35),
          ),
          SizedBox(height: 8 * s),
          Text(
            _t('board_desc_$n'),
            textAlign: TextAlign.center,
            style: TextStyle(color: _Colors.sky200, fontSize: 12.5 * s, fontWeight: FontWeight.w500, height: 1.45),
          ),
          SizedBox(height: 16 * s),
          LabActionButton(
            action: LabAction(
              label: _t('btn_setup'),
              icon: Icons.play_arrow_rounded,
              color: _Colors.sky600,
              foreground: Colors.white,
              onTap: _startActivity,
            ),
            scale: s,
            expand: false,
          ),
        ],
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: _lab.isDark ? const Color(0xB3000000) : const Color(0x990F172A),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = math.max(220.0, math.min(440 * s, box.maxWidth - 92));
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 68, 12),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(width: w, child: card),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// HTML `#s1-tools` / `#s2-tools`: drag an item onto the scene (or tap it).
  Widget _toolTray(BuildContext context, LabPalette p, double s, EdgeInsets inset) {
    return Positioned(
      top: inset.top + 4 * s,
      right: inset.right + 4,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: LabGlassCard(
          palette: p,
          padding: EdgeInsets.all(8 * s),
          radius: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('tools').toUpperCase(),
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 9 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              for (final item in _Item.values)
                if (_tray.contains(item))
                  Padding(padding: EdgeInsets.only(top: 6 * s), child: _trayItem(item, p, s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trayItem(_Item item, LabPalette p, double s) {
    final color = switch (item) {
      _Item.fish => _Colors.orange500,
      _Item.mag => _Colors.sky500,
      _Item.frog => _Colors.green500,
    };
    final label = _t(switch (item) {
      _Item.fish => 'lbl_fish',
      _Item.mag => 'lbl_mag',
      _Item.frog => 'lbl_frog',
    });
    final fill = Color.alphaBlend(color.withValues(alpha: 0.12), p.isDark ? _Colors.slate800 : Colors.white);

    Widget tile() => ValueListenableBuilder<double>(
          valueListenable: _frame,
          builder: (context, time, child) {
            final glow = 0.5 + 0.5 * math.sin(time * 4);
            return Container(
              width: 56 * s,
              height: 56 * s,
              padding: EdgeInsets.all(6 * s),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(14 * s),
                border: Border.all(color: color.withValues(alpha: 0.45 + 0.45 * glow), width: 2),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35 * glow), blurRadius: 12)],
              ),
              child: child,
            );
          },
          child: CustomPaint(painter: _ItemIconPainter(item)),
        );

    Widget body() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(),
            SizedBox(height: 4 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
              decoration: BoxDecoration(
                color: p.isDark ? const Color(0xCC1E293B) : const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: p.isDark ? _Colors.slate300 : _Colors.slate600,
                  fontSize: 9 * s,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        );

    // HTML `.dragging-clone`: scale(1.1), opacity 0.9, big shadow.
    final feedback = FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: Opacity(
        opacity: 0.9,
        child: Container(
          width: 70 * s,
          height: 70 * s,
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: color, width: 2),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12))],
          ),
          child: CustomPaint(painter: _ItemIconPainter(item)),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey('tray-${item.name}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(36 * (1 - v), 0), child: child),
      ),
      child: Draggable<_Item>(
        data: item,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: feedback,
        childWhenDragging: Opacity(opacity: 0.35, child: body()),
        onDragStarted: () {
          _Audio.play(_Sound.pickup);
          setState(() => _scene.dragging = item);
        },
        onDragEnd: (d) => _onTrayDrop(item, d.offset),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: GestureDetector(onTap: () => _onTrayTap(item), child: body()),
        ),
      ),
    );
  }

  /// Colour key for the blood and oxygen particles (gill view / X-ray).
  Widget _legend(LabPalette p, double s, EdgeInsets inset) {
    final f = s * _lab.fontScale.clamp(0.9, 1.3);
    final title = _scenario == 0
        ? _t('mode_gills')
        : (_scene.frogInWater ? _t('mode_water') : _t('mode_land'));
    Widget row(Color c, String text) => Padding(
          padding: EdgeInsets.only(top: 5 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11 * s,
                height: 11 * s,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                  boxShadow: [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 6)],
                ),
              ),
              SizedBox(width: 6 * s),
              Flexible(
                child: _chemWidget(
                  text,
                  TextStyle(color: p.text, fontSize: 10.5 * f, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
    return Positioned(
      top: inset.top,
      left: inset.left,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200 * s),
        child: LabGlassCard(
          palette: p,
          padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, 8 * s),
          radius: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 9.5 * f,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              row(_Colors.bloodDeoxy, _t('leg_deoxy')),
              row(_Colors.bloodOxy, _t('leg_oxy')),
              row(_Colors.sky400, _scenario == 1 && !_scene.frogInWater ? _t('leg_air') : _t('leg_o2')),
            ],
          ),
        ),
      ),
    );
  }

  /// "Scenario N Complete!" and, while a scenario is left, the HTML
  /// `#next-sc-msg` hint.
  Widget _conclusionExtra(int n) {
    final p = _lab.palette;
    final s = context.labScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labFormat(_t('sc_complete'), {'n': n}),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.isDark ? _Colors.sky400 : _Colors.sky600,
            fontSize: 17 * s,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (_lab.completedScenarios.length < 2) ...[
          SizedBox(height: 8 * s),
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: _Colors.sky500.withValues(alpha: p.isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _Colors.sky500.withValues(alpha: 0.35)),
            ),
            child: Text(
              _t('next_sc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.isDark ? Colors.white : _Colors.sky900,
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================ PAINTING

/// Deterministic pseudo-random value in [0, 1) for particle [i], channel [k].
double _hash(int i, int k) {
  final v = math.sin(i * 12.9898 + k * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

Offset _quad(Offset a, Offset c, Offset b, double t) {
  final u = 1 - t;
  return a * (u * u) + c * (2 * u * t) + b * (t * t);
}

/// [labText] that draws the subscript in "O₂" itself (a smaller, lowered
/// "2"), so the label looks right even in fonts without the ₂ glyph.
Rect _chemText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 18,
  Color color = Colors.white,
  FontWeight weight = FontWeight.w700,
  Color? background,
  Color? border,
  double radius = 999,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
}) {
  if (!text.contains('₂')) {
    return labText(
      canvas,
      text,
      at,
      size: size,
      color: color,
      weight: weight,
      background: background,
      border: border,
      borderWidth: 1,
      radius: radius,
      padding: padding,
    );
  }
  TextPainter piece(String s, double fs) => TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontSize: fs,
            color: color,
            fontWeight: weight,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
  final parts = text.split('₂');
  final pieces = <(TextPainter, bool)>[];
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isNotEmpty) pieces.add((piece(parts[i], size), false));
    if (i < parts.length - 1) pieces.add((piece('2', size * 0.68), true));
  }
  final lineH = size * 1.2;
  final w = pieces.fold(0.0, (sum, p) => sum + p.$1.width);
  final pad = background != null || border != null ? padding : EdgeInsets.zero;
  final box = Rect.fromCenter(center: at, width: w + pad.horizontal, height: lineH + pad.vertical);
  final rr = RRect.fromRectAndRadius(box, Radius.circular(math.min(radius, box.height / 2)));
  if (background != null) {
    canvas.drawRRect(
      rr.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(rr, Paint()..color = background);
  }
  if (border != null) {
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = border,
    );
  }
  var x = box.left + pad.left;
  final top = box.top + pad.top;
  for (final (p, sub) in pieces) {
    p.paint(canvas, Offset(x, sub ? top + lineH - p.height * 0.78 : top));
    x += p.width;
  }
  return box;
}

/// Scene label chip (the HTML-style dark pill), subscript-safe.
Rect _pill(Canvas canvas, String text, Offset at, {double size = 18}) => _chemText(
      canvas,
      text,
      at,
      size: size,
      background: const Color(0xE61E293B),
      border: const Color(0xFF475569),
    );

/// Text widget whose "₂" is drawn as a smaller, lowered "2".
Widget _chemWidget(String text, TextStyle style) {
  if (!text.contains('₂')) return Text(text, style: style);
  final parts = text.split('₂');
  final size = style.fontSize ?? 14;
  return Text.rich(
    TextSpan(
      style: style,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          TextSpan(text: parts[i]),
          if (i < parts.length - 1)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Transform.translate(
                offset: Offset(0, size * 0.3),
                child: Text('2', style: style.copyWith(fontSize: size * 0.7)),
              ),
            ),
        ],
      ],
    ),
  );
}

/// Fish body outline in fish units (length 1, facing right, centred).
final Path _fishBody = Path()
  ..moveTo(0.50, 0.01)
  ..cubicTo(0.44, -0.12, 0.25, -0.20, 0.06, -0.195)
  ..cubicTo(-0.10, -0.19, -0.22, -0.10, -0.31, -0.055)
  ..lineTo(-0.31, 0.055)
  ..cubicTo(-0.20, 0.11, -0.06, 0.185, 0.10, 0.18)
  ..cubicTo(0.28, 0.175, 0.44, 0.10, 0.50, 0.01)
  ..close();

/// Frog body + head outline in frog units (length 1, facing right; the
/// feet rest on y = 0.40).
final Path _frogBody = Path()
  ..moveTo(0.56, -0.05)
  ..cubicTo(0.54, -0.13, 0.46, -0.19, 0.36, -0.21)
  ..cubicTo(0.22, -0.23, 0.10, -0.17, -0.02, -0.19)
  ..cubicTo(-0.12, -0.21, -0.20, -0.22, -0.28, -0.16)
  ..cubicTo(-0.38, -0.10, -0.46, 0.0, -0.44, 0.10)
  ..cubicTo(-0.42, 0.20, -0.32, 0.27, -0.18, 0.27)
  ..cubicTo(0.0, 0.27, 0.16, 0.24, 0.28, 0.15)
  ..cubicTo(0.38, 0.08, 0.48, 0.03, 0.56, -0.05)
  ..close();

/// One curved vessel of the frog's skin capillary web (frog units).
class _NetEdge {
  const _NetEdge(this.a, this.ctrl, this.b);
  final Offset a;
  final Offset ctrl;
  final Offset b;
}

/// The HTML wireframe capillary mesh, as a fixed random web under the skin.
final List<_NetEdge> _frogNet = _buildFrogNet();

List<_NetEdge> _buildFrogNet() {
  final rnd = math.Random(11);
  final pts = <Offset>[];
  var guard = 0;
  while (pts.length < 46 && guard++ < 5000) {
    final p = Offset(-0.46 + rnd.nextDouble() * 1.0, -0.24 + rnd.nextDouble() * 0.52);
    if (!_frogBody.contains(p)) continue;
    if (pts.any((q) => (q - p).distance < 0.072)) continue;
    pts.add(p);
  }
  final edges = <_NetEdge>[];
  final seen = <int>{};
  for (var i = 0; i < pts.length; i++) {
    final order = List<int>.generate(pts.length, (j) => j)
      ..sort((x, y) => (pts[x] - pts[i]).distance.compareTo((pts[y] - pts[i]).distance));
    for (final j in order.skip(1).take(3)) {
      if (!seen.add(math.min(i, j) * 1000 + math.max(i, j))) continue;
      final a = pts[i];
      final b = pts[j];
      final d = b - a;
      edges.add(_NetEdge(a, (a + b) / 2 + Offset(-d.dy, d.dx) * ((rnd.nextDouble() - 0.5) * 0.6), b));
    }
  }
  return edges;
}

/// Tapered limb (capsule) from [a] to [b] with end radii [ra] and [rb].
Path _limbPath(Offset a, Offset b, double ra, double rb) {
  final d = b - a;
  final len = d.distance;
  final ends = Path()
    ..addOval(Rect.fromCircle(center: a, radius: ra))
    ..addOval(Rect.fromCircle(center: b, radius: rb));
  if (len < 1e-6) return ends;
  final n = Offset(-d.dy, d.dx) / len;
  final quad = Path()
    ..moveTo(a.dx + n.dx * ra, a.dy + n.dy * ra)
    ..lineTo(b.dx + n.dx * rb, b.dy + n.dy * rb)
    ..lineTo(b.dx - n.dx * rb, b.dy - n.dy * rb)
    ..lineTo(a.dx - n.dx * ra, a.dy - n.dy * ra)
    ..close();
  return Path.combine(PathOperation.union, quad, ends);
}

/// Side view of the HTML fish (orange body, white belly, forked tail,
/// operculum, eye) facing right, [len] px long, centred on [c].
void _paintFish(Canvas canvas, Offset c, double len, {double tail = 0, double opacity = 1}) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(len);
  if (opacity < 1) {
    canvas.saveLayer(const Rect.fromLTRB(-0.7, -0.5, 0.7, 0.5), Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
  }
  const body = _Colors.fishBody;
  final fin = Paint()
    ..shader = LinearGradient(
      colors: [labShade(body, -0.15).withValues(alpha: 0.9), labShade(body, 0.15).withValues(alpha: 0.95)],
    ).createShader(const Rect.fromLTRB(-0.5, -0.3, 0.2, 0.3));
  final ray = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.004
    ..color = labShade(body, -0.4).withValues(alpha: 0.45);

  // Caudal (tail) fin, swishing.
  final sw = tail;
  final tip = -0.50 + 0.025 * sw.abs();
  final tailPath = Path()
    ..moveTo(-0.27, -0.05)
    ..quadraticBezierTo(-0.38, -0.10 + sw * 0.02, tip, -0.21 + sw * 0.045)
    ..quadraticBezierTo(-0.45, -0.03 + sw * 0.02, -0.41 + 0.015 * sw, sw * 0.03)
    ..quadraticBezierTo(-0.45, 0.03 + sw * 0.02, tip, 0.21 + sw * 0.045)
    ..quadraticBezierTo(-0.38, 0.10 + sw * 0.02, -0.27, 0.05)
    ..close();
  canvas.drawPath(tailPath, fin);
  for (var k = -3; k <= 3; k++) {
    canvas.drawLine(Offset(-0.29, k * 0.012), Offset(tip + 0.03, k * 0.055 + sw * 0.03), ray);
  }

  // Dorsal, anal and pelvic fins (behind the body).
  final dorsal = Path()
    ..moveTo(0.08, -0.18)
    ..quadraticBezierTo(-0.01, -0.34, -0.15, -0.31)
    ..quadraticBezierTo(-0.13, -0.22, -0.21, -0.13)
    ..close();
  final anal = Path()
    ..moveTo(-0.13, 0.13)
    ..quadraticBezierTo(-0.20, 0.23, -0.27, 0.20)
    ..quadraticBezierTo(-0.25, 0.12, -0.23, 0.07)
    ..close();
  final pelvic = Path()
    ..moveTo(0.06, 0.17)
    ..quadraticBezierTo(0.0, 0.28, -0.08, 0.27)
    ..quadraticBezierTo(-0.04, 0.20, -0.03, 0.17)
    ..close();
  for (final f in [dorsal, anal, pelvic]) {
    canvas.drawPath(f, fin);
  }
  for (var k = 0; k < 5; k++) {
    final u = k / 4;
    canvas.drawLine(Offset(0.06 - 0.25 * u, -0.17 + 0.03 * u), Offset(-0.01 - 0.13 * u, -0.32 + 0.12 * u), ray);
  }

  // Body with shading.
  canvas.drawPath(
    _fishBody,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [labShade(body, -0.3), body, labShade(body, 0.2)],
        stops: const [0, 0.45, 1],
      ).createShader(const Rect.fromLTRB(-0.31, -0.2, 0.5, 0.19)),
  );
  canvas.save();
  canvas.clipPath(_fishBody);
  // White belly.
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(0.05, 0.17), width: 0.9, height: 0.2),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00F8FAFC), Color(0xF2F8FAFC)],
        stops: [0, 0.5],
      ).createShader(const Rect.fromLTRB(-0.4, 0.07, 0.5, 0.27)),
  );
  // Scales.
  final scale = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.0035
    ..color = labShade(body, -0.35).withValues(alpha: 0.32);
  for (var row = 0; row < 7; row++) {
    for (var col = 0; col < 12; col++) {
      final x = -0.27 + col * 0.042 + (row.isOdd ? 0.021 : 0);
      final y = -0.15 + row * 0.042;
      canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 0.024), -math.pi / 2, math.pi, false, scale);
    }
  }
  // Glossy highlight along the back.
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(0.06, -0.12), width: 0.46, height: 0.05),
    Paint()..color = Colors.white.withValues(alpha: 0.22),
  );
  canvas.restore();

  // Lateral line.
  canvas.drawPath(
    Path()
      ..moveTo(0.21, -0.04)
      ..quadraticBezierTo(0.0, -0.06, -0.28, 0.0),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.004
      ..color = labShade(body, -0.45).withValues(alpha: 0.4),
  );

  // Gill opening: red gills peeping out behind the gill cover (operculum).
  final slit = Path()
    ..moveTo(0.265, -0.15)
    ..cubicTo(0.18, -0.08, 0.17, 0.07, 0.255, 0.15)
    ..cubicTo(0.195, 0.07, 0.205, -0.08, 0.265, -0.15)
    ..close();
  canvas.drawPath(slit, Paint()..color = const Color(0xFFB91C1C));
  final cover = Path()
    ..moveTo(0.275, -0.155)
    ..cubicTo(0.20, -0.08, 0.19, 0.07, 0.265, 0.155)
    ..cubicTo(0.235, 0.07, 0.235, -0.08, 0.275, -0.155)
    ..close();
  canvas.drawPath(cover, Paint()..color = _Colors.fishGill);
  canvas.drawPath(
    Path()
      ..moveTo(0.275, -0.155)
      ..cubicTo(0.20, -0.08, 0.19, 0.07, 0.265, 0.155),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.006
      ..color = labShade(_Colors.fishGill, -0.35),
  );

  // Pectoral fin.
  final pect = Path()
    ..moveTo(0.17, 0.04)
    ..quadraticBezierTo(0.05, 0.06, 0.02, 0.14)
    ..quadraticBezierTo(0.10, 0.12, 0.18, 0.08)
    ..close();
  canvas.drawPath(pect, Paint()..color = labShade(body, 0.25).withValues(alpha: 0.9));
  for (var k = 0; k < 4; k++) {
    canvas.drawLine(Offset(0.17, 0.05 + k * 0.008), Offset(0.04 + k * 0.02, 0.135 - k * 0.012), ray);
  }

  // Eye and mouth.
  canvas.drawCircle(const Offset(0.375, -0.06), 0.044, Paint()..color = const Color(0xFFF8FAFC));
  canvas.drawCircle(const Offset(0.385, -0.058), 0.027, Paint()..color = _Colors.slate900);
  canvas.drawCircle(const Offset(0.376, -0.068), 0.009, Paint()..color = Colors.white);
  canvas.drawPath(
    Path()
      ..moveTo(0.505, 0.0)
      ..quadraticBezierTo(0.48, 0.025, 0.452, 0.016),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.007
      ..strokeCap = StrokeCap.round
      ..color = labShade(body, -0.55),
  );

  // Outline.
  canvas.drawPath(
    _fishBody,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0045
      ..color = labShade(body, -0.5).withValues(alpha: 0.55),
  );
  if (opacity < 1) canvas.restore();
  canvas.restore();
}

/// How the frog looks this frame (X-ray, breathing, pose).
class _FrogLook {
  const _FrogLook({
    this.xray = 0,
    this.capOpacity = 0,
    this.capColor = _Colors.bloodDeoxy,
    this.lungScale = 1,
    this.lungColor = _Colors.bloodDeoxy,
    this.throat = -1,
    this.legs = 0,
  });

  /// 0 = green skin, 1 = translucent mint skin with organs visible.
  final double xray;
  final double capOpacity;
  final Color capColor;
  final double lungScale;
  final Color lungColor;

  /// Vocal / throat sac: -1 relaxed .. 1 puffed.
  final double throat;

  /// Hind legs: 0 folded (sitting) .. 1 stretched (jumping / swimming).
  final double legs;
}

/// Side (three-quarter) view of the HTML frog facing right, [L] px long,
/// centred on [c]: bulging yellow eyes, folded hind legs with webbed feet,
/// throat sac, and the X-ray organs (lungs, windpipe, skin capillaries).
void _paintFrog(Canvas canvas, Offset c, double L, _FrogLook look) {
  final x = look.xray.clamp(0.0, 1.0);
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(L);

  final k = look.legs.clamp(0.0, 1.0);
  Offset mix(Offset a, Offset b) => Offset.lerp(a, b, k)!;
  const hip = Offset(-0.30, 0.10);
  final knee = mix(const Offset(0.04, 0.21), const Offset(-0.60, 0.16));
  final heel = mix(const Offset(-0.36, 0.33), const Offset(-0.86, 0.22));
  final toe = mix(const Offset(0.02, 0.385), const Offset(-1.06, 0.26));
  const shoulder = Offset(0.22, 0.12);
  final elbow = mix(const Offset(0.25, 0.26), const Offset(0.38, 0.22));
  final hand = mix(const Offset(0.31, 0.385), const Offset(0.55, 0.28));

  final skin = Color.lerp(_Colors.frogSkin, _Colors.frogXray, x)!;
  final dark = Color.lerp(_Colors.green700, _Colors.frogXray, x)!;
  final belly = Color.lerp(const Color(0xFFECFCCB), _Colors.frogXray, x)!;
  final ink = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.009
    ..strokeJoin = StrokeJoin.round
    ..color = labShade(_Colors.green700, -0.45).withValues(alpha: 1 - x);

  final thigh = _limbPath(hip, knee, 0.11, 0.07);
  final shin = _limbPath(knee, heel, 0.064, 0.04);
  final foot = _limbPath(heel, toe, 0.036, 0.02);
  final arm = Path.combine(
    PathOperation.union,
    _limbPath(shoulder, elbow, 0.048, 0.036),
    _limbPath(elbow, hand, 0.034, 0.022),
  );

  // Far eye peeking over the head (eye meshes stay opaque in the X-ray).
  _frogEye(canvas, const Offset(0.375, -0.25), 0.064, far: true);

  canvas.saveLayer(const Rect.fromLTRB(-1.3, -0.5, 0.8, 0.6), Paint()..color = Color.fromRGBO(0, 0, 0, 1 - 0.7 * x));
  // Far-side legs, darker and slightly behind.
  final farPaint = Paint()..color = labShade(skin, -0.32);
  canvas.save();
  canvas.translate(0.07, -0.03);
  _webbedFoot(canvas, heel, toe, labShade(skin, -0.32), labShade(skin, -0.18));
  for (final part in [foot, shin, thigh, arm]) {
    canvas.drawPath(part, farPaint);
    canvas.drawPath(part, ink);
  }
  canvas.restore();

  // Body.
  canvas.drawPath(
    _frogBody,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [dark, skin, labShade(skin, 0.12)],
        stops: const [0, 0.45, 1],
      ).createShader(const Rect.fromLTRB(-0.5, -0.26, 0.55, 0.28)),
  );
  canvas.save();
  canvas.clipPath(_frogBody);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(0.0, 0.26), width: 0.9, height: 0.2),
    Paint()..color = belly.withValues(alpha: 0.95),
  );
  if (x < 1) {
    final spot = Paint()..color = labShade(_Colors.green700, -0.3).withValues(alpha: 0.8 * (1 - x));
    for (final (cx, cy, rx, ry) in const [
      (-0.20, -0.10, 0.060, 0.034),
      (-0.02, -0.13, 0.050, 0.030),
      (0.08, -0.04, 0.040, 0.026),
      (-0.34, -0.01, 0.048, 0.030),
      (-0.13, 0.02, 0.044, 0.028),
      (0.23, -0.15, 0.030, 0.018),
    ]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), spot);
    }
    // Pale dorsolateral fold from the eye to the hip.
    canvas.drawPath(
      Path()
        ..moveTo(0.22, -0.17)
        ..quadraticBezierTo(-0.10, -0.15, -0.38, -0.05),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.014
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFBBF7D0).withValues(alpha: 0.55 * (1 - x)),
    );
  }
  canvas.restore();
  canvas.drawPath(_frogBody, ink);

  // Throat sac (puffs while breathing air).
  final th = (look.throat + 1) / 2;
  final sac = Rect.fromCenter(
    center: Offset(0.37, 0.085 + 0.025 * th),
    width: 0.14 + 0.08 * th,
    height: 0.07 + 0.08 * th,
  );
  canvas.drawOval(sac, Paint()..color = Color.lerp(const Color(0xFFF7FEE7), _Colors.frogXray, x)!);
  canvas.drawOval(sac, ink);

  // Near hind leg: long webbed foot on the ground, shin folded under the
  // big thigh.
  final legShade = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [dark, skin, labShade(skin, 0.1)],
    ).createShader(const Rect.fromLTRB(-1.1, 0, 0.2, 0.42));
  _webbedFoot(canvas, heel, toe, dark, labShade(skin, 0.15));
  for (final part in [foot, shin, thigh]) {
    canvas.drawPath(part, legShade);
    canvas.drawPath(part, ink);
  }
  if (x < 1) {
    canvas.save();
    canvas.clipPath(thigh);
    final band = Paint()
      ..strokeWidth = 0.03
      ..strokeCap = StrokeCap.round
      ..color = labShade(_Colors.green700, -0.35).withValues(alpha: 0.6 * (1 - x));
    final d = knee - hip;
    final n = Offset(-d.dy, d.dx) / d.distance;
    for (final u in const [0.3, 0.55, 0.8]) {
      final m = hip + d * u;
      canvas.drawLine(m - n * 0.13, m + n * 0.13, band);
    }
    canvas.restore();
  }
  // Near front leg.
  _fingers(canvas, hand, hand - elbow, dark);
  canvas.drawPath(arm, legShade);
  canvas.drawPath(arm, ink);

  // Head details: ear drum, mouth line, nostril.
  canvas.drawCircle(const Offset(0.15, -0.09), 0.05, Paint()..color = labShade(skin, -0.15));
  canvas.drawCircle(const Offset(0.15, -0.09), 0.05, ink);
  canvas.drawPath(
    Path()
      ..moveTo(0.555, -0.045)
      ..cubicTo(0.47, -0.015, 0.36, -0.005, 0.22, -0.045),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.012
      ..strokeCap = StrokeCap.round
      ..color = labShade(dark, -0.5),
  );
  canvas.drawCircle(const Offset(0.50, -0.125), 0.014, Paint()..color = labShade(dark, -0.55));
  canvas.restore(); // skin layer

  if (x > 0) {
    // X-ray: glowing outline, capillary web under the skin, lungs.
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.009
      ..color = Colors.white.withValues(alpha: 0.7 * x);
    for (final part in [foot, shin, thigh, arm]) {
      canvas.drawPath(part, outline..color = Colors.white.withValues(alpha: 0.45 * x));
    }
    canvas.drawPath(_frogBody, outline..color = Colors.white.withValues(alpha: 0.8 * x));
    if (look.capOpacity > 0) {
      canvas.save();
      canvas.clipPath(_frogBody);
      final vessel = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.01
        ..strokeCap = StrokeCap.round
        ..color = look.capColor.withValues(alpha: (look.capOpacity * 1.4).clamp(0.0, 1.0));
      for (final e in _frogNet) {
        canvas.drawPath(
          Path()
            ..moveTo(e.a.dx, e.a.dy)
            ..quadraticBezierTo(e.ctrl.dx, e.ctrl.dy, e.b.dx, e.b.dy),
          vessel,
        );
      }
      // Cutaneous artery and vein along the flank.
      final big = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.016
        ..strokeCap = StrokeCap.round
        ..color = look.capColor.withValues(alpha: (look.capOpacity * 1.3).clamp(0.0, 1.0));
      canvas.drawPath(
        Path()
          ..moveTo(0.22, -0.02)
          ..cubicTo(0.05, -0.10, -0.20, -0.10, -0.42, 0.04),
        big,
      );
      canvas.drawPath(
        Path()
          ..moveTo(0.20, 0.10)
          ..cubicTo(0.0, 0.18, -0.25, 0.18, -0.42, 0.12),
        big,
      );
      canvas.restore();
    }
    _frogLungs(canvas, look.lungScale, look.lungColor, x);
  }

  // Near eye on top.
  _frogEye(canvas, const Offset(0.31, -0.225), 0.085);
  canvas.restore();
}

void _frogEye(Canvas canvas, Offset c, double r, {bool far = false}) {
  final socket = c + Offset(0, r * 0.22);
  canvas.drawCircle(socket, r * 1.22, Paint()..color = far ? _Colors.green700 : _Colors.green600);
  canvas.drawCircle(
    socket,
    r * 1.22,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.009
      ..color = labShade(_Colors.green700, -0.45),
  );
  labSphere(canvas, c, r, far ? labShade(_Colors.frogEye, -0.15) : _Colors.frogEye, highlight: 0.55, shade: 0.4);
  canvas.drawOval(
    Rect.fromCenter(center: c + Offset(r * 0.12, r * 0.06), width: r * 1.15, height: r * 0.55),
    Paint()..color = const Color(0xFF0B0B0B),
  );
  canvas.drawCircle(c + Offset(-r * 0.3, -r * 0.35), r * 0.2, Paint()..color = Colors.white.withValues(alpha: 0.9));
}

void _webbedFoot(Canvas canvas, Offset heel, Offset toe, Color color, Color web) {
  final d = toe - heel;
  final len = d.distance;
  if (len < 1e-6) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  final tips = [for (final s in const [-1.2, -0.45, 0.3, 0.95]) toe + u * 0.1 + n * (s * 0.036)];
  final webPath = Path()..moveTo(toe.dx - u.dx * 0.03, toe.dy - u.dy * 0.03);
  for (final tip in tips) {
    webPath.lineTo(tip.dx, tip.dy);
  }
  webPath.close();
  canvas.drawPath(webPath, Paint()..color = web.withValues(alpha: 0.85));
  final toePaint = Paint()
    ..color = color
    ..strokeWidth = 0.016
    ..strokeCap = StrokeCap.round;
  for (final tip in tips) {
    canvas.drawLine(toe, tip, toePaint);
    canvas.drawCircle(tip, 0.013, Paint()..color = color);
  }
}

void _fingers(Canvas canvas, Offset hand, Offset dir, Color color) {
  final len = dir.distance;
  if (len < 1e-6) return;
  final u = dir / len;
  final n = Offset(-u.dy, u.dx);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 0.014
    ..strokeCap = StrokeCap.round;
  for (final s in const [-0.9, -0.1, 0.7]) {
    final tip = hand + u * 0.045 + n * (s * 0.035);
    canvas.drawLine(hand, tip, paint);
    canvas.drawCircle(tip, 0.011, Paint()..color = color);
  }
}

/// The frog's simple sac-like lungs and windpipe (HTML lung meshes).
void _frogLungs(Canvas canvas, double scale, Color color, double alpha) {
  Color a(Color c) => c.withValues(alpha: alpha);
  // Windpipe from the throat to the lungs, with cartilage rings.
  final pipe = Path()
    ..moveTo(0.38, -0.03)
    ..quadraticBezierTo(0.29, -0.10, 0.19, -0.085);
  canvas.drawPath(
    pipe,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.03
      ..strokeCap = StrokeCap.round
      ..color = a(labShade(color, 0.25)),
  );
  for (final m in pipe.computeMetrics()) {
    for (var d = 0.015; d < m.length - 0.01; d += 0.022) {
      final tan = m.getTangentForOffset(d)!;
      final n = Offset(-tan.vector.dy, tan.vector.dx);
      canvas.drawLine(
        tan.position - n * 0.014,
        tan.position + n * 0.014,
        Paint()
          ..strokeWidth = 0.005
          ..color = a(labShade(color, -0.2)),
      );
    }
  }

  void lung(Offset c, double rx, double ry, double shade) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.15);
    canvas.scale(scale);
    final r = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [a(labShade(color, 0.35 + shade)), a(labShade(color, shade)), a(labShade(color, -0.4 + shade))],
          stops: const [0, 0.55, 1],
        ).createShader(r),
    );
    // Air sacs (alveoli) texture.
    final sac = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.004
      ..color = a(labShade(color, -0.45)).withValues(alpha: 0.55 * alpha);
    for (var i = 0; i < 9; i++) {
      final ang = i * 0.7;
      final rr = 0.45 + 0.35 * _hash(i, 61);
      canvas.drawCircle(Offset(math.cos(ang) * rx * rr, math.sin(ang) * ry * rr), ry * 0.28, sac);
    }
    canvas.drawOval(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.006
        ..color = a(labShade(color, -0.55)),
    );
    canvas.restore();
  }

  lung(const Offset(0.12, -0.1), 0.15, 0.07, -0.15);
  lung(const Offset(0.05, -0.055), 0.175, 0.085, 0);
}

/// Magnifying glass (the HTML 'Inspect' tool icon), [m] px wide.
void _paintMagnifier(Canvas canvas, Offset c, double m) {
  final r = m * 0.28;
  final lens = c + Offset(-m * 0.08, -m * 0.08);
  canvas.drawLine(
    lens + Offset(r * 0.72, r * 0.72),
    lens + Offset(r * 1.85, r * 1.85),
    Paint()
      ..color = _Colors.slate700
      ..strokeWidth = m * 0.13
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawCircle(lens, r, Paint()..color = _Colors.sky100.withValues(alpha: 0.35));
  canvas.drawArc(
    Rect.fromCircle(center: lens, radius: r * 0.62),
    math.pi * 1.05,
    math.pi * 0.5,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = m * 0.045
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.85),
  );
  canvas.drawCircle(
    lens,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = m * 0.085
      ..color = _Colors.sky500,
  );
}

/// Icons of the tool tray and the setup board (fish, magnifier, frog).
class _ItemIconPainter extends CustomPainter {
  const _ItemIconPainter(this.item);

  final _Item item;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final m = math.min(size.width, size.height * 1.3);
    switch (item) {
      case _Item.fish:
        _paintFish(canvas, c + Offset(0, m * 0.03), m * 0.95);
      case _Item.mag:
        _paintMagnifier(canvas, c, size.shortestSide);
      case _Item.frog:
        _paintFrog(canvas, c + Offset(-m * 0.05, -m * 0.04), m * 0.84, const _FrogLook());
    }
  }

  @override
  bool shouldRepaint(covariant _ItemIconPainter old) => old.item != item;
}

class _RespPainter extends CustomPainter {
  _RespPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _Scene scene;
  final bool isDark;
  final bool showLabels;
  final String lang;
  final String Function(String key) tr;

  double get t => scene.time;
  Color get _o2 => isDark ? _Colors.sky400 : _Colors.sky600;

  @override
  void paint(Canvas canvas, Size size) {
    if (scene.scenario == 0) {
      _paintAquariumLab(canvas, size);
    } else {
      _paintPondLab(canvas, size);
    }
    _paintConfetti(canvas);
  }

  // ------------------------------------------------- scenario 1: aquarium

  void _paintAquariumLab(Canvas canvas, Size size) {
    final fade = scene.magFade;
    if (fade < 1) {
      final z = Curves.easeInOutCubic.transform(scene.zoom);
      canvas.save();
      if (z > 0) {
        // HTML camera tween towards the gills.
        final focus = Offset.lerp(_gillPoint, const Offset(500, 300), z)!;
        canvas.translate(focus.dx, focus.dy);
        canvas.scale(1 + 3.2 * z);
        canvas.translate(-_gillPoint.dx, -_gillPoint.dy);
      }
      _paintRoom(canvas, size);
      _paintTankBack(canvas);
      _paintTankFish(canvas);
      _paintTankFront(canvas);
      _paintBag(canvas);
      _paintSplash(canvas);
      if (scene.dragging == _Item.fish) {
        _paintZone(
          canvas,
          RRect.fromRectAndRadius(_tank.inflate(12), const Radius.circular(18)),
          Offset(_tank.center.dx, _tank.top - 52),
        );
      }
      if (scene.dragging == _Item.mag) {
        _paintZone(
          canvas,
          RRect.fromRectAndRadius(Rect.fromCircle(center: _gillPoint, radius: 64), const Radius.circular(64)),
          _gillPoint + const Offset(0, 100),
        );
      }
      if (showLabels && scene.zoomStart < 0) _paintAquariumLabels(canvas);
      _paintLens(canvas);
      if (scene.held == _Item.fish && scene.pointer != null) {
        _paintFish(canvas, scene.pointer!, _fishLen * _heldScale, tail: math.sin(t * 9));
      }
      canvas.restore();
    }
    if (fade > 0) {
      canvas.saveLayer(labBleed(size), Paint()..color = Color.fromRGBO(0, 0, 0, fade));
      _paintGillView(canvas, size);
      canvas.restore();
    }
  }

  void _paintRoom(Canvas canvas, Size size) {
    final b = labBleed(size);
    canvas.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, 460),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1224), Color(0xFF14284A)]
              : const [Color(0xFFE0F2FE), Color(0xFFF1F5F9)],
        ).createShader(const Rect.fromLTRB(0, 0, 1000, 460)),
    );
    // Wall panelling.
    final panel = Paint()
      ..color = (isDark ? Colors.white : _Colors.sky700).withValues(alpha: isDark ? 0.04 : 0.06)
      ..strokeWidth = 2;
    for (var x = -400.0; x < 1500; x += 120) {
      canvas.drawLine(Offset(x, b.top), Offset(x, 460), panel);
    }
    labGlow(canvas, const Offset(470, 280), 430, isDark ? _Colors.sky500 : Colors.white, intensity: isDark ? 0.2 : 0.6);
    // Wooden table.
    canvas.drawRect(
      Rect.fromLTRB(b.left, 456, b.right, 484),
      Paint()..color = isDark ? const Color(0xFF6B4428) : const Color(0xFFC8955F),
    );
    canvas.drawRect(
      Rect.fromLTRB(b.left, 484, b.right, b.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF4A2E19), Color(0xFF24160C)]
              : const [Color(0xFFA9703F), Color(0xFF7C4E2A)],
        ).createShader(const Rect.fromLTRB(0, 484, 1000, 600)),
    );
    canvas.drawLine(
      Offset(b.left, 484),
      Offset(b.right, 484),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.3)
        ..strokeWidth = 2,
    );
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 5; i++) {
      final y = 500.0 + i * 22;
      final path = Path()..moveTo(-300, y);
      for (var x = -300.0; x <= 1300; x += 40) {
        path.lineTo(x, y + math.sin(x / 90 + i) * 3);
      }
      canvas.drawPath(path, grain);
    }
    // Stand under the tank (drawn first: the glass sits on it).
    labBox3D(
      canvas,
      Rect.fromLTRB(_tank.left - 8, _tank.bottom - 2, _tank.right + 8, _tank.bottom + 18),
      50,
      isDark ? _Colors.slate700 : _Colors.slate800,
      angle: math.atan2(_tankDepth.dy, _tankDepth.dx),
    );
  }

  void _paintTankBack(Canvas canvas) {
    const f = _tank;
    const d = _tankDepth;
    final back = f.shift(d);
    final deep = isDark ? const Color(0xFF0B4F75) : const Color(0xFF38BDF8);
    final light = isDark ? const Color(0xFF0E7490) : const Color(0xFFBAE6FD);

    // Air above the water and the back water pane.
    canvas.drawRect(
      Rect.fromLTRB(back.left, back.top, back.right, _waterTop + d.dy),
      Paint()..color = (isDark ? Colors.white : _Colors.sky500).withValues(alpha: 0.06),
    );
    canvas.drawRect(
      Rect.fromLTRB(back.left, _waterTop + d.dy, back.right, back.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light.withValues(alpha: 0.9), deep.withValues(alpha: 0.95)],
        ).createShader(back),
    );
    // Right side pane.
    final side = Path()
      ..moveTo(f.right, _waterTop)
      ..lineTo(f.right + d.dx, _waterTop + d.dy)
      ..lineTo(f.right + d.dx, f.bottom + d.dy)
      ..lineTo(f.right, f.bottom)
      ..close();
    canvas.drawPath(side, Paint()..color = labShade(deep, -0.25).withValues(alpha: 0.9));
    // Front water body below the surface.
    canvas.drawRect(
      Rect.fromLTRB(f.left, _waterTop, f.right, f.bottom),
      Paint()..color = deep.withValues(alpha: isDark ? 0.35 : 0.2),
    );
    // Sunbeams through the water.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(f.left, _waterTop, f.right, _gravelTop));
    for (var i = 0; i < 5; i++) {
      final x0 = f.left + 60 + i * 120 + math.sin(t * 0.5 + i) * 20;
      final beam = Path()
        ..moveTo(x0, _waterTop)
        ..lineTo(x0 + 40, _waterTop)
        ..lineTo(x0 - 30, _gravelTop)
        ..lineTo(x0 - 90, _gravelTop)
        ..close();
      canvas.drawPath(beam, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.04 : 0.12));
    }
    canvas.restore();
    // Water surface (top face) with ripples.
    final surf = Path()
      ..moveTo(f.left, _waterTop)
      ..lineTo(f.left + d.dx, _waterTop + d.dy)
      ..lineTo(f.right + d.dx, _waterTop + d.dy)
      ..lineTo(f.right, _waterTop)
      ..close();
    canvas.drawPath(surf, Paint()..color = (isDark ? _Colors.sky300 : _Colors.sky200).withValues(alpha: 0.45));
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.4);
    for (var i = 0; i < 4; i++) {
      final y = _waterTop - 5 - i * 6.0;
      final x0 = f.left + 30 + i * 12.0;
      final path = Path()..moveTo(x0, y);
      for (var x = x0; x <= f.right - 20; x += 10) {
        path.lineTo(x + i * 1.5, y + math.sin(x / 18 + t * 2 + i) * 1.2);
      }
      canvas.drawPath(path, ripple);
    }
    // Gravel: top face then front band, with pebbles.
    final gravelFace = Path()
      ..moveTo(f.left, _gravelTop)
      ..lineTo(f.left + d.dx, _gravelTop + d.dy)
      ..lineTo(f.right + d.dx, _gravelTop + d.dy)
      ..lineTo(f.right, _gravelTop)
      ..close();
    canvas.drawPath(gravelFace, Paint()..color = isDark ? const Color(0xFF7A6548) : const Color(0xFFD6C3A0));
    _plant(canvas, Offset(300, _gravelTop - 8), 150, 4, 0.3, dim: true);
    _plant(canvas, Offset(560, _gravelTop - 14), 120, 5, 1.7, dim: true);
    _plant(canvas, Offset(650, _gravelTop - 10), 175, 4, 2.4, dim: true);
    _rock(canvas, Offset(360, _gravelTop + 4), 72, 34);
    _rock(canvas, Offset(612, _gravelTop + 6), 56, 28);
    canvas.drawRect(
      Rect.fromLTRB(f.left, _gravelTop, f.right, f.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF6B5B45), Color(0xFF3F3428)]
              : const [Color(0xFFC9B48D), Color(0xFF9C8462)],
        ).createShader(Rect.fromLTRB(f.left, _gravelTop, f.right, f.bottom)),
    );
    const pebbles = [
      Color(0xFFD6B98C),
      Color(0xFF9A6B45),
      Color(0xFF94A3B8),
      Color(0xFFC2774E),
      Color(0xFF64748B),
      Color(0xFFE7D7B8),
    ];
    for (var i = 0; i < 110; i++) {
      final front = i < 80;
      final px = f.left + 8 + _hash(i, 3) * (f.width - 16);
      final py = front
          ? _gravelTop + 5 + _hash(i, 4) * (f.bottom - _gravelTop - 9)
          : _gravelTop + d.dy * _hash(i, 4) * 0.9;
      final pxx = front ? px : px + d.dx * (_gravelTop - py) / -d.dy;
      final r = 3.0 + _hash(i, 5) * 4;
      final col = pebbles[(i * 7) % pebbles.length];
      canvas.drawOval(
        Rect.fromCenter(center: Offset(pxx, py), width: r * 2.2, height: r * 1.6),
        Paint()..color = isDark ? labShade(col, -0.35) : col,
      );
      canvas.drawCircle(
        Offset(pxx - r * 0.4, py - r * 0.35),
        r * 0.35,
        Paint()..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.35),
      );
    }
    // Air stone and its bubble stream.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(706, _gravelTop - 4), width: 26, height: 12), const Radius.circular(5)),
      Paint()..color = isDark ? _Colors.slate500 : _Colors.slate400,
    );
    final bubble = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: 0.75);
    for (var i = 0; i < 14; i++) {
      final travel = _gravelTop - 12 - _waterTop;
      final y = _gravelTop - 12 - ((t * 85 + i * travel / 14) % travel);
      final x = 706 + math.sin(t * 3 + i) * 6;
      final r = 2.5 + (i % 3) * 1.5;
      canvas.drawCircle(Offset(x, y), r, bubble);
      canvas.drawCircle(Offset(x - r * 0.35, y - r * 0.35), r * 0.3, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  void _plant(Canvas canvas, Offset root, double height, int blades, double phase, {bool dim = false}) {
    for (var j = 0; j < blades; j++) {
      final spread = (j - (blades - 1) / 2) * 16.0;
      final h = height * (0.65 + 0.35 * _hash(j + (phase * 10).round(), 9));
      final sway = math.sin(t * 1.4 + phase + j) * 10 * (h / 150);
      final col = [_Colors.green600, _Colors.green500, _Colors.green700][j % 3];
      final c = dim ? labShade(col, isDark ? -0.35 : -0.15) : col;
      final path = Path()
        ..moveTo(root.dx + spread * 0.2, root.dy)
        ..quadraticBezierTo(root.dx + spread * 0.5 + sway * 0.4, root.dy - h * 0.55, root.dx + spread + sway, root.dy - h);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = labShade(c, -0.2),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = labShade(c, 0.15),
      );
    }
  }

  void _rock(Canvas canvas, Offset c, double w, double h) {
    final r = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawOval(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.5),
          colors: isDark
              ? const [Color(0xFF64748B), Color(0xFF334155), Color(0xFF1E293B)]
              : const [Color(0xFFCBD5E1), Color(0xFF94A3B8), Color(0xFF64748B)],
          stops: const [0, 0.6, 1],
        ).createShader(r),
    );
  }

  void _paintTankFish(Canvas canvas) {
    if (scene.fishStart < 0) return;
    final pose = scene.fishPose;
    final swim = scene.fishInWater && !scene.magnified ? math.sin(t * 5) : 0.0;
    final c = pose.pos + Offset(0, scene.fishInWater ? math.sin(t * 1.7) * 4 : 0);
    final len = _fishLen * pose.scale;
    _paintFish(canvas, c, len, tail: swim);
    if (scene.fishInWater && !scene.magnified) _paintWaterFlow(canvas, c, len);
  }

  /// HTML `waterParticles`: water drawn into the mouth and pushed out
  /// through the gill slit.
  void _paintWaterFlow(Canvas canvas, Offset c, double len) {
    Offset w(Offset p) => c + p * len;
    const n = 34;
    for (var i = 0; i < n; i++) {
      final ph = (t * 0.45 + i / n) % 1.0;
      final h1 = _hash(i, 1);
      final h2 = _hash(i, 2);
      final h3 = _hash(i, 3);
      Offset p;
      double a;
      if (ph < 0.5) {
        final q = ph / 0.5;
        if (q > 0.94) continue;
        final from = Offset(0.74 + 0.22 * h1, -0.02 + (h2 - 0.5) * 0.34);
        p = w(Offset.lerp(from, const Offset(0.5, 0.0), Curves.easeIn.transform(q))!);
        a = math.min(1.0, q * 3);
      } else {
        // Out through the gill opening, then back and down past the belly.
        final q = (ph - 0.5) / 0.5;
        final from = Offset(0.21, -0.02 + 0.15 * h3);
        final to = Offset(-0.06 - 0.16 * h1, 0.3 + 0.07 * h3);
        p = w(_quad(from, Offset(0.16, 0.22 + 0.04 * h2), to, Curves.easeOut.transform(q)));
        a = 1 - q;
      }
      p += Offset(0, math.sin(t * 5 + i) * 1.5);
      if (isDark) labGlow(canvas, p, 9, _o2, intensity: 0.5 * a);
      canvas.drawCircle(p, 3.4, Paint()..color = _o2.withValues(alpha: 0.95 * a));
    }
  }

  void _paintTankFront(Canvas canvas) {
    const f = _tank;
    const d = _tankDepth;
    final water = Rect.fromLTRB(f.left, _waterTop, f.right, f.bottom);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? _Colors.sky400 : _Colors.sky300).withValues(alpha: 0.1),
            (isDark ? _Colors.sky700 : _Colors.sky600).withValues(alpha: 0.2),
          ],
        ).createShader(water),
    );
    canvas.drawLine(
      Offset(f.left, _waterTop),
      Offset(f.right, _waterTop),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 2,
    );
    // Glass reflections.
    canvas.save();
    canvas.clipRect(f);
    final sheen = Path()
      ..moveTo(f.left + 70, f.top)
      ..lineTo(f.left + 150, f.top)
      ..lineTo(f.left + 40, f.bottom)
      ..lineTo(f.left - 40, f.bottom)
      ..close();
    canvas.drawPath(sheen, Paint()..color = Colors.white.withValues(alpha: 0.07));
    canvas.restore();
    canvas.drawRect(
      Rect.fromLTWH(f.left + 14, f.top + 16, 8, f.height - 32),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
    canvas.drawRect(
      Rect.fromLTWH(f.right - 26, f.top + 16, 5, f.height - 32),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    // Glass edges.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (isDark ? _Colors.sky300 : _Colors.sky700).withValues(alpha: 0.55);
    canvas.drawRect(f, edge);
    canvas.drawPath(
      Path()
        ..moveTo(f.left, f.top)
        ..lineTo(f.left + d.dx, f.top + d.dy)
        ..lineTo(f.right + d.dx, f.top + d.dy)
        ..lineTo(f.right + d.dx, f.bottom + d.dy)
        ..lineTo(f.right, f.bottom)
        ..moveTo(f.right + d.dx, f.top + d.dy)
        ..lineTo(f.right, f.top),
      edge,
    );
    // Black top frame.
    final rim = Paint()
      ..color = isDark ? _Colors.slate600 : _Colors.slate800
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(f.left + d.dx, f.top + d.dy), Offset(f.right + d.dx, f.top + d.dy), rim);
    canvas.drawLine(Offset(f.right, f.top), Offset(f.right + d.dx, f.top + d.dy), rim);
    canvas.drawLine(Offset(f.left, f.top), Offset(f.left + d.dx, f.top + d.dy), rim);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(f.left - 5, f.top - 7, f.right + 5, f.top + 5), const Radius.circular(3)),
      Paint()..color = rim.color,
    );
  }

  /// The pet-shop bag the fish waits in before going into the tank.
  void _paintBag(Canvas canvas) {
    final gone = scene.fishStart < 0 ? 0.0 : ((t - scene.fishStart) / 0.7).clamp(0.0, 1.0);
    if (gone >= 1) return;
    final o = 1 - gone;
    const c = _bagCenter;
    canvas.save();
    canvas.translate(c.dx, c.dy - 92);
    canvas.rotate(math.sin(t * 1.3) * 0.03);
    canvas.translate(-c.dx, -(c.dy - 92));
    final bag = Path()
      ..moveTo(c.dx - 7, c.dy - 80)
      ..cubicTo(c.dx - 30, c.dy - 52, c.dx - 74, c.dy - 30, c.dx - 72, c.dy + 30)
      ..cubicTo(c.dx - 70, c.dy + 78, c.dx - 30, c.dy + 92, c.dx, c.dy + 92)
      ..cubicTo(c.dx + 30, c.dy + 92, c.dx + 70, c.dy + 78, c.dx + 72, c.dy + 30)
      ..cubicTo(c.dx + 74, c.dy - 30, c.dx + 30, c.dy - 52, c.dx + 7, c.dy - 80)
      ..close();
    labGroundShadow(canvas, Offset(c.dx, c.dy + 98), 120, 14, opacity: 0.25 * o);
    canvas.save();
    canvas.clipPath(bag);
    final waterTop = c.dy - 22 + math.sin(t * 2) * 2;
    canvas.drawRect(
      Rect.fromLTRB(c.dx - 80, waterTop, c.dx + 80, c.dy + 95),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.sky300.withValues(alpha: 0.55 * o), _Colors.sky600.withValues(alpha: 0.6 * o)],
        ).createShader(Rect.fromLTRB(c.dx - 80, waterTop, c.dx + 80, c.dy + 95)),
    );
    canvas.drawLine(
      Offset(c.dx - 80, waterTop),
      Offset(c.dx + 80, waterTop),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * o)
        ..strokeWidth = 2,
    );
    if (scene.fishStart < 0 && scene.held != _Item.fish) {
      _paintFish(canvas, scene.fishPose.pos, _fishLen * _bagScale, tail: math.sin(t * 4) * 0.7);
    }
    canvas.restore();
    canvas.drawPath(bag, Paint()..color = Colors.white.withValues(alpha: 0.1 * o));
    canvas.drawPath(
      bag,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.6 * o),
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 50, c.dy - 10)
        ..quadraticBezierTo(c.dx - 62, c.dy + 30, c.dx - 44, c.dy + 66),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35 * o),
    );
    // Knot and red tie.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 84), width: 24, height: 12),
      Paint()..color = Colors.white.withValues(alpha: 0.75 * o),
    );
    final tie = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = _Colors.red500.withValues(alpha: o);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - 86)
        ..quadraticBezierTo(c.dx - 22, c.dy - 108, c.dx - 10, c.dy - 92)
        ..moveTo(c.dx, c.dy - 86)
        ..quadraticBezierTo(c.dx + 24, c.dy - 106, c.dx + 12, c.dy - 90),
      tie,
    );
    canvas.restore();
  }

  void _paintSplash(Canvas canvas) {
    if (scene.splashStart < 0) return;
    final age = t - scene.splashStart;
    if (age < 0 || age > 1.4) return;
    final c = scene.splashAt;
    for (var k = 0; k < 3; k++) {
      final a = age - k * 0.18;
      if (a <= 0) continue;
      final r = 14 + a * 110;
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2, height: r * 0.45),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: (1 - age / 1.4) * 0.8),
      );
    }
    if (age < 0.7) {
      for (var i = 0; i < 14; i++) {
        final ang = -math.pi / 2 + (_hash(i, 71) - 0.5) * 2.2;
        final v = 170 + 150 * _hash(i, 72);
        final p = c + Offset(math.cos(ang) * v * age, math.sin(ang) * v * age + 450 * age * age);
        canvas.drawCircle(
          p,
          3.5,
          Paint()..color = Color.lerp(Colors.white, _Colors.sky300, 0.4)!.withValues(alpha: 1 - age / 0.7),
        );
      }
    }
  }

  /// HTML `.target-active` drop zone: glowing dashed outline.
  void _paintZone(Canvas canvas, RRect r, Offset labelAt) {
    final pulse = 0.5 + 0.5 * math.sin(t * 6);
    canvas.drawRRect(r, Paint()..color = _Colors.sky500.withValues(alpha: 0.12 + 0.1 * pulse));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..color = _Colors.sky500.withValues(alpha: 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    labDashedPath(
      canvas,
      Path()..addRRect(r),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _Colors.sky400,
      dash: 16,
      gap: 10,
      phase: -t * 40,
    );
    labText(
      canvas,
      tr('lbl_drop_here'),
      labelAt,
      size: 19,
      weight: FontWeight.w800,
      color: Colors.white,
      background: _Colors.sky600,
      radius: 10,
    );
  }

  /// Small caption chip for flow arrows ("Water in", "Air"...).
  void _tag(Canvas canvas, String text, Offset at) => _chemText(
        canvas,
        text,
        at,
        size: 17,
        weight: FontWeight.w800,
        background: _Colors.sky700.withValues(alpha: 0.92),
        radius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );

  void _paintLens(Canvas canvas) {
    if (scene.zoomStart < 0) return;
    final age = t - scene.zoomStart;
    final o = (1 - (age - 0.6) / 0.6).clamp(0.0, 1.0);
    if (o <= 0) return;
    final move = Curves.easeOutCubic.transform((age / 0.3).clamp(0.0, 1.0));
    final c = Offset.lerp(scene.lensAt, _gillPoint, move)!;
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, o));
    _paintMagnifier(canvas, c + const Offset(12, 12), 150);
    canvas.restore();
  }

  void _leader(Canvas canvas, Offset anchor, Offset label, String text) {
    final ink = isDark ? Colors.white : _Colors.slate800;
    canvas.drawLine(
      anchor,
      label,
      Paint()
        ..color = ink.withValues(alpha: 0.75)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(anchor, 4.5, Paint()..color = ink);
    _pill(canvas, text, label);
  }

  void _paintAquariumLabels(Canvas canvas) {
    _pill(canvas, tr('lbl_aquarium'), Offset(_tank.left + 84, _tank.top - 44));
    if (scene.fishStart < 0 && scene.held == null) {
      _pill(canvas, tr('lbl_fish'), _bagCenter + const Offset(0, -124));
    }
    if (!scene.fishInWater) return;
    const c = _fishHome;
    const len = _fishLen;
    _leader(canvas, c + const Offset(0.5, 0.01) * len, c + const Offset(0.62, -0.38) * len, tr('lbl_mouth'));
    _leader(canvas, _gillPoint + const Offset(-0.03, -0.11) * len, _gillPoint + const Offset(-0.16, -0.5) * len,
        tr('lbl_gills'));
    labArrow(canvas, c + const Offset(1.1, 0.12) * len, c + const Offset(0.86, 0.12) * len, color: _o2, width: 5, head: 14);
    _tag(canvas, tr('lbl_water_in'), c + const Offset(0.98, 0.22) * len);
    labArrow(canvas, c + const Offset(0.1, 0.27) * len, c + const Offset(-0.14, 0.33) * len, color: _o2, width: 5, head: 14);
    _tag(canvas, tr('lbl_water_out'), c + const Offset(-0.34, 0.34) * len);
  }

  // ------------------------------------------- scenario 1: gill close-up

  static double _archX(double y) {
    final s = ((y - 62) / 476).clamp(0.0, 1.0);
    return 262 - 184 * s * (1 - s);
  }

  static double _filY(int i) => 300 + (i - 3.5) * 58;

  /// HTML capillary colour cycle: purple for 1 s, then turning red.
  double _gillPulse(int i) {
    final cycle = (t * 1000 + i * 500) % 2000;
    if (cycle < 150) return 1 - cycle / 150;
    if (cycle < 1000) return 0;
    return ((cycle - 1000) / 500).clamp(0.0, 1.0);
  }

  void _paintGillView(Canvas canvas, Size size) {
    final b = labBleed(size);
    canvas.drawRect(
      b,
      Paint()
        ..shader = RadialGradient(
          radius: 0.85,
          colors: isDark
              ? const [Color(0xFF0C4A6E), Color(0xFF082F49), Color(0xFF020617)]
              : const [Color(0xFFF0F9FF), Color(0xFFBAE6FD), Color(0xFF7DD3FC)],
          stops: const [0, 0.55, 1],
        ).createShader(const Rect.fromLTWH(0, 0, 1000, 600)),
    );
    final streak = Paint()
      ..color = (isDark ? Colors.white : _Colors.sky700).withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 16; i++) {
      final y = 40 + i * 34.0;
      labDashedLine(canvas, Offset(-250, y), Offset(1250, y), streak, dash: 40, gap: 60, phase: -t * 90 - i * 23);
    }
    _paintGillArch(canvas);
    for (var i = 0; i < 8; i++) {
      _paintFilament(canvas, i);
    }
    _paintO2Stream(canvas);
    if (showLabels) _paintGillLabels(canvas);
  }

  void _paintGillArch(Canvas canvas) {
    final arch = Path()
      ..moveTo(262, 62)
      ..quadraticBezierTo(170, 300, 262, 538);
    Paint stroke(double w, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = c;
    canvas.drawPath(arch.shift(const Offset(5, 7)), stroke(50, Colors.black.withValues(alpha: 0.25)));
    canvas.drawPath(arch, stroke(48, isDark ? _Colors.slate400 : _Colors.slate500));
    canvas.drawPath(arch, stroke(42, _Colors.gillArch));
    canvas.drawPath(arch.shift(const Offset(-9, 0)), stroke(9, Colors.white.withValues(alpha: 0.6)));
    // Blood vessels along the arch: in (purple) and out (red).
    canvas.drawPath(arch.shift(const Offset(-6, 0)), stroke(7, _Colors.bloodDeoxy));
    canvas.drawPath(arch.shift(const Offset(9, 0)), stroke(7, _Colors.bloodOxy));
  }

  void _paintFilament(Canvas canvas, int i) {
    final y = _filY(i);
    final ax = _archX(y);
    final bx = ax + 14;
    final tip = Offset(640 - (i.isOdd ? 22 : 0), y + (_hash(i, 7) - 0.5) * 16);
    final len = tip.dx - bx;
    const hw = 21.0;
    const f = _Colors.filament;

    // Secondary lamellae: the feathery folds on both edges.
    final lam = Paint()
      ..color = labShade(f, -0.22)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var d = 16.0; d < len - 24; d += 12) {
      final u = d / len;
      final cy = y + (tip.dy - y) * u;
      final w = hw * (1 - math.pow(u, 1.8).toDouble()) + 1;
      final px = bx + d;
      canvas.drawLine(Offset(px, cy - w + 3), Offset(px + 3, cy - w - 6), lam);
      canvas.drawLine(Offset(px, cy + w - 3), Offset(px + 3, cy + w + 6), lam);
    }
    final body = Path()
      ..moveTo(bx, y - hw)
      ..cubicTo(bx + len * 0.45, y - hw - 1, tip.dx - 40, tip.dy - 13, tip.dx, tip.dy)
      ..cubicTo(tip.dx - 40, tip.dy + 13, bx + len * 0.45, y + hw + 1, bx, y + hw)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            labShade(f, -0.2).withValues(alpha: 0.92),
            labShade(f, 0.25).withValues(alpha: 0.92),
            f.withValues(alpha: 0.92),
            labShade(f, -0.28).withValues(alpha: 0.92),
          ],
          stops: const [0, 0.35, 0.6, 1],
        ).createShader(Rect.fromLTRB(bx, y - hw, tip.dx, y + hw)),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = labShade(f, -0.45).withValues(alpha: 0.6),
    );

    // Capillary loop: deoxygenated blood in, oxygenated blood out.
    final pulse = _gillPulse(i);
    final tipCol = Color.lerp(_Colors.bloodDeoxy, _Colors.bloodOxy, 0.5 * pulse)!;
    final outCol = Color.lerp(_Colors.bloodDeoxy, _Colors.bloodOxy, pulse)!;
    final turn = Offset(tip.dx - 16, tip.dy);
    final lower = Path()
      ..moveTo(ax - 6, y + 7)
      ..cubicTo(bx + len * 0.5, y + 10, turn.dx - 10, turn.dy + 7, turn.dx, turn.dy);
    final upper = Path()
      ..moveTo(turn.dx, turn.dy)
      ..cubicTo(turn.dx - 10, turn.dy - 7, bx + len * 0.5, y - 10, ax + 9, y - 7);
    final gr = Rect.fromLTRB(bx, y - 10, turn.dx, y + 10);
    Paint vessel(List<Color> colors) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(colors: colors).createShader(gr);
    canvas.drawPath(lower, vessel([_Colors.bloodDeoxy, tipCol]));
    canvas.drawPath(upper, vessel([outCol, tipCol]));
    final ml = lower.computeMetrics().first;
    final mu = upper.computeMetrics().first;
    for (var k = 0; k < 4; k++) {
      final u = (t * 0.35 + k / 4 + i * 0.137) % 1.0;
      final onLower = u < 0.5;
      final m = onLower ? ml : mu;
      final pos = m.getTangentForOffset(m.length * (onLower ? u : u - 0.5) * 2)!.position;
      final col = onLower
          ? Color.lerp(_Colors.bloodDeoxy, tipCol, u * 2)!
          : Color.lerp(tipCol, outCol, (u - 0.5) * 2)!;
      canvas.drawCircle(pos, 3.4, Paint()..color = labShade(col, 0.3));
    }
  }

  /// HTML `magParticlesIn` / `magParticlesOut`: O₂ carried by the water;
  /// most of it is absorbed into the capillaries, the rest leaves faded.
  void _paintO2Stream(Canvas canvas) {
    for (var i = 0; i < 80; i++) {
      final h1 = _hash(i, 11);
      final h2 = _hash(i, 12);
      final h3 = _hash(i, 13);
      final h4 = _hash(i, 14);
      final u = (t * (0.07 + 0.03 * h1) + h2) % 1.0;
      final x = -80 + u * 1160;
      final baseY = 70 + h3 * 460;
      var p = Offset(x, baseY + math.sin(t * 3 + i) * 8);
      var a = 1.0;
      var r = 5.0;
      final absorbed = h4 < 0.62;
      final ax = 320 + h1 * 270;
      if (absorbed && x > ax) {
        final k = ((x - ax) / 80).clamp(0.0, 1.0);
        if (k >= 1) continue;
        final fi = ((baseY - 300) / 58 + 3.5).round().clamp(0, 7);
        final fy = _filY(fi) + (h2 < 0.5 ? -7 : 7);
        p = Offset(ax + (x - ax) * 0.3, p.dy + (fy - p.dy) * Curves.easeIn.transform(k));
        a = 1 - k;
        r = 5 * (1 - 0.5 * k);
      } else if (!absorbed && x > 640) {
        a = 0.4;
      }
      if (isDark) labGlow(canvas, p, r * 3, _o2, intensity: 0.45 * a);
      canvas.drawCircle(p, r, Paint()..color = _o2.withValues(alpha: 0.95 * a));
      if (i % 8 == 0 && a > 0.5) {
        _chemText(
          canvas,
          'O₂',
          p + const Offset(0, -15),
          size: 14,
          weight: FontWeight.w800,
          color: (isDark ? Colors.white : _Colors.sky900).withValues(alpha: a),
        );
      }
    }
  }

  void _paintGillLabels(Canvas canvas) {
    labArrow(canvas, const Offset(24, 345), const Offset(150, 345), color: _o2.withValues(alpha: 0.85), width: 8, head: 22);
    _pill(canvas, tr('lbl_rich'), const Offset(92, 305));
    labArrow(canvas, const Offset(690, 300), const Offset(820, 300), color: _o2.withValues(alpha: 0.5), width: 8, head: 22);
    _pill(canvas, tr('lbl_poor'), const Offset(755, 260));
    _leader(canvas, Offset(618, _filY(1)), Offset(770, _filY(1) - 34), tr('lbl_filaments'));
    _leader(canvas, Offset(560, _filY(6) - 6), Offset(760, _filY(6) + 50), tr('lbl_capillaries'));
    _leader(canvas, Offset(_archX(470) - 16, 470), const Offset(100, 520), tr('lbl_gill_arch'));
  }

  // ------------------------------------------------ scenario 2: the pond

  /// Ground profile: the grassy bank, the shore slope and the pond bed.
  Path _earth(Rect b) => Path()
    ..moveTo(b.left, _groundY)
    ..lineTo(300, _groundY)
    ..cubicTo(340, _groundY, 362, _groundY + 14, _shoreX, _pondY + 6)
    ..cubicTo(412, 450, 470, 540, 570, 562)
    ..cubicTo(700, 582, 820, 556, 1000, 568)
    ..lineTo(b.right, 568)
    ..lineTo(b.right, b.bottom)
    ..lineTo(b.left, b.bottom)
    ..close();

  void _paintPondLab(Canvas canvas, Size size) {
    final b = labBleed(size);
    final earth = _earth(b);
    final water = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTRB(_shoreX - 40, _pondY, b.right, b.bottom)),
      earth,
    );
    _paintSky(canvas, b);
    _paintBank(canvas, b, earth);
    _paintPondWater(canvas, b, earth, water);
    _paintReeds(canvas, front: false);
    final pose = scene.frogPose;
    final held = scene.held == _Item.frog;
    if (!held) _paintFrogNow(canvas, pose.pos, pose.legs, shadow: true);
    // Water in front of the frog's submerged half.
    canvas.drawPath(
      water,
      Paint()..color = (isDark ? const Color(0xFF0E7490) : _Colors.sky500).withValues(alpha: 0.28),
    );
    _paintSurface(canvas, b);
    _lilyPad(canvas, _padCenter, 95, 22, notch: 0.35, flower: true);
    _paintReeds(canvas, front: true);
    if (!held) _paintAirStream(canvas, pose.pos);
    _paintDissolvedO2(canvas);
    _paintSplash(canvas);
    if (scene.dragging == _Item.frog) {
      _paintZone(
        canvas,
        RRect.fromRectAndRadius(_pondZone.deflate(6), const Radius.circular(24)),
        Offset(_pondZone.center.dx, _pondZone.top + 36),
      );
    }
    if (showLabels) _paintPondLabels(canvas, pose.pos, held);
    if (held && scene.pointer != null) _paintFrogNow(canvas, scene.pointer!, 0.6, shadow: false);
  }

  void _paintSky(Canvas canvas, Rect b) {
    canvas.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, _pondY + 2),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF020617), Color(0xFF0B2545), Color(0xFF155E75)]
              : const [Color(0xFF38BDF8), Color(0xFF7DD3FC), Color(0xFFE0F2FE)],
          stops: const [0, 0.6, 1],
        ).createShader(const Rect.fromLTRB(0, 0, 1000, _pondY)),
    );
    if (isDark) {
      for (var i = 0; i < 45; i++) {
        final p = Offset(-200 + _hash(i, 81) * 1400, -120 + _hash(i, 82) * 330);
        final tw = 0.5 + 0.5 * math.sin(t * 2 + i);
        canvas.drawCircle(p, 1.2 + _hash(i, 83), Paint()..color = Colors.white.withValues(alpha: 0.25 + 0.5 * tw));
      }
      labGlow(canvas, const Offset(700, 84), 90, const Color(0xFFE0F2FE), intensity: 0.35);
      canvas.drawCircle(const Offset(700, 84), 24, Paint()..color = const Color(0xFFF1F5F9));
    } else {
      labGlow(canvas, const Offset(700, 84), 140, const Color(0xFFFDE68A), intensity: 0.7);
      canvas.drawCircle(const Offset(700, 84), 30, Paint()..color = const Color(0xFFFEF3C7));
    }
    // Drifting clouds.
    final cloud = Paint()..color = isDark ? const Color(0x14CBD5E1) : const Color(0xE6FFFFFF);
    for (var i = 0; i < 3; i++) {
      final cx = ((180 + i * 380 + t * 8) % 1400) - 200;
      final cy = 70.0 + i * 38;
      for (final (dx, dy, r) in const [(0.0, 0.0, 24.0), (26.0, -10.0, 30.0), (56.0, 0.0, 22.0), (28.0, 8.0, 24.0)]) {
        canvas.drawCircle(Offset(cx + dx, cy + dy), r, cloud);
      }
    }
    // Hills and a tree line on the far side.
    final hills = Path()..moveTo(-400, _pondY);
    for (var x = -400.0; x <= 1400; x += 20) {
      hills.lineTo(x, 300 - 24 * math.sin(x / 120) - 12 * math.sin(x / 47 + 1.3));
    }
    hills
      ..lineTo(1400, _pondY)
      ..close();
    canvas.drawPath(hills, Paint()..color = isDark ? const Color(0xFF0F2A2E) : const Color(0xFF86EFAC));
    final trees = Paint()..color = isDark ? const Color(0xFF0B3B2E) : const Color(0xFF4ADE80);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(Offset(-250 + i * 55.0, 338 - 12 * _hash(i, 21)), 26 + 10 * _hash(i, 22), trees);
    }
    // Far bank behind the pond.
    canvas.drawRect(
      Rect.fromLTRB(_shoreX - 20, 352, b.right, _pondY + 2),
      Paint()..color = isDark ? const Color(0xFF14532D) : const Color(0xFF22C55E),
    );
  }

  void _paintBank(Canvas canvas, Rect b, Path earth) {
    canvas.drawPath(
      earth,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF4A3220), Color(0xFF1F150C)]
              : const [Color(0xFF8B5E34), Color(0xFF5B3A1E)],
        ).createShader(const Rect.fromLTRB(0, _groundY, 600, 600)),
    );
    final pebble = Paint()..color = Colors.black.withValues(alpha: 0.18);
    for (var i = 0; i < 60; i++) {
      final p = Offset(-80 + _hash(i, 91) * 1080, _groundY + 26 + _hash(i, 92) * 250);
      if (!earth.contains(p)) continue;
      canvas.drawOval(Rect.fromCenter(center: p, width: 8 + 8 * _hash(i, 93), height: 5 + 4 * _hash(i, 94)), pebble);
    }
    final grass = Path()
      ..moveTo(b.left, _groundY - 4)
      ..lineTo(300, _groundY - 4)
      ..cubicTo(342, _groundY - 4, 366, _groundY + 10, _shoreX + 4, _pondY + 2)
      ..lineTo(_shoreX - 6, _pondY + 10)
      ..cubicTo(356, _groundY + 24, 336, _groundY + 14, 300, _groundY + 14)
      ..lineTo(b.left, _groundY + 14)
      ..close();
    canvas.drawPath(grass, Paint()..color = isDark ? const Color(0xFF166534) : _Colors.green500);
    final blade = Paint()
      ..color = isDark ? _Colors.green700 : _Colors.green600
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var x = -260.0; x < 350; x += 9) {
      final h = 8 + 9 * _hash(x.toInt(), 31);
      final sway = math.sin(t * 2 + x / 30) * 2;
      canvas.drawLine(Offset(x, _groundY - 2), Offset(x + 2 + sway, _groundY - 2 - h), blade);
    }
    // A few daisies on the grass.
    for (final fx in const [-120.0, 40.0, 330.0]) {
      final c = Offset(fx, _groundY - 10);
      for (var k = 0; k < 6; k++) {
        final a = k * math.pi / 3;
        canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * 5, 3.5, Paint()..color = Colors.white);
      }
      canvas.drawCircle(c, 3, Paint()..color = const Color(0xFFFACC15));
    }
  }

  void _paintPondWater(Canvas canvas, Rect b, Path earth, Path water) {
    // Stones on the pond bed.
    for (var i = 0; i < 9; i++) {
      final c = Offset(600 + i * 46.0 + 14 * _hash(i, 111), 566 + 6 * _hash(i, 112));
      _rock(canvas, c, 26 + 18 * _hash(i, 113), 12 + 8 * _hash(i, 114));
    }
    // Dark mud lining the slope and the bed under the water.
    canvas.save();
    canvas.clipPath(earth);
    canvas.drawPath(
      Path()
        ..moveTo(_shoreX, _pondY + 6)
        ..cubicTo(412, 450, 470, 540, 570, 562)
        ..cubicTo(700, 582, 820, 556, 1000, 568)
        ..lineTo(b.right, 568),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..color = isDark ? const Color(0xFF241709) : const Color(0xFF4A3218),
    );
    canvas.restore();
    canvas.drawPath(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xCC0E7490), Color(0xE6082F49)]
              : const [Color(0xB338BDF8), Color(0xD90369A1)],
        ).createShader(const Rect.fromLTRB(0, _pondY, 1000, 580)),
    );
    // Swaying eelgrass.
    final weed = (isDark ? const Color(0xFF166534) : const Color(0xFF15803D)).withValues(alpha: 0.85);
    for (var i = 0; i < 7; i++) {
      final root = Offset(520 + i * 64.0 + 20 * _hash(i, 101), 566);
      final h = 70 + 60 * _hash(i, 102);
      final sway = math.sin(t * 1.2 + i) * 9;
      final path = Path()
        ..moveTo(root.dx, root.dy)
        ..cubicTo(root.dx - 8 + sway * 0.3, root.dy - h * 0.35, root.dx + 8 + sway * 0.8, root.dy - h * 0.7,
            root.dx + sway * 1.4, root.dy - h);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = weed,
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = labShade(weed, 0.3),
      );
    }
  }

  void _paintSurface(Canvas canvas, Rect b) {
    final line = Path()..moveTo(_shoreX - 4, _pondY);
    for (var x = _shoreX; x <= 1400; x += 8) {
      line.lineTo(x, _pondY + math.sin(x / 26 + t * 2) * 1.6);
    }
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white.withValues(alpha: isDark ? 0.45 : 0.75),
    );
    final glint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 10; i++) {
      final x = 430 + i * 60 + math.sin(t + i) * 10;
      final y = _pondY + 12 + (i % 3) * 14.0;
      canvas.drawLine(Offset(x, y), Offset(x + 18, y), glint);
    }
    if (scene.frogLanded) {
      for (var k = 0; k < 2; k++) {
        final ph = (t * 0.6 + k * 0.5) % 1.0;
        final rx = 70 + 70 * ph;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(_frogPond.dx, _pondY + 3), width: rx * 2, height: rx * 0.22),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white.withValues(alpha: (1 - ph) * 0.5),
        );
      }
    }
  }

  void _lilyPad(Canvas canvas, Offset c, double rx, double ry, {double notch = 0, bool flower = false}) {
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(4, 5), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    final r = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    final pad = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(r, notch + 0.22, 2 * math.pi - 0.44, false)
      ..close();
    canvas.drawPath(
      pad,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          colors: [Color(0xFF86EFAC), _Colors.lilypad, _Colors.green700],
          stops: [0, 0.55, 1],
        ).createShader(r),
    );
    final vein = Paint()
      ..strokeWidth = 1.5
      ..color = _Colors.green700.withValues(alpha: 0.55);
    for (var k = 0; k < 9; k++) {
      final a = notch + 0.45 + k * (2 * math.pi - 0.9) / 8;
      canvas.drawLine(c, c + Offset(math.cos(a) * rx * 0.88, math.sin(a) * ry * 0.88), vein);
    }
    canvas.drawPath(
      pad,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.green700,
    );
    if (flower) _waterLily(canvas, c + Offset(-rx * 0.42, -ry * 0.5));
  }

  void _waterLily(Canvas canvas, Offset c) {
    void petal(double angle, double len, Color col) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      final w = len * 0.4;
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-w, -len * 0.55, 0, -len)
        ..quadraticBezierTo(w, -len * 0.55, 0, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = col);
      canvas.restore();
    }

    for (final a in const [-1.25, -0.6, 0.6, 1.25]) {
      petal(a, 26, const Color(0xFFF9A8D4));
    }
    for (final a in const [-0.85, -0.3, 0.3, 0.85, 0.0]) {
      petal(a, 30, const Color(0xFFEC4899));
    }
    canvas.drawCircle(c + const Offset(0, -6), 6, Paint()..color = const Color(0xFFFACC15));
  }

  void _paintReeds(Canvas canvas, {required bool front}) {
    final stems = front
        ? const [(912.0, 40.0, 200.0), (938.0, 44.0, 240.0), (966.0, 38.0, 180.0)]
        : const [(392.0, 26.0, 150.0), (409.0, 32.0, 195.0), (426.0, 28.0, 130.0)];
    final stem = isDark ? const Color(0xFF3F6212) : const Color(0xFF65A30D);
    for (final (x, below, h) in stems) {
      final base = _pondY + below;
      final sway = math.sin(t * 1.3 + x) * 6;
      final top = Offset(x + sway, base - h);
      canvas.drawPath(
        Path()
          ..moveTo(x, base)
          ..quadraticBezierTo(x + sway * 0.2, base - h * 0.5, top.dx, top.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = stem,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x, base)
          ..quadraticBezierTo(x - 20, base - h * 0.4, x - 28 + sway, base - h * 0.62),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = labShade(stem, 0.15),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: top + const Offset(0, 26), width: 11, height: 38), const Radius.circular(6)),
        Paint()..color = const Color(0xFF78350F),
      );
    }
  }

  void _paintFrogNow(Canvas canvas, Offset pos, double legs, {required bool shadow}) {
    if (shadow) {
      if (scene.jumpStart < 0) {
        labGroundShadow(canvas, Offset(pos.dx - 14, _groundY + 2), 200, 22, opacity: 0.35);
      } else if (!scene.frogLanded) {
        final ground = pos.dx < _shoreX ? _groundY : _pondY;
        final h = (ground - (pos.dy + 0.4 * _frogLen)).clamp(0.0, 300.0);
        labGroundShadow(canvas, Offset(pos.dx, ground + 2), 170 - h * 0.25, 18, opacity: 0.3 * (1 - h / 300));
      }
    }
    _paintFrog(
      canvas,
      pos,
      _frogLen,
      _FrogLook(
        xray: scene.xray,
        capOpacity: scene.capOpacity,
        capColor: scene.capColor,
        lungScale: scene.lungScale,
        lungColor: scene.lungColor,
        throat: scene.throat,
        legs: legs,
      ),
    );
  }

  /// HTML `airParticles`: air drawn in through the nostrils; with the
  /// X-ray it is seen travelling down the windpipe into the lungs.
  void _paintAirStream(Canvas canvas, Offset frog) {
    if (!scene.xrayOn || scene.frogInWater) return;
    const nostril = Offset(0.5, -0.125);
    const pharynx = Offset(0.36, -0.05);
    const lungs = Offset(0.08, -0.07);
    for (var i = 0; i < 30; i++) {
      final ph = (t * 0.5 + i / 30) % 1.0;
      Offset lp;
      double a;
      if (ph < 0.6) {
        final q = ph / 0.6;
        final from = Offset(0.66 + 0.32 * _hash(i, 41), -0.26 + 0.2 * _hash(i, 42));
        lp = Offset.lerp(from, nostril, Curves.easeIn.transform(q))!;
        a = math.min(1.0, q * 3);
      } else {
        final q = (ph - 0.6) / 0.4;
        lp = _quad(nostril, pharynx, lungs, q);
        a = 1 - q * 0.6;
      }
      final p = frog + lp * _frogLen;
      if (isDark) labGlow(canvas, p, 8, _o2, intensity: 0.5 * a);
      canvas.drawCircle(p, 3.2, Paint()..color = _o2.withValues(alpha: a));
    }
  }

  /// HTML `waterO2Particles`: dissolved O₂ drifting to the frog's skin.
  void _paintDissolvedO2(Canvas canvas) {
    if (scene.waterO2Start < 0) return;
    final fade = ((t - scene.waterO2Start) / 0.6).clamp(0.0, 1.0);
    for (var i = 0; i < 70; i++) {
      final ph = (t * (0.28 + 0.1 * _hash(i, 55)) + _hash(i, 51)) % 1.0;
      final spawn = Offset(420 + 480 * _hash(i, 52), _pondY + 30 + 185 * _hash(i, 53));
      final target = _frogPond +
          Offset((_hash(i, 54) - 0.5) * 0.8 * _frogLen, (0.06 + 0.16 * _hash(i, 53)) * _frogLen);
      final p = Offset.lerp(spawn, target, Curves.easeInOut.transform(ph))! +
          Offset(math.sin(t * 2 + i) * 3, math.cos(t * 1.7 + i) * 2);
      final a = math.sin(math.pi * ph).clamp(0.0, 1.0) * fade;
      if (isDark) labGlow(canvas, p, 10, _o2, intensity: 0.5 * a);
      canvas.drawCircle(p, 3.6, Paint()..color = (isDark ? _o2 : _Colors.sky100).withValues(alpha: 0.95 * a));
      if (i % 10 == 0 && a > 0.5) {
        _chemText(canvas, 'O₂', p + const Offset(0, -14), size: 13, weight: FontWeight.w800,
            color: Colors.white.withValues(alpha: a));
      }
    }
  }

  void _paintPondLabels(Canvas canvas, Offset frog, bool held) {
    _pill(canvas, tr('lbl_land'), const Offset(110, _groundY + 78));
    _pill(canvas, tr('lbl_pond'), const Offset(740, 540));
    if (held) return;
    const l = _frogLen;
    final onLand = scene.jumpStart < 0;
    if (scene.xray > 0.5) {
      // On the bank the labels go below the frog (the collapsed mission
      // card covers the sky there); in the pond they go above it.
      _leader(canvas, frog + const Offset(0.06, -0.06) * l,
          frog + (onLand ? const Offset(0.12, 0.7) : const Offset(-0.1, -0.68)) * l, tr('lbl_lungs'));
      _leader(canvas, frog + const Offset(-0.24, 0.02) * l,
          frog + (onLand ? const Offset(-0.5, 0.95) : const Offset(-0.62, -0.44)) * l, tr('lbl_skin_caps'));
    }
    if (scene.xrayOn && !scene.frogInWater) {
      _leader(canvas, frog + const Offset(0.5, -0.125) * l, frog + const Offset(0.86, -0.5) * l, tr('lbl_nostrils'));
      _tag(canvas, tr('lbl_air'), frog + const Offset(1.0, 0.06) * l);
    }
    if (scene.waterO2Start >= 0) _pill(canvas, tr('lbl_dissolved'), const Offset(800, 480));
  }

  // ------------------------------------------------------------ confetti

  /// HTML `confetti({particleCount: 120, spread: 100})` on completion.
  void _paintConfetti(Canvas canvas) {
    if (scene.confettiStart < 0) return;
    final age = t - scene.confettiStart;
    if (age > 3.2) return;
    const colors = [_Colors.sky500, Color(0xFF3B82F6), _Colors.green500, Colors.white];
    final fade = age > 2.4 ? (3.2 - age) / 0.8 : 1.0;
    for (var i = 0; i < 120; i++) {
      final ang = -math.pi / 2 + (_hash(i, 121) - 0.5) * 1.75;
      final v = 380 + 420 * _hash(i, 122);
      final drag = (1 - math.exp(-age * 1.6)) / 1.6;
      final p = Offset(
        500 + math.cos(ang) * v * drag,
        320 + math.sin(ang) * v * drag + 320 * age * age,
      );
      final rot = age * (6 + 8 * _hash(i, 123));
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(rot);
      canvas.scale(1, math.cos(rot * 1.3));
      canvas.drawRect(
        const Rect.fromLTWH(-6, -3.5, 12, 7),
        Paint()..color = colors[i % colors.length].withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RespPainter old) =>
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
