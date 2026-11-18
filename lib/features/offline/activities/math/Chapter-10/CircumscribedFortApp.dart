// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

// रंग योजना (Color Palette)
const Color bgDark = Color(0xFF020617);
const Color bgPanel = Color(0xFF0F172A);
const Color accentPink = Color(0xFFF472B6);
const Color accentBlue = Color(0xFF3B82F6);
const Color accentGreen = Color(0xFF22C55E);
const Color accentRed = Color(0xFFEF4444);
const Color accentYellow = Color(0xFFFACC15);

// एप्लिकेशन के टेक्स्ट स्ट्रिंग्स (App Strings)
class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'app_title': 'THE CIRCUMSCRIBED FORT',
      'tagline': 'Quadrilateral Circumscribing a Circle',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Circumscribed Fort',
      'header_subtitle': 'Class 10 • Circles',
      'phase_label': 'ANALYSIS PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Theorem Verified',
      'success_desc':
          'You have successfully proven that the sum of opposite sides are equal!',
      'btn_restart': 'NEW ANALYSIS',
      'data_panel': 'Data Collection',
      's0': 'Initialize Grid. Locate Center O & Circle.',
      's1': 'Construct Circumscribing Quadrilateral ABCD.',
      's2': 'Identify points of contact: P, Q, R, S.',
      's3': 'Analyze Vertex A (Theorem 10.2).',
      's4': 'Analyze Vertex B (Theorem 10.2).',
      's5': 'Analyze Vertex C (Theorem 10.2).',
      's6': 'Analyze Vertex D (Theorem 10.2).',
      's7': 'Sum the four equal tangent equations.',
      's8': 'Group segments into full quadrilateral sides.',
      's9': 'Verify Final Theorem: AB + CD = AD + BC.',
      'btn_start': 'ESTABLISH CENTER O',
      'btn_draw_quad': 'CONSTRUCT QUAD ABCD',
      'btn_id_points': 'MARK CONTACT POINTS',
      'btn_analyze_a': 'ANALYZE VERTEX A',
      'btn_analyze_b': 'ANALYZE VERTEX B',
      'btn_analyze_c': 'ANALYZE VERTEX C',
      'btn_analyze_d': 'ANALYZE VERTEX D',
      'btn_sum_eq': 'SUM EQUATIONS',
      'btn_group_seg': 'GROUP SEGMENTS',
      'btn_complete': 'FINALIZE PROOF',
      'msg_obs_ok': 'Center O and Circle established.',
      'msg_quad_ok': 'Quadrilateral ABCD constructed.',
      'msg_pts_ok': 'Contact points P, Q, R, S identified.',
      'msg_a_ok': 'Vertex A analyzed: AP = AS.',
      'msg_b_ok': 'Vertex B analyzed: BP = BQ.',
      'msg_c_ok': 'Vertex C analyzed: CR = CQ.',
      'msg_d_ok': 'Vertex D analyzed: DR = DS.',
      'msg_sum_ok': 'Equations summed successfully.',
      'msg_grp_ok': 'Segments grouped into full sides.',
      'msg_final_ok': 'Theorem verified: AB + CD = AD + BC.',
      'msg_err': 'Calculation error. Check your math.',
    },
    'hi': {
      'app_title': 'परिगत किला',
      'tagline': 'वृत्त के परिगत चतुर्भुज',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'परिगत किला',
      'header_subtitle': 'कक्षा 10 • वृत्त',
      'phase_label': 'विश्लेषण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'प्रमेय सत्यापित',
      'success_desc':
          'आपने सफलतापूर्वक सिद्ध कर दिया है कि विपरीत भुजाओं का योग बराबर होता है!',
      'btn_restart': 'नया विश्लेषण',
      'data_panel': 'डेटा संग्रह',
      's0': 'ग्रिड प्रारंभ करें। केंद्र O और वृत्त खोजें।',
      's1': 'परिगत चतुर्भुज ABCD बनाएँ।',
      's2': 'संपर्क बिंदुओं की पहचान करें: P, Q, R, S.',
      's3': 'शीर्ष A का विश्लेषण करें (प्रमेय 10.2)।',
      's4': 'शीर्ष B का विश्लेषण करें (प्रमेय 10.2)।',
      's5': 'शीर्ष C का विश्लेषण करें (प्रमेय 10.2)।',
      's6': 'शीर्ष D का विश्लेषण करें (प्रमेय 10.2)।',
      's7': 'चार समान स्पर्शरेखा समीकरणों का योग करें।',
      's8': 'खंडों को पूर्ण चतुर्भुज भुजाओं में समूहित करें।',
      's9': 'अंतिम प्रमेय सत्यापित करें: AB + CD = AD + BC.',
      'btn_start': 'केंद्र O स्थापित करें',
      'btn_draw_quad': 'चतुर्भुज ABCD बनाएँ',
      'btn_id_points': 'संपर्क बिंदु चिह्नित करें',
      'btn_analyze_a': 'शीर्ष A का विश्लेषण करें',
      'btn_analyze_b': 'शीर्ष B का विश्लेषण करें',
      'btn_analyze_c': 'शीर्ष C का विश्लेषण करें',
      'btn_analyze_d': 'शीर्ष D का विश्लेषण करें',
      'btn_sum_eq': 'समीकरणों का योग करें',
      'btn_group_seg': 'खंडों का समूह बनाएं',
      'btn_complete': 'प्रमाण पूरा करें',
      'msg_obs_ok': 'केंद्र O और वृत्त स्थापित।',
      'msg_quad_ok': 'चतुर्भुज ABCD निर्मित।',
      'msg_pts_ok': 'संपर्क बिंदु P, Q, R, S पहचाने गए।',
      'msg_a_ok': 'शीर्ष A का विश्लेषण किया गया: AP = AS.',
      'msg_b_ok': 'शीर्ष B का विश्लेषण किया गया: BP = BQ.',
      'msg_c_ok': 'शीर्ष C का विश्लेषण किया गया: CR = CQ.',
      'msg_d_ok': 'शीर्ष D का विश्लेषण किया गया: DR = DS.',
      'msg_sum_ok': 'समीकरणों का योग सफलतापूर्वक किया गया।',
      'msg_grp_ok': 'खंडों को पूर्ण भुजाओं में समूहीकृत किया गया।',
      'msg_final_ok': 'प्रमेय सत्यापित: AB + CD = AD + BC.',
      'msg_err': 'गणना त्रुटि। अपनी गणित की जाँच करें।',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class CircumscribedFortApp extends StatefulWidget {
  const CircumscribedFortApp({super.key});

  @override
  State<CircumscribedFortApp> createState() => _CircumscribedFortAppState();
}

class _CircumscribedFortAppState extends State<CircumscribedFortApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int currentStep = 0;
  bool showSuccessModal = false;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Audio assets
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();

    // Strict Orientation & Immersive Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
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
    if (!mounted) return; // Prevent playback if the widget has been closed
    try {
      await player.stop();
      if (!mounted) return;
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

  // बायां पैनल टॉगल (Toggle Left Panel)
  void toggleLeftPanel() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      isLeftPanelOpen = !isLeftPanelOpen;
      if (isLeftPanelOpen) {
        isRightPanelOpen = false;
      }
    });
  }

  // दायां पैनल टॉगल (Toggle Right Panel)
  void toggleRightPanel() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      isRightPanelOpen = !isRightPanelOpen;
      if (isRightPanelOpen) {
        isLeftPanelOpen = false;
      }
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

        if (currentStep == 10) {
          _playSound(_successPlayer, _successUrl);
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                showSuccessModal = true;
              });
            }
          });
        }
      });
    }
  }

  void resetLab() {
    _playSound(_fxPlayer, _shutterUrl);
    setState(() {
      lang = 'en'; // Reset language per requirements
      currentStep = 0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
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
                  const Icon(Icons.shield, size: 80, color: accentPink),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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

            // 2. Right Side-Panel (Data/Calculations)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: isRightPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildRightSidebar(),
            ),

            // 3. Left Side-Panel (Mission/Controls Sidebar - 38%)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isLeftPanelOpen ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildLeftSidebar(),
            ),

            // 4. FRONT SCREEN FLOATING ELEMENTS (Z-Index high)

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
              Positioned(top: 85, left: 20, child: _buildFloatingMissionCard()),

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
                tooltip: 'Data / Collections',
              ),
            ),

            // 5. Scrollable Success Modal (Popup) with Restart Button
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
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
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

  // --- CANVAS AREA (Responsive Center Activity) ---
  Widget _buildInteractiveCanvas() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 5.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 3000,
            height: 3000,
            child: CustomPaint(painter: GridPainter()),
          ),
          SizedBox(
            width: 500,
            height: 380,
            child: CustomPaint(painter: FortPainter(step: currentStep)),
          ),
        ],
      ),
    );
  }

  // --- FLOATING MISSION CARD (Visible when Left Panel is Closed) ---
  Widget _buildFloatingMissionCard() {
    int safeStepIndex = currentStep < 10 ? currentStep : 9;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                : AppStrings.get(lang, 's$safeStepIndex'),
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
  Widget _buildLeftSidebar() {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        child: const Icon(Icons.shield, color: bgDark),
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

            // CONTROLS & CURRENT OBJECTIVE (Placed on top of the diagnosis phase/steps)
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

            // TARGET OUTPUT / DIAGNOSTIC LOG (Placed underneath)
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
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        bool isActive = index == currentStep;
                        bool isDone = index < currentStep;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
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
                              fontSize: 14,
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

  // --- RIGHT PANEL (Data & Calculations) ---
  Widget _buildRightSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: bgPanel,
        border: const Border(left: BorderSide(color: Colors.white12, width: 2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(-5, 0),
          ),
        ],
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const Icon(Icons.analytics_outlined, color: accentBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.get(lang, 'data_panel').toUpperCase(),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (currentStep < 4)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text(
                            "Awaiting vertex analysis...\n(शीर्ष विश्लेषण की प्रतीक्षा...)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white30,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    if (currentStep >= 4) ...[
                      _buildDataSectionTitle(
                        "Tangent Equalities",
                        Icons.linear_scale,
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentStep >= 4)
                              _buildEquationLine("AP = AS", accentPink),
                            if (currentStep >= 5) const SizedBox(height: 10),
                            if (currentStep >= 5)
                              _buildEquationLine("BP = BQ", accentBlue),
                            if (currentStep >= 6) const SizedBox(height: 10),
                            if (currentStep >= 6)
                              _buildEquationLine("CR = CQ", accentGreen),
                            if (currentStep >= 7) const SizedBox(height: 10),
                            if (currentStep >= 7)
                              _buildEquationLine("DR = DS", accentYellow),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (currentStep >= 8) ...[
                      _buildDataSectionTitle(
                        "Summation & Grouping",
                        Icons.functions,
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Adding all 4 equations:",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "AP + BP + CR + DR = AS + BQ + CQ + DS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            if (currentStep >= 9) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: Colors.white12),
                              ),
                              const Text(
                                "Grouping segments into sides:",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "(AP + BP) + (CR + DR) = (AS + DS) + (BQ + CQ)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (currentStep >= 10) ...[
                      _buildDataSectionTitle(
                        "Final Theorem",
                        Icons.check_circle_outline,
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentGreen, width: 2),
                        ),
                        child: const Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "AB + CD = AD + BC",
                              style: TextStyle(
                                color: accentGreen,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquationLine(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
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
          text: AppStrings.get(lang, 'btn_draw_quad'),
          color: accentPink,
          onPressed: () => advanceStep('msg_quad_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_points'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_pts_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_analyze_a'),
          color: accentPink,
          onPressed: () => advanceStep('msg_a_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_analyze_b'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_b_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_analyze_c'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_c_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_analyze_d'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_d_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_sum_eq'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_sum_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_group_seg'),
          color: accentPink,
          onPressed: () => advanceStep('msg_grp_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
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

class FortPainter extends CustomPainter {
  final int step;

  FortPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = 250;
    double cy = 180;
    double r = 80;

    Offset ptO = Offset(cx, cy);

    Offset ptP = const Offset(250, 100);
    Offset ptQ = const Offset(327.3, 200.7);
    Offset ptR = const Offset(250, 260);
    Offset ptS = const Offset(170, 180);

    Offset ptA = const Offset(170, 100);
    Offset ptB = const Offset(354.3, 100);
    Offset ptC = const Offset(311.4, 260);
    Offset ptD = const Offset(170, 260);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawText(
      String text,
      Offset pos,
      Color color,
      double size,
      FontWeight weight,
    ) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
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
      canvas.drawCircle(
        ptO,
        r,
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        ptO,
        r,
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(ptO, 4, Paint()..color = Colors.white);
      drawText(
        "O",
        Offset(ptO.dx - 5, ptO.dy + 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
    }

    if (step >= 2) {
      Path quadPath = Path()
        ..moveTo(ptA.dx, ptA.dy)
        ..lineTo(ptB.dx, ptB.dy)
        ..lineTo(ptC.dx, ptC.dy)
        ..lineTo(ptD.dx, ptD.dy)
        ..close();
      canvas.drawPath(
        quadPath,
        Paint()
          ..color = Colors.white10
          ..style = PaintingStyle.fill,
      );

      if (step < 4) {
        canvas.drawPath(
          quadPath,
          Paint()
            ..color = Colors.white30
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }

      canvas.drawCircle(ptA, 5, Paint()..color = Colors.white);
      canvas.drawCircle(ptB, 5, Paint()..color = Colors.white);
      canvas.drawCircle(ptC, 5, Paint()..color = Colors.white);
      canvas.drawCircle(ptD, 5, Paint()..color = Colors.white);

      drawText(
        "A",
        Offset(ptA.dx - 20, ptA.dy - 20),
        Colors.white,
        18,
        FontWeight.bold,
      );
      drawText(
        "B",
        Offset(ptB.dx + 10, ptB.dy - 20),
        Colors.white,
        18,
        FontWeight.bold,
      );
      drawText(
        "C",
        Offset(ptC.dx + 10, ptC.dy + 10),
        Colors.white,
        18,
        FontWeight.bold,
      );
      drawText(
        "D",
        Offset(ptD.dx - 20, ptD.dy + 10),
        Colors.white,
        18,
        FontWeight.bold,
      );
    }

    if (step >= 3) {
      canvas.drawCircle(ptP, 4, Paint()..color = Colors.white);
      canvas.drawCircle(ptQ, 4, Paint()..color = Colors.white);
      canvas.drawCircle(ptR, 4, Paint()..color = Colors.white);
      canvas.drawCircle(ptS, 4, Paint()..color = Colors.white);

      drawText(
        "P",
        Offset(ptP.dx - 5, ptP.dy - 25),
        Colors.white70,
        14,
        FontWeight.bold,
      );
      drawText(
        "Q",
        Offset(ptQ.dx + 10, ptQ.dy - 10),
        Colors.white70,
        14,
        FontWeight.bold,
      );
      drawText(
        "R",
        Offset(ptR.dx - 5, ptR.dy + 10),
        Colors.white70,
        14,
        FontWeight.bold,
      );
      drawText(
        "S",
        Offset(ptS.dx - 20, ptS.dy - 10),
        Colors.white70,
        14,
        FontWeight.bold,
      );
    }

    if (step >= 4) {
      final basePaint = Paint()
        ..color = Colors.white30
        ..strokeWidth = 2;
      canvas.drawLine(ptA, ptP, basePaint);
      canvas.drawLine(ptP, ptB, basePaint);
      canvas.drawLine(ptB, ptQ, basePaint);
      canvas.drawLine(ptQ, ptC, basePaint);
      canvas.drawLine(ptC, ptR, basePaint);
      canvas.drawLine(ptR, ptD, basePaint);
      canvas.drawLine(ptD, ptS, basePaint);
      canvas.drawLine(ptS, ptA, basePaint);
    }

    if (step >= 4) {
      final pA = Paint()
        ..color = accentPink
        ..strokeWidth = step >= 9 ? 6 : 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(ptA, ptP, pA);
      canvas.drawLine(ptA, ptS, pA);
    }

    if (step >= 5) {
      final pB = Paint()
        ..color = accentBlue
        ..strokeWidth = step >= 9 ? 6 : 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(ptB, ptP, pB);
      canvas.drawLine(ptB, ptQ, pB);
    }

    if (step >= 6) {
      final pC = Paint()
        ..color = accentGreen
        ..strokeWidth = step >= 9 ? 6 : 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(ptC, ptR, pC);
      canvas.drawLine(ptC, ptQ, pC);
    }

    if (step >= 7) {
      final pD = Paint()
        ..color = accentYellow
        ..strokeWidth = step >= 9 ? 6 : 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(ptD, ptR, pD);
      canvas.drawLine(ptD, ptS, pD);
    }
  }

  @override
  bool shouldRepaint(covariant FortPainter oldDelegate) {
    return oldDelegate.step != step;
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
