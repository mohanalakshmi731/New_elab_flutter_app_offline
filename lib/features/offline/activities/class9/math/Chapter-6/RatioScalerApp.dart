// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RatioScalerApp());
}

class RatioScalerApp extends StatelessWidget {
  const RatioScalerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Ratio Scaler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0518),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF1E1B4B),
        ),
      ),
      home: const RatioScalerScreen(),
    );
  }
}

class RatioScalerScreen extends StatefulWidget {
  const RatioScalerScreen({super.key});

  @override
  State<RatioScalerScreen> createState() => _RatioScalerScreenState();
}

class _RatioScalerScreenState extends State<RatioScalerScreen>
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
  double currentScale = 1.0;
  String step5Input = '';
  String step6Input = '';
  Map<int, String> step7Inputs = {0: '', 1: '', 2: ''};
  Map<int, String?> step8Slots = {0: null, 1: null, 2: null, 3: null};
  String step9Input = '';
  String step10Input = '';

  // Modals
  bool showFinalModal = false;

  // Geometry Defaults
  final Offset vA = const Offset(-3.5, 0.925);
  final Offset vB = const Offset(3.5, 0.925);
  final Offset vC = const Offset(1.14, -0.925);

  // Theme Constants
  final Color themeBg = const Color(0xFF0F0518);
  final Color themePanel = const Color.fromRGBO(30, 27, 75, 0.95);
  final Color themeText = const Color(0xFFF8FAFC);
  final Color themeMuted = const Color(0xFF94A3B8);
  final Color themeBorder = const Color.fromRGBO(217, 70, 239, 0.3);
  final Color themeAccent = const Color(0xFFD946EF);
  final Color themePrimary = const Color(0xFF8B5CF6);
  final Color themeSecondary = const Color(0xFF06B6D4);
  final Color themeSuccess = const Color(0xFF4ADE80);
  final Color themeError = const Color(0xFFF43F5E);

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

          // Clear inputs on advancing to next step
          step3Input = '';
          step5Input = '';
          step6Input = '';
          step7Inputs = {0: '', 1: '', 2: ''};
          step9Input = '';
          step10Input = '';
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
      currentScale = 1.0;
      step5Input = '';
      step6Input = '';
      step7Inputs = {0: '', 1: '', 2: ''};
      step8Slots = {0: null, 1: null, 2: null, 3: null};
      step9Input = '';
      step10Input = '';
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
                        colors: [themeAccent, themeSecondary],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: themeAccent.withOpacity(
                            0.3 + (_pulseController.value * 0.3),
                          ),
                          blurRadius: 30 + (_pulseController.value * 20),
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.architecture,
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
          _logItem("Ratio", "3:5:7"),
          if (currentStep >= 3)
            _logItem(
              "x",
              currentStep > 3 ? "20" : "?",
              highlight: currentStep == 3,
            ),
          if (currentStep >= 4) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "a (3x)",
              currentStep > 4 ? "60" : "?",
              highlight: currentStep == 4,
            ),
            _logItem(
              "b (5x)",
              currentStep > 4 ? "100" : "?",
              highlight: currentStep == 4,
            ),
            _logItem(
              "c (7x)",
              currentStep > 4 ? "140" : "?",
              highlight: currentStep == 4,
            ),
          ],
          if (currentStep >= 5)
            _logItem(
              "P",
              currentStep > 5 ? "300" : "?",
              highlight: currentStep == 5,
            ),
          if (currentStep >= 6)
            _logItem(
              "s",
              currentStep > 6 ? "150" : "?",
              highlight: currentStep == 6,
            ),
          if (currentStep >= 7) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "s-a",
              currentStep > 7 ? "90" : "?",
              highlight: currentStep == 7,
            ),
            _logItem(
              "s-b",
              currentStep > 7 ? "50" : "?",
              highlight: currentStep == 7,
            ),
            _logItem(
              "s-c",
              currentStep > 7 ? "10" : "?",
              highlight: currentStep == 7,
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
                _buildDraggable('3x', '3x', themePrimary),
                const SizedBox(width: 12),
                _buildDraggable('5x', '5x', themeSecondary),
                const SizedBox(width: 12),
                _buildDraggable('7x', '7x', themeAccent),
              ],
            ),
            const SizedBox(height: 12),
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                if (isAdvancing) return;
                if (['3x', '5x', '7x'].contains(details.data)) {
                  if (!step2Dropped.contains(details.data)) {
                    playSuccess();
                    setState(() {
                      step2Dropped.add(details.data);
                      if (step2Dropped.length == 3) completeStep();
                    });
                  }
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
        bool isCorrect3 = step3Input.trim() == '20';
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
              t['ui_verify_x'],
              () {
                if (step3Input.trim() == '20') {
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
                Text(
                  "Scale Factor: ",
                  style: TextStyle(
                    color: themeMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border.all(
                        color: isAdvancing || currentScale == 20.0
                            ? themeSuccess
                            : themeBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${currentScale.toInt()}x",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: currentScale == 20.0 || isAdvancing
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
                value: currentScale,
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: themeAccent,
                onChanged: isAdvancing
                    ? null
                    : (val) {
                        playClick();
                        setState(() => currentScale = val);
                      },
              ),
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_confirm_scale'],
              () {
                if (currentScale == 20.0) {
                  completeStep();
                } else {
                  playError();
                }
              },
              themePrimary,
              icon: Icons.straighten,
            ),
          ],
        );
        break;
      case 5:
        bool isCorrect5 = step5Input.trim() == '300';
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
                    "P = ",
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
                    enabled: !isAdvancing && !isCorrect5,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isAdvancing || isCorrect5
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
                        step5Input = v;
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
                if (step5Input.trim() == '300') {
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
        bool isCorrect6 = step6Input.trim() == '150';
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
                  child: TextField(
                    enabled: !isAdvancing && !isCorrect6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isAdvancing || isCorrect6
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
                        step6Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_verify_s'],
              () {
                if (step6Input.trim() == '150') {
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
      case 7:
        content = Column(
          children: [
            _buildDiffInputRow(t['ui_s_minus_a'], '90', 0),
            const SizedBox(height: 4),
            _buildDiffInputRow(t['ui_s_minus_b'], '50', 1),
            const SizedBox(height: 4),
            _buildDiffInputRow(t['ui_s_minus_c'], '10', 2),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_verify_diff'],
              () {
                if (step7Inputs[0] == '90' &&
                    step7Inputs[1] == '50' &&
                    step7Inputs[2] == '10') {
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
      case 8:
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDraggable('150', '150', themeAccent),
                const SizedBox(width: 6),
                _buildDraggable('90', '90', themeSuccess),
                const SizedBox(width: 6),
                _buildDraggable('50', '50', themeSuccess),
                const SizedBox(width: 6),
                _buildDraggable('10', '10', themeSuccess),
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
                  _buildDragTarget(0, '150', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(1, '90', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(2, '50', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(3, '10', '?'),
                ],
              ),
            ),
          ],
        );
        break;
      case 9:
        bool isCorrect9 = step9Input.trim() == '6750000';
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
                t['ui_largest_factor'],
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
              t['ui_verify_prod'],
              () {
                if (step9Input.trim() == '6750000') {
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
      case 10:
        double val = double.tryParse(step10Input) ?? 0;
        bool isCorrect10 = val >= 2598 && val <= 2605;
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
              enabled: !isAdvancing && !isCorrect10,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCorrect10 || isAdvancing ? themeSuccess : Colors.white,
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
                  step10Input = v;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_certify_area'],
              () {
                double v = double.tryParse(step10Input) ?? 0;
                if (v >= 2598 && v <= 2605) {
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
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themePanel,
        borderRadius: BorderRadius.circular(12),
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
    bool isCorrect = step7Inputs[index] == expected;

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
                  step7Inputs[index] = v;
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
    if (currentStep == 2 && step2Dropped.contains(value)) {
      return const SizedBox();
    }
    if (currentStep == 8 && step8Slots.containsValue(value)) {
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

  Widget _buildDragTarget(int index, String expected, String hint) {
    bool isFilled = step8Slots[index] != null;
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (isAdvancing) return;
        if (details.data == expected) {
          playSuccess();
          setState(() {
            step8Slots[index] = details.data;
            if (!step8Slots.containsValue(null)) {
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
            isFilled ? step8Slots[index]! : "?",
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
                currentScale: currentScale,
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
  final double currentScale;
  final Color themeAccent, themeSuccess, themeError, themeSecondary, gridColor;
  final bool isSidebarOpen;
  final double sidebarWidth;

  GeometryPainter({
    required this.step,
    required this.vA,
    required this.vB,
    required this.vC,
    required this.currentScale,
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
    final double cy = size.height / 2 - 20;

    canvas.save();

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    double stepSize = 50.0;
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

    final double s = 15.0 * currentScale;

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

    double fontSize = (14 + currentScale * 0.5).clamp(14.0, 30.0);
    String lblC = step >= 4 ? "${7 * currentScale.toInt()}m" : "7x";
    String lblA = step >= 4 ? "${3 * currentScale.toInt()}m" : "3x";
    String lblB = step >= 4 ? "${5 * currentScale.toInt()}m" : "5x";

    _drawText(
      canvas,
      lblC,
      (sA.dx + sB.dx) / 2,
      (sA.dy + sB.dy) / 2 - 20,
      themeSecondary,
      fontSize,
    ); // Top
    _drawText(
      canvas,
      lblA,
      (sB.dx + sC.dx) / 2 + 20,
      (sB.dy + sC.dy) / 2,
      themeSecondary,
      fontSize,
    ); // Right
    _drawText(
      canvas,
      lblB,
      (sA.dx + sC.dx) / 2 - 20,
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
        oldDelegate.isSidebarOpen != isSidebarOpen ||
        oldDelegate.currentScale != currentScale;
  }
}

const Map<String, dynamic> englishText = {
  'app_title': "THE RATIO SCALER",
  'tagline': "Class 9 • HERON'S FORMULA",
  'header_title': "The Ratio Scaler",
  'ui_start_mission': "START MISSION",
  'ui_reset': "RESET",
  'ui_lvl': "Lvl",
  'ui_mission_objective': "MISSION OBJECTIVE",
  'ui_procedural_steps': "PROCEDURAL STEPS",
  'ui_concept': "CONCEPT",
  'ui_mission_control': "MISSION CONTROL",
  'ui_data_log': "DATA LOG",
  'ui_step': "Step",
  'ui_drop_sides': "Perimeter Bar\nDrop Ratios Here",
  'ui_placed_sides': "Placed",
  'ui_sides': "Ratios",
  'ui_formula_p': "3x + 5x + 7x = 300",
  'ui_formula_s': "s = P / 2 =",
  'ui_s_minus_a': "s - a =",
  'ui_s_minus_b': "s - b =",
  'ui_s_minus_c': "s - c =",
  'ui_formula_heron_inner': "√ (s · d1 · d2 · d3)",
  'ui_largest_factor': "Product under root =",
  'ui_extracted_root': "Extracted final root ≈",
  'ui_contract_signed': "CONTRACT SIGNED!",
  'ui_area_certified': "Area Certified: 2598 m²",
  'ui_mastery_level': "Mastery Level: 100%",
  'ui_return_base': "RETURN TO BASE",
  'ui_verify_x': "VERIFY 'x'",
  'ui_verify_p': "VERIFY PERIMETER",
  'ui_verify_s': "VERIFY 's'",
  'ui_verify_diff': "VERIFY DIFFERENCES",
  'ui_verify_prod': "VERIFY PRODUCT",
  'ui_certify_area': "CERTIFY AREA",
  'ui_confirm_scale': "CONFIRM SCALE",
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
    "Submit",
    "Stamp Contract",
  ],
  'actions_desc': [
    "The blueprint perimeter needs to be 300m, and the sides are in a 3:5:7 ratio.",
    "Drag all three ratio terms into the box to form the perimeter equation.",
    "Solve for the multiplier 'x'. Total perimeter is 300.",
    "Use the slider to scale the blueprint up to reality by multiplying by x.",
    "Verify the real dimensions. Sum the actual lengths of the scaled triangle.",
    "Heron's formula needs the Semi-perimeter (s). Calculate s = Perimeter / 2.",
    "Find the difference between the semi-perimeter and each individual side.",
    "Load the values into Heron's Formula structure.",
    "Multiply the terms to find the total product under the radical.",
    "Calculate the final area to get your Zoning Approval!",
  ],
  'objectives': [
    "Learn how to use scaling and ratios to find the real dimensions of a blueprint, then use Heron's formula to find its area!",
    "Identify the ratio terms of the triangle's sides.",
    "Calculate the exact multiplier needed to scale the blueprint to reality.",
    "Scale the triangle visually to match the calculated multiplier.",
    "Verify the actual total perimeter of the newly scaled shape.",
    "Calculate the exact value of the semi-perimeter ('s').",
    "Find the mathematical difference between the semi-perimeter and each individual side.",
    "Substitute the calculated semi-perimeter and differences directly into Heron's Formula.",
    "Calculate the product of the terms inside the square root.",
    "Extract the final square root to find the total area.",
  ],
  'procedural_steps': [
    [
      "Review the blueprint.",
      "Note the target perimeter (P = 300m).",
      "Acknowledge the contract to begin.",
    ],
    [
      "Locate the draggable ratio terms (3x, 5x, 7x).",
      "Drag all known ratios into the drop zone.",
      "Observe the formulated equation.",
    ],
    [
      "Formulate the equation: 15x = 300.",
      "Calculate x.",
      "Input the correct value for 'x' and verify.",
    ],
    [
      "Locate the scale slider.",
      "Slide it until k matches your calculated x value.",
      "Lock in the correct scale.",
    ],
    [
      "Calculate the real side lengths: a=3x, b=5x, c=7x.",
      "Sum them up to find P.",
      "Input the total Perimeter and verify.",
    ],
    [
      "Calculate the semi-perimeter: s = P / 2.",
      "Input the correct value for 's' and verify.",
    ],
    [
      "Use the calculated 's' value.",
      "Subtract each side (a, b, c) from 's'.",
      "Verify all differences.",
    ],
    [
      "Observe Heron's structure.",
      "Drag the 's' value to its drop zone.",
      "Drag the difference values to their drop zones.",
    ],
    [
      "Review the multiplied product under the radical.",
      "Input the total product into the field.",
    ],
    [
      "Calculate the final square root.",
      "Enter the final area value.",
      "Stamp the contract to complete the mission.",
    ],
  ],
  'concepts': [
    "The blueprint gives us the ratio of the sides (3:5:7), not the real lengths. By attaching a variable 'x', the real sides become 3x, 5x, and 7x.",
    "To find the perimeter, we add all the sides together: 3x + 5x + 7x.",
    "Since we know the total perimeter is 300, we can solve for x. 15x = 300, so x = 20.",
    "Multiply the ratio numbers by x (20) to find the actual lengths of the walls!",
    "Double check your work! Adding the real sides together should equal the total perimeter (300).",
    "Heron's formula needs the 'semi-perimeter' (s). It's exactly half of the perimeter.",
    "Find the difference between the semi-perimeter and each individual side. This represents the 'slack' for each side.",
    "Plug everything into Heron's Formula: Area = √(s × (s-a) × (s-b) × (s-c)).",
    "Simplify the numbers inside the square root to make the final calculation easier.",
    "Calculate the final area to get your Zoning Approval! You did this without ever measuring the triangle's height.",
  ],
};

const Map<String, dynamic> hindiText = {
  'app_title': "अनुपात स्केलर",
  'tagline': "कक्षा 9 • हेरोन का सूत्र",
  'header_title': "अनुपात स्केलर",
  'ui_start_mission': "मिशन शुरू करें",
  'ui_reset': "रीसेट",
  'ui_lvl': "स्तर",
  'ui_mission_objective': "मिशन का उद्देश्य",
  'ui_procedural_steps': "प्रक्रियात्मक चरण",
  'ui_concept': "अवधारणा",
  'ui_mission_control': "मिशन नियंत्रण",
  'ui_data_log': "डेटा लॉग",
  'ui_step': "चरण",
  'ui_drop_sides': "परिमाप बार\nअनुपात यहाँ रखें",
  'ui_placed_sides': "रखे गए",
  'ui_sides': "अनुपात",
  'ui_formula_p': "3x + 5x + 7x = 300",
  'ui_formula_s': "s = P / 2 =",
  'ui_s_minus_a': "s - a =",
  'ui_s_minus_b': "s - b =",
  'ui_s_minus_c': "s - c =",
  'ui_formula_heron_inner': "√ (s · d1 · d2 · d3)",
  'ui_largest_factor': "रूट के तहत गुणनफल =",
  'ui_extracted_root': "निकाला गया अंतिम मूल ≈",
  'ui_contract_signed': "अनुबंध हस्ताक्षरित!",
  'ui_area_certified': "प्रमाणित क्षेत्रफल: 2598 m²",
  'ui_mastery_level': "महारत स्तर: 100%",
  'ui_return_base': "आधार पर लौटें",
  'ui_verify_x': "'x' सत्यापित करें",
  'ui_verify_p': "परिमाप सत्यापित करें",
  'ui_verify_s': "'s' सत्यापित करें",
  'ui_verify_diff': "अंतर सत्यापित करें",
  'ui_verify_prod': "गुणनफल सत्यापित करें",
  'ui_certify_area': "क्षेत्रफल प्रमाणित करें",
  'ui_confirm_scale': "स्केल की पुष्टि करें",
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
    "जमा करें",
    "अनुबंध पर मुहर लगाएँ",
  ],
  'actions_desc': [
    "ब्लूप्रिंट परिमाप 300m होना चाहिए, और भुजाएँ 3:5:7 के अनुपात में हैं।",
    "परिमाप समीकरण बनाने के लिए सभी तीन अनुपात पदों को बॉक्स में खींचें।",
    "गुणक 'x' के लिए हल करें। कुल परिमाप 300 है।",
    "ब्लूप्रिंट को x से गुणा करके वास्तविकता में स्केल करने के लिए स्लाइडर का उपयोग करें।",
    "वास्तविक आयामों को सत्यापित करें। स्केल किए गए त्रिभुज की वास्तविक लंबाई का योग करें।",
    "हेरोन के सूत्र के लिए अर्ध-परिमाप (s) की आवश्यकता होती है। गणना करें s = परिमाप / 2।",
    "अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच का अंतर ज्ञात करें।",
    "मानों को हेरोन के सूत्र संरचना में लोड करें।",
    "रेडिकल के तहत कुल गुणनफल खोजने के लिए पदों को गुणा करें।",
    "ज़ोनिंग अनुमोदन प्राप्त करने के लिए अंतिम क्षेत्रफल की गणना करें!",
  ],
  'objectives': [
    "जानें कि ब्लूप्रिंट के वास्तविक आयामों को खोजने के लिए स्केलिंग और अनुपातों का उपयोग कैसे करें, फिर इसका क्षेत्रफल खोजने के लिए हेरोन के सूत्र का उपयोग करें!",
    "त्रिभुज की भुजाओं के अनुपात पदों को पहचानें।",
    "ब्लूप्रिंट को वास्तविकता में स्केल करने के लिए आवश्यक सटीक गुणक की गणना करें।",
    "गणना किए गए गुणक से मेल खाने के लिए त्रिभुज को दृश्य रूप से स्केल करें।",
    "नए स्केल किए गए आकार के वास्तविक कुल परिमाप को सत्यापित करें।",
    "अर्ध-परिमाप ('s') के सटीक मान की गणना करें।",
    "अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच गणितीय अंतर ज्ञात करें।",
    "गणना किए गए अर्ध-परिमाप और अंतर को सीधे हेरोन के सूत्र में प्रतिस्थापित करें।",
    "वर्गमूल के अंदर के पदों के गुणनफल की गणना करें।",
    "कुल क्षेत्रफल खोजने के लिए अंतिम वर्गमूल निकालें।",
  ],
  'procedural_steps': [
    [
      "ब्लूप्रिंट की समीक्षा करें।",
      "लक्ष्य परिमाप (P = 300m) पर ध्यान दें।",
      "शुरू करने के लिए अनुबंध स्वीकार करें।",
    ],
    [
      "खींचने योग्य अनुपात पदों (3x, 5x, 7x) का पता लगाएँ।",
      "सभी ज्ञात अनुपातों को ड्रॉप ज़ोन में खींचें।",
      "तैयार किए गए समीकरण का निरीक्षण करें।",
    ],
    [
      "समीकरण बनाएँ: 15x = 300।",
      "x की गणना करें।",
      "'x' के लिए सही मान दर्ज करें और सत्यापित करें।",
    ],
    [
      "स्केल स्लाइडर का पता लगाएँ।",
      "इसे तब तक स्लाइड करें जब तक k आपके गणना किए गए x मान से मेल न खा जाए।",
      "सही स्केल लॉक करें।",
    ],
    [
      "वास्तविक भुजाओं की लंबाई की गणना करें: a=3x, b=5x, c=7x।",
      "P खोजने के लिए उनका योग करें।",
      "कुल परिमाप दर्ज करें और सत्यापित करें।",
    ],
    [
      "अर्ध-परिमाप की गणना करें: s = P / 2।",
      "'s' के लिए सही मान दर्ज करें और सत्यापित करें।",
    ],
    [
      "गणना किए गए 's' मान का उपयोग करें।",
      "'s' से प्रत्येक भुजा (a, b, c) को घटाएँ।",
      "सभी अंतरों को सत्यापित करें।",
    ],
    [
      "हेरोन की संरचना का निरीक्षण करें।",
      "'s' मान को उसके ड्रॉप ज़ोन में खींचें।",
      "अंतर मानों को उनके ड्रॉप ज़ोन में खींचें।",
    ],
    [
      "रेडिकल के तहत गुणा किए गए उत्पाद की समीक्षा करें।",
      "फ़ील्ड में कुल गुणनफल दर्ज करें।",
    ],
    [
      "अंतिम वर्गमूल की गणना करें।",
      "अंतिम क्षेत्रफल मान दर्ज करें।",
      "मिशन को पूरा करने के लिए अनुबंध पर मुहर लगाएँ।",
    ],
  ],
  'concepts': [
    "ब्लूप्रिंट हमें भुजाओं (3:5:7) का अनुपात देता है, वास्तविक लंबाई नहीं। एक चर 'x' संलग्न करने से, वास्तविक भुजाएँ 3x, 5x और 7x हो जाती हैं।",
    "परिमाप ज्ञात करने के लिए, हम सभी भुजाओं को एक साथ जोड़ते हैं: 3x + 5x + 7x।",
    "चूंकि हम जानते हैं कि कुल परिमाप 300 है, हम x के लिए हल कर सकते हैं। 15x = 300, इसलिए x = 20।",
    "दीवारों की वास्तविक लंबाई खोजने के लिए अनुपात संख्याओं को x (20) से गुणा करें!",
    "अपने काम की दोबारा जांच करें! वास्तविक भुजाओं को एक साथ जोड़ने पर कुल परिमाप (300) के बराबर होना चाहिए।",
    "हेरोन के सूत्र को 'अर्ध-परिमाप' (s) की आवश्यकता होती है। यह परिमाप का ठीक आधा है।",
    "अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच का अंतर ज्ञात करें। यह प्रत्येक भुजा के लिए 'स्लैक' का प्रतिनिधित्व करता है।",
    "सब कुछ हेरोन के सूत्र में रखें: Area = √(s × (s-a) × (s-b) × (s-c))।",
    "अंतिम गणना को आसान बनाने के लिए वर्गमूल के अंदर की संख्याओं को सरल बनाएं।",
    "ज़ोनिंग अनुमोदन प्राप्त करने के लिए अंतिम क्षेत्रफल की गणना करें! आपने त्रिभुज की ऊंचाई को मापे बिना ऐसा किया।",
  ],
};

const Map<String, Map<String, dynamic>> labText = {
  'en': englishText,
  'hi': hindiText,
  'te': englishText,
};
