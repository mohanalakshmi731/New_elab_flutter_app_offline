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
      'app_title': 'THE TANGENT TOUCH',
      'tagline': 'Properties of Tangents to a Circle',
      'init_btn': 'INITIALIZE SYSTEM',
      'header_title': 'The Tangent Touch',
      'header_subtitle': 'Class 10 • Circles',
      'phase_label': 'EXPLORATION PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Theorem Verified',
      'success_desc':
          'You have successfully verified that the radius is perpendicular to the tangent at the point of contact.',
      'btn_restart': 'NEW EXPLORATION',
      'data_panel_title': 'Calculations & Data',
      's0': 'Initialize Grid. Locate Center O.',
      's1': 'Construct Circle with radius r.',
      's2': 'Draw a secant line intersecting at A and B.',
      's3': 'Translate line outward. Observe intersection points.',
      's4': 'Limit reached: Line touches at exactly one point.',
      's5': 'Establish Tangent Line at Point of Contact (T).',
      's6': 'Construct Radius OT to the point of contact.',
      's7': 'Measure the angle between Radius and Tangent.',
      's8': 'Verify Theorem: Radius ⟂ Tangent.',
      's9': 'Analysis Complete.',
      'btn_start': 'ESTABLISH CENTER O',
      'btn_draw_circ': 'CONSTRUCT CIRCLE',
      'btn_draw_sec': 'DRAW SECANT',
      'btn_move_line': 'TRANSLATE LINE',
      'btn_id_tangent': 'IDENTIFY TANGENT',
      'btn_mark_t': 'MARK POINT OF CONTACT',
      'btn_draw_rad': 'CONSTRUCT RADIUS OT',
      'btn_meas_ang': 'MEASURE ANGLE',
      'btn_verify': 'VERIFY THEOREM',
      'btn_complete': 'FINALIZE REPORT',
      'msg_obs_ok': 'Center O established at origin.',
      'msg_circ_ok': 'Circle of radius r constructed.',
      'msg_sec_ok': 'Secant line intersects at two points.',
      'msg_move_ok': 'Line translated outward.',
      'msg_tan_ok': 'Tangent line established.',
      'msg_t_ok': 'Point of Contact T marked.',
      'msg_rad_ok': 'Radius OT constructed.',
      'msg_ang_ok': 'Angle measured: 90°.',
      'msg_thm_ok': 'Theorem 10.1 verified.',
      'msg_final_ok': 'Exploration complete.',
      'msg_err': 'Calculation error. Check your math.',
      'eq_secant': 'Secant Line',
      'eq_secant_desc': 'Intersects circle at 2 distinct points (A, B)',
      'eq_secant_dist': 'Distance to center: d < r',
      'eq_tangent': 'Tangent Line',
      'eq_tangent_desc': 'Touches circle at exactly 1 point (T)',
      'eq_tangent_dist': 'Distance to center: d = r',
      'eq_thm_10_1': 'Theorem 10.1',
      'eq_shortest_dist': 'OT is the shortest distance to Tangent L',
      'eq_radius_perp': 'Radius OT ⟂ Tangent L',
      'eq_angle': 'Angle ∠OTP',
    },
    'hi': {
      'app_title': 'स्पर्शरेखा स्पर्श',
      'tagline': 'वृत्त की स्पर्शरेखाओं के गुण',
      'init_btn': 'सिस्टम प्रारंभ करें',
      'header_title': 'स्पर्शरेखा स्पर्श',
      'header_subtitle': 'कक्षा 10 • वृत्त',
      'phase_label': 'अन्वेषण चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'प्रमेय सत्यापित',
      'success_desc':
          'आपने सफलतापूर्वक सत्यापित कर लिया है कि त्रिज्या संपर्क बिंदु पर स्पर्शरेखा के लंबवत है।',
      'btn_restart': 'नया अन्वेषण',
      'data_panel_title': 'गणना और डेटा',
      's0': 'ग्रिड प्रारंभ करें। केंद्र O खोजें।',
      's1': 'त्रिज्या r वाला वृत्त बनाएँ।',
      's2': 'A और B पर काटने वाली एक छेदक रेखा खींचें।',
      's3': 'रेखा को बाहर की ओर खिसकाएं। प्रतिच्छेदन बिंदुओं का निरीक्षण करें।',
      's4': 'सीमा तक पहुँच गया: रेखा ठीक एक बिंदु पर छूती है।',
      's5': 'संपर्क बिंदु (T) पर स्पर्शरेखा स्थापित करें।',
      's6': 'संपर्क बिंदु तक त्रिज्या OT का निर्माण करें।',
      's7': 'त्रिज्या और स्पर्शरेखा के बीच के कोण को मापें।',
      's8': 'प्रमेय सत्यापित करें: त्रिज्या ⟂ स्पर्शरेखा।',
      's9': 'विश्लेषण पूर्ण।',
      'btn_start': 'केंद्र O स्थापित करें',
      'btn_draw_circ': 'वृत्त बनाएँ',
      'btn_draw_sec': 'छेदक रेखा खींचें',
      'btn_move_line': 'रेखा खिसकाएं',
      'btn_id_tangent': 'स्पर्शरेखा पहचानें',
      'btn_mark_t': 'संपर्क बिंदु चिह्नित करें',
      'btn_draw_rad': 'त्रिज्या OT बनाएं',
      'btn_meas_ang': 'कोण मापें',
      'btn_verify': 'प्रमेय सत्यापित करें',
      'btn_complete': 'रिपोर्ट पूरी करें',
      'msg_obs_ok': 'केंद्र O मूल बिंदु पर स्थापित।',
      'msg_circ_ok': 'त्रिज्या r का वृत्त बनाया गया।',
      'msg_sec_ok': 'छेदक रेखा दो बिंदुओं पर काटती है।',
      'msg_move_ok': 'रेखा बाहर की ओर खिसक गई।',
      'msg_tan_ok': 'स्पर्शरेखा स्थापित।',
      'msg_t_ok': 'संपर्क बिंदु T चिह्नित।',
      'msg_rad_ok': 'त्रिज्या OT निर्मित।',
      'msg_ang_ok': 'कोण मापा गया: 90°।',
      'msg_thm_ok': 'प्रमेय 10.1 सत्यापित।',
      'msg_final_ok': 'अन्वेषण पूर्ण।',
      'msg_err': 'गणना त्रुटि।',
      'eq_secant': 'छेदक रेखा',
      'eq_secant_desc': 'वृत्त को 2 अलग-अलग बिंदुओं (A, B) पर काटती है',
      'eq_secant_dist': 'केंद्र से दूरी: d < r',
      'eq_tangent': 'स्पर्शरेखा',
      'eq_tangent_desc': 'वृत्त को ठीक 1 बिंदु (T) पर छूती है',
      'eq_tangent_dist': 'केंद्र से दूरी: d = r',
      'eq_thm_10_1': 'प्रमेय 10.1',
      'eq_shortest_dist': 'OT स्पर्शरेखा L की सबसे छोटी दूरी है',
      'eq_radius_perp': 'त्रिज्या OT ⟂ स्पर्शरेखा L',
      'eq_angle': 'कोण ∠OTP',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class TangentTouchApp extends StatefulWidget {
  const TangentTouchApp({super.key});

  @override
  State<TangentTouchApp> createState() => _TangentTouchAppState();
}

class _TangentTouchAppState extends State<TangentTouchApp>
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
  double lineOffset = 50.0;
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
      duration: const Duration(seconds: 3),
    );

    // Pre-load audio sources to eliminate delay on first click
    _clickPlayer.setSource(AssetSource(_clickUrl));
    _fxPlayer.setSource(AssetSource(_shutterUrl));
    _successPlayer.setSource(AssetSource(_successUrl));
    _errorPlayer.setSource(AssetSource(_errorUrl));

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
    _playSound(_clickPlayer);
    if (msgKey.isNotEmpty) {
      showToast(AppStrings.get(lang, msgKey));
    }

    if (currentStep < 10) {
      setState(() {
        currentStep++;

        // Trigger animations
        if (currentStep == 3) {
          _animateLine(100.0);
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

  void _animateLine(double targetOffset) {
    _moveAnimation =
        Tween<double>(begin: lineOffset, end: targetOffset).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {
            lineOffset = _moveAnimation.value;
          });
        });
    _moveController.forward(from: 0.0);
  }

  void resetLab() {
    _playSound(_fxPlayer);
    setState(() {
      lang = 'en'; // Reset language per requirements
      currentStep = 0;
      lineOffset = 50.0;
      showSuccessModal = false;
      hasStarted = false; // Setting hasStarted = false shows shutter screen
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      _moveController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(
                    Icons.radio_button_unchecked,
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
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    // Strictly 38% width for side panels
    final double panelWidth = screenWidth * 0.38;

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

            // Top-Left Floating Controls (No back button)
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

            // 5. Scrollable Success Modal (Popup) with close icon & Restart Button
            if (showSuccessModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
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
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(40),
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
                                    AppStrings.get(
                                      lang,
                                      'badge_title',
                                    ).toUpperCase(),
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
                            // Close the modal and remain on canvas
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 28,
                                ),
                                onPressed: () {
                                  _playSound(_clickPlayer);
                                  setState(() {
                                    showSuccessModal = false;
                                  });
                                },
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
            width: 1000,
            height: 800,
            child: Center(
              child: SizedBox(
                width: 800,
                height: 600,
                child: CustomPaint(
                  size: const Size(800, 600),
                  painter: TangentPainter(
                    step: currentStep,
                    lineOffset: lineOffset,
                  ),
                ),
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
    return Container(
      decoration: BoxDecoration(
        color: bgPanel,
        border: const Border(left: BorderSide(color: Colors.white12, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(-5, 0),
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
                    if (currentStep <= 2)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Text(
                            "Awaiting geometric construction...\nComplete steps on the left.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white30,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    if (currentStep >= 3 && currentStep < 5) ...[
                      _buildDataCard(
                        title: AppStrings.get(lang, 'eq_secant'),
                        color: accentPink,
                        children: [
                          Text(
                            AppStrings.get(lang, 'eq_secant_desc'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppStrings.get(lang, 'eq_secant_dist'),
                            style: const TextStyle(
                              color: accentYellow,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (currentStep >= 5) ...[
                      _buildDataCard(
                        title: AppStrings.get(lang, 'eq_tangent'),
                        color: accentGreen,
                        children: [
                          Text(
                            AppStrings.get(lang, 'eq_tangent_desc'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppStrings.get(lang, 'eq_tangent_dist'),
                            style: const TextStyle(
                              color: accentYellow,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (currentStep >= 7) ...[
                      const SizedBox(height: 20),
                      _buildDataCard(
                        title: AppStrings.get(lang, 'eq_thm_10_1'),
                        color: accentBlue,
                        children: [
                          Text(
                            AppStrings.get(lang, 'eq_shortest_dist'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                          if (currentStep >= 8) ...[
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.get(lang, 'eq_radius_perp'),
                              style: const TextStyle(
                                color: accentGreen,
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
                        title: AppStrings.get(lang, 'eq_angle'),
                        color: accentYellow,
                        children: [
                          const SizedBox(height: 5),
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
                                "90°",
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
          text: AppStrings.get(lang, 'btn_draw_circ'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_circ_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_sec'),
          color: accentPink,
          onPressed: () => advanceStep('msg_sec_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_move_line'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_move_ok'),
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_tangent'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_tan_ok'),
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_mark_t'),
          color: accentPink,
          onPressed: () => advanceStep('msg_t_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_rad'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_rad_ok'),
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_meas_ang'),
          color: accentGreen,
          onPressed: () {
            advanceStep('msg_ang_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_verify'),
          color: accentBlue,
          onPressed: () => advanceStep('msg_thm_ok'),
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

// --- CUSTOM PAINTERS ---

class TangentPainter extends CustomPainter {
  final int step;
  final double lineOffset;

  TangentPainter({required this.step, required this.lineOffset});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = 100.0;

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
      textPainter.paint(canvas, pos);
    }

    if (step >= 1) {
      canvas.drawCircle(center, 4, Paint()..color = Colors.white);
      drawText(
        "O",
        Offset(center.dx - 5, center.dy + 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
    }

    if (step >= 2) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = accentBlue.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
    }

    if (step >= 3) {
      double yLine = center.dy - lineOffset;
      canvas.drawLine(
        Offset(center.dx - 200, yLine),
        Offset(center.dx + 200, yLine),
        Paint()
          ..color = step >= 5 ? accentGreen : accentPink
          ..strokeWidth = 3,
      );

      double diffSq = radius * radius - lineOffset * lineOffset;
      if (diffSq > 0.1) {
        double dx = math.sqrt(diffSq);
        Offset ptA = Offset(center.dx - dx, yLine);
        Offset ptB = Offset(center.dx + dx, yLine);
        canvas.drawCircle(ptA, 5, Paint()..color = accentYellow);
        canvas.drawCircle(ptB, 5, Paint()..color = accentYellow);
        if (step < 5) {
          drawText(
            "A",
            Offset(ptA.dx - 10, ptA.dy - 25),
            accentYellow,
            16,
            FontWeight.bold,
          );
          drawText(
            "B",
            Offset(ptB.dx - 5, ptB.dy - 25),
            accentYellow,
            16,
            FontWeight.bold,
          );
        }
      } else if (step >= 5) {
        Offset ptT = Offset(center.dx, yLine);
        if (step >= 6) {
          canvas.drawCircle(ptT, 6, Paint()..color = accentYellow);
          drawText(
            "T",
            Offset(ptT.dx + 10, ptT.dy - 25),
            accentYellow,
            20,
            FontWeight.bold,
          );
        }
      }

      drawText(
        step >= 5 ? "Tangent Line (L)" : "Secant Line",
        Offset(center.dx - 190, center.dy - 130),
        step >= 5 ? accentGreen : accentPink,
        14,
        FontWeight.bold,
      );
    }

    if (step >= 7) {
      Offset ptT = Offset(center.dx, center.dy - radius);
      canvas.drawLine(
        center,
        ptT,
        Paint()
          ..color = accentYellow
          ..strokeWidth = 3,
      );
      drawText(
        "r",
        Offset(center.dx + 10, center.dy - radius / 2),
        accentYellow,
        16,
        FontWeight.bold,
      );
    }

    if (step >= 8) {
      Offset ptT = Offset(center.dx, center.dy - radius);
      _drawRightAngle(canvas, ptT, 1, 1, accentGreen);
    }
  }

  void _drawRightAngle(
    Canvas canvas,
    Offset corner,
    double dirX,
    double dirY,
    Color color,
  ) {
    const double size = 15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(corner.dx + size * dirX, corner.dy);
    path.lineTo(corner.dx + size * dirX, corner.dy + size * dirY);
    path.lineTo(corner.dx, corner.dy + size * dirY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TangentPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.lineOffset != lineOffset;
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
