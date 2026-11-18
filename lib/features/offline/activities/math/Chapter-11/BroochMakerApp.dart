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
const Color silverWire = Color(0xFFE2E8F0);

class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE BROOCH MAKER',
      'tagline': 'Wire Length and Sector Area',
      'init_btn': 'INITIALIZE WORKSHOP',
      'header_title': 'The Brooch Maker',
      'header_subtitle': 'Class 10 • Areas Related to Circles',
      'phase_label': 'FABRICATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Brooch Forged',
      'success_desc':
          'You have successfully calculated both the total wire required and the sector area!',
      'btn_restart': 'NEW FABRICATION',
      's0': 'Initialize Workspace. Specifications: d = 35mm.',
      's1': 'Shape the outer ring (Circumference).',
      's2': 'Calculate outer wire length (πd).',
      's3': 'Install 5 reinforcing diameters.',
      's4': 'Calculate total wire length required.',
      's5': 'Analyze structural divisions (10 equal sectors).',
      's6': 'Determine the central angle of a single sector (θ).',
      's7': 'Set up the Sector Area formula.',
      's8': 'Substitute known values (r = 35/2, θ = 36°).',
      's9': 'Calculate final area of one sector.',
      'btn_start': 'LOAD SPECIFICATIONS',
      'btn_draw_ring': 'SHAPE OUTER RING',
      'btn_calc_circ': 'CALCULATE RING LENGTH',
      'btn_add_diams': 'INSTALL 5 DIAMETERS',
      'btn_calc_tot_wire': 'CALCULATE TOTAL WIRE',
      'btn_analyze_divs': 'ANALYZE DIVISIONS',
      'btn_calc_angle': 'DETERMINE SECTOR ANGLE',
      'btn_formula': 'LOAD SECTOR FORMULA',
      'btn_substitute': 'SUBSTITUTE VALUES',
      'btn_calc_area': 'CALCULATE SECTOR AREA',
      'msg_obs_ok': 'Workspace initialized. Diameter = 35mm.',
      'msg_ring_ok': 'Outer silver ring forged.',
      'msg_circ_ok': 'Circumference = (22/7) × 35 = 110mm.',
      'msg_diams_ok': '5 Silver diameters installed.',
      'msg_tot_ok': 'Total Wire = 110 + (5 × 35) = 285mm.',
      'msg_divs_ok': 'Brooch divided into 10 identical sectors.',
      'msg_ang_ok': 'Angle θ = 360° / 10 = 36°.',
      'msg_form_ok': 'Sector formula loaded: (θ/360) × πr².',
      'msg_sub_ok': 'Values substituted into mathematical model.',
      'msg_final_ok': 'Sector Area = 96.25 mm². Fabrication Complete!',
      'msg_err': 'Calculation error. Check your math.',
      // New strings for calculations panel
      'calc_title': 'Calculations & Data',
      'total_wire_label': '1. Total Wire Length',
      'sector_area_label': '2. Sector Area Calculation',
      'awaiting_specs': 'Awaiting specifications...',
      'ring_calc': 'Ring = πd = (22/7) × 35 = 110',
      'diams_calc': 'Diams = 5 × 35 = 175',
      'total_calc': 'Total = 110 + 175 = 285 mm',
      'area_formula': 'Area = (θ / 360°) × πr²',
      'area_sub': 'Area = (36/360) × (22/7) × (35/2)²',
      'area_res': '= 96.25 mm²',
    },
    'hi': {
      'app_title': 'ब्रूच मेकर',
      'tagline': 'तार की लंबाई और त्रिज्यखंड का क्षेत्रफल',
      'init_btn': 'वर्कशॉप प्रारंभ करें',
      'header_title': 'ब्रूच मेकर',
      'header_subtitle': 'कक्षा 10 • वृत्तों से संबंधित क्षेत्रफल',
      'phase_label': 'निर्माण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'ब्रूच तैयार',
      'success_desc':
          'आपने आवश्यक कुल तार और त्रिज्यखंड के क्षेत्रफल की सफलतापूर्वक गणना कर ली है!',
      'btn_restart': 'नया निर्माण',
      's0': 'कार्यक्षेत्र प्रारंभ करें। विवरण: d = 35mm.',
      's1': 'बाहरी रिंग (परिधि) को आकार दें।',
      's2': 'बाहरी तार की लंबाई की गणना करें (πd)।',
      's3': '5 मजबूत व्यास स्थापित करें।',
      's4': 'आवश्यक कुल तार की लंबाई की गणना करें।',
      's5': 'संरचनात्मक विभाजनों का विश्लेषण करें (10 समान त्रिज्यखंड)।',
      's6': 'एक त्रिज्यखंड (θ) का केंद्रीय कोण निर्धारित करें।',
      's7': 'त्रिज्यखंड क्षेत्रफल सूत्र सेट करें।',
      's8': 'ज्ञात मानों को प्रतिस्थापित करें (r = 35/2, θ = 36°)।',
      's9': 'एक त्रिज्यखंड के अंतिम क्षेत्रफल की गणना करें।',
      'btn_start': 'विवरण लोड करें',
      'btn_draw_ring': 'बाहरी रिंग को आकार दें',
      'btn_calc_circ': 'रिंग की लंबाई की गणना करें',
      'btn_add_diams': '5 व्यास स्थापित करें',
      'btn_calc_tot_wire': 'कुल तार की गणना करें',
      'btn_analyze_divs': 'विभाजन का विश्लेषण करें',
      'btn_calc_angle': 'त्रिज्यखंड का कोण निर्धारित करें',
      'btn_formula': 'क्षेत्रफल सूत्र लोड करें',
      'btn_substitute': 'मान प्रतिस्थापित करें',
      'btn_calc_area': 'क्षेत्रफल की गणना करें',
      'msg_obs_ok': 'कार्यक्षेत्र आरंभ किया गया। व्यास = 35mm.',
      'msg_ring_ok': 'बाहरी चांदी की अंगूठी जाली।',
      'msg_circ_ok': 'परिधि = (22/7) × 35 = 110mm.',
      'msg_diams_ok': '5 चांदी के व्यास स्थापित।',
      'msg_tot_ok': 'कुल तार = 110 + (5 × 35) = 285mm.',
      'msg_divs_ok': 'ब्रूच को 10 समान त्रिज्यखंडों में विभाजित किया गया।',
      'msg_ang_ok': 'कोण θ = 360° / 10 = 36°.',
      'msg_form_ok': 'त्रिज्यखंड सूत्र लोड किया गया: (θ/360) × πr².',
      'msg_sub_ok': 'गणितीय मॉडल में मान प्रतिस्थापित किए गए।',
      'msg_final_ok': 'त्रिज्यखंड क्षेत्रफल = 96.25 mm². निर्माण पूर्ण!',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      // New strings for calculations panel
      'calc_title': 'गणनाएँ एवं डेटा',
      'total_wire_label': '1. कुल तार की लंबाई',
      'sector_area_label': '2. त्रिज्यखंड का क्षेत्रफल',
      'awaiting_specs': 'विवरण की प्रतीक्षा में...',
      'ring_calc': 'रिंग = πd = (22/7) × 35 = 110',
      'diams_calc': 'व्यास = 5 × 35 = 175',
      'total_calc': 'कुल = 110 + 175 = 285 mm',
      'area_formula': 'क्षेत्रफल = (θ / 360°) × πr²',
      'area_sub': 'क्षेत्रफल = (36/360) × (22/7) × (35/2)²',
      'area_res': '= 96.25 mm²',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class BroochMakerApp extends StatefulWidget {
  const BroochMakerApp({super.key});

  @override
  State<BroochMakerApp> createState() => _BroochMakerAppState();
}

class _BroochMakerAppState extends State<BroochMakerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en'; // Default language English

  // Panels State
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // Activity State
  int currentStep = 0; // Steps map from 0 to 10
  bool showSuccessModal = false;

  // Animation State
  double ringProgress = 0.0; // 0.0 to 1.0 (2*pi)
  double diamProgress = 0.0; // 0.0 to 5.0 (number of wires)

  late AnimationController _ringController;
  late AnimationController _diamController;
  late Animation<double> _ringAnimation;
  late Animation<double> _diamAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _diamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _ringController.dispose();
    _diamController.dispose();
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
      if (isLeftPanelOpen) isRightPanelOpen = false; // Auto close right
    });
  }

  void toggleRightPanel() {
    AudioManager.playClick();
    setState(() {
      isRightPanelOpen = !isRightPanelOpen;
      if (isRightPanelOpen) isLeftPanelOpen = false; // Auto close left
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
                  color: Colors.black87,
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void advanceStep(String msgKey) {
    if (currentStep < 10) {
      AudioManager.playClick();
      // Up to 10 as fully completed
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Animation Triggers
        if (currentStep == 2) {
          _animateRing();
        } else if (currentStep == 4) {
          _animateDiameters();
        }

        // Success Modal Trigger
        if (currentStep == 10) {
          AudioManager.playSuccess();
          Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
              // Keep it open for user to click restart manually or dismiss after 5s
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

  void _animateRing() {
    _ringAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            ringProgress = _ringAnimation.value;
          });
        });
    _ringController.forward(from: 0.0);
  }

  void _animateDiameters() {
    _diamAnimation =
        Tween<double>(begin: 0.0, end: 5.0).animate(
          CurvedAnimation(parent: _diamController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            diamProgress = _diamAnimation.value;
          });
        });
    _diamController.forward(from: 0.0);
  }

  void resetLab() {
    AudioManager.playError();
    setState(() {
      currentStep = 0;
      ringProgress = 0.0;
      diamProgress = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      lang = 'en'; // Reset translation
      _ringController.stop();
      _diamController.stop();
      _ringController.reset();
      _diamController.reset();
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
                const Icon(Icons.animation, size: 80, color: accentPink),
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
    double panelWidth = screenWidth * 0.38; // Strict 38%

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // 1. (CANVAS AREA)
            Positioned.fill(child: _buildCanvasArea()),

            // 2. (Canvas Floating Card) - only shows when left panel is closed
            if (!isLeftPanelOpen)
              Positioned(top: 85, left: 20, child: _buildFloatingCard()),

            // 3. राइट पैनल (Right Sidebar - Calculations)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: isRightPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildRightPanel(),
            ),

            // 4. लेफ्ट पैनल (Left Sidebar - Mission/Controls)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildLeftPanel(),
            ),

            // 5. फ्रंट स्क्रीन फ्लोटिंग बटन (Front Screen / Always Visible Buttons)
            // Fixed positions on top of sidebars

            // टॉप-लेफ्ट मेनू बटन
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

            // बॉटम-राइट डेटा कलेक्शन/गणना बटन
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFloatingActionBtn(
                icon: isRightPanelOpen ? Icons.close : Icons.data_usage_rounded,
                onTap: toggleRightPanel,
                color: accentBlue,
                tooltip: 'Data / Calculations',
              ),
            ),

            // (Success Modal)
            if (showSuccessModal) Positioned.fill(child: _buildSuccessModal()),
          ],
        ),
      ),
    );
  }

  // --- फ्लोटिंग बटन विजेट (Floating Button) ---
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

  // --- फ्लोटिंग मिशन कार्ड विजेट (Floating Mission Card) ---
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

  // --- लेफ्ट पैनल विजेट (Left Sidebar - 38%) ---
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
            // हेडर (HEADER)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 70, 15, 10),
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
                        child: const Icon(Icons.blur_circular, color: bgDark),
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
                      // भाषा टॉगल (Language Toggle)
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
                      // रीसेट बटन
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

            // नियंत्रण क्षेत्र (Interaction Controls Container) - Moved above Phase list
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

            // पैनल सामग्री (Panel Content) - Phase Label and Steps
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

                  // चरण सूची (Steps List)
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
                      shrinkWrap: true, // Let it size itself
                      physics:
                          const NeverScrollableScrollPhysics(), // Scroll handled by parent SingleChildScrollView
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

  // --- राइट पैनल विजेट (Right Sidebar - Calculations - 38%) ---
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
          // हेडर (HEADER)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
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

          // डेटा और गणनाएँ (Data and Calculations Content)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // भाग 1: कुल तार की लंबाई (Part 1: Total Wire Length)
                  if (currentStep >= 1) ...[
                    Text(
                      AppStrings.get(lang, 'total_wire_label'),
                      style: const TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (currentStep >= 3)
                      _buildMathRow(
                        AppStrings.get(lang, 'ring_calc'),
                        Colors.white70,
                      ),
                    if (currentStep >= 5) ...[
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'diams_calc'),
                        Colors.white70,
                      ),
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'total_calc'),
                        accentBlue,
                        isBold: true,
                        isHighlight: true,
                      ),
                    ],
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

                  // भाग 2: त्रिज्यखंड का क्षेत्रफल (Part 2: Sector Area)
                  if (currentStep >= 6) ...[
                    Text(
                      AppStrings.get(lang, 'sector_area_label'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (currentStep >= 8)
                      _buildMathRow(
                        AppStrings.get(lang, 'area_formula'),
                        Colors.white70,
                      ),

                    if (currentStep >= 9) ...[
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'area_sub'),
                        Colors.white,
                      ),
                    ],

                    if (currentStep >= 10) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'area_res'),
                        accentGreen,
                        isBold: true,
                        isHighlight: true,
                      ),
                    ],
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

  // --- कैनवास क्षेत्र (CANVAS AREA) ---
  Widget _buildCanvasArea() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.1,
      maxScale: 4.0,
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // विशाल बैकग्राउंड ग्रिड (Huge Background Grid)
              Positioned(
                top: -2000,
                left: -2000,
                right: -2000,
                bottom: -2000,
                child: CustomPaint(painter: GridPainter()),
              ),
              // ब्रूच ग्राफिक्स (Brooch Graphics)
              Positioned.fill(
                child: CustomPaint(
                  painter: BroochPainter(
                    step: currentStep,
                    ringProgress: ringProgress,
                    diamProgress: diamProgress,
                  ),
                ),
              ),
              // कोण लेबल (Angle Labels)
              if (currentStep >= 6)
                const Positioned(
                  left: 315,
                  top: 200,
                  child: Text(
                    "θ",
                    style: TextStyle(
                      color: accentYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (currentStep >= 7)
                const Positioned(
                  left: 345,
                  top: 160,
                  child: Text(
                    "36°",
                    style: TextStyle(
                      color: accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Adjusted strictly to advance step -> then perform visual outcome.
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
          text: AppStrings.get(lang, 'btn_draw_ring'),
          color: accentPink,
          onPressed: () => advanceStep('msg_ring_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_circ'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_circ_ok');
            if (!isRightPanelOpen)
              toggleRightPanel(); // Auto-open right panel to show math
          },
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_add_diams'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_diams_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_tot_wire'),
          color: accentGreen,
          onPressed: () {
            advanceStep('msg_tot_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_analyze_divs'),
          color: accentPink,
          onPressed: () => advanceStep('msg_divs_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_angle'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_ang_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_formula'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_form_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_substitute'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_area'),
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

// --- उप-विजेट्स (SUB-WIDGETS) ---

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

// --- कस्टम पेंटर्स (CUSTOM PAINTERS) ---

class BroochPainter extends CustomPainter {
  final int step;
  final double ringProgress;
  final double diamProgress;

  BroochPainter({
    required this.step,
    required this.ringProgress,
    required this.diamProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = const Offset(250, 250);
    // दिखने वाली त्रिज्या (Visual radius r=120)
    double radius = 120.0;

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

    if (step >= 1) {
      // हल्का ब्लूप्रिंट आउटलाइन (Very faint blueprint outline)
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawCircle(center, 2, Paint()..color = Colors.white54);
      if (step < 3) {
        drawText(
          "d = 35mm",
          Offset(center.dx - 30, center.dy + 20),
          Colors.white70,
          14,
          FontWeight.bold,
        );
      }
    }

    // 1. बाहरी रिंग बनाएं (Draw Outer Ring) - starts at step 2 after button click
    if (step >= 2 && ringProgress > 0) {
      final ringPaint = Paint()
        ..color = silverWire
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // शीर्ष से शुरू करें (Start at top)
        2 * math.pi * ringProgress,
        false,
        ringPaint,
      );
    }

    // 3. व्यास बनाएं (Draw Diameters) - starts at step 4 after button click
    if (step >= 4 && diamProgress > 0) {
      final diamPaint = Paint()
        ..color = silverWire
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      int fullLines = diamProgress.floor();
      double fraction = diamProgress - fullLines;

      // पूर्ण व्यास बनाएं (Draw fully completed diameters)
      for (int i = 0; i < fullLines; i++) {
        double angle = -math.pi / 2 + (i * 36 * math.pi / 180);
        Offset end1 = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        Offset end2 = Offset(
          center.dx - radius * math.cos(angle),
          center.dy - radius * math.sin(angle),
        );
        canvas.drawLine(end1, end2, diamPaint);
      }

      // आंशिक रूप से पूरा व्यास बनाएं (Draw the partially completed diameter)
      if (fraction > 0 && fullLines < 5) {
        double angle = -math.pi / 2 + (fullLines * 36 * math.pi / 180);
        Offset end1 = Offset(
          center.dx + (radius * fraction) * math.cos(angle),
          center.dy + (radius * fraction) * math.sin(angle),
        );
        Offset end2 = Offset(
          center.dx - (radius * fraction) * math.cos(angle),
          center.dy - (radius * fraction) * math.sin(angle),
        );
        canvas.drawLine(center, end1, diamPaint);
        canvas.drawLine(center, end2, diamPaint);
      }
    }

    // 5. त्रिज्यखंड / कोण हाइलाइट करें (Highlight Sectors / Angle) - step 6
    if (step >= 6) {
      double startAngle = -math.pi / 2;
      double sweepAngle = 36 * math.pi / 180;

      Path sectorPath = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(
        sectorPath,
        Paint()
          ..color = accentPink.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      // चाप हाइलाइट (Arc highlight)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = accentPink
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );

      // कोण संकेतक (Angle indicator)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 30),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = accentYellow.withOpacity(0.6)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BroochPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.ringProgress != ringProgress ||
        oldDelegate.diamProgress != diamProgress;
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
