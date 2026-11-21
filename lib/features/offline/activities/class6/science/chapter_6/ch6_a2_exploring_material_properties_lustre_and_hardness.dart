// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 6 Science • Chapter 6 • Activity 2
/// Exploring Material Properties: Lustre and Hardness.
///
/// Native Flutter port of
/// `Cl6S-Ch6-A2-Exploring_Material_Properties__Lustre_and_Hardness.html`
/// (Three.js r128). The Three.js scene is redrawn by a small painter's
/// renderer that reproduces the HTML camera (position (0, 10, 24), look-at
/// (0, 2, 0), 45° field of view).
///
/// Scenario 1 (The Shine Test): a spotlight sweeps over copper wire,
/// aluminium foil, a wood block and a paper sheet (the metals sparkle); the
/// learner sorts them into the Lustrous / Non-Lustrous bins, finds that an
/// old iron nail and chalk both look dull, cuts the nail open (its fresh
/// cut surface shines) and sorts the nail and the chalk.
///
/// Scenario 2 (The Scratch Test): a metal key scratches a candle (deep
/// groove), a stone (sparks, no mark), chalk (groove and powder) and a
/// wood block (no mark); the learner sorts each pair into the Hard / Soft
/// bins.
///
/// As in the HTML every test is a tool from the "Testing Tools" box (tap it,
/// or drag it onto the table) and every sort is a bin button; the tools and
/// bins are also the sidebar / mission card actions.
class Ch6A2ExploringMaterialPropertiesLustreAndHardnessPage
    extends StatefulWidget {
  const Ch6A2ExploringMaterialPropertiesLustreAndHardnessPage({super.key});

  @override
  State<Ch6A2ExploringMaterialPropertiesLustreAndHardnessPage> createState() =>
      _LustreLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones
/// bundled in `assets/audio/`.
///
/// Files (in `assets/audio/`): click → `science/click.mp3`,
/// toggle → `science/dropdown.mp3`, correct → `science/correct.mp3`,
/// wrong → `science/error.mp3`, success → `math/success.mp3`,
/// scenario → `science/page_open.mp3`, curtain → `science/curtain.mp3`,
/// pop → `science/pop.mp3`, measure → `science/pickup.mp3`.
///
/// The HTML synthesises its tones in `playSound(type)`: 'pop' (sine
/// 400 → 800 Hz blip) → pop, 'success' (C–E–G arpeggio) → success. Its
/// 'measure' tone (spotlight, cutter, key) is never synthesised (the HTML
/// plays nothing); it is mapped onto the closest file, pickup.
enum _Sound implements LabTone {
  /// Generic button click.
  click('audio/class6/science/click.mp3'),

  /// Sidebar expand / collapse.
  toggle('audio/class6/science/dropdown.mp3'),

  /// Right action (shell feedback).
  correct('audio/class6/science/correct.mp3'),

  /// Wrong action: a material put into the wrong bin.
  wrong('audio/class6/science/error.mp3'),

  /// A material sorted into its bin / conclusion popup (HTML 'success').
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// A tool picked up for dragging (HTML `onDragTool` 'pop').
  pop('audio/class6/science/pop.mp3'),

  /// Spotlight, cutter or key used (HTML 'measure').
  measure('audio/class6/science/pickup.mp3');

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
  /// ZSL yellow (`zsl.yellow`): label borders.
  static const Color zslYellow = Color(0xFFEAB308);
  static const Color amber300 = Color(0xFFFCD34D); // subtitle, soft tag
  static const Color amber400 = Color(0xFFFBBF24); // sparkle icon
  static const Color amber500 = Color(0xFFF59E0B); // accents, key 0xf59e0b
  static const Color amber600 = Color(0xFFD97706); // copper 0xd97706, bins
  static const Color amber800 = Color(0xFF92400E); // S1 wood 0x92400e
  static const Color amber900 = Color(0xFF78350F); // S2 wood 0x78350f
  static const Color yellow100 = Color(0xFFFEF9C3); // candle top
  static const Color yellow200 = Color(0xFFFEF08A); // copper highlight
  static const Color yellow300 = Color(0xFFFDE047); // candle 0xfde047
  static const Color yellow400 = Color(0xFFFACC15); // spotlight 0xfacc15
  static const Color orange500 = Color(0xFFF97316); // sparks 0xf97316
  static const Color rose600 = Color(0xFFE11D48); // Cut Iron Nail button
  static const Color sky400 = Color(0xFF38BDF8); // fresh-cut glow 0x38bdf8
  static const Color blue600 = Color(0xFF2563EB); // popup buttons
  static const Color emerald400 = Color(0xFF34D399); // completed steps
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color slate50 = Color(0xFFF8FAFC); // paper 0xf8fafc
  static const Color slate100 = Color(0xFFF1F5F9); // light scene 0xf1f5f9
  static const Color slate200 = Color(0xFFE2E8F0); // foil 0xe2e8f0
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B); // stone 0x64748b
  static const Color slate600 = Color(0xFF475569); // dull nail 0x475569
  static const Color slate700 = Color(0xFF334155); // S1 table 0x334155
  static const Color slate800 = Color(0xFF1E293B); // S2 table 0x1e293b
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617); // dark scene 0x020617
  static const Color white = Color(0xFFFFFFFF);

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Sprite labels (`rgba(15, 23, 42, 0.9)`) and the toast
  /// (`bg-slate-900/80`).
  static const Color labelBg = Color(0xE60F172A);
  static const Color toastBg = Color(0xCC0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables). The scene is `0x020617` (dark) or `0xf1f5f9` (light); the
/// sprite labels stay dark with white text in both themes, as in the HTML.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950,
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.toastBg,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F), // from-amber-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.amber500,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate950,
    readoutBorder: Color(0x66F59E0B),
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
    canvasBg: _Colors.slate100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.toastBg,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x6678350F),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D),
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.amber600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate950,
    readoutBorder: Color(0x66F59E0B),
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting (px): HTML default 15 px, slider 12 … 22 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// HTML's toasts were English-only literals; they are in the table now with
// Hindi. Changes, all in English and Hindi:
// * Step actions name the tool or bin buttons and the number of taps
//   ("Tap 'Shine Spotlight' (or drag it onto the table) …").
// * The classification steps no longer give the answer away: the HTML
//   actions "Classify copper/foil as Lustrous, wood/paper as Non-Lustrous",
//   "Sort Candle to Soft, Stone to Hard" and the HUD lines "Classify Candle
//   (Soft) and Stone (Hard)" ask the learner to sort the highlighted
//   material instead, and a wrong bin is refused with a hint. For the same
//   reason S1 step 5's concept "Classify iron nail as lustrous." states the
//   idea ("A freshly cut metal surface shows its true lustre.") and S2
//   step 4's concept "Chalk yields powder; solid wood resists key." (the
//   result of that step's test) asks the question instead; the scratch
//   toasts drop their "(Soft)" / "(Hard)" verdicts and the S1 step 3 HUD
//   line drops "dull".
// * "Click" → "Tap"; "bins below" → "bins" (the bins sit above the HUD).
// * Hindi sentences never pair a material name with a gendered verb: the
//   toasts use "{name} → … डिब्बा" or "{name}: … इसकी चमक / इस पर …".

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Exploring Material Properties: Lustre and Hardness',
    'app_subtitle': 'Class 6 • Materials Around Us',
    'scen_1': 'Scenario 1: The Shine Test: Identifying Lustre',
    'scen_2': 'Scenario 2: The Scratch Test: Identifying Hardness',
    's1_obj':
        'To observe materials and classify them as lustrous (shiny) or non-lustrous (dull) under light.',
    's2_obj':
        'To test materials for hardness by attempting to scratch them with a metal key.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Lustrous materials reflect light brightly.',
    's1_a1':
        "Tap 'Shine Spotlight' (or drag it onto the table) and watch the light pass over the copper wire, aluminium foil, wood block and paper sheet.",
    's1_o1':
        'Copper wire and aluminium foil gleam and sparkle. Wood and paper stay dull.',
    's1_c2': 'Metals generally possess metallic lustre.',
    's1_a2':
        "Sort the four materials one at a time: tap 'Lustrous (Shiny)' or 'Non-Lustrous (Dull)' for the highlighted material (4 taps).",
    's1_o2': 'Items sorted into respective bins correctly.',
    's1_c3': 'Some metals lose shine due to air tarnishing.',
    's1_a3':
        "Tap 'Spotlight on Nail & Chalk' (or drag it onto the table) to shine light on the old iron nail and the chalk.",
    's1_o3': 'Both appear dull initially.',
    's1_c4': 'True metallic shine is preserved inside.',
    's1_a4':
        "Tap 'Cut Iron Nail' (or drag it onto the table) to cut open the iron nail.",
    's1_o4': 'Fresh cut reveals brilliant metallic sparkle!',
    's1_c5': 'A freshly cut metal surface shows its true lustre.',
    's1_a5':
        "Sort the iron nail and the chalk: tap 'Lustrous (Shiny)' or 'Non-Lustrous (Dull)' for the highlighted material (2 taps).",
    's1_o5': 'Lustre investigation complete!',
    // Scenario 2 steps.
    's2_c1': 'Soft materials are easily scratched or compressed.',
    's2_a1':
        "Tap 'Scratch Candle' (or drag it onto the table) to scratch the candle with the metal key.",
    's2_o1': 'Deep scratch groove etched into candle wax.',
    's2_c2': 'Hard materials resist deformation and scratching.',
    's2_a2':
        "Tap 'Scratch Stone' (or drag it onto the table) to scratch the stone with the key.",
    's2_o2': 'Sparks fly with metallic clink! Stone remains unscratched.',
    's2_c3': 'Classify materials by scratch resistance.',
    's2_a3':
        "Sort the candle and the stone: tap 'Hard (Cannot Scratch)' or 'Soft (Can Scratch)' for the highlighted material (2 taps).",
    's2_o3': 'Items locked into correct bins.',
    's2_c4':
        'Any material can be tested the same way: does the key leave a scratch?',
    's2_a4':
        "Tap 'Scratch Chalk' and 'Scratch Wood' (or drag them onto the table) to scratch-test both materials.",
    's2_o4': 'Chalk crumbles with groove; wood resists scratch.',
    's2_c5': 'Hardness dictates material utility.',
    's2_a5':
        "Sort the chalk and the wood: tap 'Hard (Cannot Scratch)' or 'Soft (Can Scratch)' for the highlighted material (2 taps).",
    's2_o5': 'Hardness classification mastered!',
    // Canvas HUD ("Current Task") lines.
    's1_hud_1':
        "Step 1: Tap 'Shine Spotlight' to test copper wire, foil, wood, paper.",
    's1_hud_2': 'Step 2: Classify items into Lustrous and Non-Lustrous bins.',
    's1_hud_3':
        'Step 3: Tap the spotlight to test the old iron nail and chalk.',
    's1_hud_4': "Step 4: Tap 'Cut Iron Nail' to cut open the rusted nail.",
    's1_hud_5':
        'Step 5: Inspect the fresh cut lustre and classify nail & chalk.',
    's2_hud_1': "Step 1: Tap 'Scratch Candle' to test with metal key.",
    's2_hud_2': "Step 2: Tap 'Scratch Stone' to test stone hardness.",
    's2_hud_3': 'Step 3: Classify the Candle and the Stone into bins.',
    's2_hud_4': 'Step 4: Scratch test Chalk and Wood.',
    's2_hud_5':
        'Step 5: Classify the Chalk and the Wood into bins to complete!',
    // Conclusion popups.
    'sum_s1':
        'You learned that shiny materials like metals are LUSTROUS. Non-shiny items are NON-LUSTROUS. Dull metals reveal true luster when cut!',
    'sum_s2':
        'You learned that materials difficult to scratch are HARD (stone, wood). Materials easily scratched are SOFT (candle, chalk)!',
    'sc_complete': 'Scenario {n} Complete!',
    'all_complete': 'Mastery Achieved!',
    'all_complete_desc':
        'You successfully tested materials for Lustre (shininess) and Hardness (resistance to scratching)! You proved that dull metals can shine when freshly cut.',
    // Testing Tools box and bins.
    'toolbox_title': 'Testing Tools',
    'toolbox_s1_desc': 'Select tool or item to test:',
    'toolbox_s2_desc': 'Select metal key to scratch test:',
    'tool_spotlight': 'Shine Spotlight',
    'tool_spotlight_nail': 'Spotlight on Nail & Chalk',
    'tool_cutter': 'Cut Iron Nail',
    'test_candle': 'Scratch Candle',
    'test_stone': 'Scratch Stone',
    'test_chalk': 'Scratch Chalk',
    'test_wood': 'Scratch Wood',
    'classify_prompt': 'Classify inspected material into bin:',
    'classify_hard_prompt': 'Classify scratched material into bin:',
    'bin_lustrous': 'Lustrous (Shiny)',
    'bin_nonlustrous': 'Non-Lustrous (Dull)',
    'bin_hard': 'Hard (Cannot Scratch)',
    'bin_soft': 'Soft (Can Scratch)',
    'tag_lustrous': 'Lustrous',
    'tag_nonlustrous': 'Non-Lustrous',
    'tag_hard': 'Hard',
    'tag_soft': 'Soft',
    // Scene labels.
    'lbl_cwire': 'Copper Wire',
    'lbl_foil': 'Aluminium Foil',
    'lbl_wood': 'Wood Block',
    'lbl_paper': 'Paper Sheet',
    'lbl_nail': 'Iron Nail',
    'lbl_candle': 'Wax Candle',
    'lbl_stone': 'Stone',
    'lbl_chalk': 'Chalk Piece',
    // Toasts.
    'toast_shine':
        'Notice how Copper Wire & Foil shine brightly with glowing sparkles!',
    'toast_dull':
        'Notice neither Iron Nail nor Chalk sparkles. They appear dull!',
    'toast_cut':
        'Fresh cut reveals brilliant metallic sparkle inside the iron nail!',
    'toast_sorted': '{name} → {bin} bin. Correct!',
    'toast_wrong_s1':
        'Wrong bin! Look again at how {name} looked under the spotlight.',
    'toast_wrong_nail':
        'Wrong bin! Look at the freshly cut surface of the Iron Nail.',
    'toast_wrong_s2': 'Wrong bin! Remember what the key did to {name}.',
    'toast_s1_sorted':
        'Initial items sorted! Now test the old Iron Nail and the Chalk with the spotlight.',
    'toast_candle': 'Deep scratch groove etched into candle wax!',
    'toast_stone': 'Sparks fly with metallic clink! Stone resists scratch.',
    'toast_chalk': 'Chalk crumbles with deep scratch groove!',
    'toast_wood': 'Solid wood resists key scratch!',
    'toast_s2_sorted':
        'Candle & Stone classified! Now scratch test Chalk & Wood.',
    'toast_s2_both': 'Both tested! Classify Chalk and Wood into bins.',
    // Sidebar observation table.
    'findings': 'Observation Table',
    'tbl_material': 'Material',
    'tbl_result': 'Result',
    'res_untested': 'Not tested yet',
    'res_shines': 'Shines under the light',
    'res_dull': 'Looks dull under the light',
    'res_cut': 'Freshly cut surface shines',
    'res_groove': 'Key leaves a deep groove',
    'res_powder': 'Groove and powder: scratched easily',
    'res_unscratched': 'No scratch from the key',
    'sort_now': 'Sort now',
    'observations': 'Observations',
  },
  'hi': {
    'app_title': 'सामग्री के गुणों की खोज: चमक और कठोरता',
    'app_subtitle': 'कक्षा 6 • हमारे चारों ओर की सामग्री',
    'scen_1': 'परिदृश्य 1: चमक परीक्षण',
    'scen_2': 'परिदृश्य 2: खरोंच परीक्षण',
    's1_obj':
        'प्रकाश में सामग्रियों को देखकर उन्हें चमकदार (द्युतिमय) या निष्प्रभ (द्युतिहीन) के रूप में वर्गीकृत करना।',
    's2_obj': 'धातु की चाबी से खरोंचकर सामग्रियों की कठोरता का परीक्षण करना।',
    's1_c1': 'चमकदार पदार्थ प्रकाश को परावर्तित करते हैं।',
    's1_a1':
        "'प्रकाश डालें' दबाएं (या उसे मेज़ पर खींचें) और देखें कि प्रकाश तांबे के तार, एल्युमिनियम फॉइल, लकड़ी के गुटके और कागज़ की शीट पर से कैसे गुज़रता है।",
    's1_o1': 'तांबे का तार और फॉइल चमकते हैं। लकड़ी और कागज़ फीके रहते हैं।',
    's1_c2': 'धातुएं सामान्यतः चमकदार होती हैं।',
    's1_a2':
        "चारों सामग्रियों को एक-एक करके छाँटें: हाइलाइट की गई सामग्री के लिए 'चमकदार (द्युतिमय)' या 'निष्प्रभ (द्युतिहीन)' दबाएं (4 बार)।",
    's1_o2': 'वस्तुएं सही डिब्बों में रखी गईं।',
    's1_c3': 'हवा से कुछ धातुएं चमक खो देती हैं।',
    's1_a3':
        "पुरानी लोहे की कील और चॉक पर प्रकाश डालने के लिए 'कील और चॉक पर प्रकाश डालें' दबाएं (या उसे मेज़ पर खींचें)।",
    's1_o3': 'दोनों फीके दिखाई देते हैं।',
    's1_c4': 'असली चमक अंदर सुरक्षित रहती है।',
    's1_a4':
        "लोहे की कील को काटने के लिए 'लोहे की कील काटें' दबाएं (या उसे मेज़ पर खींचें)।",
    's1_o4': 'कटने पर अंदर चमकीली चांदी जैसी धातु दिखती है!',
    's1_c5': 'धातु की ताज़ी कटी सतह उसकी असली चमक दिखाती है।',
    's1_a5':
        "कील और चॉक को छाँटें: हाइलाइट की गई सामग्री के लिए 'चमकदार (द्युतिमय)' या 'निष्प्रभ (द्युतिहीन)' दबाएं (2 बार)।",
    's1_o5': 'चमक परीक्षण पूरा हुआ!',
    's2_c1': 'कोमल पदार्थों पर आसानी से खरोंच लगती है।',
    's2_a1':
        "धातु की चाबी से मोमबत्ती को खरोंचने के लिए 'मोमबत्ती खरोंचें' दबाएं (या उसे मेज़ पर खींचें)।",
    's2_o1': 'मोमबत्ती पर गहरा निशान बन जाता है।',
    's2_c2': 'कठोर पदार्थ खरोंच का विरोध करते हैं।',
    's2_a2':
        "चाबी से पत्थर को खरोंचने के लिए 'पत्थर खरोंचें' दबाएं (या उसे मेज़ पर खींचें)।",
    's2_o2': 'चिनगारी निकलती है! पत्थर पर निशान नहीं बनता।',
    's2_c3': 'कठोरता के आधार पर वर्गीकरण करें।',
    's2_a3':
        "मोमबत्ती और पत्थर को छाँटें: हाइलाइट की गई सामग्री के लिए 'कठोर (खरोंच न लगे)' या 'कोमल (खरोंच लग जाए)' दबाएं (2 बार)।",
    's2_o3': 'वस्तुएं सही डिब्बों में पहुंचीं।',
    's2_c4':
        'हर सामग्री को इसी तरह जाँचा जा सकता है: क्या चाबी से खरोंच लगती है?',
    's2_a4':
        "दोनों सामग्रियों के खरोंच परीक्षण के लिए 'चॉक खरोंचें' और 'लकड़ी खरोंचें' दबाएं (या उन्हें मेज़ पर खींचें)।",
    's2_o4': 'चॉक पर निशान बनता है, लकड़ी सुरक्षित रहती है।',
    's2_c5': 'कठोरता उपयोग तय करती है।',
    's2_a5':
        "चॉक और लकड़ी को छाँटें: हाइलाइट की गई सामग्री के लिए 'कठोर (खरोंच न लगे)' या 'कोमल (खरोंच लग जाए)' दबाएं (2 बार)।",
    's2_o5': 'कठोरता वर्गीकरण पूर्ण!',
    's1_hud_1':
        "चरण 1: तांबे के तार, फॉइल, लकड़ी और कागज़ को जाँचने के लिए 'प्रकाश डालें' दबाएं।",
    's1_hud_2':
        'चरण 2: वस्तुओं को चमकदार और निष्प्रभ डिब्बों में वर्गीकृत करें।',
    's1_hud_3': 'चरण 3: पुरानी कील और चॉक पर प्रकाश डालें।',
    's1_hud_4': "चरण 4: कील काटने के लिए 'लोहे की कील काटें' दबाएं।",
    's1_hud_5':
        'चरण 5: कटी हुई कील की चमक देखें और कील व चॉक को वर्गीकृत करें।',
    's2_hud_1':
        "चरण 1: धातु की चाबी से जाँचने के लिए 'मोमबत्ती खरोंचें' दबाएं।",
    's2_hud_2': "चरण 2: पत्थर की कठोरता जाँचने के लिए 'पत्थर खरोंचें' दबाएं।",
    's2_hud_3': 'चरण 3: मोमबत्ती और पत्थर को डिब्बों में डालें।',
    's2_hud_4': 'चरण 4: चॉक और लकड़ी का खरोंच परीक्षण करें।',
    's2_hud_5': 'चरण 5: पूरा करने के लिए चॉक और लकड़ी को डिब्बों में डालें।',
    'sum_s1':
        'आपने जाना कि धातुओं जैसी चमकने वाली सामग्रियाँ चमकदार (द्युतिमय) होती हैं। न चमकने वाली वस्तुएँ निष्प्रभ (द्युतिहीन) होती हैं। हवा से धुंधली हुई धातुएँ काटने पर असली चमक दिखाती हैं!',
    'sum_s2':
        'आपने जाना कि जिन्हें खरोंचना कठिन है वे कठोर हैं (पत्थर, लकड़ी)। जो आसानी से खरोंचे जाएं वे कोमल हैं (मोमबत्ती, चॉक)!',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'all_complete': 'महारत हासिल की!',
    'all_complete_desc':
        'आपने चमक और कठोरता के लिए सामग्रियों का सफलतापूर्वक परीक्षण किया! आपने सिद्ध किया कि कटी हुई ताजी धातु चमकदार होती है।',
    'toolbox_title': 'परीक्षण उपकरण',
    'toolbox_s1_desc': 'परीक्षण के लिए उपकरण चुनें:',
    'toolbox_s2_desc': 'खरोंच परीक्षण के लिए चाबी चुनें:',
    'tool_spotlight': 'प्रकाश डालें',
    'tool_spotlight_nail': 'कील और चॉक पर प्रकाश डालें',
    'tool_cutter': 'लोहे की कील काटें',
    'test_candle': 'मोमबत्ती खरोंचें',
    'test_stone': 'पत्थर खरोंचें',
    'test_chalk': 'चॉक खरोंचें',
    'test_wood': 'लकड़ी खरोंचें',
    'classify_prompt': 'जांची गई सामग्री को डिब्बे में डालें:',
    'classify_hard_prompt': 'खरोंची गई सामग्री को डिब्बे में डालें:',
    'bin_lustrous': 'चमकदार (द्युतिमय)',
    'bin_nonlustrous': 'निष्प्रभ (द्युतिहीन)',
    'bin_hard': 'कठोर (खरोंच न लगे)',
    'bin_soft': 'कोमल (खरोंच लग जाए)',
    'tag_lustrous': 'चमकदार',
    'tag_nonlustrous': 'निष्प्रभ',
    'tag_hard': 'कठोर',
    'tag_soft': 'कोमल',
    'lbl_cwire': 'तांबे का तार',
    'lbl_foil': 'एल्युमिनियम फॉइल',
    'lbl_wood': 'लकड़ी का गुटका',
    'lbl_paper': 'कागज़ की शीट',
    'lbl_nail': 'लोहे की कील',
    'lbl_candle': 'मोमबत्ती',
    'lbl_stone': 'पत्थर',
    'lbl_chalk': 'चॉक का टुकड़ा',
    'toast_shine':
        'देखें, तांबे का तार और एल्युमिनियम फॉइल चमकीली चिंगारियों के साथ तेज़ चमकते हैं!',
    'toast_dull':
        'देखें, न लोहे की कील में चमक दिखती है, न चॉक में। दोनों फीके दिखते हैं!',
    'toast_cut':
        'ताज़ा कटाव लोहे की कील के अंदर की चमकीली धात्विक चमक दिखाता है!',
    'toast_sorted': '{name} → {bin} डिब्बा। सही!',
    'toast_wrong_s1': 'गलत डिब्बा! {name}: प्रकाश में इसकी चमक दोबारा देखें।',
    'toast_wrong_nail': 'गलत डिब्बा! लोहे की कील की ताज़ी कटी सतह देखें।',
    'toast_wrong_s2':
        'गलत डिब्बा! {name}: याद करें, चाबी से खरोंचने पर इस पर क्या असर हुआ।',
    'toast_s1_sorted':
        'पहली वस्तुएं छँट गईं! अब पुरानी लोहे की कील और चॉक को प्रकाश से जाँचें।',
    'toast_candle': 'मोमबत्ती के मोम पर गहरी खरोंच बन गई!',
    'toast_stone':
        'धातु की खनक के साथ चिनगारियाँ निकलीं! पत्थर पर खरोंच नहीं लगी।',
    'toast_chalk': 'चॉक का चूरा झड़ता है और उस पर गहरी खरोंच बन जाती है!',
    'toast_wood': 'ठोस लकड़ी पर चाबी से खरोंच नहीं लगती!',
    'toast_s2_sorted':
        'मोमबत्ती और पत्थर वर्गीकृत! अब चॉक और लकड़ी का खरोंच परीक्षण करें।',
    'toast_s2_both': 'दोनों की जाँच हो गई! चॉक और लकड़ी को डिब्बों में डालें।',
    'findings': 'अवलोकन तालिका',
    'tbl_material': 'सामग्री',
    'tbl_result': 'परिणाम',
    'res_untested': 'अभी जाँचा नहीं गया',
    'res_shines': 'प्रकाश में चमक दिखी',
    'res_dull': 'प्रकाश में चमक नहीं दिखी',
    'res_cut': 'ताज़ी कटी सतह पर चमक दिखी',
    'res_groove': 'चाबी से गहरी खरोंच लगी',
    'res_powder': 'खरोंच लगी और चूरा झड़ा: आसानी से खरोंच',
    'res_unscratched': 'चाबी से खरोंच नहीं लगी',
    'sort_now': 'अभी छाँटें',
    'observations': 'अवलोकन',
  },
};

/// Scenarios and steps for [lang], built from [_i18n] (HTML
/// `ScenariosData[lang][n].steps`).
List<LabScenarioData> _scenarioData(LabLang lang) =>
    _scenarioCache.putIfAbsent(lang, () {
      String t(String key) => labTr(_i18n, lang, key);
      List<LabStep> steps(int scenario) => [
        for (var i = 1; i <= _stepCount; i++)
          LabStep(
            concept: t('s${scenario}_c$i'),
            action: t('s${scenario}_a$i'),
            observation: t('s${scenario}_o$i'),
          ),
      ];
      return [
        LabScenarioData(
          title: t('scen_1'),
          objective: t('s1_obj'),
          steps: steps(1),
        ),
        LabScenarioData(
          title: t('scen_2'),
          objective: t('s2_obj'),
          steps: steps(2),
        ),
      ];
    });

final Map<LabLang, List<LabScenarioData>> _scenarioCache = {};

// ===================================================================== STATE

/// Steps per scenario (HTML `steps` arrays: 5 and 5).
const int _stepCount = 5;

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);

/// HTML camera: PerspectiveCamera(45°) at (0, 10, 24) looking at
/// controls.target (0, 2, 0) (`resetCamera()`, called on every scenario).
const _V _eye = _V(0, 10, 24);
const _V _lookAt = _V(0, 2, 0);

// ------------------------------------------------------------- canvas room
// The scene is re-framed (scaled and moved, like the shell's zoom) so it
// fits between the shell's and this lab's cards at every screen size: the
// toast band at the top, the control tray and the HUD at the bottom, the
// tool column on the right and, with the sidebar collapsed, the floating
// mission card on the left. All in logical px at UI scale 1.

/// Room kept for a toast (one or two lines) at the top centre.
const double _toastBand = 32;

/// The shell's HUD card at the bottom while the sidebar is open.
const double _hudBand = 66;

/// Gap between the control tray and the scene.
const double _trayGap = 6;

/// Room kept for one row of scene labels (name and bin tag) below the
/// front row (S1) or above the objects (S2).
const double _labelBand = 34;

/// Re-framing limits and smoothing (time constant, seconds).
const double _minZoom = 0.5, _maxZoom = 1.6, _framingTau = 0.09;

/// Height of the control tray: padding, caption line, gap, one row of
/// 48 dp chips and the card's 1 px border top and bottom.
double _trayHeight(double s) =>
    2 * 7 * s + 14 * s + 5 * s + math.max(kMinInteractiveDimension, 46 * s) + 2;

/// Widest the control tray gets (two buttons / one tool).
const double _trayMaxWidth = 440, _trayOneWidth = 300;

// ------------------------------------------------- scenario 1: shine test
// HTML buildS1(). Objects rest on the table (the HTML left the foil, the
// wood block, the paper and the nail floating up to 0.7 above it).

/// Table: BoxGeometry(30, 0.5, 20) at y −0.25 (S1 0x334155, S2 0x1e293b).
const double _tableHalfX = 15, _tableHalfZ = 10, _tableHalfY = 0.25;

/// Spotlight: ConeGeometry(1.5, 3) turned apex-down; the HTML hung it at
/// (0, 6, 0), here a little lower (y 5.2, still 0.9 above the copper coil)
/// so the shine table can be shown larger on phones.
const _V _lampRest = _V(0, 5.2, 0);
const double _lampR = 1.5, _lampHalfH = 1.5;

/// The light pool under the spotlight while it shines.
const double _beamR = 2.0;

/// Copper wire: TorusGeometry(1.2, 0.2) standing at (−6, ·, 2).
const _V _copperC = _V(-6, 1.4, 2);
const double _copperR = 1.2, _copperTube = 0.2;

/// Aluminium foil: BoxGeometry(3, 0.1, 3) at (−2, ·, 2).
const _V _foilC = _V(-2, 0.05, 2), _foilHalf = _V(1.5, 0.05, 1.5);

/// Wood block: BoxGeometry(2.5, 1, 2.5) at (2, ·, 2).
const _V _woodC = _V(2, 0.5, 2), _woodHalf = _V(1.25, 0.5, 1.25);

/// Paper sheet: BoxGeometry(3, 0.05, 3.5) at (6, ·, 2).
const _V _paperC = _V(6, 0.025, 2), _paperHalf = _V(1.5, 0.025, 1.75);

/// Iron nail: CylinderGeometry(0.3, 0.3, 4) lying along x at (−3, ·, −4),
/// drawn with a head and a point (radius 0.4 so the cut face shows).
const double _nailY = 0.4, _nailZ = -4, _nailR = 0.4, _nailHeadR = 0.68;
const double _nailHeadX0 = -5.0, _nailHeadX1 = -4.85;
const double _nailTipX = -1.45, _nailPointX = -0.75, _nailCutX = -3;

/// After the cut the two halves swing open about the cut (V towards the
/// camera) so both fresh cut faces turn to the learner.
const double _nailOpenAngle = 0.8, _nailOpenGap = 0.25;

/// Chalk piece: CylinderGeometry(0.4, 0.4, 3) lying along x at (3, ·, −4).
const _V _chalkA = _V(1.5, 0.4, -4), _chalkB = _V(4.5, 0.4, -4);
const double _chalkR = 0.4;

// ------------------------------------------------ scenario 2: scratch test
// HTML buildS2().

/// Candle: CylinderGeometry(0.8, 0.8, 4) standing at (−6, ·, 0).
const _V _candleBase = _V(-6, 0, 0);
const double _candleR = 0.8, _candleH = 4;

/// Stone: DodecahedronGeometry(1.8) at (−2, ·, 0).
const double _stoneX = -2, _stoneRadius = 1.8;

/// Chalk: CylinderGeometry(0.5, 0.5, 3.5) standing at (2, ·, 0).
const _V _stickBase = _V(2, 0, 0);
const double _stickR = 0.5, _stickH = 3.5;

/// Wood block: BoxGeometry(3, 2, 3) at (6, ·, 0).
const _V _blockC = _V(6, 1, 0), _blockHalf = _V(1.5, 1, 1.5);

/// The metal key waits in front of the table (the HTML hovered it at
/// (0, 5, 2), on top of the stone's and the chalk's labels).
const _V _keyHome = _V(0, 0.7, 4.6);

/// Key tween (HTML): 300 ms to the material, four 150 ms scratch strokes
/// (`yoyo(true).repeat(3)`), 300 ms back.
const double _keyIn = 0.3, _keyScratch = 0.6, _keyOut = 0.3;

/// Length of a scratch stroke along the surface.
const double _strokeLen = 0.5;

// ----------------------------------------------------------- the materials

/// The bins of the HTML controls banner.
enum _Bin {
  lustrous('bin_lustrous', 'tag_lustrous', Icons.auto_awesome),
  nonLustrous('bin_nonlustrous', 'tag_nonlustrous', Icons.dark_mode),
  hard('bin_hard', 'tag_hard', Icons.shield),
  soft('bin_soft', 'tag_soft', Icons.gesture);

  const _Bin(this.labelKey, this.tagKey, this.icon);
  final String labelKey;
  final String tagKey;
  final IconData icon;

  /// Button fill (HTML: Lustrous / Soft `bg-amber-600`, Non-Lustrous /
  /// Hard `bg-slate-700`).
  Color get fill => switch (this) {
    _Bin.lustrous || _Bin.soft => _Colors.amber600,
    _Bin.nonLustrous || _Bin.hard => _Colors.slate700,
  };

  /// Tag colour on the dark scene labels.
  Color get tagColor => switch (this) {
    _Bin.lustrous || _Bin.soft => _Colors.amber300,
    _Bin.nonLustrous || _Bin.hard => _Colors.slate300,
  };
}

/// The bins offered in [scenario] (HTML order).
List<_Bin> _bins(int scenario) => scenario == 0
    ? const [_Bin.lustrous, _Bin.nonLustrous]
    : const [_Bin.hard, _Bin.soft];

/// The materials on the two tables, with the bin each belongs in.
enum _Item {
  copper(0, 'cwire', _Bin.lustrous, _Colors.amber600),
  foil(0, 'foil', _Bin.lustrous, _Colors.slate200),
  wood(0, 'wood', _Bin.nonLustrous, _Colors.amber800),
  paper(0, 'paper', _Bin.nonLustrous, _Colors.slate50),
  nail(0, 'nail', _Bin.lustrous, _Colors.slate600),
  chalk(0, 'chalk', _Bin.nonLustrous, _Colors.white),
  candle(1, 'candle', _Bin.soft, _Colors.yellow300),
  stone(1, 'stone', _Bin.hard, _Colors.slate500),
  stick(1, 'chalk', _Bin.soft, _Colors.white),
  block(1, 'wood', _Bin.hard, _Colors.amber900);

  const _Item(this.scenario, this.label, this.bin, this.color);
  final int scenario;
  final String label;
  final _Bin bin;
  final Color color;

  String get labelKey => 'lbl_$label';
}

/// The materials of [scenario] in the observation table's order.
List<_Item> _items(int scenario) => scenario == 0
    ? const [
        _Item.copper,
        _Item.foil,
        _Item.wood,
        _Item.paper,
        _Item.nail,
        _Item.chalk,
      ]
    : const [_Item.candle, _Item.stone, _Item.stick, _Item.block];

/// What a test showed.
enum _Obs {
  shines('res_shines'),
  dull('res_dull'),
  cut('res_cut'),
  groove('res_groove'),
  powder('res_powder'),
  unscratched('res_unscratched');

  const _Obs(this.key);
  final String key;
}

/// The Testing Tools (HTML `#floating-toolbox` items).
enum _Tool {
  spotlight(Icons.flashlight_on, null),
  cutter(Icons.content_cut, null),
  candle(Icons.key, _Item.candle),
  stone(Icons.key, _Item.stone),
  chalk(Icons.key, _Item.stick),
  wood(Icons.key, _Item.block);

  const _Tool(this.icon, this.target);
  final IconData icon;

  /// The material a key tool scratches.
  final _Item? target;

  /// Button fill and text (HTML: spotlight `bg-amber-500 text-slate-950`,
  /// cutter `bg-rose-600 text-white`, keys `bg-slate-800` with the
  /// material's colour).
  Color get fill => switch (this) {
    _Tool.spotlight => _Colors.amber500,
    _Tool.cutter => _Colors.rose600,
    _ => _Colors.slate800,
  };

  Color get ink => switch (this) {
    _Tool.spotlight => _Colors.slate950,
    _Tool.cutter => _Colors.white,
    _Tool.candle => _Colors.yellow300,
    _Tool.stone => _Colors.slate300,
    _Tool.chalk => _Colors.white,
    _Tool.wood => _Colors.amber400,
  };
}

// ------------------------------------------------------------- animations

/// The lab's timed actions and the moments (seconds after the start) at
/// which something happens; the last moment ends the action.
enum _AnimKind {
  /// HTML `useSpotlight()` step 1: copper 0.3 s, foil 1.1 s, wood 1.9 s,
  /// paper 2.6 s, back home 3.3 s.
  sweepFront([0.3, 1.1, 1.9, 2.6, 3.3]),

  /// HTML `useSpotlight()` step 3: nail 0.4 s, chalk 1.2 s, home 1.9 s.
  sweepBack([0.4, 1.2, 1.9]),

  /// Cut: the blade reaches the nail at 0.35 s; the halves have opened by
  /// 0.75 s.
  cut([0.35, 0.9]),

  /// HTML `scratchTest()`: the result at 600 ms, the key home at 1.2 s.
  scratch([0.6, 1.2]);

  const _AnimKind(this.events);
  final List<double> events;
}

/// A running timed action.
class _Anim {
  _Anim(this.kind, this.start, {this.item});

  final _AnimKind kind;
  final double start;
  final _Item? item;

  /// Moments already handled.
  int fired = 0;
}

/// Spotlight keyframes (seconds, x, z) of the HTML TWEEN chains (linear;
/// the lamp stays at y 6).
const List<(double, double, double)> _sweepFrontKeys = [
  (0.0, 0, 0),
  (0.3, -6, 2),
  (0.7, -6, 2),
  (1.1, -2, 2),
  (1.5, -2, 2),
  (1.9, 2, 2),
  (2.2, 2, 2),
  (2.6, 6, 2),
  (2.9, 6, 2),
  (3.3, 0, 0),
];
const List<(double, double, double)> _sweepBackKeys = [
  (0.0, 0, 0),
  (0.4, -3, -4),
  (0.7, -3, -4),
  (1.2, 3, -4),
  (1.5, 3, -4),
  (1.9, 0, 0),
];

/// Lamp (x, z) at [t] seconds along [keys].
(double, double) _keyAt(List<(double, double, double)> keys, double t) {
  if (t <= keys.first.$1) return (keys.first.$2, keys.first.$3);
  for (var i = 1; i < keys.length; i++) {
    final b = keys[i];
    if (t <= b.$1) {
      final a = keys[i - 1];
      final k = (t - a.$1) / (b.$1 - a.$1);
      return (a.$2 + (b.$2 - a.$2) * k, a.$3 + (b.$3 - a.$3) * k);
    }
  }
  return (keys.last.$2, keys.last.$3);
}

/// TWEEN.Easing.Quadratic.Out / In.
double _quadOut(double t) => t * (2 - t);
double _quadIn(double t) => t * t;

/// A short glow on a material (HTML `emissiveIntensity` pulses).
@immutable
class _Glow {
  const _Glow(this.start, this.color, this.peak, this.duration);

  final double start;
  final Color color;
  final double peak;
  final double duration;
}

/// Particle effects of the HTML (`createSparkleEffect`,
/// `createSparksEffect`, `createDustEffect`).
enum _FxKind { sparkle, sparks, dust }

/// One particle burst; its random paths are drawn once when it starts.
class _Fx {
  _Fx(this.kind, this.at, this.start, int seed, {this.tint = _Colors.white}) {
    final r = math.Random(seed);
    final n = kind == _FxKind.sparkle ? 24 : 20;
    for (var i = 0; i < n; i++) {
      switch (kind) {
        // 24 octahedra from ±1 flying out to ×3 … ×5.5 (800 – 1300 ms,
        // Quadratic.Out), spinning, shrinking and fading over 1.2 s.
        case _FxKind.sparkle:
          final o = _V(
            (r.nextDouble() - 0.5) * 2,
            (r.nextDouble() - 0.5) * 2,
            (r.nextDouble() - 0.5) * 2,
          );
          from.add(o);
          to.add(o * (3 + r.nextDouble() * 2.5));
          time.add(0.8 + r.nextDouble() * 0.5);
          spin.add(r.nextDouble() * math.pi * 4);
        // 20 spheres from the scratch point to ±1.5 / 0 … 3 (500 – 800 ms,
        // Quadratic.Out), shrinking over 0.8 s.
        case _FxKind.sparks:
          from.add(const _V(0, 0, 0));
          to.add(
            _V(
              (r.nextDouble() - 0.5) * 3,
              r.nextDouble() * 3,
              (r.nextDouble() - 0.5) * 3,
            ),
          );
          time.add(0.5 + r.nextDouble() * 0.3);
          spin.add(0);
        // 20 cubes falling from ±0.25 to ±1 / −2 … −4 (600 – 1000 ms,
        // Quadratic.In), fading over 1 s; they settle on the table.
        case _FxKind.dust:
          from.add(
            _V(
              (r.nextDouble() - 0.5) * 0.5,
              (r.nextDouble() - 0.5) * 0.5,
              (r.nextDouble() - 0.5) * 0.5,
            ),
          );
          to.add(
            _V(
              (r.nextDouble() - 0.5) * 2,
              -2 - r.nextDouble() * 2,
              (r.nextDouble() - 0.5) * 2,
            ),
          );
          time.add(0.6 + r.nextDouble() * 0.4);
          spin.add(r.nextDouble() * math.pi * 2);
      }
    }
  }

  final _FxKind kind;
  final _V at;
  final double start;
  final Color tint;
  final List<_V> from = [];
  final List<_V> to = [];
  final List<double> time = [];
  final List<double> spin = [];

  /// HTML `setTimeout(… scene.remove(group))`: 1.5 s, 1 s, 1.2 s.
  double get life => switch (kind) {
    _FxKind.sparkle => 1.5,
    _FxKind.sparks => 1.0,
    _FxKind.dust => 1.2,
  };
}

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// 1-based step; 6 once the scenario is complete.
  int step = 1;

  /// Test results and sorted bins of this scenario.
  final Map<_Item, _Obs> obs = {};
  final Map<_Item, _Bin> sorted = {};

  /// Materials waiting to be sorted in the current classification step.
  final List<_Item> queue = [];

  /// Key tools already used in S2 step 4 (each counts once; the HTML
  /// counted every press, so chalk twice passed as "both tested").
  final Set<_Tool> tested = {};

  _Anim? anim;

  /// Start of the cut (null until the nail is cut).
  double? cutStart;

  /// Start of each scratch that leaves a groove.
  final Map<_Item, double> grooves = {};
  final Map<_Item, _Glow> glows = {};
  final List<_Fx> effects = [];

  /// Current and wanted framing (see [_Framing]).
  _Framing framing = _Framing.identity;
  _Framing target = _Framing.identity;

  bool get busy => anim != null;

  /// The material the bins are asking about.
  _Item? get sortItem {
    for (final i in queue) {
      if (!sorted.containsKey(i)) return i;
    }
    return null;
  }

  /// Name of [sortItem] (read by the flow test).
  String? get sortingId => sortItem?.name;

  bool get nailCut => cutStart != null && time - cutStart! >= 0.35;

  /// The tools the current step offers (HTML `updateStepVisibility()`).
  List<_Tool> get offeredTools {
    if (scenario == 0) {
      return switch (step) {
        1 || 3 => const [_Tool.spotlight],
        4 => const [_Tool.cutter],
        _ => const [],
      };
    }
    return switch (step) {
      1 => const [_Tool.candle],
      2 => const [_Tool.stone],
      4 => [
        for (final t in const [_Tool.chalk, _Tool.wood])
          if (!tested.contains(t)) t,
      ],
      _ => const [],
    };
  }

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    obs.clear();
    sorted.clear();
    queue.clear();
    tested.clear();
    anim = null;
    cutStart = null;
    grooves.clear();
    glows.clear();
    effects.clear();
  }

  /// Starts [tool]'s timed action.
  void start(_Tool tool) {
    switch (tool) {
      case _Tool.spotlight:
        anim = _Anim(
          step == 1 ? _AnimKind.sweepFront : _AnimKind.sweepBack,
          time,
        );
      case _Tool.cutter:
        anim = _Anim(_AnimKind.cut, time);
        cutStart = time;
      case _Tool.candle || _Tool.stone || _Tool.chalk || _Tool.wood:
        final item = tool.target!;
        anim = _Anim(_AnimKind.scratch, time, item: item);
        if (item == _Item.candle || item == _Item.stick) grooves[item] = time;
    }
  }

  /// Spotlight position (x, z); it rests at the origin.
  (double, double) get lampXZ {
    final a = anim;
    if (a == null) return (_lampRest.x, _lampRest.z);
    return switch (a.kind) {
      _AnimKind.sweepFront => _keyAt(_sweepFrontKeys, time - a.start),
      _AnimKind.sweepBack => _keyAt(_sweepBackKeys, time - a.start),
      _ => (_lampRest.x, _lampRest.z),
    };
  }

  /// The spotlight shines only while it sweeps.
  bool get beamOn {
    final k = anim?.kind;
    return k == _AnimKind.sweepFront || k == _AnimKind.sweepBack;
  }

  /// How far the nail halves have swung open (0 … 1).
  double get nailOpen {
    final c = cutStart;
    if (c == null) return 0;
    return ((time - c - 0.35) / 0.4).clamp(0.0, 1.0);
  }

  /// Blade height above the nail axis and opacity during the cut.
  (double, double) get blade {
    final c = cutStart;
    if (c == null) return (0, 0);
    final t = time - c;
    if (t < 0.35) return (2.4 * (1 - _quadIn(t / 0.35)), 1);
    if (t < 0.75) {
      final k = (t - 0.35) / 0.4;
      return (2.6 * _quadOut(k), 1 - k);
    }
    return (0, 0);
  }

  /// Key position: home, or the HTML scratch tween on [anim]'s material.
  _V get keyPos {
    final a = anim;
    final item = a?.item;
    if (a == null || item == null) return _keyHome;
    final t = time - a.start;
    final p = _scratchPoint(item);
    // The tip (local x −1) starts half a stroke left of the point.
    final at = _V(p.x - _strokeLen / 2 + 1, p.y, p.z);
    if (t < _keyIn) return _lerpV(_keyHome, at, t / _keyIn);
    if (t < _keyIn + _keyScratch) {
      final leg = (t - _keyIn) / (_keyScratch / 4);
      final w = leg.floor().isEven
          ? leg - leg.floor()
          : 1 - (leg - leg.floor());
      return _V(at.x + _strokeLen * w, at.y - 0.1 * w, at.z);
    }
    return _lerpV(
      at,
      _keyHome,
      ((t - _keyIn - _keyScratch) / _keyOut).clamp(0.0, 1.0),
    );
  }

  /// Groove length so far (0 … 1) on [item].
  double grooveAt(_Item item) {
    final g = grooves[item];
    if (g == null) return 0;
    return ((time - g - _keyIn) / _keyScratch).clamp(0.0, 1.0);
  }

  /// Whether the scratch on the material named [id] is complete (read by
  /// the flow test).
  bool grooved(String id) => grooveAt(_Item.values.byName(id)) >= 1;

  /// What the recorded static picture shows (see [_PictureCache]).
  Object get pictureKey =>
      (scenario, sortItem, (nailOpen * 20).round(), cutStart != null);

  bool get framingSettled => framing.near(target);

  /// Stage design point of [id] ('centre' or a material name), as the
  /// learner sees it now (read by the flow test to drop tools).
  Offset anchor(String id) {
    final world = id == 'centre'
        ? (scenario == 0 ? const _V(0, 0.5, 0) : const _V(0, 1.5, 0))
        : _itemCentre(_Item.values.byName(id));
    return framing.map(_proj.p(world));
  }
}

_V _lerpV(_V a, _V b, double k) =>
    _V(a.x + (b.x - a.x) * k, a.y + (b.y - a.y) * k, a.z + (b.z - a.z) * k);

/// The front-surface point the key scratches (HTML targets (x, 3, 1) with
/// the key's tip beside the material; here the tip touches its front).
_V _scratchPoint(_Item item) => switch (item) {
  _Item.candle => const _V(-6, 2.4, _candleR + 0.05),
  _Item.stone => _V(_stoneX, _stone.centreY, _stone.front + 0.05),
  _Item.stick => const _V(2, 2.0, _stickR + 0.05),
  _Item.block => const _V(6, 1.0, 1.55),
  _ => const _V(0, 0, 0),
};

/// Middle of [item] (glows, highlight rings, drop anchors).
_V _itemCentre(_Item item) => switch (item) {
  _Item.copper => _copperC,
  _Item.foil => _foilC,
  _Item.wood => _woodC,
  _Item.paper => _paperC,
  _Item.nail => const _V(_nailCutX, _nailY, _nailZ),
  _Item.chalk => const _V(3, 0.4, -4),
  _Item.candle => const _V(-6, 2, 0),
  _Item.stone => _V(_stoneX, _stone.centreY, 0),
  _Item.stick => const _V(2, 1.75, 0),
  _Item.block => _blockC,
};

/// Radii (x, z) of the highlight ring on the table around [item].
(double, double) _ringRadii(_Item item) => switch (item) {
  _Item.copper => (1.7, 0.9),
  _Item.foil => (2.1, 1.9),
  _Item.wood => (1.8, 1.7),
  _Item.paper => (2.1, 2.3),
  _Item.nail => (2.7, 1.9),
  _Item.chalk => (2.0, 0.9),
  _Item.candle => (1.3, 1.3),
  _Item.stone => (2.2, 2.0),
  _Item.stick => (1.0, 1.0),
  _Item.block => (2.2, 2.1),
};

/// Where each scene label sits, and whether it hangs below the point
/// (S1 front row, so it never covers the nail or the chalk behind) or
/// stands above it. The nail's and the chalk's labels stand behind them
/// (the HTML put them just above), clear of the opened nail halves.
(_V, bool) _labelSpot(_Item item) => switch (item) {
  _Item.copper => (const _V(-6, 0, 3.9), true),
  _Item.foil => (const _V(-2, 0, 3.9), true),
  _Item.wood => (const _V(2, 0, 3.9), true),
  _Item.paper => (const _V(6, 0, 3.9), true),
  _Item.nail => (const _V(_nailCutX, 0, -7.4), false),
  _Item.chalk => (const _V(3, 0, -7.4), false),
  _Item.candle => (const _V(-6, _candleH + 0.45, 0), false),
  _Item.stone => (_V(_stoneX, _stone.top + 0.1, 0), false),
  _Item.stick => (const _V(2, _stickH + 0.1, 0), false),
  _Item.block => (const _V(6, 2.1, 0), false),
};

/// Scene labels in rows (neighbours share the row's room).
const List<List<_Item>> _labelRows = [
  [_Item.nail, _Item.chalk],
  [_Item.copper, _Item.foil, _Item.wood, _Item.paper],
  [_Item.candle, _Item.stone, _Item.stick, _Item.block],
];

/// Projected label points (stage design px before framing).
final Map<_Item, Offset> _labelPoints = {
  for (final i in _Item.values) i: _proj.p(_labelSpot(i).$1),
};

/// The part of the scene each scenario must keep in view (stage design px
/// before framing): every material, the spotlight on its whole sweep (S1)
/// and the key at home (S2); labels get their own band.
final List<Rect> _contentBox = [
  _bounds([
    for (final (x, z) in const [(0.0, 0.0), (-6.0, 2.0), (6.0, 2.0)])
      ..._corners(_V(x, _lampRest.y, z), const _V(_lampR, _lampHalfH, _lampR)),
    ..._corners(
      _copperC,
      const _V(_copperR + _copperTube, _copperR + _copperTube, _copperTube),
    ),
    ..._corners(_foilC, _foilHalf),
    ..._corners(_woodC, _woodHalf),
    ..._corners(_paperC, _paperHalf),
    ..._corners(const _V(-3, 0.4, -4.8), const _V(2.3, 0.4, 1.2)),
    ..._corners(const _V(3, 0.4, -4), const _V(1.5, 0.4, 0.4)),
    for (final i in _labelRows[1]) _labelSpot(i).$1,
  ]),
  _bounds([
    ..._corners(
      const _V(-6, _candleH / 2 + 0.2, 0),
      const _V(_candleR, _candleH / 2 + 0.2, _candleR),
    ),
    ..._corners(
      _V(_stoneX, _stone.centreY, 0),
      const _V(_stoneRadius, _stoneRadius, _stoneRadius),
    ),
    ..._corners(
      const _V(2, _stickH / 2, 0),
      const _V(_stickR, _stickH / 2, _stickR),
    ),
    ..._corners(_blockC, _blockHalf),
    ..._corners(_keyHome + const _V(0.1, 0, 0), const _V(1.6, 0.7, 0.2)),
  ]),
];

List<_V> _corners(_V c, _V h) => [
  for (final sx in const [-1.0, 1.0])
    for (final sy in const [-1.0, 1.0])
      for (final sz in const [-1.0, 1.0])
        _V(c.x + sx * h.x, c.y + sy * h.y, c.z + sz * h.z),
];

Rect _bounds(List<_V> pts) {
  var r = Rect.zero;
  var first = true;
  for (final w in pts) {
    final o = _proj.p(w);
    if (first) {
      r = Rect.fromLTWH(o.dx, o.dy, 0, 0);
      first = false;
    } else {
      r = r.expandToInclude(Rect.fromLTWH(o.dx, o.dy, 0, 0));
    }
  }
  return r;
}

/// The 2D view applied on top of the HTML camera: the content point [from]
/// is drawn at [to], scaled by [zoom] (stage design px).
@immutable
class _Framing {
  const _Framing(this.from, this.to, this.zoom);

  static const _Framing identity = _Framing(
    Offset(500, 280),
    Offset(500, 280),
    1,
  );

  final Offset from;
  final Offset to;
  final double zoom;

  Offset map(Offset p) => to + (p - from) * zoom;

  _Framing towards(_Framing t, double k) => _Framing(
    Offset.lerp(from, t.from, k)!,
    Offset.lerp(to, t.to, k)!,
    zoom + (t.zoom - zoom) * k,
  );

  bool near(_Framing o) =>
      (from - o.from).distance < 0.5 &&
      (to - o.to).distance < 0.5 &&
      (zoom - o.zoom).abs() < 0.002;
}

class _LustreLabState
    extends State<Ch6A2ExploringMaterialPropertiesLustreAndHardnessPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  /// Canvas text and the recorded static scene, reused every frame.
  final _TextCache _texts = _TextCache();
  final _PictureCache _pictures = _PictureCache();

  /// Jump straight to the wanted framing on the next layout (scenario
  /// change); otherwise the scene glides there.
  bool _snapFraming = true;

  /// UI scale of the last build (popup table).
  double _uiScale = 1;

  /// The visible toast of this lab and how to word it in any language, so
  /// it is shown again translated after a language switch.
  String Function()? _toastText;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarioData(_lab.lang)[_scene.scenario];

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
    _scene.load(0);
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
    _texts.dispose();
    _pictures.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ animation

  /// HTML `animate()` (TWEEN.update): runs the timed action's moments,
  /// drops finished effects and glides the framing. Only the canvas
  /// repaints.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    final a = s.anim;
    if (a != null) {
      final moments = a.kind.events;
      while (identical(s.anim, a) &&
          a.fired < moments.length &&
          now - a.start >= moments[a.fired]) {
        _onMoment(a, a.fired++);
      }
    }
    s.effects.removeWhere((fx) => now - fx.start > fx.life);
    s.glows.removeWhere((_, g) => now - g.start > g.duration);
    if (!s.framing.near(s.target)) {
      s.framing = s.framing.towards(s.target, 1 - math.exp(-dt / _framingTau));
    }
    _frame.value = now;
  }

  /// Something happens [index] moments into the timed action [a].
  void _onMoment(_Anim a, int index) {
    final s = _scene;
    final last = index == a.kind.events.length - 1;
    switch (a.kind) {
      case _AnimKind.sweepFront:
        if (!last) {
          const lit = [_Item.copper, _Item.foil, _Item.wood, _Item.paper];
          _light(lit[index]);
          // The HTML toasted this before the light even reached the wire.
          if (index == 3) _toast(() => _t('toast_shine'));
        } else {
          setState(() {
            s
              ..anim = null
              ..step = 2
              ..queue.addAll(const [
                _Item.copper,
                _Item.foil,
                _Item.wood,
                _Item.paper,
              ]);
          });
        }
      case _AnimKind.sweepBack:
        if (index == 0) {
          _light(_Item.nail);
        } else if (index == 1) {
          _light(_Item.chalk);
          _toast(() => _t('toast_dull'));
        } else {
          setState(() {
            s
              ..anim = null
              ..step = 4;
          });
        }
      case _AnimKind.cut:
        if (index == 0) {
          setState(() => s.obs[_Item.nail] = _Obs.cut);
          s.effects.add(
            _Fx(_FxKind.sparkle, _nailCutPoint, s.time, _seed(_Item.nail)),
          );
          s.glows[_Item.nail] = _Glow(s.time, _Colors.sky400, 0.6, 1.0);
          _toast(() => _t('toast_cut'));
        } else {
          setState(() {
            s
              ..anim = null
              ..step = 5
              ..queue.addAll(const [_Item.nail, _Item.chalk]);
          });
        }
      case _AnimKind.scratch:
        final item = a.item!;
        if (index == 0) {
          _scratched(item);
        } else {
          _scratchDone(item);
        }
    }
  }

  int _seed(_Item item) => (_scene.time * 1000).round() + item.index;

  /// The spotlight reaches [item]: metals sparkle and glow (HTML sparkle
  /// effect + emissive pulse); the rest stay dull.
  void _light(_Item item) {
    final s = _scene;
    final shines = item.bin == _Bin.lustrous && item != _Item.nail;
    setState(() => s.obs[item] = shines ? _Obs.shines : _Obs.dull);
    if (!shines) return;
    final at = item == _Item.copper
        ? const _V(-6, 1.6, 2)
        : const _V(-2, 0.5, 2);
    s.effects.add(_Fx(_FxKind.sparkle, at, s.time, _seed(item)));
    s.glows[item] = item == _Item.copper
        ? _Glow(s.time, _Colors.amber600, 0.6, 0.8)
        : _Glow(s.time, _Colors.slate200, 0.7, 0.8);
  }

  /// HTML `scratchTest(item)` at 600 ms: the result, its effect and toast.
  void _scratched(_Item item) {
    final s = _scene;
    final p = _scratchPoint(item);
    switch (item) {
      case _Item.candle:
        setState(() => s.obs[item] = _Obs.groove);
        s.effects.add(
          _Fx(_FxKind.dust, p, s.time, _seed(item), tint: _Colors.yellow200),
        );
        _toast(() => _t('toast_candle'));
      case _Item.stone:
        setState(() => s.obs[item] = _Obs.unscratched);
        s.effects.add(_Fx(_FxKind.sparks, p, s.time, _seed(item)));
        _toast(() => _t('toast_stone'));
      case _Item.stick:
        setState(() => s.obs[item] = _Obs.powder);
        s.effects.add(_Fx(_FxKind.dust, p, s.time, _seed(item)));
        _toast(() => _t('toast_chalk'));
      case _Item.block:
        setState(() => s.obs[item] = _Obs.unscratched);
        _toast(() => _t('toast_wood'));
      default:
        break;
    }
  }

  /// The key is home again: the next step (HTML `State.step` ladder).
  void _scratchDone(_Item item) {
    final s = _scene;
    setState(() {
      s.anim = null;
      switch (item) {
        case _Item.candle:
          s
            ..tested.add(_Tool.candle)
            ..step = 2;
        case _Item.stone:
          s
            ..tested.add(_Tool.stone)
            ..step = 3
            ..queue.addAll(const [_Item.candle, _Item.stone]);
        case _Item.stick || _Item.block:
          s.tested.add(item == _Item.stick ? _Tool.chalk : _Tool.wood);
          if (s.tested.containsAll(const [_Tool.chalk, _Tool.wood])) {
            s
              ..step = 5
              ..queue.addAll(const [_Item.stick, _Item.block]);
          }
        default:
          break;
      }
    });
    if (s.step == 5 && s.scenario == 1 && s.queue.length == 2) {
      // After the second material's own toast has been read.
      _lab.after(const Duration(milliseconds: 1500), () {
        if (!mounted || _scene.step != 5 || _scene.sorted.length > 2) return;
        _toast(() => _t('toast_s2_both'));
      });
    }
  }

  // ---------------------------------------------------------------- logic

  /// HTML `showToast(msg)`; tones are played by the callers.
  void _toast(String Function() text, {bool error = false}) {
    _toastText = text;
    _lab.showToast(text(), isError: error, sound: error);
  }

  /// Re-shows the visible toast (this lab's or the shell's "Scenario
  /// Complete") in the new language after a switch from [previous].
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    if (shown == null) return;
    final fn = _toastText;
    final String translated;
    if (fn != null && shown.text == _withLang(previous, fn)) {
      translated = fn();
    } else if (shown.text ==
        labTr(kLabCommonStrings, previous, 'msg_scenario_complete')) {
      translated = _lab.t('msg_scenario_complete');
    } else {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(translated, isError: shown.isError, sound: false);
    });
  }

  /// [fn]'s text in [lang].
  String _withLang(LabLang lang, String Function() fn) {
    final now = _lab.lang;
    _lab.lang = lang;
    final text = fn();
    _lab.lang = now;
    return text;
  }

  /// HTML `changeScenario(id)` / `resetApp()`: cancels every pending
  /// timer and animation and starts [index] at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _snapFraming = true;
    });
    _lab.resetView(sound: false);
  }

  bool _canUse(_Tool t) =>
      _lab.isLabActive &&
      _lab.popup == null &&
      !_scene.busy &&
      _scene.offeredTools.contains(t);

  /// A Testing Tool tapped or dropped on the table (HTML `useSpotlight()`,
  /// `cutIronNail()`, `scratchTest(item)`).
  void _useTool(_Tool t) {
    if (!_canUse(t)) return;
    _Sound.measure.play();
    setState(() => _scene.start(t));
  }

  /// A bin button (HTML `classifyS1(type)` / `classifyS2(type)`). The HTML
  /// accepted any two presses of any bin (even before testing, which
  /// opened the summary at step 1); here the highlighted material must go
  /// into its own bin, and a wrong bin is refused with a hint.
  void _sort(_Bin bin) {
    final s = _scene;
    final item = s.sortItem;
    if (item == null || s.busy) return;
    String name() => _t(item.labelKey);
    if (item.bin != bin) {
      final key = item == _Item.nail
          ? 'toast_wrong_nail'
          : (s.scenario == 0 ? 'toast_wrong_s1' : 'toast_wrong_s2');
      _toast(() => labFormat(_t(key), {'name': name()}), error: true);
      return;
    }
    _Sound.success.play();
    setState(() => s.sorted[item] = bin);
    _toast(
      () => labFormat(_t('toast_sorted'), {
        'name': name(),
        'bin': _t(bin.tagKey),
      }),
    );
    if (s.sortItem != null) return;
    setState(() {
      s.queue.clear();
      s.step += 1;
    });
    if (s.step == 3) _toast(() => _t('toast_s1_sorted'));
    if (s.step == 4) _toast(() => _t('toast_s2_sorted'));
    if (s.step > _stepCount) _showConclusion(s.scenario);
  }

  /// HTML `showObservationPopup()` 800 ms after the last sort: the
  /// scenario summary (S2: "Mastery Achieved!" once both are done) with the
  /// observation table.
  void _showConclusion(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: const Duration(milliseconds: 800),
      title: () => scenario == 1 && _lab.completedScenarios.length >= 2
          ? _t('all_complete')
          : labFormat(_t('sc_complete'), {'n': scenario + 1}),
      heading: () => _scenarioData(_lab.lang)[scenario].title,
      body: () {
        final summary = _t('sum_s${scenario + 1}');
        if (scenario == 1 && _lab.completedScenarios.length >= 2) {
          return '$summary\n\n${_t('all_complete_desc')}';
        }
        return summary;
      },
      extra: () => _resultsTable(
        _lab.palette,
        _uiScale * _lab.fontScale.clamp(0.9, 1.4),
      ),
    );
  }

  // ------------------------------------------------------------------- UI

  String _toolLabel(_Tool t) => switch (t) {
    _Tool.spotlight => _t(
      _scene.step == 3 ? 'tool_spotlight_nail' : 'tool_spotlight',
    ),
    _Tool.cutter => _t('tool_cutter'),
    _Tool.candle => _t('test_candle'),
    _Tool.stone => _t('test_stone'),
    _Tool.chalk => _t('test_chalk'),
    _Tool.wood => _t('test_wood'),
  };

  /// The tools of the step, or the two bins while a material waits.
  List<LabAction> _actions() {
    final s = _scene;
    final tools = s.offeredTools;
    if (tools.isNotEmpty) {
      return [
        for (final t in tools)
          LabAction(
            label: _toolLabel(t),
            icon: t.icon,
            color: t.fill,
            foreground: t.ink,
            enabled: !s.busy,
            highlight: !s.busy,
            silent: true,
            onTap: () => _useTool(t),
          ),
      ];
    }
    if (s.sortItem == null) return const [];
    return [
      for (final b in _bins(s.scenario))
        LabAction(
          label: _t(b.labelKey),
          icon: b.icon,
          color: b.fill,
          foreground: _Colors.white,
          silent: true,
          onTap: () => _sort(b),
        ),
    ];
  }

  /// The observation table (sidebar and conclusion popup).
  Widget _resultsTable(LabPalette p, double scale) {
    final s = _scene;
    final current = s.sortItem;
    return _ResultsTable(
      palette: p,
      scale: scale,
      headLeft: _t('tbl_material'),
      headRight: _t('tbl_result'),
      sortNow: _t('sort_now'),
      rows: [
        for (final item in _items(s.scenario))
          _ResultRow(
            label: _t(item.labelKey),
            value: _t(s.obs[item]?.key ?? 'res_untested'),
            swatch: item.color,
            tested: s.obs.containsKey(item),
            bin: s.sorted[item] == null ? null : _t(s.sorted[item]!.tagKey),
            binColor: s.sorted[item]?.fill,
            current: item == current,
          ),
      ],
    );
  }

  /// Sidebar extra: the observation table, then the observation of every
  /// step done so far (the HTML accordion's "Observation", shown once
  /// observed).
  Widget _sidebarPanel(LabPalette p, double s, LabScenarioData data) {
    final f = s * _lab.fontScale;
    final done = math.min(_scene.step - 1, data.steps.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _resultsTable(p, f),
        if (done > 0) ...[
          SizedBox(height: 12 * s),
          LabSectionLabel(
            _t('observations'),
            size: 10.5 * s,
            icon: Icons.visibility,
          ),
          SizedBox(height: 6 * s),
          for (var i = 1; i <= done; i++)
            _ObservationLine(
              number: i,
              text: data.steps[i - 1].observation,
              palette: p,
              scale: f,
            ),
        ],
      ],
    );
  }

  /// The control tray (HTML `#floating-toolbox` and `#controls-banner`):
  /// the step's tools (tap or drag) or the two bins with the material to
  /// sort.
  Widget? _tray(LabPalette p, double s, double width) {
    final sc = _scene;
    final tools = sc.offeredTools;
    final item = sc.sortItem;
    if (tools.isEmpty && item == null) return null;
    final chipH = math.max(kMinInteractiveDimension, 46 * s);
    final List<Widget> chips;
    final InlineSpan caption;
    final captionStyle = TextStyle(
      color: p.textMuted,
      fontSize: 10 * s,
      fontWeight: FontWeight.w600,
    );
    final strong = TextStyle(
      color: p.textStrong,
      fontWeight: FontWeight.w900,
      letterSpacing: labLetterSpacing(_t('toolbox_title'), 0.6),
    );
    if (tools.isNotEmpty) {
      caption = TextSpan(
        children: [
          TextSpan(text: _t('toolbox_title').toUpperCase(), style: strong),
          const TextSpan(text: '  '),
          TextSpan(
            text: _t(sc.scenario == 0 ? 'toolbox_s1_desc' : 'toolbox_s2_desc'),
          ),
        ],
      );
      chips = [
        for (final t in tools) _toolChip(t, s, chipH, width / tools.length),
      ];
    } else {
      caption = TextSpan(
        children: [
          TextSpan(
            text: _t(
              sc.scenario == 0 ? 'classify_prompt' : 'classify_hard_prompt',
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: _t(item!.labelKey),
            style: TextStyle(color: p.accentInk, fontWeight: FontWeight.w900),
          ),
        ],
      );
      chips = [
        for (final b in _bins(sc.scenario))
          Material(
            color: LabInk.clear,
            child: InkWell(
              key: ValueKey('ch6a2-bin-${b.name}'),
              borderRadius: BorderRadius.circular(12 * s),
              onTap: () => _sort(b),
              child: _TrayChip(
                label: _t(b.labelKey),
                icon: b.icon,
                fill: b.fill,
                ink: _Colors.white,
                height: chipH,
                scale: s,
              ),
            ),
          ),
      ];
    }
    return SizedBox(
      width: width,
      height: _trayHeight(s),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 7 * s),
        radius: 16,
        borderColor: p.accent.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 14 * s,
              child: Row(
                children: [
                  Icon(
                    tools.isNotEmpty ? Icons.back_hand : Icons.inventory_2,
                    size: 12 * s,
                    color: p.accentInk,
                  ),
                  SizedBox(width: 5 * s),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        caption,
                        maxLines: 1,
                        style: captionStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5 * s),
            SizedBox(
              height: chipH,
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) SizedBox(width: 8 * s),
                    Expanded(child: chips[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A Testing Tool: tap it, or drag it onto the table (HTML
  /// `draggable="true"` with a drop zone over the whole scene).
  Widget _toolChip(_Tool t, double s, double height, double width) {
    final enabled = _canUse(t);
    Widget chip({bool lifted = false, bool dimmed = false}) => _TrayChip(
      label: _toolLabel(t),
      icon: t.icon,
      fill: t.fill,
      ink: t.ink,
      height: height,
      scale: s,
      enabled: (enabled || lifted) && !dimmed,
      lifted: lifted,
    );
    return Draggable<_Tool>(
      data: t,
      maxSimultaneousDrags: enabled ? 1 : 0,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: _Sound.pop.play,
      // Centred on the finger.
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: math.min(width, 220 * s),
            child: chip(lifted: true),
          ),
        ),
      ),
      childWhenDragging: chip(dimmed: true),
      child: Material(
        color: LabInk.clear,
        child: InkWell(
          key: ValueKey('ch6a2-tool-${t.name}'),
          borderRadius: BorderRadius.circular(12 * s),
          onTap: enabled ? () => _useTool(t) : null,
          child: chip(),
        ),
      ),
    );
  }

  /// The framing that fits [_contentBox] between the cards for a canvas of
  /// [canvas] logical px (see the "canvas room" constants).
  _Framing _framingFor(BuildContext context, Size canvas) {
    final box = _contentBox[_scene.scenario];
    final k = math.min(
      canvas.width / _design.width,
      canvas.height / _design.height,
    );
    if (!k.isFinite || k <= 0) return _Framing.identity;
    final screen = MediaQuery.sizeOf(context);
    final s = context.labScale;
    final inset = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    // While the sidebar slides, the canvas starts where it ends.
    final sidebarNow = math.max(0.0, screen.width - canvas.width);
    final left = open ? inset.left : math.max(8.0, inset.left - sidebarNow);
    final right = canvas.width - inset.right;
    var top = inset.top + _toastBand * s;
    var bottom =
        canvas.height -
        inset.bottom -
        (open ? _hudBand * s : 0) -
        _trayHeight(s) -
        _trayGap * s;
    if (_scene.scenario == 0) {
      bottom -= _labelBand * s;
    } else {
      top += _labelBand * s;
    }
    final ox = (canvas.width - _design.width * k) / 2;
    final oy = (canvas.height - _design.height * k) / 2;
    final free = Rect.fromLTRB(
      (left - ox) / k,
      (top - oy) / k,
      (right - ox) / k,
      (bottom - oy) / k,
    );
    if (free.width <= 1 || free.height <= 1) {
      return _Framing(box.center, free.center, _minZoom);
    }
    final zoom = math
        .min(free.width / box.width, free.height / box.height)
        .clamp(_minZoom, _maxZoom);
    return _Framing(box.center, free.center, zoom);
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
        final sc = _scene.scenario;
        final inset = labOverlayInsets(context, _lab);
        final pad = MediaQuery.paddingOf(context);
        final screen = MediaQuery.sizeOf(context);
        final open = _lab.isSidebarOpen;
        // The canvas is the screen minus the sidebar (as the shell sizes
        // it); the tray spans it between the left margin and the tools.
        final canvasW = open
            ? screen.width - _sidebarWidth(screen.width)
            : screen.width;
        final trayLeft = open ? inset.left : 8 + pad.left;
        final trayRoom = math.max(0.0, canvasW - trayLeft - inset.right);
        // One tool gets a narrower tray than two buttons.
        final trayWidth =
            (_scene.offeredTools.length == 1 ? _trayOneWidth : _trayMaxWidth) *
            s;
        final tray = _lab.isLabActive && _lab.popup == null
            ? _tray(p, s, math.min(trayRoom, trayWidth))
            : null;
        return LabShell(
          controller: _lab,
          icon: Icons.auto_awesome,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          actions: _actions(),
          onReset: () => _loadScenario(0),
          // The last task no longer applies once the summary is open.
          showHud: _scene.step <= data.steps.length,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, _stepCount)}'),
          sidebarExtraTitle: _t('findings'),
          sidebarExtra: _sidebarPanel(p, s, data),
          overlays: [
            if (tray != null)
              Positioned(
                key: const ValueKey('ch6a2-tray'),
                left: trayLeft,
                right: inset.right,
                bottom: inset.bottom + (open ? _hudBand * s : 0),
                child: Center(child: tray),
              ),
          ],
          stage: _buildStage(p),
        );
      },
    );
  }

  /// Sidebar width for a screen of [width] (the shell's rule: 30 % by
  /// default, 20 – 50 %, at least 180 px).
  double _sidebarWidth(double width) {
    final min = math.max(180.0, width * 0.2);
    final max = math.max(min, width * 0.5);
    return (width * _lab.sidebarFraction).clamp(min, max);
  }

  Widget _buildStage(LabPalette p) {
    return LayoutBuilder(
      builder: (context, box) {
        final canvas = box.biggest;
        final k = math.min(
          canvas.width / _design.width,
          canvas.height / _design.height,
        );
        final target = _framingFor(context, canvas);
        _scene.target = target;
        if (_snapFraming && canvas.width > 0) {
          _scene.framing = target;
          _snapFraming = false;
        }
        return DragTarget<_Tool>(
          onWillAcceptWithDetails: (d) => _canUse(d.data),
          onAcceptWithDetails: (d) => _useTool(d.data),
          builder: (context, candidates, rejected) => LabStage(
            designSize: _design,
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  texts: _texts,
                  pictures: _pictures,
                  repaint: _frame,
                  palette: p,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  pxPerDp: k > 0 && k.isFinite ? 1 / k : 1,
                  uiScale: context.labScale,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------ canvas cards

/// One tool or bin button of the control tray. Built without the shell's
/// style scope so it can also be the drag feedback.
class _TrayChip extends StatelessWidget {
  const _TrayChip({
    required this.label,
    required this.icon,
    required this.fill,
    required this.ink,
    required this.height,
    required this.scale,
    this.enabled = true,
    this.lifted = false,
  });

  final String label;
  final IconData icon;
  final Color fill;
  final Color ink;
  final double height;
  final double scale;
  final bool enabled;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final fg = enabled ? ink : ink.withValues(alpha: 0.55);
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 8 * s),
      decoration: BoxDecoration(
        color: enabled ? fill : fill.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: lifted ? _Colors.white : LabInk.clear,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: lifted ? LabInk.shadowStrong : LabInk.shadowSoft,
            blurRadius: lifted ? 16 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16 * s, color: fg),
          SizedBox(width: 5 * s),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- sidebar tables

/// One material of the observation table.
@immutable
class _ResultRow {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.swatch,
    required this.tested,
    this.bin,
    this.binColor,
    this.current = false,
  });

  final String label;
  final String value;
  final Color swatch;
  final bool tested;

  /// The bin it was sorted into, if any.
  final String? bin;
  final Color? binColor;

  /// The bins are asking about this material now.
  final bool current;
}

/// The observation table: material, test result and bin (sidebar and
/// conclusion popup).
class _ResultsTable extends StatelessWidget {
  const _ResultsTable({
    required this.palette,
    required this.scale,
    required this.headLeft,
    required this.headRight,
    required this.sortNow,
    required this.rows,
  });

  final LabPalette palette;
  final double scale;
  final String headLeft;
  final String headRight;
  final String sortNow;
  final List<_ResultRow> rows;

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

    Widget pill(String text, Color fill, Color ink) => Container(
      margin: EdgeInsets.only(top: 3 * f),
      padding: EdgeInsets.symmetric(horizontal: 6 * f, vertical: 1.5 * f),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ink,
          fontSize: 10 * f,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
      ),
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
            Expanded(flex: 4, child: left),
            SizedBox(width: 8 * f),
            Expanded(flex: 5, child: right),
          ],
        ),
      );
    }

    Widget material(_ResultRow r) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9 * f,
          height: 9 * f,
          margin: EdgeInsets.only(top: 3 * f, right: 5 * f),
          decoration: BoxDecoration(
            color: r.swatch,
            shape: BoxShape.circle,
            border: Border.all(color: p.cardBorder),
          ),
        ),
        Flexible(child: Text(r.label, style: style(p.text, FontWeight.w600))),
      ],
    );

    Widget result(_ResultRow r) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.value,
          style: r.tested
              ? style(p.textStrong, FontWeight.w700)
              : style(p.textMuted, FontWeight.w500, italic: true),
        ),
        if (r.bin != null)
          pill('✓ ${r.bin}', r.binColor ?? p.accent, _Colors.white)
        else if (r.current)
          pill(sortNow, p.accent, p.onAccent),
      ],
    );

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
              material(rows[i]),
              result(rows[i]),
              fill: rows[i].current ? p.accent.withValues(alpha: 0.12) : null,
              last: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

/// One observed result in the sidebar (HTML accordion "Observation").
class _ObservationLine extends StatelessWidget {
  const _ObservationLine({
    required this.number,
    required this.text,
    required this.palette,
    required this.scale,
  });

  final int number;
  final String text;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final f = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * f),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18 * f,
            height: 18 * f,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.info.withValues(alpha: 0.18),
              border: Border.all(color: p.info.withValues(alpha: 0.5)),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: p.info,
                fontSize: 9.5 * f,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 7 * f),
          Expanded(
            child: Text(
              text,
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
    );
  }
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

  /// Three.js `rotation.x = a` applied to this vector.
  _V rotX(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x, y * c - z * s, y * s + z * c);
  }

  /// Three.js `rotation.y = a` applied to this vector.
  _V rotY(double a) {
    final c = math.cos(a), s = math.sin(a);
    return _V(x * c + z * s, y, -x * s + z * c);
  }
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

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => focal / math.max(0.1, (w - eye).dot(f));

  Offset p(_V w) {
    final d = w - eye;
    final k = focal / math.max(0.1, d.dot(f));
    return Offset(center.dx + d.dot(r) * k, center.dy - d.dot(u) * k);
  }

  /// Whether a face with outward normal [n] through [at] faces the camera.
  bool faces(_V n, _V at) => n.dot(eye - at) > 0;
}

/// The lab's only camera (the HTML never moves it outside OrbitControls,
/// which start locked; the shell's zoom tools scale the canvas instead).
final _Proj _proj = _Proj(_eye, _lookAt);

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

/// HTML DodecahedronGeometry(1.8), turned a little so the stone looks
/// natural, resting on the table: its vertices, faces, height and front.
@immutable
class _StoneShape {
  const _StoneShape(
    this.vertices,
    this.faces,
    this.normals,
    this.centreY,
    this.top,
    this.front,
  );

  factory _StoneShape.build() {
    const phi = 1.6180339887;
    final raw = <_V>[
      for (final a in const [-1.0, 1.0])
        for (final b in const [-1.0, 1.0])
          for (final c in const [-1.0, 1.0]) _V(a, b, c),
      for (final a in const [-1.0, 1.0])
        for (final b in const [-1.0, 1.0]) ...[
          _V(0, a / phi, b * phi),
          _V(a / phi, b * phi, 0),
          _V(a * phi, 0, b / phi),
        ],
    ];
    // Face normals: the dual icosahedron's vertices.
    final dirs = <_V>[
      for (final a in const [-1.0, 1.0])
        for (final b in const [-1.0, 1.0]) ...[
          _V(0, a * phi, b),
          _V(a * phi, b, 0),
          _V(b, 0, a * phi),
        ],
    ];
    const tiltX = 0.35, turnY = 0.5;
    final k = _stoneRadius / math.sqrt(3);
    _V place(_V v) => (v * k).rotX(tiltX).rotY(turnY);
    final verts = [for (final v in raw) place(v)];
    final faces = <List<int>>[];
    final normals = <_V>[];
    for (final d in dirs) {
      final idx = List<int>.generate(raw.length, (i) => i)
        ..sort((a, b) => raw[b].dot(d).compareTo(raw[a].dot(d)));
      final face = idx.sublist(0, 5);
      final n = d.unit.rotX(tiltX).rotY(turnY);
      // Order the five corners around the normal.
      final c = face.fold(const _V(0, 0, 0), (s, i) => s + verts[i]) * 0.2;
      final ax = (verts[face.first] - c).unit;
      final ay = n.cross(ax);
      face.sort((a, b) {
        final va = verts[a] - c, vb = verts[b] - c;
        return math
            .atan2(va.dot(ay), va.dot(ax))
            .compareTo(math.atan2(vb.dot(ay), vb.dot(ax)));
      });
      faces.add(face);
      normals.add(n);
    }
    final minY = verts.map((v) => v.y).reduce(math.min);
    final maxY = verts.map((v) => v.y).reduce(math.max);
    final maxZ = verts.map((v) => v.z).reduce(math.max);
    return _StoneShape(verts, faces, normals, -minY, maxY - minY, maxZ * 0.8);
  }

  final List<_V> vertices;
  final List<List<int>> faces;
  final List<_V> normals;

  /// Centre height (resting on the table), top height and front face z.
  final double centreY;
  final double top;
  final double front;
}

final _StoneShape _stone = _StoneShape.build();

/// Where the nail is cut (sparkle and glint).
const _V _nailCutPoint = _V(_nailCutX, _nailY + 0.3, _nailZ);

// ================================================================== PAINTING

/// Key light direction (HTML DirectionalLight at (15, 30, 20)).
const _V _light = _V(0.3841, 0.7682, 0.5121);
const _V _up = _V(0, 1, 0);

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

/// Samples on a circle.
const int _rim = 18;

/// Scene label text (logical px at UI scale 1) and chip padding.
const double _labelPx = 10.5, _tagPx = 9, _labelPadX = 5, _labelPadY = 3;

/// Paints the HTML Three.js scene: the table and materials (recorded once
/// per change, see [_PictureCache]), the spotlight and its beam (S1), the
/// key and the scratch grooves (S2), the particle effects and the floating
/// labels, all under the current [_Framing].
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.texts,
    required this.pictures,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.pxPerDp,
    required this.uiScale,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache texts;
  final _PictureCache pictures;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;

  /// Stage design px per logical px, and the UI scale (label size).
  final double pxPerDp;
  final double uiScale;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _soft = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Paint _glow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
  final Path _path = Path();
  final List<Rect> _placed = [];

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    _fill
      ..shader = null
      ..color = palette.canvasBg;
    canvas.drawRect(labBleed(size), _fill);
    final f = s.framing;
    canvas.save();
    canvas.translate(f.to.dx, f.to.dy);
    canvas.scale(f.zoom);
    canvas.translate(-f.from.dx, -f.from.dy);
    canvas.drawPicture(pictures.get(s.pictureKey, _record));
    if (s.scenario == 0) {
      _spotlight(canvas);
      _blade(canvas);
    } else {
      _grooves(canvas);
      _key(canvas, s.keyPos);
    }
    _glows(canvas);
    _effects(canvas);
    canvas.restore();
    if (showLabels) _labels(canvas);
  }

  // ------------------------------------------------------- static picture

  /// The static part of the scene for [_Scene.pictureKey].
  void _record(Canvas c) {
    final s = scene;
    _box(
      c,
      const _V(0, -_tableHalfY, 0),
      const _V(_tableHalfX, _tableHalfY, _tableHalfZ),
      s.scenario == 0 ? _Colors.slate700 : _Colors.slate800,
    );
    final item = s.sortItem;
    if (item != null) _ring(c, item);
    if (s.scenario == 0) {
      _shadow(c, const _V(-3, 0, -4), 2.2, 0.5);
      _shadow(c, const _V(3, 0, -4), 1.6, 0.5);
      _nail(c);
      _cyl(c, _chalkA, _chalkB, _chalkR, _Colors.white);
      _shadow(c, _copperC, 1.3, 0.35);
      _copper(c);
      _shadow(c, _foilC, 1.6, 1.6);
      _foil(c);
      _shadow(c, _woodC, 1.4, 1.4);
      _box(c, _woodC, _woodHalf, _Colors.amber800);
      _grain(c, _woodC, _woodHalf);
      _shadow(c, _paperC, 1.6, 1.8);
      _box(c, _paperC, _paperHalf, _Colors.slate50);
    } else {
      _shadow(c, _candleBase, 1.0, 1.0);
      _cyl(
        c,
        _candleBase,
        _candleBase + const _V(0, _candleH, 0),
        _candleR,
        _Colors.yellow300,
        capB: _Colors.yellow100,
      );
      _stroke
        ..strokeWidth = 0.08 * _proj.scaleAt(const _V(-6, _candleH, 0))
        ..color = _Colors.slate900;
      c.drawLine(
        _proj.p(const _V(-6, _candleH, 0)),
        _proj.p(const _V(-6, _candleH + 0.35, 0)),
        _stroke,
      );
      _shadow(c, const _V(_stoneX, 0, 0), 1.9, 1.9);
      _stoneDraw(c);
      _shadow(c, _stickBase, 0.7, 0.7);
      _cyl(
        c,
        _stickBase,
        _stickBase + const _V(0, _stickH, 0),
        _stickR,
        _Colors.white,
      );
      _shadow(c, _blockC, 1.8, 1.8);
      _box(c, _blockC, _blockHalf, _Colors.amber900);
      _grain(c, _blockC, _blockHalf);
    }
  }

  /// Amber ring on the table around the material the bins ask about.
  void _ring(Canvas c, _Item item) {
    final centre = _itemCentre(item);
    final (rx, rz) = _ringRadii(item);
    _path.reset();
    for (var i = 0; i <= 32; i++) {
      final a = i / 32 * math.pi * 2;
      final o = _proj.p(
        _V(centre.x + math.cos(a) * rx, 0.02, centre.z + math.sin(a) * rz),
      );
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
    _fill
      ..shader = null
      ..color = _Colors.amber500.withValues(alpha: 0.18);
    c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 2.5
      ..color = _Colors.amber400;
    c.drawPath(_path, _stroke);
  }

  /// Soft shadow on the table under a material.
  void _shadow(Canvas c, _V at, double rx, double rz) {
    final l = _proj.p(_V(at.x - rx, 0.01, at.z));
    final r = _proj.p(_V(at.x + rx, 0.01, at.z));
    final b = _proj.p(_V(at.x, 0.01, at.z - rz));
    final f = _proj.p(_V(at.x, 0.01, at.z + rz));
    _soft.color = LabInk.black.withValues(alpha: 0.35);
    c.drawOval(Rect.fromLTRB(l.dx, b.dy, r.dx, f.dy), _soft);
  }

  /// Copper wire coil (HTML torus, metalness 0.9): a thick copper ring with
  /// a bright highlight along its upper left.
  void _copper(Canvas c) {
    final width = 2 * _copperTube * _proj.scaleAt(_copperC);
    _ringPath(_copperC, _copperR, 0, math.pi * 2);
    _stroke
      ..strokeWidth = width + 1.6
      ..color = labShade(_Colors.amber600, -0.5);
    c.drawPath(_path, _stroke);
    _stroke
      ..strokeWidth = width
      ..color = _Colors.amber600;
    c.drawPath(_path, _stroke);
    _ringPath(_copperC, _copperR, math.pi * 0.5, math.pi * 1.05);
    _stroke
      ..strokeWidth = width * 0.38
      ..color = _Colors.yellow200;
    c.drawPath(_path, _stroke);
    _ringPath(_copperC, _copperR, math.pi * 1.6, math.pi * 1.8);
    _stroke
      ..strokeWidth = width * 0.25
      ..color = _Colors.yellow200.withValues(alpha: 0.7);
    c.drawPath(_path, _stroke);
  }

  /// Arc of a circle of radius [r] in the vertical plane through [centre],
  /// from angle [a0] to [a1], into [_path].
  void _ringPath(_V centre, double r, double a0, double a1) {
    _path.reset();
    const n = 36;
    for (var i = 0; i <= n; i++) {
      final a = a0 + (a1 - a0) * i / n;
      final o = _proj.p(
        _V(centre.x + math.cos(a) * r, centre.y + math.sin(a) * r, centre.z),
      );
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
  }

  /// Aluminium foil (metalness 0.95): a thin sheet with a metallic sheen.
  void _foil(Canvas c) {
    _box(c, _foilC, _foilHalf, _Colors.slate200);
    final y = _foilC.y + _foilHalf.y;
    final a = _proj.p(_V(_foilC.x - _foilHalf.x, y, _foilC.z - _foilHalf.z));
    final b = _proj.p(_V(_foilC.x + _foilHalf.x, y, _foilC.z - _foilHalf.z));
    final d = _proj.p(_V(_foilC.x + _foilHalf.x, y, _foilC.z + _foilHalf.z));
    final e = _proj.p(_V(_foilC.x - _foilHalf.x, y, _foilC.z + _foilHalf.z));
    _path
      ..reset()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(d.dx, d.dy)
      ..lineTo(e.dx, e.dy)
      ..close();
    _fill
      ..color = _Colors.white
      ..shader = ui.Gradient.linear(
        a,
        d,
        const [
          _Colors.slate300,
          _Colors.white,
          _Colors.slate300,
          _Colors.white,
          _Colors.slate400,
        ],
        const [0, 0.3, 0.5, 0.72, 1],
      );
    c.drawPath(_path, _fill);
    _fill.shader = null;
    // A few crinkles.
    _stroke
      ..strokeWidth = 0.8
      ..color = _Colors.slate400.withValues(alpha: 0.6);
    for (final t in const [0.3, 0.62]) {
      c.drawLine(Offset.lerp(a, b, t)!, Offset.lerp(e, d, t + 0.08)!, _stroke);
    }
  }

  /// Wood grain on a block's top and front faces.
  void _grain(Canvas c, _V centre, _V half) {
    _stroke
      ..strokeWidth = 0.8
      ..color = labShade(_Colors.amber900, -0.45).withValues(alpha: 0.6);
    final top = centre.y + half.y;
    for (final t in const [-0.5, 0.0, 0.45]) {
      final z = centre.z + t * half.z;
      c.drawLine(
        _proj.p(_V(centre.x - half.x * 0.9, top, z)),
        _proj.p(_V(centre.x + half.x * 0.9, top, z + 0.1)),
        _stroke,
      );
    }
    for (final t in const [-0.4, 0.3]) {
      final y = centre.y + t * half.y;
      c.drawLine(
        _proj.p(_V(centre.x - half.x * 0.9, y, centre.z + half.z)),
        _proj.p(_V(centre.x + half.x * 0.9, y + 0.05, centre.z + half.z)),
        _stroke,
      );
    }
  }

  /// The iron nail: dull grey (tarnished) outside. Once cut, the halves
  /// swing open about the cut and both fresh cut faces shine silver.
  void _nail(Canvas c) {
    final s = scene;
    const dull = _Colors.slate600;
    const pivot = _V(_nailCutX, _nailY, _nailZ);
    _V at(double x) => _V(x, _nailY, _nailZ);
    if (s.cutStart == null || !s.nailCut && s.nailOpen == 0) {
      _cyl(c, at(_nailHeadX0), at(_nailHeadX1), _nailHeadR, dull);
      _cyl(c, at(_nailHeadX1), at(_nailTipX), _nailR, dull);
      _cone(c, at(_nailTipX), at(_nailPointX), _nailR, dull);
      return;
    }
    final open = s.nailOpen;
    final turn = _nailOpenAngle * open;
    final gap = _nailOpenGap * open;
    _V left(_V v) => pivot + (v - pivot).rotY(-turn) + _V(-gap, 0, 0);
    _V right(_V v) => pivot + (v - pivot).rotY(turn) + _V(gap, 0, 0);
    // Left half: head, then the shaft with its fresh cut end.
    _cyl(c, left(at(_nailHeadX0)), left(at(_nailHeadX1)), _nailHeadR, dull);
    _cyl(
      c,
      left(at(_nailHeadX1)),
      left(pivot),
      _nailR,
      dull,
      capB: _Colors.slate100,
    );
    // Right half: point, then the shaft with its fresh cut end.
    _cone(c, right(at(_nailTipX)), right(at(_nailPointX)), _nailR, dull);
    _cyl(
      c,
      right(pivot),
      right(at(_nailTipX)),
      _nailR,
      dull,
      capA: _Colors.slate100,
    );
    if (open > 0.5) {
      for (final p in [left(pivot), right(pivot)]) {
        _star(c, _proj.p(p), 0.42 * _proj.scaleAt(p), _Colors.white, 0.3);
      }
    }
  }

  /// HTML DodecahedronGeometry stone (roughness 0.9): its faces turned to
  /// the camera, each lit by the key light.
  void _stoneDraw(Canvas c) {
    final centre = _V(_stoneX, _stone.centreY, 0);
    for (var f = 0; f < _stone.faces.length; f++) {
      final n = _stone.normals[f];
      final face = _stone.faces[f];
      final mid = face.fold(
        const _V(0, 0, 0),
        (s, i) => s + _stone.vertices[i],
      );
      if (!_proj.faces(n, centre + mid * 0.2)) continue;
      _path.reset();
      for (var i = 0; i < face.length; i++) {
        final o = _proj.p(centre + _stone.vertices[face[i]]);
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _path.close();
      _fill
        ..shader = null
        ..color = _lit(_Colors.slate500, n);
      c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.9
        ..color = labShade(_Colors.slate500, -0.5).withValues(alpha: 0.5);
      c.drawPath(_path, _stroke);
    }
  }

  // ---------------------------------------------------------- live parts

  /// HTML spotlight cone (emissive 0xfacc15; the HTML TWEENs move it in x
  /// and z only) and, while it sweeps, its
  /// beam and light pool.
  void _spotlight(Canvas c) {
    final s = scene;
    final (x, z) = s.lampXZ;
    final apex = _V(x, _lampRest.y - _lampHalfH, z);
    if (s.beamOn) {
      final pool = _flatOval(_V(x, 0.02, z), _beamR);
      _soft.color = _Colors.yellow400.withValues(alpha: 0.32);
      c.drawOval(pool, _soft);
      final a = _proj.p(apex);
      _path
        ..reset()
        ..moveTo(a.dx, a.dy)
        ..lineTo(pool.left, pool.center.dy)
        ..arcTo(pool, math.pi, -math.pi, false)
        ..close();
      _fill
        ..shader = null
        ..color = _Colors.yellow300.withValues(alpha: 0.14);
      c.drawPath(_path, _fill);
      _glow.color = _Colors.yellow300.withValues(alpha: 0.5);
      c.drawCircle(a, 0.9 * _proj.scaleAt(apex), _glow);
    }
    // The cone: its sides down to the apex, then its wide top.
    final top = _flatOval(_V(x, _lampRest.y + _lampHalfH, z), _lampR);
    final a = _proj.p(apex);
    _path
      ..reset()
      ..moveTo(a.dx, a.dy)
      ..lineTo(top.left, top.center.dy)
      ..arcTo(top, math.pi, -math.pi, false)
      ..close();
    _fill
      ..shader = null
      ..color = _Colors.yellow400;
    c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = labShade(_Colors.yellow400, -0.45);
    c.drawPath(_path, _stroke);
    _fill.color = _Colors.yellow200;
    c.drawOval(top, _fill);
    c.drawOval(top, _stroke);
  }

  /// Screen rect of a horizontal circle (radius [r]) centred at [at].
  Rect _flatOval(_V at, double r) {
    final l = _proj.p(_V(at.x - r, at.y, at.z));
    final rt = _proj.p(_V(at.x + r, at.y, at.z));
    final b = _proj.p(_V(at.x, at.y, at.z - r));
    final f = _proj.p(_V(at.x, at.y, at.z + r));
    return Rect.fromLTRB(l.dx, b.dy, rt.dx, f.dy);
  }

  /// The blade that cuts the nail (S1 step 4).
  void _blade(Canvas c) {
    final (h, alpha) = scene.blade;
    if (alpha <= 0) return;
    const x = _nailCutX, z = _nailZ + 0.6;
    final y0 = _nailY + h - 0.1;
    final pts = [
      _proj.p(_V(x - 0.55, y0 + 1.4, z)),
      _proj.p(_V(x + 0.55, y0 + 1.4, z)),
      _proj.p(_V(x + 0.55, y0 + 0.3, z)),
      _proj.p(_V(x - 0.55, y0, z)),
    ];
    _path
      ..reset()
      ..addPolygon(pts, true);
    _fill
      ..shader = null
      ..color = _Colors.slate300.withValues(alpha: alpha);
    c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 1.2
      ..color = _Colors.slate600.withValues(alpha: alpha);
    c.drawPath(_path, _stroke);
    _stroke.color = _Colors.white.withValues(alpha: alpha);
    c.drawLine(pts[3], pts[2], _stroke);
    // Handle.
    final hl = _proj.p(_V(x - 0.35, y0 + 1.4, z));
    final hr = _proj.p(_V(x + 0.35, y0 + 1.75, z));
    _fill.color = _Colors.slate800.withValues(alpha: alpha);
    c.drawRect(Rect.fromPoints(hl, hr), _fill);
  }

  /// Scratch grooves on the candle and the chalk (the HTML only shrank the
  /// candle; its text promises "deep scratch groove").
  void _grooves(Canvas c) {
    final s = scene;
    for (final item in s.grooves.keys) {
      final g = s.grooveAt(item);
      if (g <= 0) continue;
      final p = _scratchPoint(item);
      final a = _proj.p(_V(p.x - _strokeLen / 2, p.y, p.z));
      final b = _proj.p(_V(p.x - _strokeLen / 2 + _strokeLen * g, p.y, p.z));
      final k = _proj.scaleAt(p);
      _stroke
        ..strokeWidth = 0.11 * k
        ..color = labShade(item.color, -0.55);
      c.drawLine(a, b, _stroke);
      _stroke
        ..strokeWidth = 0.04 * k
        ..color = _Colors.white.withValues(alpha: 0.8);
      final dy = Offset(0, 0.07 * k);
      c.drawLine(a + dy, b + dy, _stroke);
    }
  }

  /// HTML metal key (0xf59e0b, metalness 0.9), drawn with its tip on the
  /// left so it touches the material it scratches: shaft, tooth and ring.
  void _key(Canvas c, _V k) {
    final scale = _proj.scaleAt(k);
    final tip = _proj.p(_V(k.x - 1, k.y, k.z));
    final end = _proj.p(_V(k.x + 0.55, k.y, k.z));
    final w = 0.3 * scale;
    _stroke
      ..strokeWidth = w + 1.4
      ..color = labShade(_Colors.amber500, -0.5);
    c.drawLine(tip, end, _stroke);
    _stroke
      ..strokeWidth = w
      ..color = _Colors.amber500;
    c.drawLine(tip, end, _stroke);
    _stroke
      ..strokeWidth = w * 0.3
      ..color = _Colors.yellow200;
    c.drawLine(tip - Offset(0, w * 0.22), end - Offset(0, w * 0.22), _stroke);
    // Tooth below the shaft near the tip.
    final t0 = _proj.p(_V(k.x - 0.85, k.y, k.z));
    final t1 = _proj.p(_V(k.x - 0.55, k.y - 0.4, k.z));
    _fill
      ..shader = null
      ..color = _Colors.amber600;
    c.drawRect(Rect.fromPoints(t0, t1), _fill);
    // Ring.
    final ring = _proj.p(_V(k.x + 1, k.y, k.z));
    final r = 0.5 * scale;
    _stroke
      ..strokeWidth = w + 1.4
      ..color = labShade(_Colors.amber500, -0.5);
    c.drawCircle(ring, r, _stroke);
    _stroke
      ..strokeWidth = w
      ..color = _Colors.amber500;
    c.drawCircle(ring, r, _stroke);
    _stroke
      ..strokeWidth = w * 0.3
      ..color = _Colors.yellow200;
    c.drawArc(
      Rect.fromCircle(center: ring, radius: r),
      math.pi * 1.05,
      math.pi * 0.55,
      false,
      _stroke,
    );
  }

  /// Short glows (HTML emissive pulses), fading out.
  void _glows(Canvas c) {
    final s = scene;
    for (final MapEntry(key: item, value: g) in s.glows.entries) {
      final k = 1 - ((s.time - g.start) / g.duration).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final at = item == _Item.nail ? _nailCutPoint : _itemCentre(item);
      final r =
          (item == _Item.copper ? 1.7 : (item == _Item.foil ? 1.8 : 1.2)) *
          _proj.scaleAt(at);
      _glow.color = g.color.withValues(alpha: g.peak * k);
      c.drawCircle(_proj.p(at), r, _glow);
    }
  }

  /// Particle bursts: sparkles (S1), sparks and dust (S2).
  void _effects(Canvas c) {
    final s = scene;
    for (final fx in s.effects) {
      final t = s.time - fx.start;
      for (var i = 0; i < fx.from.length; i++) {
        switch (fx.kind) {
          case _FxKind.sparkle:
            final k = _quadOut((t / fx.time[i]).clamp(0.0, 1.0));
            final life = (t / 1.2).clamp(0.0, 1.0);
            if (life >= 1) continue;
            final w = fx.at + _lerpV(fx.from[i], fx.to[i], k);
            final size = 0.25 * (1 - 0.95 * life) * _proj.scaleAt(w);
            const tints = [_Colors.yellow400, _Colors.white, _Colors.yellow300];
            _star(
              c,
              _proj.p(w),
              size * 1.6,
              tints[i % 3].withValues(alpha: 1 - life),
              fx.spin[i] * life,
            );
          case _FxKind.sparks:
            final k = _quadOut((t / fx.time[i]).clamp(0.0, 1.0));
            final life = (t / 0.8).clamp(0.0, 1.0);
            if (life >= 1) continue;
            final w = fx.at + _lerpV(fx.from[i], fx.to[i], k);
            const tints = [_Colors.orange500, _Colors.zslYellow, _Colors.white];
            _fill
              ..shader = null
              ..color = tints[i % 3];
            c.drawCircle(
              _proj.p(w),
              0.12 * (1 - 0.85 * life) * _proj.scaleAt(w),
              _fill,
            );
          case _FxKind.dust:
            final k = _quadIn((t / fx.time[i]).clamp(0.0, 1.0));
            final life = (t / 1.0).clamp(0.0, 1.0);
            if (life >= 1) continue;
            var w = fx.at + _lerpV(fx.from[i], fx.to[i], k);
            if (w.y < 0.04) w = _V(w.x, 0.04, w.z);
            final half = 0.075 * _proj.scaleAt(w);
            _fill
              ..shader = null
              ..color = fx.tint.withValues(alpha: 0.9 * (1 - life));
            c.save();
            final o = _proj.p(w);
            c.translate(o.dx, o.dy);
            c.rotate(fx.spin[i] * k);
            c.drawRect(Rect.fromLTRB(-half, -half, half, half), _fill);
            c.restore();
        }
      }
    }
  }

  /// A four-point sparkle star.
  void _star(Canvas c, Offset o, double r, Color color, double turn) {
    _path.reset();
    for (var i = 0; i < 8; i++) {
      final a = turn + i * math.pi / 4;
      final d = i.isEven ? r : r * 0.32;
      final p = o + Offset(math.cos(a) * d, math.sin(a) * d);
      if (i == 0) {
        _path.moveTo(p.dx, p.dy);
      } else {
        _path.lineTo(p.dx, p.dy);
      }
    }
    _path.close();
    _fill
      ..shader = null
      ..color = color;
    c.drawPath(_path, _fill);
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (HTML ambient
  /// 0.75 + directional 0.95, toned down to keep the colours).
  Color _lit(Color c, _V n) {
    final i = 0.62 + 0.5 * math.max(0.0, n.dot(_light));
    return Color.from(
      alpha: c.a,
      red: (c.r * i).clamp(0.0, 1.0),
      green: (c.g * i).clamp(0.0, 1.0),
      blue: (c.b * i).clamp(0.0, 1.0),
    );
  }

  /// Axis-aligned box centred at [centre] with half sizes [half]; faces
  /// turned away from the camera are skipped.
  void _box(Canvas c, _V centre, _V half, Color color) {
    _V corner(_V s) => centre + _V(s.x * half.x, s.y * half.y, s.z * half.z);
    for (final (n, bl, br, tl) in _boxFaces) {
      if (!_proj.faces(n, corner(n))) continue;
      final pBL = _proj.p(corner(bl)), pBR = _proj.p(corner(br));
      final pTL = _proj.p(corner(tl)), pTR = _proj.p(corner(br + tl - bl));
      _path
        ..reset()
        ..moveTo(pBL.dx, pBL.dy)
        ..lineTo(pBR.dx, pBR.dy)
        ..lineTo(pTR.dx, pTR.dy)
        ..lineTo(pTL.dx, pTL.dy)
        ..close();
      _fill
        ..shader = null
        ..color = _lit(color, n);
      c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.5).withValues(alpha: 0.35);
      c.drawPath(_path, _stroke);
    }
  }

  /// Unit vectors across the axis [ax].
  (_V, _V) _across(_V ax) {
    final helper = ax.y.abs() < 0.9 ? _up : const _V(1, 0, 0);
    final u = ax.cross(helper).unit;
    return (u, ax.cross(u));
  }

  /// Cylinder from [a] to [b] (radius [r]): its side with a shaded
  /// gradient across, then whichever end caps face the camera ([capA] /
  /// [capB] colour them, e.g. a fresh cut face).
  void _cyl(
    Canvas c,
    _V a,
    _V b,
    double r,
    Color color, {
    Color? capA,
    Color? capB,
  }) {
    final ax = (b - a).unit;
    final (u, v) = _across(ax);
    final rimA = <_V>[], rimB = <_V>[];
    for (var i = 0; i < _rim; i++) {
      final t = i / _rim * math.pi * 2;
      final o = u * (math.cos(t) * r) + v * (math.sin(t) * r);
      rimA.add(a + o);
      rimB.add(b + o);
    }
    final hull = _hull([
      for (final w in [...rimA, ...rimB]) _proj.p(w),
    ]);
    if (hull.length >= 3) {
      final pa = _proj.p(a), pb = _proj.p(b);
      final mid = Offset.lerp(pa, pb, 0.5)!;
      var dir = pb - pa;
      if (dir.distance < 0.001) dir = const Offset(1, 0);
      dir = dir / dir.distance;
      final across = Offset(-dir.dy, dir.dx);
      final half = r * _proj.scaleAt(_lerpV(a, b, 0.5)) * 1.05;
      // A shader keeps the paint colour's alpha: make it opaque first.
      _fill
        ..color = _Colors.white
        ..shader = ui.Gradient.linear(
          mid - across * half,
          mid + across * half,
          [
            labShade(color, -0.4),
            labShade(color, 0.25),
            color,
            labShade(color, -0.45),
          ],
          const [0, 0.35, 0.62, 1],
        );
      _path
        ..reset()
        ..addPolygon(hull, true);
      c.drawPath(_path, _fill);
      _fill.shader = null;
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.55).withValues(alpha: 0.4);
      c.drawPath(_path, _stroke);
    }
    for (final (rim, at, n, tone) in [
      (rimA, a, ax * -1, capA),
      (rimB, b, ax, capB),
    ]) {
      if (!_proj.faces(n, at)) continue;
      _path
        ..reset()
        ..addPolygon([for (final w in rim) _proj.p(w)], true);
      _fill
        ..shader = null
        ..color = tone ?? _lit(labShade(color, 0.1), n);
      c.drawPath(_path, _fill);
      _stroke
        ..strokeWidth = 0.8
        ..color = labShade(color, -0.5).withValues(alpha: 0.5);
      c.drawPath(_path, _stroke);
    }
  }

  /// Cone from a base circle at [base] (radius [r]) to [apex].
  void _cone(Canvas c, _V base, _V apex, double r, Color color) {
    final (u, v) = _across((apex - base).unit);
    final hull = _hull([
      _proj.p(apex),
      for (var i = 0; i < _rim; i++)
        _proj.p(
          base +
              u * (math.cos(i / _rim * math.pi * 2) * r) +
              v * (math.sin(i / _rim * math.pi * 2) * r),
        ),
    ]);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..addPolygon(hull, true);
    _fill
      ..shader = null
      ..color = _lit(color, _up);
    c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 0.8
      ..color = labShade(color, -0.5).withValues(alpha: 0.45);
    c.drawPath(_path, _stroke);
  }

  // ---------------------------------------------------------------- labels

  /// HTML sprite labels (dark chip, ZSL-yellow border, white bold text),
  /// kept readable at every screen size: each wraps to the room between
  /// its neighbours and moves out of the way of a label it would overlap.
  /// A sorted material's label shows its bin; the material the bins ask
  /// about has a pulsing amber border.
  void _labels(Canvas c) {
    final s = scene;
    final f = s.framing;
    _placed.clear();
    final rows = s.scenario == 0
        ? [_labelRows[0], _labelRows[1]]
        : [_labelRows[2]];
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        final at = f.map(_labelPoints[row[i]]!);
        var room = double.infinity;
        if (i > 0) {
          room = math.min(
            room,
            (at - f.map(_labelPoints[row[i - 1]]!)).distance,
          );
        }
        if (i < row.length - 1) {
          room = math.min(
            room,
            (f.map(_labelPoints[row[i + 1]]!) - at).distance,
          );
        }
        _label(c, row[i], at, room);
      }
    }
  }

  void _label(Canvas c, _Item item, Offset at, double room) {
    final s = scene;
    final dp = pxPerDp * uiScale;
    final padX = _labelPadX * dp, padY = _labelPadY * dp;
    final maxW = (room.isFinite ? room * 0.94 - 2 * padX : 1e4).clamp(
      40 * dp,
      130 * dp,
    );
    final name = texts.get(
      labTr(_i18n, lang, item.labelKey),
      size: _labelPx * dp,
      color: palette.labelText,
      weight: FontWeight.w800,
      maxWidth: maxW,
    );
    final bin = s.sorted[item];
    final tag = bin == null
        ? null
        : texts.get(
            '✓ ${labTr(_i18n, lang, bin.tagKey)}',
            size: _tagPx * dp,
            color: bin.tagColor,
            weight: FontWeight.w800,
            maxWidth: maxW,
          );
    final w = math.max(name.width, tag?.width ?? 0) + 2 * padX;
    final h = name.height + (tag == null ? 0 : tag.height + dp) + 2 * padY;
    final below = _labelSpot(item).$2;
    final gap = 3 * dp;
    var rect = Rect.fromLTWH(
      at.dx - w / 2,
      below ? at.dy + gap : at.dy - gap - h,
      w,
      h,
    );
    for (var pass = 0; pass < 8; pass++) {
      Rect? hit;
      for (final r in _placed) {
        if (r.overlaps(rect.inflate(dp))) {
          hit = r;
          break;
        }
      }
      if (hit == null) break;
      rect = rect.shift(
        Offset(
          0,
          below
              ? hit.bottom - rect.top + 2 * dp
              : hit.top - rect.bottom - 2 * dp,
        ),
      );
    }
    _placed.add(rect);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(8 * dp));
    _fill
      ..shader = null
      ..color = palette.labelBg;
    c.drawRRect(rr, _fill);
    final current = item == s.sortItem;
    final pulse = 0.55 + 0.45 * math.sin(s.time * 5).abs();
    _stroke
      ..strokeWidth = (current ? 2.2 : 1) * dp
      ..color = current
          ? _Colors.amber400.withValues(alpha: pulse)
          : _Colors.zslYellow.withValues(alpha: 0.75);
    c.drawRRect(rr, _stroke);
    name.paint(
      c,
      Offset(rect.left + (rect.width - name.width) / 2, rect.top + padY),
    );
    tag?.paint(
      c,
      Offset(
        rect.left + (rect.width - tag.width) / 2,
        rect.top + padY + name.height + dp,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.pxPerDp != pxPerDp ||
      old.uiScale != uiScale;
}

/// The recorded static scene, re-recorded only when its key changes (a
/// scenario, the material to sort, the nail being cut). Owned (and
/// disposed) by the page State.
class _PictureCache {
  ui.Picture? _picture;
  Object? _key;

  ui.Picture get(Object key, void Function(Canvas canvas) record) {
    final cached = _picture;
    if (cached != null && key == _key) return cached;
    final recorder = ui.PictureRecorder();
    record(Canvas(recorder));
    cached?.dispose();
    _key = key;
    return _picture = recorder.endRecording();
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
    _key = null;
  }
}

/// TextPainters for the canvas text, laid out once and reused every frame.
/// Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  /// Most painters kept (sizes change while the screen is resized).
  static const int _limit = 240;

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
    required double maxWidth,
  }) {
    // Rounded so a sliding sidebar does not lay out a new painter per frame.
    final px = (size * 4).round() / 4;
    final wrap = (maxWidth / 4).round() * 4.0;
    final key = '$text|$px|$wrap|${color.toARGB32()}|${weight.value}';
    final cached = _painters[key];
    if (cached != null) return cached;
    if (_painters.length >= _limit) dispose();
    return _painters[key] = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: px,
          fontWeight: weight,
          height: 1.2,
          fontFamily: LabFont.active.family,
          fontFamilyFallback: LabFont.active.fallback,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    )..layout(maxWidth: wrap);
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
