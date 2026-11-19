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

/// Class 7 Science • Chapter 10 • Activity 2
/// Photosynthesis: The Process of Food Synthesis.
///
/// Native Flutter port of `Cl7S-Ch10-A2-Photosynthesis__The_Process_of_Food_Synthesis.html`.
/// Scenario 1 covers one variegated plant with a black box, waits 36 hours,
/// then boils, decolourises (alcohol) and iodine-tests a sunlit and a dark
/// leaf. Scenario 2 destarches a plant, seals half a leaf in a bottle of
/// caustic soda (no CO₂), lights it and iodine-tests the leaf.
class Ch10A2PhotosynthesisTheProcessOfFoodSynthesisPage extends StatefulWidget {
  const Ch10A2PhotosynthesisTheProcessOfFoodSynthesisPage({super.key});

  @override
  State<Ch10A2PhotosynthesisTheProcessOfFoodSynthesisPage> createState() =>
      _Ch10A2PhotosynthesisTheProcessOfFoodSynthesisPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// The HTML synthesised Web Audio tones: `click` (pick up) → pickup,
/// `drop` → drop, `success` → correct / success, `error` → wrong,
/// `boil` (brown noise) → bubble. Pouring the caustic soda uses splash and
/// the time-lapse buttons whoosh.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / step completed.
  correct('correct.mp3'),

  /// Wrong action / invalid drop.
  wrong('wrong.mp3'),

  /// Scenario completed / conclusion popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// An object picked up from the scene.
  pickup('pickup.mp3'),

  /// An object dropped into place / an iodine drop.
  drop('drop.mp3'),

  /// Boiling water / alcohol bath.
  bubble('bubble.mp3'),

  /// Caustic soda poured into the bottle.
  splash('splash.mp3'),

  /// Time-lapse (Wait 36 / 48 / 6 hours).
  whoosh('whoosh.mp3');

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

/// CSS variables and Tailwind colours used by this lab.
abstract final class _Colors {
  // Theme (HTML `:root` / `.light-theme`).
  static const Color blue900 = Color(0xFF1E3A8A); // --bg-main (dark)
  static const Color blue950 = Color(0xFF172554); // --bg-panel (dark)
  static const Color blue300 = Color(0xFF93C5FD); // --text-muted (dark)
  static const Color blue500 = Color(0xFF3B82F6); // --border (dark)
  static const Color sky100 = Color(0xFFE0F2FE); // --bg-main (light)
  static const Color sky200 = Color(0xFFBAE6FD); // --border (light)
  static const Color green500 = Color(0xFF22C55E); // --accent
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color lime400 = Color(0xFFA3E635);
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color red500 = Color(0xFFEF4444);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color emerald500 = Color(0xFF10B981);

  // Scene artwork (SVG fills).
  static const Color yellow50 = Color(0xFFFEFCE8);
  static const Color yellow200 = Color(0xFFFEF08A); // pale, decolourised leaf
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706); // iodine yellow-brown
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber950 = Color(0xFF451A03);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange900 = Color(0xFF7C2D12);
  static const Color indigo950 = Color(0xFF1E1B4B); // iodine blue-black
  static const Color wood = Color(0xFF3E2723);
  static const Color woodDoor = Color(0xFF4E342E);
  static const Color woodShelf = Color(0xFF5D4037);
  static const Color woodEdge = Color(0xFF1F1209);
  static const Color gold = Color(0xFFD4AF37);
}

/// This lab's light and dark palettes (the HTML `:root` / `.light-theme`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.blue900,
    panel: Color(0xF2172554),
    border: Color(0x663B82F6),
    card: Color(0x801E3A8A),
    cardBorder: Color(0x663B82F6),
    canvasBg: _Colors.slate900,
    text: _Colors.slate50,
    textStrong: Colors.white,
    textMuted: _Colors.blue300,
    accent: _Colors.green500,
    onAccent: _Colors.slate900,
    primary: _Colors.blue500,
    onPrimary: Colors.white,
    success: _Colors.green500,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue400,
    popupBg: _Colors.blue950,
    popupHeader: _Colors.blue900,
    dialogBg: _Colors.blue950,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4D22C55E),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFF4ADE80),
    buttonBorder: Color(0xCC22C55E),
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: Color(0xE61E293B),
    labelText: Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.sky100,
    panel: Color(0xF2FFFFFF),
    border: Color(0x1A000000),
    card: Color(0x80E0F2FE),
    cardBorder: _Colors.sky200,
    canvasBg: _Colors.slate200,
    text: _Colors.slate900,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.green600,
    onAccent: _Colors.slate900,
    primary: _Colors.blue600,
    onPrimary: Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue600,
    popupBg: Colors.white,
    popupHeader: _Colors.sky100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate950,
    curtainGlow: Color(0x4D22C55E),
    curtainText: Colors.white,
    curtainMuted: _Colors.slate400,
    curtainIcon: _Colors.slate300,
    buttonBg: Color(0xCC000000),
    buttonIcon: Color(0xFF4ADE80),
    buttonBorder: Color(0xCC22C55E),
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
    'app_title': 'Photosynthesis: Process of Food Synthesis',
    'app_subtitle': 'Class 7 • Life Processes in Plants',
    's1_title': '1. Sunlight and Chlorophyll',
    's2_title': '2. The Role of Air (Carbon Dioxide)',
    'sci_obs': 'Scientific Conclusion',
    'exp_out': 'Expected Outcome',
    'conclusion_hud': 'Conclusion — review the results.',
    'wait36h': 'Wait 36 Hours',
    'wait48h': 'Wait 48 Hours',
    'wait6h': 'Wait 6 Hours',
    'btn_iodine_sun': 'Add Iodine (Sun Leaf)',
    'btn_iodine_dark': 'Add Iodine (Dark Leaf)',
    'btn_iodine_s2': 'Add Iodine (Test Leaf)',
    // Scene labels.
    'boil_label': 'Boiling Water',
    'alc_label': 'Alcohol in Water Bath',
    'tile_label': 'White Tile',
    'black_box': 'Black Box',
    'sun_plant': 'Sunlight Plant',
    'dark_plant': 'Dark Plant',
    'sun_leaf': 'Sunlight Leaf',
    'dark_leaf': 'Dark Leaf',
    'hot_water': 'Hot Water',
    'alcohol': 'Alcohol',
    'alc_sun': 'Alcohol (Sun)',
    'alc_dark': 'Alcohol (Dark)',
    'iodine': 'Iodine',
    'healthy_plant': 'Healthy Potted Plant',
    'destarched_plant': 'Destarched Plant',
    'dark_closet': 'DARK CLOSET',
    'naoh_desc': 'NaOH\n(Absorbs CO₂)',
    'caustic_soda': 'Caustic Soda',
    'target_leaf': 'Target Leaf',
    'split_cork': 'SPLIT CORK',
    'exp_setup': 'Experiment Setup',
    'sun_lamp': 'SUN LAMP',
    'test_station': 'Starch Test Station',
    'blue_black': 'BLUE-BLACK',
    'yellow_brown': 'YELLOW-BROWN',
    'out_bottle': 'Outside Bottle',
    'in_bottle': 'Inside Bottle',
    'starch_pres': 'Starch Present (CO₂ available)',
    'starch_abs': 'Starch Absent (No CO₂)',
    'lab_bench': 'Lab Bench',
    'day_2': 'DAY 2',
    'hours': '{n} h',
    'sun_leaf_result': 'Sunlight Leaf (Green parts turned Blue-Black)',
    'dark_leaf_result': 'Dark Leaf (No Starch)',
    // Feedback (the HTML HUD messages).
    'fb_covered': 'Covered.',
    'fb_time36': 'Time passing... 36 Hours elapsed.',
    'fb_extracted': 'Leaves extracted. Proceeding to Starch Test...',
    'fb_boiling': 'Boiling leaves... Softening cell walls.',
    'fb_extracting': 'Extracting chlorophyll... Alcohol turns green.',
    'fb_pale': 'Leaves are pale (chlorophyll removed). Drag them to the Tile.',
    'fb_placed': 'Leaves placed. Now test the Sunlight Leaf.',
    'fb_iodine_sun': 'Iodine added to Sunlight Leaf.',
    'fb_test_dark': 'Test the Dark Leaf.',
    'fb_iodine_dark': 'Iodine added to Dark Leaf.',
    'fb_in_dark': 'Plant placed in dark.',
    'fb_time48': 'Time passing... 48 Hours elapsed.',
    'fb_destarched': 'Plant is now destarched.',
    'fb_naoh': 'NaOH added to bottle. Proceeding...',
    'fb_naoh_wait': 'NaOH added to bottle. Now move the plant to the lab bench.',
    'fb_cork': 'Cork attached! Now drag leaf to bottle.',
    'fb_sealed': 'Leaf sealed inside bottle. Proceeding...',
    'fb_sunlit': 'Placed under the sun lamp.',
    'fb_time6': 'Photosynthesizing... 6 Hours elapsed.',
    'fb_station': 'Starch test started. Processing...',
    'fb_iodine_s2': 'Iodine added to the Test Leaf.',
    // Wrong moves.
    'err_wrong_place': "That doesn't go there. Follow the current step.",
    'err_wrong_tube': 'Each leaf goes into its own labelled test tube.',
    'err_leaf_first': 'Put the leaf into this test tube first.',
    'err_tile_first': 'Place both leaves on the white tile first.',
    'err_sun_first': 'Test the Sunlight Leaf first.',
    'err_sun_done': 'The Sunlight Leaf is already tested. Now test the Dark Leaf.',
    'err_cork_first': 'Attach the split cork to the bottle first.',
    // Conclusions.
    's1_heading': 'Results Overview',
    's1_body': "The 'Sunlight' leaf proved that starch is only made in the green parts "
        '(where chlorophyll is present).\n\n'
        "The 'Dark' leaf proved that even with chlorophyll, no starch is made without sunlight.",
    's1_box': 'Conclusion: Both sunlight and chlorophyll are essential for photosynthesis.',
    's1_done': 'Scenario 1 Completed. Please try the next scenario.',
    's2_heading': 'Results: The CO₂ Factor',
    's2_body': 'The iodine test visually proved that starch was only produced in the half of '
        'the leaf exposed to the air.\n\n'
        'The NaOH inside the bottle absorbed all the carbon dioxide, halting photosynthesis '
        'in that section.',
    's2_box': 'Conclusion: Carbon Dioxide is essential for photosynthesis.',
    's2_done': 'Scenario 2 Completed.',
  },
  'hi': {
    'app_title': 'प्रकाश संश्लेषण: भोजन संश्लेषण की प्रक्रिया',
    'app_subtitle': 'कक्षा 7 • पौधों में जैव प्रक्रम',
    's1_title': '1. सूर्य का प्रकाश और क्लोरोफिल',
    's2_title': '2. हवा (कार्बन डाइऑक्साइड) की भूमिका',
    'sci_obs': 'वैज्ञानिक निष्कर्ष',
    'exp_out': 'अपेक्षित परिणाम',
    'conclusion_hud': 'निष्कर्ष — परिणाम देखें।',
    'wait36h': '36 घंटे रुकें',
    'wait48h': '48 घंटे रुकें',
    'wait6h': '6 घंटे रुकें',
    'btn_iodine_sun': 'आयोडीन डालें (धूप वाली पत्ती)',
    'btn_iodine_dark': 'आयोडीन डालें (अंधेरे वाली पत्ती)',
    'btn_iodine_s2': 'आयोडीन डालें (परीक्षण पत्ती)',
    'boil_label': 'उबलता पानी',
    'alc_label': 'जल-ऊष्मक में ऐल्कोहॉल',
    'tile_label': 'सफ़ेद टाइल',
    'black_box': 'काला बॉक्स',
    'sun_plant': 'धूप वाला पौधा',
    'dark_plant': 'अंधेरे वाला पौधा',
    'sun_leaf': 'धूप वाली पत्ती',
    'dark_leaf': 'अंधेरे वाली पत्ती',
    'hot_water': 'गर्म पानी',
    'alcohol': 'ऐल्कोहॉल',
    'alc_sun': 'ऐल्कोहॉल (धूप)',
    'alc_dark': 'ऐल्कोहॉल (अंधेरा)',
    'iodine': 'आयोडीन',
    'healthy_plant': 'स्वस्थ गमले का पौधा',
    'destarched_plant': 'स्टार्च-रहित पौधा',
    'dark_closet': 'अंधेरी अलमारी',
    'naoh_desc': 'NaOH\n(CO₂ सोखता है)',
    'caustic_soda': 'कास्टिक सोडा',
    'target_leaf': 'लक्षित पत्ती',
    'split_cork': 'चिरा हुआ कॉर्क',
    'exp_setup': 'प्रयोग सेटअप',
    'sun_lamp': 'सन लैंप (धूप)',
    'test_station': 'स्टार्च परीक्षण स्टेशन',
    'blue_black': 'नीला-काला',
    'yellow_brown': 'पीला-भूरा',
    'out_bottle': 'बोतल के बाहर',
    'in_bottle': 'बोतल के अंदर',
    'starch_pres': 'स्टार्च मौजूद (CO₂ उपलब्ध)',
    'starch_abs': 'स्टार्च अनुपस्थित (CO₂ नहीं)',
    'lab_bench': 'लैब बेंच',
    'day_2': 'दिन 2',
    'hours': '{n} घंटे',
    'sun_leaf_result': 'धूप वाली पत्ती (हरे भाग नीले-काले हो गए)',
    'dark_leaf_result': 'अंधेरे वाली पत्ती (कोई स्टार्च नहीं)',
    'fb_covered': 'पौधा ढक दिया गया।',
    'fb_time36': 'समय बीत रहा है... 36 घंटे बीत गए।',
    'fb_extracted': 'पत्तियाँ तोड़ ली गईं। स्टार्च परीक्षण की ओर...',
    'fb_boiling': 'पत्तियाँ उबल रही हैं... कोशिका भित्तियाँ नरम हो रही हैं।',
    'fb_extracting': 'क्लोरोफिल निकल रहा है... ऐल्कोहॉल हरा हो रहा है।',
    'fb_pale': 'पत्तियाँ फीकी पड़ गईं (क्लोरोफिल हट गया)। उन्हें टाइल पर खींचें।',
    'fb_placed': 'पत्तियाँ रख दी गईं। अब धूप वाली पत्ती का परीक्षण करें।',
    'fb_iodine_sun': 'धूप वाली पत्ती पर आयोडीन डाला गया।',
    'fb_test_dark': 'अब अंधेरे वाली पत्ती का परीक्षण करें।',
    'fb_iodine_dark': 'अंधेरे वाली पत्ती पर आयोडीन डाला गया।',
    'fb_in_dark': 'पौधा अंधेरे में रख दिया गया।',
    'fb_time48': 'समय बीत रहा है... 48 घंटे बीत गए।',
    'fb_destarched': 'पौधा अब स्टार्च-रहित है।',
    'fb_naoh': 'बोतल में NaOH डाला गया। आगे बढ़ रहे हैं...',
    'fb_naoh_wait': 'बोतल में NaOH डाला गया। अब पौधे को लैब बेंच पर रखें।',
    'fb_cork': 'कॉर्क लग गया! अब पत्ती को बोतल तक खींचें।',
    'fb_sealed': 'पत्ती बोतल में सील हो गई। आगे बढ़ रहे हैं...',
    'fb_sunlit': 'सेटअप सन लैंप के नीचे रख दिया गया।',
    'fb_time6': 'प्रकाश संश्लेषण हो रहा है... 6 घंटे बीत गए।',
    'fb_station': 'स्टार्च परीक्षण शुरू। प्रक्रिया जारी है...',
    'fb_iodine_s2': 'परीक्षण पत्ती पर आयोडीन डाला गया।',
    'err_wrong_place': 'यह वहाँ नहीं जाता। वर्तमान चरण का पालन करें।',
    'err_wrong_tube': 'हर पत्ती अपनी लेबल वाली परखनली में जाती है।',
    'err_leaf_first': 'पहले पत्ती को इस परखनली में डालें।',
    'err_tile_first': 'पहले दोनों पत्तियाँ सफ़ेद टाइल पर रखें।',
    'err_sun_first': 'पहले धूप वाली पत्ती का परीक्षण करें।',
    'err_sun_done': 'धूप वाली पत्ती का परीक्षण हो चुका है। अब अंधेरे वाली पत्ती का परीक्षण करें।',
    'err_cork_first': 'पहले चिरे हुए कॉर्क को बोतल पर लगाएँ।',
    's1_heading': 'परिणाम का सारांश',
    's1_body': "'धूप' वाली पत्ती ने सिद्ध किया कि स्टार्च केवल हरे भागों में ही बनता है "
        '(जहाँ क्लोरोफिल मौजूद होता है)।\n\n'
        "'अंधेरे' वाली पत्ती ने सिद्ध किया कि क्लोरोफिल होने पर भी सूर्य के प्रकाश के बिना "
        'स्टार्च नहीं बनता।',
    's1_box': 'निष्कर्ष: प्रकाश संश्लेषण के लिए सूर्य का प्रकाश और क्लोरोफिल दोनों आवश्यक हैं।',
    's1_done': 'परिदृश्य 1 पूरा हुआ। कृपया अगला परिदृश्य आज़माएँ।',
    's2_heading': 'परिणाम: CO₂ का प्रभाव',
    's2_body': 'आयोडीन परीक्षण ने साबित कर दिया कि स्टार्च केवल पत्ती के उस आधे भाग में बना '
        'जो हवा के संपर्क में था।\n\n'
        'बोतल के अंदर रखे NaOH ने सारी कार्बन डाइऑक्साइड सोख ली, जिससे उस भाग में '
        'प्रकाश संश्लेषण रुक गया।',
    's2_box': 'निष्कर्ष: प्रकाश संश्लेषण के लिए कार्बन डाइऑक्साइड आवश्यक है।',
    's2_done': 'परिदृश्य 2 पूरा हुआ।',
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually prove that both sunlight and chlorophyll are necessary for a plant to produce starch.',
      steps: [
        LabStep(
          concept: 'Cover the Plant',
          action: 'You see two identical potted plants with variegated leaves (green and white patches). '
              'DRAG the large black box and DROP it over the plant on the right to cover it completely.',
          observation: 'The plant on the right is now covered by a black box, blocking all light. '
              'The plant on the left remains in bright sunlight.',
        ),
        LabStep(
          concept: 'Passage of Time',
          action: "CLICK the 'Wait 36 Hours' button to simulate the passage of time.",
          observation: 'The simulation time advances by 36 hours. The sun moves across the sky.',
        ),
        LabStep(
          concept: 'Collect the Leaves',
          action: 'DRAG one variegated leaf from the sun-exposed plant to the lab bench. Then, DRAG the black '
              'box off the second plant and DRAG one of its variegated leaves to the lab bench next to the first one.',
          observation:
              "Two leaves are placed side-by-side on the lab bench, one labeled 'Sunlight' and the other 'Dark'.",
        ),
        LabStep(
          concept: 'Boil the Leaves',
          action: "Now, let's test for starch. DRAG both leaves and DROP them into the beaker of boiling water.",
          observation: 'The leaves are placed in the boiling water, which softens them.',
        ),
        LabStep(
          concept: 'Remove the Chlorophyll',
          action: 'DRAG each leaf from the water and DROP it into its own test tube containing alcohol. '
              'Then, DRAG both test tubes and DROP them into the beaker of boiling water.',
          observation: 'The chlorophyll is removed from the leaves, turning the alcohol green and the leaves pale.',
        ),
        LabStep(
          concept: 'Iodine Test: Sunlight Leaf',
          action: 'DRAG the pale leaves out of the test tubes and DROP them onto the white tile. '
              "DRAG the iodine dropper over the 'Sunlight' leaf OR click the Add Iodine button.",
          observation: 'The parts of the leaf that were originally green turn a dark blue-black color. '
              'The white parts remain yellowish-brown.',
        ),
        LabStep(
          concept: 'Iodine Test: Dark Leaf',
          action: "DRAG the iodine dropper over the 'Dark' leaf OR click the Add Iodine button.",
          observation: 'The entire leaf turns a yellowish-brown color. No part turns blue-black.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visually prove that carbon dioxide from the air is necessary for a plant to produce starch.',
      steps: [
        LabStep(
          concept: 'Destarch the Plant',
          action: 'First, we must destarch the plant. DRAG the potted plant and DROP it inside the dark '
              "cupboard. CLICK the 'Wait 48 Hours' button.",
          observation: 'The plant is placed in darkness to use up all its stored starch.',
        ),
        LabStep(
          concept: 'Prepare the CO₂ Trap',
          action: "DRAG the plant from the cupboard to the lab bench. DRAG the beaker of 'Caustic Soda' (NaOH) "
              'and POUR it into the wide-mouthed bottle.',
          observation: 'The caustic soda solution, which absorbs carbon dioxide, is added to the bottle.',
        ),
        LabStep(
          concept: 'Seal Half the Leaf',
          action: 'DRAG the split cork and DROP it onto the mouth of the bottle. Now, carefully DRAG one leaf '
              'from the plant and INSERT its tip into the bottle through the hole in the cork.',
          observation: 'Half of the leaf is sealed inside the bottle (with no CO₂), and the other half remains '
              'outside in the open air.',
        ),
        LabStep(
          concept: 'Expose to Light',
          action: 'DRAG the entire setup (plant and attached bottle) and DROP it under the bright sun lamp. '
              "CLICK the 'Wait 6 Hours' button.",
          observation: 'The plant is exposed to light to allow photosynthesis to occur.',
        ),
        LabStep(
          concept: 'Prepare the Leaf',
          action: 'DRAG the leaf to detach it from the plant. Now perform the iodine test: DRAG the leaf to the '
              'boiling water, then alcohol, and finally to the white tile.',
          observation: 'The leaf is prepared for the iodine test, becoming pale and soft.',
        ),
        LabStep(
          concept: 'Iodine Test',
          action: 'DRAG the iodine dropper over the entire leaf OR click the Add Iodine button.',
          observation: 'The half of the leaf that was outside the bottle turns blue-black. '
              'The half that was inside the bottle remains yellowish-brown.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'दृश्य रूप से सिद्ध करना कि पौधे को स्टार्च बनाने के लिए सूर्य का प्रकाश और क्लोरोफिल दोनों आवश्यक हैं।',
      steps: [
        LabStep(
          concept: 'पौधे को ढकें',
          action: 'आपके सामने चितकबरी पत्तियों (हरे और सफ़ेद धब्बों वाली) वाले दो एक जैसे गमले के पौधे हैं। '
              'बड़े काले बॉक्स को खींचें और दाईं ओर वाले पौधे पर छोड़ दें ताकि वह पूरी तरह ढक जाए।',
          observation: 'दाईं ओर का पौधा अब काले बॉक्स से ढका है, जिससे उस तक कोई प्रकाश नहीं पहुँचता। '
              'बाईं ओर का पौधा तेज़ धूप में रहता है।',
        ),
        LabStep(
          concept: 'समय का बीतना',
          action: "समय बीतने का अनुकरण करने के लिए '36 घंटे रुकें' बटन पर क्लिक करें।",
          observation: 'सिमुलेशन का समय 36 घंटे आगे बढ़ता है। सूर्य आकाश में घूमता है।',
        ),
        LabStep(
          concept: 'पत्तियाँ एकत्र करें',
          action: 'धूप वाले पौधे से एक चितकबरी पत्ती खींचकर लैब बेंच पर रखें। फिर दूसरे पौधे से काला बॉक्स '
              'हटाएँ और उसकी एक चितकबरी पत्ती को पहली पत्ती के बगल में लैब बेंच पर खींचें।',
          observation: "दो पत्तियाँ लैब बेंच पर साथ-साथ रखी हैं, एक 'धूप' और दूसरी 'अंधेरा' लेबल वाली।",
        ),
        LabStep(
          concept: 'पत्तियों को उबालें',
          action: 'अब स्टार्च का परीक्षण करेंगे। दोनों पत्तियों को खींचकर उबलते पानी के बीकर में छोड़ें।',
          observation: 'पत्तियाँ उबलते पानी में रखी जाती हैं, जिससे वे नरम हो जाती हैं।',
        ),
        LabStep(
          concept: 'क्लोरोफिल हटाएँ',
          action: 'हर पत्ती को पानी से निकालकर ऐल्कोहॉल वाली अपनी परखनली में छोड़ें। '
              'फिर दोनों परखनलियों को खींचकर उबलते पानी के बीकर में छोड़ें।',
          observation: 'पत्तियों से क्लोरोफिल निकल जाता है, ऐल्कोहॉल हरा हो जाता है और पत्तियाँ फीकी पड़ जाती हैं।',
        ),
        LabStep(
          concept: 'आयोडीन परीक्षण: धूप वाली पत्ती',
          action: 'फीकी पत्तियों को परखनलियों से निकालकर सफ़ेद टाइल पर छोड़ें। '
              "आयोडीन ड्रॉपर को 'धूप' वाली पत्ती पर खींचें या 'आयोडीन डालें' बटन पर क्लिक करें।",
          observation: 'पत्ती के जो भाग पहले हरे थे वे गहरे नीले-काले हो जाते हैं। सफ़ेद भाग पीले-भूरे ही रहते हैं।',
        ),
        LabStep(
          concept: 'आयोडीन परीक्षण: अंधेरे वाली पत्ती',
          action: "आयोडीन ड्रॉपर को 'अंधेरे' वाली पत्ती पर खींचें या 'आयोडीन डालें' बटन पर क्लिक करें।",
          observation: 'पूरी पत्ती पीली-भूरी हो जाती है। कोई भी भाग नीला-काला नहीं होता।',
        ),
      ],
    ),
    LabScenarioData(
      objective: 'दृश्य रूप से सिद्ध करना कि पौधे को स्टार्च बनाने के लिए हवा की कार्बन डाइऑक्साइड आवश्यक है।',
      steps: [
        LabStep(
          concept: 'पौधे को स्टार्च-रहित करें',
          action: 'सबसे पहले पौधे को स्टार्च-रहित करना होगा। गमले के पौधे को खींचकर अंधेरी अलमारी के अंदर छोड़ें। '
              "फिर '48 घंटे रुकें' बटन पर क्लिक करें।",
          observation: 'पौधे को अंधेरे में रखा गया है ताकि वह अपना सारा संग्रहित स्टार्च इस्तेमाल कर ले।',
        ),
        LabStep(
          concept: 'CO₂ सोखने वाली बोतल तैयार करें',
          action: "पौधे को अलमारी से खींचकर लैब बेंच पर रखें। 'कास्टिक सोडा' (NaOH) के बीकर को खींचकर "
              'चौड़े मुँह वाली बोतल में उड़ेलें।',
          observation: 'बोतल में कास्टिक सोडा का घोल डाला जाता है, जो कार्बन डाइऑक्साइड सोख लेता है।',
        ),
        LabStep(
          concept: 'आधी पत्ती को सील करें',
          action: 'चिरे हुए कॉर्क को खींचकर बोतल के मुँह पर छोड़ें। अब पौधे की एक पत्ती को सावधानी से खींचें '
              'और उसका सिरा कॉर्क की दरार से बोतल के अंदर डालें।',
          observation: 'पत्ती का आधा भाग बोतल के अंदर (बिना CO₂ के) सील हो जाता है और बाकी आधा भाग '
              'बाहर खुली हवा में रहता है।',
        ),
        LabStep(
          concept: 'प्रकाश में रखें',
          action: 'पूरे सेटअप (पौधा और जुड़ी हुई बोतल) को खींचकर तेज़ सन लैंप के नीचे छोड़ें। '
              "फिर '6 घंटे रुकें' बटन पर क्लिक करें।",
          observation: 'प्रकाश संश्लेषण होने के लिए पौधे को प्रकाश में रखा जाता है।',
        ),
        LabStep(
          concept: 'पत्ती तैयार करें',
          action: 'पत्ती को पौधे से अलग करने के लिए उसे खींचें। अब आयोडीन परीक्षण करें: पत्ती को उबलते पानी, '
              'फिर ऐल्कोहॉल और अंत में सफ़ेद टाइल पर ले जाएँ।',
          observation: 'आयोडीन परीक्षण के लिए पत्ती तैयार हो जाती है; वह फीकी और नरम हो जाती है।',
        ),
        LabStep(
          concept: 'आयोडीन परीक्षण',
          action: "आयोडीन ड्रॉपर को पूरी पत्ती पर खींचें या 'आयोडीन डालें' बटन पर क्लिक करें।",
          observation: 'पत्ती का जो आधा भाग बोतल के बाहर था वह नीला-काला हो जाता है। '
              'जो आधा भाग बोतल के अंदर था वह पीला-भूरा ही रहता है।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

/// The HTML `#scene-content` box (900 × 600 px).
const Size _design = Size(900, 600);

/// Scene layout in design px (the HTML absolute positions, tidied so that
/// every object sits on a bench and fits inside its container).
abstract final class _G {
  // Scenario 1, outdoors (steps 1–2).
  static const double ground = 400;
  static const Offset plantA = Offset(230, 400);
  static const Offset plantB = Offset(680, 400);
  static const Offset sun = Offset(95, 95);
  static const Offset boxStart = Offset(455, 175);
  static const Offset boxCover = Offset(695, 264);
  static const Rect zonePlantB = Rect.fromLTRB(590, 150, 770, 402);

  // Scenario 1, laboratory (steps 3–8).
  static const double s1Counter = 331;
  static const Offset labPlantA = Offset(180, 336);
  static const Offset labPlantB = Offset(480, 336);
  static const Offset boxLabCover = Offset(495, 200);
  static const Offset boxParked = Offset(775, 196);
  static const Rect zoneBench = Rect.fromLTRB(150, 360, 750, 452);
  static const Rect zoneBenchEdge = Rect.fromLTRB(680, 40, 900, 336);
  static const Offset benchSun = Offset(320, 405);
  static const Offset benchDark = Offset(580, 405);
  static const Rect beaker = Rect.fromLTRB(385, 158, 515, 320);
  static const Rect hotPlate = Rect.fromLTRB(365, 320, 535, 340);
  static const double beakerLevel = 0.55;
  static const Offset waterSun = Offset(428, 250);
  static const Offset waterDark = Offset(474, 262);
  static const Offset tubeSunHome = Offset(200, 254);
  static const Offset tubeDarkHome = Offset(700, 254);
  static const Size tube = Size(34, 150);
  static const Offset tubeSunIn = Offset(428, 236);
  static const Offset tubeDarkIn = Offset(472, 236);
  static const Rect tile = Rect.fromLTRB(230, 372, 670, 456);
  static const Offset tileSun = Offset(345, 412);
  static const Offset tileDark = Offset(555, 412);
  static const Offset iodineS1 = Offset(100, 412); // iodine bottle base
  static const Offset dropperS1 = Offset(100, 300);

  // Scenario 2.
  static const double floor = 455;
  static const Offset s2Plant = Offset(230, 455); // pot base
  static const Rect closetRight = Rect.fromLTRB(480, 100, 790, 455);
  static const Rect closetLeft = Rect.fromLTRB(40, 100, 350, 455);
  static const Offset plantInCloset = Offset(635, 440);
  static const Offset plantInClosetL = Offset(195, 440);
  static const Rect benchSlab = Rect.fromLTRB(400, 330, 830, 385);
  static const Rect zoneS2Bench = Rect.fromLTRB(400, 130, 830, 385);
  static const Offset plantOnBench = Offset(500, 332);
  static const Offset bottleBench = Offset(650, 332);
  static const double bottleBenchScale = 0.9;
  static const Offset naohHome = Offset(755, 283);
  static const Offset naohPour = Offset(705, 140);

  static const double s2Counter = 450;
  static const Offset bigPlant = Offset(220, 455);
  static const double bigPlantScale = 1.35;
  static const Offset bigBottle = Offset(640, 455);
  static const double bigBottleScale = 1.27;
  static const Offset corkHome = Offset(755, 175);
  static const Offset branchTip = Offset(330, 208); // target leaf petiole
  static const double leafAngle = 0.21; // HTML rotate-12
  static const Offset setupStart = Offset(200, 298);
  static const Offset setupInSun = Offset(590, 298);
  static const Offset sunZone = Offset(600, 275);
  static const double sunZoneR = 195;
  static const Offset lamp = Offset(742, 100);

  static const Offset fadedSetup = Offset(150, 320);
  static const Offset leaf2Home = Offset(330, 410);
  static const Rect station = Rect.fromLTRB(400, 170, 830, 455);
  static const Rect boilBeaker = Rect.fromLTRB(425, 296, 505, 428);
  static const Rect alcBeaker = Rect.fromLTRB(575, 296, 655, 428);
  static const Rect stationTile = Rect.fromLTRB(700, 406, 810, 442);
  static const Offset leafInBoil = Offset(465, 372);
  static const Offset leafInAlc = Offset(615, 372);
  static const Offset leafOnStationTile = Offset(755, 420);

  static const double s2TileCounter = 380;
  static const Rect s2Tile = Rect.fromLTRB(270, 400, 630, 495);
  static const Offset s2Leaf = Offset(450, 446);
  static const Offset iodineS2 = Offset(720, 410);
  static const Offset dropperS2 = Offset(720, 298);
}

/// One draggable object of the scene: centre, rotation and scale, with an
/// optional tween (the HTML CSS transitions and snap-backs).
class _Item {
  _Item(
    this.id,
    Offset c,
    this.size, {
    double rot = 0,
    double scl = 1,
    this.draggable = true,
    this.lockHint,
  })  : home = c,
        homeRot = rot,
        homeScl = scl,
        _c = c,
        _rot = rot,
        _scl = scl;

  final String id;

  /// Unscaled hit box.
  final Size size;
  bool draggable;

  /// Error toast key shown when the item is grabbed while it is locked.
  String? lockHint;

  /// Where a wrong drop sends the item back to.
  Offset home;
  double homeRot;
  double homeScl;

  Offset _c;
  double _rot;
  double _scl;
  Offset _fc = Offset.zero;
  double _frot = 0;
  double _fscl = 1;
  double _t0 = 0;
  double _dur = 0;

  double _k(double t) => Curves.easeInOutCubic.transform(((t - _t0) / _dur).clamp(0.0, 1.0));

  Offset at(double t) => _dur <= 0 ? _c : Offset.lerp(_fc, _c, _k(t))!;
  double rotAt(double t) => _dur <= 0 ? _rot : _frot + (_rot - _frot) * _k(t);
  double sclAt(double t) => _dur <= 0 ? _scl : _fscl + (_scl - _fscl) * _k(t);
  bool moving(double t) => _dur > 0 && t < _t0 + _dur;

  /// Stops any tween where it is (start of a drag).
  void freeze(double t) {
    _c = at(t);
    _rot = rotAt(t);
    _scl = sclAt(t);
    _dur = 0;
  }

  /// Follows the pointer.
  void jump(Offset c) {
    _c = c;
    _dur = 0;
  }

  void moveTo(double now, Offset c, {double? rot, double? scl, double dur = 0.35}) {
    _fc = at(now);
    _frot = rotAt(now);
    _fscl = sclAt(now);
    _c = c;
    _rot = rot ?? _frot;
    _scl = scl ?? _fscl;
    _t0 = now;
    _dur = dur;
  }

  void goHome(double now) => moveTo(now, home, rot: homeRot, scl: homeScl, dur: 0.3);

  Rect hitRect(double t) {
    final s = sclAt(t);
    final upright = math.sin(rotAt(t)).abs() > 0.7;
    final w = (upright ? size.height : size.width) * s;
    final h = (upright ? size.width : size.height) * s;
    return Rect.fromCenter(center: at(t), width: w, height: h).inflate(12);
  }
}

/// A drop target (HTML `.dropzone`).
class _Zone {
  const _Zone(this.id, this.rect, {this.circle = false});
  final String id;
  final Rect rect;
  final bool circle;

  bool hit(Offset p, {double slack = 30}) => circle
      ? (p - rect.center).distance <= rect.width / 2 + slack
      : rect.inflate(slack).contains(p);
}

/// A falling iodine drop (HTML `drop.animate(...)`).
class _Drop {
  const _Drop(this.from, this.to, this.t0);
  final Offset from;
  final Offset to;
  final double t0;
}

/// One canvas-confetti particle (`confetti()` defaults: spread, decay 0.9,
/// gravity 3 px per frame, 200 ticks).
class _Fetti {
  const _Fetti({
    required this.angle,
    required this.velocity,
    required this.color,
    required this.size,
    required this.wobbleSpeed,
    required this.phase,
    required this.circle,
  });
  final double angle;
  final double velocity;
  final Color color;
  final double size;
  final double wobbleSpeed;
  final double phase;
  final bool circle;
}

/// Mutable scene model read by the painter every frame (the HTML `state`
/// object plus what `render2DScene()` built for the current step).
class _PhotoScene {
  int scenario = 0;

  /// 1-based step; `steps.length + 1` once the scenario is finished.
  int step = 1;
  double time = 0;
  final Map<String, _Item> items = {};

  String? dragId;
  Offset grabOffset = Offset.zero;
  Offset dragFrom = Offset.zero;
  _Zone? dragZone;
  bool dragHot = false;

  /// An animation sequence is running (inputs are ignored, like the HTML
  /// while its timeouts run).
  bool busy = false;

  // Scenario 1 (HTML `s1_progress`).
  bool boxMoved = false;
  bool sunBench = false, darkBench = false;
  bool sunWater = false, darkWater = false;
  bool sunTube = false, darkTube = false;
  bool sunTubeIn = false, darkTubeIn = false;
  bool sunTile = false, darkTile = false;

  // Scenario 2.
  bool plantInCloset = false;
  bool plantOnBench = false;
  bool naohPoured = false;
  bool corkOn = false;
  bool leafSealed = false;
  bool setupInSun = false;
  bool legend = false;

  // Animation start times (scene seconds).
  double? waitStart;
  double? boilStart;
  double? paleStart;
  double? sunIodineStart;
  double? darkIodineStart;
  double? pourStart;
  double? s2PaleStart;
  double? s2IodineStart;
  _Drop? drop;

  // Confetti burst (HTML `confetti()`).
  double? confettiStart;
  final List<_Fetti> confetti = [];

  double prog(double? start, double dur) => start == null ? 0 : ((time - start) / dur).clamp(0.0, 1.0);

  /// Chlorophyll removed (scenario 1, alcohol bath).
  double get pale => step >= 6 ? 1 : (step == 5 ? prog(paleStart, 2.0) : 0);
  double get sunIodine => step >= 7 ? 1 : (step == 6 ? prog(sunIodineStart, 1.4) : 0);
  double get darkIodine => step >= 8 ? 1 : (step == 7 ? prog(darkIodineStart, 1.4) : 0);
  double get s2Pale => step >= 6 ? 1 : (step == 5 ? prog(s2PaleStart, 1.6) : 0);
  double get s2Iodine => step >= 7 ? 1 : (step == 6 ? prog(s2IodineStart, 2.0) : 0);
  double get naohLevel => naohPoured ? 1 : prog(pourStart, 0.95);

  void reset() {
    items.clear();
    dragId = null;
    dragZone = null;
    dragHot = false;
    busy = false;
    boxMoved = sunBench = darkBench = sunWater = darkWater = false;
    sunTube = darkTube = sunTubeIn = darkTubeIn = sunTile = darkTile = false;
    plantInCloset = plantOnBench = naohPoured = corkOn = leafSealed = setupInSun = legend = false;
    waitStart = boilStart = paleStart = sunIodineStart = darkIodineStart = null;
    pourStart = s2PaleStart = s2IodineStart = null;
    drop = null;
    confettiStart = null;
    confetti.clear();
  }

  void add(_Item it) => items[it.id] = it;
}

/// Pan recognizer that only claims pointers starting on a scene object, so
/// the zoom viewer still pans elsewhere when the camera is unlocked.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch10A2PhotosynthesisTheProcessOfFoodSynthesisPageState
    extends State<Ch10A2PhotosynthesisTheProcessOfFoodSynthesisPage> with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _PhotoScene _scene = _PhotoScene();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  late final Ticker _ticker;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];
  double get _now => _scene.time;

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
    _buildS1(1);
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

  // ------------------------------------------------------------ scenario

  /// HTML `loadScenario()` / `resetScenarioState()`.
  void _resetScenario() {
    _lab.cancelPending();
    _scene.reset();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _scene.scenario = index;
      _resetScenario();
      _enterStep(1);
    });
  }

  void _fullReset() {
    setState(() {
      _scene.scenario = 0;
      _resetScenario();
      _enterStep(1);
    });
  }

  /// HTML `completeStep()` + `render2DScene()`: builds the draggable
  /// objects of the new step.
  void _enterStep(int step) {
    final sc = _scene;
    sc
      ..step = step
      ..busy = false
      ..dragId = null
      ..dragZone = null
      ..items.clear();
    if (sc.scenario == 0) {
      _buildS1(step);
    } else {
      _buildS2(step);
    }
    if (mounted) setState(() {});
  }

  void _buildS1(int step) {
    final sc = _scene;
    // The test leaf grows from the stem 128 px above the pot base at -0.35 rad.
    Offset onStem(Offset base) => base + Offset(40 * math.cos(-0.35), -128 + 40 * math.sin(-0.35));
    switch (step) {
      case 1:
        sc.add(_Item('box', _G.boxStart, const Size(210, 280)));
      case 3:
        sc.add(_Item('leafDark', onStem(_G.labPlantB), const Size(100, 50),
            rot: -0.35, scl: 0.8, draggable: false));
        sc.add(_Item('box', _G.boxLabCover, const Size(210, 280)));
        sc.add(_Item('leafSun', onStem(_G.labPlantA), const Size(100, 50), rot: -0.35, scl: 0.8));
      case 4:
        sc.add(_Item('leafSun', _G.benchSun, const Size(100, 50), rot: -0.12, scl: 0.96));
        sc.add(_Item('leafDark', _G.benchDark, const Size(100, 50), rot: 0.1, scl: 0.96));
      case 5:
        sc.sunWater = sc.darkWater = true;
        sc.add(_Item('tubeSun', _G.tubeSunHome, _G.tube, draggable: false, lockHint: 'err_leaf_first'));
        sc.add(_Item('tubeDark', _G.tubeDarkHome, _G.tube, draggable: false, lockHint: 'err_leaf_first'));
        sc.add(_Item('leafDark', _G.waterDark, const Size(100, 50), rot: -0.4, scl: 0.46));
        sc.add(_Item('leafSun', _G.waterSun, const Size(100, 50), rot: 0.5, scl: 0.46));
      case 6:
        sc.add(_Item('leafSun', _G.tubeSunIn + const Offset(0, 37), const Size(100, 50),
            rot: -math.pi / 2, scl: 0.44));
        sc.add(_Item('leafDark', _G.tubeDarkIn + const Offset(0, 37), const Size(100, 50),
            rot: -math.pi / 2, scl: 0.44));
        sc.add(_Item('dropper', _G.dropperS1, const Size(36, 120)));
        _lab.showToast(_t('fb_pale'));
      case 7:
        sc.sunTile = sc.darkTile = true;
        sc.add(_Item('dropper', _G.dropperS1, const Size(36, 120)));
        _lab.showToast(_t('fb_test_dark'), sound: false);
      case 8:
        _lab.after(const Duration(milliseconds: 1000), _finishScenario);
    }
  }

  void _buildS2(int step) {
    final sc = _scene;
    switch (step) {
      case 1:
        sc.add(_Item('plant', _G.s2Plant + const Offset(0, -154), const Size(200, 300), scl: 1.1));
      case 2:
        sc.add(_Item('plant', _G.plantInClosetL + const Offset(0, -133), const Size(200, 300), scl: 0.95));
        sc.add(_Item('naoh', _G.naohHome, const Size(64, 96)));
      case 3:
        final c = _G.branchTip + Offset(60 * math.cos(_G.leafAngle), 60 * math.sin(_G.leafAngle));
        sc.add(_Item('leaf', c, const Size(100, 50),
            rot: _G.leafAngle, scl: 1.2, draggable: false, lockHint: 'err_cork_first'));
        sc.add(_Item('cork', _G.corkHome, const Size(60, 50)));
      case 4:
        sc.add(_Item('setup', _G.setupStart, const Size(300, 310)));
      case 5:
        sc.add(_Item('leaf2', _G.leaf2Home, const Size(100, 50), rot: _G.leafAngle, scl: 1.0));
      case 6:
        sc.add(_Item('dropper', _G.dropperS2, const Size(36, 120)));
      case 7:
        _lab.after(const Duration(milliseconds: 1000), _finishScenario);
    }
  }

  /// HTML step 7 / 6 render: conclusion popup + `confetti()` after 1 s.
  void _finishScenario() {
    if (!mounted) return;
    final scenario = _scene.scenario;
    _burstConfetti();
    _lab.showScenarioConclusion(
      scenarioIndex: scenario,
      totalScenarios: 2,
      delay: Duration.zero,
      title: () => _t('sci_obs'),
      heading: () => _t(scenario == 0 ? 's1_heading' : 's2_heading'),
      body: () => _t(scenario == 0 ? 's1_body' : 's2_body'),
      extra: () => _conclusionExtra(scenario),
    );
  }

  void _burstConfetti() {
    const colors = [
      Color(0xFF26CCFF),
      Color(0xFFA25AFD),
      Color(0xFFFF5E7E),
      Color(0xFF88FF5A),
      Color(0xFFFCFF42),
      Color(0xFFFFA62D),
      Color(0xFFFF36FF),
    ];
    final rng = math.Random(7 + _scene.scenario);
    final sc = _scene;
    sc.confetti.clear();
    for (var i = 0; i < 110; i++) {
      final spread = 70 * math.pi / 180;
      sc.confetti.add(_Fetti(
        angle: -math.pi / 2 + spread / 2 - rng.nextDouble() * spread,
        velocity: 45 * 0.5 + rng.nextDouble() * 45,
        color: colors[i % colors.length],
        size: 7 + rng.nextDouble() * 5,
        wobbleSpeed: math.min(0.11, rng.nextDouble() * 0.1 + 0.05),
        phase: rng.nextDouble() * math.pi * 2,
        circle: i % 3 == 0,
      ));
    }
    sc.confettiStart = sc.time;
    _lab.after(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      setState(() {
        sc.confettiStart = null;
        sc.confetti.clear();
      });
    });
    setState(() {});
  }

  // ---------------------------------------------------------- dragging

  /// Drop zones of the current step.
  List<_Zone> _zones() {
    final sc = _scene;
    if (sc.scenario == 0) {
      switch (sc.step) {
        case 1:
          return const [_Zone('plantB', _G.zonePlantB)];
        case 3:
          return const [_Zone('bench', _G.zoneBench), _Zone('benchEdge', _G.zoneBenchEdge)];
        case 4:
          return [_Zone('beaker', _G.beaker.inflate(10))];
        case 5:
          return [
            _Zone('beaker', _G.beaker.inflate(10)),
            for (final id in ['tubeSun', 'tubeDark'])
              if (sc.items[id] case final it?) _Zone(id, it.hitRect(sc.time)),
          ];
        case 6:
          return [
            const _Zone('tile', _G.tile),
            if (sc.sunTile) _Zone('leafSunTile', Rect.fromCenter(center: _G.tileSun, width: 140, height: 74)),
            if (sc.darkTile) _Zone('leafDarkTile', Rect.fromCenter(center: _G.tileDark, width: 140, height: 74)),
          ];
        case 7:
          return [
            _Zone('leafSunTile', Rect.fromCenter(center: _G.tileSun, width: 140, height: 74)),
            _Zone('leafDarkTile', Rect.fromCenter(center: _G.tileDark, width: 140, height: 74)),
          ];
      }
    } else {
      switch (sc.step) {
        case 1:
          return const [_Zone('closet', _G.closetRight)];
        case 2:
          return [
            _Zone('bottle', _bottleRect(_G.bottleBench, _G.bottleBenchScale)),
            const _Zone('bench', _G.zoneS2Bench),
            const _Zone('closet', _G.closetLeft),
          ];
        case 3:
          return [_Zone('bottle', _bottleRect(_G.bigBottle, _G.bigBottleScale))];
        case 4:
          return [_Zone('sun', Rect.fromCircle(center: _G.sunZone, radius: _G.sunZoneR), circle: true)];
        case 5:
          return const [_Zone('station', _G.station)];
        case 6:
          return [_Zone('leaf2', Rect.fromCenter(center: _G.s2Leaf, width: 190, height: 96))];
      }
    }
    return const [];
  }

  /// The zone each object must be dropped on in this step.
  String? _targetOf(String id) {
    final sc = _scene;
    if (sc.scenario == 0) {
      switch ((sc.step, id)) {
        case (1, 'box'):
          return 'plantB';
        case (3, 'box'):
          return 'benchEdge';
        case (3, _):
          return 'bench';
        case (4, _):
          return 'beaker';
        case (5, 'leafSun'):
          return 'tubeSun';
        case (5, 'leafDark'):
          return 'tubeDark';
        case (5, _):
          return 'beaker';
        case (6, 'dropper'):
          return 'leafSunTile';
        case (6, _):
          return 'tile';
        case (7, 'dropper'):
          return 'leafDarkTile';
      }
    } else {
      switch ((sc.step, id)) {
        case (1, _):
          return 'closet';
        case (2, 'plant'):
          return 'bench';
        case (2, 'naoh'):
          return 'bottle';
        case (3, _):
          return 'bottle';
        case (4, _):
          return 'sun';
        case (5, _):
          return 'station';
        case (6, _):
          return 'leaf2';
      }
    }
    return null;
  }

  /// The point of an object that must land in its zone (the dropper's tip).
  Offset _refPoint(_Item it) => it.id == 'dropper' ? it.at(_now) + const Offset(0, 58) : it.at(_now);

  _Item? _hitItem(Offset p) {
    final list = _scene.items.values.toList();
    for (var i = list.length - 1; i >= 0; i--) {
      final it = list[i];
      if (!it.draggable && it.lockHint == null) continue;
      if (it.hitRect(_now).contains(p)) return it;
    }
    return null;
  }

  bool _accepts(Offset p) =>
      _lab.isLabActive && _lab.popup == null && !_scene.busy && _scene.dragId == null && _hitItem(p) != null;

  void _grab(Offset p) {
    final sc = _scene;
    if (sc.busy || sc.dragId != null) return;
    final it = _hitItem(p);
    if (it == null) return;
    if (!it.draggable) {
      _lab.showToast(_t(it.lockHint!), isError: true);
      return;
    }
    it.freeze(_now);
    _Audio.play(_Sound.pickup);
    setState(() {
      sc
        ..dragId = it.id
        ..grabOffset = p - it.at(_now)
        ..dragFrom = it.at(_now);
      final target = _targetOf(it.id);
      sc.dragZone = target == null ? null : _zones().where((z) => z.id == target).firstOrNull;
      sc.dragHot = false;
    });
  }

  void _dragTo(Offset p) {
    final sc = _scene;
    final id = sc.dragId;
    if (id == null) return;
    final it = sc.items[id]!;
    it.jump(p - sc.grabOffset);
    final hot = sc.dragZone?.hit(_refPoint(it)) ?? false;
    if (hot != sc.dragHot) setState(() => sc.dragHot = hot);
  }

  /// HTML pointerup: `handleOrganicDrop()` when over the right zone,
  /// otherwise the object snaps back.
  void _release() {
    final sc = _scene;
    final id = sc.dragId;
    if (id == null) return;
    final it = sc.items[id]!;
    final p = _refPoint(it);
    final moved = (it.at(_now) - sc.dragFrom).distance > 12;
    final zones = _zones();
    final target = _targetOf(id);
    final origin = zones.where((z) => z.hit(sc.dragFrom, slack: 0)).map((z) => z.id).toSet();
    setState(() {
      sc
        ..dragId = null
        ..dragZone = null
        ..dragHot = false;
    });
    final good = zones.where((z) => z.id == target && z.hit(p)).firstOrNull;
    if (good != null && moved) {
      _Audio.play(_Sound.drop);
      final error = _onDrop(it, good.id);
      if (error != null) {
        it.goHome(_now);
        _lab.showToast(_t(error), isError: true);
      }
      setState(() {});
      return;
    }
    it.goHome(_now);
    final wrong = zones.where((z) => z.id != target && !origin.contains(z.id) && z.hit(p, slack: 0)).firstOrNull;
    if (moved && wrong != null) _lab.showToast(_t(_wrongHint(id, wrong.id)), isError: true);
    setState(() {});
  }

  String _wrongHint(String id, String zone) {
    final sc = _scene;
    if (sc.scenario == 0) {
      if (sc.step == 5 && id.startsWith('leaf') && zone.startsWith('tube')) return 'err_wrong_tube';
      if (sc.step == 6 && id == 'dropper') {
        return sc.sunTile && sc.darkTile ? 'err_sun_first' : 'err_tile_first';
      }
      if (sc.step == 7 && id == 'dropper') return 'err_sun_done';
    }
    return 'err_wrong_place';
  }

  /// HTML `handleOrganicDrop()`. Returns an error key when the drop is not
  /// allowed yet.
  String? _onDrop(_Item it, String zone) {
    final sc = _scene;
    final now = _now;
    if (sc.scenario == 0) {
      switch (sc.step) {
        case 1:
          it
            ..draggable = false
            ..moveTo(now, _G.boxCover, dur: 0.4);
          sc.busy = true;
          _lab.showToast(_t('fb_covered'));
          _lab.after(const Duration(milliseconds: 600), () => _enterStep(2));
        case 3:
          if (it.id == 'box') {
            it
              ..moveTo(now, _G.boxParked, dur: 0.3)
              ..home = _G.boxParked;
            sc.boxMoved = true;
            sc.items['leafDark']?.draggable = true;
          } else {
            final sun = it.id == 'leafSun';
            it
              ..draggable = false
              ..moveTo(now, sun ? _G.benchSun : _G.benchDark, rot: sun ? -0.12 : 0.1, scl: 0.96);
            if (sun) {
              sc.sunBench = true;
            } else {
              sc.darkBench = true;
            }
            if (sc.sunBench && sc.darkBench) {
              sc.busy = true;
              _lab.showToast(_t('fb_extracted'));
              _lab.after(const Duration(milliseconds: 1500), () => _enterStep(4));
            }
          }
        case 4:
          final sun = it.id == 'leafSun';
          it
            ..draggable = false
            ..moveTo(now, sun ? _G.waterSun : _G.waterDark, rot: sun ? 0.5 : -0.4, scl: 0.46, dur: 0.45);
          if (sun) {
            sc.sunWater = true;
          } else {
            sc.darkWater = true;
          }
          if (sc.sunWater && sc.darkWater) {
            sc
              ..busy = true
              ..boilStart = now;
            _Audio.play(_Sound.bubble);
            _lab.showToast(_t('fb_boiling'), sound: false);
            _lab.after(const Duration(milliseconds: 2000), () {
              _Audio.play(_Sound.correct);
              _enterStep(5);
            });
          }
        case 5:
          if (it.id.startsWith('leaf')) {
            final sun = it.id == 'leafSun';
            sc.items.remove(it.id);
            final tube = sc.items[sun ? 'tubeSun' : 'tubeDark']!;
            tube
              ..draggable = true
              ..lockHint = null;
            if (sun) {
              sc.sunTube = true;
            } else {
              sc.darkTube = true;
            }
          } else {
            final sun = it.id == 'tubeSun';
            it
              ..draggable = false
              ..moveTo(now, sun ? _G.tubeSunIn : _G.tubeDarkIn, dur: 0.4);
            if (sun) {
              sc.sunTubeIn = true;
            } else {
              sc.darkTubeIn = true;
            }
          }
          if (sc.sunTube && sc.darkTube && sc.sunTubeIn && sc.darkTubeIn) {
            sc
              ..busy = true
              ..paleStart = now + 0.3;
            _Audio.play(_Sound.bubble);
            _lab.showToast(_t('fb_extracting'), sound: false);
            _lab.after(const Duration(milliseconds: 2500), () => _enterStep(6));
          }
        case 6:
          if (it.id == 'dropper') {
            if (!(sc.sunTile && sc.darkTile)) return 'err_tile_first';
            _iodineS1(true);
          } else {
            final sun = it.id == 'leafSun';
            it
              ..draggable = false
              ..moveTo(now, sun ? _G.tileSun : _G.tileDark, rot: 0, scl: 1.25, dur: 0.4);
            if (sun) {
              sc.sunTile = true;
            } else {
              sc.darkTile = true;
            }
            if (sc.sunTile && sc.darkTile) _lab.showToast(_t('fb_placed'));
          }
        case 7:
          _iodineS1(false);
      }
    } else {
      switch (sc.step) {
        case 1:
          it
            ..draggable = false
            ..moveTo(now, _G.plantInCloset + const Offset(0, -133), scl: 0.95, dur: 0.4);
          sc.plantInCloset = true;
          _lab.showToast(_t('fb_in_dark'), sound: false);
        case 2:
          if (it.id == 'plant') {
            it
              ..draggable = false
              ..moveTo(now, _G.plantOnBench + const Offset(0, -119), scl: 0.85, dur: 0.4);
            sc.plantOnBench = true;
            _checkBench();
          } else {
            _pour(it);
          }
        case 3:
          if (it.id == 'cork') {
            it
              ..draggable = false
              ..moveTo(now, _corkSeat(_G.bigBottle, _G.bigBottleScale), dur: 0.35);
            sc.corkOn = true;
            sc.items['leaf']
              ?..draggable = true
              ..lockHint = null;
            _lab.showToast(_t('fb_cork'), sound: false);
          } else {
            sc
              ..items.remove('leaf')
              ..leafSealed = true
              ..busy = true;
            _lab.showToast(_t('fb_sealed'));
            _lab.after(const Duration(milliseconds: 2000), () => _enterStep(4));
          }
        case 4:
          it
            ..draggable = false
            ..moveTo(now, _G.setupInSun, dur: 0.45);
          sc.setupInSun = true;
          _lab.showToast(_t('fb_sunlit'), sound: false);
        case 5:
          _stationSequence(it);
        case 6:
          _iodineS2();
      }
    }
    return null;
  }

  // ----------------------------------------------------------- sequences

  /// HTML `triggerS1Wait36()`: the sun crosses the sky for 36 hours.
  void _wait36() {
    final sc = _scene;
    if (sc.busy) return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      sc
        ..busy = true
        ..waitStart = _now;
    });
    _lab.showToast(_t('fb_time36'), sound: false);
    _lab.after(const Duration(milliseconds: 2500), () {
      sc.waitStart = null;
      _Audio.play(_Sound.correct);
      _enterStep(3);
    });
  }

  /// HTML `addIodineToLeaf()`: dropper over the leaf, a drop falls and the
  /// leaf changes colour; next step 1.5 s later.
  void _iodineS1(bool sun) {
    final sc = _scene;
    final d = sc.items['dropper'];
    if (d == null || sc.busy) return;
    if (sun && !(sc.sunTile && sc.darkTile)) return;
    final leaf = sun ? _G.tileSun : _G.tileDark;
    _dropIodine(d, leaf, () {
      if (sun) {
        sc.sunIodineStart = _now;
      } else {
        sc.darkIodineStart = _now;
      }
      _lab.showToast(_t(sun ? 'fb_iodine_sun' : 'fb_iodine_dark'));
    }, next: () => _enterStep(sun ? 7 : 8), wait: 1500);
  }

  /// HTML `addIodineToLeafS2()`.
  void _iodineS2() {
    final sc = _scene;
    final d = sc.items['dropper'];
    if (d == null || sc.busy) return;
    _dropIodine(d, _G.s2Leaf, () {
      sc
        ..s2IodineStart = _now
        ..legend = true;
      _lab.showToast(_t('fb_iodine_s2'));
    }, next: () => _enterStep(7), wait: 3500);
  }

  void _dropIodine(_Item d, Offset leaf, VoidCallback colour, {required VoidCallback next, required int wait}) {
    final sc = _scene;
    final tip = leaf + const Offset(-8, -46);
    setState(() {
      sc.busy = true;
      d
        ..draggable = false
        ..moveTo(_now, tip - const Offset(0, 58), dur: 0.5);
    });
    _lab.after(const Duration(milliseconds: 600), () {
      sc.drop = _Drop(tip, leaf + const Offset(-8, -4), _now);
      _Audio.play(_Sound.drop);
    });
    _lab.after(const Duration(milliseconds: 1000), () {
      d.moveTo(_now, d.home, dur: 0.5);
      colour();
      setState(() {});
    });
    _lab.after(Duration(milliseconds: 1000 + wait), next);
  }

  /// HTML `triggerS2Wait48()`: "DAY 2" blackout, then the plant is
  /// destarched.
  void _wait48() {
    final sc = _scene;
    if (sc.busy) return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      sc
        ..busy = true
        ..waitStart = _now;
    });
    _lab.showToast(_t('fb_time48'), sound: false);
    _lab.after(const Duration(milliseconds: 2000), () {
      sc.waitStart = null;
      _enterStep(2);
    });
    _lab.after(const Duration(milliseconds: 2500), () => _lab.showToast(_t('fb_destarched')));
  }

  /// Caustic soda poured into the bottle (HTML: beaker fades, liquid appears).
  void _pour(_Item naoh) {
    final sc = _scene;
    sc.busy = true;
    naoh
      ..draggable = false
      ..moveTo(_now, _G.naohPour, rot: -1.9, dur: 0.45);
    _lab.after(const Duration(milliseconds: 450), () {
      sc.pourStart = _now;
      _Audio.play(_Sound.splash);
    });
    _lab.after(const Duration(milliseconds: 1500), () {
      setState(() {
        sc
          ..naohPoured = true
          ..busy = false
          ..items.remove('naoh');
      });
      _checkBench();
    });
  }

  /// Step 2 of scenario 2 ends once the plant is on the bench and the NaOH
  /// is in the bottle.
  void _checkBench() {
    final sc = _scene;
    if (sc.plantOnBench && sc.naohPoured) {
      sc.busy = true;
      _lab.showToast(_t('fb_naoh'));
      _lab.after(const Duration(milliseconds: 1500), () => _enterStep(3));
    } else if (sc.naohPoured) {
      _lab.showToast(_t('fb_naoh_wait'), sound: false);
    }
  }

  /// HTML `triggerS2Wait6Hours()`: spinning clock under the lamp.
  void _wait6() {
    final sc = _scene;
    if (sc.busy) return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      sc
        ..busy = true
        ..waitStart = _now;
    });
    _lab.showToast(_t('fb_time6'), sound: false);
    _lab.after(const Duration(milliseconds: 2500), () {
      sc.waitStart = null;
      _Audio.play(_Sound.correct);
      _enterStep(5);
    });
  }

  /// HTML `triggerS2StarchTestSequence()`: boiling water → alcohol → tile.
  void _stationSequence(_Item leaf) {
    final sc = _scene;
    sc.busy = true;
    leaf
      ..draggable = false
      ..moveTo(_now, _G.leafInBoil, rot: -0.17, scl: 0.5, dur: 0.8);
    _Audio.play(_Sound.bubble);
    _lab.showToast(_t('fb_station'));
    _lab.after(const Duration(milliseconds: 2000), () {
      leaf.moveTo(_now, _G.leafInAlc, rot: 0.17, scl: 0.5, dur: 0.8);
      sc.s2PaleStart = _now + 0.4;
      _Audio.play(_Sound.bubble);
    });
    _lab.after(const Duration(milliseconds: 4000), () {
      leaf.moveTo(_now, _G.leafOnStationTile, rot: 0, scl: 0.85, dur: 0.8);
    });
    _lab.after(const Duration(milliseconds: 4800), () => _Audio.play(_Sound.drop));
    _lab.after(const Duration(milliseconds: 5000), () => _enterStep(6));
  }

  // ---------------------------------------------------------------- UI

  List<LabAction> _actions() {
    final sc = _scene;
    final free = !sc.busy;
    LabAction wait(String key, VoidCallback onTap) => LabAction(
          label: _t(key),
          icon: Icons.hourglass_bottom_rounded,
          color: _Theme.of(_lab.isDark).accent,
          foreground: _Colors.slate900,
          highlight: free,
          enabled: free,
          silent: true,
          onTap: onTap,
        );
    if (sc.scenario == 0) {
      if (sc.step == 2) return [wait('wait36h', _wait36)];
      if (sc.step == 6) {
        final ready = free && sc.sunTile && sc.darkTile;
        return [
          LabAction(
            label: _t('btn_iodine_sun'),
            icon: Icons.water_drop,
            color: _Theme.of(_lab.isDark).accent,
            foreground: _Colors.slate900,
            enabled: ready,
            highlight: ready,
            onTap: () => _iodineS1(true),
          ),
        ];
      }
      if (sc.step == 7) {
        return [
          LabAction(
            label: _t('btn_iodine_dark'),
            icon: Icons.water_drop,
            color: _Colors.slate500,
            foreground: Colors.white,
            enabled: free,
            highlight: free,
            onTap: () => _iodineS1(false),
          ),
        ];
      }
    } else {
      if (sc.step == 1 && sc.plantInCloset) return [wait('wait48h', _wait48)];
      if (sc.step == 4 && sc.setupInSun) return [wait('wait6h', _wait6)];
      if (sc.step == 6) {
        return [
          LabAction(
            label: _t('btn_iodine_s2'),
            icon: Icons.water_drop,
            color: _Theme.of(_lab.isDark).accent,
            foreground: _Colors.slate900,
            enabled: free,
            highlight: free,
            onTap: _iodineS2,
          ),
        ];
      }
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final p = _Theme.of(_lab.isDark);
        final s = context.labScale;
        final data = _data;
        final sc = _scene;
        final done = sc.step > data.steps.length;
        final current = data.steps[(sc.step - 1).clamp(0, data.steps.length - 1)];
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('s1_title'), _t('s2_title')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: done ? _t('conclusion_hud') : null,
          actions: _actions(),
          sidebarExtraTitle: _t('exp_out'),
          sidebarExtra: _outcomeCard(p, s, current.observation),
          onReset: _fullReset,
          overlays: [
            if (sc.confettiStart != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConfettiPainter(scene: sc, repaint: _frame),
                  ),
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
                    ..accepts = _accepts
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
                painter: _PhotoPainter(
                  scene: sc,
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

  /// HTML accordion "Expected Outcome from the Task" of the current step.
  Widget _outcomeCard(LabPalette p, double s, String text) {
    final f = s * _lab.fontScale;
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.info.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_rounded, size: 15 * s, color: p.info),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: p.textMuted, fontSize: 12 * f, height: 1.4, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// The HTML conclusion box (`bg-green-100` / `bg-blue-100`) and the
  /// "Scenario completed" line.
  Widget _conclusionExtra(int scenario) {
    return Builder(
      builder: (context) {
        final s = context.labScale;
        final p = _Theme.of(_lab.isDark);
        final green = scenario == 0;
        final bg = green ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE);
        final fg = green ? const Color(0xFF166534) : const Color(0xFF1E40AF);
        final border = green ? const Color(0xFF86EFAC) : const Color(0xFF93C5FD);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(12 * s),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Text(
                _t(green ? 's1_box' : 's2_box'),
                textAlign: TextAlign.center,
                style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13 * s, height: 1.35),
              ),
            ),
            SizedBox(height: 10 * s),
            Text(
              _t(green ? 's1_done' : 's2_done'),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12.5 * s),
            ),
          ],
        );
      },
    );
  }
}

/// Bounding box of a wide-mouthed bottle standing on [base] (the drop zone).
Rect _bottleRect(Offset base, double s) =>
    Rect.fromLTRB(base.dx - 55 * s, base.dy - 150 * s, base.dx + 55 * s, base.dy);

/// Where the split cork sits in a bottle's mouth.
Offset _corkSeat(Offset base, double s) => base + Offset(0, -142 * s);

// ============================================================ PAINTING

/// Leaf colour sets.
enum _Look { variegated, green, lime }

/// The HTML `variegatedLeafLarge` paths (viewBox 100 × 50, re-centred on
/// y = 0): the petiole end is at x = 0, the tip at x = 100.
final Path _leafOuter = Path()
  ..moveTo(0, 0)
  ..cubicTo(40, -25, 80, -25, 100, 0)
  ..cubicTo(80, 25, 40, 25, 0, 0)
  ..close();
final Path _leafInner = Path()
  ..moveTo(20, 0)
  ..cubicTo(40, -15, 60, -15, 80, 0)
  ..cubicTo(60, 15, 40, 15, 20, 0)
  ..close();

/// Leaves along the stem: (height above the pot base, angle, length).
const List<(double, double, double)> _leafSpecs = [
  (100, -2.75, 74),
  (128, -0.35, 80), // the leaf that is tested
  (156, -2.55, 68),
  (182, -0.62, 62),
  (212, -1.57, 50),
];

class _PhotoPainter extends CustomPainter {
  _PhotoPainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _PhotoScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  double get _t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = scene;
    if (sc.scenario == 0) {
      if (sc.step <= 2) {
        _s1Outdoor(canvas, size);
      } else {
        _s1Lab(canvas, size);
      }
    } else {
      _s2(canvas, size);
    }
    _paintDrop(canvas);
    _paintDrag(canvas);
    _paintOverlays(canvas, size);
  }

  // ------------------------------------------------------------- items

  /// Draws a scene object unless it is being dragged (drawn last instead).
  void _item(Canvas c, String id) {
    final it = scene.items[id];
    if (it == null || scene.dragId == id) return;
    _drawItem(c, it);
  }

  void _drawItem(Canvas c, _Item it) {
    final sc = scene;
    final p = it.at(_t);
    final r = it.rotAt(_t);
    final s = it.sclAt(_t);
    switch (it.id) {
      case 'box':
        _blackBox(c, p);
        if (sc.step == 1) _tag(c, tr('black_box'), p + const Offset(0, -156), _Colors.slate500);
      case 'leafSun' || 'leafDark':
        final sun = it.id == 'leafSun';
        final bob = (sc.step == 4 || sc.step == 5) && _inWater(it.id) && !it.moving(_t) && sc.dragId != it.id
            ? Offset(0, math.sin(_t * 4 + (sun ? 0 : 1.7)) * 2.5)
            : Offset.zero;
        _testLeaf(c, sun, p + bob, r, s);
        if ((sc.step == 3 || sc.step == 4) && !(sc.step == 4 && _inWater(it.id))) {
          _tag(c, tr(sun ? 'sun_leaf' : 'dark_leaf'), p + Offset(0, -26 - 20 * s), _Colors.slate500, size: 13);
        }
      case 'tubeSun' || 'tubeDark':
        final sun = it.id == 'tubeSun';
        _tubeWithLeaf(c, sun, p);
        if (sc.step == 5 && !(sun ? sc.sunTubeIn : sc.darkTubeIn) && !it.moving(_t)) {
          _tag(c, tr(sun ? 'alc_sun' : 'alc_dark'), p + Offset(0, -_G.tube.height / 2 - 22), _Colors.slate400,
              size: 13);
        }
      case 'dropper':
        _dropper(c, p, idle: it.draggable && sc.dragId != it.id);
        if (!sc.busy) _tag(c, tr('iodine'), p + const Offset(0, -76), _Colors.slate500, size: 13);
      case 'plant':
        final look = sc.step == 1 ? _Look.green : _Look.lime;
        final base = p + Offset(0, 140 * s);
        _plant(c, base, s, look);
        if (sc.step == 1 && !sc.plantInCloset) {
          _tag(c, tr('healthy_plant'), base + Offset(0, -284 * s), _Colors.slate500);
        }
      case 'naoh':
        _naohBeaker(c, p, r, label: !sc.busy);
      case 'cork':
        _cork(c, Rect.fromCenter(center: p, width: 50 * s * _G.bigBottleScale, height: 34 * s * _G.bigBottleScale));
        if (!sc.corkOn) _tag(c, tr('split_cork'), p + const Offset(0, -42), _Colors.slate500);
      case 'leaf':
        final len = 100 * s;
        _leaf(c, p - Offset(math.cos(r), math.sin(r)) * (len / 2), len, r, base: _Colors.lime400);
        _tag(c, tr('target_leaf'), p + const Offset(0, -46), _Colors.green700);
      case 'setup':
        _setup(c, p, 1, leaf: true);
        if (!sc.setupInSun) _tag(c, tr('exp_setup'), p + const Offset(0, -172), _Colors.slate500);
      case 'leaf2':
        _s2Leaf(c, p, r, 100 * s);
        if (sc.step == 5 && !sc.busy) _tag(c, tr('target_leaf'), p + const Offset(0, -38), _Colors.green700);
    }
  }

  bool _inWater(String id) => id == 'leafSun' ? scene.sunWater : scene.darkWater;

  /// The dragged object on top, with the HTML `.dropzone.dragover` cue on
  /// its target.
  void _paintDrag(Canvas c) {
    final sc = scene;
    final id = sc.dragId;
    if (id == null) return;
    final zone = sc.dragZone;
    if (zone != null) _zoneCue(c, zone, sc.dragHot);
    final it = sc.items[id];
    if (it == null) return;
    final r = it.hitRect(_t);
    labGroundShadow(c, Offset(r.center.dx, r.bottom), r.width * 0.7, 16, opacity: 0.22);
    _drawItem(c, it);
  }

  void _zoneCue(Canvas c, _Zone z, bool hot) {
    const green = _Colors.green500;
    final path = Path();
    if (z.circle) {
      path.addOval(z.rect.inflate(6));
    } else {
      path.addRRect(RRect.fromRectAndRadius(z.rect, const Radius.circular(10)));
    }
    if (hot) c.drawPath(path, Paint()..color = green.withValues(alpha: 0.28));
    labDashedPath(
      c,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hot ? 4 : 2.5
        ..color = green.withValues(alpha: hot ? 1 : 0.6),
      dash: 12,
      gap: 8,
      phase: _t * 30,
    );
  }

  // ------------------------------------------------- scenario 1: outdoors

  void _s1Outdoor(Canvas c, Size size) {
    final sc = scene;
    final w = sc.step == 2 ? sc.prog(sc.waitStart, 2.4) : 0.0;
    // 36 h = 1.5 turns of the sun along its arc.
    final th = 0.75 + w * 3 * math.pi;
    final elev = math.sin(th);
    final night = w <= 0 ? 0.0 : ((0.15 - elev) / 0.3).clamp(0.0, 1.0);
    _sky(c, size, night);
    if (w <= 0 || elev > -0.2) {
      final arc = Offset(450 - 430 * math.cos(th), 430 - 390 * math.sin(th));
      final blend = Curves.easeInOut.transform((w / 0.12).clamp(0.0, 1.0));
      _sun(c, Offset.lerp(_G.sun, arc, blend)!, 34);
    }
    _hillsAndGround(c, size, night);
    _plant(c, _G.plantA, 1, _Look.variegated);
    _plant(c, _G.plantB, 1, _Look.variegated);
    if (sc.step == 2) _blackBox(c, _G.boxCover);
    _item(c, 'box');
    if (night > 0) {
      c.drawRect(labBleed(size), Paint()..color = _Colors.slate950.withValues(alpha: 0.38 * night));
    }
    if (sc.step == 2 && sc.waitStart != null) _hoursBadge(c, const Offset(740, 52), (36 * w).round(), w);
  }

  void _sky(Canvas c, Size size, double night) {
    final b = labBleed(size);
    final day = isDark
        ? const [Color(0xFF0C2D6B), Color(0xFF2563EB)]
        : const [Color(0xFF7DD3FC), Color(0xFFE0F2FE)];
    const dark = [Color(0xFF020617), Color(0xFF0F172A)];
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, _G.ground + 10),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(day[0], dark[0], night)!, Color.lerp(day[1], dark[1], night)!],
        ).createShader(const Rect.fromLTRB(0, 0, 900, 400)),
    );
    if (night > 0) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.85 * night);
      for (var i = 0; i < 46; i++) {
        final x = (i * 197.0) % 900;
        final y = 20 + (i * 83.0) % 300;
        c.drawCircle(Offset(x, y), 1 + (i % 3) * 0.6, star);
      }
    }
    // Soft clouds in daylight.
    final cloud = Paint()..color = Colors.white.withValues(alpha: (isDark ? 0.10 : 0.55) * (1 - night));
    for (final (cx, cy, k) in const [(330.0, 70.0, 1.0), (620.0, 40.0, 0.8), (820.0, 120.0, 0.7)]) {
      final o = Offset(cx + math.sin(_t * 0.05 + cx) * 12, cy);
      c.drawOval(Rect.fromCenter(center: o, width: 120 * k, height: 34 * k), cloud);
      c.drawOval(Rect.fromCenter(center: o + Offset(-24 * k, -12 * k), width: 64 * k, height: 40 * k), cloud);
      c.drawOval(Rect.fromCenter(center: o + Offset(22 * k, -14 * k), width: 56 * k, height: 34 * k), cloud);
    }
  }

  void _hillsAndGround(Canvas c, Size size, double night) {
    final b = labBleed(size);
    final hillColor = Color.lerp(
      isDark ? const Color(0xFF14532D) : const Color(0xFF86EFAC),
      const Color(0xFF052E16),
      night,
    )!;
    final hills = Path()..moveTo(b.left, _G.ground);
    for (double x = b.left; x <= b.right; x += 12) {
      hills.lineTo(x, _G.ground - 42 - 26 * math.sin(x / 120) - 14 * math.sin(x / 47 + 1));
    }
    hills
      ..lineTo(b.right, _G.ground)
      ..close();
    c.drawPath(hills, Paint()..color = hillColor);
    final g = Rect.fromLTRB(b.left, _G.ground, b.right, b.bottom);
    c.drawRect(
      g,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF166534), Color(0xFF052E16)]
              : const [Color(0xFF4ADE80), Color(0xFF15803D)],
        ).createShader(Rect.fromLTRB(0, _G.ground, 900, 600)),
    );
    // HTML ground line (`border-b-8 border-slate-300`).
    c.drawRect(
      Rect.fromLTRB(b.left, _G.ground - 2, b.right, _G.ground + 5),
      Paint()..color = (isDark ? _Colors.slate600 : _Colors.slate300).withValues(alpha: 0.9),
    );
    final blade = Paint()
      ..color = (isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A)).withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final x = (i * 61.0) % 960 - 30;
      final y = _G.ground + 22 + (i * 37.0) % 150;
      c.drawLine(Offset(x, y), Offset(x - 3, y - 9), blade);
      c.drawLine(Offset(x + 4, y), Offset(x + 6, y - 8), blade);
    }
  }

  void _sun(Canvas c, Offset p, double r) {
    labGlow(c, p, r * 3.4, _Colors.amber400, intensity: 0.6);
    final ray = Paint()
      ..color = _Colors.amber500
      ..strokeWidth = r * 0.26
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = _t * 0.3 + i * math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a));
      c.drawLine(p + d * r * 1.3, p + d * r * 1.85, ray);
    }
    c.drawCircle(
      p,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFFEF3C7), _Colors.amber400, _Colors.amber500],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: p, radius: r)),
    );
  }

  void _hoursBadge(Canvas c, Offset at, int hours, double k) {
    final r = Rect.fromCenter(center: at, width: 150, height: 52);
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(12)),
      Paint()..color = _Colors.slate900.withValues(alpha: 0.92),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.slate600,
    );
    _clockFace(c, Offset(r.left + 28, at.dy), 17, k * 36 * 2 * math.pi);
    labText(
      c,
      tr('hours').replaceAll('{n}', '$hours'),
      Offset(r.left + 54, at.dy),
      anchor: Alignment.centerLeft,
      size: 24,
      weight: FontWeight.w800,
      color: const Color(0xFF4ADE80),
    );
  }

  void _clockFace(Canvas c, Offset p, double r, double angle) {
    c.drawCircle(p, r, Paint()..color = Colors.white);
    c.drawCircle(
      p,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.13
        ..color = _Colors.slate700,
    );
    final tick = Paint()
      ..color = _Colors.slate500
      ..strokeWidth = r * 0.06;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final d = Offset(math.cos(a), math.sin(a));
      c.drawLine(p + d * r * 0.72, p + d * r * 0.86, tick);
    }
    final hand = Paint()
      ..color = _Colors.red500
      ..strokeWidth = r * 0.09
      ..strokeCap = StrokeCap.round;
    c.drawLine(p, p + Offset(math.sin(angle), -math.cos(angle)) * r * 0.7, hand);
    c.drawLine(
      p,
      p + Offset(math.sin(angle / 12), -math.cos(angle / 12)) * r * 0.45,
      hand..color = _Colors.slate700,
    );
    c.drawCircle(p, r * 0.09, Paint()..color = _Colors.slate700);
  }

  // ---------------------------------------------- scenario 1: laboratory

  void _s1Lab(Canvas c, Size size) {
    _labRoom(c, size, _G.s1Counter);
    switch (scene.step) {
      case 3:
        _s1Leaves(c);
      case 4:
        _s1Boil(c);
      case 5:
        _s1Tubes(c);
      case 6:
        _s1Tile(c);
      case 7:
        _s1Tile(c);
      default:
        _s1Done(c);
    }
  }

  /// Step 3: pluck a leaf from each plant (the dark one is under the box).
  void _s1Leaves(Canvas c) {
    final sc = scene;
    _benchBoard(c, _G.zoneBench);
    _plant(c, _G.labPlantA, 1, _Look.variegated, hideTestLeaf: true, opacity: 0.55);
    _plant(c, _G.labPlantB, 1, _Look.variegated, hideTestLeaf: true, opacity: 0.55);
    _tag(c, tr('sun_plant'), _G.labPlantA + const Offset(0, -282), _Colors.yellow600, size: 15);
    if (sc.boxMoved) _tag(c, tr('dark_plant'), _G.labPlantB + const Offset(0, -282), _Colors.slate600, size: 15);
    _item(c, 'leafDark');
    _item(c, 'box');
    _item(c, 'leafSun');
  }

  /// Step 4: boiling water beaker on a hot plate.
  void _s1Boil(Canvas c) {
    final sc = scene;
    final boil = sc.boilStart != null ? 1.0 : 0.45;
    _hotPlate(c, _G.hotPlate, 1);
    _beakerBack(c, _G.beaker, _Colors.blue500, _G.beakerLevel);
    for (final id in const ['leafSun', 'leafDark']) {
      if (_inWater(id)) _item(c, id);
    }
    _beakerFront(c, _G.beaker, _Colors.blue500, _G.beakerLevel, text: tr('hot_water'), boil: boil);
    _tag(c, tr('boil_label'), Offset(_G.beaker.center.dx, _G.beaker.top - 18), _Colors.slate400, size: 14);
    for (final id in const ['leafSun', 'leafDark']) {
      if (!_inWater(id)) _item(c, id);
    }
  }

  /// Step 5: leaves into the alcohol tubes, tubes into the water bath.
  void _s1Tubes(Canvas c) {
    final sc = scene;
    _rackBack(c, _G.tubeSunHome);
    _rackBack(c, _G.tubeDarkHome);
    _hotPlate(c, _G.hotPlate, 1);
    _beakerBack(c, _G.beaker, _Colors.blue500, _G.beakerLevel);
    if (sc.sunTubeIn) _item(c, 'tubeSun');
    if (sc.darkTubeIn) _item(c, 'tubeDark');
    _item(c, 'leafDark');
    _item(c, 'leafSun');
    final tubesIn = sc.sunTubeIn || sc.darkTubeIn;
    _beakerFront(c, _G.beaker, _Colors.blue500, _G.beakerLevel, text: tubesIn ? null : tr('hot_water'), boil: 0.6);
    _tag(c, tr('boil_label'), Offset(_G.beaker.center.dx, _G.beaker.top - 18), _Colors.slate400, size: 14);
    if (!sc.sunTubeIn) _item(c, 'tubeSun');
    if (!sc.darkTubeIn) _item(c, 'tubeDark');
    _rackFront(c, _G.tubeSunHome);
    _rackFront(c, _G.tubeDarkHome);
  }

  /// Steps 6–7: pale leaves onto the white tile, iodine test.
  void _s1Tile(Canvas c) {
    final sc = scene;
    if (sc.step == 6) {
      c.saveLayer(null, Paint()..color = const Color(0x99000000));
      _hotPlate(c, _G.hotPlate, 1);
      _beakerBack(c, _G.beaker, _Colors.blue500, _G.beakerLevel);
      c.restore();
      for (final sun in const [true, false]) {
        final id = sun ? 'leafSun' : 'leafDark';
        final it = sc.items[id];
        final inTube = it != null && !(sun ? sc.sunTile : sc.darkTile) && sc.dragId != id && !it.moving(_t);
        _tube(
          c,
          Rect.fromCenter(center: sun ? _G.tubeSunIn : _G.tubeDarkIn, width: _G.tube.width, height: _G.tube.height),
          _alcohol(),
          inside: inTube ? () => _drawItem(c, it) : null,
        );
      }
      c.saveLayer(null, Paint()..color = const Color(0x99000000));
      _beakerFront(c, _G.beaker, _Colors.blue500, _G.beakerLevel, boil: 0.5);
      c.restore();
      _tag(c, tr('boil_label'), Offset(_G.beaker.center.dx, _G.beaker.top - 18), _Colors.slate400, size: 14);
    }
    _tile(c, _G.tile);
    _tag(c, tr('tile_label'), Offset(_G.tile.left - 8, _G.tile.center.dy), _Colors.slate400,
        size: 13, anchor: Alignment.centerRight);
    for (final sun in const [true, false]) {
      final placed = sun ? sc.sunTile : sc.darkTile;
      if (!placed) continue;
      final id = sun ? 'leafSun' : 'leafDark';
      if (sc.items[id] != null) {
        _item(c, id);
      } else {
        _testLeaf(c, sun, sun ? _G.tileSun : _G.tileDark, 0, 1.25);
      }
      _tag(c, tr(sun ? 'sun_leaf' : 'dark_leaf'), (sun ? _G.tileSun : _G.tileDark) + const Offset(0, -46),
          _Colors.slate500, size: 13);
    }
    for (final sun in const [true, false]) {
      final id = sun ? 'leafSun' : 'leafDark';
      final it = sc.items[id];
      if (it != null && !(sun ? sc.sunTile : sc.darkTile) && it.moving(_t)) _item(c, id);
    }
    _item(c, 'dropper');
    _iodineBottle(c, _G.iodineS1);
  }

  /// HTML step 7 (index): both results on the tile, enlarged.
  void _s1Done(Canvas c) {
    _tile(c, _G.tile);
    _testLeaf(c, true, _G.tileSun, 0, 1.45);
    _testLeaf(c, false, _G.tileDark, 0, 1.45);
    _tag(c, tr('sun_leaf_result'), _G.tileSun + const Offset(0, -70), _Colors.slate700,
        size: 14, maxWidth: 200);
    _tag(c, tr('dark_leaf_result'), _G.tileDark + const Offset(0, -70), _Colors.amber700,
        size: 14, maxWidth: 200);
  }

  Color _alcohol() =>
      Color.lerp(_Colors.slate50.withValues(alpha: 0.55), _Colors.green500, scene.pale)!;

  // ---------------------------------------------------------- scenario 2

  void _s2(Canvas c, Size size) {
    final sc = scene;
    switch (sc.step) {
      case 1:
        _labRoom(c, size, _G.floor, floor: true);
        final open = sc.waitStart != null ? 1 - sc.prog(sc.waitStart, 0.45) : 1.0;
        final settled = sc.plantInCloset && !(sc.items['plant']?.moving(_t) ?? false);
        _closet(c, _G.closetRight, open, inside: settled ? () => _item(c, 'plant') : null);
        _tag(c, tr('dark_closet'), Offset(_G.closetRight.center.dx, _G.closetRight.top - 20), _Colors.slate500,
            size: 15);
        if (!settled) _item(c, 'plant');
      case 2:
        _labRoom(c, size, _G.floor, floor: true);
        _closet(c, _G.closetLeft, 1, inside: sc.plantOnBench ? null : () => _item(c, 'plant'));
        _tag(c, tr('dark_closet'), Offset(_G.closetLeft.center.dx, _G.closetLeft.top - 20), _Colors.slate500,
            size: 15);
        if (!sc.plantOnBench && sc.dragId != 'plant') {
          _tag(c, tr('destarched_plant'), _G.plantInClosetL + const Offset(0, -276), _Colors.green700);
        }
        _s2Bench(c);
        _bottle(c, _G.bottleBench, _G.bottleBenchScale, naoh: sc.naohLevel, cork: false);
        if (sc.plantOnBench) _item(c, 'plant');
        _pourStream(c);
        _item(c, 'naoh');
      case 3:
        _labRoom(c, size, _G.s2Counter);
        _bigPlant(c);
        final b = _G.bigBottle;
        const s = _G.bigBottleScale;
        if (sc.leafSealed) {
          _bottle(c, b, s, naoh: 1, cork: true, leaf: true, petiole: b + const Offset(0, -142 * s - 70 * s * 1.15));
        } else {
          _bottle(c, b, s, naoh: 1, cork: false);
        }
        _item(c, 'cork');
        _item(c, 'leaf');
      case 4:
        _labRoom(c, size, _G.s2Counter);
        _sunZone(c);
        _item(c, 'setup');
        _lampLight(c);
      case 5:
        _labRoom(c, size, _G.s2Counter);
        c.saveLayer(null, Paint()..color = const Color(0x80000000));
        _setup(c, _G.fadedSetup, 0.85, leaf: false);
        c.restore();
        _station(c);
        if (!_leaf2InBeaker()) _item(c, 'leaf2');
      case 6:
        _labRoom(c, size, _G.s2TileCounter);
        _tile(c, _G.s2Tile);
        _tag(c, tr('tile_label'), Offset(_G.s2Tile.left - 8, _G.s2Tile.center.dy), _Colors.slate400,
            size: 13, anchor: Alignment.centerRight);
        _s2Leaf(c, _G.s2Leaf, 0, 170);
        _tag(c, tr('target_leaf'), _G.s2Leaf + const Offset(0, -56), _Colors.green700, size: 13);
        _item(c, 'dropper');
        _iodineBottle(c, _G.iodineS2);
        if (sc.legend) _legend(c, const Offset(450, 120), sc.prog(sc.s2IodineStart, 0.6));
      default:
        _labRoom(c, size, _G.s2Counter);
        _s2Result(c);
    }
  }

  /// Scenario 2, step 3: the destarched plant with the target leaf on a
  /// long branch (HTML zoomed view).
  void _bigPlant(Canvas c) {
    final sc = scene;
    const s = _G.bigPlantScale;
    final base = _G.bigPlant;
    _plant(c, base, s, _Look.lime, hideTestLeaf: true);
    final from = base + const Offset(0, -128 * s);
    final branch = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = _Colors.green800;
    if (sc.leafSealed) {
      final to = _G.bigBottle + const Offset(0, -142 * _G.bigBottleScale - 70 * _G.bigBottleScale * 1.15);
      c.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(from.dx + 140, from.dy - 120, to.dx, to.dy - 110, to.dx, to.dy),
        branch,
      );
    } else {
      c.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(from.dx + 60, from.dy - 50, _G.branchTip.dx, _G.branchTip.dy),
        branch,
      );
    }
  }

  /// The plant + bottle setup (HTML `#setup-wrapper`), centred on [g].
  void _setup(Canvas c, Offset g, double s, {required bool leaf}) {
    final plantBase = g + Offset(-70 * s, 150 * s);
    final bottleBase = g + Offset(90 * s, 150 * s);
    _plant(c, plantBase, s, _Look.lime, hideTestLeaf: true);
    final petiole = bottleBase + Offset(0, -142 * s - 66 * s);
    if (leaf) {
      final from = plantBase + Offset(0, -128 * s);
      c.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(from.dx + 50 * s, from.dy - 80 * s, petiole.dx, petiole.dy - 70 * s, petiole.dx, petiole.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * s
          ..strokeCap = StrokeCap.round
          ..color = _Colors.green800,
      );
    }
    _bottle(c, bottleBase, s, naoh: 1, cork: true, leaf: leaf, petiole: petiole, leafLen: 132 * s);
  }

  void _s2Bench(Canvas c) {
    final slab = _G.benchSlab;
    final leg = Paint()..color = _Colors.amber950;
    c.drawRect(Rect.fromLTRB(slab.left + 22, slab.bottom - 4, slab.left + 42, _G.floor), leg);
    c.drawRect(Rect.fromLTRB(slab.right - 42, slab.bottom - 4, slab.right - 22, _G.floor), leg);
    labGroundShadow(c, Offset(slab.center.dx, _G.floor + 4), slab.width * 0.9, 16, opacity: 0.25);
    _benchBoard(c, slab);
  }

  /// HTML lab bench: `bg-amber-800/80 border-4 border-amber-950` with its
  /// label.
  void _benchBoard(Canvas c, Rect r) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
    c.drawRRect(
      rr.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    c.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA16207), _Colors.amber800, Color(0xFF7C2D12)],
        ).createShader(r),
    );
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.5;
    for (var i = 1; i < 5; i++) {
      final y = r.top + r.height * i / 5;
      c.drawLine(Offset(r.left + 12, y), Offset(r.right - 12, y + math.sin(i * 2.0) * 3), grain);
    }
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _Colors.amber950,
    );
    if (showLabels) {
      labText(c, tr('lab_bench'), r.center, size: 24, weight: FontWeight.w800, color: _Colors.amber200);
    }
  }

  void _pourStream(Canvas c) {
    final sc = scene;
    final start = sc.pourStart;
    if (start == null || sc.naohPoured) return;
    final k = _t - start;
    if (k < 0 || k > 0.95) return;
    final it = sc.items['naoh'];
    if (it == null) return;
    final p = it.at(_t);
    final r = it.rotAt(_t);
    final lip = p + _rotate(const Offset(-30, -46), r);
    final mouth = _G.bottleBench + const Offset(0, -142 * _G.bottleBenchScale);
    final a = (k / 0.12).clamp(0.0, 1.0) * (1 - ((k - 0.8) / 0.15).clamp(0.0, 1.0));
    c.drawPath(
      Path()
        ..moveTo(lip.dx, lip.dy)
        ..quadraticBezierTo(lip.dx - 10, lip.dy + 8, mouth.dx + 2, mouth.dy + 30),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = _Colors.blue200.withValues(alpha: 0.85 * a),
    );
  }

  /// HTML `#zone-sun`: gradient disc with a dashed border and the lamp.
  void _sunZone(Canvas c) {
    final sc = scene;
    final rect = Rect.fromCircle(center: _G.sunZone, radius: _G.sunZoneR);
    final power = sc.waitStart != null ? 1.0 : (sc.setupInSun ? 0.85 : 0.6);
    c.drawCircle(
      _G.sunZone,
      _G.sunZoneR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _Colors.blue200.withValues(alpha: isDark ? 0.75 : 1),
            _Colors.yellow50.withValues(alpha: isDark ? 0.85 : 1),
          ],
        ).createShader(rect),
    );
    labGlow(c, _G.sunZone + const Offset(60, -60), _G.sunZoneR, _Colors.amber400, intensity: 0.35 * power);
    labDashedPath(
      c,
      Path()..addOval(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _Colors.yellow300,
      dash: 14,
      gap: 9,
    );
    if (showLabels) {
      labText(
        c,
        tr('sun_lamp'),
        Offset(rect.left + 58, rect.top + 46),
        anchor: Alignment.centerLeft,
        size: 21,
        weight: FontWeight.w900,
        color: _Colors.yellow500,
        letterSpacing: 1,
      );
    }
    _lampHead(c, power);
  }

  void _lampHead(Canvas c, double power) {
    final p = _G.lamp;
    final rod = Paint()
      ..color = _Colors.slate500
      ..strokeWidth = 8;
    c.drawLine(Offset(p.dx + 40, -400), Offset(p.dx + 40, p.dy - 40), rod);
    c.drawLine(Offset(p.dx + 40, p.dy - 40), p + const Offset(14, -14), rod);
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(0.85);
    // HTML sun lamp: slate shade with a glowing amber bulb.
    final shade = Path()
      ..moveTo(-26, -22)
      ..lineTo(26, -22)
      ..lineTo(44, 26)
      ..lineTo(-44, 26)
      ..close();
    c.drawPath(
      shade,
      Paint()
        ..shader = const LinearGradient(
          colors: [_Colors.slate600, _Colors.slate700, _Colors.slate800],
        ).createShader(const Rect.fromLTRB(-44, -22, 44, 26)),
    );
    final pulse = 0.75 + 0.25 * math.sin(_t * 3);
    c.drawOval(
      const Rect.fromLTRB(-40, 18, 40, 36),
      Paint()..color = Color.lerp(_Colors.amber500, const Color(0xFFFEF3C7), pulse * power)!,
    );
    c.restore();
  }

  /// Light cone from the lamp onto the setup.
  void _lampLight(Canvas c) {
    final sc = scene;
    final power = sc.waitStart != null ? 1.0 : (sc.setupInSun ? 0.8 : 0.45);
    final p = _G.lamp;
    final d = Offset(math.cos(0.85 + math.pi / 2), math.sin(0.85 + math.pi / 2));
    final n = Offset(-d.dy, d.dx);
    final mouth = p + d * 30;
    final far = mouth + d * 300;
    final cone = Path()
      ..moveTo((mouth + n * 40).dx, (mouth + n * 40).dy)
      ..lineTo((far + n * 170).dx, (far + n * 170).dy)
      ..lineTo((far - n * 170).dx, (far - n * 170).dy)
      ..lineTo((mouth - n * 40).dx, (mouth - n * 40).dy)
      ..close();
    c.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(d.dx * -1, d.dy * -1),
          end: Alignment(d.dx, d.dy),
          colors: [
            _Colors.amber400.withValues(alpha: 0.42 * power),
            _Colors.amber400.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromPoints(mouth, far).inflate(170)),
    );
    labGlow(c, mouth, 46, _Colors.amber400, intensity: 0.8 * power);
  }

  /// HTML `#station`: boiling water, alcohol bath and white tile.
  void _station(Canvas c) {
    final st = _G.station;
    if (showLabels) {
      labText(
        c,
        tr('test_station'),
        Offset(st.center.dx, st.top + 6),
        size: 20,
        weight: FontWeight.w800,
        color: isDark ? _Colors.slate300 : _Colors.slate500,
      );
    }
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(st.left, st.bottom - 9, st.right, st.bottom - 1), const Radius.circular(3)),
      Paint()..color = isDark ? _Colors.slate500 : _Colors.slate300,
    );
    for (final (glass, color, text, label) in [
      (_G.boilBeaker, _Colors.blue500, 'hot_water', 'boil_label'),
      (_G.alcBeaker, _Colors.emerald500, 'alcohol', 'alc_label'),
    ]) {
      final plate = Rect.fromLTRB(glass.left - 13, glass.bottom, glass.right + 13, glass.bottom + 16);
      _hotPlate(c, plate, 1);
      _beakerBack(c, glass, color, 0.58);
      if (_leaf2InBeaker(glass)) _item(c, 'leaf2');
      _beakerFront(c, glass, color, 0.58, text: tr(text), boil: 0.7, small: true);
      _tag(c, tr(label), Offset(glass.center.dx, glass.top - 16), _Colors.slate400, size: 12, maxWidth: 140);
    }
    _tile(c, _G.stationTile);
    _tag(c, tr('tile_label'), Offset(_G.stationTile.center.dx, _G.stationTile.top - 16), _Colors.slate400,
        size: 12);
  }

  /// The test leaf is inside [glass] (or either station beaker) while the
  /// starch-test sequence runs.
  bool _leaf2InBeaker([Rect? glass]) {
    final leaf = scene.items['leaf2'];
    if (leaf == null || !scene.busy || scene.dragId == 'leaf2') return false;
    final at = leaf.at(_t);
    if (glass != null) return glass.contains(at);
    return _G.boilBeaker.contains(at) || _G.alcBeaker.contains(at);
  }

  /// HTML step 6 legend: BLUE-BLACK = starch present / YELLOW-BROWN = absent.
  void _legend(Canvas c, Offset at, double k) {
    if (k <= 0) return;
    final rows = [
      (_Colors.indigo950, '${tr('blue_black')} = ${tr('starch_pres')}'),
      (_Colors.amber600, '${tr('yellow_brown')} = ${tr('starch_abs')}'),
    ];
    final box = Rect.fromCenter(center: at, width: 470, height: 84);
    c.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(10)),
      Paint()..color = Colors.white.withValues(alpha: 0.94 * k),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.slate300.withValues(alpha: k),
    );
    for (var i = 0; i < rows.length; i++) {
      final y = box.top + 24 + i * 36.0;
      final sw = Rect.fromCenter(center: Offset(box.left + 26, y), width: 22, height: 22);
      c.drawRRect(RRect.fromRectAndRadius(sw, const Radius.circular(5)), Paint()..color = rows[i].$1.withValues(alpha: k));
      labText(
        c,
        rows[i].$2,
        Offset(box.left + 46, y),
        anchor: Alignment.centerLeft,
        size: 15,
        weight: FontWeight.w800,
        color: _Colors.slate800,
        opacity: k,
        maxWidth: 410,
      );
    }
  }

  /// HTML scenario 2 conclusion: split leaf with both labels.
  void _s2Result(Canvas c) {
    const center = Offset(450, 340);
    _s2Leaf(c, center, 0, 300, split: 1);
    final lead = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isDark ? _Colors.slate400 : _Colors.slate500;
    labDashedPath(c, Path()..moveTo(250, 252)..lineTo(250, 300)..lineTo(370, 330), lead);
    labDashedPath(c, Path()..moveTo(650, 252)..lineTo(650, 300)..lineTo(530, 330), lead);
    if (!showLabels) return;
    _resultBlock(c, const Offset(250, 196), tr('blue_black'), tr('out_bottle'), tr('starch_pres'),
        isDark ? _Colors.blue300 : _Colors.slate800);
    _resultBlock(c, const Offset(650, 196), tr('yellow_brown'), tr('in_bottle'), tr('starch_abs'),
        isDark ? _Colors.amber400 : _Colors.amber700);
  }

  void _resultBlock(Canvas c, Offset at, String big, String where, String meaning, Color color) {
    final card = Rect.fromCenter(center: at, width: 250, height: 104);
    c.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(12)),
      Paint()..color = isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.6),
    );
    labText(c, big, Offset(at.dx, card.top + 24), size: 22, weight: FontWeight.w900, color: color);
    labText(
      c,
      where.toUpperCase(),
      Offset(at.dx, card.top + 52),
      size: 13,
      weight: FontWeight.w800,
      color: isDark ? _Colors.slate400 : _Colors.slate500,
      letterSpacing: 1,
    );
    labText(c, meaning, Offset(at.dx, card.top + 78), size: 13, weight: FontWeight.w700, color: color, maxWidth: 236);
  }

  // ------------------------------------------------------------ overlays

  void _paintOverlays(Canvas c, Size size) {
    final sc = scene;
    if (sc.scenario != 1 || sc.waitStart == null) return;
    final k = sc.prog(sc.waitStart, sc.step == 1 ? 2.0 : 2.4);
    if (sc.step == 1) {
      // HTML: `bg-black/80` with a pulsing "DAY 2".
      final a = (sc.prog(sc.waitStart, 0.5) * 0.8).clamp(0.0, 0.8);
      c.drawRect(labBleed(size), Paint()..color = Colors.black.withValues(alpha: a));
      final pulse = 0.55 + 0.45 * (0.5 + 0.5 * math.cos(_t * math.pi));
      labText(
        c,
        tr('day_2'),
        const Offset(450, 290),
        size: 76,
        weight: FontWeight.w900,
        color: Colors.white,
        opacity: pulse * (a / 0.8),
        letterSpacing: 10,
      );
    } else if (sc.step == 4) {
      // HTML: spinning clock in the middle of the scene.
      const p = Offset(450, 270);
      labGroundShadow(c, p + const Offset(0, 104), 160, 24, opacity: 0.25);
      _clockFace(c, p, 92, k * 6 * 2 * math.pi);
      labText(
        c,
        tr('hours').replaceAll('{n}', '${(6 * k).round()}'),
        p + const Offset(0, 128),
        size: 24,
        weight: FontWeight.w800,
        color: const Color(0xFF4ADE80),
        background: _Colors.slate900.withValues(alpha: 0.92),
        border: _Colors.slate600,
        borderWidth: 2,
        radius: 10,
      );
    }
  }

  void _paintDrop(Canvas c) {
    final d = scene.drop;
    if (d == null) return;
    final k = (_t - d.t0) / 0.4;
    if (k < 0 || k > 1.8) return;
    if (k <= 1) {
      final p = Offset.lerp(d.from, d.to, Curves.easeIn.transform(k))!;
      c.drawPath(_dropShape(p, 7), Paint()..color = _Colors.amber700);
    } else {
      final r = (k - 1) * 30;
      c.drawCircle(
        d.to,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _Colors.amber700.withValues(alpha: (1.8 - k) / 0.8),
      );
    }
  }

  Path _dropShape(Offset p, double r) => Path()
    ..moveTo(p.dx, p.dy - r * 1.8)
    ..quadraticBezierTo(p.dx + r * 1.1, p.dy - r * 0.2, p.dx, p.dy + r)
    ..quadraticBezierTo(p.dx - r * 1.1, p.dy - r * 0.2, p.dx, p.dy - r * 1.8)
    ..close();

  // ------------------------------------------------------------ artwork

  void _labRoom(Canvas c, Size size, double surface, {bool floor = false}) {
    final b = labBleed(size);
    c.drawRect(
      b,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B1222), _Colors.slate800]
              : const [_Colors.slate100, _Colors.slate200],
        ).createShader(Rect.fromLTRB(0, 0, 900, surface)),
    );
    // Faint wall tiles.
    final tile = Paint()
      ..color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: isDark ? 0.035 : 0.07)
      ..strokeWidth = 1;
    for (double y = surface - 46; y > b.top; y -= 46) {
      c.drawLine(Offset(b.left, y), Offset(b.right, y), tile);
    }
    for (double x = -900; x < 1800; x += 92) {
      c.drawLine(Offset(x, b.top), Offset(x, surface), tile);
    }
    if (floor) {
      c.drawRect(
        Rect.fromLTRB(b.left, surface, b.right, b.bottom),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF1E293B), Color(0xFF0B1222)]
                : const [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
          ).createShader(Rect.fromLTRB(0, surface, 900, 600)),
      );
      c.drawRect(
        Rect.fromLTRB(b.left, surface - 8, b.right, surface),
        Paint()..color = isDark ? _Colors.slate600 : _Colors.slate400,
      );
      return;
    }
    // Lab counter: top surface, a light front edge and the front face.
    final front = surface + 150;
    c.drawRect(
      Rect.fromLTRB(b.left, surface, b.right, front),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [_Colors.slate700, _Colors.slate600] : const [_Colors.slate300, _Colors.slate200],
        ).createShader(Rect.fromLTRB(0, surface, 900, front)),
    );
    c.drawRect(
      Rect.fromLTRB(b.left, surface - 3, b.right, surface + 2),
      Paint()..color = isDark ? _Colors.slate800 : _Colors.slate400,
    );
    c.drawRect(
      Rect.fromLTRB(b.left, front, b.right, front + 5),
      Paint()..color = isDark ? _Colors.slate500 : Colors.white,
    );
    c.drawRect(
      Rect.fromLTRB(b.left, front + 5, b.right, b.bottom),
      Paint()..color = isDark ? _Colors.slate900 : _Colors.slate400,
    );
  }

  /// HTML `pot` SVG (viewBox 100): trapezoid body and rim, scaled by [s]
  /// with the body's bottom edge on [base].
  void _pot(Canvas c, Offset base, double s) {
    final o = base + Offset(-50 * s, -90 * s);
    Offset p(double x, double y) => o + Offset(x * s, y * s);
    labGroundShadow(c, base + Offset(0, 2 * s), 70 * s, 12 * s, opacity: 0.3);
    final body = Path()
      ..moveTo(p(20, 20).dx, p(20, 20).dy)
      ..lineTo(p(80, 20).dx, p(80, 20).dy)
      ..lineTo(p(70, 90).dx, p(70, 90).dy)
      ..lineTo(p(30, 90).dx, p(30, 90).dy)
      ..close();
    final bodyRect = Rect.fromPoints(p(20, 20), p(80, 90));
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9A3412), _Colors.orange600, _Colors.orange700, Color(0xFF7C2D12)],
          stops: [0, 0.3, 0.65, 1],
        ).createShader(bodyRect),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s
      ..strokeJoin = StrokeJoin.round
      ..color = _Colors.orange900;
    c.drawPath(body, edge);
    final rim = RRect.fromRectAndRadius(Rect.fromPoints(p(15, 10), p(85, 25)), Radius.circular(5 * s));
    c.drawRRect(
      rim,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFB923C), _Colors.orange600],
        ).createShader(rim.outerRect),
    );
    c.drawRRect(rim, edge);
    c.drawOval(
      Rect.fromCenter(center: p(50, 11), width: 60 * s, height: 6 * s),
      Paint()..color = _Colors.amber950,
    );
  }

  /// A potted plant (HTML `variegatedSapling`, drawn larger and leafier).
  void _plant(Canvas c, Offset base, double s, _Look look, {bool hideTestLeaf = false, double opacity = 1}) {
    _pot(c, base, s);
    if (opacity < 1) {
      c.saveLayer(null, Paint()..color = Colors.black.withValues(alpha: opacity));
    }
    final bottom = base + Offset(0, -80 * s);
    final top = base + Offset(0, -214 * s);
    c.drawLine(
      bottom,
      top,
      Paint()
        ..color = _Colors.green800
        ..strokeWidth = 7 * s
        ..strokeCap = StrokeCap.round,
    );
    c.drawLine(
      bottom + Offset(-1.5 * s, 0),
      top + Offset(-1.5 * s, 8 * s),
      Paint()
        ..color = _Colors.green500.withValues(alpha: 0.45)
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < _leafSpecs.length; i++) {
      if (hideTestLeaf && i == 1) continue;
      final (h, a, len) = _leafSpecs[i];
      final attach = base + Offset(0, -h * s);
      switch (look) {
        case _Look.variegated:
          _leaf(c, attach, len * s, a, base: _Colors.lime400, inner: _Colors.slate50);
        case _Look.green:
          _leaf(c, attach, len * s, a, base: _Colors.green500);
        case _Look.lime:
          _leaf(c, attach, len * s, a, base: _Colors.lime400);
      }
    }
    if (opacity < 1) c.restore();
  }

  /// The HTML leaf: a lens with an optional pale inner patch, midrib and
  /// veins. [tipColor] colours the tip half (the half sealed in the bottle).
  void _leaf(
    Canvas c,
    Offset petiole,
    double len,
    double angle, {
    required Color base,
    Color? inner,
    Color? tipColor,
  }) {
    if (len <= 0) return;
    c.save();
    c.translate(petiole.dx, petiole.dy);
    c.rotate(angle);
    final k = len / 100;
    c.scale(k);
    Paint fill(Color col) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [labShade(col, 0.16), labShade(col, -0.12)],
      ).createShader(const Rect.fromLTRB(0, -19, 100, 19));
    if (tipColor == null) {
      c.drawPath(_leafOuter, fill(base));
    } else {
      c.save();
      c.clipRect(const Rect.fromLTRB(-5, -30, 50, 30));
      c.drawPath(_leafOuter, fill(base));
      c.restore();
      c.save();
      c.clipRect(const Rect.fromLTRB(50, -30, 105, 30));
      c.drawPath(_leafOuter, fill(tipColor));
      c.restore();
    }
    if (inner != null) c.drawPath(_leafInner, Paint()..color = inner.withValues(alpha: 0.9));
    final vein = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..color = _Colors.green800.withValues(alpha: 0.35);
    c.drawLine(const Offset(3, 0), const Offset(93, 0), vein);
    for (var i = 0; i < 4; i++) {
      final x = 22.0 + i * 18;
      c.drawLine(Offset(x, 0), Offset(x + 11, -10 + i * 1.2), vein);
      c.drawLine(Offset(x, 0), Offset(x + 11, 10 - i * 1.2), vein);
    }
    c.drawPath(
      _leafOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.green800,
    );
    c.restore();
  }

  /// Scenario 1 test leaf ([sun] or dark) centred on [p] with its colours:
  /// fresh → pale (alcohol) → iodine result.
  void _testLeaf(Canvas c, bool sun, Offset p, double rot, double scl) {
    final sc = scene;
    final pale = sc.pale;
    final iodine = sun ? sc.sunIodine : sc.darkIodine;
    var base = Color.lerp(_Colors.lime400, _Colors.yellow200, pale)!;
    var inner = Color.lerp(_Colors.slate50, _Colors.yellow200, pale)!;
    base = Color.lerp(base, sun ? _Colors.indigo950 : _Colors.amber600, iodine)!;
    inner = Color.lerp(inner, _Colors.amber600, iodine)!;
    final len = 100 * scl;
    _leaf(c, p - Offset(math.cos(rot), math.sin(rot)) * (len / 2), len, rot, base: base, inner: inner);
  }

  /// Scenario 2 test leaf: fresh → pale → split iodine result.
  void _s2Leaf(Canvas c, Offset p, double rot, double len, {double? split}) {
    final sc = scene;
    final pale = split != null ? 1.0 : sc.s2Pale;
    final iodine = split ?? sc.s2Iodine;
    final fresh = Color.lerp(_Colors.lime400, _Colors.yellow200, pale)!;
    final petiole = p - Offset(math.cos(rot), math.sin(rot)) * (len / 2);
    if (iodine <= 0) {
      _leaf(c, petiole, len, rot, base: fresh);
    } else {
      _leaf(
        c,
        petiole,
        len,
        rot,
        base: Color.lerp(fresh, _Colors.indigo950, iodine)!,
        tipColor: Color.lerp(fresh, _Colors.amber600, iodine)!,
      );
    }
  }

  /// HTML `blackBox` SVG: front, top and side faces (bbox 210 × 280).
  void _blackBox(Canvas c, Offset center) {
    final l = center.dx - 105;
    final t = center.dy - 140;
    labGroundShadow(c, Offset(center.dx - 4, t + 282), 200, 18, opacity: 0.35);
    final front = Rect.fromLTWH(l, t + 30, 180, 250);
    final top = Path()
      ..moveTo(l, t + 30)
      ..lineTo(l + 30, t)
      ..lineTo(l + 210, t)
      ..lineTo(l + 180, t + 30)
      ..close();
    final side = Path()
      ..moveTo(l + 180, t + 30)
      ..lineTo(l + 210, t)
      ..lineTo(l + 210, t + 250)
      ..lineTo(l + 180, t + 280)
      ..close();
    c.drawPath(top, Paint()..color = _Colors.slate700);
    c.drawPath(side, Paint()..color = _Colors.slate900);
    c.drawRRect(
      RRect.fromRectAndRadius(front, const Radius.circular(4)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF3A4A61), Color(0xFF263347), Color(0xFF172131)]
              : const [Color(0xFF2B3A50), _Colors.slate800, Color(0xFF111A28)],
        ).createShader(front),
    );
    // Soft sheen so the box reads as a solid object on dark backgrounds.
    c.drawPath(
      Path()
        ..moveTo(front.left + 14, front.top + 12)
        ..lineTo(front.left + 70, front.top + 12)
        ..lineTo(front.left + 14, front.top + 120)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: isDark ? 0.07 : 0.05),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = isDark ? _Colors.slate500 : _Colors.slate900;
    c.drawPath(top, edge);
    c.drawPath(side, edge);
    c.drawRRect(RRect.fromRectAndRadius(front, const Radius.circular(4)), edge);
  }

  void _hotPlate(Canvas c, Rect r, double heat) {
    labGroundShadow(c, Offset(r.center.dx, r.bottom), r.width * 0.95, 10, opacity: 0.3);
    final body = RRect.fromRectAndRadius(r, const Radius.circular(4));
    c.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.slate600, _Colors.slate800],
        ).createShader(r),
    );
    final glow = 0.55 + 0.25 * math.sin(_t * 2.4);
    c.drawRect(
      Rect.fromLTRB(r.left + 8, r.top, r.right - 8, r.top + 3),
      Paint()..color = Color.lerp(_Colors.slate400, const Color(0xFFF97316), heat * glow)!,
    );
    c.drawCircle(Offset(r.right - 14, r.center.dy + 2), 3, Paint()..color = _Colors.red500.withValues(alpha: heat));
  }

  /// HTML `beaker()` SVG, back half: glass and liquid.
  void _beakerBack(Canvas c, Rect g, Color liquid, double level) {
    final path = _beakerPath(g);
    c.drawPath(path, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.08 : 0.35));
    final top = g.bottom - g.height * level;
    c.save();
    c.clipPath(path);
    c.drawRect(
      Rect.fromLTRB(g.left, top, g.right, g.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [liquid.withValues(alpha: 0.5), labShade(liquid, -0.2).withValues(alpha: 0.65)],
        ).createShader(Rect.fromLTRB(g.left, top, g.right, g.bottom)),
    );
    c.restore();
  }

  /// Beaker front: surface, bubbles, white label and the glass outline.
  void _beakerFront(Canvas c, Rect g, Color liquid, double level,
      {String? text, double boil = 0, bool small = false}) {
    final top = g.bottom - g.height * level;
    c.drawOval(
      Rect.fromLTRB(g.left + 2, top - 4, g.right - 2, top + 4),
      Paint()..color = labShade(liquid, 0.35).withValues(alpha: 0.75),
    );
    if (boil > 0) {
      final bubble = Paint();
      final n = (6 + 10 * boil).round();
      for (var i = 0; i < n; i++) {
        final ph = (_t * (0.6 + 0.5 * boil) + i * 0.37) % 1.0;
        final x = g.left + g.width * (0.12 + 0.76 * ((i * 0.618) % 1.0)) + math.sin(_t * 3 + i) * 2;
        final y = g.bottom - 6 - ph * (g.bottom - top - 8);
        bubble.color = Colors.white.withValues(alpha: 0.75 * (1 - ph));
        c.drawCircle(Offset(x, y), 1.8 + (i % 3) * 1.1, bubble);
      }
    }
    if (text != null && showLabels) {
      labText(
        c,
        text,
        Offset(g.center.dx, g.bottom - (small ? 16 : 22)),
        size: small ? 12 : 15,
        weight: FontWeight.w800,
        color: Colors.white,
        maxWidth: g.width - 8,
        shadows: const [Shadow(color: Color(0x88000000), blurRadius: 3)],
      );
    }
    final path = _beakerPath(g, open: true);
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.slate400,
    );
    c.drawLine(
      Offset(g.left + g.width * 0.14, g.top + 14),
      Offset(g.left + g.width * 0.14, g.bottom - 16),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.3),
    );
    final mark = Paint()
      ..strokeWidth = 1.5
      ..color = _Colors.slate400.withValues(alpha: 0.8);
    for (var i = 1; i <= 4; i++) {
      final y = g.bottom - g.height * i / 5;
      c.drawLine(Offset(g.right - g.width * 0.22, y), Offset(g.right - 3, y), mark);
    }
  }

  Path _beakerPath(Rect g, {bool open = false}) {
    final r = math.min(14.0, g.width * 0.12);
    final p = Path()
      ..moveTo(g.left - 7, g.top)
      ..lineTo(g.left, g.top + 6)
      ..lineTo(g.left, g.bottom - r)
      ..quadraticBezierTo(g.left, g.bottom, g.left + r, g.bottom)
      ..lineTo(g.right - r, g.bottom)
      ..quadraticBezierTo(g.right, g.bottom, g.right, g.bottom - r)
      ..lineTo(g.right, g.top + 6)
      ..lineTo(g.right + 7, g.top);
    if (!open) p.close();
    return p;
  }

  /// HTML `testTube()` SVG with alcohol (and optionally a leaf) inside.
  void _tube(Canvas c, Rect g, Color liquid, {double level = 0.5, VoidCallback? inside}) {
    final r = g.width / 2;
    final path = Path()
      ..moveTo(g.left, g.top)
      ..lineTo(g.left, g.bottom - r)
      ..arcToPoint(Offset(g.right, g.bottom - r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(g.right, g.top)
      ..close();
    c.drawPath(path, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.4));
    c.save();
    c.clipPath(path);
    final top = g.bottom - g.height * level;
    c.drawRect(Rect.fromLTRB(g.left, top, g.right, g.bottom), Paint()..color = liquid);
    c.drawRect(
      Rect.fromLTRB(g.left, top - 1.5, g.right, top + 1.5),
      Paint()..color = labShade(liquid, 0.3).withValues(alpha: 0.8),
    );
    inside?.call();
    c.restore();
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = isDark ? _Colors.slate300 : _Colors.slate400,
    );
    c.drawLine(
      Offset(g.left - 4, g.top),
      Offset(g.right + 4, g.top),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = isDark ? _Colors.slate300 : _Colors.slate400,
    );
    c.drawLine(
      Offset(g.left + 6, g.top + 10),
      Offset(g.left + 6, g.bottom - r),
      Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  /// A test tube item (scenario 1 step 5), with its leaf once inserted.
  void _tubeWithLeaf(Canvas c, bool sun, Offset p) {
    final sc = scene;
    final g = Rect.fromCenter(center: p, width: _G.tube.width, height: _G.tube.height);
    final hasLeaf = sun ? sc.sunTube : sc.darkTube;
    _tube(
      c,
      g,
      _alcohol(),
      inside: hasLeaf ? () => _testLeaf(c, sun, Offset(p.dx, g.bottom - 38), -math.pi / 2, 0.44) : null,
    );
  }

  void _rackBack(Canvas c, Offset tube) {
    final y = tube.dy + _G.tube.height / 2 + 6;
    final wood = Paint()..color = isDark ? const Color(0xFF6D4C2F) : const Color(0xFF8D6E4F);
    labGroundShadow(c, Offset(tube.dx, y + 4), 110, 12, opacity: 0.3);
    c.drawRect(Rect.fromLTRB(tube.dx - 48, y - 86, tube.dx - 40, y - 4), wood);
    c.drawRect(Rect.fromLTRB(tube.dx + 40, y - 86, tube.dx + 48, y - 4), wood);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(tube.dx - 54, y - 10, tube.dx + 54, y + 2), const Radius.circular(3)),
      Paint()..color = isDark ? const Color(0xFF8D6E4F) : const Color(0xFFA1887F),
    );
  }

  void _rackFront(Canvas c, Offset tube) {
    final y = tube.dy + _G.tube.height / 2 + 6;
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(tube.dx - 54, y - 92, tube.dx + 54, y - 80), const Radius.circular(3)),
      Paint()..color = isDark ? const Color(0xFF8D6E4F) : const Color(0xFFA1887F),
    );
  }

  /// HTML `tile` SVG: a white tile lying on the bench.
  void _tile(Canvas c, Rect r) {
    final inset = r.height * 0.22;
    const th = 8.0;
    labGroundShadow(c, Offset(r.center.dx, r.bottom), r.width * 1.02, 18, opacity: 0.3);
    final top = Path()
      ..moveTo(r.left + inset, r.top)
      ..lineTo(r.right - inset, r.top)
      ..lineTo(r.right, r.bottom - th)
      ..lineTo(r.left, r.bottom - th)
      ..close();
    final front = Rect.fromLTRB(r.left, r.bottom - th, r.right, r.bottom);
    c.drawRect(front, Paint()..color = _Colors.slate300);
    c.drawPath(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _Colors.slate50, _Colors.slate100],
        ).createShader(r),
    );
    c.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.slate300,
    );
    c.drawLine(
      Offset(r.left + inset + 16, r.top + 7),
      Offset(r.left + inset + r.width * 0.3, r.top + 7),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  /// HTML `dropper` SVG: red rubber bulb, glass pipette with iodine and a
  /// bouncing drop at the tip while it waits.
  void _dropper(Canvas c, Offset p, {required bool idle}) {
    final glass = Path()
      ..moveTo(p.dx - 7, p.dy - 16)
      ..lineTo(p.dx - 7, p.dy + 38)
      ..lineTo(p.dx, p.dy + 58)
      ..lineTo(p.dx + 7, p.dy + 38)
      ..lineTo(p.dx + 7, p.dy - 16)
      ..close();
    c.drawPath(glass, Paint()..color = Colors.white.withValues(alpha: 0.8));
    c.save();
    c.clipPath(glass);
    c.drawRect(Rect.fromLTRB(p.dx - 8, p.dy + 14, p.dx + 8, p.dy + 60), Paint()..color = _Colors.amber700);
    c.restore();
    c.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = _Colors.slate400,
    );
    final bulb = Rect.fromLTRB(p.dx - 11, p.dy - 36, p.dx + 11, p.dy - 14);
    final red = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB91C1C), _Colors.red500, Color(0xFFF87171), _Colors.red500, Color(0xFF991B1B)],
        stops: [0, 0.25, 0.45, 0.7, 1],
      ).createShader(Rect.fromLTRB(p.dx - 14, p.dy - 60, p.dx + 14, p.dy - 14));
    c.drawRRect(RRect.fromRectAndRadius(bulb, const Radius.circular(3)), red);
    c.drawCircle(Offset(p.dx, p.dy - 44), 13, red);
    c.drawCircle(
      Offset(p.dx - 4, p.dy - 49),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    if (idle) {
      final bounce = (math.sin(_t * math.pi * 2)).abs() * 5;
      c.drawPath(_dropShape(Offset(p.dx, p.dy + 64 - bounce), 3.6), Paint()..color = _Colors.amber700);
    }
  }

  /// Amber iodine bottle the dropper rests in.
  void _iodineBottle(Canvas c, Offset base) {
    labGroundShadow(c, base, 70, 10, opacity: 0.3);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(base.dx - 28, base.dy - 58, base.dx + 28, base.dy),
      const Radius.circular(9),
    );
    c.drawRect(
      Rect.fromLTRB(base.dx - 12, base.dy - 70, base.dx + 12, base.dy - 56),
      Paint()..color = _Colors.amber900,
    );
    c.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF78350F), _Colors.amber700, Color(0xFF92400E), Color(0xFF451A03)],
          stops: [0, 0.3, 0.6, 1],
        ).createShader(body.outerRect),
    );
    final label = Rect.fromLTRB(base.dx - 22, base.dy - 44, base.dx + 22, base.dy - 20);
    c.drawRRect(RRect.fromRectAndRadius(label, const Radius.circular(3)), Paint()..color = _Colors.slate50);
    // "I₂" drawn as I + a lowered 2 (no subscript glyph needed).
    labText(c, 'I', label.center + const Offset(-3, -1), size: 15, weight: FontWeight.w900, color: _Colors.amber900);
    labText(c, '2', label.center + const Offset(4, 4), size: 9, weight: FontWeight.w900, color: _Colors.amber900);
  }

  /// HTML `closet` SVG: wooden frame, black interior, shelf and two doors
  /// ([open] 1 = swung open, 0 = closed).
  void _closet(Canvas c, Rect f, double open, {VoidCallback? inside}) {
    labGroundShadow(c, Offset(f.center.dx, f.bottom), f.width * 1.05, 20, opacity: 0.35);
    final frame = RRect.fromRectAndRadius(f, const Radius.circular(6));
    c.drawRRect(
      frame,
      Paint()
        ..shader = const LinearGradient(
          colors: [_Colors.wood, Color(0xFF4E342E), _Colors.wood],
        ).createShader(f),
    );
    c.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.woodEdge,
    );
    final room = f.deflate(16);
    c.drawRRect(
      RRect.fromRectAndRadius(room, const Radius.circular(3)),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF050505)],
        ).createShader(room),
    );
    c.drawRect(
      Rect.fromLTRB(room.left, room.top + 24, room.right, room.top + 32),
      Paint()..color = _Colors.woodShelf,
    );
    if (inside != null) {
      c.save();
      c.clipRect(room);
      inside();
      c.drawRect(room, Paint()..color = Colors.black.withValues(alpha: 0.4));
      c.restore();
    }
    // Doors hinge on the frame edges.
    final half = f.width / 2;
    for (final left in const [true, false]) {
      final hinge = left ? f.left : f.right;
      final dir = left ? -1.0 : 1.0;
      final free = hinge + dir * (40 * open) - dir * (half * (1 - open));
      final sag = 18 * open;
      final door = Path()
        ..moveTo(hinge, f.top)
        ..lineTo(free, f.top + sag)
        ..lineTo(free, f.bottom - sag)
        ..lineTo(hinge, f.bottom)
        ..close();
      c.drawPath(door, Paint()..color = _Colors.woodDoor);
      c.drawPath(
        door,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _Colors.woodEdge,
      );
      if ((free - hinge).abs() > 6) {
        c.drawCircle(Offset(free - dir * 8 * (open > 0.5 ? 1 : -1), f.center.dy), 4, Paint()..color = _Colors.gold);
      }
    }
  }

  /// HTML `bottle` SVG (a wide-mouthed bottle) standing on [base], with the
  /// NaOH solution, the split cork and a leaf sealed through it.
  void _bottle(
    Canvas c,
    Offset base,
    double s, {
    required double naoh,
    required bool cork,
    bool leaf = false,
    Offset? petiole,
    double? leafLen,
  }) {
    final l = base.dx - 55 * s, r = base.dx + 55 * s;
    final top = base.dy - 115 * s, bot = base.dy;
    final nl = base.dx - 22 * s, nr = base.dx + 22 * s, nt = base.dy - 142 * s;
    final rad = 16 * s;
    final outline = Path()
      ..moveTo(nl, nt)
      ..lineTo(nl, top)
      ..lineTo(l + rad, top)
      ..quadraticBezierTo(l, top, l, top + rad)
      ..lineTo(l, bot - rad)
      ..quadraticBezierTo(l, bot, l + rad, bot)
      ..lineTo(r - rad, bot)
      ..quadraticBezierTo(r, bot, r, bot - rad)
      ..lineTo(r, top + rad)
      ..quadraticBezierTo(r, top, r - rad, top)
      ..lineTo(nr, top)
      ..lineTo(nr, nt);
    final closed = Path()
      ..addPath(outline, Offset.zero)
      ..close();
    labGroundShadow(c, base, 120 * s, 12 * s, opacity: 0.3);
    c.drawPath(closed, Paint()..color = _Colors.slate200.withValues(alpha: isDark ? 0.22 : 0.55));
    if (naoh > 0) {
      c.save();
      c.clipPath(closed);
      final h = 36 * s * naoh;
      c.drawRect(
        Rect.fromLTRB(l, bot - h, r, bot),
        Paint()..color = (isDark ? Colors.white : const Color(0xFFDBEAFE)).withValues(alpha: 0.75),
      );
      c.drawRect(
        Rect.fromLTRB(l, bot - h - 1.5, r, bot - h + 1.5),
        Paint()..color = _Colors.blue400.withValues(alpha: 0.5),
      );
      c.restore();
    }
    final len = leafLen ?? 150 * s;
    if (leaf && petiole != null) {
      _leaf(c, petiole, len, math.pi / 2, base: _Colors.lime400);
      // The part inside the bottle is seen through the glass.
      c.save();
      c.clipPath(closed);
      c.drawRect(
        Rect.fromLTRB(l, nt + 14 * s, r, bot),
        Paint()..color = _Colors.slate200.withValues(alpha: isDark ? 0.18 : 0.28),
      );
      c.restore();
    }
    c.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * s
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.slate400,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(base.dx, nt), width: 54 * s, height: 12 * s),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s
        ..color = _Colors.slate400,
    );
    c.drawLine(
      Offset(l + 12 * s, top + 16 * s),
      Offset(l + 12 * s, bot - 18 * s),
      Paint()
        ..strokeWidth = 4 * s
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    if (cork) _cork(c, Rect.fromCenter(center: _corkSeat(base, s), width: 50 * s, height: 34 * s));
    if (naoh > 0.5 && showLabels) {
      labText(
        c,
        tr('naoh_desc'),
        Offset(base.dx, bot - 62 * s),
        size: 11.5 * math.max(1.0, s),
        weight: FontWeight.w800,
        color: _Colors.slate700,
        background: Colors.white.withValues(alpha: 0.85),
        border: _Colors.slate300,
        borderWidth: 1,
        radius: 5,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        opacity: ((naoh - 0.5) * 2).clamp(0.0, 1.0),
        maxWidth: 100 * s,
      );
    }
  }

  /// HTML `cork` SVG: amber block with the split line.
  void _cork(Canvas c, Rect r) {
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right - r.width * 0.1, r.bottom)
      ..lineTo(r.left + r.width * 0.1, r.bottom)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [_Colors.amber700, _Colors.amber500, _Colors.amber600, _Colors.amber700],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(r),
    );
    final dot = Paint()..color = _Colors.amber900.withValues(alpha: 0.35);
    for (var i = 0; i < 7; i++) {
      c.drawCircle(
        Offset(r.left + r.width * (0.18 + (i * 0.37) % 0.66), r.top + r.height * (0.25 + (i * 0.53) % 0.55)),
        1.4,
        dot,
      );
    }
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.amber900,
    );
    c.drawLine(
      Offset(r.center.dx, r.top),
      Offset(r.center.dx, r.bottom),
      Paint()
        ..strokeWidth = 2
        ..color = _Colors.amber900,
    );
  }

  /// Caustic soda beaker (HTML `beaker('#60a5fa', 'NaOH')`), tilted while
  /// pouring.
  void _naohBeaker(Canvas c, Offset p, double rot, {required bool label}) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(rot);
    const g = Rect.fromLTRB(-30, -46, 30, 46);
    // Tilted for pouring: the stream shows the liquid instead.
    final level = rot.abs() > 0.3 ? 0.0 : 0.55;
    _beakerBack(c, g, _Colors.blue400, level);
    _beakerFront(c, g, _Colors.blue400, level, text: 'NaOH', small: true);
    c.restore();
    if (label) _tag(c, tr('caustic_soda'), p + const Offset(0, -66), _Colors.blue600, size: 13);
  }

  /// Scene label chip (HTML `.label-text`), hidden with the labels tool.
  void _tag(
    Canvas c,
    String text,
    Offset at,
    Color tone, {
    double size = 14,
    Alignment anchor = Alignment.center,
    double? maxWidth,
  }) {
    if (!showLabels) return;
    labText(
      c,
      text,
      at,
      size: size,
      weight: FontWeight.w800,
      anchor: anchor,
      maxWidth: maxWidth,
      color: isDark ? labShade(tone, 0.55) : labShade(tone, -0.2),
      background: isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF),
      border: tone.withValues(alpha: 0.55),
      borderWidth: 1.2,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      radius: 8,
    );
  }

  static Offset _rotate(Offset v, double a) =>
      Offset(v.dx * math.cos(a) - v.dy * math.sin(a), v.dx * math.sin(a) + v.dy * math.cos(a));

  @override
  bool shouldRepaint(covariant _PhotoPainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

/// Native version of the HTML `confetti()` burst: particles shot upwards
/// from 60% of the canvas height, slowing down (decay 0.9 per frame) while
/// gravity pulls them down, fluttering and fading over 200 frames.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.scene, required Listenable repaint}) : super(repaint: repaint);

  final _PhotoScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final start = scene.confettiStart;
    if (start == null) return;
    final n = (scene.time - start) * 60;
    if (n < 0 || n > 200) return;
    final k = size.height / 650;
    final origin = Offset(size.width * 0.5, size.height * 0.6);
    final travel = (1 - math.pow(0.9, n)) / 0.1;
    final alpha = (1 - n / 200).clamp(0.0, 1.0);
    final paint = Paint();
    for (final f in scene.confetti) {
      final x = origin.dx + math.cos(f.angle) * f.velocity * travel * k;
      final y = origin.dy + math.sin(f.angle) * f.velocity * travel * k + 3 * n * k;
      final wobble = f.phase + n * f.wobbleSpeed;
      final p = Offset(x + 10 * k * math.cos(wobble), y + 10 * k * math.sin(wobble));
      paint.color = f.color.withValues(alpha: alpha);
      final sz = f.size * k.clamp(0.6, 1.4);
      if (f.circle) {
        canvas.drawOval(
          Rect.fromCenter(center: p, width: sz, height: sz * (0.4 + 0.6 * math.cos(wobble * 2).abs())),
          paint,
        );
      } else {
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(f.phase + n * 0.1);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: sz, height: sz * 0.6 * math.cos(n * 0.1 + f.phase).abs() + 1),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
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
