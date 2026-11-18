// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AngleSpotlightApp());
}

class AngleSpotlightApp extends StatefulWidget {
  const AngleSpotlightApp({super.key});

  @override
  State<AngleSpotlightApp> createState() => _AngleSpotlightAppState();
}

class _AngleSpotlightAppState extends State<AngleSpotlightApp>
    with TickerProviderStateMixin {
  // Navigation & UI State
  bool hasStarted = false;
  bool isSidebarOpen = true;
  String currentLang = 'en';
  int currentStep = 1;
  bool isAdvancing = false;

  // App Logic State
  Map<int, String?> step2Slots = {0: null, 1: null, 2: null};
  String step3Input = '';
  Map<int, String?> step4Slots = {0: null};
  String step5Input = '';
  String step6Input = '';
  Map<int, String?> step7Slots = {0: null};
  String step8Input = '';
  String step9Input = '';

  // Text Controllers
  final TextEditingController _step3Ctrl = TextEditingController();
  final TextEditingController _step5Ctrl = TextEditingController();
  final TextEditingController _step6Ctrl = TextEditingController();
  final TextEditingController _step8Ctrl = TextEditingController();
  final TextEditingController _step9Ctrl = TextEditingController();

  // Modals
  bool showFinalModal = false;

  // Geometry
  final double radius = 120.0;
  final Offset centerO = const Offset(0, 0);

  // Angles in radians (0 is right, pi/2 is down)
  final double angleP = math.pi * 0.75; // 135 degrees
  final double angleQ = math.pi * 0.25; // 45 degrees
  final double angleA = -math.pi * 0.5; // -90 degrees
  final double angleB = -math.pi * 0.85; // -153 degrees

  // Theme Constants
  final Color themeBg = const Color(0xFF020617);
  final Color themePanel = const Color.fromRGBO(15, 23, 42, 0.95);
  final Color themeText = const Color(0xFFF8FAFC);
  final Color themeMuted = const Color(0xFF94A3B8);
  final Color themeBorder = const Color.fromRGBO(59, 130, 246, 0.3);
  final Color themeAccent = const Color(0xFFF59E0B);
  final Color themePrimary = const Color(0xFF3B82F6);
  final Color themeSecondary = const Color(0xFF8B5CF6);
  final Color themeSuccess = const Color(0xFF10B981);
  final Color themeError = const Color(0xFFF43F5E);

  // Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Audio asset paths (assets/audio/class9/)
  static const String _clickUrl =
      'audio/class9/click.mp3';
  static const String _successUrl =
      'audio/class9/success.mp3';
  static const String _errorUrl =
      'audio/class9/error.mp3';
  static const String _alertUrl =
      'audio/class9/shutter.mp3';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    _step3Ctrl.dispose();
    _step5Ctrl.dispose();
    _step6Ctrl.dispose();
    _step8Ctrl.dispose();
    _step9Ctrl.dispose();
    super.dispose();
  }

  void playClick() => _clickPlayer.play(AssetSource(_clickUrl));
  void playSuccess() => _successPlayer.play(AssetSource(_successUrl));
  void playError() => _errorPlayer.play(AssetSource(_errorUrl));
  void playShutter() => _fxPlayer.play(AssetSource(_alertUrl));

  void cycleLanguage() {
    playClick();
    setState(() {
      currentLang = currentLang == 'en' ? 'hi' : 'en';
    });
  }

  void completeStep() {
    if (isAdvancing) return;
    playSuccess();
    setState(() {
      isAdvancing = true;
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        if (currentStep < 10) {
          currentStep++;

          step3Input = '';
          _step3Ctrl.clear();
          step5Input = '';
          _step5Ctrl.clear();
          step6Input = '';
          _step6Ctrl.clear();
          step8Input = '';
          _step8Ctrl.clear();
          step9Input = '';
          _step9Ctrl.clear();
        } else {
          playShutter();
          showFinalModal = true;
        }
        isAdvancing = false;
      });
    });
  }

  void fullReset() {
    playClick();
    setState(() {
      hasStarted = false;
      currentLang = 'en';
      currentStep = 1;
      isAdvancing = false;

      step2Slots = {0: null, 1: null, 2: null};
      step3Input = '';
      _step3Ctrl.clear();
      step4Slots = {0: null};
      step5Input = '';
      _step5Ctrl.clear();
      step6Input = '';
      _step6Ctrl.clear();
      step7Slots = {0: null};
      step8Input = '';
      _step8Ctrl.clear();
      step9Input = '';
      _step9Ctrl.clear();

      showFinalModal = false;
      isSidebarOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) return _buildShutterScreen();

    final t = labText[currentLang]!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.30;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: themeBg,
        body: Stack(
          children: [
            // Canvas Layer
            Positioned.fill(child: _buildCanvasArea(sidebarWidth)),

            // Top-Right Data Log
            Positioned(top: 16, right: 16, child: _buildDataLog(t)),

            // Left Sidebar Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: Colors.transparent,
                child: _buildSidebar(t),
              ),
            ),

            // Bottom-Left Mission Control
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 16,
              left: isSidebarOpen ? sidebarWidth + 16 : 16,
              width: 320,
              child: _buildMissionControl(t),
            ),

            // Top-Left Menu Button (Matches Image Style)
            if (!isSidebarOpen)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    playClick();
                    setState(() => isSidebarOpen = true);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Final Modal Overlay
            if (showFinalModal)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(child: _buildFinalModal(t)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    final t = labText[currentLang] ?? labText['en']!;
    return Scaffold(
      backgroundColor: themeBg,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themePrimary, themeSecondary],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: themePrimary.withOpacity(
                            0.3 + (_pulseController.value * 0.3),
                          ),
                          blurRadius: 30 + (_pulseController.value * 20),
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.data_usage,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                t['app_title'],
                style: TextStyle(
                  color: themeText,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t['tagline'],
                style: TextStyle(
                  color: themeAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  playShutter();
                  setState(() => hasStarted = true);
                },
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(
                  t['ui_start_mission'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 10,
                  shadowColor: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(Map<String, dynamic> t) {
    return Container(
      decoration: BoxDecoration(
        color: themePanel,
        border: Border(right: BorderSide(color: themeBorder, width: 2)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t['header_title'],
                    style: TextStyle(
                      color: themePrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () {
                    playClick();
                    setState(() => isSidebarOpen = false);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildControlButton(
                      currentLang.toUpperCase(),
                      Icons.language,
                      cycleLanguage,
                    ),
                    const SizedBox(width: 8),
                    _buildControlButton(
                      t['ui_reset'],
                      Icons.refresh,
                      fullReset,
                      color: themeError,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    "${t['ui_lvl']} $currentStep / 10",
                    style: TextStyle(
                      color: themeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              t['ui_mission_objective'],
              themePrimary,
              Icons.my_location,
            ),
            Text(
              t['objectives'][currentStep - 1],
              style: TextStyle(
                color: themeText,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              t['ui_procedural_steps'],
              themeSecondary,
              Icons.checklist,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  (t['procedural_steps'][currentStep - 1] as List<String>).map((
                    stepText,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: TextStyle(
                              color: themeSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              stepText,
                              style: TextStyle(
                                color: themeText.withOpacity(0.9),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(t['ui_concept'], themeSuccess, Icons.lightbulb),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeSuccess.withOpacity(0.3)),
              ),
              child: Text(
                t['concepts'][currentStep - 1],
                style: TextStyle(
                  color: themeSuccess,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                "© ZEROSCIENCELAB - Fall in Love with Math and Science",
                style: TextStyle(
                  color: themeMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    final c = color ?? themeText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: themeBorder),
          borderRadius: BorderRadius.circular(8),
          color: themeBg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataLog(Map<String, dynamic> t) {
    if (currentStep < 2) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themePanel.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeAccent, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t['ui_data_log'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const Divider(color: Colors.white24, height: 8),
          _logItem(
            "Center",
            currentStep >= 3 ? "O" : "?",
            highlight: currentStep == 2,
          ),
          _logItem(
            "Arc",
            currentStep >= 3 ? "PQ" : "?",
            highlight: currentStep == 2,
          ),
          if (currentStep >= 3)
            _logItem(
              "∠POQ",
              currentStep >= 4 ? "90°" : "?",
              highlight: currentStep == 3,
            ),
          if (currentStep >= 4) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "Point A",
              currentStep >= 5 ? "Fixed" : "?",
              highlight: currentStep == 4,
            ),
            _logItem(
              "∠PAQ",
              currentStep >= 6 ? "45°" : "?",
              highlight: currentStep == 5,
            ),
          ],
          if (currentStep >= 7) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "Point B",
              currentStep >= 8 ? "Fixed" : "?",
              highlight: currentStep == 7,
            ),
            _logItem(
              "∠PBQ",
              currentStep >= 9 ? "45°" : "?",
              highlight: currentStep == 8,
            ),
          ],
          if (currentStep >= 9) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "Reflex ∠POQ",
              currentStep >= 10 ? "270°" : "?",
              highlight: currentStep == 9,
            ),
          ],
        ],
      ),
    );
  }

  Widget _logItem(String key, String val, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$key: ",
            style: TextStyle(
              color: themeMuted,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            val,
            style: TextStyle(
              color: highlight ? themeAccent : themeSuccess,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionControl(Map<String, dynamic> t) {
    Widget content = const SizedBox();

    switch (currentStep) {
      case 1:
        content = _buildPrimaryBtn(
          t['actions_btn'][0],
          completeStep,
          themeAccent,
        );
        break;
      case 2:
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDraggable('O', 'Center O', themePrimary, 2),
                const SizedBox(width: 8),
                _buildDraggable('P', 'Point P', themeSecondary, 2),
                const SizedBox(width: 8),
                _buildDraggable('Q', 'Point Q', themeAccent, 2),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDragTarget(0, 'P', 'P', step2Slots),
                _buildDragTarget(1, 'O', 'Center', step2Slots),
                _buildDragTarget(2, 'Q', 'Q', step2Slots),
              ],
            ),
          ],
        );
        break;
      case 3:
        bool isCorrect3 = step3Input.trim() == '90';
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: themeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "∠POQ =",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _step3Ctrl,
                    enabled: !isAdvancing && !isCorrect3,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isAdvancing || isCorrect3
                              ? themeSuccess
                              : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: "? °",
                      hintStyle: TextStyle(color: themeMuted),
                      filled: true,
                      fillColor: Colors.black45,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeBorder, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        step3Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][2],
              () {
                if (step3Input.trim() == '90') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSuccess,
              icon: Icons.check_circle_outline,
            ),
          ],
        );
        break;
      case 4:
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildDraggable('A', 'Point A', themePrimary, 4)],
            ),
            const SizedBox(height: 12),
            _buildDragTarget(0, 'A', 'Drop A on Major Arc', step4Slots),
          ],
        );
        break;
      case 5:
        bool isCorrect5 = step5Input.trim() == '45';
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: themeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "∠PAQ =",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _step5Ctrl,
                    enabled: !isAdvancing && !isCorrect5,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isAdvancing || isCorrect5
                              ? themeSuccess
                              : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: "? °",
                      hintStyle: TextStyle(color: themeMuted),
                      filled: true,
                      fillColor: Colors.black45,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeBorder, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        step5Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][4],
              () {
                if (step5Input.trim() == '45') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSuccess,
              icon: Icons.check_circle_outline,
            ),
          ],
        );
        break;
      case 6:
        bool isCorrect6 = step6Input.trim() == '90';
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: themeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "2 × ∠PAQ =",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _step6Ctrl,
                    enabled: !isAdvancing && !isCorrect6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isAdvancing || isCorrect6
                              ? themeSuccess
                              : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: "? °",
                      hintStyle: TextStyle(color: themeMuted),
                      filled: true,
                      fillColor: Colors.black45,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeBorder, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        step6Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][5],
              () {
                if (step6Input.trim() == '90') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSecondary,
              icon: Icons.verified,
            ),
          ],
        );
        break;
      case 7:
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildDraggable('B', 'Point B', themeAccent, 7)],
            ),
            const SizedBox(height: 12),
            _buildDragTarget(0, 'B', 'Drop B on Major Arc', step7Slots),
          ],
        );
        break;
      case 8:
        bool isCorrect8 = step8Input.trim() == '45';
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: themeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "∠PBQ =",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _step8Ctrl,
                    enabled: !isAdvancing && !isCorrect8,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isAdvancing || isCorrect8
                              ? themeSuccess
                              : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: "? °",
                      hintStyle: TextStyle(color: themeMuted),
                      filled: true,
                      fillColor: Colors.black45,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeBorder, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        step8Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][7],
              () {
                if (step8Input.trim() == '45') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSuccess,
              icon: Icons.check_circle_outline,
            ),
          ],
        );
        break;
      case 9:
        bool isCorrect9 = step9Input.trim() == '270';
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: themeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "360° - ∠POQ =",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _step9Ctrl,
                    enabled: !isAdvancing && !isCorrect9,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isAdvancing || isCorrect9
                              ? themeSuccess
                              : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: "? °",
                      hintStyle: TextStyle(color: themeMuted),
                      filled: true,
                      fillColor: Colors.black45,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeBorder, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeSuccess, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        step9Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][8],
              () {
                if (step9Input.trim() == '270') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeAccent,
              icon: Icons.calculate,
            ),
          ],
        );
        break;
      case 10:
        content = _buildPrimaryBtn(
          t['actions_btn'][9],
          completeStep,
          themeSuccess,
          textColor: Colors.black,
          icon: Icons.workspace_premium,
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeAccent, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t['ui_mission_control'],
                style: TextStyle(
                  color: themeMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                "${t['ui_step']} $currentStep",
                style: TextStyle(
                  color: themeAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          Text(
            t['actions_desc'][currentStep - 1],
            textAlign: TextAlign.center,
            style: TextStyle(color: themeText.withOpacity(0.9), fontSize: 10),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildPrimaryBtn(
    String text,
    VoidCallback onTap,
    Color bgColor, {
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    return InkWell(
      onTap: isAdvancing ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isAdvancing ? themeSuccess : bgColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (isAdvancing ? themeSuccess : bgColor).withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAdvancing)
              const Icon(Icons.check_circle, color: Colors.black, size: 14)
            else if (icon != null)
              Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4),
            Text(
              isAdvancing
                  ? labText[currentLang]!['ui_correct_advancing']
                  : text.toUpperCase(),
              style: TextStyle(
                color: isAdvancing ? Colors.black : textColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggable(
    String value,
    String label,
    Color color,
    int stepValidation,
  ) {
    if (currentStep != stepValidation) return const SizedBox();

    // Check if dropped
    if (currentStep == 2 && step2Slots.containsValue(value)) {
      return const SizedBox();
    }
    if (currentStep == 4 && step4Slots.containsValue(value)) {
      return const SizedBox();
    }
    if (currentStep == 7 && step7Slots.containsValue(value)) {
      return const SizedBox();
    }

    return Draggable<String>(
      data: value,
      onDragStarted: playClick,
      maxSimultaneousDrags: isAdvancing ? 0 : 1,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [BoxShadow(blurRadius: 10)],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildDragTarget(
    int index,
    String expected,
    String hint,
    Map<int, String?> slots,
  ) {
    bool isFilled = slots[index] != null;
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (isAdvancing) return;
        if (details.data == expected) {
          playSuccess();
          setState(() {
            slots[index] = details.data;
            if (!slots.containsValue(null)) {
              completeStep();
            }
          });
        } else {
          playError();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFilled ? themeSuccess.withOpacity(0.2) : Colors.black45,
            border: Border.all(
              color:
                  isFilled
                      ? themeSuccess
                      : (candidateData.isNotEmpty ? themeAccent : themeBorder),
              width: 1.5,
              style: isFilled ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isFilled ? slots[index]! : hint,
            style: TextStyle(
              color: isFilled ? themeSuccess : themeMuted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinalModal(Map<String, dynamic> t) {
    return SingleChildScrollView(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themePanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeSuccess, width: 3),
          boxShadow: [
            BoxShadow(
              color: themeSuccess.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: themeSuccess,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeSuccess.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t['ui_contract_signed'],
                  style: TextStyle(
                    color: themeSuccess,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t['ui_area_certified'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  t['ui_mastery_level'],
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPrimaryBtn(
                  t['ui_return_base'],
                  fullReset,
                  themeSuccess,
                  textColor: Colors.black,
                ),
              ],
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () {
                  playClick();
                  setState(() => showFinalModal = false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea(double sidebarWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(4000),
          minScale: 0.1,
          maxScale: 8.0,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: CustomPaint(
              painter: GeometryPainter(
                step: currentStep,
                radius: radius,
                centerO: centerO,
                angleP: angleP,
                angleQ: angleQ,
                angleA: angleA,
                angleB: angleB,
                themeAccent: themeAccent,
                themeSuccess: themeSuccess,
                themeError: themeError,
                themeSecondary: themeSecondary,
                themePrimary: themePrimary,
                themeText: themeText,
                gridColor: themePrimary.withOpacity(0.05),
                isSidebarOpen: isSidebarOpen,
                sidebarWidth: sidebarWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GeometryPainter extends CustomPainter {
  final int step;
  final double radius;
  final Offset centerO;
  final double angleP, angleQ, angleA, angleB;
  final Color themeAccent,
      themeSuccess,
      themeError,
      themeSecondary,
      themePrimary,
      themeText,
      gridColor;
  final bool isSidebarOpen;
  final double sidebarWidth;

  GeometryPainter({
    required this.step,
    required this.radius,
    required this.centerO,
    required this.angleP,
    required this.angleQ,
    required this.angleA,
    required this.angleB,
    required this.themeAccent,
    required this.themeSuccess,
    required this.themeError,
    required this.themeSecondary,
    required this.themePrimary,
    required this.themeText,
    required this.gridColor,
    required this.isSidebarOpen,
    required this.sidebarWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth =
        isSidebarOpen ? size.width - sidebarWidth : size.width;
    final double cx = (isSidebarOpen ? sidebarWidth : 0) + (availableWidth / 2);
    final double cy = size.height / 2 - 20;

    canvas.save();
    canvas.translate(cx, cy);

    // Grid
    final Paint gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1;
    double stepSize = 40.0;
    for (double x = -4000; x < 4000; x += stepSize) {
      canvas.drawLine(Offset(x, -4000), Offset(x, 4000), gridPaint);
    }
    for (double y = -4000; y < 4000; y += stepSize) {
      canvas.drawLine(Offset(-4000, y), Offset(4000, y), gridPaint);
    }

    final Paint axisPaint =
        Paint()
          ..color = Colors.white10
          ..strokeWidth = 2;
    canvas.drawLine(Offset(-4000, 0), Offset(4000, 0), axisPaint);
    canvas.drawLine(Offset(0, -4000), Offset(0, 4000), axisPaint);

    // Calculate Points
    Offset pP = Offset(math.cos(angleP) * radius, math.sin(angleP) * radius);
    Offset pQ = Offset(math.cos(angleQ) * radius, math.sin(angleQ) * radius);
    Offset pA = Offset(math.cos(angleA) * radius, math.sin(angleA) * radius);
    Offset pB = Offset(math.cos(angleB) * radius, math.sin(angleB) * radius);

    // Circle
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = themePrimary.withOpacity(0.1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centerO,
      radius,
      Paint()
        ..color = themePrimary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final Paint linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2;
    final Paint activeLinePaint =
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 3;

    if (step >= 2) {
      // Show O, P, Q and Chord PQ
      canvas.drawLine(centerO, pP, linePaint);
      canvas.drawLine(centerO, pQ, linePaint);

      // Arc highlight
      final Rect arcRect = Rect.fromCircle(center: centerO, radius: radius);
      canvas.drawArc(
        arcRect,
        angleQ,
        angleP - angleQ,
        false,
        Paint()
          ..color = themeAccent
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );
    }

    if (step >= 3) {
      // Angle at O (90 deg)
      canvas.drawArc(
        Rect.fromCircle(center: centerO, radius: 25),
        angleQ,
        angleP - angleQ,
        false,
        Paint()
          ..color = themeAccent
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "90°",
        centerO + const Offset(0, 40),
        themeAccent,
        14.0,
      );
    }

    if (step >= 4) {
      // Show A
      canvas.drawLine(pP, pA, linePaint);
      canvas.drawLine(pQ, pA, linePaint);
    }

    if (step >= 5) {
      // Angle at A (45 deg)
      // Angle vector from A to Q and A to P.
      double a1 = math.atan2(pQ.dy - pA.dy, pQ.dx - pA.dx);
      double a2 = math.atan2(pP.dy - pA.dy, pP.dx - pA.dx);
      // Ensure positive sweep
      if (a2 < a1) a2 += 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: pA, radius: 30),
        a1,
        a2 - a1,
        false,
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _drawText(canvas, "45°", pA + const Offset(0, 45), themeSuccess, 14.0);
    }

    if (step >= 6) {
      // Highlight PA, QA, PO, QO
      canvas.drawLine(centerO, pP, activeLinePaint);
      canvas.drawLine(centerO, pQ, activeLinePaint);
      canvas.drawLine(pP, pA, activeLinePaint);
      canvas.drawLine(pQ, pA, activeLinePaint);
    }

    if (step >= 7) {
      // Show B
      canvas.drawLine(
        pP,
        pB,
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        pQ,
        pB,
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 2,
      );
    }

    if (step >= 8) {
      // Angle at B (45 deg)
      double b1 = math.atan2(pQ.dy - pB.dy, pQ.dx - pB.dx);
      double b2 = math.atan2(pP.dy - pB.dy, pP.dx - pB.dx);
      if (b2 < b1) b2 += 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: pB, radius: 30),
        b1,
        b2 - b1,
        false,
        Paint()
          ..color = themeSuccess
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _drawText(canvas, "45°", pB + const Offset(20, 35), themeSuccess, 14.0);
    }

    if (step >= 9) {
      // Reflex angle at O (270 deg)
      canvas.drawArc(
        Rect.fromCircle(center: centerO, radius: 30),
        angleP,
        (2 * math.pi) - (angleP - angleQ),
        false,
        Paint()
          ..color = themeError
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _drawText(
        canvas,
        "270°",
        centerO + const Offset(0, -45),
        themeError,
        14.0,
      );
    }

    if (step == 10) {
      canvas.drawCircle(
        centerO,
        radius,
        Paint()
          ..color = themeSuccess.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }

    // Nodes
    void drawNode(Offset pos, String label, Color color) {
      canvas.drawCircle(pos, 6, Paint()..color = color);
      canvas.drawCircle(pos, 4, Paint()..color = Colors.white);

      Offset offsetDir = pos;
      if (pos.distance > 0) offsetDir = pos / pos.distance;
      _drawText(canvas, label, pos + offsetDir * 25, color, 14.0);
    }

    if (step >= 2) {
      drawNode(centerO, "O", themeText);
      drawNode(pP, "P", themeText);
      drawNode(pQ, "Q", themeText);
    }

    if (step >= 4) {
      drawNode(pA, "A", themeSuccess);
    }

    if (step >= 7) {
      drawNode(pB, "B", themeSuccess);
    }

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.bold,
        fontFamily: 'sans-serif',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    // Background for text readability
    Rect bgRect = Rect.fromCenter(
      center: offset,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );

    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.isSidebarOpen != isSidebarOpen;
  }
}

const Map<String, dynamic> englishText = {
  'app_title': "THE ANGLE SPOTLIGHT",
  'tagline': "Class 9 • CIRCLE THEOREMS",
  'header_title': "The Angle Spotlight",
  'ui_start_mission': "START MISSION",
  'ui_reset': "RESET",
  'ui_lvl': "Lvl",
  'ui_mission_objective': "MISSION OBJECTIVE",
  'ui_procedural_steps': "PROCEDURAL STEPS",
  'ui_concept': "CONCEPT",
  'ui_mission_control': "MISSION CONTROL",
  'ui_data_log': "DATA LOG",
  'ui_step': "Step",
  'ui_contract_signed': "THEOREM PROVED!",
  'ui_area_certified': "Angles Certified & Logged",
  'ui_mastery_level': "Mastery Level: 100%",
  'ui_return_base': "RETURN TO BASE",
  'ui_correct_advancing': "CORRECT! ADVANCING...",

  'actions_btn': [
    "Initialize Scanner",
    "Confirm Points",
    "Verify Central Angle",
    "Confirm Point A",
    "Verify Inscribed Angle",
    "Verify Theorem",
    "Confirm Point B",
    "Verify Segment Angle",
    "Verify Reflex Angle",
    "Certify Theorem",
  ],
  'actions_desc': [
    "Welcome to the Circle lab. Initialize the geometric scanner.",
    "Place the center O and the arc end points P and Q on the circle.",
    "Measure the angle subtended by minor arc PQ at the center O.",
    "Place point A anywhere on the major arc (the remaining part of the circle).",
    "Measure the angle subtended by arc PQ at point A.",
    "Verify the theorem: The angle at the center is double the angle at the remaining part.",
    "Place another point B on the major arc.",
    "Measure the angle at B. Verify that angles in the same segment are equal.",
    "Calculate the reflex angle of POQ subtended by the major arc.",
    "The analysis is complete. Certify the circle theorems.",
  ],
  'objectives': [
    "Understand the core circle theorem relating central angles and inscribed angles.",
    "Identify the center of the circle and the endpoints of an arc.",
    "Calculate the angle subtended by the arc at the center of the circle.",
    "Identify a point on the remaining (major) arc of the circle.",
    "Calculate the angle subtended by the same arc at a point on the circumference.",
    "Prove visually and mathematically that Angle at Center = 2 × Angle at Circumference.",
    "Identify a second point on the same major arc.",
    "Prove that angles in the same segment of a circle are equal.",
    "Understand how the major arc subtends a reflex angle at the center.",
    "Finalize the theorem certification.",
  ],
  'procedural_steps': [
    ["Activate the radar.", "Acknowledge the starting sequence."],
    [
      "Locate points O, P, Q.",
      "Drag them to their correct locations on the circle.",
    ],
    ["Observe ∠POQ.", "Enter the value of the central angle."],
    ["Locate point A.", "Drag it to the top of the circle (major arc)."],
    ["Observe ∠PAQ.", "Enter the value of the inscribed angle."],
    ["Observe the equation.", "Verify that 2 × ∠PAQ = ∠POQ."],
    ["Locate point B.", "Drag it to another spot on the major arc."],
    ["Observe ∠PBQ.", "Enter the value of this new inscribed angle."],
    ["Calculate the reflex angle.", "Subtract the interior ∠POQ from 360°."],
    ["Review the established theorems.", "Certify the lab completion."],
  ],
  'concepts': [
    "A circle is a collection of points equidistant from a center. Arcs are parts of the circumference.",
    "An arc subtends an angle at the center by drawing lines from the arc's endpoints to the center.",
    "The central angle is a direct measure of the arc's angular size.",
    "The same arc can also subtend an angle at any point on the remaining part of the circle (the inscribed angle).",
    "The inscribed angle is always smaller than the central angle subtended by the same arc.",
    "Theorem: The angle subtended by an arc at the centre is double the angle subtended by it at any remaining part of the circle.",
    "By choosing a different point B on the same major arc, we create another inscribed angle.",
    "Theorem: Angles in the same segment of a circle are equal. Since both ∠PAQ and ∠PBQ are half of ∠POQ, they must be equal.",
    "The major arc PQ subtends a reflex angle (>180°) at the center, which is 360° - the minor central angle.",
    "These theorems form the foundation for cyclic quadrilaterals and advanced circle geometry.",
  ],
};

const Map<String, dynamic> hindiText = {
  'app_title': "द एंगल स्पॉटलाइट",
  'tagline': "कक्षा 9 • वृत्त के प्रमेय",
  'header_title': "द एंगल स्पॉटलाइट",
  'ui_start_mission': "मिशन शुरू करें",
  'ui_reset': "रीसेट",
  'ui_lvl': "स्तर",
  'ui_mission_objective': "मिशन उद्देश्य",
  'ui_procedural_steps': "प्रक्रिया चरण",
  'ui_concept': "अवधारणा",
  'ui_mission_control': "मिशन नियंत्रण",
  'ui_data_log': "डेटा लॉग",
  'ui_step': "चरण",
  'ui_contract_signed': "प्रमेय सिद्ध!",
  'ui_area_certified': "कोण प्रमाणित",
  'ui_mastery_level': "महारत: 100%",
  'ui_return_base': "वापस जाएँ",
  'ui_correct_advancing': "सही! आगे बढ़ रहे...",

  'actions_btn': [
    "स्कैनर शुरू करें",
    "बिंदु पुष्टि करें",
    "केंद्रीय कोण जांचें",
    "बिंदु A पुष्टि करें",
    "अंतर्निहित कोण जांचें",
    "प्रमेय जांचें",
    "बिंदु B पुष्टि करें",
    "खंड कोण जांचें",
    "प्रतिवर्ती कोण जांचें",
    "प्रमेय प्रमाणित करें",
  ],
  'actions_desc': [
    "सर्कल लैब में स्वागत है। ज्यामितीय स्कैनर शुरू करें।",
    "केंद्र O और चाप बिंदु P और Q को वृत्त पर रखें।",
    "केंद्र O पर लघु चाप PQ का कोण मापें।",
    "बिंदु A को प्रमुख चाप पर कहीं भी रखें।",
    "बिंदु A पर चाप PQ का कोण मापें।",
    "प्रमेय जांचें: केंद्र का कोण शेष भाग के कोण का दोगुना होता है।",
    "प्रमुख चाप पर एक और बिंदु B रखें।",
    "B पर कोण मापें। जांचें कि एक ही खंड के कोण बराबर हैं।",
    "प्रमुख चाप द्वारा बने POQ के प्रतिवर्ती कोण की गणना करें।",
    "विश्लेषण पूरा हुआ। वृत्त प्रमेयों को प्रमाणित करें।",
  ],
  'objectives': [
    "केंद्रीय और अंतर्निहित कोणों के बीच वृत्त प्रमेय को समझें।",
    "वृत्त के केंद्र और चाप के बिंदुओं को पहचानें।",
    "वृत्त के केंद्र में चाप द्वारा बने कोण की गणना करें।",
    "वृत्त के प्रमुख चाप पर एक बिंदु को पहचानें।",
    "परिधि पर उसी चाप द्वारा बने कोण की गणना करें।",
    "सिद्ध करें कि केंद्र पर कोण = 2 × परिधि पर कोण।",
    "उसी प्रमुख चाप पर दूसरे बिंदु को पहचानें।",
    "सिद्ध करें कि एक ही वृत्त खंड के कोण बराबर होते हैं।",
    "समझें कि प्रमुख चाप केंद्र पर प्रतिवर्ती कोण कैसे बनाता है।",
    "प्रमेय प्रमाणीकरण को पूरा करें।",
  ],
  'procedural_steps': [
    ["रडार सक्रिय करें।", "प्रारंभिक अनुक्रम स्वीकार करें।"],
    ["O, P, Q का पता लगाएँ।", "उन्हें वृत्त पर सही स्थानों पर खींचें।"],
    ["∠POQ का निरीक्षण करें।", "केंद्रीय कोण दर्ज करें।"],
    ["बिंदु A का पता लगाएँ।", "इसे वृत्त के शीर्ष (प्रमुख चाप) पर खींचें।"],
    ["∠PAQ का निरीक्षण करें।", "अंतर्निहित कोण दर्ज करें।"],
    ["समीकरण का निरीक्षण करें।", "जांचें कि 2 × ∠PAQ = ∠POQ।"],
    ["बिंदु B का पता लगाएँ।", "इसे प्रमुख चाप पर दूसरे स्थान पर खींचें।"],
    ["∠PBQ का निरीक्षण करें।", "नया अंतर्निहित कोण दर्ज करें।"],
    ["प्रतिवर्ती कोण की गणना करें।", "आंतरिक ∠POQ को 360° से घटाएं।"],
    ["स्थापित प्रमेयों की समीक्षा करें।", "लैब पूर्णता को प्रमाणित करें।"],
  ],
  'concepts': [
    "वृत्त केंद्र से समान दूरी पर बिंदुओं का समूह है। चाप परिधि के भाग हैं।",
    "एक चाप केंद्र तक रेखाएँ खींचकर केंद्र पर एक कोण बनाता है।",
    "केंद्रीय कोण चाप के आकार का प्रत्यक्ष माप है।",
    "वही चाप वृत्त के शेष भाग पर भी एक कोण बना सकता है।",
    "अंतर्निहित कोण हमेशा उसी चाप के केंद्रीय कोण से छोटा होता है।",
    "प्रमेय: चाप द्वारा केंद्र पर बना कोण शेष भाग पर बने कोण का दोगुना होता है।",
    "उसी प्रमुख चाप पर बिंदु B चुनकर, हम एक और अंतर्निहित कोण बनाते हैं।",
    "प्रमेय: एक ही वृत्त खंड के कोण बराबर होते हैं।",
    "प्रमुख चाप PQ केंद्र पर एक प्रतिवर्ती कोण (>180°) बनाता है।",
    "ये प्रमेय चक्रीय चतुर्भुज और उन्नत ज्यामिति की नींव बनाते हैं।",
  ],
};

const Map<String, Map<String, dynamic>> labText = {
  'en': englishText,
  'hi': hindiText,
};