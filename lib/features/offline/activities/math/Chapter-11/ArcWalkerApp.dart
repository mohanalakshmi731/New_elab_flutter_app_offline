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
      'app_title': 'THE ARC WALKER',
      'tagline': 'Length of an Arc of a Sector',
      'init_btn': 'INITIALIZE WALKER',
      'header_title': 'The Arc Walker',
      'header_subtitle': 'Class 10 • Areas Related to Circles',
      'phase_label': 'WALKING PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Path Verified',
      'success_desc':
          'You have successfully calculated the length of the arc traced by the walker!',
      'btn_restart': 'NEW PATH',
      'data_panel_title': 'Calculations & Data',
      's0': 'Initialize Grid. Define Circular Path (r = 21m).',
      's1': 'Locate Center Origin O.',
      's2': 'Establish Starting Point A on perimeter.',
      's3': 'Set Target Angle θ = 120°. Construct sector.',
      's4': 'Initiate Walker. Trace path to Point B.',
      's5': 'Identify the traced path as the Arc.',
      's6': 'Load Arc Length Formula: (θ/360°) × 2πr.',
      's7': 'Calculate Full Circumference (2πr).',
      's8': 'Determine Path Fraction (θ/360°).',
      's9': 'Calculate Final Arc Length.',
      'btn_start': 'DRAW CIRCULAR PATH',
      'btn_loc_center': 'LOCATE CENTER O',
      'btn_start_pt': 'MARK START POINT A',
      'btn_set_angle': 'SET ANGLE (120°)',
      'btn_walk': 'INITIATE WALKER',
      'btn_id_arc': 'IDENTIFY ARC',
      'btn_load_form': 'LOAD FORMULA',
      'btn_calc_circ': 'CALCULATE CIRCUMFERENCE',
      'btn_calc_frac': 'CALCULATE FRACTION',
      'btn_calc_final': 'CALCULATE ARC LENGTH',
      'msg_obs_ok': 'Circular path established. Radius = 21m.',
      'msg_center_ok': 'Center O locked.',
      'msg_pt_a_ok': 'Start Point A locked.',
      'msg_ang_ok': 'Target angle set to 120°.',
      'msg_walk_ok': 'Walker arrived at B. Path traced.',
      'msg_arc_ok': 'Arc AB formally identified.',
      'msg_form_ok': 'Formula loaded into memory.',
      'msg_circ_ok': 'Circumference = 2 × (22/7) × 21 = 132m.',
      'msg_frac_ok': 'Fraction = 120/360 = 1/3.',
      'msg_final_ok': 'Arc Length = (1/3) × 132 = 44m. Complete!',
      'msg_err': 'Calculation error. Check your math.',
    },
    'hi': {
      'app_title': 'आर्क वॉकर',
      'tagline': 'त्रिज्यखंड के चाप की लंबाई',
      'init_btn': 'वॉकर प्रारंभ करें',
      'header_title': 'आर्क वॉकर',
      'header_subtitle': 'कक्षा 10 • वृत्तों से संबंधित क्षेत्रफल',
      'phase_label': 'चलने का चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'पथ सत्यापित',
      'success_desc':
          'आपने वॉकर द्वारा ट्रेस किए गए चाप की लंबाई की सफलतापूर्वक गणना की है!',
      'btn_restart': 'नया पथ',
      'data_panel_title': 'गणना और डेटा',
      's0': 'ग्रिड प्रारंभ करें। वृत्ताकार पथ (r = 21m) को परिभाषित करें।',
      's1': 'केंद्र मूल O का पता लगाएँ।',
      's2': 'परिधि पर प्रारंभिक बिंदु A स्थापित करें।',
      's3': 'लक्ष्य कोण θ = 120° सेट करें। त्रिज्यखंड बनाएँ।',
      's4': 'वॉकर प्रारंभ करें। बिंदु B तक पथ ट्रेस करें।',
      's5': 'ट्रेस किए गए पथ को चाप (Arc) के रूप में पहचानें।',
      's6': 'चाप की लंबाई का सूत्र लोड करें: (θ/360°) × 2πr.',
      's7': 'पूर्ण परिधि (2πr) की गणना करें।',
      's8': 'पथ अंश (θ/360°) निर्धारित करें।',
      's9': 'अंतिम चाप की लंबाई की गणना करें।',
      'btn_start': 'वृत्ताकार पथ बनाएँ',
      'btn_loc_center': 'केंद्र O खोजें',
      'btn_start_pt': 'प्रारंभिक बिंदु A चिह्नित करें',
      'btn_set_angle': 'कोण सेट करें (120°)',
      'btn_walk': 'वॉकर प्रारंभ करें',
      'btn_id_arc': 'चाप पहचानें',
      'btn_load_form': 'सूत्र लोड करें',
      'btn_calc_circ': 'परिधि की गणना करें',
      'btn_calc_frac': 'अंश की गणना करें',
      'btn_calc_final': 'चाप की लंबाई की गणना करें',
      'msg_obs_ok': 'वृत्ताकार पथ स्थापित। त्रिज्या = 21m.',
      'msg_center_ok': 'केंद्र O लॉक किया गया।',
      'msg_pt_a_ok': 'प्रारंभिक बिंदु A लॉक किया गया।',
      'msg_ang_ok': 'लक्ष्य कोण 120° पर सेट।',
      'msg_walk_ok': 'वॉकर B पर पहुँचा। पथ ट्रेस किया गया।',
      'msg_arc_ok': 'चाप AB औपचारिक रूप से पहचाना गया।',
      'msg_form_ok': 'सूत्र मेमोरी में लोड किया गया।',
      'msg_circ_ok': 'परिधि = 2 × (22/7) × 21 = 132m.',
      'msg_frac_ok': 'अंश = 120/360 = 1/3.',
      'msg_final_ok': 'चाप की लंबाई = (1/3) × 132 = 44m. पूर्ण!',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ArcWalkerApp extends StatefulWidget {
  const ArcWalkerApp({super.key});

  @override
  State<ArcWalkerApp> createState() => _ArcWalkerAppState();
}

class _ArcWalkerAppState extends State<ArcWalkerApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  // Panels visibility states
  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  // Activity State
  int currentStep = 0;
  bool showSuccessModal = false;

  // Animation State
  double walkAngle = 0.0;
  late AnimationController _walkController;
  late Animation<double> _walkAnimation;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
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
    _walkController.dispose();
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
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF1F5F9),
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
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Trigger animations (step 5 is when "INITIATE WALKER" is clicked)
        if (currentStep == 5) {
          _animateWalk(120.0);
        }

        // Final step logic
        if (currentStep == 10) {
          AudioManager.playSuccess();
          Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });

              // Optional: Auto dismiss after some time (keeping to allow user to view or click Restart manually)
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

  void _animateWalk(double targetAngle) {
    _walkAnimation =
        Tween<double>(begin: walkAngle, end: targetAngle).animate(
          CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            walkAngle = _walkAnimation.value;
          });
        });
    _walkController.forward(from: 0.0);
  }

  void resetLab() {
    AudioManager.playError();
    setState(() {
      currentStep = 0;
      walkAngle = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      lang = 'en'; // Reset language to English
      _walkController.reset();
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
                const Icon(Icons.radar, size: 80, color: accentPink),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: startGame,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: Text(
                    AppStrings.get(lang, 'init_btn'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double screenW = MediaQuery.of(context).size.width;
    double panelWidth = screenW * 0.38; // Strict 38% width for sidebars

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // 1. पूर्ण स्क्रीन कैनवास (Interactive Canvas)
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(5000),
                minScale: 0.2,
                maxScale: 4.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background Grid
                    Positioned.fill(child: CustomPaint(painter: GridPainter())),

                    // Scene Content
                    Center(
                      child: SizedBox(
                        width: 500,
                        height: 380,
                        child: CustomPaint(
                          size: const Size(500, 380),
                          painter: ArcWalkerPainter(
                            step: currentStep,
                            walkAngle: walkAngle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. बायाँ साइड पैनल (Left Control Panel)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: bgPanel,
                  border: Border(
                    right: BorderSide(color: Colors.white12, width: 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(5, 0),
                    ),
                  ],
                ),
                child: _buildLeftPanelContent(),
              ),
            ),

            // 3. दायाँ साइड पैनल (Right Data Panel)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: isRightPanelOpen ? 0 : -panelWidth,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: bgPanel,
                  border: Border(
                    left: BorderSide(color: Colors.white12, width: 2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: _buildRightPanelContent(),
              ),
            ),

            // 4. फ्लोटिंग बटन (Fixed Floating Controls)
            Positioned(
              top: 20,
              left: 20,
              child: _buildFloatingActionBtn(
                icon: isLeftPanelOpen ? Icons.menu_open_rounded : Icons.menu,
                onTap: toggleLeftPanel,
                color: accentPink,
                tooltip: 'Toggle Controls',
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFloatingActionBtn(
                icon: isRightPanelOpen ? Icons.close : Icons.analytics,
                onTap: toggleRightPanel,
                color: accentBlue,
                tooltip: 'Data / Calculations',
              ),
            ),

            // फ्लोटिंग मिशन कार्ड (जब बायां पैनल बंद हो तब दिखाई देगा)
            if (!isLeftPanelOpen && currentStep < 10)
              _buildFloatingMissionCard(),

            // 5. सफलता मॉडल (Success Modal Overlay)
            if (showSuccessModal) Positioned.fill(child: _buildSuccessModal()),
          ],
        ),
      ),
    );
  }

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

  Widget _buildLeftPanelContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Title Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentPink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.donut_large, color: bgDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get(lang, 'header_title').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            AppStrings.get(lang, 'header_subtitle'),
                            style: const TextStyle(
                              color: accentPink,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Language Toggle & Restart
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
                      onPressed: resetLab,
                      tooltip: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // Action Controls Area (Current Objective)
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

          // Phase Label and Progress
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                      "${AppStrings.get(lang, 'step_label')} ${math.min(currentStep + 1, 10)}/10",
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
                  value: math.min(currentStep + 1, 10) / 10,
                  backgroundColor: Colors.black38,
                  color: accentPink,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),

          // Mission Log Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white10,
              border: Border(
                top: BorderSide(color: Colors.white12),
                bottom: BorderSide(color: Colors.white12),
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

          // Steps List
          Container(
            color: Colors.black26,
            padding: const EdgeInsets.only(bottom: 20),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                bool isActive = index == currentStep;
                bool isDone = index < currentStep;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
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
    );
  }

  Widget _buildRightPanelContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Data Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.analytics, color: accentYellow, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.get(lang, 'data_panel_title').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Calculations Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentStep < 7)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Text(
                        "Awaiting path tracing...\nComplete steps on the left.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white30,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                if (currentStep >= 7) ...[
                  _buildDataCard(
                    title: "Arc Length Formula",
                    color: accentBlue,
                    children: [
                      const Text(
                        "L = (θ / 360°) × 2πr",
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      if (currentStep >= 9) ...[
                        const SizedBox(height: 10),
                        const Text(
                          "Fraction = 120 / 360",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          "         = 1/3",
                          style: TextStyle(
                            color: accentYellow,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                if (currentStep >= 8) ...[
                  const SizedBox(height: 20),
                  _buildDataCard(
                    title: "Full Circumference",
                    color: accentPink,
                    children: [
                      const Text(
                        "C = 2πr",
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "C = 2 × (22/7) × 21",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "C = 132m",
                        style: TextStyle(
                          color: accentPink,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],

                if (currentStep >= 10) ...[
                  const SizedBox(height: 20),
                  _buildDataCard(
                    title: "Final Arc Length",
                    color: accentGreen,
                    children: [
                      const Text(
                        "L = (1/3) × 132",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.1),
                          border: Border.all(color: accentGreen),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "L = 44m",
                            style: TextStyle(
                              color: accentGreen,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

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
          text: AppStrings.get(lang, 'btn_start_pt'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_pt_a_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_set_angle'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_ang_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_walk'),
          color: accentPink,
          onPressed: () => advanceStep('msg_walk_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_arc'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_arc_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_load_form'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_form_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_circ'),
          color: accentPink,
          onPressed: () {
            advanceStep('msg_circ_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_frac'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_frac_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_final'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_final_ok'),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildFloatingMissionCard() {
    int displayStep = math.min(currentStep, 9);
    return Positioned(
      top: 85,
      left: 20,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgPanel.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentPink.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.track_changes, color: accentPink, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${AppStrings.get(lang, 'active_mission').toUpperCase()} • ${displayStep + 1}/10",
                    style: const TextStyle(
                      color: accentPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.get(lang, 's$displayStep'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildControlsArea(), // Action Button Reuse
            ],
          ),
        ),
      ),
    );
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
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: Text(
                    AppStrings.get(lang, 'success_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                // NEW: Restart Button in Success Modal
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class ArcWalkerPainter extends CustomPainter {
  final int step;
  final double walkAngle; // Degrees

  ArcWalkerPainter({required this.step, required this.walkAngle});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;
    double r = 120;

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

    // 1. Circular Path (After button 0 is clicked -> step 1)
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

    // 2. Center O
    if (step >= 2) {
      canvas.drawCircle(center, 4, Paint()..color = Colors.white);
      drawText(
        "O",
        Offset(center.dx - 5, center.dy + 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
    }

    Offset ptA = Offset(cx + r, cy); // 0 degrees (right side)

    // 3. Point A
    if (step >= 3) {
      canvas.drawLine(
        center,
        ptA,
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 2,
      );
      canvas.drawCircle(ptA, 5, Paint()..color = Colors.white);
      drawText(
        "A",
        Offset(ptA.dx + 10, ptA.dy - 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
      drawText(
        "r=21m",
        Offset(cx + r / 2 - 15, cy + 5),
        Colors.white70,
        12,
        FontWeight.normal,
      );
    }

    // 4. Target Angle 120
    double targetAngleRad =
        -120 * math.pi / 180; // Negative because canvas Y is down
    Offset ptB = Offset(
      cx + r * math.cos(targetAngleRad),
      cy + r * math.sin(targetAngleRad),
    );

    if (step >= 4) {
      canvas.drawLine(
        center,
        ptB,
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 2,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 30),
        0,
        targetAngleRad,
        true,
        Paint()
          ..color = accentYellow.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
      drawText(
        "120°",
        Offset(cx + 15, cy - 25),
        accentYellow,
        14,
        FontWeight.bold,
      );
    }

    // 5. Walker Path (Dynamic Arc)
    if (step >= 5) {
      double currentRad = -walkAngle * math.pi / 180;
      Offset walkerPos = Offset(
        cx + r * math.cos(currentRad),
        cy + r * math.sin(currentRad),
      );

      // Draw Traced Arc
      if (walkAngle > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          0,
          currentRad,
          false,
          Paint()
            ..color = step >= 6 ? accentGreen : accentPink
            ..strokeWidth = step >= 6 ? 6 : 4
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }

      // Draw Walker
      canvas.drawCircle(walkerPos, 8, Paint()..color = accentBlue);
      canvas.drawCircle(walkerPos, 4, Paint()..color = Colors.white);

      // Label B when reached
      if (walkAngle == 120.0) {
        drawText(
          "B",
          Offset(walkerPos.dx - 25, walkerPos.dy - 20),
          Colors.white,
          16,
          FontWeight.bold,
        );
      }

      // Label Arc
      if (step >= 6) {
        double midRad = targetAngleRad / 2;
        Offset arcLabelPos = Offset(
          cx + (r + 20) * math.cos(midRad),
          cy + (r + 20) * math.sin(midRad),
        );
        drawText(
          step >= 10 ? "L = 44m" : "Arc AB",
          Offset(arcLabelPos.dx - 20, arcLabelPos.dy - 10),
          accentGreen,
          14,
          FontWeight.bold,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArcWalkerPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.walkAngle != walkAngle;
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
    for (double i = -2000; i < 4000; i += step) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 4000), paint);
      canvas.drawLine(Offset(-2000, i), Offset(4000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
