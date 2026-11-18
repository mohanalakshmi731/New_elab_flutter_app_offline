// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

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
      'app_title': 'THE WIPER BLADE',
      'tagline': 'Area of Sectors in the Real World',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Wiper Blade',
      'header_subtitle': 'Class 10 • Areas Related to Circles',
      'phase_label': 'DIAGNOSTIC PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Area Cleared',
      'success_desc':
          'You have successfully calculated the total area cleaned at each sweep of the blades!',
      'btn_restart': 'NEW DIAGNOSTIC',
      's0': 'Initialize Windshield Grid. Car in position.',
      's1': 'Install Left Wiper. Blade length (r) = 25cm.',
      's2': 'Test Left Wiper Sweep. Angle (θ) = 115°.',
      's3': 'Install Right Wiper. Blade length (r) = 25cm.',
      's4': 'Test Right Wiper Sweep. Angle (θ) = 115°.',
      's5': 'Activate dual sweep. Observe non-overlapping areas.',
      's6': 'Set up the Sector Area formula.',
      's7': 'Substitute known values (r=25, θ=115°).',
      's8': 'Calculate Area swept by a SINGLE blade.',
      's9': 'Calculate TOTAL Area swept by BOTH blades.',
      'btn_start': 'DEPLOY WINDSHIELD',
      'btn_left_wiper': 'INSTALL LEFT WIPER',
      'btn_left_sweep': 'TEST LEFT SWEEP',
      'btn_right_wiper': 'INSTALL RIGHT WIPER',
      'btn_right_sweep': 'TEST RIGHT SWEEP',
      'btn_dual_sweep': 'ACTIVATE DUAL SWEEP',
      'btn_formula': 'LOAD SECTOR FORMULA',
      'btn_substitute': 'SUBSTITUTE VALUES',
      'btn_calc_single': 'CALCULATE SINGLE AREA',
      'btn_calc_total': 'CALCULATE TOTAL AREA',
      'msg_obs_ok': 'Windshield geometry locked. Vehicle ready.',
      'msg_lw_ok': 'Left wiper installed at Pivot 1.',
      'msg_ls_ok': 'Left sweep verified: 115° coverage.',
      'msg_rw_ok': 'Right wiper installed at Pivot 2.',
      'msg_rs_ok': 'Right sweep verified: 115° coverage.',
      'msg_ds_ok': 'Dual sweep active. Clearance optimal.',
      'msg_form_ok': 'Sector formula retrieved from database.',
      'msg_sub_ok': 'Values injected into mathematical model.',
      'msg_single_ok': 'Single blade area ≈ 627.48 cm².',
      'msg_final_ok': 'Total cleared area ≈ 1254.96 cm².',
      'msg_err': 'Calculation error. Check your math.',
      // Calculations Panel Strings
      'calc_title': 'Calculations & Data',
      'awaiting_specs': 'Awaiting system activation...',
      'single_area_title': '1. Single Sector Area',
      'single_area_form': 'A = (θ/360) × πr²',
      'single_area_sub': 'A = (115/360) × (22/7) × 25²',
      'single_area_res': 'A ≈ 627.48 cm²',
      'total_area_title': '2. Total Area Cleaned',
      'total_area_form': 'Total = 2 × Single Area',
      'total_area_sub': 'Total = 2 × 627.48',
      'total_area_res': '= 1254.96 cm²',
    },
    'hi': {
      'app_title': 'वाइपर ब्लेड',
      'tagline': 'वास्तविक दुनिया में त्रिज्यखंड का क्षेत्रफल',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'वाइपर ब्लेड',
      'header_subtitle': 'कक्षा 10 • वृत्तों से संबंधित क्षेत्रफल',
      'phase_label': 'निदान चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'क्षेत्र साफ़ किया गया',
      'success_desc':
          'आपने ब्लेड के प्रत्येक स्वीप पर साफ़ किए गए कुल क्षेत्र की सफलतापूर्वक गणना की है!',
      'btn_restart': 'नया निदान',
      's0': 'विंडशील्ड ग्रिड प्रारंभ करें। कार तैयार है।',
      's1': 'बायां वाइपर स्थापित करें। ब्लेड की लंबाई (r) = 25cm.',
      's2': 'बायां वाइपर स्वीप का परीक्षण करें। कोण (θ) = 115°.',
      's3': 'दायां वाइपर स्थापित करें। ब्लेड की लंबाई (r) = 25cm.',
      's4': 'दायां वाइपर स्वीप का परीक्षण करें। कोण (θ) = 115°.',
      's5':
          'दोहरा स्वीप सक्रिय करें। गैर-अतिव्यापी क्षेत्रों का निरीक्षण करें।',
      's6': 'त्रिज्यखंड क्षेत्रफल सूत्र सेट करें।',
      's7': 'ज्ञात मानों को प्रतिस्थापित करें (r=25, θ=115°)।',
      's8': 'एक ब्लेड द्वारा साफ़ किए गए क्षेत्रफल की गणना करें।',
      's9': 'दोनों ब्लेड द्वारा साफ़ किए गए कुल क्षेत्रफल की गणना करें।',
      'btn_start': 'विंडशील्ड तैनात करें',
      'btn_left_wiper': 'बायां वाइपर स्थापित करें',
      'btn_left_sweep': 'बायां स्वीप जांचें',
      'btn_right_wiper': 'दायां वाइपर स्थापित करें',
      'btn_right_sweep': 'दायां स्वीप जांचें',
      'btn_dual_sweep': 'दोहरा स्वीप चालू करें',
      'btn_formula': 'सूत्र लोड करें',
      'btn_substitute': 'मान प्रतिस्थापित करें',
      'btn_calc_single': 'एकल क्षेत्रफल की गणना करें',
      'btn_calc_total': 'कुल क्षेत्रफल की गणना करें',
      'msg_obs_ok': 'विंडशील्ड ज्यामिति लॉक हो गई। वाहन तैयार।',
      'msg_lw_ok': 'बायां वाइपर पिवट 1 पर स्थापित।',
      'msg_ls_ok': 'बायां स्वीप सत्यापित: 115° कवरेज।',
      'msg_rw_ok': 'दायां वाइपर पिवट 2 पर स्थापित।',
      'msg_rs_ok': 'दायां स्वीप सत्यापित: 115° कवरेज।',
      'msg_ds_ok': 'दोहरा स्वीप सक्रिय। निकासी इष्टतम।',
      'msg_form_ok': 'डेटाबेस से त्रिज्यखंड सूत्र प्राप्त किया गया।',
      'msg_sub_ok': 'मानों को गणितीय मॉडल में इंजेक्ट किया गया।',
      'msg_single_ok': 'सिंगल ब्लेड क्षेत्र ≈ 627.48 cm².',
      'msg_final_ok': 'कुल साफ़ क्षेत्र ≈ 1254.96 cm².',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
      // Calculations Panel Strings
      'calc_title': 'गणनाएँ एवं डेटा',
      'awaiting_specs': 'सिस्टम सक्रियण की प्रतीक्षा में...',
      'single_area_title': '1. एकल त्रिज्यखंड का क्षेत्रफल',
      'single_area_form': 'क्षेत्रफल = (θ/360) × πr²',
      'single_area_sub': 'क्षेत्रफल = (115/360) × (22/7) × 25²',
      'single_area_res': 'क्षेत्रफल ≈ 627.48 cm²',
      'total_area_title': '2. साफ़ किया गया कुल क्षेत्रफल',
      'total_area_form': 'कुल = 2 × एकल क्षेत्रफल',
      'total_area_sub': 'कुल = 2 × 627.48',
      'total_area_res': '= 1254.96 cm²',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class WiperBladeApp extends StatefulWidget {
  const WiperBladeApp({super.key});

  @override
  State<WiperBladeApp> createState() => _WiperBladeAppState();
}

class _WiperBladeAppState extends State<WiperBladeApp>
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
  double leftSweep = 0.0;
  double rightSweep = 0.0;
  late AnimationController _leftController;
  late AnimationController _rightController;
  late Animation<double> _leftAnimation;
  late Animation<double> _rightAnimation;

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Audio assets
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();

    // Strict Orientation & Immersive Mode as requested
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _leftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();

    // Dispose Audio
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    // Revert Orientation & Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  Future<void> _playSound(AudioPlayer player, String url) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void startGame() {
    _playSound(_fxPlayer, _shutterUrl);
    setState(() {
      hasStarted = true;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
    });
  }

  void switchLang(String newLang) {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      lang = newLang;
    });
  }

  void toggleLeftPanel() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      isLeftPanelOpen = !isLeftPanelOpen;
      if (isLeftPanelOpen) isRightPanelOpen = false;
    });
  }

  void toggleRightPanel() {
    _playSound(_clickPlayer, _clickUrl);
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
    if (isError) {
      _playSound(_errorPlayer, _errorUrl);
    }

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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgPanel,
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
    _playSound(_clickPlayer, _clickUrl);

    if (currentStep < 10) {
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Animation Triggers
        if (currentStep == 3) {
          _animateLeft(115.0);
        } else if (currentStep == 5) {
          _animateRight(115.0);
        } else if (currentStep == 6) {
          _leftController.repeat(reverse: true);
          _rightController.repeat(reverse: true);
        }

        if (currentStep == 10) {
          _playSound(_successPlayer, _successUrl);
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });

              Timer(const Duration(seconds: 6), () {
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

  void _animateLeft(double targetAngle) {
    _leftAnimation =
        Tween<double>(begin: leftSweep, end: targetAngle).animate(
          CurvedAnimation(parent: _leftController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            leftSweep = _leftAnimation.value;
          });
        });
    _leftController.forward(from: 0.0);
  }

  void _animateRight(double targetAngle) {
    _rightAnimation =
        Tween<double>(begin: rightSweep, end: targetAngle).animate(
          CurvedAnimation(parent: _rightController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            rightSweep = _rightAnimation.value;
          });
        });
    _rightController.forward(from: 0.0);
  }

  void resetLab() {
    _playSound(_fxPlayer, _shutterUrl);
    setState(() {
      lang = 'en'; // Reset language per requirements
      currentStep = 0;
      leftSweep = 0.0;
      rightSweep = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      _leftController.stop();
      _rightController.stop();
      _leftController.reset();
      _rightController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold Wrapped with GestureDetector to preserve Immersive UI Mode
    Widget buildBase({required Widget child}) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: child,
      );
    }

    if (!hasStarted) {
      return buildBase(
        child: Scaffold(
          backgroundColor: bgDark,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, size: 80, color: accentPink),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.get(lang, 'app_title'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: accentPink,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.get(lang, 'tagline'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
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
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    // Sidebar strictly 38% of screen width as per prompt
    double panelWidth = screenWidth * 0.38;

    return buildBase(
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // 1. CANVAS AREA (Center Activity - fully responsive)
            Positioned.fill(child: _buildInteractiveCanvas()),

            // 2. Right Panel (Calculations)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: isRightPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildRightPanel(),
            ),

            // 3. Left Panel (Mission/Controls Sidebar - 38%)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildLeftPanel(),
            ),

            // 4. FRONT SCREEN FLOATING ELEMENTS (Z-Index is high since they are at bottom of Stack)

            // Top-Left Floating Controls
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

            // 4.5 Floating Mission Card (Canvas Interactions when Sidebar is closed)
            if (!isLeftPanelOpen)
              Positioned(top: 85, left: 20, child: _buildFloatingCard()),

            // Bottom-Right Floating Controls
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

            // 5. Scrollable Success Modal (Popup)
            if (showSuccessModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: bgDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentGreen, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: accentGreen.withOpacity(0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              color: accentGreen,
                              size: 80,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.get(lang, 'badge_title').toUpperCase(),
                              textAlign: TextAlign.center,
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
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentPink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: resetLab,
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                AppStrings.get(lang, 'btn_restart'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
      ),
    );
  }

  // --- FLOATING ACTION BUTTON ---
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

  // --- FLOATING MISSION CARD (Visible when Left Panel is Closed) ---
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

  // --- LEFT SIDEBAR (38% Width, Scrollable, Contains Header, Target Output & Buttons) ---
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
      // Making Sidebar entirely scrollable
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(
                15,
                80,
                15,
                10,
              ), // Padding adjusted for floating buttons overlap
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
                        child: const Icon(Icons.directions_car, color: bgDark),
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
                      // Language Toggle
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
                      // Reset Button
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

            // CONTROLS & BUTTONS (MOVED UP)
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

            // TARGET OUTPUT / MISSION LOG (MOVED DOWN)
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
                    margin: const EdgeInsets.only(
                      bottom: 20,
                    ), // Bottom padding for scroll clear
                    child: ListView.builder(
                      shrinkWrap:
                          true, // Let it size itself inside SingleChildScrollView
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

  // --- RIGHT PANEL (Calculations) ---
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
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
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
                const SizedBox(width: 50),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep >= 6) ...[
                    Text(
                      AppStrings.get(lang, 'single_area_title'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'single_area_form'),
                      Colors.white70,
                    ),
                    if (currentStep >= 7) ...[
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'single_area_sub'),
                        Colors.white,
                      ),
                    ],
                    if (currentStep >= 8) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'single_area_res'),
                        accentPink,
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
                  if (currentStep >= 9) ...[
                    Text(
                      AppStrings.get(lang, 'total_area_title'),
                      style: const TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildMathRow(
                      AppStrings.get(lang, 'total_area_form'),
                      Colors.white70,
                    ),
                    const SizedBox(height: 10),
                    _buildMathRow(
                      AppStrings.get(lang, 'total_area_sub'),
                      Colors.white,
                    ),
                    if (currentStep >= 10) ...[
                      const SizedBox(height: 15),
                      _buildMathRow(
                        AppStrings.get(lang, 'total_area_res'),
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

  // --- CANVAS AREA (Responsive Center Activity) ---
  Widget _buildInteractiveCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(2000),
          minScale: 0.1,
          maxScale: 4.0,
          child: Center(
            child: SizedBox(
              width: 800,
              height: 600,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: CustomPaint(painter: GridPainter())),
                  Center(
                    child: SizedBox(
                      width: 800,
                      height: 600,
                      child: CustomPaint(
                        painter: WiperPainter(
                          step: currentStep,
                          leftSweep: leftSweep,
                          rightSweep: rightSweep,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          text: AppStrings.get(lang, 'btn_left_wiper'),
          color: accentPink,
          onPressed: () => advanceStep('msg_lw_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_left_sweep'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_ls_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_right_wiper'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_rw_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_right_sweep'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_rs_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_dual_sweep'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_ds_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_formula'),
          color: accentPink,
          onPressed: () {
            advanceStep('msg_form_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_substitute'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_sub_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_single'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_single_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_total'),
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

class WiperPainter extends CustomPainter {
  final int step;
  final double leftSweep;
  final double rightSweep;

  WiperPainter({
    required this.step,
    required this.leftSweep,
    required this.rightSweep,
  });

  void _drawRealisticWiper(
    Canvas canvas,
    Offset pivot,
    double angleRad,
    Color accentColor,
  ) {
    double r = 200.0;
    Offset midPt = Offset(
      pivot.dx + (r * 0.3) * math.cos(angleRad),
      pivot.dy + (r * 0.3) * math.sin(angleRad),
    );
    Offset endPt = Offset(
      pivot.dx + r * math.cos(angleRad),
      pivot.dy + r * math.sin(angleRad),
    );
    Offset rubberStart = Offset(
      pivot.dx + (r * 0.2) * math.cos(angleRad),
      pivot.dy + (r * 0.2) * math.sin(angleRad),
    );

    canvas.drawCircle(pivot, 14, Paint()..color = Colors.black);
    canvas.drawCircle(pivot, 7, Paint()..color = Colors.grey.shade700);

    canvas.drawLine(
      pivot,
      midPt,
      Paint()
        ..color = Colors.grey.shade800
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      midPt,
      endPt,
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      rubberStart,
      endPt,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.square,
    );

    canvas.drawLine(
      midPt,
      endPt,
      Paint()
        ..color = accentColor.withOpacity(0.8)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    double radius = 200.0;
    Offset centerLeft = const Offset(300, 415);
    Offset centerRight = const Offset(500, 415);

    double startAngleDeg = 170.0;
    double startAngleRad = -startAngleDeg * math.pi / 180;

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
        Paint()..color = bgDark.withOpacity(0.8),
      );
      textPainter.paint(canvas, pos);
    }

    Path carBody = Path()
      ..moveTo(220, 150)
      ..quadraticBezierTo(400, 120, 580, 150)
      ..lineTo(760, 420)
      ..quadraticBezierTo(810, 500, 790, 600)
      ..lineTo(10, 600)
      ..quadraticBezierTo(-10, 500, 40, 420)
      ..close();

    Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFF8FAFC), const Color(0xFF94A3B8)],
      ).createShader(const Rect.fromLTWH(0, 0, 800, 600));
    canvas.drawPath(carBody, bodyPaint);

    Path hood = Path()
      ..moveTo(40, 420)
      ..quadraticBezierTo(400, 460, 760, 420);
    canvas.drawPath(
      hood,
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    canvas.drawPath(
      Path()
        ..moveTo(250, 435)
        ..quadraticBezierTo(280, 500, 260, 560),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawPath(
      Path()
        ..moveTo(550, 435)
        ..quadraticBezierTo(520, 500, 540, 560),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    Path grille = Path()
      ..moveTo(290, 480)
      ..lineTo(510, 480)
      ..lineTo(540, 560)
      ..lineTo(260, 560)
      ..close();
    canvas.drawPath(grille, Paint()..color = Colors.black87);
    for (double i = 490; i <= 550; i += 12) {
      canvas.drawLine(
        Offset(275, i),
        Offset(525, i),
        Paint()
          ..color = Colors.white12
          ..strokeWidth = 2,
      );
    }

    canvas.drawPath(
      Path()
        ..moveTo(100, 540)
        ..lineTo(230, 540)
        ..lineTo(210, 580)
        ..lineTo(90, 580)
        ..close(),
      Paint()..color = Colors.black,
    );
    canvas.drawPath(
      Path()
        ..moveTo(700, 540)
        ..lineTo(570, 540)
        ..lineTo(590, 580)
        ..lineTo(710, 580)
        ..close(),
      Paint()..color = Colors.black,
    );

    Path leftHeadlight = Path()
      ..moveTo(80, 460)
      ..lineTo(250, 475)
      ..lineTo(230, 505)
      ..lineTo(70, 490)
      ..close();
    canvas.drawPath(
      leftHeadlight,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    canvas.drawLine(
      const Offset(85, 465),
      const Offset(240, 480),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    Path rightHeadlight = Path()
      ..moveTo(720, 460)
      ..lineTo(550, 475)
      ..lineTo(570, 505)
      ..lineTo(730, 490)
      ..close();
    canvas.drawPath(
      rightHeadlight,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    canvas.drawLine(
      const Offset(715, 465),
      const Offset(560, 480),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    Path leftMirror = Path()
      ..moveTo(60, 300)
      ..lineTo(10, 310)
      ..lineTo(0, 340)
      ..lineTo(50, 350)
      ..close();
    Path rightMirror = Path()
      ..moveTo(740, 300)
      ..lineTo(790, 310)
      ..lineTo(800, 340)
      ..lineTo(750, 350)
      ..close();
    canvas.drawPath(leftMirror, Paint()..color = const Color(0xFF0A0F14));
    canvas.drawPath(rightMirror, Paint()..color = const Color(0xFF0A0F14));

    canvas.drawRect(
      const Rect.fromLTWH(360, 565, 80, 20),
      Paint()..color = Colors.white,
    );
    drawText(
      "WIPER-10",
      const Offset(366, 568),
      Colors.black,
      12,
      FontWeight.bold,
    );

    canvas.drawOval(
      const Rect.fromLTWH(385, 465, 30, 15),
      Paint()..color = Colors.white70,
    );
    canvas.drawOval(
      const Rect.fromLTWH(390, 468, 20, 9),
      Paint()..color = Colors.black87,
    );

    if (step >= 1) {
      Path windshieldFrit = Path()
        ..moveTo(40, 420)
        ..lineTo(225, 155)
        ..quadraticBezierTo(400, 125, 575, 155)
        ..lineTo(760, 420)
        ..quadraticBezierTo(400, 440, 40, 420)
        ..close();

      canvas.drawPath(windshieldFrit, Paint()..color = const Color(0xFF05080A));

      Path windshieldGlass = Path()
        ..moveTo(60, 405)
        ..lineTo(235, 170)
        ..quadraticBezierTo(400, 140, 565, 170)
        ..lineTo(740, 405)
        ..quadraticBezierTo(400, 425, 60, 405)
        ..close();

      Paint glassPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.withOpacity(0.2),
            Colors.blueGrey.withOpacity(0.4),
            Colors.cyan.withOpacity(0.15),
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 800, 600));

      canvas.drawPath(windshieldGlass, glassPaint);

      Path reflection1 = Path()
        ..moveTo(250, 180)
        ..lineTo(300, 177)
        ..lineTo(140, 395)
        ..lineTo(90, 395)
        ..close();
      Path reflection2 = Path()
        ..moveTo(330, 175)
        ..lineTo(350, 174)
        ..lineTo(190, 398)
        ..lineTo(170, 398)
        ..close();
      Paint reflPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 800, 600));

      canvas.drawPath(reflection1, reflPaint);
      canvas.drawPath(reflection2, reflPaint);
    }

    if (step >= 3) {
      double sweepRad = leftSweep * math.pi / 180;
      if (leftSweep > 0) {
        Path sector = Path()
          ..moveTo(centerLeft.dx, centerLeft.dy)
          ..arcTo(
            Rect.fromCircle(center: centerLeft, radius: radius),
            startAngleRad,
            sweepRad,
            false,
          )
          ..close();

        canvas.drawPath(
          sector,
          Paint()
            ..color = accentPink.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          sector,
          Paint()
            ..color = Colors.lightBlueAccent.withOpacity(0.15)
            ..style = PaintingStyle.fill,
        );

        canvas.drawArc(
          Rect.fromCircle(center: centerLeft, radius: radius),
          startAngleRad,
          sweepRad,
          false,
          Paint()
            ..color = accentPink.withOpacity(0.8)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }

      if (step < 4 && leftSweep > 100) {
        drawText(
          "r = 25cm",
          Offset(centerLeft.dx - 30, centerLeft.dy - 80),
          accentPink,
          16,
          FontWeight.bold,
        );
        drawText(
          "θ = 115°",
          Offset(centerLeft.dx + 40, centerLeft.dy - 40),
          accentYellow,
          16,
          FontWeight.bold,
        );
      }
    }

    if (step >= 5) {
      double sweepRad = rightSweep * math.pi / 180;
      if (rightSweep > 0) {
        Path sector = Path()
          ..moveTo(centerRight.dx, centerRight.dy)
          ..arcTo(
            Rect.fromCircle(center: centerRight, radius: radius),
            startAngleRad,
            sweepRad,
            false,
          )
          ..close();

        canvas.drawPath(
          sector,
          Paint()
            ..color = accentBlue.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          sector,
          Paint()
            ..color = Colors.lightBlueAccent.withOpacity(0.15)
            ..style = PaintingStyle.fill,
        );

        canvas.drawArc(
          Rect.fromCircle(center: centerRight, radius: radius),
          startAngleRad,
          sweepRad,
          false,
          Paint()
            ..color = accentBlue.withOpacity(0.8)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }

      if (step < 6 && rightSweep > 100) {
        drawText(
          "r = 25cm",
          Offset(centerRight.dx - 30, centerRight.dy - 80),
          accentBlue,
          16,
          FontWeight.bold,
        );
        drawText(
          "θ = 115°",
          Offset(centerRight.dx + 40, centerRight.dy - 40),
          accentYellow,
          16,
          FontWeight.bold,
        );
      }
    }

    if (step >= 2) {
      if (step < 4) {
        drawText(
          "Pivot 1",
          Offset(centerLeft.dx - 30, centerLeft.dy + 20),
          accentPink,
          14,
          FontWeight.bold,
        );
      }
      double currentAngleRad =
          startAngleRad + (step >= 3 ? leftSweep * math.pi / 180 : 0);
      _drawRealisticWiper(canvas, centerLeft, currentAngleRad, accentPink);
    }

    if (step >= 4) {
      if (step < 6) {
        drawText(
          "Pivot 2",
          Offset(centerRight.dx - 30, centerRight.dy + 20),
          accentBlue,
          14,
          FontWeight.bold,
        );
      }
      double currentAngleRad =
          startAngleRad + (step >= 5 ? rightSweep * math.pi / 180 : 0);
      _drawRealisticWiper(canvas, centerRight, currentAngleRad, accentBlue);
    }

    if (step >= 6 && step < 10) {
      drawText(
        "NO OVERLAP",
        const Offset(355, 260),
        accentGreen,
        16,
        FontWeight.bold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WiperPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.leftSweep != leftSweep ||
        oldDelegate.rightSweep != rightSweep;
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
    }
    for (double i = -2000; i < 4000; i += step) {
      canvas.drawLine(Offset(-2000, i), Offset(4000, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
