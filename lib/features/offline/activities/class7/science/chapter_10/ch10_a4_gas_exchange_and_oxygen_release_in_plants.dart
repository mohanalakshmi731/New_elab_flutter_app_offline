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

/// Class 7 Science • Chapter 10 • Activity 4
/// Gas Exchange and Oxygen Release in Plants.
///
/// Native Flutter port of `Cl7S-Ch10-A4-Gas_Exchange_and_Oxygen_Release_in_Plants.html`.
/// Scenario 1 builds a Hydrilla / funnel / test tube setup, duplicates it into
/// a sunlit zone and a dark box, fast-forwards time and tests the collected
/// gas with a matchstick. Scenario 2 seals germinating moong seeds in a flask
/// and pipes their CO₂ through lime water, which turns milky.
class Ch10A4GasExchangeAndOxygenReleaseInPlantsPage extends StatefulWidget {
  const Ch10A4GasExchangeAndOxygenReleaseInPlantsPage({super.key});

  @override
  State<Ch10A4GasExchangeAndOxygenReleaseInPlantsPage> createState() =>
      _Ch10A4GasExchangeAndOxygenReleaseInPlantsPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pickup 2356, drop 2364, fire 1348,
/// splash 1311, bubble 732, magic 871.
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

  /// HTML `playSound('drag')`: an object is picked up.
  pickup('pickup.mp3'),

  /// HTML `playSound('drop')`: an object lands in its place.
  drop('drop.mp3'),

  /// HTML `playSound('flare')`: the matchstick flares up in oxygen.
  fire('fire.mp3'),

  /// HTML `playSound('pour')`: dry seeds poured into the water bowl.
  splash('splash.mp3'),

  /// Gas bubbles start rising during a time-lapse.
  bubble('bubble.mp3'),

  /// HTML `playSound('magic')`: the setup is duplicated.
  magic('magic.mp3');

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

/// Tailwind / CSS colours used by this lab (HTML `--accent`, `--wall-color`,
/// `--table-top`, SVG fills...).
abstract final class _Colors {
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // --accent (dark)
  static const Color green600 = Color(0xFF16A34A); // --accent-hover (dark)
  static const Color green700 = Color(0xFF15803D); // hydrilla stem
  static const Color emerald500 = Color(0xFF10B981); // --accent (light)
  static const Color emerald600 = Color(0xFF059669); // --accent-hover (light)
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red900 = Color(0xFF7F1D1D); // match head
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706); // --table-top (light)
  static const Color amber700 = Color(0xFFB45309); // cork
  static const Color amber800 = Color(0xFF92400E); // --table-side (light)
  static const Color amber900 = Color(0xFF78350F); // rack bars
  static const Color amber950 = Color(0xFF451A03); // rack legs
  static const Color orange500 = Color(0xFFF97316);
  static const Color lime600 = Color(0xFF65A30D); // moong seeds
  static const Color lime700 = Color(0xFF4D7C0F);
  static const Color sky100 = Color(0xFFE0F2FE); // --wall-color (light)
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
}

/// This lab's light and dark palettes (the HTML `:root` / `.light-theme`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF21E293B),
    border: Color(0x99334155),
    card: Color(0xCC0F172A),
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: _Colors.slate50,
    textMuted: _Colors.slate400,
    accent: _Colors.green500,
    onAccent: _Colors.slate900,
    primary: _Colors.green600,
    onPrimary: Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: Color(0xF2143D2A),
    toastText: Color(0xFFBBF7D0),
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4D22C55E),
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
    bg: _Colors.slate100,
    panel: Color(0xF2FFFFFF),
    border: Color(0x99CBD5E1),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sky100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.emerald500,
    onAccent: _Colors.slate900,
    primary: _Colors.emerald600,
    onPrimary: Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue600,
    popupBg: _Colors.slate100,
    popupHeader: Colors.white,
    dialogBg: Colors.white,
    toastBg: Color(0xF2DCFCE7),
    toastText: Color(0xFF166534),
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4D22C55E),
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
    'app_title': 'Gas Exchange in Plants',
    'app_subtitle': 'Class 7 • Life Processes in Plants',
    'scen_1': '1. The Oxygen Factory',
    'scen_2': "2. The Seed's Breath",
    'sci_obs': 'Scientific Conclusion',
    'exp_out': 'Detailed Concept & Outcome',
    // HUD feedback (HTML `hud`).
    'h_dragPlant': 'Drag the Hydrilla plant to the beaker.',
    'h_plantIn': 'Hydrilla placed.',
    'h_dragFunnel': 'Drag the funnel to cover the plant.',
    'h_funnelIn': 'Funnel positioned.',
    'h_dragTube': 'Drag the inverted test tube over the funnel.',
    'h_tubeIn': 'Initial setup complete. We need a control.',
    'h_duplicate': 'Setups successfully duplicated.',
    'h_dragZones': 'Drag Setup A to the Sunny zone. Drag B to the Dark Box.',
    'h_zonesIn': 'Environments set.',
    'h_simulating': 'Simulating time passage...',
    'h_bubbles': 'Observe the gas collecting in Setup A.',
    'h_testA': 'Drag Tube A to the rack. Then drag the matchstick.',
    'h_flare': 'Huge flare! Oxygen detected.',
    'h_testB': 'Drag Tube B to the rack. Then drag the matchstick.',
    'h_noFlare': 'No reaction. No oxygen present.',
    'h_dragSeeds': 'Drag the beaker of dry seeds to the water bowl.',
    'h_seedsSoaking': 'Seeds soaking to break dormancy...',
    'h_dragCotton': 'Drag cotton to the flask. Use the dropper to moisten it.',
    'h_cottonWet': 'Cotton bed is moist.',
    'h_addWetSeeds': 'Drag the soaked seeds to the moist flask.',
    'h_seedsIn': 'Seeds added to the chamber.',
    'h_dragCork': 'Drag the cork to seal the flask.',
    'h_corkIn': 'Chamber sealed airtight.',
    'h_dragTubes': 'Drag the lime water indicator tubes to the rack.',
    'h_tubesIn': 'Indicator tubes ready.',
    'h_dragPipe': 'Drag the rubber pipe to connect the flask to Tube B.',
    'h_pipeConnected': 'Exhaust pathway sealed.',
    'h_respiring': 'Seeds actively respiring...',
    'h_milky': 'Chemical reaction! Lime water turned milky.',
    'h_conc': 'Experiment complete.',
    'btn_dup': 'Duplicate Setup',
    'btn_ff': 'Fast Forward Simulation',
    'btn_ff24': 'Fast Forward 24 Hrs',
    // Scene labels (HTML `lbl`).
    'lbl_hydrilla': 'Hydrilla Plant',
    'lbl_beaker': 'Glass Beaker',
    'lbl_funnel': 'Glass Funnel',
    'lbl_tube': 'Test Tube',
    'lbl_tubeA': 'Tube A',
    'lbl_tubeB': 'Tube B',
    'lbl_sun': 'Sunlight Zone',
    'lbl_dark': 'Dark Box Zone',
    'lbl_match': 'Matchstick',
    'lbl_rack': 'Test Tube Rack',
    'lbl_seeds': 'Moong Seeds',
    'lbl_bowl': 'Water Bowl',
    'lbl_cotton': 'Cotton Wool',
    'lbl_dropper': 'Water Dropper',
    'lbl_flask': 'Conical Flask',
    'lbl_cork': 'Rubber Cork',
    'lbl_pipe': 'Rubber Pipe',
    'lbl_limeA': 'Lime Water A (Control)',
    'lbl_limeB': 'Lime Water B',
    'lbl_setupA': 'Setup A (Light)',
    'lbl_setupB': 'Setup B (Dark)',
    'lbl_soaked': 'Soaked Seeds',
    'lbl_a': 'A',
    'lbl_b': 'B',
    // Small additions of the native port.
    'try_again': 'Not there!',
    'timelapse': 'Time-lapse',
    'hours': 'h',
    // Conclusions (HTML `s1_conclusion` / `s2_conclusion`).
    's1_res_title': 'Photosynthesis Result',
    's1_p1': 'The bright flare of the matchstick confirms the presence of Oxygen.',
    's1_p2': 'Gas bubbles were only produced by the plant exposed to the sunlight (Setup A).',
    's1_p3': 'The plant hidden in the dark box (Setup B) did not photosynthesize and produced zero gas.',
    's1_conc':
        'Conclusion: Plants release Oxygen as a byproduct of photosynthesis, which strictly requires light energy.',
    's2_res_title': 'Respiration Result',
    's2_p1': 'The lime water turning milky white definitively confirms the presence of Carbon Dioxide.',
    's2_p2':
        'The germinating seeds in the sealed flask actively respired, breaking down their stored food to generate energy for growth.',
    's2_p3':
        'This life process exhausted CO₂, which traveled through the sealed pipe and reacted chemically with the lime water in Tube B.',
    's2_conc':
        'Conclusion: Living germinating seeds actively respire, consuming oxygen and releasing Carbon Dioxide.',
  },
  'hi': {
    'app_title': 'पौधों में गैस विनिमय',
    'app_subtitle': 'कक्षा 7 • पौधों में जैव प्रक्रम',
    'scen_1': '1. ऑक्सीजन फैक्ट्री',
    'scen_2': '2. बीज की सांस',
    'sci_obs': 'वैज्ञानिक निष्कर्ष',
    'exp_out': 'विस्तृत अवधारणा और परिणाम',
    'h_dragPlant': 'हाइड्रिला को बीकर में खींचें।',
    'h_plantIn': 'पौधा रखा गया।',
    'h_dragFunnel': 'फ़नल को पौधे के ऊपर खींचें।',
    'h_funnelIn': 'फ़नल स्थित है।',
    'h_dragTube': 'टेस्ट ट्यूब को फ़नल के ऊपर खींचें।',
    'h_tubeIn': 'सेटअप पूरा हुआ। नियंत्रण की आवश्यकता है।',
    'h_duplicate': 'सेटअप डुप्लिकेट किए गए।',
    'h_dragZones': 'सेटअप A को सूर्य पर, B को डार्क बॉक्स में खींचें।',
    'h_zonesIn': 'वातावरण सेट।',
    'h_simulating': 'अनुकरण हो रहा है...',
    'h_bubbles': 'गैस इकट्ठा होने का निरीक्षण करें।',
    'h_testA': 'ट्यूब A को रैक पर खींचें। फिर माचिस को खींचें।',
    'h_flare': 'तेज लौ! ऑक्सीजन का पता चला।',
    'h_testB': 'ट्यूब B को रैक पर खींचें। फिर माचिस को खींचें।',
    'h_noFlare': 'कोई प्रतिक्रिया नहीं।',
    'h_dragSeeds': 'सूखे बीजों को पानी के कटोरे में खींचें।',
    'h_seedsSoaking': 'बीज भीग रहे हैं...',
    'h_dragCotton': 'कपास को फ्लास्क में खींचें। ड्रॉपर का उपयोग करें।',
    'h_cottonWet': 'कपास नम है।',
    'h_addWetSeeds': 'भीगे हुए बीजों को फ्लास्क में खींचें।',
    'h_seedsIn': 'बीज जोड़े गए।',
    'h_dragCork': 'फ्लास्क को सील करने के लिए कॉर्क खींचें।',
    'h_corkIn': 'कक्ष सील है।',
    'h_dragTubes': 'संकेतक ट्यूबों को रैक पर खींचें।',
    'h_tubesIn': 'ट्यूब तैयार हैं।',
    'h_dragPipe': 'फ्लास्क और ट्यूब B को जोड़ने के लिए रबर पाइप खींचें।',
    'h_pipeConnected': 'निकास मार्ग सील है।',
    'h_respiring': 'बीज श्वसन कर रहे हैं...',
    'h_milky': 'रासायनिक प्रतिक्रिया! चूने का पानी दूधिया हो गया।',
    'h_conc': 'प्रयोग पूर्ण।',
    'btn_dup': 'डुप्लिकेट सेटअप',
    'btn_ff': 'सिमुलेशन फास्ट फॉरवर्ड करें',
    'btn_ff24': '24 घंटे फास्ट फॉरवर्ड',
    'lbl_hydrilla': 'हाइड्रिला पौधा',
    'lbl_beaker': 'कांच का बीकर',
    'lbl_funnel': 'कांच का फ़नल',
    'lbl_tube': 'टेस्ट ट्यूब',
    'lbl_tubeA': 'ट्यूब A',
    'lbl_tubeB': 'ट्यूब B',
    'lbl_sun': 'धूप क्षेत्र',
    'lbl_dark': 'डार्क बॉक्स',
    'lbl_match': 'माचिस',
    'lbl_rack': 'टेस्ट ट्यूब रैक',
    'lbl_seeds': 'मूंग के बीज',
    'lbl_bowl': 'पानी का कटोरा',
    'lbl_cotton': 'कपास',
    'lbl_dropper': 'ड्रॉपर',
    'lbl_flask': 'शंक्वाकार फ्लास्क',
    'lbl_cork': 'रबर कॉर्क',
    'lbl_pipe': 'रबर पाइप',
    'lbl_limeA': 'चूने का पानी A',
    'lbl_limeB': 'चूने का पानी B',
    'lbl_setupA': 'सेटअप A',
    'lbl_setupB': 'सेटअप B',
    'lbl_soaked': 'भीगे हुए बीज',
    'lbl_a': 'A',
    'lbl_b': 'B',
    'try_again': 'वहाँ नहीं!',
    'timelapse': 'टाइम-लैप्स',
    'hours': 'घंटे',
    's1_res_title': 'प्रकाश संश्लेषण परिणाम',
    's1_p1': 'माचिस की तेज लौ ऑक्सीजन की उपस्थिति की पुष्टि करती है।',
    's1_p2': 'गैस के बुलबुले केवल उस पौधे द्वारा उत्पादित किए गए थे जो सूरज की रोशनी (सेटअप A) के संपर्क में था।',
    's1_p3': 'डार्क बॉक्स (सेटअप B) में छिपे हुए पौधे ने प्रकाश संश्लेषण नहीं किया और कोई गैस नहीं बनाई।',
    's1_conc': 'निष्कर्ष: पौधे प्रकाश संश्लेषण के उपोत्पाद के रूप में ऑक्सीजन छोड़ते हैं, जिसके लिए प्रकाश की आवश्यकता होती है।',
    's2_res_title': 'श्वसन परिणाम',
    's2_p1': 'चूने का पानी दूधिया सफेद हो जाना कार्बन डाइऑक्साइड की पुष्टि करता है।',
    's2_p2': 'सील किए गए फ्लास्क में अंकुरित बीजों ने सक्रिय रूप से श्वसन किया, जिससे ऊर्जा पैदा हुई।',
    's2_p3':
        'इस प्रक्रिया ने CO₂ को बाहर निकाल दिया, जो पाइप के माध्यम से यात्रा करता था और ट्यूब B में चूने के पानी के साथ प्रतिक्रिया करता था।',
    's2_conc': 'निष्कर्ष: जीवित अंकुरित बीज सक्रिय रूप से श्वसन करते हैं, ऑक्सीजन का सेवन करते हैं और कार्बन डाइऑक्साइड छोड़ते हैं।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually demonstrate that plants actively release oxygen gas as a byproduct during photosynthesis, and that this process absolutely requires light.',
      steps: [
        LabStep(
          concept: 'Place Plant',
          action: 'DRAG the Hydrilla plant and DROP it into the large glass beaker.',
          observation:
              'Hydrilla is a submerged aquatic plant. Keeping it completely underwater allows us to visibly capture any exhaust gases as physical bubbles.',
        ),
        LabStep(
          concept: 'Add Funnel',
          action: 'DRAG the glass funnel and DROP it over the Hydrilla plant.',
          observation:
              'The funnel acts as a collection canopy. It channels all the tiny bubbles released by the many leaves into a single, concentrated stream at the narrow stem.',
        ),
        LabStep(
          concept: 'Add Test Tube',
          action: 'DRAG the water-filled test tube and DROP it inverted over the funnel.',
          observation:
              "This uses the 'downward displacement of water' method. As gas rises into the tube, it will push the water down, trapping the pure gas perfectly.",
        ),
        LabStep(
          concept: 'Duplicate Setup',
          action: "CLICK the 'Duplicate Setup' button to create a second beaker setup.",
          observation:
              "In a scientific experiment, we need a 'control' to compare against. Identical setups ensure only our chosen variable (light) causes any differences.",
        ),
        LabStep(
          concept: 'Contrasting Light',
          action: "DRAG setup 'A' to the Sunny zone. DRAG setup 'B' to the Dark Box zone.",
          observation:
              'Light is our variable. By actively depriving one plant of light (Setup B), we can prove if light is the strict trigger for the gas-producing reaction.',
        ),
        LabStep(
          concept: 'Time Lapse',
          action: "CLICK the 'Fast Forward' button to simulate several hours of time passing.",
          observation:
              'Photosynthesis is gradual. Over hours, light energy splits water, releasing Oxygen gas bubbles in Setup A. Setup B shows no activity.',
        ),
        LabStep(
          concept: 'Test Gas A',
          action: 'DRAG tube A to the rack. Then DRAG the matchstick to its mouth.',
          observation:
              'Oxygen violently supports combustion. The glowing matchstick flares up brightly, proving the collected gas is pure, highly concentrated Oxygen.',
        ),
        LabStep(
          concept: 'Test Control B',
          action: 'DRAG tube B to the rack. Then DRAG the matchstick to its mouth.',
          observation:
              'Without light, the dark plant did not photosynthesize or produce gas. The matchstick shows no reaction, confirming light is the necessary catalyst.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visually demonstrate that germinating seeds are living organisms that respire, consuming oxygen and releasing carbon dioxide gas.',
      steps: [
        LabStep(
          concept: 'Soak Seeds',
          action: 'DRAG the beaker of dry moong seeds and DROP it into the water bowl.',
          observation:
              "Dry seeds are dormant. Soaking them triggers rapid cellular respiration, 'waking them up' as they prepare the energy needed to sprout.",
        ),
        LabStep(
          concept: 'Moist Cotton',
          action: 'DRAG cotton to the flask. DRAG the dropper to moisten it.',
          observation:
              'Germinating seeds require continuous moisture. The damp cotton provides a humid environment without drowning them in standing water.',
        ),
        LabStep(
          concept: 'Add Seeds',
          action: 'DRAG the soaked seeds from the bowl into the flask.',
          observation:
              'The conical flask serves as a closed respiration chamber, allowing us to safely trap and measure the exhaust gases produced by the living seeds.',
        ),
        LabStep(
          concept: 'Seal Flask',
          action: 'DRAG the rubber cork to seal the mouth of the flask.',
          observation:
              'An airtight seal is critical. It ensures that the Carbon Dioxide produced by the seeds cannot simply escape and disperse into the room.',
        ),
        LabStep(
          concept: 'Indicator Tubes',
          action: 'DRAG the lime water tubes to the test tube rack.',
          observation:
              "Lime water (Calcium Hydroxide) is a specific chemical indicator. It visibly reacts with Carbon Dioxide, allowing us to 'see' the invisible gas.",
        ),
        LabStep(
          concept: 'Connect Pipe',
          action: 'DRAG the rubber pipe to connect the flask to test tube B.',
          observation:
              'The pipe acts as a direct exhaust line. It forces the trapped gas from the respiring seeds to bubble violently through the chemical indicator.',
        ),
        LabStep(
          concept: 'Respiration Result',
          action: "CLICK the 'Fast Forward' button to simulate 24 hours.",
          observation:
              'Seeds consume oxygen and exhale Carbon Dioxide. This CO2 reacts with the clear lime water, turning it into a milky white precipitate (Calcium Carbonate).',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'यह प्रदर्शित करने के लिए कि पौधे प्रकाश संश्लेषण के दौरान ऑक्सीजन गैस छोड़ते हैं, और इस प्रक्रिया के लिए प्रकाश की आवश्यकता होती है।',
      steps: [
        LabStep(
          concept: 'पौधा रखें',
          action: 'हाइड्रिला पौधे को खींचें और बड़े कांच के बीकर के केंद्र में छोड़ दें।',
          observation:
              'हाइड्रिला एक जलीय पौधा है। इसे पूरी तरह से पानी के भीतर रखने से हम निकास गैसों को बुलबुले के रूप में पकड़ सकते हैं।',
        ),
        LabStep(
          concept: 'फ़नल जोड़ें',
          action: 'कांच के फ़नल को खींचें और बीकर के अंदर हाइड्रिला पौधे के ऊपर छोड़ दें।',
          observation:
              'फ़नल एक संग्रह छतरी के रूप में कार्य करता है। यह पत्तियों द्वारा छोड़े गए बुलबुले को एक धारा में प्रवाहित करता है।',
        ),
        LabStep(
          concept: 'टेस्ट ट्यूब जोड़ें',
          action: 'पानी से भरी टेस्ट ट्यूब को खींचें और फ़नल के तने के ऊपर उल्टा छोड़ दें।',
          observation:
              "यह 'पानी के नीचे की ओर विस्थापन' पद्धति का उपयोग करता है। जैसे ही गैस ट्यूब में उठती है, वह पानी को नीचे धकेल देगी।",
        ),
        LabStep(
          concept: 'डुप्लिकेट सेटअप',
          action: "एक समान दूसरा बीकर सेटअप बनाने के लिए 'डुप्लिकेट सेटअप' बटन पर क्लिक करें।",
          observation:
              "वैज्ञानिक प्रयोग में, हमें तुलना करने के लिए एक 'नियंत्रण' की आवश्यकता होती है। समान सेटअप सुनिश्चित करते हैं कि केवल प्रकाश ही अंतर पैदा करता है।",
        ),
        LabStep(
          concept: 'विपरीत प्रकाश',
          action: "सेटअप 'A' को सूर्य क्षेत्र में खींचें। सेटअप 'B' को डार्क बॉक्स में खींचें।",
          observation:
              'प्रकाश हमारा चर है। एक पौधे को प्रकाश से वंचित करके, हम यह साबित कर सकते हैं कि प्रकाश गैस पैदा करने वाली प्रतिक्रिया के लिए आवश्यक है।',
        ),
        LabStep(
          concept: 'टाइम लैप्स',
          action: "कई घंटों का अनुकरण करने के लिए 'फास्ट फॉरवर्ड' बटन पर क्लिक करें।",
          observation:
              'प्रकाश ऊर्जा पानी को विभाजित करती है, सेटअप A में ऑक्सीजन बुलबुले छोड़ती है। सेटअप B में कोई गतिविधि नहीं होती है।',
        ),
        LabStep(
          concept: 'गैस A का परीक्षण करें',
          action: 'टेस्ट ट्यूब A को रैक पर खींचें। फिर माचिस को उसके मुंह पर खींचें।',
          observation:
              'ऑक्सीजन दहन का समर्थन करती है। माचिस तेजी से भड़कती है, जिससे साबित होता है कि गैस शुद्ध ऑक्सीजन है।',
        ),
        LabStep(
          concept: 'नियंत्रण B का परीक्षण करें',
          action: 'टेस्ट ट्यूब B को रैक पर खींचें। फिर माचिस को उसके मुंह पर खींचें।',
          observation: 'प्रकाश के बिना, पौधे ने प्रकाश संश्लेषण नहीं किया। माचिस कोई प्रतिक्रिया नहीं दिखाती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह प्रदर्शित करने के लिए कि अंकुरित बीज जीवित जीव हैं जो श्वसन करते हैं, ऑक्सीजन का सेवन करते हैं और कार्बन डाइऑक्साइड छोड़ते हैं।',
      steps: [
        LabStep(
          concept: 'बीज भिगोएँ',
          action: 'सूखे मूंग के बीज के बीकर को खींचें और पानी के कटोरे में छोड़ दें।',
          observation:
              'सूखे बीज निष्क्रिय होते हैं। उन्हें भिगोने से तेजी से श्वसन शुरू हो जाता है, जिससे वे अंकुरित होने के लिए तैयार हो जाते हैं।',
        ),
        LabStep(
          concept: 'नम कपास',
          action: 'कपास को फ्लास्क में खींचें। इसे नम करने के लिए ड्रॉपर का उपयोग करें।',
          observation:
              'अंकुरित बीजों को नमी की आवश्यकता होती है। नम कपास उन्हें पानी में डुबाए बिना एक आर्द्र वातावरण प्रदान करता है।',
        ),
        LabStep(
          concept: 'बीज जोड़ें',
          action: 'भीगे हुए बीजों को कटोरे से फ्लास्क में खींचें।',
          observation:
              'शंक्वाकार फ्लास्क एक बंद श्वसन कक्ष के रूप में कार्य करता है, जिससे हम निकास गैसों को फंसा सकते हैं।',
        ),
        LabStep(
          concept: 'फ्लास्क को सील करें',
          action: 'फ्लास्क के मुंह को सील करने के लिए रबर कॉर्क को खींचें।',
          observation:
              'वायुरोधी सील महत्वपूर्ण है। यह सुनिश्चित करता है कि बीजों द्वारा उत्पादित कार्बन डाइऑक्साइड बच न सके।',
        ),
        LabStep(
          concept: 'संकेतक ट्यूब',
          action: 'चूने के पानी की ट्यूबों को टेस्ट ट्यूब रैक पर खींचें।',
          observation:
              "चूने का पानी एक रासायनिक संकेतक है। यह कार्बन डाइऑक्साइड के साथ प्रतिक्रिया करता है, जिससे हम गैस को 'देख' सकते हैं।",
        ),
        LabStep(
          concept: 'पाइप कनेक्ट करें',
          action: 'फ्लास्क को टेस्ट ट्यूब B से जोड़ने के लिए रबर पाइप खींचें।',
          observation:
              'पाइप एक निकास लाइन के रूप में कार्य करता है। यह गैस को सीधे रासायनिक संकेतक के माध्यम से प्रवाहित करता है।',
        ),
        LabStep(
          concept: 'श्वसन परिणाम',
          action: "24 घंटे का अनुकरण करने के लिए 'फास्ट फॉरवर्ड' बटन पर क्लिक करें।",
          observation:
              'बीज कार्बन डाइऑक्साइड छोड़ते हैं। यह CO2 चूने के पानी के साथ प्रतिक्रिया करता है, जिससे यह दूधिया सफेद हो जाता है।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

/// The HTML `#scene-content` box (900 x 600 px); positions below are the
/// HTML's absolute pixel positions unless noted.
const Size _design = Size(900, 600);

/// Top edge of the lab table (HTML `top-[450px]`).
const double _tableY = 450;

// Scenario 1 layout.
const Rect _beakerZone = Rect.fromLTWH(400, 290, 100, 160);
// Zones are a little narrower than the HTML's 300 px so that the duplicated
// setups start in the gap between them (see report).
const Rect _sunZone = Rect.fromLTWH(90, 50, 260, 400);
const Rect _darkZone = Rect.fromLTWH(550, 50, 260, 400);
const Rect _rack1 = Rect.fromLTWH(370, 350, 160, 100);
const double _beakerW = 78;
const double _beakerH = 118;
const double _beakerX = 450;
const double _gapAX = 404;
const double _gapBX = 496;
const double _sunX = 220;
const double _darkX = 680;
const double _rack1AX = 410;
const double _rack1BX = 490;
const Offset _matchHome = Offset(585, 468);

/// Matchstick angle while its head is held at a tube mouth (head down,
/// stick pointing up and right).
const double _testAngle = -0.85 * math.pi;

// Scenario 2 layout.
const Rect _bowlZone = Rect.fromLTWH(400, 380, 120, 70);
const Rect _flaskRect = Rect.fromLTWH(300, 290, 120, 160);
const Rect _rack2 = Rect.fromLTWH(550, 350, 160, 100);
const double _rack2AX = 590;
const double _rack2BX = 670;
const Rect _pipeArea = Rect.fromLTRB(320, 190, 720, 450);
const Offset _pourCenter = Offset(432, 352);
const double _pourAngle = 2.0;

/// Draggable objects (HTML `.draggable` elements).
enum _Item {
  hydrilla,
  funnel,
  tube,
  setupA,
  setupB,
  tubeA,
  tubeB,
  match,
  seedBeaker,
  cotton,
  dropper,
  bowl,
  cork,
  limeTubes,
  pipe,
}

/// Drop targets (HTML `.dropzone` elements).
enum _Zone { beaker, sun, dark, rack1, tubeARack, tubeBRack, bowl, flask, rack2, pipeArea }

/// A short eased move of an item (snap back, glide into place).
class _Glide {
  const _Glide(this.from, this.to, this.t0, this.dur, this.a0, this.a1);
  final Offset from;
  final Offset to;
  final double t0;
  final double dur;
  final double a0;
  final double a1;

  double k(double t) => Curves.easeOutCubic.transform(((t - t0) / dur).clamp(0.0, 1.0));
  bool done(double t) => t >= t0 + dur;
}

/// Position of one draggable item: translation from its home and rotation.
class _ItemState {
  Offset off = Offset.zero;
  double angle = 0;
  _Glide? glide;

  Offset offAt(double t) {
    final g = glide;
    return g == null ? off : Offset.lerp(g.from, g.to, g.k(t))!;
  }

  double angleAt(double t) {
    final g = glide;
    return g == null ? angle : g.a0 + (g.a1 - g.a0) * g.k(t);
  }

  void glideTo(Offset to, double t, {double? angle, double dur = 0.35}) {
    glide = _Glide(offAt(t), to, t, dur, angleAt(t), angle ?? this.angle);
    off = to;
    if (angle != null) this.angle = angle;
  }

  void reset() {
    off = Offset.zero;
    angle = 0;
    glide = null;
  }
}

/// Mutable scene model read by the painter every frame (HTML `state`).
class _GasScene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  /// A step change is pending (HTML `setTimeout(completeStep)`); nothing
  /// can be dragged meanwhile.
  bool busy = false;

  /// A fast-forward time-lapse is running.
  bool simulating = false;

  // Scenario 1 progress (HTML `s1_prog`).
  bool plantIn = false;
  bool funnelIn = false;
  bool tubeIn = false;
  bool duplicated = false;
  bool aPlaced = false;
  bool bPlaced = false;
  bool simulated = false;
  bool tubeARack = false;
  bool tubeBRack = false;
  bool testA = false;
  bool testB = false;

  /// Which rack tube the matchstick is being held at (`null` = none).
  _Item? matchAt;

  // Scenario 2 progress (HTML `s2_prog`).
  bool seedsSoaking = false;
  bool seedsSoaked = false;
  bool cottonIn = false;
  bool cottonWet = false;
  bool seedsIn = false;
  bool corkIn = false;
  bool tubesIn = false;
  bool pipeConnected = false;
  bool simulated2 = false;

  // Animation start times (scene seconds).
  double dupAt = -99;
  double simAt = -99;
  double flareAt = -99;
  double soakAt = -99;
  double wetAt = -99;
  double milkAt = -99;
  double doneAt = -99;

  _Item? dragging;
  _Zone? hover;
  final Map<_Item, _ItemState> items = {for (final i in _Item.values) i: _ItemState()};

  /// HTML `loadScenario()`: clears both progress objects.
  void resetProgress() {
    busy = false;
    simulating = false;
    plantIn = funnelIn = tubeIn = duplicated = aPlaced = bPlaced = false;
    simulated = tubeARack = tubeBRack = testA = testB = false;
    matchAt = null;
    seedsSoaking = seedsSoaked = cottonIn = cottonWet = seedsIn = false;
    corkIn = tubesIn = pipeConnected = simulated2 = false;
    dupAt = simAt = flareAt = soakAt = wetAt = milkAt = doneAt = -99;
    dragging = null;
    hover = null;
    for (final s in items.values) {
      s.reset();
    }
  }

  /// Ends finished glides.
  void settle() {
    for (final s in items.values) {
      final g = s.glide;
      if (g != null && g.done(time)) s.glide = null;
    }
  }

  bool moving(_Item it) => items[it]!.glide != null;

  Offset offOf(_Item it) => items[it]!.offAt(time);
  double angleOf(_Item it) => items[it]!.angleAt(time);

  /// Fraction of tube A filled with oxygen (HTML 3 s water-level transition).
  double get gasA => simulated ? 0.42 * ((time - simAt) / 3).clamp(0.0, 1.0) : 0;

  /// Wall clock time in hours: 9:00 AM, wound forward by the time-lapse
  /// (several hours in scenario 1, 24 hours in scenario 2).
  double get clockHours {
    final start = scenario == 0 ? simAt : milkAt;
    final on = scenario == 0 ? simulated : simulated2;
    if (!on) return 9;
    final k = Curves.easeInOut.transform(((time - start) / 3.5).clamp(0.0, 1.0));
    return 9 + (scenario == 0 ? 6 : 24) * k;
  }

  /// 0 (clear) .. 1 (milky) lime water in tube B.
  double get milk => simulated2 ? ((time - milkAt) / 3).clamp(0.0, 1.0) : 0;

  /// Objects the current step lets the user drag (HTML rendered `.draggable`s).
  List<_Item> draggables() {
    if (busy) return const [];
    if (scenario == 0) {
      return switch (step) {
        1 => [if (!plantIn) _Item.hydrilla],
        2 => [if (!funnelIn) _Item.funnel],
        3 => [if (!tubeIn) _Item.tube],
        5 => [if (!aPlaced) _Item.setupA, if (!bPlaced) _Item.setupB],
        7 => [if (!tubeARack) _Item.tubeA, _Item.match],
        8 => [if (!tubeBRack) _Item.tubeB, _Item.match],
        _ => const [],
      };
    }
    return switch (step) {
      1 => [if (!seedsSoaking) _Item.seedBeaker],
      2 => [if (!cottonIn) _Item.cotton, if (cottonIn && !cottonWet) _Item.dropper],
      3 => [if (!seedsIn) _Item.bowl],
      4 => [if (!corkIn) _Item.cork],
      5 => [if (!tubesIn) _Item.limeTubes],
      6 => [if (!pipeConnected) _Item.pipe],
      _ => const [],
    };
  }

  static Rect setupRect(double x) => Rect.fromLTRB(x - 44, 300, x + 44, 450);
  static Rect beakerTubeRect(double x) => Rect.fromLTRB(x - 10, 304, x + 10, 377);
  static Rect rackTubeRect(double x) => Rect.fromLTWH(x - 12, 330, 24, 100);

  Rect homeRect(_Item it) => switch (it) {
        _Item.hydrilla => const Rect.fromLTWH(150, 250, 60, 120),
        _Item.funnel => const Rect.fromLTWH(150, 260, 80, 100),
        _Item.tube => const Rect.fromLTWH(170, 250, 40, 120),
        _Item.setupA => setupRect(aPlaced ? _sunX : _gapAX),
        _Item.setupB => setupRect(bPlaced ? _darkX : _gapBX),
        _Item.tubeA => beakerTubeRect(_sunX),
        _Item.tubeB => beakerTubeRect(_darkX),
        _Item.match => Rect.fromLTRB(_matchHome.dx - 14, _matchHome.dy - 22, _matchHome.dx + 14, _matchHome.dy + 54),
        _Item.seedBeaker => const Rect.fromLTWH(262, 362, 56, 86),
        _Item.cotton => const Rect.fromLTWH(150, 404, 80, 44),
        _Item.dropper => const Rect.fromLTWH(160, 312, 40, 100),
        _Item.bowl => _bowlZone,
        _Item.cork => const Rect.fromLTWH(500, 422, 40, 27),
        _Item.limeTubes => const Rect.fromLTWH(560, 170, 100, 120),
        _Item.pipe => const Rect.fromLTWH(140, 215, 100, 50),
      };

  Rect rectOf(_Item it) => homeRect(it).shift(offOf(it));

  /// Generous touch area of an item.
  Rect hitRect(_Item it) {
    final r = rectOf(it);
    if (it == _Item.tubeA || it == _Item.tubeB) return r.inflate(14);
    return r.inflate(8);
  }

  /// Point tested against the drop zones: the matchstick's head, otherwise
  /// the item's centre.
  Offset dropPoint(_Item it) => it == _Item.match ? _matchHome + offOf(it) : rectOf(it).center;

  /// The zone an item must be dropped on now (HTML `handleOrganicDrop`).
  _Zone? targetZone(_Item it) => switch (it) {
        _Item.hydrilla || _Item.funnel || _Item.tube => _Zone.beaker,
        _Item.setupA => _Zone.sun,
        _Item.setupB => _Zone.dark,
        _Item.tubeA || _Item.tubeB => _Zone.rack1,
        _Item.match => step == 7
            ? (tubeARack ? _Zone.tubeARack : null)
            : (tubeBRack ? _Zone.tubeBRack : null),
        _Item.seedBeaker => _Zone.bowl,
        _Item.bowl || _Item.cotton || _Item.dropper || _Item.cork => _Zone.flask,
        _Item.limeTubes => _Zone.rack2,
        _Item.pipe => _Zone.pipeArea,
      };

  Rect zoneRect(_Zone z) => switch (z) {
        _Zone.beaker => _beakerZone,
        _Zone.sun => _sunZone,
        _Zone.dark => _darkZone,
        _Zone.rack1 => _rack1,
        _Zone.tubeARack => rackTubeRect(_rack1AX),
        _Zone.tubeBRack => rackTubeRect(_rack1BX),
        _Zone.bowl => _bowlZone,
        _Zone.flask => _flaskRect,
        _Zone.rack2 => _rack2,
        _Zone.pipeArea => _pipeArea,
      };

  /// The HTML overlap test, simplified: the item's drop point lies inside
  /// the zone grown by the HTML's 20 px padding.
  bool isOver(_Item it, _Zone z) {
    final pad = z == _Zone.tubeARack || z == _Zone.tubeBRack ? 26.0 : 20.0;
    return zoneRect(z).inflate(pad).contains(dropPoint(it));
  }
}

/// Picks up items only where the scene has a draggable object, so canvas
/// panning (when unlocked) still works elsewhere.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

/// One canvas-confetti particle (same physics as `confetti.browser.js`).
class _Confetto {
  _Confetto({
    required this.originY,
    required this.velocity,
    required this.angle2D,
    required this.wobble,
    required this.wobbleSpeed,
    required this.tiltAngle,
    required this.color,
    required this.circle,
  });

  final double originY;
  final Color color;
  final bool circle;
  double x = 0;
  double y = 0;
  double velocity;
  double angle2D;
  double wobble;
  double wobbleSpeed;
  double tiltAngle;
  double wobbleX = 0;
  double wobbleY = 0;
  double tiltSin = 0;
  double tiltCos = 0;
  double random = 2;
  int tick = 0;

  static const int totalTicks = 200;
}

/// Native stand-in for `confetti({...})`: a burst of painted paper bits
/// stepped at 60 ticks per second. Positions are px at an 800 px tall
/// viewport and scaled to the canvas by the painter.
class _Confetti {
  final List<_Confetto> parts = [];
  final math.Random _rng = math.Random();
  double _acc = 0;

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
    const startVelocity = 45.0;
    final rad = spread * math.pi / 180;
    for (var i = 0; i < count; i++) {
      parts.add(_Confetto(
        originY: originY,
        velocity: startVelocity * 0.5 + _rng.nextDouble() * startVelocity,
        angle2D: -math.pi / 2 + (0.5 * rad - _rng.nextDouble() * rad),
        wobble: _rng.nextDouble() * 10,
        wobbleSpeed: math.min(0.11, _rng.nextDouble() * 0.1 + 0.05),
        tiltAngle: (_rng.nextDouble() * 0.5 + 0.25) * math.pi,
        color: _colors[i % _colors.length],
        circle: _rng.nextBool(),
      ));
    }
  }

  void update(double dt) {
    if (parts.isEmpty) {
      _acc = 0;
      return;
    }
    _acc += dt;
    while (_acc >= 1 / 60 && parts.isNotEmpty) {
      _acc -= 1 / 60;
      for (final p in parts) {
        p.x += math.cos(p.angle2D) * p.velocity;
        p.y += math.sin(p.angle2D) * p.velocity + 3; // gravity 1 (x3)
        p.velocity *= 0.9; // decay
        p.wobble += p.wobbleSpeed;
        p.wobbleX = p.x + 10 * math.cos(p.wobble);
        p.wobbleY = p.y + 10 * math.sin(p.wobble);
        p.tiltAngle += 0.1;
        p.tiltSin = math.sin(p.tiltAngle);
        p.tiltCos = math.cos(p.tiltAngle);
        p.random = _rng.nextDouble() + 2;
        p.tick++;
      }
      parts.removeWhere((p) => p.tick >= _Confetto.totalTicks);
    }
  }

  void clear() {
    parts.clear();
    _acc = 0;
  }
}

class _Ch10A4GasExchangeAndOxygenReleaseInPlantsPageState
    extends State<Ch10A4GasExchangeAndOxygenReleaseInPlantsPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _GasScene _scene = _GasScene();
  final _Confetti _confetti = _Confetti();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;

  Offset _dragStartOff = Offset.zero;
  Offset _dragStartPointer = Offset.zero;

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

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _scene.time).clamp(0.0, 0.1);
    _scene.time = t;
    _scene.settle();
    _confetti.update(dt);
    _frame.value = t;
  }

  // ------------------------------------------------------------ logic

  /// HTML `loadScenario()`: cancels timers and rebuilds the scene.
  void _buildScenario() {
    _lab.cancelPending();
    _scene.resetProgress();
    _confetti.clear();
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

  /// HTML `completeStep(next)` (next is 1-based here).
  void _completeStep(int next) {
    setState(() {
      _scene
        ..step = next
        ..busy = false
        ..simulating = false;
    });
    if (next > _data.steps.length) _finish();
  }

  /// HTML `setTimeout(() => completeStep(next), ms)`.
  void _completeAfter(int ms, int next, {VoidCallback? before}) {
    _scene.busy = true;
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      before?.call();
      _completeStep(next);
    });
  }

  /// HTML `updateHUD(a, b)` feedback pill.
  void _feedback(String a, [String? b]) {
    _lab.showToast(b == null ? _t(a) : '${_t(a)} ${_t(b)}', sound: false);
  }

  /// End of scenario: conclusion popup and confetti after 1 s (HTML
  /// `showObservation(...)` + `confetti(...)`).
  void _finish() {
    final sc = _scene.scenario;
    _scene.doneAt = _scene.time;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 1000),
      title: () => _t('sci_obs'),
      heading: () => _t(sc == 0 ? 's1_res_title' : 's2_res_title'),
      body: () => _t(sc == 0 ? 's1_p1' : 's2_p1'),
      extra: () => _conclusionExtra(sc),
    );
    _lab.after(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (sc == 0) {
        _confetti.burst(count: 100, spread: 70, originY: 0.6);
      } else {
        _confetti.burst(count: 150, spread: 90);
      }
    });
  }

  /// HTML `duplicateS1()`.
  void _duplicate() {
    final sc = _scene;
    if (sc.step != 4 || sc.duplicated) return;
    setState(() {
      sc.duplicated = true;
      sc.dupAt = sc.time;
      // Both copies slide out of the original beaker's spot.
      sc.items[_Item.setupA]!
        ..off = const Offset(_beakerX - _gapAX, 0)
        ..glideTo(Offset.zero, sc.time, dur: 0.55);
      sc.items[_Item.setupB]!
        ..off = const Offset(_beakerX - _gapBX, 0)
        ..glideTo(Offset.zero, sc.time, dur: 0.55);
    });
    _feedback('h_duplicate', 'h_dragZones');
    _completeStep(5);
  }

  /// HTML `triggerSim1()`.
  void _simulate1() {
    final sc = _scene;
    if (sc.simulated) return;
    setState(() {
      sc
        ..simulated = true
        ..simulating = true
        ..simAt = sc.time;
    });
    _feedback('h_simulating', 'h_bubbles');
    _lab.after(const Duration(milliseconds: 300), () => _Audio.play(_Sound.bubble, volume: 0.5));
    _completeAfter(4000, 7);
  }

  /// HTML `triggerSim2()`.
  void _simulate2() {
    final sc = _scene;
    if (sc.simulated2) return;
    setState(() {
      sc
        ..simulated2 = true
        ..simulating = true
        ..milkAt = sc.time;
    });
    _feedback('h_respiring', 'h_milky');
    _lab.after(const Duration(milliseconds: 300), () => _Audio.play(_Sound.bubble, volume: 0.5));
    _completeAfter(4000, 8);
  }

  /// Instruction shown after a wrong drop (the HUD text of the step).
  String? _hintKey() {
    final sc = _scene;
    if (sc.scenario == 0) {
      return const {
        1: 'h_dragPlant',
        2: 'h_dragFunnel',
        3: 'h_dragTube',
        5: 'h_dragZones',
        7: 'h_testA',
        8: 'h_testB',
      }[sc.step];
    }
    return const {
      1: 'h_dragSeeds',
      2: 'h_dragCotton',
      3: 'h_addWetSeeds',
      4: 'h_dragCork',
      5: 'h_dragTubes',
      6: 'h_dragPipe',
    }[sc.step];
  }

  // ------------------------------------------------------- interaction

  _Item? _hitItem(Offset p) {
    for (final it in _scene.draggables().reversed) {
      if (_scene.hitRect(it).contains(p)) return it;
    }
    return null;
  }

  /// HTML `pointerdown` on a `.draggable`.
  bool _grab(Offset p) {
    final sc = _scene;
    if (!_lab.isLabActive || sc.dragging != null) return false;
    final it = _hitItem(p);
    if (it == null) return false;
    final st = sc.items[it]!;
    st
      ..off = st.offAt(sc.time)
      ..glide = null;
    _dragStartOff = st.off;
    _dragStartPointer = p;
    _Audio.play(_Sound.pickup, volume: 0.4);
    setState(() => sc.dragging = it);
    return true;
  }

  /// HTML `pointermove`: moves the item and highlights the zone below it.
  void _dragTo(Offset p) {
    final sc = _scene;
    final it = sc.dragging;
    if (it == null) return;
    final home = sc.homeRect(it);
    var off = _dragStartOff + (p - _dragStartPointer);
    final c = home.center + off;
    off += Offset(
      c.dx.clamp(10.0, _design.width - 10) - c.dx,
      c.dy.clamp(10.0, _design.height - 10) - c.dy,
    );
    sc.items[it]!.off = off;
    final target = sc.targetZone(it);
    final hover = target != null && sc.isOver(it, target) ? target : null;
    if (hover != sc.hover) setState(() => sc.hover = hover);
  }

  /// HTML `pointerup`: drop on the right zone or snap back.
  void _release() {
    final sc = _scene;
    final it = sc.dragging;
    if (it == null) return;
    final moved = (sc.items[it]!.off - _dragStartOff).distance;
    final target = sc.targetZone(it);
    final ok = target != null && sc.isOver(it, target);
    setState(() {
      sc
        ..dragging = null
        ..hover = null;
    });
    if (ok) {
      _onDrop(it);
    } else {
      setState(() => sc.items[it]!.glideTo(Offset.zero, sc.time));
      if (moved > 12) {
        final hint = _hintKey();
        _lab.showToast(hint == null ? _t('try_again') : '${_t('try_again')} ${_t(hint)}', isError: true);
      }
    }
  }

  /// HTML `handleOrganicDrop(dragId, dropId)` success branches.
  void _onDrop(_Item it) {
    final sc = _scene;
    final st = sc.items[it]!;
    final t = sc.time;
    switch (it) {
      case _Item.hydrilla:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.plantIn = true;
          st.reset();
        });
        _feedback('h_plantIn', 'h_dragFunnel');
        _completeAfter(1000, 2);
      case _Item.funnel:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.funnelIn = true;
          st.reset();
        });
        _feedback('h_funnelIn', 'h_dragTube');
        _completeAfter(1000, 3);
      case _Item.tube:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.tubeIn = true;
          st.reset();
        });
        _feedback('h_tubeIn');
        _completeAfter(1000, 4);
      case _Item.setupA:
      case _Item.setupB:
        _Audio.play(_Sound.drop);
        final dropC = sc.rectOf(it).center;
        setState(() {
          if (it == _Item.setupA) {
            sc.aPlaced = true;
          } else {
            sc.bPlaced = true;
          }
          // Glide from where it was dropped to the centre of its zone.
          st
            ..glide = null
            ..off = dropC - sc.homeRect(it).center
            ..glideTo(Offset.zero, t, dur: 0.4);
        });
        if (sc.aPlaced && sc.bPlaced) {
          _feedback('h_zonesIn');
          _completeAfter(1000, 6);
        }
      case _Item.tubeA:
      case _Item.tubeB:
        _Audio.play(_Sound.drop);
        setState(() {
          if (it == _Item.tubeA) {
            sc.tubeARack = true;
          } else {
            sc.tubeBRack = true;
          }
          st.reset();
        });
      case _Item.match:
        final atA = sc.step == 7;
        final mouth = Offset(atA ? _rack1AX : _rack1BX, 338);
        setState(() {
          sc.matchAt = atA ? _Item.tubeA : _Item.tubeB;
          st.glideTo(mouth - _matchHome, t, angle: _testAngle, dur: 0.3);
          if (atA) {
            sc
              ..testA = true
              ..flareAt = t + 0.25;
          } else {
            sc.testB = true;
          }
        });
        void putBack() {
          sc.matchAt = null;
          st.glideTo(Offset.zero, sc.time, angle: 0, dur: 0.45);
        }
        if (atA) {
          _lab.after(const Duration(milliseconds: 250), () => _Audio.play(_Sound.fire));
          _feedback('h_flare', 'h_testB');
          _completeAfter(2000, 8, before: putBack);
        } else {
          _Audio.play(_Sound.drop);
          _feedback('h_noFlare', 'h_conc');
          _completeAfter(2000, 9, before: putBack);
        }
      case _Item.seedBeaker:
        _Audio.play(_Sound.splash);
        final dropC = sc.rectOf(it).center;
        setState(() {
          sc
            ..seedsSoaking = true
            ..soakAt = t;
          // Tip the beaker over the bowl and pour the seeds in.
          st
            ..glide = null
            ..off = dropC - sc.homeRect(it).center
            ..glideTo(_pourCenter - sc.homeRect(it).center, t, angle: _pourAngle, dur: 0.3);
        });
        _feedback('h_seedsSoaking');
        _scene.busy = true;
        _lab.after(const Duration(milliseconds: 1600), () {
          if (mounted) setState(() => st.glideTo(Offset.zero, _scene.time, angle: 0, dur: 0.45));
        });
        _lab.after(const Duration(milliseconds: 2000), () {
          if (!mounted) return;
          setState(() => sc.seedsSoaked = true);
          _feedback('h_dragCotton');
          _completeAfter(1000, 2);
        });
      case _Item.cotton:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.cottonIn = true;
          st.reset();
        });
      case _Item.dropper:
        _Audio.play(_Sound.drop);
        setState(() {
          sc
            ..cottonWet = true
            ..wetAt = t;
          st.reset();
        });
        _feedback('h_cottonWet', 'h_addWetSeeds');
        _completeAfter(1000, 3);
      case _Item.bowl:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.seedsIn = true;
          st.glideTo(Offset.zero, t, dur: 0.4);
        });
        _feedback('h_seedsIn', 'h_dragCork');
        _completeAfter(1000, 4);
      case _Item.cork:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.corkIn = true;
          st.reset();
        });
        _feedback('h_corkIn', 'h_dragTubes');
        _completeAfter(1000, 5);
      case _Item.limeTubes:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.tubesIn = true;
          st.reset();
        });
        _feedback('h_tubesIn', 'h_dragPipe');
        _completeAfter(1000, 6);
      case _Item.pipe:
        _Audio.play(_Sound.drop);
        setState(() {
          sc.pipeConnected = true;
          st.reset();
        });
        _feedback('h_pipeConnected');
        _completeAfter(1000, 7);
    }
  }

  /// HTML `refreshHUD()` action buttons.
  List<LabAction> _actions() {
    final sc = _scene;
    if (sc.scenario == 0 && sc.step == 4 && sc.tubeIn) {
      return [
        LabAction(
          label: _t('btn_dup'),
          icon: Icons.copy_rounded,
          highlight: true,
          sound: _Sound.magic,
          onTap: _duplicate,
        ),
      ];
    }
    if (sc.scenario == 0 && sc.step == 6 && sc.aPlaced && sc.bPlaced) {
      return [
        LabAction(
          label: _t('btn_ff'),
          icon: Icons.fast_forward_rounded,
          highlight: !sc.simulated,
          enabled: !sc.simulated,
          onTap: _simulate1,
        ),
      ];
    }
    if (sc.scenario == 1 && sc.step == 7 && sc.pipeConnected) {
      return [
        LabAction(
          label: _t('btn_ff24'),
          icon: Icons.fast_forward_rounded,
          highlight: !sc.simulated2,
          enabled: !sc.simulated2,
          onTap: _simulate2,
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
        final sc = _scene;
        final complete = sc.step > data.steps.length;
        return LabShell(
          controller: _lab,
          icon: Icons.eco_rounded,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: complete ? _t('h_conc') : null,
          actions: _actions(),
          sidebarExtraTitle: _t('exp_out'),
          sidebarExtra: _outcomeCard(p, s, data),
          onReset: _fullReset,
          overlays: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ConfettiPainter(_confetti, repaint: _frame)),
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
              },
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  repaint: _frame,
                  isDark: _lab.isDark,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  tr: _t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The HTML accordion's "Detailed Concept & Outcome" for the current step.
  Widget _outcomeCard(LabPalette p, double s, LabScenarioData data) {
    final i = (_scene.step - 1).clamp(0, data.steps.length - 1);
    final step = data.steps[i];
    final f = s * _lab.fontScale;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, size: 14 * f, color: p.info),
              SizedBox(width: 6 * s),
              Expanded(
                child: Text(
                  step.concept,
                  style: TextStyle(color: p.info, fontWeight: FontWeight.w800, fontSize: 11.5 * f),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * s),
          Text(
            step.observation,
            style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.45, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// The rest of the HTML conclusion card: explanation box and the green
  /// "Conclusion" banner.
  Widget _conclusionExtra(int scenario) {
    return Builder(
      builder: (context) {
        final s = context.labScale;
        final p = _Theme.of(_lab.isDark);
        final f = s * _lab.fontScale.clamp(0.9, 1.4);
        final pre = scenario == 0 ? 's1' : 's2';
        final green = _lab.isDark ? _Colors.green400 : _Colors.green700;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(12 * s),
              decoration: BoxDecoration(
                color: p.isDark ? _Colors.slate800 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('${pre}_p2'), style: TextStyle(color: p.text, fontSize: 12.5 * f, height: 1.45)),
                  SizedBox(height: 8 * s),
                  Text(_t('${pre}_p3'), style: TextStyle(color: p.text, fontSize: 12.5 * f, height: 1.45)),
                ],
              ),
            ),
            SizedBox(height: 10 * s),
            Container(
              padding: EdgeInsets.all(12 * s),
              decoration: BoxDecoration(
                color: _Colors.green500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _Colors.green500.withValues(alpha: 0.3)),
              ),
              child: Text(
                _t('${pre}_conc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: green, fontWeight: FontWeight.w800, fontSize: 12.5 * f, height: 1.4),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================ PAINTING

/// Pseudo random 0..1 from an integer (stable per bubble / seed).
double _hash(int i) {
  final v = math.sin(i * 127.1 + 311.7) * 43758.5453;
  return v - v.floorToDouble();
}

/// Scene colours that follow the theme (HTML `--wall-color`, `--table-top`,
/// `--glass-stroke`...).
class _Ink {
  _Ink(bool dark)
      : wallTop = dark ? const Color(0xFF0A1120) : const Color(0xFFCDEAFB),
        wall = dark ? _Colors.slate900 : _Colors.sky100,
        tableTop = dark ? _Colors.slate700 : _Colors.amber600,
        tableSide = dark ? _Colors.slate800 : _Colors.amber800,
        glassStroke = dark ? _Colors.slate300 : _Colors.slate700,
        glassFill = dark ? const Color(0x1AFFFFFF) : const Color(0x80FFFFFF),
        panel = dark ? _Colors.slate800 : Colors.white,
        border = dark ? _Colors.slate700 : _Colors.slate300,
        text = dark ? _Colors.slate50 : _Colors.slate900,
        dashed = dark ? _Colors.slate500 : _Colors.slate400,
        pipe = dark ? _Colors.slate500 : _Colors.slate700,
        accent = dark ? _Colors.green500 : _Colors.emerald500;

  final Color wallTop;
  final Color wall;
  final Color tableTop;
  final Color tableSide;
  final Color glassStroke;
  final Color glassFill;
  final Color panel;
  final Color border;
  final Color text;
  final Color dashed;
  final Color pipe;
  final Color accent;
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  })  : ink = _Ink(isDark),
        super(repaint: repaint);

  final _GasScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;
  final _Ink ink;

  double get t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    _background(canvas, size);
    _wallClock(canvas, Offset(450, scene.scenario == 0 ? 104 : 112));
    if (scene.scenario == 0) {
      _paintS1(canvas);
    } else {
      _paintS2(canvas);
    }
    final d = scene.dragging;
    if (d != null) {
      _lift(canvas, scene.rectOf(d));
      _drawItem(canvas, d);
    }
  }

  // ------------------------------------------------------------ backdrop

  /// Wall and the "infinite" table (HTML `--wall-color` / `--table-top`
  /// with a 16 px `--table-side` border).
  void _background(Canvas c, Size size) {
    final b = labBleed(size);
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, _tableY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ink.wallTop, ink.wall],
        ).createShader(const Rect.fromLTRB(0, 0, 900, _tableY)),
    );
    // Faint wall tiles.
    final tile = Paint()
      ..color = (isDark ? Colors.white : _Colors.slate700).withValues(alpha: isDark ? 0.025 : 0.05)
      ..strokeWidth = 1;
    for (var x = -600.0; x <= 1500; x += 75) {
      c.drawLine(Offset(x, b.top), Offset(x, _tableY), tile);
    }
    for (var y = _tableY - 75; y >= b.top; y -= 75) {
      c.drawLine(Offset(b.left, y), Offset(b.right, y), tile);
    }
    // Table.
    c.drawRect(
      Rect.fromLTRB(b.left, _tableY, b.right, b.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [labShade(ink.tableTop, 0.06), labShade(ink.tableTop, -0.12)],
        ).createShader(const Rect.fromLTRB(0, _tableY, 900, 600)),
    );
    c.drawRect(Rect.fromLTRB(b.left, _tableY, b.right, _tableY + 16), Paint()..color = ink.tableSide);
    c.drawRect(
      Rect.fromLTRB(b.left, _tableY + 16, b.right, _tableY + 26),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.22), Colors.black.withValues(alpha: 0)],
        ).createShader(const Rect.fromLTRB(0, _tableY + 16, 900, _tableY + 26)),
    );
    c.drawLine(
      Offset(b.left, _tableY + 0.5),
      Offset(b.right, _tableY + 0.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..strokeWidth = 1,
    );
  }

  /// Wall clock whose hands race during the fast-forward time-lapse, with
  /// a "+N h" caption while it runs.
  void _wallClock(Canvas c, Offset o) {
    final h = scene.clockHours;
    const r = 30.0;
    c.drawCircle(o.translate(0, 4), r + 4, Paint()..color = Colors.black.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    c.drawCircle(o, r + 4, Paint()..color = isDark ? _Colors.slate600 : _Colors.slate700);
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: isDark ? const [_Colors.slate200, _Colors.slate400] : const [Colors.white, _Colors.slate200],
        ).createShader(Rect.fromCircle(center: o, radius: r)),
    );
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final d = Offset(math.sin(a), -math.cos(a));
      c.drawLine(o + d * (r - (i % 3 == 0 ? 7 : 4)), o + d * (r - 1.5), _stroke(_Colors.slate700, i % 3 == 0 ? 2.2 : 1.2));
    }
    void hand(double turns, double len, double w, Color col) {
      final a = turns * 2 * math.pi;
      c.drawLine(o, o + Offset(math.sin(a), -math.cos(a)) * len, _stroke(col, w));
    }

    hand((h % 12) / 12, r * 0.52, 3.2, _Colors.slate800);
    hand(h % 1, r * 0.78, 2.2, _Colors.slate700);
    c.drawCircle(o, 3, Paint()..color = _Colors.red500);
    if (scene.simulating) {
      final add = (h - 9).round();
      labText(
        c,
        '${tr('timelapse')}  +$add ${tr('hours')}',
        o + const Offset(0, r + 20),
        size: 13,
        weight: FontWeight.w800,
        color: ink.text,
        background: ink.panel,
        border: ink.accent,
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      );
    }
  }

  // ------------------------------------------------------------ helpers

  /// Object caption (HTML `.label-text` chip).
  void _label(
    Canvas c,
    String text,
    Offset at, {
    Color? color,
    Color? border,
    double borderWidth = 1,
    Alignment anchor = Alignment.center,
    double size = 13,
  }) {
    if (!showLabels) return;
    labText(
      c,
      text,
      at,
      size: size,
      weight: FontWeight.w800,
      color: color ?? ink.text,
      background: ink.panel,
      border: border ?? ink.border,
      borderWidth: borderWidth,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      anchor: anchor,
    );
  }

  double _textWidth(String text, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width + 14;
  }

  /// HTML `border-4 border-dashed` drop zone, green when an item hovers it
  /// (`.dropzone.dragover`).
  void _zoneOutline(Canvas c, Rect r, double radius, {bool hover = false, Color? color}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(radius));
    if (hover) {
      c.drawRRect(rr, Paint()..color = _Colors.green500.withValues(alpha: 0.2));
      c.drawRRect(
        rr.deflate(3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = _Colors.green500.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      c.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _Colors.green500,
      );
      return;
    }
    labDashedPath(
      c,
      Path()..addRRect(rr),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color ?? ink.dashed,
      dash: 10,
      gap: 7,
    );
  }

  /// Tray card behind small tools (HTML `bg-[var(--bg-panel)] rounded-xl
  /// border p-2`).
  void _card(Canvas c, Rect r) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(12));
    c.drawRRect(
      rr.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.4 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    c.drawRRect(rr, Paint()..color = ink.panel);
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ink.border,
    );
  }

  /// Drop shadow under the item being dragged (`.is-dragging`).
  void _lift(Canvas c, Rect r) {
    c.drawRRect(
      RRect.fromRectAndRadius(r.shift(const Offset(0, 16)).deflate(4), const Radius.circular(14)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = color;

  // ------------------------------------------------------------ plants & glass

  /// Hydrilla sprigs: wavy stems with whorls of small leaves. [h] is the
  /// height of the main stem.
  void _hydrilla(Canvas c, Offset base, double h, {double s = 1, double sway = 1}) {
    final stem = _stroke(_Colors.green700, 2.4 * s);
    final leaf = Paint()..color = _Colors.green500;
    final leafEdge = _stroke(_Colors.green600, 0.8 * s);
    void sprig(Offset from, double len, double lean, double phase) {
      const n = 24;
      final pts = <Offset>[];
      for (var i = 0; i <= n; i++) {
        final f = i / n;
        pts.add(Offset(
          from.dx + lean * f * len * 0.35 + math.sin(f * 5 + phase) * 3.5 * s + math.sin(t * 1.3 + phase) * 2.5 * s * f * f * sway,
          from.dy - f * len,
        ));
      }
      c.drawPath(Path()..addPolygon(pts, false), stem);
      for (var k = 1; k <= 7; k++) {
        final f = k / 7.6;
        final p = pts[(f * n).round()];
        final size = (1 - f * 0.45) * 9 * s;
        for (final side in const [-1.0, 1.0, 0.0]) {
          final a = side == 0 ? 0.25 * math.sin(k + phase) : side * (0.95 + 0.2 * math.sin(k * 1.7 + phase));
          final ls = side == 0 ? size * 0.7 : size;
          c.save();
          c.translate(p.dx, p.dy);
          c.rotate(a);
          final r = Rect.fromCenter(center: Offset(0, -ls / 2), width: ls * 0.38, height: ls);
          c.drawOval(r, leaf);
          c.drawOval(r, leafEdge);
          c.restore();
        }
      }
      c.drawCircle(pts.last, 2.6 * s, leaf);
    }

    sprig(base, h, 0, 0);
    sprig(base + Offset(2 * s, -h * 0.28), h * 0.55, 1, 1.7);
    sprig(base + Offset(-2 * s, -h * 0.42), h * 0.42, -1, 3.1);
  }

  /// Upright glass funnel (HTML `SVGS.funnel`), drawn inside [r].
  void _funnelUpright(Canvas c, Rect r) {
    final cx = r.center.dx;
    final top = r.top + 4;
    final neck = r.top + r.height * 0.55;
    final hw = r.width * 0.44;
    final sw = r.width * 0.065;
    final path = Path()
      ..moveTo(cx - hw, top)
      ..lineTo(cx + hw, top)
      ..lineTo(cx + sw, neck)
      ..lineTo(cx + sw, r.bottom)
      ..lineTo(cx - sw, r.bottom)
      ..lineTo(cx - sw, neck)
      ..close();
    c.drawPath(path, Paint()..color = ink.glassFill);
    c.drawPath(path, _stroke(ink.glassStroke, 2.5));
    c.drawOval(Rect.fromCenter(center: Offset(cx, top), width: hw * 2, height: 8), _stroke(ink.glassStroke, 2.5));
    c.drawLine(
      Offset(cx - hw * 0.6, top + 8),
      Offset(cx - sw * 0.4, neck - 4),
      _stroke(Colors.white.withValues(alpha: 0.35), 2),
    );
  }

  /// Inverted glass funnel over the plant (wide mouth down, stem up).
  void _funnelInverted(Canvas c, double cx, double mouthY, double apexY, double stemTop, double mouthW) {
    const sw = 4.5;
    final hw = mouthW / 2;
    final outline = Path()
      ..moveTo(cx - hw, mouthY)
      ..lineTo(cx - sw, apexY)
      ..lineTo(cx - sw, stemTop)
      ..moveTo(cx + sw, stemTop)
      ..lineTo(cx + sw, apexY)
      ..lineTo(cx + hw, mouthY);
    final fill = Path()
      ..moveTo(cx - hw, mouthY)
      ..lineTo(cx - sw, apexY)
      ..lineTo(cx - sw, stemTop)
      ..lineTo(cx + sw, stemTop)
      ..lineTo(cx + sw, apexY)
      ..lineTo(cx + hw, mouthY)
      ..close();
    c.drawPath(fill, Paint()..color = Colors.white.withValues(alpha: 0.18));
    final edge = _stroke(const Color(0xE6F8FAFC), 2.2);
    c.drawPath(outline, edge);
    c.drawOval(Rect.fromCenter(center: Offset(cx, mouthY), width: mouthW, height: 7), edge);
    c.drawLine(Offset(cx - hw * 0.55, mouthY - 6), Offset(cx - sw - 2, apexY + 4), _stroke(Colors.white.withValues(alpha: 0.4), 1.5));
  }

  /// Water-filled test tube standing upside down (closed end up). [gas] is
  /// the fraction of the tube filled with collected gas.
  void _tubeInverted(Canvas c, Rect r, {double gas = 0, double bubbleAt = -1}) {
    final rad = r.width / 2;
    final path = Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, r.top + rad)
      ..arcToPoint(Offset(r.right, r.top + rad), radius: Radius.circular(rad))
      ..lineTo(r.right, r.bottom);
    final inner = Path()
      ..addPath(path, Offset.zero)
      ..close();
    c.drawPath(inner, Paint()..color = ink.glassFill);
    c.save();
    c.clipPath(inner);
    final gasY = r.top + r.height * gas;
    c.drawRect(
      Rect.fromLTRB(r.left, gasY, r.right, r.bottom),
      Paint()..color = _Colors.blue500.withValues(alpha: 0.6),
    );
    if (gas > 0.005) {
      c.drawRect(Rect.fromLTRB(r.left, r.top, r.right, gasY), Paint()..color = Colors.white.withValues(alpha: 0.12));
      c.drawLine(Offset(r.left, gasY), Offset(r.right, gasY), _stroke(const Color(0xE6DBEAFE), 1.4));
    }
    if (bubbleAt >= 0) {
      // HTML `.animate-bubble` inside the tube.
      for (var i = 0; i < 4; i++) {
        final u = ((t - bubbleAt) / 1.4 + i / 4) % 1.0;
        final y = r.bottom - 4 - (r.bottom - 4 - gasY) * Curves.easeIn.transform(u);
        final x = r.center.dx + math.sin(u * 9 + i) * 2.5;
        c.drawCircle(Offset(x, y), 1.4 + 0.8 * u, Paint()..color = Colors.white.withValues(alpha: 0.9 * (1 - u * 0.6)));
      }
    }
    c.restore();
    c.drawPath(path, _stroke(ink.glassStroke, 2));
    c.drawOval(Rect.fromCenter(center: Offset(r.center.dx, r.bottom), width: r.width + 2, height: 4), _stroke(ink.glassStroke, 1.5));
    c.drawLine(
      Offset(r.left + 4, r.top + rad),
      Offset(r.left + 4, r.bottom - 6),
      _stroke(Colors.white.withValues(alpha: 0.35), 1.6),
    );
  }

  /// Upright test tube (open end up). [fill] is the liquid fraction.
  void _tubeUpright(Canvas c, Rect r, {double fill = 0, Color liquid = const Color(0x993B82F6), Color? gasTint}) {
    final rad = r.width / 2;
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.left, r.bottom - rad)
      ..arcToPoint(Offset(r.right, r.bottom - rad), radius: Radius.circular(rad), clockwise: false)
      ..lineTo(r.right, r.top);
    final inner = Path()
      ..addPath(path, Offset.zero)
      ..close();
    c.drawPath(inner, Paint()..color = ink.glassFill);
    c.save();
    c.clipPath(inner);
    final ly = r.bottom - r.height * fill;
    if (gasTint != null) c.drawRect(Rect.fromLTRB(r.left, r.top, r.right, ly), Paint()..color = gasTint);
    if (fill > 0) {
      c.drawRect(Rect.fromLTRB(r.left, ly, r.right, r.bottom), Paint()..color = liquid);
      c.drawLine(Offset(r.left, ly), Offset(r.right, ly), _stroke(Colors.white.withValues(alpha: 0.5), 1.2));
    }
    c.restore();
    c.drawPath(path, _stroke(ink.glassStroke, 2));
    c.drawOval(Rect.fromCenter(center: Offset(r.center.dx, r.top), width: r.width + 3, height: 5), _stroke(ink.glassStroke, 2));
    c.drawLine(
      Offset(r.left + 4, r.top + 6),
      Offset(r.left + 4, r.bottom - rad - 2),
      _stroke(Colors.white.withValues(alpha: 0.35), 1.6),
    );
  }

  /// Glass beaker with water and the optional Hydrilla / inverted funnel /
  /// inverted test tube (HTML `SVGS.beaker(...)`). [base] is the bottom
  /// centre.
  void _beaker(
    Canvas c,
    Offset base, {
    bool plant = false,
    bool funnel = false,
    bool tube = false,
    double gas = 0,
    double bubbleAt = -1,
  }) {
    const w = _beakerW, h = _beakerH;
    final l = base.dx - w / 2, r = base.dx + w / 2, top = base.dy - h, bot = base.dy;
    labGroundShadow(c, Offset(base.dx, bot + 1), w * 1.15, 10, opacity: 0.28);
    final body = Path()
      ..moveTo(l, top)
      ..lineTo(l, bot - 6)
      ..quadraticBezierTo(l, bot, l + 6, bot)
      ..lineTo(r - 6, bot)
      ..quadraticBezierTo(r, bot, r, bot - 6)
      ..lineTo(r, top);
    c.drawPath(body, Paint()..color = ink.glassFill);
    // Water (HTML rgba(59,130,246,0.5)).
    final wt = top + h * 0.14;
    final water = Rect.fromLTRB(l + 2.5, wt, r - 2.5, bot - 2.5);
    c.drawRRect(
      RRect.fromRectAndCorners(water, bottomLeft: const Radius.circular(4), bottomRight: const Radius.circular(4)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.blue400.withValues(alpha: 0.5), _Colors.blue600.withValues(alpha: 0.6)],
        ).createShader(water),
    );
    c.drawLine(Offset(l + 3, wt), Offset(r - 3, wt), _stroke(const Color(0xCCBFDBFE), 1.5));
    final mouthY = bot - 7, apexY = bot - h * 0.5, stemTop = bot - h * 0.66;
    if (plant) _hydrilla(c, Offset(base.dx, bot - 4), h * 0.45, s: 0.8);
    if (bubbleAt >= 0) _plantBubbles(c, base.dx, bot, apexY, tube ? top - 26 + 73 * gas : wt, bubbleAt);
    if (funnel) _funnelInverted(c, base.dx, mouthY, apexY, stemTop, w * 0.84);
    if (tube) {
      _tubeInverted(
        c,
        _GasScene.beakerTubeRect(base.dx),
        gas: gas,
        bubbleAt: bubbleAt,
      );
    }
    c.drawPath(body, _stroke(ink.glassStroke, 3));
    c.drawLine(Offset(l - 5, top), Offset(r + 5, top), _stroke(ink.glassStroke, 3));
    c.drawPath(
      Path()
        ..moveTo(l, top + 5)
        ..quadraticBezierTo(l - 9, top + 5, l - 5, top + 13),
      _stroke(ink.glassStroke, 2.5),
    );
    c.drawLine(Offset(l + 7, top + 12), Offset(l + 7, bot - 12), _stroke(Colors.white.withValues(alpha: 0.28), 3));
    final g = _stroke(ink.glassStroke.withValues(alpha: 0.6), 1.2);
    for (var i = 1; i <= 3; i++) {
      final y = bot - h * i / 4.5;
      c.drawLine(Offset(r - 16, y), Offset(r - 4, y), g);
    }
  }

  /// Oxygen bubbles leaving the Hydrilla leaves, gathered by the funnel and
  /// rising into the tube (the HTML `.animate-bubble` group, extended).
  void _plantBubbles(Canvas c, double cx, double bot, double apexY, double endY, double startAt) {
    final te = t - startAt;
    const n = 14;
    for (var i = 0; i < n; i++) {
      final period = 1.6 + (i % 4) * 0.25;
      final cycles = te / period - i / n;
      if (cycles < 0) continue;
      final u = cycles % 1.0;
      final start = Offset(cx + (_hash(i * 7 + 1) - 0.5) * 44, bot - 14 - _hash(i * 13 + 5) * 48);
      final y = start.dy + (endY - start.dy) * Curves.easeIn.transform(u);
      final k = ((y - apexY) / (start.dy - apexY)).clamp(0.0, 1.0);
      final x = cx + (start.dx - cx) * k + math.sin(t * 6 + i) * 1.2 * k;
      final a = u < 0.1 ? u / 0.1 : (u > 0.9 ? (1 - u) / 0.1 : 1.0);
      final rr = 1.3 + _hash(i * 3 + 2) * 1.3;
      c.drawCircle(Offset(x, y), rr, Paint()..color = Colors.white.withValues(alpha: 0.8 * a));
    }
  }

  // ------------------------------------------------------------ scenario 1

  void _paintS1(Canvas c) {
    final sc = scene;
    final st = sc.step;
    if (st <= 4) {
      final hover = sc.hover == _Zone.beaker;
      if (st <= 3 || hover) _zoneOutline(c, _beakerZone, 12, hover: hover);
      _beaker(c, const Offset(_beakerX, 448), plant: sc.plantIn, funnel: sc.funnelIn, tube: sc.tubeIn);
      _label(c, tr('lbl_beaker'), Offset(_beakerX, _beakerZone.top - 14));
      if (!sc.plantIn && sc.dragging != _Item.hydrilla) _drawItem(c, _Item.hydrilla);
      if (!sc.funnelIn && st >= 2 && sc.dragging != _Item.funnel) _drawItem(c, _Item.funnel);
      if (!sc.tubeIn && st >= 3 && sc.dragging != _Item.tube) _drawItem(c, _Item.tube);
      return;
    }
    // Zones fade in after "Duplicate Setup".
    final za = ((t - sc.dupAt) / 0.5).clamp(0.0, 1.0);
    if (za < 1) c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: za));
    _sunZoneDraw(c);
    _darkZoneDraw(c);
    if (za < 1) c.restore();

    // Setups (placed ones under the free ones).
    for (final it in const [_Item.setupA, _Item.setupB]) {
      if (sc.dragging != it) _drawItem(c, it);
    }
    _setupLabels(c);

    if (st >= 7) {
      if (sc.hover == _Zone.rack1) _zoneOutline(c, _rack1.inflate(4), 10, hover: true);
      _rack(c, _rack1, const [_rack1AX, 450, _rack1BX], tubes: () {
        if (sc.tubeARack) {
          _tubeUpright(
            c,
            _GasScene.rackTubeRect(_rack1AX),
            fill: 0.55,
            gasTint: Colors.white.withValues(alpha: 0.12),
          );
        }
        if (sc.tubeBRack) _tubeUpright(c, _GasScene.rackTubeRect(_rack1BX), fill: 0.95);
      });
      if (sc.hover == _Zone.tubeARack || sc.hover == _Zone.tubeBRack) {
        _zoneOutline(c, sc.zoneRect(sc.hover!).inflate(7), 10, hover: true);
      }
      _label(c, tr('lbl_rack'), Offset(_rack1.center.dx, _tableY + 26));
      if (sc.tubeARack && sc.matchAt != _Item.tubeA) _label(c, tr('lbl_tubeA'), const Offset(_rack1AX, 314));
      if (sc.tubeBRack && sc.matchAt != _Item.tubeB) _label(c, tr('lbl_tubeB'), const Offset(_rack1BX, 314));
      // Free tubes being carried back to their beaker.
      for (final it in const [_Item.tubeA, _Item.tubeB]) {
        final inRack = it == _Item.tubeA ? sc.tubeARack : sc.tubeBRack;
        if (!inRack && sc.dragging != it && sc.moving(it)) _drawItem(c, it);
      }
      if (sc.dragging != _Item.match) _drawItem(c, _Item.match);
    }
  }

  /// HTML `#zoneSun`: dashed amber zone with the sun and its rays.
  void _sunZoneDraw(Canvas c) {
    final sc = scene;
    final rr = RRect.fromRectAndRadius(_sunZone, const Radius.circular(16));
    c.drawRRect(rr, Paint()..color = _Colors.amber500.withValues(alpha: 0.1));
    c.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Colors.yellow200.withValues(alpha: 0.4), _Colors.yellow200.withValues(alpha: 0)],
        ).createShader(_sunZone),
    );
    final sun = Offset(_sunZone.center.dx, _sunZone.top + 58);
    // Sunlight falling on Setup A.
    if (sc.aPlaced) {
      final strong = sc.simulating ? 1.0 : 0.6;
      final beam = Path()
        ..moveTo(sun.dx - 18, sun.dy + 20)
        ..lineTo(sun.dx + 18, sun.dy + 20)
        ..lineTo(_sunX + 58, 440)
        ..lineTo(_sunX - 58, 440)
        ..close();
      c.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _Colors.yellow400.withValues(alpha: 0.32 * strong),
              _Colors.yellow400.withValues(alpha: 0.04),
            ],
          ).createShader(Rect.fromLTRB(_sunX - 58, sun.dy, _sunX + 58, 440)),
      );
    }
    if (sc.hover == _Zone.sun) {
      _zoneOutline(c, _sunZone, 16, hover: true);
    } else {
      _zoneOutline(c, _sunZone, 16, color: _Colors.amber500.withValues(alpha: 0.6));
    }
    // Sun (HTML `SVGS.sun`, with the unused `.animate-sun-rays` spin).
    labGlow(c, sun, 70, _Colors.yellow400, intensity: 0.55);
    c.save();
    c.translate(sun.dx, sun.dy);
    c.rotate(t * 2 * math.pi / 20);
    final ray = _stroke(_Colors.yellow400, 6);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      c.drawLine(Offset(math.cos(a) * 31, math.sin(a) * 31), Offset(math.cos(a) * 40, math.sin(a) * 40), ray);
    }
    c.restore();
    labSphere(c, sun, 25, _Colors.yellow400, highlight: 0.5, shade: 0.15);
    if (showLabels) {
      labText(
        c,
        tr('lbl_sun'),
        Offset(sun.dx, sun.dy + 62),
        size: 13,
        weight: FontWeight.w800,
        color: _Colors.amber600,
        background: Colors.white.withValues(alpha: 0.6),
        radius: 6,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      );
    }
  }

  /// HTML `#zoneDark`: dashed dark panel with the dark box icon.
  void _darkZoneDraw(Canvas c) {
    final rr = RRect.fromRectAndRadius(_darkZone, const Radius.circular(16));
    c.drawRRect(rr, Paint()..color = isDark ? _Colors.slate950 : _Colors.slate900);
    c.drawRRect(
      rr,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.4),
          radius: 0.9,
          colors: [_Colors.slate800.withValues(alpha: 0.35), Colors.transparent],
        ).createShader(_darkZone),
    );
    if (scene.hover == _Zone.dark) {
      _zoneOutline(c, _darkZone, 16, hover: true);
    } else {
      _zoneOutline(c, _darkZone, 16, color: _Colors.slate600);
    }
    // 3D dark box (HTML `SVGS.darkBox`).
    final cx = _darkZone.center.dx;
    final front = Rect.fromLTWH(cx - 52, 82, 92, 74);
    labBox3D(c, front, 22, _Colors.slate800, angle: -0.7);
    labDashedLine(
      c,
      Offset(front.left + 6, front.top + 8),
      Offset(front.right - 6, front.top + 8),
      _stroke(_Colors.slate600, 1.5),
      dash: 6,
      gap: 4,
    );
    c.drawRect(front.deflate(10), Paint()..color = Colors.black.withValues(alpha: 0.35));
    if (showLabels) {
      labText(
        c,
        tr('lbl_dark'),
        Offset(cx, 182),
        size: 13,
        weight: FontWeight.w800,
        color: _Colors.slate400,
      );
    }
  }

  /// "Setup A (Light)" / "Setup B (Dark)" captions; staggered while the two
  /// setups stand side by side in the gap.
  void _setupLabels(Canvas c) {
    if (!showLabels) return;
    final sc = scene;
    final a = sc.rectOf(_Item.setupA).center.dx;
    final b = sc.rectOf(_Item.setupB).center.dx;
    final ta = tr('lbl_setupA'), tb = tr('lbl_setupB');
    final close = (a - b).abs() < (_textWidth(ta, 12) + _textWidth(tb, 12)) / 2 + 6;
    final ay = sc.rectOf(_Item.setupA).top - 10;
    final by = sc.rectOf(_Item.setupB).top - (close ? 38 : 10);
    _label(c, ta, Offset(a, ay), color: ink.accent, border: ink.accent, borderWidth: 2, size: 12);
    _label(c, tb, Offset(b, by), color: _Colors.red400, border: _Colors.red500, borderWidth: 2, size: 12);
  }

  /// Wooden test tube rack (HTML `SVGS.rack`). [tubes] paints the tubes
  /// between the legs and the front bars so they look inserted.
  void _rack(Canvas c, Rect r, List<double> holes, {VoidCallback? tubes}) {
    labGroundShadow(c, Offset(r.center.dx, r.bottom + 1), r.width * 0.95, 9, opacity: 0.3);
    final leg = Paint()..color = _Colors.amber950;
    c.drawRect(Rect.fromLTWH(r.left + 20, r.top + 20, 10, 80), leg);
    c.drawRect(Rect.fromLTWH(r.left + 130, r.top + 20, 10, 80), leg);
    for (final x in holes) {
      c.drawOval(Rect.fromCenter(center: Offset(x, r.top + 22), width: 22, height: 6), Paint()..color = Colors.black.withValues(alpha: 0.75));
    }
    tubes?.call();
    void bar(double y) {
      final b = Rect.fromLTWH(r.left + 10, y, 140, 10);
      c.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(2)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9A4A16), _Colors.amber900],
          ).createShader(b),
      );
    }

    bar(r.top + 24);
    bar(r.top + 70);
  }

  // ------------------------------------------------------------ scenario 2

  void _paintS2(Canvas c) {
    final sc = scene;
    final st = sc.step;
    if (st == 6 && sc.dragging == _Item.pipe) {
      // Ghost of where the pipe will go.
      labDashedPath(
        c,
        _pipePath(),
        _stroke((sc.hover == _Zone.pipeArea ? _Colors.green500 : ink.dashed).withValues(alpha: 0.8), 3),
        dash: 9,
        gap: 6,
      );
    }
    if (st <= 3) {
      final hover = sc.hover == _Zone.bowl;
      if (st == 1 || hover) _zoneOutline(c, _bowlZone, 35, hover: hover);
      if (sc.dragging != _Item.bowl) _drawItem(c, _Item.bowl);
    }
    if (st >= 2) {
      final hover = sc.hover == _Zone.flask;
      if ((st >= 2 && st <= 4) || hover) _zoneOutline(c, _flaskRect, 12, hover: hover);
      _flask(c, _flaskRect);
      _label(c, tr('lbl_flask'), Offset(_flaskRect.center.dx, _tableY + 26));
    }
    if (sc.pipeConnected) _pipeConnected(c);
    if (st >= 5) {
      final hover = sc.hover == _Zone.rack2;
      if (st == 5 || hover) _zoneOutline(c, _rack2, 10, hover: hover);
      _rack(c, _rack2, const [_rack2AX, 630, _rack2BX], tubes: () {
        if (!sc.tubesIn) return;
        _limeTube(c, _GasScene.rackTubeRect(_rack2AX).inflate(1), 0);
        _limeTube(c, _GasScene.rackTubeRect(_rack2BX).inflate(1), sc.milk);
        if (sc.pipeConnected) _pipeInTube(c);
      });
      _label(c, tr('lbl_rack'), Offset(_rack2.center.dx, _tableY + 54));
      if (sc.tubesIn) {
        _label(c, tr('lbl_a'), Offset(_rack2AX, _tableY + 24));
        _label(c, tr('lbl_b'), Offset(_rack2BX, _tableY + 24));
      }
    }
    if (st == 1 && sc.dragging != _Item.seedBeaker) _drawItem(c, _Item.seedBeaker);
    if (st >= 2 && !sc.cottonIn && sc.dragging != _Item.cotton) _drawItem(c, _Item.cotton);
    if (sc.cottonIn && !sc.cottonWet && sc.dragging != _Item.dropper) _drawItem(c, _Item.dropper);
    if (st == 4 && !sc.corkIn && sc.dragging != _Item.cork) _drawItem(c, _Item.cork);
    if (st == 5 && !sc.tubesIn && sc.dragging != _Item.limeTubes) _drawItem(c, _Item.limeTubes);
    if (st == 6 && !sc.pipeConnected && sc.dragging != _Item.pipe) _drawItem(c, _Item.pipe);
    _pourSeeds(c);
    _drips(c);
    if (st == 8) _co2Badges(c);
  }

  /// Seeds sliding out of the tipped beaker into the bowl.
  void _pourSeeds(Canvas c) {
    final sc = scene;
    if (!sc.seedsSoaking) return;
    final te = t - sc.soakAt;
    if (te < 0.3 || te > 1.6) return;
    final mouth = _pourCenter + Offset(math.sin(_pourAngle) * 43, -math.cos(_pourAngle) * 43);
    for (var i = 0; i < 7; i++) {
      final u = (te - 0.3 - i * 0.1) / 0.45;
      if (u <= 0 || u >= 1) continue;
      final land = _bowlSeedPos(i);
      final p = Offset(
        mouth.dx + (land.dx - mouth.dx) * u,
        mouth.dy + (land.dy - mouth.dy) * Curves.easeIn.transform(u),
      );
      _seed(c, p, 5, 3, u * 4 + i);
    }
  }

  /// Water drops from the dropper onto the cotton.
  void _drips(Canvas c) {
    final te = t - scene.wetAt;
    if (te < 0 || te > 1.1) return;
    for (var i = 0; i < 3; i++) {
      final u = (te - i * 0.2) / 0.5;
      if (u <= 0 || u >= 1) continue;
      final y = 296 + (418 - 296) * Curves.easeIn.transform(u);
      c.drawOval(Rect.fromCenter(center: Offset(360, y), width: 5, height: 7), Paint()..color = _Colors.blue400);
    }
  }

  Offset _bowlSeedPos(int i, [Rect r = _bowlZone]) => Offset(r.left + 34 + i * 9.0, r.top + 47 + (i.isEven ? 0 : 4));

  void _seed(Canvas c, Offset p, double rx, double ry, double angle) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(angle);
    final r = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
    c.drawOval(r, Paint()..color = _Colors.lime600);
    c.drawOval(r, _stroke(_Colors.lime700, 1));
    c.drawOval(Rect.fromCenter(center: Offset(-rx * 0.3, -ry * 0.35), width: rx * 0.8, height: ry * 0.5), Paint()..color = Colors.white.withValues(alpha: 0.3));
    c.restore();
  }

  /// Blue water bowl (HTML `SVGS.bowl(hasWater, hasSeeds)`), in [r].
  void _bowl(Canvas c, Rect r, {required int seeds}) {
    c.save();
    c.translate(r.left, r.top + 11);
    labGroundShadow(c, const Offset(60, 58), 96, 8, opacity: 0.3);
    final body = Path()
      ..moveTo(10, 20)
      ..cubicTo(10, 70, 110, 70, 110, 20)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DB8FB), _Colors.blue400, Color(0xFF3F86E8)],
        ).createShader(const Rect.fromLTWH(10, 20, 100, 38)),
    );
    final water = Path()
      ..moveTo(15, 25)
      ..cubicTo(15, 65, 105, 65, 105, 25)
      ..close();
    c.drawPath(water, Paint()..color = _Colors.blue600.withValues(alpha: 0.5));
    c.drawOval(const Rect.fromLTRB(14, 14, 106, 30), Paint()..color = const Color(0x8093C5FD));
    c.restore();
    for (var i = 0; i < seeds; i++) {
      _seed(c, _bowlSeedPos(i, r), 5.5, 3.6, (i.isEven ? 0.3 : -0.4) + math.sin(t * 2 + i) * 0.05);
    }
    // Soaking bubbles.
    final sc = scene;
    if (sc.seedsSoaking && sc.step <= 2 && seeds > 0) {
      for (var i = 0; i < 5; i++) {
        final u = ((t - sc.soakAt) / 1.3 + i / 5) % 1.0;
        final p = _bowlSeedPos(i + 1, r) + Offset(math.sin(u * 8 + i) * 2, -u * 18);
        c.drawCircle(p, 1.4, Paint()..color = Colors.white.withValues(alpha: 0.7 * (1 - u)));
      }
    }
    c.save();
    c.translate(r.left, r.top + 11);
    c.drawPath(
      Path()
        ..moveTo(10, 20)
        ..cubicTo(10, 70, 110, 70, 110, 20),
      _stroke(_Colors.blue500, 3),
    );
    c.drawOval(const Rect.fromLTRB(10, 10, 110, 30), _stroke(_Colors.blue500, 3));
    c.drawLine(const Offset(22, 32), const Offset(30, 46), _stroke(Colors.white.withValues(alpha: 0.4), 2.5));
    c.restore();
  }

  /// Small glass beaker of dry moong seeds, centred on [center].
  void _seedBeaker(Canvas c, Offset center, double angle) {
    final sc = scene;
    var left = 7;
    if (sc.seedsSoaking) {
      final te = t - sc.soakAt;
      left = (7 - (((te - 0.3) / 0.1).floor() + 1)).clamp(0, 7);
    }
    if (angle.abs() < 0.01) labGroundShadow(c, Offset(center.dx, center.dy + 43), 60, 8, opacity: 0.28);
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    const body = Rect.fromLTRB(-25, -38, 25, 42);
    final rr = RRect.fromRectAndCorners(body, bottomLeft: const Radius.circular(6), bottomRight: const Radius.circular(6));
    c.drawRRect(rr, Paint()..color = ink.glassFill);
    const pos = [
      Offset(-10, 33),
      Offset(5, 36),
      Offset(10, 26),
      Offset(-5, 22),
      Offset(-15, 18),
      Offset(5, 12),
      Offset(-5, 6),
    ];
    for (var i = 0; i < left; i++) {
      _seed(c, pos[i], 5, 3, i * 0.7);
    }
    c.drawRRect(rr, _stroke(ink.glassStroke, 2));
    c.drawOval(const Rect.fromLTRB(-25, -43, 25, -33), _stroke(ink.glassStroke, 2));
    c.drawLine(const Offset(-18, -28), const Offset(-18, 34), _stroke(Colors.white.withValues(alpha: 0.3), 2.5));
    c.restore();
  }

  /// Conical flask with cotton, seeds and cork (HTML `SVGS.flask(...)`).
  void _flask(Canvas c, Rect r) {
    final sc = scene;
    c.save();
    c.translate(r.left, r.top);
    labGroundShadow(c, const Offset(60, 157), 100, 9, opacity: 0.3);
    final glass = Path()
      ..moveTo(45, 20)
      ..lineTo(45, 60)
      ..lineTo(15, 140)
      ..arcToPoint(const Offset(30, 155), radius: const Radius.circular(15), clockwise: false)
      ..lineTo(90, 155)
      ..arcToPoint(const Offset(105, 140), radius: const Radius.circular(15), clockwise: false)
      ..lineTo(75, 60)
      ..lineTo(75, 20);
    final inner = Path()
      ..addPath(glass, Offset.zero)
      ..close();
    c.drawPath(inner, Paint()..color = ink.glassFill);
    if (sc.cottonIn) {
      final wet = sc.cottonWet ? ((t - sc.wetAt - 0.3) / 0.8).clamp(0.0, 1.0) : 0.0;
      final col = Color.lerp(_Colors.slate50, _Colors.slate300, wet)!;
      final shade = Color.lerp(_Colors.slate200, _Colors.slate400, wet)!;
      c.save();
      c.clipPath(inner);
      const puffs = [
        Offset(28, 146),
        Offset(44, 138),
        Offset(60, 135),
        Offset(76, 138),
        Offset(92, 146),
        Offset(36, 150),
        Offset(60, 148),
        Offset(84, 150),
      ];
      for (final p in puffs) {
        c.drawCircle(
          p,
          12,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [col, shade],
            ).createShader(Rect.fromCircle(center: p, radius: 12)),
        );
      }
      c.restore();
    }
    if (sc.seedsIn) {
      const seeds = [Offset(-20, 0), Offset(-10, -5), Offset(0, 5), Offset(10, -2), Offset(25, 2)];
      for (var i = 0; i < seeds.length; i++) {
        final pulse = (i == 1 || i == 3) ? 1 + 0.05 * math.sin(t * math.pi) : 1.0;
        _seed(c, const Offset(60, 128) + seeds[i], 5 * pulse, 3 * pulse, i * 0.6);
      }
    }
    c.drawPath(glass, _stroke(ink.glassStroke, 3));
    c.drawOval(const Rect.fromLTRB(45, 15, 75, 25), _stroke(ink.glassStroke, 3));
    c.drawLine(const Offset(50, 30), const Offset(50, 60), _stroke(Colors.white.withValues(alpha: 0.3), 2.5));
    c.drawLine(const Offset(42, 72), const Offset(24, 128), _stroke(Colors.white.withValues(alpha: 0.25), 3));
    if (sc.corkIn) _corkShape(c, const Rect.fromLTRB(45, 8, 75, 30));
    c.restore();
  }

  /// Rubber cork (trapezoid with two holes) inside [r].
  void _corkShape(Canvas c, Rect r) {
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right - r.width / 6, r.bottom)
      ..lineTo(r.left + r.width / 6, r.bottom)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [_Colors.amber800, _Colors.amber700, Color(0xFFC2620E), _Colors.amber800],
          stops: [0, 0.35, 0.6, 1],
        ).createShader(r),
    );
    c.drawPath(path, _stroke(_Colors.amber900, 2));
    final hy = r.top + r.height * 0.22;
    c.drawOval(Rect.fromCenter(center: Offset(r.left + r.width / 3, hy), width: r.width * 0.2, height: 4), Paint()..color = _Colors.amber950);
    c.drawOval(Rect.fromCenter(center: Offset(r.right - r.width / 3, hy), width: r.width * 0.2, height: 4), Paint()..color = _Colors.amber950);
  }

  /// Fluffy cotton wool (HTML `SVGS.cotton`).
  void _cottonBall(Canvas c, Rect r) {
    labGroundShadow(c, Offset(r.center.dx, r.bottom), r.width * 0.9, 7, opacity: 0.25);
    const puffs = [
      (0.22, 0.62, 0.2),
      (0.42, 0.42, 0.25),
      (0.65, 0.45, 0.24),
      (0.82, 0.66, 0.18),
      (0.52, 0.7, 0.24),
      (0.3, 0.76, 0.18),
    ];
    for (final (fx, fy, fr) in puffs) {
      final p = Offset(r.left + r.width * fx, r.top + r.height * fy);
      final rad = r.width * fr;
      c.drawCircle(
        p,
        rad,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.45),
            colors: [Colors.white, isDark ? _Colors.slate200 : _Colors.slate300],
          ).createShader(Rect.fromCircle(center: p, radius: rad)),
      );
    }
  }

  /// Water dropper tilted by 30° (HTML `SVGS.dropper`), with a drip.
  void _dropper(Canvas c, Rect r) {
    c.save();
    c.translate(r.center.dx, r.center.dy);
    c.rotate(-math.pi / 6);
    c.translate(-20, -50);
    const tube = Rect.fromLTWH(15, 30, 10, 50);
    c.drawRect(tube, Paint()..color = ink.glassFill);
    c.drawRect(const Rect.fromLTWH(16.5, 46, 7, 34), Paint()..color = _Colors.blue400.withValues(alpha: 0.65));
    final tip = Path()
      ..moveTo(15, 80)
      ..lineTo(25, 80)
      ..lineTo(22, 95)
      ..lineTo(18, 95)
      ..close();
    c.drawPath(tip, Paint()..color = _Colors.blue400.withValues(alpha: 0.5));
    c.drawRect(tube, _stroke(ink.glassStroke, 2));
    c.drawPath(tip, _stroke(ink.glassStroke, 2));
    final bulb = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10, 20, 22), const Radius.circular(5));
    c.drawRRect(bulb, Paint()..color = _Colors.blue500);
    labSphere(c, const Offset(20, 10), 10, _Colors.blue500, highlight: 0.35, shade: 0.3);
    c.restore();
    // Drip forming at the tip and falling (HTML `.animate-bounce` drop).
    const a = -math.pi / 6;
    final nozzle = r.center + Offset(-45 * math.sin(a), 45 * math.cos(a));
    final u = (t % 1.2) / 1.2;
    final dy = u < 0.6 ? 0.0 : (u - 0.6) / 0.4 * 26;
    final rad = 1.5 + 1.8 * (u < 0.6 ? u / 0.6 : 1);
    c.drawCircle(nozzle + Offset(0, rad + dy), rad, Paint()..color = _Colors.blue400.withValues(alpha: u < 0.95 ? 1 : 0));
  }

  /// Lime water test tube; [milk] 0 = clear, 1 = milky white.
  void _limeTube(Canvas c, Rect r, double milk) {
    final clear = isDark ? const Color(0x66CBD5E1) : const Color(0x8094A3B8);
    _tubeUpright(c, r, fill: 0.66, liquid: Color.lerp(clear, const Color(0xF2FFFFFF), milk)!);
  }

  /// Pipe path from the cork to the bottom of tube B.
  Path _pipePath() => Path()
    ..moveTo(360, 300)
    ..lineTo(360, 252)
    ..quadraticBezierTo(360, 232, 380, 232)
    ..lineTo(_rack2BX - 20, 232)
    ..quadraticBezierTo(_rack2BX, 232, _rack2BX, 252)
    ..lineTo(_rack2BX, 410);

  /// Connected rubber pipe with the HTML `.animate-co2-flow` dashes.
  void _pipeConnected(Canvas c) {
    final path = _pipePath();
    c.drawPath(path, _stroke(Colors.black.withValues(alpha: 0.25), 9));
    c.drawPath(path, _stroke(ink.pipe, 6));
    labDashedPath(c, path, _stroke(_Colors.slate400, 2), dash: 4, gap: 4, phase: -t * 20);
  }

  /// Part of the pipe inside tube B (drawn over the liquid) and its bubbles.
  void _pipeInTube(Canvas c) {
    final sc = scene;
    final r = _GasScene.rackTubeRect(_rack2BX);
    if (sc.simulated2) {
      for (var i = 0; i < 6; i++) {
        final u = ((t - sc.milkAt) / 0.9 + i / 6) % 1.0;
        final p = Offset(_rack2BX + 4 + math.sin(u * 10 + i) * 3, 404 - u * (404 - (r.bottom - r.height * 0.66)));
        c.drawCircle(p, 1.4 + u * 1.2, Paint()..color = Colors.white.withValues(alpha: 0.6 * (1 - u * 0.5)));
      }
    }
  }

  /// Loose rubber pipe (HTML step 6 `#pipe`), inside [r].
  void _pipeLoose(Canvas c, Rect r) {
    final path = Path()
      ..moveTo(r.left + 10, r.top + 25)
      ..quadraticBezierTo(r.left + 50, r.top - 20, r.left + 90, r.top + 25)
      ..quadraticBezierTo(r.left + 96, r.top + 40, r.left + 84, r.top + 46);
    c.drawPath(path.shift(const Offset(0, 4)), _stroke(Colors.black.withValues(alpha: 0.2), 9));
    c.drawPath(path, _stroke(ink.pipe, 7));
    c.drawPath(path, _stroke(Colors.white.withValues(alpha: 0.18), 1.5));
  }

  /// HTML step 7 badges: no CO₂ in control tube A, CO₂ in tube B.
  void _co2Badges(Canvas c) {
    final k = Curves.easeOutBack.transform(((t - scene.doneAt) / 0.4).clamp(0.0, 1.0));
    if (k <= 0) return;
    void badge(Offset p, Color col, bool crossed) {
      c.save();
      c.translate(p.dx, p.dy);
      c.scale(k);
      c.drawCircle(const Offset(0, 4), 30, Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      c.drawCircle(Offset.zero, 30, Paint()..color = Colors.white);
      c.drawCircle(Offset.zero, 29, _stroke(col, 2.5));
      final co = labText(c, 'CO', const Offset(-4, -1), size: 18, weight: FontWeight.w900, color: col);
      final two = labText(c, '2', Offset(co.right + 0.5, 5), size: 11, weight: FontWeight.w900, color: col, anchor: Alignment.centerLeft);
      if (crossed) c.drawLine(Offset(co.left - 3, 0), Offset(two.right + 3, 0), _stroke(col, 2.5));
      c.restore();
    }

    badge(const Offset(520, 384), _Colors.red500, true);
    badge(const Offset(744, 384), _Colors.green500, false);
  }

  // ------------------------------------------------------------ items

  /// Paints one draggable item at its current position (and its caption).
  void _drawItem(Canvas c, _Item it) {
    final sc = scene;
    final r = sc.rectOf(it);
    switch (it) {
      case _Item.hydrilla:
        _card(c, r);
        _hydrilla(c, Offset(r.center.dx, r.bottom - 10), r.height - 30, s: 0.8, sway: 0.4);
        _label(c, tr('lbl_hydrilla'), Offset(r.center.dx, r.top - 14));
      case _Item.funnel:
        _card(c, r);
        _funnelUpright(c, r.deflate(9));
        _label(c, tr('lbl_funnel'), Offset(r.center.dx, r.top - 14));
      case _Item.tube:
        _card(c, r);
        _tubeInverted(c, Rect.fromCenter(center: r.center, width: 18, height: r.height - 22));
        _label(c, tr('lbl_tube'), Offset(r.center.dx, r.top - 14));
      case _Item.setupA:
      case _Item.setupB:
        final isA = it == _Item.setupA;
        final base = r.bottomCenter - const Offset(0, 2);
        final tubeOut = isA ? (sc.tubeARack || sc.dragging == _Item.tubeA || sc.moving(_Item.tubeA)) : (sc.tubeBRack || sc.dragging == _Item.tubeB || sc.moving(_Item.tubeB));
        final dim = !isA && sc.bPlaced;
        if (dim) {
          c.saveLayer(r.inflate(30), Paint());
        }
        _beaker(
          c,
          base,
          plant: true,
          funnel: true,
          tube: !tubeOut,
          gas: isA ? sc.gasA : 0,
          bubbleAt: isA && sc.simulated && !tubeOut ? sc.simAt : -1,
        );
        if (dim) {
          c.drawRect(r.inflate(30), Paint()..color = const Color(0x59000000)..blendMode = BlendMode.srcATop);
          c.restore();
        }
      case _Item.tubeA:
      case _Item.tubeB:
        _tubeInverted(c, r, gas: it == _Item.tubeA ? sc.gasA : 0);
      case _Item.match:
        final head = _matchHome + sc.offOf(it);
        final angle = sc.angleOf(it);
        var flame = 15.0;
        if (sc.matchAt == _Item.tubeA) flame = _flareHeight(t - sc.flareAt);
        _matchstick(c, head, angle, flame);
        if (sc.matchAt == null && !sc.moving(it)) {
          _label(c, tr('lbl_match'), head + const Offset(16, 22), anchor: Alignment.centerLeft);
        }
      case _Item.seedBeaker:
        _seedBeaker(c, r.center, sc.angleOf(it));
        if (!sc.seedsSoaking) _label(c, tr('lbl_seeds'), Offset(r.center.dx, r.top - 14));
      case _Item.cotton:
        _cottonBall(c, r);
        _label(c, tr('lbl_cotton'), Offset(r.center.dx, r.top - 12));
      case _Item.dropper:
        _dropper(c, r);
        _label(c, tr('lbl_dropper'), Offset(r.center.dx - 8, r.top - 10));
      case _Item.bowl:
        final st = sc.step;
        final seeds = sc.seedsIn || !sc.seedsSoaking ? 0 : (((t - sc.soakAt - 0.75) / 0.1).floor() + 1).clamp(0, 7);
        _bowl(c, r, seeds: seeds);
        if (!(sc.seedsSoaking && st == 1)) {
          _label(c, tr(st == 3 && !sc.seedsIn ? 'lbl_soaked' : 'lbl_bowl'), Offset(r.center.dx, r.top - 12));
        }
      case _Item.cork:
        labGroundShadow(c, Offset(r.center.dx, r.bottom), r.width, 6, opacity: 0.3);
        _corkShape(c, r);
        _label(c, tr('lbl_cork'), Offset(r.center.dx, r.top - 14));
      case _Item.limeTubes:
        _card(c, r);
        _limeTube(c, Rect.fromLTWH(r.left + 16, r.top + 12, 26, r.height - 24), 0);
        _limeTube(c, Rect.fromLTWH(r.right - 42, r.top + 12, 26, r.height - 24), 0);
        _label(c, '${tr('lbl_limeA')} & ${tr('lbl_limeB')}', Offset(r.center.dx, r.top - 14));
      case _Item.pipe:
        _pipeLoose(c, r);
        _label(c, tr('lbl_pipe'), Offset(r.center.dx, r.top - 12));
    }
  }

  /// HTML `@keyframes flare-up` (1.5 s): the flame jumps to 3.5x, holds
  /// at 3x and settles back.
  double _flareHeight(double dt) {
    const base = 15.0, peak = 105.0, hold = 90.0;
    if (dt < 0 || dt >= 1.5) return base;
    final p = dt / 1.5;
    if (p < 0.2) return base + (peak - base) * Curves.easeOut.transform(p / 0.2);
    if (p < 0.8) return peak + (hold - peak) * ((p - 0.2) / 0.6);
    return hold + (base - hold) * Curves.easeIn.transform((p - 0.8) / 0.2);
  }

  /// Lit matchstick (HTML `SVGS.matchstick`); [head] is the match head,
  /// [angle] turns the stick about it, the flame always points up.
  void _matchstick(Canvas c, Offset head, double angle, double flame) {
    if (angle.abs() < 0.01) labGroundShadow(c, head + const Offset(0, 54), 22, 6, opacity: 0.3);
    c.save();
    c.translate(head.dx, head.dy);
    c.rotate(angle);
    final stick = RRect.fromLTRBR(-3, 3, 3, 52, const Radius.circular(1.5));
    c.drawRRect(
      stick,
      Paint()
        ..shader = const LinearGradient(
          colors: [_Colors.amber700, _Colors.amber500, _Colors.amber600],
          stops: [0, 0.45, 1],
        ).createShader(stick.outerRect),
    );
    c.drawOval(Rect.fromCenter(center: const Offset(0, 1), width: 9, height: 12), Paint()..color = _Colors.red900);
    c.restore();
    _flame(c, head.translate(0, -2), flame);
  }

  /// Red / yellow flame (HTML `#flame` paths), flickering.
  void _flame(Canvas c, Offset base, double h) {
    final flick = 1 + 0.07 * math.sin(t * 19) + 0.05 * math.sin(t * 31 + 1.1);
    final hh = h * flick;
    final w = math.min(h, 40.0) * 0.5 + (h > 40 ? (h - 40) * 0.18 : 0);
    final big = ((h - 15) / 90).clamp(0.0, 1.0);
    labGlow(c, base.translate(0, -hh * 0.4), hh * (1.1 + big * 0.2), _Colors.orange500, intensity: 0.45 + big * 0.4);
    if (big > 0.05) labGlow(c, base.translate(0, -hh * 0.3), hh * 0.9, _Colors.yellow200, intensity: big * 0.8);
    Path drop(double sx, double sy) {
      final tip = Offset(base.dx + math.sin(t * 7) * 1.5 * sx, base.dy - hh * sy);
      return Path()
        ..moveTo(tip.dx, tip.dy)
        ..cubicTo(base.dx + w * sx, base.dy - hh * sy * 0.45, base.dx + w * sx * 0.8, base.dy, base.dx, base.dy)
        ..cubicTo(base.dx - w * sx * 0.8, base.dy, base.dx - w * sx, base.dy - hh * sy * 0.45, tip.dx, tip.dy)
        ..close();
    }

    c.drawPath(drop(1, 1), Paint()..color = _Colors.red500);
    c.drawPath(drop(0.62, 0.68), Paint()..color = _Colors.yellow400);
    c.drawPath(drop(0.3, 0.32), Paint()..color = const Color(0xFFFFF7D6));
    if (big > 0.2) {
      // Sparks thrown out by the oxygen flare.
      for (var i = 0; i < 10; i++) {
        final a = -math.pi / 2 + (_hash(i * 5) - 0.5) * 2.2;
        final d = (t * 90 + _hash(i * 11) * 60) % 70;
        final p = base + Offset(math.cos(a), math.sin(a)) * (10 + d);
        c.drawCircle(p, 1.6, Paint()..color = _Colors.yellow200.withValues(alpha: big * (1 - d / 70)));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

/// Paints the confetti bursts over the canvas (canvas-confetti shapes:
/// squares and ovals that wobble, tilt and fade).
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.confetti, {required Listenable repaint}) : super(repaint: repaint);

  final _Confetti confetti;

  @override
  void paint(Canvas canvas, Size size) {
    if (confetti.parts.isEmpty) return;
    final k = (size.height / 800).clamp(0.45, 1.3);
    for (final p in confetti.parts) {
      final o = Offset(size.width * 0.5, size.height * p.originY);
      Offset m(double x, double y) => o + Offset(x * k, y * k);
      final paint = Paint()..color = p.color.withValues(alpha: (1 - p.tick / _Confetto.totalTicks).clamp(0.0, 1.0));
      final x1 = p.x + p.random * p.tiltCos;
      final y1 = p.y + p.random * p.tiltSin;
      final x2 = p.wobbleX + p.random * p.tiltCos;
      final y2 = p.wobbleY + p.random * p.tiltSin;
      if (p.circle) {
        final ctr = m(p.x, p.y);
        canvas.save();
        canvas.translate(ctr.dx, ctr.dy);
        canvas.rotate(math.pi / 10 * p.wobble);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: math.max(1, (x2 - x1).abs() * 0.6 * k * 2),
            height: math.max(1, (y2 - y1).abs() * 0.6 * k * 2),
          ),
          paint,
        );
        canvas.restore();
      } else {
        final a = m(p.x, p.y), b = m(p.wobbleX, y1), cc = m(x2, y2), d = m(x1, p.wobbleY);
        canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy)
            ..lineTo(cc.dx, cc.dy)
            ..lineTo(d.dx, d.dy)
            ..close(),
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
