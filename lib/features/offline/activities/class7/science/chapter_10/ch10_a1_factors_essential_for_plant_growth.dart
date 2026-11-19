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

/// Class 7 Science • Chapter 10 • Activity 1
/// Factors Essential for Plant Growth.
///
/// Native Flutter port of `Cl7S-Ch10-A1-Factors_Essential_for_Plant_Growth.html`.
/// Scenario 1 plants three chilli saplings, puts them in sunlight or a dark
/// closet, waters two of them and time-lapses two weeks of growth. Scenario 2
/// destarches a plant, seals half a leaf in an NaOH bottle and runs the iodine
/// starch test to show that carbon dioxide is needed for photosynthesis.
class Ch10A1FactorsEssentialForPlantGrowthPage extends StatefulWidget {
  const Ch10A1FactorsEssentialForPlantGrowthPage({super.key});

  @override
  State<Ch10A1FactorsEssentialForPlantGrowthPage> createState() =>
      _Ch10A1FactorsEssentialForPlantGrowthPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// The HTML synthesises its tones with Web Audio: `click` -> click,
/// `drop` -> drop, `success` -> correct (step done) / success (popup),
/// `error` -> wrong, `boil` -> bubble. Picking an item up plays pickup,
/// watering plays splash and the time skips play whoosh / magic.
enum _Sound implements LabTone {
  /// Generic button click.
  click('click.mp3'),

  /// Sidebar expand / collapse.
  toggle('toggle.mp3'),

  /// Correct action / step completed.
  correct('correct.mp3'),

  /// Wrong action / invalid move.
  wrong('wrong.mp3'),

  /// Scenario completed / observation popup.
  success('success.mp3'),

  /// Scenario changed.
  scenario('scenario.mp3'),

  /// Curtain (intro shutter) opening or closing.
  curtain('curtain.mp3'),

  /// An item dropped into place.
  drop('drop.mp3'),

  /// An item picked up.
  pickup('pickup.mp3'),

  /// Watering a pot.
  splash('splash.mp3'),

  /// Boiling water / alcohol bath.
  bubble('bubble.mp3'),

  /// "Wait 2 Days".
  whoosh('whoosh.mp3'),

  /// "Wait 6 Hours" (sunlight).
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

/// Brand, Tailwind and SVG colours used by this lab.
abstract final class _Colors {
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // --accent
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534); // sapling / stem stroke
  static const Color lime400 = Color(0xFFA3E635); // experiment leaf
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD); // --text-muted (dark)
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // --border (dark)
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A); // --bg-main (dark)
  static const Color blue950 = Color(0xFF172554); // --bg-panel (dark)
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky100 = Color(0xFFE0F2FE); // --bg-main (light)
  static const Color sky200 = Color(0xFFBAE6FD); // --border (light)
  static const Color yellow50 = Color(0xFFFEFCE8);
  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow500 = Color(0xFFEAB308);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color orange900 = Color(0xFF7C2D12);
  static const Color wilted = Color(0xFF8B4513); // Pot B leaves (HTML)
  static const Color emerald500 = Color(0xFF10B981);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo950 = Color(0xFF1E1B4B); // blue-black starch
  static const Color red500 = Color(0xFFEF4444);
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
  static const Color closetWood = Color(0xFF3E2723);
  static const Color closetDoor = Color(0xFF4E342E);
  static const Color closetShelf = Color(0xFF5D4037);
  static const Color closetEdge = Color(0xFF1F1209);
  static const Color gold = Color(0xFFD4AF37);
  static const Color wood = Color(0xFFA16207);
}

/// This lab's light and dark palettes (the HTML `:root` / `.light-theme`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.blue950,
    panel: Color(0xF2172554),
    border: Color(0x663B82F6),
    card: Color(0x801E3A8A),
    cardBorder: Color(0x663B82F6),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: _Colors.slate50,
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
    toastBg: Color(0xF20F172A),
    toastText: _Colors.green400,
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
    bg: _Colors.sky100,
    panel: Color(0xF2FFFFFF),
    border: Color(0x1A000000),
    card: _Colors.sky50,
    cardBorder: _Colors.sky200,
    canvasBg: _Colors.slate200,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.green600,
    onAccent: Colors.white,
    primary: _Colors.blue600,
    onPrimary: Colors.white,
    success: _Colors.green600,
    danger: _Colors.red500,
    onDanger: Colors.white,
    info: _Colors.blue600,
    popupBg: Colors.white,
    popupHeader: _Colors.sky50,
    dialogBg: Colors.white,
    toastBg: Color(0xF20F172A),
    toastText: _Colors.green400,
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
    'app_title': 'Factors Essential for Plant Growth',
    'app_subtitle': 'Class 7 • Life Processes in Plants',
    'scen_1': '1. Sunlight and Water',
    'scen_2': '2. Carbon Dioxide (Starch Test)',
    'sci_obs': 'Scientific Conclusion',
    'exp_out': 'Expected Outcome',
    'wait_2d': 'Wait 2 Days',
    'wait_6h': 'Wait 6 Hours',
    // Scene labels (hard-coded in the HTML scene).
    'sun_label': 'SUNLIT WINDOW',
    'dark_label': 'DARK CLOSET',
    'boil_label': 'Boiling Water',
    'alc_label': 'Alcohol in Water Bath',
    'tile_label': 'White Tile',
    'pot_a': 'Pot A',
    'pot_b': 'Pot B',
    'pot_c': 'Pot C',
    'sapling': 'Sapling',
    'water_can': 'Watering Can',
    'week_0': 'Week 0',
    'week_2': 'Week 2',
    'day_n': 'Day {n}',
    'healthy_plant': 'Healthy Potted Plant',
    'target_leaf': 'Target Leaf',
    'split_cork': 'SPLIT CORK',
    'naoh': 'NaOH',
    'absorbs_co2': '(Absorbs CO₂)',
    'setup': 'Experiment Setup',
    'station': 'Starch Test Station',
    'hot_water': 'Hot Water',
    'alcohol': 'Alcohol',
    'day_2': 'DAY 2',
    'blue_black': 'BLUE-BLACK',
    'outside': 'Outside Bottle',
    'starch_present': 'Starch Present (CO₂ available)',
    'yellow_brown': 'YELLOW-BROWN',
    'inside': 'Inside Bottle',
    'starch_absent': 'Starch Absent (No CO₂)',
    // Observation popups and conclusions.
    'obs_a_title': 'Pot A (Sun + Water)',
    'obs_a_desc': 'Thrived and grew healthy green leaves.',
    'obs_b_title': 'Pot B (Sun Only)',
    'obs_b_desc': 'Wilted and turned brown due to dehydration.',
    'obs_c_title': 'Pot C (Water Only)',
    'obs_c_desc': 'Etiolated—grew tall but spindly and yellow.',
    's1_res_title': 'Results Overview',
    's1_concl': 'Conclusion: Both sunlight and water are indispensable!',
    's1_done': 'Scenario 1 Completed. Please try the next scenario.',
    's2_res_title': 'Results: The CO₂ Factor',
    's2_p1':
        'The iodine test visually proved that starch was only produced in the half of the leaf exposed to the air.',
    's2_p2':
        'The NaOH inside the bottle absorbed all the carbon dioxide, halting photosynthesis in that section.',
    's2_concl': 'Conclusion: Carbon Dioxide is essential for photosynthesis.',
    's2_done': 'Scenario 2 Completed.',
    // HUD feedback (HTML updateHUD).
    'fb_planted': 'Planted ({n}/3) • Success!',
    'fb_setup_done': 'Setup Complete! Proceeding...',
    'fb_placed_sun': 'Placed in Sunlit Window ({n}/3)',
    'fb_placed_dark': 'Placed in Dark Closet ({n}/3)',
    'fb_wrong_place': 'Incorrect Placement! Check variables.',
    'fb_isolated': 'Variables isolated. Proceeding...',
    'fb_watered': 'Watered ({n}/2)',
    'fb_no_water_b': 'Do NOT water Pot B! Isolating water variable.',
    'fb_water_done': 'Watering complete. Proceeding...',
    'fb_timelapse': 'Time-Lapse Complete. Proceeding...',
    'fb_all_inspected': 'All pots inspected. Mission Complete!',
    'fb_plant_dark': 'Plant placed in dark.',
    'fb_time_passing': 'Time passing... 2 Days elapsed.',
    'fb_destarched': 'Plant is now destarched.',
    'fb_cork': 'Cork attached! Now drag leaf to bottle.',
    'fb_sealed': 'Leaf sealed with NaOH. Proceeding...',
    'fb_placed_sunlit': 'Placed in Sunlit Window.',
    'fb_photo': 'Photosynthesizing... 6 Hours elapsed.',
    'fb_starch_start': 'Starch test started. Processing...',
  },
  'hi': {
    'app_title': 'पौधों की वृद्धि के लिए आवश्यक कारक',
    'app_subtitle': 'कक्षा 7 • पौधों में जैव प्रक्रम',
    'scen_1': '1. सूर्य का प्रकाश और पानी',
    'scen_2': '2. कार्बन डाइऑक्साइड (स्टार्च परीक्षण)',
    'sci_obs': 'वैज्ञानिक निष्कर्ष',
    'exp_out': 'अपेक्षित परिणाम',
    'wait_2d': '2 दिन प्रतीक्षा करें',
    'wait_6h': '6 घंटे प्रतीक्षा करें',
    'sun_label': 'धूप वाली खिड़की',
    'dark_label': 'अंधेरी अलमारी',
    'boil_label': 'उबलता पानी',
    'alc_label': 'वॉटर बाथ में ऐल्कोहॉल',
    'tile_label': 'सफ़ेद टाइल',
    'pot_a': 'गमला A',
    'pot_b': 'गमला B',
    'pot_c': 'गमला C',
    'sapling': 'नन्हा पौधा',
    'water_can': 'पानी का झारा',
    'week_0': 'सप्ताह 0',
    'week_2': 'सप्ताह 2',
    'day_n': 'दिन {n}',
    'healthy_plant': 'गमले में स्वस्थ पौधा',
    'target_leaf': 'चुनी गई पत्ती',
    'split_cork': 'चिरा हुआ कॉर्क',
    'naoh': 'NaOH',
    'absorbs_co2': '(CO₂ सोखता है)',
    'setup': 'प्रयोग की व्यवस्था',
    'station': 'स्टार्च परीक्षण स्टेशन',
    'hot_water': 'गर्म पानी',
    'alcohol': 'ऐल्कोहॉल',
    'day_2': 'दिन 2',
    'blue_black': 'नीला-काला',
    'outside': 'बोतल के बाहर',
    'starch_present': 'स्टार्च उपस्थित (CO₂ उपलब्ध)',
    'yellow_brown': 'पीला-भूरा',
    'inside': 'बोतल के अंदर',
    'starch_absent': 'स्टार्च अनुपस्थित (CO₂ नहीं)',
    'obs_a_title': 'गमला A (धूप + पानी)',
    'obs_a_desc': 'अच्छी तरह बढ़ा और इसमें स्वस्थ हरी पत्तियाँ आईं।',
    'obs_b_title': 'गमला B (केवल धूप)',
    'obs_b_desc': 'पानी की कमी (निर्जलीकरण) से मुरझा गया और भूरा हो गया।',
    'obs_c_title': 'गमला C (केवल पानी)',
    'obs_c_desc': 'पांडुरित हो गया—लंबा तो हुआ, पर पतला, कमज़ोर और पीला।',
    's1_res_title': 'परिणामों का सारांश',
    's1_concl': 'निष्कर्ष: सूर्य का प्रकाश और पानी दोनों अनिवार्य हैं!',
    's1_done': 'परिदृश्य 1 पूरा हुआ। कृपया अगला परिदृश्य आज़माएँ।',
    's2_res_title': 'परिणाम: CO₂ कारक',
    's2_p1':
        'आयोडीन परीक्षण ने स्पष्ट दिखाया कि स्टार्च केवल पत्ती के उस आधे भाग में बना जो हवा के संपर्क में था।',
    's2_p2':
        'बोतल के अंदर रखे NaOH ने सारी कार्बन डाइऑक्साइड सोख ली, जिससे पत्ती के उस भाग में प्रकाश संश्लेषण रुक गया।',
    's2_concl': 'निष्कर्ष: प्रकाश संश्लेषण के लिए कार्बन डाइऑक्साइड आवश्यक है।',
    's2_done': 'परिदृश्य 2 पूरा हुआ।',
    'fb_planted': 'पौधा लगाया गया ({n}/3) • बहुत बढ़िया!',
    'fb_setup_done': 'तैयारी पूरी! आगे बढ़ रहे हैं...',
    'fb_placed_sun': 'धूप वाली खिड़की में रखा गया ({n}/3)',
    'fb_placed_dark': 'अंधेरी अलमारी में रखा गया ({n}/3)',
    'fb_wrong_place': 'गलत जगह! चरों (वेरिएबल) की जाँच करें।',
    'fb_isolated': 'चर अलग कर दिए गए। आगे बढ़ रहे हैं...',
    'fb_watered': 'पानी दिया गया ({n}/2)',
    'fb_no_water_b': 'गमले B को पानी न दें! पानी वाले चर को अलग रखना है।',
    'fb_water_done': 'पानी देना पूरा हुआ। आगे बढ़ रहे हैं...',
    'fb_timelapse': 'टाइम-लैप्स पूरा हुआ। आगे बढ़ रहे हैं...',
    'fb_all_inspected': 'सभी गमलों की जाँच हो गई। मिशन पूरा!',
    'fb_plant_dark': 'पौधा अंधेरे में रख दिया गया।',
    'fb_time_passing': 'समय बीत रहा है... 2 दिन बीत गए।',
    'fb_destarched': 'अब पौधा स्टार्च-रहित हो गया है।',
    'fb_cork': 'कॉर्क लग गया! अब पत्ती को बोतल तक खींचें।',
    'fb_sealed': 'पत्ती NaOH वाली बोतल में सील हो गई। आगे बढ़ रहे हैं...',
    'fb_placed_sunlit': 'धूप वाली खिड़की में रखा गया।',
    'fb_photo': 'प्रकाश संश्लेषण हो रहा है... 6 घंटे बीत गए।',
    'fb_starch_start': 'स्टार्च परीक्षण शुरू हुआ। प्रक्रिया चल रही है...',
  },
};

// Steps: action = the HTML step `i` (task instructions), observation = `o`
// (expected outcome). The HTML step titles are just "Step N", so the concept
// names summarise each step.
const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To visually demonstrate and conclude that both sunlight and water are indispensable for healthy plant growth.',
      steps: [
        LabStep(
          concept: 'Planting the Saplings',
          action:
              'DRAG three identical chilli saplings from the tray and DROP one into each of the three earthen pots labelled A, B, and C.',
          observation:
              'All three pots are populated with identical, healthy green saplings of the same initial height and leaf count.',
        ),
        LabStep(
          concept: 'Setting the Conditions',
          action:
              'Set the conditions for each pot. DRAG Pot A to the "Sunlit Window" area. DRAG Pot B to the "Sunlit Window" area. DRAG Pot C into the "Dark Closet" area.',
          observation:
              'Pots A and B are side-by-side in a bright, sunny location. Pot C is inside a closed, dark space.',
        ),
        LabStep(
          concept: 'Watering',
          action:
              'Water the plants according to the experiment. DRAG the watering can to Pot A. DRAG the watering can to Pot C. Notice you cannot water Pot B.',
          observation: 'Pot A and Pot C are watered. Pot B remains dry.',
        ),
        LabStep(
          concept: 'Time-Lapse',
          action:
              'CLICK and DRAG the "Time-Lapse" slider from "Week 0" to "Week 2" to observe the changes.',
          observation: 'The growth (or decay) of the three plants is animated over the two-week period.',
        ),
        LabStep(
          concept: 'Comparing Results',
          action: 'CLICK on each pot to see the final results and compare them.',
          observation:
              'A summary card appears for each plant, visually displaying the final height, leaf count, and leaf color.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To visually prove that carbon dioxide from the air is essential for a plant leaf to produce starch (food) during photosynthesis.',
      steps: [
        LabStep(
          concept: 'Destarching',
          action:
              'First, we must ensure the plant has no stored starch. DRAG the healthy potted plant into the "Dark Closet" and CLICK the "Wait 2 Days" button.',
          observation: 'The plant is "destarched."',
        ),
        LabStep(
          concept: 'Bottle Setup',
          action:
              'Set up the experiment. DRAG the split cork and attach it to the stem of the highlighted leaf. Then, DRAG the tip of the leaf into the wide-mouthed bottle containing sodium hydroxide.',
          observation:
              'Half of the leaf is inside the sealed bottle, and the other half is outside in the open air.',
        ),
        LabStep(
          concept: 'Sunlight Exposure',
          action:
              'DRAG the entire setup (plant and bottle) to the "Sunlit Window" and CLICK the "Wait 6 Hours" button.',
          observation: 'The plant is exposed to sunlight to allow photosynthesis to occur.',
        ),
        LabStep(
          concept: 'Starch Test',
          action:
              'Now, let\'s test the leaf for starch. DRAG the leaf to the "Starch Test Station". The process will be automated. First, boiling water, then alcohol, then iodine solution.',
          observation: 'The leaf is prepared for the starch test and the iodine solution is applied.',
        ),
        LabStep(
          concept: 'Iodine Result',
          action: 'Observe the final result of the iodine test.',
          observation: 'The user clearly sees a two-toned leaf, proving where starch was made.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'दृश्य रूप से दिखाना और निष्कर्ष निकालना कि पौधे की स्वस्थ वृद्धि के लिए सूर्य का प्रकाश और पानी दोनों अनिवार्य हैं।',
      steps: [
        LabStep(
          concept: 'पौधे लगाना',
          action:
              'ट्रे से मिर्च के तीन एक जैसे नन्हे पौधे खींचें और A, B और C लेबल वाले तीनों मिट्टी के गमलों में एक-एक पौधा छोड़ें।',
          observation:
              'तीनों गमलों में एक जैसे, स्वस्थ हरे पौधे लग जाते हैं, जिनकी शुरुआती ऊँचाई और पत्तियों की संख्या समान है।',
        ),
        LabStep(
          concept: 'परिस्थितियाँ तय करना',
          action:
              'हर गमले के लिए परिस्थितियाँ तय करें। गमले A को "धूप वाली खिड़की" वाले भाग में खींचें। गमले B को भी "धूप वाली खिड़की" वाले भाग में खींचें। गमले C को "अंधेरी अलमारी" वाले भाग में खींचें।',
          observation: 'गमले A और B साथ-साथ तेज़ धूप वाली जगह पर हैं। गमला C एक बंद, अंधेरी जगह के अंदर है।',
        ),
        LabStep(
          concept: 'पानी देना',
          action:
              'प्रयोग के अनुसार पौधों को पानी दें। झारे को गमले A तक खींचें। झारे को गमले C तक खींचें। ध्यान दें कि आप गमले B को पानी नहीं दे सकते।',
          observation: 'गमले A और गमले C को पानी मिल जाता है। गमला B सूखा रहता है।',
        ),
        LabStep(
          concept: 'टाइम-लैप्स',
          action: 'बदलाव देखने के लिए "टाइम-लैप्स" स्लाइडर को क्लिक करके "सप्ताह 0" से "सप्ताह 2" तक खींचें।',
          observation: 'दो सप्ताह की अवधि में तीनों पौधों की वृद्धि (या मुरझाना) एनिमेशन में दिखाई देती है।',
        ),
        LabStep(
          concept: 'परिणामों की तुलना',
          action: 'अंतिम परिणाम देखने और उनकी तुलना करने के लिए हर गमले पर क्लिक करें।',
          observation:
              'हर पौधे के लिए एक सारांश कार्ड दिखता है, जिसमें अंतिम ऊँचाई, पत्तियों की संख्या और पत्तियों का रंग दिखाई देता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'दृश्य रूप से सिद्ध करना कि प्रकाश संश्लेषण के दौरान पत्ती द्वारा स्टार्च (भोजन) बनाने के लिए हवा की कार्बन डाइऑक्साइड आवश्यक है।',
      steps: [
        LabStep(
          concept: 'पौधे को स्टार्च-रहित करना',
          action:
              'पहले यह सुनिश्चित करना होगा कि पौधे में कोई संचित स्टार्च न हो। गमले में लगे स्वस्थ पौधे को "अंधेरी अलमारी" में खींचें और "2 दिन प्रतीक्षा करें" बटन पर क्लिक करें।',
          observation: 'पौधा "स्टार्च-रहित" हो जाता है।',
        ),
        LabStep(
          concept: 'बोतल की व्यवस्था',
          action:
              'प्रयोग तैयार करें। चिरे हुए कॉर्क को खींचकर चमकती हुई पत्ती के डंठल पर लगाएँ। फिर पत्ती के सिरे को खींचकर सोडियम हाइड्रॉक्साइड वाली चौड़े मुँह की बोतल में डालें।',
          observation: 'पत्ती का आधा भाग सील की हुई बोतल के अंदर है और बाकी आधा भाग बाहर खुली हवा में है।',
        ),
        LabStep(
          concept: 'धूप में रखना',
          action:
              'पूरी व्यवस्था (पौधा और बोतल) को "धूप वाली खिड़की" तक खींचें और "6 घंटे प्रतीक्षा करें" बटन पर क्लिक करें।',
          observation: 'पौधे को धूप में रखा जाता है ताकि प्रकाश संश्लेषण हो सके।',
        ),
        LabStep(
          concept: 'स्टार्च परीक्षण',
          action:
              'अब पत्ती में स्टार्च की जाँच करते हैं। पत्ती को "स्टार्च परीक्षण स्टेशन" तक खींचें। आगे की प्रक्रिया अपने-आप होगी: पहले उबलता पानी, फिर ऐल्कोहॉल, फिर आयोडीन विलयन।',
          observation: 'पत्ती को स्टार्च परीक्षण के लिए तैयार किया जाता है और उस पर आयोडीन विलयन डाला जाता है।',
        ),
        LabStep(
          concept: 'आयोडीन परिणाम',
          action: 'आयोडीन परीक्षण का अंतिम परिणाम देखें।',
          observation: 'पत्ती साफ़ तौर पर दो रंगों में दिखती है, जिससे पता चलता है कि स्टार्च कहाँ बना था।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

/// The HTML `#scene-content` is a 900 x 600 px coordinate system.
const Size _design = Size(900, 600);
const Offset _mid = Offset(450, 300);
const List<String> _letters = ['A', 'B', 'C'];
const List<String> _potKeys = ['a', 'b', 'c'];

/// Everything that can be dragged (the HTML `.draggable` elements).
enum _Item { sapling, pot, can, slider, plant, cork, leaf, setup, leaf2 }

/// Scene layout in design coordinates (taken from the HTML absolute
/// positions; a few items sit higher so the canvas HUD never covers them).
abstract final class _Geo {
  // ---- Scenario 1
  static const List<double> potX = [150, 386, 622];
  static Rect pot1(int i) => Rect.fromLTWH(potX[i], 128, 128, 128);
  static const Rect tray = Rect.fromLTWH(250, 350, 400, 96);
  static Rect traySapling(int i) =>
      Rect.fromCenter(center: Offset(346 + 104.0 * i, 398), width: 64, height: 64);
  static Rect trayPot(int i) => Rect.fromLTWH(282 + 120.0 * i, 380, 96, 96);
  static const List<double> placedX = [50, 170, 627];
  static Rect placedPot(int i) => Rect.fromLTWH(placedX[i], 380, 96, 96);
  static const Rect potTray = Rect.fromLTRB(268, 296, 632, 492);
  static Rect pot3(int i) => Rect.fromLTWH(potX[i], 272, 128, 128);
  static const Rect can = Rect.fromLTWH(654, 40, 96, 96);

  /// Can offset (from its hook) while it pours into pot [i].
  static Offset pourOffset(int i) => _potSoil(pot3(i)) + const Offset(-46, -44) - can.center;
  static const List<double> potX4 = [100, 350, 680];
  static Rect pot4(int i) => Rect.fromLTWH(potX4[i], 272, 128, 128);
  static Rect potHit4(int i) {
    final b = pot4(i);
    return Rect.fromLTRB(b.left - 10, b.top - 170, b.right + 10, b.bottom);
  }

  static const Rect slider = Rect.fromLTWH(200, 424, 500, 76);
  static const double trackL = 226, trackR = 674, trackY = 478;

  // ---- Scenario 2 (the plant is drawn in the step 2 frame: pot box below)
  static const Rect potS2 = Rect.fromLTWH(130, 324, 160, 160);
  static const Rect plantBounds = Rect.fromLTRB(126, 100, 398, 470);
  static const Offset petiole = Offset(300, 190);
  static const double leafLen = 96;
  static const double sealAngle = math.pi / 3;
  static const Rect closetZone = Rect.fromLTWH(475, 80, 350, 400);
  static const Offset closetOrigin = Offset(475, 105);
  static const double plantScale1 = 0.75;
  static const Offset plantHome = Offset(186, 330);
  static const Offset plantCloset = Offset(551, 312);
  static Rect plantRect(Offset potTopLeft) => Rect.fromLTRB(
        potTopLeft.dx + (plantBounds.left - potS2.left) * plantScale1,
        potTopLeft.dy + (plantBounds.top - potS2.top) * plantScale1,
        potTopLeft.dx + (plantBounds.right - potS2.left) * plantScale1,
        potTopLeft.dy + (plantBounds.bottom - potS2.top) * plantScale1,
      );
  static const Offset mouthHome = Offset(735, 234);
  static const Offset mouthSealed = Offset(324, 234);
  static const Rect bottleHome = Rect.fromLTRB(685, 222, 785, 468);
  static const Offset corkHome = Offset(778, 160);
  static Rect corkBox(Offset o) => Rect.fromCenter(center: corkHome + o, width: 46, height: 30);
  static const Rect leafBox = Rect.fromLTRB(300, 166, 396, 214);
  static const Rect corkTarget = Rect.fromLTRB(268, 158, 402, 222);
  static const double zoom = 1.25;
  static const Offset zoomFocus = Offset(485, 296);
  static const Rect setupBounds = Rect.fromLTRB(126, 100, 384, 470);
  static const Offset sunC = Offset(650, 300);
  static const double sunR = 200;
  static const Offset sunSpot = Offset(790, 150);
  static const Offset setupSun = Offset(380, -6);
  static const Rect station = Rect.fromLTRB(370, 170, 850, 470);
  static const Offset leaf2Home = Offset(300, 356);
  static const double leaf2Rot = 12 * math.pi / 180;
  static Rect leaf2Box(Offset o) => Rect.fromCenter(center: leaf2Home + o, width: 96, height: 48);
  static const List<double> beakerX = [450, 610];
  static Rect beaker(int i) => Rect.fromCenter(center: Offset(beakerX[i], 410), width: 76, height: 104);
  static const Offset tileC = Offset(770, 430);
  static Rect tile() => Rect.fromCenter(center: tileC, width: 128, height: 64);
}

/// Mutable scene model read by the painter every frame (the HTML `state`,
/// `s1_progress` and the DOM positions of the dragged items).
class _PlantScene {
  int scenario = 0;
  int step = 1;
  double time = 0;

  /// In-scene camera (the HTML `zoomCam(1.5, ...)` close-up of the leaf).
  double zoom = 1;
  Offset focus = _mid;

  /// True while a "Proceeding..." transition is pending (input ignored).
  bool locked = false;

  // Drag (HTML pointerdown / pointermove / pointerup on `.draggable`).
  _Item? drag;
  int dragIndex = 0;
  Offset dragStart = Offset.zero;
  Offset dragOffset = Offset.zero;
  _Item? snapItem;
  int snapIndex = 0;
  Offset snapFrom = Offset.zero;
  double snapAt = -10;

  // Scenario 1 (HTML `s1_progress`).
  final List<bool> trayUsed = [false, false, false];
  final List<double> plantedAt = [-1, -1, -1];
  final List<int> zone = [0, 0, 0]; // 0 tray, 1 sunlit window, 2 dark closet
  final List<double> zoneAt = [-10, -10, -10];
  final List<Offset> zoneFrom = [Offset.zero, Offset.zero, Offset.zero];
  final List<double> wateredAt = [-1, -1, -1];
  double crossAt = -10;
  double pourAt = -10;
  int pourPot = 0;
  Offset pourFrom = Offset.zero;
  double growth = 0;
  bool growthDone = false;
  final Set<int> inspected = {};
  bool s1Done = false;

  // Scenario 2.
  double closetAt = -1;
  Offset closetFrom = Offset.zero;
  double dayAt = -1;
  double corkAt = -1;
  double sealAt = -1;
  Offset sealFrom = Offset.zero;
  double sunAt = -1;
  Offset sunFrom = Offset.zero;
  double clockAt = -1;
  double testAt = -1;
  Offset testFrom = Offset.zero;

  bool get inCloset => closetAt >= 0;
  bool get corkOn => corkAt >= 0;
  bool get sealed => sealAt >= 0;
  bool get inSun => sunAt >= 0;
  int get planted => plantedAt.where((v) => v >= 0).length;
  int get placed => zone.where((z) => z != 0).length;
  int get watered => wateredAt.where((v) => v >= 0).length;

  /// Eased 0..1 progress of an animation that started [since] seconds ago.
  static double ease(double since, double duration) =>
      since < 0 ? 0 : Curves.easeInOutCubic.transform((since / duration).clamp(0.0, 1.0));

  double get sealE => sealed ? ease(time - sealAt, 0.8) : 0;

  /// HTML `loadScenario()` / `resetScenarioState()`.
  void resetProgress() {
    zoom = 1;
    focus = _mid;
    locked = false;
    drag = null;
    dragOffset = Offset.zero;
    snapItem = null;
    for (var i = 0; i < 3; i++) {
      trayUsed[i] = false;
      plantedAt[i] = -1;
      zone[i] = 0;
      zoneAt[i] = -10;
      zoneFrom[i] = Offset.zero;
      wateredAt[i] = -1;
    }
    crossAt = -10;
    pourAt = -10;
    growth = 0;
    growthDone = false;
    inspected.clear();
    s1Done = false;
    closetAt = -1;
    dayAt = -1;
    corkAt = -1;
    sealAt = -1;
    sunAt = -1;
    clockAt = -1;
    testAt = -1;
  }

  /// Drag / snap-back offset of an item from its home position.
  Offset offsetOf(_Item item, int i) {
    if (drag == item && dragIndex == i) return dragOffset;
    if (snapItem == item && snapIndex == i) {
      final u = (time - snapAt) / 0.22;
      if (u < 0) return snapFrom;
      if (u < 1) return snapFrom * (1 - Curves.easeOutCubic.transform(u));
    }
    return Offset.zero;
  }

  /// The item's box at its home position (used for drop tests).
  Rect itemBox(_Item item, int i) {
    switch (item) {
      case _Item.sapling:
        return _Geo.traySapling(i);
      case _Item.pot:
        return _Geo.trayPot(i);
      case _Item.can:
        return _Geo.can;
      case _Item.slider:
        return _Geo.slider;
      case _Item.plant:
        return _Geo.plantRect(_Geo.plantHome);
      case _Item.cork:
        return _Geo.corkBox(Offset.zero);
      case _Item.leaf:
        return _Geo.leafBox;
      case _Item.setup:
        return _Geo.setupBounds;
      case _Item.leaf2:
        return _Geo.leaf2Box(Offset.zero);
    }
  }

  /// The draggable item under [p] in the current step, if any.
  ({_Item item, int index})? hitItem(Offset p) {
    if (locked || drag != null) return null;
    if (scenario == 0) {
      switch (step) {
        case 1:
          for (var i = 0; i < 3; i++) {
            if (!trayUsed[i] && _Geo.traySapling(i).inflate(8).contains(p)) return (item: _Item.sapling, index: i);
          }
        case 2:
          for (var i = 0; i < 3; i++) {
            final b = _Geo.trayPot(i);
            if (zone[i] == 0 && Rect.fromLTRB(b.left, b.top - 56, b.right, b.bottom).contains(p)) {
              return (item: _Item.pot, index: i);
            }
          }
        case 3:
          if (_Geo.can.inflate(6).contains(p)) return (item: _Item.can, index: 0);
        case 4:
          if (!growthDone && _Geo.slider.inflate(6).contains(p)) return (item: _Item.slider, index: 0);
      }
    } else {
      switch (step) {
        case 1:
          if (!inCloset && _Geo.plantRect(_Geo.plantHome).contains(p)) return (item: _Item.plant, index: 0);
        case 2:
          if (!corkOn && _Geo.corkBox(Offset.zero).inflate(12).contains(p)) return (item: _Item.cork, index: 0);
          if (corkOn && !sealed && _Geo.leafBox.inflate(10).contains(p)) return (item: _Item.leaf, index: 0);
        case 3:
          if (!inSun && _Geo.setupBounds.contains(p)) return (item: _Item.setup, index: 0);
        case 4:
          if (testAt < 0 && _Geo.leaf2Box(Offset.zero).inflate(12).contains(p)) return (item: _Item.leaf2, index: 0);
      }
    }
    return null;
  }

  /// What the dragged box [r] is over (the HTML `.dropzone` overlap test):
  /// a pot index, a zone id (0 sunlit window / 1 dark closet) or 0 for the
  /// single target of the other items; -1 when nothing.
  int targetOf(_Item item, Rect r) {
    switch (item) {
      case _Item.sapling:
        return _bestOverlap(r, [for (var i = 0; i < 3; i++) _Geo.pot1(i)]);
      case _Item.pot:
        if (_Geo.potTray.contains(r.center)) return -1;
        return r.center.dx < 450 ? 0 : 1;
      case _Item.can:
        return _bestOverlap(r, [for (var i = 0; i < 3; i++) _Geo.pot3(i)]);
      case _Item.plant:
        return r.overlaps(_Geo.closetZone) ? 0 : -1;
      case _Item.cork:
        return r.overlaps(_Geo.corkTarget) ? 0 : -1;
      case _Item.leaf:
        return r.overlaps(_Geo.bottleHome) ? 0 : -1;
      case _Item.setup:
        return (r.center - _Geo.sunC).distance < _Geo.sunR + 10 ? 0 : -1;
      case _Item.leaf2:
        return _Geo.station.contains(r.center) ? 0 : -1;
      case _Item.slider:
        return -1;
    }
  }

  /// Drop target under the item being dragged (HTML `.dragover`).
  int get hover {
    final d = drag;
    if (d == null) return -1;
    return targetOf(d, itemBox(d, dragIndex).shift(dragOffset));
  }

  /// Scenario 1, step 2: pot box (tray, dragged, or settling into its zone).
  Rect potBox2(int i) {
    if (zone[i] == 0) return _Geo.trayPot(i).shift(offsetOf(_Item.pot, i));
    final e = ease(time - zoneAt[i], 0.35);
    return Rect.lerp(_Geo.trayPot(i).shift(zoneFrom[i]), _Geo.placedPot(i), e)!;
  }

  /// Scenario 2, step 1: pot box top-left of the (scaled) potted plant.
  Offset plantTopLeft() {
    if (!inCloset) return _Geo.plantHome + offsetOf(_Item.plant, 0);
    final e = ease(time - closetAt, 0.45);
    return Offset.lerp(_Geo.plantHome + closetFrom, _Geo.plantCloset, e)!;
  }

  /// Scenario 2, step 3: offset of the whole setup.
  Offset setupOffset() {
    if (!inSun) return offsetOf(_Item.setup, 0);
    return Offset.lerp(sunFrom, _Geo.setupSun, ease(time - sunAt, 0.45))!;
  }
}

int _bestOverlap(Rect r, List<Rect> zones) {
  var best = -1;
  var area = 0.0;
  for (var i = 0; i < zones.length; i++) {
    if (!r.overlaps(zones[i])) continue;
    final x = r.intersect(zones[i]);
    final a = x.width * x.height;
    if (a > area) {
      area = a;
      best = i;
    }
  }
  return best;
}

/// One canvas-confetti particle (same physics as `confetti()` defaults:
/// angle 90, spread 45, startVelocity 45, decay 0.9, gravity 1, 200 ticks).
class _Bit {
  _Bit({
    required this.angle,
    required this.velocity,
    required this.wobble,
    required this.wobbleSpeed,
    required this.tilt,
    required this.color,
    required this.circle,
    required this.random,
  });

  double x = 0, y = 0;
  final double angle;
  double velocity;
  double wobble;
  final double wobbleSpeed;
  double tilt;
  final Color color;
  final bool circle;
  final double random;
  int tick = 0;
}

/// Native stand-in for the HTML `confetti()` burst.
class _Confetti {
  static const int ticks = 200;
  static const List<Color> colors = [
    Color(0xFF26CCFF), Color(0xFFA25AFD), Color(0xFFFF5E7E), Color(0xFF88FF5A), //
    Color(0xFFFCFF42), Color(0xFFFFA62D), Color(0xFFFF36FF),
  ];

  final List<_Bit> bits = [];
  double _acc = 0;

  void burst(math.Random rng, {int count = 70}) {
    const spread = 45 * math.pi / 180;
    for (var i = 0; i < count; i++) {
      bits.add(_Bit(
        angle: -math.pi / 2 + (0.5 * spread - rng.nextDouble() * spread),
        velocity: 45 * 0.5 + rng.nextDouble() * 45,
        wobble: rng.nextDouble() * 10,
        wobbleSpeed: math.min(0.11, rng.nextDouble() * 0.1 + 0.05),
        tilt: (rng.nextDouble() * 0.5 + 0.25) * math.pi,
        color: colors[rng.nextInt(colors.length)],
        circle: rng.nextBool(),
        random: rng.nextDouble() + 2,
      ));
    }
  }

  /// Advances the particles by [dt] seconds (canvas-confetti runs one tick
  /// per 60 Hz frame).
  void step(double dt) {
    if (bits.isEmpty) {
      _acc = 0;
      return;
    }
    _acc += dt * 60;
    while (_acc >= 1) {
      _acc -= 1;
      for (final b in bits) {
        b.x += math.cos(b.angle) * b.velocity;
        b.y += math.sin(b.angle) * b.velocity + 3;
        b.velocity *= 0.9;
        b.wobble += b.wobbleSpeed;
        b.tilt += 0.1;
        b.tick++;
      }
      bits.removeWhere((b) => b.tick >= ticks);
    }
  }

  void clear() {
    bits.clear();
    _acc = 0;
  }
}

/// Pan recognizer that only claims touches starting on a draggable item (so
/// empty-canvas drags still pan the zoomed canvas) and starts after a small
/// slop.
class _ItemPanRecognizer extends PanGestureRecognizer {
  _ItemPanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch10A1FactorsEssentialForPlantGrowthPageState extends State<Ch10A1FactorsEssentialForPlantGrowthPage>
    with TickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _PlantScene _s = _PlantScene();
  final _Confetti _confetti = _Confetti();
  final ValueNotifier<double> _frame = ValueNotifier(0);
  final math.Random _rng = math.Random();

  late final Ticker _ticker;
  late final AnimationController _cam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  double _camFromZ = 1, _camToZ = 1;
  Offset _camFromF = _mid, _camToF = _mid;

  /// Full-screen layer for the confetti (above the conclusion popup).
  OverlayEntry? _confettiEntry;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_s.scenario];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;
      final dt = (t - _s.time).clamp(0.0, 0.1);
      _s.time = t;
      _confetti.step(dt);
      _frame.value = t;
    })..start();
    _cam.addListener(() {
      final v = Curves.easeInOutCubic.transform(_cam.value);
      _s.zoom = _camFromZ + (_camToZ - _camFromZ) * v;
      _s.focus = Offset.lerp(_camFromF, _camToF, v)!;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _confettiEntry?.remove();
    _confettiEntry = null;
    _ticker.dispose();
    _cam.dispose();
    _frame.dispose();
    _lab.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ logic

  /// Design (stage) coordinates -> scene coordinates under the camera.
  Offset _toScene(Offset local) => (local - _mid) / _s.zoom + _s.focus;

  void _zoomTo(double z, Offset f) {
    _camFromZ = _s.zoom;
    _camFromF = _s.focus;
    _camToZ = z;
    _camToF = f;
    _cam.forward(from: 0);
  }

  /// HTML `loadScenario()`: cancels timers and rebuilds the scene.
  void _resetScene() {
    _lab.cancelPending();
    _cam.stop();
    _s.resetProgress();
    _confetti.clear();
    _lab.resetView(sound: false);
  }

  void _changeScenario(int index) {
    setState(() {
      _s.scenario = index;
      _s.step = 1;
      _lab.hidePopup(sound: false);
      _resetScene();
    });
  }

  void _fullReset() {
    setState(() {
      _s.scenario = 0;
      _s.step = 1;
      _resetScene();
    });
  }

  /// HTML `completeStep(n)` + `render2DScene()`.
  void _goStep(int step) {
    if (!mounted) return;
    setState(() {
      _s.step = step;
      _s.locked = false;
      _s.snapItem = null;
    });
    if (_s.scenario == 1 && step == 2) _zoomTo(_Geo.zoom, _Geo.zoomFocus);
    if (_s.scenario == 1 && step == 5) _finishScenario2();
  }

  /// Runs [fn] after [ms] while blocking input ("Proceeding...").
  void _proceed(int ms, VoidCallback fn) {
    _s.locked = true;
    _lab.after(Duration(milliseconds: ms), fn);
  }

  /// HTML `updateHUD(..., feedback, type)` -> the shell's feedback toast.
  void _say(String key, {Map<String, Object> args = const {}, bool error = false}) =>
      _lab.showToast(labFormat(_t(key), args), isError: error, sound: false);

  /// HTML `confetti()`: a short burst painted over the whole screen.
  void _burst() {
    if (!mounted) return;
    _confetti.burst(_rng);
    if (_confettiEntry == null) {
      final overlay = Overlay.maybeOf(context);
      if (overlay == null) return;
      _confettiEntry = OverlayEntry(
        builder: (_) => IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(confetti: _confetti, repaint: _frame),
          ),
        ),
      );
      overlay.insert(_confettiEntry!);
    }
  }

  // ---- gestures (HTML pointerdown / pointermove / pointerup)

  void _grab(Offset local) {
    final p = _toScene(local);
    final hit = _s.hitItem(p);
    if (hit == null) return;
    _Audio.play(_Sound.pickup);
    setState(() {
      _s
        ..drag = hit.item
        ..dragIndex = hit.index
        ..dragStart = p
        ..dragOffset = Offset.zero
        ..snapItem = null;
    });
    if (hit.item == _Item.slider) _setGrowth(p.dx);
  }

  void _dragTo(Offset local) {
    final item = _s.drag;
    if (item == null) return;
    final p = _toScene(local);
    if (item == _Item.slider) {
      _setGrowth(p.dx);
      return;
    }
    _s.dragOffset = p - _s.dragStart;
  }

  void _release() {
    final s = _s;
    final item = s.drag;
    if (item == null) return;
    final i = s.dragIndex;
    final off = s.dragOffset;
    s
      ..drag = null
      ..dragOffset = Offset.zero;
    if (item != _Item.slider) {
      s
        ..snapItem = item
        ..snapIndex = i
        ..snapFrom = off
        ..snapAt = s.time;
      if (off.distance >= 2 && _drop(item, i, off)) s.snapItem = null;
    }
    if (mounted) setState(() {});
  }

  /// HTML `handleOrganicDrop(dragId, dropId)`. Returns true when the item
  /// stays where it was dropped (otherwise it slides back home).
  bool _drop(_Item item, int i, Offset off) {
    final s = _s;
    final r = s.itemBox(item, i).shift(off);
    final target = s.targetOf(item, r);
    switch (item) {
      case _Item.sapling:
        if (target < 0 || s.plantedAt[target] >= 0) return false;
        _Audio.play(_Sound.drop);
        s.trayUsed[i] = true;
        s.plantedAt[target] = s.time;
        _say('fb_planted', args: {'n': s.planted});
        if (s.planted == 3) {
          _Audio.play(_Sound.correct);
          _say('fb_setup_done');
          _proceed(1500, () => _goStep(2));
        }
        return true;
      case _Item.pot:
        if (target < 0) return false;
        final ok = (target == 0 && i < 2) || (target == 1 && i == 2);
        if (!ok) {
          _Audio.play(_Sound.wrong);
          _say('fb_wrong_place', error: true);
          return false;
        }
        _Audio.play(_Sound.drop);
        s.zone[i] = target + 1;
        s.zoneAt[i] = s.time;
        s.zoneFrom[i] = off;
        _say(target == 0 ? 'fb_placed_sun' : 'fb_placed_dark', args: {'n': s.placed});
        if (s.placed == 3) {
          _Audio.play(_Sound.correct);
          _say('fb_isolated');
          _proceed(1500, () => _goStep(3));
        }
        return true;
      case _Item.can:
        if (target < 0) return false;
        if (target == 1) {
          _Audio.play(_Sound.wrong);
          _say('fb_no_water_b', error: true);
          s.crossAt = s.time;
          return false;
        }
        if (s.wateredAt[target] < 0) {
          _Audio.play(_Sound.splash);
          s.wateredAt[target] = s.time;
          s.pourAt = s.time;
          s.pourPot = target;
          s.pourFrom = off;
          // Pour for a moment over the pot, then go back to the hook.
          s.snapFrom = _Geo.pourOffset(target);
          s.snapAt = s.time + 0.75;
          _say('fb_watered', args: {'n': s.watered});
          if (s.watered == 2) {
            _Audio.play(_Sound.correct);
            _say('fb_water_done');
            _proceed(1500, () => _goStep(4));
          }
        }
        return false;
      case _Item.plant:
        if (target < 0) return false;
        _Audio.play(_Sound.drop);
        s.closetAt = s.time;
        s.closetFrom = off;
        _say('fb_plant_dark');
        return true;
      case _Item.cork:
        if (target < 0) return false;
        _Audio.play(_Sound.drop);
        s.corkAt = s.time;
        _say('fb_cork');
        return true;
      case _Item.leaf:
        if (target < 0) return false;
        _Audio.play(_Sound.correct);
        s.sealAt = s.time;
        s.sealFrom = off;
        _say('fb_sealed');
        _proceed(2000, () {
          _zoomTo(1, _mid);
          _goStep(3);
        });
        return true;
      case _Item.setup:
        if (target < 0) return false;
        _Audio.play(_Sound.drop);
        s.sunAt = s.time;
        s.sunFrom = off;
        _say('fb_placed_sunlit');
        return true;
      case _Item.leaf2:
        if (target < 0) return false;
        _Audio.play(_Sound.correct);
        s.testAt = s.time;
        s.testFrom = r.center;
        s.locked = true;
        _say('fb_starch_start');
        _startStarchTest();
        return true;
      case _Item.slider:
        return false;
    }
  }

  void _onTapUp(TapUpDetails d) {
    if (!_lab.isLabActive) return;
    final s = _s;
    final p = _toScene(d.localPosition);
    if (s.scenario != 0) return;
    if (s.step == 4 && !s.growthDone && !s.locked && _Geo.slider.inflate(6).contains(p)) {
      _setGrowth(p.dx);
      setState(() {});
    } else if (s.step == 5) {
      for (var i = 0; i < 3; i++) {
        if (_Geo.potHit4(i).contains(p)) {
          _inspect(i);
          return;
        }
      }
    }
  }

  /// HTML `#time-slider` input handler (0..1 = Week 0..Week 2).
  void _setGrowth(double x) {
    final s = _s;
    if (s.growthDone) return;
    s.growth = ((x - _Geo.trackL) / (_Geo.trackR - _Geo.trackL)).clamp(0.0, 1.0);
    if (s.growth >= 1) {
      s
        ..growthDone = true
        ..drag = null;
      _Audio.play(_Sound.correct);
      _say('fb_timelapse');
      _proceed(1500, () => _goStep(5));
      setState(() {});
    }
  }

  /// HTML `clickPot(pot)`: observation card, then the conclusion once all
  /// three pots were inspected.
  void _inspect(int i) {
    final s = _s;
    _Audio.play(_Sound.click);
    final k = _potKeys[i];
    _lab.showPopup(() => LabPopupContent(
          title: _t('sci_obs'),
          icon: Icons.lightbulb,
          heading: _t('obs_${k}_title'),
          body: _t('obs_${k}_desc'),
          extra: _potThumb(i),
        ));
    setState(() => s.inspected.add(i));
    if (s.inspected.length == 3 && !s.s1Done) {
      s.s1Done = true;
      _say('fb_all_inspected');
      _lab.showScenarioConclusion(
        scenarioIndex: 0,
        totalScenarios: 2,
        title: () => _t('sci_obs'),
        heading: () => _t('s1_res_title'),
        body: () => [
          for (final key in _potKeys) '${_t('obs_${key}_title')}: ${_t('obs_${key}_desc')}',
        ].join('\n'),
        extra: () => _conclusionBox(_t('s1_concl'), _t('s1_done'), green: true),
      );
      _lab.after(const Duration(milliseconds: 500), _burst);
    }
  }

  /// HTML `triggerS2Wait2Days()`.
  void _wait2Days() {
    if (_s.dayAt >= 0) return;
    _Audio.play(_Sound.whoosh);
    setState(() => _s.dayAt = _s.time);
    _say('fb_time_passing');
    _lab.after(const Duration(milliseconds: 2000), () {
      _goStep(2);
      _lab.after(const Duration(milliseconds: 500), () => _say('fb_destarched'));
    });
  }

  /// HTML `triggerS2Wait6Hours()`.
  void _wait6Hours() {
    if (_s.clockAt >= 0) return;
    _Audio.play(_Sound.magic);
    setState(() => _s.clockAt = _s.time);
    _say('fb_photo');
    _lab.after(const Duration(milliseconds: 2500), () => _goStep(4));
  }

  /// HTML `triggerS2StarchTestSequence()`: boiling water (0 s), alcohol
  /// (2 s), white tile (4 s), iodine dropper (5 s), result (7 s). The leaf's
  /// path is drawn by the painter from `testAt`.
  void _startStarchTest() {
    _Audio.play(_Sound.bubble);
    _lab.after(const Duration(milliseconds: 2000), () => _Audio.play(_Sound.bubble));
    _lab.after(const Duration(milliseconds: 5500), () => _Audio.play(_Sound.drop));
    _lab.after(const Duration(milliseconds: 7000), () => _goStep(5));
  }

  /// Scenario 2, step 5: the HTML shows the conclusion 1 s after the result.
  void _finishScenario2() {
    const delay = Duration(milliseconds: 1000);
    _lab.showScenarioConclusion(
      scenarioIndex: 1,
      totalScenarios: 2,
      delay: delay,
      title: () => _t('sci_obs'),
      heading: () => _t('s2_res_title'),
      body: () => '${_t('s2_p1')}\n\n${_t('s2_p2')}',
      extra: () => _conclusionBox(_t('s2_concl'), _t('s2_done'), green: false),
    );
    _lab.after(delay, _burst);
  }

  List<LabAction> _actions() {
    final s = _s;
    final p = _lab.palette;
    if (s.scenario == 1 && s.step == 1 && s.inCloset && s.dayAt < 0) {
      return [
        LabAction(
          label: _t('wait_2d'),
          icon: Icons.nights_stay,
          color: p.accent,
          foreground: p.onAccent,
          highlight: true,
          silent: true,
          onTap: _wait2Days,
        ),
      ];
    }
    if (s.scenario == 1 && s.step == 3 && s.inSun && s.clockAt < 0) {
      return [
        LabAction(
          label: _t('wait_6h'),
          icon: Icons.wb_sunny,
          color: p.accent,
          foreground: p.onAccent,
          highlight: true,
          silent: true,
          onTap: _wait6Hours,
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
        final actions = _actions();
        final inset = labOverlayInsets(context, _lab);
        return LabShell(
          controller: _lab,
          icon: Icons.eco,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1'), _t('scen_2')],
          scenarioIndex: _s.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: _s.step,
          actions: actions,
          sidebarExtraTitle: _t('exp_out'),
          sidebarExtra: _outcomeCard(p, s),
          onReset: _fullReset,
          overlays: [
            // HTML `#hud-actions`: the step's button under the canvas HUD
            // (the sidebar copy may be scrolled out of view).
            if (actions.isNotEmpty && _lab.isSidebarOpen)
              Positioned(
                left: inset.left,
                right: inset.right,
                bottom: inset.bottom + 62 * s,
                child: Center(
                  child: LabActionButton(action: actions.first, scale: s, expand: false),
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
                    ..accepts = ((local) => _lab.isLabActive && _s.hitItem(_toScene(local)) != null)
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
                painter: _ScenePainter(
                  scene: _s,
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

  /// The HTML teacher board's "Expected Outcome from the Task" for the
  /// current step.
  Widget _outcomeCard(LabPalette p, double s) {
    final f = s * _lab.fontScale;
    final steps = _data.steps;
    final step = steps[(_s.step - 1).clamp(0, steps.length - 1)];
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.info.withValues(alpha: 0.5)),
      ),
      child: Text(
        step.observation,
        style: TextStyle(color: p.text, fontSize: 12 * f, height: 1.4, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Coloured conclusion box + "Scenario N Completed" line (HTML
  /// `bg-green-100` / `bg-blue-100` boxes in the conclusion popups).
  Widget _conclusionBox(String conclusion, String done, {required bool green}) {
    final s = context.labScale;
    final p = _lab.palette;
    final dark = p.isDark;
    final bg = green
        ? (dark ? const Color(0x3322C55E) : const Color(0xFFDCFCE7))
        : (dark ? const Color(0x333B82F6) : const Color(0xFFDBEAFE));
    final fg = green
        ? (dark ? _Colors.green400 : _Colors.green800)
        : (dark ? _Colors.blue300 : const Color(0xFF1E40AF));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: fg.withValues(alpha: 0.5)),
          ),
          child: Text(
            conclusion,
            textAlign: TextAlign.center,
            style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13 * s, height: 1.35),
          ),
        ),
        SizedBox(height: 10 * s),
        Text(
          done,
          textAlign: TextAlign.center,
          style: TextStyle(color: p.textStrong, fontWeight: FontWeight.w800, fontSize: 12.5 * s),
        ),
      ],
    );
  }

  /// Small picture of the pot's final plant for its observation card.
  Widget _potThumb(int pot) {
    final s = context.labScale;
    return Center(
      child: SizedBox(
        width: 150 * s,
        height: 118 * s,
        child: CustomPaint(painter: _ThumbPainter(pot: pot, isDark: _lab.isDark)),
      ),
    );
  }
}

// ============================================================ PAINTING

double _smooth(double a, double b, double v) {
  final x = ((v - a) / (b - a)).clamp(0.0, 1.0);
  return x * x * (3 - 2 * x);
}

double _ease(double u) => Curves.easeInOutCubic.transform(u.clamp(0.0, 1.0));

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Point where a sapling's stem meets the soil of a pot drawn in [box].
Offset _potSoil(Rect box) => Offset(box.center.dx, box.top + box.height * 0.11);

/// HTML `SVGS.pot(lbl)`: terracotta pot with a white label disc, in its
/// 100 x 100 box. [wet] darkens the soil (watered), [cracks] dries it out.
void _paintPot(Canvas c, Rect box, String letter, {double wet = 0, double cracks = 0, bool disc = true}) {
  final k = box.width / 100;
  Offset p(double x, double y) => Offset(box.left + x * k, box.top + y * k);
  labGroundShadow(c, p(50, 91), 64 * k, 9 * k, opacity: 0.32);
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3 * k
    ..strokeJoin = StrokeJoin.round
    ..color = _Colors.orange900;
  final body = Path()..addPolygon([p(20, 20), p(80, 20), p(70, 90), p(30, 90)], true);
  c.drawPath(
    body,
    Paint()
      ..shader = const LinearGradient(
        colors: [_Colors.orange800, _Colors.orange700, Color(0xFFE8692C), _Colors.orange700, _Colors.orange900],
        stops: [0, 0.3, 0.45, 0.72, 1],
      ).createShader(Rect.fromPoints(p(20, 20), p(80, 90))),
  );
  c.drawPath(body, edge);
  if (disc) {
    c.drawCircle(p(50, 60), 20 * k, Paint()..color = Colors.white);
    c.drawCircle(p(50, 60), 20 * k, edge);
    if (letter.isNotEmpty) {
      labText(c, letter, p(50, 60.5), size: 24 * k, weight: FontWeight.w900, color: _Colors.orange900);
    }
  }
  final rim = RRect.fromRectAndRadius(Rect.fromPoints(p(15, 10), p(85, 25)), Radius.circular(5 * k));
  c.drawRRect(
    rim,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_Colors.orange400, _Colors.orange600, _Colors.orange700],
      ).createShader(rim.outerRect),
  );
  c.drawRRect(rim, edge);
  // Soil in the mouth of the pot.
  final soil = Rect.fromCenter(center: p(50, 11), width: 62 * k, height: 6 * k);
  c.drawOval(soil, Paint()..color = Color.lerp(const Color(0xFF7A5634), const Color(0xFF3A2414), wet)!);
  if (wet > 0) {
    c.drawOval(
      Rect.fromCenter(center: p(40, 10.2), width: 18 * k, height: 1.6 * k),
      Paint()..color = Colors.white.withValues(alpha: 0.3 * wet),
    );
  }
  if (cracks > 0) {
    final crack = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * k
      ..color = const Color(0xFF4A2F18).withValues(alpha: cracks);
    for (final x in [30.0, 46.0, 60.0, 72.0]) {
      c.drawPath(
        Path()
          ..moveTo(p(x, 9.5).dx, p(x, 9.5).dy)
          ..lineTo(p(x + 3, 11).dx, p(x + 3, 11).dy)
          ..lineTo(p(x + 1, 12.6).dx, p(x + 1, 12.6).dy),
        crack,
      );
    }
  }
}

/// HTML `SVGS.sapling(fill)`: stem plus three leaves, in a 100 x 100 box
/// whose stem foot (50, 90) sits at [base]. [sx] / [sy] are the HTML growth
/// transforms; [droop] wilts the plant, [extra] grows new leaves.
void _paintSapling(
  Canvas c,
  Offset base,
  double size, {
  double sx = 1,
  double sy = 1,
  Color fill = _Colors.green500,
  Color stroke = _Colors.green800,
  double droop = 0,
  double extra = 0,
}) {
  if (size <= 0.5) return;
  final k = size / 100;
  // Leaves stretch less than the stem (an etiolated plant is mostly stem).
  final ly = math.min(sy, sx * 1.5);
  Offset map(Offset v) => Offset(base.dx + (v.dx - 50) * k * sx, base.dy + (v.dy - 90) * k * sy);
  const foot = Offset(50, 90);
  const ctrl = Offset(50, 60);
  final tip = Offset(50 + 22 * droop, 30 + 16 * droop);
  Offset stemAt(double t) {
    final u = 1 - t;
    return foot * (u * u) + ctrl * (2 * u * t) + tip * (t * t);
  }

  final sw = 4 * k * math.sqrt(sx * ly).clamp(0.6, 1.6);
  final line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = sw
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = stroke;
  final f = map(foot), cp = map(ctrl), tp = map(tip);
  c.drawPath(Path()..moveTo(f.dx, f.dy)..quadraticBezierTo(cp.dx, cp.dy, tp.dx, tp.dy), line);

  // One leaf: quadratic lens from the stem point at [t] (svg units relative
  // to that point), turned by [turn] and scaled by [scale].
  void leaf(double t, Offset c1, Offset end, Offset c2, double turn, double scale) {
    if (scale <= 0.01) return;
    final at = map(stemAt(t));
    final cs = math.cos(turn), sn = math.sin(turn);
    Offset m(Offset v) {
      final r = Offset(v.dx * cs - v.dy * sn, v.dx * sn + v.dy * cs) * scale;
      return Offset(at.dx + r.dx * k * sx, at.dy + r.dy * k * ly);
    }

    final p1 = m(c1), pe = m(end), p2 = m(c2);
    final path = Path()
      ..moveTo(at.dx, at.dy)
      ..quadraticBezierTo(p1.dx, p1.dy, pe.dx, pe.dy)
      ..quadraticBezierTo(p2.dx, p2.dy, at.dx, at.dy)
      ..close();
    c.drawPath(path, Paint()..color = fill);
    c.drawLine(
      at,
      Offset.lerp(at, pe, 0.72)!,
      Paint()
        ..strokeWidth = sw * 0.4
        ..strokeCap = StrokeCap.round
        ..color = labShade(fill, 0.35),
    );
    c.drawPath(path, line);
  }

  if (extra > 0) {
    leaf(0.5, const Offset(-20, 10), const Offset(-30, -10), const Offset(-10, -20), -0.2, 0.85 * extra);
    leaf(0.17, const Offset(20, 10), const Offset(30, -10), const Offset(10, -20), 0.1, 0.75 * extra);
    leaf(0.84, const Offset(20, 2), const Offset(26, -14), const Offset(6, -18), 0, 0.6 * extra);
  }
  leaf(1 / 3, const Offset(-20, 10), const Offset(-30, -10), const Offset(-10, -20), -0.7 * droop, 1);
  leaf(2 / 3, const Offset(20, 10), const Offset(30, -10), const Offset(10, -20), 0.8 * droop, 1);
  leaf(1, const Offset(-20, 0), const Offset(-10, -20), const Offset(10, -20), -0.9 * droop, 1);
}

/// Scenario 1, steps 4-5: the pot and its plant after [v] of the two weeks
/// (HTML `#time-slider` transforms: A grows, B wilts brown, C etiolates).
void _paintGrowth(Canvas c, Rect box, int pot, double v) {
  _paintPot(c, box, _letters[pot], wet: pot == 1 ? 0 : 1, cracks: pot == 1 ? _smooth(0.3, 0.8, v) : 0);
  final base = _potSoil(box);
  final size = box.width * 0.625;
  switch (pot) {
    case 0:
      _paintSapling(c, base, size, sx: 1 + 1.5 * v, sy: 1 + 1.5 * v, extra: _smooth(0.35, 1, v));
    case 1:
      _paintSapling(
        c,
        base,
        size,
        sx: 1 - 0.1 * v,
        sy: 1 - 0.4 * v,
        droop: v,
        fill: Color.lerp(_Colors.green500, _Colors.wilted, _smooth(0.4, 0.6, v))!,
        stroke: Color.lerp(_Colors.green800, const Color(0xFF5C3317), _smooth(0.5, 0.9, v))!,
      );
    default:
      _paintSapling(
        c,
        base,
        size,
        sx: 1 - 0.2 * v,
        sy: 1 + 2 * v,
        fill: Color.lerp(_Colors.green500, _Colors.yellow500, _smooth(0.2, 0.4, v))!,
        stroke: Color.lerp(_Colors.green800, const Color(0xFFA16207), _smooth(0.3, 0.8, v))!,
      );
  }
}

/// The HTML leaf (`M0 25 C40 0, 80 0, 100 25 C80 50, 40 50, 0 25`): a lens
/// from [base] along [angle], [len] long and [width] wide. [tipFill] colours
/// the tip half differently (the iodine result).
void _paintLeaf(
  Canvas c,
  Offset base,
  double angle,
  double len, {
  double? width,
  Color fill = _Colors.lime400,
  Color stroke = _Colors.green800,
  Color? tipFill,
  Color? tipStroke,
  double glow = 0,
}) {
  final w = width ?? len / 2;
  c.save();
  c.translate(base.dx, base.dy);
  c.rotate(angle);
  final path = Path()
    ..moveTo(0, 0)
    ..cubicTo(0.4 * len, -w / 2, 0.8 * len, -w / 2, len, 0)
    ..cubicTo(0.8 * len, w / 2, 0.4 * len, w / 2, 0, 0)
    ..close();
  if (glow > 0) {
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = _Colors.yellow300.withValues(alpha: 0.6 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }
  final bounds = Rect.fromLTRB(0, -w / 2, len, w / 2);
  Paint fillPaint(Color col) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [labShade(col, 0.18), col, labShade(col, -0.15)],
    ).createShader(bounds);
  Paint edge(Color col) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.2, len * 0.018)
    ..strokeJoin = StrokeJoin.round
    ..color = col;
  void half(bool tip, void Function() draw) {
    c.save();
    c.clipRect(tip ? Rect.fromLTRB(len / 2, -w, len + 4, w) : Rect.fromLTRB(-4, -w, len / 2, w));
    draw();
    c.restore();
  }

  if (tipFill == null) {
    c.drawPath(path, fillPaint(fill));
  } else {
    half(false, () => c.drawPath(path, fillPaint(fill)));
    half(true, () => c.drawPath(path, fillPaint(tipFill)));
  }
  // Midrib and side veins.
  final vein = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(0.8, len * 0.011)
    ..strokeCap = StrokeCap.round
    ..color = Colors.white.withValues(alpha: 0.3);
  c.drawLine(Offset(len * 0.03, 0), Offset(len * 0.93, 0), vein);
  for (var i = 0; i < 4; i++) {
    final x0 = len * (0.14 + 0.17 * i);
    final u = (x0 + len * 0.12) / len;
    final reach = 1.05 * w * u * (1 - u);
    c.drawLine(Offset(x0, 0), Offset(x0 + len * 0.12, -reach), vein);
    c.drawLine(Offset(x0, 0), Offset(x0 + len * 0.12, reach), vein);
  }
  if (tipStroke == null) {
    c.drawPath(path, edge(stroke));
  } else {
    half(false, () => c.drawPath(path, edge(stroke)));
    half(true, () => c.drawPath(path, edge(tipStroke)));
  }
  c.restore();
}

/// HTML `SVGS.closet`: a wardrobe with both doors open, its 100 x 100 box
/// scaled by [k] from [o]. [shelf] is the shelf height in box units.
void _paintCloset(Canvas c, Offset o, double k, {double? shelf = 45, double opacity = 1, bool knobs = true}) {
  Offset p(double x, double y) => o + Offset(x * k, y * k);
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1, 0.5 * k)
    ..color = a(_Colors.closetEdge);
  for (final door in [
    [p(5, 5), p(-20, 15), p(-20, 85), p(5, 95)],
    [p(95, 5), p(120, 15), p(120, 85), p(95, 95)],
  ]) {
    final path = Path()..addPolygon(door, true);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [a(_Colors.closetDoor), a(labShade(_Colors.closetDoor, -0.25))],
        ).createShader(path.getBounds()),
    );
    c.drawPath(path, edge);
  }
  // Door panels.
  for (final panel in [
    [p(1, 14), p(-15, 20), p(-15, 46), p(1, 44)],
    [p(1, 56), p(-15, 54), p(-15, 80), p(1, 86)],
    [p(99, 14), p(115, 20), p(115, 46), p(99, 44)],
    [p(99, 56), p(115, 54), p(115, 80), p(99, 86)],
  ]) {
    c.drawPath(Path()..addPolygon(panel, true), edge);
  }
  if (knobs) {
    c.drawCircle(p(-15, 50), 2 * k, Paint()..color = a(_Colors.gold));
    c.drawCircle(p(115, 50), 2 * k, Paint()..color = a(_Colors.gold));
  }
  final body = RRect.fromRectAndRadius(Rect.fromPoints(p(5, 5), p(95, 95)), Radius.circular(4 * k));
  c.drawRRect(body, Paint()..color = a(_Colors.closetWood));
  c.drawRRect(body, edge);
  final inner = Rect.fromPoints(p(10, 10), p(90, 90));
  c.drawRRect(
    RRect.fromRectAndRadius(inner, Radius.circular(2 * k)),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [a(const Color(0xFF050505)), a(const Color(0xFF1C1917))],
      ).createShader(inner),
  );
  if (shelf != null) {
    final r = Rect.fromPoints(p(10, shelf), p(90, shelf + 4));
    c.drawRect(r, Paint()..color = a(_Colors.closetShelf));
    c.drawRect(r, edge);
  }
}

/// HTML `SVGS.sun` / the Phosphor sun icon: disc, eight rays and a glow.
void _paintSun(Canvas c, Offset ctr, double r, double spin, {double glow = 1}) {
  labGlow(c, ctr, r * 3.4, _Colors.yellow200, intensity: 0.75 * glow);
  final ray = Paint()
    ..strokeWidth = r * 0.3
    ..strokeCap = StrokeCap.round
    ..color = _Colors.amber500;
  for (var i = 0; i < 8; i++) {
    final a = spin + i * math.pi / 4;
    final d = Offset(math.cos(a), math.sin(a));
    c.drawLine(ctr + d * (r * 1.5), ctr + d * (r * 2), ray);
  }
  c.drawCircle(
    ctr,
    r,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [_Colors.yellow200, _Colors.amber400, _Colors.amber500],
        stops: [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: ctr, radius: r)),
  );
}

/// HTML `SVGS.waterCan` in its 100 x 100 box, tipped by [tilt] radians.
void _paintCan(Canvas c, Rect box, double tilt) {
  final k = box.width / 100;
  Offset p(double x, double y) => Offset(box.left + x * k, box.top + y * k);
  c.save();
  c.translate(box.center.dx, box.center.dy);
  c.rotate(tilt);
  c.translate(-box.center.dx, -box.center.dy);
  labGroundShadow(c, p(50, 92), 46 * k, 7 * k, opacity: 0.25);
  // Handle.
  c.drawPath(
    Path()
      ..moveTo(p(30, 50).dx, p(30, 50).dy)
      ..cubicTo(p(10, 50).dx, p(10, 50).dy, p(10, 80).dx, p(10, 80).dy, p(30, 80).dx, p(30, 80).dy),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 * k
      ..strokeCap = StrokeCap.round
      ..color = _Colors.blue500,
  );
  // Spout and rose.
  c.drawLine(
    p(70, 60),
    p(90, 30),
    Paint()
      ..strokeWidth = 8 * k
      ..strokeCap = StrokeCap.round
      ..color = _Colors.slate400,
  );
  final rose = Rect.fromCenter(center: p(90, 30), width: 10 * k, height: 20 * k);
  c.drawOval(rose, Paint()..color = _Colors.slate300);
  c.drawOval(
    rose,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * k
      ..color = _Colors.slate600,
  );
  // Body.
  final body = RRect.fromRectAndRadius(Rect.fromPoints(p(30, 40), p(70, 90)), Radius.circular(5 * k));
  c.drawRRect(
    body,
    Paint()
      ..shader = const LinearGradient(
        colors: [_Colors.blue600, _Colors.blue400, _Colors.blue500, Color(0xFF1D4ED8)],
        stops: [0, 0.3, 0.6, 1],
      ).createShader(body.outerRect),
  );
  c.drawRRect(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * k
      ..color = _Colors.blue900,
  );
  c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromPoints(p(28, 37), p(72, 43)), Radius.circular(3 * k)),
    Paint()..color = _Colors.blue900,
  );
  c.restore();
}

/// Where the watering can's rose is, for a can in [box] tipped by [tilt].
Offset _canRose(Rect box, double tilt) {
  final k = box.width / 100;
  final v = Offset((90 - 50) * k, (30 - 50) * k);
  final cs = math.cos(tilt), sn = math.sin(tilt);
  return box.center + Offset(v.dx * cs - v.dy * sn, v.dx * sn + v.dy * cs);
}

/// The HTML water-drop badge (24 x 24 icon) centred at [ctr].
void _paintWaterDrop(Canvas c, Offset ctr, double size, {double opacity = 1}) {
  final k = size / 24;
  Offset p(double x, double y) => ctr + Offset((x - 12) * k, (y - 12) * k);
  final path = Path()
    ..moveTo(p(12, 3).dx, p(12, 3).dy)
    ..cubicTo(p(12, 3).dx, p(12, 3).dy, p(18, 10).dx, p(18, 10).dy, p(18, 14).dx, p(18, 14).dy)
    ..arcToPoint(p(6, 14), radius: Radius.circular(6 * k))
    ..cubicTo(p(6, 10).dx, p(6, 10).dy, p(12, 3).dx, p(12, 3).dy, p(12, 3).dx, p(12, 3).dy)
    ..close();
  c.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_Colors.blue400.withValues(alpha: opacity), _Colors.blue600.withValues(alpha: opacity)],
      ).createShader(path.getBounds()),
  );
  c.drawCircle(p(9.5, 14), 1.6 * k, Paint()..color = Colors.white.withValues(alpha: 0.6 * opacity));
}

/// HTML `SVGS.cross`: red "not allowed" badge.
void _paintCross(Canvas c, Offset ctr, double r, {double opacity = 1}) {
  c.drawCircle(
    ctr + const Offset(0, 3),
    r,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.25 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
  );
  c.drawCircle(ctr, r, Paint()..color = _Colors.red500.withValues(alpha: opacity));
  final x = Paint()
    ..strokeWidth = r * 0.25
    ..strokeCap = StrokeCap.round
    ..color = Colors.white.withValues(alpha: opacity);
  final d = r * 0.375;
  c.drawLine(ctr + Offset(-d, -d), ctr + Offset(d, d), x);
  c.drawLine(ctr + Offset(d, -d), ctr + Offset(-d, d), x);
}

/// HTML `SVGS.cork`: split cork stopper centred at [ctr].
void _paintCork(Canvas c, Offset ctr, double scale, {double opacity = 1}) {
  if (opacity <= 0) return;
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  final w = 48 * scale, h = 24 * scale;
  final path = Path()
    ..addPolygon([
      ctr + Offset(-w / 2, -h / 2),
      ctr + Offset(w / 2, -h / 2),
      ctr + Offset(w * 0.4, h / 2),
      ctr + Offset(-w * 0.4, h / 2),
    ], true);
  c.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        colors: [a(_Colors.amber700), a(_Colors.amber500), a(_Colors.amber600), a(_Colors.amber800)],
        stops: const [0, 0.35, 0.65, 1],
      ).createShader(path.getBounds()),
  );
  c.drawOval(
    Rect.fromCenter(center: ctr + Offset(0, -h / 2), width: w, height: h * 0.32),
    Paint()..color = a(const Color(0xFFF2B65A)),
  );
  final edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6 * scale
    ..color = a(_Colors.amber900);
  c.drawPath(path, edge);
  c.drawLine(ctr + Offset(0, -h / 2), ctr + Offset(0, h / 2), edge);
  final pore = Paint()..color = a(_Colors.amber900.withValues(alpha: 0.5));
  for (final d in const [Offset(-12, -2), Offset(9, 4), Offset(-5, 6), Offset(14, -4)]) {
    c.drawCircle(ctr + d * scale, 1.3 * scale, pore);
  }
}

/// Glass of the wide-mouthed bottle whose mouth centre is [m].
Path _bottlePath(Offset m) {
  final x = m.dx, y = m.dy;
  return Path()
    ..moveTo(x - 24, y)
    ..lineTo(x - 24, y + 14)
    ..cubicTo(x - 24, y + 26, x - 42, y + 24, x - 42, y + 38)
    ..lineTo(x - 42, y + 100)
    ..quadraticBezierTo(x - 42, y + 112, x - 30, y + 112)
    ..lineTo(x + 30, y + 112)
    ..quadraticBezierTo(x + 42, y + 112, x + 42, y + 100)
    ..lineTo(x + 42, y + 38)
    ..cubicTo(x + 42, y + 24, x + 24, y + 26, x + 24, y + 14)
    ..lineTo(x + 24, y)
    ..close();
}

/// HTML `SVGS.bottle` (back half): wooden stand, NaOH solution, glass.
void _paintBottleBack(Canvas c, Offset m, double floorY) {
  final bottom = m.dy + 112;
  labGroundShadow(c, Offset(m.dx, floorY), 110, 10, opacity: 0.28);
  labBox3D(c, Rect.fromLTRB(m.dx - 46, bottom, m.dx + 42, floorY), 10, _Colors.wood);
  final body = _bottlePath(m);
  c.drawPath(body, Paint()..color = const Color(0x40E2E8F0));
  c.save();
  c.clipPath(body);
  final liquid = Rect.fromLTRB(m.dx - 44, m.dy + 74, m.dx + 44, bottom);
  c.drawRect(
    liquid,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x99BAE6FD), Color(0xB37DD3FC)],
      ).createShader(liquid),
  );
  c.drawOval(
    Rect.fromCenter(center: Offset(m.dx, m.dy + 74), width: 84, height: 7),
    Paint()..color = const Color(0x99E0F2FE),
  );
  c.restore();
}

/// HTML `SVGS.bottle` (front half): glass outline, lip and the NaOH label.
void _paintBottleFront(Canvas c, Offset m, {String? label, double labelOpacity = 0}) {
  final body = _bottlePath(m);
  c.drawPath(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..color = _Colors.slate400,
  );
  c.drawLine(
    Offset(m.dx - 34, m.dy + 44),
    Offset(m.dx - 34, m.dy + 100),
    Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.45),
  );
  final lip = RRect.fromRectAndRadius(
    Rect.fromCenter(center: m, width: 56, height: 8),
    const Radius.circular(4),
  );
  c.drawRRect(lip, Paint()..color = const Color(0xCCE2E8F0));
  c.drawRRect(
    lip,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _Colors.slate400,
  );
  if (label != null && labelOpacity > 0) {
    labText(
      c,
      label,
      Offset(m.dx, m.dy + 92),
      size: 10,
      weight: FontWeight.w800,
      color: _Colors.slate700,
      background: const Color(0xE6FFFFFF),
      border: _Colors.slate300,
      radius: 4,
      maxWidth: 76,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      opacity: labelOpacity,
    );
  }
}

/// HTML `SVGS.clock` (192 px, red hand spinning once a second).
void _paintClock(Canvas c, Offset ctr, double r, double since, double opacity) {
  if (opacity <= 0) return;
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  c.drawCircle(
    ctr + const Offset(0, 8),
    r * 0.94,
    Paint()
      ..color = a(const Color(0x66000000))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
  );
  c.drawCircle(ctr, r * 0.9, Paint()..color = a(Colors.white));
  c.drawCircle(
    ctr,
    r * 0.9,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..color = a(_Colors.slate700),
  );
  final tick = Paint()
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..color = a(_Colors.slate400);
  for (var i = 0; i < 12; i++) {
    final ang = i * math.pi / 6;
    final d = Offset(math.cos(ang), math.sin(ang));
    c.drawLine(ctr + d * (r * 0.66), ctr + d * (r * (i % 3 == 0 ? 0.76 : 0.72)), tick);
  }
  final hour = since * 2 * math.pi / 12 - math.pi / 2;
  c.drawLine(
    ctr,
    ctr + Offset(math.cos(hour), math.sin(hour)) * r * 0.38,
    Paint()
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round
      ..color = a(_Colors.slate700),
  );
  final hand = since * 2 * math.pi - math.pi / 2;
  c.drawLine(
    ctr,
    ctr + Offset(math.cos(hand), math.sin(hand)) * r * 0.62,
    Paint()
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round
      ..color = a(_Colors.red500),
  );
  c.drawCircle(ctr, r * 0.06, Paint()..color = a(_Colors.slate700));
}

/// HTML `SVGS.beaker(color, label)` with its rising bubbles.
void _paintBeaker(Canvas c, Rect r, Color liquid, String text, double t, {bool boiling = false}) {
  labGroundShadow(c, Offset(r.center.dx, r.bottom), r.width * 1.1, 8, opacity: 0.25);
  labBeaker(c, r, fill: 0.55, liquid: liquid, glass: _Colors.slate300, liquidOpacity: 0.62);
  final inner = r.deflate(3);
  final top = inner.bottom - inner.height * 0.55;
  final n = boiling ? 9 : 4;
  for (var i = 0; i < n; i++) {
    final ph = (t * (boiling ? 0.9 : 0.55) + i / n) % 1.0;
    final x = r.center.dx + math.sin(i * 2.3 + t * 2) * inner.width * 0.3;
    final y = inner.bottom - 6 - ph * (inner.bottom - 6 - top);
    c.drawCircle(
      Offset(x, y),
      (boiling ? 2.2 : 1.8) + ph * 1.6,
      Paint()..color = Colors.white.withValues(alpha: 0.75 * (1 - ph)),
    );
  }
  if (boiling) {
    final steam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final ph = (t * 0.5 + i / 3) % 1.0;
      final x0 = r.center.dx + (i - 1) * 16;
      final path = Path()..moveTo(x0, r.top - 4 - ph * 30);
      for (var d = 0.0; d <= 26; d += 2) {
        path.lineTo(x0 + 4 * math.sin(d / 5 + t * 4 + i), r.top - 4 - ph * 30 - d);
      }
      c.drawPath(path, steam..color = Colors.white.withValues(alpha: 0.35 * (1 - ph)));
    }
  }
  labText(
    c,
    text,
    Offset(r.center.dx, (top + inner.bottom) / 2 + 6),
    size: 11,
    weight: FontWeight.w800,
    color: Colors.white,
    maxWidth: r.width - 6,
    shadows: const [Shadow(color: Color(0x99000000), blurRadius: 3)],
  );
}

/// HTML `SVGS.tile`: the white tile (a rhombus in a 100 x 50 box).
void _paintTile(Canvas c, Rect r) {
  Offset p(double u, double v) => Offset(r.left + u * r.width / 100, r.top + v * r.height / 50);
  final path = Path()..addPolygon([p(10, 25), p(50, 5), p(90, 25), p(50, 45)], true);
  labGroundShadow(c, p(50, 30), r.width * 0.78, r.height * 0.45, opacity: 0.2);
  c.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, _Colors.slate100, _Colors.slate200],
      ).createShader(r),
  );
  c.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = _Colors.slate300,
  );
}

/// HTML `SVGS.dropper`: iodine dropper whose nozzle is at [tip].
void _paintDropper(Canvas c, Offset tip, double opacity) {
  if (opacity <= 0) return;
  Color a(Color col) => col.withValues(alpha: col.a * opacity);
  final tube = Path()
    ..addPolygon([
      tip + const Offset(-7, -64),
      tip + const Offset(-7, -14),
      tip + const Offset(-2, 0),
      tip + const Offset(2, 0),
      tip + const Offset(7, -14),
      tip + const Offset(7, -64),
    ], true);
  c.drawPath(tube, Paint()..color = a(const Color(0xCCFFFFFF)));
  c.save();
  c.clipPath(tube);
  c.drawRect(Rect.fromLTRB(tip.dx - 8, tip.dy - 34, tip.dx + 8, tip.dy), Paint()..color = a(const Color(0xDDB45309)));
  c.restore();
  c.drawPath(
    tube,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = a(_Colors.slate400),
  );
  final bulb = RRect.fromRectAndRadius(
    Rect.fromLTRB(tip.dx - 10, tip.dy - 90, tip.dx + 10, tip.dy - 62),
    const Radius.circular(9),
  );
  c.drawRRect(
    bulb,
    Paint()
      ..shader = LinearGradient(colors: [a(const Color(0xFFF87171)), a(_Colors.red500), a(const Color(0xFFB91C1C))])
          .createShader(bulb.outerRect),
  );
}

// Scenario 2 plant (drawn in the step 2 frame, pot box _Geo.potS2).
const Offset _stem0 = Offset(210, 343);
const Offset _stem1 = Offset(213, 280);
const Offset _stem2 = Offset(178, 210);
const Offset _stem3 = Offset(172, 128);

Offset _stemAt(double t) {
  final u = 1 - t;
  return _stem0 * (u * u * u) + _stem1 * (3 * u * u * t) + _stem2 * (3 * u * t * t) + _stem3 * (t * t * t);
}

/// The scenario 2 potted plant (HTML step 2 SVG: main stem, branch and
/// leaves) without the target leaf. [stub] shows the cut branch end.
void _paintS2Plant(Canvas c, Color leaf, {bool stub = false}) {
  _paintPot(c, _Geo.potS2, '', disc: false);
  void side(double t, double angle, double len, double w) {
    final a = _stemAt(t);
    final dir = Offset(math.cos(angle), math.sin(angle));
    final base = a + dir * 6;
    c.drawLine(
      a,
      base,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = _Colors.green800,
    );
    _paintLeaf(c, base, angle, len, width: w, fill: leaf);
  }

  side(0.22, math.pi + 0.30, 62, 30);
  side(0.42, -0.35, 44, 22);
  side(0.64, math.pi + 0.55, 54, 26);
  side(0.82, -0.75, 40, 20);
  final stem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.round
    ..color = _Colors.green800;
  c.drawPath(
    Path()
      ..moveTo(_stem0.dx, _stem0.dy)
      ..cubicTo(_stem1.dx, _stem1.dy, _stem2.dx, _stem2.dy, _stem3.dx, _stem3.dy),
    stem,
  );
  _paintLeaf(c, _stem3, -math.pi / 2 - 0.5, 46, width: 22, fill: leaf);
  _paintLeaf(c, _stem3, -math.pi / 2 + 0.45, 42, width: 20, fill: leaf);
  // Branch carrying the target leaf (HTML second stem path).
  final a = _stemAt(0.52);
  const p = _Geo.petiole;
  c.drawPath(
    Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(250, 196, p.dx, p.dy),
    stem..strokeWidth = 5,
  );
  if (stub) {
    c.drawCircle(p, 3.5, Paint()..color = const Color(0xFFBEF264));
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required Listenable repaint,
    required this.isDark,
    required this.showLabels,
    required this.lang,
    required this.tr,
  }) : super(repaint: repaint);

  final _PlantScene scene;
  final bool isDark;
  final bool showLabels;
  final LabLang lang;
  final String Function(String key) tr;

  double get t => scene.time;
  Color get _muted => isDark ? _Colors.slate400 : _Colors.slate500;

  @override
  void paint(Canvas canvas, Size size) {
    final s = scene;
    canvas.save();
    canvas.translate(_mid.dx, _mid.dy);
    canvas.scale(s.zoom);
    canvas.translate(-s.focus.dx, -s.focus.dy);
    if (s.scenario == 0) {
      switch (s.step) {
        case 1:
          _s1Planting(canvas, size);
        case 2:
          _s1Conditions(canvas, size);
        case 3:
          _s1Watering(canvas, size);
        default:
          _s1Growth(canvas, size);
      }
    } else {
      switch (s.step) {
        case 1:
          _s2Destarch(canvas, size);
        case 2:
          _s2Bottle(canvas, size);
        case 3:
          _s2Sunlight(canvas, size);
        case 4:
          _s2Station(canvas, size);
        default:
          _s2Result(canvas, size);
      }
    }
    canvas.restore();
  }

  // ------------------------------------------------------------ helpers

  /// HTML `.label-text`: plain bold scene label (hidden with the labels).
  void _tag(
    Canvas c,
    String text,
    Offset at, {
    Color? color,
    double size = 15,
    Alignment anchor = Alignment.center,
    double? maxWidth,
    double letterSpacing = 0,
  }) {
    if (!showLabels) return;
    labText(
      c,
      text,
      at,
      size: size,
      weight: FontWeight.w800,
      color: color ?? _muted,
      anchor: anchor,
      maxWidth: maxWidth,
      letterSpacing: letterSpacing,
    );
  }

  /// HTML rounded label chips (`rounded-full px-4 py-1`).
  void _chip(Canvas c, String text, Offset at, {required Color bg, required Color fg, double size = 17, Alignment anchor = Alignment.center}) {
    if (!showLabels) return;
    labText(
      c,
      text,
      at,
      size: size,
      weight: FontWeight.w900,
      color: fg,
      background: bg,
      anchor: anchor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      letterSpacing: 0.4,
    );
  }

  /// Lab wall with a bench whose top is at [benchY].
  void _room(Canvas c, Size size, double benchY) {
    final b = labBleed(size);
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, b.right, benchY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [Color(0xFF0B1222), Color(0xFF1E293B)] : const [_Colors.slate200, _Colors.slate50],
        ).createShader(Rect.fromLTRB(0, 0, 900, benchY)),
    );
    _bench(c, size, benchY);
  }

  /// The HTML bench (`border-b-8 border-slate-300`) as a slab.
  void _bench(Canvas c, Size size, double benchY) {
    final b = labBleed(size);
    c.drawRect(
      Rect.fromLTRB(b.left, benchY - 6, b.right, benchY + 10),
      Paint()..color = isDark ? _Colors.slate500 : _Colors.slate300,
    );
    c.drawRect(
      Rect.fromLTRB(b.left, benchY - 6, b.right, benchY - 4),
      Paint()..color = isDark ? _Colors.slate400 : Colors.white,
    );
    c.drawRect(
      Rect.fromLTRB(b.left, benchY + 10, b.right, b.bottom),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? const [_Colors.slate700, _Colors.slate900] : const [_Colors.slate400, _Colors.slate300],
        ).createShader(Rect.fromLTRB(0, benchY + 10, 900, benchY + 160)),
    );
  }

  /// HTML `.dropzone.dragover`: green tint with a dashed border.
  void _highlight(Canvas c, Rect r, {double radius = 14, bool circle = false}) {
    final pulse = 0.5 + 0.5 * math.sin(t * 6);
    final path = circle ? (Path()..addOval(r)) : (Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius))));
    c.drawPath(path, Paint()..color = _Colors.green500.withValues(alpha: 0.16 + 0.1 * pulse));
    labDashedPath(
      c,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _Colors.green500,
      dash: 12,
      gap: 8,
      phase: t * 30,
    );
  }

  // ------------------------------------------------- scenario 1 scenes

  /// Step 1: three empty pots on the bench, saplings in the tray.
  void _s1Planting(Canvas c, Size size) {
    final s = scene;
    _room(c, size, 243);
    final hover = s.drag == _Item.sapling ? s.hover : -1;
    for (var i = 0; i < 3; i++) {
      final box = _Geo.pot1(i);
      if (hover == i) _highlight(c, box.inflate(10));
      _paintPot(c, box, _letters[i]);
      final at = s.plantedAt[i];
      if (at >= 0) {
        final g = Curves.easeOutBack.transform(((t - at) / 0.5).clamp(0.0, 1.0));
        _paintSapling(c, _potSoil(box), 80 * g);
      }
      _tag(c, tr('pot_${_potKeys[i]}'), Offset(box.center.dx, 52));
    }
    final tray = RRect.fromRectAndRadius(_Geo.tray, const Radius.circular(12));
    c.drawRRect(
      tray.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    c.drawRRect(tray, Paint()..color = isDark ? const Color(0x24FFFFFF) : const Color(0x99FFFFFF));
    c.drawRRect(
      tray,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = isDark ? const Color(0x663B82F6) : _Colors.sky200,
    );
    for (var i = 0; i < 3; i++) {
      if (s.drag == _Item.sapling && s.dragIndex == i) continue;
      _traySapling(c, i);
    }
    if (s.drag == _Item.sapling) _traySapling(c, s.dragIndex);
  }

  void _traySapling(Canvas c, int i) {
    final s = scene;
    if (s.trayUsed[i]) return;
    final box = _Geo.traySapling(i).shift(s.offsetOf(_Item.sapling, i));
    _paintSapling(c, Offset(box.center.dx, box.top + 0.9 * box.height), 64);
    _tag(
      c,
      tr('sapling'),
      Offset(box.center.dx, box.top - 6),
      color: isDark ? _Colors.green400 : _Colors.green700,
      size: 12,
    );
  }

  /// Step 2: sunlit window (left) and dark closet (right) zones.
  void _s1Conditions(Canvas c, Size size) {
    final s = scene;
    final b = labBleed(size);
    // Sunlit window zone: blue-200 -> yellow-100.
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, 450, b.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.blue200, _Colors.yellow100],
        ).createShader(const Rect.fromLTRB(0, 0, 450, 600)),
    );
    _window(c);
    c.drawRect(Rect.fromLTRB(b.left, 476, 450, b.bottom), Paint()..color = const Color(0xFFE5D3AC));
    c.drawRect(Rect.fromLTRB(b.left, 476, 450, 480), Paint()..color = const Color(0xFFC9B07E));
    // Dark closet zone.
    c.drawRect(Rect.fromLTRB(450, b.top, b.right, b.bottom), Paint()..color = _Colors.slate900);
    _paintCloset(c, const Offset(515, 190), 3.2, shelf: 25, opacity: 0.6, knobs: false);
    c.drawRect(Rect.fromLTRB(450, 478, b.right, b.bottom), Paint()..color = const Color(0xFF0B1120));
    // HTML border-r-4 slate-300 between the zones.
    c.drawRect(Rect.fromLTRB(448, b.top, 452, b.bottom), Paint()..color = _Colors.slate300);
    final hover = s.drag == _Item.pot ? s.hover : -1;
    if (hover == 0) _highlight(c, const Rect.fromLTRB(8, 8, 442, 592));
    if (hover == 1) _highlight(c, const Rect.fromLTRB(458, 8, 892, 592));
    _chip(c, tr('sun_label'), const Offset(16, 16), bg: const Color(0xB3FFFFFF), fg: _Colors.yellow600, anchor: Alignment.topLeft);
    _chip(c, tr('dark_label'), const Offset(675, 16), bg: const Color(0x80000000), fg: _Colors.slate400, anchor: Alignment.topCenter);
    // Pots still waiting in the middle tray.
    if (s.zone.contains(0)) {
      final tray = RRect.fromRectAndRadius(_Geo.potTray, const Radius.circular(16));
      c.drawRRect(tray, Paint()..color = const Color(0x260F172A));
      labDashedPath(
        c,
        Path()..addRRect(tray),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.5),
      );
    }
    for (var i = 0; i < 3; i++) {
      if (s.drag == _Item.pot && s.dragIndex == i) continue;
      _conditionPot(c, i);
    }
    if (s.drag == _Item.pot) _conditionPot(c, s.dragIndex);
  }

  /// Window with the sun and light beams in the sunlit zone.
  void _window(Canvas c) {
    const frame = Rect.fromLTRB(30, 70, 420, 292);
    // Light beams falling from the window onto the floor.
    for (var i = 0; i < 3; i++) {
      final x0 = 80.0 + i * 110;
      final a = 0.16 + 0.06 * math.sin(t * 1.3 + i * 1.7);
      c.drawPath(
        Path()
          ..addPolygon([
            Offset(x0, 292),
            Offset(x0 + 80, 292),
            Offset(x0 + 20, 478),
            Offset(x0 - 70, 478),
          ], true),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Colors.yellow200.withValues(alpha: a + 0.1), _Colors.yellow200.withValues(alpha: 0)],
          ).createShader(Rect.fromLTRB(x0 - 70, 292, x0 + 80, 478)),
      );
    }
    final rr = RRect.fromRectAndRadius(frame, const Radius.circular(6));
    c.drawRRect(rr.shift(const Offset(0, 4)), Paint()..color = const Color(0x22000000));
    c.drawRRect(rr, Paint()..color = _Colors.slate50);
    final glass = frame.deflate(10);
    c.drawRect(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DD3FC), Color(0xFFE0F2FE)],
        ).createShader(glass),
    );
    c.save();
    c.clipRect(glass);
    _paintSun(c, const Offset(345, 128), 26, t * 0.25);
    c.restore();
    final bar = Paint()..color = _Colors.slate50;
    c.drawRect(Rect.fromCenter(center: glass.center, width: 8, height: glass.height), bar);
    c.drawRect(Rect.fromCenter(center: glass.center, width: glass.width, height: 8), bar);
    c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _Colors.slate300,
    );
    // Sill.
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(20, 288, 430, 300), const Radius.circular(3)),
      Paint()..color = const Color(0xFFD6B98C),
    );
  }

  void _conditionPot(Canvas c, int i) {
    final box = scene.potBox2(i);
    _paintPot(c, box, _letters[i]);
    _paintSapling(c, _potSoil(box), 64);
    if (scene.zone[i] == 2) {
      // Inside the dark closet.
      c.drawRect(box.inflate(40), Paint()..color = Colors.black.withValues(alpha: 0.12));
    }
    if (showLabels) {
      labText(
        c,
        tr('pot_${_potKeys[i]}'),
        Offset(box.center.dx, box.top - 62),
        size: 13,
        weight: FontWeight.w800,
        color: Colors.white,
        background: const Color(0x80000000),
        radius: 4,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      );
    }
  }

  /// Step 3: watering can and the three pots on the bench.
  void _s1Watering(Canvas c, Size size) {
    final s = scene;
    _room(c, size, 387);
    final hover = s.drag == _Item.can ? s.hover : -1;
    for (var i = 0; i < 3; i++) {
      final box = _Geo.pot3(i);
      if (hover == i) _highlight(c, box.inflate(10));
      final w = s.wateredAt[i];
      _paintPot(c, box, _letters[i], wet: w < 0 ? 0 : ((t - w - 0.15) / 0.6).clamp(0.0, 1.0));
      _paintSapling(c, _potSoil(box), 80);
      _tag(c, tr('pot_${_potKeys[i]}'), Offset(box.center.dx, box.top - 84));
      if (w >= 0) {
        final appear = ((t - w) / 0.3).clamp(0.0, 1.0);
        final bounce = (math.cos(math.pi * (t - w))).abs() * 10;
        _paintWaterDrop(c, Offset(box.right + 4, box.top - 10 - bounce), 40, opacity: appear);
      }
    }
    final ct = t - s.crossAt;
    if (ct >= 0 && ct < 1.5) {
      final box = _Geo.pot3(1);
      final o = ct < 1.2 ? 1.0 : (1.5 - ct) / 0.3;
      _paintCross(c, Offset(box.center.dx, box.top + 28), 32 * Curves.easeOutBack.transform((ct / 0.25).clamp(0.0, 1.0)), opacity: o);
    }
    // Watering can (tips over the pot while pouring, then goes back).
    final pour = t - s.pourAt;
    late Rect box;
    late double tilt;
    if (pour >= 0 && pour < 0.75) {
      final from = _Geo.can.shift(s.pourFrom);
      box = Rect.lerp(from, _Geo.can.shift(_Geo.pourOffset(s.pourPot)), _ease(pour / 0.15))!;
      tilt = 0.7 * _smooth(0.05, 0.2, pour) * (1 - _smooth(0.62, 0.75, pour));
      if (pour > 0.15 && pour < 0.68) {
        final rose = _canRose(box, tilt);
        final soil = _potSoil(_Geo.pot3(s.pourPot));
        for (var k = 0; k < 10; k++) {
          final ph = (pour * 2.4 + k / 10) % 1.0;
          final p = Offset(
            _lerp(rose.dx, soil.dx + (k % 3 - 1) * 9, ph),
            rose.dy + (soil.dy - 2 - rose.dy) * ph * ph,
          );
          c.drawCircle(p, 2.6, Paint()..color = _Colors.blue400.withValues(alpha: 0.9));
        }
      }
    } else {
      box = _Geo.can.shift(s.offsetOf(_Item.can, 0));
      tilt = hover == 0 || hover == 2 ? 0.25 : 0.0;
    }
    _paintCan(c, box, tilt);
    _tag(c, tr('water_can'), Offset(box.center.dx, box.top - 12), color: isDark ? _Colors.blue400 : _Colors.blue500, size: 14);
  }

  /// Steps 4-5: two-week time-lapse in the sun (left) and the dark (right).
  void _s1Growth(Canvas c, Size size) {
    final s = scene;
    final b = labBleed(size);
    c.drawRect(
      Rect.fromLTRB(b.left, b.top, 600, b.bottom),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.blue100, Colors.white],
        ).createShader(const Rect.fromLTRB(0, 0, 600, 600)),
    );
    c.drawRect(Rect.fromLTRB(600, b.top, b.right, b.bottom), Paint()..color = _Colors.slate800);
    _paintSun(c, const Offset(540, 84), 24, t * 0.25);
    _bench(c, size, 387);
    _chip(c, tr('sun_label'), const Offset(16, 16), bg: const Color(0xB3FFFFFF), fg: _Colors.yellow600, anchor: Alignment.topLeft, size: 14);
    _chip(c, tr('dark_label'), const Offset(722, 16), bg: const Color(0x80000000), fg: _Colors.slate400, anchor: Alignment.topCenter, size: 14);
    final v = s.step >= 5 ? 1.0 : s.growth;
    for (var i = 0; i < 3; i++) {
      final box = _Geo.pot4(i);
      if (s.step >= 5 && !s.inspected.contains(i)) {
        // Hint: the pots can be clicked.
        final pulse = 0.5 + 0.5 * math.sin(t * 4 + i);
        c.drawOval(
          Rect.fromCenter(center: Offset(box.center.dx, box.top + 116), width: 110 + 12 * pulse, height: 20 + 4 * pulse),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = _Colors.green500.withValues(alpha: 0.4 + 0.4 * pulse),
        );
      }
      _paintGrowth(c, box, i, v);
    }
    if (s.step == 4) _slider(c, v);
  }

  /// HTML time-lapse card: "Week 0 ... Week 2" and the range input.
  void _slider(Canvas c, double v) {
    final card = RRect.fromRectAndRadius(_Geo.slider, const Radius.circular(14));
    c.drawRRect(
      card.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    c.drawRRect(card, Paint()..color = const Color(0xD9FFFFFF));
    c.drawRRect(
      card,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.green500,
    );
    labText(c, tr('week_0'), const Offset(_Geo.trackL, 448), anchor: Alignment.centerLeft, size: 14, weight: FontWeight.w800, color: _Colors.slate700);
    labText(c, tr('week_2'), const Offset(_Geo.trackR, 448), anchor: Alignment.centerRight, size: 14, weight: FontWeight.w800, color: _Colors.slate700);
    labText(
      c,
      labFormat(tr('day_n'), {'n': (v * 14).round()}),
      const Offset(450, 448),
      size: 13,
      weight: FontWeight.w800,
      color: _Colors.green700,
    );
    const y = _Geo.trackY;
    final x = _lerp(_Geo.trackL, _Geo.trackR, v);
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(_Geo.trackL, y - 4, _Geo.trackR, y + 4), const Radius.circular(4)),
      Paint()..color = _Colors.slate200,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(_Geo.trackL, y - 4, x, y + 4), const Radius.circular(4)),
      Paint()..color = _Colors.green500,
    );
    if (v == 0) labGlow(c, Offset(x, y), 26 + 4 * math.sin(t * 5), _Colors.green400, intensity: 0.8);
    c.drawCircle(
      Offset(x, y + 2),
      11,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    c.drawCircle(Offset(x, y), 11, Paint()..color = Colors.white);
    c.drawCircle(
      Offset(x, y),
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = _Colors.green500,
    );
  }

  // ------------------------------------------------- scenario 2 scenes

  /// Draws the scenario 2 plant (step 2 frame) with its pot box at
  /// [topLeft], scaled by [scale].
  void _plantAt(Canvas c, Offset topLeft, double scale, Color leaf) {
    c.save();
    c.translate(topLeft.dx, topLeft.dy);
    c.scale(scale);
    c.translate(-_Geo.potS2.left, -_Geo.potS2.top);
    _paintS2Plant(c, leaf);
    _paintLeaf(c, _Geo.petiole, 0, _Geo.leafLen, fill: leaf);
    c.restore();
  }

  /// Step 1: drag the plant into the dark closet, then wait 2 days.
  void _s2Destarch(Canvas c, Size size) {
    final s = scene;
    _room(c, size, 440);
    if (s.drag == _Item.plant && s.hover == 0) _highlight(c, _Geo.closetZone);
    _paintCloset(c, _Geo.closetOrigin, 3.5, shelf: null);
    _tag(c, tr('dark_label'), const Offset(650, 62), size: 17, letterSpacing: 3);
    final tl = s.plantTopLeft();
    _plantAt(c, tl, _Geo.plantScale1, _Colors.green500);
    if (s.inCloset) {
      // In the shade of the closet.
      final a = 0.35 * _PlantScene.ease(t - s.closetAt, 0.45);
      c.drawRect(
        Rect.fromPoints(_Geo.closetOrigin + const Offset(35, 35), _Geo.closetOrigin + const Offset(315, 315)),
        Paint()..color = Colors.black.withValues(alpha: a),
      );
    }
    final r = _Geo.plantRect(tl);
    _tag(c, tr('healthy_plant'), Offset(r.center.dx, r.top - 10), size: 14);
    if (s.dayAt >= 0) {
      final since = t - s.dayAt;
      final a = (since / 0.3).clamp(0.0, 1.0);
      c.drawRect(labBleed(size), Paint()..color = Colors.black.withValues(alpha: 0.8 * a));
      final pulse = 0.75 + 0.25 * math.cos(since * math.pi);
      labText(c, tr('day_2'), _mid, size: 64, weight: FontWeight.w900, color: Colors.white, opacity: a * pulse, letterSpacing: 10);
    }
  }

  /// Step 2 (zoomed in): split cork onto the leaf, leaf into the NaOH bottle.
  void _s2Bottle(Canvas c, Size size) {
    final s = scene;
    _room(c, size, 468);
    c.drawLine(
      const Offset(594, 150),
      const Offset(594, 462),
      Paint()
        ..strokeWidth = 2
        ..color = isDark ? _Colors.slate600 : _Colors.slate300,
    );
    final e = s.sealE;
    final mouth = Offset.lerp(_Geo.mouthHome, _Geo.mouthSealed, e)!;
    _paintS2Plant(c, _Colors.lime400);
    if (s.drag == _Item.leaf && s.hover == 0) _highlight(c, _Geo.bottleHome.inflate(8));
    _paintBottleBack(c, mouth, 468);
    // Target leaf.
    final leafOff = s.drag == _Item.leaf
        ? s.dragOffset
        : (s.sealed ? s.sealFrom * (1 - e) : s.offsetOf(_Item.leaf, 0));
    final angle = _Geo.sealAngle * e;
    final base = _Geo.petiole + leafOff;
    if (s.drag == _Item.cork && s.hover == 0) _highlight(c, _Geo.corkTarget, radius: 20);
    _paintLeaf(c, base, angle, _Geo.leafLen, glow: s.sealed ? 0 : 0.6 + 0.4 * math.sin(t * 4));
    if (!s.sealed) {
      _tag(c, tr('target_leaf'), base + const Offset(48, -34), color: isDark ? _Colors.green400 : _Colors.green700, size: 13);
    }
    _paintBottleFront(c, mouth, label: '${tr('naoh')}\n${tr('absorbs_co2')}', labelOpacity: showLabels ? e : 0);
    if (s.corkOn) {
      final appear = ((t - s.corkAt) / 0.3).clamp(0.0, 1.0);
      final pos = Offset.lerp(base + const Offset(-4, 0), mouth + const Offset(0, -3), e)!;
      _paintCork(c, pos, _lerp(0.55, 1.05, e), opacity: appear);
    } else {
      final at = _Geo.corkHome + s.offsetOf(_Item.cork, 0);
      _paintCork(c, at, 0.9);
      _tag(c, tr('split_cork'), at + const Offset(0, -28), size: 12);
    }
  }

  /// Plant + sealed bottle + cork (steps 3), in the step 2 frame.
  void _paintSetup(Canvas c) {
    _paintS2Plant(c, _Colors.lime400);
    _paintBottleBack(c, _Geo.mouthSealed, 468);
    _paintLeaf(c, _Geo.petiole, _Geo.sealAngle, _Geo.leafLen);
    _paintBottleFront(c, _Geo.mouthSealed, label: '${tr('naoh')}\n${tr('absorbs_co2')}', labelOpacity: showLabels ? 1 : 0);
    _paintCork(c, _Geo.mouthSealed + const Offset(0, -3), 1.05);
  }

  /// Step 3: carry the setup into the sunlit zone and wait 6 hours.
  void _s2Sunlight(Canvas c, Size size) {
    final s = scene;
    _room(c, size, 468);
    final zone = Rect.fromCircle(center: _Geo.sunC, radius: _Geo.sunR);
    c.drawOval(
      zone,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_Colors.blue200, _Colors.yellow50],
        ).createShader(zone),
    );
    labDashedPath(
      c,
      Path()..addOval(zone),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _Colors.yellow300,
      dash: 14,
      gap: 9,
    );
    if (s.drag == _Item.setup && s.hover == 0) _highlight(c, zone, circle: true);
    final waiting = s.clockAt >= 0;
    final since = waiting ? t - s.clockAt : 0.0;
    final off = s.setupOffset();
    if (waiting) {
      // Sunlight pouring onto the leaves (HTML animate-sun-rays).
      final leaf = _Geo.petiole + off + const Offset(30, 40);
      for (var i = 0; i < 5; i++) {
        final a = (0.25 + 0.15 * math.sin(since * 6 + i)) * (since / 0.4).clamp(0.0, 1.0);
        final to = leaf + Offset(-60.0 + i * 30, 20.0 + (i % 2) * 20);
        c.drawLine(
          _Geo.sunSpot,
          to,
          Paint()
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..color = _Colors.yellow300.withValues(alpha: a),
        );
      }
    }
    _paintSun(c, _Geo.sunSpot, 26, t * 0.3 + since * 0.9, glow: waiting ? 1.2 + 0.2 * math.sin(since * 4) : 1);
    _chip(c, tr('sun_label'), const Offset(650, 142), bg: const Color(0xB3FFFFFF), fg: _Colors.yellow600, size: 16);
    c.save();
    c.translate(off.dx, off.dy);
    _paintSetup(c);
    c.restore();
    _tag(c, tr('setup'), Offset(_Geo.setupBounds.center.dx, _Geo.setupBounds.top - 10) + off, size: 15);
    if (waiting) {
      _paintClock(c, _mid, 96, since, (since / 0.25).clamp(0.0, 1.0));
    }
  }

  /// Step 4: the starch test station (boiling water, alcohol, tile, iodine).
  void _s2Station(Canvas c, Size size) {
    final s = scene;
    _room(c, size, 462);
    // Faded setup: the plant without the tested leaf.
    c.saveLayer(const Rect.fromLTRB(40, 60, 380, 480), Paint()..color = const Color(0x80000000));
    c.translate(-40, -6);
    _paintS2Plant(c, _Colors.lime400, stub: true);
    c.restore();
    if (s.drag == _Item.leaf2 && s.hover == 0) _highlight(c, _Geo.station);
    _tag(c, tr('station'), const Offset(610, 152), size: 19);
    final tau = s.testAt >= 0 ? t - s.testAt : -1.0;
    _paintBeaker(c, _Geo.beaker(0), _Colors.blue500, tr('hot_water'), t, boiling: true);
    _paintBeaker(c, _Geo.beaker(1), _Colors.emerald500, tr('alcohol'), t);
    _tag(c, tr('boil_label'), Offset(_Geo.beakerX[0], 334), size: 12, maxWidth: 150, anchor: Alignment.bottomCenter);
    _tag(c, tr('alc_label'), Offset(_Geo.beakerX[1], 334), size: 12, maxWidth: 150, anchor: Alignment.bottomCenter);
    _paintTile(c, _Geo.tile());
    _tag(c, tr('tile_label'), const Offset(770, 392), size: 12, anchor: Alignment.bottomCenter);
    // The leaf.
    late Offset ctr;
    late double rot;
    late double scale;
    if (tau < 0) {
      ctr = _Geo.leaf2Home + s.offsetOf(_Item.leaf2, 0);
      rot = _Geo.leaf2Rot;
      scale = 1;
    } else {
      (ctr, rot, scale) = _leafPose(tau, s.testFrom);
    }
    final pale = _smooth(2, 4, tau);
    final stain = _smooth(6, 7, tau);
    final fill = Color.lerp(_Colors.lime400, _Colors.slate100, pale)!;
    final stroke = Color.lerp(_Colors.green800, _Colors.slate400, pale)!;
    final len = _Geo.leafLen * scale;
    final base = ctr - Offset(math.cos(rot), math.sin(rot)) * (len / 2);
    _paintLeaf(
      c,
      base,
      rot,
      len,
      fill: Color.lerp(fill, _Colors.indigo950, stain)!,
      stroke: Color.lerp(stroke, _Colors.slate900, stain)!,
      tipFill: stain > 0 ? Color.lerp(fill, _Colors.amber600, stain) : null,
      tipStroke: stain > 0 ? Color.lerp(stroke, _Colors.amber800, stain) : null,
      glow: tau < 0 ? 0.4 + 0.3 * math.sin(t * 4) : 0,
    );
    // Submerged in a beaker: tint the leaf with the liquid.
    for (var i = 0; i < 2; i++) {
      final r = _Geo.beaker(i).deflate(3);
      final liquid = Rect.fromLTRB(r.left, r.bottom - r.height * 0.55, r.right, r.bottom);
      if (liquid.contains(ctr)) {
        c.drawRect(liquid, Paint()..color = (i == 0 ? _Colors.blue500 : _Colors.emerald500).withValues(alpha: 0.35));
      }
    }
    if (tau < 0) {
      _tag(c, tr('target_leaf'), ctr + const Offset(0, -36), color: isDark ? _Colors.green400 : _Colors.green700, size: 13);
    }
    // Iodine dropper.
    if (tau >= 5) {
      final d = _ease((tau - 5) / 0.5);
      final tip = Offset(_Geo.tileC.dx + 4, _lerp(330, 396, d));
      _paintDropper(c, tip, d);
      if (tau >= 5.5 && tau < 6.0) {
        final f = (tau - 5.5) / 0.5;
        c.drawCircle(Offset(tip.dx, _lerp(400, 426, f * f)), 4, Paint()..color = _Colors.amber700);
      }
      if (tau >= 6) {
        final r = 6 + 22 * _smooth(6, 6.6, tau);
        c.drawCircle(
          Offset(tip.dx, 428),
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = _Colors.amber700.withValues(alpha: (1 - _smooth(6, 6.8, tau)) * 0.8),
        );
      }
    }
  }

  /// Leaf path of the automated starch test (HTML `triggerS2StarchTestSequence`).
  (Offset, double, double) _leafPose(double tau, Offset from) {
    const deg = math.pi / 180;
    final b1 = Offset(_Geo.beakerX[0], 428), b2 = Offset(_Geo.beakerX[1], 428);
    final tile = _Geo.tileC + const Offset(0, -2);
    Offset hop(Offset a, Offset b, double u, double top) {
      if (u < 0.3) return Offset(a.dx, _lerp(a.dy, top, _ease(u / 0.3)));
      if (u < 0.7) return Offset(_lerp(a.dx, b.dx, _ease((u - 0.3) / 0.4)), top);
      return Offset(b.dx, _lerp(top, b.dy, _ease((u - 0.7) / 0.3)));
    }

    if (tau < 1) {
      final u = tau.clamp(0.0, 1.0);
      return (hop(from, b1, u, math.min(from.dy, 320)), _lerp(_Geo.leaf2Rot, -10 * deg, _ease(u)), _lerp(1, 0.6, _ease(u)));
    }
    if (tau < 2) return (b1 + Offset(0, 2 * math.sin(tau * 9)), -10 * deg, 0.6);
    if (tau < 3) return (hop(b1, b2, tau - 2, 320), _lerp(-10 * deg, 10 * deg, _ease(tau - 2)), 0.6);
    if (tau < 4) return (b2 + Offset(0, 2 * math.sin(tau * 5)), 10 * deg, 0.6);
    if (tau < 5) return (hop(b2, tile, tau - 4, 320), _lerp(10 * deg, 0, _ease(tau - 4)), _lerp(0.6, 1, _ease(tau - 4)));
    return (tile, 0, 1);
  }

  /// Step 5: the two-toned leaf after the iodine test.
  void _s2Result(Canvas c, Size size) {
    _room(c, size, 462);
    _paintTile(c, Rect.fromCenter(center: const Offset(450, 340), width: 440, height: 190));
    const base = Offset(322, 330);
    labGroundShadow(c, const Offset(450, 372), 260, 26, opacity: 0.25);
    _paintLeaf(
      c,
      base,
      0,
      256,
      width: 128,
      fill: _Colors.indigo950,
      stroke: _Colors.slate900,
      tipFill: _Colors.amber600,
      tipStroke: _Colors.amber800,
    );
    if (!showLabels) return;
    final blue = isDark ? _Colors.indigo200 : _Colors.slate800;
    final amber = isDark ? _Colors.amber400 : _Colors.amber700;
    final sub = isDark ? _Colors.slate400 : _Colors.slate500;
    final small = isDark ? _Colors.slate300 : _Colors.slate700;
    void block(double x, String head, String where, String note, Color color) {
      labText(c, head, Offset(x, 172), size: 22, weight: FontWeight.w900, color: color, maxWidth: 260);
      labText(c, where.toUpperCase(), Offset(x, 198), size: 12, weight: FontWeight.w800, color: sub, letterSpacing: 1, maxWidth: 260);
      labText(c, note, Offset(x, 218), size: 12, weight: FontWeight.w700, color: small, maxWidth: 240);
    }

    block(300, tr('blue_black'), tr('outside'), tr('starch_present'), blue);
    block(600, tr('yellow_brown'), tr('inside'), tr('starch_absent'), amber);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = sub;
    labDashedLine(c, const Offset(320, 234), const Offset(384, 304), line, dash: 6, gap: 5);
    labDashedLine(c, const Offset(580, 234), const Offset(516, 304), line, dash: 6, gap: 5);
    c.drawCircle(const Offset(384, 306), 4, Paint()..color = sub);
    c.drawCircle(const Offset(516, 306), 4, Paint()..color = sub);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang;
}

/// Final plant of one pot, for its observation card.
class _ThumbPainter extends CustomPainter {
  _ThumbPainter({required this.pot, required this.isDark});

  final int pot;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Virtual 220 x 300 box: pot at the bottom, the grown plant above it.
    final k = math.min(size.width / 220, size.height / 300);
    canvas.save();
    canvas.translate((size.width - 220 * k) / 2, (size.height - 300 * k) / 2);
    canvas.scale(k);
    _paintGrowth(canvas, const Rect.fromLTWH(46, 178, 128, 128), pot, 1);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThumbPainter old) => old.pot != pot || old.isDark != isDark;
}

/// Paints the confetti burst over the canvas (HTML `confetti()`).
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.confetti, required Listenable repaint}) : super(repaint: repaint);

  final _Confetti confetti;

  @override
  void paint(Canvas canvas, Size size) {
    if (confetti.bits.isEmpty) return;
    // canvas-confetti works in window pixels; scale its 800 px world to fit.
    final k = math.max(0.55, size.height / 800);
    final origin = Offset(size.width * 0.5, size.height * 0.62);
    for (final b in confetti.bits) {
      final alpha = (1 - b.tick / _Confetti.ticks).clamp(0.0, 1.0);
      final paint = Paint()..color = b.color.withValues(alpha: alpha);
      final tc = math.cos(b.tilt) * b.random, ts = math.sin(b.tilt) * b.random;
      final wx = b.x + 10 * math.cos(b.wobble), wy = b.y + 10 * math.sin(b.wobble);
      Offset at(double x, double y) => origin + Offset(x, y) * k;
      if (b.circle) {
        canvas.save();
        final c0 = at(b.x, b.y);
        canvas.translate(c0.dx, c0.dy);
        canvas.rotate(math.pi / 10 * b.wobble);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: math.max(2, ((wx + tc) - (b.x + tc)).abs() * 0.6 * 2 * k),
            height: math.max(2, ((wy + ts) - (b.y + ts)).abs() * 0.6 * 2 * k),
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawPath(
          Path()
            ..addPolygon([
              at(b.x, b.y),
              at(wx, b.y + ts),
              at(wx + tc, wy + ts),
              at(b.x + tc, wy),
            ], true),
          paint,
        );
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
