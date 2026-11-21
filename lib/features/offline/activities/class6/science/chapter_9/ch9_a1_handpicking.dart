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

/// Class 6 Science • Chapter 9 • Activity 1
/// Handpicking (Separating by Sight).
///
/// Native Flutter port of `Cl6S-Ch9-A1-Handpicking.html`.
///
/// Scenario 1 (Cleaning Grains for Nani): drag the four grey stones, one by
/// one, from the bowl of wheat into the empty discard bowl, then the four
/// flaky brown husk pieces; look at the clean wheat and tap 'Finish
/// Observation'.
///
/// Scenario 2 (Malli's Pulao Plate): drag the six whole black peppercorns,
/// one by one, out of the pulao onto the glowing edge of the plate (three,
/// then the remaining three), then tap 'Finish Observation'.
class Ch9A1HandpickingPage extends StatefulWidget {
  const Ch9A1HandpickingPage({super.key});

  @override
  State<Ch9A1HandpickingPage> createState() => _HandpickingLabState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesised three WebAudio tones; they map
/// to: `click` (a piece picked up) → pickup.mp3, `snap` (a piece dropped in
/// the right place) → drop.mp3, `ding` (Finish Observation) → success.mp3.
/// A piece dropped in the wrong place goes back with error.mp3 (the HTML
/// played its click).
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

  /// Positive feedback toast.
  correct('audio/class6/science/correct.mp3'),

  /// A piece dropped in the wrong place, a piece that is not picked yet.
  wrong('audio/class6/science/error.mp3'),

  /// HTML `playSound('ding')`: Finish Observation and the summary.
  success('audio/class6/math/success.mp3'),

  /// Scenario changed.
  scenario('audio/class6/science/page_open.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('audio/class6/science/curtain.mp3'),

  /// HTML `playSound('snap')`: a piece dropped into the discard bowl or on
  /// the edge of the plate.
  drop('audio/class6/science/drop.mp3'),

  /// HTML `playSound('click')` in `startDrag`: a piece picked up.
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
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- scene
  /// `scene.background`: 0x0f172a (dark theme) / 0xf8fafc (light theme).
  static const Color sceneDark = Color(0xFF0F172A);
  static const Color sceneLight = Color(0xFFF8FAFC);

  /// `tableMat` 0x334155.
  static const Color table = Color(0xFF334155);

  /// `mixBowlOuter` / `mixBowlRim` (the clay bowl of wheat).
  static const Color mixOuter = Color(0xFFB45309);
  static const Color mixRim = Color(0xFF78350F);

  /// `discardBowlOuter` / `discardBowlRim` (the teal discard bowl).
  static const Color discardOuter = Color(0xFF0F766E);
  static const Color discardRim = Color(0xFF115E59);

  /// `mixBowlInner`, `discardBowlInner`, `plateInner`: 0xfffbeb.
  static const Color cream = Color(0xFFFFFBEB);

  /// `plateOuter` 0xa8a29e and `plateBorder` 0x4f46e5.
  static const Color plateOuter = Color(0xFFA8A29E);
  static const Color plateBorder = Color(0xFF4F46E5);

  /// `wheatMat`, `stoneMat`, `huskMat`.
  static const Color wheat = Color(0xFFD97706);
  static const Color stone = Color(0xFF64748B);
  static const Color husk = Color(0xFFA16207);

  /// `riceMat`, `peaMat`, `carrotMat`, `pepperMat`.
  static const Color rice = Color(0xFFFEF08A);
  static const Color pea = Color(0xFF22C55E);
  static const Color carrot = Color(0xFFF97316);
  static const Color pepper = Color(0xFF0F172A);

  /// `glowMat` (0x6366f1, opacity 0.35): the discard bowl's drop zone.
  static const Color dropGlow = Color(0x596366F1);

  /// `plateEdgeZoneS2` (0x10b981, opacity 0.55): the plate's glowing edge.
  static const Color edgeGlow = Color(0x8C10B981);

  /// Halo round the piece being dragged.
  static const Color heldGlow = Color(0x806366F1);

  /// Soft contact shadows.
  static const Color shadow = Color(0x59000000);

  /// `.label-3d` chips: glass panel (slate-900/92 or white/95) with an
  /// indigo-400 border.
  static const Color labelBgDark = Color(0xEB0F172A);
  static const Color labelBgLight = Color(0xF2FFFFFF);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950,
    panel: Color(0xEB0F172A), // glass-bg rgba(15, 23, 42, 0.92)
    border: Color(0x26FFFFFF), // glass-border white / 15
    card: Color(0xCC1E293B), // slate-800 / 80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.sceneDark,
    text: _Colors.slate300,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald500,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: _Colors.slate900,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81), // indigo-900 / 40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC), // indigo-300 / 80
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: Color(0x996366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgDark,
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF), // glass-bg rgba(255, 255, 255, 0.95)
    border: Color(0x26000000), // glass-border black / 15
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.sceneLight,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.indigo500,
    onAccent: _Colors.white,
    primary: _Colors.indigo600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red600,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: _Colors.slate800,
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x66312E81),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCCA5B4FC),
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xE60F172A),
    buttonIcon: _Colors.indigo400,
    buttonBorder: Color(0x996366F1),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.labelBgLight,
    labelText: _Colors.slate800,
  );
}

// ====================================================================== FONT

/// This lab's font. A `null` family uses the platform font, which includes
/// Devanagari for Hindi (the HTML's Plus Jakarta Sans is a web font). Sizes
/// are the HTML sidebar font-size slider: 15 px, 12–22 px.
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
// From the HTML `i18n` and `ScenariosData` tables (Telugu dropped). Each
// step keeps the HTML concept (c) and observation (o); its action (a) says
// exactly what to drag or tap ("one by one", "then tap 'Finish
// Observation'", the button the HTML showed at step 3). The HUD lines
// (`sN_hud_M`) are the HTML's, with "CLICK and DRAG" / "click" made touch
// words. Hindi follows the English where the HTML Hindi was shortened or
// wrong (it called the grey stones भूरे, brown). Keys marked "added" are new
// texts the HTML did not have.

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Handpicking (Separating by Sight)',
    'app_subtitle': 'Class 6 • Methods of Separation in Everyday Life',
    'sc1_title': 'Scenario 1: Cleaning Grains for Nani',
    'sc2_title': "Scenario 2: Malli's Pulao Plate",
    'sc1_obj':
        "To help Malli and Valli's family by separating the small stones and husk from a pile of wheat grains, just like they saw in Haryana.",
    'sc2_obj':
        'To separate the whole black peppers from a plate of vegetable pulao, just like Malli did at lunchtime.',
    // Scenario 1 steps.
    's1_c1': 'Remove Stones',
    's1_a1':
        'Drag the 4 grey stones, one by one, from the grain bowl into the empty Discard bowl on the right.',
    's1_o1':
        'Stones have a distinct grey color and irregular shape, making them easy to identify and pick out.',
    's1_c2': 'Remove Husk',
    's1_a2':
        'Drag the 4 flaky brown husk pieces, one by one, into the Discard bowl.',
    's1_o2':
        'The larger husk flakes are lighter and brownish compared to the golden wheat grains.',
    's1_c3': 'Clean Wheat',
    's1_a3':
        "Observe the clean wheat bowl free of impurities, then tap 'Finish Observation'.",
    's1_o3':
        'You just used Handpicking! It works because stones and husk have different size, shape, and color from the grains.',
    // Scenario 2 steps.
    's2_c1': 'Identify Peppers',
    's2_a1':
        'Drag 3 whole black peppercorns, one by one, from the pulao to the glowing edge of the plate.',
    's2_o1':
        'Round, black peppercorns clearly stand out against yellowish rice and green peas.',
    's2_c2': 'Complete Separation',
    's2_a2':
        'Drag the remaining 3 peppercorns, one by one, to the glowing edge of the plate.',
    's2_o2':
        'As each peppercorn is moved, the pulao becomes ready and pleasant to eat.',
    's2_c3': 'Conclusion',
    's2_a3': "Review the handpicking concept, then tap 'Finish Observation'.",
    's2_o3':
        'Handpicking is very convenient when unwanted items are easily visible and present in small quantities.',
    // HUD "Current Task" lines (HTML `hud`).
    's1_hud_1':
        'Step 1: Drag the unwanted grey stones from the mixture bowl into the empty Discard bowl.',
    's1_hud_2':
        'Step 2: Drag the flaky brown husk pieces from the wheat bowl into the Discard bowl.',
    's1_hud_3':
        'Step 3: Observation complete! Review the clean wheat grains and tap Finish Observation.',
    's2_hud_1':
        'Step 1: Drag the first few whole black peppercorns from the pulao onto the empty rim of the plate.',
    's2_hud_2':
        'Step 2: Continue dragging all remaining whole black peppercorns to the side of the plate.',
    's2_hud_3':
        'Step 3: All peppers separated! Tap Finish Observation and read the summary.',
    // Conclusions (HTML `summary`).
    'sc_complete': 'Scenario {n} Complete!',
    's1_sum_title': 'Well Done!',
    's1_sum':
        'You just used Handpicking! It works because the stones and husk have a different size, color, and shape from the grains, making them easy to pick out by hand.',
    's2_sum_title': 'Nice one!',
    's2_sum':
        'This is also Handpicking! This method is very convenient when the items you want to remove are easily visible and are present in small quantities.',
    'btn_finish': 'Finish Observation',
    // 3D labels.
    'lbl_mix_bowl': 'Mixture Bowl',
    'lbl_discard_bowl': 'Discard Bowl',
    'lbl_pulao_plate': 'Pulao Plate',
    'lbl_edge_zone': 'Plate Edge',
    // Counters (HTML `cnt_*`; the HTML had no element to show them in).
    'cnt_stones': 'Stones Removed: {c} / 4',
    'cnt_husk': 'Husk Pieces Removed: {c} / 4',
    'cnt_ready': 'Clean Wheat Ready!',
    'cnt_peppers': 'Peppers Separated: {c} / 6',
    // Teacher-board accordion.
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    // Added.
    'obs_pending': 'The result appears once you complete this step.',
    'toast_drop_bowl': 'Drop it into the Discard bowl.',
    'toast_drop_edge': 'Put it on the glowing edge of the plate.',
    'toast_stones_first': 'Pick out the grey stones first.',
    'scene_s1':
        'A bowl of wheat mixed with small stones and husk, and an empty discard bowl',
    'scene_s2': 'A plate of vegetable pulao with whole black peppercorns',
  },
  'hi': {
    'app_title': 'हाथ से चुनना (हस्तचयन)',
    'app_subtitle': 'कक्षा 6 • दैनिक जीवन में पृथक्करण की विधियाँ',
    'sc1_title': 'परिदृश्य 1: नानी के लिए अनाज साफ करना',
    'sc2_title': 'परिदृश्य 2: मल्ली की पुलाव की प्लेट',
    'sc1_obj':
        'मल्ली और वल्ली के परिवार की मदद करना: गेहूँ के दानों के ढेर से छोटे कंकड़ और भूसी को हाथ से चुनकर अलग करना, जैसा उन्होंने हरियाणा में देखा था।',
    'sc2_obj':
        'सब्ज़ी पुलाव की प्लेट से साबुत काली मिर्च को हाथ से चुनकर अलग करना, जैसा मल्ली ने दोपहर के भोजन के समय किया था।',
    's1_c1': 'कंकड़ हटाएँ',
    's1_a1':
        '4 स्लेटी कंकड़ों को एक-एक करके अनाज के कटोरे से खींचकर दाईं ओर के खाली त्यागने वाले कटोरे में डालें।',
    's1_o1':
        'कंकड़ों का स्लेटी रंग और अनियमित आकार अलग दिखता है, इसलिए उन्हें पहचानकर चुनना आसान है।',
    's1_c2': 'भूसी हटाएँ',
    's1_a2':
        'भूसी के 4 पतले भूरे टुकड़ों को एक-एक करके खींचकर त्यागने वाले कटोरे में डालें।',
    's1_o2':
        'भूसी के बड़े टुकड़े सुनहरे गेहूँ के दानों की तुलना में हल्के और भूरे रंग के होते हैं।',
    's1_c3': 'साफ गेहूँ',
    's1_a3':
        "अशुद्धियों से मुक्त साफ गेहूँ के कटोरे का अवलोकन करें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's1_o3':
        'आपने अभी हस्तचयन का उपयोग किया! यह इसलिए काम करता है क्योंकि कंकड़ और भूसी का आकार, रूप और रंग अनाज के दानों से अलग होता है।',
    's2_c1': 'काली मिर्च पहचानें',
    's2_a1':
        'पुलाव से 3 साबुत काली मिर्चों को एक-एक करके खींचकर प्लेट के चमकते किनारे पर रखें।',
    's2_o1':
        'गोल, काली मिर्च के दाने पीले चावल और हरी मटर के बीच साफ अलग दिखाई देते हैं।',
    's2_c2': 'पृथक्करण पूरा करें',
    's2_a2':
        'बची हुई 3 काली मिर्चों को भी एक-एक करके खींचकर प्लेट के चमकते किनारे पर रखें।',
    's2_o2':
        'हर काली मिर्च के हटने के साथ पुलाव खाने के लिए तैयार और अच्छा होता जाता है।',
    's2_c3': 'निष्कर्ष',
    's2_a3':
        "हस्तचयन की अवधारणा को समझें, फिर 'अवलोकन समाप्त करें' पर टैप करें।",
    's2_o3':
        'हस्तचयन तब बहुत सुविधाजनक होता है जब अवांछित वस्तुएँ आसानी से दिखाई दें और कम मात्रा में हों।',
    's1_hud_1':
        'चरण 1: मिश्रण के कटोरे से अनचाहे स्लेटी कंकड़ों को खींचकर खाली त्यागने वाले कटोरे में डालें।',
    's1_hud_2':
        'चरण 2: भूसी के पतले भूरे टुकड़ों को गेहूँ के कटोरे से खींचकर त्यागने वाले कटोरे में डालें।',
    's1_hud_3':
        'चरण 3: अवलोकन पूर्ण! साफ गेहूँ के दाने देखें और अवलोकन समाप्त करें पर टैप करें।',
    's2_hud_1':
        'चरण 1: पुलाव से पहली कुछ साबुत काली मिर्चों को खींचकर प्लेट के खाली किनारे पर रखें।',
    's2_hud_2':
        'चरण 2: बची हुई सभी साबुत काली मिर्चों को भी खींचकर प्लेट के किनारे पर रखें।',
    's2_hud_3':
        'चरण 3: सभी काली मिर्चें अलग हो गईं! अवलोकन समाप्त करें पर टैप करें और सारांश पढ़ें।',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_sum_title': 'बहुत बढ़िया!',
    's1_sum':
        'आपने हस्तचयन का उपयोग किया! कंकड़ और भूसी का आकार, रंग और रूप गेहूँ के दानों से अलग होता है, इसलिए उन्हें आसानी से हाथ से चुनकर अलग किया जा सकता है।',
    's2_sum_title': 'शाबाश!',
    's2_sum':
        'यह भी हस्तचयन है! यह विधि तब बहुत सुविधाजनक होती है जब हटाई जाने वाली वस्तुएँ आसानी से दिखाई दें और कम मात्रा में हों।',
    'btn_finish': 'अवलोकन समाप्त करें',
    'lbl_mix_bowl': 'मिश्रण का कटोरा',
    'lbl_discard_bowl': 'त्यागने वाला कटोरा',
    'lbl_pulao_plate': 'पुलाव की प्लेट',
    'lbl_edge_zone': 'प्लेट का किनारा',
    'cnt_stones': 'कंकड़ हटाए गए: {c} / 4',
    'cnt_husk': 'भूसी के टुकड़े हटाए गए: {c} / 4',
    'cnt_ready': 'साफ गेहूँ तैयार!',
    'cnt_peppers': 'अलग की गईं काली मिर्चें: {c} / 6',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'यह चरण पूरा करने पर परिणाम दिखेगा।',
    'toast_drop_bowl': 'इसे त्यागने वाले कटोरे में डालें।',
    'toast_drop_edge': 'इसे प्लेट के चमकते किनारे पर रखें।',
    'toast_stones_first': 'पहले स्लेटी कंकड़ों को चुनकर निकालें।',
    'scene_s1':
        'छोटे कंकड़ और भूसी मिले गेहूँ का कटोरा और एक खाली त्यागने वाला कटोरा',
    'scene_s2': 'साबुत काली मिर्च वाली सब्ज़ी पुलाव की प्लेट',
  },
};

/// Number of steps of each scenario (HTML `ScenariosData[n].steps`).
const List<int> _stepCounts = [3, 3];

/// The two scenarios for [lang], built from the string table.
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _stepCounts.length; n++)
      LabScenarioData(
        title: t('sc${n}_title'),
        objective: t('sc${n}_obj'),
        steps: [
          for (var i = 1; i <= _stepCounts[n - 1]; i++)
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

/// HTML `resetCamera()` (screens wider than 768 px): `camera.position.set(0,
/// 14, 20)` and `controls.target.set(0, 2, 0)`, for both scenarios.
const _V _eye = _V(0, 14, 20);
const _V _lookAt = _V(0, 2, 0);

/// The look-at point is drawn 30 px above the stage centre (a lens shift),
/// so the front of the pulao plate stays clear of the HUD chip.
const Offset _lookAtOnStage = Offset(500, 250);

/// Half of a 48 dp touch target, in screen pixels.
const double _touchDp = 24;

/// Pan slop for grabbing a piece (short drags must pick it up).
const double _dragSlop = 8;

/// Object labels: 12 design px, enlarged up to 1.8x on small stages so the
/// HTML's 10 px chips stay readable.
const double _labelPx = 12;
const double _labelFullScale = 0.85;
const double _labelMaxBoost = 1.8;

/// While the sidebar is collapsed the scene slides right (as far as the
/// tool column allows) and [_collapsedDrop] design px down, so the floating
/// mission card at the top left never covers a piece to pick up. (The HUD
/// chip at the bottom is hidden while the sidebar is collapsed.)
const double _collapsedDrop = 45;
const double _cardGap = 8;

/// The slide runs with the sidebar (380 ms).
const Duration _panDuration = Duration(milliseconds: 380);

/// Key of the sliding scene layer. Flows map scene design coordinates to
/// the screen through it, so they follow the slide.
const ValueKey<String> _sceneKey = ValueKey('ch9-a1-scene');

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

  /// Where the ray through [s] meets the horizontal plane at height [y]
  /// (HTML `raycaster.ray.intersectPlane(dragPlane, …)`), or null when it
  /// points away from it.
  _V? onPlaneY(Offset s, double y) {
    final dir = ray(s);
    if (dir.y.abs() < 1e-6) return null;
    final t = (y - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}

/// The one camera of both scenarios.
final _Cam _cam = _Cam(_eye, _lookAt, _lookAtOnStage);

// ------------------------------------------------------------- the table

/// `new THREE.BoxGeometry(36, 1.5, 20)` with its top at y = 0.
const double _tableHalfX = 18;
const double _tableHalfZ = 10;
const double _tableThickness = 1.5;

/// Every bowl and the plate stand at y = 0.1 (`position.set(…, 0.1, …)`).
const double _baseY = 0.1;

/// One bowl of `buildScenario1Scene()`: an open truncated cone (outer and
/// inner wall), a rim ring on top and a flat floor inside.
@immutable
class _Bowl {
  const _Bowl({
    required this.x,
    required this.height,
    required this.outerTop,
    required this.outerBottom,
    required this.innerTop,
    required this.floor,
    required this.outer,
    required this.rim,
  });

  /// Centre x (z = 0).
  final double x;

  /// Rim height above [_baseY].
  final double height;
  final double outerTop;
  final double outerBottom;
  final double innerTop;

  /// Radius of the floor circle (`CircleGeometry`) at [_floorY].
  final double floor;
  final Color outer;
  final Color rim;

  double get rimY => _baseY + height;
}

/// Bowl floors: `floor.position.y = 0.31` inside the group at y = 0.1.
const double _floorY = 0.41;

/// `mixBowlS1`: outer `CylinderGeometry(5.0, 3.6, 2.5)`, inner (4.6, 3.3,
/// 2.4), rim ring 4.6–5.0 at 2.5, floor r 3.3; at (-6, 0.1, 0).
const _Bowl _mixBowl = _Bowl(
  x: -6,
  height: 2.5,
  outerTop: 5.0,
  outerBottom: 3.6,
  innerTop: 4.6,
  floor: 3.3,
  outer: _Colors.mixOuter,
  rim: _Colors.mixRim,
);

/// `discardBowlS1`: outer `CylinderGeometry(4.5, 3.2, 2.2)`, inner (4.1,
/// 2.9, 2.1), rim ring 4.1–4.5 at 2.2, floor r 2.9; at (6, 0.1, 0).
const _Bowl _discardBowl = _Bowl(
  x: 6,
  height: 2.2,
  outerTop: 4.5,
  outerBottom: 3.2,
  innerTop: 4.1,
  floor: 2.9,
  outer: _Colors.discardOuter,
  rim: _Colors.discardRim,
);

/// `discardBowlZoneS1`: `RingGeometry(2.8, 4.1)` at y = 2.22 (steps 1–2).
const double _dropZoneInner = 2.8;
const double _dropZoneOuter = 4.1;
const double _dropZoneY = 2.22;

/// `checkDrop()`: a piece released within 5.2 (xz) of the discard bowl's
/// centre goes in.
const double _discardCatch = 5.2;

// ------------------------------------------------------------- the plate

/// `pulaoPlateS2` at the origin: base `CylinderGeometry(8.5, 7.5, 0.6)`,
/// surface circle r 7.2, rim ring 7.2–8.2 and the indigo border ring
/// 8.2–8.55, all on top at y ≈ 0.71.
const double _plateTopR = 8.5;
const double _plateBottomR = 7.5;
const double _plateTopY = 0.7;
const double _plateSurfaceR = 7.2;
const double _plateRimR = 8.2;
const double _plateBorderR = 8.55;
const double _plateSurfaceY = 0.715;

/// `plateEdgeZoneS2`: `RingGeometry(5.2, 8.3)`, the plate's glowing edge
/// (steps 1–2). The HTML put it at y = 0.625, under the plate's top where
/// it could not be seen; here it lies on the plate.
const double _edgeZoneInner = 5.2;
const double _edgeZoneOuter = 8.3;

/// `checkDrop()`: a peppercorn counts as moved out of the pulao from 4.2
/// (xz) from the centre; here it must also stay on the plate (the HTML
/// accepted a peppercorn dropped anywhere on the table).
const double _edgeCatchInner = 4.2;
const double _edgeCatchOuter = _plateBorderR;

/// A peppercorn put down this far out lies on the bare plate; nearer the
/// middle it rests on the rice (the HTML sank it into the plate at 0.65).
const double _bareRimFrom = 5;

// ------------------------------------------------------------- the pieces

/// The three kinds of piece the learner picks out.
enum _Kind {
  /// `DodecahedronGeometry(0.55, 1)`, #64748b, resting at y = 2.2.
  stone(0.55, 2.2),

  /// `BoxGeometry(0.8, 0.15, 0.5)`, #a16207, resting at y = 2.3 (its hit
  /// radius is about half its length).
  husk(0.42, 2.3),

  /// `SphereGeometry(0.4)`, #0f172a, resting at y = 1.4.
  pepper(0.4, 1.4);

  const _Kind(this.radius, this.restY);

  final double radius;
  final double restY;
}

/// Where the 4 stones and the 4 husk pieces lie on the wheat (x, z). The
/// HTML scattered them at random (`-6 + (Math.random() - 0.5) * 4`), which
/// could stack two on top of each other; these fixed, spread-out places keep
/// every piece in sight and reachable by touch.
const List<(double, double)> _stoneSpots = [
  (-8.5, -1.0),
  (-4.6, -2.3),
  (-3.6, 1.3),
  (-6.9, 2.0),
];
const List<(double, double)> _huskSpots = [
  (-6.7, -2.6),
  (-3.1, -0.7),
  (-5.4, 0.2),
  (-8.8, 1.5),
];

/// HTML husk `rotation.set(rand, rand * π, rand)`: yaw, tilt about x and
/// about z of each husk flake (gentle tilts, so the flakes lie on the
/// wheat).
const List<(double, double, double)> _huskTurns = [
  (0.4, 0.25, 0.35),
  (1.9, 0.4, 0.1),
  (2.8, 0.15, 0.45),
  (1.1, 0.5, 0.2),
];

/// The six peppercorns in the pulao (x, z), spread out like the stones.
const List<(double, double)> _pepperSpots = [
  (-2.6, -1.0),
  (0.4, -2.6),
  (2.7, -0.6),
  (1.6, 2.0),
  (-1.4, 2.2),
  (0.0, 0.2),
];

/// Resting places on the discard bowl's floor (x, z): stones first, then
/// husk. The HTML left them floating at y = 1.5–2.0 above the floor.
const List<(double, double)> _discardSpots = [
  (4.9, -0.7),
  (6.9, -1.0),
  (7.2, 0.8),
  (5.2, 1.0),
  (6.1, -0.1),
  (4.3, 0.3),
  (7.9, -0.1),
  (6.3, 1.8),
];

/// Centre heights above the discard bowl's floor: a stone resting on its
/// rounded side (0.85 of its radius) and a flake lying flat (half its 0.15
/// thickness).
const double _stoneRestLift = 0.47;
const double _huskHalfThickness = 0.075;

/// Tops of the wheat pile and of the rice, where a lifted piece's shadow
/// falls.
const double _wheatTopY = 1.9;
const double _riceTopY = 1.2;

/// HTML `position.y = 3.5` while a piece is dragged.
const double _liftY = 3.5;

/// HTML tweens: into place 300 ms, back home 400 ms (Quadratic.Out).
const double _placeSeconds = 0.3;
const double _returnSeconds = 0.4;

/// A dragged piece stays over the table.
const double _dragHalfX = _tableHalfX - 1;
const double _dragHalfZ = _tableHalfZ - 0.5;

/// One stone, husk flake or peppercorn.
class _Piece {
  _Piece(this.kind, this.index, this.home) : pos = home;

  final _Kind kind;

  /// Number within its kind (picks its shape and turn).
  final int index;
  final _V home;
  _V pos;

  /// HTML `userData.placed`: in the discard bowl / on the edge of the plate.
  bool placed = false;

  /// Being dragged (lifted to [_liftY]).
  bool held = false;

  _V _from = _V.zero;
  _V _to = _V.zero;
  double _start = -1;
  double _seconds = 1;

  bool get moving => _start >= 0;

  /// HTML `new TWEEN.Tween(position).to(…).easing(Quadratic.Out)`.
  void glide(_V to, double now, double seconds) {
    _from = pos;
    _to = to;
    _start = now;
    _seconds = seconds;
  }

  void stop() => _start = -1;

  void advance(double now) {
    if (_start < 0) return;
    final t = ((now - _start) / _seconds).clamp(0.0, 1.0);
    pos = _V.lerp(_from, _to, Curves.easeOutQuad.transform(t));
    if (t >= 1) _start = -1;
  }
}

/// Mutable scene read by the painter every frame.
class _Scene {
  double time = 0;
  int scenario = 0;

  /// Bumped on every load, so late callbacks of an old load are ignored.
  int epoch = 0;

  /// 1-based step; [_stepCounts] + 1 once Finish Observation was tapped.
  int step = 1;
  bool concluded = false;

  /// HTML `State.stonesRemoved` / `huskRemoved` / `peppersRemoved`.
  int stonesRemoved = 0;
  int huskRemoved = 0;
  int peppersRemoved = 0;

  final List<_Piece> pieces = [];

  /// The HTML drop zones glow during steps 1 and 2.
  bool get zoneVisible => step <= 2;

  /// HTML `changeScenario(sc)` → `resetScenarioState(sc)`.
  void load(int index) {
    scenario = index;
    epoch++;
    step = 1;
    concluded = false;
    stonesRemoved = 0;
    huskRemoved = 0;
    peppersRemoved = 0;
    pieces.clear();
    if (index == 0) {
      for (var i = 0; i < _stoneSpots.length; i++) {
        final (x, z) = _stoneSpots[i];
        pieces.add(_Piece(_Kind.stone, i, _V(x, _Kind.stone.restY, z)));
      }
      for (var i = 0; i < _huskSpots.length; i++) {
        final (x, z) = _huskSpots[i];
        pieces.add(_Piece(_Kind.husk, i, _V(x, _Kind.husk.restY, z)));
      }
    } else {
      for (var i = 0; i < _pepperSpots.length; i++) {
        final (x, z) = _pepperSpots[i];
        pieces.add(_Piece(_Kind.pepper, i, _V(x, _Kind.pepper.restY, z)));
      }
    }
  }

  /// Design-space point of world (x, y, z) (used by the flow tests).
  Offset project(double x, double y, double z) => _cam.p(_V(x, y, z));

  /// Design-space centre of piece [i] now (used by the flow tests).
  Offset pointOf(int i) => _cam.p(pieces[i].pos);
}

/// Left and right ends (design x, before the slide) of what the learner
/// works with: S1 the pieces on the wheat and the discard bowl, S2 the
/// peppercorns and the plate.
final (double, double) _s1Extent = (
  [
    for (final (x, z) in [..._stoneSpots, ..._huskSpots])
      _cam.p(_V(x, _Kind.stone.restY, z)).dx -
          _Kind.stone.radius * _cam.scaleAt(_V(x, _Kind.stone.restY, z)),
  ].reduce(math.min),
  _cam.p(_V(_discardBowl.x + _discardBowl.outerTop, _discardBowl.rimY, 0)).dx,
);
final (double, double) _s2Extent = (
  [
    for (final (x, z) in _pepperSpots)
      _cam.p(_V(x, _Kind.pepper.restY, z)).dx -
          _Kind.pepper.radius * _cam.scaleAt(_V(x, _Kind.pepper.restY, z)),
  ].reduce(math.min),
  _cam.p(const _V(_plateBorderR, _plateSurfaceY, 0)).dx,
);

/// Pan recognizer that only joins the gesture arena for pointers that land
/// on a piece the learner may pick up now ([canGrab]), so other drags still
/// pan / zoom the canvas.
class _GrabPanRecognizer extends PanGestureRecognizer {
  _GrabPanRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? canGrab;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      event is PointerDownEvent &&
      (canGrab?.call(event) ?? false);
}

class _HandpickingLabState extends State<Ch9A1HandpickingPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final _PaintCache _cache = _PaintCache();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final Map<LabLang, List<LabScenarioData>> _data = {};
  late final Ticker _ticker;

  /// Touch radius and label size in design pixels for the current stage
  /// scale (set while laying out the stage).
  double _touch = _touchDp;
  double _labelSize = _labelPx;

  /// Slide of the scene layer in design px (zero while the sidebar is open).
  Offset _shift = Offset.zero;

  /// The drag in progress: the piece, the load it started in, the drag
  /// plane's height and the grab offset (plane hit minus the piece's
  /// position, HTML `dragOffset`).
  _Piece? _held;
  int _grabEpoch = -1;
  double _planeY = 0;
  _V _grabOffset = _V.zero;
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

  /// HTML `animate()` + `TWEEN.update()`: moves the gliding pieces, then one
  /// repaint of the canvas.
  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _scene.time = now;
    for (final p in _scene.pieces) {
      p.advance(now);
    }
    _frame.value = now;
  }

  // ----------------------------------------------------------- scenarios

  /// HTML `changeScenario(sc)`: clears timers and tweens, puts every piece
  /// back and starts at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    setState(() {
      _scene.load(index);
      _held = null;
      _grabEpoch = -1;
      _moved = false;
    });
    _lab.resetView(sound: false);
  }

  /// HTML `triggerMainAction()`: the summary modal, through the shell's
  /// conclusion popup.
  void _conclude(int scenario) {
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: _stepCounts.length,
      delay: Duration.zero,
      title: () => labFormat(_t('sc_complete'), {'n': scenario + 1}),
      heading: () => _t('s${scenario + 1}_sum_title'),
      body: () => _t('s${scenario + 1}_sum'),
    );
  }

  /// "Finish Observation" (HTML `#btn-action-main`, step 3): the summary;
  /// tapped again later it re-opens it.
  void _onFinish() {
    final s = _scene;
    if (s.step < _stepCounts[s.scenario]) return;
    if (!s.concluded) {
      setState(() {
        s
          ..concluded = true
          ..step = _stepCounts[s.scenario] + 1;
      });
    }
    _conclude(s.scenario);
  }

  // -------------------------------------------------------------- gestures

  /// May [p] be picked up now? (HTML `draggableList`: the stones in step 1,
  /// the husk in step 2, the peppercorns in steps 1–2.)
  bool _canMove(_Piece p) {
    if (p.placed) return false;
    final s = _scene;
    if (s.scenario == 0) {
      return (s.step == 1 && p.kind == _Kind.stone) ||
          (s.step == 2 && p.kind == _Kind.husk);
    }
    return s.step <= 2;
  }

  /// Distance from [at] to [p]'s centre and its drawn radius (design px).
  (double, double) _reach(_Piece p, Offset at) =>
      ((at - _cam.p(p.pos)).distance, p.kind.radius * _cam.scaleAt(p.pos));

  /// A piece that may not be picked up yet lying right under [at].
  _Piece? _blockerAt(Offset at) {
    for (final p in _scene.pieces) {
      if (p.placed || _canMove(p)) continue;
      final (d, r) = _reach(p, at);
      if (d <= r * 1.15) return p;
    }
    return null;
  }

  /// HTML `onPointerDown` raycast: the nearest piece that may be moved now
  /// within a 48 dp touch of [at]. A touch right on a piece that may not be
  /// moved yet (a husk flake during step 1) picks nothing up, even when a
  /// stone is within reach. (The HTML grabbed the nearest movable piece up
  /// to 6–8 units from the touch, so a touch anywhere on the wheat picked a
  /// stone; here the learner has to find it.)
  _Piece? _pick(Offset at) {
    _Piece? best;
    var bestD = double.infinity;
    var bestR = 0.0;
    for (final p in _scene.pieces) {
      if (!_canMove(p)) continue;
      final (d, r) = _reach(p, at);
      if (d <= math.max(r, _touch) && d < bestD) {
        best = p;
        bestD = d;
        bestR = r;
      }
    }
    if (best != null && bestD > bestR && _blockerAt(at) != null) return null;
    return best;
  }

  bool _canGrab(PointerDownEvent event) {
    if (!_lab.isLabActive || _held != null) return false;
    return _pick(event.localPosition) != null;
  }

  /// A touch on a husk flake while the stones are still to be picked out
  /// gets a hint (the HTML ignored it).
  void _onPointerDown(PointerDownEvent event) {
    if (!_lab.isLabActive || _held != null) return;
    final at = event.localPosition;
    if (_pick(at) != null) return;
    final blocker = _blockerAt(at);
    if (blocker == null) return;
    if (blocker.kind == _Kind.husk) {
      _lab.showToast(_t('toast_stones_first'), isError: true);
    }
  }

  /// HTML `startDrag`: the drag plane is horizontal through the piece.
  void _onDown(DragDownDetails d) {
    final p = _pick(d.localPosition);
    if (p == null) return;
    p.stop();
    _held = p;
    _grabEpoch = _scene.epoch;
    _moved = false;
    _planeY = p.pos.y;
    final hit = _cam.onPlaneY(d.localPosition, _planeY);
    _grabOffset = hit == null ? _V.zero : hit - p.pos;
    _Sound.pickup.play();
    setState(() => p.held = true);
  }

  /// HTML `pointermove`: the piece follows the finger on its plane, lifted
  /// to y = 3.5.
  void _onDragUpdate(DragUpdateDetails d) {
    final p = _held;
    if (p == null || _grabEpoch != _scene.epoch) return;
    final hit = _cam.onPlaneY(d.localPosition, _planeY);
    if (hit == null) return;
    final at = hit - _grabOffset;
    p.pos = _V(
      at.x.clamp(-_dragHalfX, _dragHalfX),
      _liftY,
      at.z.clamp(-_dragHalfZ, _dragHalfZ),
    );
    _moved = true;
  }

  void _onDragEnd(DragEndDetails _) => _release();

  /// HTML `endDragHandler` → `checkDrop()`.
  void _release() {
    final p = _held;
    final current = _grabEpoch == _scene.epoch;
    _held = null;
    _grabEpoch = -1;
    if (p == null || !current) return;
    final s = _scene;
    setState(() => p.held = false);
    if (!_moved) {
      // A touch without a drag puts the piece straight back.
      if (p.pos != p.home) p.glide(p.home, s.time, _returnSeconds);
      return;
    }
    _moved = false;
    if (s.scenario == 0) {
      _dropS1(p);
    } else {
      _dropS2(p);
    }
  }

  /// Back to where it was picked up, with the HTML's 400 ms tween.
  void _sendHome(_Piece p, String toastKey) {
    p.glide(p.home, _scene.time, _returnSeconds);
    _lab.showToast(_t(toastKey), isError: true);
  }

  /// Scenario 1: released over the discard bowl it drops in; anywhere else
  /// it goes back onto the wheat.
  void _dropS1(_Piece p) {
    final s = _scene;
    final dx = p.pos.x - _discardBowl.x;
    if (math.sqrt(dx * dx + p.pos.z * p.pos.z) >= _discardCatch) {
      _sendHome(p, 'toast_drop_bowl');
      return;
    }
    final stone = p.kind == _Kind.stone;
    final slot = stone ? s.stonesRemoved : _stoneSpots.length + s.huskRemoved;
    final (x, z) = _discardSpots[slot % _discardSpots.length];
    // Resting on the floor: a stone on its rounded side, a flake flat.
    final y = _floorY + (stone ? _stoneRestLift : _huskHalfThickness);
    p
      ..placed = true
      ..glide(_V(x, y, z), s.time, _placeSeconds);
    _Sound.drop.play();
    setState(() {
      if (stone) {
        s.stonesRemoved++;
        if (s.stonesRemoved >= _stoneSpots.length) s.step = 2;
      } else {
        s.huskRemoved++;
        if (s.huskRemoved >= _huskSpots.length) s.step = 3;
      }
    });
  }

  /// Scenario 2: released on the plate away from the pulao it stays there;
  /// still in the pulao, or off the plate, it goes back.
  void _dropS2(_Piece p) {
    final s = _scene;
    final d = math.sqrt(p.pos.x * p.pos.x + p.pos.z * p.pos.z);
    if (d < _edgeCatchInner || d > _edgeCatchOuter) {
      _sendHome(p, 'toast_drop_edge');
      return;
    }
    final y = d >= _bareRimFrom
        ? _plateSurfaceY + _Kind.pepper.radius
        : _Kind.pepper.restY;
    p
      ..placed = true
      ..glide(_V(p.pos.x, y, p.pos.z), s.time, _placeSeconds);
    _Sound.drop.play();
    setState(() {
      s.peppersRemoved++;
      if (s.step == 1 && s.peppersRemoved >= 3) s.step = 2;
      if (s.peppersRemoved >= _pepperSpots.length) s.step = 3;
    });
  }

  /// The slide that moves the scene's working area (pieces, bowl, plate)
  /// clear of the floating mission card while the sidebar is collapsed,
  /// without pushing its right side under the tool column.
  Offset _collapsedShift(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (fit <= 0 || !fit.isFinite) return Offset.zero;
    final stageLeft = (size.width - _design.width * fit) / 2;
    final cardRight =
        (76 +
            pad.left +
            _missionCardWidth(size, context.labScale) -
            stageLeft) /
        fit;
    final tools = labOverlayInsets(context, _lab).right;
    final toolsLeft = (size.width - tools - stageLeft) / fit;
    final (left, right) = _scene.scenario == 0 ? _s1Extent : _s2Extent;
    final room = math.max(0.0, toolsLeft - _cardGap - right);
    return Offset(
      (cardRight + _cardGap - left).clamp(0.0, room),
      _collapsedDrop,
    );
  }

  // -------------------------------------------------------------------- UI

  /// The step's own button (HTML `#btn-action-main`, shown at step 3), in
  /// the sidebar and the floating mission card.
  List<LabAction> _actions() {
    final s = _scene;
    if (s.step < _stepCounts[s.scenario]) return const [];
    return [
      LabAction(
        label: _t('btn_finish'),
        icon: Icons.arrow_forward,
        color: _Colors.emerald600,
        foreground: _Colors.white,
        highlight: !s.concluded,
        silent: true,
        onTap: _onFinish,
      ),
    ];
  }

  /// HTML `updateCounterDisplay()` text (the HTML had no `#counter-text`
  /// element, so it never showed).
  (String, bool) _counter() {
    final s = _scene;
    if (s.scenario == 1) {
      return (
        labFormat(_t('cnt_peppers'), {'c': s.peppersRemoved}),
        s.peppersRemoved >= _pepperSpots.length,
      );
    }
    if (s.step == 1) {
      return (labFormat(_t('cnt_stones'), {'c': s.stonesRemoved}), false);
    }
    if (s.step == 2) {
      return (labFormat(_t('cnt_husk'), {'c': s.huskRemoved}), false);
    }
    return (_t('cnt_ready'), true);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final s = context.labScale;
        final data = _scenarioData;
        final sc = _scene.scenario;
        final inset = labOverlayInsets(context, _lab);
        final (counter, done) = _counter();
        return LabShell(
          controller: _lab,
          icon: Icons.pan_tool,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('sc1_title'), _t('sc2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _scene.step,
          hud: _t('s${sc + 1}_hud_${_scene.step.clamp(1, data.steps.length)}'),
          actions: _actions(),
          // HTML `enterLab()` and `resetApp()` both start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            key: ValueKey('ch9a1-steps-$sc-${_scene.step}'),
            steps: data.steps,
            current: _scene.step,
            palette: _lab.palette,
            scale: s,
            fontScale: s * _lab.fontScale,
            stepLabel: _t('exploration'),
            conceptLabel: _t('concept_focus'),
            actionLabel: _t('action'),
            observationLabel: _t('observation'),
            pendingText: _t('obs_pending'),
          ),
          overlays: [
            // The HTML `cnt_*` counter: top right of the canvas, below the
            // toasts and clear of the scene.
            if (_lab.isLabActive)
              Positioned(
                key: const ValueKey('ch9a1-counter'),
                top: inset.top + 56 * s,
                right: inset.right,
                child: _CounterChip(
                  text: counter,
                  done: done,
                  palette: _lab.palette,
                  scale: s,
                ),
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
          _labelSize =
              _labelPx * (_labelFullScale / fit).clamp(1.0, _labelMaxBoost);
          _shift = _lab.isSidebarOpen ? Offset.zero : _collapsedShift(context);
        }
        return LabStage(
          designSize: _design,
          // The slide moves the whole scene layer (painting and hit tests),
          // so gestures arrive in the scene's own design coordinates.
          child: AnimatedSlide(
            offset: Offset(
              _shift.dx / _design.width,
              _shift.dy / _design.height,
            ),
            duration: _panDuration,
            curve: Curves.easeInOutCubic,
            child: KeyedSubtree(
              key: _sceneKey,
              child: Listener(
                onPointerDown: _onPointerDown,
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Drags on the scene are not screen-reader actions; the
                  // scene is announced by its label instead.
                  excludeFromSemantics: true,
                  gestures: <Type, GestureRecognizerFactory>{
                    _GrabPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _GrabPanRecognizer
                        >(
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
                            ..onUpdate = _onDragUpdate
                            ..onEnd = _onDragEnd
                            ..onCancel = _release,
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
                        ),
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
}

/// The HTML `cnt_*` counter as a small card on the canvas.
class _CounterChip extends StatelessWidget {
  const _CounterChip({
    required this.text,
    required this.done,
    required this.palette,
    required this.scale,
  });

  final String text;
  final bool done;
  final LabPalette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final s = scale;
    final tone = done ? p.success : p.accentInk;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 230 * s),
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
        radius: 12,
        borderColor: tone.withValues(alpha: 0.6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              done ? Icons.check_circle : Icons.pan_tool_alt,
              size: 15 * s,
              color: tone,
            ),
            SizedBox(width: 6 * s),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.textStrong,
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HTML teacher-board accordion ("Observation Step"): one card per step
/// with its task, action and result. The current step is open, done steps
/// show a tick and can be re-opened, future steps are dimmed. A step's
/// result is shown once the step is done (the HTML showed it before the
/// learner had seen it).
class _StepsAccordion extends StatefulWidget {
  const _StepsAccordion({
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
    required this.pendingText,
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
  final String pendingText;

  @override
  State<_StepsAccordion> createState() => _StepsAccordionState();
}

class _StepsAccordionState extends State<_StepsAccordion> {
  /// Steps the learner opened or closed (HTML `toggleAccordion`).
  final Set<int> _toggled = {};

  bool _isOpen(int i) => (i == widget.current) != _toggled.contains(i);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= widget.steps.length; i++) _tile(context, i),
      ],
    );
  }

  Widget _heading(String text, Color color) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color,
      fontSize: 9.5 * widget.fontScale,
      fontWeight: FontWeight.w800,
      letterSpacing: labLetterSpacing(text, 0.8),
    ),
  );

  Widget _tile(BuildContext context, int i) {
    final w = widget;
    final p = w.palette;
    final s = w.scale;
    final f = w.fontScale;
    final past = i < w.current;
    final current = i == w.current;
    final future = i > w.current;
    final open = !future && _isOpen(i);
    // Future steps: HTML `text-slate-500`, dimmed and closed.
    final dim = future ? 0.5 : 1.0;
    final accent = p.accentInk;
    final tone = current ? accent : (past ? p.success : p.textMuted);
    final border = current
        ? p.accent
        : (past ? p.success.withValues(alpha: 0.5) : p.cardBorder);
    final step = w.steps[i - 1];

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
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
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
                              ? p.accent
                              : (past
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.cardBorder.withValues(
                                        alpha: 0.5 * dim,
                                      )),
                          border: Border.all(
                            color: current
                                ? p.accent
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
                                      ? p.onAccent
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
                  _heading(w.conceptLabel, accent),
                  SizedBox(height: 3 * s),
                  Text(
                    step.concept,
                    style: TextStyle(
                      color: p.textStrong,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.actionLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    step.action,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  _heading(w.observationLabel, p.textStrong),
                  SizedBox(height: 3 * s),
                  Text(
                    past ? step.observation : w.pendingText,
                    style: TextStyle(
                      color: past ? p.text : p.textMuted,
                      fontSize: 11.5 * f,
                      fontWeight: past ? FontWeight.w600 : FontWeight.w500,
                      fontStyle: past ? FontStyle.normal : FontStyle.italic,
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

// ================================================================== PAINTING

/// HTML lights: key `DirectionalLight` at (12, 25, 16) and the bluish fill
/// light at (-15, 18, -12), normalised.
const _V _keyLight = _V(0.3748, 0.7809, 0.4997);
const _V _fillLight = _V(-0.5698, 0.6838, -0.4559);

/// HTML `AmbientLight(0.65)`, key light 0.8 and fill light 0.4, scaled so a
/// face turned straight up shows its material colour (the WebGL scene, with
/// no tone mapping, washed the cream plate and the rice out to white).
const double _ambient = 0.55;
const double _keyStrength = 0.45;
const double _fillStrength = 0.15;

/// MeshStandardMaterial look: ambient light plus the two lights' Lambert
/// terms on a face with normal [n].
Color _lit(Color c, _V n, {double opacity = 1}) {
  final i =
      _ambient +
      _keyStrength * math.max(0.0, n.dot(_keyLight)) +
      _fillStrength * math.max(0.0, n.dot(_fillLight));
  return Color.from(
    alpha: c.a * opacity,
    red: math.min(1.0, c.r * i),
    green: math.min(1.0, c.g * i),
    blue: math.min(1.0, c.b * i),
  );
}

/// Points of a horizontal circle of radius [r] at height [y] round (cx, cz),
/// projected.
List<Offset> _ring(double cx, double y, double cz, double r, {int n = 48}) => [
  for (var i = 0; i < n; i++)
    _cam.p(
      _V(
        cx + r * math.cos(i * 2 * math.pi / n),
        y,
        cz + r * math.sin(i * 2 * math.pi / n),
      ),
    ),
];

/// Convex hull of [pts] (monotone chain): the outline of a bowl's wall.
List<Offset> _hull(List<Offset> pts) {
  final p = [
    ...pts,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double turn(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        turn(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <Offset>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        turn(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [...lower..removeLast(), ...upper..removeLast()];
}

Path _poly(List<Offset> pts) => Path()..addPolygon(pts, true);

/// A ring (annulus) between two projected circles.
Path _annulus(List<Offset> outer, List<Offset> inner) => Path()
  ..fillType = PathFillType.evenOdd
  ..addPolygon(outer, true)
  ..addPolygon(inner, true);

/// HTML `for (i < n)` scatter with `Math.random()`, from a fixed seed so the
/// pile looks the same on every visit: points ((r - 0.5) * [spread], [y0] +
/// r * [rise], (r - 0.5) * [spread]) kept when nearer than [maxLength] to
/// the group origin (bowl- or plate-local), moved to (cx, [_baseY], 0).
List<_V> _scatter({
  required int seed,
  required int count,
  required double spread,
  required double y0,
  required double rise,
  required double maxLength,
  required double cx,
}) {
  final rnd = math.Random(seed);
  final out = <_V>[];
  for (var i = 0; i < count; i++) {
    final x = (rnd.nextDouble() - 0.5) * spread;
    final y = y0 + rnd.nextDouble() * rise;
    final z = (rnd.nextDouble() - 0.5) * spread;
    if (math.sqrt(x * x + y * y + z * z) < maxLength) {
      out.add(_V(cx + x, _baseY + y, z));
    }
  }
  // Far to near, so nearer grains cover farther ones.
  out.sort((a, b) => _cam.depth(b).compareTo(_cam.depth(a)));
  return out;
}

/// `buildScenario1Scene()`: 80 wheat grains `SphereGeometry(0.35)` scaled
/// (1.4, 0.7, 0.7) in the mixture bowl.
final List<_V> _wheatGrains = _scatter(
  seed: 91,
  count: 80,
  spread: 6.5,
  y0: 0.5,
  rise: 1.2,
  maxLength: 3.8,
  cx: _mixBowl.x,
);

/// `buildScenario2Scene()`: 150 rice grains `SphereGeometry(0.3)` scaled
/// (1.5, 0.6, 0.6) on the plate.
final List<_V> _riceGrains = _scatter(
  seed: 92,
  count: 150,
  spread: 8,
  y0: 0.6,
  rise: 0.8,
  maxLength: 5,
  cx: 0,
);

/// `buildScenario2Scene()`: 18 peas and carrot pieces `SphereGeometry(0.35)`
/// at y = 1.1 (every other one a carrot piece).
final List<(_V, bool)> _vegPieces = () {
  final rnd = math.Random(93);
  final out = <(_V, bool)>[];
  for (var i = 0; i < 18; i++) {
    final x = (rnd.nextDouble() - 0.5) * 6.5;
    final z = (rnd.nextDouble() - 0.5) * 6.5;
    const y = 1.1;
    if (math.sqrt(x * x + y * y + z * z) < 4.5) {
      out.add((_V(x, _baseY + y, z), i.isEven));
    }
  }
  return out;
}();

/// Paints and paths reused by every frame (no allocation per frame).
class _Pens {
  final Paint fill = Paint();
  final Paint stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final Paint shadow = Paint()
    ..color = _Colors.shadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  /// Halo round the piece being dragged.
  final Paint glow = Paint()
    ..color = _Colors.heldGlow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  final Path path = Path();
}

/// What the painter makes once and reuses: pens, the static backdrop (table,
/// bowls with the wheat / plate with the pulao), the pieces' shapes and
/// shading, and the label text painters. Owned by the page state and
/// disposed with it.
class _PaintCache {
  final _Pens pens = _Pens();
  final Map<String, TextPainter> _labels = {};
  LabLang? _lang;
  double _labelSize = _labelPx;
  bool _labelDark = true;
  ui.Picture? _backdrop;
  (int, bool, bool)? _backdropKey;

  /// Pieces in painting order (reused list).
  final List<_Piece> order = [];

  /// Unit-size outlines and facet lines of the four stones (irregular
  /// `DodecahedronGeometry` silhouettes, each turned its own way).
  final List<Path> stoneOutlines = [
    for (var i = 0; i < 4; i++) _stoneOutline(i),
  ];
  final List<Path> stoneFacets = [for (var i = 0; i < 4; i++) _stoneFacets(i)];

  /// Wrinkles of a dried peppercorn, unit size.
  final Path pepperWrinkles = Path()
    ..moveTo(-0.55, -0.15)
    ..quadraticBezierTo(-0.2, -0.35, 0.15, -0.1)
    ..moveTo(-0.35, 0.3)
    ..quadraticBezierTo(0.05, 0.1, 0.5, 0.35)
    ..moveTo(0.25, -0.55)
    ..quadraticBezierTo(0.45, -0.25, 0.6, -0.05);

  /// Shading of a unit sphere lit from the upper right (stone, peppercorn).
  final Paint stoneShade = _unitShade(_Colors.stone);
  final Paint pepperShade = _unitShade(_Colors.pepper, highlight: 0.35);

  /// Rotated corners of each husk flake (box-local, before moving).
  final List<_Flake> flakes = [
    for (final (yaw, tx, tz) in _huskTurns) _Flake(yaw, tx, tz),
  ];

  double get labelSize => _labelSize;
  bool get labelDark => _labelDark;

  /// Drops the label painters when the language, label size or theme
  /// changes.
  void prepare(LabLang lang, double labelSize, bool dark) {
    if (lang == _lang && labelSize == _labelSize && dark == _labelDark) {
      return;
    }
    _disposeLabels();
    _lang = lang;
    _labelSize = labelSize;
    _labelDark = dark;
  }

  TextPainter label(String text) => _labels[text] ??= TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: _labelDark ? _Colors.white : _Colors.slate800,
        fontSize: _labelSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: labLetterSpacing(text, 0.2),
        fontFamily: LabFont.active.family,
        fontFamilyFallback: LabFont.active.fallback,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// The static part of [scenario]'s scene, recorded once per theme and
  /// drop-zone visibility.
  ui.Picture backdrop(int scenario, bool dark, bool zone, Size size) {
    final key = (scenario, dark, zone);
    final cached = _backdrop;
    if (cached != null && key == _backdropKey) return cached;
    cached?.dispose();
    final recorder = ui.PictureRecorder();
    _paintBackdrop(Canvas(recorder), scenario, dark, zone, size);
    _backdropKey = key;
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

/// A unit sphere's shading: light upper right (towards the key light), dark
/// lower left.
Paint _unitShade(Color c, {double highlight = 0.45}) =>
    Paint()
      ..shader = ui.Gradient.radial(
        const Offset(0.3, -0.35),
        1.45,
        [labShade(c, highlight), c, labShade(c, -0.45)],
        const [0, 0.45, 1],
      );

/// Unit outline of stone [i]: nine corners at radius 1 ± 0.14, turned by
/// the stone's own angle (HTML `rotation.set(rand * 3, rand * 3, 0)`).
Path _stoneOutline(int i) {
  final rnd = math.Random(70 + i);
  final turn = rnd.nextDouble() * math.pi;
  const corners = 9;
  final path = Path();
  for (var k = 0; k < corners; k++) {
    final a = turn + k * 2 * math.pi / corners;
    final r = 0.86 + rnd.nextDouble() * 0.28;
    final o = Offset(math.cos(a) * r, math.sin(a) * r * 0.9);
    if (k == 0) {
      path.moveTo(o.dx, o.dy);
    } else {
      path.lineTo(o.dx, o.dy);
    }
  }
  return path..close();
}

/// Facet edges of stone [i] (a few lines from an off-centre point).
Path _stoneFacets(int i) {
  final rnd = math.Random(80 + i);
  final c = Offset(
    -0.2 + rnd.nextDouble() * 0.3,
    -0.25 + rnd.nextDouble() * 0.3,
  );
  final path = Path();
  for (var k = 0; k < 4; k++) {
    final a = k * math.pi / 2 + rnd.nextDouble() * 0.9;
    path
      ..moveTo(c.dx, c.dy)
      ..lineTo(math.cos(a) * 0.82, math.sin(a) * 0.74);
  }
  return path;
}

/// A husk flake: `BoxGeometry(0.8, 0.15, 0.5)` turned by Euler angles
/// (order XYZ, as Three.js), corners and face normals precomputed.
@immutable
class _Flake {
  factory _Flake(double yaw, double tiltX, double tiltZ) {
    _V rot(_V v) {
      // Three.js Euler 'XYZ': R = Rx · Ry · Rz.
      final cz = math.cos(tiltZ), sz = math.sin(tiltZ);
      final v1 = _V(v.x * cz - v.y * sz, v.x * sz + v.y * cz, v.z);
      final cy = math.cos(yaw), sy = math.sin(yaw);
      final v2 = _V(v1.x * cy + v1.z * sy, v1.y, -v1.x * sy + v1.z * cy);
      final cx = math.cos(tiltX), sx = math.sin(tiltX);
      return _V(v2.x, v2.y * cx - v2.z * sx, v2.y * sx + v2.z * cx);
    }

    const h = _V(0.4, 0.075, 0.25);
    return _Flake._(
      [
        for (var i = 0; i < 8; i++)
          rot(
            _V(
              i & 1 == 0 ? -h.x : h.x,
              i & 2 == 0 ? -h.y : h.y,
              i & 4 == 0 ? -h.z : h.z,
            ),
          ),
      ],
      [for (final n in _faceNormals) rot(n)],
    );
  }

  const _Flake._(this.corners, this.normals);

  /// Corner i has x = ±, y = ± and z = ± by its bits 0, 1 and 2.
  final List<_V> corners;
  final List<_V> normals;

  static const List<_V> _faceNormals = [
    _V(1, 0, 0),
    _V(-1, 0, 0),
    _V(0, 1, 0),
    _V(0, -1, 0),
    _V(0, 0, 1),
    _V(0, 0, -1),
  ];

  /// Corner indices of each face, in [_faceNormals] order.
  static const List<List<int>> faces = [
    [1, 3, 7, 5],
    [0, 4, 6, 2],
    [2, 6, 7, 3],
    [0, 1, 5, 4],
    [4, 5, 7, 6],
    [0, 2, 3, 1],
  ];
}

// ------------------------------------------------------------ backdrop

/// The scene's static layer: background, table and, for Scenario 1, the two
/// bowls (with the wheat) or, for Scenario 2, the plate of pulao.
void _paintBackdrop(
  Canvas canvas,
  int scenario,
  bool dark,
  bool zone,
  Size size,
) {
  final paint = Paint();
  canvas.drawRect(
    labBleed(size),
    paint..color = dark ? _Colors.sceneDark : _Colors.sceneLight,
  );
  _paintTable(canvas, paint);
  if (scenario == 0) {
    _paintBowl(canvas, _mixBowl, contents: _paintWheat);
    _paintBowl(
      canvas,
      _discardBowl,
      contents: zone ? (c, _) => _paintDropZone(c) : null,
    );
  } else {
    _paintPlate(canvas, zone);
  }
}

/// `tableMat` box 36 x 1.5 x 20, top at y = 0.
void _paintTable(Canvas canvas, Paint paint) {
  const hx = _tableHalfX, hz = _tableHalfZ, h = _tableThickness;
  final top = [
    _cam.p(const _V(-hx, 0, -hz)),
    _cam.p(const _V(hx, 0, -hz)),
    _cam.p(const _V(hx, 0, hz)),
    _cam.p(const _V(-hx, 0, hz)),
  ];
  final front = [
    _cam.p(const _V(-hx, 0, hz)),
    _cam.p(const _V(hx, 0, hz)),
    _cam.p(const _V(hx, -h, hz)),
    _cam.p(const _V(-hx, -h, hz)),
  ];
  canvas.drawPath(_poly(front), paint..color = _lit(_Colors.table, _V.zero));
  canvas.drawPath(_poly(top), paint..color = _lit(_Colors.table, _V.up));
  // The far edge catches the light.
  canvas.drawLine(
    top[0],
    top[1],
    Paint()
      ..strokeWidth = 1.5
      ..color = labShade(_Colors.table, 0.25),
  );
}

/// Soft shadow of a round footprint of radius [r] at (cx, 0, cz), pushed
/// away from the key light.
void _paintFootShadow(Canvas canvas, double cx, double cz, double r) {
  canvas.drawPath(
    _poly(_ring(cx - 0.35, 0.002, cz - 0.4, r, n: 32)),
    Paint()
      ..color = _Colors.shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
  );
}

/// One bowl: shadow, outer wall, rim, the visible inside (back wall and
/// floor), what lies in it ([contents], clipped to the opening) and the rim
/// edges.
void _paintBowl(
  Canvas canvas,
  _Bowl b, {
  void Function(Canvas canvas, Path opening)? contents,
}) {
  final paint = Paint();
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  _paintFootShadow(canvas, b.x, 0, b.outerBottom + 0.4);

  // Outer wall: the outline of both circles, lit from the right.
  final top = _ring(b.x, b.rimY, 0, b.outerTop);
  final bottom = _ring(b.x, _baseY, 0, b.outerBottom);
  final wall = _hull([...top, ...bottom]);
  final bounds = _poly(wall).getBounds();
  canvas.drawPath(
    _poly(wall),
    paint
      ..shader = ui.Gradient.linear(
        bounds.centerLeft,
        bounds.centerRight,
        [
          _lit(b.outer, const _V(-1, 0, 0.3)),
          _lit(b.outer, const _V(0, 0.2, 1)),
          _lit(b.outer, const _V(0.9, 0.2, 0.4)),
          _lit(b.outer, const _V(1, 0, -0.2)),
        ],
        const [0, 0.45, 0.8, 1],
      ),
  );
  paint.shader = null;

  // Rim ring on top, then the inside seen through the opening.
  final inner = _ring(b.x, b.rimY, 0, b.innerTop);
  canvas.drawPath(_poly(top), paint..color = _lit(b.rim, _V.up));
  final opening = _poly(inner);
  final ib = opening.getBounds();
  canvas.drawPath(
    opening,
    paint
      ..shader = ui.Gradient.linear(
        ib.topCenter,
        ib.bottomCenter,
        [
          _lit(_Colors.cream, const _V(0, 0.3, 1)),
          _lit(_Colors.cream, const _V(0, 1, 0.3)),
          labShade(_Colors.cream, -0.25),
        ],
        const [0, 0.55, 1],
      ),
  );
  paint.shader = null;
  canvas.save();
  canvas.clipPath(opening);
  canvas.drawPath(
    _poly(_ring(b.x, _floorY, 0, b.floor)),
    paint..color = labShade(_Colors.cream, -0.08),
  );
  contents?.call(canvas, opening);
  canvas.restore();

  // Rim edges.
  canvas.drawPath(
    _poly(top),
    edge..color = labShade(b.rim, -0.4).withValues(alpha: 0.7),
  );
  canvas.drawPath(
    opening,
    edge..color = labShade(b.rim, -0.3).withValues(alpha: 0.8),
  );
}

/// The wheat in the mixture bowl: a bed of grain, then the grains far to
/// near (`wheatMat` ellipsoids 0.98 x 0.49, lying along x).
void _paintWheat(Canvas canvas, Path opening) {
  final paint = Paint();
  canvas.drawPath(
    _poly(_ring(_mixBowl.x, 1.15, 0, 3.55)),
    paint..color = labShade(_Colors.wheat, -0.12),
  );
  final crease = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = labShade(_Colors.wheat, -0.4).withValues(alpha: 0.6);
  for (final g in _wheatGrains) {
    final c = _cam.p(g);
    final k = _cam.scaleAt(g);
    final rect = Rect.fromCenter(center: c, width: 0.98 * k, height: 0.46 * k);
    canvas.drawOval(
      rect,
      paint
        ..shader = ui.Gradient.radial(
          c + Offset(0.15 * k, -0.1 * k),
          0.6 * k,
          [
            labShade(_Colors.wheat, 0.35),
            _Colors.wheat,
            labShade(_Colors.wheat, -0.35),
          ],
          const [0, 0.55, 1],
        ),
    );
    paint.shader = null;
    canvas.drawLine(
      c + Offset(-0.3 * k, 0.02 * k),
      c + Offset(0.3 * k, -0.02 * k),
      crease..strokeWidth = math.max(0.6, 0.05 * k),
    );
  }
}

/// `discardBowlZoneS1`: the indigo ring glowing just under the discard
/// bowl's rim (steps 1–2).
void _paintDropZone(Canvas canvas) {
  canvas.drawPath(
    _annulus(
      _ring(_discardBowl.x, _dropZoneY, 0, _dropZoneOuter),
      _ring(_discardBowl.x, _dropZoneY, 0, _dropZoneInner),
    ),
    Paint()..color = _Colors.dropGlow,
  );
}

/// The pulao plate: base, indigo border, cream rim and surface, the glowing
/// edge ([zone], steps 1–2), the rice bed, then the rice grains, peas and
/// carrot pieces far to near.
void _paintPlate(Canvas canvas, bool zone) {
  final paint = Paint();
  _paintFootShadow(canvas, 0, 0, _plateBottomR + 0.5);
  final top = _ring(0, _plateTopY, 0, _plateTopR, n: 64);
  final bottom = _ring(0, _baseY, 0, _plateBottomR, n: 64);
  final wall = _hull([...top, ...bottom]);
  final bounds = _poly(wall).getBounds();
  canvas.drawPath(
    _poly(wall),
    paint
      ..shader = ui.Gradient.linear(
        bounds.centerLeft,
        bounds.centerRight,
        [
          _lit(_Colors.plateOuter, const _V(-1, 0, 0.3)),
          _lit(_Colors.plateOuter, const _V(0, 0.2, 1)),
          _lit(_Colors.plateOuter, const _V(1, 0, 0)),
        ],
        const [0, 0.5, 1],
      ),
  );
  paint.shader = null;
  canvas.drawPath(
    _poly(_ring(0, _plateSurfaceY, 0, _plateBorderR, n: 64)),
    paint..color = _lit(_Colors.plateBorder, _V.up),
  );
  canvas.drawPath(
    _poly(_ring(0, _plateSurfaceY, 0, _plateRimR, n: 64)),
    paint..color = _lit(_Colors.cream, _V.up),
  );
  canvas.drawPath(
    _poly(_ring(0, _plateSurfaceY, 0, _plateSurfaceR, n: 64)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = labShade(_Colors.cream, -0.2),
  );
  if (zone) {
    canvas.drawPath(
      _annulus(
        _ring(0, _plateSurfaceY + 0.005, 0, _edgeZoneOuter, n: 64),
        _ring(0, _plateSurfaceY + 0.005, 0, _edgeZoneInner, n: 64),
      ),
      paint..color = _Colors.edgeGlow,
    );
  }
  // The pulao: a bed of rice, then grains and vegetables far to near.
  canvas.drawPath(
    _poly(_ring(0, 0.9, 0, 4.6, n: 48)),
    Paint()
      ..color = labShade(_Colors.rice, -0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  final items = <(_V, int)>[
    for (final g in _riceGrains) (g, 0),
    for (final (v, pea) in _vegPieces) (v, pea ? 1 : 2),
  ]..sort((a, b) => _cam.depth(b.$1).compareTo(_cam.depth(a.$1)));
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.7
    ..color = labShade(_Colors.rice, -0.35).withValues(alpha: 0.7);
  for (final (v, kind) in items) {
    final c = _cam.p(v);
    final k = _cam.scaleAt(v);
    if (kind == 0) {
      // `riceMat` ellipsoid 0.9 x 0.36, lying along x.
      final rect = Rect.fromCenter(center: c, width: 0.9 * k, height: 0.32 * k);
      canvas.drawOval(
        rect,
        paint..color = _lit(_Colors.rice, const _V(0, 1, 0.4)),
      );
      canvas.drawOval(rect, edge);
      continue;
    }
    // `peaMat` / `carrotMat` spheres of radius 0.35.
    final color = kind == 1 ? _Colors.pea : _Colors.carrot;
    final r = 0.35 * k;
    canvas.drawCircle(
      c,
      r,
      paint
        ..shader = ui.Gradient.radial(
          c + Offset(0.3 * r, -0.35 * r),
          1.45 * r,
          [labShade(color, 0.4), color, labShade(color, -0.4)],
          const [0, 0.45, 1],
        ),
    );
    paint.shader = null;
  }
}

// ------------------------------------------------------------- the scene

/// Paints the HTML Three.js scene: the static backdrop from [_PaintCache],
/// the stones / husk flakes / peppercorns far to near, the piece being
/// dragged on top with its shadow, and the labels.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cache,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.labelSize,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _PaintCache cache;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final double labelSize;

  _Pens get _pens => cache.pens;

  String _t(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    cache.prepare(lang, labelSize, isDark);
    canvas.drawPicture(
      cache.backdrop(scene.scenario, isDark, scene.zoneVisible, size),
    );
    _Piece? held;
    final order = cache.order..clear();
    for (final p in scene.pieces) {
      if (p.held) {
        held = p;
      } else {
        order.add(p);
      }
    }
    order.sort((a, b) => _cam.depth(b.pos).compareTo(_cam.depth(a.pos)));
    if (held != null) _paintDropShadow(canvas, held);
    for (final p in order) {
      _paintPiece(canvas, p);
    }
    if (held != null) {
      final c = _cam.p(held.pos);
      final r = held.kind.radius * _cam.scaleAt(held.pos);
      canvas.drawCircle(c, r * 1.7, _pens.glow);
      _paintPiece(canvas, held);
    }
    if (showLabels) _paintLabels(canvas);
  }

  /// Where a lifted piece would land: a soft shadow on the surface under it.
  void _paintDropShadow(Canvas canvas, _Piece p) {
    final x = p.pos.x, z = p.pos.z;
    final double y;
    if (scene.scenario == 0) {
      final dm = math.sqrt(math.pow(x - _mixBowl.x, 2) + z * z);
      final dd = math.sqrt(math.pow(x - _discardBowl.x, 2) + z * z);
      y = dm < _mixBowl.innerTop
          ? _wheatTopY
          : (dd < _discardBowl.innerTop ? _floorY : 0.002);
    } else {
      final d = math.sqrt(x * x + z * z);
      y = d < _plateBorderR
          ? (d < _bareRimFrom ? _riceTopY : _plateSurfaceY)
          : 0.002;
    }
    final at = _V(x, y, z);
    final c = _cam.p(at);
    final k = _cam.scaleAt(at);
    final r = p.kind.radius * k;
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 2.2 * r, height: 1.1 * r),
      _pens.shadow,
    );
  }

  void _paintPiece(Canvas canvas, _Piece p) {
    switch (p.kind) {
      case _Kind.stone:
        _paintStone(canvas, p);
      case _Kind.husk:
        _paintHusk(canvas, p);
      case _Kind.pepper:
        _paintPepper(canvas, p);
    }
  }

  /// `stoneMat` dodecahedron: an irregular grey outline, shaded, with facet
  /// edges.
  void _paintStone(Canvas canvas, _Piece p) {
    final c = _cam.p(p.pos);
    final r = _Kind.stone.radius * _cam.scaleAt(p.pos);
    final i = p.index % cache.stoneOutlines.length;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(r);
    canvas.drawPath(cache.stoneOutlines[i], cache.stoneShade);
    canvas.drawPath(
      cache.stoneFacets[i],
      _pens.stroke
        ..strokeWidth = 1 / r
        ..color = labShade(_Colors.stone, -0.35).withValues(alpha: 0.6),
    );
    canvas.drawPath(
      cache.stoneOutlines[i],
      _pens.stroke
        ..strokeWidth = 1 / r
        ..color = labShade(_Colors.stone, -0.5),
    );
    canvas.restore();
  }

  /// `huskMat` flake: the faces of the turned box that face the camera.
  void _paintHusk(Canvas canvas, _Piece p) {
    final flake = cache.flakes[p.index % cache.flakes.length];
    for (var f = 0; f < _Flake.faces.length; f++) {
      final n = flake.normals[f];
      final idx = _Flake.faces[f];
      final mid = p.pos + (flake.corners[idx[0]] + flake.corners[idx[2]]) * 0.5;
      if (n.dot(_cam.eye - mid) <= 0) continue;
      final path = _pens.path..reset();
      for (var k = 0; k < 4; k++) {
        final o = _cam.p(p.pos + flake.corners[idx[k]]);
        if (k == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      path.close();
      canvas.drawPath(path, _pens.fill..color = _lit(_Colors.husk, n));
      canvas.drawPath(
        path,
        _pens.stroke
          ..strokeWidth = 0.8
          ..color = labShade(_Colors.husk, -0.45),
      );
    }
  }

  /// `pepperMat` sphere: very dark, glossy, wrinkled.
  void _paintPepper(Canvas canvas, _Piece p) {
    final c = _cam.p(p.pos);
    final r = _Kind.pepper.radius * _cam.scaleAt(p.pos);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(r);
    canvas.drawCircle(Offset.zero, 1, cache.pepperShade);
    canvas.drawPath(
      cache.pepperWrinkles,
      _pens.stroke
        ..strokeWidth = 1.1 / r
        ..color = _Colors.slate500.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      const Offset(0.32, -0.38),
      0.18,
      _pens.fill..color = _Colors.white.withValues(alpha: 0.55),
    );
    canvas.restore();
  }

  // ------------------------------------------------------------ labels

  /// HTML `createStdLabel(...)` chips. The HTML put them over the bowls'
  /// middles (where the stones lie) and both plate labels at the plate's
  /// centre (the 'Plate Edge' label among the peppercorns); here the bowl
  /// labels sit on the table in front of the bowls, 'Pulao Plate' beyond the
  /// back of the plate and 'Plate Edge' on the back-left of the glowing
  /// edge, clear of every piece.
  void _paintLabels(Canvas canvas) {
    if (scene.scenario == 0) {
      _chip(canvas, _cam.p(_mixLabelAt), _t('lbl_mix_bowl'));
      _chip(canvas, _cam.p(_discardLabelAt), _t('lbl_discard_bowl'));
      return;
    }
    _chip(canvas, _cam.p(_plateLabelAt), _t('lbl_pulao_plate'));
    _chip(canvas, _cam.p(_edgeLabelAt), _t('lbl_edge_zone'));
  }

  static const _V _mixLabelAt = _V(-6, 0, 6.3);
  static const _V _discardLabelAt = _V(6, 0, 5.9);
  static const _V _plateLabelAt = _V(0, 0.72, -10);
  static const _V _edgeLabelAt = _V(-5, 0.72, -5);

  /// A label chip centred on [at] (glass panel, indigo-400 border).
  void _chip(Canvas canvas, Offset at, String text) {
    final tp = cache.label(text);
    final size = cache.labelSize;
    final padX = size * 0.6, padY = size * 0.3;
    final rect = Rect.fromCenter(
      center: at,
      width: tp.width + 2 * padX,
      height: tp.height + 2 * padY,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size * 0.4));
    canvas.drawRRect(
      rr,
      _pens.fill
        ..color = cache.labelDark ? _Colors.labelBgDark : _Colors.labelBgLight,
    );
    canvas.drawRRect(
      rr,
      _pens.stroke
        ..strokeWidth = 1.2
        ..color = _Colors.indigo400,
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
      old.labelSize != labelSize;
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
