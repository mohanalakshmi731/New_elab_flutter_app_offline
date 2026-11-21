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

/// Class 6 Science • Chapter 7 • Activity 6
/// Air Temperature Measurement and Analysis.
///
/// Native Flutter port of
/// `Cl6S-Ch7-A6-Air_Temperature_Measurement_and_Analysis.html` (Three.js
/// r128). The two Three.js rooms are redrawn by a CustomPainter through a
/// perspective projection of the same camera (position (0, 18, 50), look-at
/// (0, 5, 0), 45° field of view), re-fitted beside the floating cards.
///
/// Scenario 1 (Weather Watch): switch on the weather station, drag Day 1's
/// maximum and minimum air temperatures into the 10-day table (the line
/// graph plots them), record Days 2 and 3, fast-forward to Day 10 and see
/// the air temperature go up and down from day to day.
///
/// Scenario 2 (The Classroom Microclimate): read the wall clock at 9:00 AM,
/// drag the room-air and water thermometer readings into the table, move the
/// clock on to 1:00 PM and 4:00 PM and record again; the bar chart shows
/// that air heats up and cools down faster than water.
class Ch7A6AirTemperatureMeasurementAndAnalysisPage extends StatefulWidget {
  const Ch7A6AirTemperatureMeasurementAndAnalysisPage({super.key});

  @override
  State<Ch7A6AirTemperatureMeasurementAndAnalysisPage> createState() =>
      _Ch7A6PageState();
}

// ===================================================================== AUDIO

/// This lab's sound effects: local tones bundled
/// in `assets/audio/`. The HTML synthesises three tones with the Web Audio
/// API: 'pop' (400 → 800 Hz chirp: buttons, curtain, scenario change, a
/// value dropped into the table), 'click' (600 → 800 Hz tick: the wall
/// clock and every fast-forwarded day) and 'success' (a two-note triangle
/// chime when a row is complete and for the conclusion). They map to
/// pop.mp3, click.mp3 and success.mp3; error.mp3 marks the error toasts and
/// correct.mp3 the shell's own "Scenario Complete" toast.
///
/// Files (in `assets/audio/`): pop → `science/pop.mp3`,
/// click → `science/click.mp3`, success → `math/success.mp3`,
/// correct → `science/correct.mp3`, wrong → `science/error.mp3`.
enum _Sound implements LabTone {
  /// HTML `playSound('pop')`.
  pop('audio/class6/science/pop.mp3'),

  /// HTML `playSound('click')`.
  click('audio/class6/science/click.mp3'),

  /// HTML `playSound('success')`.
  success('audio/class6/math/success.mp3'),

  /// Shell feedback toast.
  correct('audio/class6/science/correct.mp3'),

  /// Error toast (a reading dropped into the wrong cell).
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

/// Tailwind colours of the HTML UI and the Three.js material colours.
abstract final class _Colors {
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // accent (text-blue-500)
  static const Color blue600 = Color(0xFF2563EB); // buttons (from-blue-600)
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444); // max line, clock rim
  static const Color red600 = Color(0xFFDC2626); // max values
  static const Color sky400 = Color(0xFF38BDF8); // air bars (.bar-air)
  static const Color sky500 = Color(0xFF0EA5E9); // air reading, water
  static const Color sky600 = Color(0xFF0284C7); // air values
  static const Color emerald400 = Color(0xFF34D399); // water bars
  static const Color emerald500 = Color(0xFF10B981); // water reading
  static const Color emerald600 = Color(0xFF059669); // water values
  static const Color slate50 = Color(0xFFF8FAFC); // thermometer base
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0); // gridlines
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8); // station body
  static const Color slate500 = Color(0xFF64748B); // axis labels
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155); // S1 wall, minute hand
  static const Color slate800 = Color(0xFF1E293B); // clock ticks
  static const Color slate900 = Color(0xFF0F172A); // scene background
  static const Color slate950 = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Three.js materials.
  static const Color desk = Color(0xFF8B5A2B);
  static const Color skyBlue = Color(0xFF87CEEB); // clear sky / 9 AM
  static const Color skyGrey = Color(0xFFA1A1AA); // overcast (Next Day)
  static const Color skySlate = Color(0xFF64748B); // overcast (fast forward)
  static const Color skyNoon = Color(0xFF38BDF8); // 1 PM
  static const Color skyEvening = Color(0xFFFDBA74); // 4 PM
  static const Color sun = Color(0xFFFDE047);
  static const Color classWall = Color(0xFFF5F5DC); // "warm classroom wall"
  static const Color chalkboard = Color(0xFF2F4F4F);
  static const Color chalkFrame = Color(0xFF5C4033);
  static const Color hill = Color(0xFF4ADE80);
  static const Color warmLight = Color(0xFFFFEDD5); // 4 PM light colour

  /// canvas-confetti default colours.
  static const List<Color> confetti = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];

  /// Glass panels (`--glass-bg`) and their borders (`--glass-border`).
  static const Color glassDark = Color(0xEB0F172A);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color borderDark = Color(0x26FFFFFF);
  static const Color borderLight = Color(0x26000000);

  /// Reading chips on the wall (`.drag-num` text shadow, as a backdrop).
  static const Color chipBg = Color(0xD9020617);
}

/// This lab's light and dark palettes (the HTML `:root` / `.dark`
/// variables): sidebar, canvas, popups, curtain, buttons and readouts.
abstract final class _Theme {
  static const LabPalette dark = LabPalette(
    isDark: true,
    bg: _Colors.slate950, // --bg-primary
    panel: _Colors.glassDark,
    border: _Colors.borderDark,
    card: Color(0xCC1E293B), // dark:bg-slate-800/80
    cardBorder: _Colors.slate700,
    canvasBg: _Colors.slate950, // #canvas-wrapper bg-[#020617]
    text: _Colors.slate200,
    textStrong: _Colors.white,
    textMuted: _Colors.slate400,
    accent: _Colors.blue500,
    onAccent: _Colors.white,
    primary: _Colors.blue600, // summary button from-blue-600
    onPrimary: _Colors.white,
    success: _Colors.emerald500,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald400, // completed steps (dark:text-emerald-400)
    popupBg: _Colors.slate900,
    popupHeader: _Colors.slate800,
    dialogBg: _Colors.slate900,
    toastBg: Color(0xE60F172A), // bg-slate-900/90
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A), // from-blue-900/40
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD), // text-blue-300/80
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassDark,
    buttonIcon: _Colors.blue500,
    buttonBorder: _Colors.borderDark,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.glassDark, // .label-3d glass-panel
    labelText: _Colors.white,
  );

  static const LabPalette light = LabPalette(
    isDark: false,
    bg: _Colors.slate200, // --bg-primary #e2e8f0
    panel: _Colors.glassLight,
    border: _Colors.borderLight,
    card: _Colors.slate100,
    cardBorder: _Colors.slate300,
    canvasBg: _Colors.slate100,
    text: _Colors.slate700,
    textStrong: _Colors.slate900,
    textMuted: _Colors.slate500,
    accent: _Colors.blue600,
    onAccent: _Colors.white,
    primary: _Colors.blue600,
    onPrimary: _Colors.white,
    success: _Colors.emerald600,
    danger: _Colors.red500,
    onDanger: _Colors.white,
    info: _Colors.emerald600,
    popupBg: _Colors.white,
    popupHeader: _Colors.slate100,
    dialogBg: _Colors.white,
    toastBg: Color(0xE60F172A),
    toastText: _Colors.white,
    curtainBg: _Colors.slate900,
    curtainGlow: Color(0x661E3A8A),
    curtainText: _Colors.white,
    curtainMuted: Color(0xCC93C5FD),
    curtainIcon: _Colors.slate300,
    buttonBg: _Colors.glassLight,
    buttonIcon: _Colors.blue600,
    buttonBorder: _Colors.borderLight,
    readoutBg: _Colors.slate900,
    readoutBorder: _Colors.slate700,
    readoutIcon: _Colors.slate400,
    labelBg: _Colors.glassLight,
    labelText: _Colors.slate800,
  );
}

// ====================================================================== FONT

/// This lab's font. The HTML uses Plus Jakarta Sans; a `null` family uses
/// the app font, which includes Devanagari for Hindi. Sizes are the sidebar
/// text size setting in px (HTML `--sidebar-font-size`: 15 px, slider
/// 12–22 px).
const _font = LabFont(
  family: null,
  fallback: null,
  size: 15,
  minSize: 12,
  maxSize: 22,
);

/// This lab's tones, palettes and font, handed to the shared shell. The
/// HTML plays its 'pop' for the curtain, scenario change and sidebar too.
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
// From the HTML `i18n` / `ScenariosData` tables (Telugu dropped). Changes:
// * step actions say exactly what to do, with touch words ("TAP", "DRAG")
//   and the Hindi button names in Hindi mode (the HTML Hindi quoted the
//   English labels);
// * S1 step 5 lists every action of the step (record Day 2, Next Day,
//   record Day 3, Fast Forward); S2 step 6 says to record after advancing;
// * S1 observation 3 no longer says the points "connect to the origin"
//   (they never did);
// * times are written the Hindi way in Hindi mode ("सुबह 9:00");
// * strings marked "added" were not in the HTML (wrong-cell toasts, table
//   and chart labels, the screen captions, the sidebar's pending text) or
//   were hard-coded English there (the table headers, "Air vs Water
//   Heating", the chart axis).

const LabStringTable _i18n = {
  'en': {
    'app_title': 'Air Temperature Measurement and Analysis',
    'app_subtitle': 'Class 6 • Temperature and its Measurements',
    'scen_1_title': 'Scenario 1: Weather Watch',
    'scen_2_title': 'Scenario 2: The Classroom Microclimate',
    'scen_1_obj':
        'Observe, record, and analyze max and min air temperatures for a 10-day period.',
    'scen_2_obj':
        'Compare air temperature vs water temperature at different times of the day to see which heats up faster.',
    // Scenario 1 steps.
    's1_c1': 'Simulation Start',
    's1_a1':
        "TAP the 'Start' button to switch on the weather station for Day 1.",
    's1_o1': 'Simulation begins, showing max/min temps for Day 1.',
    's1_c2': 'Record Max Temp',
    's1_a2':
        "DRAG the red maximum temperature from the station's screen to the Max °C cell of the Day 1 row in the table.",
    's1_o2': 'Data populates the Day 1 maximum cell.',
    's1_c3': 'Record Min Temp',
    's1_a3':
        'DRAG the blue minimum temperature to the Min °C cell of the Day 1 row, then watch the graph plot Day 1.',
    's1_o3': "Day 1's maximum and minimum points appear on the graph.",
    's1_c4': 'Advance Weather',
    's1_a4': "TAP the 'Next Day' button.",
    's1_o4': 'Window scene changes, station numbers spin to new values.',
    's1_c5': 'Complete Dataset',
    's1_a5':
        "RECORD Day 2 (drag its maximum and minimum temperatures to the table), TAP 'Next Day', record Day 3 the same way, then TAP 'Fast Forward to Day 10'.",
    's1_o5': 'Data table and line graph fully build out for 10 days.',
    's1_c6': 'Analyze Graph',
    's1_a6':
        "OBSERVE the completed graph lines, then TAP 'Observe Conclusion'.",
    's1_o6': 'Air temperature is dynamic and fluctuates every day.',
    // Scenario 2 steps.
    's2_c1': 'Initial Reading',
    's2_a1': 'TAP the wall clock to take the 9:00 AM reading.',
    's2_o1': 'Thermometer readings become clear.',
    's2_c2': 'Record Air',
    's2_a2':
        'DRAG the room air temperature (beside the wall thermometer) to the Air °C cell of the 9:00 AM row.',
    's2_o2': 'Air temperature recorded.',
    's2_c3': 'Record Water',
    's2_a3':
        'DRAG the water temperature (beside the thermometer in the beaker) to the Water °C cell of the 9:00 AM row.',
    's2_o3': 'Water temperature recorded.',
    's2_c4': 'Midday Heating',
    's2_a4': "TAP the 'Advance Time (1:00 PM)' button.",
    's2_o4': 'Sun moves higher, both temperatures rise.',
    's2_c5': 'Record Midday',
    's2_a5':
        'DRAG both new temperatures (air and water) to the 1:00 PM row of the table.',
    's2_o5': 'Air temperature increased significantly more than water.',
    's2_c6': 'Afternoon Cooling',
    's2_a6':
        "TAP 'Advance Time (4:00 PM)', then DRAG both new temperatures to the 4:00 PM row.",
    's2_o6': 'Temperatures begin to drop as sun lowers.',
    's2_c7': 'Data Analysis',
    's2_a7': "OBSERVE the final bar chart, then TAP 'Observe Conclusion'.",
    's2_o7': 'Air heats up and cools down much faster than water.',
    // HUD ("Current Task").
    's1_hud_1':
        "Step 1: TAP the 'Start' button to begin the simulation for Day 1.",
    's1_hud_2':
        'Step 2: DRAG the Max Temp from the station to the Day 1 row in the table.',
    's1_hud_3':
        'Step 3: DRAG the Min Temp to the Day 1 row. Notice the graph plots automatically.',
    's1_hud_4': "Step 4: TAP the 'Next Day' button to change the weather.",
    's1_hud_5':
        "Step 5: Record data for Days 2 & 3. Then tap 'Fast Forward to Day 10'.",
    's1_hud_6':
        "Step 6: OBSERVE the final line graph. Tap 'Observe Conclusion'.",
    's2_hud_1': 'Step 1: TAP the wall clock to take the 9:00 AM reading.',
    's2_hud_2':
        'Step 2: DRAG the Room Air Temp reading to the 9:00 AM table row.',
    's2_hud_3': 'Step 3: DRAG the Water Temp reading to the 9:00 AM table row.',
    's2_hud_4': "Step 4: TAP 'Advance Time' to move the clock to 1:00 PM.",
    's2_hud_5': 'Step 5: DRAG and record both new temperatures for 1:00 PM.',
    's2_hud_6': "Step 6: TAP 'Advance Time' to 4:00 PM and record final temps.",
    's2_hud_7':
        "Step 7: OBSERVE the final Bar Chart comparison. Tap 'Observe Conclusion'.",
    // Buttons.
    'btn_start': 'Start',
    'btn_next_day': 'Next Day',
    'btn_ff': 'Fast Forward to Day 10',
    'btn_conclude': 'Observe Conclusion',
    'btn_adv_1pm': 'Advance Time (1:00 PM)',
    'btn_adv_4pm': 'Advance Time (4:00 PM)',
    'btn_clock': 'Read the Wall Clock (9:00 AM)', // added (HTML: icon only)
    // Toasts.
    'toast_fast_forward': 'Fast Forwarding 7 Days...',
    'toast_drag_room': 'Drag the Room Temp to the table.',
    'toast_drag_water': 'Drag the Water Temp to the table.',
    'err_cell_max':
        'Wrong cell! The maximum temperature goes in the Max °C cell of Day {n}.',
    'err_cell_min':
        'Wrong cell! The minimum temperature goes in the Min °C cell of Day {n}.',
    'err_cell_air':
        'Wrong cell! The room air temperature goes in the Air °C cell of the {time} row.',
    'err_cell_water':
        'Wrong cell! The water temperature goes in the Water °C cell of the {time} row.',
    // Canvas labels.
    'lbl_weather_station': 'Weather Station',
    'lbl_wall_clock': 'Wall Clock',
    'lbl_room_thermo': 'Room Thermometer',
    'lbl_water_thermo': 'Water Thermometer',
    'cap_max': 'MAX', // added
    'cap_min': 'MIN', // added
    // Data cards and charts.
    's1_table_title': '10-Day Temperature Record',
    'tbl_day': 'Day',
    'day_n': 'Day {n}',
    'col_max': 'Max °C',
    'col_min': 'Min °C',
    'graph_title': 'Temperature Trend',
    'lbl_days_1_10': 'Days (1-10)',
    'legend_max': 'Max', // added
    'legend_min': 'Min', // added
    's2_table_title': 'Air vs Water Heating',
    'tbl_time': 'Time',
    'col_air': 'Air °C',
    'col_water': 'Water °C',
    'time_1': '9:00 AM',
    'time_2': '1:00 PM',
    'time_3': '4:00 PM',
    'chart_title': 'Temperature Change',
    'chart_1': '9 AM',
    'chart_2': '1 PM',
    'chart_3': '4 PM',
    'lbl_air': 'Air',
    'lbl_water': 'Water',
    // Sidebar.
    'concept_exp': 'Observation Step',
    'exploration': 'Step',
    'concept_focus': 'Task',
    'action': 'Action',
    'observation': 'Result',
    'obs_pending': 'The result appears once you complete this step.',
    // Conclusion popups.
    'sc_complete': 'Scenario {n} Complete!',
    's1_headline': 'Dynamic Weather!',
    's1_summary':
        'You have successfully recorded the weather! Notice how the temperature lines go up and down daily. This continuous change is exactly why meteorologists track data to forecast weather patterns.',
    's2_headline': 'Differential Heating!',
    's2_summary':
        'Great job! The bar chart clearly shows that air heats up and cools down faster than water. This scientific principle explains why beach sand gets burning hot during the day while ocean water stays cool and refreshing.',
  },
  'hi': {
    'app_title': 'वायु तापमान मापन और विश्लेषण',
    'app_subtitle': 'कक्षा 6 • तापमान और उसका मापन',
    'scen_1_title': 'परिदृश्य 1: मौसम पर नज़र',
    'scen_2_title': 'परिदृश्य 2: कक्षा की सूक्ष्म जलवायु',
    'scen_1_obj':
        '10 दिनों के लिए अधिकतम और न्यूनतम वायु तापमान का निरीक्षण, रिकॉर्ड और विश्लेषण करें।',
    'scen_2_obj':
        'यह देखने के लिए कि कौन तेज़ी से गर्म होता है, दिन के अलग-अलग समय पर हवा बनाम पानी के तापमान की तुलना करें।',
    's1_c1': 'सिमुलेशन शुरू',
    's1_a1': "दिन 1 के लिए मौसम स्टेशन चालू करने हेतु 'शुरू करें' बटन दबाएँ।",
    's1_o1':
        'सिमुलेशन शुरू होता है, पहले दिन के लिए अधिकतम/न्यूनतम तापमान दिखाता है।',
    's1_c2': 'अधिकतम तापमान रिकॉर्ड करें',
    's1_a2':
        "स्टेशन की स्क्रीन से लाल अधिकतम तापमान को तालिका में दिन 1 की पंक्ति के 'अधिकतम °C' खाने में खींचें।",
    's1_o2': 'दिन 1 के अधिकतम खाने में डेटा भर जाता है।',
    's1_c3': 'न्यूनतम तापमान रिकॉर्ड करें',
    's1_a3':
        "नीले न्यूनतम तापमान को दिन 1 की पंक्ति के 'न्यूनतम °C' खाने में खींचें, फिर ग्राफ पर दिन 1 को अंकित होते देखें।",
    's1_o3': 'ग्राफ पर दिन 1 के अधिकतम और न्यूनतम बिंदु दिखाई देते हैं।',
    's1_c4': 'मौसम आगे बढ़ाएं',
    's1_a4': "'अगला दिन' बटन दबाएँ।",
    's1_o4': 'खिड़की का दृश्य बदलता है, स्टेशन के नंबर नए मानों पर घूमते हैं।',
    's1_c5': 'डेटासेट पूरा करें',
    's1_a5':
        "दिन 2 रिकॉर्ड करें (उसके अधिकतम और न्यूनतम तापमान तालिका में खींचें), 'अगला दिन' दबाएँ, दिन 3 को भी इसी तरह रिकॉर्ड करें, फिर 'दिन 10 पर जाएं' दबाएँ।",
    's1_o5':
        'डेटा तालिका और लाइन ग्राफ 10 दिनों के लिए पूरी तरह से बन जाते हैं।',
    's1_c6': 'ग्राफ का विश्लेषण करें',
    's1_a6':
        "पूरी हुई ग्राफ रेखाओं का निरीक्षण करें, फिर 'निष्कर्ष देखें' दबाएँ।",
    's1_o6': 'हवा का तापमान गतिशील है और हर दिन बदलता रहता है।',
    's2_c1': 'प्रारंभिक रीडिंग',
    's2_a1': 'सुबह 9:00 बजे की रीडिंग लेने के लिए दीवार घड़ी पर टैप करें।',
    's2_o1': 'थर्मामीटर की रीडिंग स्पष्ट हो जाती है।',
    's2_c2': 'हवा रिकॉर्ड करें',
    's2_a2':
        "कमरे की हवा के तापमान (दीवार थर्मामीटर के पास) को सुबह 9:00 बजे की पंक्ति के 'हवा °C' खाने में खींचें।",
    's2_o2': 'हवा का तापमान दर्ज किया गया।',
    's2_c3': 'पानी रिकॉर्ड करें',
    's2_a3':
        "पानी के तापमान (बीकर के थर्मामीटर के पास) को सुबह 9:00 बजे की पंक्ति के 'पानी °C' खाने में खींचें।",
    's2_o3': 'पानी का तापमान दर्ज किया गया।',
    's2_c4': 'दोपहर की गर्मी',
    's2_a4': "'समय आगे बढ़ाएं (दोपहर 1:00)' बटन दबाएँ।",
    's2_o4': 'सूरज ऊपर जाता है, दोनों तापमान बढ़ते हैं।',
    's2_c5': 'दोपहर रिकॉर्ड करें',
    's2_a5':
        'दोनों नए तापमान (हवा और पानी) को तालिका की दोपहर 1:00 बजे की पंक्ति में खींचें।',
    's2_o5': 'हवा का तापमान पानी की तुलना में काफी अधिक बढ़ गया।',
    's2_c6': 'दोपहर बाद की ठंडक',
    's2_a6':
        "'समय आगे बढ़ाएं (शाम 4:00)' दबाएँ, फिर दोनों नए तापमान शाम 4:00 बजे की पंक्ति में खींचें।",
    's2_o6': 'सूरज के नीचे जाने पर तापमान गिरना शुरू हो जाता है।',
    's2_c7': 'डेटा विश्लेषण',
    's2_a7': "अंतिम बार चार्ट का निरीक्षण करें, फिर 'निष्कर्ष देखें' दबाएँ।",
    's2_o7': 'हवा पानी की तुलना में बहुत तेज़ी से गर्म और ठंडी होती है।',
    's1_hud_1':
        "चरण 1: दिन 1 के लिए सिमुलेशन शुरू करने के लिए 'शुरू करें' दबाएँ।",
    's1_hud_2':
        'चरण 2: स्टेशन से अधिकतम तापमान को तालिका के दिन 1 की पंक्ति में खींचें।',
    's1_hud_3':
        'चरण 3: न्यूनतम तापमान को दिन 1 की पंक्ति में खींचें। ध्यान दें, ग्राफ अपने आप बनता है।',
    's1_hud_4': "चरण 4: मौसम बदलने के लिए 'अगला दिन' दबाएँ।",
    's1_hud_5':
        "चरण 5: दिन 2 और 3 का डेटा रिकॉर्ड करें। फिर 'दिन 10 पर जाएं' दबाएँ।",
    's1_hud_6': "चरण 6: अंतिम ग्राफ का निरीक्षण करें। 'निष्कर्ष देखें' दबाएँ।",
    's2_hud_1': 'चरण 1: सुबह 9:00 बजे की रीडिंग के लिए दीवार घड़ी पर टैप करें।',
    's2_hud_2':
        'चरण 2: कमरे की हवा के तापमान को तालिका में सुबह 9:00 बजे की पंक्ति में खींचें।',
    's2_hud_3':
        'चरण 3: पानी के तापमान को तालिका में सुबह 9:00 बजे की पंक्ति में खींचें।',
    's2_hud_4':
        "चरण 4: घड़ी को दोपहर 1:00 बजे पर ले जाने के लिए 'समय आगे बढ़ाएं' दबाएँ।",
    's2_hud_5': 'चरण 5: दोपहर 1:00 बजे के दोनों नए तापमान खींचकर रिकॉर्ड करें।',
    's2_hud_6':
        "चरण 6: 'समय आगे बढ़ाएं' दबाकर शाम 4:00 बजे पर जाएं और अंतिम तापमान रिकॉर्ड करें।",
    's2_hud_7':
        "चरण 7: अंतिम बार चार्ट की तुलना देखें। 'निष्कर्ष देखें' दबाएँ।",
    'btn_start': 'शुरू करें',
    'btn_next_day': 'अगला दिन',
    'btn_ff': 'दिन 10 पर जाएं',
    'btn_conclude': 'निष्कर्ष देखें',
    'btn_adv_1pm': 'समय आगे बढ़ाएं (दोपहर 1:00)',
    'btn_adv_4pm': 'समय आगे बढ़ाएं (शाम 4:00)',
    'btn_clock': 'दीवार घड़ी देखें (सुबह 9:00)',
    'toast_fast_forward': '7 दिन तेज़ी से आगे बढ़ा रहे हैं...',
    'toast_drag_room': 'कमरे के तापमान को तालिका में खींचें।',
    'toast_drag_water': 'पानी के तापमान को तालिका में खींचें।',
    'err_cell_max':
        "गलत खाना! अधिकतम तापमान दिन {n} के 'अधिकतम °C' खाने में जाता है।",
    'err_cell_min':
        "गलत खाना! न्यूनतम तापमान दिन {n} के 'न्यूनतम °C' खाने में जाता है।",
    'err_cell_air':
        "गलत खाना! कमरे की हवा का तापमान {time} की पंक्ति के 'हवा °C' खाने में जाता है।",
    'err_cell_water':
        "गलत खाना! पानी का तापमान {time} की पंक्ति के 'पानी °C' खाने में जाता है।",
    'lbl_weather_station': 'मौसम स्टेशन',
    'lbl_wall_clock': 'दीवार घड़ी',
    'lbl_room_thermo': 'कमरे का थर्मामीटर',
    'lbl_water_thermo': 'पानी का थर्मामीटर',
    'cap_max': 'अधिकतम',
    'cap_min': 'न्यूनतम',
    's1_table_title': '10-दिवसीय तापमान रिकॉर्ड',
    'tbl_day': 'दिन',
    'day_n': 'दिन {n}',
    'col_max': 'अधिकतम °C',
    'col_min': 'न्यूनतम °C',
    'graph_title': 'तापमान की प्रवृत्ति',
    'lbl_days_1_10': 'दिन (1-10)',
    'legend_max': 'अधिकतम',
    'legend_min': 'न्यूनतम',
    's2_table_title': 'हवा बनाम पानी का गर्म होना',
    'tbl_time': 'समय',
    'col_air': 'हवा °C',
    'col_water': 'पानी °C',
    'time_1': 'सुबह 9:00',
    'time_2': 'दोपहर 1:00',
    'time_3': 'शाम 4:00',
    'chart_title': 'तापमान परिवर्तन',
    'chart_1': 'सुबह 9',
    'chart_2': 'दोपहर 1',
    'chart_3': 'शाम 4',
    'lbl_air': 'हवा',
    'lbl_water': 'पानी',
    'concept_exp': 'अवलोकन चरण',
    'exploration': 'चरण',
    'concept_focus': 'कार्य',
    'action': 'क्रिया',
    'observation': 'परिणाम',
    'obs_pending': 'यह चरण पूरा करने पर परिणाम दिखेगा।',
    'sc_complete': 'परिदृश्य {n} पूर्ण!',
    's1_headline': 'गतिशील मौसम!',
    's1_summary':
        'आपने सफलतापूर्वक मौसम दर्ज किया है! ध्यान दें कि कैसे तापमान की रेखाएं प्रतिदिन ऊपर और नीचे जाती हैं। यह निरंतर परिवर्तन ही कारण है कि मौसम विज्ञानी मौसम के पैटर्न का पूर्वानुमान लगाने के लिए डेटा ट्रैक करते हैं।',
    's2_headline': 'विभेदक ताप!',
    's2_summary':
        'बहुत बढ़िया! बार चार्ट स्पष्ट रूप से दिखाता है कि हवा पानी की तुलना में तेज़ी से गर्म और ठंडी होती है। यह वैज्ञानिक सिद्धांत बताता है कि दिन के दौरान समुद्र तट की रेत क्यों जलने लगती है जबकि समुद्र का पानी ठंडा और ताज़ा रहता है।',
  },
};

/// Steps per scenario (HTML `ScenariosData[...].steps`).
const List<int> _stepCounts = [6, 7];
const int _scenarioCount = 2;

/// Scenarios and steps for [lang] (HTML `ScenariosData`: concept, action,
/// observation per step).
List<LabScenarioData> _buildScenarios(LabLang lang) {
  String t(String key) => labTr(_i18n, lang, key);
  return [
    for (var n = 1; n <= _scenarioCount; n++)
      LabScenarioData(
        title: t('scen_${n}_title'),
        objective: t('scen_${n}_obj'),
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

final Map<LabLang, List<LabScenarioData>> _scenarios = {
  for (final lang in LabLang.values) lang: _buildScenarios(lang),
};

// ===================================================================== STATE

/// Design size of the stage (the HTML WebGL canvas, scaled to fit).
const Size _design = Size(1000, 560);
const Offset _designCenter = Offset(500, 280);

/// The part of the design box the scene's touch targets are kept in (the
/// stage only hit-tests inside its design box).
final Rect _stageRect = (Offset.zero & _design).deflate(2);

/// HTML `resetCamera()`: `camera.position.set(0, 18, 50)`,
/// `controls.target.set(0, 5, 0)`, PerspectiveCamera(45°), both scenarios.
const _V _camEye = _V(0, 18, 50);
const _V _camTarget = _V(0, 5, 0);
const _V _up = _V(0, 1, 0);
const double _near = 0.1;

/// Design px per world unit at depth 1: 280 / tan(22.5°), the 45° field of
/// view over the 560 px stage height.
const double _focal = 675.96;

/// HTML lights: `AmbientLight(0xffffff, 0.6)` and `DirectionalLight(
/// 0xffffff, 0.8)` at (10, 20, 15), toned down by [_exposure] so the lit
/// faces keep their colour on a phone.
const double _ambient = 0.6;
const double _sunLight = 0.8;
const double _exposure = 0.85;

/// (10, 20, 15) normalised.
const _V _lightDir = _V(0.3714, 0.7428, 0.5571);

/// The scene is never drawn larger than the HTML camera shows it.
const double _maxZoom = 1;

/// Re-framing (fit the scene beside the cards) slides like the sidebar.
const double _framingSeconds = 0.38;

/// Canvas px kept free around cards when the scene is fitted beside them.
const double _cardGap = 8;

/// Shell layout the framing keeps clear of: the HUD chip at the bottom of
/// the canvas (two lines, label row, padding; × UI scale) and the compact
/// floating mission card (phones in landscape: screens shorter than
/// [_compactBelow], at most [_compactCardMax] of the height, 12 px from the
/// top).
const double _hudBand = 54;
const double _compactBelow = 480;
const double _compactCardMax = 0.55;
const double _missionTop = 12;

/// The floating cards start below the toast at the top centre (× UI scale).
const double _toastClear = 44;

/// Scene focus (base projection, design px): what the framing keeps in
/// view. S1: the window frame, the weather station and its label. S2: the
/// window, wall clock, room thermometer, beaker and their labels.
const Rect _focusS1 = Rect.fromLTRB(305, 62, 695, 362);
const Rect _focusS2 = Rect.fromLTRB(205, 28, 735, 385);

/// Scene labels (HTML `text-xs`): 12 design px at the HTML camera, shrinking
/// with the scene but never below [_labelMinDp] on screen.
const double _labelPx = 12;
const double _labelMinDp = 9.5;

/// "MAX" / "MIN" on the station's screen: 9 design px, at least
/// [_captionMinDp] on screen.
const double _captionPx = 9;
const double _captionMinDp = 8;

/// Reading chips (HTML `.drag-num`, 2rem font-black): [_chipPx] design px
/// at the HTML camera, never smaller than [_chipMinDp] on screen; they
/// pulse 1 → 1.1 → 1 every [_pulseSeconds] (`dragPulse`) and grow 1.2× in
/// the finger (`.drag-num:active`).
const double _chipPx = 26;
const double _chipMinDp = 13;
const double _pulseSeconds = 2;
const double _liftScale = 1.2;

/// A reading chip can be picked up this far from its centre (design px at
/// the HTML camera, and at least [_touchDp] on screen).
const double _chipHitPx = 34;
const double _touchDp = 26;

/// A drop counts when the finger is inside the cell or this close to it
/// (logical px).
const double _dropSlack = 4;

/// HTML `TWEEN.Tween(dummy).to({val: 100}, 800)`: the station digits spin
/// for 0.8 s; a new random digit every [_spinTick] s.
const double _spinSeconds = 0.8;
const double _spinTick = 0.05;

/// HTML `setTimeout(() => progressScenario1/2(), 1000)` after a complete
/// row, and the fast-forward rhythm (`delay += 400`, last row + 500 ms).
const Duration _rowReview = Duration(milliseconds: 1000);
const Duration _ffDayGap = Duration(milliseconds: 400);
const Duration _ffSettle = Duration(milliseconds: 500);

/// HTML `setupTimeData()`: the thermometer liquids rise for 1 s, then the
/// readings appear.
const Duration _readingDelay = Duration(milliseconds: 1000);

/// The conclusion opens right after 'Observe Conclusion' (HTML: at once,
/// with a 300 ms fade).
const Duration _conclusionDelay = Duration(milliseconds: 300);

// ------------------------------------------------------- scenario 1 data

/// HTML `State.s1.data`: maximum / minimum air temperature (°C), Days 1–10.
const List<(int, int)> _s1Data = [
  (25, 12),
  (27, 14),
  (24, 11),
  (22, 10),
  (28, 15),
  (29, 16),
  (30, 18),
  (26, 14),
  (25, 13),
  (22, 11),
];
const int _days = 10;

/// Days the learner records by hand (HTML: 1–3; 4–10 are fast-forwarded).
const int _handDays = 3;

/// Days whose maximum is at most this (°C) get an overcast window. The
/// HTML picked a blue or grey sky at random, unrelated to the record.
const int _overcastMax = 24;

/// HTML `sunMesh.position.set(-10, 15, -9.8)`; 'Next Day' moves it to a
/// random point (x −10…10, y 12…17); here a fixed point per day, higher on
/// warmer days.
const List<Offset> _sunByDay = [Offset(-10, 15), Offset(-3, 15), Offset(5, 13)];

/// HTML window colour tweens: 1 s on 'Next Day', 300 ms per fast-forwarded
/// day.
const double _skySecondsNextDay = 1;
const double _skySecondsFastForward = 0.3;

// ------------------------------------------------------- scenario 2 data

/// HTML `State.s2.data`: room air / water temperature (°C) at 9:00 AM,
/// 1:00 PM and 4:00 PM.
const List<(int, int)> _s2Data = [(20, 18), (28, 21), (26, 20)];
const int _times = 3;

/// Hour hand angle (clockwise from 12) at 9:00, 1:00 and 4:00. The minute
/// hand turns 12 times as fast, so it sweeps round and ends on 12. (The
/// HTML turned both hands together and showed 3 o'clock for 4:00 PM.)
const List<double> _hourAngles = [
  1.5 * math.pi,
  2 * math.pi + math.pi / 6,
  2 * math.pi + 2 * math.pi / 3,
];

/// HTML `advanceTime()`: hands 1.5 s Cubic.InOut; sun and sky 1.5 s.
const double _advanceSeconds = 1.5;

/// HTML `setupTimeData()`: liquids `scale.y = max(0.1, temp / 35)` over
/// 1 s, Quadratic.Out.
const double _fluidSeconds = 1;
const double _fluidMin = 0.1;
const double _fluidFull = 35;

/// Window sky, sun (window-local x, y) and sunlight at each reading.
const List<Color> _s2Sky = [
  _Colors.skyBlue,
  _Colors.skyNoon,
  _Colors.skyEvening,
];
const List<Offset> _s2Sun = [Offset(-4, -2), Offset(0, 3), Offset(4, -2)];
const List<double> _s2Light = [0.8, 1.2, 0.6];

// ---------------------------------------------------------- scene objects

/// S1 weather station (HTML `station`): body BoxGeometry(10, 8, 3) at y 4,
/// black screen PlaneGeometry(8, 5) at (0, 4.5, 1.51).
const _V _stationCenter = _V(0, 4, 0);
const _V _stationHalf = _V(5, 4, 1.5);
const double _screenZ = 1.51;

/// S2 objects (HTML groups): wall clock, wall thermometer, beaker.
const _V _clockCenter = _V(-4, 18, -9.5);
const double _clockR = 2.5;
const _V _thermoCenter = _V(4, 14, -9.5);
const _V _beakerBase = _V(12, 0, -2);

/// Lab thermometer in the beaker: 12 long, tilted −0.15 rad about z. The
/// HTML put its centre 3 above the beaker floor, which buried the bulb in
/// the desk; here the bulb sits in the water just above the floor.
const double _labThermoCenterY = 6.7;
const double _labThermoTilt = 0.15;

/// The two reading chips of each scenario (HTML anchors `anchorMax`,
/// `anchorMin`, `anchorAir`, `anchorWater`). S1: side by side on the
/// station's screen (the HTML stacked them 2 units apart, too close for a
/// finger); S2: beside each thermometer instead of on top of its scale.
enum _Handle {
  max(_V(-2.5, 4.0, 1.6), 'cap_max'),
  min(_V(2.5, 4.0, 1.6), 'cap_min'),
  air(_V(6.9, 15.2, -9.2), 'lbl_air'),
  water(_V(15.4, 10.0, -2), 'lbl_water');

  const _Handle(this.anchor, this.caption);

  final _V anchor;
  final String caption;

  bool get isS1 => this == max || this == min;

  /// The table column it belongs in (0 = left value column).
  int get column => this == max || this == air ? 0 : 1;
}

/// Scenario 1 progress (HTML `State.step` and the main button's label).
enum _S1Phase {
  start,
  recording,
  review,
  nextDay,
  fastForwardReady,
  fastForwarding,
  observe,
}

/// Scenario 2 progress.
enum _S2Phase { clock, recording, review, advance, observe }

// tween.js easing functions (exact, not Flutter's bezier approximations).
typedef _Ease = double Function(double t);

double _linear(double t) => t;

double _quadOut(double t) => t * (2 - t);

double _cubicInOut(double t) {
  final k = t * 2;
  if (k < 1) return 0.5 * k * k * k;
  final m = k - 2;
  return 0.5 * (m * m * m + 2);
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
Color _lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t)!;
Offset _lerpOffset(Offset a, Offset b, double t) => Offset.lerp(a, b, t)!;

/// A TWEEN.js tween of one value.
@immutable
class _Anim<T> {
  const _Anim(
    this.from,
    this.to,
    this.start,
    this.seconds,
    this.lerp, [
    this.ease = _linear,
  ]);

  final T from;
  final T to;
  final double start;
  final double seconds;
  final T Function(T a, T b, double t) lerp;
  final _Ease ease;

  double progress(double now) =>
      seconds <= 0 ? 1 : ((now - start) / seconds).clamp(0.0, 1.0);

  T at(double now) => lerp(from, to, ease(progress(now)));

  bool isDone(double now) => progress(now) >= 1;
}

/// One canvas-confetti piece (screen space, design px).
class _Confetto {
  _Confetto(this.x, this.y, this.angle, this.speed, this.color, this.wobble);

  double x;
  double y;
  final double angle;
  double speed;
  final Color color;
  double wobble;
}

/// canvas-confetti `{particleCount: 150, spread: 70, origin: {y: 0.3}}`:
/// start speed 45 px / frame, decay 0.9 / frame, gravity 3 px / frame,
/// 200 frames.
const int _confettiCount = 150;
const double _confettiSpread = 70 * math.pi / 180;
const double _confettiSpeed = 45;
const double _confettiDecay = 0.9;
const double _confettiGravity = 3;
const double _confettiSeconds = 200 / 60;
const Offset _confettiOrigin = Offset(500, 168);

/// Mutable simulation state, read by the painter every frame.
class _Scene {
  _Scene() {
    load(0);
  }

  double time = 0;
  int scenario = 0;

  /// 1-based step; the step count + 1 once the conclusion is open.
  int step = 1;

  /// Bumped by every [load]: callbacks of an earlier scenario are dropped.
  int token = 0;

  // --------------------------------------------------------- framing
  _Framing framing = _Framing.base;
  _Framing _from = _Framing.base;
  _Framing _to = _Framing.base;
  double _framingT = 1;

  /// True once the scene has finished re-fitting itself (tests wait for it
  /// before dragging).
  bool get framingSettled => _framingT >= 1;

  // ------------------------------------------------------ scenario 1
  _S1Phase s1 = _S1Phase.start;

  /// Day on the station (0 before 'Start').
  int day = 0;
  final List<int?> maxRec = List<int?>.filled(_days, null);
  final List<int?> minRec = List<int?>.filled(_days, null);

  /// Days plotted on the line graph (HTML `plotS1Graph(upToDay)`).
  int plotted = 0;
  double spinStart = -10;

  // ------------------------------------------------------ scenario 2
  _S2Phase s2 = _S2Phase.clock;

  /// 0 = 9:00 AM, 1 = 1:00 PM, 2 = 4:00 PM; −1 before the clock is read.
  int timeIndex = -1;
  final List<int?> airRec = List<int?>.filled(_times, null);
  final List<int?> waterRec = List<int?>.filled(_times, null);

  /// The thermometer readings are shown (1 s after the clock moves).
  bool readings = false;
  double hourAngle = _hourAngles[0];
  _Anim<double>? hourAnim;
  double roomFluid = _fluidMin;
  double labFluid = _fluidMin;
  _Anim<double>? roomAnim;
  _Anim<double>? labAnim;
  double light = _s2Light[0];
  bool chartShown = false;

  // --------------------------------------------------- both scenarios
  /// Window sky and sun (S1: world x, y on the wall; S2: in the window).
  Color sky = _Colors.skyBlue;
  _Anim<Color>? skyAnim;
  Offset sun = _sunByDay[0];
  _Anim<Offset>? sunAnim;

  /// The reading chip in the learner's finger (drawn by the drag layer).
  _Handle? lifted;

  final List<_Confetto> confetti = [];
  double confettiStart = 0;

  /// HTML `changeScenario(id)` / `resetScenarioState(sc)`.
  void load(int index) {
    token++;
    scenario = index;
    step = 1;
    s1 = _S1Phase.start;
    day = 0;
    maxRec.fillRange(0, _days, null);
    minRec.fillRange(0, _days, null);
    plotted = 0;
    spinStart = -10;
    s2 = _S2Phase.clock;
    timeIndex = -1;
    airRec.fillRange(0, _times, null);
    waterRec.fillRange(0, _times, null);
    readings = false;
    hourAngle = _hourAngles[0];
    hourAnim = null;
    roomFluid = labFluid = _fluidMin;
    roomAnim = labAnim = null;
    light = _s2Light[0];
    chartShown = false;
    sky = _Colors.skyBlue;
    skyAnim = null;
    sun = index == 0 ? _sunByDay[0] : _s2Sun[0];
    sunAnim = null;
    lifted = null;
    confetti.clear();
  }

  bool get spinning => time < spinStart + _spinSeconds;

  /// The value a reading chip shows.
  int value(_Handle h) => switch (h) {
    _Handle.max => _s1Data[day - 1].$1,
    _Handle.min => _s1Data[day - 1].$2,
    _Handle.air => _s2Data[timeIndex].$1,
    _Handle.water => _s2Data[timeIndex].$2,
  };

  /// The record a chip goes into (null if it has none yet).
  int? recorded(_Handle h) => switch (h) {
    _Handle.max => day > 0 ? maxRec[day - 1] : null,
    _Handle.min => day > 0 ? minRec[day - 1] : null,
    _Handle.air => timeIndex >= 0 ? airRec[timeIndex] : null,
    _Handle.water => timeIndex >= 0 ? waterRec[timeIndex] : null,
  };

  /// The chip is on show and can be picked up.
  bool ready(_Handle h) {
    if (h.isS1) {
      return scenario == 0 &&
          s1 == _S1Phase.recording &&
          day > 0 &&
          !spinning &&
          recorded(h) == null;
    }
    return scenario == 1 &&
        s2 == _S2Phase.recording &&
        readings &&
        recorded(h) == null;
  }

  /// The S1 digits are spinning on the station's screen.
  bool spinningOn(_Handle h) =>
      h.isS1 && scenario == 0 && s1 == _S1Phase.recording && spinning;

  _Proj get proj => _Proj(framing);

  /// Design point of a reading chip in the current framing, or null while
  /// it cannot be picked up (used by the instruction-flow tests).
  Offset? handlePoint(String id) {
    final h = _Handle.values.byName(id);
    return ready(h) ? proj.p(h.anchor) : null;
  }

  /// Design point of the wall clock in the current framing (tests).
  Offset get clockPoint => proj.p(_clockCenter);

  void setFraming(_Framing target, {required bool snap}) {
    if (snap) {
      framing = _from = _to = target;
      _framingT = 1;
      return;
    }
    if (target.closeTo(_to)) return;
    _from = framing;
    _to = target;
    _framingT = 0;
  }

  void burstConfetti() {
    confetti.clear();
    confettiStart = time;
    final random = math.Random(7);
    for (var i = 0; i < _confettiCount; i++) {
      confetti.add(
        _Confetto(
          _confettiOrigin.dx,
          _confettiOrigin.dy,
          -math.pi / 2 + (random.nextDouble() - 0.5) * _confettiSpread,
          _confettiSpeed * (0.5 + random.nextDouble() * 0.5),
          _Colors.confetti[i % _Colors.confetti.length],
          random.nextDouble() * 10,
        ),
      );
    }
  }

  /// TWEEN.update() plus the framing and confetti. True while anything on
  /// the canvas moves (the reading chips pulse while they are shown).
  bool advance(double dt) {
    final now = time;
    var moving = false;
    if (skyAnim case final a?) {
      sky = a.at(now);
      if (a.isDone(now)) skyAnim = null;
      moving = true;
    }
    if (sunAnim case final a?) {
      sun = a.at(now);
      if (a.isDone(now)) sunAnim = null;
      moving = true;
    }
    if (hourAnim case final a?) {
      hourAngle = a.at(now);
      if (a.isDone(now)) hourAnim = null;
      moving = true;
    }
    if (roomAnim case final a?) {
      roomFluid = a.at(now);
      if (a.isDone(now)) roomAnim = null;
      moving = true;
    }
    if (labAnim case final a?) {
      labFluid = a.at(now);
      if (a.isDone(now)) labAnim = null;
      moving = true;
    }
    if (_framingT < 1) {
      _framingT = math.min(1, _framingT + dt / _framingSeconds);
      framing = _from.lerpTo(_to, Curves.easeInOutCubic.transform(_framingT));
      moving = true;
    }
    if (confetti.isNotEmpty) {
      if (now - confettiStart > _confettiSeconds) {
        confetti.clear();
      } else {
        final frames = dt * 60;
        final decay = math.pow(_confettiDecay, frames).toDouble();
        for (final c in confetti) {
          c
            ..x += math.cos(c.angle) * c.speed * frames
            ..y +=
                math.sin(c.angle) * c.speed * frames + _confettiGravity * frames
            ..speed *= decay
            ..wobble += 0.1 * frames;
        }
      }
      moving = true;
    }
    final pulsing =
        (scenario == 0 && s1 == _S1Phase.recording) ||
        (scenario == 1 && (s2 == _S2Phase.clock || readings));
    return moving || pulsing;
  }
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
}

/// Where the scene sits on the stage: the base (HTML) projection moved to
/// [center] and scaled by [zoom], so it fits beside the floating cards.
@immutable
class _Framing {
  const _Framing(this.center, this.zoom);

  final Offset center;
  final double zoom;

  static const _Framing base = _Framing(_designCenter, 1);

  _Framing lerpTo(_Framing o, double t) =>
      _Framing(Offset.lerp(center, o.center, t)!, zoom + (o.zoom - zoom) * t);

  bool closeTo(_Framing o) =>
      (center - o.center).distance < 0.5 && (zoom - o.zoom).abs() < 0.002;
}

/// The HTML PerspectiveCamera as a pinhole projection onto the design
/// stage, in a [_Framing].
@immutable
class _Proj {
  const _Proj(this.framing);

  final _Framing framing;

  static final _V _f = (_camTarget - _camEye).unit;
  static final _V _r = _f.cross(_up).unit;
  static final _V _u = _r.cross(_f);

  /// Camera position (for back-face tests).
  _V get eye => _camEye;

  double depth(_V w) => (w - _camEye).dot(_f);

  /// Design pixels per world unit at [w].
  double scaleAt(_V w) => _focal * framing.zoom / math.max(_near, depth(w));

  Offset p(_V w) {
    final d = w - _camEye;
    final k = _focal * framing.zoom / math.max(_near, d.dot(_f));
    return Offset(
      framing.center.dx + d.dot(_r) * k,
      framing.center.dy - d.dot(_u) * k,
    );
  }
}

/// Best framing for [focus] (base projection) inside [free], clear of the
/// [obstacles] (all in design coordinates): the largest zoom (at most
/// [_maxZoom]) of the free rectangles left once the obstacles are cut out.
_Framing _fitFraming(Rect focus, Rect free, List<Rect> obstacles) {
  if (free.width <= 1 || free.height <= 1) return _Framing.base;
  var rects = [free];
  for (final o in obstacles) {
    final next = <Rect>[];
    for (final r in rects) {
      if (!r.overlaps(o)) {
        next.add(r);
        continue;
      }
      if (o.left > r.left + 1) {
        next.add(Rect.fromLTRB(r.left, r.top, o.left, r.bottom));
      }
      if (o.right < r.right - 1) {
        next.add(Rect.fromLTRB(o.right, r.top, r.right, r.bottom));
      }
      if (o.top > r.top + 1) {
        next.add(Rect.fromLTRB(r.left, r.top, r.right, o.top));
      }
      if (o.bottom < r.bottom - 1) {
        next.add(Rect.fromLTRB(r.left, o.bottom, r.right, r.bottom));
      }
    }
    rects = next;
  }
  (Rect, double)? pick;
  for (final r in rects) {
    final z = math.min(
      _maxZoom,
      math.min(r.width / focus.width, r.height / focus.height),
    );
    if (pick == null ||
        z > pick.$2 + 1e-6 ||
        ((z - pick.$2).abs() <= 1e-6 &&
            r.width * r.height > pick.$1.width * pick.$1.height)) {
      pick = (r, z);
    }
  }
  if (pick == null || pick.$2 <= 0) return _Framing.base;
  final (rect, zoom) = pick;
  return _Framing(rect.center - (focus.center - _designCenter) * zoom, zoom);
}

/// The reading chip in the finger (canvas px): drawn above the cards.
@immutable
class _Lift {
  const _Lift(this.at, this.text, this.color, this.fontPx);

  final Offset at;
  final String text;
  final Color color;

  /// Font size on screen (logical px) before the 1.2× lift.
  final double fontPx;

  _Lift moved(Offset to) => _Lift(to, text, color, fontPx);
}

// ------------------------------------------------------------- page state

class _Ch7A6PageState
    extends State<Ch7A6AirTemperatureMeasurementAndAnalysisPage>
    with SingleTickerProviderStateMixin {
  final LabController _lab = LabController(style: _style, camLocked: true);
  final _Scene _scene = _Scene();
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final ValueNotifier<_Lift?> _lift = ValueNotifier(null);
  final _TextCache _text = _TextCache();
  late final Ticker _ticker;

  /// The canvas area (the drag layer, a full-size overlay) and the data
  /// card: measured to fit the scene beside the cards and to map drops.
  final GlobalKey _canvasKey = GlobalKey(debugLabel: 'ch7a6-canvas');
  final GlobalKey _cardKey = GlobalKey(debugLabel: 'ch7a6-card');

  /// Table cells by id ('s1-r3-max', 's2-r2-water'): drop targets.
  final Map<String, GlobalKey> _cellKeys = {};

  /// Stage scale (design px → logical px).
  double _fit = 1;

  /// Accordion cards the learner opened or closed by hand (step numbers).
  final Set<int> _toggledSteps = {};

  /// The scene changed outside a running tween: repaint on the next tick.
  bool _dirty = true;
  bool _framingQueued = false;
  bool _snapFraming = true;

  // Drag of a reading chip.
  Offset? _downAt;
  Offset _lastGlobal = Offset.zero;
  _Handle? _dragging;

  /// Key, parameters, style and language of the lab's last toast: a
  /// language switch re-shows it translated.
  String? _toastKey;
  Map<String, Object> _toastParams = const {};
  String _toastText = '';
  bool _toastError = false;
  LabLang _toastLang = LabLang.en;

  String _t(String key) => _lab.tr(_i18n, key);
  LabScenarioData get _data => _scenarios[_lab.lang]![_scene.scenario];

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
    _ticker = createTicker(_onTick)..start();
    _lab.addListener(_retranslateToast);
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
    _lab.removeListener(_retranslateToast);
    _ticker.dispose();
    _frame.dispose();
    _lift.dispose();
    _text.dispose();
    _lab.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- frames

  /// HTML `animate()` + `TWEEN.update()`. Repaints only the canvas, and only
  /// while something moves.
  void _onTick(Duration elapsed) {
    final s = _scene;
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final dt = (now - s.time).clamp(0.0, 0.1);
    s.time = now;
    final moving = s.advance(dt);
    if (moving || _dirty) {
      _dirty = false;
      _frame.value++;
    }
  }

  /// Every state change also redraws the canvas: the painter reads the
  /// mutable scene, so `shouldRepaint` cannot see it change.
  @override
  void setState(VoidCallback fn) {
    _dirty = true;
    super.setState(fn);
  }

  /// Runs [fn] after [delay] unless the scenario was changed meanwhile.
  void _after(Duration delay, VoidCallback fn) {
    final token = _scene.token;
    _lab.after(delay, () {
      if (!mounted || _scene.token != token) return;
      fn();
    });
  }

  void _goToStep(int step) {
    _scene.step = step;
    _toggledSteps.clear();
  }

  // ------------------------------------------------------------- framing

  /// Re-fits the scene after this frame (cards and canvas are laid out by
  /// then).
  void _scheduleFraming() {
    if (_framingQueued) return;
    _framingQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framingQueued = false;
      if (mounted) _updateFraming();
    });
  }

  /// Fits the scenario's focus into the part of the canvas no card covers:
  /// the tool column, the HUD (sidebar open), the floating mission card
  /// (sidebar collapsed), the data card and the canvas action card.
  void _updateFraming() {
    final canvas = _canvasKey.currentContext?.findRenderObject();
    if (canvas is! RenderBox || !canvas.hasSize) return;
    final size = canvas.size;
    final fit = math.min(
      size.width / _design.width,
      size.height / _design.height,
    );
    if (!(fit > 0) || !fit.isFinite) return;
    final origin = canvas.localToGlobal(Offset.zero);
    final stage = Offset(
      (size.width - _design.width * fit) / 2,
      (size.height - _design.height * fit) / 2,
    );
    Rect toDesign(Rect r) => Rect.fromLTRB(
      (r.left - stage.dx) / fit,
      (r.top - stage.dy) / fit,
      (r.right - stage.dx) / fit,
      (r.bottom - stage.dy) / fit,
    );
    final s = context.labScale;
    final pad = MediaQuery.paddingOf(context);
    final screen = MediaQuery.sizeOf(context);
    final insets = labOverlayInsets(context, _lab);
    final open = _lab.isSidebarOpen;
    final free = Rect.fromLTRB(
      8 + (open ? 0 : pad.left),
      8 + pad.top,
      size.width - insets.right,
      size.height - (open ? _hudBand * s + 8 : 8) - pad.bottom,
    );
    final obstacles = <Rect>[];
    if (_lab.isLabActive) {
      if (!open) {
        final bottom = screen.height < _compactBelow
            ? _missionTop + pad.top + screen.height * _compactCardMax
            : size.height;
        obstacles.add(Rect.fromLTRB(0, 0, insets.left, bottom));
      }
      final card = _cardKey.currentContext?.findRenderObject();
      if (card is RenderBox && card.hasSize && card.attached) {
        obstacles.add((card.localToGlobal(Offset.zero) - origin) & card.size);
      }
      final slot = _actionSlot(context);
      if (slot != null) obstacles.add(slot);
    }
    final target = _fitFraming(
      _scene.scenario == 0 ? _focusS1 : _focusS2,
      toDesign(free).intersect(_stageRect),
      [for (final r in obstacles) toDesign(r.inflate(_cardGap))],
    );
    _scene.setFraming(target, snap: _snapFraming);
    _snapFraming = false;
    _dirty = true;
  }

  // ------------------------------------------------------------------ toasts

  /// Shows the toast [key] in the current language. Normal toasts are
  /// silent (the HTML `showToast` plays nothing); errors play the wrong
  /// tone.
  void _toast(
    String key, {
    bool error = false,
    Map<String, Object> params = const {},
  }) {
    _toastKey = key;
    _toastParams = params;
    _toastError = error;
    _toastLang = _lab.lang;
    _toastText = labFormat(_t(key), params);
    _lab.showToast(_toastText, isError: error, sound: error);
  }

  /// After a language switch, the toast still on screen is shown again in
  /// the new language (silently, after the current frame).
  void _retranslateToast() {
    final key = _toastKey;
    if (key == null || _lab.lang == _toastLang) return;
    _toastLang = _lab.lang;
    final shown = _lab.toast;
    if (shown == null || shown.text != _toastText) return;
    final error = _toastError;
    final params = _localParams(_toastParams);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lab.toast?.id != shown.id) return;
      _toastKey = key;
      _toastText = labFormat(_t(key), params);
      _lab.showToast(_toastText, isError: error, sound: false);
    });
  }

  /// Toast parameters in the current language (a row's time).
  Map<String, Object> _localParams(Map<String, Object> params) => {
    for (final e in params.entries)
      e.key: e.key == 'time' ? _t('time_${_scene.timeIndex + 1}') : e.value,
  };

  // ---------------------------------------------------------------- logic

  /// HTML `changeScenario(id)` (also Enter Lab, Restart Lab and Reset Lab):
  /// cancels every pending timer and rebuilds the scenario at step 1.
  void _loadScenario(int index) {
    _lab.cancelPending();
    _lab.hidePopup(sound: false);
    _dragging = null;
    _lift.value = null;
    _toastKey = null;
    setState(() {
      _scene.load(index);
      _toggledSteps.clear();
    });
    _lab.resetView(sound: false);
    _snapFraming = true;
    _scheduleFraming();
  }

  /// HTML `triggerMainAction()` on step 1: Day 1 on the station.
  void _start() {
    final s = _scene;
    if (s.scenario != 0 || s.s1 != _S1Phase.start) return;
    setState(() {
      _goToStep(2);
      s
        ..day = 1
        ..spinStart = s.time
        ..s1 = _S1Phase.recording;
    });
  }

  /// HTML `advanceDay()`: the next day's weather in the window, new digits.
  void _nextDay() {
    final s = _scene;
    if (s.scenario != 0 || s.s1 != _S1Phase.nextDay) return;
    setState(() {
      s
        ..day += 1
        ..spinStart = s.time
        ..s1 = _S1Phase.recording
        ..skyAnim = _Anim(
          s.sky,
          _skyFor(s.day, fastForward: false),
          s.time,
          _skySecondsNextDay,
          _lerpColor,
        )
        ..sunAnim = _Anim(
          s.sun,
          _sunByDay[s.day - 1],
          s.time,
          _skySecondsNextDay,
          _lerpOffset,
        );
      if (s.step == 4) _goToStep(5);
    });
  }

  /// HTML `fastForwardS1()`: Days 4–10 fill in 400 ms apart.
  void _fastForward() {
    final s = _scene;
    if (s.scenario != 0 || s.s1 != _S1Phase.fastForwardReady) return;
    setState(() => s.s1 = _S1Phase.fastForwarding);
    _toast('toast_fast_forward');
    for (var d = _handDays + 1; d <= _days; d++) {
      final dayNo = d;
      _after(_ffDayGap * (d - _handDays - 1), () {
        _Sound.click.play();
        setState(() {
          s
            ..day = dayNo
            ..maxRec[dayNo - 1] = _s1Data[dayNo - 1].$1
            ..minRec[dayNo - 1] = _s1Data[dayNo - 1].$2
            ..plotted = dayNo
            ..skyAnim = _Anim(
              s.sky,
              _skyFor(dayNo, fastForward: true),
              s.time,
              _skySecondsFastForward,
              _lerpColor,
            );
        });
      });
    }
    _after(_ffDayGap * (_days - _handDays) + _ffSettle, () {
      setState(() {
        _goToStep(6);
        s.s1 = _S1Phase.observe;
      });
    });
  }

  /// HTML `progressScenario1()` 1 s after a complete row.
  void _progressS1() {
    final s = _scene;
    setState(() {
      if (s.day == 1) {
        _goToStep(4);
        s.s1 = _S1Phase.nextDay;
      } else if (s.day < _handDays) {
        s.s1 = _S1Phase.nextDay;
      } else {
        s.s1 = _S1Phase.fastForwardReady;
      }
    });
  }

  /// HTML `triggerClockAction()`: the 9:00 AM reading.
  void _readClock() {
    final s = _scene;
    if (s.scenario != 1 || s.s2 != _S2Phase.clock) return;
    _Sound.click.play();
    setState(() {
      _goToStep(2);
      s.timeIndex = 0;
    });
    _setupTime();
  }

  /// HTML `advanceTime()`: the clock, sun, sky and light move on.
  void _advanceTime() {
    final s = _scene;
    if (s.scenario != 1 || s.s2 != _S2Phase.advance) return;
    setState(() {
      s.timeIndex += 1;
      final i = s.timeIndex;
      // The HTML jumped to step 7 here, before the 4 PM values were
      // recorded; step 6 now lasts until they are.
      _goToStep(i == 1 ? 5 : 6);
      s
        ..hourAnim = _Anim(
          s.hourAngle,
          _hourAngles[i],
          s.time,
          _advanceSeconds,
          _lerpDouble,
          _cubicInOut,
        )
        ..sunAnim = _Anim(
          s.sun,
          _s2Sun[i],
          s.time,
          _advanceSeconds,
          _lerpOffset,
        )
        ..skyAnim = _Anim(s.sky, _s2Sky[i], s.time, _advanceSeconds, _lerpColor)
        ..light = _s2Light[i];
    });
    _setupTime();
  }

  /// HTML `setupTimeData()`: the liquids rise or fall to the new readings
  /// over 1 s, then the readings appear with a hint.
  void _setupTime() {
    final s = _scene;
    final (air, water) = _s2Data[s.timeIndex];
    setState(() {
      s
        ..s2 = _S2Phase.recording
        ..readings = false
        ..roomAnim = _Anim(
          s.roomFluid,
          math.max(_fluidMin, air / _fluidFull),
          s.time,
          _fluidSeconds,
          _lerpDouble,
          _quadOut,
        )
        ..labAnim = _Anim(
          s.labFluid,
          math.max(_fluidMin, water / _fluidFull),
          s.time,
          _fluidSeconds,
          _lerpDouble,
          _quadOut,
        );
    });
    _after(_readingDelay, () {
      setState(() => s.readings = true);
      _toast('toast_drag_room');
    });
  }

  /// HTML `progressScenario2()` 1 s after a complete row.
  void _progressS2() {
    final s = _scene;
    setState(() {
      switch (s.timeIndex) {
        case 0:
          _goToStep(4);
          s.s2 = _S2Phase.advance;
        case 1:
          _goToStep(6);
          s.s2 = _S2Phase.advance;
        default:
          // HTML `drawBarChart()` and the chart container shown.
          _goToStep(7);
          s
            ..chartShown = true
            ..s2 = _S2Phase.observe;
      }
    });
  }

  /// A reading dropped into its own cell (HTML pointerup → checkDrop).
  void _record(_Handle h) {
    final s = _scene;
    _Sound.pop.play();
    setState(() {
      final v = s.value(h);
      switch (h) {
        case _Handle.max:
          s.maxRec[s.day - 1] = v;
        case _Handle.min:
          s.minRec[s.day - 1] = v;
        case _Handle.air:
          s.airRec[s.timeIndex] = v;
        case _Handle.water:
          s.waterRec[s.timeIndex] = v;
      }
      // Steps 2 → 3 ask for the maximum / air reading first; the HTML took
      // both in any order and never showed step 3.
      final first = h.isS1 ? s.maxRec[0] : s.airRec[0];
      final onFirstRow = h.isS1 ? s.day == 1 : s.timeIndex == 0;
      if (onFirstRow && s.step == 2 && first != null) _goToStep(3);
    });
    final rowDone = h.isS1
        ? s.maxRec[s.day - 1] != null && s.minRec[s.day - 1] != null
        : s.airRec[s.timeIndex] != null && s.waterRec[s.timeIndex] != null;
    if (!rowDone) {
      if (h == _Handle.air) _toast('toast_drag_water');
      return;
    }
    _Sound.success.play();
    setState(() {
      if (h.isS1) {
        s
          ..plotted = s.day
          ..s1 = _S1Phase.review;
        if (s.day == 1) _goToStep(3);
      } else {
        s.s2 = _S2Phase.review;
        if (s.timeIndex == 0) _goToStep(3);
      }
    });
    _after(_rowReview, h.isS1 ? _progressS1 : _progressS2);
  }

  /// HTML `triggerConclusion()` ('Observe Conclusion'): the summary with
  /// the scenario's graph; confetti after the last scenario. The button
  /// stays to open the summary again.
  void _showConclusion() {
    final s = _scene;
    final sc = s.scenario;
    final done = sc == 0 ? s.s1 == _S1Phase.observe : s.s2 == _S2Phase.observe;
    if (!done) return;
    if (sc == 1) s.burstConfetti();
    _dirty = true;
    _lab.showScenarioConclusion(
      scenarioIndex: sc,
      totalScenarios: _scenarioCount,
      delay: _conclusionDelay,
      title: () => labFormat(_t('sc_complete'), {'n': sc + 1}),
      heading: () => _t('s${sc + 1}_headline'),
      body: () => _t('s${sc + 1}_summary'),
      extra: () =>
          _ConclusionChart(scenario: sc, scene: _scene, text: _text, t: _t),
    );
    _after(_conclusionDelay, () {
      setState(() => _goToStep(_stepCounts[sc] + 1));
    });
  }

  void _toggleStep(int i) {
    _Sound.pop.play();
    setState(() {
      if (!_toggledSteps.remove(i)) _toggledSteps.add(i);
    });
  }

  // ------------------------------------------------------- drag and drop

  /// Converts a global position into canvas coordinates (the drag layer).
  Offset _toCanvas(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box.globalToLocal(global) : global;
  }

  /// On-screen font size (logical px) of the reading chips.
  double get _chipFontDp =>
      _chipPx * _fit * _chipScale(_scene.framing.zoom, _fit);

  /// The reading chip under [at] (design px), if one can be picked up.
  _Handle? _handleAt(Offset at) {
    final s = _scene;
    final p = s.proj;
    final radius = math.max(
      _chipHitPx * s.framing.zoom,
      _touchDp / math.max(_fit, 0.01),
    );
    _Handle? best;
    var bestD = double.infinity;
    for (final h in _Handle.values) {
      if (!s.ready(h)) continue;
      final d = (p.p(h.anchor) - at).distance;
      if (d <= radius && d < bestD) {
        best = h;
        bestD = d;
      }
    }
    return best;
  }

  void _onPanDown(DragDownDetails d) {
    _downAt = d.localPosition;
    _lastGlobal = d.globalPosition;
  }

  /// HTML pointerdown on a `.drag-num`: the reading lifts into the finger
  /// and its cells are highlighted.
  void _onPanStart(DragStartDetails d) {
    final h = _handleAt(_downAt ?? d.localPosition);
    if (h == null) return;
    _dragging = h;
    _lastGlobal = d.globalPosition;
    setState(() => _scene.lifted = h);
    _lift.value = _Lift(
      _toCanvas(d.globalPosition),
      _chipText(h),
      _chipColor(h),
      _chipFontDp,
    );
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragging == null) return;
    _lastGlobal = d.globalPosition;
    _lift.value = _lift.value?.moved(_toCanvas(d.globalPosition));
  }

  void _onPanEnd() {
    final h = _dragging;
    if (h == null) return;
    _dragging = null;
    _lift.value = null;
    _drop(h, _lastGlobal);
  }

  void _onPanCancel() {
    if (_dragging == null) return;
    _dragging = null;
    _lift.value = null;
    setState(() => _scene.lifted = null);
  }

  /// HTML pointerup: a reading dropped on its own cell is recorded; one
  /// dropped on another cell goes back with a hint (the HTML sent it back
  /// silently); elsewhere it just goes back.
  void _drop(_Handle h, Offset global) {
    setState(() => _scene.lifted = null);
    final target = _targetCell(h);
    final hit = _cellAt(global, prefer: target);
    if (hit == target) {
      _record(h);
      return;
    }
    if (hit == null) return;
    final s = _scene;
    final key = switch (h) {
      _Handle.max => 'err_cell_max',
      _Handle.min => 'err_cell_min',
      _Handle.air => 'err_cell_air',
      _Handle.water => 'err_cell_water',
    };
    _toast(
      key,
      error: true,
      params: h.isS1 ? {'n': s.day} : {'time': _t('time_${s.timeIndex + 1}')},
    );
  }

  /// Cell id of row [row] (1-based) and column [col] in [scenario].
  static String _cellId(int scenario, int row, int col) {
    final kind = scenario == 0
        ? (col == 0 ? 'max' : 'min')
        : (col == 0 ? 'air' : 'water');
    return 's${scenario + 1}-r$row-$kind';
  }

  String _targetCell(_Handle h) {
    final s = _scene;
    final row = h.isS1 ? s.day : s.timeIndex + 1;
    return _cellId(h.isS1 ? 0 : 1, row, h.column);
  }

  GlobalKey _cellKey(String id) =>
      _cellKeys.putIfAbsent(id, () => GlobalKey(debugLabel: 'ch7a6-$id'));

  /// The table cell under [global] (logical px), trying [prefer] first.
  String? _cellAt(Offset global, {required String prefer}) {
    bool inside(String id) {
      final box = _cellKeys[id]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return false;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      return rect.inflate(_dropSlack).contains(global);
    }

    if (inside(prefer)) return prefer;
    final sc = _scene.scenario;
    final rows = sc == 0 ? _days : _times;
    for (var r = 1; r <= rows; r++) {
      for (var c = 0; c < 2; c++) {
        final id = _cellId(sc, r, c);
        if (inside(id)) return id;
      }
    }
    return null;
  }

  String _chipText(_Handle h) =>
      h.isS1 ? '${_scene.value(h)}' : '${_scene.value(h)}°C';

  /// HTML `.drag-num` colours: red-500 / blue-500 (S1), sky-500 /
  /// emerald-500 (S2).
  static Color _chipColor(_Handle h) => switch (h) {
    _Handle.max => _Colors.red500,
    _Handle.min => _Colors.blue500,
    _Handle.air => _Colors.sky500,
    _Handle.water => _Colors.emerald500,
  };

  /// A tap on the stage: the wall clock in S2 step 1 (HTML clock button).
  void _onStageTap(Offset at) {
    final s = _scene;
    if (s.scenario != 1 || s.s2 != _S2Phase.clock) return;
    final p = s.proj;
    final radius = math.max(
      (_clockR + 0.6) * p.scaleAt(_clockCenter),
      _touchDp / math.max(_fit, 0.01),
    );
    if ((p.p(_clockCenter) - at).distance <= radius) _readClock();
  }

  // -------------------------------------------------------------------- UI

  /// The HTML main action button (`#btn-action-main`) for the current
  /// state, or null while the learner drags, waits or watches.
  LabAction? _mainAction() {
    final s = _scene;
    LabAction action(String key, IconData icon, VoidCallback onTap) =>
        LabAction(
          label: _t(key),
          icon: icon,
          color: _Colors.blue600,
          foreground: _Colors.white,
          highlight: true,
          onTap: onTap,
        );
    if (s.scenario == 0) {
      return switch (s.s1) {
        _S1Phase.start => action('btn_start', Icons.play_arrow, _start),
        _S1Phase.nextDay => action('btn_next_day', Icons.skip_next, _nextDay),
        _S1Phase.fastForwardReady => action(
          'btn_ff',
          Icons.fast_forward,
          _fastForward,
        ),
        _S1Phase.observe => action(
          'btn_conclude',
          Icons.insights,
          _showConclusion,
        ),
        _ => null,
      };
    }
    return switch (s.s2) {
      _S2Phase.advance => action(
        s.timeIndex == 0 ? 'btn_adv_1pm' : 'btn_adv_4pm',
        Icons.update,
        _advanceTime,
      ),
      _S2Phase.observe => action(
        'btn_conclude',
        Icons.insights,
        _showConclusion,
      ),
      _ => null,
    };
  }

  /// The HTML clock button (`#btn-action-clock`), for the sidebar and the
  /// mission card; on the canvas the clock itself is tapped.
  LabAction? _clockAction() {
    final s = _scene;
    if (s.scenario != 1 || s.s2 != _S2Phase.clock) return null;
    return LabAction(
      label: _t('btn_clock'),
      icon: Icons.schedule,
      color: _Colors.blue600,
      foreground: _Colors.white,
      highlight: true,
      silent: true,
      onTap: _readClock,
    );
  }

  /// Width of the canvas (screen minus the sidebar, as the shell sizes it).
  double _canvasWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (!_lab.isSidebarOpen) return w;
    final min = math.max(180.0, w * 0.2);
    final max = math.max(min, w * 0.5);
    return w - (w * _lab.sidebarFraction).clamp(min, max);
  }

  /// Top of the floating cards (canvas px): below the toast band.
  double _cardTop(BuildContext context) =>
      labOverlayInsets(context, _lab).top + _toastClear * context.labScale;

  /// Where the canvas action card goes (canvas px), while the sidebar is
  /// open and the canvas is wide enough for it beside the data card;
  /// reserved even while no action is shown, so the scene does not jump.
  Rect? _actionSlot(BuildContext context) {
    if (!_lab.isSidebarOpen || !_lab.isLabActive) return null;
    final s = context.labScale;
    final inset = labOverlayInsets(context, _lab);
    final width = _actionCardWidth * s;
    final room =
        _canvasWidth(context) -
        inset.left -
        inset.right -
        _DataCard.widthFor(_scene, s) -
        2 * _cardGap;
    if (room < width) return null;
    return Rect.fromLTWH(
      inset.left,
      _cardTop(context),
      width,
      _actionCardHeight * s,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lab,
      builder: (context, _) {
        final data = _data;
        final s = _scene;
        final sc = s.scenario;
        final scale = context.labScale;
        final steps = _stepCounts[sc];
        _scheduleFraming();
        return LabShell(
          controller: _lab,
          icon: Icons.thermostat,
          title: _t('app_title'),
          subtitle: _t('app_subtitle'),
          scenarioNames: [_t('scen_1_title'), _t('scen_2_title')],
          scenarioIndex: sc,
          onScenarioChanged: _loadScenario,
          objective: data.objective,
          steps: data.steps,
          currentStep: s.step,
          hud: _t('s${sc + 1}_hud_${s.step.clamp(1, steps)}'),
          // The last task line no longer applies once the conclusion opens.
          showHud: s.step <= steps,
          actions: [?_clockAction(), ?_mainAction()],
          sidebarExtraTitle: _t('concept_exp'),
          sidebarExtra: _StepsAccordion(
            steps: data.steps,
            currentStep: s.step,
            toggled: Set.of(_toggledSteps),
            onToggle: _toggleStep,
            t: _t,
            fontScale: _lab.fontScale,
          ),
          overlays: _overlays(context, scale),
          // HTML enterLab() and resetApp() start at Scenario 1.
          onEnterLab: () => _loadScenario(0),
          onReset: () => _loadScenario(0),
          stage: _stage(),
        );
      },
    );
  }

  /// The HTML data panel (`#panel-s1` / `#panel-s2`) at the top right, the
  /// main action button at the top left (sidebar open, wide canvas) and the
  /// drag layer that carries a reading above the cards.
  List<Widget> _overlays(BuildContext context, double scale) {
    final p = _lab.palette;
    final inset = labOverlayInsets(context, _lab);
    final top = _cardTop(context);
    final slot = _actionSlot(context);
    final main = _mainAction();
    return [
      if (_lab.isLabActive)
        Positioned(
          key: const ValueKey('ch7a6-data-card'),
          top: top,
          right: inset.right,
          child: _DataCard(
            key: _cardKey,
            scene: _scene,
            dragging: _dragging,
            cellKey: _cellKey,
            cellId: _cellId,
            text: _text,
            t: _t,
            scale: scale,
          ),
        ),
      if (slot != null && main != null && _lab.popup == null)
        Positioned(
          key: const ValueKey('ch7a6-action-card'),
          top: slot.top,
          left: slot.left,
          child: SizedBox(
            width: slot.width,
            child: LabGlassCard(
              palette: p,
              padding: EdgeInsets.all(_actionCardPad * scale),
              child: LabActionButton(action: main, scale: scale, dense: true),
            ),
          ),
        ),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            key: _canvasKey,
            painter: _LiftPainter(lift: _lift, text: _text),
          ),
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
        if (fit > 0 && fit.isFinite) _fit = fit;
        _scheduleFraming();
        return LabStage(
          designSize: _design,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The scene is described by its labels and the sidebar steps.
            excludeFromSemantics: true,
            onTapUp: (d) => _onStageTap(d.localPosition),
            onPanDown: _onPanDown,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => _onPanEnd(),
            onPanCancel: _onPanCancel,
            child: RepaintBoundary(
              child: CustomPaint(
                size: _design,
                painter: _ScenePainter(
                  scene: _scene,
                  text: _text,
                  repaint: _frame,
                  palette: _lab.palette,
                  showLabels: _lab.showLabels,
                  lang: _lab.lang,
                  stageFit: _fit,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Draw scale of the reading chips at framing [zoom] on a stage scaled by
/// [fit]: the HTML size, but never smaller than [_chipMinDp] on screen.
double _chipScale(double zoom, double fit) =>
    math.max(zoom, _chipMinDp / (_chipPx * math.max(fit, 0.01)));

/// Window sky for [day]: overcast on the cooler days of the record.
Color _skyFor(int day, {required bool fastForward}) {
  if (_s1Data[day - 1].$1 > _overcastMax) return _Colors.skyBlue;
  return fastForward ? _Colors.skySlate : _Colors.skyGrey;
}

// ------------------------------------------------------------ canvas cards

/// Canvas action card (the HTML floating `#btn-action-main`), × UI scale.
const double _actionCardWidth = 184;
const double _actionCardHeight = 70;
const double _actionCardPad = 8;

/// Data card layout (HTML `#panel-s1` / `#panel-s2`: title, table and
/// graph side by side so the card stays short on a phone), × UI scale.
const double _cardPad = 8;
const double _cardInnerGap = 6;
const double _cardTitlePx = 10;
const double _headRowH = 19;
const double _s1TableW = 134;
const double _s1RowH = 17;
const double _s2TableW = 170;
const double _s2RowH = 26;
const double _graphW = 150;
const double _cellPx = 10;

/// The HTML data panel: the scenario's table (drop targets) beside its
/// graph. S1 shows all ten days from the start (future days dimmed) so the
/// card keeps its size; the S2 bar chart appears once all three rows are
/// recorded, as in the HTML.
class _DataCard extends StatelessWidget {
  const _DataCard({
    super.key,
    required this.scene,
    required this.dragging,
    required this.cellKey,
    required this.cellId,
    required this.text,
    required this.t,
    required this.scale,
  });

  final _Scene scene;

  /// The reading in the finger: its row's cells are highlighted.
  final _Handle? dragging;
  final GlobalKey Function(String id) cellKey;
  final String Function(int scenario, int row, int col) cellId;
  final _TextCache text;
  final String Function(String key) t;
  final double scale;

  /// Card width at UI scale [s] (the framing reserves it).
  static double widthFor(_Scene scene, double s) {
    final table = scene.scenario == 0 ? _s1TableW : _s2TableW;
    final graph = scene.scenario == 0 || scene.chartShown
        ? _cardInnerGap + _graphW
        : 0;
    return (2 * _cardPad + table + graph) * s;
  }

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = scale;
    final sc = scene.scenario;
    final title = t(sc == 0 ? 's1_table_title' : 's2_table_title');
    final english = !_hasDevanagari(title);
    final rows = sc == 0 ? _days : _times;
    final rowH = (sc == 0 ? _s1RowH : _s2RowH) * s;
    final tableH = _headRowH * s + rows * rowH;
    final showGraph = sc == 0 || scene.chartShown;
    return Material(
      color: LabInk.clear,
      child: LabGlassCard(
        palette: p,
        padding: EdgeInsets.all(_cardPad * s),
        radius: 16,
        borderColor: p.cardBorder,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: widthFor(scene, s) - 2 * _cardPad * s,
              child: Text(
                english ? title.toUpperCase() : title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.accentInk,
                  fontSize: _cardTitlePx * s,
                  fontWeight: FontWeight.w900,
                  letterSpacing: labLetterSpacing(title, 0.8),
                ),
              ),
            ),
            SizedBox(height: _cardInnerGap * s),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: (sc == 0 ? _s1TableW : _s2TableW) * s,
                  child: _table(p, s, rowH),
                ),
                if (showGraph) ...[
                  SizedBox(width: _cardInnerGap * s),
                  SizedBox(
                    width: _graphW * s,
                    height: tableH,
                    child: _graphBox(p, s),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(LabPalette p, double s, double rowH) {
    final sc = scene.scenario;
    final rows = sc == 0 ? _days : _times;
    final grid = p.isDark ? _Colors.slate700 : _Colors.slate300;
    final headStyle = TextStyle(
      color: p.isDark ? _Colors.slate200 : _Colors.slate800,
      fontSize: _cellPx * s,
      fontWeight: FontWeight.w800,
      height: 1.1,
    );
    final leftColor = sc == 0
        ? (p.isDark ? _Colors.red400 : _Colors.red600)
        : (p.isDark ? _Colors.sky500 : _Colors.sky600);
    final rightColor = sc == 0
        ? (p.isDark ? _Colors.blue400 : _Colors.blue600)
        : (p.isDark ? _Colors.emerald500 : _Colors.emerald600);
    Widget head(String key, Color color) => SizedBox(
      height: _headRowH * s,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3 * s),
            child: Text(t(key), style: headStyle.copyWith(color: color)),
          ),
        ),
      ),
    );
    final active = _activeRow();
    final highlight = dragging != null;
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.15),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(color: grid),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: p.isDark ? _Colors.slate800 : _Colors.slate200,
          ),
          children: [
            head(sc == 0 ? 'tbl_day' : 'tbl_time', headStyle.color!),
            head(sc == 0 ? 'col_max' : 'col_air', leftColor),
            head(sc == 0 ? 'col_min' : 'col_water', rightColor),
          ],
        ),
        for (var r = 1; r <= rows; r++)
          _row(p, s, rowH, r, leftColor, rightColor, active, highlight),
      ],
    );
  }

  /// The row taking readings now (1-based), or null.
  int? _activeRow() {
    final s = scene;
    if (s.scenario == 0) {
      final taking = s.s1 == _S1Phase.recording || s.s1 == _S1Phase.review;
      return taking && s.day > 0 ? s.day : null;
    }
    final taking = s.s2 == _S2Phase.recording || s.s2 == _S2Phase.review;
    return taking && s.timeIndex >= 0 ? s.timeIndex + 1 : null;
  }

  TableRow _row(
    LabPalette p,
    double s,
    double rowH,
    int r,
    Color leftColor,
    Color rightColor,
    int? active,
    bool highlight,
  ) {
    final sc = scene.scenario;
    final reached = sc == 0 ? r <= scene.day : r <= scene.timeIndex + 1;
    final label = sc == 0 ? labFormat(t('day_n'), {'n': r}) : t('time_$r');
    final left = sc == 0 ? scene.maxRec[r - 1] : scene.airRec[r - 1];
    final right = sc == 0 ? scene.minRec[r - 1] : scene.waterRec[r - 1];
    final unit = sc == 0 ? '' : '°C';
    final stripe = r.isEven
        ? (p.isDark ? const Color(0x801E293B) : _Colors.slate50)
        : (p.isDark ? _Colors.slate900 : _Colors.white);
    final labelColor = p.isDark ? _Colors.slate400 : _Colors.slate600;
    Widget cell(int col, int? value, Color color) {
      final id = cellId(sc, r, col);
      final target = highlight && r == active;
      final shown = value == null ? '' : '$value$unit';
      return KeyedSubtree(
        key: ValueKey('ch7a6-cell-$id'),
        child: SizedBox(
          key: cellKey(id),
          height: rowH,
          child: CustomPaint(
            foregroundPainter: target ? _DashedCellPainter(p.accent) : null,
            child: ColoredBox(
              color: target
                  ? p.accent.withValues(alpha: 0.2)
                  : (r == active
                        ? p.accent.withValues(alpha: 0.08)
                        : LabInk.clear),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    shown,
                    style: TextStyle(
                      color: color,
                      fontSize: (_cellPx + 1) * s,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(color: stripe),
      children: [
        SizedBox(
          height: rowH,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * s),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: reached
                        ? labelColor
                        : labelColor.withValues(alpha: 0.45),
                    fontSize: _cellPx * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        cell(0, left, leftColor),
        cell(1, right, rightColor),
      ],
    );
  }

  Widget _graphBox(LabPalette p, double s) {
    final sc = scene.scenario;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate950 : _Colors.slate50,
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(
          color: p.isDark ? _Colors.slate700 : _Colors.slate300,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3 * s),
            child: Text(
              t(sc == 0 ? 'graph_title' : 'chart_title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _Colors.slate500,
                fontSize: 8.5 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: sc == 0
                ? CustomPaint(
                    key: const ValueKey('ch7a6-line-graph'),
                    size: Size.infinite,
                    painter: _LineGraphPainter(
                      plotted: scene.plotted,
                      text: text,
                      t: t,
                      isDark: p.isDark,
                      textScale: s,
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    key: const ValueKey('ch7a6-bar-chart'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    // HTML `.bar-air` transition: cubic-bezier(0.175,
                    // 0.885, 0.32, 1.275) = easeOutBack.
                    curve: Curves.easeOutBack,
                    builder: (context, grow, _) => CustomPaint(
                      size: Size.infinite,
                      painter: _BarChartPainter(
                        scene: scene,
                        grow: grow,
                        text: text,
                        t: t,
                        isDark: p.isDark,
                        textScale: s,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

bool _hasDevanagari(String s) => RegExp('[ऀ-ॿ]').hasMatch(s);

/// HTML `.drop-cell.active-target`: a dashed accent border.
class _DashedCellPainter extends CustomPainter {
  _DashedCellPainter(this.color);

  final Color color;
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color;
    final r = (Offset.zero & size).deflate(1.5);
    labDashedLine(canvas, r.topLeft, r.topRight, _paint, dash: 4, gap: 3);
    labDashedLine(canvas, r.topRight, r.bottomRight, _paint, dash: 4, gap: 3);
    labDashedLine(canvas, r.bottomRight, r.bottomLeft, _paint, dash: 4, gap: 3);
    labDashedLine(canvas, r.bottomLeft, r.topLeft, _paint, dash: 4, gap: 3);
  }

  @override
  bool shouldRepaint(covariant _DashedCellPainter old) => old.color != color;
}

/// The scenario's graph in the conclusion popup (the learner reads it with
/// the conclusion; the data card is behind the popup).
class _ConclusionChart extends StatelessWidget {
  const _ConclusionChart({
    required this.scenario,
    required this.scene,
    required this.text,
    required this.t,
  });

  final int scenario;
  final _Scene scene;
  final _TextCache text;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    return Container(
      height: 124 * s,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.isDark ? _Colors.slate950 : _Colors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: p.isDark ? _Colors.slate700 : _Colors.slate300,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4 * s),
            child: Text(
              t(scenario == 0 ? 'graph_title' : 'chart_title'),
              style: TextStyle(
                color: _Colors.slate500,
                fontSize: 10 * s,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: scenario == 0
                  ? _LineGraphPainter(
                      plotted: scene.plotted,
                      text: text,
                      t: t,
                      isDark: p.isDark,
                      textScale: s * 1.2,
                    )
                  : _BarChartPainter(
                      scene: scene,
                      grow: 1,
                      text: text,
                      t: t,
                      isDark: p.isDark,
                      textScale: s * 1.2,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ sidebar extra

/// Sidebar extra: the HTML "Observation Step" accordion (task, action and,
/// once the step is done, its result).
class _StepsAccordion extends StatelessWidget {
  const _StepsAccordion({
    required this.steps,
    required this.currentStep,
    required this.toggled,
    required this.onToggle,
    required this.t,
    required this.fontScale,
  });

  final List<LabStep> steps;
  final int currentStep;
  final Set<int> toggled;
  final ValueChanged<int> onToggle;
  final String Function(String key) t;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final p = LabStyleScope.of(context).palette;
    final s = context.labScale;
    final f = s * fontScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= steps.length; i++) ...[
          if (i > 1) SizedBox(height: 6 * s),
          _stepCard(p, s, f, i),
        ],
      ],
    );
  }

  /// One accordion card: past steps green with a check, the current one
  /// open, future ones greyed out and closed (HTML `updateTeacherBoard`).
  Widget _stepCard(LabPalette p, double s, double f, int i) {
    final past = i < currentStep;
    final current = i == currentStep;
    final future = i > currentStep;
    final open = !future && (current != toggled.contains(i));
    final tint = current ? p.accentInk : (past ? p.info : p.textMuted);
    final step = steps[i - 1];
    TextStyle body(Color color) => TextStyle(
      color: color,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    TextStyle head(Color color) => TextStyle(
      color: color,
      fontSize: 11.5 * f,
      fontWeight: FontWeight.w800,
      height: 1.4,
    );
    Widget line(String label, String text, Color labelColor, Color color) =>
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$label: ', style: head(labelColor)),
              TextSpan(text: text),
            ],
          ),
          style: body(color),
        );
    return Container(
      decoration: BoxDecoration(
        color: future ? p.card.withValues(alpha: p.card.a * 0.5) : p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? p.accent
              : (past ? p.info.withValues(alpha: 0.5) : p.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: future ? null : () => onToggle(i),
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
                                  ? p.info.withValues(alpha: 0.2)
                                  : p.cardBorder.withValues(alpha: 0.5)),
                        border: Border.all(color: current ? p.accent : tint),
                      ),
                      child: past
                          ? Icon(Icons.check, size: 13 * s, color: p.info)
                          : Text(
                              '$i',
                              style: TextStyle(
                                color: current ? p.onAccent : p.textMuted,
                                fontSize: 10.5 * s,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: Text(
                        '${t('exploration')} $i',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tint,
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
                      color: p.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              padding: EdgeInsets.fromLTRB(10 * s, 0, 10 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  line(t('concept_focus'), step.concept, p.accentInk, p.text),
                  SizedBox(height: 6 * s),
                  line(t('action'), step.action, p.textStrong, p.text),
                  SizedBox(height: 6 * s),
                  // The result is shown once it has been observed (the
                  // HTML showed it before the learner acted).
                  if (past)
                    line(
                      t('observation'),
                      step.observation,
                      p.textStrong,
                      p.textMuted,
                    )
                  else
                    Text(
                      t('obs_pending'),
                      style: body(
                        p.textMuted,
                      ).copyWith(fontStyle: FontStyle.italic),
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

/// Box faces: outward normal and four corners (in units of the half size).
const List<(_V, _V, _V, _V, _V)> _boxFaces = [
  (_V(1, 0, 0), _V(1, -1, 1), _V(1, -1, -1), _V(1, 1, -1), _V(1, 1, 1)),
  (_V(-1, 0, 0), _V(-1, -1, -1), _V(-1, -1, 1), _V(-1, 1, 1), _V(-1, 1, -1)),
  (_V(0, 1, 0), _V(-1, 1, 1), _V(1, 1, 1), _V(1, 1, -1), _V(-1, 1, -1)),
  (_V(0, -1, 0), _V(-1, -1, -1), _V(1, -1, -1), _V(1, -1, 1), _V(-1, -1, 1)),
  (_V(0, 0, 1), _V(-1, -1, 1), _V(1, -1, 1), _V(1, 1, 1), _V(-1, 1, 1)),
  (_V(0, 0, -1), _V(1, -1, -1), _V(-1, -1, -1), _V(-1, 1, -1), _V(1, 1, -1)),
];

const _V _faceFront = _V(0, 0, 1);

/// Points on a circle (unit radius), shared by every round shape.
const int _roundSegments = 28;
final List<(double, double)> _unitCircle = [
  for (var i = 0; i < _roundSegments; i++)
    (
      math.cos(2 * math.pi * i / _roundSegments),
      math.sin(2 * math.pi * i / _roundSegments),
    ),
];

/// Paints the HTML Three.js rooms: S1 the weather station in front of a
/// window, S2 the classroom (window, chalkboard, wall clock, wall
/// thermometer, beaker with a lab thermometer), the reading chips, the
/// floating labels and the S2 confetti.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.text,
    required Listenable repaint,
    required this.palette,
    required this.showLabels,
    required this.lang,
    required this.stageFit,
  }) : super(repaint: repaint);

  final _Scene scene;
  final _TextCache text;
  final LabPalette palette;
  final bool showLabels;
  final LabLang lang;

  /// Stage scale (design px → logical px): readings stay legible on small
  /// stages.
  final double stageFit;

  /// Draw scale of the reading chips (design px per chip px).
  double get _chipK => _chipScale(scene.framing.zoom, stageFit);

  /// Size (design px) of text that follows the scene's zoom: [px] at the
  /// HTML camera, at least [minDp] on screen.
  double _sceneText(double px, double minDp) =>
      math.max(px * scene.framing.zoom, minDp / math.max(stageFit, 0.01));

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Path _path = Path();

  late Canvas _c;
  late _Proj _p;

  String _s(String key) => labTr(_i18n, lang, key);

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    _p = scene.proj;
    _fill
      ..shader = null
      ..color = _Colors.slate900; // HTML scene.background 0x0f172a
    _c.drawRect(labBleed(size), _fill);
    if (scene.scenario == 0) {
      _paintScenario1();
    } else {
      _paintScenario2();
    }
    if (showLabels) _paintLabels();
    _paintChips();
    if (scene.scenario == 1 && scene.s2 == _S2Phase.clock) _clockPulse();
    if (scene.confetti.isNotEmpty) _paintConfetti();
  }

  // ------------------------------------------------------------ scenario 1

  void _paintScenario1() {
    final s = scene;
    // Wall (PlaneGeometry(80, 40) at (0, 20, −10)), larger so it fills the
    // stage at any framing.
    _flatRect(-150, 150, 0, 120, -10, _lit(_Colors.slate700, _faceFront));
    // Window: sky, sun, white frame.
    _windowContent(
      left: -15,
      right: 15,
      bottom: 4.5,
      top: 19.5,
      z: -9.9,
      sky: s.sky,
      paintInside: () => _disc(_V(s.sun.dx, s.sun.dy, -9.8), 2, _Colors.sun),
    );
    _box(const _V(0, 20, -9.5), const _V(16, 0.5, 0.5), _Colors.white);
    _box(const _V(0, 4, -9.5), const _V(16, 0.5, 0.5), _Colors.white);
    _box(const _V(-15.5, 12, -9.5), const _V(0.5, 8.5, 0.5), _Colors.white);
    _box(const _V(15.5, 12, -9.5), const _V(0.5, 8.5, 0.5), _Colors.white);
    // Desk (BoxGeometry(40, 2, 15) at y −1).
    _box(const _V(0, -1, 0), const _V(20, 1, 7.5), _Colors.desk, edge: 0.25);
    // Weather station: metal body and black screen.
    _box(_stationCenter, _stationHalf, _Colors.slate400, edge: 0.3);
    _flatRect(-4, 4, 2, 7, _screenZ, _Colors.black);
    if (s.day > 0 && s.s1 == _S1Phase.recording) _screenCaptions();
  }

  /// "MAX" / "MIN" above the two readings on the station's screen.
  void _screenCaptions() {
    for (final h in const [_Handle.max, _Handle.min]) {
      final at = _p.p(h.anchor + const _V(0, 2.0, 0));
      final k = _sceneText(_captionPx, _captionMinDp) / _captionPx;
      final tp = text.get(
        _s(h.caption),
        size: _captionPx,
        color: h == _Handle.max ? _Colors.red400 : _Colors.blue400,
        weight: FontWeight.w800,
        letterSpacing: labLetterSpacing(_s(h.caption), 0.6),
      );
      _c
        ..save()
        ..translate(at.dx, at.dy)
        ..scale(k);
      tp.paint(_c, Offset(-tp.width / 2, -tp.height / 2));
      _c.restore();
    }
  }

  // ------------------------------------------------------------ scenario 2

  void _paintScenario2() {
    final s = scene;
    // Classroom wall (PlaneGeometry(80, 40), beige).
    _flatRect(-150, 150, 0, 120, -10, _lit(_Colors.classWall, _faceFront));
    // Chalkboard: frame (25 × 15) and the board in front of it (the HTML
    // board sat inside its frame box and never showed).
    _box(const _V(12, 15, -9.9), const _V(12.5, 7.5, 0.25), _Colors.chalkFrame);
    _flatRect(0, 24, 8, 22, -9.6, _lit(_Colors.chalkboard, _faceFront));
    // Window at (−16, 15, −9.5): sky, sun and hill inside the glass, frame.
    const wx = -16.0, wy = 15.0;
    _windowContent(
      left: wx - 7,
      right: wx + 7,
      bottom: wy - 5,
      top: wy + 5,
      z: -9.4,
      sky: s.sky,
      paintInside: () {
        _disc(_V(wx + s.sun.dx, wy + s.sun.dy, -9.3), 1.5, _Colors.sun);
        _disc(
          const _V(wx, wy - 5, -9.25),
          6,
          _Colors.hill,
          scaleX: 1.5,
          scaleY: 0.5,
        );
      },
    );
    _box(const _V(wx, wy + 5.5, -9.2), const _V(8, 0.5, 0.25), _Colors.white);
    _box(const _V(wx, wy - 5.5, -9.2), const _V(8, 0.5, 0.25), _Colors.white);
    _box(const _V(wx - 7.5, wy, -9.2), const _V(0.5, 5, 0.25), _Colors.white);
    _box(const _V(wx + 7.5, wy, -9.2), const _V(0.5, 5, 0.25), _Colors.white);
    _wallClock();
    _wallThermometer();
    // Desk (BoxGeometry(60, 2, 20) at (0, −1, −2)).
    _box(const _V(0, -1, -2), const _V(30, 1, 10), _Colors.desk, edge: 0.25);
    _beaker();
  }

  /// HTML wall clock: red rim, white face, 12 ticks, hour and minute hands.
  void _wallClock() {
    final s = scene;
    const c = _clockCenter;
    _fill.color = _Colors.black.withValues(alpha: 0.2);
    _discPath(c + const _V(0.2, -0.2, -0.1), 2.6);
    _c.drawPath(_path, _fill);
    _disc(c + const _V(0, 0, 0.2), _clockR, _Colors.white);
    final k = _p.scaleAt(c);
    _stroke.color = _Colors.slate800;
    for (var i = 0; i < 12; i++) {
      final hour = i % 3 == 0;
      final a = i * math.pi / 6;
      final len = hour ? 0.6 : 0.3;
      final dir = _V(math.cos(a), math.sin(a), 0);
      _stroke.strokeWidth = math.max(0.8, (hour ? 0.15 : 0.08) * k);
      _c.drawLine(
        _p.p(c + dir * (2.0 - len / 2) + const _V(0, 0, 0.25)),
        _p.p(c + dir * (2.0 + len / 2) + const _V(0, 0, 0.25)),
        _stroke,
      );
    }
    // Hands (clockwise angle from 12).
    void hand(double angle, double length, double width, Color color) {
      final dir = _V(math.sin(angle), math.cos(angle), 0);
      _stroke
        ..color = color
        ..strokeWidth = math.max(1.2, width * k);
      _c.drawLine(
        _p.p(c + const _V(0, 0, 0.3)),
        _p.p(c + dir * length + const _V(0, 0, 0.3)),
        _stroke,
      );
    }

    hand(s.hourAngle * 12, 2.0, 0.12, _Colors.slate700);
    hand(s.hourAngle, 1.4, 0.2, _Colors.black);
    _disc(c + const _V(0, 0, 0.5), 0.15, _Colors.black);
    // Rim (TorusGeometry(2.5, 0.3)).
    _ring(c + const _V(0, 0, 0.15), _clockR - 0.3, _clockR + 0.3);
    _fill.color = _lit(_Colors.red500, _faceFront);
    _c.drawPath(_path, _fill);
  }

  /// HTML pulse-highlight around the clock button: a ring that grows and
  /// fades every 1.5 s while the clock waits to be tapped.
  void _clockPulse() {
    final phase = (scene.time % 1.5) / 1.5;
    final o = _p.p(_clockCenter);
    final r = (_clockR + 0.4) * _p.scaleAt(_clockCenter);
    _stroke
      ..strokeWidth = 3
      ..color = _Colors.blue500.withValues(alpha: 0.75 * (1 - phase));
    _c.drawCircle(o, r + 3 + 12 * phase, _stroke);
    _stroke
      ..strokeWidth = 2
      ..color = _Colors.blue500;
    _c.drawCircle(o, r + 2, _stroke);
  }

  /// HTML wall thermometer (air): white capsule, scale ticks, red liquid
  /// rising from the bulb.
  void _wallThermometer() {
    final s = scene;
    const c = _thermoCenter;
    // Capsule: 2.5 wide, a 10-long body with round ends.
    _path.reset();
    const r = 1.25, half = 5.0, z = 0.2;
    for (var i = 0; i <= 14; i++) {
      final a = math.pi * i / 14;
      final o = _p.p(c + _V(r * math.cos(a), half + r * math.sin(a), z));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    for (var i = 0; i <= 14; i++) {
      final a = math.pi + math.pi * i / 14;
      final o = _p.p(c + _V(r * math.cos(a), -half + r * math.sin(a), z));
      _path.lineTo(o.dx, o.dy);
    }
    _path.close();
    _shadow.color = _Colors.black.withValues(alpha: 0.25);
    _c.drawPath(_path.shift(const Offset(2, 3)), _shadow);
    _fill
      ..shader = null
      ..color = _lit(_Colors.slate50, _faceFront);
    _c.drawPath(_path, _fill);
    // Empty tube behind the liquid, so the scale reads as a column.
    _flatRect(-0.2, 0.2, -4, 5, c.z + 0.25, _Colors.slate200, base: c);
    // Ticks: 8 marks from y −2.5 to 4.5.
    final k = _p.scaleAt(c);
    _stroke
      ..color = _Colors.black
      ..strokeWidth = math.max(0.8, 0.06 * k);
    for (var i = 0; i < 8; i++) {
      final y = -2.5 + i * 1.0;
      _c.drawLine(
        _p.p(c + _V(-0.8, y, 0.3)),
        _p.p(c + _V(-0.2, y, 0.3)),
        _stroke,
      );
    }
    // Liquid: 9 tall at full scale, from the bulb (y −4).
    _flatRect(
      -0.2,
      0.2,
      -4,
      -4 + 9 * s.roomFluid,
      c.z + 0.3,
      _Colors.red500,
      base: c,
    );
    _sphere(c + const _V(0, -4, 0.2), 0.9, _Colors.red500);
  }

  /// HTML beaker of water with a lab thermometer (green liquid).
  void _beaker() {
    final s = scene;
    const b = _beakerBase;
    final axis = _V(math.sin(_labThermoTilt), math.cos(_labThermoTilt), 0);
    final centre = b + const _V(0, _labThermoCenterY, 0);
    final bulb = centre - axis * 6;
    // Shadow of the beaker on the desk.
    _discPathFlat(b + const _V(0.6, 0.01, 0.4), 3.1);
    _shadow.color = _Colors.black.withValues(alpha: 0.3);
    _c.drawPath(_path, _shadow);
    // Thermometer: glass tube, liquid from the bulb, bulb.
    _tube(bulb, centre + axis * 6, 0.3, _Colors.white.withValues(alpha: 0.5));
    final k = _p.scaleAt(centre);
    _stroke
      ..color = _Colors.emerald500
      ..strokeWidth = math.max(1.5, 0.24 * k)
      ..strokeCap = StrokeCap.butt;
    _c.drawLine(_p.p(bulb), _p.p(bulb + axis * (11 * s.labFluid)), _stroke);
    _stroke.strokeCap = StrokeCap.round;
    _sphere(bulb, 0.6, _Colors.emerald500);
    // Water (r 2.9, 4.5 deep) over the lower part of the thermometer.
    _cylinderY(b, 2.9, 4.5, _Colors.sky500.withValues(alpha: 0.7));
    // Glass (r 3, 6 tall, open), drawn last so it tints what is inside.
    _cylinderY(b, 3, 6, _Colors.white.withValues(alpha: 0.18), rim: true);
  }

  // ------------------------------------------------------------ window

  /// A window's glass with [sky], what [paintInside] draws clipped to the
  /// glass (sun, hill).
  void _windowContent({
    required double left,
    required double right,
    required double bottom,
    required double top,
    required double z,
    required Color sky,
    required VoidCallback paintInside,
  }) {
    _flatRect(left, right, bottom, top, z, sky);
    final clip = Path()
      ..moveTo(_p.p(_V(left, bottom, z)).dx, _p.p(_V(left, bottom, z)).dy)
      ..lineTo(_p.p(_V(right, bottom, z)).dx, _p.p(_V(right, bottom, z)).dy)
      ..lineTo(_p.p(_V(right, top, z)).dx, _p.p(_V(right, top, z)).dy)
      ..lineTo(_p.p(_V(left, top, z)).dx, _p.p(_V(left, top, z)).dy)
      ..close();
    _c
      ..save()
      ..clipPath(clip);
    paintInside();
    _c.restore();
  }

  // ------------------------------------------------------------ labels

  /// HTML floating labels (`.label-3d`). S2's labels sit beside each
  /// other's objects instead of on top of one another.
  void _paintLabels() {
    if (scene.scenario == 0) {
      _label('lbl_weather_station', _p.p(const _V(0, 9, 2)), Alignment.center);
      return;
    }
    _label(
      'lbl_wall_clock',
      _p.p(_clockCenter + const _V(0.8, 3.2, 0)),
      Alignment.bottomRight,
    );
    _label(
      'lbl_room_thermo',
      _p.p(_thermoCenter + const _V(-0.8, 6.8, 0)),
      Alignment.bottomLeft,
    );
    // Left of the beaker, on the wall above the desk: the HTML spot (above
    // the thermometer) ran into the room thermometer and its reading.
    _label(
      'lbl_water_thermo',
      _p.p(_beakerBase + const _V(-3.4, 4.5, 0)),
      Alignment.centerRight,
    );
  }

  /// A glass label chip with a blue tag icon, placed with [anchor] on [at].
  void _label(String key, Offset at, Alignment anchor) {
    // Laid out once at the HTML size and scaled with the scene, so the
    // text cache does not fill up while the scene re-fits itself.
    final k = _sceneText(_labelPx, _labelMinDp) / _labelPx;
    final label = _s(key);
    final tp = text.get(
      label,
      size: _labelPx,
      color: palette.labelText,
      weight: FontWeight.w800,
    );
    final icon = text.get(
      String.fromCharCode(Icons.sell.codePoint),
      size: _labelPx,
      color: _Colors.blue500,
      weight: FontWeight.w400,
      family: Icons.sell.fontFamily,
    );
    const padX = 7.0, padY = 4.0, gap = 4.0;
    final w = icon.width + gap + tp.width + 2 * padX;
    final h = tp.height + 2 * padY;
    final rect = Rect.fromLTWH(
      -(anchor.x + 1) / 2 * w,
      -(anchor.y + 1) / 2 * h,
      w,
      h,
    );
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(7));
    _c
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(k);
    _shadow.color = _Colors.black.withValues(alpha: 0.3);
    _c.drawRRect(rr.shift(const Offset(0, 2)), _shadow);
    _fill
      ..shader = null
      ..color = palette.labelBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = palette.isDark ? _Colors.slate600 : _Colors.slate300;
    _c.drawRRect(rr, _stroke);
    icon.paint(_c, Offset(rect.left + padX, rect.center.dy - icon.height / 2));
    tp.paint(_c, Offset(rect.left + padX + icon.width + gap, rect.top + padY));
    _c.restore();
  }

  // ------------------------------------------------------------ chips

  /// The readings (HTML `.drag-num`), pulsing while they wait to be
  /// dragged; S1's digits spin first.
  void _paintChips() {
    final s = scene;
    for (final h in _Handle.values) {
      if (s.lifted == h) continue;
      final spin = s.spinningOn(h);
      if (!spin && !s.ready(h)) continue;
      final value = spin ? _spinDigit(h) : s.value(h);
      final label = h.isS1 ? '$value' : '$value°C';
      final pulse = spin
          ? 1.0
          : 1 + 0.1 * math.pow(math.sin(math.pi * s.time / _pulseSeconds), 2);
      _chip(
        _p.p(h.anchor),
        label,
        _Ch7A6PageState._chipColor(h),
        _chipK * pulse,
      );
    }
  }

  /// HTML `Math.floor(Math.random() * 40)` while the digits spin.
  int _spinDigit(_Handle h) {
    final tick = (scene.time / _spinTick).floor();
    return (tick * 7919 + h.index * 104729) % 40;
  }

  /// A reading chip centred on [at]: bold coloured digits on a dark pill.
  void _chip(Offset at, String label, Color color, double k) {
    final tp = text.get(
      label,
      size: _chipPx,
      color: color,
      weight: FontWeight.w900,
    );
    final w = tp.width + 12, h = tp.height + 2;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      const Radius.circular(9),
    );
    _c
      ..save()
      ..translate(at.dx, at.dy)
      ..scale(k);
    _shadow.color = _Colors.black.withValues(alpha: 0.5);
    _c.drawRRect(rr.shift(const Offset(0, 4)), _shadow);
    _fill
      ..shader = null
      ..color = _Colors.chipBg;
    _c.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: 0.7);
    _c.drawRRect(rr, _stroke);
    tp.paint(_c, Offset(-tp.width / 2, -tp.height / 2));
    _c.restore();
  }

  // ------------------------------------------------------------ confetti

  void _paintConfetti() {
    final s = scene;
    final fade = 1 - ((s.time - s.confettiStart) / _confettiSeconds);
    if (fade <= 0) return;
    for (final c in s.confetti) {
      _fill
        ..shader = null
        ..color = c.color.withValues(alpha: fade.clamp(0.0, 1.0));
      _c
        ..save()
        ..translate(c.x, c.y)
        ..rotate(c.wobble)
        ..scale(1, 0.5 + 0.5 * math.cos(c.wobble * 1.3).abs());
      _c.drawRect(const Rect.fromLTWH(-5, -3.5, 10, 7), _fill);
      _c.restore();
    }
  }

  // ------------------------------------------------------------ primitives

  /// Lambert-style shade of [c] for a face with normal [n] (HTML ambient
  /// 0.6 + directional light; S2's light follows the time of day).
  Color _lit(Color c, _V n) {
    final s = scene;
    final direct = s.scenario == 0 ? _sunLight : s.light;
    final i = (_ambient + direct * math.max(0.0, n.dot(_lightDir))) * _exposure;
    final warm = s.scenario == 1 && s.timeIndex == 2
        ? _Colors.warmLight
        : _Colors.white;
    return Color.from(
      alpha: c.a,
      red: (c.r * i * warm.r).clamp(0.0, 1.0),
      green: (c.g * i * warm.g).clamp(0.0, 1.0),
      blue: (c.b * i * warm.b).clamp(0.0, 1.0),
    );
  }

  /// A flat rectangle facing the camera (x and y in world units at depth
  /// [z]); with [base] the coordinates are relative to it.
  void _flatRect(
    double x0,
    double x1,
    double y0,
    double y1,
    double z,
    Color color, {
    _V base = _V.zero,
  }) {
    final bz = base == _V.zero ? z : z - base.z;
    final a = _p.p(base + _V(x0, y0, bz));
    final b = _p.p(base + _V(x1, y0, bz));
    final c = _p.p(base + _V(x1, y1, bz));
    final d = _p.p(base + _V(x0, y1, bz));
    _path
      ..reset()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
  }

  /// Box centred at [c] with half sizes [h].
  void _box(_V c, _V h, Color color, {double edge = 0.35}) {
    _V corner(_V s) => c + _V(s.x * h.x, s.y * h.y, s.z * h.z);
    for (final (n, a, b, cc, d) in _boxFaces) {
      if (n.dot(_p.eye - corner(n)) <= 0) continue;
      final pa = _p.p(corner(a)), pb = _p.p(corner(b));
      final pc = _p.p(corner(cc)), pd = _p.p(corner(d));
      _path
        ..reset()
        ..moveTo(pa.dx, pa.dy)
        ..lineTo(pb.dx, pb.dy)
        ..lineTo(pc.dx, pc.dy)
        ..lineTo(pd.dx, pd.dy)
        ..close();
      final lit = _lit(color, n);
      _fill
        ..shader = null
        ..color = lit;
      _c.drawPath(_path, _fill);
      if (edge > 0) {
        _stroke
          ..strokeWidth = 0.8
          ..color = labShade(lit, -0.5).withValues(alpha: edge);
        _c.drawPath(_path, _stroke);
      }
    }
  }

  /// Circle of radius [r] in the plane facing the camera (z constant) into
  /// [_path], optionally stretched (HTML `hill.scale.set(1.5, 0.5, 1)`).
  void _discPath(_V c, double r, {double scaleX = 1, double scaleY = 1}) {
    _path.reset();
    for (var i = 0; i < _roundSegments; i++) {
      final (cx, cy) = _unitCircle[i];
      final o = _p.p(c + _V(cx * r * scaleX, cy * r * scaleY, 0));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
  }

  /// Circle of radius [r] lying flat (y constant) into [_path].
  void _discPathFlat(_V c, double r) {
    _path.reset();
    for (var i = 0; i < _roundSegments; i++) {
      final (cx, cz) = _unitCircle[i];
      final o = _p.p(c + _V(cx * r, 0, cz * r));
      if (i == 0) {
        _path.moveTo(o.dx, o.dy);
      } else {
        _path.lineTo(o.dx, o.dy);
      }
    }
    _path.close();
  }

  void _disc(
    _V c,
    double r,
    Color color, {
    double scaleX = 1,
    double scaleY = 1,
  }) {
    _discPath(c, r, scaleX: scaleX, scaleY: scaleY);
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
  }

  /// Flat ring between radii [r0] and [r1] (facing the camera) into
  /// [_path].
  void _ring(_V c, double r0, double r1) {
    _path
      ..reset()
      ..fillType = PathFillType.evenOdd;
    for (final r in [r1, r0]) {
      for (var i = 0; i < _roundSegments; i++) {
        final (cx, cy) = _unitCircle[i];
        final o = _p.p(c + _V(cx * r, cy * r, 0));
        if (i == 0) {
          _path.moveTo(o.dx, o.dy);
        } else {
          _path.lineTo(o.dx, o.dy);
        }
      }
      _path.close();
    }
  }

  /// Lit sphere (MeshStandardMaterial look).
  void _sphere(_V c, double r, Color color) {
    final o = _p.p(c);
    final radius = r * _p.scaleAt(c);
    _fill.shader = ui.Gradient.radial(
      o + Offset(-radius * 0.35, -radius * 0.4),
      radius * 1.3,
      [labShade(color, 0.45), color, labShade(color, -0.35)],
      const [0, 0.45, 1],
    );
    _c.drawCircle(o, radius, _fill);
    _fill.shader = null;
  }

  /// Upright cylinder standing on [base] (radius [r], height [h]):
  /// silhouette, top ellipse and, with [rim], the glass rims.
  void _cylinderY(
    _V base,
    double r,
    double h,
    Color color, {
    bool rim = false,
  }) {
    final top = base + _V(0, h, 0);
    final pts = <Offset>[];
    for (final (cx, cz) in _unitCircle) {
      pts
        ..add(_p.p(base + _V(cx * r, 0, cz * r)))
        ..add(_p.p(top + _V(cx * r, 0, cz * r)));
    }
    final hull = _hull(pts);
    if (hull.length < 3) return;
    _path
      ..reset()
      ..fillType = PathFillType.nonZero
      ..addPolygon(hull, true);
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
    _discPathFlat(top, r);
    _fill.color = labShade(color, 0.15);
    _c.drawPath(_path, _fill);
    if (!rim) return;
    _stroke
      ..strokeWidth = 1.2
      ..color = _Colors.white.withValues(alpha: 0.55);
    _c.drawPath(_path, _stroke);
    _discPathFlat(base + const _V(0, 0.05, 0), r);
    _stroke.color = _Colors.white.withValues(alpha: 0.3);
    _c.drawPath(_path, _stroke);
  }

  /// Glass tube from [a] to [b] (radius [r]).
  void _tube(_V a, _V b, double r, Color color) {
    final axis = (b - a).unit;
    final side = axis.cross(const _V(0, 0, 1)).unit;
    final pa = _p.p(a), pb = _p.p(b);
    final wa = r * _p.scaleAt(a), wb = r * _p.scaleAt(b);
    final dir = Offset(side.x, -side.y);
    _path
      ..reset()
      ..fillType = PathFillType.nonZero
      ..moveTo((pa + dir * wa).dx, (pa + dir * wa).dy)
      ..lineTo((pb + dir * wb).dx, (pb + dir * wb).dy)
      ..arcToPoint(pb - dir * wb, radius: Radius.circular(wb))
      ..lineTo((pa - dir * wa).dx, (pa - dir * wa).dy)
      ..close();
    _fill
      ..shader = null
      ..color = color;
    _c.drawPath(_path, _fill);
    _stroke
      ..strokeWidth = 1
      ..color = _Colors.white.withValues(alpha: 0.6);
    _c.drawPath(_path, _stroke);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.scene != scene ||
      old.palette != palette ||
      old.showLabels != showLabels ||
      old.lang != lang ||
      old.stageFit != stageFit;
}

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

/// The reading in the learner's finger, drawn above the cards (HTML: the
/// dragged `.drag-num` follows the pointer, 1.2× larger).
class _LiftPainter extends CustomPainter {
  _LiftPainter({required this.lift, required this.text}) : super(repaint: lift);

  final ValueListenable<_Lift?> lift;
  final _TextCache text;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()..style = PaintingStyle.stroke;
  final Paint _shadow = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  @override
  void paint(Canvas canvas, Size size) {
    final l = lift.value;
    if (l == null) return;
    final tp = text.get(
      l.text,
      size: _chipPx,
      color: l.color,
      weight: FontWeight.w900,
    );
    final k = l.fontPx / _chipPx * _liftScale;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: tp.width + 12,
        height: tp.height + 2,
      ),
      const Radius.circular(9),
    );
    canvas
      ..save()
      ..translate(l.at.dx, l.at.dy)
      ..scale(k);
    _shadow.color = _Colors.black.withValues(alpha: 0.6);
    canvas.drawRRect(rr.shift(const Offset(0, 8)), _shadow);
    _fill.color = _Colors.chipBg;
    canvas.drawRRect(rr, _fill);
    _stroke
      ..strokeWidth = 1.5
      ..color = l.color;
    canvas.drawRRect(rr, _stroke);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiftPainter old) =>
      old.lift != lift || old.text != text;
}

/// HTML `#s1-graph`: maximum (red) and minimum (blue) lines over Days 1–10
/// on a 0–40 °C axis, in the SVG's 200 × 150 view box.
class _LineGraphPainter extends CustomPainter {
  _LineGraphPainter({
    required this.plotted,
    required this.text,
    required this.t,
    required this.isDark,
    required this.textScale,
  });

  final int plotted;
  final _TextCache text;
  final String Function(String key) t;
  final bool isDark;
  final double textScale;

  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _fill = Paint();
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    // HTML: x = 20 + (i − 1) × 18.8, y = 130 − t / 40 × 120 in 200 × 150.
    final sx = size.width / 200, sy = size.height / 150;
    Offset at(double x, double y) => Offset(x * sx, y * sy);
    final axis = isDark ? _Colors.slate600 : _Colors.slate300;
    final grid = isDark ? _Colors.slate800 : _Colors.slate200;
    _line
      ..strokeWidth = 1
      ..color = axis;
    canvas.drawLine(at(20, 130), at(190, 130), _line);
    _line
      ..strokeWidth = 0.6
      ..color = grid;
    for (final y in const [100.0, 70.0, 40.0, 10.0]) {
      labDashedLine(canvas, at(20, y), at(190, y), _line, dash: 2, gap: 2);
    }
    final small = 7.5 * textScale;
    for (var i = 0; i <= 4; i++) {
      final tp = text.get(
        '${i * 10}',
        size: small,
        color: _Colors.slate500,
        weight: FontWeight.w600,
      );
      tp.paint(
        canvas,
        at(14, 130 - i * 30.0) - Offset(tp.width, tp.height / 2),
      );
    }
    final xLabel = text.get(
      t('lbl_days_1_10'),
      size: small,
      color: _Colors.slate500,
      weight: FontWeight.w600,
    );
    xLabel.paint(
      canvas,
      Offset(size.width / 2 - xLabel.width / 2, size.height - xLabel.height),
    );
    // Legend (added): Max / Min.
    var lx = at(24, 6).dx;
    for (final (key, color) in const [
      ('legend_max', _Colors.red500),
      ('legend_min', _Colors.blue500),
    ]) {
      final tp = text.get(
        t(key),
        size: small,
        color: _Colors.slate500,
        weight: FontWeight.w700,
      );
      _fill.color = color;
      canvas.drawCircle(Offset(lx + 3, at(0, 8).dy), 3, _fill);
      tp.paint(canvas, Offset(lx + 9, at(0, 8).dy - tp.height / 2));
      lx += tp.width + 18;
    }
    if (plotted <= 0) return;
    for (final (pick, color) in [
      ((int i) => _s1Data[i].$1, _Colors.red500),
      ((int i) => _s1Data[i].$2, _Colors.blue500),
    ]) {
      _path.reset();
      for (var i = 0; i < plotted; i++) {
        final p = at(20 + i * 18.8, 130 - pick(i) / 40 * 120);
        if (i == 0) {
          _path.moveTo(p.dx, p.dy);
        } else {
          _path.lineTo(p.dx, p.dy);
        }
      }
      _line
        ..strokeWidth = 2.4 * math.min(sx, sy)
        ..color = color;
      canvas.drawPath(_path, _line);
      _fill.color = color;
      for (var i = 0; i < plotted; i++) {
        canvas.drawCircle(
          at(20 + i * 18.8, 130 - pick(i) / 40 * 120),
          3.2 * math.min(sx, sy),
          _fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter old) =>
      old.plotted != plotted ||
      old.isDark != isDark ||
      old.textScale != textScale ||
      old.t('lbl_days_1_10') != t('lbl_days_1_10');
}

/// HTML `#s2-chart`: air (sky) and water (emerald) bars at 9 AM, 1 PM and
/// 4 PM. The bars start at 0 °C, so the axis reads 0–30 °C (the HTML axis
/// said 10–30 under bars drawn from 0).
class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.scene,
    required this.grow,
    required this.text,
    required this.t,
    required this.isDark,
    required this.textScale,
  });

  final _Scene scene;
  final double grow;
  final _TextCache text;
  final String Function(String key) t;
  final bool isDark;
  final double textScale;

  final Paint _line = Paint()..style = PaintingStyle.stroke;
  final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200, sy = size.height / 150;
    Offset at(double x, double y) => Offset(x * sx, y * sy);
    final axis = isDark ? _Colors.slate600 : _Colors.slate300;
    final grid = isDark ? _Colors.slate800 : _Colors.slate200;
    final small = 7.5 * textScale;
    _line
      ..strokeWidth = 1
      ..color = axis;
    canvas.drawLine(at(20, 130), at(190, 130), _line);
    _line
      ..strokeWidth = 0.6
      ..color = grid;
    for (var i = 1; i <= 3; i++) {
      final y = 130 - i * 40.0;
      labDashedLine(canvas, at(20, y), at(190, y), _line, dash: 2, gap: 2);
    }
    for (var i = 0; i <= 3; i++) {
      final tp = text.get(
        '${i * 10}',
        size: small,
        color: _Colors.slate500,
        weight: FontWeight.w600,
      );
      tp.paint(
        canvas,
        at(14, 130 - i * 40.0) - Offset(tp.width, tp.height / 2),
      );
    }
    const xs = [55.0, 105.0, 155.0];
    for (var i = 0; i < _times; i++) {
      final tp = text.get(
        t('chart_${i + 1}'),
        size: small,
        color: _Colors.slate500,
        weight: FontWeight.w600,
      );
      tp.paint(
        canvas,
        Offset(at(xs[i], 0).dx - tp.width / 2, size.height - tp.height),
      );
      for (final (value, x, color) in [
        (scene.airRec[i], xs[i] - 15, _Colors.sky400),
        (scene.waterRec[i], xs[i] + 3, _Colors.emerald400),
      ]) {
        if (value == null) continue;
        final h = value / 30 * 120 * grow;
        _fill.color = color;
        canvas.drawRect(
          Rect.fromPoints(at(x, 130 - h), at(x + 12, 130)),
          _fill,
        );
        final label = text.get(
          '$value',
          size: small,
          color: color,
          weight: FontWeight.w800,
        );
        final top = at(x + 6, 130 - h - 2);
        label.paint(
          canvas,
          Offset(top.dx - label.width / 2, top.dy - label.height),
        );
      }
    }
    // Legend (HTML: Air / Water squares at the top left).
    var lx = at(25, 0).dx;
    for (final (key, color) in const [
      ('lbl_air', _Colors.sky400),
      ('lbl_water', _Colors.emerald400),
    ]) {
      final tp = text.get(
        t(key),
        size: small,
        color: _Colors.slate500,
        weight: FontWeight.w700,
      );
      _fill.color = color;
      canvas.drawRect(Rect.fromLTWH(lx, at(0, 5).dy, 6 * sx, 6 * sx), _fill);
      tp.paint(canvas, Offset(lx + 8 * sx, at(0, 8).dy - tp.height / 2));
      lx += 8 * sx + tp.width + 10;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.grow != grow ||
      old.isDark != isDark ||
      old.textScale != textScale ||
      old.t('lbl_air') != t('lbl_air');
}

/// TextPainters for the canvas text, laid out once and reused every frame.
/// Owned (and disposed) by the page State.
class _TextCache {
  final Map<String, TextPainter> _painters = {};

  /// Painters evicted at the last overflow. They are disposed one overflow
  /// later, never while a paint call may still hold them.
  List<TextPainter> _retired = const [];

  /// Painters kept before the cache starts over (the S1 digits spin through
  /// up to 40 values per colour; everything else is a fixed set).
  static const int _maxEntries = 400;

  TextPainter get(
    String text, {
    required double size,
    required Color color,
    required FontWeight weight,
    double letterSpacing = 0,
    String? family,
  }) {
    final key =
        '$text|${size.toStringAsFixed(2)}|${color.toARGB32()}|${weight.value}|$letterSpacing|$family';
    final hit = _painters[key];
    if (hit != null) return hit;
    if (_painters.length >= _maxEntries) {
      for (final painter in _retired) {
        painter.dispose();
      }
      _retired = _painters.values.toList();
      _painters.clear();
    }
    return _painters[key] = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: 1.2,
          fontFamily: family ?? LabFont.active.family,
          fontFamilyFallback: family == null ? LabFont.active.fallback : null,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }

  void dispose() {
    for (final painter in [..._retired, ..._painters.values]) {
      painter.dispose();
    }
    _retired = const [];
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
