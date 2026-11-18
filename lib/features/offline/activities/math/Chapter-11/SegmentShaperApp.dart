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
      'app_title': 'THE SEGMENT SHAPER',
      'tagline': 'Area of a Segment of a Circle',
      'init_btn': 'INITIALIZE SHAPER',
      'header_title': 'The Segment Shaper',
      'header_subtitle': 'Class 10 • Areas Related to Circles',
      'phase_label': 'SHAPING PHASE',
      'step_label': 'Stage',
      'mission_log': 'Console Log',
      'active_mission': 'Current Objective',
      'badge_title': 'Segment Master',
      'success_desc':
          'You have successfully calculated the areas of both the minor and major segments!',
      'btn_restart': 'NEW SHAPE',
      's0': 'Initialize Grid. Construct Circle (r = 10).',
      's1': 'Draw a Chord AB to cut the circle.',
      's2': 'Draw Radii OA and OB to form a Sector (90°).',
      's3': 'Calculate the Area of Sector OAB.',
      's4': 'Identify and Calculate Area of Triangle OAB.',
      's5': 'Extract Triangle to isolate the Minor Segment.',
      's6': 'Calculate Area of Minor Segment.',
      's7': 'Identify the Major Segment.',
      's8': 'Calculate Total Area of the Circle.',
      's9': 'Calculate Area of Major Segment.',
      'btn_start': 'CONSTRUCT CIRCLE',
      'btn_draw_chord': 'DRAW CHORD AB',
      'btn_draw_radii': 'DEFINE SECTOR (90°)',
      'btn_calc_sector': 'CALCULATE SECTOR AREA',
      'btn_calc_tri': 'CALCULATE TRIANGLE AREA',
      'btn_extract': 'EXTRACT TRIANGLE',
      'btn_calc_minor': 'CALC MINOR SEGMENT',
      'btn_id_major': 'IDENTIFY MAJOR SEGMENT',
      'btn_calc_tot': 'CALC TOTAL AREA',
      'btn_calc_major': 'CALC MAJOR SEGMENT',
      'msg_circ_ok': 'Circle established. Radius = 10.',
      'msg_chord_ok': 'Chord AB drawn. Circle divided into two segments.',
      'msg_sector_ok': 'Sector OAB defined with central angle 90°.',
      'msg_sec_calc_ok': 'Sector Area = 25π.',
      'msg_tri_calc_ok': 'Triangle Area = 50.',
      'msg_ext_ok': 'Triangle extracted. Minor segment isolated.',
      'msg_minor_ok': 'Minor Segment Area = 25π - 50.',
      'msg_major_ok': 'Major Segment identified.',
      'msg_tot_ok': 'Total Circle Area = 100π.',
      'msg_final_ok': 'Major Segment Area = 75π + 50. Complete!',
      'msg_err': 'Calculation error. Check your math.',
      // Calculations Panel Strings
      'calc_title': 'Calculations & Data',
      'awaiting_specs': 'Awaiting geometric shapes...',
      'comp_title': '1. Area Components',
      'comp_sec': 'Sector Area (90°) = (90/360) × 100π = 25π',
      'comp_tri': 'Triangle Area = ½ × 10 × 10 = 50',
      'comp_tot': 'Total Circle Area = π × 10² = 100π',
      'seg_title': '2. Segment Areas',
      'seg_min': 'Minor Segment = Sector - Triangle',
      'seg_min_res': '= 25π - 50',
      'seg_maj': 'Major Segment = Total Area - Minor Segment',
      'seg_maj_res': '= 100π - (25π - 50)\n= 75π + 50',
    },
    'hi': {
      'app_title': 'सेगमेंट शेपर',
      'tagline': 'वृत्त के वृत्तखंड का क्षेत्रफल',
      'init_btn': 'शेपर प्रारंभ करें',
      'header_title': 'सेगमेंट शेपर',
      'header_subtitle': 'कक्षा 10 • वृत्तों से संबंधित क्षेत्रफल',
      'phase_label': 'आकार देने का चरण',
      'step_label': 'चरण',
      'mission_log': 'कंसोल लॉग',
      'active_mission': 'वर्तमान उद्देश्य',
      'badge_title': 'वृत्तखंड मास्टर',
      'success_desc':
          'आपने लघु और दीर्घ वृत्तखंडों के क्षेत्रफलों की सफलतापूर्वक गणना कर ली है!',
      'btn_restart': 'नया आकार',
      's0': 'ग्रिड प्रारंभ करें। वृत्त (r = 10) बनाएँ।',
      's1': 'वृत्त को काटने के लिए एक जीवा AB खींचें।',
      's2': 'त्रिज्यखंड (90°) बनाने के लिए त्रिज्या OA और OB खींचें।',
      's3': 'त्रिज्यखंड OAB के क्षेत्रफल की गणना करें।',
      's4': 'त्रिभुज OAB को पहचानें और क्षेत्रफल की गणना करें।',
      's5': 'लघु वृत्तखंड को अलग करने के लिए त्रिभुज निकालें।',
      's6': 'लघु वृत्तखंड के क्षेत्रफल की गणना करें।',
      's7': 'दीर्घ वृत्तखंड की पहचान करें।',
      's8': 'वृत्त के कुल क्षेत्रफल की गणना करें।',
      's9': 'दीर्घ वृत्तखंड के क्षेत्रफल की गणना करें।',
      'btn_start': 'वृत्त बनाएँ',
      'btn_draw_chord': 'जीवा AB खींचें',
      'btn_draw_radii': 'त्रिज्यखंड परिभाषित करें',
      'btn_calc_sector': 'त्रिज्यखंड का क्षेत्रफल',
      'btn_calc_tri': 'त्रिभुज का क्षेत्रफल',
      'btn_extract': 'त्रिभुज निकालें',
      'btn_calc_minor': 'लघु वृत्तखंड क्षेत्रफल',
      'btn_id_major': 'दीर्घ वृत्तखंड पहचानें',
      'btn_calc_tot': 'कुल क्षेत्रफल गणना',
      'btn_calc_major': 'दीर्घ वृत्तखंड क्षेत्रफल',
      'msg_circ_ok': 'वृत्त स्थापित। त्रिज्या = 10.',
      'msg_chord_ok': 'जीवा AB खींची गई। वृत्त दो खंडों में विभाजित।',
      'msg_sector_ok': 'केंद्रीय कोण 90° के साथ त्रिज्यखंड OAB परिभाषित।',
      'msg_sec_calc_ok': 'त्रिज्यखंड का क्षेत्रफल = 25π.',
      'msg_tri_calc_ok': 'त्रिभुज का क्षेत्रफल = 50.',
      'msg_ext_ok': 'त्रिभुज निकाला गया। लघु वृत्तखंड अलग हो गया।',
      'msg_minor_ok': 'लघु वृत्तखंड का क्षेत्रफल = 25π - 50.',
      'msg_major_ok': 'दीर्घ वृत्तखंड पहचाना गया।',
      'msg_tot_ok': 'वृत्त का कुल क्षेत्रफल = 100π.',
      'msg_final_ok': 'दीर्घ वृत्तखंड का क्षेत्रफल = 75π + 50. पूर्ण!',
      'msg_err': 'गणना त्रुटि।',
      // Calculations Panel Strings
      'calc_title': 'गणनाएँ एवं डेटा',
      'awaiting_specs': 'ज्यामितीय आकृतियों की प्रतीक्षा में...',
      'comp_title': '1. क्षेत्रफल के घटक',
      'comp_sec': 'त्रिज्यखंड क्षेत्रफल (90°) = 25π',
      'comp_tri': 'त्रिभुज क्षेत्रफल = ½ × 10 × 10 = 50',
      'comp_tot': 'कुल वृत्त क्षेत्रफल = π × 10² = 100π',
      'seg_title': '2. वृत्तखंड का क्षेत्रफल',
      'seg_min': 'लघु वृत्तखंड = त्रिज्यखंड - त्रिभुज',
      'seg_min_res': '= 25π - 50',
      'seg_maj': 'दीर्घ वृत्तखंड = कुल क्षेत्रफल - लघु वृत्तखंड',
      'seg_maj_res': '= 100π - (25π - 50)\n= 75π + 50',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']![key] ?? key;
  }
}

class SegmentShaperApp extends StatefulWidget {
  const SegmentShaperApp({super.key});

  @override
  State<SegmentShaperApp> createState() => _SegmentShaperAppState();
}

class _SegmentShaperAppState extends State<SegmentShaperApp>
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
  double extractOffset = 0.0;
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _moveController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
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
      setState(() {
        currentStep++;
        if (msgKey.isNotEmpty) {
          showToast(AppStrings.get(lang, msgKey));
        }

        // Trigger Animation
        if (currentStep == 6) {
          // 'btn_extract' pressed at step 5 brings us to 6
          _animateExtract(30.0);
        }

        // Success Modal
        if (currentStep == 10) {
          AudioManager.playSuccess();
          Timer(const Duration(seconds: 1), () {
            if (!mounted) return;
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
          });
        }
      });
    }
  }

  void _animateExtract(double targetOffset) {
    _moveAnimation =
        Tween<double>(begin: extractOffset, end: targetOffset).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
        )..addListener(() {
          setState(() {
            extractOffset = _moveAnimation.value;
          });
        });
    _moveController.forward(from: 0.0);
  }

  void resetLab() {
    AudioManager.playError();
    setState(() {
      currentStep = 0;
      extractOffset = 0.0;
      showSuccessModal = false;
      hasStarted = false;
      isLeftPanelOpen = true;
      isRightPanelOpen = false;
      lang = 'en'; // Reset language to English
      _moveController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        },
        child: Scaffold(
          backgroundColor: bgDark,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trip_origin, size: 80, color: accentPink),
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
    // Strictly 38% width for side panels
    double panelWidth = screenWidth * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      child: Scaffold(
        backgroundColor: bgDark,
        body: Stack(
          children: [
            // 1. CANVAS AREA
            Positioned.fill(child: _buildInteractiveCanvas()),

            // 2. FLOATING MISSION CARD (Visible if left panel is closed)
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

            // 4. LEFT PANEL (Mission/Controls)
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
                icon: isRightPanelOpen ? Icons.close : Icons.data_usage_rounded,
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
                        child: const Icon(Icons.trip_origin, color: bgDark),
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

            // INTERACTION CONTROLS - Positioned above Phase Progress List
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

            // PHASE LABEL AND PROGRESS
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
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
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
                  if (currentStep >= 3) ...[
                    // 1. Area Components
                    Text(
                      AppStrings.get(lang, 'comp_title'),
                      style: const TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (currentStep >= 4) // Sector Area
                      _buildMathRow(
                        AppStrings.get(lang, 'comp_sec'),
                        Colors.white70,
                      ),

                    if (currentStep >= 5) ...[
                      // Triangle Area
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'comp_tri'),
                        Colors.white70,
                      ),
                    ],

                    if (currentStep >= 9) ...[
                      // Total Circle Area
                      const SizedBox(height: 10),
                      _buildMathRow(
                        AppStrings.get(lang, 'comp_tot'),
                        Colors.white70,
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

                  if (currentStep >= 6) ...[
                    // 2. Segment Areas
                    Text(
                      AppStrings.get(lang, 'seg_title'),
                      style: const TextStyle(
                        color: accentPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (currentStep >= 7) ...[
                      _buildMathRow(
                        AppStrings.get(lang, 'seg_min'),
                        Colors.white70,
                      ),
                      const SizedBox(height: 5),
                      _buildMathRow(
                        AppStrings.get(lang, 'seg_min_res'),
                        accentGreen,
                        isBold: true,
                        isHighlight: true,
                      ),
                      const SizedBox(height: 25),
                    ],

                    if (currentStep >= 9) ...[
                      _buildMathRow(
                        AppStrings.get(lang, 'seg_maj'),
                        Colors.white70,
                      ),

                      if (currentStep >= 10) ...[
                        const SizedBox(height: 5),
                        _buildMathRow(
                          AppStrings.get(lang, 'seg_maj_res'),
                          accentPink,
                          isBold: true,
                          isHighlight: true,
                        ),
                      ],
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

  // --- CANVAS AREA ---
  Widget _buildInteractiveCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(2000),
          minScale: 0.2,
          maxScale: 4.0,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
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
                      painter: SegmentPainter(
                        step: currentStep,
                        extractOffset: extractOffset,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          onPressed: () => advanceStep('msg_circ_ok'),
        );
      case 1:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_chord'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_chord_ok'),
        );
      case 2:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_draw_radii'),
          color: accentGreen,
          onPressed: () => advanceStep('msg_sector_ok'),
        );
      case 3:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_sector'),
          color: accentPink,
          onPressed: () {
            advanceStep('msg_sec_calc_ok');
            if (!isRightPanelOpen) toggleRightPanel(); // Auto-open math panel
          },
        );
      case 4:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_tri'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_tri_calc_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 5:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_extract'),
          color: accentYellow,
          onPressed: () => advanceStep('msg_ext_ok'),
        );
      case 6:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_minor'),
          color: accentGreen,
          onPressed: () {
            advanceStep('msg_minor_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 7:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_id_major'),
          color: accentPink,
          onPressed: () => advanceStep('msg_major_ok'),
        );
      case 8:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_tot'),
          color: accentBlue,
          onPressed: () {
            advanceStep('msg_tot_ok');
            if (!isRightPanelOpen) toggleRightPanel();
          },
        );
      case 9:
        return _ControlButton(
          text: AppStrings.get(lang, 'btn_calc_major'),
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

class SegmentPainter extends CustomPainter {
  final int step;
  final double extractOffset;

  SegmentPainter({required this.step, required this.extractOffset});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = 250;
    double cy = 190;
    double r = 120;

    // 90 degrees sector
    double startAngle = math.pi / 4; // 45 degrees
    double sweepAngle = math.pi / 2; // 90 degrees

    Offset center = Offset(cx, cy);
    Offset ptA = Offset(
      cx + r * math.cos(startAngle),
      cy + r * math.sin(startAngle),
    );
    Offset ptB = Offset(
      cx + r * math.cos(startAngle + sweepAngle),
      cy + r * math.sin(startAngle + sweepAngle),
    );

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

    // 0. Base Circle
    if (step >= 1) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Major Segment Fill - Highlighted in step 8+
      if (step >= 8) {
        Path majorPath = Path()
          ..moveTo(ptB.dx, ptB.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: r),
            startAngle + sweepAngle,
            2 * math.pi - sweepAngle,
            false,
          )
          ..close();
        canvas.drawPath(
          majorPath,
          Paint()
            ..color = accentPink.withOpacity(0.2)
            ..style = PaintingStyle.fill,
        );
        if (step >= 9) {
          drawText(
            "Major Segment",
            Offset(cx - 50, cy - 50),
            accentPink,
            16,
            FontWeight.bold,
          );
        }
      } else {
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..color = Colors.white.withOpacity(0.05)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.drawCircle(center, 4, Paint()..color = Colors.white);
      drawText(
        "O",
        Offset(center.dx - 5, center.dy - 25),
        Colors.white,
        16,
        FontWeight.bold,
      );
    }

    // Triangle Shift Coordinates
    Offset shift = Offset(0, -extractOffset);
    Offset shiftedCenter = Offset(center.dx + shift.dx, center.dy + shift.dy);
    Offset shiftedPtA = Offset(ptA.dx + shift.dx, ptA.dy + shift.dy);
    Offset shiftedPtB = Offset(ptB.dx + shift.dx, ptB.dy + shift.dy);

    // Minor Segment Area
    if (step >= 3) {
      Path minorPath = Path()
        ..moveTo(ptA.dx, ptA.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(ptA.dx, ptA.dy)
        ..close();

      Color minorColor = (step >= 7 && step < 8)
          ? accentGreen
          : accentGreen.withOpacity(0.4);
      canvas.drawPath(
        minorPath,
        Paint()
          ..color = minorColor.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        minorPath,
        Paint()
          ..color = accentGreen
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      if (step >= 7 && step < 8) {
        drawText(
          "Minor Segment",
          Offset(cx - 50, cy + r - 20),
          accentGreen,
          14,
          FontWeight.bold,
        );
      }
    }

    // Triangle Area
    if (step >= 3) {
      Path triPath = Path()
        ..moveTo(shiftedCenter.dx, shiftedCenter.dy)
        ..lineTo(shiftedPtA.dx, shiftedPtA.dy)
        ..lineTo(shiftedPtB.dx, shiftedPtB.dy)
        ..close();

      Color triColor = (step >= 5 && step < 7) ? accentYellow : Colors.white24;
      canvas.drawPath(
        triPath,
        Paint()
          ..color = triColor.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        triPath,
        Paint()
          ..color = triColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Right Angle Indicator
      if (step >= 3) {
        _drawRightAngleAt(
          canvas,
          shiftedCenter,
          shiftedPtB,
          shiftedPtA,
          triColor,
        );
      }

      if (step >= 5 && step < 7) {
        drawText(
          "Triangle",
          Offset(shiftedCenter.dx - 30, shiftedCenter.dy + 40),
          accentYellow,
          14,
          FontWeight.bold,
        );
      }
    }

    // 1. Draw Chord
    if (step >= 2) {
      canvas.drawLine(
        ptA,
        ptB,
        Paint()
          ..color = accentPink
          ..strokeWidth = 3,
      );
      drawText(
        "A",
        Offset(ptA.dx + 10, ptA.dy - 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
      drawText(
        "B",
        Offset(ptB.dx - 20, ptB.dy - 10),
        Colors.white,
        16,
        FontWeight.bold,
      );
    }

    // Sector Highlighting
    if (step == 4) {
      Path sectorPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(ptA.dx, ptA.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();
      canvas.drawPath(
        sectorPath,
        Paint()
          ..color = accentBlue.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        sectorPath,
        Paint()
          ..color = accentBlue
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
      drawText(
        "Sector OAB",
        Offset(cx - 40, cy + 40),
        accentBlue,
        16,
        FontWeight.bold,
      );
    }
  }

  void _drawRightAngleAt(Canvas canvas, Offset o, Offset a, Offset b, Color c) {
    double size = 15;

    double dx1 = a.dx - o.dx;
    double dy1 = a.dy - o.dy;
    double len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
    double u1x = dx1 / len1;
    double u1y = dy1 / len1;

    double dx2 = b.dx - o.dx;
    double dy2 = b.dy - o.dy;
    double len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
    double u2x = dx2 / len2;
    double u2y = dy2 / len2;

    Offset corner1 = Offset(o.dx + u1x * size, o.dy + u1y * size);
    Offset corner2 = Offset(corner1.dx + u2x * size, corner1.dy + u2y * size);
    Offset corner3 = Offset(o.dx + u2x * size, o.dy + u2y * size);

    Path path = Path()
      ..moveTo(corner1.dx, corner1.dy)
      ..lineTo(corner2.dx, corner2.dy)
      ..lineTo(corner3.dx, corner3.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = c
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant SegmentPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.extractOffset != extractOffset;
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
