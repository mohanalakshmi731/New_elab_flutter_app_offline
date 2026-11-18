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
  runApp(const TrianglePainterApp());
}

class TrianglePainterApp extends StatelessWidget {
  const TrianglePainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Triangle Painter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0518),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF1E1B4B),
        ),
      ),
      home: const TrianglePainterScreen(),
    );
  }
}

class TrianglePainterScreen extends StatefulWidget {
  const TrianglePainterScreen({super.key});

  @override
  State<TrianglePainterScreen> createState() => _TrianglePainterScreenState();
}

class _TrianglePainterScreenState extends State<TrianglePainterScreen>
    with TickerProviderStateMixin {
  // Navigation & UI State
  bool hasStarted = false;
  bool isSidebarOpen = true;
  String currentLang = 'en';
  int currentStep = 1;
  bool isAdvancing = false;

  // App Logic State
  List<String> step2Dropped = [];
  String step3Input = '';
  double step4SliderValue = 0.0;
  Map<int, String> step5Inputs = {0: '', 1: '', 2: ''};
  Map<int, String?> step6Slots = {0: null, 1: null, 2: null, 3: null};
  String step7Input = '';
  String step8Input = '';
  String step9Input = '';
  String step10Input = '';

  // Text Controllers to clear inputs automatically
  final TextEditingController _step3Ctrl = TextEditingController();
  final List<TextEditingController> _step5Ctrls = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController _step7Ctrl = TextEditingController();
  final TextEditingController _step8Ctrl = TextEditingController();
  final TextEditingController _step9Ctrl = TextEditingController();
  final TextEditingController _step10Ctrl = TextEditingController();

  // Modals
  bool showFinalModal = false;

  // Geometry Defaults (Isosceles: base 50, sides 65)
  // These map exactly to a triangle with width 50 and height 60
  final Offset vA = const Offset(-25, -20);
  final Offset vB = const Offset(25, -20);
  final Offset vC = const Offset(0, 40);

  // Theme Constants
  final Color themeBg = const Color(0xFF0F0518);
  final Color themePanel = const Color.fromRGBO(30, 27, 75, 0.95);
  final Color themeText = const Color(0xFFF8FAFC);
  final Color themeMuted = const Color(0xFF94A3B8);
  final Color themeBorder = const Color.fromRGBO(
    139,
    92,
    246,
    0.3,
  ); // Purple border
  final Color themeAccent = const Color(0xFFF59E0B); // Amber
  final Color themePrimary = const Color(0xFF8B5CF6); // Purple
  final Color themeSecondary = const Color(0xFF3B82F6); // Blue
  final Color themeSuccess = const Color(0xFF10B981); // Emerald
  final Color themeError = const Color(0xFFF43F5E); // Rose

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

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
    for (var ctrl in _step5Ctrls) {
      ctrl.dispose();
    }
    _step7Ctrl.dispose();
    _step8Ctrl.dispose();
    _step9Ctrl.dispose();
    _step10Ctrl.dispose();
    super.dispose();
  }

  // Audio Helpers
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

          // Clear inputs for next steps so they don't hold previous answers
          step3Input = '';
          _step3Ctrl.clear();

          step4SliderValue = 0.0;

          step5Inputs = {0: '', 1: '', 2: ''};
          for (var ctrl in _step5Ctrls) {
            ctrl.clear();
          }

          step6Slots = {0: null, 1: null, 2: null, 3: null};

          step7Input = '';
          _step7Ctrl.clear();

          step8Input = '';
          _step8Ctrl.clear();

          step9Input = '';
          _step9Ctrl.clear();

          step10Input = '';
          _step10Ctrl.clear();
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

      step2Dropped = [];

      step3Input = '';
      _step3Ctrl.clear();

      step4SliderValue = 0.0;

      step5Inputs = {0: '', 1: '', 2: ''};
      for (var ctrl in _step5Ctrls) {
        ctrl.clear();
      }

      step6Slots = {0: null, 1: null, 2: null, 3: null};

      step7Input = '';
      _step7Ctrl.clear();

      step8Input = '';
      _step8Ctrl.clear();

      step9Input = '';
      _step9Ctrl.clear();

      step10Input = '';
      _step10Ctrl.clear();

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

    return Scaffold(
      backgroundColor: themeBg,
      body: Stack(
        children: [
          // Canvas Layer
          Positioned.fill(child: _buildCanvasArea(sidebarWidth)),

          // Bottom-Right Data Log
          Positioned(bottom: 16, right: 16, child: _buildDataLog(t)),

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

          // Action Panel (Bottom Left, 38% width)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: 16,
            left: isSidebarOpen ? sidebarWidth + 16 : 16,
            width: screenWidth * 0.38,
            child: _buildMissionControl(t),
          ),

          // Menu Button (Visible when sidebar closed)
          if (!isSidebarOpen)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: themePanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeBorder),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    playClick();
                    setState(() => isSidebarOpen = true);
                  },
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
                      Icons.format_paint,
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
                  color: themeSecondary,
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
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () {
                    playClick();
                    setState(() => isSidebarOpen = false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              children: (t['procedural_steps'][currentStep - 1] as List<String>)
                  .map((stepText) {
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
                  })
                  .toList(),
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
            "a",
            currentStep > 2 ? "50" : "?",
            highlight: currentStep == 3,
          ), // Revealed after dropping
          _logItem(
            "b",
            currentStep > 2 ? "65" : "?",
            highlight: currentStep == 3,
          ),
          _logItem(
            "c",
            currentStep > 2 ? "65" : "?",
            highlight: currentStep == 3,
          ),
          if (currentStep >= 3)
            _logItem(
              "P",
              currentStep > 3 ? "180" : "?",
              highlight: currentStep == 3,
            ),
          if (currentStep >= 4)
            _logItem(
              "s",
              currentStep > 4 ? "90" : "?",
              highlight: currentStep == 4,
            ),
          if (currentStep >= 5) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "s-a",
              currentStep > 5 ? "40" : "?",
              highlight: currentStep == 5,
            ),
            _logItem(
              "s-b",
              currentStep > 5 ? "25" : "?",
              highlight: currentStep == 5,
            ),
            _logItem(
              "s-c",
              currentStep > 5 ? "25" : "?",
              highlight: currentStep == 5,
            ),
          ],
          if (currentStep >= 8) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "Area",
              currentStep > 8 ? "1500" : "?",
              highlight: currentStep == 8,
            ),
          ],
          if (currentStep >= 9) ...[
            _logItem(
              "Rate",
              currentStep > 9 ? "7" : "?",
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
            "$key = ",
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
                _buildDraggable('50', '50', themePrimary),
                const SizedBox(width: 12),
                _buildDraggable('65', '65', themeSecondary),
                const SizedBox(width: 12),
                _buildDraggable('65', '65', themeAccent),
              ],
            ),
            const SizedBox(height: 12),
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                if (isAdvancing) return;
                if (['50', '65'].contains(details.data)) {
                  int count65 = step2Dropped.where((e) => e == '65').length;
                  int count50 = step2Dropped.where((e) => e == '50').length;

                  if (details.data == '65' && count65 >= 2) return;
                  if (details.data == '50' && count50 >= 1) return;

                  playSuccess();
                  setState(() {
                    step2Dropped.add(details.data);
                    if (step2Dropped.length == 3) completeStep();
                  });
                } else {
                  playError();
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: step2Dropped.length == 3 || isAdvancing
                        ? themeSuccess.withOpacity(0.2)
                        : Colors.black45,
                    border: Border.all(
                      color: step2Dropped.length == 3 || isAdvancing
                          ? themeSuccess
                          : themeBorder,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    step2Dropped.isEmpty
                        ? t['ui_drop_sides']
                        : "${t['ui_placed_sides']} ${step2Dropped.length}/3 ${t['ui_sides']}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: step2Dropped.length == 3 || isAdvancing
                          ? themeSuccess
                          : themeMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        );
        break;
      case 3:
        bool isCorrect3 = step3Input.trim() == '180';
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
                  child: Text(
                    t['ui_formula_p'],
                    style: const TextStyle(
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
                      color: isAdvancing || isCorrect3
                          ? themeSuccess
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      hintText: "?",
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
              t['ui_verify_p'],
              () {
                if (step3Input.trim() == '180') {
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
                  child: Text(
                    t['ui_formula_s'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border.all(
                        color: isAdvancing || step4SliderValue == 90.0
                            ? themeSuccess
                            : themeBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      step4SliderValue > 0
                          ? "${step4SliderValue.toInt()}"
                          : "?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: step4SliderValue == 90.0 || isAdvancing
                            ? themeSuccess
                            : themeAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16.0,
                ),
              ),
              child: Slider(
                value: step4SliderValue,
                min: 0,
                max: 180,
                divisions: 180,
                activeColor: themeAccent,
                onChanged: isAdvancing
                    ? null
                    : (val) {
                        if (val.toInt() % 10 == 0) playClick();
                        setState(() => step4SliderValue = val);
                        if (val == 90.0) completeStep();
                      },
              ),
            ),
          ],
        );
        break;
      case 5:
        content = Column(
          children: [
            _buildDiffInputRow(t['ui_s_minus_a'], '40', 0),
            const SizedBox(height: 4),
            _buildDiffInputRow(t['ui_s_minus_b'], '25', 1),
            const SizedBox(height: 4),
            _buildDiffInputRow(t['ui_s_minus_c'], '25', 2),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_verify_diff'],
              () {
                if (step5Inputs[0] == '40' &&
                    step5Inputs[1] == '25' &&
                    step5Inputs[2] == '25') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSuccess,
              icon: Icons.playlist_add_check,
            ),
          ],
        );
        break;
      case 6:
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDraggable('90', '90', themeAccent),
                const SizedBox(width: 6),
                _buildDraggable('40', '40', themeSuccess),
                const SizedBox(width: 6),
                _buildDraggable('25', '25', themeSecondary),
                const SizedBox(width: 6),
                _buildDraggable('25', '25', themeSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: themeBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '√',
                    style: TextStyle(
                      color: themeText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildDragTarget(0, '90', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(1, '40', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(2, '25', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(3, '25', '?'),
                ],
              ),
            ),
          ],
        );
        break;
      case 7:
        bool isCorrect7 = step7Input.trim() == '2250000';
        content = Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: themeBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['ui_formula_heron_inner'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _step7Ctrl,
              enabled: !isAdvancing && !isCorrect7,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect7 || isAdvancing ? themeSuccess : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: "?",
                hintStyle: TextStyle(color: themeMuted),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                  step7Input = v;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_verify_prod'],
              () {
                if (step7Input.trim() == '2250000') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSecondary,
              icon: Icons.calculate,
            ),
          ],
        );
        break;
      case 8:
        bool isCorrect8 = step8Input.trim() == '1500';
        content = Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: themeBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['ui_extracted_root'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _step8Ctrl,
              enabled: !isAdvancing && !isCorrect8,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect8 || isAdvancing ? themeSuccess : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: "?",
                hintStyle: TextStyle(color: themeMuted),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_certify_area'],
              () {
                if (step8Input.trim() == '1500') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSuccess,
              icon: Icons.verified,
            ),
          ],
        );
        break;
      case 9:
        bool isCorrect9 = step9Input.trim() == '7';
        content = Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: themeBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['ui_verify_rate'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: themeAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['ui_rate_hint'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _step9Ctrl,
              enabled: !isAdvancing && !isCorrect9,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect9 || isAdvancing ? themeSuccess : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: "?",
                hintStyle: TextStyle(color: themeMuted),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][8],
              () {
                if (step9Input.trim() == '7') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeAccent,
              icon: Icons.currency_rupee,
            ),
          ],
        );
        break;
      case 10:
        bool isCorrect10 = step10Input.trim() == '10500';
        content = Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: themeBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['ui_verify_cost'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _step10Ctrl,
              enabled: !isAdvancing && !isCorrect10,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect10 || isAdvancing ? themeSuccess : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: t['ui_cost_hint'],
                hintStyle: TextStyle(color: themeMuted.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.black45,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                  step10Input = v;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['actions_btn'][9],
              () {
                if (step10Input.trim() == '10500') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeSuccess,
              icon: Icons.receipt_long,
            ),
          ],
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 15, spreadRadius: 2),
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
          const Divider(color: Colors.white24, height: 8),
          Text(
            t['actions_desc'][currentStep - 1],
            textAlign: TextAlign.center,
            style: TextStyle(color: themeText.withOpacity(0.9), fontSize: 10),
          ),
          const SizedBox(height: 8),
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

  Widget _buildDiffInputRow(String label, String expected, int index) {
    bool isCorrect = step5Inputs[index] == expected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.all(
          color: isCorrect || isAdvancing ? themeSuccess : themeBorder,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: themeMuted,
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _step5Ctrls[index],
              enabled: !isCorrect && !isAdvancing,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect || isAdvancing ? themeSuccess : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: "?",
                hintStyle: TextStyle(color: themeMuted.withOpacity(0.5)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged: (v) {
                setState(() {
                  step5Inputs[index] = v;
                });
              },
            ),
          ),
          if (isCorrect)
            Icon(Icons.check_circle, color: themeSuccess, size: 14),
        ],
      ),
    );
  }

  Widget _buildDraggable(String value, String label, Color color) {
    int count65 = step2Dropped.where((e) => e == '65').length;
    int count50 = step2Dropped.where((e) => e == '50').length;

    if (currentStep == 2) {
      if (value == '65' && count65 >= 2) return const SizedBox();
      if (value == '50' && count50 >= 1) return const SizedBox();
    }

    if (currentStep == 6 && step6Slots.containsValue(value)) {
      int valueCountInSlots = step6Slots.values.where((e) => e == value).length;
      if (value == '25' && valueCountInSlots >= 2) return const SizedBox();
      if (value != '25' && valueCountInSlots >= 1) return const SizedBox();
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

  Widget _buildDragTarget(int index, String expected, String hint) {
    bool isFilled = step6Slots[index] != null;
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (isAdvancing) return;
        if (details.data == expected) {
          playSuccess();
          setState(() {
            step6Slots[index] = details.data;
            if (!step6Slots.containsValue(null)) {
              completeStep();
            }
          });
        } else {
          playError();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFilled ? themeSuccess.withOpacity(0.2) : Colors.black45,
            border: Border.all(
              color: isFilled
                  ? themeSuccess
                  : (candidateData.isNotEmpty ? themeAccent : themeBorder),
              width: 1.5,
              style: isFilled ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isFilled ? step6Slots[index]! : "?",
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
                vA: vA,
                vB: vB,
                vC: vC,
                themeAccent: themeAccent,
                themeSuccess: themeSuccess,
                themeError: themeError,
                themeSecondary: themeSecondary,
                gridColor: themeAccent.withOpacity(0.05),
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
  final Offset vA, vB, vC;
  final Color themeAccent, themeSuccess, themeError, themeSecondary, gridColor;
  final bool isSidebarOpen;
  final double sidebarWidth;

  GeometryPainter({
    required this.step,
    required this.vA,
    required this.vB,
    required this.vC,
    required this.themeAccent,
    required this.themeSuccess,
    required this.themeError,
    required this.themeSecondary,
    required this.gridColor,
    required this.isSidebarOpen,
    required this.sidebarWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth = isSidebarOpen
        ? size.width - sidebarWidth
        : size.width;
    final double cx = isSidebarOpen
        ? sidebarWidth + (availableWidth / 2)
        : size.width / 2;
    final double cy = size.height / 2 + 10;

    canvas.save();

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    double stepSize = 40.0;
    for (double x = -4000; x < 4000; x += stepSize) {
      canvas.drawLine(Offset(x + cx, -4000), Offset(x + cx, 4000), gridPaint);
    }
    for (double y = -4000; y < 4000; y += stepSize) {
      canvas.drawLine(Offset(-4000, y + cy), Offset(4000, y + cy), gridPaint);
    }

    final Paint axisPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 2;
    canvas.drawLine(Offset(-4000, cy), Offset(4000, cy), axisPaint);
    canvas.drawLine(Offset(cx, -4000), Offset(cx, 4000), axisPaint);

    // Compute dynamic scale based on screen size so triangle fits nicely
    final double s = math
        .min(availableWidth / 150, (size.height - 180) / 150)
        .clamp(2.5, 6.0);

    // Invert Y axis to match standard cartesian coordinates on screen
    Offset sA = Offset(cx + vA.dx * s, cy - vA.dy * s);
    Offset sB = Offset(cx + vB.dx * s, cy - vB.dy * s);
    Offset sC = Offset(cx + vC.dx * s, cy - vC.dy * s);

    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(sB, sC, solidPaint);
    canvas.drawLine(sC, sA, solidPaint);
    canvas.drawLine(sA, sB, solidPaint);

    if (step == 10) {
      final fillPaint = Paint()
        ..color = themeSuccess.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(sA.dx, sA.dy)
        ..lineTo(sB.dx, sB.dy)
        ..lineTo(sC.dx, sC.dy)
        ..close();
      canvas.drawPath(path, fillPaint);
    }

    double fontSize = 16.0;

    // Only show sides after step 2 is complete (so they are found on the canvas)
    String lblA = step > 2 ? "65m" : "b";
    String lblB = step > 2 ? "65m" : "c";
    String lblC = step > 2 ? "50m" : "a";

    _drawText(
      canvas,
      lblC,
      (sA.dx + sB.dx) / 2,
      (sA.dy + sB.dy) / 2 + 25,
      themeSecondary,
      fontSize,
    ); // Bottom
    _drawText(
      canvas,
      lblA,
      (sB.dx + sC.dx) / 2 + 25,
      (sB.dy + sC.dy) / 2,
      themeSecondary,
      fontSize,
    ); // Right
    _drawText(
      canvas,
      lblB,
      (sA.dx + sC.dx) / 2 - 25,
      (sA.dy + sC.dy) / 2,
      themeSecondary,
      fontSize,
    ); // Left

    final Paint nodeOutline = Paint()..color = Colors.white;
    for (var p in [sA, sB, sC]) {
      canvas.drawCircle(p, 6, solidPaint);
      canvas.drawCircle(p, 4, nodeOutline);
    }

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
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
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.isSidebarOpen != isSidebarOpen;
  }
}

const Map<String, dynamic> englishText = {
  'app_title': "THE TRIANGLE PAINTER",
  'tagline': "Class 9 • COST ESTIMATION",
  'header_title': "The Triangle Painter",
  'ui_start_mission': "START MISSION",
  'ui_reset': "RESET",
  'ui_lvl': "Lvl",
  'ui_mission_objective': "MISSION OBJECTIVE",
  'ui_procedural_steps': "PROCEDURAL STEPS",
  'ui_concept': "CONCEPT",
  'ui_mission_control': "MISSION CONTROL",
  'ui_data_log': "DATA LOG",
  'ui_step': "Step",
  'ui_drop_sides': "Perimeter Bar\nDrop Sides Here",
  'ui_placed_sides': "Placed",
  'ui_sides': "Sides",
  'ui_formula_p': "a + b + c = P",
  'ui_formula_s': "s = P / 2 =",
  'ui_s_minus_a': "s - a =",
  'ui_s_minus_b': "s - b =",
  'ui_s_minus_c': "s - c =",
  'ui_formula_heron_inner': "Product under root =",
  'ui_extracted_root': "Extracted root (Area) =",
  'ui_verify_rate': "Given Painting Rate (₹/m²) =",
  'ui_rate_hint': "Contract specifies a rate of ₹7 per m²",
  'ui_cost_hint': "Area × Rate = ?",
  'ui_verify_cost': "Total Cost = Area × Rate =",
  'ui_contract_signed': "WALL PAINTED!",
  'ui_area_certified': "Total Cost Approved: ₹10500",
  'ui_mastery_level': "Mastery Level: 100%",
  'ui_return_base': "RETURN TO BASE",
  'ui_verify_p': "VERIFY PERIMETER",
  'ui_verify_diff': "VERIFY DIFFERENCES",
  'ui_verify_prod': "VERIFY PRODUCT",
  'ui_certify_area': "CERTIFY AREA",
  'ui_correct_advancing': "CORRECT! ADVANCING...",
  'actions_btn': [
    "Acknowledge Contract",
    "Submit",
    "Submit",
    "Confirm Scale",
    "Submit",
    "Submit",
    "Verify Differences",
    "Submit",
    "Verify Rate",
    "Stamp Contract",
  ],
  'actions_desc': [
    "We have a triangular wall to paint. Determine the area and total cost based on the painting rate.",
    "Place the known side lengths onto the perimeter calculation bar.",
    "Sum the sides to find the total Perimeter (P).",
    "Use the slider to find the exact value of the Semi-perimeter (s).",
    "Calculate the difference between the semi-perimeter and each individual side.",
    "Load the values into Heron's Formula structure.",
    "Multiply the terms to find the total product under the square root.",
    "Extract the square root to calculate the final Area.",
    "Identify the painting rate given in the contract hint below.",
    "Multiply the total area by the rate to find the final painting cost.",
  ],
  'objectives': [
    "Understand the scenario: We must paint a triangular wall. The cost is calculated based on area.",
    "Identify the side lengths from the blueprint.",
    "Find the total perimeter P.",
    "Find the semi-perimeter s.",
    "Find the mathematical differences for Heron's formula.",
    "Substitute the values directly into Heron's Formula.",
    "Calculate the product under the square root.",
    "Extract the square root to find the Area.",
    "Identify the cost rate per square meter.",
    "Multiply Area by Rate to find Total Cost.",
  ],
  'procedural_steps': [
    ["Review the wall blueprint.", "Acknowledge the contract to begin."],
    ["Locate the side lengths.", "Drag them into the perimeter calculation."],
    ["Add the sides together to find P.", "Input the Perimeter and verify."],
    [
      "Locate the slider.",
      "Slide it until it equals exactly half the perimeter.",
      "Lock in 's'.",
    ],
    [
      "Use 's'.",
      "Subtract side 'a'.",
      "Subtract side 'b'.",
      "Subtract side 'c'.",
      "Verify all differences.",
    ],
    [
      "Observe Heron's structure.",
      "Drag 's' to its drop zone.",
      "Drag the difference values to their drop zones.",
    ],
    [
      "Review the multiplied product.",
      "Input the total product into the field.",
    ],
    ["Calculate the final square root.", "Enter the final area value."],
    ["Read the contract rate (₹7/m²).", "Enter the exact rate."],
    ["Multiply Area by Rate.", "Submit the final cost to stamp the contract."],
  ],
  'concepts': [
    "To estimate the cost of painting, we first need to know the total area of the surface.",
    "A triangle has three sides: a, b, and c.",
    "The perimeter is the total boundary of the shape.",
    "Heron's formula requires the 'semi-perimeter' (s), which is exactly half of the total perimeter.",
    "Find the difference between the semi-perimeter and each individual side. This represents the 'slack' for each side.",
    "Plug everything into Heron's Formula: Area = √(s × (s-a) × (s-b) × (s-c)).",
    "Multiply the components inside the root to simplify the expression.",
    "Extracting the square root gives us the actual Area in square units.",
    "A rate tells us how much it costs for just one single square unit of area.",
    "Total Cost is calculated directly by multiplying the total Area by the unit Rate.",
  ],
};

const Map<String, dynamic> hindiText = {
  'app_title': "द ट्राइएंगल पेंटर",
  'tagline': "कक्षा 9 • लागत अनुमान",
  'header_title': "ट्राइएंगल पेंटर",
  'ui_start_mission': "मिशन शुरू करें",
  'ui_reset': "रीसेट",
  'ui_lvl': "स्तर",
  'ui_mission_objective': "मिशन का उद्देश्य",
  'ui_procedural_steps': "प्रक्रियात्मक चरण",
  'ui_concept': "अवधारणा",
  'ui_mission_control': "मिशन नियंत्रण",
  'ui_data_log': "डेटा लॉग",
  'ui_step': "चरण",
  'ui_drop_sides': "परिमाप बार\nभुजाएँ यहाँ रखें",
  'ui_placed_sides': "रखी गई",
  'ui_sides': "भुजाएँ",
  'ui_formula_p': "a + b + c = P",
  'ui_formula_s': "s = P / 2 =",
  'ui_s_minus_a': "s - a =",
  'ui_s_minus_b': "s - b =",
  'ui_s_minus_c': "s - c =",
  'ui_formula_heron_inner': "रूट के तहत गुणनफल =",
  'ui_extracted_root': "निकाला गया मूल (क्षेत्रफल) =",
  'ui_verify_rate': "दी गई पेंटिंग दर (₹/m²) =",
  'ui_rate_hint': "अनुबंध ₹7 प्रति m² की दर निर्दिष्ट करता है",
  'ui_cost_hint': "क्षेत्रफल × दर = ?",
  'ui_verify_cost': "कुल लागत = क्षेत्रफल × दर =",
  'ui_contract_signed': "दीवार पेंट हो गई!",
  'ui_area_certified': "कुल लागत स्वीकृत: ₹10500",
  'ui_mastery_level': "महारत स्तर: 100%",
  'ui_return_base': "आधार पर लौटें",
  'ui_verify_p': "परिमाप सत्यापित करें",
  'ui_verify_diff': "अंतर सत्यापित करें",
  'ui_verify_prod': "गुणनफल सत्यापित करें",
  'ui_certify_area': "क्षेत्रफल प्रमाणित करें",
  'ui_correct_advancing': "सही! आगे बढ़ रहे हैं...",
  'actions_btn': [
    "अनुबंध स्वीकार करें",
    "जमा करें",
    "जमा करें",
    "स्केल की पुष्टि करें",
    "जमा करें",
    "जमा करें",
    "अंतर सत्यापित करें",
    "जमा करें",
    "दर सत्यापित करें",
    "अनुबंध पर मुहर लगाएँ",
  ],
  'actions_desc': [
    "हमें एक त्रिकोणीय दीवार को पेंट करना है। पेंटिंग दर के आधार पर क्षेत्रफल और कुल लागत निर्धारित करें।",
    "ज्ञात भुजा की लंबाई को परिमाप गणना पट्टी पर रखें।",
    "कुल परिमाप (P) खोजने के लिए भुजाओं को जोड़ें।",
    "अर्ध-परिमाप (s) का सटीक मान खोजने के लिए स्लाइडर का उपयोग करें।",
    "अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच के अंतर की गणना करें।",
    "मानों को हेरोन के सूत्र संरचना में लोड करें।",
    "वर्गमूल के तहत कुल गुणनफल खोजने के लिए पदों को गुणा करें।",
    "अंतिम क्षेत्रफल की गणना करने के लिए वर्गमूल निकालें।",
    "नीचे दिए गए अनुबंध संकेत में दी गई पेंटिंग दर को पहचानें।",
    "अंतिम पेंटिंग लागत खोजने के लिए कुल क्षेत्रफल को दर से गुणा करें।",
  ],
  'objectives': [
    "परिदृश्य को समझें: हमें एक त्रिकोणीय दीवार को पेंट करना है। लागत की गणना क्षेत्रफल के आधार पर की जाती है।",
    "ब्लूप्रिंट से भुजा की लंबाई पहचानें।",
    "कुल परिमाप P ज्ञात करें।",
    "अर्ध-परिमाप s ज्ञात करें।",
    "हेरोन के सूत्र के लिए गणितीय अंतर ज्ञात करें।",
    "मानों को सीधे हेरोन के सूत्र में प्रतिस्थापित करें।",
    "वर्गमूल के तहत गुणनफल की गणना करें।",
    "क्षेत्रफल खोजने के लिए वर्गमूल निकालें।",
    "प्रति वर्ग मीटर लागत दर को पहचानें।",
    "कुल लागत खोजने के लिए क्षेत्रफल को दर से गुणा करें।",
  ],
  'procedural_steps': [
    [
      "दीवार ब्लूप्रिंट की समीक्षा करें।",
      "शुरू करने के लिए अनुबंध स्वीकार करें।",
    ],
    ["भुजाओं की लंबाई का पता लगाएँ।", "उन्हें परिमाप गणना में खींचें।"],
    [
      "P खोजने के लिए भुजाओं को एक साथ जोड़ें।",
      "परिमाप दर्ज करें और सत्यापित करें।",
    ],
    [
      "स्लाइडर का पता लगाएँ।",
      "इसे तब तक स्लाइड करें जब तक यह परिमाप के ठीक आधे के बराबर न हो जाए।",
      "'s' को लॉक करें।",
    ],
    [
      "'s' का उपयोग करें।",
      "भुजा 'a' को घटाएँ।",
      "भुजा 'b' को घटाएँ।",
      "भुजा 'c' को घटाएँ।",
      "सभी अंतरों को सत्यापित करें।",
    ],
    [
      "हेरोन की संरचना का निरीक्षण करें।",
      "'s' को उसके ड्रॉप ज़ोन में खींचें।",
      "अंतर मानों को उनके ड्रॉप ज़ोन में खींचें।",
    ],
    ["गुणा किए गए उत्पाद की समीक्षा करें।", "फ़ील्ड में कुल गुणनफल दर्ज करें।"],
    ["अंतिम वर्गमूल की गणना करें।", "अंतिम क्षेत्रफल मान दर्ज करें।"],
    ["अनुबंध दर (₹7/m²) पढ़ें।", "सटीक दर दर्ज करें।"],
    [
      "क्षेत्रफल को दर से गुणा करें।",
      "अनुबंध पर मुहर लगाने के लिए अंतिम लागत जमा करें।",
    ],
  ],
  'concepts': [
    "पेंटिंग की लागत का अनुमान लगाने के लिए, हमें पहले सतह का कुल क्षेत्रफल जानना होगा।",
    "त्रिभुज की तीन भुजाएँ होती हैं: a, b और c।",
    "परिमाप आकार की कुल सीमा है।",
    "हेरोन के सूत्र के लिए 'अर्ध-परिमाप' (s) की आवश्यकता होती है, जो कुल परिमाप का ठीक आधा है।",
    "अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच का अंतर ज्ञात करें।",
    "सब कुछ हेरोन के सूत्र में रखें: Area = √(s × (s-a) × (s-b) × (s-c))।",
    "व्यंजक को सरल बनाने के लिए मूल के अंदर के घटकों को गुणा करें।",
    "वर्गमूल निकालने से हमें वर्ग इकाइयों में वास्तविक क्षेत्रफल मिलता है।",
    "एक दर हमें बताती है कि क्षेत्रफल की केवल एक वर्ग इकाई के लिए कितना खर्च आता है।",
    "कुल लागत की गणना सीधे कुल क्षेत्रफल को इकाई दर से गुणा करके की जाती है।",
  ],
};

const Map<String, Map<String, dynamic>> labText = {
  'en': englishText,
  'hi': hindiText,
};
