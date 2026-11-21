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

/// Class 6 Science • Chapter 12 (Beyond Earth) • Activity 2
/// Observing the Night Sky.
///
/// Native Flutter port of `Cl6S-Ch12-A2-Observing_the_Night_Sky.html`.
///
/// Scenario 1 (Finding the North Star): click the seven stars of the Big
/// Dipper, then its two pointer stars, drag the Pointer Distance Tool to 5x
/// to extend the pointer line, and click the Pole Star at its tip.
///
/// Scenario 2 (The Hunter and His Dog): click the three stars of Orion's
/// belt, then Betelgeuse and Rigel, extend the belt line with the Pointer
/// Distance Tool and click Sirius at its tip.
///
/// The HTML Three.js sky (camera at the origin, 60° field of view, stars on
/// a dome about 40 units away) is projected onto a 1000 × 560 design stage.
class Ch12A2ObservingTheNightSkyPage extends StatefulWidget {
  const Ch12A2ObservingTheNightSkyPage({super.key});

  @override
  State<Ch12A2ObservingTheNightSkyPage> createState() =>
      _Ch12A2ObservingTheNightSkyPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three tones with WebAudio:
/// 'click' (a star is clicked, the slider reaches 5x) -> click.mp3, 'pop'
/// (enter lab, scenario change, sidebar, language) -> pop.mp3 and 'success'
/// (Pole Star / Sirius found, conclusion) -> success.mp3. The hint toasts
/// added in this port use error.mp3.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/pop.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/pop.mp3`, curtain → `science/pop.mp3`.
enum _Sound implements LabTone {
  /// A star is clicked; the Pointer Distance Tool reaches 5x (HTML 'click').
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse (HTML 'pop').
  toggle('audio/class6/science/pop.mp3'),

  /// Feedback toast of the shell (e.g. "Scenario Complete").
  correct('audio/class6/science/correct.mp3'),

  /// Hint toast: a star that is not part of the current step was clicked,
  /// or the slider was let go before 5x.
  wrong('audio/class6/science/error.mp3'),

  /// Pole Star / Sirius found, conclusion popup (HTML 'success').
  success('audio/class6/math/success.mp3'),

  /// Scenario changed (HTML 'pop' in changeScenario()).
  scenario('audio/class6/science/pop.mp3'),

  /// Curtain lifted or lowered (HTML 'pop' in enterLab() / resetApp()).
  curtain('audio/class6/science/pop.mp3');

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

/// Tailwind colours used by the HTML (UI, Three.js materials and labels).
abstract final class _Colors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8); // background stars
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color indigo200 = Color(0xFFC7D2FE); // Pole Star / Orion badge
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color yellow200 = Color(0xFFFEF08A); // Big Dipper stars
  static const Color yellow300 = Color(0xFFFDE047); // dipper badge, readout
  static const Color yellow400 = Color(0xFFFACC15); // drag guide line
  static const Color yellow500 = Color(0xFFEAB308); // dipper lines (ZSL)
  static const Color amber500 = Color(0xFFF59E0B); // belt pointer line
  static const Color red300 = Color(0xFFFCA5A5); // Betelgeuse
  static const Color red500 = Color(0xFFEF4444); // pole pointer line
  static const Color blue300 = Color(0xFF93C5FD); // Orion / Canis stars
  static const Color blue400 = Color(0xFF60A5FA); // Pole Star, belt line
  static const Color sky300 = Color(0xFF7DD3FC); // dog outline
  static const Color sky400 = Color(0xFF38BDF8); // pointer stars line
  static const Color cyan300 = Color(0xFF67E8F9); // Canis Major badge
  static const Color emerald400 = Color(0xFF34D399); // "5x" tick
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  /// The night sky (HTML `#canvas-wrapper` bg-[#03071e]).
  static const Color night = Color(0xFF03071E);

  /// Star label chip (`.star-label`: rgba(15, 23, 42, 0.85)).
  static const Color labelBg = Color(0xD90F172A);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// canvas-confetti's default colours.
  static const List<Color> confetti = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The HTML accent is indigo (sidebar headings, Enter Lab,
/// current step); the night sky stays dark in both themes.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary #020617
    panel: _Colors.glassDark, // sidebar dark:bg-slate-900 (glass)
    border: _Colors.borderDark,
    card: Color(0xCC0F172A), // dark:bg-slate-900/80
    cardBorder: _Colors.slate800,
    canvasBg: _Colors.night,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    // indigo-400 instead of indigo-500 so small headings stay readable on
    // the dark panel; dark text on it for the same reason.
    accent: _Colors.indigo400,
    onAccent: _Colors.slate950,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // completed steps (text-emerald-400)
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // text-indigo-300/80
    curtainIcon: _Colors.indigo400,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.indigo400,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.indigo500,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.slate100, // bg-slate-100
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.night,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo600,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600, // completed steps (text-emerald-600)
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.indigo400,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.indigo600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.indigo500,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size (px): HTML default 15 px, slider 12-22 px (the shell allows up
/// to 24 px).
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Changes:
// * Step 1.1 and its HUD line say that all 7 Big Dipper stars must be
//   clicked (the HTML needs 7 clicks but said "click on the ladle").
// * Step 2.2 says where Betelgeuse and Rigel are (they have no label yet);
//   its HUD line names them (the HTML said "the corner stars", but only
//   Betelgeuse and Rigel complete the step).
// * Steps 1.3 / 2.3 and their HUD lines say the slider goes to 5x (the step
//   ends there).
// * The HTML toasts were English only ("Alkaid Discovered (1/7)"); they are
//   translated here, the Hindi ones built around the noun तारा so the verb
//   never has to agree with a star's name.
// * Hindi texts no longer mix in English words (Big Dipper, Dubhe & Merak,
//   Polaris, Hunter).
// * Added: the hint for a slider let go before 5x, the "all steps done"
//   objective, the observation list and the scene descriptions.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Observing the Night Sky',
    'app_subtitle': 'Class 6 • Beyond Earth',
    'scen_1': 'Scenario 1: Finding the North Star',
    'scen_2': 'Scenario 2: The Hunter and His Dog',
    's1_obj':
        "To locate the Big Dipper and use its two 'pointer stars' to find the Pole Star (Polaris) precisely.",
    's2_obj':
        'To identify the constellation Orion and use its belt to locate Sirius, the brightest star in the night sky.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Big Dipper Asterism',
    's1_a1':
        'CLICK each of the 7 stars of the Big Dipper ladle (the stars with pulsing rings) in the northern sky.',
    's1_o1':
        'The 7 stars illuminate clearly to form the recognizable question-mark / spoon pattern.',
    's1_c2': 'Pointer Stars',
    's1_a2': 'CLICK on Dubhe and Merak at the front end of the ladle.',
    's1_o2': "They glow brightly and are labeled 'Pointer Stars'.",
    's1_c3': 'Extending 5x Distance',
    's1_a3': 'DRAG the Pointer Distance Tool slider from 1x up to 5x.',
    's1_o3':
        'A straight dashed pointer line shoots upwards across the dark sky.',
    's1_c4': 'Polaris & Ursa Minor',
    's1_a4': 'CLICK on the star (Polaris) at the exact 5x tip and observe.',
    's1_o4':
        'Ursa Major and Ursa Minor constellation lines light up along with a large North Compass rose!',
    // Scenario 2 steps.
    's2_c1': "Locating Orion's Belt",
    's2_a1': 'CLICK on the three aligned diagonal stars in the winter sky.',
    's2_o1': 'Alnitak, Alnilam, and Mintaka glow in bright blue harmony.',
    's2_c2': 'Hunter Constellation',
    's2_a2':
        "CLICK on Betelgeuse (the reddish star at the top left) and Rigel (the bright star at the bottom right) to draw the Hunter's body.",
    's2_o2':
        'The constellation lines form and a majestic mythological Hunter silhouette fades into the sky!',
    's2_c3': 'Belt Pointer Line',
    's2_a3':
        'DRAG the Pointer Distance Tool slider up to 5x to project a line leftward from the belt.',
    's2_o3': 'A glowing guide line extends eastward across the cosmos.',
    's2_c4': 'Sirius & Canis Major',
    's2_a4': 'CLICK on Sirius at the tip of the pointer line.',
    's2_o4':
        'Sirius shimmers intensely! Canis Major (The Great Dog) appears alongside the Hunter overlay.',
    // HUD "Current Task" lines (HTML `hud`).
    's1_hud_1':
        'Step 1: Click each of the 7 pulsing stars of the Big Dipper asterism.',
    's1_hud_2':
        'Step 2: Click on both pointer stars (Dubhe & Merak) at the outer edge of the ladle.',
    's1_hud_3':
        'Step 3: Drag the Pointer Distance Tool up to 5x distance outward along the pointer line.',
    's1_hud_4':
        'Step 4: Click on the Pole Star at the 5x target to reveal Ursa Minor and the North Compass!',
    's2_hud_1':
        "Step 1: Click on Orion's Belt (the 3 bright diagonal stars pulsing in unison).",
    's2_hud_2':
        'Step 2: Click on the corner stars Betelgeuse and Rigel to complete Orion and reveal the Hunter artwork overlay.',
    's2_hud_3':
        "Step 3: Drag the Pointer Distance Tool up to 5x to extend a line from Orion's Belt to the left (eastward).",
    's2_hud_4':
        'Step 4: Click on Sirius (the brilliant star) to reveal Canis Major and the Dog artwork overlay!',
    'hud_done': "All 4 steps done! Tap 'Observe Conclusion'.",
    'obj_done':
        "All four steps are done. Tap 'Observe Conclusion' to read what you found.",
    'btn_conclude': 'Observe Conclusion',
    // Pointer Distance Tool (HTML `#distance-slider-box`).
    'pointer_tool': 'Pointer Distance Tool',
    'mult_text': '{v}x Multiplier',
    'tick': '{n}x',
    // Scene texts.
    'compass_north': 'NORTH (TOWARDS POLE STAR)',
    'bd_badge': '✦ Big Dipper (Saptarshi Ladle) ✦',
    'polaris_badge': '★ Pole Star (Polaris - True North) ★',
    'orion_badge': '✦ Orion (The Hunter) ✦',
    'canis_badge': '✦ Canis Major (The Great Dog) ✦',
    'star_bd_1': 'Alkaid',
    'star_bd_2': 'Mizar',
    'star_bd_3': 'Alioth',
    'star_bd_4': 'Megrez',
    'star_bd_5': 'Phecda',
    'star_bd_6': 'Merak',
    'star_bd_7': 'Dubhe',
    'star_bd_6_p': 'Merak (Pointer)',
    'star_bd_7_p': 'Dubhe (Pointer)',
    'star_polaris': 'Pole Star (Polaris)',
    'star_or_b1': 'Alnitak',
    'star_or_b2': 'Alnilam',
    'star_or_b3': 'Mintaka',
    'star_or_betelgeuse': 'Betelgeuse',
    'star_or_rigel': 'Rigel',
    'star_or_c1': 'Bellatrix',
    'star_or_c2': 'Saiph',
    'star_sirius': 'Sirius (Brightest)',
    'star_cm_1': 'Mirzam',
    'star_cm_2': 'Wezen',
    'star_cm_3': 'Adhara',
    // Toasts (HTML: English only).
    'toast_found': '{name} Discovered ({n}/{total})',
    'toast_focus_n': '{name} Focused ({n}/2)',
    'toast_focus': '{name} Focused',
    'toast_short':
        'The line has not reached 5x yet. Keep dragging the slider up to 5x.',
    // Conclusion (HTML summary / success modals).
    'sc_complete': 'Scenario {n} Complete!',
    'obs_complete': 'Observation Complete!',
    's1_summary':
        'The Big Dipper (Saptarshi) is an asterism within Ursa Major. By following the line through its two pointer stars for about 5 times their distance, you accurately locate Polaris—the anchor of true North.',
    's2_summary':
        "Orion's Belt points directly toward Sirius in Canis Major. Sirius is nearly twice as massive as our Sun and shines with unrivaled brilliance in Earth's night sky.",
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You mastered observational stargazing! You learned how to recognize asterisms and use pointer stars to effortlessly locate the North Star and Sirius in the night sky.',
    // Added: sidebar observation list and scene descriptions.
    'obs_title': 'Observations',
    'obs_step': 'Step {n}',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'scene_s1': 'The northern night sky with the Big Dipper and the Pole Star.',
    'scene_s2': 'The winter night sky with Orion, Sirius and Canis Major.',
  },
  'hi': {
    'app_title': 'रात्रि आकाश का अवलोकन',
    'app_subtitle': 'कक्षा 6 • पृथ्वी के पार',
    'scen_1': 'परिदृश्य 1: ध्रुव तारे की खोज',
    'scen_2': 'परिदृश्य 2: शिकारी और उसका कुत्ता',
    's1_obj':
        "सप्तर्षि को खोजना और उसके दो 'संकेतक तारों' की सहायता से सटीक रूप से ध्रुव तारा (पोलारिस) ढूंढना।",
    's2_obj':
        'ओरियन (मृगशीर्ष) तारामंडल की पहचान करना और उसकी बेल्ट की सहायता से रात्रि आकाश के सबसे चमकीले तारे सीरियस (लुब्धक) को खोजना।',
    's1_c1': 'सप्तर्षि तारा-समूह',
    's1_a1':
        'उत्तरी आकाश में सप्तर्षि (चम्मच) के सभी 7 तारों (जिनके चारों ओर घेरा चमक रहा है) पर एक-एक करके क्लिक करें।',
    's1_o1':
        'सप्तर्षि के 7 तारे स्पष्ट रूप से चमककर चम्मच / प्रश्नचिह्न जैसी आकृति बनाते हैं।',
    's1_c2': 'संकेतक तारे',
    's1_a2':
        'चम्मच के आगे वाले सिरे पर स्थित दुभे और मेराक, दोनों तारों पर क्लिक करें।',
    's1_o2': "दोनों तारे तेज़ चमकते हैं और उन पर 'संकेतक' लिखा आता है।",
    's1_c3': '5 गुना दूरी तक विस्तार',
    's1_a3': 'संकेतक दूरी उपकरण के स्लाइडर को 1x से 5x तक खींचें।',
    's1_o3': 'एक सीधी बिंदीदार संकेतक रेखा अंधेरे आकाश में ऊपर की ओर बढ़ती है।',
    's1_c4': 'ध्रुव तारा और लघु सप्तर्षि',
    's1_a4':
        'रेखा के ठीक 5x वाले सिरे पर स्थित तारे (ध्रुव तारा) पर क्लिक करें और देखें।',
    's1_o4':
        'वृहत् सप्तर्षि और लघु सप्तर्षि तारामंडल की आकृतियाँ चमक उठती हैं और उत्तर दिशा बताने वाला बड़ा कंपास दिखाई देता है!',
    's2_c1': 'ओरियन की बेल्ट की खोज',
    's2_a1':
        'सर्दियों के आकाश में एक तिरछी सीध में स्थित तीनों तारों पर क्लिक करें।',
    's2_o1':
        'अलनिताक, अलनिलम और मिंतका, तीनों तारे नीली रोशनी में एक साथ चमक उठते हैं।',
    's2_c2': 'शिकारी तारामंडल',
    's2_a2':
        'शिकारी का शरीर बनाने के लिए बीटलग्यूज (ऊपर बाईं ओर का लाल-सा तारा) और रिगेल (नीचे दाईं ओर का चमकीला तारा) पर क्लिक करें।',
    's2_o2':
        'तारामंडल की रेखाएं बनती हैं और पौराणिक शिकारी की सुंदर आकृति आकाश में उभर आती है!',
    's2_c3': 'बेल्ट संकेतक रेखा',
    's2_a3':
        'बेल्ट से बाईं ओर रेखा बढ़ाने के लिए संकेतक दूरी उपकरण के स्लाइडर को 5x तक खींचें।',
    's2_o3': 'एक चमकती मार्गदर्शक रेखा आकाश में पूर्व दिशा की ओर बढ़ती है।',
    's2_c4': 'सीरियस और केनिस मेजर',
    's2_a4': 'संकेतक रेखा के सिरे पर स्थित सीरियस पर क्लिक करें।',
    's2_o4':
        'सीरियस तेज़ी से जगमगाता है! शिकारी के साथ केनिस मेजर (बड़ा कुत्ता) तारामंडल दिखाई देता है।',
    's1_hud_1':
        'चरण 1: सप्तर्षि के घेरे वाले सभी 7 तारों पर एक-एक करके क्लिक करें।',
    's1_hud_2':
        'चरण 2: चम्मच के बाहरी किनारे के दोनों संकेतक तारों (दुभे और मेराक) पर क्लिक करें।',
    's1_hud_3':
        'चरण 3: संकेतक दूरी उपकरण को 5x दूरी तक खींचकर संकेतक रेखा को आगे बढ़ाएं।',
    's1_hud_4':
        'चरण 4: 5x वाले सिरे पर स्थित ध्रुव तारे पर क्लिक करें और लघु सप्तर्षि व उत्तर दिशा का कंपास देखें!',
    's2_hud_1':
        'चरण 1: ओरियन की बेल्ट (एक साथ चमकते 3 तिरछे तारों) पर क्लिक करें।',
    's2_hud_2':
        'चरण 2: ओरियन को पूरा करने के लिए कोने के तारों बीटलग्यूज और रिगेल पर क्लिक करें और शिकारी की आकृति देखें।',
    's2_hud_3':
        'चरण 3: संकेतक दूरी उपकरण को 5x तक खींचकर ओरियन की बेल्ट से बाईं ओर (पूर्व की ओर) रेखा बढ़ाएं।',
    's2_hud_4':
        'चरण 4: सीरियस (सबसे चमकीले तारे) पर क्लिक करें और केनिस मेजर व कुत्ते की आकृति देखें!',
    'hud_done': "चारों चरण पूरे! 'निष्कर्ष देखें' पर टैप करें।",
    'obj_done':
        "चारों चरण पूरे हो गए। आपने जो खोजा, उसे पढ़ने के लिए 'निष्कर्ष देखें' पर टैप करें।",
    'btn_conclude': 'निष्कर्ष देखें',
    'pointer_tool': 'संकेतक दूरी उपकरण',
    'mult_text': '{v}x दूरी गुणक',
    'tick': '{n}x',
    'compass_north': 'उत्तर दिशा (ध्रुव तारे की ओर)',
    'bd_badge': '✦ सप्तर्षि (बड़ा चम्मच) ✦',
    'polaris_badge': '★ ध्रुव तारा (उत्तर दिशा) ★',
    'orion_badge': '✦ ओरियन (मृगशीर्ष शिकारी) ✦',
    'canis_badge': '✦ केनिस मेजर (बड़ा कुत्ता) ✦',
    'star_bd_1': 'अल्केड',
    'star_bd_2': 'मिज़ार',
    'star_bd_3': 'अलियोथ',
    'star_bd_4': 'मेग्रेज़',
    'star_bd_5': 'फ़ेकदा',
    'star_bd_6': 'मेराक',
    'star_bd_7': 'दुभे',
    'star_bd_6_p': 'मेराक (संकेतक)',
    'star_bd_7_p': 'दुभे (संकेतक)',
    'star_polaris': 'ध्रुव तारा (पोलारिस)',
    'star_or_b1': 'अलनिताक',
    'star_or_b2': 'अलनिलम',
    'star_or_b3': 'मिंतका',
    'star_or_betelgeuse': 'बीटलग्यूज',
    'star_or_rigel': 'रिगेल',
    'star_or_c1': 'बेलैट्रिक्स',
    'star_or_c2': 'सैफ़',
    'star_sirius': 'सीरियस (लुब्धक)',
    'star_cm_1': 'मिर्ज़म',
    'star_cm_2': 'वेज़ेन',
    'star_cm_3': 'अधरा',
    'toast_found': 'तारा मिला: {name} ({n}/{total})',
    'toast_focus_n': 'तारा चुना गया: {name} ({n}/2)',
    'toast_focus': 'तारा चुना गया: {name}',
    'toast_short':
        'रेखा अभी 5x तक नहीं पहुँची है। स्लाइडर को 5x तक खींचते रहें।',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'obs_complete': 'अवलोकन पूर्ण!',
    's1_summary':
        'सप्तर्षि, उर्सा मेजर (वृहत् सप्तर्षि) तारामंडल का एक तारा-समूह है। इसके दो संकेतक तारों को जोड़ने वाली रेखा को उनकी दूरी के लगभग 5 गुना आगे बढ़ाने पर ध्रुव तारा मिलता है, जो सही उत्तर दिशा बताता है।',
    's2_summary':
        'ओरियन की बेल्ट सीधे केनिस मेजर के सीरियस (लुब्धक) की ओर इशारा करती है। सीरियस हमारे सूर्य से लगभग दोगुना भारी है और पृथ्वी के रात्रि आकाश में सबसे अधिक चमकता है।',
    'all_complete': 'आपने महारत हासिल की!',
    'all_complete_desc':
        'आपने तारों का अवलोकन करना सीख लिया है! आपने जाना कि कैसे तारा-समूहों और संकेतक तारों से ध्रुव तारा और सीरियस आसानी से खोजे जा सकते हैं।',
    'obs_title': 'अवलोकन',
    'obs_step': 'चरण {n}',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखाई देगा।',
    'scene_s1': 'उत्तरी रात्रि आकाश, जिसमें सप्तर्षि और ध्रुव तारा हैं।',
    'scene_s2':
        'सर्दियों का रात्रि आकाश, जिसमें ओरियन, सीरियस और केनिस मेजर हैं।',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML
/// `ScenariosData[lang][n].steps`).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      return [
        for (var sc = 1; sc <= 2; sc++)
          LabScenarioData(
            title: t('scen_$sc'),
            objective: t('s${sc}_obj'),
            steps: [
              for (var i = 1; i <= _stepCount; i++)
                LabStep(
                  concept: t('s${sc}_c$i'),
                  action: t('s${sc}_a$i'),
                  observation: t('s${sc}_o$i'),
                ),
            ],
          ),
      ];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Steps per scenario (HTML `steps` arrays); step 5 = all done, the
/// 'Observe Conclusion' button is shown.
const int _stepCount = 4;

/// Smallest touch target for a star (logical px).
const double _touchDp = 48;

/// Slop before a press on a star becomes a drag (RawGestureDetector does
/// not apply MediaQuery's gesture settings).
const double _dragSlop = 8;

// ------------------------------------------------------------------ camera
// HTML init3D(): PerspectiveCamera(60, aspect, 0.1, 1000) at the origin;
// resetCamera() points OrbitControls at the scenario's target.

/// Focal length in design px: 280 / tan(30°) (60° vertical field of view
/// over the 560 px stage height).
const double _focal = 484.974;

/// Scenario 1 looks at (0, 10, -40) as in the HTML. Scenario 2 looked at
/// (-10, 0, -40); with Sirius moved below the belt (see [_s2Stars]) the
/// view is lowered to (-9, -4, -40) so Canis Major stays above the HUD.
const _V _s1Target = _V(0, 10, -40);
const _V _s2Target = _V(-9, -4, -40);

/// While the sidebar is collapsed the sky slides right (design px) so the
/// floating mission card at the top left does not cover the stars; during
/// step 3 it stays left of the Pointer Distance Tool card. Each scenario's
/// sky spans these x values (labels included) when unshifted.
const (double, double) _s1Extent = (270, 790);
const (double, double) _s2Extent = (270, 790);

/// During step 3 the Scenario 1 sky needs room up to here: the pointer
/// stars' labels sit right of the pointer line (the Pole Star's wide badge
/// appears only once it is found).
const double _s1ToolRight = 800;

/// Label placement: the pointer line is kept clear of labels (step 3 on),
/// sampled every [_lineStep] design px as squares of [_lineDot], each
/// overlap counted [_lineWeight] times.
const double _lineStep = 6, _lineDot = 6, _lineWeight = 3;

/// The shell's floating mission card starts 76 dp from the left.
const double _missionLeft = 76;

/// Gap kept between the mission card / tool column and the stars.
const double _cardGap = 10;

/// Rate (1/s) at which the sky slides to its new framing.
const double _shiftRate = 8;

// ------------------------------------------------------------- star look

/// HTML createStar(): sphere radii (world units).
const double _dipperSize = 0.85;
const double _polarisSize = 1.4;
const double _beltSize = 0.95;
const double _orionSize = 0.8;
const double _siriusSize = 1.7;

/// HTML ring: RingGeometry(size × 1.15, size × 1.6), opacity 0.18.
const double _ringInner = 1.15, _ringOuter = 1.6, _ringOpacity = 0.18;

/// HTML pulseRing(): scale = base + sin(t × 0.005) × 0.15 and opacity
/// 0.18 + sin(t × 0.005) × 0.08, t in ms (5 rad/s).
const double _ringRate = 5, _ringAmp = 0.15, _ringOpacityAmp = 0.08;

/// HTML click feedback: mesh.scale 1.4 for 300 ms.
const double _popScale = 1.4, _popTime = 0.3;

/// HTML: the found Pole Star grows to 1.7, Sirius to 1.9.
const double _polarisFoundScale = 1.7, _siriusFoundScale = 1.9;

/// HTML background starfield: 1600 points on a sphere of radius 80, size
/// 0.6, colour #94a3b8, opacity 0.6.
const int _skyCount = 1600;
const double _skyRadius = 80, _skyPointSize = 0.6, _skyOpacity = 0.6;

/// HTML artwork shimmer: opacity + sin(t × 0.003) × amplitude (3 rad/s).
const double _artRate = 3;

/// HTML LineDashedMaterial: pointer lines dash 1.5 / gap 0.8, drag guide
/// dash 1.2 / gap 0.6 (world units).
const double _extDash = 1.5, _extGap = 0.8, _guideDash = 1.2, _guideGap = 0.6;

/// Constellation line width (design px; WebGL draws 1 px lines).
const double _lineWidth = 1.6;

// ------------------------------------------------------------------ slider

/// HTML `#distance-slider`: min 1, max 5, step 0.1; the line is complete
/// once the value reaches 4.8 (`v >= 4.8`).
const double _multMin = 1, _multMax = 5, _multDone = 4.8;
const int _multDivisions = 40;

/// Pointer Distance Tool card: width and slider length (dp, × UI scale),
/// its top below the toast band and the canvas band kept for the HUD.
const double _toolCardWidth = 92;
const double _toolCardTop = 58;
const double _toolCardChrome = 92;
const double _hudBand = 74;
const double _sliderMin = 80, _sliderMax = 170;

// --------------------------------------------------------------- confetti

/// canvas-confetti (`particleCount: 150, spread: 70, origin: {y: 0.3}`):
/// 200 ticks of 1/60 s, velocity × 0.9 per tick, gravity 3 px per tick;
/// velocities scaled by [_confettiSpeed] for the stage.
const int _confettiCount = 150;
const double _confettiTicks = 200;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiStart = 45;
const double _confettiSpeed = 0.6;
const double _confettiSpread = 70 * math.pi / 180;
const Offset _confettiOrigin = Offset(500, 168);

// ----------------------------------------------------------------- the sky

/// A star of the HTML `s1Stars` / `s2Stars` arrays: id (also its name key
/// `star_<id>`), position, sphere radius and colour.
@immutable
class _Star {
  const _Star(this.id, this.pos, this.size, this.color);

  final String id;
  final _V pos;
  final double size;
  final Color color;
}

/// Scenario 1: the Big Dipper and the Pole Star (HTML `s1Stars`). Merak was
/// at (7, 1, -42): the HTML Pole Star then lay only 3.2 pointer distances
/// beyond Dubhe although the lab teaches "about 5 times". Merak now sits
/// one fifth of the Dubhe → Pole Star distance below Dubhe, so the 5x tip
/// of the pointer line lands exactly on the Pole Star.
const List<_Star> _s1Stars = [
  _Star('bd_1', _V(-16, 12, -40), _dipperSize, _Colors.yellow200),
  _Star('bd_2', _V(-11, 11, -41), _dipperSize, _Colors.yellow200),
  _Star('bd_3', _V(-5, 10, -42), _dipperSize, _Colors.yellow200),
  _Star('bd_4', _V(0, 7, -43), _dipperSize, _Colors.yellow200),
  _Star('bd_5', _V(0, 2, -43), _dipperSize, _Colors.yellow200),
  _Star('bd_6', _V(7.2, 3.2, -42.4), _dipperSize, _Colors.yellow200),
  _Star('bd_7', _V(8, 7, -42), _dipperSize, _Colors.yellow200),
  _Star('polaris', _V(12, 26, -40), _polarisSize, _Colors.blue400),
];

/// Scenario 2: Orion, Sirius and Canis Major (HTML `s2Stars`). In the HTML
/// the belt rose to the left (Mintaka lowest) and pointed up to Sirius; in
/// the real sky (Orion facing south, Betelgeuse at the top left) the belt
/// slopes down to the left and points down to Sirius, and Rigel is higher
/// than Saiph. The belt, Rigel, Saiph and Sirius are placed that way:
/// Sirius lies five belt gaps beyond Alnitak along the belt line. In the
/// HTML Canis Major was mirrored: Mirzam lay east (left) of Sirius and
/// Adhara west of Wezen. As in the real sky, Mirzam now lies west of Sirius
/// (towards Orion) and a little lower, Wezen and Adhara to the south-east,
/// Adhara the lowest and west of Wezen.
const List<_Star> _s2Stars = [
  _Star('or_b1', _V(-4, -3, -42), _beltSize, _Colors.blue300), // Alnitak
  _Star('or_b2', _V(0, -1.5, -42), _beltSize, _Colors.blue300), // Alnilam
  _Star('or_b3', _V(4, 0, -42), _beltSize, _Colors.blue300), // Mintaka
  _Star('or_betelgeuse', _V(-5, 8, -41), _orionSize, _Colors.red300),
  _Star('or_rigel', _V(5, -8, -41), _orionSize, _Colors.blue300),
  _Star('or_c1', _V(6, 6, -41), _orionSize, _Colors.blue300), // Bellatrix
  _Star('or_c2', _V(-6, -10, -41), _orionSize, _Colors.blue300), // Saiph
  _Star('sirius', _V(-24, -10.5, -42), _siriusSize, _Colors.white),
  _Star('cm_1', _V(-19.5, -11.7, -42), _orionSize, _Colors.blue300), // Mirzam
  _Star('cm_2', _V(-28.5, -19.2, -42), _orionSize, _Colors.blue300), // Wezen
  _Star('cm_3', _V(-26.8, -21.5, -42), _orionSize, _Colors.blue300), // Adhara
];

final Map<String, _Star> _starById = {
  for (final s in [..._s1Stars, ..._s2Stars]) s.id: s,
};

/// HTML createLine() star chains.
const List<String> _dipperLine = [
  'bd_1',
  'bd_2',
  'bd_3',
  'bd_4',
  'bd_5',
  'bd_6',
  'bd_7',
  'bd_4',
];
const List<String> _pointerLine = ['bd_6', 'bd_7'];
const List<String> _beltLine = ['or_b1', 'or_b2', 'or_b3'];
const List<String> _bodyLine = [
  'or_betelgeuse',
  'or_c1',
  'or_b3',
  'or_rigel',
  'or_c2',
  'or_b1',
  'or_betelgeuse',
];
const List<String> _canisLine = ['sirius', 'cm_1', 'cm_3', 'cm_2', 'sirius'];

/// The stars each step asks for: Big Dipper / belt (step 1), the pointer
/// pair / the Hunter's corners (step 2; HTML: any corner star is "focused",
/// Betelgeuse and Rigel complete it) and the target star (step 4).
const List<String> _dipperStars = [
  'bd_1',
  'bd_2',
  'bd_3',
  'bd_4',
  'bd_5',
  'bd_6',
  'bd_7',
];
const List<String> _pointerStars = ['bd_6', 'bd_7'];
const List<String> _cornerStars = [
  'or_betelgeuse',
  'or_rigel',
  'or_c1',
  'or_c2',
];
const List<String> _bodyKeys = ['or_betelgeuse', 'or_rigel'];

/// A pointer line (HTML `s1_polaris_ext` / `s2_sirius_ext`): drawn from
/// [start] through [to]; at multiplier v its tip is [to] + v × ([to] −
/// [from]), so at 5x it reaches [target].
@immutable
class _Pointer {
  const _Pointer(this.start, this.from, this.to, this.target, this.color);

  final String start;
  final String from;
  final String to;
  final String target;
  final Color color;

  _V tip(double v) {
    final a = _starById[from]!.pos, b = _starById[to]!.pos;
    return b + (b - a) * v;
  }
}

/// Scenario 1: Merak → Dubhe, 5 pointer distances to the Pole Star (red
/// dashed line). Scenario 2: Mintaka → Alnitak, 5 belt gaps (Alnilam →
/// Alnitak) to Sirius (amber dashed line).
const List<_Pointer> _pointers = [
  _Pointer('bd_6', 'bd_6', 'bd_7', 'polaris', _Colors.red500),
  _Pointer('or_b3', 'or_b2', 'or_b1', 'sirius', _Colors.amber500),
];

/// HTML createArtworkFigure(): a translucent silhouette (fill opacity and
/// its shimmer amplitude) with an outline at opacity min(1, 2.5 × fill).
@immutable
class _Figure {
  const _Figure(
    this.points,
    this.fill,
    this.outline,
    this.opacity,
    this.shimmerBase,
    this.shimmerAmp,
  );

  final List<_V> points;
  final Color fill;
  final Color outline;
  final double opacity;
  final double shimmerBase;
  final double shimmerAmp;
}

/// Ursa Major (`ursaMajorPolygon`, Merak's corner moved with Merak).
const _Figure _ursaMajor = _Figure(
  [
    _V(-16, 12, -40),
    _V(-11, 11, -41),
    _V(-5, 10, -42),
    _V(0, 7, -43),
    _V(8, 7, -42),
    _V(12, 3, -42),
    _V(10, 0, -42),
    _V(7.2, 3.2, -42.4),
    _V(0, 2, -43),
    _V(-3, 4, -43),
    _V(0, 7, -43),
  ],
  _Colors.yellow500,
  _Colors.yellow400,
  0.18,
  0.16,
  0.06,
);

/// Ursa Minor (`ursaMinorPolygon`).
const _Figure _ursaMinor = _Figure(
  [
    _V(12, 26, -40),
    _V(16, 23, -40),
    _V(21, 21, -40),
    _V(24, 24, -40),
    _V(20, 27, -40),
    _V(16, 23, -40),
  ],
  _Colors.blue400,
  _Colors.blue300,
  0.18,
  0.16,
  0.06,
);

/// The Hunter (`orionPolygon`, its belt and foot corners moved with the
/// stars).
const _Figure _hunter = _Figure(
  [
    _V(-5, 8, -41),
    _V(0, 14, -41),
    _V(6, 6, -41),
    _V(12, 11, -41),
    _V(11, 3, -41),
    _V(6, 6, -41),
    _V(4, 0, -42),
    _V(5, -8, -41),
    _V(1, -9, -41),
    _V(0, -5, -41),
    _V(-6, -10, -41),
    _V(-8, -12, -41),
    _V(-4, -3, -42),
    _V(-11, 4, -41),
    _V(-13, -3, -41),
    _V(-12, 8, -41),
    _V(-5, 8, -41),
  ],
  _Colors.blue300,
  _Colors.blue400,
  0.2,
  0.18,
  0.07,
);

/// The Great Dog (HTML `canisPolygon`, redrawn around the corrected stars):
/// facing Orion, Sirius at its chest, Mirzam at the raised front paw, Wezen
/// at the rump and Adhara at the hind foot.
const _Figure _dog = _Figure(
  [
    _V(-21, -7.5, -42), // nose
    _V(-23.5, -6, -42),
    _V(-25.5, -7.5, -42),
    _V(-27.5, -12, -42), // back
    _V(-30, -17.5, -42),
    _V(-32.5, -17, -42), // tail
    _V(-31, -20, -42),
    _V(-29, -23.5, -42), // hind leg
    _V(-26, -24, -42),
    _V(-25.5, -20.5, -42),
    _V(-24, -16.5, -42), // belly
    _V(-23, -20, -42), // front leg
    _V(-21.5, -20, -42),
    _V(-21.8, -14.5, -42),
    _V(-18.2, -12.7, -42), // raised paw
    _V(-18.2, -10.7, -42),
    _V(-22, -9.9, -42), // chest
    _V(-22.5, -8.9, -42),
  ],
  _Colors.sky400,
  _Colors.sky300,
  0.25,
  0.22,
  0.08,
);

/// HTML addBadge(): a floating title chip (text key, anchor, fill, text and
/// border colours). The anchors are moved off the stars they named: the
/// HTML put the Big Dipper badge on top of Alioth and Megrez and the Canis
/// Major badge between Sirius and Wezen.
@immutable
class _Badge {
  const _Badge(this.key, this.at, this.fill, this.text, this.border);

  final String key;
  final _V at;
  final Color fill;
  final Color text;
  final Color border;
}

const _Badge _dipperBadge = _Badge(
  'bd_badge',
  _V(-5, -1, -42),
  Color(0x33EAB308), // bg-yellow-500/20
  _Colors.yellow300,
  Color(0x80EAB308), // border-yellow-500/50
);
const _Badge _polarisBadge = _Badge(
  'polaris_badge',
  _V(12, 29, -40),
  Color(0x4D6366F1), // bg-indigo-500/30
  _Colors.indigo200,
  Color(0x99818CF8), // border-indigo-400/60
);
const _Badge _orionBadge = _Badge(
  'orion_badge',
  _V(0, 12, -41),
  Color(0x4D6366F1),
  _Colors.indigo200,
  Color(0x99818CF8),
);
const _Badge _canisBadge = _Badge(
  'canis_badge',
  _V(-26, -2, -42),
  Color(0x3306B6D4), // bg-cyan-500/20
  _Colors.cyan300,
  Color(0x8022D3EE), // border-cyan-400/50
);

/// HTML `#compass-rose-box` ("NORTH (TOWARDS POLE STAR)"). The HTML showed
/// it at the canvas's top right, where it covered the Pole Star on a phone;
/// it is drawn in the sky left of the Pole Star instead, bouncing like the
/// HTML `animate-bounce` (1 s).
const _V _compassAt = _V(-12, 21, -40);

/// Pan recogniser that only claims pointers that start on a star (decided
/// by [canGrab]), so other drags still reach the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _Ch12A2ObservingTheNightSkyPageState
    extends State<Ch12A2ObservingTheNightSkyPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  /// Pointer Distance Tool value (HTML `#distance-slider`).
  final ValueNotifier<double> _mult = ValueNotifier(_multMin);
  final _TextCache _texts = _TextCache();
  late final Ticker _ticker;

  /// Finger-sized hit radius for a star (design px) and the canvas label
  /// size boost, from the last stage layout.
  double _touch = _touchDp / 2;
  double _labelScale = 1;

  /// Design x beyond which canvas labels would sit under a card: the
  /// Pointer Distance Tool (step 3) or the tool column.
  double _labelRight = _design.width;

  /// Star under the finger at pointer-down (not yet dragging).
  String? _grab;

  /// The last toast of this lab (rebuilt in the new language on a switch)
  /// and the id the controller gave it.
  String Function()? _toastText;
  int _toastShownId = -1;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarioData(_lab.lang)[_scene.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.load(0);
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
    _mult.dispose();
    _texts.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()`: the clock for the ring pulses, the artwork shimmer,
  /// the click pulses and the confetti; also eases the sky to its framing.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = math.max(0.0, now - s.time);
    s.time = now;
    final gap = s.shiftTarget - s.shift;
    s.shift = gap.abs() < 0.05
        ? s.shiftTarget
        : s.shift + gap * math.min(1.0, dt * _shiftRate);
    _frame.value = now;
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast()`; [text] is kept to translate the toast on a
  /// language switch.
  void _toast(String Function() text, {bool error = false}) {
    _toastText = text;
    _lab.showToast(text(), isError: error, sound: error);
    _toastShownId = _lab.toast?.id ?? -1;
  }

  /// Re-shows the visible toast (this lab's or the shell's "Scenario
  /// Complete") in the new language after a switch from [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    if (shown == null) return;
    final String translated;
    final ownText = _toastText;
    if (shown.id == _toastShownId && ownText != null) {
      translated = ownText();
    } else if (shown.text ==
        labTr(kLabCommonStrings, previous, 'msg_scenario_complete')) {
      translated = _lab.t('msg_scenario_complete');
    } else {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      final own = shown.id == _toastShownId;
      _lab.showToast(translated, isError: shown.isError, sound: false);
      if (own) _toastShownId = _lab.toast?.id ?? -1;
    });
  }

  /// HTML `changeScenario()` / `resetScenarioState()`: the scenario's sky at
  /// step 1, every click, line, figure and the slider reset.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _grab = null;
    });
    _mult.value = _multMin;
    _lab.resetView(sound: false);
  }

  String _name(String id) => _t('star_$id');

  /// The HUD line of the current step, shown as a hint when a star that is
  /// not part of the step is clicked.
  void _hint() {
    final s = _scene;
    final key = 's${s.scenario + 1}_hud_${s.step}';
    _toast(() => _t(key), error: true);
  }

  /// HTML `handleStarClick(mesh)`.
  void _clickStar(String id) {
    final s = _scene;
    if (!_lab.isLabActive) return;
    _Sound.click.play();
    s.popUntil[id] = s.time + _popTime;
    if (s.finished) return;
    if (s.scenario == 0) {
      _clickS1(id);
    } else {
      _clickS2(id);
    }
  }

  void _clickS1(String id) {
    final s = _scene;
    switch (s.step) {
      case 1:
        if (!_dipperStars.contains(id)) return _hint();
        if (!s.discovered.add(id)) return;
        final n = s.discovered.length;
        _toast(
          () => labFormat(_t('toast_found'), {
            'name': _name(id),
            'n': n,
            'total': _dipperStars.length,
          }),
        );
        if (n >= _dipperStars.length) _advance();
      case 2:
        if (!_pointerStars.contains(id)) return _hint();
        if (!s.focused.add(id)) return;
        final n = s.focused.length;
        _toast(
          () => labFormat(_t('toast_focus_n'), {'name': _name(id), 'n': n}),
        );
        if (n >= _pointerStars.length) _advance();
      case 3:
        _hint();
      case 4:
        if (id != 'polaris') return _hint();
        _Sound.success.play();
        _advance();
    }
  }

  void _clickS2(String id) {
    final s = _scene;
    switch (s.step) {
      case 1:
        if (!_beltLine.contains(id)) return _hint();
        if (!s.discovered.add(id)) return;
        final n = s.discovered.length;
        _toast(
          () => labFormat(_t('toast_found'), {
            'name': _name(id),
            'n': n,
            'total': _beltLine.length,
          }),
        );
        if (n >= _beltLine.length) _advance();
      case 2:
        if (!_cornerStars.contains(id)) return _hint();
        if (!s.focused.add(id)) return;
        _toast(() => labFormat(_t('toast_focus'), {'name': _name(id)}));
        if (_bodyKeys.every(s.focused.contains)) _advance();
      case 3:
        _hint();
      case 4:
        if (id != 'sirius') return _hint();
        _Sound.success.play();
        _advance();
    }
  }

  /// HTML `progressStep()`.
  void _advance() {
    setState(() => _scene.step += 1);
    if (_scene.step == 3) _mult.value = _multMin;
  }

  /// HTML `slider.oninput`: the pointer line follows the slider; at 4.8x it
  /// is complete (snapped to 5x so it reaches the target star).
  void _onMultiplier(double v) {
    final s = _scene;
    if (s.step != 3) return;
    if (v >= _multDone) {
      s.multiplier = _multMax;
      _mult.value = _multMax;
      _Sound.click.play();
      _advance();
      return;
    }
    s.multiplier = v;
    _mult.value = v;
  }

  /// Added: letting go of the slider before 5x gives a hint (the HTML gave
  /// no feedback and drew nothing before 4.8x).
  void _onMultiplierEnd(double v) {
    if (_scene.step != 3 || v >= _multDone) return;
    _toast(() => _t('toast_short'), error: true);
  }

  /// HTML `triggerConclusion()` ('Observe Conclusion'): the summary
  /// (Scenario 1) or the summary with "Mastery Achieved!" and confetti
  /// (Scenario 2; the HTML showed only the mastery modal there, never the
  /// Scenario 2 summary). Re-opens the summary when tapped again.
  void _observeConclusion() {
    final s = _scene;
    if (!s.finished) return;
    final sc = s.scenario;
    setState(() {
      if (sc == 1 && !s.conclusionSeen) s.confettiStart = s.time;
      s.conclusionSeen = true;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      heading: () => _t('obs_complete'),
      body: () => _t('s${sc + 1}_summary'),
      extra: sc == 1 ? () => _mastery(_lab.palette, context.labScale) : null,
    );
  }

  // -------------------------------------------------------------- gestures

  /// HTML raycast against the visible stars: the nearest star within its
  /// ring or a finger-sized circle.
  String? _starAt(Offset at) {
    final s = _scene;
    final p = s.proj;
    String? best;
    var bestD = double.infinity;
    for (final star in s.stars) {
      final c = p.p(star.pos);
      final r = math.max(
        star.size * _ringOuter * s.scaleOf(star) * p.scaleAt(star.pos),
        _touch,
      );
      final d = (at - c).distance;
      if (d <= r && d < bestD) {
        best = star.id;
        bestD = d;
      }
    }
    return best;
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive || _scene.dragFrom != null) return;
    final id = _starAt(d.localPosition);
    if (id != null) _clickStar(id);
  }

  /// HTML `onPointerDown`: a press on a star starts a drag guide line.
  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _scene.dragFrom != null) return false;
    _grab = _starAt(event.localPosition);
    return _grab != null;
  }

  void _onDragStart(DragStartDetails d) {
    final id = _grab;
    if (id == null) return;
    _scene
      ..dragFrom = id
      ..dragAt = d.localPosition;
  }

  /// HTML `onPointerMove`: the dashed guide line follows the finger.
  void _onDragUpdate(DragUpdateDetails d) {
    if (_scene.dragFrom == null) return;
    _scene.dragAt = d.localPosition;
  }

  /// HTML `onPointerUp`: released on a star, that star is clicked; a drag
  /// between the two stars of step 2 (Dubhe ↔ Merak, Betelgeuse ↔ Rigel)
  /// clicks both.
  void _onDragEnd(DragEndDetails _) {
    final s = _scene;
    final from = s.dragFrom;
    final at = s.dragAt;
    _release();
    if (from == null || at == null) return;
    final to = _starAt(at);
    if (to == null) return;
    final pair = s.scenario == 0 ? _pointerStars : _bodyKeys;
    if (s.step == 2 && from != to && pair.contains(from) && pair.contains(to)) {
      _clickStar(from);
      if (s.step == 2) _clickStar(to);
      return;
    }
    _clickStar(to);
  }

  void _release() {
    _grab = null;
    _scene
      ..dragFrom = null
      ..dragAt = null;
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#compare-btn-container` ('Observe Conclusion'), shown once the
  /// four steps are done.
  List<LabAction> _actions() {
    final s = _scene;
    return [
      if (s.finished)
        LabAction(
          label: _t('btn_conclude'),
          icon: Icons.lightbulb,
          color: _Colors.indigo600,
          foreground: _Colors.white,
          highlight: !s.conclusionSeen,
          // The popup plays the HTML 'success' tone.
          silent: true,
          onTap: _observeConclusion,
        ),
    ];
  }

  /// Horizontal slide of the sky (design px). While the sidebar is
  /// collapsed the sky slides right so the floating mission card does not
  /// cover it (compare Ch4-A1 `_collapsedShift`), but never under the tool
  /// column or, during step 3, under the Pointer Distance Tool card: if the
  /// sky does not fit beside the card it slides left, as far as the stage's
  /// left edge.
  double _frameShift(BuildContext context, BoxConstraints box, double fit) {
    if (fit <= 0 || !fit.isFinite) return 0;
    final scale = context.labScale;
    final stageLeft = (box.maxWidth - _design.width * fit) / 2;
    final tool = _scene.step == 3;
    var cardsLeft = box.maxWidth - labOverlayInsets(context, _lab).right;
    if (tool) cardsLeft -= _toolCardWidth * scale;
    final s1 = _scene.scenario == 0;
    final (left, right) = s1 ? _s1Extent : _s2Extent;
    final skyRight = tool && s1 ? _s1ToolRight : right;
    final room = (cardsLeft - stageLeft) / fit - _cardGap - skyRight;
    var want = 0.0;
    if (!_lab.isSidebarOpen) {
      final size = MediaQuery.sizeOf(context);
      final pad = MediaQuery.paddingOf(context);
      final card = _missionCardWidth(size, scale);
      final cardRight = (_missionLeft + pad.left + card - stageLeft) / fit;
      want = math.max(0.0, cardRight + _cardGap - left);
    }
    return math.max(math.min(want, room), -left);
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
        final f = context.labScale * _lab.fontScale;
        final data = _data;
        final s = _scene;
        final sc = s.scenario + 1;
        return LabShell(
          controller: _lab,
          icon: Icons.nights_stay,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          // After step 4 the HTML showed 'Observe Conclusion'; the
          // objective says to tap it.
          instruction: s.finished ? _t('obj_done') : null,
          hud: s.finished ? _t('hud_done') : _t('s${sc}_hud_${s.step}'),
          // The task line no longer applies once the conclusion was read.
          showHud: !s.conclusionSeen,
          actions: _actions(),
          // HTML `resetApp()` starts again at Scenario 1.
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
          overlays: _overlays(context, p),
          stage: _stage(),
        );
      },
    );
  }

  /// HTML `#distance-slider-box`, shown during step 3: a vertical card at
  /// the right of the canvas, left of the tool column, below the toast band
  /// and above the HUD (the HTML card was horizontal, 192 px wide, and
  /// covered the pointer stars on a phone).
  List<Widget> _overlays(BuildContext context, LabPalette p) {
    if (!_lab.isLabActive || _scene.step != 3) return const [];
    final s = context.labScale;
    final inset = labOverlayInsets(context, _lab);
    final pad = MediaQuery.paddingOf(context);
    final height = MediaQuery.sizeOf(context).height;
    final top = _toolCardTop + pad.top;
    final band = _lab.isSidebarOpen ? _hudBand : inset.bottom;
    final column = (height - top - band - pad.bottom - _toolCardChrome * s)
        .clamp(_sliderMin, math.max(_sliderMin, _sliderMax * s))
        .toDouble();
    return [
      Positioned(
        key: const ValueKey('ch12a2-distance'),
        top: top,
        right: inset.right,
        child: _DistanceCard(
          palette: p,
          scale: s,
          width: _toolCardWidth * s,
          column: column,
          title: _t('pointer_tool'),
          readout: (v) =>
              labFormat(_t('mult_text'), {'v': v.toStringAsFixed(1)}),
          tick: (n) => labFormat(_t('tick'), {'n': n}),
          value: _mult,
          onChanged: _onMultiplier,
          onChangeEnd: _onMultiplierEnd,
        ),
      ),
    ];
  }

  Widget _stage() {
    return LayoutBuilder(
      builder: (context, box) {
        final fit = math.min(
          box.maxWidth / _design.width,
          box.maxHeight / _design.height,
        );
        if (fit > 0 && fit.isFinite) {
          _touch = _touchDp / 2 / fit;
          // Canvas labels stay readable when the stage is scaled down.
          _labelScale = (0.85 / fit).clamp(1.0, 1.6);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          var right = box.maxWidth - labOverlayInsets(context, _lab).right;
          if (_scene.step == 3) {
            right -= _toolCardWidth * context.labScale;
          }
          _labelRight = (right - stageLeft) / fit;
        }
        _scene.shiftTarget = _frameShift(context, box, fit);
        return LabStage(
          designSize: _design,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            // Taps on the sky are not screen-reader actions; the scene is
            // announced by its label instead.
            excludeFromSemantics: true,
            gestures: <Type, GestureRecognizerFactory>{
              _GrabPanRecognizer:
                  GestureRecognizerFactoryWithHandlers<_GrabPanRecognizer>(
                    () => _GrabPanRecognizer(debugOwner: this),
                    (r) => r
                      ..gestureSettings = const DeviceGestureSettings(
                        touchSlop: _dragSlop,
                      )
                      ..canGrab = _canGrab
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = _onDragStart
                      ..onUpdate = _onDragUpdate
                      ..onEnd = _onDragEnd
                      ..onCancel = _release,
                  ),
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(debugOwner: this),
                    (r) => r.onTapUp = _onTapUp,
                  ),
            },
            child: Semantics(
              image: true,
              label: _t(_scene.scenario == 0 ? 'scene_s1' : 'scene_s2'),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: _design,
                  painter: _ScenePainter(
                    scene: _scene,
                    texts: _texts,
                    repaint: _frame,
                    showLabels: _lab.showLabels,
                    lang: _lab.lang,
                    labelScale: _labelScale,
                    labelRight: _labelRight,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _data.steps;
    final done = (_scene.step - 1).clamp(0, steps.length);
    return _ObservationList(
      palette: p,
      scale: f,
      empty: _t('obs_empty'),
      entries: [
        for (var i = 1; i <= done; i++)
          (labFormat(_t('obs_step'), {'n': i}), steps[i - 1].observation),
      ],
    );
  }

  /// HTML `#success-modal` text ("Mastery Achieved!"), shown under the
  /// Scenario 2 summary.
  Widget _mastery(LabPalette p, double s) {
    final gold = p.ink(_Colors.yellow400);
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: _Colors.yellow500.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Colors.yellow500.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_events, color: gold, size: 22 * s),
          SizedBox(width: 8 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('all_complete'),
                  style: TextStyle(
                    color: p.textStrong,
                    fontSize: 13.5 * s,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  _t('all_complete_desc'),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ side widgets

/// HTML `#distance-slider-box` ("Pointer Distance Tool"): the multiplier
/// readout and the 1x-5x slider, upright so it fits beside the sky.
class _DistanceCard extends StatelessWidget {
  const _DistanceCard({
    required this.palette,
    required this.scale,
    required this.width,
    required this.column,
    required this.title,
    required this.readout,
    required this.tick,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final LabPalette palette;
  final double scale;
  final double width;

  /// Length of the slider track (dp).
  final double column;
  final String title;

  /// "{v}x Multiplier" for a value, and the "{n}x" tick labels.
  final String Function(double v) readout;
  final String Function(int n) tick;
  final ValueListenable<double> value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = palette;
    final overlay = 14 * s;
    final tickStyle = TextStyle(
      color: p.textMuted,
      fontSize: 9 * s,
      fontWeight: FontWeight.w800,
      height: 1,
    );
    return LabGlassCard(
      palette: p,
      radius: 16,
      color: p.isDark ? _Colors.glassDark : _Colors.glassLight,
      borderColor: _Colors.indigo500.withValues(alpha: 0.6),
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 8 * s),
      child: SizedBox(
        width: width - 12 * s,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.ink(_Colors.indigo400),
                fontSize: 9 * s,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: labLetterSpacing(title, 0.6),
              ),
            ),
            SizedBox(height: 6 * s),
            ValueListenableBuilder<double>(
              valueListenable: value,
              builder: (context, v, _) => Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 4 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: _Colors.indigo500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _Colors.indigo500.withValues(alpha: 0.3),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    readout(v),
                    maxLines: 1,
                    style: TextStyle(
                      color: p.ink(_Colors.yellow300),
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6 * s),
            SizedBox(
              height: column,
              child: Row(
                children: [
                  // 5x at the top (HTML: the 5x tick is green).
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: overlay - 4 * s),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var n = 5; n >= 1; n--)
                          Text(
                            tick(n),
                            style: n == 5
                                ? tickStyle.copyWith(
                                    color: p.ink(_Colors.emerald400),
                                  )
                                : tickStyle,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      label: title,
                      child: SizedBox(
                        key: const ValueKey('ch12a2-distance-slider'),
                        height: column,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6 * s,
                              activeTrackColor: _Colors.indigo500,
                              inactiveTrackColor: p.isDark
                                  ? _Colors.slate700
                                  : _Colors.slate300,
                              thumbColor: _Colors.white,
                              overlayColor: _Colors.indigo500.withValues(
                                alpha: 0.2,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: overlay,
                              ),
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 10 * s,
                              ),
                              showValueIndicator: ShowValueIndicator.never,
                            ),
                            child: ValueListenableBuilder<double>(
                              valueListenable: value,
                              builder: (context, v, _) => Slider(
                                value: v.clamp(_multMin, _multMax),
                                min: _multMin,
                                max: _multMax,
                                divisions: _multDivisions,
                                onChanged: onChanged,
                                onChangeEnd: onChangeEnd,
                              ),
                            ),
                          ),
                        ),
                      ),
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
}

/// The sidebar's observation list: one line per step done.
class _ObservationList extends StatelessWidget {
  const _ObservationList({
    required this.palette,
    required this.scale,
    required this.empty,
    required this.entries,
  });

  final LabPalette palette;
  final double scale;
  final String empty;

  /// (step heading, observation text), in step order.
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    return Container(
      padding: EdgeInsets.all(10 * f),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: entries.isEmpty
          ? Text(
              empty,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 11.5 * f,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 8 * f),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1 * f),
                          child: Icon(
                            Icons.check_circle,
                            size: 13 * f,
                            color: p.success,
                          ),
                        ),
                        SizedBox(width: 6 * f),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${entries[i].$1}: ',
                                  style: TextStyle(
                                    color: p.textStrong,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(text: entries[i].$2),
                              ],
                            ),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 11.5 * f,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ------------------------------------------------------------- scene model

/// One confetti piece (canvas-confetti).
@immutable
class _Confetto {
  const _Confetto(this.angle, this.velocity, this.color, this.spin);

  final double angle;
  final double velocity;
  final Color color;
  final double spin;
}

/// A chip placed on the sky: star label, title badge.
@immutable
class _Placed {
  const _Placed(this.text, this.rect, this.fill, this.border, this.radius);

  final TextPainter text;
  final Rect rect;
  final Color fill;
  final Color border;
  final double radius;
}

/// Mutable simulation state (HTML `State.s1` / `State.s2` and the star
/// meshes), read by the painter every frame.
class _Scene {
  _Scene() {
    // HTML: 1600 random points on a sphere of radius 80.
    final rnd = math.Random(1600);
    for (var i = 0; i < _skyCount; i++) {
      final theta = rnd.nextDouble() * 2 * math.pi;
      final phi = math.acos(2 * rnd.nextDouble() - 1);
      sky.add(
        _V(
          _skyRadius * math.sin(phi) * math.cos(theta),
          _skyRadius * math.sin(phi) * math.sin(theta),
          _skyRadius * math.cos(phi),
        ),
      );
    }
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add(
        _Confetto(
          -math.pi / 2 + _confettiSpread * (0.5 - rnd.nextDouble()),
          (_confettiStart * 0.5 + rnd.nextDouble() * _confettiStart) *
              _confettiSpeed,
          _Colors.confetti[i % _Colors.confetti.length],
          (rnd.nextDouble() - 0.5) * 0.4,
        ),
      );
    }
  }

  final List<_V> sky = [];
  final List<_Confetto> confetti = [];

  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-4; 5 once all four steps are done).
  int step = 1;

  /// Stars clicked in step 1 (HTML `clickedStars`) and step 2 (HTML
  /// `pointerStarsClicked` / `bodyStarsClicked`).
  final Set<String> discovered = {};
  final Set<String> focused = {};

  /// Pointer Distance Tool value while step 3 runs.
  double multiplier = _multMin;

  /// 'Observe Conclusion' was tapped (HUD hidden, button stops pulsing).
  bool conclusionSeen = false;
  double? confettiStart;

  /// Scene time until which a clicked star stays enlarged.
  final Map<String, double> popUntil = {};

  /// HTML drag guide line: the star it starts from and the finger.
  String? dragFrom;
  Offset? dragAt;

  /// Horizontal slide of the sky (design px) and where it is heading.
  double shift = 0;
  double shiftTarget = 0;

  /// Painter caches: projected background stars and placed label chips.
  Float32List? skyPoints;
  int skyKey = 0;
  int? labelKey;
  final List<_Placed> placed = [];

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    discovered.clear();
    focused.clear();
    multiplier = _multMin;
    conclusionSeen = false;
    confettiStart = null;
    popUntil.clear();
    dragFrom = null;
    dragAt = null;
    labelKey = null;
  }

  bool get finished => step > _stepCount;
  List<_Star> get stars => scenario == 0 ? _s1Stars : _s2Stars;
  _Pointer get pointer => _pointers[scenario];
  _Proj get proj => _Proj(scenario == 0 ? _s1Target : _s2Target, shift);

  /// Design-space point of star [id] (also read by the tests).
  Offset point(String id) => proj.p(_starById[id]!.pos);

  /// The pointer line's multiplier as drawn (full once step 3 is done).
  double get lineMultiplier => step > 3 ? _multMax : multiplier;

  /// Mesh scale without the click pulse: the found Pole Star / Sirius grow.
  double restScale(_Star s) {
    if (!finished || s.id != pointer.target) return 1;
    return s.id == 'polaris' ? _polarisFoundScale : _siriusFoundScale;
  }

  /// Mesh scale: HTML click feedback 1.4 for 300 ms.
  double scaleOf(_Star s) {
    final until = popUntil[s.id];
    final rest = restScale(s);
    return until != null && time < until ? math.max(rest, _popScale) : rest;
  }

  /// HTML `pulseRing(mesh, base)` for the current step, or null when the
  /// star's ring rests.
  double? ringPulse(_Star s) {
    final id = s.id;
    if (scenario == 0) {
      return switch (step) {
        1 when _dipperStars.contains(id) && !discovered.contains(id) => 1.2,
        2 when _pointerStars.contains(id) => 1.35,
        4 when id == 'polaris' => 1.5,
        _ => null,
      };
    }
    return switch (step) {
      1 when _beltLine.contains(id) && !discovered.contains(id) => 1.25,
      2 when _cornerStars.contains(id) => 1.3,
      4 when id == 'sirius' => 1.6,
      _ => null,
    };
  }

  /// Added glow for the stars the observations say "illuminate" / "glow"
  /// (the HTML had no glow; 0 = none, 1 = strongest).
  double glow(_Star s) {
    final id = s.id;
    if (scenario == 0) {
      if (id == 'polaris') return finished ? 1 : 0;
      if (step > 2 && _pointerStars.contains(id)) return 1;
      return step > 1 ? 0.45 : 0;
    }
    if (id == 'sirius') return finished ? 1 : 0;
    if (step > 1 && _beltLine.contains(id)) return 0.8;
    if (step > 2 && _cornerStars.contains(id)) return 0.45;
    return 0;
  }

  /// Stars with a name label (HTML updateStarLabelsUI()).
  List<String> get labelled => scenario == 0
      ? [if (step > 1) ..._dipperStars, if (finished) 'polaris']
      : [
          if (step > 1) ..._beltLine,
          if (step > 2) ..._cornerStars,
          if (finished) ...const ['sirius', 'cm_1', 'cm_2', 'cm_3'],
        ];

  /// Title badges shown (HTML addBadge()).
  List<_Badge> get badges => scenario == 0
      ? [if (step > 1) _dipperBadge, if (finished) _polarisBadge]
      : [if (step > 2) _orionBadge, if (finished) _canisBadge];

  /// Name key of a star's label; the pointer stars are named so once
  /// step 2 is done.
  String nameKey(String id) =>
      step > 2 && scenario == 0 && _pointerStars.contains(id)
      ? 'star_${id}_p'
      : 'star_$id';
}

// ------------------------------------------------------------------ 3D math

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

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
}

/// The HTML PerspectiveCamera (60° vertical field of view) at the origin
/// looking at the OrbitControls target, projected onto the design stage;
/// [center] is moved right by the collapsed-sidebar slide.
@immutable
class _Proj {
  factory _Proj(_V target, double shift) {
    final f = target.unit;
    final r = f.cross(const _V(0, 1, 0)).unit;
    return _Proj._(
      f,
      r,
      r.cross(f),
      Offset(_design.width / 2 + shift, _design.height / 2),
    );
  }

  const _Proj._(this.f, this.r, this.u, this.center);

  final _V f;
  final _V r;
  final _V u;
  final Offset center;

  double depth(_V w) => w.dot(f);
  bool inFront(_V w) => depth(w) > 0.1;

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => _focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final k = scaleAt(w);
    return Offset(center.dx + w.dot(r) * k, center.dy - w.dot(u) * k);
  }
}

/// Each scenario's stars, farthest first (the camera never turns, so the
/// HTML depth order is fixed).
final List<List<_Star>> _byDepth = [
  for (final (stars, target) in [(_s1Stars, _s1Target), (_s2Stars, _s2Target)])
    [
      ...stars,
    ]..sort((a, b) => b.pos.dot(target.unit).compareTo(a.pos.dot(target.unit))),
];

// ================================================================== PAINTING

/// Label chip padding (HTML `.star-label`: px 8, py 2) and badge padding
/// (`px-3 py-1.5`), at a label scale of 1.
const double _labelPadX = 8, _labelPadY = 2, _badgePadX = 12, _badgePadY = 6;

/// Label and badge text sizes (HTML 11 px / 12 px, extra bold).
const double _labelFont = 11, _badgeFont = 12;

/// Paints the HTML Three.js night sky: background stars, constellation
/// figures and lines, the pointer line, the stars with their rings, the
/// labels and badges, the compass and the confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required Listenable repaint,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
    required this.labelRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  /// Labels are kept left of this design x (cards on the right).
  final double labelRight;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _dash = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt;
  final Paint _skyPaint = Paint()..strokeCap = StrokeCap.square;
  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
  final Path _path = Path();

  late Canvas _c;
  late _Proj _p;

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _background(size);
    _figures();
    _lines();
    _stars();
    if (showLabels) _labels();
    if (scene.scenario == 0 && scene.finished) _compass();
    _confetti();
  }

  String _tr(String key) => labTr(_i18n, lang, key);

  // ------------------------------------------------------------ background

  /// HTML `#canvas-wrapper` (#03071e) and the 1600-point starfield, filling
  /// the letterbox around the stage as well.
  void _background(Size size) {
    final s = scene;
    final bleed = labBleed(size);
    _fill
      ..shader = null
      ..color = _Colors.night;
    _c.drawRect(bleed, _fill);
    final key = Object.hash(s.scenario, (s.shift * 4).round(), size);
    var points = s.skyPoints;
    if (points == null || s.skyKey != key) {
      final list = <double>[];
      for (final v in s.sky) {
        if (!_p.inFront(v)) continue;
        final o = _p.p(v);
        if (bleed.contains(o)) list.addAll([o.dx, o.dy]);
      }
      points = s.skyPoints = Float32List.fromList(list);
      s.skyKey = key;
    }
    _skyPaint
      ..color = _Colors.slate400.withValues(alpha: _skyOpacity)
      ..strokeWidth = _skyPointSize * _focal / _skyRadius;
    _c.drawRawPoints(ui.PointMode.points, points, _skyPaint);
  }

  // --------------------------------------------------------------- figures

  /// HTML artwork silhouettes: Ursa Major (step 1 done), Ursa Minor (Pole
  /// Star found), the Hunter (step 2 done) and the Great Dog (Sirius found).
  void _figures() {
    final s = scene;
    if (s.scenario == 0) {
      if (s.step > 1) _figure(_ursaMajor);
      if (s.finished) _figure(_ursaMinor);
    } else {
      if (s.step > 2) _figure(_hunter);
      if (s.finished) _figure(_dog);
    }
  }

  void _figure(_Figure fig) {
    _path.reset();
    for (var i = 0; i < fig.points.length; i++) {
      final o = _p.p(fig.points[i]);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    final shimmer =
        fig.shimmerBase + math.sin(scene.time * _artRate) * fig.shimmerAmp;
    _fill
      ..shader = null
      ..color = fig.fill.withValues(alpha: shimmer.clamp(0.0, 1.0));
    _c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 1.4
      ..color = fig.outline.withValues(alpha: math.min(1, fig.opacity * 2.5));
    _c.drawPath(_path, _stroke);
  }

  // ----------------------------------------------------------------- lines

  /// HTML createLine(): the Big Dipper and its pointer pair, Orion's belt
  /// and body, Canis Major; then the pointer line and the drag guide.
  void _lines() {
    final s = scene;
    if (s.scenario == 0) {
      if (s.step > 1) _chain(_dipperLine, _Colors.yellow500);
      if (s.step > 2) _chain(_pointerLine, _Colors.sky400);
    } else {
      if (s.step > 1) _chain(_beltLine, _Colors.blue400);
      if (s.step > 2) _chain(_bodyLine, _Colors.blue300);
      if (s.finished) _chain(_canisLine, _Colors.blue300);
    }
    if (s.step > 2) _pointerLineExt();
    _guide();
  }

  void _chain(List<String> ids, Color color) {
    _path.reset();
    for (var i = 0; i < ids.length; i++) {
      final o = _p.p(_starById[ids[i]]!.pos);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _stroke
      ..strokeWidth = _lineWidth
      ..color = color;
    _c.drawPath(_path, _stroke);
  }

  /// HTML `s1_polaris_ext` / `s2_sirius_ext`: a dashed line from the first
  /// pointer star through the second. The HTML showed it whole at 4.8x;
  /// here it grows with the slider, with a dot at every whole multiple.
  void _pointerLineExt() {
    final s = scene;
    final ptr = s.pointer;
    final v = s.lineMultiplier;
    final tip = ptr.tip(v);
    final k = _p.scaleAt(tip);
    _dashed(
      _p.p(_starById[ptr.start]!.pos),
      _p.p(tip),
      _extDash * k,
      _extGap * k,
      ptr.color,
      2,
    );
    if (s.step != 3) return;
    _fill
      ..shader = null
      ..color = ptr.color;
    for (var n = 1; n <= v.floor(); n++) {
      _c.drawCircle(_p.p(ptr.tip(n.toDouble())), 3, _fill);
    }
  }

  /// HTML `dragGuideLine`: yellow dashes from the pressed star to the
  /// finger.
  void _guide() {
    final s = scene;
    final from = s.dragFrom, at = s.dragAt;
    if (from == null || at == null) return;
    final star = _starById[from]!;
    final k = _p.scaleAt(star.pos);
    _dashed(
      _p.p(star.pos),
      at,
      _guideDash * k,
      _guideGap * k,
      _Colors.yellow400,
      2,
    );
  }

  void _dashed(
    Offset a,
    Offset b,
    double dash,
    double gap,
    Color color,
    double width,
  ) {
    final d = b - a;
    final len = d.distance;
    if (len < 1 || dash <= 0) return;
    final u = d / len;
    _dash
      ..strokeWidth = width
      ..color = color;
    for (var t = 0.0; t < len; t += dash + gap) {
      _c.drawLine(a + u * t, a + u * math.min(len, t + dash), _dash);
    }
  }

  // ----------------------------------------------------------------- stars

  /// HTML star meshes (flat discs) with their rings, farthest first. Rings
  /// pulse on the stars the current step asks for.
  void _stars() {
    final s = scene;
    final phase = math.sin(s.time * _ringRate);
    for (final star in _byDepth[s.scenario]) {
      final c = _p.p(star.pos);
      final r = star.size * s.scaleOf(star) * _p.scaleAt(star.pos);
      final glow = s.glow(star);
      if (glow > 0) {
        _glow.color = star.color.withValues(alpha: 0.5 * glow);
        _c.drawCircle(c, r * 1.9, _glow);
      }
      final pulse = s.ringPulse(star);
      final ring = r * (pulse == null ? 1 : pulse + phase * _ringAmp);
      final opacity = pulse == null
          ? _ringOpacity
          : _ringOpacity + phase * _ringOpacityAmp;
      _stroke
        ..strokeWidth = ring * (_ringOuter - _ringInner)
        ..color = star.color.withValues(alpha: opacity);
      _c.drawCircle(c, ring * (_ringOuter + _ringInner) / 2, _stroke);
      _fill
        ..shader = null
        ..color = star.color;
      _c.drawCircle(c, r, _fill);
    }
  }

  // ---------------------------------------------------------------- labels

  /// HTML `.star-label` chips and the floating badges.
  void _labels() {
    _layoutLabels();
    for (final chip in scene.placed) {
      final rr = RRect.fromRectAndRadius(
        chip.rect,
        Radius.circular(chip.radius),
      );
      _fill
        ..shader = null
        ..color = chip.fill;
      _c.drawRRect(rr, _fill);
      _stroke
        ..strokeWidth = 1
        ..color = chip.border;
      _c.drawRRect(rr, _stroke);
      chip.text.paint(
        _c,
        chip.rect.center - Offset(chip.text.width / 2, chip.text.height / 2),
      );
    }
  }

  /// Places the badges at their anchors, then each star label beside its
  /// star (above, as in the HTML, unless that covers another label, badge
  /// or star). Cached until the step, language, scale or framing changes.
  void _layoutLabels() {
    final s = scene;
    final k = labelScale;
    final key = Object.hash(
      s.scenario,
      s.step,
      lang,
      k,
      s.shift.round(),
      labelRight.round(),
    );
    if (s.labelKey == key) return;
    s
      ..labelKey = key
      ..placed.clear();
    final taken = <Rect>[];
    final discs = <(String, Rect)>[
      for (final star in s.stars)
        (
          star.id,
          Rect.fromCircle(
            center: _p.p(star.pos),
            radius:
                star.size *
                _ringOuter *
                s.restScale(star) *
                _p.scaleAt(star.pos),
          ),
        ),
    ];
    // The pointer line (from the first pointer star to the target star),
    // which the learner watches grow in step 3.
    final line = <Rect>[];
    if (s.step > 2) {
      final ptr = s.pointer;
      final a = _p.p(_starById[ptr.from]!.pos);
      final b = _p.p(_starById[ptr.target]!.pos);
      final n = math.max(1, ((b - a).distance / _lineStep).floor());
      for (var i = 0; i <= n; i++) {
        line.add(
          Rect.fromCenter(
            center: Offset.lerp(a, b, i / n)!,
            width: _lineDot,
            height: _lineDot,
          ),
        );
      }
    }
    if (s.scenario == 0 && s.finished) taken.add(_compassRect());
    // The Pointer Distance Tool / tool column on the right.
    taken.add(
      Rect.fromLTRB(
        labelRight,
        -_design.height,
        3 * _design.width,
        2 * _design.height,
      ),
    );
    for (final b in s.badges) {
      final tp = texts.get(
        _tr(b.key),
        size: _badgeFont * k,
        color: b.text,
        weight: FontWeight.w800,
      );
      final rect = Rect.fromCenter(
        center: _p.p(b.at),
        width: tp.width + 2 * _badgePadX * k,
        height: tp.height + 2 * _badgePadY * k,
      );
      taken.add(rect);
      s.placed.add(_Placed(tp, rect, b.fill, b.border, 12 * k));
    }
    for (final id in s.labelled) {
      final star = _starById[id]!;
      final tp = texts.get(
        _tr(s.nameKey(id)),
        size: _labelFont * k,
        color: _Colors.white,
        weight: FontWeight.w800,
      );
      final w = tp.width + 2 * _labelPadX * k;
      final h = tp.height + 2 * _labelPadY * k;
      final c = _p.p(star.pos);
      final r = star.size * s.restScale(star) * _p.scaleAt(star.pos);
      final side = r + 4 * k;
      // HTML: the chip's bottom sits 12 px above the star's centre.
      final up = math.max(12.0, side);
      final options = [
        Rect.fromLTWH(c.dx - w / 2, c.dy - up - h, w, h),
        Rect.fromLTWH(c.dx - w / 2, c.dy + side, w, h),
        Rect.fromLTWH(c.dx + side, c.dy - h / 2, w, h),
        Rect.fromLTWH(c.dx - side - w, c.dy - h / 2, w, h),
        Rect.fromLTWH(c.dx + side * 0.7, c.dy - up - h, w, h),
        Rect.fromLTWH(c.dx - side * 0.7 - w, c.dy - up - h, w, h),
        Rect.fromLTWH(c.dx + side * 0.7, c.dy + side, w, h),
        Rect.fromLTWH(c.dx - side * 0.7 - w, c.dy + side, w, h),
      ];
      var best = options.first;
      var bestCost = double.infinity;
      for (var i = 0; i < options.length; i++) {
        final o = options[i];
        // A small preference for the HTML's place and the nearer sides.
        var cost = i * 0.5;
        for (final t in taken) {
          cost += _overlap(o, t);
        }
        for (final (other, disc) in discs) {
          if (other != id) cost += 2 * _overlap(o, disc);
        }
        for (final dot in line) {
          cost += _lineWeight * _overlap(o, dot);
        }
        if (cost < bestCost) {
          bestCost = cost;
          best = o;
        }
      }
      taken.add(best);
      s.placed.add(
        _Placed(
          tp,
          best,
          _Colors.labelBg,
          _Colors.indigo500.withValues(alpha: 0.5),
          8 * k,
        ),
      );
    }
  }

  static double _overlap(Rect a, Rect b) {
    final i = a.intersect(b);
    return i.width > 0 && i.height > 0 ? i.width * i.height : 0;
  }

  // --------------------------------------------------------------- compass

  TextPainter _compassText() {
    final text = _tr('compass_north');
    return texts.get(
      text,
      size: _badgeFont * labelScale,
      color: _Colors.white,
      weight: FontWeight.w900,
      letterSpacing: labLetterSpacing(text, 1.2),
    );
  }

  Rect _compassRect() {
    final k = labelScale;
    final tp = _compassText();
    final icon = 20 * k;
    return Rect.fromCenter(
      center: _p.p(_compassAt),
      width: 12 * k + icon + 8 * k + tp.width + 14 * k,
      height: math.max(icon, tp.height) + 16 * k,
    );
  }

  /// HTML `#compass-rose-box`: a dark chip with a red compass and "NORTH
  /// (TOWARDS POLE STAR)", bouncing once a second (`animate-bounce`).
  void _compass() {
    final k = labelScale;
    final tp = _compassText();
    final bounce = -0.25 * 20 * k * (math.cos(scene.time * math.pi)).abs();
    final rect = _compassRect().shift(Offset(0, bounce));
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(16 * k));
    _fill
      ..shader = null
      ..color = _Colors.slate900.withValues(alpha: 0.9);
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1.2
      ..color = _Colors.indigo500.withValues(alpha: 0.5);
    _c.drawRRect(rr, _stroke);
    // Compass: a ring with its needle, north (red) up.
    final ic = Offset(rect.left + 12 * k + 10 * k, rect.center.dy);
    final ir = 9 * k;
    _stroke
      ..strokeWidth = 2 * k
      ..color = _Colors.red500;
    _c.drawCircle(ic, ir, _stroke);
    _path
      ..reset()
      ..moveTo(ic.dx, ic.dy - ir * 0.75)
      ..lineTo(ic.dx + ir * 0.3, ic.dy)
      ..lineTo(ic.dx - ir * 0.3, ic.dy)
      ..close();
    _fill.color = _Colors.red500;
    _c.drawPath(_path, _fill);
    _path
      ..reset()
      ..moveTo(ic.dx, ic.dy + ir * 0.75)
      ..lineTo(ic.dx + ir * 0.3, ic.dy)
      ..lineTo(ic.dx - ir * 0.3, ic.dy)
      ..close();
    _fill.color = _Colors.slate300;
    _c.drawPath(_path, _fill);
    tp.paint(
      _c,
      Offset(
        rect.left + 12 * k + 20 * k + 8 * k,
        rect.center.dy - tp.height / 2,
      ),
    );
  }

  // -------------------------------------------------------------- confetti

  /// HTML `confetti(...)` when Scenario 2's conclusion opens.
  void _confetti() {
    final s = scene;
    final t0 = s.confettiStart;
    if (t0 == null) return;
    final ticks = (s.time - t0) * 60;
    if (ticks >= _confettiTicks) return;
    final fade = 1 - ticks / _confettiTicks;
    final reach =
        (1 - math.pow(_confettiDecay, ticks).toDouble()) / (1 - _confettiDecay);
    final fall = _confettiGravity * ticks;
    _fill.shader = null;
    for (final c in s.confetti) {
      final d = c.velocity * reach;
      final x = _confettiOrigin.dx + math.cos(c.angle) * d;
      final y = _confettiOrigin.dy + math.sin(c.angle) * d + fall;
      _c
        ..save()
        ..translate(x, y)
        ..rotate(c.spin * ticks);
      _c.drawRect(
        const Rect.fromLTWH(-5, -3, 10, 6),
        _fill..color = c.color.withValues(alpha: fade),
      );
      _c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.texts != texts ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale ||
      old.labelRight != labelRight;
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
    final key =
        '$text|$size|${color.toARGB32()}|${weight.value}|$letterSpacing';
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
