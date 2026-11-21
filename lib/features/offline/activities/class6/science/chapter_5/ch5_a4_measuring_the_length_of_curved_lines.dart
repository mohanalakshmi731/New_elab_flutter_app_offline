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

/// Class 6 Science • Chapter 5 • Activity 4
/// Measuring the Length of Curved Lines.
///
/// Native Flutter port of
/// `Cl6S-Ch5-A4-Measuring_the_Length_of_Curved_Lines.html`.
///
/// Scenario 1 (Decorating the Archway): tap the box of string lights to get
/// a ball of thread, anchor the thread at the start of the curved archway,
/// trace the whole curve with the ball, cut the thread, drop it on the metre
/// scale and read the straightened length (0.88 m).
///
/// Scenario 2 (Measuring a Leaf's Edge): the same steps along the right edge
/// of a leaf, read on a 15-cm ruler (11.4 cm).
class Ch5A4MeasuringTheLengthOfCurvedLinesPage extends StatefulWidget {
  const Ch5A4MeasuringTheLengthOfCurvedLinesPage({super.key});

  @override
  State<Ch5A4MeasuringTheLengthOfCurvedLinesPage> createState() =>
      _Ch5A4MeasuringTheLengthOfCurvedLinesPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three tones with WebAudio:
/// 'pop' (every step, button and toggle), 'success' and 'snip'.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// success → `math/success.mp3`, snip → `science/click.mp3`,
/// wrong → `science/error.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`: each completed step, every button, toggle,
  /// scenario change and the intro curtain.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('success')`: thread anchored, curve traced, thread on
  /// the scale, reading shown, summary popup.
  success('audio/class6/math/success.mp3'),

  /// HTML `playSound('snip')` (a 0.1 s 800 → 1200 Hz chirp). There is no
  /// scissors sound in `assets/audio/`; the short click is the closest.
  snip('audio/class6/science/click.mp3'),

  /// A drop away from the green marker (the HTML is silent here; the
  /// shell's error tone goes with its error toast).
  wrong('audio/class6/science/error.mp3');

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

/// Tailwind colours used by the HTML (UI, Three.js materials, labels).
abstract final class _Colors {
  /// ZSL yellow (`zsl.yellow`): Enter Lab, highlights, Scenario 1's ball of
  /// thread (0xeab308).
  static const Color zslYellow = Color(0xFFEAB308);

  /// The thread line (LineBasicMaterial 0xffea00).
  static const Color thread = Color(0xFFFFEA00);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);

  /// Highlight glow of the object to use (emissive 0x4f46e5).
  static const Color indigo600 = Color(0xFF4F46E5);

  /// Drop marker ring (0x4ade80).
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);

  /// Leaf (0x14532d), its midrib and its stem.
  static const Color green900 = Color(0xFF14532D);
  static const Color green700 = Color(0xFF15803D);
  static const Color lime800 = Color(0xFF3F6212);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald600 = Color(0xE6059669); // bg-emerald-600/90
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber500 = Color(0xE6F59E0B); // bg-amber-500/90

  /// Box of string lights (0xc2410c).
  static const Color orange700 = Color(0xFFC2410C);

  /// Scenario 2's ball of thread (0xef4444) and the highlight blink.
  static const Color red500 = Color(0xFFEF4444);

  /// Archway walls (0xd6d3d1).
  static const Color stone300 = Color(0xFFD6D3D1);

  /// Ruler texture: background #f8fafc, marks #0f172a.
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);

  /// Arch guide line (0x64748b).
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  /// Scene label chip (`bg-slate-900/90`).
  static const Color labelBg = Color(0xE60F172A);

  /// Start / End label border (`border-indigo-500/50`).
  static const Color labelBorder = Color(0x806366F1);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xE60F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The canvas follows the theme like the HTML `setTheme()`:
/// #020617 in dark mode, #e2e8f0 in light mode.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.green400, // completed steps (dark:text-green-400)
    popupBg: _Colors.slate900, // summary modal bg-slate-900
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
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
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.white,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate200,
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
/// the app font, which includes Devanagari for Hindi. Sizes are the HTML
/// sidebar font slider (12–22 px, default 15 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The
/// HTML plays its 'pop' for every UI action (buttons, toggles, scenario
/// change, Enter Lab).
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.pop,
  wrong: _Sound.wrong,
  success: _Sound.success,
  scenario: _Sound.pop,
  curtain: _Sound.pop,
  dark: _Theme.dark,
  light: _Theme.light,
  font: _font,
  releaseAudio: _Audio.release,
);

// =================================================================== STRINGS
//
// Copied from the HTML `i18n` and `ScenariosData` tables (Telugu dropped).
// Changes, each because the HTML text contradicted its own simulation:
// the subtitle's "Measurment" typo; Scenario 1's reading is 0.88 m (the
// traced arch is 10.56 units long on a 12-unit = 100 cm metre scale; the
// HTML's "1.2 m" is longer than the scale itself); "aligned against a metre
// scale" became "a measuring scale" (Scenario 2 uses the 15-cm ruler); the
// Hindi S2 step 1 no longer mentions a table (there is none). The toasts
// were English-only in the HTML and gained Hindi.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Measuring the Length of Curved Lines',
    'app_subtitle': 'Class 6 • Measurement of Length and Motion',
    'scen_1_opt': 'Scenario 1: Decorating the Archway',
    'scen_2_opt': "Scenario 2: Measuring a Leaf's Edge",
    's1_desc':
        'To find the exact length of string lights needed to decorate a curved archway.',
    's2_desc':
        'To measure the length of the curved edge of a leaf using a thread and a 15-cm scale.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1':
        'Rigid rulers cannot measure curved archways directly; a flexible tool like thread is needed first.',
    's1_a1': 'CLICK on the highlighted box of string lights to begin.',
    's1_o1':
        'A ball of thread appears on the screen, representing a tool to measure the arch before cutting the lights.',
    's1_c2':
        'Anchoring the starting point ensures measurement begins exactly at the boundary origin.',
    's1_a2':
        'DRAG the highlighted thread and DROP it onto the green starting point of the archway.',
    's1_o2':
        "The end of the thread 'snaps' and sticks firmly to the starting point of the arch.",
    's1_c3':
        'Flexible thread conforms to irregular curves, matching the exact path length.',
    's1_a3':
        'DRAG the thread ball along the entire curve of the archway to its bottom-right corner.',
    's1_o3':
        'The thread unspools and lays perfectly along the curve of the archway.',
    's1_c4':
        'Detaching the traced segment preserves the exact contour length of the archway.',
    's1_a4':
        'CLICK on the scissors icon to cut the thread at the end of the arch.',
    's1_o4':
        'The measured segment of thread detaches from the ball and exists as a separate curved object.',
    's1_c5':
        'Transferring the curved thread to a standard straight measuring instrument allows reading.',
    's1_a5':
        'DRAG the highlighted curved thread and DROP it on the green marker next to the metre scale.',
    's1_o5':
        'The thread is moved from the archway and positioned near the standard measuring tool.',
    's1_c6':
        'Converting curved arc length to a straight line along a standard scale gives accurate measurement.',
    's1_a6':
        'Wait for the thread to straighten against the scale and READ the measurement.',
    's1_o6':
        "The thread transforms into a straight line aligned with '0'. Final length = 0.88 m (88 cm), and the archway lights up!",
    // Scenario 2 steps.
    's2_c1':
        'Biological specimens like leaves have curved edges that require flexible thread tracing.',
    's2_a1':
        'CLICK on the highlighted ball of thread placed next to the fallen leaf.',
    's2_o1':
        'The thread becomes active and ready for measuring the leaf outline.',
    's2_c2':
        'Precise placement at the leaf tip sets the zero reference point for tracing.',
    's2_a2':
        'DRAG the highlighted thread and DROP it onto the green tip of the leaf.',
    's2_o2': "The thread anchors securely to the leaf's tip starting point.",
    's2_c3':
        'Tracing along the biological curve captures its non-linear perimeter accurately.',
    's2_a3':
        'Carefully DRAG the thread ball along the right edge of the leaf down to the stem.',
    's2_o3':
        'A segment of thread dynamically sticks to and traces the curved outline of the leaf edge.',
    's2_c4':
        'Cutting the thread isolates the specific perimeter segment corresponding to the leaf edge.',
    's2_a4': 'CLICK the scissors icon to cut the thread at the stem junction.',
    's2_o4':
        "A 'snip' sound plays and the curved thread segment becomes a separate movable object.",
    's2_c5':
        'Aligning the traced object with a standard 15-cm ruler prepares it for numerical readout.',
    's2_a5':
        'DRAG the highlighted curved thread and DROP it onto the green marker on the 15-cm scale.',
    's2_o5':
        'The thread positions perfectly next to the clear centimetre and millimetre markings.',
    's2_c6':
        'Straightening the thread against the markings converts curved edge length into centimetres.',
    's2_a6': 'Wait for the thread to straighten and READ the magnified length.',
    's2_o6':
        'The thread aligns horizontally. Final measurement = 11.4 cm, converting curve to measurable length!',
    // Toasts (HTML `showToast`).
    'toast_tool': 'Tool ready! Drag it to the marker.',
    'toast_anchored': 'Anchored! Now trace along the curve.',
    'toast_traced': 'Traced perfectly! Cut the thread.',
    'toast_cut': 'Thread cut! Drag the curved line to the scale.',
    'err_marker': 'Drag directly to the highlighted green marker!',
    'err_scale':
        'Drop it directly on the highlighted green marker on the scale!',
    // Scene labels (HTML `#labels-container`) and the scissors button.
    'lbl_start': 'Start Point',
    'lbl_end': 'End Point',
    'lbl_arch': 'Arch Curve',
    'lbl_leaf': 'Leaf Curve',
    'lbl_mscale': 'Metre Scale (100 cm)',
    'lbl_cscale': '15-cm Ruler',
    'reading_s1': 'Reading: 0.88 m',
    'reading_s2': 'Reading: 11.4 cm',
    'cut_thread': 'Cut Thread',
    'scene_s1':
        'A stone archway, a box of string lights, a ball of thread and a metre scale',
    'scene_s2': 'A leaf, a red ball of thread and a 15-cm ruler',
    // Summary popups.
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete': 'All Scenarios Completed!',
    'all_complete_desc':
        'You have successfully mastered measuring curved lines using flexible thread and aligning it against a measuring scale!',
    // Teacher board "Conceptual Exploration" list.
    'concept_exp': 'Conceptual Exploration',
    'exploration': 'Exploration',
    'concept_focus': 'Concept Focus',
    'action': 'Action',
    'observation': 'Observation',
  },
  'hi': {
    'app_title': 'वक्र रेखा का मापन',
    'app_subtitle': 'कक्षा 6 • लंबाई और गति का मापन',
    'scen_1_opt': 'परिदृश्य 1: मेहराब की सजावट',
    'scen_2_opt': 'परिदृश्य 2: पत्ती के किनारे का मापन',
    's1_desc':
        'वक्र मेहराब को सजाने के लिए आवश्यक लड़ी की सटीक लंबाई ज्ञात करना।',
    's2_desc':
        'धागे और 15-सेमी पैमाने का उपयोग करके पत्ती के वक्र किनारे की लंबाई मापना।',
    's1_c1':
        'सीधे पैमाने मेहराब को नहीं माप सकते; पहले लचीले माध्यम की आवश्यकता होती है।',
    's1_a1': 'प्रारंभ करने के लिए लड़ी के हाइलाइट किए गए बॉक्स पर क्लिक करें।',
    's1_o1': 'स्क्रीन पर धागे का एक गोला प्रकट होता है।',
    's1_c2': 'प्रारंभिक बिंदु को स्थिर करने से मापन ठीक शुरुआत से होता है।',
    's1_a2':
        'हाइलाइट किए गए धागे को खींचकर मेहराब के हरे प्रारंभिक बिंदु पर छोड़ें।',
    's1_o2': 'धागे का सिरा मेहराब के प्रारंभिक बिंदु पर चिपक जाता है।',
    's1_c3': 'लचीला धागा मेहराब के हर मोड़ के अनुसार ढल जाता है।',
    's1_a3':
        'धागे के गोले को खींचकर मेहराब के वक्र पर निचले-दाएं कोने तक ले जाएं।',
    's1_o3': 'धागा मेहराब के वक्र पर पूरी तरह बिछ जाता है।',
    's1_c4': 'मापे गए हिस्से को काटने से मेहराब की सटीक लंबाई प्राप्त होती है।',
    's1_a4': 'धागे को काटने के लिए कैंची के आइकन पर क्लिक करें।',
    's1_o4': 'धागे का मापा गया टुकड़ा एक स्वतंत्र वक्र वस्तु बन जाता है।',
    's1_c5':
        'वक्र धागे को सीधे मापक पैमाने के पास ले जाने से मापन संभव होता है।',
    's1_a5': 'वक्र धागे को खींचकर मीटर पैमाने के पास हरे मार्कर पर छोड़ें।',
    's1_o5': 'धागा मेहराब से हटकर मीटर पैमाने के पास आ जाता है।',
    's1_c6': 'वक्र लंबाई को सीधी रेखा में बदलने से सटीक माप मिलती है।',
    's1_a6': 'पैमाने पर सीधे हुए धागे को देखें और पाठ्यांक (माप) पढ़ें।',
    's1_o6':
        "धागा सीधा होकर '0' निशान से संरेखित होता है। कुल लंबाई = 0.88 मीटर (88 सेमी), और मेहराब पर रोशनी जगमगाने लगती है!",
    's2_c1':
        'पत्तियों के किनारे मुड़े होते हैं जिन्हें मापने के लिए लचीले धागे की आवश्यकता होती है।',
    's2_a1':
        'गिरी हुई पत्ती के पास रखे धागे के हाइलाइट किए गए गोले पर क्लिक करें।',
    's2_o1':
        'धागा सक्रिय हो जाता है और पत्ती की रूपरेखा मापने के लिए तैयार है।',
    's2_c2': 'पत्ती के सिरे पर सटीक बिंदु मापन का प्रारंभिक संदर्भ तय करता है।',
    's2_a2': 'हाइलाइट किए गए धागे को खींचकर पत्ती के हरे ऊपरी सिरे पर छोड़ें।',
    's2_o2': 'धागा पत्ती के प्रारंभिक बिंदु पर मजबूती से जुड़ जाता है।',
    's2_c3':
        'प्राकृतिक वक्र के साथ अनुरेखण करने से उसकी सटीक परिधि प्राप्त होती है।',
    's2_a3':
        'धागे के गोले को सावधानी से पत्ती के दाएं किनारे के साथ डंठल तक खींचें।',
    's2_o3': 'धागे का टुकड़ा पत्ती के वक्र किनारे के साथ चिपक जाता है।',
    's2_c4': 'धागे को काटने से पत्ती के किनारे की सटीक परिधि अलग हो जाती है।',
    's2_a4': 'डंठल के पास धागा काटने के लिए कैंची के आइकन पर क्लिक करें।',
    's2_o4': 'वक्र धागा एक स्वतंत्र वस्तु बन जाता है।',
    's2_c5':
        'मापे गए धागे को पैमाने के साथ संरेखित करने से संख्यात्मक माप मिलती है।',
    's2_a5':
        'वक्र धागे के टुकड़े को खींचकर 15-सेमी पैमाने पर हरे मार्कर पर छोड़ें।',
    's2_o5': 'धागा स्पष्ट निशानों के ठीक बगल में आ जाता है।',
    's2_c6':
        'निशानों के समानांतर धागे को सीधा करने से वक्र लंबाई सेंटीमीटर में बदल जाती है।',
    's2_a6': "'0' निशान से शुरू होने वाले सीधे धागे को देखें और माप पढ़ें।",
    's2_o6': 'अंतिम माप = 11.4 सेमी, वक्र रेखा सीधी माप में बदल गई!',
    'toast_tool': 'उपकरण तैयार! इसे हरे मार्कर तक खींचें।',
    'toast_anchored': 'धागे का सिरा जुड़ गया! अब वक्र के साथ-साथ खींचें।',
    'toast_traced': 'अनुरेखण पूरा हुआ! अब धागा काटें।',
    'toast_cut': 'धागा कट गया! अब वक्र धागे को पैमाने तक खींचें।',
    'err_marker': 'धागे को सीधे हाइलाइट किए गए हरे मार्कर तक खींचें!',
    'err_scale': 'इसे पैमाने पर हाइलाइट किए गए हरे मार्कर पर ही छोड़ें!',
    'lbl_start': 'प्रारंभिक बिंदु',
    'lbl_end': 'अंतिम बिंदु',
    'lbl_arch': 'मेहराब वक्र',
    'lbl_leaf': 'पत्ती का वक्र',
    'lbl_mscale': 'मीटर पैमाना (100 सेमी)',
    'lbl_cscale': '15-सेमी पैमाना',
    'reading_s1': 'पाठ्यांक: 0.88 मीटर',
    'reading_s2': 'पाठ्यांक: 11.4 सेमी',
    'cut_thread': 'धागा काटें',
    'scene_s1': 'पत्थर का मेहराब, लड़ी का बॉक्स, धागे का गोला और मीटर पैमाना',
    'scene_s2': 'एक पत्ती, धागे का लाल गोला और 15-सेमी पैमाना',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete': 'सभी परिदृश्य पूर्ण हुए!',
    'all_complete_desc':
        'आपने लचीले धागे का उपयोग करके वक्र रेखाओं को मापने और उन्हें पैमाने पर सही ढंग से पढ़ने में महारत हासिल कर ली है!',
    'concept_exp': 'वैचारिक अन्वेषण',
    'exploration': 'अन्वेषण',
    'concept_focus': 'मुख्य अवधारणा',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML `ScenariosData`:
/// six steps of concept / action / observation per scenario).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      LabScenarioData scenario(int n) => LabScenarioData(
        title: t('scen_${n}_opt'),
        objective: t('s${n}_desc'),
        steps: [
          for (var i = 1; i <= _stepCount; i++)
            LabStep(
              concept: t('s${n}_c$i'),
              action: t('s${n}_a$i'),
              observation: t('s${n}_o$i'),
            ),
        ],
      );
      return [scenario(1), scenario(2)];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// Steps per scenario (HTML `steps`), and the value of `step` once the
/// reading is shown (the scenario is finished).
const int _stepCount = 6;
const int _doneStep = _stepCount + 1;

/// Smallest touch target (logical px) and the scene drags' touch slop
/// (Flutter's default is 18 px; short drags must pick objects up).
const double _minTouch = 48;
const DeviceGestureSettings _dragSettings = DeviceGestureSettings(touchSlop: 8);

// ------------------------------------------------------------------ camera
// HTML `init3D()`: PerspectiveCamera(45°) at (0, 3, 16); OrbitControls
// target (0, 0, 0); the camera stays locked.

const _V _eye = _V(0, 3, 16);

/// 280 / tan(22.5°): the 45° vertical field of view over the 560 px stage.
const double _focal = 675.98;
const Offset _stageCentre = Offset(500, 280);

/// Scenario 2 view. The HTML leaf tip (y 5.8) sits at the very top of the
/// view, where Flutter's toasts appear, and its ruler label under the HUD:
/// the leaf scene is drawn a little smaller and lower.
const double _leafViewZoom = 0.92;
const double _leafViewDrop = 45;

/// Horizontal extent (design px, home view) of each scenario's objects and
/// labels. While the sidebar is collapsed the floating mission card covers
/// the top-left of the canvas, so the scene slides (and if needed shrinks)
/// into the room between the card and the tool column, easing over 380 ms
/// like the sidebar.
const (double, double) _s1Extent = (138, 778);
const (double, double) _s2Extent = (255, 720);
const double _framingSeconds = 0.38;

/// LAB FRAMEWORK: the floating mission card's left edge (beside the menu
/// button) and the gap kept from it and from the tool column.
const double _missionCardLeft = 76;
const double _cardGap = 12;

/// Canvas text stays readable when the stage is scaled down (same rule as
/// the Chapter 4 labs).
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

// --------------------------------------------------------------- scenario 1
// HTML `buildScenario1()`.

/// Archway: two 2 × 4 × 1 pillars and a 10 × 2 × 1 top (MeshStandardMaterial
/// 0xd6d3d1).
const _V _pillarLeft = _V(-4, 2, 0);
const _V _pillarRight = _V(4, 2, 0);
const _V _pillarHalf = _V(1, 2, 0.5);
const _V _archTop = _V(0, 5, 0);
const _V _archTopHalf = _V(5, 1, 0.5);

/// Front face of the archway walls (z = 0.5).
const double _wallFrontZ = 0.5;

/// The arch curve: CatmullRomCurve3 through these points, `getPoints(100)`.
const List<_V> _archControl = [
  _V(-3, 1, 0.6),
  _V(-3, 3, 0.6),
  _V(0, 4, 0.6),
  _V(3, 3, 0.6),
  _V(3, 1, 0.6),
];
const int _pathDivisions = 100;

/// Box of string lights (2 × 1.5 × 2, 0xc2410c) and the ball of thread that
/// appears on it (sphere r 0.5 at the box + (0, 1.5, 0), 0xeab308).
const _V _lightsBoxCentre = _V(-6, -1, 2);
const _V _lightsBoxHalf = _V(1, 0.75, 1);
const _V _ball1Home = _V(-6, 0.5, 2);
const double _ball1Radius = 0.5;

/// Metre scale: 12 × 0.5 × 1.5 box at (0, -3, 1) with 100 cm marks.
const double _metreHalfWidth = 6;
const double _cmPerUnitMetre = 100 / 12;

// --------------------------------------------------------------- scenario 2
// HTML `buildScenario2()`.

/// The leaf: two quadratic curves from the tip (0, 5.8) round (±3, 2.8) to
/// the base (0, -1.2); the traced right edge is the same curve at z 0.4.
const _V _leafTip = _V(0, 5.8, 0.4);
const _V _leafControl = _V(3, 2.8, 0.4);
const _V _leafBase = _V(0, -1.2, 0.4);

/// The leaf is scaled by ~0.976 about its middle so that its right edge is
/// exactly the 11.4 cm the HTML reads on the 15-cm ruler (the HTML's own
/// edge measured 11.7 cm on its ruler).
const _V _leafMiddle = _V(0, 2.3, 0.4);
const double _leafEdgeCm = 11.4;

/// Front of the extruded leaf (depth 0.1 + bevel 0.05).
const double _leafFaceZ = 0.15;

/// Scenario 2's ball of thread (sphere r 0.4 at (4, 0.8, 1), 0xef4444).
const _V _ball2Home = _V(4, 0.8, 1);
const double _ball2Radius = 0.4;

/// 15-cm ruler: 10 × 0.5 × 1.5 box at (0, -3, 1).
const double _rulerHalfWidth = 5;
const double _cmPerUnitRuler = 15 / 10;

// ------------------------------------------------------------------- shared

/// Both scales: centre (0, -3, 1), 0.5 tall, 1.5 deep.
const double _scaleY = -3;
const double _scaleZ = 1;
const _V _scaleCentre = _V(0, _scaleY, _scaleZ);
const double _scaleHalfHeight = 0.25;
const double _scaleHalfDepth = 0.75;

/// Drop marker on the scale (HTML: scale.position + (0, 0.5, 0)).
const _V _scaleTarget = _V(0, -2.5, 1);

/// Drop marker ring: RingGeometry(0.5, 0.8), pulsing ×(1 ± 0.2).
const double _ringMid = 0.65;
const double _ringWidth = 0.3;
const double _ringPulse = 0.2;

/// HTML pulses (highlight, ring, blink) run at `Date.now() * 0.005`.
const double _pulseRate = 5;

/// Step 2: the ball anchors when dropped within this distance (x, y) of the
/// start point. The HTML's 4 units let a plain click on Scenario 1's ball
/// (3.04 units from the start) anchor it without any drag.
const double _anchorRadius = 1.5;

/// Step 3: the thread follows the ball while it is within this distance of
/// the curve (at least 20 dp on screen), and only from the part already
/// traced onwards (at most [_traceWindow] points ahead or back). The HTML
/// took the nearest point anywhere within 1.5 units, so a straight drag
/// along the bottom of the archway (or down the leaf's midrib) "traced"
/// the whole curve.
const double _traceTolerance = 0.8;
const double _traceTouchDp = 20;
const int _traceWindow = 10;

/// Step 5: the thread can be picked up within this distance of it (HTML
/// line raycast threshold 3 units, which reached across the whole arch
/// opening); it lands on the scale when dropped within [_scaleDropRadius]
/// of the marker after moving at least [_scaleMinMove]. The HTML accepted
/// anything within 8 units, so a click on the thread where it lay passed.
const double _threadReach = 1.0;
const double _scaleDropRadius = 2.0;
const double _scaleMinMove = 0.5;

/// Where a dragged object may go (keeps it on screen).
const double _dragLimitX = 9;
const double _dragMinY = -4.5;
const double _dragMaxY = 6.5;

/// Step 6: the straightened thread lies on the top face of the scale, from
/// its '0' end, between the marks and the numbers.
const double _straightY = -2.74;
const double _straightZ = 0.8;

/// Step 5: the dropped thread glides onto the marker and settles with its
/// lowest point just above the scale's top (the HTML centred it on the
/// marker, so the tall leaf thread hung through the ruler and off the
/// stage).
const double _threadRestGap = 0.05;

// ------------------------------------------------------------------ timings
// HTML TWEEN durations and setTimeouts.

const double _anchorTween = 0.3; // to the start point, Quadratic.Out
const Duration _anchorDelay = Duration(milliseconds: 350);
const double _returnTween = 0.5; // back after a missed drop, linear
const double _scaleTween = 0.4; // onto the marker, Quadratic.Out
const Duration _scaleDelay = Duration(milliseconds: 450);
const double _straightenTime = 1.5; // Cubic.InOut
const Duration _popupDelay = Duration(milliseconds: 2000);

/// The reading label pops in (Tailwind `transition-all`, 150 ms from
/// scale 0.5) and the archway's lights fade in.
const double _readingPop = 0.15;
const double _lightsFade = 0.6;

// ------------------------------------------------------------------- paths

/// The arch curve (HTML `archPathPoints`).
final List<_V> _archPath = _catmullRom(_archControl, _pathDivisions);
final List<double> _archCumulative = _cumulative(_archPath);

/// The leaf's right edge (HTML `leafPathPoints`), scaled to 11.4 cm.
final List<_V> _leafPath = _leafCurve(true);
final List<double> _leafCumulative = _cumulative(_leafPath);

/// The leaf's left edge (painting only).
final List<_V> _leafLeftEdge = _leafCurve(false);

/// The leaf outline on its front face (every 4th edge point).
final List<_V> _leafOutline = [
  for (var i = 0; i < _leafPath.length; i += _outlineStride)
    _leafPath[i].withZ(_leafFaceZ),
  _leafPath.last.withZ(_leafFaceZ),
  for (var i = _leafLeftEdge.length - 1; i >= 0; i -= _outlineStride)
    _leafLeftEdge[i].withZ(_leafFaceZ),
];
const int _outlineStride = 4;

/// The leaf's midrib (tip to base) and four pairs of veins, on its face.
final List<(_V, _V)> _leafVeins = () {
  final tip = _leafPath.first.withZ(_leafFaceZ);
  final base = _leafPath.last.withZ(_leafFaceZ);
  return [
    (tip, base),
    for (var i = 1; i <= _veinPairs; i++)
      for (final edge in [_leafPath, _leafLeftEdge])
        () {
          final t = i / (_veinPairs + 1);
          final mid = _V.lerp(tip, base, t + _veinLag);
          final e = edge[(t * _pathDivisions).round()].withZ(_leafFaceZ);
          return (mid, _V.lerp(mid, e, _veinReach));
        }(),
  ];
}();
const int _veinPairs = 4;
const double _veinLag = 0.06, _veinReach = 0.8;

/// The short stem below the leaf's base (the steps trace "down to the
/// stem"; the HTML model has none).
const _V _stemReach = _V(0.08, -0.6, 0);

/// The arch curve on the wall's front face (the wall above it fills the
/// corners of the square opening).
final List<_V> _archOnWall = [for (final q in _archPath) q.withZ(_wallFrontZ)];

/// String-light bulbs along the arch, just in front of the curve.
final List<_V> _archBulbs = [
  for (var i = 0; i < _archPath.length; i += _bulbEvery)
    _archPath[i].withZ(_bulbZ),
];
const int _bulbEvery = 4;
const double _bulbZ = 0.65;
const double _bulbRadius = 0.11;

/// The box of string lights: a sagging wire across its front face, inset
/// from its sides and below its top, with five bulbs hanging from it.
const double _wireInset = 0.2, _wireDrop = 0.2, _wireSag = 0.18;
const double _boxBulbDrop = 0.13, _boxBulbRadius = 0.09;
const int _boxBulbs = 5, _wireSegments = 10;
_V _wireAt(double t) {
  const c = _lightsBoxCentre, h = _lightsBoxHalf;
  return _V(
    c.x - h.x + _wireInset + (2 * h.x - 2 * _wireInset) * t,
    c.y + h.y - _wireDrop - _wireSag * math.sin(math.pi * t),
    c.z + h.z + 0.01, // just in front of the face
  );
}

final List<_V> _boxWire = [
  for (var i = 0; i <= _wireSegments; i++) _wireAt(i / _wireSegments),
];
final List<_V> _boxBulbPoints = [
  for (var i = 0; i < _boxBulbs; i++)
    _wireAt((i + 0.5) / _boxBulbs) + const _V(0, -_boxBulbDrop, 0),
];

/// Leaf edge scale factor (see [_leafMiddle]).
final double _leafScale =
    (_leafEdgeCm / _cmPerUnitRuler) / _cumulative(_rawLeafEdge(true)).last;

/// HTML QuadraticBezierCurve3(tip, (±3, 2.8), base).getPoints(100); the
/// left edge for [right] false.
List<_V> _rawLeafEdge(bool right) {
  final c = right
      ? _leafControl
      : _V(-_leafControl.x, _leafControl.y, _leafControl.z);
  return [
    for (var i = 0; i <= _pathDivisions; i++)
      _quadBezier(_leafTip, c, _leafBase, i / _pathDivisions),
  ];
}

List<_V> _leafCurve(bool right) => [
  for (final p in _rawLeafEdge(right))
    _leafMiddle + (p - _leafMiddle) * _leafScale,
];

_V _quadBezier(_V a, _V b, _V c, double t) {
  final u = 1 - t;
  return a * (u * u) + b * (2 * u * t) + c * (t * t);
}

/// Three.js `CatmullRomCurve3.getPoints(n)` with its default centripetal
/// parameterisation (end points extrapolated).
List<_V> _catmullRom(List<_V> pts, int n) {
  final l = pts.length;
  _V at(double t) {
    final p = (l - 1) * t;
    var i = p.floor();
    var w = p - i;
    if (w == 0 && i == l - 1) {
      i = l - 2;
      w = 1;
    }
    final p0 = i > 0 ? pts[i - 1] : pts[0] + (pts[0] - pts[1]);
    final p1 = pts[i], p2 = pts[i + 1];
    final p3 = i + 2 < l ? pts[i + 2] : pts[l - 1] + (pts[l - 1] - pts[l - 2]);
    var dt0 = math.pow((p1 - p0).dot(p1 - p0), 0.25).toDouble();
    var dt1 = math.pow((p2 - p1).dot(p2 - p1), 0.25).toDouble();
    var dt2 = math.pow((p3 - p2).dot(p3 - p2), 0.25).toDouble();
    if (dt1 < 1e-4) dt1 = 1;
    if (dt0 < 1e-4) dt0 = dt1;
    if (dt2 < 1e-4) dt2 = dt1;
    double axis(double x0, double x1, double x2, double x3) {
      var t1 = (x1 - x0) / dt0 - (x2 - x0) / (dt0 + dt1) + (x2 - x1) / dt1;
      var t2 = (x2 - x1) / dt1 - (x3 - x1) / (dt1 + dt2) + (x3 - x2) / dt2;
      t1 *= dt1;
      t2 *= dt1;
      final c2 = -3 * x1 + 3 * x2 - 2 * t1 - t2;
      final c3 = 2 * x1 - 2 * x2 + t1 + t2;
      return x1 + t1 * w + c2 * w * w + c3 * w * w * w;
    }

    return _V(
      axis(p0.x, p1.x, p2.x, p3.x),
      axis(p0.y, p1.y, p2.y, p3.y),
      axis(p0.z, p1.z, p2.z, p3.z),
    );
  }

  return [for (var k = 0; k <= n; k++) at(k / n)];
}

/// Thread length from the first point to each point (world units).
List<double> _cumulative(List<_V> pts) {
  final out = <double>[0];
  for (var i = 1; i < pts.length; i++) {
    out.add(out.last + (pts[i] - pts[i - 1]).length);
  }
  return out;
}

/// Horizontal (x, y) distance, as the HTML snap tests use.
double _dist2(_V a, _V b) =>
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));

/// Distance from [p] to the segment [a]–[b].
double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.distanceSquared;
  if (len2 < 1e-9) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
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
  _V withZ(double v) => _V(x, y, v);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// The HTML camera projected onto the design stage: [focal] and [centre]
/// carry the scenario view and the collapsed-sidebar framing.
@immutable
class _Proj {
  const _Proj(this.centre, this.focal);

  /// Camera axes: forward (to the origin), right and up.
  static final _V f = (_V.zero - _eye).unit;
  static final _V r = f.cross(const _V(0, 1, 0)).unit;
  static final _V u = r.cross(f);

  final Offset centre;
  final double focal;

  double depth(_V w) => (w - _eye).dot(f);

  /// Design px per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, depth(w));

  Offset p(_V w) {
    final d = w - _eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(centre.dx + d.dot(r) * k, centre.dy - d.dot(u) * k);
  }

  /// World ray through a stage point (HTML Raycaster).
  _V ray(Offset s) =>
      (f + r * ((s.dx - centre.dx) / focal) + u * (-(s.dy - centre.dy) / focal))
          .unit;

  /// Where that ray meets the plane z = [z] (the HTML drag planes have the
  /// normal (0, 0, 1)), or null.
  _V? onPlaneZ(Offset s, double z) {
    final d = ray(s);
    if (d.z.abs() < 1e-9) return null;
    final t = (z - _eye.z) / d.z;
    if (t <= 0) return null;
    return _eye + d * t;
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

// ------------------------------------------------------------------ tweens

/// TWEEN.Easing.Linear.None.
double _linear(double t) => t;

/// TWEEN.Easing.Quadratic.Out.
double _quadOut(double t) => t * (2 - t);

/// TWEEN.Easing.Cubic.InOut.
double _cubicInOut(double t) {
  if (t < 0.5) return 4 * t * t * t;
  final u = 2 * t - 2;
  return 0.5 * u * u * u + 1;
}

/// One tween.js tween: [apply] receives the eased progress 0..1.
class _Tween {
  _Tween({
    required this.start,
    required this.duration,
    required this.apply,
    required this.ease,
    this.owner,
    this.onComplete,
  });

  final double start;
  final double duration;
  final void Function(double k) apply;
  final double Function(double t) ease;

  /// The object it moves (cancelled when the learner grabs it again).
  final _Obj? owner;
  final VoidCallback? onComplete;

  /// Applies the tween at [now] (seconds); true once it has finished.
  bool update(double now) {
    final t = ((now - start) / duration).clamp(0.0, 1.0);
    apply(ease(t));
    return t >= 1;
  }
}

// ------------------------------------------------------------- scene model

/// What the learner can drag: the ball of thread (steps 2–3) and the cut
/// thread (step 5).
enum _Obj { ball, thread }

/// All mutable simulation state; the painter reads it every frame.
class _Scene {
  _Scene() {
    load(0, collapsed: false);
  }

  int scenario = 0;

  /// 1–6 (HTML `State.step`); [_doneStep] once the reading is shown.
  int step = 1;

  /// Ticker time in seconds.
  double time = 0;
  final List<_Tween> tweens = [];

  /// 0 = sidebar open, 1 = collapsed (linear; eased in [framing]).
  double framingT = 0;

  /// Collapsed-sidebar framing: zoom and horizontal shift (design px).
  double collapsedZoom = 1;
  double collapsedShift = 0;

  /// The ball of thread (HTML `threadBall1` / `threadBall2`).
  _V ball = _ball1Home;
  bool ballVisible = false;

  /// Step 3: the thread covers the curve from its first point to this one
  /// (HTML `setDrawRange(0, closestIdx + 1)`).
  int traced = 0;

  /// The thread is anchored (shown from step 3).
  bool threadLaid = false;

  /// Step 4 done: the thread is a separate object, [threadRel] around
  /// [threadCentre] (HTML: geometry re-centred on its bounding box).
  bool cut = false;
  _V threadCentre = _V.zero;
  final List<_V> threadRel = [];

  /// Step 6: blend from the curved to the straightened thread (0..1).
  double straighten = 0;

  /// Time the reading appeared, or −1.
  double readingAt = -1;

  /// A snap or the scale drop is under way (no new grabs).
  bool busy = false;

  /// The object being dragged, its drag plane z, grab offset, where the
  /// drag started and the finger's last point on the plane.
  _Obj? dragging;
  double planeZ = 0;
  _V grabOffset = _V.zero;
  _V dragFrom = _V.zero;
  _V? finger;

  double get framing => Curves.easeInOutCubic.transform(framingT);

  bool get isArch => scenario == 0;
  List<_V> get path => isArch ? _archPath : _leafPath;
  List<double> get pathCumulative => isArch ? _archCumulative : _leafCumulative;
  double get ballRadius => isArch ? _ball1Radius : _ball2Radius;
  double get scaleHalfWidth => isArch ? _metreHalfWidth : _rulerHalfWidth;

  /// Length read on the scale, in cm.
  double get readingCm => isArch
      ? pathCumulative.last * _cmPerUnitMetre
      : pathCumulative.last * _cmPerUnitRuler;

  /// Where the green drop marker is (HTML `targetMarker`), or null.
  _V? get marker => switch (step) {
    2 => path.first,
    5 => _scaleTarget,
    _ => null,
  };

  /// The object that pulses (HTML `highlightedObj`).
  _Obj? get highlighted => switch (step) {
    1 when !isArch => _Obj.ball,
    2 || 3 => _Obj.ball,
    5 => _Obj.thread,
    _ => null,
  };

  /// Scenario 1 step 1: the box of string lights pulses.
  bool get boxHighlighted => isArch && step == 1;

  /// Points of the thread that are drawn.
  int get threadCount => cut ? threadRel.length : (threadLaid ? traced + 1 : 0);

  /// World position of thread point [i].
  _V threadAt(int i) {
    if (!cut) return path[i];
    final curved = threadCentre + threadRel[i];
    if (straighten <= 0) return curved;
    final straight = _V(
      -scaleHalfWidth + pathCumulative[i],
      _straightY,
      _straightZ,
    );
    return _V.lerp(curved, straight, straighten);
  }

  /// The camera with the current framing.
  _Proj get proj => projAt(framing);

  /// The camera at framing [e] (0 = sidebar open, 1 = collapsed).
  _Proj projAt(double e) {
    final zs = isArch ? 1.0 : _leafViewZoom;
    final dy = isArch ? 0.0 : _leafViewDrop;
    final z = 1 + (collapsedZoom - 1) * e;
    return _Proj(
      Offset(_stageCentre.dx + collapsedShift * e, _stageCentre.dy + z * dy),
      _focal * zs * z,
    );
  }

  // Read by the QA flow (integration_test/qa/flows) through the painter:
  // design-space positions with the current framing.

  /// Design position of world point (x, y, z).
  Offset designPoint(double x, double y, double z) => proj.p(_V(x, y, z));

  Offset get ballPoint => proj.p(ball);
  Offset pathPoint(int i) => proj.p(path[i]);
  int get pathPoints => path.length;
  Offset threadPointAt(int i) => proj.p(threadAt(i));
  Offset get markerPoint => proj.p(marker ?? _scaleTarget);
  bool get readingShown => readingAt >= 0;

  /// HTML `changeScenario(id)`: every object back home, step 1.
  void load(int index, {required bool collapsed}) {
    scenario = index;
    step = 1;
    tweens.clear();
    ball = index == 0 ? _ball1Home : _ball2Home;
    // HTML: threadBall1 appears at step 1; threadBall2 is there from the
    // start.
    ballVisible = index == 1;
    traced = 0;
    threadLaid = false;
    cut = false;
    threadCentre = _V.zero;
    threadRel.clear();
    straighten = 0;
    readingAt = -1;
    busy = false;
    dragging = null;
    planeZ = ball.z;
    grabOffset = _V.zero;
    dragFrom = ball;
    finger = null;
    framingT = collapsed ? 1 : 0;
  }

  void tween(
    double seconds,
    void Function(double k) apply, {
    double Function(double t) ease = _linear,
    _Obj? owner,
    VoidCallback? onComplete,
  }) {
    tweens.add(
      _Tween(
        start: time,
        duration: seconds,
        apply: apply,
        ease: ease,
        owner: owner,
        onComplete: onComplete,
      ),
    );
  }

  /// TWEEN.update(): advances every running tween.
  void updateTweens() {
    if (tweens.isEmpty) return;
    final finished = <_Tween>[];
    for (final tw in List.of(tweens)) {
      if (tw.update(time)) finished.add(tw);
    }
    tweens.removeWhere(finished.contains);
    for (final tw in finished) {
      tw.onComplete?.call();
    }
  }
}

/// Pan recogniser that only joins the gesture arena when [canGrab] picks up
/// the step's object at pointer-down (HTML `onPointerDown` raycast), so
/// every other drag still reaches the zoom viewer.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (canGrab?.call(event) ?? false) super.addAllowedPointer(event);
  }
}

class _Ch5A4MeasuringTheLengthOfCurvedLinesPageState
    extends State<Ch5A4MeasuringTheLengthOfCurvedLinesPage>
    with SingleTickerProviderStateMixin {
  // HTML `State.isCamLocked = true`: drags interact with the scene.
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final _PaintCache _cache = _PaintCache();
  late final Ticker _ticker;

  /// Stage scale (design px → logical px), for finger-sized hit areas.
  double _fit = 1;

  /// The last toast this lab showed (key and shown text), so it can be
  /// re-translated when the language changes while it is visible.
  String? _toastKey;
  String? _toastText;

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
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_onLabChanged);
    // The readings written in _i18n ('reading_sN', 'sN_o6') are the traced
    // lengths: 0.88 m on the metre scale, 11.4 cm on the 15-cm ruler.
    assert((_archCumulative.last * _cmPerUnitMetre).round() == 88);
    assert((_leafCumulative.last * _cmPerUnitRuler * 10).round() == 114);
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
    _cache.dispose();
    _lab
      ..removeListener(_onLabChanged)
      ..dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- animation

  /// HTML `animate()`: TWEEN.update() and the collapsed-sidebar framing,
  /// then a repaint of the canvas only.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    final target = _lab.isSidebarOpen ? 0.0 : 1.0;
    if (s.framingT != target) {
      final step = dt / _framingSeconds;
      s.framingT = target > s.framingT
          ? math.min(target, s.framingT + step)
          : math.max(target, s.framingT - step);
    }
    s.updateTweens();
    _frame.value = now;
  }

  // ---------------------------------------------------------------- toasts

  /// HTML `showToast(msg)`. Error toasts play the shell's error tone; the
  /// others go with the HTML's own step sounds.
  void _toast(String key, {bool isError = false}) {
    _toastKey = key;
    _toastText = _t(key);
    _lab.showToast(_toastText!, isError: isError, sound: isError);
  }

  /// Language switched while a toast is up: show it in the new language
  /// (this lab's toasts and the shell's "Scenario Complete" toast).
  void _onLabChanged() {
    final shown = _lab.toast;
    if (shown == null) return;
    String? text;
    if (_toastKey != null && shown.text == _toastText) {
      text = _t(_toastKey!);
      if (text == _toastText) return;
      _toastText = text;
    } else {
      for (final key in const ['msg_scenario_complete', 'msg_all_complete']) {
        final other = labTr(kLabCommonStrings, _lab.lang.next, key);
        if (shown.text == other && _lab.t(key) != other) text = _lab.t(key);
      }
    }
    if (text != null) {
      _lab.showToast(text, isError: shown.isError, sound: false);
    }
  }

  // ----------------------------------------------------------------- logic

  /// HTML `changeScenario(id)` (scenario selector) and `resetApp()`: stops
  /// every timer and tween and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() => _scene.load(index, collapsed: !_lab.isSidebarOpen));
    _lab.resetView(sound: false);
  }

  /// Step 1 (HTML `completeCurrentStep` at step 1): Scenario 1's ball of
  /// thread appears on the box; Scenario 2's ball becomes the tool.
  void _completeTool() {
    final s = _scene;
    _Sound.pop.play();
    setState(() {
      if (s.isArch) s.ballVisible = true;
      s.step = 2;
    });
    _toast('toast_tool');
  }

  /// Step 2 done: the thread's end sticks to the start point.
  void _completeAnchor() {
    final s = _scene;
    _Sound.pop.play();
    _Sound.success.play();
    setState(() {
      s
        ..busy = false
        ..ball = s.path.first
        ..threadLaid = true
        ..traced = 0
        ..step = 3;
    });
    _toast('toast_anchored');
  }

  /// Step 3 done: the ball reached the end of the curve.
  void _completeTrace() {
    final s = _scene;
    _Sound.pop.play();
    _Sound.success.play();
    setState(() {
      s
        ..dragging = null
        ..traced = s.path.length - 1
        ..ball = s.path.last
        ..step = 4;
    });
    _toast('toast_traced');
  }

  /// HTML `cutThread()` (scissors, step 4): the ball goes, and the traced
  /// thread becomes an object centred on its bounding box.
  void _cutThread() {
    final s = _scene;
    if (s.step != 4 || !_lab.isLabActive) return;
    _Sound.snip.play();
    final pts = s.path;
    var lo = pts.first, hi = pts.first;
    for (final q in pts) {
      lo = _V(math.min(lo.x, q.x), math.min(lo.y, q.y), math.min(lo.z, q.z));
      hi = _V(math.max(hi.x, q.x), math.max(hi.y, q.y), math.max(hi.z, q.z));
    }
    final centre = (lo + hi) * 0.5;
    setState(() {
      s
        ..ballVisible = false
        ..cut = true
        ..threadCentre = centre
        ..threadRel.clear()
        ..threadRel.addAll([for (final q in pts) q - centre])
        ..step = 5;
    });
    _toast('toast_cut');
    _Sound.pop.play();
  }

  /// Step 5 done (450 ms after the drop): the thread straightens along the
  /// scale (1.5 s, Cubic.InOut).
  void _completeScaleDrop() {
    final s = _scene;
    _Sound.pop.play();
    _Sound.success.play();
    setState(() => s.step = 6);
    s.tween(
      _straightenTime,
      (k) => s.straighten = k,
      ease: _cubicInOut,
      onComplete: _showReading,
    );
  }

  /// The thread is straight: the reading appears (Scenario 1's archway
  /// lights up) and the summary follows 2 s later.
  void _showReading() {
    if (!mounted) return;
    final s = _scene;
    final index = s.scenario;
    _Sound.success.play();
    setState(() {
      s
        ..readingAt = s.time
        ..step = _doneStep;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: index,
      totalScenarios: 2,
      delay: _popupDelay,
      heading: () => _allDone
          ? _t('all_complete')
          : labFormat(_t('sc_complete'), {'n': index + 1}),
      body: () {
        final observation = _scenarioData(
          _lab.lang,
        )[index].steps.last.observation;
        return _allDone
            ? '$observation\n\n${_t('all_complete_desc')}'
            : observation;
      },
    );
  }

  /// HTML `showObservationPopup()`: the final popup once both scenarios
  /// are done (it also keeps the last scenario's observation, which the
  /// HTML's final popup dropped).
  bool get _allDone => _lab.completedScenarios.length >= 2;

  // ------------------------------------------------------------ hit tests

  /// Scenario 1's box of string lights (its projected bounds, at least a
  /// finger wide).
  bool _onLightsBox(Offset p) {
    var box = _scene.proj.bounds(_lightsBoxCentre, _lightsBoxHalf);
    final min = _minTouch / _fit;
    if (box.width < min || box.height < min) {
      box = Rect.fromCenter(
        center: box.center,
        width: math.max(box.width, min),
        height: math.max(box.height, min),
      );
    }
    return box.contains(p);
  }

  bool _onBall(Offset p) {
    final s = _scene;
    if (!s.ballVisible) return false;
    final proj = s.proj;
    final reach = math.max(
      s.ballRadius * proj.scaleAt(s.ball),
      _minTouch / 2 / _fit,
    );
    return (p - proj.p(s.ball)).distance <= reach;
  }

  bool _onThread(Offset p) {
    final s = _scene;
    final n = s.threadCount;
    if (n < 2) return false;
    final proj = s.proj;
    final reach = math.max(
      _threadReach * proj.scaleAt(s.threadCentre),
      _minTouch / 2 / _fit,
    );
    var prev = proj.p(s.threadAt(0));
    for (var i = 1; i < n; i++) {
      final q = proj.p(s.threadAt(i));
      if (_segmentDistance(p, prev, q) <= reach) return true;
      prev = q;
    }
    return false;
  }

  // -------------------------------------------------------------- gestures

  /// HTML `onPointerDown` at step 1: a click on the highlighted object.
  void _onTapUp(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.step != 1 || s.busy) return;
    final hit = s.isArch
        ? _onLightsBox(d.localPosition)
        : _onBall(d.localPosition);
    if (hit) _completeTool();
  }

  /// HTML `onPointerDown` at steps 2, 3 and 5: picks up the ball or the cut
  /// thread on its drag plane (normal (0, 0, 1) through the object).
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.dragging != null) return false;
    final p = event.localPosition;
    final _Obj obj;
    if ((s.step == 2 || s.step == 3) && _onBall(p)) {
      obj = _Obj.ball;
    } else if (s.step == 5 && _onThread(p)) {
      obj = _Obj.thread;
    } else {
      return false;
    }
    final pos = obj == _Obj.ball ? s.ball : s.threadCentre;
    final hit = s.proj.onPlaneZ(p, pos.z);
    s.tweens.removeWhere((t) => t.owner == obj);
    s
      ..dragging = obj
      ..planeZ = pos.z
      ..dragFrom = pos
      ..grabOffset = hit == null ? _V.zero : hit - pos
      ..finger = hit;
    return true;
  }

  /// HTML `onPointerMove`: the object follows the finger on its plane; at
  /// step 3 the thread follows the ball along the curve.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final obj = s.dragging;
    if (obj == null) return;
    final hit = s.proj.onPlaneZ(d.localPosition, s.planeZ);
    if (hit == null) return;
    s.finger = hit;
    final q = hit - s.grabOffset;
    final pos = _V(
      q.x.clamp(-_dragLimitX, _dragLimitX),
      q.y.clamp(_dragMinY, _dragMaxY),
      s.planeZ,
    );
    if (obj == _Obj.ball) {
      s.ball = pos;
      if (s.step == 3) _trace();
    } else {
      s.threadCentre = pos;
    }
  }

  /// HTML tracing logic: the thread is drawn up to the curve point nearest
  /// the ball, if it is close enough; reaching the end finishes step 3.
  void _trace() {
    final s = _scene;
    final path = s.path;
    final n = path.length;
    final tolerance = math.max(
      _traceTolerance,
      _traceTouchDp / _fit / s.proj.scaleAt(s.ball),
    );
    final lo = math.max(0, s.traced - _traceWindow);
    final hi = math.min(n - 1, s.traced + _traceWindow);
    var best = s.traced;
    var bestDistance = double.infinity;
    for (var i = lo; i <= hi; i++) {
      final d = (path[i] - s.ball).length;
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    if (bestDistance < tolerance) s.traced = best;
    if (s.traced >= n - 2) _completeTrace();
  }

  /// HTML `onPointerUp`: the step's snap rule.
  void _release() {
    final s = _scene;
    final obj = s.dragging;
    s.dragging = null;
    if (obj == null) return;
    if (obj == _Obj.ball && s.step == 2) {
      _dropBall();
    } else if (obj == _Obj.thread && s.step == 5) {
      _dropThread();
    }
  }

  /// Step 2: on the start point the ball snaps there (300 ms) and the step
  /// completes 350 ms later; elsewhere it goes back (500 ms) with a toast.
  void _dropBall() {
    final s = _scene;
    final from = s.ball;
    final start = s.path.first;
    if (_dist2(from, start) < _anchorRadius) {
      final scenario = s.scenario;
      s
        ..busy = true
        ..tween(
          _anchorTween,
          (k) => s.ball = _V.lerp(from, start, k),
          ease: _quadOut,
          owner: _Obj.ball,
        );
      _lab.after(_anchorDelay, () {
        if (!mounted || s.scenario != scenario || s.step != 2) return;
        _completeAnchor();
      });
    } else {
      final home = s.dragFrom;
      s.tween(
        _returnTween,
        (k) => s.ball = _V.lerp(from, home, k),
        owner: _Obj.ball,
      );
      _toast('err_marker', isError: true);
    }
  }

  /// Step 5: dropped on the scale's marker (the thread or the finger near
  /// it, after a real move) it glides onto the scale at the marker
  /// (400 ms) and the step completes 450 ms later; elsewhere it goes back
  /// with a toast.
  void _dropThread() {
    final s = _scene;
    final from = s.threadCentre;
    final finger = s.finger;
    final moved = (from - s.dragFrom).length >= _scaleMinMove;
    final near =
        _dist2(from, _scaleTarget) < _scaleDropRadius ||
        (finger != null && _dist2(finger, _scaleTarget) < _scaleDropRadius);
    if (moved && near) {
      final scenario = s.scenario;
      var low = 0.0;
      for (final q in s.threadRel) {
        low = math.min(low, q.y);
      }
      final rest = _V(
        _scaleTarget.x,
        _scaleY + _scaleHalfHeight + _threadRestGap - low,
        _scaleTarget.z,
      );
      s
        ..busy = true
        ..tween(
          _scaleTween,
          (k) => s.threadCentre = _V.lerp(from, rest, k),
          ease: _quadOut,
          owner: _Obj.thread,
        );
      _lab.after(_scaleDelay, () {
        if (!mounted || s.scenario != scenario || s.step != 5) return;
        _completeScaleDrop();
      });
    } else {
      final home = s.dragFrom;
      s.tween(
        _returnTween,
        (k) => s.threadCentre = _V.lerp(from, home, k),
        owner: _Obj.thread,
      );
      _toast('err_scale', isError: true);
    }
  }

  // --------------------------------------------------------------- framing

  /// Collapsed-sidebar framing for the current scenario: slides (and if
  /// needed shrinks) the scene into the room right of the floating mission
  /// card. Uses the shell's own card width ([_missionCardWidth]).
  void _syncCollapsedFraming(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0 && fit.isFinite)) return;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final cardRight =
        _missionCardLeft + pad.left + _missionCardWidth(size, context.labScale);
    final freeLeft = (cardRight + _cardGap - stageLeft) / fit;
    final freeRight =
        (size.width -
            labOverlayInsets(context, _lab).right -
            _cardGap -
            stageLeft) /
        fit;
    final (left, right) = _scene.isArch ? _s1Extent : _s2Extent;
    var zoom = 1.0, shift = 0.0;
    if (freeLeft > left || freeRight < right) {
      zoom = math.min(1.0, (freeRight - freeLeft) / (right - left));
      final slack = (freeRight - freeLeft) - (right - left) * zoom;
      shift =
          freeLeft +
          slack / 2 -
          _stageCentre.dx -
          zoom * (left - _stageCentre.dx);
    }
    _scene
      ..collapsedZoom = zoom
      ..collapsedShift = shift;
  }

  /// Visible design-space columns of the stage: right of the sidebar or the
  /// mission card, left of the tool column.
  (double, double) _visibleColumns(BuildContext context, BoxConstraints box) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final stageLeft = (box.maxWidth - _design.width * _fit) / 2;
    final right =
        (box.maxWidth - labOverlayInsets(context, _lab).right - stageLeft) /
        _fit;
    final leftEdge = _lab.isSidebarOpen
        ? 0.0
        : _missionCardLeft +
              pad.left +
              _missionCardWidth(size, context.labScale) +
              _cardGap;
    return ((leftEdge - stageLeft) / _fit, right);
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _data;
        _syncCollapsedFraming(context);
        return LabShell(
          controller: _lab,
          icon: Icons.gesture,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: _scene.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          onReset: () => _loadScenario(0),
          // The HTML HUD shows the current step's action; it goes once the
          // reading is shown.
          showHud: _scene.step <= _stepCount,
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _ExplorationList(
            key: ValueKey('explore-${_scene.scenario}-${_scene.step}'),
            steps: data.steps,
            current: _scene.step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
          ),
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
        _fit = fit > 0 && fit.isFinite ? fit : 1;
        final labelScale = (_labelFullScale / _fit).clamp(1.0, _labelMaxBoost);
        final (visibleLeft, visibleRight) = _visibleColumns(context, box);
        final s = _scene;
        return LabStage(
          designSize: _design,
          child: Stack(
            children: [
              Positioned.fill(
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags and taps on the scene are not screen-reader
                  // actions; the scene is announced by its label instead.
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    TapGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          TapGestureRecognizer
                        >(
                          () => TapGestureRecognizer(debugOwner: this),
                          (r) => r.onTapUp = _onTapUp,
                        ),
                    _GrabPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _GrabPanRecognizer
                        >(
                          () => _GrabPanRecognizer(debugOwner: this),
                          (r) => r
                            // A RawGestureDetector does not take
                            // MediaQuery's gesture settings.
                            ..gestureSettings = _dragSettings
                            ..canGrab = _canGrab
                            ..dragStartBehavior = DragStartBehavior.down
                            ..onUpdate = _onDragUpdate
                            ..onEnd = ((_) => _release())
                            ..onCancel = _release,
                        ),
                  },
                  child: Semantics(
                    image: true,
                    label: _t(s.isArch ? 'scene_s1' : 'scene_s2'),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: _design,
                        painter: _ScenePainter(
                          scene: s,
                          cache: _cache,
                          repaint: _frame,
                          palette: _lab.palette,
                          showLabels: _lab.showLabels,
                          lang: _lab.lang,
                          labelScale: labelScale,
                          visibleLeft: visibleLeft,
                          visibleRight: visibleRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (s.step == 4 && _lab.isLabActive) _scissorsButton(labelScale),
            ],
          ),
        );
      },
    );
  }

  /// HTML `#scissors-btn` at the end of the traced curve: the button the
  /// learner taps (the painter draws the bouncing scissors under it). Placed
  /// for the framing the scene is easing to.
  Widget _scissorsButton(double labelScale) {
    final s = _scene;
    final at = s.projAt(_lab.isSidebarOpen ? 0 : 1).p(s.path.last);
    final size = math.max(_scissorsSize * labelScale, _minTouch / _fit);
    return Positioned(
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      width: size,
      height: size,
      child: Tooltip(
        message: _t('cut_thread'),
        child: Semantics(
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _cutThread,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// HTML teacher board "Conceptual Exploration": one card per step; the
/// current step is open with its concept and action, done steps show a tick
/// and open to show their observation too, future steps stay closed. (The
/// HTML also let future steps open, which gave away Scenario 1's and 2's
/// final readings before the learner measured.)
class _ExplorationList extends StatefulWidget {
  const _ExplorationList({
    super.key,
    required this.steps,
    required this.current,
    required this.palette,
    required this.scale,
    required this.fontScale,
    required this.stepLabel,
    required this.conceptLabel,
    required this.actionLabel,
    required this.observationLabel,
  });

  final List<LabStep> steps;
  final int current;
  final LabPalette palette;
  final double scale;

  /// [scale] times the sidebar font-size setting.
  final double fontScale;
  final String stepLabel;
  final String conceptLabel;
  final String actionLabel;
  final String observationLabel;

  @override
  State<_ExplorationList> createState() => _ExplorationListState();
}

class _ExplorationListState extends State<_ExplorationList> {
  /// Steps the learner opened or closed (HTML `toggleAccordion`).
  final Set<int> _toggled = {};

  /// The current step is open; once the scenario is done, the last one
  /// (with the reading in its observation).
  bool _isOpen(int i) =>
      (i == math.min(widget.current, widget.steps.length)) !=
      _toggled.contains(i);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++) _tile(context, i),
      ],
    );
  }

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    final dim = future ? 0.55 : 1.0;
    final tone = current
        ? p.ink(_Colors.indigo400)
        : (past ? p.info : p.textMuted);
    final border = current
        ? _Colors.indigo500
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

    TextSpan labelled(String label, String text, Color labelColor) => TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: TextStyle(color: labelColor, fontWeight: FontWeight.w800),
        ),
        TextSpan(text: text),
      ],
    );

    return Container(
      margin: EdgeInsets.only(bottom: 6 * s),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: border.a * dim)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: LabInk.clear,
            child: InkWell(
              onTap: future
                  ? null
                  : () {
                      LabStyleScope.of(context).style.click.play();
                      setState(() {
                        if (!_toggled.remove(i)) _toggled.add(i);
                      });
                    },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _minTouch),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s),
                  child: Row(
                    children: [
                      Container(
                        width: 22 * s,
                        height: 22 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: current
                              ? _Colors.indigo500
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? _Colors.indigo400
                                : (past
                                      ? p.success.withValues(alpha: 0.5)
                                      : p.cardBorder.withValues(alpha: dim)),
                          ),
                        ),
                        child: past
                            ? Icon(Icons.check, size: 13 * s, color: p.success)
                            : Text(
                                '$i',
                                style: TextStyle(
                                  color: current
                                      ? _Colors.white
                                      : p.textMuted.withValues(alpha: dim),
                                  fontSize: 11 * s,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: Text(
                          '${w.stepLabel} $i',
                          style: TextStyle(
                            color: tone.withValues(alpha: tone.a * dim),
                            fontSize: 12.5 * f,
                            fontWeight: current
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        open ? Icons.expand_less : Icons.expand_more,
                        size: 18 * s,
                        color: tone.withValues(alpha: 0.7 * dim),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.cardBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    labelled(w.conceptLabel, step.concept, p.accentInk),
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text.rich(
                    labelled(w.actionLabel, step.action, p.textStrong),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  // The observation once the learner has seen it.
                  if (past) ...[
                    SizedBox(height: 6 * s),
                    Text.rich(
                      labelled(
                        w.observationLabel,
                        step.observation,
                        p.textStrong,
                      ),
                      style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11.5 * f,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (10, 20, 15)).
const _V _light = _V(0.3714, 0.7428, 0.5571);

/// Box faces: outward normal, then the bottom-left, bottom-right and
/// top-left corners of the face, in units of the half size.
const List<(_V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(1, 1, -1)),
];

/// HTML ruler texture: a 1024 × 128 canvas, marks from its top edge, bold
/// 36 px numbers with their baseline at y = 80.
const double _texW = 1024, _texH = 128, _texFont = 36, _texBaseline = 80;

/// Scissors button: 56 px circle (p-3 + w-8 icon) with a 32 px icon drawn
/// from the HTML SVG (24-unit viewBox); it bounces by 25% of its height
/// every second (Tailwind `animate-bounce`).
const double _scissorsSize = 56;
const double _scissorsIcon = 32;
const double _scissorsViewBox = 24;

/// Label chip padding (HTML `px-2.5 py-1`, at the 12 px label size).
const double _labelPadX = 9, _labelPadY = 3.5;

/// Magnified reading: a lens over the scale showing the marks around the
/// thread's end, windows of 16 cm (metre scale) and 4 cm (15-cm ruler).
const double _lensWidth = 280, _lensHeight = 78;
const (double, double) _lensWindowMetre = (77, 93);
const (double, double) _lensWindowRuler = (9.5, 13.5);

/// String-light colours (the archway's finale and the box).
const List<Color> _bulbColours = [
  _Colors.amber300,
  _Colors.red500,
  _Colors.green400,
  _Colors.indigo400,
  _Colors.thread,
];

/// The HTML scissors SVG paths (24-unit viewBox): two indigo handles and a
/// yellow blade.
final Path _scissorsHandles = Path()
  ..moveTo(7.12109, 7.12134)
  ..cubicTo(5.94957, 5.94981, 5.94957, 4.05026, 7.12109, 2.87873)
  ..cubicTo(8.29262, 1.70721, 10.1922, 1.70721, 11.3637, 2.87873)
  ..lineTo(13.4851, 5.00005)
  ..lineTo(9.24243, 9.24269)
  ..close()
  ..moveTo(7.12109, 16.8787)
  ..cubicTo(5.94957, 18.0502, 5.94957, 19.9497, 7.12109, 21.1213)
  ..cubicTo(8.29262, 22.2928, 10.1922, 22.2928, 11.3637, 21.1213)
  ..lineTo(16.9998, 15.4853)
  ..lineTo(12.7572, 11.2427)
  ..close();
final Path _scissorsBlade = Path()
  ..moveTo(17.3789, 8.86392)
  ..lineTo(9.62132, 16.6215)
  ..lineTo(7.50001, 14.5)
  ..lineTo(15.2576, 6.7424)
  ..close();

/// Paints the HTML Three.js scene: the stone archway, the box of string
/// lights and the metre scale (S1) or the leaf and the 15-cm ruler (S2),
/// then the drop marker, the thread, the ball of thread, the labels, the
/// scissors and the magnified reading.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.labelScale,
    required this.visibleLeft,
    required this.visibleRight,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;
  final double labelScale;

  /// Design-space columns not covered by the sidebar / mission card or the
  /// tool column (the magnified reading stays inside them).
  final double visibleLeft;
  final double visibleRight;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  final Path _path = Path();
  final Float64List _matrix = Float64List(16);

  late Canvas _c;
  late _Proj _p;

  String _t(String key) => labTr(_i18n, lang, key);

  /// HTML pulse `sin(Date.now() * 0.005)`.
  double get _pulse => math.sin(scene.time * _pulseRate);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    _c.drawRect(labBleed(size), _fill);
    if (scene.isArch) {
      _paintArchway();
    } else {
      _paintLeafScene();
    }
    _paintMarker();
    _paintThread();
    _paintBall();
    if (showLabels) _paintLabels();
    if (scene.step == 4) _paintScissors();
    if (scene.readingAt >= 0) _paintReading();
  }

  // ------------------------------------------------------------ scenario 1

  void _paintArchway() {
    // The top first: its underside is behind the pillars' fronts.
    _box(_archTop, _archTopHalf, _Colors.stone300);
    _box(_pillarLeft, _pillarHalf, _Colors.stone300);
    _box(_pillarRight, _pillarHalf, _Colors.stone300);
    _spandrels();
    // HTML arch line (0x64748b, opacity 0.5).
    _polyline(_archPath, _Colors.slate500.withValues(alpha: 0.5), 2.5);
    if (scene.readingAt >= 0) _archLights();
    _scale(metre: true);
    _lightsBox();
  }

  /// The wall above the arch curve, so the opening is the curved archway
  /// the learner traces (the HTML drew the curve inside a square opening).
  void _spandrels() {
    _path.reset();
    final first = _p.p(const _V(-3, 4, _wallFrontZ));
    _path.moveTo(first.dx, first.dy);
    for (final q in _archOnWall) {
      final o = _p.p(q);
      _path.lineTo(o.dx, o.dy);
    }
    final last = _p.p(const _V(3, 4, _wallFrontZ));
    _path
      ..lineTo(last.dx, last.dy)
      ..close();
    _fill
      ..shader = null
      ..color = _lit(_Colors.stone300, const _V(0, 0, 1));
    _c.drawPath(_path, _fill);
  }

  /// Scenario 1's finale ("the archway lights up"): string lights along
  /// the curve, twinkling.
  void _archLights() {
    final fade = ((scene.time - scene.readingAt) / _lightsFade).clamp(0.0, 1.0);
    final r = _bulbRadius * _p.scaleAt(_archBulbs.first);
    for (var n = 0; n < _archBulbs.length; n++) {
      final colour = _bulbColours[n % _bulbColours.length];
      // Each bulb twinkles at its own phase (4 rad/s).
      final twinkle = 0.65 + 0.35 * math.sin(scene.time * 4 + n * 1.7);
      final o = _p.p(_archBulbs[n]);
      _glow.color = colour.withValues(alpha: 0.55 * twinkle * fade);
      _c.drawCircle(o, r * 2.2, _glow);
      _fill
        ..shader = null
        ..color = labShade(colour, 0.35).withValues(alpha: fade);
      _c.drawCircle(o, r, _fill);
    }
  }

  /// HTML lightsBox (0xc2410c), pulsing at step 1, with a string of bulbs
  /// on its front so it reads as a box of string lights.
  void _lightsBox() {
    final glow = scene.boxHighlighted ? 0.5 + 0.5 * _pulse : 0.0;
    if (glow > 0) {
      final b = _p.bounds(_lightsBoxCentre, _lightsBoxHalf);
      _glow.color = _Colors.indigo600.withValues(alpha: 0.45 * glow);
      _c.drawRRect(
        RRect.fromRectAndRadius(b.inflate(6), const Radius.circular(10)),
        _glow,
      );
    }
    _box(_lightsBoxCentre, _lightsBoxHalf, _Colors.orange700, glow: glow);
    _polyline(_boxWire, _Colors.slate900.withValues(alpha: 0.7), 1.5);
    final r = _boxBulbRadius * _p.scaleAt(_lightsBoxCentre);
    for (var i = 0; i < _boxBulbPoints.length; i++) {
      _fill
        ..shader = null
        ..color = _bulbColours[i % _bulbColours.length];
      _c.drawCircle(_p.p(_boxBulbPoints[i]), r, _fill);
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _paintLeafScene() {
    _leaf();
    // HTML leaf line (white, opacity 0.8) along the right edge.
    _polyline(_leafPath, _Colors.white.withValues(alpha: 0.8), 3);
    _scale(metre: false);
  }

  /// HTML leaf (ExtrudeGeometry of two quadratic curves, 0x14532d), with a
  /// midrib, veins and the stem the steps refer to.
  void _leaf() {
    _path.reset();
    for (var i = 0; i < _leafOutline.length; i++) {
      final o = _p.p(_leafOutline[i]);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    // Extrusion edge (the face, darker, a little lower right), then the
    // lit face.
    _fill
      ..shader = null
      ..color = labShade(_Colors.green900, -0.35);
    _c
      ..save()
      ..translate(1.5, 2)
      ..drawPath(_path, _fill)
      ..restore();
    _fill.color = _lit(_Colors.green900, const _V(0, 0, 1));
    _c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 1.2
      ..color = labShade(_Colors.green900, 0.25);
    _c.drawPath(_path, _stroke);
    // Midrib (the first pair, thicker) and veins.
    _stroke.color = _Colors.green700.withValues(alpha: 0.9);
    for (var i = 0; i < _leafVeins.length; i++) {
      final (a, b) = _leafVeins[i];
      _stroke.strokeWidth = i == 0 ? 1.6 : 1;
      _c.drawLine(_p.p(a), _p.p(b), _stroke);
    }
    // Stem below the base.
    final base = _leafVeins.first.$2;
    _stroke
      ..strokeWidth = math.max(2, 0.1 * _p.scaleAt(base))
      ..color = _Colors.lime800;
    _c.drawLine(_p.p(base), _p.p(base + _stemReach), _stroke);
  }

  // ------------------------------------------------------------- the scale

  /// The metre scale (12 units = 100 cm) or the 15-cm ruler (10 units): a
  /// white box with the HTML ruler texture on its top and front faces.
  void _scale({required bool metre}) {
    final hw = metre ? _metreHalfWidth : _rulerHalfWidth;
    const c = _scaleCentre;
    final top = c.y + _scaleHalfHeight, bottom = c.y - _scaleHalfHeight;
    final back = c.z - _scaleHalfDepth, front = c.z + _scaleHalfDepth;
    final art = cache.ruler(metre: metre);
    // Top face: marks along the back edge (texture top), numbers in front.
    _texturedFace(
      art,
      _V(-hw, top, back),
      _V(hw, top, back),
      _V(-hw, top, front),
      const _V(0, 1, 0),
    );
    // Front face: marks hanging from its top edge.
    _texturedFace(
      art,
      _V(-hw, top, front),
      _V(hw, top, front),
      _V(-hw, bottom, front),
      const _V(0, 0, 1),
    );
  }

  /// One box face showing [art] (texture corners tl, tr, bl; affine).
  void _texturedFace(ui.Picture art, _V tl, _V tr, _V bl, _V normal) {
    final pTL = _p.p(tl), pTR = _p.p(tr), pBL = _p.p(bl);
    final pBR = _p.p(tr + bl - tl);
    _path
      ..reset()
      ..moveTo(pTL.dx, pTL.dy)
      ..lineTo(pTR.dx, pTR.dy)
      ..lineTo(pBR.dx, pBR.dy)
      ..lineTo(pBL.dx, pBL.dy)
      ..close();
    _fill
      ..shader = null
      ..color = _Colors.slate50;
    _c.drawPath(_path, _fill);
    final ax = (pTR - pTL) / _texW, ay = (pBL - pTL) / _texH;
    if ((ax.dx * ay.dy - ax.dy * ay.dx).abs() * _texW * _texH > 40) {
      _matrix
        ..fillRange(0, 16, 0)
        ..[0] = ax.dx
        ..[1] = ax.dy
        ..[4] = ay.dx
        ..[5] = ay.dy
        ..[10] = 1
        ..[12] = pTL.dx
        ..[13] = pTL.dy
        ..[15] = 1;
      _c
        ..save()
        ..clipPath(_path)
        ..transform(_matrix)
        ..drawPicture(art)
        ..restore();
    }
    // Light: darker faces get a translucent shade.
    final shade = (1 - _intensity(normal)).clamp(0.0, 0.35);
    if (shade > 0.01) {
      _fill.color = LabInk.black.withValues(alpha: shade);
      _c.drawPath(_path, _fill);
    }
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.slate400;
    _c.drawPath(_path, _stroke);
  }

  // ---------------------------------------------- marker, thread, ball

  /// HTML targetMarker: a green ring facing the camera, pulsing ×(1 ± 0.2).
  void _paintMarker() {
    final m = scene.marker;
    if (m == null) return;
    final k = _p.scaleAt(m) * (1 + _ringPulse * _pulse);
    _stroke
      ..strokeWidth = _ringWidth * k
      ..color = _Colors.green400.withValues(alpha: 0.8);
    _c.drawCircle(_p.p(m), _ringMid * k, _stroke);
  }

  /// The thread (0xffea00, thickened by the HTML's four offset copies);
  /// at step 5 it blinks red / yellow; at step 3 a loose end runs to the
  /// ball.
  void _paintThread() {
    final s = scene;
    final n = s.threadCount;
    if (n == 0) return;
    final k = _p.scaleAt(s.cut ? s.threadCentre : s.path[s.traced]);
    final width = math.max(2.5, 0.09 * k);
    final blink = s.highlighted == _Obj.thread && _pulse > 0;
    final colour = blink ? _Colors.red500 : _Colors.thread;
    if (n >= 2) {
      _path.reset();
      for (var i = 0; i < n; i++) {
        final o = _p.p(s.threadAt(i));
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _stroke
        ..strokeWidth = width + 2
        ..color = LabInk.black.withValues(alpha: 0.35);
      _c.drawPath(_path, _stroke);
      _stroke
        ..strokeWidth = width
        ..color = colour;
      _c.drawPath(_path, _stroke);
    }
    if (!s.cut && s.ballVisible) {
      _stroke
        ..strokeWidth = width * 0.6
        ..color = _Colors.thread.withValues(alpha: 0.75);
      _c.drawLine(_p.p(s.threadAt(n - 1)), _p.p(s.ball), _stroke);
    }
  }

  /// The ball of thread: a lit sphere wound with thread, pulsing indigo
  /// while it is the object to use.
  void _paintBall() {
    final s = scene;
    if (!s.ballVisible) return;
    final c = _p.p(s.ball);
    final r = s.ballRadius * _p.scaleAt(s.ball);
    final base = s.isArch ? _Colors.zslYellow : _Colors.red500;
    final glow = s.highlighted == _Obj.ball ? 0.5 + 0.5 * _pulse : 0.0;
    if (glow > 0) {
      _glow.color = _Colors.indigo600.withValues(alpha: 0.6 * glow);
      _c.drawCircle(c, r * 1.45, _glow);
    }
    final colour = Color.lerp(base, _Colors.indigo500, 0.35 * glow)!;
    _fill.shader = ui.Gradient.radial(
      c + Offset(-r * 0.35, -r * 0.4),
      r * 1.3,
      [labShade(colour, 0.45), colour, labShade(colour, -0.5)],
      const [0, 0.5, 1],
    );
    _c.drawCircle(c, r, _fill);
    _fill.shader = null;
    // Wound thread: bands of arcs across the ball, clipped to it.
    _stroke
      ..strokeWidth = math.max(1, r * 0.07)
      ..color = labShade(colour, -0.35).withValues(alpha: 0.6);
    _c
      ..save()
      ..clipPath(
        _path
          ..reset()
          ..addOval(Rect.fromCircle(center: c, radius: r)),
      )
      ..translate(c.dx, c.dy)
      ..rotate(-0.5);
    for (final dy in const [-0.75, -0.25, 0.25, 0.75]) {
      _c.drawOval(
        Rect.fromCenter(
          center: Offset(0, r * (dy + 0.9)),
          width: r * 3,
          height: r * 1.8,
        ),
        _stroke,
      );
    }
    _c.restore();
  }

  // ---------------------------------------------------------------- labels

  /// HTML `#labels-container`: the object and scale labels, and Start /
  /// End Point during steps 2–5. Placed beside the points they name so
  /// they do not cover the green marker or the curve.
  void _paintLabels() {
    final s = scene;
    final first = s.path.first, last = s.path.last;
    final showEnds = s.step > 1 && s.step < 6;
    final scaleLabel = _p.p(
      const _V(0, _scaleY - _scaleHalfHeight - 0.05, _scaleZ + _scaleHalfDepth),
    );
    if (s.isArch) {
      _chip(
        _t('lbl_arch'),
        _p.p(const _V(0, 5.3, _wallFrontZ)),
        Alignment.center,
        _Colors.amber500,
        _Colors.slate950,
        _Colors.amber300,
        weight: FontWeight.w800,
      );
      if (showEnds) {
        _chip(
          _t('lbl_start'),
          _p.p(first + const _V(0, -0.9, 0)),
          Alignment.topCenter,
          _Colors.labelBg,
          _Colors.white,
          _Colors.labelBorder,
        );
        _chip(
          _t('lbl_end'),
          _p.p(last + const _V(0, -0.9, 0)),
          Alignment.topCenter,
          _Colors.labelBg,
          _Colors.white,
          _Colors.labelBorder,
        );
      }
      _chip(
        _t('lbl_mscale'),
        scaleLabel,
        Alignment.topCenter,
        _Colors.emerald600,
        _Colors.white,
        _Colors.emerald400,
        weight: FontWeight.w800,
      );
      return;
    }
    _chip(
      _t('lbl_leaf'),
      _p.p(const _V(-1.75, 2.3, _leafFaceZ)),
      Alignment.centerRight,
      _Colors.amber500,
      _Colors.slate950,
      _Colors.amber300,
      weight: FontWeight.w800,
    );
    if (showEnds) {
      _chip(
        _t('lbl_start'),
        _p.p(first + const _V(-1.25, 0, 0)),
        Alignment.centerRight,
        _Colors.labelBg,
        _Colors.white,
        _Colors.labelBorder,
      );
      _chip(
        _t('lbl_end'),
        _p.p(last + const _V(-1.25, 0, 0)),
        Alignment.centerRight,
        _Colors.labelBg,
        _Colors.white,
        _Colors.labelBorder,
      );
    }
    _chip(
      _t('lbl_cscale'),
      scaleLabel,
      Alignment.topCenter,
      _Colors.emerald600,
      _Colors.white,
      _Colors.emerald400,
      weight: FontWeight.w800,
    );
  }

  /// A label chip whose [anchor] point sits on [at].
  void _chip(
    String text,
    Offset at,
    Alignment anchor,
    Color background,
    Color foreground,
    Color border, {
    FontWeight weight = FontWeight.w700,
  }) {
    final k = labelScale;
    final tp = cache.text(text, 12 * k, foreground, weight);
    final w = tp.width + 2 * _labelPadX * k, h = tp.height + 2 * _labelPadY * k;
    final rect = Rect.fromLTWH(
      at.dx - (anchor.x + 1) / 2 * w,
      at.dy - (anchor.y + 1) / 2 * h,
      w,
      h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * k));
    _fill
      ..shader = null
      ..color = background;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = border;
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(rect.left + _labelPadX * k, rect.top + _labelPadY * k));
  }

  // -------------------------------------------------------------- scissors

  /// HTML `#scissors-btn` (white / slate-800 circle, indigo border and
  /// glow, the scissors SVG), bouncing at the end of the traced curve.
  void _paintScissors() {
    final k = labelScale;
    final size = _scissorsSize * k;
    final phase = scene.time % 1;
    final bounce = -0.25 * size * (1 - math.sin(math.pi * phase));
    final c = _p.p(scene.path.last) + Offset(0, bounce);
    _glow.color = _Colors.indigo500.withValues(alpha: 0.5);
    _c.drawCircle(c, size * 0.55, _glow);
    _fill
      ..shader = null
      ..color = palette.isDark ? _Colors.slate800 : _Colors.white;
    _c.drawCircle(c, size / 2, _fill);
    _stroke
      ..strokeWidth = 2 * k
      ..color = _Colors.indigo500;
    _c.drawCircle(c, size / 2, _stroke);
    final icon = _scissorsIcon * k;
    final unit = icon / _scissorsViewBox;
    _c
      ..save()
      ..translate(c.dx - icon / 2, c.dy - icon / 2)
      ..scale(unit);
    _fill.color = _Colors.indigo500;
    _c.drawPath(_scissorsHandles, _fill);
    _fill.color = _Colors.zslYellow;
    _c
      ..drawPath(_scissorsBlade, _fill)
      ..restore();
  }

  // --------------------------------------------------------------- reading

  /// HTML `#lbl-scale-reading` ("Reading: …", indigo chip popping in over
  /// the scale) with a magnified view of the marks round the thread's end
  /// ("READ the magnified length"): the scale's own marks are a few pixels
  /// tall in the 3D view.
  void _paintReading() {
    final s = scene;
    final k = labelScale;
    final pop = ((s.time - s.readingAt) / _readingPop).clamp(0.0, 1.0);
    final room = math.max(120.0, visibleRight - visibleLeft - 16);
    final w = math.min(_lensWidth * k, room);
    final h = _lensHeight * k;
    final scaleTop = _p.p(
      const _V(0, _scaleY + _scaleHalfHeight, _scaleZ - _scaleHalfDepth),
    );
    final cx = scaleTop.dx.clamp(
      visibleLeft + w / 2 + 8,
      math.max(visibleLeft + w / 2 + 8, visibleRight - w / 2 - 8),
    );
    final lens = Rect.fromLTWH(cx - w / 2, scaleTop.dy - 16 * k - h, w, h);
    final strip = Rect.fromLTRB(
      lens.left + 10 * k,
      lens.top + 24 * k,
      lens.right - 10 * k,
      lens.bottom - 8 * k,
    );
    final metre = s.isArch;
    final (a, b) = metre ? _lensWindowMetre : _lensWindowRuler;
    double xAt(double cm) => strip.left + (cm - a) / (b - a) * strip.width;
    final xEnd = xAt(s.readingCm).clamp(strip.left, strip.right);

    // Pointer from the lens to the thread's end on the scale (drawn first,
    // from where the lens is while it pops in from half size).
    final grow = 0.5 + 0.5 * pop;
    final from = lens.center + (Offset(xEnd, lens.bottom) - lens.center) * grow;
    final end = _p.p(s.threadAt(s.threadCount - 1));
    _stroke
      ..strokeWidth = 1.5
      ..color = _Colors.indigo400.withValues(alpha: 0.8 * pop);
    _c.drawLine(from, end, _stroke);
    _fill
      ..shader = null
      ..color = _Colors.indigo400.withValues(alpha: pop);
    _c.drawCircle(end, 3 * k, _fill);

    _c
      ..save()
      ..translate(lens.center.dx, lens.center.dy)
      ..scale(grow)
      ..translate(-lens.center.dx, -lens.center.dy);

    // Lens frame and the ruler strip.
    final rr = RRect.fromRectAndRadius(lens, Radius.circular(12 * k));
    _glow.color = _Colors.indigo600.withValues(alpha: 0.45 * pop);
    _c.drawRRect(rr, _glow);
    _fill.color = palette.isDark ? _Colors.slate900 : _Colors.white;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 2 * k
      ..color = _Colors.indigo400;
    _c.drawRRect(rr, _stroke);
    _fill.color = _Colors.slate50;
    _c.drawRect(strip, _fill);

    // Marks: centimetres on the metre scale, millimetres on the ruler;
    // every 5th longer, every 10th longest and numbered.
    final perCm = metre ? 1 : 10;
    _stroke
      ..strokeCap = StrokeCap.butt
      ..color = _Colors.slate900;
    for (var m = (a * perCm).ceil(); m <= (b * perCm).floor(); m++) {
      final major = m % 10 == 0, half = m % 5 == 0;
      final len = strip.height * (major ? 0.5 : (half ? 0.36 : 0.22));
      final x = xAt(m / perCm);
      _stroke.strokeWidth = (major ? 1.8 : 1.1) * k;
      _c.drawLine(Offset(x, strip.top), Offset(x, strip.top + len), _stroke);
      // Numbers whose text fits inside the strip.
      if (major && x - strip.left > 14 * k && strip.right - x > 14 * k) {
        final label = metre ? _metreLabel(m) : '${m ~/ perCm}';
        final tp = cache.text(label, 12 * k, _Colors.slate900, FontWeight.w800);
        tp.paint(_c, Offset(x - tp.width / 2, strip.bottom - tp.height - 1));
      }
    }
    _stroke.strokeCap = StrokeCap.round;

    // The straightened thread up to its end, marked in indigo.
    _stroke
      ..strokeWidth = 4 * k
      ..color = _Colors.thread;
    _c.drawLine(
      Offset(strip.left, strip.top + 2 * k),
      Offset(xEnd, strip.top + 2 * k),
      _stroke,
    );
    _stroke
      ..strokeWidth = 2 * k
      ..color = _Colors.indigo600;
    _c.drawLine(
      Offset(xEnd, strip.top - 4 * k),
      Offset(xEnd, strip.bottom),
      _stroke,
    );

    // "Reading: …" chip on the lens's top edge.
    final tp = cache.text(
      _t(metre ? 'reading_s1' : 'reading_s2'),
      14 * k,
      _Colors.white,
      FontWeight.w900,
    );
    final chip = Rect.fromCenter(
      center: Offset(lens.center.dx, lens.top + 2 * k),
      width: tp.width + 24 * k,
      height: tp.height + 12 * k,
    );
    final cr = RRect.fromRectAndRadius(chip, Radius.circular(8 * k));
    _fill.color = _Colors.indigo600;
    _c.drawRRect(cr, _fill);
    _stroke
      ..strokeWidth = 2 * k
      ..color = _Colors.indigo400;
    _c.drawRRect(cr, _stroke);
    tp.paint(
      _c,
      Offset(chip.center.dx - tp.width / 2, chip.center.dy - tp.height / 2),
    );
    _c.restore();
  }

  /// The metre scale's numbers are in metres (HTML texture: i / 100).
  String _metreLabel(int cm) =>
      cm % 100 == 0 ? '${cm ~/ 100}' : (cm / 100).toStringAsFixed(1);

  // ------------------------------------------------------------ primitives

  /// HTML lights: ambient + key light, toned down so lit faces keep their
  /// colour.
  double _intensity(_V n) => 0.58 + 0.55 * math.max(0.0, n.dot(_light));

  Color _lit(Color c, _V n, {double glow = 0}) {
    final i = _intensity(n);
    final lit = Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
    return glow > 0 ? Color.lerp(lit, _Colors.indigo500, 0.45 * glow)! : lit;
  }

  /// Box centred at [c] with half sizes [h]: the faces turned to the camera,
  /// lit, with soft edges; [glow] adds the HTML's indigo emissive.
  void _box(_V c, _V h, Color color, {double glow = 0}) {
    _V corner(_V s) => c + _V(s.x * h.x, s.y * h.y, s.z * h.z);
    for (final (n, bl, br, tl) in _boxFaces) {
      if (n.dot(_eye - corner(n)) <= 0) continue;
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
        ..color = _lit(color, n, glow: glow);
      _c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.5).withValues(alpha: 0.35);
      _c.drawPath(_path, _stroke);
    }
  }

  void _polyline(List<_V> pts, Color colour, double width) {
    _path.reset();
    for (var i = 0; i < pts.length; i++) {
      final o = _p.p(pts[i]);
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _stroke
      ..strokeWidth = width
      ..color = colour;
    _c.drawPath(_path, _stroke);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.cache != cache ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.labelScale != labelScale ||
      old.visibleLeft != visibleLeft ||
      old.visibleRight != visibleRight;
}

/// Canvas text and the two ruler textures, made once and reused every
/// frame. Owned (and disposed) by the page State.
class _PaintCache {
  final Map<String, TextPainter> _texts = {};
  ui.Picture? _metre;
  ui.Picture? _ruler;

  /// Laid-out text (labels, reading, lens numbers).
  TextPainter text(String s, double size, Color color, FontWeight weight) {
    final key =
        '$s|${size.toStringAsFixed(2)}|${color.toARGB32()}|${weight.value}';
    final hit = _texts[key];
    if (hit != null) return hit;
    if (_texts.length > 160) _clearTexts();
    return _texts[key] = _layout(s, size, color, weight);
  }

  TextPainter _layout(String s, double size, Color color, FontWeight weight) =>
      TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            height: 1.2,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// HTML `createRulerTexture(100)` / `createRulerTexture(15)`.
  ui.Picture ruler({required bool metre}) => metre
      ? (_metre ??= _recordRuler(metre: true))
      : (_ruler ??= _recordRuler(metre: false));

  /// The 1024 × 128 texture: #f8fafc, #0f172a marks 15 / 25 / 40 px long
  /// (1, 5 and 10 cm). The metre scale is numbered in metres every 10 cm
  /// (HTML); the 15-cm ruler gets the millimetre marks and the number on
  /// every centimetre that its steps describe (the HTML drew only "10").
  /// Both show the '0' the thread is aligned with.
  ui.Picture _recordRuler({required bool metre}) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _texW, _texH));
    final paint = Paint()..color = _Colors.slate50;
    canvas.drawRect(const Rect.fromLTWH(0, 0, _texW, _texH), paint);
    paint.color = _Colors.slate900;
    final cm = metre ? 100 : 15;
    final perCm = _texW / cm;
    if (!metre) {
      for (var mm = 1; mm < cm * 10; mm++) {
        if (mm % 10 == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(mm * perCm / 10, 0, 2, mm % 5 == 0 ? 20 : 10),
          paint,
        );
      }
    }
    final painters = <TextPainter>[];
    for (var i = 0; i <= cm; i++) {
      final x = i * perCm;
      final major = metre ? i % 10 == 0 : true;
      final h = (metre ? i % 10 == 0 : i % 10 == 0)
          ? 40.0
          : (i % 5 == 0 ? 25.0 : (metre ? 15.0 : 30.0));
      canvas.drawRect(Rect.fromLTWH(x, 0, 3, h), paint);
      if (!major || i == cm) continue;
      final label = metre
          ? (i == 0 ? '0' : (i == 100 ? '1' : (i / 100).toStringAsFixed(1)))
          : '$i';
      final tp = _layout(label, _texFont, _Colors.slate900, FontWeight.w700);
      painters.add(tp);
      tp.paint(
        canvas,
        Offset(
          i == 0 ? x + 4 : x - tp.width / 2,
          _texBaseline -
              tp.computeDistanceToActualBaseline(TextBaseline.alphabetic),
        ),
      );
    }
    for (final tp in painters) {
      tp.dispose();
    }
    return recorder.endRecording();
  }

  void _clearTexts() {
    for (final tp in _texts.values) {
      tp.dispose();
    }
    _texts.clear();
  }

  void dispose() {
    _clearTexts();
    _metre?.dispose();
    _ruler?.dispose();
    _metre = null;
    _ruler = null;
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
