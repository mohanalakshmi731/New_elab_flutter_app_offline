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
      'app_title': 'THE CONCENTRIC RING',
      'tagline': 'Properties of Concentric Circles',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Concentric Ring',
      'header_subtitle': 'Class 10 • Circles',
      'phase_label': 'EXPLORATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Theorem Verified',
      'success_desc':
          'You have successfully proven that the chord of the larger circle is bisected at the point of contact.',
      'btn_restart': 'NEW EXPLORATION',
      'data_panel_title': 'Calculations & Data',
      's0': 'Initialize Grid. Locate Center O.',
      's1': 'Construct Inner Circle (radius r).',
      's2': 'Construct Outer Circle (radius R).',
      's3': 'Draw an arbitrary Chord AB of the Outer Circle.',
      's4': 'Translate Chord AB to touch Inner Circle at point P.',
      's5': 'Construct Inner Radius OP.',
      's6': 'Verify Angle: Radius ⟂ Tangent (Theorem 10.1).',
      's7': 'Measure segments AP and PB.',
      's8': 'Apply Perpendicular Bisector property.',
      's9': 'Confirm Equality: AP = PB.',
      'btn_start': 'ESTABLISH CENTER O',
      'btn_draw_inner': 'DRAW INNER CIRCLE',
      'btn_draw_outer': 'DRAW OUTER CIRCLE',
      'btn_draw_chord': 'DRAW CHORD AB',
      'btn_move_chord': 'MAKE AB TANGENT',
      'btn_draw_op': 'CONSTRUCT RADIUS OP',
      'btn_verify_ang': 'VERIFY 90° ANGLE',
      'btn_meas_segments': 'MEASURE AP & PB',
      'btn_apply_bisect': 'APPLY BISECTION',
      'btn_complete': 'FINALIZE REPORT',
      'msg_obs_ok': 'Center O established at origin.',
      'msg_inner_ok': 'Inner circle (r) constructed.',
      'msg_outer_ok': 'Outer circle (R) constructed.',
      'msg_chord_ok': 'Chord AB drawn across outer circle.',
      'msg_move_ok': 'Chord translated. Now tangent to inner circle at P.',
      'msg_op_ok': 'Radius OP constructed to point of contact.',
      'msg_ang_ok': 'Angle measured: 90° (Radius ⟂ Tangent).',
      'msg_meas_ok': 'Lengths of AP and PB measured.',
      'msg_bisect_ok': 'Perpendicular from center bisects chord confirmed.',
      'msg_final_ok': 'Theorem verified: AP = PB.',
      'msg_err': 'Calculation error. Check your math.',
    },
    'hi': {
      'app_title': 'कंसेंट्रिक रिंग',
      'tagline': 'संकेंद्री वृत्तों के गुण',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'कंसेंट्रिक रिंग',
      'header_subtitle': 'कक्षा 10 • वृत्त',
      'phase_label': 'अन्वेषण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'प्रमेय सत्यापित',
      'success_desc':
          'आपने सफलतापूर्वक सिद्ध कर दिया है कि बड़े वृत्त की जीवा संपर्क बिंदु पर समद्विभाजित होती है।',
      'btn_restart': 'नया अन्वेषण',
      'data_panel_title': 'गणना और डेटा',
      's0': 'ग्रिड प्रारंभ करें। केंद्र O खोजें।',
      's1': 'आंतरिक वृत्त (त्रिज्या r) बनाएँ।',
      's2': 'बाहरी वृत्त (त्रिज्या R) बनाएँ।',
      's3': 'बाहरी वृत्त की एक मनमानी जीवा AB खींचें।',
      's4': 'जीवा AB को बिंदु P पर आंतरिक वृत्त को छूने के लिए खिसकाएं।',
      's5': 'आंतरिक त्रिज्या OP का निर्माण करें।',
      's6': 'कोण सत्यापित करें: त्रिज्या ⟂ स्पर्शरेखा (प्रमेय 10.1)।',
      's7': 'खंड AP और PB को मापें।',
      's8': 'लंब समद्विभाजक गुण लागू करें।',
      's9': 'समानता की पुष्टि करें: AP = PB।',
      'btn_start': 'केंद्र O स्थापित करें',
      'btn_draw_inner': 'आंतरिक वृत्त बनाएँ',
      'btn_draw_outer': 'बाहरी वृत्त बनाएँ',
      'btn_draw_chord': 'जीवा AB खींचें',
      'btn_move_chord': 'AB को स्पर्शरेखा बनाएँ',
      'btn_draw_op': 'त्रिज्या OP बनाएँ',
      'btn_verify_ang': '90° कोण सत्यापित करें',
      'btn_meas_segments': 'AP और PB मापें',
      'btn_apply_bisect': 'समद्विभाजन लागू करें',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_obs_ok': 'केंद्र O स्थापित।',
      'msg_inner_ok': 'आंतरिक वृत्त (r) निर्मित।',
      'msg_outer_ok': 'बाहरी वृत्त (R) निर्मित।',
      'msg_chord_ok': 'जीवा AB खींची गई।',
      'msg_move_ok': 'जीवा स्थानांतरित। अब P पर स्पर्शरेखा है।',
      'msg_op_ok': 'संपर्क बिंदु तक त्रिज्या OP निर्मित।',
      'msg_ang_ok': 'कोण मापा गया: 90° (त्रिज्या ⟂ स्पर्शरेखा)।',
      'msg_meas_ok': 'AP और PB की लंबाई मापी गई।',
      'msg_bisect_ok': 'केंद्र से लंब जीवा को समद्विभाजित करता है।',
      'msg_final_ok': 'प्रमेय सत्यापित: AP = PB.',
      'msg_err': 'गणना त्रुटि।',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class ConcentricRingApp extends StatefulWidget {
  const ConcentricRingApp({super.key});

  @override
  State<ConcentricRingApp> createState() => _ConcentricRingAppState();
}

class _ConcentricRingAppState extends State<ConcentricRingApp>
    with TickerProviderStateMixin {
  bool hasStarted = false;
  String lang = 'en';

  bool isLeftPanelOpen = true;
  bool isRightPanelOpen = false;

  int currentStep = 0;
  bool showSuccessModal = false;

  double chordDist = 30.0;
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  // Audio Players (Using 'final' to prevent dispose crashes on hot-reload/navigation)
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
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Pre-load audio sources to eliminate delay on first click
    _clickPlayer.setSource(AssetSource(_clickUrl));
    _fxPlayer.setSource(AssetSource(_shutterUrl));
    _successPlayer.setSource(AssetSource(_successUrl));
    _errorPlayer.setSource(AssetSource(_errorUrl));

    // Strict Orientation & Immersive Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _moveController.dispose();

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

  Future<void> _playSound(AudioPlayer player) async {
    if (!mounted) return;
    try {
      // Seek to zero and resume for instant playback of pre-loaded sources
      await player.seek(Duration.zero);
      if (!mounted) return;
      await player.resume();
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void startGame() {
    _playSound(_fxPlayer);
    setState(() {
      hasStarted = true;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
    });
  }

  void switchLang(String newLang) {
    _playSound(_clickPlayer);
    setState(() {
      lang = newLang;
    });
  }

  void toggleLeftPanel() {
    _playSound(_clickPlayer);
    setState(() {
      isLeftPanelOpen = !isLeftPanelOpen;
      if (isLeftPanelOpen) isRightPanelOpen = false;
    });
  }

  void toggleRightPanel() {
    _playSound(_clickPlayer);
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
      _playSound(_errorPlayer);
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
    _playSound(_clickPlayer);
    if (currentStep < 10) {
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Animate chord when step 4 is completed (currentStep becomes 5)
        if (currentStep == 5) {
          _animateChord(60.0); // Animate to rInner
        }

        if (currentStep == 10) {
          _playSound(_successPlayer);
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

  void _animateChord(double targetDist) {
    _moveAnimation =
        Tween<double>(begin: chordDist, end: targetDist).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            chordDist = _moveAnimation.value;
          });
        });
    _moveController.forward(from: 0.0);
  }

  void resetLab() {
    _playSound(_fxPlayer);
    setState(() {
      lang = 'en'; // Reset language per requirements
      currentStep = 0;
      chordDist = 30.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      _moveController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap to preserve immersive UI
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
      return buildBase(child: _buildSplashScreen());
    }

    double screenW = MediaQuery.of(context).size.width;
    // Sidebar strictly 38% of screen width
    double panelWidth = screenW * 0.38;

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

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.track_changes, size: 80, color: accentPink),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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

  // --- CANVAS AREA ---
  Widget _buildInteractiveCanvas() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.2,
      maxScale: 5.0,
      child: Stack(
        clipBehavior: Clip.none,
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
            child: CustomPaint(
              size: const Size(500, 380),
              painter: ConcentricPainter(
                step: currentStep,
                chordDist: chordDist,
              ),
            ),
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
          _buildActionControls(),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 80, 15, 10),
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
                        child: const Icon(Icons.architecture, color: bgDark),
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
                  _buildActionControls(),
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
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ListView.builder(
                      shrinkWrap: true,
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
    double r = 60.0;
    double rOuter = 100.0;
    double ap = math.sqrt(rOuter * rOuter - r * r); // 80

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
                  const Icon(Icons.analytics, color: accentYellow),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.get(lang, 'data_panel_title').toUpperCase(),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentStep < 5)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Text(
                            "Awaiting geometric construction...\nComplete steps on the left.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white30,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    if (currentStep >= 5) ...[
                      _buildDataCard(
                        title: "Theorem 10.1",
                        color: accentBlue,
                        children: [
                          const Text(
                            "AB is tangent to Inner Circle",
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          if (currentStep >= 7) ...[
                            const SizedBox(height: 10),
                            const Text(
                              "Radius OP ⟂ Chord AB",
                              style: TextStyle(
                                color: accentGreen,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              "∠OPA = ∠OPB = 90°",
                              style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    if (currentStep >= 8) ...[
                      const SizedBox(height: 20),
                      _buildDataCard(
                        title: "Pythagoras in ΔOPA",
                        color: accentPink,
                        children: [
                          const Text(
                            "AP² + OP² = OA²",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "AP² = R² - r²",
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "AP = √(${rOuter.toInt()}² - ${r.toInt()}²)",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "AP = ${ap.toInt()}",
                            style: const TextStyle(
                              color: accentYellow,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Similarly in ΔOPB,",
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "PB = ${ap.toInt()}",
                            style: const TextStyle(
                              color: accentYellow,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (currentStep >= 9) ...[
                      const SizedBox(height: 20),
                      _buildDataCard(
                        title: "Conclusion",
                        color: accentGreen,
                        children: [
                          const Text(
                            "Perpendicular drawn from the center bisects the chord.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          if (currentStep >= 10) ...[
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: accentYellow.withOpacity(0.1),
                                border: Border.all(color: accentYellow),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "AP = PB",
                                  style: TextStyle(
                                    color: accentYellow,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildActionControls() {
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
          text: AppStrings.get(lang, 'btn_draw_inner'),
          color: accentPink,
          onPressed: () => advanceStep('msg_inner_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_outer'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_outer_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_chord'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_chord_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_move_chord'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_move_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_op'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_op_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_verify_ang'),
          color: accentPink,
          onPressed: () => advanceStep('msg_ang_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_meas_segments'),
          color: accentYellow,
          onPressed: () {
            advanceStep('msg_meas_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_apply_bisect'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_bisect_ok'),
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_complete'),
          color: accentBlue,
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

class ConcentricPainter extends CustomPainter {
  final int step;
  final double chordDist;

  ConcentricPainter({required this.step, required this.chordDist});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = 250;
    double cy = 190;
    double rInner = 60.0;
    double rOuter = 100.0;

    Offset ptO = Offset(cx, cy);

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
      canvas.drawCircle(
        ptO,
        rInner,
        Paint()
          ..color = accentPink
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        ptO,
        rInner,
        Paint()
          ..color = accentPink.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
      if (step < 4) {
        drawText(
          "r",
          Offset(ptO.dx + 20, ptO.dy - 20),
          accentPink,
          14,
          FontWeight.bold,
        );
      }
    }

    if (step >= 3) {
      canvas.drawCircle(
        ptO,
        rOuter,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        ptO,
        rOuter,
        Paint()
          ..color = accentBlue.withOpacity(0.05)
          ..style = PaintingStyle.fill,
      );
      if (step < 4) {
        drawText(
          "R",
          Offset(ptO.dx + 60, ptO.dy + 60),
          accentBlue,
          14,
          FontWeight.bold,
        );
      }
    }

    if (step >= 4) {
      double d = chordDist;
      double dxOuter = math.sqrt(rOuter * rOuter - d * d);

      Offset ptA = Offset(ptO.dx - dxOuter, ptO.dy - d);
      Offset ptB = Offset(ptO.dx + dxOuter, ptO.dy - d);
      Offset ptP = Offset(ptO.dx, ptO.dy - d);

      canvas.drawLine(
        ptA,
        ptB,
        Paint()
          ..color = step >= 5 ? accentYellow : Colors.white
          ..strokeWidth = 3,
      );

      canvas.drawCircle(ptA, 5, Paint()..color = Colors.white);
      canvas.drawCircle(ptB, 5, Paint()..color = Colors.white);
      drawText(
        "A",
        Offset(ptA.dx - 20, ptA.dy - 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
      drawText(
        "B",
        Offset(ptB.dx + 10, ptB.dy - 10),
        Colors.white,
        16,
        FontWeight.bold,
      );

      if (step >= 5 && d == rInner) {
        canvas.drawCircle(ptP, 5, Paint()..color = accentYellow);
        drawText(
          "P",
          Offset(ptP.dx + 10, ptP.dy - 25),
          accentYellow,
          16,
          FontWeight.bold,
        );
      }

      if (step >= 6 && d == rInner) {
        canvas.drawLine(
          ptO,
          ptP,
          Paint()
            ..color = accentPink
            ..strokeWidth = 2,
        );
        drawText(
          "r",
          Offset(ptO.dx + 5, ptO.dy - d / 2),
          accentPink,
          14,
          FontWeight.bold,
        );
      }

      if (step >= 7 && d == rInner) {
        _drawRightAngleAtP(canvas, ptP, ptA, ptO, accentGreen);
      }

      if (step >= 8 && d == rInner) {
        _drawDashedLine(
          canvas,
          ptO,
          ptA,
          Paint()
            ..color = accentBlue
            ..strokeWidth = 2,
        );
        _drawDashedLine(
          canvas,
          ptO,
          ptB,
          Paint()
            ..color = accentBlue
            ..strokeWidth = 2,
        );
        drawText(
          "R",
          Offset((ptO.dx + ptA.dx) / 2 - 15, (ptO.dy + ptA.dy) / 2),
          accentBlue,
          14,
          FontWeight.bold,
        );
        drawText(
          "R",
          Offset((ptO.dx + ptB.dx) / 2 + 10, (ptO.dy + ptB.dy) / 2),
          accentBlue,
          14,
          FontWeight.bold,
        );
      }

      if (step >= 9 && d == rInner) {
        Offset midAP = Offset((ptA.dx + ptP.dx) / 2, ptP.dy);
        Offset midPB = Offset((ptB.dx + ptP.dx) / 2, ptP.dy);

        _drawTick(canvas, ptA, ptP, midAP, accentGreen);
        _drawTick(canvas, ptP, ptB, midPB, accentGreen);
      }
    }
  }

  void _drawRightAngleAtP(
    Canvas canvas,
    Offset p,
    Offset a,
    Offset o,
    Color c,
  ) {
    double size = 15;
    Path path = Path()
      ..moveTo(p.dx - size, p.dy)
      ..lineTo(p.dx - size, p.dy + size)
      ..lineTo(p.dx, p.dy + size);

    canvas.drawPath(
      path,
      Paint()
        ..color = c
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawTick(Canvas canvas, Offset p1, Offset p2, Offset mid, Color color) {
    canvas.drawLine(
      Offset(mid.dx, mid.dy - 6),
      Offset(mid.dx, mid.dy + 6),
      Paint()
        ..color = color
        ..strokeWidth = 3,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 6, dashSpace = 4;
    double startX = p1.dx, startY = p1.dy;
    final double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    final double distance = (math.sqrt(dx * dx + dy * dy));
    final double angle = math.atan2(dy, dx);

    double drawnLength = 0;
    while (drawnLength < distance) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + dashWidth * math.cos(angle),
          startY + dashWidth * math.sin(angle),
        ),
        paint,
      );
      startX += (dashWidth + dashSpace) * math.cos(angle);
      startY += (dashWidth + dashSpace) * math.sin(angle);
      drawnLength += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant ConcentricPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.chordDist != chordDist;
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
