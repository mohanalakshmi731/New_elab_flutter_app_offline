// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Class 7 Science • Chapter 9 • Activity 4
/// Gas Exchange and Cellular Respiration.
///
/// Native Flutter lab designed from the textbook (the HTML
/// `Cl7S-Ch09-A3-Gas_Exchange_and_Cellular_Respiration.html` only embedded an
/// external 3D viewer).
/// Learners zoom into an alveolus and drag O₂ into the blood and CO₂ out,
/// trace one blood cell through the heart, body cells and lungs, then watch a
/// body cell release energy from glucose and test exhaled air with lime water.
class Ch9A4GasExchangeAndCellularRespirationPage extends StatefulWidget {
  const Ch9A4GasExchangeAndCellularRespirationPage({super.key});

  @override
  State<Ch9A4GasExchangeAndCellularRespirationPage> createState() =>
      _Ch9A4GasExchangeAndCellularRespirationPageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: Mixkit tones (mixkit.co, free licence)
/// bundled in `assets/audio/class7/`.
///
/// Mixkit IDs: click 2568, toggle 166, correct 2870, wrong 946, success 270,
/// scenario 1107, curtain 2633, pop 2357, whoosh 1492, bubble 732, drop 2364,
/// pickup 2356, magic 871, spark 2365.
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

  /// Comparison chart appears.
  pop('pop.mp3'),

  /// Breathing in / out, blood pumped along a vessel, scene change.
  whoosh('whoosh.mp3'),

  /// Air bubbling through lime water.
  bubble('bubble.mp3'),

  /// A molecule dropped in the right place.
  drop('drop.mp3'),

  /// A molecule or the blood cell picked up.
  pickup('pickup.mp3'),

  /// Zooming into the alveolus.
  magic('magic.mp3'),

  /// Energy released in the cell.
  spark('spark.mp3');

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

/// Brand, Tailwind and biology colours used by this lab.
abstract final class _Colors {
  static const Color zslYellow = Color(0xFFEAB308); // zsl.yellow
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Scene colours.
  static const Color oxygen = Color(0xFF38BDF8); // sky-400: O₂
  static const Color carbon = Color(0xFF475569); // slate-600: C of CO₂
  static const Color carbonO = Color(0xFF94A3B8); // slate-400: O of CO₂
  static const Color rich = Color(0xFFEF4444); // oxygen-rich blood
  static const Color poor = Color(0xFF3B82F6); // oxygen-poor blood
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);
  static const Color rose800 = Color(0xFF9F1239);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);
  static const Color yellow = Color(0xFFFACC15);
  static const Color orange = Color(0xFFFB923C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color water = Color(0xFF60A5FA);
}

/// This lab's light and dark palettes (standard ZSL lab look): sidebar,
/// canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate900,
    panel: Color(0xF20F172A),
    border: Color(0x26FFFFFF),
    card: Color(0x991E293B),
    cardBorder: Color(0x80334155),
    canvasBg: _Colors.slate900,
    text: _Colors.slate200,
    textStrong: Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate800,
    toastBg: _Colors.slate100,
    toastText: _Colors.slate900,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
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
    bg: _Colors.slate200,
    panel: Color(0xF2FFFFFF),
    border: Color(0x26000000),
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate800,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.zslYellow,
    onAccent: _Colors.slate900,
    primary: _Colors.indigo600,
    onPrimary: Colors.white,
    success: _Colors.green,
    danger: _Colors.red,
    onDanger: Colors.white,
    info: _Colors.blue,
    popupBg: Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: Colors.white,
    toastBg: _Colors.slate900,
    toastText: Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x333B82F6),
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
    'app_title': 'Gas Exchange and Cellular Respiration',
    'app_subtitle': 'Class 7 • Life Processes in Animals',
    'scen_1_opt': 'Scenario 1: Gas Exchange in the Alveoli',
    'scen_2_opt': 'Scenario 2: Blood Flow Through the Heart',
    'scen_3_opt': 'Scenario 3: Respiration in a Cell and the Lime Water Test',
    // Buttons.
    'btn_breathe_in': 'Breathe In',
    'btn_breathe_out': 'Breathe Out',
    'btn_start_heart': 'Start Heartbeat',
    'btn_release_energy': 'Release Energy',
    'btn_push': 'Push Pichkari (A)',
    'btn_blow': 'Blow into Straw (B)',
    'btn_compare': 'Compare Air',
    'btn_continue': 'Continue',
    // Popups.
    'obs_title': 'Observation',
    'conclusion_title': 'Scientific Conclusion',
    'conclusion_heading': 'What we learnt',
    'objective_complete': 'Scenario complete! Choose another scenario or restart the lab.',
    'conclusion_1':
        'The alveoli have very thin walls surrounded by fine blood vessels. Oxygen from the air in the alveoli passes into the blood, which carries it to all parts of the body. At the same time, carbon dioxide brought by the blood passes into the alveoli and is breathed out. This exchange of gases takes place in the alveoli of the lungs.',
    'conclusion_2':
        'The heart pumps blood through blood vessels to all parts of the body. Oxygen-rich blood from the lungs enters the heart, which pumps it to the body cells. The cells use the oxygen and give carbon dioxide to the blood. This oxygen-poor blood returns to the heart, which pumps it to the lungs, where carbon dioxide leaves and oxygen enters. The heart, blood and blood vessels form the circulatory system.',
    'conclusion_3':
        'Respiration takes place inside the cells of the body. Oxygen breaks down glucose into carbon dioxide and water, and energy is released. This energy helps us walk, run, play and even think. The blood carries the carbon dioxide to the lungs, where it is breathed out, which is why exhaled air turns lime water milky. Breathing is a physical process, while respiration is a chemical process.',
    // Scenario 1 scene.
    'lbl_windpipe': 'Windpipe',
    'lbl_right_lung': 'Right lung',
    'lbl_left_lung': 'Left lung',
    'lbl_alveoli': 'Alveoli',
    'lbl_tap_zoom': 'Tap to zoom in',
    'lbl_alveolus': 'Alveolus (air sac)',
    'lbl_thin_wall': 'Thin wall',
    'lbl_blood_vessel': 'Blood vessel',
    'lbl_from_body': 'From the body',
    'lbl_to_heart': 'To the heart',
    'lbl_rbc': 'Red blood cells',
    'lbl_air_in': 'Fresh air in',
    'lbl_air_out': 'Used air out',
    'lbl_o2': 'O_2',
    'lbl_co2': 'CO_2',
    // Scenario 2 scene.
    'lbl_lungs': 'Lungs',
    'lbl_heart': 'Heart',
    'lbl_right_side': 'Right side',
    'lbl_left_side': 'Left side',
    'lbl_body_cells': 'Body cells',
    'lbl_rich': 'Oxygen-rich blood',
    'lbl_poor': 'Oxygen-poor blood',
    'lbl_blood_cell': 'Blood cell',
    // Scenario 3 scene.
    'lbl_cell': 'Body cell',
    'lbl_nucleus': 'Nucleus',
    'lbl_cytoplasm': 'Cytoplasm',
    'lbl_glucose': 'Glucose',
    'lbl_oxygen': 'Oxygen',
    'lbl_carbon_dioxide': 'Carbon dioxide',
    'lbl_water': 'Water',
    'lbl_energy': 'Energy',
    'lbl_lime_water': 'Lime water',
    'lbl_pichkari': 'Pichkari (syringe)',
    'lbl_straw': 'Straw',
    'lbl_tube_a': 'Test tube A',
    'lbl_tube_b': 'Test tube B',
    'lbl_air_around': 'Air around us',
    'lbl_air_breathed_out': 'Air breathed out',
    'lbl_clear': 'Stays clear',
    'lbl_cloudy': 'Turning cloudy…',
    'lbl_milky': 'Turns milky',
    'lbl_tap_push': 'Tap to push',
    'lbl_tap_blow': 'Tap to blow',
    // Cards.
    'card_gas': 'Gas Levels',
    'card_air': 'Air in the alveolus',
    'card_blood': 'Blood',
    'card_path': 'Blood Path',
    'path_1': 'Lungs → Heart (left side)',
    'path_2': 'Heart → Body cells',
    'path_3': 'Body cells → Heart (right side)',
    'path_4': 'Heart → Lungs',
    'card_cell_now': 'Blood cell now',
    'state_rich': 'Oxygen-rich',
    'state_poor': 'Oxygen-poor',
    'card_heartbeat': 'Heartbeat',
    'state_on': 'Beating',
    'state_off': 'Stopped',
    'card_results': 'Results',
    'card_equation': 'Respiration in the cell',
    'eq_title': 'Word equation of respiration',
    'card_energy': 'Energy released',
    'card_lime_test': 'Lime water test',
    'pending': 'Not tested yet',
    'blows_fmt': 'Blows: {n}/3',
    'cmp_title': 'Inhaled vs Exhaled Air',
    'cmp_inhaled': 'Inhaled air',
    'cmp_exhaled': 'Exhaled air',
    'cmp_nearly': 'nearly',
    // Toasts: scenario 1.
    't_zoomed': 'You are now inside the lungs, looking at one alveolus.',
    'e_tap_alveoli': 'Tap the glowing alveoli at the end of a branch.',
    't_breathed_in': 'Fresh air rich in oxygen has filled the alveolus.',
    'e_breathe_first': 'First breathe in to fill the alveolus with fresh air.',
    'e_no_air_yet': 'There is no fresh air to breathe out yet. Breathe in first.',
    'e_o2_first': 'Move the oxygen first. The carbon dioxide comes next.',
    'e_drop_blood': 'Drop the oxygen inside the blood vessel, just below the thin wall.',
    't_o2_moved': 'Oxygen passed into the blood! ({n}/3)',
    'e_drop_alveolus': 'Drop the carbon dioxide inside the alveolus.',
    't_co2_moved': 'Carbon dioxide passed into the alveolus! ({n}/3)',
    'e_o2_stays': 'This oxygen is now in the blood. The blood will carry it to all parts of the body.',
    'e_enough_o2': 'Enough oxygen has moved. Now move the carbon dioxide out of the blood.',
    'e_co2_done': 'This carbon dioxide is already in the alveolus. It will be breathed out.',
    'e_breathe_out_now': "Tap 'Breathe Out' to send the used air out.",
    'e_full_already': 'The alveolus is already full of air. Move the gases across the wall first.',
    't_breathed_out': 'The used air, with its carbon dioxide, is breathed out.',
    'hint_drag': 'Drag it across, do not just tap it.',
    // Toasts: scenario 2.
    't_heart_started': 'The heart is pumping! Watch the blood flow through the blood vessels.',
    'e_start_heart': "Tap 'Start Heartbeat' first.",
    'e_drop_part': 'Drop the blood cell on the lungs, the heart or the body cells.',
    'e_already_here': 'The blood cell is already here. Where does the blood go next?',
    't_reached_left': 'Oxygen-rich blood has entered the left side of the heart.',
    'e_rich_to_right':
        'This side receives oxygen-poor blood from the body. Blood from the lungs enters the LEFT side (on your right).',
    'e_lungs_to_heart_first': 'Blood from the lungs goes to the heart first. The heart then pumps it to the body.',
    't_reached_body': 'The body cells took oxygen and gave carbon dioxide. The blood is now oxygen-poor.',
    'e_rich_not_lungs': 'This blood is rich in oxygen. The heart pumps it to the body cells, not back to the lungs.',
    'e_sides_separate': 'The two sides of the heart are separate. The heart pumps this blood out through a blood vessel.',
    't_reached_right': 'Oxygen-poor blood has returned to the right side of the heart.',
    'e_poor_to_left':
        'The left side carries only oxygen-rich blood. Oxygen-poor blood returns to the RIGHT side (on your left).',
    'e_body_to_heart_first': 'Blood from the body returns to the heart first. The heart then pumps it to the lungs.',
    'e_poor_to_lungs': 'Oxygen-poor blood must go to the lungs to pick up oxygen.',
    't_reached_lungs': 'In the lungs the blood gave out carbon dioxide and took in oxygen. It is oxygen-rich again!',
    'hint_drag_cell': 'Drag the blood cell to where the blood goes next.',
    // Toasts: scenario 3.
    't_glucose_in': 'Glucose (food) is inside the cell.',
    't_o2_in': 'Oxygen is inside the cell.',
    'e_drop_cell': 'Drop it inside the body cell.',
    'e_inside_already': 'This is already inside the cell.',
    'e_tap_release': "Tap 'Release Energy' to start respiration.",
    'e_water_stays': 'Water stays in the body and is used by it. Move the carbon dioxide out.',
    'i_energy_used': 'The cell uses this energy. It helps us walk, run, play and even think!',
    'e_drop_blood_co2': 'Drop the carbon dioxide into the blood vessel.',
    't_co2_out': 'The blood will carry the carbon dioxide to the lungs.',
    't_to_bench': 'Now let us test the air we breathe out with lime water.',
    'e_test_a_first': 'First test the air around us: push the pichkari over test tube A.',
    't_a_clear': 'Bubbles passed through, but the lime water in test tube A stays clear.',
    'e_a_done': 'Test tube A is done. Now blow into test tube B through the straw.',
    't_blow': 'You blew air into test tube B ({n}/3).',
    't_b_milky': 'The lime water in test tube B has turned milky!',
    'e_wait_bubbles': 'Wait for the bubbles to stop.',
    'e_compare_now': "Tap 'Compare Air' to compare the two kinds of air.",
  },
  'hi': {
    'app_title': 'गैसों का विनिमय और कोशिकीय श्वसन',
    'app_subtitle': 'कक्षा 7 • जंतुओं में जैव प्रक्रम',
    'scen_1_opt': 'परिदृश्य 1: वायुकोषों में गैसों का विनिमय',
    'scen_2_opt': 'परिदृश्य 2: हृदय से होकर रक्त का प्रवाह',
    'scen_3_opt': 'परिदृश्य 3: कोशिका में श्वसन और चूने के पानी का परीक्षण',
    'btn_breathe_in': 'साँस अंदर लें',
    'btn_breathe_out': 'साँस बाहर छोड़ें',
    'btn_start_heart': 'दिल की धड़कन शुरू करें',
    'btn_release_energy': 'ऊर्जा मुक्त करें',
    'btn_push': 'पिचकारी दबाएँ (A)',
    'btn_blow': 'स्ट्रॉ में फूँकें (B)',
    'btn_compare': 'वायु की तुलना करें',
    'btn_continue': 'जारी रखें',
    'obs_title': 'अवलोकन',
    'conclusion_title': 'वैज्ञानिक निष्कर्ष',
    'conclusion_heading': 'हमने क्या सीखा',
    'objective_complete': 'परिदृश्य पूरा हुआ! कोई दूसरा परिदृश्य चुनें या लैब फिर से शुरू करें।',
    'conclusion_1':
        'वायुकोषों की भित्तियाँ बहुत पतली होती हैं और ये महीन रक्त वाहिकाओं से घिरे होते हैं। वायुकोषों की वायु से ऑक्सीजन रक्त में चली जाती है, जो उसे शरीर के सभी भागों तक ले जाता है। उसी समय, रक्त द्वारा लाई गई कार्बन डाइऑक्साइड वायुकोषों में आ जाती है और साँस के साथ बाहर निकल जाती है। गैसों का यह विनिमय फेफड़ों के वायुकोषों में होता है।',
    'conclusion_2':
        'हृदय रक्त वाहिकाओं द्वारा शरीर के सभी भागों में रक्त पंप करता है। फेफड़ों से ऑक्सीजन से भरपूर रक्त हृदय में आता है, जो उसे शरीर की कोशिकाओं तक पंप करता है। कोशिकाएँ ऑक्सीजन का उपयोग करती हैं और रक्त को कार्बन डाइऑक्साइड देती हैं। यह कम ऑक्सीजन वाला रक्त हृदय में लौटता है, जो उसे फेफड़ों तक पंप करता है, जहाँ कार्बन डाइऑक्साइड बाहर निकलती है और ऑक्सीजन रक्त में आती है। हृदय, रक्त और रक्त वाहिकाएँ मिलकर परिसंचरण तंत्र बनाते हैं।',
    'conclusion_3':
        'श्वसन शरीर की कोशिकाओं के अंदर होता है। ऑक्सीजन ग्लूकोज़ को कार्बन डाइऑक्साइड और जल में तोड़ देती है और ऊर्जा मुक्त होती है। यह ऊर्जा हमें चलने, दौड़ने, खेलने और सोचने में भी मदद करती है। रक्त कार्बन डाइऑक्साइड को फेफड़ों तक ले जाता है, जहाँ से वह साँस के साथ बाहर निकल जाती है, इसीलिए बाहर छोड़ी गई वायु चूने के पानी को दूधिया कर देती है। साँस लेना एक भौतिक प्रक्रिया है, जबकि श्वसन एक रासायनिक प्रक्रिया है।',
    'lbl_windpipe': 'श्वासनली',
    'lbl_right_lung': 'दायाँ फेफड़ा',
    'lbl_left_lung': 'बायाँ फेफड़ा',
    'lbl_alveoli': 'वायुकोष',
    'lbl_tap_zoom': 'ज़ूम करने के लिए टैप करें',
    'lbl_alveolus': 'वायुकोष (एल्वियोलस)',
    'lbl_thin_wall': 'पतली भित्ति',
    'lbl_blood_vessel': 'रक्त वाहिका',
    'lbl_from_body': 'शरीर से',
    'lbl_to_heart': 'हृदय की ओर',
    'lbl_rbc': 'लाल रक्त कोशिकाएँ',
    'lbl_air_in': 'ताज़ी वायु अंदर',
    'lbl_air_out': 'उपयोग की गई वायु बाहर',
    'lbl_o2': 'O_2',
    'lbl_co2': 'CO_2',
    'lbl_lungs': 'फेफड़े',
    'lbl_heart': 'हृदय',
    'lbl_right_side': 'दायाँ भाग',
    'lbl_left_side': 'बायाँ भाग',
    'lbl_body_cells': 'शरीर की कोशिकाएँ',
    'lbl_rich': 'ऑक्सीजन से भरपूर रक्त',
    'lbl_poor': 'कम ऑक्सीजन वाला रक्त',
    'lbl_blood_cell': 'रक्त कोशिका',
    'lbl_cell': 'शरीर की कोशिका',
    'lbl_nucleus': 'केंद्रक',
    'lbl_cytoplasm': 'कोशिकाद्रव्य',
    'lbl_glucose': 'ग्लूकोज़',
    'lbl_oxygen': 'ऑक्सीजन',
    'lbl_carbon_dioxide': 'कार्बन डाइऑक्साइड',
    'lbl_water': 'जल',
    'lbl_energy': 'ऊर्जा',
    'lbl_lime_water': 'चूने का पानी',
    'lbl_pichkari': 'पिचकारी (सिरिंज)',
    'lbl_straw': 'स्ट्रॉ',
    'lbl_tube_a': 'परखनली A',
    'lbl_tube_b': 'परखनली B',
    'lbl_air_around': 'आसपास की वायु',
    'lbl_air_breathed_out': 'बाहर छोड़ी गई वायु',
    'lbl_clear': 'साफ़ रहता है',
    'lbl_cloudy': 'धुंधला हो रहा है…',
    'lbl_milky': 'दूधिया हो जाता है',
    'lbl_tap_push': 'दबाने के लिए टैप करें',
    'lbl_tap_blow': 'फूँकने के लिए टैप करें',
    'card_gas': 'गैसों का स्तर',
    'card_air': 'वायुकोष की वायु',
    'card_blood': 'रक्त',
    'card_path': 'रक्त का मार्ग',
    'path_1': 'फेफड़े → हृदय (बायाँ भाग)',
    'path_2': 'हृदय → शरीर की कोशिकाएँ',
    'path_3': 'शरीर की कोशिकाएँ → हृदय (दायाँ भाग)',
    'path_4': 'हृदय → फेफड़े',
    'card_cell_now': 'अभी रक्त कोशिका',
    'state_rich': 'ऑक्सीजन से भरपूर',
    'state_poor': 'कम ऑक्सीजन',
    'card_heartbeat': 'दिल की धड़कन',
    'state_on': 'धड़क रहा है',
    'state_off': 'रुका हुआ',
    'card_results': 'परिणाम',
    'card_equation': 'कोशिका में श्वसन',
    'eq_title': 'श्वसन का शब्द समीकरण',
    'card_energy': 'मुक्त ऊर्जा',
    'card_lime_test': 'चूने के पानी का परीक्षण',
    'pending': 'अभी परीक्षण नहीं हुआ',
    'blows_fmt': 'फूँक: {n}/3',
    'cmp_title': 'अंदर ली गई बनाम बाहर छोड़ी गई वायु',
    'cmp_inhaled': 'अंदर ली गई वायु',
    'cmp_exhaled': 'बाहर छोड़ी गई वायु',
    'cmp_nearly': 'लगभग',
    't_zoomed': 'अब आप फेफड़ों के अंदर एक वायुकोष को देख रहे हैं।',
    'e_tap_alveoli': 'शाखा के सिरे पर चमकते वायुकोषों पर टैप करें।',
    't_breathed_in': 'ऑक्सीजन से भरपूर ताज़ी वायु वायुकोष में भर गई है।',
    'e_breathe_first': 'पहले साँस अंदर लेकर वायुकोष को ताज़ी वायु से भरें।',
    'e_no_air_yet': 'अभी बाहर छोड़ने के लिए ताज़ी वायु नहीं है। पहले साँस अंदर लें।',
    'e_o2_first': 'पहले ऑक्सीजन को ले जाएँ। कार्बन डाइऑक्साइड की बारी उसके बाद आएगी।',
    'e_drop_blood': 'ऑक्सीजन को पतली भित्ति के ठीक नीचे रक्त वाहिका के अंदर छोड़ें।',
    't_o2_moved': 'ऑक्सीजन रक्त में चली गई! ({n}/3)',
    'e_drop_alveolus': 'कार्बन डाइऑक्साइड को वायुकोष के अंदर छोड़ें।',
    't_co2_moved': 'कार्बन डाइऑक्साइड वायुकोष में चली गई! ({n}/3)',
    'e_o2_stays': 'यह ऑक्सीजन अब रक्त में है। रक्त इसे शरीर के सभी भागों तक ले जाएगा।',
    'e_enough_o2': 'पर्याप्त ऑक्सीजन जा चुकी है। अब कार्बन डाइऑक्साइड को रक्त से बाहर ले जाएँ।',
    'e_co2_done': 'यह कार्बन डाइऑक्साइड पहले से वायुकोष में है। इसे साँस के साथ बाहर छोड़ा जाएगा।',
    'e_breathe_out_now': "उपयोग की गई वायु बाहर भेजने के लिए 'साँस बाहर छोड़ें' पर टैप करें।",
    'e_full_already': 'वायुकोष पहले से वायु से भरा है। पहले गैसों को भित्ति के पार ले जाएँ।',
    't_breathed_out': 'कार्बन डाइऑक्साइड वाली उपयोग की गई वायु बाहर छोड़ दी गई।',
    'hint_drag': 'इसे केवल टैप न करें, खींचकर ले जाएँ।',
    't_heart_started': 'हृदय पंप कर रहा है! रक्त वाहिकाओं में बहते रक्त को देखें।',
    'e_start_heart': "पहले 'दिल की धड़कन शुरू करें' पर टैप करें।",
    'e_drop_part': 'रक्त कोशिका को फेफड़ों, हृदय या शरीर की कोशिकाओं पर छोड़ें।',
    'e_already_here': 'रक्त कोशिका पहले से यहीं है। रक्त आगे कहाँ जाता है?',
    't_reached_left': 'ऑक्सीजन से भरपूर रक्त हृदय के बाएँ भाग में पहुँच गया है।',
    'e_rich_to_right':
        'यह भाग शरीर से कम ऑक्सीजन वाला रक्त प्राप्त करता है। फेफड़ों से आया रक्त बाएँ भाग (आपकी दाईं ओर) में जाता है।',
    'e_lungs_to_heart_first': 'फेफड़ों से रक्त पहले हृदय में जाता है। फिर हृदय उसे शरीर में पंप करता है।',
    't_reached_body': 'शरीर की कोशिकाओं ने ऑक्सीजन ली और कार्बन डाइऑक्साइड दी। अब रक्त में ऑक्सीजन कम है।',
    'e_rich_not_lungs': 'इस रक्त में भरपूर ऑक्सीजन है। हृदय इसे शरीर की कोशिकाओं तक पंप करता है, वापस फेफड़ों में नहीं।',
    'e_sides_separate': 'हृदय के दोनों भाग अलग-अलग होते हैं। हृदय इस रक्त को एक रक्त वाहिका द्वारा बाहर पंप करता है।',
    't_reached_right': 'कम ऑक्सीजन वाला रक्त हृदय के दाएँ भाग में लौट आया है।',
    'e_poor_to_left':
        'बाएँ भाग में केवल ऑक्सीजन से भरपूर रक्त रहता है। कम ऑक्सीजन वाला रक्त दाएँ भाग (आपकी बाईं ओर) में लौटता है।',
    'e_body_to_heart_first': 'शरीर से रक्त पहले हृदय में लौटता है। फिर हृदय उसे फेफड़ों तक पंप करता है।',
    'e_poor_to_lungs': 'कम ऑक्सीजन वाले रक्त को ऑक्सीजन लेने के लिए फेफड़ों में जाना होगा।',
    't_reached_lungs': 'फेफड़ों में रक्त ने कार्बन डाइऑक्साइड छोड़ी और ऑक्सीजन ली। यह फिर से ऑक्सीजन से भरपूर है!',
    'hint_drag_cell': 'रक्त कोशिका को वहाँ खींचें जहाँ रक्त आगे जाता है।',
    't_glucose_in': 'ग्लूकोज़ (भोजन) कोशिका के अंदर पहुँच गया।',
    't_o2_in': 'ऑक्सीजन कोशिका के अंदर पहुँच गई।',
    'e_drop_cell': 'इसे शरीर की कोशिका के अंदर छोड़ें।',
    'e_inside_already': 'यह पहले से कोशिका के अंदर है।',
    'e_tap_release': "श्वसन शुरू करने के लिए 'ऊर्जा मुक्त करें' पर टैप करें।",
    'e_water_stays': 'जल शरीर में ही रहता है और उसके काम आता है। कार्बन डाइऑक्साइड को बाहर ले जाएँ।',
    'i_energy_used': 'कोशिका इस ऊर्जा का उपयोग करती है। यह हमें चलने, दौड़ने, खेलने और सोचने में भी मदद करती है!',
    'e_drop_blood_co2': 'कार्बन डाइऑक्साइड को रक्त वाहिका में छोड़ें।',
    't_co2_out': 'रक्त कार्बन डाइऑक्साइड को फेफड़ों तक ले जाएगा।',
    't_to_bench': 'अब बाहर छोड़ी गई वायु का चूने के पानी से परीक्षण करें।',
    'e_test_a_first': 'पहले आसपास की वायु का परीक्षण करें: परखनली A के ऊपर लगी पिचकारी दबाएँ।',
    't_a_clear': 'बुलबुले निकले, लेकिन परखनली A का चूने का पानी साफ़ रहा।',
    'e_a_done': 'परखनली A का परीक्षण हो गया। अब स्ट्रॉ से परखनली B में फूँकें।',
    't_blow': 'आपने परखनली B में वायु फूँकी ({n}/3)।',
    't_b_milky': 'परखनली B का चूने का पानी दूधिया हो गया!',
    'e_wait_bubbles': 'बुलबुले रुकने तक प्रतीक्षा करें।',
    'e_compare_now': "दोनों प्रकार की वायु की तुलना के लिए 'वायु की तुलना करें' पर टैप करें।",
  },
};

const Map<String, List<LabScenarioData>> _scenarios = {
  'en': [
    LabScenarioData(
      objective:
          'To zoom into the lungs and move oxygen and carbon dioxide across the thin wall of an alveolus, to see how gases are exchanged between the air and the blood.',
      steps: [
        LabStep(
          concept: 'Lungs and Alveoli',
          action: 'TAP the glowing bunch of tiny air sacs (alveoli) at the end of a branch in the lungs to zoom in.',
          observation:
              'The windpipe divides into finer and finer branches that end in tiny balloon-like sacs called alveoli.',
        ),
        LabStep(
          concept: 'Breathing In',
          action: "TAP 'Breathe In' to fill the alveolus with fresh air.",
          observation:
              'Fresh air rich in oxygen fills the alveolus. Its thin wall is wrapped by a fine blood vessel that brings oxygen-poor blood from the body.',
        ),
        LabStep(
          concept: 'Oxygen into the Blood',
          action: 'DRAG 3 blue oxygen molecules from the alveolus across its thin wall into the blood vessel.',
          observation:
              'Oxygen passes from the alveolus, where there is more of it, into the blood, where there is less. The blood becomes oxygen-rich (bright red). Some oxygen still stays in the air of the alveolus.',
        ),
        LabStep(
          concept: 'Carbon Dioxide out of the Blood',
          action: 'DRAG 3 grey carbon dioxide molecules from the blood vessel into the alveolus.',
          observation:
              'Carbon dioxide brought by the blood from the body passes into the alveolus, where there is less of it.',
        ),
        LabStep(
          concept: 'Breathing Out',
          action: "TAP 'Breathe Out' to push the used air out of the lungs.",
          observation:
              'The air breathed out carries the carbon dioxide away. The oxygen-rich blood flows on to the heart, which pumps it to all parts of the body.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To trace one blood cell as the heart pumps it from the lungs to the body cells and back, and to see where blood is oxygen-rich and where it is oxygen-poor.',
      steps: [
        LabStep(
          concept: 'The Circulatory System',
          action: "TAP 'Start Heartbeat' to make the heart pump blood through the blood vessels.",
          observation:
              'The heart pumps blood through blood vessels. Red shows oxygen-rich blood and blue shows oxygen-poor blood.',
        ),
        LabStep(
          concept: 'Lungs to Heart',
          action: 'Follow the red blood vessel and DRAG the oxygen-rich blood cell from the lungs to the heart.',
          observation:
              'Oxygen-rich blood from the lungs enters the left side of the heart. (The heart is drawn as if it faces you, so its left side is on your right.)',
        ),
        LabStep(
          concept: 'Heart to Body',
          action: 'The heart pumps this blood out. DRAG the blood cell from the heart to the body cells.',
          observation:
              'The body cells take oxygen from the blood and give carbon dioxide to it. The blood becomes oxygen-poor (blue).',
        ),
        LabStep(
          concept: 'Body to Heart',
          action: 'DRAG the oxygen-poor blood cell back to the heart.',
          observation: 'Oxygen-poor blood from the body returns to the right side of the heart.',
        ),
        LabStep(
          concept: 'Heart to Lungs',
          action: 'DRAG the blood cell from the heart to the lungs.',
          observation:
              'In the lungs the blood gives out carbon dioxide and takes in oxygen. It becomes oxygen-rich again and the journey repeats.',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'To see how a body cell uses oxygen to break down glucose and release energy, and to test the air we breathe out with lime water.',
      steps: [
        LabStep(
          concept: 'Food and Oxygen Reach the Cell',
          action: 'DRAG the glucose (sugar) and the oxygen from the blood vessel into the body cell.',
          observation: 'Blood brings glucose from digested food and oxygen from the lungs to every cell of the body.',
        ),
        LabStep(
          concept: 'Respiration',
          action: "TAP 'Release Energy' to let oxygen break down the glucose inside the cell.",
          observation:
              'Oxygen breaks down glucose into carbon dioxide and water, and energy is released. This is respiration.',
        ),
        LabStep(
          concept: 'Removing the Waste',
          action: 'DRAG the carbon dioxide out of the cell into the blood vessel.',
          observation: 'Carbon dioxide is a waste product. The blood carries it to the lungs, where it is breathed out.',
        ),
        LabStep(
          concept: 'Air We Breathe In',
          action:
              'TAP the pichkari (syringe) to pass the air around us, the air we breathe in, through the lime water in test tube A.',
          observation: 'The lime water in test tube A stays clear.',
        ),
        LabStep(
          concept: 'Air We Breathe Out',
          action: 'TAP the straw 3 times to blow the air you breathe out through the lime water in test tube B.',
          observation:
              'The lime water in test tube B turns milky. Lime water turns milky with carbon dioxide, so the air we breathe out has more carbon dioxide than the air we breathe in.',
        ),
        LabStep(
          concept: 'Compare the Air',
          action: "TAP 'Compare Air' to see how the air we breathe in differs from the air we breathe out.",
          observation:
              'Exhaled air has less oxygen (nearly 16–17%) and much more carbon dioxide (nearly 4–5%) than inhaled air (nearly 21% oxygen and 0.04% carbon dioxide). Not all the oxygen is used up.',
        ),
      ],
    ),
  ],
  'hi': [
    LabScenarioData(
      objective:
          'फेफड़ों के अंदर ज़ूम करके एक वायुकोष (एल्वियोलस) की पतली भित्ति के आर-पार ऑक्सीजन और कार्बन डाइऑक्साइड को ले जाना, और यह देखना कि वायु और रक्त के बीच गैसों का विनिमय कैसे होता है।',
      steps: [
        LabStep(
          concept: 'फेफड़े और वायुकोष',
          action: 'फेफड़ों में एक शाखा के सिरे पर चमकती छोटी वायु-थैलियों (वायुकोषों) के गुच्छे पर टैप करके ज़ूम करें।',
          observation:
              'श्वासनली छोटी-छोटी और पतली शाखाओं में बँटती जाती है, जिनके सिरों पर गुब्बारे जैसी छोटी थैलियाँ होती हैं, जिन्हें वायुकोष (एल्वियोली) कहते हैं।',
        ),
        LabStep(
          concept: 'साँस अंदर लेना',
          action: "वायुकोष को ताज़ी वायु से भरने के लिए 'साँस अंदर लें' पर टैप करें।",
          observation:
              'ऑक्सीजन से भरपूर ताज़ी वायु वायुकोष में भर जाती है। इसकी पतली भित्ति के चारों ओर एक महीन रक्त वाहिका लिपटी होती है, जो शरीर से कम ऑक्सीजन वाला रक्त लाती है।',
        ),
        LabStep(
          concept: 'ऑक्सीजन रक्त में',
          action: 'नीले रंग के ऑक्सीजन के 3 अणुओं को वायुकोष से उसकी पतली भित्ति के पार रक्त वाहिका में खींचकर ले जाएँ।',
          observation:
              'ऑक्सीजन वायुकोष से, जहाँ यह अधिक है, रक्त में जाती है, जहाँ यह कम है। रक्त ऑक्सीजन से भरपूर (चमकीला लाल) हो जाता है। कुछ ऑक्सीजन वायुकोष की वायु में ही रह जाती है।',
        ),
        LabStep(
          concept: 'कार्बन डाइऑक्साइड रक्त से बाहर',
          action: 'स्लेटी रंग के कार्बन डाइऑक्साइड के 3 अणुओं को रक्त वाहिका से वायुकोष में खींचकर ले जाएँ।',
          observation: 'शरीर से रक्त द्वारा लाई गई कार्बन डाइऑक्साइड वायुकोष में चली जाती है, जहाँ यह कम है।',
        ),
        LabStep(
          concept: 'साँस बाहर छोड़ना',
          action: "उपयोग की गई वायु को फेफड़ों से बाहर निकालने के लिए 'साँस बाहर छोड़ें' पर टैप करें।",
          observation:
              'बाहर छोड़ी गई वायु कार्बन डाइऑक्साइड को बाहर ले जाती है। ऑक्सीजन से भरपूर रक्त हृदय तक जाता है, जो उसे शरीर के सभी भागों में पंप करता है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'हृदय द्वारा फेफड़ों से शरीर की कोशिकाओं तक और वापस पंप की जाने वाली एक रक्त कोशिका के मार्ग का पता लगाना, और यह देखना कि रक्त कहाँ ऑक्सीजन से भरपूर होता है और कहाँ उसमें ऑक्सीजन कम होती है।',
      steps: [
        LabStep(
          concept: 'परिसंचरण तंत्र',
          action: "हृदय से रक्त वाहिकाओं में रक्त पंप कराने के लिए 'दिल की धड़कन शुरू करें' पर टैप करें।",
          observation:
              'हृदय रक्त वाहिकाओं में रक्त पंप करता है। लाल रंग ऑक्सीजन से भरपूर रक्त और नीला रंग कम ऑक्सीजन वाला रक्त दर्शाता है।',
        ),
        LabStep(
          concept: 'फेफड़ों से हृदय तक',
          action: 'लाल रक्त वाहिका के मार्ग पर चलते हुए ऑक्सीजन से भरपूर रक्त कोशिका को फेफड़ों से हृदय तक खींचें।',
          observation:
              'फेफड़ों से आया ऑक्सीजन से भरपूर रक्त हृदय के बाएँ भाग में प्रवेश करता है। (हृदय ऐसे दिखाया गया है जैसे वह आपकी ओर मुख किए हो, इसलिए उसका बायाँ भाग आपकी दाईं ओर है।)',
        ),
        LabStep(
          concept: 'हृदय से शरीर तक',
          action: 'हृदय इस रक्त को बाहर पंप करता है। रक्त कोशिका को हृदय से शरीर की कोशिकाओं तक खींचें।',
          observation:
              'शरीर की कोशिकाएँ रक्त से ऑक्सीजन लेती हैं और उसे कार्बन डाइऑक्साइड देती हैं। रक्त में ऑक्सीजन कम हो जाती है (नीला)।',
        ),
        LabStep(
          concept: 'शरीर से हृदय तक',
          action: 'कम ऑक्सीजन वाली रक्त कोशिका को वापस हृदय तक खींचें।',
          observation: 'शरीर से आया कम ऑक्सीजन वाला रक्त हृदय के दाएँ भाग में लौटता है।',
        ),
        LabStep(
          concept: 'हृदय से फेफड़ों तक',
          action: 'रक्त कोशिका को हृदय से फेफड़ों तक खींचें।',
          observation:
              'फेफड़ों में रक्त कार्बन डाइऑक्साइड छोड़ता है और ऑक्सीजन लेता है। यह फिर से ऑक्सीजन से भरपूर हो जाता है और यह यात्रा दोहराई जाती है।',
        ),
      ],
    ),
    LabScenarioData(
      objective:
          'यह देखना कि शरीर की कोशिका ऑक्सीजन की सहायता से ग्लूकोज़ को कैसे तोड़ती है और ऊर्जा मुक्त करती है, और बाहर छोड़ी गई वायु का चूने के पानी से परीक्षण करना।',
      steps: [
        LabStep(
          concept: 'भोजन और ऑक्सीजन कोशिका तक',
          action: 'ग्लूकोज़ (शर्करा) और ऑक्सीजन को रक्त वाहिका से शरीर की कोशिका में खींचें।',
          observation: 'रक्त पचे हुए भोजन से ग्लूकोज़ और फेफड़ों से ऑक्सीजन शरीर की प्रत्येक कोशिका तक पहुँचाता है।',
        ),
        LabStep(
          concept: 'श्वसन',
          action: "कोशिका के अंदर ऑक्सीजन द्वारा ग्लूकोज़ को तोड़ने के लिए 'ऊर्जा मुक्त करें' पर टैप करें।",
          observation:
              'ऑक्सीजन ग्लूकोज़ को कार्बन डाइऑक्साइड और जल में तोड़ देती है और ऊर्जा मुक्त होती है। यही श्वसन है।',
        ),
        LabStep(
          concept: 'अपशिष्ट को हटाना',
          action: 'कार्बन डाइऑक्साइड को कोशिका से बाहर रक्त वाहिका में खींचें।',
          observation:
              'कार्बन डाइऑक्साइड एक अपशिष्ट उत्पाद है। रक्त इसे फेफड़ों तक ले जाता है, जहाँ से इसे साँस के साथ बाहर छोड़ दिया जाता है।',
        ),
        LabStep(
          concept: 'अंदर ली जाने वाली वायु',
          action:
              'हमारे आसपास की वायु, यानी जो वायु हम अंदर लेते हैं, उसे परखनली A के चूने के पानी में से गुज़ारने के लिए पिचकारी पर टैप करें।',
          observation: 'परखनली A का चूने का पानी साफ़ रहता है।',
        ),
        LabStep(
          concept: 'बाहर छोड़ी जाने वाली वायु',
          action: 'बाहर छोड़ी जाने वाली वायु को परखनली B के चूने के पानी में फूँकने के लिए स्ट्रॉ पर 3 बार टैप करें।',
          observation:
              'परखनली B का चूने का पानी दूधिया हो जाता है। कार्बन डाइऑक्साइड से चूने का पानी दूधिया होता है, इसलिए बाहर छोड़ी गई वायु में अंदर ली गई वायु की तुलना में अधिक कार्बन डाइऑक्साइड होती है।',
        ),
        LabStep(
          concept: 'वायु की तुलना',
          action: "अंदर ली गई और बाहर छोड़ी गई वायु में अंतर देखने के लिए 'वायु की तुलना करें' पर टैप करें।",
          observation:
              'बाहर छोड़ी गई वायु में अंदर ली गई वायु (लगभग 21% ऑक्सीजन और 0.04% कार्बन डाइऑक्साइड) की तुलना में कम ऑक्सीजन (लगभग 16–17%) और कहीं अधिक कार्बन डाइऑक्साइड (लगभग 4–5%) होती है। सारी ऑक्सीजन उपयोग में नहीं आती।',
        ),
      ],
    ),
  ],
};

// ============================================================== STATE

const Size _design = Size(1000, 560);

// ---- Scenario 1: lungs overview and the alveolus close-up (design px).

/// Centre of the lungs drawing (breathing / scaling pivot).
const Offset _lungC = Offset(500, 282);

/// The glowing bunch of alveoli the learner taps to zoom in.
const Offset _target = Offset(352, 388);

/// Centre of the alveolus in the close-up.
const Offset _alvC = Offset(500, 215);

/// The capillary hugs the alveolus on a circle of radius [_capR] for
/// |dx| <= [_capCore], then flattens out towards both edges.
const double _capR = 190;
const double _capCore = 114;
const double _capHalf = 30;

double _capY(double x) {
  final dx = x - _alvC.dx;
  final ax = dx.abs();
  if (ax <= _capCore) return _alvC.dy + math.sqrt(_capR * _capR - dx * dx);
  final y0 = math.sqrt(_capR * _capR - _capCore * _capCore);
  final slope = _capCore / y0;
  const l = 90.0;
  return _alvC.dy + y0 - slope * l * (1 - math.exp(-(ax - _capCore) / l));
}

double _capAngle(double x) => math.atan2(_capY(x + 1) - _capY(x - 1), 2);

/// Centre line of the capillary (extends into the letterbox).
final Path _capPath = () {
  final p = Path()..moveTo(-900, _capY(-900));
  for (var x = -894.0; x <= 1900; x += 6) {
    p.lineTo(x, _capY(x));
  }
  return p;
}();

/// Visible part of the capillary, used to move the red blood cells.
final _capFlow = () {
  final p = Path()..moveTo(-140, _capY(-140));
  for (var x = -134.0; x <= 1140; x += 6) {
    p.lineTo(x, _capY(x));
  }
  return p.computeMetrics().first;
}();

const List<Offset> _alvO2Slots = [
  Offset(420, 170), Offset(500, 148), Offset(580, 170), //
  Offset(408, 242), Offset(500, 232), Offset(592, 242),
];
const List<Offset> _alvCo2Slots = [Offset(440, 300), Offset(500, 318), Offset(560, 300)];
const List<double> _bloodO2X = [430, 510, 590];
const List<double> _bloodCo2X = [360, 420, 470, 550, 625];

Offset _bloodO2Slot(int i) => Offset(_bloodO2X[i], _capY(_bloodO2X[i]) - 13);
Offset _bloodCo2Slot(int i) => Offset(_bloodCo2X[i], _capY(_bloodCo2X[i]) + 9);

class _Seg {
  const _Seg(this.a, this.b, this.w);
  final Offset a, b;
  final double w;
}

/// Branches of the windpipe inside both lungs (and their tips).
final ({List<_Seg> segs, List<Offset> tips}) _tree = () {
  final segs = <_Seg>[];
  final tips = <Offset>[];
  void grow(Offset from, double angle, double len, double w, int depth) {
    final to = from + Offset(math.cos(angle), math.sin(angle)) * len;
    segs.add(_Seg(from, to, w));
    if (depth == 0) {
      tips.add(to);
      return;
    }
    grow(to, angle - 0.45, len * 0.78, w * 0.68, depth - 1);
    grow(to, angle + 0.42, len * 0.74, w * 0.68, depth - 1);
  }

  grow(const Offset(462, 250), math.pi * 0.62, 64, 12, 4);
  grow(const Offset(538, 250), math.pi * 0.38, 64, 12, 4);
  return (segs: segs, tips: tips);
}();

/// The right lung (drawn on the viewer's left).
final Path _lungRightPath = Path()
  ..moveTo(412, 92)
  ..cubicTo(360, 96, 292, 170, 276, 282)
  ..cubicTo(262, 372, 262, 440, 288, 470)
  ..cubicTo(332, 458, 402, 446, 456, 464)
  ..cubicTo(468, 410, 458, 330, 462, 262)
  ..cubicTo(466, 190, 452, 118, 412, 92)
  ..close();

/// The left lung (viewer's right), with the notch for the heart.
final Path _lungLeftPath = Path()
  ..moveTo(588, 92)
  ..cubicTo(640, 96, 708, 170, 724, 282)
  ..cubicTo(738, 372, 738, 440, 712, 470)
  ..cubicTo(668, 458, 610, 450, 560, 462)
  ..cubicTo(592, 430, 598, 372, 566, 346)
  ..cubicTo(536, 318, 540, 250, 540, 230)
  ..cubicTo(542, 160, 556, 112, 588, 92)
  ..close();

// ---- Scenario 2: circulation (heart, lungs, body cells).

const Offset _heartC = Offset(500, 305);

final Path _heartPath = Path()
  ..moveTo(500, 240)
  ..cubicTo(470, 208, 394, 212, 392, 272)
  ..cubicTo(390, 332, 452, 378, 500, 398)
  ..cubicTo(548, 378, 610, 332, 608, 272)
  ..cubicTo(606, 212, 530, 208, 500, 240)
  ..close();

/// Right ventricle (viewer's left, lower chamber).
final Path _rvPath = Path()
  ..moveTo(494, 300)
  ..cubicTo(494, 340, 492, 368, 490, 382)
  ..cubicTo(462, 368, 420, 336, 416, 304)
  ..cubicTo(432, 294, 470, 293, 494, 300)
  ..close();

/// Left ventricle (viewer's right, lower chamber).
final Path _lvPath = Path()
  ..moveTo(506, 300)
  ..cubicTo(506, 340, 508, 368, 510, 382)
  ..cubicTo(538, 368, 580, 336, 584, 304)
  ..cubicTo(568, 294, 530, 293, 506, 300)
  ..close();

// Blood vessels: to the lungs (blue), from the lungs (red), to the body
// (red), from the body (blue) and the two capillary beds.
final Path _paPath = Path()
  ..moveTo(478, 240)
  ..cubicTo(474, 205, 430, 200, 412, 172);
final Path _pvPath = Path()
  ..moveTo(588, 172)
  ..cubicTo(570, 200, 526, 205, 522, 240);
final Path _aoPath = Path()
  ..moveTo(604, 300)
  ..cubicTo(690, 296, 760, 300, 760, 386)
  ..cubicTo(760, 452, 690, 470, 614, 470);
final Path _vcPath = Path()
  ..moveTo(386, 470)
  ..cubicTo(310, 470, 240, 452, 240, 386)
  ..cubicTo(240, 300, 310, 296, 396, 300);
final Path _lungCapPath = Path()
  ..moveTo(412, 172)
  ..cubicTo(420, 60, 580, 60, 588, 172);
final Path _bodyCapPath = Path()
  ..moveTo(614, 470)
  ..cubicTo(590, 522, 410, 522, 386, 470);

final _paM = _paPath.computeMetrics().first;
final _pvM = _pvPath.computeMetrics().first;
final _aoM = _aoPath.computeMetrics().first;
final _vcM = _vcPath.computeMetrics().first;
final _lungCapM = _lungCapPath.computeMetrics().first;
final _bodyCapM = _bodyCapPath.computeMetrics().first;

const List<Offset> _bodyCells = [
  Offset(500, 448), Offset(450, 448), Offset(550, 448), Offset(475, 486), //
  Offset(525, 486), Offset(425, 486), Offset(575, 486),
];

enum _Place { lungs, left, right, body }

const Offset _tracerLungsStart = Offset(578, 136);
const Offset _tracerLungsEnd = Offset(422, 136);
const Offset _tracerLeft = Offset(548, 314);
const Offset _tracerRight = Offset(452, 314);
const Offset _tracerBody = Offset(500, 452);

// ---- Scenario 3: a body cell, then the lime water bench.

const Offset _cellC = Offset(470, 222);
const double _cellRx = 265;
const double _cellRy = 158;
const Offset _nucC = Offset(345, 205);
const Offset _reactC = Offset(612, 222);
const double _vesY = 466;
const double _vesHalf = 40;

const Offset _glucoseStart = Offset(290, _vesY);
const Offset _o2Start = Offset(660, _vesY);
const Offset _glucoseIn = Offset(555, 200);
const Offset _o2In = Offset(665, 255);
const Offset _co2Home = Offset(548, 305);
const Offset _waterHome = Offset(668, 300);

/// Bench geometry: test tubes A / B, the pichkari and the straw.
const Rect _tubeA = Rect.fromLTRB(300, 210, 356, 425);
const Rect _tubeB = Rect.fromLTRB(500, 210, 556, 425);
const double _limeTop = 300;
const Rect _tapA = Rect.fromLTRB(276, 0, 384, 432);
const Rect _tapB = Rect.fromLTRB(484, 60, 790, 432);

final List<Offset> _granules = () {
  final rng = math.Random(11);
  final out = <Offset>[];
  while (out.length < 34) {
    final p = Offset(
      _cellC.dx + (rng.nextDouble() * 2 - 1) * _cellRx * 0.85,
      _cellC.dy + (rng.nextDouble() * 2 - 1) * _cellRy * 0.8,
    );
    final e = math.pow((p.dx - _cellC.dx) / (_cellRx * 0.88), 2) + math.pow((p.dy - _cellC.dy) / (_cellRy * 0.84), 2);
    if (e < 1 && (p - _nucC).distance > 70) out.add(p);
  }
  return out;
}();

double _smooth(double a, double b, double x) {
  final v = ((x - a) / (b - a)).clamp(0.0, 1.0);
  return v * v * (3 - 2 * v);
}

/// Splits a formula label into (text, isSubscript) runs: `_` followed by
/// digits marks a subscript, so 'CO_2' reads CO₂ with any font.
List<(String, bool)> _runs(String text) {
  final out = <(String, bool)>[];
  final buf = StringBuffer();
  var i = 0;
  while (i < text.length) {
    if (text[i] == '_' && i + 1 < text.length && '0123456789'.contains(text[i + 1])) {
      if (buf.isNotEmpty) out.add((buf.toString(), false));
      buf.clear();
      var j = i + 1;
      while (j < text.length && '0123456789'.contains(text[j])) {
        j++;
      }
      out.add((text.substring(i + 1, j), true));
      i = j;
    } else {
      buf.write(text[i]);
      i++;
    }
  }
  if (buf.isNotEmpty) out.add((buf.toString(), false));
  return out;
}

/// Text where each '→' is drawn as an arrow icon (works with any font).
Widget _arrowText(String text, TextStyle style) {
  final parts = text.split('→');
  final size = style.fontSize ?? 12;
  return Text.rich(
    TextSpan(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_forward_rounded, size: size * 1.05, color: style.color),
            ),
          TextSpan(text: parts[i]),
        ],
      ],
    ),
    style: style,
  );
}

/// Text with chemical subscripts (see [_runs]) for cards and tables.
Widget _chem(String text, TextStyle style, {TextAlign align = TextAlign.start}) {
  final size = style.fontSize ?? 12;
  return Text.rich(
    TextSpan(
      children: [
        for (final (s, sub) in _runs(text))
          if (!sub)
            TextSpan(text: s)
          else
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Transform.translate(
                offset: Offset(0, size * 0.22),
                child: Text(s, style: style.copyWith(fontSize: size * 0.72)),
              ),
            ),
      ],
    ),
    style: style,
    textAlign: align,
  );
}

/// Heart "lub-dub" pulse (0..~1) at time [t] seconds after it started.
double _beat(double t) {
  final ph = (t * 1.2) % 1.0;
  double g(double c) => math.exp(-math.pow((ph - c) / 0.05, 2).toDouble());
  return g(0.08) + 0.6 * g(0.28);
}

enum _Kind { o2, co2, glucose, water }

/// A draggable molecule. It eases towards [home] unless it is dragged.
class _Mol {
  _Mol(this.kind, Offset at, this.phase)
      : home = at,
        pos = at;

  final _Kind kind;
  final double phase;
  Offset home;
  Offset pos;
  bool visible = true;

  /// Crossed the wall / entered the cell / left the cell.
  bool moved = false;

  /// Flying out of the scene (breathed out); hidden on arrival.
  bool leaving = false;
}

/// Mutable scene model read by the painter every frame.
class _Scene {
  int scenario = 0;
  int step = 1;
  double time = 0;
  double busyUntil = 0;
  final List<_Mol> mols = [];

  /// Index of the dragged molecule, -1 for the blood cell, null if none.
  int? drag;

  // Scenario 1.
  double? zoomAt;
  double inflate = 0;
  double inflateTarget = 0;
  double oxygenation = 0;
  double breathAt = -99;
  bool breathIn = true;
  bool breathedIn = false;
  bool breathedOut = false;
  int o2Moved = 0;
  int co2Moved = 0;

  // Scenario 2.
  bool heartOn = false;
  double heartAt = 0;
  _Place at = _Place.lungs;
  Offset tracer = _tracerLungsStart;
  Offset tracerHome = _tracerLungsStart;
  double rich = 1;
  double richTarget = 1;
  int route = -1;
  double routeAt = -99;
  double exchangeAt = -99;
  bool exchangeInLungs = false;
  int legsDone = 0;

  // Scenario 3.
  double? benchAt;
  double reactAt = -99;
  bool reacted = false;
  double energy = 0;
  double energyTarget = 0;
  bool co2Out = false;
  double pushAt = -99;
  bool aDone = false;
  int blows = 0;
  double blowAt = -99;
  double milk = 0;
  bool compared = false;

  bool get busy => time < busyUntil;

  /// 0 = lungs overview, 1 = alveolus close-up.
  double get zoom {
    if (scenario != 0) return 1;
    final z = zoomAt;
    if (z == null) return step >= 2 ? 1 : 0;
    return ((time - z) / 1.4).clamp(0.0, 1.0);
  }

  /// 0 = body cell, 1 = lime water bench.
  double get bench {
    final b = benchAt;
    if (b == null) return 0;
    return ((time - b) / 0.8).clamp(0.0, 1.0);
  }

  void reset(int s) {
    scenario = s;
    step = 1;
    busyUntil = 0;
    drag = null;
    mols.clear();
    zoomAt = null;
    inflate = 0;
    inflateTarget = 0;
    oxygenation = 0;
    breathAt = -99;
    breathIn = true;
    breathedIn = false;
    breathedOut = false;
    o2Moved = 0;
    co2Moved = 0;
    heartOn = false;
    heartAt = 0;
    at = _Place.lungs;
    tracer = _tracerLungsStart;
    tracerHome = _tracerLungsStart;
    rich = 1;
    richTarget = 1;
    route = -1;
    routeAt = -99;
    exchangeAt = -99;
    exchangeInLungs = false;
    legsDone = 0;
    benchAt = null;
    reactAt = -99;
    reacted = false;
    energy = 0;
    energyTarget = 0;
    co2Out = false;
    pushAt = -99;
    aDone = false;
    blows = 0;
    blowAt = -99;
    milk = 0;
    compared = false;
    if (s == 0) {
      for (var i = 0; i < 6; i++) {
        mols.add(_Mol(_Kind.o2, _alvO2Slots[i], i * 1.3)..visible = false);
      }
      for (var i = 0; i < 5; i++) {
        mols.add(_Mol(_Kind.co2, _bloodCo2Slot(i), 0.7 + i * 1.1));
      }
    } else if (s == 2) {
      mols
        ..add(_Mol(_Kind.glucose, _glucoseStart, 0.4))
        ..add(_Mol(_Kind.o2, _o2Start, 1.9))
        ..add(_Mol(_Kind.co2, _reactC, 2.6)..visible = false)
        ..add(_Mol(_Kind.water, _reactC, 3.3)..visible = false);
    }
  }

  /// Eases molecules, the blood cell and the colour levels towards their
  /// targets.
  void update(double dt) {
    final k = 1 - math.exp(-dt * 5);
    for (var i = 0; i < mols.length; i++) {
      final m = mols[i];
      if (drag == i) continue;
      m.pos = Offset.lerp(m.pos, m.home, k)!;
      if (m.leaving && (m.pos - m.home).distance < 40) m.visible = false;
    }
    final slow = 1 - math.exp(-dt * 2.5);
    inflate += (inflateTarget - inflate) * slow;
    oxygenation += (o2Moved / 3 - oxygenation) * slow;
    if (drag != -1) tracer = Offset.lerp(tracer, tracerHome, 1 - math.exp(-dt * 4))!;
    rich += (richTarget - rich) * (1 - math.exp(-dt * 2.2));
    energy += (energyTarget - energy) * slow;
    milk += (blows / 3 - milk) * (1 - math.exp(-dt * 1.6));
  }
}

/// Pan recognizer that only claims pointers which start on a draggable
/// object, so an unlocked camera can still pan the canvas elsewhere.
class _ScenePanRecognizer extends PanGestureRecognizer {
  _ScenePanRecognizer() : super(debugOwner: null);

  bool Function(Offset local) accepts = _never;

  static bool _never(Offset _) => false;

  @override
  bool isPointerAllowed(PointerEvent event) => accepts(event.localPosition) && super.isPointerAllowed(event);
}

class _Ch9A4GasExchangeAndCellularRespirationPageState extends State<Ch9A4GasExchangeAndCellularRespirationPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<double> _frame = ValueNotifier(0);

  late final Ticker _ticker;

  String _t(String key) => _lab.tr(_i18n, key);
  String _f(String key, Map<String, Object> values) => labFormat(_t(key), values);
  LabScenarioData get _data => _scenarios[_lab.lang.code]![_scene.scenario];
  bool get _complete => _scene.step > _data.steps.length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scene.reset(0);
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (t - _scene.time).clamp(0.0, 0.1);
    _scene.time = t;
    _scene.update(dt);
    _frame.value = t;
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

  // ------------------------------------------------------------ flow

  void _changeScenario(int index) {
    setState(() {
      _lab.hidePopup(sound: false);
      _lab.cancelPending();
      _scene.reset(index);
      _lab.resetView(sound: false);
    });
  }

  void _fullReset() {
    setState(() {
      _lab.cancelPending();
      _scene.reset(0);
    });
  }

  void _busyFor(int ms) => _scene.busyUntil = _scene.time + ms / 1000;

  void _advance() {
    if (!mounted) return;
    setState(() {
      _scene.busyUntil = 0;
      if (_scene.step <= _data.steps.length) _scene.step++;
    });
  }

  /// Marks the scenario finished and shows its conclusion popup.
  void _finish() {
    if (!mounted) return;
    final idx = _scene.scenario;
    setState(() {
      _scene.busyUntil = 0;
      _scene.step = _data.steps.length + 1;
    });
    _lab.showScenarioConclusion(
      scenarioIndex: idx,
      totalScenarios: 3,
      delay: const Duration(milliseconds: 700),
      title: () => _t('conclusion_title'),
      heading: () => _t('conclusion_heading'),
      body: () => _t('conclusion_${idx + 1}'),
      extra: idx == 2
          ? () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_equationBox(), const SizedBox(height: 10), _comparisonTable()],
              )
          : null,
    );
  }

  /// Observation popup for (1-based) [step] of the current scenario. The
  /// step has already advanced, so closing it never blocks the lab.
  void _observe(int step, {Widget Function()? extra}) {
    final scenario = _scene.scenario;
    _lab.showPopup(() {
      final s = _scenarios[_lab.lang.code]![scenario].steps[step - 1];
      return LabPopupContent(
        title: _t('obs_title'),
        heading: s.concept,
        body: s.observation,
        extra: extra?.call(),
        icon: Icons.visibility,
        accent: _Colors.oxygen,
        actions: [
          LabAction(
            label: _t('btn_continue'),
            icon: Icons.arrow_forward,
            color: _Colors.indigo600,
            foreground: Colors.white,
            onTap: () => _lab.hidePopup(sound: false),
          ),
        ],
      );
    });
  }

  void _error(String key) => _lab.showToast(_t(key), isError: true);

  void _info(String key) {
    _Audio.play(_Sound.click);
    _lab.showToast(_t(key), sound: false);
  }

  // ------------------------------------------------ scenario 1 actions

  void _breatheIn() {
    final sc = _scene;
    if (sc.busy) return;
    if (sc.step != 2) {
      _Audio.play(_Sound.wrong);
      _error(sc.step == 5 ? 'e_full_already' : 'e_breathe_out_now');
      return;
    }
    _Audio.play(_Sound.whoosh);
    setState(() {
      for (var i = 0; i < 6; i++) {
        final m = sc.mols[i];
        m
          ..visible = true
          ..home = _alvO2Slots[i]
          ..pos = Offset(500 + (i.isEven ? -10 : 10), -60.0 - i * 70);
      }
      sc
        ..breathIn = true
        ..breathAt = sc.time
        ..breathedIn = true
        ..inflateTarget = 1;
      _busyFor(1800);
    });
    _lab.after(const Duration(milliseconds: 1800), () {
      _lab.showToast(_t('t_breathed_in'));
      _advance();
    });
  }

  void _breatheOut() {
    final sc = _scene;
    if (sc.busy) return;
    if (sc.step != 5) {
      _Audio.play(_Sound.wrong);
      _error(sc.step == 2 ? 'e_no_air_yet' : 'e_full_already');
      return;
    }
    _Audio.play(_Sound.whoosh);
    setState(() {
      var n = 0;
      for (final m in sc.mols) {
        final inAlveolus = (m.kind == _Kind.o2 && !m.moved) || (m.kind == _Kind.co2 && m.moved);
        if (!inAlveolus || !m.visible) continue;
        m
          ..leaving = true
          ..home = Offset(500 + (n.isEven ? -12.0 : 12.0), -160.0 - n * 40);
        n++;
      }
      sc
        ..breathIn = false
        ..breathAt = sc.time
        ..breathedOut = true
        ..inflateTarget = 0;
      _busyFor(2000);
    });
    _lab.after(const Duration(milliseconds: 1900), () {
      _lab.showToast(_t('t_breathed_out'), sound: false);
      _finish();
    });
  }

  /// Scene tap in the lungs overview.
  void _tapLungs(Offset p) {
    final sc = _scene;
    if (sc.zoomAt != null) return;
    if ((p - _target).distance < 52) {
      _Audio.play(_Sound.magic);
      setState(() {
        sc.zoomAt = sc.time;
        _busyFor(1500);
      });
      _lab.after(const Duration(milliseconds: 1500), () {
        _lab.showToast(_t('t_zoomed'));
        _advance();
      });
    } else if (_lungRightPath.contains(p) || _lungLeftPath.contains(p) || (p.dx - 500).abs() < 30 && p.dy < 250) {
      _error('e_tap_alveoli');
    }
  }

  String? _s1GrabError(_Mol m) {
    switch (_scene.step) {
      case 2:
        return 'e_breathe_first';
      case 3:
        if (m.kind == _Kind.co2) return 'e_o2_first';
        return m.moved ? 'e_o2_stays' : null;
      case 4:
        if (m.kind == _Kind.o2) return m.moved ? 'e_o2_stays' : 'e_enough_o2';
        return m.moved ? 'e_co2_done' : null;
      default:
        return 'e_breathe_out_now';
    }
  }

  bool _inBlood(Offset p) => p.dx > 140 && p.dx < 860 && (p.dy - _capY(p.dx)).abs() < _capHalf + 18;

  void _dropS1(_Mol m) {
    final sc = _scene;
    if (m.kind == _Kind.o2) {
      if (!_inBlood(m.pos)) {
        _error('e_drop_blood');
        return;
      }
      m
        ..moved = true
        ..home = _bloodO2Slot(sc.o2Moved);
      sc.o2Moved++;
      if (sc.o2Moved < 3) {
        _lab.showToast(_f('t_o2_moved', {'n': sc.o2Moved}));
      } else {
        _Audio.play(_Sound.drop);
        _lab.showToast(_f('t_o2_moved', {'n': 3}), sound: false);
        _advance();
        _lab.after(const Duration(milliseconds: 700), () => _observe(3));
      }
    } else {
      if ((m.pos - _alvC).distance > 140) {
        _error('e_drop_alveolus');
        return;
      }
      m
        ..moved = true
        ..home = _alvCo2Slots[sc.co2Moved];
      sc.co2Moved++;
      _lab.showToast(_f('t_co2_moved', {'n': sc.co2Moved}));
      if (sc.co2Moved >= 3) _advance();
    }
  }

  // ------------------------------------------------ scenario 2 actions

  void _startHeart() {
    final sc = _scene;
    if (sc.heartOn) return;
    _Audio.play(_Sound.whoosh);
    setState(() {
      sc
        ..heartOn = true
        ..heartAt = sc.time;
    });
    _lab.showToast(_t('t_heart_started'));
    _advance();
  }

  _Place? _placeAt(Offset p) {
    if (const Rect.fromLTRB(350, 0, 650, 192).contains(p)) return _Place.lungs;
    if (const Rect.fromLTRB(380, 200, 620, 408).contains(p)) return p.dx < 500 ? _Place.right : _Place.left;
    if (const Rect.fromLTRB(370, 412, 630, 600).contains(p)) return _Place.body;
    return null;
  }

  static const Map<int, _Place> _expected = {
    2: _Place.left,
    3: _Place.body,
    4: _Place.right,
    5: _Place.lungs,
  };

  /// Moves the blood cell to [dest] (dropped there or tapped).
  void _sendTo(_Place? dest) {
    final sc = _scene;
    final st = sc.step;
    if (dest == null) {
      _error('e_drop_part');
      return;
    }
    if (dest == sc.at) {
      _error('e_already_here');
      return;
    }
    if (dest != _expected[st]) {
      final key = switch ((st, dest)) {
        (2, _Place.right) => 'e_rich_to_right',
        (2, _) => 'e_lungs_to_heart_first',
        (3, _Place.lungs) => 'e_rich_not_lungs',
        (3, _) => 'e_sides_separate',
        (4, _Place.left) => 'e_poor_to_left',
        (4, _) => 'e_body_to_heart_first',
        (5, _Place.left) => 'e_poor_to_left',
        _ => 'e_poor_to_lungs',
      };
      _error(key);
      return;
    }
    _Audio.play(_Sound.whoosh);
    setState(() {
      sc
        ..route = st - 2
        ..routeAt = sc.time
        ..at = dest
        ..legsDone = st - 1
        ..tracerHome = switch (dest) {
          _Place.left => _tracerLeft,
          _Place.right => _tracerRight,
          _Place.body => _tracerBody,
          _Place.lungs => _tracerLungsEnd,
        };
    });
    switch (st) {
      case 2:
        _lab.showToast(_t('t_reached_left'));
        _advance();
      case 4:
        _lab.showToast(_t('t_reached_right'));
        _advance();
      case 3 || 5:
        final lungs = st == 5;
        setState(() {
          sc
            ..exchangeAt = sc.time + 0.6
            ..exchangeInLungs = lungs;
          _busyFor(2200);
        });
        _lab.after(const Duration(milliseconds: 900), () => sc.richTarget = lungs ? 1 : 0);
        _lab.after(const Duration(milliseconds: 2200), () {
          if (lungs) {
            _lab.showToast(_t('t_reached_lungs'), sound: false);
            _finish();
          } else {
            _lab.showToast(_t('t_reached_body'), sound: false);
            _advance();
            _observe(3);
          }
        });
    }
  }

  // ------------------------------------------------ scenario 3 actions

  bool _inCell(Offset p) {
    final dx = (p.dx - _cellC.dx) / _cellRx;
    final dy = (p.dy - _cellC.dy) / _cellRy;
    return dx * dx + dy * dy < 0.9;
  }

  String? _s3GrabError(_Mol m) {
    switch (_scene.step) {
      case 1:
        return m.moved ? 'e_inside_already' : null;
      case 2:
        return 'e_tap_release';
      case 3:
        if (m.kind == _Kind.water) return 'e_water_stays';
        return m.moved ? 'e_compare_now' : null;
      default:
        return null;
    }
  }

  void _dropS3(_Mol m) {
    final sc = _scene;
    if (sc.step == 1) {
      if (!_inCell(m.pos)) {
        _error('e_drop_cell');
        return;
      }
      m
        ..moved = true
        ..home = m.kind == _Kind.glucose ? _glucoseIn : _o2In;
      _lab.showToast(_t(m.kind == _Kind.glucose ? 't_glucose_in' : 't_o2_in'));
      if (sc.mols[0].moved && sc.mols[1].moved) _advance();
    } else if (sc.step == 3 && m.kind == _Kind.co2) {
      if ((m.pos.dy - _vesY).abs() > _vesHalf + 22) {
        _error('e_drop_blood_co2');
        return;
      }
      m
        ..moved = true
        ..home = Offset(m.pos.dx.clamp(160.0, 840.0), _vesY);
      sc.co2Out = true;
      _lab.showToast(_t('t_co2_out'));
      _busyFor(1600);
      _lab.after(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        _Audio.play(_Sound.whoosh);
        setState(() => sc.benchAt = sc.time);
        _lab.showToast(_t('t_to_bench'), sound: false);
        _advance();
      });
    }
  }

  void _react() {
    final sc = _scene;
    if (sc.busy || sc.step != 2) return;
    _Audio.play(_Sound.magic);
    setState(() {
      sc.reactAt = sc.time;
      sc.mols[0].home = _reactC - const Offset(20, 0);
      sc.mols[1].home = _reactC + const Offset(20, 0);
      _busyFor(2700);
    });
    _lab.after(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _Audio.play(_Sound.spark);
      setState(() {
        sc
          ..reacted = true
          ..energyTarget = 1;
        sc.mols[0].visible = false;
        sc.mols[1].visible = false;
        sc.mols[2]
          ..visible = true
          ..pos = _reactC
          ..home = _co2Home;
        sc.mols[3]
          ..visible = true
          ..pos = _reactC
          ..home = _waterHome;
      });
    });
    _lab.after(const Duration(milliseconds: 2700), () {
      _advance();
      _observe(2, extra: _equationBox);
    });
  }

  void _pushPichkari() {
    final sc = _scene;
    if (sc.busy) return;
    if (sc.step != 4) {
      _Audio.play(_Sound.wrong);
      _error(sc.step == 5 ? 'e_a_done' : 'e_compare_now');
      return;
    }
    _Audio.play(_Sound.bubble);
    setState(() {
      sc.pushAt = sc.time;
      _busyFor(1900);
    });
    _lab.after(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      setState(() => sc.aDone = true);
      _lab.showToast(_t('t_a_clear'));
      _advance();
    });
  }

  void _blow() {
    final sc = _scene;
    if (sc.step == 4) {
      _Audio.play(_Sound.wrong);
      _error('e_test_a_first');
      return;
    }
    if (sc.step != 5) {
      _Audio.play(_Sound.wrong);
      _error('e_compare_now');
      return;
    }
    if (sc.busy) {
      _error('e_wait_bubbles');
      return;
    }
    _Audio.play(_Sound.bubble);
    setState(() {
      sc
        ..blows += 1
        ..blowAt = sc.time;
      _busyFor(1300);
    });
    final n = sc.blows;
    if (n < 3) {
      _lab.showToast(_f('t_blow', {'n': n}), sound: false);
      _lab.after(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => sc.busyUntil = 0);
      });
    } else {
      _lab.after(const Duration(milliseconds: 1500), () {
        _lab.showToast(_t('t_b_milky'), sound: false);
        _advance();
        _observe(5);
      });
    }
  }

  void _compare() {
    final sc = _scene;
    if (sc.compared) return;
    _Audio.play(_Sound.pop);
    setState(() {
      sc.compared = true;
      _busyFor(1600);
    });
    _lab.after(const Duration(milliseconds: 1600), _finish);
  }

  // ---------------------------------------------------------- gestures

  /// Index of the molecule under [p], -1 for the blood cell, or null.
  int? _hitKey(Offset p) {
    final sc = _scene;
    if (_complete) return null;
    if (sc.scenario == 1) return (p - sc.tracer).distance < 44 ? -1 : null;
    if (sc.scenario == 0 && sc.step == 1) return null;
    if (sc.scenario == 2 && sc.benchAt != null) return null;
    int? best;
    var bestD = 42.0;
    for (var i = 0; i < sc.mols.length; i++) {
      final m = sc.mols[i];
      if (!m.visible || m.leaving) continue;
      final d = (p - m.pos).distance;
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  String? _grabError(int key) {
    final sc = _scene;
    if (key == -1) return sc.heartOn ? null : 'e_start_heart';
    final m = sc.mols[key];
    return sc.scenario == 0 ? _s1GrabError(m) : _s3GrabError(m);
  }

  void _grab(Offset p) {
    final sc = _scene;
    if (!_lab.isLabActive || sc.drag != null || sc.busy) return;
    final key = _hitKey(p);
    if (key == null) return;
    final err = _grabError(key);
    if (err != null) {
      _error(err);
      return;
    }
    _Audio.play(_Sound.pickup);
    setState(() => sc.drag = key);
  }

  void _dragTo(Offset p) {
    final sc = _scene;
    final key = sc.drag;
    if (key == null) return;
    final q = Offset(p.dx.clamp(-40.0, 1040.0), p.dy.clamp(-40.0, 600.0));
    if (key == -1) {
      sc.tracer = q;
    } else {
      sc.mols[key].pos = q;
    }
  }

  void _release() {
    final sc = _scene;
    final key = sc.drag;
    if (key == null) return;
    setState(() => sc.drag = null);
    if (key == -1) {
      _sendTo(_placeAt(sc.tracer));
      return;
    }
    final m = sc.mols[key];
    setState(() {
      if (sc.scenario == 0) {
        _dropS1(m);
      } else {
        _dropS3(m);
      }
    });
  }

  void _onTapUp(TapUpDetails d) {
    final sc = _scene;
    final p = d.localPosition;
    if (!_lab.isLabActive || _complete) return;
    switch (sc.scenario) {
      case 0:
        if (sc.step == 1) {
          if (!sc.busy) _tapLungs(p);
          return;
        }
        final key = _hitKey(p);
        if (key == null || sc.busy) return;
        final err = _grabError(key);
        err == null ? _info('hint_drag') : _error(err);
      case 1:
        if (sc.busy) return;
        if (sc.step == 1) {
          if ((p - sc.tracer).distance < 44) {
            _error('e_start_heart');
          } else if (_heartPath.contains(p)) {
            _startHeart();
          }
          return;
        }
        if ((p - sc.tracer).distance < 44) {
          _info('hint_drag_cell');
          return;
        }
        final dest = _placeAt(p);
        if (dest != null) _sendTo(dest);
      default:
        if (sc.benchAt == null) {
          if (sc.reacted && sc.step == 3 && (p - _reactC).distance < 46) {
            _info('i_energy_used');
            return;
          }
          final key = _hitKey(p);
          if (key == null || sc.busy) return;
          final err = _grabError(key);
          err == null ? _info('hint_drag') : _error(err);
          return;
        }
        if (_tapA.contains(p)) {
          _pushPichkari();
        } else if (_tapB.contains(p)) {
          _blow();
        }
    }
  }

  // ----------------------------------------------------------- actions

  List<LabAction> _actions() {
    final sc = _scene;
    final st = sc.step;
    final busy = sc.busy;
    switch (sc.scenario) {
      case 0:
        if (st == 2 || st == 5) {
          return [
            LabAction(
              label: _t('btn_breathe_in'),
              icon: Icons.keyboard_double_arrow_down,
              color: const Color(0xFF0EA5E9),
              foreground: Colors.white,
              highlight: st == 2,
              enabled: !busy,
              silent: true,
              onTap: _breatheIn,
            ),
            LabAction(
              label: _t('btn_breathe_out'),
              icon: Icons.keyboard_double_arrow_up,
              color: _Colors.slate500,
              foreground: Colors.white,
              highlight: st == 5,
              enabled: !busy,
              silent: true,
              onTap: _breatheOut,
            ),
          ];
        }
      case 1:
        if (st == 1) {
          return [
            LabAction(
              label: _t('btn_start_heart'),
              icon: Icons.favorite,
              color: _Colors.rose600,
              foreground: Colors.white,
              highlight: true,
              silent: true,
              onTap: _startHeart,
            ),
          ];
        }
      default:
        if (st == 2) {
          return [
            LabAction(
              label: _t('btn_release_energy'),
              icon: Icons.bolt,
              color: _Colors.amber,
              highlight: true,
              enabled: !busy,
              silent: true,
              onTap: _react,
            ),
          ];
        }
        if (st == 4 || st == 5) {
          return [
            LabAction(
              label: _t('btn_push'),
              icon: Icons.vaccines,
              color: const Color(0xFF0EA5E9),
              foreground: Colors.white,
              highlight: st == 4,
              enabled: !busy,
              silent: true,
              onTap: _pushPichkari,
            ),
            LabAction(
              label: _t('btn_blow'),
              icon: Icons.air,
              color: _Colors.indigo600,
              foreground: Colors.white,
              highlight: st == 5,
              enabled: !busy,
              silent: true,
              onTap: _blow,
            ),
          ];
        }
        if (st == 6) {
          return [
            LabAction(
              label: _t('btn_compare'),
              icon: Icons.bar_chart,
              highlight: !sc.compared,
              enabled: !sc.compared,
              silent: true,
              onTap: _compare,
            ),
          ];
        }
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
        final inset = labOverlayInsets(context, _lab);
        final showCard = !_lab.isSidebarOpen && ((sc.scenario == 0 && sc.step >= 2) || sc.scenario == 1);
        return LabShell(
          controller: _lab,
          icon: Icons.air,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_opt'), _t('scen_2_opt'), _t('scen_3_opt')],
          scenarioIndex: sc.scenario,
          onScenarioChanged: _changeScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: sc.step,
          instruction: _complete ? _t('objective_complete') : null,
          actions: _actions(),
          sidebarExtraTitle: _t(switch (sc.scenario) {
            0 => 'card_gas',
            1 => 'card_path',
            _ => 'card_results',
          }),
          sidebarExtra: _dataCard(p, s * _lab.fontScale, framed: true),
          onReset: _fullReset,
          overlays: [
            if (showCard)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _overlayCard(p, s),
              ),
            if (sc.scenario == 2 && sc.step <= 3 && sc.benchAt == null)
              Positioned(
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Center(child: _equationStrip(p, s)),
              ),
            if (sc.scenario == 2 && sc.step == 5)
              Positioned(
                top: inset.top,
                left: inset.left,
                right: inset.right,
                child: Center(
                  child: LabReadout(
                    text: _f('blows_fmt', {'n': sc.blows}),
                    icon: Icons.air,
                    color: const Color(0xFF7DD3FC),
                    scale: s * 0.8,
                    fontSize: 18,
                  ),
                ),
              ),
            if (sc.scenario == 2 && sc.compared)
              Positioned(
                top: inset.top,
                right: inset.right,
                child: _comparisonCard(p, s),
              ),
          ],
          stage: LabStage(
            designSize: _design,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _ScenePanRecognizer: GestureRecognizerFactoryWithHandlers<_ScenePanRecognizer>(
                  _ScenePanRecognizer.new,
                  (r) => r
                    ..accepts = ((local) => _lab.isLabActive && _hitKey(local) != null)
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

  /// The scenario's data card for the sidebar (or the collapsed overlay).
  Widget _dataCard(LabPalette p, double f, {required bool framed}) {
    final body = switch (_scene.scenario) {
      0 => _gasBody(p, f),
      1 => _pathBody(p, f),
      _ => _resultsBody(p, f),
    };
    if (!framed) return body;
    return Container(
      padding: EdgeInsets.all(10 * f),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: body,
    );
  }

  Widget _overlayCard(LabPalette p, double s) {
    final title = _t(_scene.scenario == 0 ? 'card_gas' : 'card_path');
    return Container(
      width: 214 * s,
      padding: EdgeInsets.all(9 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: p.border),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(color: p.accent, fontSize: 9.5 * s, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          SizedBox(height: 6 * s),
          _dataCard(p, s * 0.92, framed: false),
        ],
      ),
    );
  }

  // Scenario 1 card: oxygen / carbon dioxide in the alveolus air and blood.
  Widget _gasBody(LabPalette p, double f) {
    final sc = _scene;
    final alvO2 = sc.breathedIn && !sc.breathedOut ? 6 - sc.o2Moved : 0;
    final alvCo2 = sc.breathedOut ? 0 : sc.co2Moved;
    final bloodO2 = sc.o2Moved;
    final bloodCo2 = 5 - sc.co2Moved;
    final o2Color = p.isDark ? _Colors.oxygen : const Color(0xFF0284C7);
    final co2Color = p.isDark ? _Colors.slate300 : _Colors.slate500;
    Widget section(String title, IconData icon, int o2, int co2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 13 * f, color: p.textMuted),
              SizedBox(width: 4 * f),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: p.textMuted, fontSize: 11 * f, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * f),
          _bar(p, f, _t('lbl_o2'), o2, 6, o2Color),
          SizedBox(height: 3 * f),
          _bar(p, f, _t('lbl_co2'), co2, 6, co2Color),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section(_t('card_air'), Icons.bubble_chart, alvO2, alvCo2),
        Divider(color: p.cardBorder, height: 14 * f),
        section(_t('card_blood'), Icons.water_drop, bloodO2, bloodCo2),
      ],
    );
  }

  /// "O2 ■■■■□□ 4" segmented level bar.
  Widget _bar(LabPalette p, double f, String label, int n, int max, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 34 * f,
          child: _chem(label, TextStyle(color: color, fontSize: 11.5 * f, fontWeight: FontWeight.w800)),
        ),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < max; i++)
                Expanded(
                  child: Container(
                    height: 9 * f,
                    margin: EdgeInsets.symmetric(horizontal: 1.2 * f),
                    decoration: BoxDecoration(
                      color: i < n ? color : p.cardBorder.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3 * f),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: 18 * f,
          child: Text(
            '$n',
            textAlign: TextAlign.right,
            style: TextStyle(color: p.textStrong, fontSize: 11.5 * f, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  // Scenario 2 card: the four legs of the journey and the blood's state.
  Widget _pathBody(LabPalette p, double f) {
    final sc = _scene;
    final richNow = sc.richTarget > 0.5;
    final stateColor = richNow ? (p.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)) : (p.isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 4; i++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.5 * f),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  sc.legsDone > i
                      ? Icons.check_circle
                      : (sc.heartOn && sc.step - 2 == i ? Icons.arrow_circle_right : Icons.circle_outlined),
                  size: 14 * f,
                  color: sc.legsDone > i
                      ? p.success
                      : (sc.heartOn && sc.step - 2 == i ? p.accent : p.textMuted),
                ),
                SizedBox(width: 6 * f),
                Expanded(
                  child: _arrowText(
                    _t('path_${i + 1}'),
                    TextStyle(
                      color: sc.legsDone > i ? p.textStrong : p.text,
                      fontSize: 11.5 * f,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Divider(color: p.cardBorder, height: 12 * f),
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('card_cell_now'),
          value: _t(richNow ? 'state_rich' : 'state_poor'),
          valueColor: stateColor,
        ),
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('card_heartbeat'),
          value: _t(sc.heartOn ? 'state_on' : 'state_off'),
          valueColor: sc.heartOn ? p.success : p.textMuted,
        ),
      ],
    );
  }

  // Scenario 3 card: the word equation, energy and the lime water results.
  Widget _resultsBody(LabPalette p, double f) {
    final sc = _scene;
    final b = sc.blows;
    final bValue = b == 0 ? _t('pending') : (b < 3 ? _t('lbl_cloudy') : _t('lbl_milky'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t('card_equation'),
          style: TextStyle(color: p.textMuted, fontSize: 11 * f, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 5 * f),
        _equationWrap(p, f),
        SizedBox(height: 6 * f),
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('card_energy'),
          value: sc.reacted ? '100%' : '0%',
          valueColor: sc.reacted ? _Colors.zslYellow : p.textMuted,
        ),
        Divider(color: p.cardBorder, height: 14 * f),
        Text(
          _t('card_lime_test'),
          style: TextStyle(color: p.textMuted, fontSize: 11 * f, fontWeight: FontWeight.w800),
        ),
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('lbl_tube_a'),
          value: sc.aDone ? _t('lbl_clear') : _t('pending'),
          valueColor: sc.aDone ? p.success : p.textMuted,
        ),
        LabInfoRow(
          palette: p,
          scale: f,
          label: _t('lbl_tube_b'),
          value: bValue,
          valueColor: b == 0 ? p.textMuted : p.textStrong,
        ),
      ],
    );
  }

  /// Glucose + Oxygen → Carbon dioxide + Water + Energy, each term lit once
  /// it is present in the cell.
  Widget _equationWrap(LabPalette p, double f, {bool all = false}) {
    final sc = _scene;
    final done = all || sc.reacted;
    final gIn = done || (sc.mols.isNotEmpty && sc.mols[0].moved);
    final oIn = done || (sc.mols.length > 1 && sc.mols[1].moved);
    Widget chip(String key, Color c, bool lit) {
      final fg = lit ? (p.isDark ? labShade(c, 0.35) : labShade(c, -0.35)) : p.textMuted;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 7 * f, vertical: 3 * f),
        decoration: BoxDecoration(
          color: lit ? c.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: lit ? c : p.cardBorder, width: 1.4),
        ),
        child: Text(
          _t(key),
          style: TextStyle(color: fg, fontSize: 11 * f, fontWeight: FontWeight.w800),
        ),
      );
    }

    Widget op(String s) => s == '→'
        ? Icon(Icons.arrow_forward_rounded, size: 16 * f, color: p.textStrong)
        : Text(
            s,
            style: TextStyle(color: p.textStrong, fontSize: 13 * f, fontWeight: FontWeight.w900),
          );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4 * f,
      runSpacing: 4 * f,
      children: [
        chip('lbl_glucose', _Colors.amber, gIn),
        op('+'),
        chip('lbl_oxygen', _Colors.oxygen, oIn),
        op('→'),
        chip('lbl_carbon_dioxide', _Colors.slate400, done),
        op('+'),
        chip('lbl_water', _Colors.water, done),
        op('+'),
        chip('lbl_energy', _Colors.zslYellow, done),
      ],
    );
  }

  Widget _equationStrip(LabPalette p, double s) {
    return Container(
      constraints: BoxConstraints(maxWidth: 520 * s),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.55)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 5))],
      ),
      child: _equationWrap(p, s * 0.95),
    );
  }

  /// The word equation of respiration, all terms lit (popups).
  Widget _equationBox() {
    return Builder(
      builder: (context) {
        final s = context.labScale;
        final p = _Theme.of(_lab.isDark);
        return Container(
          padding: EdgeInsets.all(10 * s),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _t('eq_title'),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 11 * s, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6 * s),
              _equationWrap(p, s, all: true),
            ],
          ),
        );
      },
    );
  }

  /// Inhaled vs exhaled air bars (textbook Fig. 9.13 values).
  Widget _comparisonCard(LabPalette p, double s) {
    final o2c = p.isDark ? _Colors.oxygen : const Color(0xFF0284C7);
    final co2c = p.isDark ? _Colors.slate300 : _Colors.slate500;
    Widget row(String who, double frac, String value, Color c) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2 * s),
        child: Row(
          children: [
            SizedBox(
              width: 74 * s,
              child: Text(
                who,
                maxLines: 2,
                style: TextStyle(color: p.text, fontSize: 9.5 * s, fontWeight: FontWeight.w700, height: 1.1),
              ),
            ),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: frac),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: math.max(v, 0.02),
                    child: Container(
                      height: 10 * s,
                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4 * s)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 46 * s,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(color: p.textStrong, fontSize: 10 * s, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
    }

    Widget gas(String title, Color c, List<Widget> rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _chem(title, TextStyle(color: c, fontSize: 11 * s, fontWeight: FontWeight.w800)),
            ...rows,
          ],
        );

    return Container(
      width: 250 * s,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: _Colors.zslYellow.withValues(alpha: 0.6)),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _t('cmp_title').toUpperCase(),
            style: TextStyle(color: p.accent, fontSize: 9.5 * s, fontWeight: FontWeight.w800, letterSpacing: 0.8),
          ),
          SizedBox(height: 6 * s),
          gas('${_t('lbl_oxygen')} (O_2)', o2c, [
            row(_t('cmp_inhaled'), 21 / 25, '~21%', o2c),
            row(_t('cmp_exhaled'), 16.5 / 25, '~16–17%', o2c),
          ]),
          SizedBox(height: 5 * s),
          gas('${_t('lbl_carbon_dioxide')} (CO_2)', co2c, [
            row(_t('cmp_inhaled'), 0.04 / 5, '~0.04%', co2c),
            row(_t('cmp_exhaled'), 4.5 / 5, '~4–5%', co2c),
          ]),
        ],
      ),
    );
  }

  /// Conclusion table for scenario 3 (rebuilt with the popup).
  Widget _comparisonTable() {
    return Builder(
      builder: (context) {
        final s = context.labScale;
        final p = _Theme.of(_lab.isDark);
        final head = TextStyle(color: p.textStrong, fontSize: 11 * s, fontWeight: FontWeight.w800, height: 1.2);
        final cell = TextStyle(color: p.text, fontSize: 11.5 * s, fontWeight: FontWeight.w600, height: 1.25);
        Widget c(String text, TextStyle st) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 5 * s),
              child: _chem(text, st, align: TextAlign.center),
            );
        return Table(
          border: TableBorder.all(color: p.cardBorder, borderRadius: BorderRadius.circular(8)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
          children: [
            TableRow(
              decoration: BoxDecoration(color: p.card),
              children: [c('', head), c(_t('cmp_inhaled'), head), c(_t('cmp_exhaled'), head)],
            ),
            TableRow(children: [
              c('${_t('lbl_oxygen')} (O_2)', head),
              c('~21%', cell),
              c('~16–17%', cell),
            ]),
            TableRow(children: [
              c('${_t('lbl_carbon_dioxide')} (CO_2)', head),
              c('~0.04%', cell),
              c('~4–5%', cell),
            ]),
            TableRow(children: [
              c(_t('lbl_lime_water'), head),
              c(_t('lbl_clear'), cell),
              c(_t('lbl_milky'), cell),
            ]),
          ],
        );
      },
    );
  }
}

// ============================================================ PAINTING

class _ScenePainter extends CustomPainter {
  _ScenePainter({
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
  final LabLang lang;
  final String Function(String key) tr;

  _Scene get sc => scene;
  double get t => scene.time;

  @override
  void paint(Canvas canvas, Size size) {
    switch (sc.scenario) {
      case 0:
        _paintS1(canvas, size);
      case 1:
        _paintS2(canvas, size);
      default:
        _paintS3(canvas, size);
    }
  }

  // ------------------------------------------------------------ shared

  void _bg(Canvas canvas, Size size, Color top, Color bottom) {
    canvas.drawRect(
      labBleed(size),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );
  }

  /// Runs [draw] in a layer with [alpha] (cross-fades between views).
  void _layer(Canvas canvas, Size size, double alpha, VoidCallback draw) {
    if (alpha <= 0.001) return;
    if (alpha >= 0.999) {
      canvas.save();
      draw();
      canvas.restore();
      return;
    }
    canvas.saveLayer(labBleed(size), Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    draw();
    canvas.restore();
  }

  void _label(Canvas canvas, String key, Offset at, {Alignment anchor = Alignment.center, double size = 14}) {
    if (!showLabels) return;
    labPill(canvas, tr(key), at, size: size, anchor: anchor);
  }

  /// Small tag under a molecule; `_2` marks become real subscripts.
  void _tag(Canvas canvas, String text, Offset at, {double size = 12}) {
    if (!showLabels) return;
    _richText(canvas, text, at, size: size, background: const Color(0xCC0F172A));
  }

  /// Draws [text] with chemical subscripts (see [_runs]) centred on
  /// [at] (or placed by [anchor]), optionally on a rounded chip.
  Rect _richText(
    Canvas canvas,
    String text,
    Offset at, {
    double size = 12,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w800,
    Color? background,
    Alignment anchor = Alignment.center,
  }) {
    final parts = <(TextPainter, bool)>[];
    var w = 0.0;
    var hasSub = false;
    for (final (s, sub) in _runs(text)) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontSize: sub ? size * 0.72 : size,
            color: color,
            fontWeight: weight,
            fontFamily: LabFont.active.family,
            fontFamilyFallback: LabFont.active.fallback,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      parts.add((tp, sub));
      w += tp.width;
      hasSub |= sub;
    }
    final pad = background != null ? const EdgeInsets.fromLTRB(6, 1, 6, 1) : EdgeInsets.zero;
    final h = size * (hasSub ? 1.32 : 1.2);
    final bw = w + pad.horizontal;
    final bh = h + pad.vertical;
    final left = at.dx - (anchor.x + 1) / 2 * bw;
    final top = at.dy - (anchor.y + 1) / 2 * bh;
    final rect = Rect.fromLTWH(left, top, bw, bh);
    if (background != null) {
      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(
        rr.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(rr, Paint()..color = background);
    }
    var x = left + pad.left;
    for (final (tp, sub) in parts) {
      tp.paint(canvas, Offset(x, top + pad.top + (sub ? size * 0.44 : 0)));
      x += tp.width;
    }
    return rect;
  }

  void _o2(Canvas canvas, Offset at, double phase, {double scale = 1, double alpha = 1}) {
    final a = 0.4 * math.sin(t * 0.9 + phase);
    final d = Offset(math.cos(a), math.sin(a)) * 10 * scale;
    labSphere(canvas, at - d, 12 * scale, _Colors.oxygen, outline: true, opacity: alpha);
    labSphere(canvas, at + d, 12 * scale, _Colors.oxygen, outline: true, opacity: alpha);
  }

  void _co2(Canvas canvas, Offset at, double phase, {double scale = 1, double alpha = 1}) {
    final a = 0.35 * math.sin(t * 0.8 + phase);
    final d = Offset(math.cos(a), math.sin(a)) * 19 * scale;
    labSphere(canvas, at - d, 10 * scale, _Colors.carbonO, outline: true, opacity: alpha);
    labSphere(canvas, at + d, 10 * scale, _Colors.carbonO, outline: true, opacity: alpha);
    labSphere(canvas, at, 12.5 * scale, _Colors.carbon, outline: true, opacity: alpha);
  }

  void _glucose(Canvas canvas, Offset at, double phase, {double scale = 1}) {
    final r = 22 * scale;
    final rot = 0.25 * math.sin(t * 0.7 + phase);
    Path hex(double rr) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = rot + i * math.pi / 3 + math.pi / 6;
        final q = at + Offset(math.cos(a), math.sin(a)) * rr;
        if (i == 0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      return path..close();
    }

    final outer = hex(r);
    canvas.drawPath(
      outer.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [labShade(_Colors.amber, 0.45), _Colors.amber, labShade(_Colors.amber, -0.35)],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: at, radius: r)),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.amber700,
    );
    canvas.drawPath(
      hex(r * 0.55),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _water(Canvas canvas, Offset at, {double scale = 1}) {
    final r = 14 * scale;
    final c = at + Offset(0, 0.3 * r);
    final path = Path()
      ..moveTo(at.dx, at.dy - 1.5 * r)
      ..quadraticBezierTo(at.dx + r * 1.05, c.dy - r * 0.5, at.dx + r, c.dy)
      ..arcToPoint(Offset(at.dx - r, c.dy), radius: Radius.circular(r))
      ..quadraticBezierTo(at.dx - r * 1.05, c.dy - r * 0.5, at.dx, at.dy - 1.5 * r)
      ..close();
    final rect = Rect.fromCircle(center: c, radius: r * 1.5);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.2),
          colors: [labShade(_Colors.water, 0.55), _Colors.water, labShade(_Colors.water, -0.35)],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF1D4ED8),
    );
  }

  /// Red blood cell (biconcave disc seen at an angle).
  void _rbc(Canvas canvas, Offset at, double r, Color color, double angle, {double alpha = 1}) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    final rect = Rect.fromCenter(center: Offset.zero, width: 2 * r, height: 1.35 * r);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            labShade(color, -0.3).withValues(alpha: alpha),
            labShade(color, 0.12).withValues(alpha: alpha),
            labShade(color, -0.4).withValues(alpha: alpha),
          ],
          stops: const [0.15, 0.6, 1],
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-0.25 * r, -0.28 * r), width: 0.8 * r, height: 0.3 * r),
      Paint()..color = Colors.white.withValues(alpha: 0.3 * alpha),
    );
    canvas.restore();
  }

  /// Pulsing yellow ring around something the learner should act on.
  void _hint(Canvas canvas, Offset at, double r) {
    final k = 0.5 + 0.5 * math.sin(t * 4);
    canvas.drawCircle(
      at,
      r + 4 * k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = _Colors.zslYellow.withValues(alpha: 0.45 + 0.4 * k),
    );
  }

  Path _boltPath(Offset c, double h) {
    const pts = [
      Offset(0.06, -0.5), Offset(-0.26, 0.06), Offset(-0.03, 0.06), Offset(-0.13, 0.5), //
      Offset(0.27, -0.1), Offset(0.04, -0.1), Offset(0.2, -0.5),
    ];
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final q = c + pts[i] * h;
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    return path..close();
  }

  // ======================================================= SCENARIO 1

  void _paintS1(Canvas canvas, Size size) {
    final z = sc.zoom;
    if (z < 1) {
      final e = Curves.easeInCubic.transform(z);
      _layer(canvas, size, 1 - _smooth(0.45, 1.0, z), () {
        canvas.translate(_target.dx, _target.dy);
        canvas.scale(1 + 8 * e);
        canvas.translate(-_target.dx, -_target.dy);
        _paintLungsView(canvas, size);
      });
    }
    if (z > 0.45) {
      final e = Curves.easeOutCubic.transform(_smooth(0.45, 1.0, z));
      _layer(canvas, size, e, () {
        canvas.translate(_alvC.dx, _alvC.dy);
        canvas.scale(0.6 + 0.4 * e);
        canvas.translate(-_alvC.dx, -_alvC.dy);
        _paintAlveolusView(canvas, size);
      });
    }
  }

  void _drawTrachea(Canvas canvas) {
    const tube = Rect.fromLTRB(482, 16, 518, 214);
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [_Colors.rose400, Color(0xFFFFE4E6), _Colors.rose300, _Colors.rose600],
        stops: [0, 0.35, 0.7, 1],
      ).createShader(tube);
    // Bronchi into both lungs.
    final bronchus = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 22
      ..color = _Colors.rose300;
    canvas.drawLine(const Offset(500, 204), const Offset(462, 252), bronchus);
    canvas.drawLine(const Offset(500, 204), const Offset(538, 252), bronchus);
    canvas.drawRRect(RRect.fromRectAndRadius(tube, const Radius.circular(12)), fill);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.75);
    for (var y = 28.0; y < 206; y += 13) {
      canvas.drawArc(Rect.fromCenter(center: Offset(500, y), width: 34, height: 9), 0.15, math.pi - 0.3, false, ring);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(tube, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.rose700.withValues(alpha: 0.6),
    );
  }

  void _drawLungs(Canvas canvas, {bool detail = true}) {
    for (final right in [true, false]) {
      final path = right ? _lungRightPath : _lungLeftPath;
      final b = path.getBounds();
      canvas.drawPath(
        path.shift(const Offset(0, 8)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(right ? -0.25 : 0.25, -0.45),
            radius: 1.0,
            colors: const [_Colors.rose200, _Colors.rose400, _Colors.rose700],
            stops: const [0, 0.55, 1],
          ).createShader(b),
      );
      canvas.save();
      canvas.clipPath(path);
      // Lobe fissure.
      final fissure = Path()
        ..moveTo(right ? b.left : b.right, b.top + b.height * 0.5)
        ..quadraticBezierTo(b.center.dx, b.top + b.height * 0.42, right ? b.right : b.left, b.top + b.height * 0.66);
      canvas.drawPath(
        fissure,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _Colors.rose800.withValues(alpha: 0.45),
      );
      if (detail) {
        final under = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = _Colors.rose700.withValues(alpha: 0.55);
        final over = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFF1F2).withValues(alpha: 0.9);
        for (final s in _tree.segs) {
          canvas.drawLine(s.a, s.b, under..strokeWidth = s.w + 2.5);
        }
        for (final s in _tree.segs) {
          canvas.drawLine(s.a, s.b, over..strokeWidth = s.w);
        }
        final sac = Paint()..color = _Colors.rose200;
        final sacEdge = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _Colors.rose700;
        for (final tip in _tree.tips) {
          for (var k = 0; k < 3; k++) {
            final c = tip + Offset(math.cos(k * 2.1) * 5, math.sin(k * 2.1) * 5);
            canvas.drawCircle(c, 4.5, sac);
            canvas.drawCircle(c, 4.5, sacEdge);
          }
        }
      }
      canvas.restore();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _Colors.rose800,
      );
      // Glossy highlight.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(right ? b.left + b.width * 0.38 : b.right - b.width * 0.38, b.top + b.height * 0.22),
          width: b.width * 0.32,
          height: b.height * 0.16,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  void _paintLungsView(Canvas canvas, Size size) {
    _bg(
      canvas,
      size,
      isDark ? const Color(0xFF2A1424) : const Color(0xFFFFF1F2),
      isDark ? _Colors.slate900 : _Colors.slate100,
    );
    labGlow(canvas, _lungC, 360, isDark ? const Color(0x22F43F5E) : const Color(0x14F43F5E));
    final k = 1 + 0.018 * math.sin(t * 1.5);
    canvas.save();
    canvas.translate(_lungC.dx, _lungC.dy);
    canvas.scale(k);
    canvas.translate(-_lungC.dx, -_lungC.dy);
    // Dome-shaped diaphragm below the lungs.
    final dome = Path()
      ..moveTo(214, 528)
      ..quadraticBezierTo(500, 404, 786, 528);
    canvas.drawPath(
      dome,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 18
        ..color = (isDark ? const Color(0xFF9D3B5C) : const Color(0xFFE79AB0)).withValues(alpha: 0.8),
    );
    _drawTrachea(canvas);
    _drawLungs(canvas);

    // The bunch of alveoli to zoom into, at the end of its own branch.
    var near = _tree.tips.first;
    for (final tip in _tree.tips) {
      if ((tip - _target).distance < (near - _target).distance) near = tip;
    }
    canvas.save();
    canvas.clipPath(_lungRightPath);
    canvas.drawLine(
      near,
      _target,
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFF1F2),
    );
    canvas.restore();
    final pulse = 0.5 + 0.5 * math.sin(t * 3.5);
    labGlow(canvas, _target, 64, _Colors.zslYellow, intensity: 0.35 + 0.3 * pulse);
    for (var i = 0; i < 7; i++) {
      final c = i == 0 ? _target : _target + Offset(math.cos(i * 1.05) * 13, math.sin(i * 1.05) * 13);
      labSphere(canvas, c, 8.5, _Colors.rose300, highlight: 0.5, outline: true);
    }
    canvas.drawCircle(
      _target,
      30 + 5 * pulse,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _Colors.zslYellow.withValues(alpha: 0.6 + 0.35 * pulse),
    );
    canvas.restore();

    if (sc.zoomAt == null) {
      _label(canvas, 'lbl_windpipe', const Offset(530, 62), anchor: Alignment.centerLeft);
      _label(canvas, 'lbl_right_lung', const Offset(262, 196), anchor: Alignment.centerRight);
      _label(canvas, 'lbl_left_lung', const Offset(738, 196), anchor: Alignment.centerLeft);
      _label(canvas, 'lbl_alveoli', _target + const Offset(-40, -34), anchor: Alignment.centerRight);
      labText(
        canvas,
        tr('lbl_tap_zoom'),
        _target + const Offset(0, 46),
        anchor: Alignment.topCenter,
        size: 13,
        weight: FontWeight.w800,
        color: _Colors.slate900,
        background: _Colors.zslYellow,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      );
    }
  }

  void _paintAlveolusView(Canvas canvas, Size size) {
    _bg(
      canvas,
      size,
      isDark ? const Color(0xFF2A0F1F) : const Color(0xFFFFE4E6),
      isDark ? const Color(0xFF12080F) : const Color(0xFFFFF1F2),
    );
    final r = 140 + 10 * sc.inflate + 2.5 * math.sin(t * 1.5);
    _drawAirways(canvas, r);
    _drawCapillary(canvas);
    _drawAirFlow(canvas);

    // Structure labels.
    _label(canvas, 'lbl_alveolus', const Offset(664, 214), anchor: Alignment.centerLeft);
    _label(canvas, 'lbl_from_body', const Offset(150, 248));
    _label(canvas, 'lbl_to_heart', const Offset(845, 248));
    _label(canvas, 'lbl_rbc', const Offset(200, 368));
    _label(canvas, 'lbl_blood_vessel', const Offset(500, 466));
    if (showLabels) {
      final wall = _alvC + Offset(math.cos(0.9), math.sin(0.9)) * r;
      labDashedLine(
        canvas,
        const Offset(690, 398),
        wall,
        Paint()
          ..strokeWidth = 1.6
          ..color = isDark ? _Colors.slate300 : _Colors.slate700,
        dash: 5,
        gap: 4,
      );
      canvas.drawCircle(wall, 3.5, Paint()..color = isDark ? _Colors.slate200 : _Colors.slate700);
      _label(canvas, 'lbl_thin_wall', const Offset(690, 398), anchor: Alignment.centerLeft);
    }

    _gasLegend(canvas);
    _drawS1Molecules(canvas);
  }

  /// Neighbouring air sacs of the same bunch (centre, radius) and the small
  /// airways joining them.
  static const List<(Offset, double)> _sacs = [
    (Offset(200, 178), 58.0), (Offset(806, 174), 60.0), //
    (Offset(322, 112), 80.0), (Offset(682, 106), 84.0),
  ];
  static const List<(Offset, Offset)> _ducts = [
    (Offset(500, 30), Offset(322, 112)), (Offset(500, 30), Offset(682, 106)), //
    (Offset(322, 112), Offset(200, 178)), (Offset(682, 106), Offset(806, 174)),
  ];

  /// Airway (bronchiole), neighbouring sacs wrapped in fine blood vessels
  /// and the main alveolus.
  void _drawAirways(Canvas canvas, double r) {
    final wallColor = isDark ? const Color(0xFFE25C86) : _Colors.rose400;
    final wall = Paint()..color = wallColor;
    final wallStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = wallColor;
    // Walls (one connected shape).
    canvas.drawLine(const Offset(500, -400), const Offset(500, 96), wallStroke..strokeWidth = 74);
    for (final (a, b) in _ducts) {
      canvas.drawLine(a, b, wallStroke..strokeWidth = 44);
    }
    for (final (c, nr) in _sacs) {
      canvas.drawCircle(c, nr + 5, wall);
    }
    canvas.drawCircle(_alvC, r + 5, wall);

    // Air inside.
    final airIn = isDark ? const Color(0xFF6A2A4C) : Colors.white;
    final airOut = isDark ? const Color(0xFF3E1531) : const Color(0xFFFFE4E6);
    Paint air(Offset c, double rr) => Paint()
      ..shader = RadialGradient(colors: [airIn, airOut], stops: const [0.1, 1])
          .createShader(Rect.fromCircle(center: c.translate(-rr * 0.2, -rr * 0.25), radius: rr * 1.2));
    final airStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = airOut;
    canvas.drawLine(const Offset(500, -400), const Offset(500, 100), airStroke..strokeWidth = 60);
    for (final (a, b) in _ducts) {
      canvas.drawLine(a, b, airStroke..strokeWidth = 30);
    }
    for (final (c, nr) in _sacs) {
      canvas.drawCircle(c, nr - 2, air(c, nr));
    }
    // Fine blood vessels wrapped around each neighbouring sac.
    final mesh = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final red = (isDark ? const Color(0xFFE0475A) : const Color(0xFFEF6A7A)).withValues(alpha: 0.85);
    final blue = (isDark ? const Color(0xFF6D6FD9) : const Color(0xFF8B8FF0)).withValues(alpha: 0.85);
    for (final (c, nr) in _sacs) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: nr + 6)));
      canvas.drawArc(Rect.fromCircle(center: c, radius: nr + 1), 0.15 * math.pi, 0.7 * math.pi, false,
          mesh..strokeWidth = 5..color = red);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - nr, c.dy + nr * 0.05)
          ..quadraticBezierTo(c.dx, c.dy + nr * 0.75, c.dx + nr, c.dy + nr * 0.05),
        mesh..strokeWidth = 4..color = blue,
      );
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - nr * 0.75, c.dy - nr * 0.7)
          ..quadraticBezierTo(c.dx + nr * 0.15, c.dy - nr * 0.05, c.dx + nr * 0.45, c.dy + nr * 0.9),
        mesh..strokeWidth = 3.5..color = red,
      );
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + nr * 0.8, c.dy - nr * 0.6)
          ..quadraticBezierTo(c.dx + nr * 0.1, c.dy - nr * 0.2, c.dx - nr * 0.35, c.dy + nr * 0.92),
        mesh..strokeWidth = 3..color = blue,
      );
      canvas.restore();
    }
    canvas.drawCircle(_alvC, r - 2, air(_alvC, r));
    // Soft highlight: the sac is a thin, balloon-like bag of air.
    canvas.drawOval(
      Rect.fromCenter(center: _alvC + Offset(-r * 0.38, -r * 0.42), width: r * 0.62, height: r * 0.3),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.09 : 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Main alveolus wall drawn again so it stands out from its neighbours.
    canvas.drawCircle(
      _alvC,
      r + 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = wallColor,
    );
    canvas.drawCircle(
      _alvC,
      r - 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _Colors.rose200.withValues(alpha: 0.7),
    );
    // Opening into the airway.
    canvas.drawRect(Rect.fromLTRB(471, _alvC.dy - r - 8, 529, _alvC.dy - r + 6), Paint()..color = airOut);
    // Wall cells (nuclei) along the alveolus.
    final nucleus = Paint()..color = _Colors.rose800.withValues(alpha: isDark ? 0.75 : 0.55);
    for (var i = 0; i < 9; i++) {
      final a = -0.9 + i * 0.52;
      if ((a + math.pi / 2).abs() < 0.35 || (a - 3 * math.pi / 2).abs() < 0.35) continue;
      final q = _alvC + Offset(math.cos(a), math.sin(a)) * (r + 1.5);
      canvas.save();
      canvas.translate(q.dx, q.dy);
      canvas.rotate(a + math.pi / 2);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 13, height: 5), nucleus);
      canvas.restore();
    }
  }

  /// Key for the two gases (top-left of the alveolus close-up).
  void _gasLegend(Canvas canvas) {
    const box = Rect.fromLTRB(16, 16, 236, 88);
    final rr = RRect.fromRectAndRadius(box, const Radius.circular(12));
    canvas.drawRRect(rr, Paint()..color = isDark ? const Color(0xCC0F172A) : const Color(0xE6FFFFFF));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = isDark ? const Color(0x33FFFFFF) : const Color(0x22000000),
    );
    final text = isDark ? _Colors.slate200 : _Colors.slate800;
    _o2(canvas, const Offset(46, 36), 0, scale: 0.62);
    _co2(canvas, const Offset(46, 68), 0, scale: 0.62);
    _richText(canvas, 'O_2  ${tr('lbl_oxygen')}', const Offset(76, 36),
        anchor: Alignment.centerLeft, size: 14, color: text, weight: FontWeight.w700);
    _richText(canvas, 'CO_2  ${tr('lbl_carbon_dioxide')}', const Offset(76, 68),
        anchor: Alignment.centerLeft, size: 14, color: text, weight: FontWeight.w700);
  }

  void _drawCapillary(Canvas canvas) {
    final wallColor = isDark ? const Color(0xFFB24A72) : const Color(0xFFF9A8D4);
    canvas.drawPath(
      _capPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _capHalf * 2 + 10
        ..strokeJoin = StrokeJoin.round
        ..color = wallColor,
    );
    final poor = isDark ? const Color(0xFF2B2F6B) : const Color(0xFFBFC8F5);
    final rich = isDark ? const Color(0xFF6B1B26) : const Color(0xFFFBC4C4);
    final mixed = Color.lerp(poor, rich, sc.oxygenation)!;
    canvas.drawPath(
      _capPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _capHalf * 2
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(
          colors: [poor, poor, mixed, mixed],
          stops: const [0, 0.4, 0.62, 1],
        ).createShader(const Rect.fromLTRB(-100, 0, 1100, 1)),
    );
    // Red blood cells flowing from the body (left) towards the heart (right).
    final len = _capFlow.length;
    const n = 16;
    for (var i = 0; i < n; i++) {
      final d = (t * 46 + i * len / n) % len;
      final tan = _capFlow.getTangentForOffset(d);
      if (tan == null) continue;
      final off = (i.isEven ? 1 : -1) * 13.0;
      final nrm = Offset(math.sin(tan.angle), math.cos(tan.angle));
      final q = tan.position + nrm * off;
      final f = _smooth(380, 640, q.dx) * sc.oxygenation;
      final col = Color.lerp(_Colors.poor, _Colors.rich, f)!;
      _rbc(canvas, q, 12.5, col, -tan.angle);
    }
    // Flow direction chevrons.
    for (final x in [70.0, 930.0]) {
      final a = _capAngle(x);
      final c = Offset(x, _capY(x));
      final u = Offset(math.cos(a), math.sin(a));
      labArrow(canvas, c - u * 16, c + u * 16, color: Colors.white.withValues(alpha: 0.85), width: 3, head: 10);
    }
  }

  void _drawAirFlow(Canvas canvas) {
    final age = t - sc.breathAt;
    if (age < 0 || age > 1.9) return;
    final a = 1 - _smooth(1.3, 1.9, age);
    final color = (sc.breathIn ? _Colors.oxygen : _Colors.slate400).withValues(alpha: a);
    for (final x in [478.0, 522.0]) {
      if (sc.breathIn) {
        labWavyArrow(canvas, Offset(x, -10), Offset(x, 64), t, color: color, amp: 4);
      } else {
        labWavyArrow(canvas, Offset(x, 64), Offset(x, -10), t, color: color, amp: 4);
      }
    }
    if (showLabels) {
      labPill(canvas, tr(sc.breathIn ? 'lbl_air_in' : 'lbl_air_out'), const Offset(548, 26),
          anchor: Alignment.centerLeft, opacity: a);
    }
  }

  void _drawS1Molecules(Canvas canvas) {
    final st = sc.step;
    for (var i = 0; i < sc.mols.length; i++) {
      if (sc.drag == i) continue;
      _drawS1Mol(canvas, i, st);
    }
    final d = sc.drag;
    if (d != null && d >= 0) {
      final m = sc.mols[d];
      labGlow(canvas, m.pos, 46, m.kind == _Kind.o2 ? _Colors.oxygen : _Colors.slate300, intensity: 0.5);
      _drawS1Mol(canvas, d, st);
    }
  }

  void _drawS1Mol(Canvas canvas, int i, int st) {
    final m = sc.mols[i];
    if (!m.visible) return;
    final dragged = sc.drag == i;
    final wob = dragged ? Offset.zero : Offset(math.sin(t * 1.3 + m.phase) * 3, math.cos(t * 1.1 + m.phase) * 3);
    final q = m.pos + wob;
    final active = !sc.busy && !m.moved && ((st == 3 && m.kind == _Kind.o2) || (st == 4 && m.kind == _Kind.co2));
    if (active && !dragged) _hint(canvas, q, m.kind == _Kind.o2 ? 27 : 33);
    if (m.kind == _Kind.o2) {
      _o2(canvas, q, m.phase, scale: dragged ? 1.15 : 1);
      _tag(canvas, tr('lbl_o2'), q + const Offset(0, 22));
    } else {
      _co2(canvas, q, m.phase, scale: dragged ? 1.15 : 1);
      _tag(canvas, tr('lbl_co2'), q + const Offset(0, 22));
    }
  }

  // ======================================================= SCENARIO 2

  void _paintS2(Canvas canvas, Size size) {
    _bg(
      canvas,
      size,
      isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      isDark ? const Color(0xFF0B1120) : _Colors.slate200,
    );
    labGlow(canvas, _heartC, 280, isDark ? const Color(0x26F43F5E) : const Color(0x1AF43F5E));
    final on = sc.heartOn;
    final since = t - sc.heartAt;
    final beat = on ? _beat(since) : 0.0;
    final flow = on ? since * 58 : 0.0;

    _vessel(canvas, _vcPath, _Colors.poor);
    _vessel(canvas, _aoPath, _Colors.rich);
    _drawBodyCells(canvas);
    _gradientVessel(canvas, _bodyCapPath, _Colors.rich, _Colors.poor, const Rect.fromLTRB(614, 0, 386, 1), width: 11);
    _vessel(canvas, _paPath, _Colors.poor);
    _vessel(canvas, _pvPath, _Colors.rich);
    canvas.save();
    canvas.translate(500, 110);
    canvas.scale(0.54, 0.42);
    canvas.translate(-_lungC.dx, -_lungC.dy);
    _drawTrachea(canvas);
    _drawLungs(canvas, detail: false);
    canvas.restore();
    _gradientVessel(canvas, _lungCapPath, _Colors.poor, _Colors.rich, const Rect.fromLTRB(412, 0, 588, 1), width: 11);
    _drawHeart(canvas, beat);

    // Blood flowing through every vessel.
    if (on) {
      _flowDots(canvas, _vcM, flow, (_) => _Colors.poor);
      _flowDots(canvas, _aoM, flow, (_) => _Colors.rich);
      _flowDots(canvas, _paM, flow, (_) => _Colors.poor);
      _flowDots(canvas, _pvM, flow, (_) => _Colors.rich);
      _flowDots(canvas, _lungCapM, flow, (f) => Color.lerp(_Colors.poor, _Colors.rich, f)!, r: 4.5);
      _flowDots(canvas, _bodyCapM, flow, (f) => Color.lerp(_Colors.rich, _Colors.poor, f)!, r: 4.5);
    }
    for (final m in [_vcM, _aoM, _paM, _pvM]) {
      final tan = m.getTangentForOffset(m.length * 0.55);
      if (tan == null) continue;
      final u = Offset(math.cos(tan.angle), -math.sin(tan.angle));
      labArrow(canvas, tan.position - u * 9, tan.position + u * 9, color: Colors.white, width: 3, head: 9);
    }
    _drawRoute(canvas);
    _drawExchange(canvas);

    _label(canvas, 'lbl_lungs', const Offset(366, 66), anchor: Alignment.centerRight);
    _label(canvas, 'lbl_heart', const Offset(624, 232), anchor: Alignment.centerLeft);
    _label(canvas, 'lbl_right_side', const Offset(384, 338), anchor: Alignment.centerRight);
    _label(canvas, 'lbl_left_side', const Offset(616, 338), anchor: Alignment.centerLeft);
    _label(canvas, 'lbl_body_cells', const Offset(606, 430), anchor: Alignment.centerLeft);
    _drawLegend(canvas);
    _drawTracer(canvas);
  }

  void _vessel(Canvas canvas, Path path, Color color, {double width = 17}) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, p..strokeWidth = width + 6..color = labShade(color, -0.5));
    canvas.drawPath(path, p..strokeWidth = width..color = color);
    canvas.drawPath(path, p..strokeWidth = width * 0.3..color = Colors.white.withValues(alpha: 0.3));
  }

  void _gradientVessel(Canvas canvas, Path path, Color from, Color to, Rect along, {double width = 17}) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, p..strokeWidth = width + 5..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawPath(
      path,
      p
        ..strokeWidth = width
        ..shader = LinearGradient(colors: [from, to]).createShader(along),
    );
  }

  void _flowDots(Canvas canvas, PathMetric metric, double flow, Color Function(double f) color, {double r = 5.5}) {
    final len = metric.length;
    const gap = 30.0;
    final n = (len / gap).floor();
    for (var i = 0; i < n; i++) {
      final d = (flow + i * gap) % len;
      final tan = metric.getTangentForOffset(d);
      if (tan == null) continue;
      final f = d / len;
      _rbc(canvas, tan.position, r, color(f), -tan.angle);
    }
  }

  void _drawHeart(Canvas canvas, double beat) {
    canvas.save();
    canvas.translate(_heartC.dx, _heartC.dy);
    canvas.scale(1 + 0.05 * beat);
    canvas.translate(-_heartC.dx, -_heartC.dy);
    final b = _heartPath.getBounds();
    canvas.drawPath(
      _heartPath.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawPath(
      _heartPath,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [_Colors.rose300, _Colors.rose600, Color(0xFF7F1D3A)],
          stops: [0, 0.55, 1],
        ).createShader(b),
    );
    Paint chamber(Rect r, Color c) => Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [labShade(c, 0.3), c, labShade(c, -0.35)],
        stops: const [0, 0.55, 1],
      ).createShader(r);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFE4E6).withValues(alpha: 0.85);
    final ra = Rect.fromCenter(center: const Offset(452, 266), width: 66, height: 50);
    final la = Rect.fromCenter(center: const Offset(548, 266), width: 66, height: 50);
    canvas.drawOval(ra, chamber(ra, _Colors.poor));
    canvas.drawOval(ra, edge);
    canvas.drawOval(la, chamber(la, _Colors.rich));
    canvas.drawOval(la, edge);
    canvas.drawPath(_rvPath, chamber(_rvPath.getBounds(), _Colors.poor));
    canvas.drawPath(_rvPath, edge);
    canvas.drawPath(_lvPath, chamber(_lvPath.getBounds(), _Colors.rich));
    canvas.drawPath(_lvPath, edge);
    // Valves between the upper and lower chambers.
    final valve = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (final x in [452.0, 548.0]) {
      final open = 3 * beat;
      canvas.drawPath(
        Path()
          ..moveTo(x - 14, 292)
          ..lineTo(x - 2 - open, 304)
          ..lineTo(x - 6, 292)
          ..close(),
        valve,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x + 14, 292)
          ..lineTo(x + 2 + open, 304)
          ..lineTo(x + 6, 292)
          ..close(),
        valve,
      );
    }
    canvas.drawPath(
      _heartPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF6B1230),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(440, 236), width: 46, height: 18),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();
  }

  void _drawBodyCells(Canvas canvas) {
    for (final c in _bodyCells) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3 + 0.2;
        final q = c + Offset(math.cos(a), math.sin(a)) * 25;
        if (i == 0) {
          path.moveTo(q.dx, q.dy);
        } else {
          path.lineTo(q.dx, q.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [Color(0xFFFFEDD5), Color(0xFFFDBA74), Color(0xFFEA580C)],
            stops: [0, 0.6, 1],
          ).createShader(Rect.fromCircle(center: c, radius: 26)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeJoin = StrokeJoin.round
          ..color = _Colors.orange700,
      );
      labSphere(canvas, c + const Offset(2, 1), 7, _Colors.violet, highlight: 0.4);
    }
  }

  /// Bright pulse along the vessel the blood cell just travelled.
  void _drawRoute(Canvas canvas) {
    final age = t - sc.routeAt;
    if (sc.route < 0 || age < 0 || age > 1.6) return;
    final m = [_pvM, _aoM, _vcM, _paM][sc.route];
    final k = Curves.easeInOut.transform((age / 1.0).clamp(0.0, 1.0));
    final fade = 1 - _smooth(1.0, 1.6, age);
    canvas.drawPath(
      m.extractPath(0, m.length * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7
        ..color = _Colors.zslYellow.withValues(alpha: 0.85 * fade),
    );
    final tan = m.getTangentForOffset(m.length * k);
    if (tan != null) labGlow(canvas, tan.position, 26, _Colors.zslYellow, intensity: fade);
  }

  /// O₂ / CO₂ swapped between the blood cell and the cells or lungs.
  void _drawExchange(Canvas canvas) {
    final e = (t - sc.exchangeAt) / 1.5;
    if (e < 0 || e > 1) return;
    final k = Curves.easeInOut.transform(e);
    final a = math.sin(e * math.pi).clamp(0.0, 1.0);
    final cell = sc.tracer;
    for (var i = 0; i < 3; i++) {
      if (sc.exchangeInLungs) {
        final lungSpot = Offset(440 + i * 60.0, 70 + (i.isOdd ? 20 : 0));
        _co2(canvas, Offset.lerp(cell, lungSpot + const Offset(0, -30), k)!, i.toDouble(), scale: 0.6, alpha: a);
        _o2(canvas, Offset.lerp(lungSpot, cell + Offset((i - 1) * 16.0, 0), k)!, i.toDouble(), scale: 0.6, alpha: a);
      } else {
        final out = _bodyCells[1 + i * 2];
        final into = _bodyCells[2 + i * 2 > 6 ? 0 : 2 + i * 2];
        _o2(canvas, Offset.lerp(cell, out, k)!, i.toDouble(), scale: 0.6, alpha: a);
        _co2(canvas, Offset.lerp(into, cell + Offset((i - 1) * 16.0, 0), k)!, i.toDouble(), scale: 0.6, alpha: a);
      }
    }
  }

  void _drawLegend(Canvas canvas) {
    const box = Rect.fromLTRB(16, 16, 250, 84);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(12)),
      Paint()..color = isDark ? const Color(0xCC0F172A) : const Color(0xE6FFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = isDark ? const Color(0x33FFFFFF) : const Color(0x22000000),
    );
    final text = isDark ? _Colors.slate200 : _Colors.slate800;
    for (final (i, c, key) in [(0, _Colors.rich, 'lbl_rich'), (1, _Colors.poor, 'lbl_poor')]) {
      final y = 34.0 + i * 32;
      _rbc(canvas, Offset(38, y), 10, c, 0);
      labText(canvas, tr(key), Offset(58, y), anchor: Alignment.centerLeft, size: 14, weight: FontWeight.w700, color: text);
    }
  }

  void _drawTracer(Canvas canvas) {
    final c = sc.tracer;
    final col = Color.lerp(_Colors.poor, _Colors.rich, sc.rich.clamp(0.0, 1.0))!;
    final waiting = sc.heartOn && !sc.busy && sc.step >= 2 && sc.step <= 5;
    labGlow(canvas, c, 50, col, intensity: 0.55);
    if (waiting && sc.drag != -1) _hint(canvas, c, 32);
    canvas.drawCircle(c, 27, Paint()..color = Colors.white.withValues(alpha: 0.9));
    _rbc(canvas, c, 22, col, 0);
    // Oxygen it carries.
    final o = sc.rich.clamp(0.0, 1.0);
    if (o > 0.05) {
      for (var i = 0; i < 3; i++) {
        final a = t * 1.5 + i * 2.1;
        labSphere(canvas, c + Offset(math.cos(a), math.sin(a)) * 28, 5, _Colors.oxygen, opacity: o);
      }
    }
    _label(canvas, 'lbl_blood_cell', c + const Offset(0, -44), size: 12.5);
  }

  // ======================================================= SCENARIO 3

  void _paintS3(Canvas canvas, Size size) {
    final b = sc.bench;
    if (b < 1) _layer(canvas, size, 1 - b, () => _paintCellView(canvas, size));
    if (b > 0) _layer(canvas, size, b, () => _paintBench(canvas, size));
  }

  void _paintCellView(Canvas canvas, Size size) {
    _bg(
      canvas,
      size,
      isDark ? const Color(0xFF1F1612) : const Color(0xFFFFF7ED),
      isDark ? _Colors.slate900 : _Colors.slate100,
    );
    _drawVesselS3(canvas, size);
    _drawCell(canvas);
    _drawEnergyMeter(canvas);
    _drawReaction(canvas);

    _label(canvas, 'lbl_cell', const Offset(232, 70), anchor: Alignment.centerRight);
    _label(canvas, 'lbl_nucleus', _nucC + const Offset(0, 74));
    _label(canvas, 'lbl_cytoplasm', const Offset(450, 340));
    _label(canvas, 'lbl_blood_vessel', const Offset(120, 400));

    for (var i = 0; i < sc.mols.length; i++) {
      if (sc.drag != i) _drawS3Mol(canvas, i);
    }
    final d = sc.drag;
    if (d != null && d >= 0) {
      labGlow(canvas, sc.mols[d].pos, 50, _Colors.zslYellow, intensity: 0.4);
      _drawS3Mol(canvas, d);
    }
  }

  void _drawVesselS3(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    final wall = Rect.fromLTRB(bleed.left, _vesY - _vesHalf - 6, bleed.right, _vesY + _vesHalf + 6);
    canvas.drawRect(wall, Paint()..color = isDark ? const Color(0xFFB24A72) : const Color(0xFFF9A8D4));
    final plasma = Rect.fromLTRB(bleed.left, _vesY - _vesHalf, bleed.right, _vesY + _vesHalf);
    canvas.drawRect(plasma, Paint()..color = isDark ? const Color(0xFF5A1A26) : const Color(0xFFFECACA));
    for (var i = 0; i < 16; i++) {
      final x = (t * 40 + i * 76) % 1216 - 108;
      final y = _vesY + (i.isEven ? -14 : 14) + math.sin(t + i) * 3;
      _rbc(canvas, Offset(x, y), 11, _Colors.rich, 0.15 * math.sin(t * 0.8 + i));
    }
    for (final x in [60.0, 940.0]) {
      labArrow(canvas, Offset(x - 16, _vesY), Offset(x + 16, _vesY), color: Colors.white.withValues(alpha: 0.85), head: 10);
    }
  }

  void _drawCell(Canvas canvas) {
    final path = Path();
    for (var i = 0; i <= 90; i++) {
      final a = i / 90 * 2 * math.pi;
      final k = 1 + 0.035 * math.sin(3 * a + t * 0.6) + 0.022 * math.sin(5 * a - t * 0.4);
      final q = _cellC + Offset(math.cos(a) * _cellRx * k, math.sin(a) * _cellRy * k);
      if (i == 0) {
        path.moveTo(q.dx, q.dy);
      } else {
        path.lineTo(q.dx, q.dy);
      }
    }
    path.close();
    final b = path.getBounds();
    canvas.drawPath(
      path.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          colors: isDark
              ? const [Color(0xFF5B3A26), Color(0xFF3D2618), Color(0xFF2A1A10)]
              : const [Color(0xFFFFFBF5), Color(0xFFFFEDD5), Color(0xFFFED7AA)],
          stops: const [0, 0.6, 1],
        ).createShader(b),
    );
    final dot = Paint()..color = (isDark ? const Color(0xFFFDBA74) : _Colors.orange700).withValues(alpha: 0.35);
    for (final g in _granules) {
      canvas.drawCircle(g, 2.6, dot);
    }
    // Nucleus.
    final nr = Rect.fromCircle(center: _nucC, radius: 52);
    canvas.drawCircle(
      _nucC,
      52,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFDDD6FE), Color(0xFFA78BFA), Color(0xFF6D28D9)],
          stops: [0, 0.55, 1],
        ).createShader(nr),
    );
    canvas.drawCircle(
      _nucC,
      52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF5B21B6),
    );
    canvas.drawCircle(_nucC + const Offset(10, 8), 15, Paint()..color = const Color(0xFF5B21B6));
    final chrom = Paint()..color = const Color(0xFF4C1D95).withValues(alpha: 0.6);
    for (var i = 0; i < 8; i++) {
      final a = i * 0.8;
      canvas.drawCircle(_nucC + Offset(math.cos(a) * 30, math.sin(a) * 26), 3, chrom);
    }
    // Membrane.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = _Colors.orange.withValues(alpha: 0.3),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = isDark ? _Colors.orange : const Color(0xFFF97316),
    );
    // Drop zone glow while something is dragged towards the cell.
    if (sc.step == 1 && sc.drag != null) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = _Colors.zslYellow.withValues(alpha: 0.5 + 0.4 * math.sin(t * 6)),
      );
    }
  }

  void _drawEnergyMeter(Canvas canvas) {
    const box = Rect.fromLTRB(800, 112, 834, 330);
    final rr = RRect.fromRectAndRadius(box, const Radius.circular(12));
    canvas.drawRRect(rr, Paint()..color = isDark ? const Color(0xCC0F172A) : const Color(0xE6FFFFFF));
    final h = (box.height - 8) * sc.energy.clamp(0.0, 1.0);
    if (h > 1) {
      final fill = Rect.fromLTRB(box.left + 4, box.bottom - 4 - h, box.right - 4, box.bottom - 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fill, const Radius.circular(9)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [_Colors.amber, _Colors.yellow],
          ).createShader(fill),
      );
    }
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = isDark ? _Colors.slate400 : _Colors.slate500,
    );
    final bolt = _boltPath(const Offset(817, 88), 30);
    canvas.drawPath(bolt, Paint()..color = sc.reacted ? _Colors.yellow : (isDark ? _Colors.slate500 : _Colors.slate400));
    canvas.drawPath(
      bolt,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _Colors.amber700,
    );
    _label(canvas, 'lbl_energy', const Offset(817, 352), size: 13);
  }

  void _drawReaction(Canvas canvas) {
    final r = t - sc.reactAt;
    if (!sc.reacted && r >= 0 && r < 1.0) {
      labGlow(canvas, _reactC, 30 + 70 * r, _Colors.yellow, intensity: r);
    }
    if (!sc.reacted) return;
    final burst = r - 0.9;
    if (burst >= 0 && burst < 0.9) {
      canvas.drawCircle(
        _reactC,
        20 + burst * 180,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * (1 - burst / 0.9)
          ..color = _Colors.yellow.withValues(alpha: 1 - burst / 0.9),
      );
    }
    final pulse = 0.5 + 0.5 * math.sin(t * 4);
    labGlow(canvas, _reactC, 74 + 12 * pulse, _Colors.yellow, intensity: 0.5 + 0.25 * pulse);
    final ray = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = _Colors.yellow.withValues(alpha: 0.85);
    for (var i = 0; i < 8; i++) {
      final a = t * 0.8 + i * math.pi / 4;
      final u = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(_reactC + u * 36, _reactC + u * (46 + 6 * pulse), ray);
    }
    final bolt = _boltPath(_reactC, 54);
    canvas.drawPath(bolt, Paint()..color = _Colors.yellow);
    canvas.drawPath(
      bolt,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = _Colors.amber700,
    );
    _label(canvas, 'lbl_energy', _reactC + const Offset(0, -52), size: 13);
  }

  void _drawS3Mol(Canvas canvas, int i) {
    final m = sc.mols[i];
    if (!m.visible) return;
    final dragged = sc.drag == i;
    final wob = dragged ? Offset.zero : Offset(math.sin(t * 1.2 + m.phase) * 2.5, math.cos(t + m.phase) * 2.5);
    final q = m.pos + wob;
    final st = sc.step;
    final active = !sc.busy &&
        !m.moved &&
        ((st == 1 && (m.kind == _Kind.glucose || m.kind == _Kind.o2)) || (st == 3 && m.kind == _Kind.co2));
    if (active && !dragged) _hint(canvas, q, 34);
    final sc1 = dragged ? 1.3 : 1.15;
    switch (m.kind) {
      case _Kind.glucose:
        _glucose(canvas, q, m.phase, scale: dragged ? 1.15 : 1);
        _tag(canvas, tr('lbl_glucose'), q + const Offset(0, 32), size: 12.5);
      case _Kind.o2:
        _o2(canvas, q, m.phase, scale: sc1);
        _tag(canvas, '${tr('lbl_oxygen')} (O_2)', q + const Offset(0, 28), size: 12.5);
      case _Kind.co2:
        _co2(canvas, q, m.phase, scale: sc1);
        _tag(canvas, '${tr('lbl_carbon_dioxide')} (CO_2)', q + const Offset(0, 28), size: 12.5);
      case _Kind.water:
        _water(canvas, q, scale: dragged ? 1.2 : 1.05);
        _tag(canvas, '${tr('lbl_water')} (H_2O)', q + const Offset(0, 28), size: 12.5);
    }
  }

  // ---------------------------------------------------------- bench

  void _paintBench(Canvas canvas, Size size) {
    final bleed = labBleed(size);
    _bg(
      canvas,
      size,
      isDark ? _Colors.slate800 : const Color(0xFFE2E8F0),
      isDark ? _Colors.slate900 : _Colors.slate300,
    );
    // Table.
    final table = Rect.fromLTRB(bleed.left, 440, bleed.right, bleed.bottom);
    canvas.drawRect(
      table,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF5B3A1E), Color(0xFF3B2412)]
              : const [Color(0xFFD6A26A), Color(0xFFA16207)],
        ).createShader(const Rect.fromLTRB(0, 440, 1000, 560)),
    );
    canvas.drawRect(
      Rect.fromLTRB(bleed.left, 438, bleed.right, 444),
      Paint()..color = isDark ? const Color(0xFF7C5532) : const Color(0xFFE8C08E),
    );

    // Rack: base and legs behind the tubes.
    const wood = Color(0xFFB7791F);
    final woodPaint = Paint()..color = wood;
    labBox3D(canvas, const Rect.fromLTRB(240, 424, 628, 440), 10, wood, stroke: false);
    canvas.drawRect(const Rect.fromLTRB(256, 270, 268, 426), woodPaint);
    canvas.drawRect(const Rect.fromLTRB(600, 270, 612, 426), woodPaint);

    final pushAge = t - sc.pushAt;
    final blowAge = t - sc.blowAt;
    final clear = isDark ? const Color(0x667DD3FC) : const Color(0x5593C5FD);
    const milky = Color(0xF5F1F5F9);
    _tube(canvas, _tubeA, clear, bubbles: pushAge > 0.15 && pushAge < 1.8 ? pushAge : null, tip: 405);
    _tube(
      canvas,
      _tubeB,
      Color.lerp(clear, milky, sc.milk.clamp(0.0, 1.0))!,
      bubbles: blowAge >= 0 && blowAge < 1.3 ? blowAge : null,
      tip: 405,
      cloudy: sc.milk,
    );

    // Rack top plate (tubes pass through it).
    labBox3D(canvas, const Rect.fromLTRB(248, 262, 620, 280), 10, wood, stroke: false);
    for (final (x, l) in [(328.0, 'A'), (528.0, 'B')]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 262), width: 62, height: 8), Paint()..color = const Color(0xFF7C4A12));
      labText(canvas, l, Offset(x, 271), size: 14, weight: FontWeight.w900, color: const Color(0xFF431407));
    }

    _drawPichkari(canvas, pushAge);
    _drawStraw(canvas);
    _drawFace(canvas, blowAge >= 0 && blowAge < 1.2 ? math.sin(blowAge / 1.2 * math.pi) : 0);

    // Labels.
    _label(canvas, 'lbl_pichkari', const Offset(296, 104), anchor: Alignment.centerRight);
    _label(canvas, 'lbl_air_around', const Offset(296, 140), anchor: Alignment.centerRight);
    _label(canvas, 'lbl_straw', const Offset(540, 236), anchor: Alignment.centerLeft);
    _label(canvas, 'lbl_air_breathed_out', const Offset(700, 60));
    _label(canvas, 'lbl_lime_water', const Offset(428, 360));
    _label(canvas, 'lbl_tube_a', const Offset(328, 466), size: 13);
    _label(canvas, 'lbl_tube_b', const Offset(528, 466), size: 13);
    if (sc.aDone) _result(canvas, 'lbl_clear', const Offset(328, 500), _Colors.green);
    if (sc.blows > 0) {
      _result(canvas, sc.blows < 3 ? 'lbl_cloudy' : 'lbl_milky', const Offset(528, 500), _Colors.slate300);
    }
    if (!sc.busy && sc.step == 4) {
      _hint(canvas, const Offset(328, 120), 46);
      _tagHint(canvas, 'lbl_tap_push', const Offset(328, 196));
    }
    if (!sc.busy && sc.step == 5) {
      _hint(canvas, const Offset(560, 150), 40);
      _tagHint(canvas, 'lbl_tap_blow', const Offset(590, 196));
    }
  }

  void _tagHint(Canvas canvas, String key, Offset at) {
    labText(
      canvas,
      tr(key),
      at,
      size: 12,
      weight: FontWeight.w800,
      color: _Colors.slate900,
      background: _Colors.zslYellow,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  void _result(Canvas canvas, String key, Offset at, Color border) {
    labText(
      canvas,
      tr(key),
      at,
      size: 13,
      weight: FontWeight.w800,
      color: isDark ? Colors.white : _Colors.slate900,
      background: isDark ? const Color(0xE60F172A) : const Color(0xF2FFFFFF),
      border: border,
      borderWidth: 2,
      radius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  /// Glass test tube with lime water, optional bubbles and cloudiness.
  void _tube(Canvas canvas, Rect r, Color liquid, {double? bubbles, required double tip, double cloudy = 0}) {
    final rad = r.width / 2;
    final glass = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.left, r.bottom - rad)
      ..arcToPoint(Offset(r.right, r.bottom - rad), radius: Radius.circular(rad), clockwise: false)
      ..lineTo(r.right, r.top);
    final closed = Path()
      ..addPath(glass, Offset.zero)
      ..close();
    canvas.save();
    canvas.clipPath(closed);
    canvas.drawRect(Rect.fromLTRB(r.left, r.top, r.right, r.bottom), Paint()..color = Colors.white.withValues(alpha: isDark ? 0.06 : 0.35));
    final lq = Rect.fromLTRB(r.left, _limeTop, r.right, r.bottom);
    canvas.drawRect(
      lq,
      Paint()
        ..shader = LinearGradient(
          colors: [labShade(liquid, -0.08), liquid, labShade(liquid, 0.15)],
          stops: const [0, 0.5, 1],
        ).createShader(lq),
    );
    if (cloudy > 0.25) {
      final speck = Paint()..color = Colors.white.withValues(alpha: 0.5 * cloudy);
      for (var i = 0; i < 26; i++) {
        final x = r.left + 6 + (i * 37 % 44);
        final y = _limeTop + 8 + ((i * 53 + t * 6) % (r.bottom - _limeTop - 14));
        canvas.drawCircle(Offset(x, y), 1.6, speck);
      }
    }
    canvas.drawLine(
      Offset(r.left, _limeTop),
      Offset(r.right, _limeTop),
      Paint()
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.6),
    );
    if (bubbles != null) {
      final bubble = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.9);
      for (var i = 0; i < 12; i++) {
        final ph = (bubbles * 1.6 + i / 12) % 1.0;
        final y = tip - ph * (tip - _limeTop - 4);
        final x = r.center.dx + math.sin(i * 1.7 + bubbles * 9) * 9;
        canvas.drawCircle(Offset(x, y), 2.5 + (i % 3) * 1.4, bubble);
      }
    }
    canvas.restore();
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = isDark ? const Color(0xCCBFDBFE) : const Color(0xFF64748B),
    );
    canvas.drawLine(
      Offset(r.left - 4, r.top),
      Offset(r.right + 4, r.top),
      Paint()
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = isDark ? const Color(0xFFBFDBFE) : const Color(0xFF64748B),
    );
    canvas.drawLine(
      Offset(r.left + 8, r.top + 14),
      Offset(r.left + 8, r.bottom - rad),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawPichkari(Canvas canvas, double age) {
    final u = sc.aDone ? 1.0 : (age > 0 ? Curves.easeInOut.transform((age / 0.9).clamp(0.0, 1.0)) : 0.0);
    final head = 80 + u * 86;
    final glassCol = isDark ? const Color(0xCCBFDBFE) : const Color(0xFF64748B);
    // Delivery tube into test tube A.
    canvas.drawLine(
      const Offset(328, 190),
      const Offset(328, 405),
      Paint()
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = isDark ? const Color(0x99E0F2FE) : const Color(0xAA94A3B8),
    );
    // Plunger rod and thumb rest.
    canvas.drawRect(Rect.fromLTRB(324, head - 64, 332, head), Paint()..color = _Colors.slate400);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(300, head - 72, 356, head - 62), const Radius.circular(4)),
      Paint()..color = isDark ? _Colors.slate300 : _Colors.slate500,
    );
    // Barrel.
    const barrel = Rect.fromLTRB(306, 70, 350, 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barrel, const Radius.circular(6)),
      Paint()..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.55),
    );
    // Rubber piston.
    canvas.drawRect(Rect.fromLTRB(308, head, 348, head + 9), Paint()..color = _Colors.slate700);
    final mark = Paint()
      ..strokeWidth = 1.5
      ..color = glassCol;
    for (var y = 90.0; y < 176; y += 14) {
      canvas.drawLine(Offset(338, y), Offset(349, y), mark);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(barrel, const Radius.circular(6)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = glassCol,
    );
    canvas.drawRect(const Rect.fromLTRB(298, 68, 358, 74), Paint()..color = glassCol);
    // Nozzle.
    canvas.drawPath(
      Path()
        ..moveTo(318, 180)
        ..lineTo(338, 180)
        ..lineTo(331, 192)
        ..lineTo(325, 192)
        ..close(),
      Paint()..color = glassCol,
    );
  }

  void _drawStraw(Canvas canvas) {
    final path = Path()
      ..moveTo(528, 410)
      ..lineTo(528, 176)
      ..quadraticBezierTo(528, 150, 554, 150)
      ..lineTo(642, 150);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFBE123C),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = _Colors.rose400,
    );
    labDashedPath(
      canvas,
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Colors.white.withValues(alpha: 0.8),
      dash: 7,
      gap: 9,
    );
  }

  /// Child (side view) blowing into the straw, like textbook Fig. 9.11 (b).
  void _drawFace(Canvas canvas, double puff) {
    const c = Offset(702, 142);
    const skin = Color(0xFFE0A47A);
    const skinDark = Color(0xFFB9784F);
    // Shirt and neck.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(646, 214, 790, 300),
        topLeft: const Radius.circular(46),
        topRight: const Radius.circular(52),
      ),
      Paint()..color = const Color(0xFF2563EB),
    );
    canvas.drawRect(const Rect.fromLTRB(686, 186, 724, 222), Paint()..color = skinDark);
    // Head.
    canvas.drawCircle(
      c,
      58,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.3),
          colors: [Color(0xFFF2C6A0), skin, skinDark],
          stops: [0, 0.6, 1],
        ).createShader(Rect.fromCircle(center: c, radius: 58)),
    );
    // Nose.
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 54, c.dy - 18)
        ..quadraticBezierTo(c.dx - 70, c.dy - 2, c.dx - 55, c.dy + 2)
        ..close(),
      Paint()..color = skin,
    );
    // Hair.
    final hair = Path()
      ..moveTo(c.dx - 52, c.dy - 20)
      ..cubicTo(c.dx - 44, c.dy - 74, c.dx + 44, c.dy - 80, c.dx + 60, c.dy - 16)
      ..cubicTo(c.dx + 66, c.dy + 12, c.dx + 54, c.dy + 34, c.dx + 44, c.dy + 40)
      ..cubicTo(c.dx + 28, c.dy - 6, c.dx - 12, c.dy - 30, c.dx - 52, c.dy - 20)
      ..close();
    canvas.drawPath(hair, Paint()..color = const Color(0xFF1F2937));
    // Ear, eye, brow.
    canvas.drawOval(Rect.fromCenter(center: c + const Offset(16, 8), width: 18, height: 25), Paint()..color = skin);
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(16, 8), width: 18, height: 25),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = skinDark,
    );
    canvas.drawOval(Rect.fromCenter(center: c + const Offset(-30, -12), width: 8, height: 11), Paint()..color = _Colors.slate900);
    canvas.drawLine(
      c + const Offset(-38, -26),
      c + const Offset(-22, -28),
      Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF1F2937),
    );
    // Puffed cheek and lips on the straw.
    canvas.drawCircle(c + const Offset(-30, 16), 13 + 7 * puff, Paint()..color = const Color(0x40F43F5E));
    canvas.drawOval(Rect.fromCenter(center: c + const Offset(-56, 9), width: 14, height: 11), Paint()..color = _Colors.rose700);
    if (puff > 0.05) {
      final line = Paint()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = (isDark ? Colors.white : _Colors.slate500).withValues(alpha: puff);
      for (var i = 0; i < 3; i++) {
        final y = 118.0 + i * 12;
        canvas.drawLine(Offset(612 - i * 4.0, y), Offset(596 - i * 4.0, y - 4), line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.isDark != isDark || old.showLabels != showLabels || old.lang != lang || old.scene != scene;
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
