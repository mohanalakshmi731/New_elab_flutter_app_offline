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

/// Class 6 Science • Chapter 6 • Activity 6
/// Defining Matter and Its Applications.
///
/// Native Flutter port of
/// `Cl6S-Ch6-A6-Defining_Matter_and_Its_Applications.html`.
///
/// Scenario 1 (The Case of the Occupied Chair): the school bag is weighed on
/// a digital scale (it has mass), put on a chair (it takes up the seat) and
/// the student cannot sit until the bag is moved to the floor (two objects
/// cannot be in the same space).
///
/// Scenario 2 (The Tumbler Challenge): a tumbler is made from cloth in the
/// Fabricator and leaks when water is poured in; a glass tumbler holds the
/// water. Materials are chosen for their properties.
///
/// The Three.js room and workbench are redrawn by a CustomPainter through a
/// perspective projection of the same camera (fov 45°, position (0, 12, 22),
/// looking at the origin).
class Ch6A6DefiningMatterAndItsApplicationsPage extends StatefulWidget {
  const Ch6A6DefiningMatterAndItsApplicationsPage({super.key});

  @override
  State<Ch6A6DefiningMatterAndItsApplicationsPage> createState() =>
      _MatterLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three Web Audio tones: `pop`
/// (clicks, the sidebar, scenario change, Enter Lab, every object snapping
/// into place, the student starting to walk, the pitcher tilting),
/// `success` (the scale reading, the student sitting, the glass holding
/// water, the summary) and `error` (the student unable to sit, the cloth
/// leaking), mapped to error.mp3. correct.mp3 is the shell's feedback tone.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`,
/// success → `math/success.mp3`.
enum _Sound implements LabTone {
  /// HTML `pop`.
  pop('audio/class6/science/pop.mp3'),

  /// "Scenario Complete" toast after Continue.
  correct('audio/class6/science/correct.mp3'),

  /// HTML `error`; also an object dropped in the wrong place.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `success`.
  success('audio/class6/math/success.mp3');

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
  static const Color white = Color(0xFFFFFFFF);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red600 = Color(0xFFDC2626);

  /// Summary popup body `bg-[#121629]`.
  static const Color popup = Color(0xFF121629);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x020617 (dark), 0xf1f5f9 (light, `setTheme`).
  static const Color sceneDark = slate950;
  static const Color sceneLight = slate100;

  /// Scenario 1 floor `BoxGeometry(30, 1, 15)` 0x94a3b8; Scenario 2
  /// workbench 0x334155.
  static const Color floor = slate400;
  static const Color bench = slate700;

  /// Weighing scale: base 0x334155, pan 0xcbd5e1, LCD window (added).
  static const Color scaleBase = slate700;
  static const Color scalePan = slate300;
  static const Color lcd = Color(0xFF0B1220);

  /// Scale readout sprite: rgba(59,130,246,0.9) empty, rgba(16,185,129,0.9)
  /// with the bag on it.
  static const Color readoutEmpty = Color(0xE63B82F6);
  static const Color readoutLoaded = Color(0xE610B981);

  /// Chair: wood 0xd4a373, legs 0x94a3b8.
  static const Color wood = Color(0xFFD4A373);
  static const Color chairLeg = slate400;

  /// School bag 0x3b82f6 with a 0xe2e8f0 pocket.
  static const Color bag = blue500;
  static const Color bagPocket = slate200;

  /// Student: head 0xfcb096, shirt 0xf8fafc, trousers 0x1e3a8a, face
  /// features #0f172a.
  static const Color skin = Color(0xFFFCB096);
  static const Color shirt = Color(0xFFF8FAFC);
  static const Color trousers = Color(0xFF1E3A8A);
  static const Color faceInk = slate900;

  /// Highlight ring `RingGeometry(1.5, 2.2)` 0xeab308, opacity 0.8.
  static const Color ring = Color(0xCCEAB308);

  /// Fabricator: base 0x0f172a, glowing target ring 0x3b82f6, glass casing
  /// (white, transmission 0.9), top ring 0x94a3b8.
  static const Color moldBase = slate900;
  static const Color moldTarget = blue500;
  static const Color glass = white;
  static const Color moldTop = slate400;

  /// Cloth stack layers 0xf43f5e, 0xe11d48, 0xbe123c; the cloth tumbler is
  /// 0xf43f5e.
  static const Color cloth1 = Color(0xFFF43F5E);
  static const Color cloth2 = Color(0xFFE11D48);
  static const Color cloth3 = Color(0xFFBE123C);

  /// Glass block 0xe0f2fe (transmission 0.95).
  static const Color glassBlock = Color(0xFFE0F2FE);

  /// Water 0x3b82f6 (transmission 0.8); pitcher handle 0x94a3b8.
  static const Color water = blue500;
  static const Color handle = slate400;

  /// Soft contact shadows (the HTML scene casts shadow maps).
  static const Color shadow = Color(0x59000000);

  /// `createTextSprite` label: rgba(15, 23, 42, 0.8), white bold text.
  static const Color labelBg = Color(0xCC0F172A);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xF20F172A), // teacher board dark:bg-slate-900
    border: Color(0x26FFFFFF), // --glass-border white/15
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.amber500, // text-amber-500 headings, border-amber-500
    onAccent: _Colors.slate950,
    primary: _Colors.blue500, // summary button bg-[#3b82f6]
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red600, // error toast bg-red-600/90
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.popup,
    popupHeader: _Colors.slate900,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // #toast bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900, // #shutter-screen bg-slate-900
    curtainGlow: Color(0x66312E81), // from-indigo-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCFCD34D), // subtitle text-amber-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A), // sidebar toggle bg-slate-900
    buttonIcon: _Colors.amber500, // text-amber-500
    buttonBorder: _Colors.slate700, // border-slate-700
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBg,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: Color(0xF2FFFFFF), // teacher board bg-white
    border: Color(0x26000000), // --glass-border black/15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.amber500,
    onAccent: _Colors.slate950,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: _Colors.amber300,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.amber500,
    buttonBorder: _Colors.slate700,
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
/// are the HTML sidebar text size setting: 15 px, slider 12–22 px.
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The HTML
/// plays its `pop` tone for clicks, the sidebar, scenario changes and the
/// curtain.
const _style = LabStyle(
  click: _Sound.pop,
  toggle: _Sound.pop,
  correct: _Sound.correct,
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). The
// HTML's toasts, canvas labels and summaries were English only; their Hindi
// is added. Steps say exactly what to do on a touch screen ("tap" instead
// of "click", how to pour); keys marked "added" are new texts.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Defining Matter and Its Applications',
    'app_subtitle': 'Class 6 • Materials Around Us',
    'scen_1_opt': 'Scenario 1: The Case of the Occupied Chair',
    'scen_2_opt': 'Scenario 2: The Tumbler Challenge',
    's1_desc':
        'To visually and interactively understand the two defining properties of matter: having mass and occupying space (volume).',
    's2_desc':
        'To understand that materials are chosen to make objects based on their properties, applying the concept of matter to a real-world problem.',
    // Scenario 1 steps: concept (c), action (a), observation (o).
    's1_c1': 'Matter has mass.',
    's1_a1': 'Drag the school bag onto the digital weighing scale.',
    's1_o1':
        "The scale's platform depresses, and the digital display changes from '0.00 kg' to '3.50 kg'.",
    's1_c2': 'Matter occupies space.',
    's1_a2': 'Drag the school bag onto the chair.',
    's1_o2': 'The school bag sits on the chair, occupying the seat space.',
    // The HTML stated the result ("Two objects cannot occupy the same
    // space.") before the learner tried; asked as a question here.
    's1_c3': 'Can two objects occupy the same space at the same time?',
    's1_a3': 'Tap the student to make him try to sit on the chair.',
    's1_o3':
        'The student tries to sit but cannot, because the bag is in the way.',
    's1_c4': 'Space must be cleared.',
    's1_a4':
        'Drag the school bag from the chair down to the floor, then tap the student to make him sit.',
    's1_o4': 'The student successfully sits on the empty chair.',
    // Scenario 2 steps.
    's2_c1': 'Creating objects from materials.',
    's2_a1': 'Drag the stack of cloth to the Fabricator.',
    's2_o1': 'A tumbler made of cloth appears on the workbench.',
    's2_c2': 'Testing material properties.',
    's2_a2':
        'Drag the water pitcher to the Fabricator to pour water into the cloth tumbler.',
    's2_o2':
        'Water leaks through the porous cloth, the tumbler slumps over. Failed.',
    's2_c3': 'Selecting a different material.',
    's2_a3': 'Drag the block of glass to the Fabricator.',
    's2_o3': 'A shiny, transparent glass tumbler is created.',
    's2_c4': 'Retesting the object.',
    's2_a4':
        'Drag the water pitcher to the Fabricator to pour water into the glass tumbler.',
    's2_o4': 'The glass holds the water perfectly. Success!',
    // HTML `hud-instruction` lines ("click the avatar" → "tap the student").
    's1_hud_1': 'Drag the school bag onto the digital weighing scale.',
    's1_hud_2': 'Drag the school bag onto the chair.',
    's1_hud_3': 'Tap the student to make him try to sit.',
    's1_hud_4': 'Move the bag to the floor, then tap the student again.',
    's2_hud_1': "Drag the 'Cloth' stack to the Fabricator to mold a tumbler.",
    's2_hud_2': 'Drag the water pitcher to pour liquid into the cloth tumbler.',
    's2_hud_3': "Drag the 'Glass' crystal to the Fabricator.",
    's2_hud_4': 'Drag the water pitcher to pour liquid into the glass tumbler.',
    // Canvas labels (HTML `createTextSprite`).
    'lbl_bag': 'BAG',
    'lbl_student': 'STUDENT',
    'lbl_fabricator': 'FABRICATOR',
    'lbl_cloth': 'CLOTH',
    'lbl_glass': 'GLASS',
    'lbl_pitcher': 'WATER PITCHER',
    'unit_kg': '{v} kg',
    // HTML toasts.
    't_scale': 'Bag placed on scale! Mass recorded.',
    't_chair': 'Bag placed on chair! It occupies space.',
    't_cannot_sit': 'Cannot sit! The bag is occupying the space.',
    't_floor': 'Bag moved to floor. Chair is empty.',
    't_sat': 'Success! The space was empty.',
    't_cloth_tumbler': 'Cloth tumbler molded!',
    't_cloth_fail': 'Failed! Cloth is porous and leaks.',
    't_glass_tumbler': 'Glass tumbler molded!',
    't_glass_ok': 'Success! Glass is waterproof and holds the liquid.',
    // Added: feedback where the HTML silently sent the object back.
    'e_drop_scale': 'Drop the school bag on the weighing scale.',
    'e_drop_chair': 'Drop the school bag on the chair.',
    'e_drop_floor': 'Put the bag down on an empty part of the floor.',
    'e_bag_first': 'The bag is still on the chair. Move it to the floor first.',
    'e_drop_cloth': 'Drop the cloth on the Fabricator.',
    'e_drop_glass': 'Drop the glass block on the Fabricator.',
    'e_drop_jug': 'Bring the water pitcher to the Fabricator to pour.',
    // Summary popup (HTML `showSummaryPopup`).
    'sc_complete': 'Scenario {n} Complete!',
    'sum_s1':
        'You proved: The school bag has mass (shown by the weighing scale) and occupies space (preventing the student from sitting). Anything that has mass and occupies space is defined as matter.',
    'sum_s2':
        "You proved: The cloth tumbler failed because it's porous, while the glass tumbler successfully held water. Different types of matter have different properties, dictating their real-world applications.",
    'btn_auto': 'Auto-Perform Action',
    // Added: the sidebar's observation list.
    'obs_title': 'Observations',
    'obs_empty':
        'The observation of each step appears here once you complete it.',
    'obs_step': 'Step {n}',
    'scene_s1':
        'Room with a digital weighing scale, a chair, a school bag and a student',
    'scene_s2':
        'Workbench with the Fabricator, a stack of cloth, a block of glass and a water pitcher',
  },
  'hi': {
    'app_title': 'पदार्थ की परिभाषा और उसके अनुप्रयोग',
    'app_subtitle': 'कक्षा 6 • हमारे चारों ओर की सामग्री',
    'scen_1_opt': 'परिदृश्य 1: कुर्सी का मामला',
    'scen_2_opt': 'परिदृश्य 2: गिलास चुनौती',
    's1_desc':
        'पदार्थ के दो परिभाषित गुणों — द्रव्यमान होना और स्थान (आयतन) घेरना — को देखकर और स्वयं करके समझना।',
    's2_desc':
        'यह समझना कि वस्तुएँ बनाने के लिए पदार्थों को उनके गुणों के आधार पर चुना जाता है, और पदार्थ की इस समझ को एक वास्तविक समस्या पर लागू करना।',
    's1_c1': 'पदार्थ में द्रव्यमान होता है।',
    's1_a1': 'स्कूल बैग को डिजिटल तराजू पर खींचें।',
    's1_o1':
        "तराजू का पलड़ा नीचे दबता है और डिजिटल डिस्प्ले '0.00 किग्रा' से बदलकर '3.50 किग्रा' हो जाता है।",
    's1_c2': 'पदार्थ स्थान घेरता है।',
    's1_a2': 'स्कूल बैग को कुर्सी पर खींचें।',
    's1_o2': 'स्कूल बैग कुर्सी पर रखा है और सीट की जगह घेर लेता है।',
    's1_c3': 'क्या दो वस्तुएँ एक ही समय में एक ही स्थान घेर सकती हैं?',
    's1_a3': 'छात्र पर टैप करें ताकि वह कुर्सी पर बैठने की कोशिश करे।',
    's1_o3':
        'छात्र बैठने की कोशिश करता है, पर बैठ नहीं पाता क्योंकि बैग बीच में है।',
    's1_c4': 'स्थान खाली करना होगा।',
    's1_a4':
        'स्कूल बैग को कुर्सी से नीचे फर्श पर खींचें, फिर छात्र पर टैप करें ताकि वह बैठ जाए।',
    's1_o4': 'छात्र खाली कुर्सी पर सफलतापूर्वक बैठ जाता है।',
    's2_c1': 'पदार्थों से वस्तुएँ बनाना।',
    's2_a1': 'कपड़े के ढेर को साँचे (फैब्रिकेटर) तक खींचें।',
    's2_o1': 'कपड़े से बना एक गिलास वर्कबेंच पर दिखाई देता है।',
    's2_c2': 'पदार्थ के गुणों का परीक्षण।',
    's2_a2':
        'कपड़े के गिलास में पानी डालने के लिए पानी के जग को साँचे तक खींचें।',
    's2_o2':
        'पानी छिद्रों वाले कपड़े से रिस जाता है और गिलास पिचककर झुक जाता है। विफल।',
    's2_c3': 'कोई दूसरा पदार्थ चुनना।',
    's2_a3': 'काँच के ब्लॉक को साँचे (फैब्रिकेटर) तक खींचें।',
    's2_o3': 'एक चमकदार, पारदर्शी काँच का गिलास बन जाता है।',
    's2_c4': 'वस्तु का फिर से परीक्षण।',
    's2_a4':
        'काँच के गिलास में पानी डालने के लिए पानी के जग को साँचे तक खींचें।',
    's2_o4': 'काँच पानी को पूरी तरह रोके रखता है। सफल!',
    's1_hud_1': 'स्कूल बैग को डिजिटल तराजू पर खींचें।',
    's1_hud_2': 'स्कूल बैग को कुर्सी पर खींचें।',
    's1_hud_3': 'छात्र पर टैप करें ताकि वह बैठने की कोशिश करे।',
    's1_hud_4': 'बैग को फर्श पर रखें, फिर छात्र पर दोबारा टैप करें।',
    's2_hud_1': "गिलास बनाने के लिए 'कपड़े' के ढेर को साँचे में खींचें।",
    's2_hud_2': 'कपड़े के गिलास में पानी डालने के लिए जग को खींचें।',
    's2_hud_3': "'काँच' के ब्लॉक को साँचे में खींचें।",
    's2_hud_4': 'काँच के गिलास में पानी डालने के लिए जग को खींचें।',
    'lbl_bag': 'बैग',
    'lbl_student': 'छात्र',
    'lbl_fabricator': 'साँचा',
    'lbl_cloth': 'कपड़ा',
    'lbl_glass': 'काँच',
    'lbl_pitcher': 'पानी का जग',
    'unit_kg': '{v} किग्रा',
    't_scale': 'बैग तराजू पर रखा गया! द्रव्यमान दर्ज हुआ।',
    't_chair': 'बैग कुर्सी पर रखा गया! यह स्थान घेरता है।',
    't_cannot_sit': 'बैठ नहीं सकता! बैग ने जगह घेर रखी है।',
    't_floor': 'बैग फर्श पर रख दिया गया। कुर्सी खाली है।',
    't_sat': 'सफल! जगह खाली थी।',
    't_cloth_tumbler': 'कपड़े का गिलास बन गया!',
    't_cloth_fail': 'विफल! कपड़े में छिद्र होते हैं, इसलिए पानी रिस जाता है।',
    't_glass_tumbler': 'काँच का गिलास बन गया!',
    't_glass_ok': 'सफल! काँच जलरोधी है और पानी को रोके रखता है।',
    'e_drop_scale': 'स्कूल बैग को तराजू पर छोड़ें।',
    'e_drop_chair': 'स्कूल बैग को कुर्सी पर छोड़ें।',
    'e_drop_floor': 'बैग को फर्श की किसी खाली जगह पर रखें।',
    'e_bag_first': 'बैग अभी भी कुर्सी पर है। पहले उसे फर्श पर रखें।',
    'e_drop_cloth': 'कपड़े को साँचे पर छोड़ें।',
    'e_drop_glass': 'काँच के ब्लॉक को साँचे पर छोड़ें।',
    'e_drop_jug': 'पानी डालने के लिए जग को साँचे के पास लाएँ।',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    'sum_s1':
        'आपने सिद्ध किया: स्कूल बैग में द्रव्यमान है (जो तराजू ने दिखाया) और यह स्थान घेरता है (जिससे छात्र बैठ नहीं पाया)। जिस भी चीज़ में द्रव्यमान होता है और जो स्थान घेरती है, उसे पदार्थ कहते हैं।',
    'sum_s2':
        'आपने सिद्ध किया: कपड़े का गिलास विफल रहा क्योंकि कपड़े में छिद्र होते हैं, जबकि काँच के गिलास ने पानी को सफलतापूर्वक रोके रखा। अलग-अलग प्रकार के पदार्थों के गुण अलग-अलग होते हैं, और यही गुण तय करते हैं कि उनसे कौन-सी वस्तुएँ बनाई जाएँ।',
    'btn_auto': 'स्वचालित रूप से क्रिया करें',
    'obs_title': 'अवलोकन',
    'obs_empty': 'हर चरण पूरा करने पर उसका अवलोकन यहाँ दिखेगा।',
    'obs_step': 'चरण {n}',
    'scene_s1': 'डिजिटल तराजू, कुर्सी, स्कूल बैग और एक छात्र वाला कमरा',
    'scene_s2':
        'साँचे (फैब्रिकेटर), कपड़े के ढेर, काँच के ब्लॉक और पानी के जग वाला वर्कबेंच',
  },
};

/// Scenarios and steps per scenario (HTML `ScenariosData`).
const int _scenarioCount = 2;
const int _stepCount = 4;

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
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
      ),
  ];
}

// ===================================================================== STATE

/// Design size of the scene; [LabStage] scales it to fit the canvas.
const Size _design = Size(1000, 560);

/// HTML `new THREE.PerspectiveCamera(45, …)`: vertical field of view.
const double _fovDegrees = 45;

/// HTML `camera.position.set(0, 12, 22)` looking at `controls.target`
/// (0, 0, 0), in both scenarios (`resetCamera()`).
const _V _eye = _V(0, 12, 22);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing objects (short drags must pick them up).
const double _dragSlop = 8;

/// Scene labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's sprite labels stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// While the sidebar is collapsed the scene slides down this far (design
/// px), so the shell's floating mission card at the top left (on phones at
/// most 55 % of the screen height) leaves the scale, the cloth and the glass
/// in view.
const double _collapsedDrop = 130;

/// The slide follows the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the sliding scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the slide.
const ValueKey<String> _sceneKey = ValueKey('ch6-a6-scene');

/// Minimal 3D vector (Three.js `Vector3`).
@immutable
class _V {
  const _V(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const _V zero = _V(0, 0, 0);
  static const _V up = _V(0, 1, 0);
  static const _V right = _V(1, 0, 0);
  static const _V front = _V(0, 0, 1);

  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double k) => _V(x * k, y * k, z * k);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double get length => math.sqrt(dot(this));
  _V get unit => this * (1 / length);

  /// The same point at height [h].
  _V atY(double h) => _V(x, h, z);

  static _V lerp(_V a, _V b, double t) => a + (b - a) * t;
}

/// Horizontal (x / z) distance between two points.
double _flat(_V a, _V b) =>
    math.sqrt((a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z));

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

  /// Where the ray through [s] meets the horizontal plane y = [h] (HTML
  /// `dragPlane`, set to the dragged object's height).
  _V? onPlaneY(Offset s, double h) {
    final dir = ray(s);
    if (dir.y.abs() < 1e-6) return null;
    final t = (h - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// Scenario 1 camera. The room's objects lie right of the origin (the scale
/// at x = -4, the student at x = 12), so the look-at point is drawn 60 px
/// left of the stage centre, keeping the student clear of the tool column
/// on small phones.
final _Cam _camRoom = _Cam(_eye, _V.zero, const Offset(440, 280));

/// Scenario 2 camera: the workbench is centred on the origin.
final _Cam _camBench = _Cam(_eye, _V.zero, const Offset(500, 280));

/// HTML `DirectionalLight(0xfff8e7, 1)` at (10, 20, 10), normalised.
const _V _light = _V(0.4082, 0.8165, 0.4082);

/// HTML `AmbientLight(0xffffff, 0.7)` plus the key light; the key light is
/// toned down so the lit faces do not all clip to white.
const double _ambient = 0.6;
const double _diffuse = 0.55;

// ------------------------------------------------------- scenario 1: room

/// HTML `positions.s1`. The bag heights are corrected so the bag rests on
/// each surface: the HTML centred the 2.8-high bag at 0.65 (inside the
/// scale), 2.5 (inside the seat) and 1.25 (in the floor).
const _V _bagStart = _V(4, _bagRestY, 3); // HTML (4, 1.25, 3)
const _V _bagOnScale = _V(-4, 2.3, 0); // HTML (-4, 0.65, 0)
const _V _bagOnChair = _V(6, 3.05, -2); // HTML (6, 2.5, -2)

/// Where Auto-Perform puts the bag down: left of the chair. The HTML spot
/// `positions.s1.floor` (5, 1.25, 4) is right in front of the chair, where
/// the bag hid the seated student's legs.
const _V _floorSpot = _V(1.5, _bagRestY, 4);

/// Centre height of the bag resting on the floor (half its 2.8 height).
const double _bagRestY = 1.4;

/// `scaleGrp` and `chairGrp` positions (on the floor).
const _V _scaleAt = _V(-4, 0, 0);
const _V _chairAt = _V(6, 0, -2);

/// Scale pan height (`scalePan.position.y = 0.9`), 0.1 lower with the bag
/// on it.
const double _panY = 0.9;
const double _panDip = 0.1;

/// The student: start (`avatarStart`), beside the chair after the failed
/// try (`avatarChair.x + 3`), in front of the chair (`avatarChair`) and on
/// the seat. The HTML "seated" pose (y 1.5, z 0.5) left him floating in
/// front of the seat; here his hips rest on the seat.
const _V _avatarStart = _V(12, 0, 0);
const _V _avatarBeside = _V(9, 0, 1);
const _V _avatarFront = _V(6, 0, 1);
const _V _avatarSeat = _V(6, 0, -1.6);

/// Leg parts (the HTML legs are one 2-unit cylinder): thigh and shin.
const double _thigh = 1.2;
const double _shin = 0.8;

/// A drop counts on the scale / chair within this horizontal distance of
/// its centre (the HTML accepted 5 units, which also let a bag dropped in
/// the middle of the room land on the chair).
const double _bagRange = 3.0;

/// Room floor `BoxGeometry(30, 1, 15)`: the bag stays on it.
const double _roomHalfX = 13.9;
const double _roomMinZ = -6.8;
const double _roomMaxZ = 6.3;

/// Where the bag cannot be put down in step 4 (bag centre, x0 x1 z0 z1):
/// on the chair, on the scale, and on the student's way to the chair.
const List<(double, double, double, double)> _floorBlocked = [
  (3.4, 8.6, -4.7, 0.2), // chair seat (3 x 3) plus half the bag
  (-7.1, -0.9, -3.2, 2.7), // scale base (4 x 4) plus half the bag
  (3.8, 11.0, -0.85, 2.35), // the student walking from x 9 to the chair
];

/// HTML timings (ms): object snap / revert, the student's walk and sit,
/// the summary after he sits, the shake after the failed try.
const int _snapMs = 300;
const int _revertMs = 200;
const int _walkMs = 1000;
const int _sitMs = 300;
const int _s1SummaryMs = 1500;
const double _shakeSeconds = 0.15;
const double _shakeX = 0.5;

// -------------------------------------------------- scenario 2: workbench

/// HTML `positions.s2`. Cloth and glass go onto the Fabricator's base
/// (y 0.4; the HTML snapped them to y 0, inside it).
const _V _moldAt = _V(0, 0, -1);
const _V _inMold = _V(0, 0.4, -1);
const _V _clothStart = _V(-6, 0, 3);
const _V _glassStart = _V(-3, 0, 3);
const _V _jugStart = _V(6, 0, 3);
const _V _jugPour = _V(2.5, 3.5, -1);

/// Fabricator: base `CylinderGeometry(2.5, 2.8, 0.4)`, glass casing radius
/// 2.2 and 2.5 high on top of it, the tumbler `CylinderGeometry(1.2, 0.9,
/// 2.5)` centred at y 1.65.
const double _baseTop = 0.4;
const double _tumblerY = 1.65;
const double _tumblerH = 2.5;

/// A drop counts in the Fabricator within this horizontal distance of its
/// centre (casing radius 2.2; the HTML accepted 5); the pitcher within
/// [_pourRange].
const double _moldRange = 3.0;
const double _pourRange = 3.5;

/// The workbench `BoxGeometry(30, 1, 15)`: objects stay on it.
const double _benchHalfX = 13;
const double _benchHalfZ = 6;

/// HTML `animatePour`: the pitcher tilts to π / 2.5 in 500 ms, the drops
/// fall for 1200 ms, the result shows 400 ms after the tilt, the pitcher
/// returns 1500 ms later; the glass summary follows 1 s after that.
const double _tiltAngle = math.pi / 2.5;
const int _tiltMs = 500;
const int _pourResultMs = 900;
const int _pourReturnMs = 2400;
const int _s2SummaryMs = 2500;
const double _pourSeconds = 1.2;

/// Puddle (`leakPool`, radius 3, scale 0.1 → 1.5 in 1 s), cloth slump and
/// glass fill (1 s each), tumbler pop-in (400 ms, Bounce.Out).
const double _leakSeconds = 1;
const double _fillSeconds = 1;
const double _moldSeconds = 0.4;

/// Water drops (`waterTraces`): 30 spheres of radius 0.12, started 40 ms
/// apart, falling from y 3.2 in 200–450 ms (Quadratic.In) to y 0.45 (cloth,
/// spread 1.5) or 1.0 (glass, spread 0.4).
const int _dropCount = 30;
const double _dropStagger = _pourSeconds / _dropCount;
const double _dropRadius = 0.12;
const double _dropTopY = 3.2;

/// Highlight ring: `RingGeometry(1.5, 2.2)` pulsing to 1.3x and back every
/// 800 ms.
const double _ringIn = 1.5;
const double _ringOut = 2.2;
const double _ringPulse = 0.3;
const double _ringPeriod = 0.8;

/// HTML `TWEEN` scale-up of a picked-up object (1.1x in 150 ms).
const double _heldScale = 0.1;
const double _heldSeconds = 0.15;

/// Where the school bag is.
enum _Spot { start, moving, scale, chair, floor }

/// The student's face texture (`createFaceSprite(expression)`).
enum _Mood { neutral, sad, happy }

/// The scene objects the learner drags or taps (HTML `userData.id`).
enum _Item { bag, avatar, cloth, glass, jug }

/// The tumbler standing in the Fabricator.
enum _Tumbler { none, cloth, glass }

/// A straight move between two points over [seconds] from [start] (scene
/// time), eased by [curve] (a TWEEN.js tween on `position`).
@immutable
class _Move {
  const _Move(
    this.from,
    this.to,
    this.start,
    this.seconds, [
    this.curve = Curves.linear,
  ]);

  const _Move.still(_V at)
    : from = at,
      to = at,
      start = 0,
      seconds = 0,
      curve = Curves.linear;

  final _V from;
  final _V to;
  final double start;
  final double seconds;
  final Curve curve;

  _V at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return _V.lerp(from, to, curve.transform((t - start) / seconds));
  }
}

/// A number eased linearly from [from] to [to] (a TWEEN.js tween on a
/// scalar, default Linear easing).
@immutable
class _Ramp {
  const _Ramp(this.from, this.to, this.start, this.seconds);

  const _Ramp.still(double value)
    : from = value,
      to = value,
      start = 0,
      seconds = 0;

  final double from;
  final double to;
  final double start;
  final double seconds;

  double at(double t) {
    if (seconds <= 0 || t >= start + seconds) return to;
    if (t <= start) return from;
    return from + (to - from) * (t - start) / seconds;
  }
}

/// One falling water drop.
class _Drop {
  _V from = _V.zero;
  _V to = _V.zero;
  double start = 0;
  double seconds = 1;

  /// HTML `drop.scale.y = 1 + random * 2`.
  double stretch = 1;
  bool live = false;

  bool finished(double t) => t >= start + seconds;

  _V at(double t) => _V.lerp(
    from,
    to,
    Curves.easeInQuad.transform(((t - start) / seconds).clamp(0.0, 1.0)),
  );
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// HTML `State.step` (1-based).
  int step = 1;

  /// HTML `State.isAnimating`: an object glides or an animation runs, and
  /// the scene ignores touches meanwhile.
  bool busy = false;

  /// The scenario's last step is done (its summary is scheduled).
  bool done = false;

  /// HTML `State.draggedMesh`, and when it was picked up / let go.
  _Item? held;
  _Item? lastHeld;
  double heldAt = 0;
  double releasedAt = -10;

  // ------------------------------------------------------------ scenario 1
  _Move bag = const _Move.still(_bagStart);
  _Spot bagSpot = _Spot.start;
  _Move avatar = const _Move.still(_avatarStart);

  /// 0 standing … 1 seated (HTML `avatarLegs.rotation.x` → -π / 2).
  _Ramp sit = const _Ramp.still(0);
  _Mood mood = _Mood.neutral;
  double shakeAt = -10;

  // ------------------------------------------------------------ scenario 2
  _Move cloth = const _Move.still(_clothStart);
  _Move glass = const _Move.still(_glassStart);
  _Move jug = const _Move.still(_jugStart);
  bool clothShown = true;
  bool glassShown = true;

  /// Pitcher tilt about z (HTML `jug.rotation.z`).
  _Ramp tilt = const _Ramp.still(0);
  _Tumbler tumbler = _Tumbler.none;
  double moldedAt = -10;

  /// The cloth tumbler started to leak / the glass tumbler to fill.
  double leakAt = -10;
  double fillAt = -10;

  /// The drops started falling (-1: no pour), and into which tumbler.
  double pourAt = -1;
  bool pourFail = true;
  final List<_Drop> drops = [for (var i = 0; i < _dropCount; i++) _Drop()];

  /// The scale shows the bag's mass while the bag rests on it.
  bool get scaleLoaded => bagSpot == _Spot.scale;

  _V posOf(_Item item) => switch (item) {
    _Item.bag => bag.at(time),
    _Item.avatar => avatar.at(time),
    _Item.cloth => cloth.at(time),
    _Item.glass => glass.at(time),
    _Item.jug => jug.at(time),
  };

  /// HTML `isObjActiveForStep(id)`: what the current step lets the learner
  /// drag or tap.
  bool isActive(_Item item) {
    if (done) return false;
    if (scenario == 0) {
      return switch (step) {
        1 || 2 => item == _Item.bag,
        3 => item == _Item.avatar,
        4 =>
          item == _Item.bag || (item == _Item.avatar && bagSpot == _Spot.floor),
        _ => false,
      };
    }
    return switch (step) {
      1 => item == _Item.cloth,
      2 || 4 => item == _Item.jug,
      3 => item == _Item.glass,
      _ => false,
    };
  }

  /// HTML `updateHighlights()`: the object the current step is about.
  _Item? get ringItem {
    if (done || busy || held != null) return null;
    if (scenario == 0) {
      return switch (step) {
        3 => _Item.avatar,
        4 when bagSpot == _Spot.floor => _Item.avatar,
        _ => _Item.bag,
      };
    }
    return switch (step) {
      1 => _Item.cloth,
      3 => _Item.glass,
      _ => _Item.jug,
    };
  }

  /// Size factor of [item]: 1.1x while held (HTML scale tween).
  double grow(_Item item) {
    if (held == item) {
      return 1 + _heldScale * ((time - heldAt) / _heldSeconds).clamp(0.0, 1.0);
    }
    if (lastHeld == item) {
      return 1 +
          _heldScale *
              (1 - ((time - releasedAt) / _heldSeconds).clamp(0.0, 1.0));
    }
    return 1;
  }

  /// HTML `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    step = 1;
    busy = false;
    done = false;
    held = null;
    lastHeld = null;
    releasedAt = -10;
    bag = const _Move.still(_bagStart);
    bagSpot = _Spot.start;
    avatar = const _Move.still(_avatarStart);
    sit = const _Ramp.still(0);
    mood = _Mood.neutral;
    shakeAt = -10;
    cloth = const _Move.still(_clothStart);
    glass = const _Move.still(_glassStart);
    jug = const _Move.still(_jugStart);
    clothShown = true;
    glassShown = true;
    tilt = const _Ramp.still(0);
    tumbler = _Tumbler.none;
    moldedAt = -10;
    leakAt = -10;
    fillAt = -10;
    pourAt = -1;
    for (final d in drops) {
      d.live = false;
    }
  }
}

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on an object the current step lets the learner drag ([canGrab]).
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _MatterLabState extends State<Ch6A6DefiningMatterAndItsApplicationsPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rnd = math.Random();
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in design pixels for the current stage
  /// scale, and the tool column's left edge (set while laying out).
  double _touch = _touchDp;
  double _labelSize = _labelPx;
  double _labelRight = _design.width;

  /// HTML `dragStartPos` / `dragOffset`, and where the bag was.
  _V _grabStart = _V.zero;
  _V _grabOffset = _V.zero;
  _Spot _grabSpot = _Spot.start;

  /// The held object has actually been dragged (past the slop).
  bool _moved = false;

  /// The last toast this lab showed (re-translated on a language switch).
  String? _toastKey;
  int? _toastId;
  LabLang _builtLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);

  LabScenarioData get _scenarioData =>
      (_data[_lab.lang] ??= _buildScenarios(_lab.lang))[_scene.scenario];

  /// HTML `hud-instruction`: `sN_hud_M` of the current step.
  String get _hudKey => 's${_scene.scenario + 1}_hud_${_scene.step}';

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
    _cache.dispose();
    _lab.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- frames

  /// HTML `animate()`: every motion is a function of the scene time, so a
  /// frame advances the clock, moves the water drops and repaints.
  void _onTick(Duration elapsed) {
    final s = _scene;
    s.time = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _tickDrops();
    _frame.value = s.time;
  }

  /// HTML `startPouringParticles`: each drop starts 40 ms after the one
  /// before and falls again as soon as it lands, until 1.2 s have passed.
  void _tickDrops() {
    final s = _scene;
    if (s.pourAt < 0) return;
    final elapsed = s.time - s.pourAt;
    for (var i = 0; i < s.drops.length; i++) {
      final d = s.drops[i];
      if (d.live && !d.finished(s.time)) continue;
      d.live = false;
      if (elapsed >= i * _dropStagger && elapsed < _pourSeconds) _spawn(d);
    }
  }

  void _spawn(_Drop d) {
    final s = _scene;
    double jitter(double width) => (_rnd.nextDouble() - 0.5) * width;
    final spread = s.pourFail ? 1.5 : 0.4;
    d
      ..from = _V(_moldAt.x + jitter(0.3), _dropTopY, _moldAt.z + jitter(0.3))
      ..to = _V(
        _moldAt.x + jitter(spread),
        s.pourFail ? 0.45 : 1.0,
        _moldAt.z + jitter(spread),
      )
      ..start = s.time
      ..seconds = (200 + _rnd.nextDouble() * 250) / 1000
      ..stretch = 1 + _rnd.nextDouble() * 2
      ..live = true;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)` / `resetScenarioState(sc)`: cancels every
  /// timer and animation and rebuilds the scene.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _moved = false;
    });
    _lab.resetView(sound: false);
  }

  void _setBusy(bool busy) {
    if (!mounted || _scene.busy == busy) return;
    setState(() => _scene.busy = busy);
  }

  /// Shows the toast [key]; [sound] plays the shell's right / wrong tone.
  void _toast(String key, {bool error = false, bool sound = false}) {
    _toastKey = key;
    _lab.showToast(_t(key), isError: error, sound: sound);
    _toastId = _lab.toast?.id;
  }

  /// After a language switch, shows the toast on screen in the new language.
  void _retranslateToast(LabLang previous) {
    final shown = _lab.toast;
    final key = _toastKey;
    if (shown == null || key == null || shown.id != _toastId) return;
    if (shown.text != labTr(_i18n, previous, key)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _lab.showToast(_t(key), isError: shown.isError, sound: false);
      _toastId = _lab.toast?.id;
    });
  }

  /// The summary popup (HTML `showSummaryPopup(sc)`) after [delay].
  void _conclude(int scenario, int delayMs) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _scenarioCount,
      delay: Duration(milliseconds: delayMs),
      heading: () => labFormat(_t('sc_complete'), {'n': scenario + 1}),
      body: () => _t('sum_s${scenario + 1}'),
    );
  }

  void _setMove(_Item item, _Move move) {
    final s = _scene;
    switch (item) {
      case _Item.bag:
        s.bag = move;
      case _Item.avatar:
        s.avatar = move;
      case _Item.cloth:
        s.cloth = move;
      case _Item.glass:
        s.glass = move;
      case _Item.jug:
        s.jug = move;
    }
  }

  /// HTML `snapAndAdvance(mesh, pos, callback, time)`: the object glides to
  /// [to] (Quadratic.Out) with the `pop` tone; touches are ignored until it
  /// arrives, then [then] runs.
  void _snap(
    _Item item,
    _V to, {
    int ms = _snapMs,
    bool sound = true,
    VoidCallback? then,
  }) {
    final s = _scene;
    _setBusy(true);
    if (sound) _Sound.pop.play();
    _setMove(
      item,
      _Move(s.posOf(item), to, s.time, ms / 1000, Curves.easeOutQuad),
    );
    _lab.after(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _setBusy(false);
      then?.call();
    });
  }

  /// HTML revert (`snapAndAdvance(mesh, dragStartPos, null, 200)`): the
  /// object goes back to where it was picked up. The HTML said nothing; the
  /// toast [key] now says where it belongs.
  void _revert(_Item item, String key) {
    final spot = _grabSpot;
    _toast(key, error: true, sound: true);
    _snap(
      item,
      _grabStart,
      ms: _revertMs,
      sound: false,
      then: () {
        if (item == _Item.bag) setState(() => _scene.bagSpot = spot);
      },
    );
  }

  // ------------------------------------------------- scenario 1 results

  /// HTML step-1 callback: `updateScaleText("3.50 kg")` (pan dips, success
  /// tone), step 2, toast.
  void _scaleReached() {
    _Sound.success.play();
    setState(() {
      _scene
        ..bagSpot = _Spot.scale
        ..step = 2;
    });
    _toast('t_scale');
  }

  void _chairReached() {
    setState(() {
      _scene
        ..bagSpot = _Spot.chair
        ..step = 3;
    });
    _toast('t_chair');
  }

  /// Step 4, first half: the chair is empty; the student can now sit.
  void _floorReached() {
    setState(() => _scene.bagSpot = _Spot.floor);
    _toast('t_floor');
  }

  /// HTML `handleAvatarClick()`: step 3 the student walks up beside the
  /// chair, frowns and gives up; step 4 (bag on the floor) he walks to the
  /// chair and sits.
  void _avatarClick() {
    final s = _scene;
    if (s.scenario != 0 || s.busy || s.done) return;
    final from = s.avatar.at(s.time);
    if (s.step == 3) {
      _setBusy(true);
      _Sound.pop.play();
      setState(() {
        s
          ..mood = _Mood.sad
          ..avatar = _Move(from, _avatarBeside, s.time, _walkMs / 1000);
      });
      _lab.after(const Duration(milliseconds: _walkMs), () {
        if (!mounted) return;
        _Sound.wrong.play();
        setState(() {
          s
            ..shakeAt = s.time
            ..step = 4
            ..busy = false;
        });
        _toast('t_cannot_sit', error: true);
      });
    } else if (s.step == 4 && s.bagSpot == _Spot.floor) {
      _setBusy(true);
      _Sound.pop.play();
      setState(() {
        s
          ..mood = _Mood.happy
          ..avatar = _Move(from, _avatarFront, s.time, _walkMs / 1000);
      });
      _lab.after(const Duration(milliseconds: _walkMs), () {
        if (!mounted) return;
        _Sound.success.play();
        setState(() {
          s
            ..sit = _Ramp(0, 1, s.time, _sitMs / 1000)
            ..avatar = _Move(_avatarFront, _avatarSeat, s.time, _sitMs / 1000)
            ..done = true;
        });
        _toast('t_sat');
        _conclude(0, _s1SummaryMs);
        _lab.after(const Duration(milliseconds: _sitMs), () => _setBusy(false));
      });
    }
  }

  // ------------------------------------------------- scenario 2 results

  void _clothMolded() {
    final s = _scene;
    setState(() {
      s
        ..clothShown = false
        ..tumbler = _Tumbler.cloth
        ..moldedAt = s.time
        ..step = 2;
    });
    _toast('t_cloth_tumbler');
  }

  /// The glass tumbler replaces the leaking cloth one (and its puddle).
  void _glassMolded() {
    final s = _scene;
    setState(() {
      s
        ..glassShown = false
        ..tumbler = _Tumbler.glass
        ..leakAt = -10
        ..moldedAt = s.time
        ..step = 4;
    });
    _toast('t_glass_tumbler');
  }

  /// HTML `animatePour(isFail)`: the pitcher tilts, water drops fall, then
  /// the cloth tumbler leaks and slumps (step 2) or the glass tumbler fills
  /// (step 4); 1.5 s later the pitcher goes back.
  void _pour(bool fail) {
    final s = _scene;
    _setBusy(true);
    _Sound.pop.play();
    s
      ..tilt = _Ramp(0, _tiltAngle, s.time, _tiltMs / 1000)
      ..pourFail = fail;
    _lab.after(const Duration(milliseconds: _tiltMs), () {
      if (mounted) s.pourAt = s.time;
    });
    _lab.after(const Duration(milliseconds: _pourResultMs), () {
      if (!mounted) return;
      if (fail) {
        _Sound.wrong.play();
        setState(() => s.leakAt = s.time);
        _toast('t_cloth_fail', error: true);
      } else {
        _Sound.success.play();
        setState(() {
          s
            ..fillAt = s.time
            ..done = true;
        });
        _toast('t_glass_ok');
        _conclude(1, _s2SummaryMs);
      }
    });
    _lab.after(const Duration(milliseconds: _pourReturnMs), () {
      if (!mounted) return;
      s.tilt = _Ramp(s.tilt.at(s.time), 0, s.time, _tiltMs / 1000);
      _snap(
        _Item.jug,
        _jugStart,
        then: () {
          // The next step shows once the pitcher is back and can be held.
          if (fail) setState(() => s.step = 3);
        },
      );
    });
  }

  // ------------------------------------------------------ Auto-Perform

  /// HTML `autoCompleteStep()`: does the current step's action.
  void _autoPerform() {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.held != null || s.done) return;
    if (s.scenario == 0) {
      switch (s.step) {
        case 1:
          s.bagSpot = _Spot.moving;
          _snap(_Item.bag, _bagOnScale, then: _scaleReached);
        case 2:
          s.bagSpot = _Spot.moving;
          _snap(_Item.bag, _bagOnChair, then: _chairReached);
        case 3:
          _avatarClick();
        default:
          if (s.bagSpot == _Spot.floor) {
            _avatarClick();
          } else {
            s.bagSpot = _Spot.moving;
            _snap(_Item.bag, _floorSpot, then: _floorReached);
          }
      }
      return;
    }
    switch (s.step) {
      case 1:
        _snap(_Item.cloth, _inMold, then: _clothMolded);
      case 2:
        _snap(_Item.jug, _jugPour, then: () => _pour(true));
      case 3:
        _snap(_Item.glass, _inMold, then: _glassMolded);
      default:
        _snap(_Item.jug, _jugPour, then: () => _pour(false));
    }
  }

  // -------------------------------------------------------------- gestures

  _Cam get _cam => _scene.scenario == 0 ? _camRoom : _camBench;

  /// HTML invisible hit boxes (`bagHit` 4 x 4.5 x 3, `avatarHit` 3.5 x 6 x
  /// 3.5, `clothHit` / `glassHit` 3.5³, `jugHit` 4 x 5 x 4) as screen
  /// rectangles, at least a 48 dp target around the object's centre.
  Rect _hitRect(_Item item) {
    final s = _scene;
    final pos = s.posOf(item);
    final (centre, half) = switch (item) {
      _Item.bag => (pos, const _V(2, 2.25, 1.5)),
      _Item.avatar => (pos + const _V(0, 2.5, 0), const _V(1.75, 3, 1.75)),
      _Item.cloth => (pos + const _V(0, 1, 0), const _V(1.75, 1.75, 1.75)),
      _Item.glass => (pos + const _V(0, 0.9, 0), const _V(1.75, 1.75, 1.75)),
      _Item.jug => (pos + const _V(0, 1.5, 0), const _V(2, 2.5, 2)),
    };
    final cam = _cam;
    var rect = Rect.fromCircle(center: cam.p(centre), radius: _touch);
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        for (final sz in const [-1.0, 1.0]) {
          final c = cam.p(centre + _V(sx * half.x, sy * half.y, sz * half.z));
          rect = rect.expandToInclude(Rect.fromLTWH(c.dx, c.dy, 0, 0));
        }
      }
    }
    return rect;
  }

  /// The object under [at]: the one the step is about first (HTML raycast
  /// order is by distance; the step's object is what the learner aims at).
  _Item? _itemAt(Offset at) {
    final s = _scene;
    final items = s.scenario == 0
        ? const [_Item.avatar, _Item.bag]
        : [
            if (s.clothShown) _Item.cloth,
            if (s.glassShown) _Item.glass,
            _Item.jug,
          ];
    _Item? other;
    for (final item in items) {
      if (!_hitRect(item).contains(at)) continue;
      if (s.isActive(item)) return item;
      other ??= item;
    }
    return other;
  }

  /// HTML `onPointerDown`: only the step's draggable object can be held.
  bool _canGrab(PointerDownEvent event) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.done || s.held != null) return false;
    final item = _itemAt(event.localPosition);
    return item != null && item != _Item.avatar && s.isActive(item);
  }

  /// HTML `onPointerDown` on a draggable: the drag plane at the object's
  /// height and the grab offset.
  void _onDown(DragDownDetails d) {
    final s = _scene;
    final item = _itemAt(d.localPosition);
    if (item == null || item == _Item.avatar || !s.isActive(item)) return;
    final pos = s.posOf(item);
    final hit = _cam.onPlaneY(d.localPosition, pos.y);
    _grabStart = pos;
    _grabSpot = s.bagSpot;
    _grabOffset = hit == null ? _V.zero : _V(hit.x - pos.x, 0, hit.z - pos.z);
    _moved = false;
    setState(() {
      s
        ..held = item
        ..lastHeld = item
        ..heldAt = s.time;
    });
  }

  void _onDragStart(DragStartDetails d) {
    final s = _scene;
    if (s.held == null) return;
    _moved = true;
    // Lifted off the scale: its display goes back to 0.00 kg.
    if (s.held == _Item.bag) setState(() => s.bagSpot = _Spot.moving);
  }

  /// HTML `onPointerMove`: the held object follows the finger on its plane.
  void _onDragUpdate(DragUpdateDetails d) {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    final hit = _cam.onPlaneY(d.localPosition, _grabStart.y);
    if (hit == null) return;
    final x = hit.x - _grabOffset.x;
    final z = hit.z - _grabOffset.z;
    final p = item == _Item.bag
        ? _V(
            x.clamp(-_roomHalfX, _roomHalfX),
            _grabStart.y,
            z.clamp(_roomMinZ, _roomMaxZ),
          )
        : _V(
            x.clamp(-_benchHalfX, _benchHalfX),
            _grabStart.y,
            z.clamp(-_benchHalfZ, _benchHalfZ),
          );
    _setMove(item, _Move.still(p));
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `onPointerUp`: a dragged object is checked against the step's
  /// target; a mere tap leaves it where it was.
  void _release() {
    final s = _scene;
    final item = s.held;
    if (item == null) return;
    setState(() {
      s
        ..held = null
        ..releasedAt = s.time;
    });
    if (!_moved) return;
    _moved = false;
    _checkDrop(item);
  }

  /// HTML `checkDropTarget()`.
  void _checkDrop(_Item item) {
    final s = _scene;
    final p = s.posOf(item);
    if (item == _Item.bag) {
      if (s.step == 1 && _flat(p, _scaleAt) < _bagRange) {
        _snap(item, _bagOnScale, then: _scaleReached);
      } else if (s.step == 2 && _flat(p, _chairAt) < _bagRange) {
        _snap(item, _bagOnChair, then: _chairReached);
      } else if (s.step == 4 && _floorFree(p)) {
        _snap(item, p.atY(_bagRestY), then: _floorReached);
      } else {
        _revert(item, switch (s.step) {
          1 => 'e_drop_scale',
          2 => 'e_drop_chair',
          _ => 'e_drop_floor',
        });
      }
      return;
    }
    final toMold = _flat(p, _moldAt);
    switch (item) {
      case _Item.cloth when s.step == 1 && toMold < _moldRange:
        _snap(item, _inMold, then: _clothMolded);
      case _Item.glass when s.step == 3 && toMold < _moldRange:
        _snap(item, _inMold, then: _glassMolded);
      case _Item.jug when (s.step == 2 || s.step == 4) && toMold < _pourRange:
        final fail = s.step == 2;
        _snap(item, _jugPour, then: () => _pour(fail));
      case _Item.cloth:
        _revert(item, 'e_drop_cloth');
      case _Item.glass:
        _revert(item, 'e_drop_glass');
      default:
        _revert(item, 'e_drop_jug');
    }
  }

  /// Step 4: the HTML accepted only a drop near one floor spot and slid the
  /// bag there; here the bag stays where it is put down, anywhere on the
  /// open floor (not on the chair, the scale or the student's way).
  bool _floorFree(_V p) {
    for (final (x0, x1, z0, z1) in _floorBlocked) {
      if (p.x > x0 && p.x < x1 && p.z > z0 && p.z < z1) return false;
    }
    return true;
  }

  /// Taps: the student (HTML `clickable` avatar). A tap on another object
  /// repeats the current task; the HTML ignored it.
  void _onTap(TapUpDetails d) {
    final s = _scene;
    if (!_lab.isLabActive || s.busy || s.held != null || s.done) return;
    final item = _itemAt(d.localPosition);
    if (item == null) return;
    if (item == _Item.avatar) {
      if (s.isActive(item)) {
        _avatarClick();
        return;
      }
      if (s.step == 4) {
        _toast('e_bag_first', error: true, sound: true);
        return;
      }
    }
    if (s.isActive(item)) {
      // The right object, but it has to be dragged.
      _toast(_hudKey);
    } else {
      _toast(_hudKey, error: true, sound: true);
    }
  }

  // -------------------------------------------------------------------- UI

  /// HTML `#hud-container` button "Auto-Perform Action".
  List<LabAction> _actions() {
    final s = _scene;
    if (s.done) return const [];
    return [
      LabAction(
        label: _t('btn_auto'),
        icon: Icons.auto_fix_high,
        color: _Colors.indigo600,
        foreground: _Colors.white,
        enabled: !s.busy && s.held == null,
        // The object's snap plays the HTML `pop`.
        silent: true,
        onTap: _autoPerform,
      ),
    ];
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
        final data = _scenarioData;
        final s = _scene;
        return LabShell(
          controller: _lab,
          icon: Icons.scale,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt')],
          scenarioIndex: s.scenario,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.done ? data.steps.length + 1 : s.step,
          actions: _actions(),
          // HTML `hud-instruction`; it no longer applies once the scenario
          // is done.
          showHud: !s.done,
          hud: _t(_hudKey),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('obs_title'),
          sidebarExtra: _observations(p, f),
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          final stageLeft = (box.maxWidth - _design.width * fit) / 2;
          final tools = labOverlayInsets(context, _lab).right;
          _labelRight = math.min(
            _design.width,
            (box.maxWidth - tools - stageLeft) / fit,
          );
        }
        final drop = _lab.isSidebarOpen ? 0.0 : _collapsedDrop;
        return LabStage(
          designSize: _design,
          // The slide moves the whole scene layer (painting and hit tests),
          // so gestures arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(0, drop / _design.height),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                // Drags and taps on the scene are not screen-reader actions
                // (Auto-Perform does the same); the scene is announced by
                // its label instead.
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
                  TapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer
                      >(
                        () => TapGestureRecognizer(debugOwner: this),
                        (r) => r.onTapUp = _onTap,
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

  /// Sidebar list of the observations of the steps done so far (the HTML
  /// accordion showed each step's observation before it was made).
  Widget _observations(LabPalette p, double f) {
    final steps = _scenarioData.steps;
    final s = _scene;
    final done = (s.done ? steps.length : s.step - 1).clamp(0, steps.length);
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

// ================================================================== PAINTING

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();

  /// Same-colour hairline around opaque facets, hiding anti-aliasing seams.
  final Paint seam = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..strokeJoin = StrokeJoin.round;
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  /// Round-ended thick lines (legs, chair legs, torus rings).
  final Paint limb = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final Path path = Path();

  /// Even-odd path for rings (the highlight ring, the Fabricator target).
  final Path ringPath = Path()..fillType = PathFillType.evenOdd;
}

/// What the painter makes once and reuses: pens, the static backdrop (scene
/// background and floor / workbench) and the label text painters. Owned by
/// the page state and disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  ui.Picture? _backdrop;
  int _backdropScenario = -1;
  bool _backdropDark = true;

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
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: labLetterSpacing(text, 0.6),
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

/// [v] turned by [yaw] about the y axis (Three.js `rotation.y`).
_V _yawed(_V v, double yaw) {
  if (yaw == 0) return v;
  final c = math.cos(yaw), s = math.sin(yaw);
  return _V(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

/// Convex hull of [pts] (monotone chain), for glass silhouettes.
List<Offset> _hull(List<Offset> pts) {
  if (pts.length < 3) return pts;
  pts.sort(
    (a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy),
  );
  double turn(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in pts) {
    while (lower.length >= 2 &&
        turn(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in pts.reversed) {
    while (upper.length >= 2 &&
        turn(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// Segments of rims and rings (smooth enough at this size).
const int _ringSides = 28;

/// Mesh drawing in one camera's projection.
class _Gfx {
  _Gfx(this.canvas, this.cam, this.pens);

  final Canvas canvas;
  final _Cam cam;
  final _Pens pens;

  _V get _eyeAt => cam.eye;

  void _to(Path path, int i, Offset o) {
    if (i == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }

  /// Filled polygon through the projected [pts].
  void poly(List<_V> pts, Color color, {Color? edge, double edgeWidth = 1}) {
    final path = pens.path..reset();
    for (var i = 0; i < pts.length; i++) {
      _to(path, i, cam.p(pts[i]));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
    if (edge != null) {
      canvas.drawPath(
        path,
        pens.stroke
          ..strokeWidth = edgeWidth
          ..color = edge,
      );
    }
  }

  /// BoxGeometry centred at [c], turned by [yaw]: the faces seen by the
  /// camera, lit; [edge] darkens (or [edgeColor] colours) the rims.
  void box(
    _V c,
    _V size,
    Color color, {
    double opacity = 1,
    double edge = 0.35,
    Color? edgeColor,
    double yaw = 0,
  }) {
    final hx = size.x / 2, hy = size.y / 2, hz = size.z / 2;
    for (final face in _boxFaces) {
      final f = face.normal;
      final n = _yawed(f, yaw);
      final mid = c + _yawed(_V(f.x * hx, f.y * hy, f.z * hz), yaw);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final path = pens.path..reset();
      for (var i = 0; i < 4; i++) {
        final k = face.corners[i];
        _to(path, i, cam.p(c + _yawed(_V(k.x * hx, k.y * hy, k.z * hz), yaw)));
      }
      path.close();
      canvas.drawPath(
        path,
        pens.fill..color = _lit(color, n, opacity: opacity),
      );
      final rim =
          edgeColor ??
          (edge > 0
              ? labShade(color, -0.5).withValues(alpha: edge * opacity)
              : null);
      if (rim != null) {
        canvas.drawPath(
          path,
          pens.stroke
            ..strokeWidth = 0.8
            ..color = rim,
        );
      }
    }
  }

  /// Cross-section direction at [a] radians in the frame ([ex], [ez]).
  static _V _dir(_V ex, _V ez, double a) => ex * math.cos(a) + ez * math.sin(a);

  /// CylinderGeometry: radius [r0] at [base], [r1] at the far end, [h]
  /// long along [axis]; [ex] / [ez] span its cross-section. The facets
  /// turned to the camera are lit one by one; [cap] (or [capColor] for an
  /// open container's inside) closes the far end when it faces the camera.
  void cylinder(
    _V base,
    double r0,
    double r1,
    double h,
    Color color, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    double opacity = 1,
    bool cap = true,
    Color? capColor,
    int sides = 24,
  }) {
    if (h <= 0) return;
    final top = base + axis * h;
    final slope = (r0 - r1) / h;
    for (var i = 0; i < sides; i++) {
      final a0 = i * 2 * math.pi / sides;
      final a1 = (i + 1) * 2 * math.pi / sides;
      final m = _dir(ex, ez, (a0 + a1) / 2);
      final n = (m + axis * slope).unit;
      final mid = base + axis * (h / 2) + m * ((r0 + r1) / 2);
      if (n.dot(_eyeAt - mid) <= 0) continue;
      final d0 = _dir(ex, ez, a0), d1 = _dir(ex, ez, a1);
      final path = pens.path..reset();
      _to(path, 0, cam.p(base + d0 * r0));
      _to(path, 1, cam.p(base + d1 * r0));
      _to(path, 2, cam.p(top + d1 * r1));
      _to(path, 3, cam.p(top + d0 * r1));
      path.close();
      final c = _lit(color, n, opacity: opacity);
      canvas.drawPath(path, pens.fill..color = c);
      if (opacity >= 1) canvas.drawPath(path, pens.seam..color = c);
    }
    if (cap && axis.dot(_eyeAt - top) > 0) {
      disc(top, r1, capColor ?? _lit(color, axis, opacity: opacity), ex, ez);
    }
  }

  /// A flat disc of radius [r] centred at [c] in the plane ([ex], [ez]).
  void disc(_V c, double r, Color color, [_V ex = _V.right, _V ez = _V.front]) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      _to(path, i, cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r));
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// RingGeometry lying flat at [c] (MeshBasicMaterial: not lit).
  void ring(_V c, double rIn, double rOut, Color color) {
    final path = pens.ringPath..reset();
    for (final r in [rOut, rIn]) {
      for (var i = 0; i < _ringSides; i++) {
        final o = cam.p(
          c + _dir(_V.right, _V.front, i * 2 * math.pi / _ringSides) * r,
        );
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
    }
    canvas.drawPath(path, pens.fill..color = color);
  }

  /// TorusGeometry of radius [radius] and tube [tube] centred at [c] in the
  /// plane ([ex], [ez]): a thick ring with a highlight.
  void torus(_V c, double radius, double tube, Color color, _V ex, _V ez) {
    final path = pens.path..reset();
    for (var i = 0; i <= _ringSides; i++) {
      _to(
        path,
        i,
        cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * radius),
      );
    }
    final w = math.max(1.2, 2 * tube * cam.scaleAt(c));
    canvas.drawPath(
      path,
      pens.limb
        ..strokeWidth = w
        ..color = labShade(color, -0.15),
    );
    canvas.drawPath(
      path,
      pens.limb
        ..strokeWidth = w * 0.35
        ..color = labShade(color, 0.35),
    );
  }

  /// A round limb from [a] to [b] (CylinderGeometry of radius [r]) with a
  /// highlight on its lit side.
  void limb(_V a, _V b, double r, Color color) {
    final pa = cam.p(a), pb = cam.p(b);
    final w = math.max(1.5, 2 * r * cam.scaleAt((a + b) * 0.5));
    canvas.drawLine(
      pa,
      pb,
      pens.limb
        ..strokeWidth = w
        ..color = labShade(color, -0.1),
    );
    final d = pb - pa;
    final len = d.distance;
    if (len < 0.5) return;
    var n = Offset(-d.dy / len, d.dx / len);
    if (n.dx < 0) n = -n; // towards the key light (upper right)
    canvas.drawLine(
      pa + n * (w * 0.22),
      pb + n * (w * 0.22),
      pens.limb
        ..strokeWidth = w * 0.25
        ..color = labShade(color, 0.3),
    );
  }

  /// SphereGeometry: a lit disc with its shaded side away from the key
  /// light and a highlight (no gradient, so nothing is allocated).
  void sphere(_V c, double r, Color color) {
    final o = cam.p(c);
    final rr = r * cam.scaleAt(c);
    canvas.drawCircle(o, rr, pens.fill..color = labShade(color, -0.3));
    canvas.drawCircle(
      o + Offset(rr * 0.12, -rr * 0.14),
      rr * 0.84,
      pens.fill..color = color,
    );
    canvas.drawCircle(
      o + Offset(rr * 0.34, -rr * 0.38),
      rr * 0.22,
      pens.fill..color = labShade(color, 0.45),
    );
  }

  /// Soft blurred shadow of an elliptic footprint on the floor.
  void shadow(double x, double z, double rx, double rz) {
    final path = pens.path..reset();
    for (var i = 0; i < _ringSides; i++) {
      final a = i * 2 * math.pi / _ringSides;
      _to(
        path,
        i,
        cam.p(_V(x + math.cos(a) * rx, 0.003, z + math.sin(a) * rz)),
      );
    }
    path.close();
    canvas.drawPath(path, pens.shadow);
  }

  /// Rim of a cylinder end: the ring of radius [r] at [c].
  List<Offset> _rim(_V c, double r, _V ex, _V ez) => [
    for (var i = 0; i < _ringSides; i++)
      cam.p(c + _dir(ex, ez, i * 2 * math.pi / _ringSides) * r),
  ];

  /// Clear glass (MeshPhysicalMaterial, transmission ~0.9), back part: the
  /// faint body and the far halves of its rims. Draw the contents next and
  /// [glassFront] last.
  void glassBack(
    _V base,
    double r0,
    double r1,
    double h, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    Color tint = _Colors.glass,
    double body = 0.07,
  }) {
    final top = base + axis * h;
    final hull = _hull([..._rim(base, r0, ex, ez), ..._rim(top, r1, ex, ez)]);
    final path = pens.path..reset();
    for (var i = 0; i < hull.length; i++) {
      _to(path, i, hull[i]);
    }
    path.close();
    canvas.drawPath(path, pens.fill..color = tint.withValues(alpha: body));
    _halfRim(base, r0, ex, ez, near: false, alpha: 0.22, tint: tint);
    _halfRim(top, r1, ex, ez, near: false, alpha: 0.3, tint: tint);
  }

  /// Clear glass, front part: the near rims, the silhouette edges and a
  /// highlight stripe.
  void glassFront(
    _V base,
    double r0,
    double r1,
    double h, {
    _V axis = _V.up,
    _V ex = _V.right,
    _V ez = _V.front,
    Color tint = _Colors.glass,
  }) {
    final top = base + axis * h;
    _halfRim(base, r0, ex, ez, near: true, alpha: 0.4, tint: tint);
    _halfRim(top, r1, ex, ez, near: true, alpha: 0.55, tint: tint);
    // Silhouette lines where the side turns away from the camera.
    final v = _eyeAt - (base + axis * (h / 2));
    final a = math.atan2(-ex.dot(v), ez.dot(v));
    final edge = pens.stroke
      ..strokeWidth = 1.2
      ..color = tint.withValues(alpha: 0.4);
    for (final s in [a, a + math.pi]) {
      final d = _dir(ex, ez, s);
      canvas.drawLine(cam.p(base + d * r0), cam.p(top + d * r1), edge);
    }
    // Highlight towards the key light.
    final hl = _dir(ex, ez, a + math.pi * 0.72);
    canvas.drawLine(
      cam.p(base + axis * (h * 0.12) + hl * (r0 * 0.8)),
      cam.p(base + axis * (h * 0.88) + hl * (r1 * 0.8)),
      pens.limb
        ..strokeWidth = math.max(1.5, 0.12 * cam.scaleAt(base))
        ..color = tint.withValues(alpha: 0.28),
    );
  }

  /// The near or far half of a rim (seen from the camera).
  void _halfRim(
    _V c,
    double r,
    _V ex,
    _V ez, {
    required bool near,
    required double alpha,
    required Color tint,
  }) {
    final v = _eyeAt - c;
    final path = pens.path..reset();
    var open = false;
    for (var i = 0; i <= _ringSides; i++) {
      final d = _dir(ex, ez, i * 2 * math.pi / _ringSides);
      final isNear = d.dot(v) > 0;
      final o = cam.p(c + d * r);
      if (isNear == near) {
        if (open) {
          path.lineTo(o.dx, o.dy);
        } else {
          path.moveTo(o.dx, o.dy);
          open = true;
        }
      } else {
        open = false;
      }
    }
    canvas.drawPath(
      path,
      pens.stroke
        ..strokeWidth = 1.4
        ..color = tint.withValues(alpha: alpha),
    );
  }
}

/// The scene's static layer: background and the floor (S1) or the
/// workbench (S2).
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  Size size,
  _Pens pens,
) {
  canvas.drawRect(
    labBleed(size),
    pens.fill..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  final room = scenario == 0;
  _Gfx(canvas, room ? _camRoom : _camBench, pens).box(
    const _V(0, -0.5, 0),
    const _V(30, 1, 15),
    room ? _Colors.floor : _Colors.bench,
    edge: 0.4,
  );
}

/// Paints the HTML Three.js scene of the current scenario: S1 the room with
/// the scale, the chair, the bag and the student, S2 the workbench with the
/// Fabricator, the cloth, the glass and the pitcher.
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

  /// Design x of the tool column's left edge (labels stay left of it).
  final double labelRight;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize);
    canvas.drawPicture(cache.backdrop(scene.scenario, isDark, size));
    if (scene.scenario == 0) {
      _paintRoom(canvas);
    } else {
      _paintBench(canvas);
    }
  }

  /// HTML highlight ring under [at], pulsing.
  void _paintRing(_Gfx g, _V at) {
    final x = scene.time / _ringPeriod;
    final pulse = 1 + _ringPulse * (1 - ((x % 2) - 1).abs());
    g.ring(
      _V(at.x, 0.05, at.z),
      _ringIn * pulse,
      _ringOut * pulse,
      _Colors.ring,
    );
  }

  // ---------------------------------------------------------- scenario 1

  /// The student's position, with the HTML shake (+0.5 for 150 ms).
  _V _avatarPos() {
    final s = scene;
    final p = s.avatar.at(s.time);
    final shaking = s.time - s.shakeAt < _shakeSeconds;
    return shaking ? p + const _V(_shakeX, 0, 0) : p;
  }

  void _paintRoom(Canvas canvas) {
    final g = _Gfx(canvas, _camRoom, _pens);
    final s = scene;
    final bag = s.bag.at(s.time);
    final av = _avatarPos();

    // Contact shadows; the key light at (10, 20, 10) casts them towards
    // -x / -z.
    g.shadow(_scaleAt.x - 0.2, _scaleAt.z - 0.2, 2.3, 2.3);
    g.shadow(_chairAt.x - 0.4, _chairAt.z - 0.4, 1.8, 1.8);
    if (bag.y < _bagRestY + 0.3) g.shadow(bag.x - 0.5, bag.z - 0.4, 1.3, 1);
    g.shadow(av.x - 0.3, av.z - 0.3, 0.9, 0.6);

    final ring = s.ringItem;
    if (ring != null) _paintRing(g, ring == _Item.bag ? bag : av);

    // Bodies far to near; the held bag in front of everything.
    final order = [0, 1, 2, 3]; // scale, chair, bag, student
    double depth(int part) => switch (part) {
      0 => _camRoom.depth(_scaleAt + const _V(0, 0.5, 0)),
      1 => _camRoom.depth(_chairAt + const _V(0, 1.5, 0)),
      2 => s.held == _Item.bag ? double.negativeInfinity : _camRoom.depth(bag),
      _ => _camRoom.depth(av + const _V(0, 3, 0)),
    };
    order.sort((a, b) => depth(b).compareTo(depth(a)));
    for (final part in order) {
      switch (part) {
        case 0:
          _paintScale(g);
        case 1:
          _paintChair(g);
        case 2:
          _paintBag(g, bag, s.grow(_Item.bag));
        default:
          _paintStudent(g, av);
      }
    }

    // The scale's display is part of the scale, always shown.
    final kg = labFormat(_t('unit_kg'), {'v': s.scaleLoaded ? '3.50' : '0.00'});
    _chip(
      canvas,
      _camRoom.p(_scaleAt + const _V(0, 0.4, 2.05)),
      kg,
      background: s.scaleLoaded ? _Colors.readoutLoaded : _Colors.readoutEmpty,
    );
    if (!showLabels) return;
    if (s.bagSpot == _Spot.floor) {
      // On the floor the label goes in front of the bag, where it cannot
      // cover the student walking to the chair or sitting on it.
      final front = _camRoom.p(bag + const _V(0, -_bagRestY, 1.2));
      _chip(canvas, front + Offset(0, cache.labelSize * 1.1), _t('lbl_bag'));
    } else {
      _chip(
        canvas,
        _camRoom.p(bag + _V(0, 2.2 * s.grow(_Item.bag), 0)),
        _t('lbl_bag'),
      );
    }
    _chip(canvas, _camRoom.p(av + const _V(0, 5.5, 0)), _t('lbl_student'));
  }

  /// `scaleGrp`: base 4 x 0.8 x 4, pan 3.5 x 0.2 x 3.5 (dipping 0.1 with
  /// the bag on it) and an LCD window on the front (added: the HTML's
  /// readout sprite floated inside the bag).
  void _paintScale(_Gfx g) {
    g.box(
      _scaleAt + const _V(0, 0.4, 0),
      const _V(4, 0.8, 4),
      _Colors.scaleBase,
    );
    final pan = _panY - (scene.scaleLoaded ? _panDip : 0);
    g.box(
      _V(_scaleAt.x, pan, _scaleAt.z),
      const _V(3.5, 0.2, 3.5),
      _Colors.scalePan,
    );
    g.poly([
      _scaleAt + const _V(-1.3, 0.15, 2.01),
      _scaleAt + const _V(1.3, 0.15, 2.01),
      _scaleAt + const _V(1.3, 0.65, 2.01),
      _scaleAt + const _V(-1.3, 0.65, 2.01),
    ], _Colors.lcd);
  }

  /// `chairGrp`: seat 3 x 0.3 x 3 at y 1.5, back 3 x 2.5 x 0.3, four legs
  /// of radius 0.15; back legs, seat, back, front legs.
  void _paintChair(_Gfx g) {
    const c = _chairAt;
    for (final z in const [-1.3, 1.3]) {
      for (final x in const [-1.3, 1.3]) {
        if (z > 0) continue;
        g.limb(c + _V(x, 0.05, z), c + _V(x, 1.35, z), 0.15, _Colors.chairLeg);
      }
    }
    g.box(c + const _V(0, 1.5, 0), const _V(3, 0.3, 3), _Colors.wood);
    g.box(c + const _V(0, 2.9, -1.35), const _V(3, 2.5, 0.3), _Colors.wood);
    for (final x in const [-1.3, 1.3]) {
      g.limb(
        c + _V(x, 0.05, 1.3),
        c + _V(x, 1.35, 1.3),
        0.15,
        _Colors.chairLeg,
      );
    }
  }

  /// `meshes.bag`: body 2.2 x 2.8 x 1.4 and front pocket 1.6 x 1.4 x 0.6,
  /// scaled by [k] about its centre.
  void _paintBag(_Gfx g, _V p, double k) {
    g.box(p, _V(2.2 * k, 2.8 * k, 1.4 * k), _Colors.bag, edge: 0.45);
    g.box(
      p + _V(0, -0.4 * k, 0.9 * k),
      _V(1.6 * k, 1.4 * k, 0.6 * k),
      _Colors.bagPocket,
      edge: 0.45,
    );
  }

  /// `meshes.avatar`: legs (radius 0.3), torso 1.4 x 1.8 x 0.9, head of
  /// radius 0.7 with the face. Seated, the thighs point forward and the
  /// shins hang down.
  void _paintStudent(_Gfx g, _V p) {
    final s = scene;
    final a = s.sit.at(s.time) * math.pi / 2;
    void legs() {
      for (final side in const [-0.4, 0.4]) {
        final hip = p + _V(side, 2, 0);
        final knee = hip + _V(0, -math.cos(a) * _thigh, math.sin(a) * _thigh);
        g.limb(hip, knee, 0.3, _Colors.trousers);
        g.limb(knee, knee + const _V(0, -_shin, 0), 0.3, _Colors.trousers);
      }
    }

    final seated = a > math.pi / 4;
    if (!seated) legs();
    g.box(p + const _V(0, 3, 0), const _V(1.4, 1.8, 0.9), _Colors.shirt);
    if (seated) legs();
    final head = p + const _V(0, 4.5, 0);
    g.sphere(head, 0.7, _Colors.skin);
    _paintFace(g, head, s.mood);
  }

  /// `createFaceSprite(expression)` on the 1.3 x 1.3 face plane in front of
  /// the head (canvas 128 px: eyes r 10 at (40, 50) and (88, 50); lines 10
  /// px wide).
  void _paintFace(_Gfx g, _V head, _Mood mood) {
    const px = 1.3 / 128; // world units per face-canvas pixel
    _V at(double cx, double cy) =>
        head + _V((cx - 64) * px, (64 - cy) * px, 0.72);
    final k = g.cam.scaleAt(at(64, 64));
    final ink = _pens.fill..color = _Colors.faceInk;
    g.canvas.drawCircle(g.cam.p(at(40, 50)), 10 * px * k, ink);
    g.canvas.drawCircle(g.cam.p(at(88, 50)), 10 * px * k, ink);
    final line = _pens.stroke
      ..strokeWidth = math.max(1, 10 * px * k)
      ..color = _Colors.faceInk;
    void seg(double x0, double y0, double x1, double y1) =>
        g.canvas.drawLine(g.cam.p(at(x0, y0)), g.cam.p(at(x1, y1)), line);
    void arc(double cx, double cy, double r, double from, double to) {
      final path = _pens.path..reset();
      for (var i = 0; i <= 10; i++) {
        final t = from + (to - from) * i / 10;
        final o = g.cam.p(at(cx + r * math.cos(t), cy + r * math.sin(t)));
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      g.canvas.drawPath(path, line);
    }

    switch (mood) {
      case _Mood.neutral:
        seg(45, 90, 83, 90);
      case _Mood.sad:
        seg(30, 35, 50, 30);
        seg(98, 35, 78, 30);
        arc(64, 110, 20, math.pi + 0.4, 2 * math.pi - 0.4);
      case _Mood.happy:
        seg(30, 35, 50, 25);
        seg(98, 35, 78, 25);
        arc(64, 75, 24, 0.2, math.pi - 0.2);
    }
  }

  // ---------------------------------------------------------- scenario 2

  void _paintBench(Canvas canvas) {
    final g = _Gfx(canvas, _camBench, _pens);
    final s = scene;
    final cloth = s.cloth.at(s.time);
    final glass = s.glass.at(s.time);
    final jug = s.jug.at(s.time);

    if (s.clothShown) g.shadow(cloth.x - 0.4, cloth.z - 0.4, 1.4, 1.4);
    if (s.glassShown) g.shadow(glass.x - 0.4, glass.z - 0.4, 1.3, 1.3);
    if (jug.y < 0.5) g.shadow(jug.x - 0.5, jug.z - 0.5, 1.3, 1.3);
    g.shadow(_moldAt.x - 0.2, _moldAt.z - 0.2, 3, 3);

    // `leakPool`: the puddle spreads over the bench around the base.
    final leak = _leak();
    if (leak > 0) {
      g.disc(
        _moldAt.atY(0.01),
        3 * (0.1 + 1.4 * leak),
        _Colors.water.withValues(alpha: 0.5),
      );
    }

    final ring = s.ringItem;
    if (ring != null) _paintRing(g, s.posOf(ring));

    // Objects standing in the Fabricator are drawn inside it.
    bool inMold(_Item item) =>
        s.held != item && _flat(s.posOf(item), _moldAt) < 1;
    final inside = <_Item>[
      if (s.clothShown && inMold(_Item.cloth)) _Item.cloth,
      if (s.glassShown && inMold(_Item.glass)) _Item.glass,
    ];
    final parts = <_Item?>[
      null, // the Fabricator
      if (s.clothShown && !inside.contains(_Item.cloth)) _Item.cloth,
      if (s.glassShown && !inside.contains(_Item.glass)) _Item.glass,
      _Item.jug,
    ];
    double depth(_Item? item) {
      if (item == null) return _camBench.depth(_moldAt + const _V(0, 1.5, 0));
      if (s.held == item) return double.negativeInfinity;
      return _camBench.depth(s.posOf(item) + const _V(0, 1, 0));
    }

    parts.sort((a, b) => depth(b).compareTo(depth(a)));
    for (final part in parts) {
      switch (part) {
        case null:
          _paintMold(g, inside, leak);
        case _Item.cloth:
          _paintCloth(g, cloth, s.grow(_Item.cloth));
        case _Item.glass:
          _paintGlassBlock(g, glass, s.grow(_Item.glass));
        default:
          _paintJug(g, jug, s.tilt.at(s.time), s.grow(_Item.jug));
      }
    }

    if (!showLabels) return;
    final lifted = jug.y > 0.5 || s.tilt.at(s.time) > 0.01;
    if (!lifted) {
      _chip(
        canvas,
        _camBench.p(_moldAt + const _V(0, 3.8, 0)),
        _t('lbl_fabricator'),
      );
    }
    if (s.clothShown && !inside.contains(_Item.cloth)) {
      _chip(
        canvas,
        _camBench.p(cloth + _V(0, 2.5 * s.grow(_Item.cloth), 0)),
        _t('lbl_cloth'),
      );
    }
    if (s.glassShown && !inside.contains(_Item.glass)) {
      _chip(
        canvas,
        _camBench.p(glass + _V(0, 2.5 * s.grow(_Item.glass), 0)),
        _t('lbl_glass'),
      );
    }
    if (!lifted) {
      _chip(
        canvas,
        _camBench.p(jug + _V(0, 3.8 * s.grow(_Item.jug), 0)),
        _t('lbl_pitcher'),
      );
    }
  }

  /// How far the leak has spread (0 … 1; 0 without a leak).
  double _leak() {
    final s = scene;
    if (s.leakAt < 0 || s.tumbler != _Tumbler.cloth) return 0;
    return ((s.time - s.leakAt) / _leakSeconds).clamp(0.0, 1.0);
  }

  /// The Fabricator: base, puddle and target ring, glass casing (back),
  /// the objects and the tumbler inside it, the water drops, the casing's
  /// front and the top ring.
  void _paintMold(_Gfx g, List<_Item> inside, double leak) {
    final s = scene;
    const m = _moldAt;
    g.cylinder(m, 2.8, 2.5, _baseTop, _Colors.moldBase);
    if (leak > 0) {
      g.disc(
        m.atY(_baseTop + 0.005),
        math.min(2.45, 3 * (0.1 + 1.4 * leak)),
        _Colors.water.withValues(alpha: 0.6),
      );
    }
    g.ring(m.atY(_baseTop + 0.01), 1.2, 1.8, _Colors.moldTarget);
    final casing = m.atY(_baseTop);
    g.glassBack(casing, 2.2, 2.2, 2.5, body: 0.05);
    for (final item in inside) {
      if (item == _Item.cloth) {
        _paintCloth(g, s.cloth.at(s.time), 1);
      } else {
        _paintGlassBlock(g, s.glass.at(s.time), 1);
      }
    }
    _paintTumbler(g);
    g.glassFront(casing, 2.2, 2.2, 2.5);
    g.torus(m.atY(2.9), 2.2, 0.15, _Colors.moldTop, _V.right, _V.front);
  }

  /// The tumbler (pop-in: `scale.y` 0.1 → 1, Bounce.Out, 400 ms, about its
  /// centre at y 1.65) and the water drops falling into it. The cloth one
  /// slumps when it leaks (`scale` → (1.4, 0.3, 1.4), centre → y 0.8); the
  /// glass one fills (`filledWater.scale.y` 0.01 → 1).
  void _paintTumbler(_Gfx g) {
    final s = scene;
    var rim = double.infinity; // drops below the cloth's rim are hidden
    if (s.tumbler != _Tumbler.none) {
      final pop = ((s.time - s.moldedAt) / _moldSeconds).clamp(0.0, 1.0);
      final grow = 0.1 + 0.9 * Curves.bounceOut.transform(pop);
      if (s.tumbler == _Tumbler.cloth) {
        final e = _leak();
        final sy = grow * (1 - 0.7 * e);
        final sx = 1 + 0.4 * e;
        final cy = _tumblerY + (0.8 - _tumblerY) * e;
        final h = _tumblerH * sy;
        final base = _moldAt.atY(cy - h / 2);
        g.cylinder(
          base,
          0.9 * sx,
          1.2 * sx,
          h,
          _Colors.cloth1,
          capColor: labShade(_Colors.cloth3, -0.35),
        );
        rim = base.y + h;
      } else {
        final h = _tumblerH * grow;
        final base = _moldAt.atY(_tumblerY - h / 2);
        g.glassBack(base, 0.9, 1.2, h, body: 0.1);
        if (s.fillAt >= 0) {
          final f = ((s.time - s.fillAt) / _fillSeconds).clamp(0.0, 1.0);
          g.cylinder(
            _moldAt.atY(0.45),
            0.88,
            1.15,
            2.2 * (0.01 + 0.99 * f),
            _Colors.water,
            opacity: 0.8,
          );
        }
        _paintDrops(g, rim);
        g.glassFront(base, 0.9, 1.2, h);
        return;
      }
    }
    _paintDrops(g, rim);
  }

  /// HTML `waterTraces`: falling drops (radius 0.12, stretched 1–3x).
  void _paintDrops(_Gfx g, double rim) {
    final s = scene;
    if (s.pourAt < 0) return;
    final paint = _pens.fill..color = _Colors.water.withValues(alpha: 0.85);
    for (final d in s.drops) {
      if (!d.live) continue;
      final p = d.at(s.time);
      if (p.y < rim) continue;
      final k = g.cam.scaleAt(p);
      g.canvas.drawOval(
        Rect.fromCenter(
          center: g.cam.p(p),
          width: 2 * _dropRadius * k,
          height: 2 * _dropRadius * k * d.stretch,
        ),
        paint,
      );
    }
  }

  /// `meshes.cloth`: three 2 x 0.4 x 2 layers, slightly askew (the HTML
  /// turned each by a random angle up to ±0.15 rad).
  void _paintCloth(_Gfx g, _V p, double k) {
    const layers = [
      (_Colors.cloth1, 0.08),
      (_Colors.cloth2, -0.11),
      (_Colors.cloth3, 0.05),
    ];
    for (var i = 0; i < layers.length; i++) {
      final (color, yaw) = layers[i];
      g.box(
        p + _V(0, (0.2 + i * 0.42) * k, 0),
        _V(2 * k, 0.4 * k, 2 * k),
        color,
        yaw: yaw,
        edge: 0.3,
      );
    }
  }

  /// `meshes.glass`: a 1.8 cube of clear glass (0xe0f2fe).
  void _paintGlassBlock(_Gfx g, _V p, double k) {
    g.box(
      p + _V(0, 0.9 * k, 0),
      _V(1.8 * k, 1.8 * k, 1.8 * k),
      _Colors.glassBlock,
      opacity: 0.5,
      edgeColor: _Colors.white.withValues(alpha: 0.8),
    );
  }

  /// `meshes.jug`: glass body `CylinderGeometry(1.2, 1, 3)`, water inside
  /// (0.95 → 1.1, 2.5 high), the handle `TorusGeometry(0.8, 0.15)` on its
  /// +x side; the group turns by [tilt] about z at its base.
  void _paintJug(_Gfx g, _V p, double tilt, double k) {
    final c = math.cos(tilt), sn = math.sin(tilt);
    final axis = _V(-sn, c, 0);
    final ex = _V(c, sn, 0);
    _V local(double x, double y) => p + ex * (x * k) + axis * (y * k);
    g.torus(local(1.2, 1.5), 0.8 * k, 0.15 * k, _Colors.handle, ex, axis);
    g.glassBack(p, 1.0 * k, 1.2 * k, 3 * k, axis: axis, ex: ex, body: 0.1);
    g.cylinder(
      local(0, 0.05),
      0.95 * k,
      1.1 * k,
      2.5 * k,
      _Colors.water,
      axis: axis,
      ex: ex,
      opacity: 0.85,
    );
    g.glassFront(p, 1.0 * k, 1.2 * k, 3 * k, axis: axis, ex: ex);
  }

  // ------------------------------------------------------------ labels

  /// HTML `createTextSprite`: a rounded chip with white bold text centred
  /// on [at], kept left of the tool column.
  void _chip(Canvas canvas, Offset at, String text, {Color? background}) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final w = tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final minX = w / 2 + 4;
    final cx = at.dx
        .clamp(minX, math.max(minX, labelRight - w / 2 - 4))
        .toDouble();
    final rect = Rect.fromCenter(
      center: Offset(cx, at.dy),
      width: w,
      height: h,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size * 0.5)),
      _pens.fill..color = background ?? _Colors.labelBg,
    );
    tp.paint(canvas, Offset(rect.left + padX, rect.top + padY));
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
