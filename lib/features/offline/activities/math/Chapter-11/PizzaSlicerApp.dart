// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;

// --- AUDIO MANAGER ---
class AudioManager {
  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback on Android
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  static Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource(_clickUrl));
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    try {
      await _successPlayer.stop();
      await _successPlayer.play(AssetSource(_successUrl));
    } catch (_) {}
  }

  static Future<void> playError() async {
    try {
      await _errorPlayer.stop();
      await _errorPlayer.play(AssetSource(_errorUrl));
    } catch (_) {}
  }

  static Future<void> playShutter() async {
    try {
      await _fxPlayer.stop();
      await _fxPlayer.play(AssetSource(_shutterUrl));
    } catch (_) {}
  }
}

const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);
const Color accentYellow = Color(0xFFFACC15);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE PIZZA SLICER',
      'tagline': 'Area of a Sector of a Circle',
      'init_btn': 'INITIALIZE SLICER',
      'header_title': 'The Pizza Slicer',
      'header_subtitle': 'Class 10 • Areas Related to Circles',
      'phase_label': 'SLICING PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Sector Master',
      'success_desc':
          'You have successfully calculated the area and arc length of the sector!',
      'btn_restart': 'NEW SLICE',
      's0': 'Initialize Grid. Bake circular pizza (r = 10).',
      's1': 'Identify Center O.',
      's2': 'Make First Radial Cut (Radius 1).',
      's3': 'Set Slicing Angle (θ = 60°).',
      's4': 'Make Second Radial Cut (Radius 2).',
      's5': 'Extract Sector (The Pizza Slice).',
      's6': 'Calculate Total Area of Pizza (πr²).',
      's7': 'Determine Slice Fraction (θ/360°).',
      's8': 'Calculate Sector Area (Fraction × Total).',
      's9': 'Calculate Arc Length (The Crust).',
      'btn_start': 'BAKE PIZZA BASE',
      'btn_loc_center': 'LOCATE CENTER',
      'btn_cut_1': 'FIRST RADIAL CUT',
      'btn_set_angle': 'SET ANGLE (60°)',
      'btn_cut_2': 'SECOND RADIAL CUT',
      'btn_extract': 'EXTRACT SLICE',
      'btn_calc_tot': 'CALCULATE TOTAL AREA',
      'btn_calc_frac': 'DETERMINE FRACTION',
      'btn_calc_sec': 'CALCULATE SECTOR AREA',
      'btn_calc_arc': 'CALCULATE ARC LENGTH',
      'msg_obs_ok': 'Pizza base established. Radius r = 10.',
      'msg_center_ok': 'Center point O located.',
      'msg_cut1_ok': 'First radius cut made.',
      'msg_angle_ok': 'Slicing angle set to 60°.',
      'msg_cut2_ok': 'Second radius cut made. Sector defined.',
      'msg_ext_ok': 'Sector extracted from the main circle.',
      'msg_tot_ok': 'Total Area = 100π.',
      'msg_frac_ok': 'Slice Fraction = 60/360 = 1/6.',
      'msg_sec_ok': 'Sector Area = (1/6) × 100π = 50π/3.',
      'msg_final_ok': 'Arc Length = (1/6) × 20π = 10π/3. Complete!',
      'msg_err': 'Calculation error. Check your math.',
      // Calculations Panel Strings
      'calc_title': 'Calculations & Data',
      'awaiting_specs': 'Awaiting slicing operations...',
      'prop_title': '1. Pizza Base Properties',
      'prop_r': 'Radius (r) = 10',
      'prop_a': 'Angle (θ) = 60°',
      'prop_tot': 'Total Area = πr² = 100π',
      'sec_title': '2. Sector Area Calculation',
      'sec_frac': 'Fraction = 60 / 360 = 1/6',
      'sec_area': 'Sector Area = (1/6) × 100π = 50π/3',
      'arc_title': '3. Arc Length Calculation',
      'arc_form': 'Arc = (θ / 360°) × 2πr',
      'arc_res': 'Arc = (1/6) × 20π = 10π/3',
    },
    'hi': {
      'app_title': 'पिज़्ज़ा स्लाइसर',
      'tagline': 'वृत्त के त्रिज्यखंड का क्षेत्रफल',
      'init_btn': 'स्लाइसर प्रारंभ करें',
      'header_title': 'पिज़्ज़ा स्लाइसर',
      'header_subtitle': 'कक्षा 10 • वृत्तों से संबंधित क्षेत्रफल',
      'phase_label': 'स्लाइसिंग चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'त्रिज्यखंड मास्टर',
      'success_desc':
          'आपने सफलतापूर्वक त्रिज्यखंड के क्षेत्रफल और चाप की लंबाई की गणना कर ली है!',
      'btn_restart': 'नया स्लाइस',
      's0': 'ग्रिड प्रारंभ करें। गोल पिज़्ज़ा बनाएँ (r = 10)।',
      's1': 'केंद्र O को पहचानें।',
      's2': 'पहला रेडियल कट (त्रिज्या 1) करें।',
      's3': 'स्लाइसिंग कोण (θ = 60°) सेट करें।',
      's4': 'दूसरा रेडियल कट (त्रिज्या 2) करें।',
      's5': 'त्रिज्यखंड निकालें (पिज़्ज़ा स्लाइस)।',
      's6': 'पिज़्ज़ा के कुल क्षेत्रफल की गणना करें (πr²)।',
      's7': 'स्लाइस अंश (θ/360°) निर्धारित करें।',
      's8': 'त्रिज्यखंड क्षेत्रफल की गणना करें (अंश × कुल)।',
      's9': 'चाप की लंबाई की गणना करें (क्रस्ट)।',
      'btn_start': 'पिज़्ज़ा बेस बनाएँ',
      'btn_loc_center': 'केंद्र खोजें',
      'btn_cut_1': 'पहला कट',
      'btn_set_angle': 'कोण सेट करें (60°)',
      'btn_cut_2': 'दूसरा कट',
      'btn_extract': 'स्लाइस निकालें',
      'btn_calc_tot': 'कुल क्षेत्रफल गणना',
      'btn_calc_frac': 'अंश निर्धारित करें',
      'btn_calc_sec': 'त्रिज्यखंड क्षेत्रफल',
      'btn_calc_arc': 'चाप की लंबाई',
      'msg_obs_ok': 'पिज़्ज़ा बेस तैयार। त्रिज्या r = 10.',
      'msg_center_ok': 'केंद्र बिंदु O स्थित।',
      'msg_cut1_ok': 'पहली त्रिज्या कट गई।',
      'msg_angle_ok': 'स्लाइसिंग कोण 60° पर सेट।',
      'msg_cut2_ok': 'दूसरी त्रिज्या कट गई। त्रिज्यखंड परिभाषित।',
      'msg_ext_ok': 'मुख्य वृत्त से त्रिज्यखंड निकाला गया।',
      'msg_tot_ok': 'कुल क्षेत्रफल = 100π.',
      'msg_frac_ok': 'स्लाइस अंश = 60/360 = 1/6.',
      'msg_sec_ok': 'त्रिज्यखंड का क्षेत्रफल = (1/6) × 100π = 50π/3.',
      'msg_final_ok': 'चाप की लंबाई = (1/6) × 20π = 10π/3. पूर्ण!',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      // Calculations Panel Strings
      'calc_title': 'गणनाएँ एवं डेटा',
      'awaiting_specs': 'सिलाईसिंग संचालन की प्रतीक्षा में...',
      'prop_title': '1. पिज़्ज़ा बेस गुण',
      'prop_r': 'त्रिज्या (r) = 10',
      'prop_a': 'कोण (θ) = 60°',
      'prop_tot': 'कुल क्षेत्रफल = πr² = 100π',
      'sec_title': '2. त्रिज्यखंड क्षेत्रफल की गणना',
      'sec_frac': 'अंश = 60 / 360 = 1/6',
      'sec_area': 'त्रिज्यखंड क्षेत्रफल = (1/6) × 100π = 50π/3',
      'arc_title': '3. चाप की लंबाई',
      'arc_form': 'चाप = (θ / 360°) × 2πr',
      'arc_res': 'चाप = (1/6) × 20π = 10π/3',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class PizzaSlicerApp extends StatefulWidget {
  const PizzaSlicerApp({super.key});

  @override
  State<PizzaSlicerApp> createState() => _PizzaSlicerAppState();
}

class _PizzaSlicerAppState extends State<PizzaSlicerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Panels State
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Animation State
  double sliceOffset = 0.0;
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void startGame() {
    AudioManager.playShutter();
    setState(() {
      hasStarted = true;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
    });
  }

  void switchLang(String newLang) {
    AudioManager.playClick();
    setState(() {
      lang = newLang;
    });
  }

  void toggleLeftPanel() {
    AudioManager.playClick();
    setState(() {
      isLeftPanelOpen = !isLeftPanelOpen;
      if (isLeftPanelOpen) isRightPanelOpen = false;
    });
  }

  void toggleRightPanel() {
    AudioManager.playClick();
    setState(() {
      isRightPanelOpen = !isRightPanelOpen;
      if (isRightPanelOpen) isLeftPanelOpen = false;
    });
  }

  void showToast(
    String message, {
    bool isError = false,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isError
                  ? accentRed
                  : (isSuccess ? accentGreen : accentBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bgDark,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? accentRed : (isSuccess ? accentGreen : accentBlue),
            width: 2,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void advanceStep(String msgKey) {
    if (currentStep < 10) {
      AudioManager.playClick();
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Trigger animations based on step completion
        if (currentStep == 6) {
          // Extract Slice
          _animateSlice(30.0);
        }

        if (currentStep == 10) {
          AudioManager.playSuccess();
          // Show success popup and auto-close after 5 seconds
          Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  setState(() {
                    showSuccessModal = false;
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  void _animateSlice(double targetOffset) {
    _moveAnimation =
        Tween<double>(begin: sliceOffset, end: targetOffset).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeOutBack),
        )..addListener(() {
          setState(() {
            sliceOffset = _moveAnimation.value;
          });
        });
    _moveController.forward(from: 0.0);
  }

  void resetLab() {
    AudioManager.playError();
    setState(() {
      currentStep = 0;
      sliceOffset = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      lang = 'en'; // Reset language
      _moveController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Scaffold(
          backgroundColor: bgDark,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  size: 80,
                  color: accentPink,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get(lang, 'app_title'),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: accentPink,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.get(lang, 'tagline'),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: startGame,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Text(
                      AppStrings.get(lang, 'init_btn'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    // Strict 38% panel width for proper proportion
    double panelWidth = screenWidth * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // 1. CANVAS AREA
            Positioned.fill(child: _buildInteractiveCanvas()),

            // 2. FLOATING MISSION CARD (Visible if Left Panel Collapsed)
            if (!isLeftPanelOpen && currentStep < 10)
              Positioned(top: 85, left: 20, child: _buildFloatingCard()),

            // 3. RIGHT PANEL (Calculations)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: isRightPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildRightPanel(),
            ),

            // 5. LEFT PANEL (Mission/Controls)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildLeftPanel(),
            ),

            // 5. FRONT SCREEN FIXED FLOATING BUTTONS

            // Top-Left Menu Button
            Positioned(
              top: 20,
              left: 20,
              child: _buildFloatingActionBtn(
                icon: isLeftPanelOpen ? Icons.menu_open : Icons.menu,
                onTap: toggleLeftPanel,
                color: accentPink,
                tooltip: 'Menu',
              ),
            ),

            // Bottom-Right Data/Calculations Button
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFloatingActionBtn(
                icon: isRightPanelOpen
                    ? Icons.data_usage
                    : Icons.data_usage_rounded,
                onTap: toggleRightPanel,
                color: accentBlue,
                tooltip: 'Data / Calculations',
              ),
            ),

            // SUCCESS MODAL
            if (showSuccessModal) Positioned.fill(child: _buildSuccessModal()),
          ],
        ),
      ),
    );
  }

  // --- FLOATING ACTION BUTTONS ---
  Widget _buildFloatingActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: bgPanel.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        ),
        elevation: 10,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }

  // --- FLOATING MISSION CARD ---
  Widget _buildFloatingCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgPanel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get(lang, 'active_mission').toUpperCase(),
                style: const TextStyle(
                  color: accentPink,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${currentStep >= 10 ? 10 : currentStep + 1}/10",
                  style: const TextStyle(
                    color: accentBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentStep >= 10
                ? AppStrings.get(lang, 'badge_title')
                : AppStrings.get(lang, 's$currentStep'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildControlsArea(),
        ],
      ),
    );
  }

  // --- LEFT SIDEBAR (38%) ---
  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel,
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 75, 15, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.pie_chart, color: bgDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get(
                                lang,
                                'header_title',
                              ).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.get(lang, 'header_subtitle'),
                              style: const TextStyle(
                                color: accentPink,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LangBtn(
                              title: 'EN',
                              isActive: lang == 'en',
                              onTap: () => switchLang('en'),
                            ),
                            _LangBtn(
                              title: 'HI',
                              isActive: lang == 'hi',
                              onTap: () => switchLang('hi'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.power_settings_new),
                        color: Colors.white54,
                        iconSize: 24,
                        onPressed: resetLab,
                        tooltip: 'Restart Lab',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // INTERACTION CONTROLS - Moved above Phase progress list
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black45,
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get(lang, 'active_mission').toUpperCase(),
                    style: const TextStyle(
                      color: accentPink,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStep >= 10
                        ? AppStrings.get(lang, 'badge_title')
                        : AppStrings.get(lang, 's$currentStep'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildControlsArea(),
                ],
              ),
            ),

            // CONTENT Phase Label
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get(lang, 'phase_label'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${currentStep >= 10 ? 10 : currentStep + 1}/10",
                        style: const TextStyle(
                          color: accentBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (currentStep >= 10 ? 10 : currentStep + 1) / 10,
                    backgroundColor: Colors.black38,
                    color: accentPink,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 20),

                  // Mission Log
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppStrings.get(lang, 'mission_log').toUpperCase(),
                      style: const TextStyle(
                        color: accentPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        bool isActive = index == currentStep;
                        bool isDone = index < currentStep;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? accentPink.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isActive
                                    ? accentPink
                                    : isDone
                                    ? accentGreen
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            "${index + 1}. ${AppStrings.get(lang, 's$index')}",
                            style: TextStyle(
                              color: isActive
                                  ? accentPink
                                  : isDone
                                  ? Colors.white54
                                  : Colors.white30,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
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

  // --- RIGHT SIDEBAR (Calculations - 38%) ---
  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel,
        border: const Border(left: BorderSide(color: Colors.white12, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: toggleRightPanel,
                ),
                const SizedBox(width: 10),
                const Icon(Icons.data_usage, color: accentBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.get(lang, 'calc_title').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // CALCULATIONS CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep >= 7) ...[
                    // 1. Pizza Base Properties
                    Text(
                      AppStrings.get(lang, 'prop_title'),
                      style: const TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'prop_r'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 5),
                    _buildMathRow(
                      AppStrings.get(lang, 'prop_a'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'prop_tot'),
                      accentBlue,
                      isBold: true,
                      isHighlight: true,
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    Center(
                      child: Text(
                        AppStrings.get(lang, 'awaiting_specs'),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],

                  if (currentStep >= 8) ...[
                    // 2. Sector Area Calculation
                    Text(
                      AppStrings.get(lang, 'sec_title'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'sec_frac'),
                      Colors.white70,
                    ),

                    if (currentStep >= 9) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'sec_area'),
                        accentPink,
                        isBold: true,
                        isHighlight: true,
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],

                  if (currentStep >= 10) ...[
                    // 3. Arc Length Calculation
                    Text(
                      AppStrings.get(lang, 'arc_title'),
                      style: const TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'arc_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'arc_res'),
                      accentGreen,
                      isBold: true,
                      isHighlight: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathRow(
    String text,
    Color color, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isHighlight ? 12 : 8,
        horizontal: isHighlight ? 15 : 0,
      ),
      decoration: isHighlight
          ? BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border(left: BorderSide(color: color, width: 4)),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: isHighlight ? 18 : 15,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
    );
  }

  // --- CANVAS AREA ---
  Widget _buildInteractiveCanvas() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.2,
      maxScale: 5.0,
      child: Center(
        child: SizedBox(
          width: 800,
          height: 600,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Grid
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              // Scene Content
              Positioned.fill(
                child: Center(
                  child: CustomPaint(
                    size: const Size(500, 380),
                    painter: PizzaPainter(
                      step: currentStep,
                      sliceOffset: sliceOffset,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CONTROLS AREA ---
  Widget _buildControlsArea() {
    if (currentStep >= 10) {
      return _ControlButton(
        text: AppStrings.get(lang, 'btn_restart'),
        color: accentPink,
        onPressed: resetLab,
      );
    }

    switch (currentStep) {
      case 0:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_start'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_obs_ok'),
        );
      case 1:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_loc_center'),
          color: accentPink,
          onPressed: () => advanceStep('msg_center_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_cut_1'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_cut1_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_set_angle'),
          color: accentPink,
          onPressed: () => advanceStep('msg_angle_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_cut_2'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_cut2_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_extract'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_ext_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_tot'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_tot_ok');
            if (!isRightPanelOpen) toggleRightPanel(); // Auto-open math panel
          },
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_frac'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_frac_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_sec'),
          color: accentPink,
          onPressed: () {
            advanceStep('msg_sec_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_arc'),
          color: accentGreen,
          onPressed: () {
            advanceStep('msg_final_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildSuccessModal() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(40),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: bgDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGreen, width: 2),
              boxShadow: [
                BoxShadow(color: accentGreen.withOpacity(0.3), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: accentGreen, size: 80),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get(lang, 'badge_title').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.get(lang, 'success_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: resetLab,
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: Text(
                    AppStrings.get(lang, 'btn_restart'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _ControlButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == accentYellow ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _LangBtn({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class PizzaPainter extends CustomPainter {
  final int step;
  final double sliceOffset;

  PizzaPainter({required this.step, required this.sliceOffset});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = 250;
    double cy = 190;
    double r = 120;
    // 60 degrees in radians. Negative because in canvas +y is down.
    double angleRad = -math.pi / 3;

    Offset center = Offset(cx, cy);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawText(
      String text,
      Offset pos,
      Color color,
      double textSize,
      FontWeight weight,
    ) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: textSize,
          fontWeight: weight,
          fontFamily: 'monospace',
        ),
      );
      textPainter.layout();
      canvas.drawRect(
        Rect.fromLTWH(
          pos.dx - 2,
          pos.dy - 2,
          textPainter.width + 4,
          textPainter.height + 4,
        ),
        Paint()..color = bgDark.withOpacity(0.7),
      );
      textPainter.paint(canvas, pos);
    }

    // Step 1+ : Circle exists
    if (step >= 1) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill,
      );
    }

    // Step 2+ : Center O Located
    if (step >= 2) {
      canvas.drawCircle(center, 4, Paint()..color = Colors.white);
      drawText(
        "O",
        Offset(center.dx - 10, center.dy + 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
    }

    double bisectAngle = angleRad / 2;
    double dx = sliceOffset * math.cos(bisectAngle);
    double dy = sliceOffset * math.sin(bisectAngle);
    Offset extractedCenter = Offset(cx + dx, cy + dy);

    // Step 6+ : Remaining pizza (if sector extracted)
    if (step >= 6) {
      Path remainingPath = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + r * math.cos(angleRad), cy + r * math.sin(angleRad))
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          angleRad,
          (2 * math.pi) + angleRad, // Almost full circle missing 60 deg
          false,
        )
        ..close();

      canvas.drawPath(
        remainingPath,
        Paint()
          ..color = accentBlue.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        remainingPath,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Step 3+ : Cuts & Sector operations
    if (step >= 3) {
      Path slicePath = Path()..moveTo(extractedCenter.dx, extractedCenter.dy);

      Offset r1End = Offset(extractedCenter.dx + r, extractedCenter.dy);
      slicePath.lineTo(r1End.dx, r1End.dy);

      if (step >= 4) {
        slicePath.arcTo(
          Rect.fromCircle(center: extractedCenter, radius: r),
          0,
          angleRad,
          false,
        );
      }

      if (step >= 5) {
        slicePath.close();
      }

      if (step >= 6) {
        canvas.drawPath(
          slicePath,
          Paint()
            ..color = accentPink.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
      }

      if (step >= 3) {
        canvas.drawLine(
          extractedCenter,
          r1End,
          Paint()
            ..color = accentPink
            ..strokeWidth = 3,
        );
        if (step < 6) {
          drawText(
            "r=10",
            Offset(extractedCenter.dx + r / 2, extractedCenter.dy + 5),
            accentPink,
            14,
            FontWeight.bold,
          );
        }
      }

      if (step >= 4) {
        canvas.drawArc(
          Rect.fromCircle(center: extractedCenter, radius: 40),
          0,
          angleRad,
          true,
          Paint()
            ..color = accentYellow.withOpacity(0.4)
            ..style = PaintingStyle.fill,
        );
        drawText(
          "60°",
          Offset(extractedCenter.dx + 45, extractedCenter.dy - 25),
          accentYellow,
          14,
          FontWeight.bold,
        );
      }

      if (step >= 5) {
        Offset r2End = Offset(
          extractedCenter.dx + r * math.cos(angleRad),
          extractedCenter.dy + r * math.sin(angleRad),
        );
        canvas.drawLine(
          extractedCenter,
          r2End,
          Paint()
            ..color = accentPink
            ..strokeWidth = 3,
        );

        Path arcOnly = Path()
          ..moveTo(r1End.dx, r1End.dy)
          ..arcTo(
            Rect.fromCircle(center: extractedCenter, radius: r),
            0,
            angleRad,
            false,
          );
        canvas.drawPath(
          arcOnly,
          Paint()
            ..color = step >= 10 ? accentGreen : accentPink
            ..strokeWidth = step >= 10 ? 6 : 3
            ..style = PaintingStyle.stroke,
        );

        if (step >= 10) {
          drawText(
            "Arc Length",
            Offset(extractedCenter.dx + r + 10, extractedCenter.dy - r / 3),
            accentGreen,
            14,
            FontWeight.bold,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PizzaPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.sliceOffset != sliceOffset;
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const double step = 40;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
