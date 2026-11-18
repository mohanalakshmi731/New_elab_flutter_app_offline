// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PerimeterPatrolApp());
}

class PerimeterPatrolApp extends StatelessWidget {
  const PerimeterPatrolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Perimeter Patrol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0518),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF1E1B4B),
        ),
      ),
      home: const PerimeterPatrolScreen(),
    );
  }
}

class PerimeterPatrolScreen extends StatefulWidget {
  const PerimeterPatrolScreen({super.key});

  @override
  State<PerimeterPatrolScreen> createState() => _PerimeterPatrolScreenState();
}

class _PerimeterPatrolScreenState extends State<PerimeterPatrolScreen>
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
  double step5SliderValue = 0.0;
  Map<int, String> step6Inputs = {0: '', 1: '', 2: ''};
  Map<int, String?> step7Slots = {0: null, 1: null, 2: null, 3: null};
  String step8Input = '';
  String step9Input = '';
  String step10Input = '';

  // Modals
  bool showFinalModal = false;

  // Geometry Defaults
  final Offset vA = const Offset(-4, 4);
  final Offset vB = const Offset(-5, -4);
  final Offset vC = const Offset(5, -4);

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
      step5SliderValue = 0.0;
      step6Inputs = {0: '', 1: '', 2: ''};
      step7Slots = {0: null, 1: null, 2: null, 3: null};
      step8Input = '';
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

          // Action Panel (Compact, Bottom Left, 38% width)
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
          _logItem("P", "32"),
          _logItem("a", "8"),
          _logItem("b", "11"),
          _logItem(
            "c",
            currentStep > 3 ? "13" : "?",
            highlight: currentStep == 3,
          ),
          _logItem(
            "s",
            currentStep > 5 ? "16" : "?",
            highlight: currentStep == 5,
          ),
          if (currentStep >= 6) ...[
            const Divider(color: Colors.white24, height: 8),
            _logItem(
              "s-a",
              currentStep > 6 ? "8" : "?",
              highlight: currentStep == 6,
            ),
            _logItem(
              "s-b",
              currentStep > 6 ? "5" : "?",
              highlight: currentStep == 6,
            ),
            _logItem(
              "s-c",
              currentStep > 6 ? "3" : "?",
              highlight: currentStep == 6,
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
                _buildDraggable('8', '8', themePrimary),
                const SizedBox(width: 8),
                _buildDraggable('11', '11', themeSecondary),
              ],
            ),
            const SizedBox(height: 8),
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                if (isAdvancing) return;
                if (details.data == '8' || details.data == '11') {
                  if (!step2Dropped.contains(details.data)) {
                    playSuccess();
                    setState(() {
                      step2Dropped.add(details.data);
                      if (step2Dropped.length == 2) completeStep();
                    });
                  }
                } else {
                  playError();
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: step2Dropped.length == 2 || isAdvancing
                        ? themeSuccess.withOpacity(0.2)
                        : Colors.black45,
                    border: Border.all(
                      color: step2Dropped.length == 2 || isAdvancing
                          ? themeSuccess
                          : themeBorder,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    step2Dropped.isEmpty
                        ? t['ui_drop_sides']
                        : "${t['ui_placed_sides']} ${step2Dropped.length}/2 ${t['ui_sides']}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: step2Dropped.length == 2 || isAdvancing
                          ? themeSuccess
                          : themeMuted,
                      fontSize: 11,
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
        bool isCorrect3 = step3Input.trim() == '13';
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
                const SizedBox(width: 8),
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
                        step3Input = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_verify_side_c'],
              () {
                if (step3Input.trim() == '13') {
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
        content = _buildPrimaryBtn(
          t['actions_btn'][3],
          completeStep,
          themePrimary,
        );
        break;
      case 5:
        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border.all(
                        color: isAdvancing || step5SliderValue == 16.0
                            ? themeSuccess
                            : themeBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      step5SliderValue > 0
                          ? "${step5SliderValue.toInt()}"
                          : "?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: step5SliderValue == 16 || isAdvancing
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
                value: step5SliderValue,
                min: 0,
                max: 32,
                divisions: 32,
                activeColor: themeAccent,
                onChanged: isAdvancing
                    ? null
                    : (val) {
                        if (val.toInt() % 4 == 0) playClick();
                        setState(() => step5SliderValue = val);
                        if (val == 16.0) completeStep();
                      },
              ),
            ),
          ],
        );
        break;
      case 6:
        content = Column(
          children: [
            _buildDiffInputRow(t['ui_s_minus_a'], 0),
            const SizedBox(height: 4),
            _buildDiffInputRow(t['ui_s_minus_b'], 1),
            const SizedBox(height: 4),
            _buildDiffInputRow(t['ui_s_minus_c'], 2),
            const SizedBox(height: 8),
            _buildPrimaryBtn(
              t['ui_verify_diff'],
              () {
                if (step6Inputs[0] == '8' &&
                    step6Inputs[1] == '5' &&
                    step6Inputs[2] == '3') {
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
      case 7:
        content = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDraggable('16', '16', themeAccent),
                const SizedBox(width: 6),
                _buildDraggable('8', '8', themeSuccess),
                const SizedBox(width: 6),
                _buildDraggable('5', '5', themeSuccess),
                const SizedBox(width: 6),
                _buildDraggable('3', '3', themeSuccess),
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
                  _buildDragTarget(0, '16', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(1, '8', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(2, '5', '?'),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: themeMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDragTarget(3, '3', '?'),
                ],
              ),
            ),
          ],
        );
        break;
      case 8:
        bool isCorrect8 = step8Input.trim() == '1920';
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
              t['ui_verify_prod'],
              () {
                if (step8Input.trim() == '1920') {
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
      case 9:
        bool isCorrect9 = step9Input.trim() == '64';
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
              t['ui_verify_factor'],
              () {
                if (step9Input.trim() == '64') {
                  completeStep();
                } else {
                  playError();
                }
              },
              themeAccent,
              icon: Icons.rule,
            ),
          ],
        );
        break;
      case 10:
        bool isCorrect10 = step10Input.trim() == '8';
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
                if (step10Input.trim() == '8') {
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
      padding: const EdgeInsets.all(8),
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
              isAdvancing ? 'Correct! Advancing...' : text.toUpperCase(),
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

  Widget _buildDiffInputRow(String label, int index) {
    bool isCorrect =
        (index == 0 && step6Inputs[0] == '8') ||
        (index == 1 && step6Inputs[1] == '5') ||
        (index == 2 && step6Inputs[2] == '3');

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
                  step6Inputs[index] = v;
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
    if (currentStep == 7 && step7Slots.containsValue(value)) {
      return const SizedBox();
    }

    return Draggable<String>(
      data: value,
      onDragStarted: playClick,
      maxSimultaneousDrags: isAdvancing ? 0 : 1, // Disable drag if advancing
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
    bool isFilled = step7Slots[index] != null;
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (isAdvancing) return;
        if (details.data == expected) {
          playSuccess();
          setState(() {
            step7Slots[index] = details.data;
            if (!step7Slots.containsValue(null)) {
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
            isFilled ? step7Slots[index]! : "?",
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
                    fontSize: 16,
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
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.2,
          maxScale: 4.0,
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
    final double cy = size.height / 2 - 40;

    final double scale = 30.0;

    canvas.save();
    canvas.translate(cx, cy);

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    double stepSize = scale;
    for (double x = -size.width; x < size.width; x += stepSize) {
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (double y = -size.height; y < size.height; y += stepSize) {
      canvas.drawLine(Offset(-size.width, y), Offset(size.width, y), gridPaint);
    }

    final Paint axisPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 2;
    canvas.drawLine(Offset(-size.width, 0), Offset(size.width, 0), axisPaint);
    canvas.drawLine(Offset(0, -size.height), Offset(0, size.height), axisPaint);

    Offset toScreen(Offset p) => Offset(p.dx * scale, -p.dy * scale);

    final sA = toScreen(vA);
    final sB = toScreen(vB);
    final sC = toScreen(vC);

    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(sB, sC, solidPaint);
    canvas.drawLine(sC, sA, solidPaint);

    final Paint abPaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (step >= 3) {
      abPaint.color = themeSuccess;
      canvas.drawLine(sA, sB, abPaint);
    } else {
      abPaint.color = themeError;
      _drawDashedLine(canvas, sA, sB, [10, 10], abPaint);
    }

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

    _drawText(
      canvas,
      "11m",
      (sA.dx + sC.dx) / 2 + 20,
      (sA.dy + sC.dy) / 2,
      themeSecondary,
      16,
    );
    _drawText(
      canvas,
      "8m",
      (sB.dx + sC.dx) / 2,
      (sB.dy + sC.dy) / 2 + 25,
      themeSecondary,
      16,
    );

    if (step >= 3) {
      _drawText(
        canvas,
        "13m",
        (sA.dx + sB.dx) / 2 - 20,
        (sA.dy + sB.dy) / 2,
        themeSuccess,
        16,
      );
    } else {
      _drawText(
        canvas,
        "? m",
        (sA.dx + sB.dx) / 2 - 20,
        (sA.dy + sB.dy) / 2,
        themeError,
        16,
      );
    }

    final Paint nodeOutline = Paint()..color = Colors.white;
    for (var p in [sA, sB, sC]) {
      canvas.drawCircle(p, 6, solidPaint);
      canvas.drawCircle(p, 4, nodeOutline);
    }

    canvas.restore();
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    List<double> dashArray,
    Paint paint,
  ) {
    double distance = (p1 - p2).distance;
    double dashLen = dashArray[0];
    double gapLen = dashArray[1];
    int dashCount = (distance / (dashLen + gapLen)).floor();
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;

    double x = p1.dx;
    double y = p1.dy;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dx * dashLen, y + dy * dashLen),
        paint,
      );
      x += dx * (dashLen + gapLen);
      y += dy * (dashLen + gapLen);
    }
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

const Map<String, Map<String, dynamic>> labText = {
  'en': {
    'app_title': "THE PERIMETER PATROL",
    'tagline': "Class 9 • HERON'S FORMULA",
    'header_title': "Perimeter Patrol",
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
    'ui_formula_p': "P - (a + b) =",
    'ui_formula_s': "s = P / 2 =",
    'ui_s_minus_a': "s - a =",
    'ui_s_minus_b': "s - b =",
    'ui_s_minus_c': "s - c =",
    'ui_formula_heron_inner': "s · (s-a) · (s-b) · (s-c) =",
    'ui_largest_factor': "Largest perfect square factor =",
    'ui_extracted_root': "Extracted root =",
    'ui_contract_signed': "CONTRACT SIGNED!",
    'ui_area_certified': "Area Certified: 43.81 m²",
    'ui_mastery_level': "Mastery Level: 100%",
    'ui_return_base': "RETURN TO BASE",
    'ui_verify_side_c': "VERIFY SIDE 'c'",
    'ui_verify_diff': "VERIFY DIFFERENCES",
    'ui_verify_prod': "VERIFY PRODUCT",
    'ui_verify_factor': "VERIFY FACTOR",
    'ui_certify_area': "CERTIFY AREA",
    'ui_correct_advancing': "CORRECT! ADVANCING...",
    'actions_btn': [
      "Acknowledge Contract",
      "Submit",
      "Submit",
      "Activate Analysis Mode",
      "Submit",
      "Verify Differences",
      "Submit",
      "Factorize into Squares",
      "Extract Root (Final Area)",
      "Stamp Contract",
    ],
    'actions_desc': [
      "You have been assigned a new contract to survey an incomplete triangular perimeter.",
      "Place the known measurements onto the perimeter bar to visualize the missing gap.",
      "Calculate the missing side by subtracting the known sides from the total perimeter.",
      "Heron's engine requires the 'semi-perimeter' to function. Switch modes to calculate it.",
      "The semi-perimeter (s) is exactly half of the total perimeter.",
      "Calculate the difference between the semi-perimeter and each side.",
      "Load the values into Heron's Formula structure.",
      "Multiply the terms to find the total product under the radical.",
      "Pull out the perfect squares to simplify the calculation.",
      "The area calculation is complete. Ready for final approval.",
    ],
    'objectives': [
      "Understand the scenario: We need to fence a triangular perimeter but are missing one side's measurement. The total required perimeter is known.",
      "Identify the known sides of the triangle and compare them against the total perimeter.",
      "Calculate the exact length of the missing side.",
      "Recognize that Heron's formula requires a special value called the semi-perimeter ('s').",
      "Calculate the exact value of the semi-perimeter ('s').",
      "Find the mathematical difference between the semi-perimeter and each individual side.",
      "Substitute the calculated semi-perimeter and differences directly into Heron's Formula.",
      "Factor the numbers inside the square root to simplify the complex multiplication.",
      "Extract the perfect square root to simplify the final area.",
      "Review the finalized area calculation and verify the land contract.",
    ],
    'procedural_steps': [
      [
        "Review the initial triangle diagram.",
        "Note the total contract perimeter (P = 32m).",
        "Acknowledge the contract to begin.",
      ],
      [
        "Locate the draggable side lengths.",
        "Drag both known sides onto the Perimeter Bar.",
        "Observe the remaining empty space representing side 'c'.",
      ],
      [
        "Formulate the equation: c = P - (a+b).",
        "Calculate it.",
        "Input the correct value for side 'c' and verify.",
      ],
      [
        "Review the difference between full Perimeter (P) and Semi-perimeter (s).",
        "Activate the Analysis Mode.",
      ],
      [
        "Locate the Cutter Slider tool.",
        "Slide it until it reaches exactly half of the total perimeter.",
        "Lock in the correct 's' value.",
      ],
      [
        "Use the calculated 's' value.",
        "Subtract side 'a' from 's'.",
        "Subtract side 'b' from 's'.",
        "Subtract side 'c' from 's'.",
        "Verify all differences.",
      ],
      [
        "Observe Heron's structure: √(s · d1 · d2 · d3)",
        "Drag the 's' value to its drop zone.",
        "Drag the difference values to their drop zones.",
      ],
      [
        "Review the multiplied product under the radical.",
        "Input the total product into the field.",
      ],
      [
        "Factorize the number into perfect squares.",
        "Enter the largest perfect square factor.",
      ],
      [
        "Extract the final value.",
        "Enter the extracted root value.",
        "Stamp the contract to complete the mission.",
      ],
    ],
    'concepts': [
      "The perimeter of a triangle is the total length of its outer boundary, calculated by adding the lengths of all three sides: P = a + b + c.",
      "If the total perimeter is known, the missing side can be treated as an algebraic variable.",
      "By subtracting the sum of the known sides from the total perimeter, we isolate and solve for the unknown side.",
      "Heron of Alexandria devised a method to calculate area using only side lengths, requiring a fundamental metric called the 'semi-perimeter'.",
      "The semi-perimeter, denoted as 's', is exactly half of the total perimeter: s = P/2.",
      "Heron's formula relies on calculating the difference between the semi-perimeter and each individual side, creating three distinct factors.",
      "The core of Heron's Formula is the square root of the product of the semi-perimeter and the three differences: Area = √(s(s-a)(s-b)(s-c)).",
      "Large numbers under a square root can be factored into perfect squares to simplify manual calculation.",
      "Extracting the square root of the perfect squares leaves the irreducible components inside, which can then be approximated as a decimal.",
      "Heron's Formula is a powerful tool in land surveying and architecture, allowing area calculation without needing to find the height of the triangle.",
    ],
  },
  'hi': {
    'app_title': "द पेरिमीटर पेट्रोल",
    'tagline': "कक्षा 9 • हेरोन का सूत्र",
    'header_title': "पेरिमीटर पेट्रोल",
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
    'ui_formula_p': "P - (a + b) =",
    'ui_formula_s': "s = P / 2 =",
    'ui_s_minus_a': "s - a =",
    'ui_s_minus_b': "s - b =",
    'ui_s_minus_c': "s - c =",
    'ui_formula_heron_inner': "s · (s-a) · (s-b) · (s-c) =",
    'ui_largest_factor': "सबसे बड़ा पूर्ण वर्ग कारक =",
    'ui_extracted_root': "निकाला गया मूल =",
    'ui_contract_signed': "अनुबंध हस्ताक्षरित!",
    'ui_area_certified': "प्रमाणित क्षेत्रफल: 43.81 m²",
    'ui_mastery_level': "महारत स्तर: 100%",
    'ui_return_base': "आधार पर लौटें",
    'ui_verify_side_c': "भुजा 'c' सत्यापित करें",
    'ui_verify_diff': "अंतर सत्यापित करें",
    'ui_verify_prod': "गुणनफल सत्यापित करें",
    'ui_verify_factor': "कारक सत्यापित करें",
    'ui_certify_area': "क्षेत्रफल प्रमाणित करें",
    'ui_correct_advancing': "सही! आगे बढ़ रहे हैं...",
    'actions_btn': [
      "अनुबंध स्वीकार करें",
      "जमा करें",
      "जमा करें",
      "विश्लेषण मोड सक्रिय करें",
      "जमा करें",
      "सत्यापित करें",
      "जमा करें",
      "वर्गों में गुणनखंड करें",
      "मूल निकालें (अंतिम क्षेत्रफल)",
      "अनुबंध पर मुहर लगाएँ",
    ],
    'actions_desc': [
      "आपको एक अधूरे त्रिकोणीय परिमाप का सर्वेक्षण करने का नया अनुबंध सौंपा गया है।",
      "छूटे हुए हिस्से की कल्पना करने के लिए ज्ञात मापों को परिमाप पट्टी पर रखें।",
      "कुल परिमाप से ज्ञात भुजाओं को घटाकर अज्ञात भुजा की गणना करें।",
      "हेरोन के इंजन को काम करने के लिए 'अर्ध-परिमाप' की आवश्यकता है। इसकी गणना करने के लिए मोड बदलें।",
      "अर्ध-परिमाप (s) कुल परिमाप का ठीक आधा है।",
      "अर्ध-परिमाप और प्रत्येक भुजा के बीच के अंतर की गणना करें।",
      "मानों को हेरोन के सूत्र संरचना में लोड करें।",
      "रेडिकल के नीचे कुल गुणनफल खोजने के लिए पदों को गुणा करें।",
      "गणना को सरल बनाने के लिए पूर्ण वर्गों को बाहर निकालें।",
      "क्षेत्रफल की गणना पूरी हो गई है। अंतिम स्वीकृति के लिए तैयार है।",
    ],
    'objectives': [
      "परिदृश्य को समझें: हमें एक त्रिकोणीय परिधि की बाड़ लगानी है, लेकिन एक भुजा का माप गायब है। कुल आवश्यक परिमाप ज्ञात है।",
      "त्रिभुज की ज्ञात भुजाओं को पहचानें और कुल परिमाप से उनकी तुलना करें।",
      "अज्ञात भुजा की सटीक लंबाई की गणना करें।",
      "समझें कि हेरोन के सूत्र के लिए 'अर्ध-परिमाप' ('s') नामक एक विशेष मान की आवश्यकता होती है।",
      "अर्ध-परिमाप ('s') के सटीक मान की गणना करें।",
      "अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच गणितीय अंतर ज्ञात करें।",
      "गणना किए गए अर्ध-परिमाप और अंतरों को सीधे हेरोन के सूत्र में प्रतिस्थापित करें।",
      "जटिल गुणा को सरल बनाने के लिए वर्गमूल के अंदर की संख्याओं का गुणनखंड करें।",
      "अंतिम क्षेत्रफल को सरल बनाने के लिए पूर्ण वर्गमूल निकालें।",
      "अंतिम क्षेत्र गणना की समीक्षा करें और भूमि अनुबंध को सत्यापित करें।",
    ],
    'procedural_steps': [
      [
        "प्रारंभिक त्रिभुज आरेख की समीक्षा करें।",
        "कुल अनुबंध परिमाप (P = 32m) पर ध्यान दें।",
        "शुरू करने के लिए अनुबंध स्वीकार करें।",
      ],
      [
        "खींचने योग्य भुजाओं का पता लगाएँ।",
        "दोनों ज्ञात भुजाओं को परिमाप पट्टी पर खींचें।",
        "भुजा 'c' का प्रतिनिधित्व करने वाले शेष खाली स्थान का निरीक्षण करें।",
      ],
      [
        "समीकरण बनाएँ: c = P - (a+b)।",
        "इसकी गणना करें।",
        "भुजा 'c' के लिए सही मान दर्ज करें और सत्यापित करें।",
      ],
      [
        "पूर्ण परिमाप (P) और अर्ध-परिमाप (s) के बीच के अंतर की समीक्षा करें।",
        "विश्लेषण मोड सक्रिय करें।",
      ],
      [
        "कटर स्लाइडर उपकरण का पता लगाएँ।",
        "इसे तब तक स्लाइड करें जब तक कि यह कुल परिमाप के ठीक आधे तक न पहुँच जाए।",
        "सही 's' मान को लॉक करें।",
      ],
      [
        "गणना किए गए 's' मान का उपयोग करें।",
        "'s' से भुजा 'a' घटाएँ।",
        "'s' से भुजा 'b' घटाएँ।",
        "'s' से भुजा 'c' घटाएँ।",
        "सभी अंतरों को सत्यापित करें।",
      ],
      [
        "हेरोन की संरचना का निरीक्षण करें: √(s · d1 · d2 · d3)",
        "'s' मान को उसके ड्रॉप ज़ोन में खींचें।",
        "अंतर मानों को उनके ड्रॉप ज़ोन में खींचें।",
      ],
      [
        "रेडिकल के तहत गुणा किए गए उत्पाद की समीक्षा करें।",
        "फ़ील्ड में कुल गुणनफल दर्ज करें।",
      ],
      [
        "संख्या को पूर्ण वर्गों में गुणनखंडित करें।",
        "सबसे बड़ा पूर्ण वर्ग कारक दर्ज करें।",
      ],
      [
        "अंतिम मान निकालें।",
        "निकाले गए मूल मान को दर्ज करें।",
        "मिशन को पूरा करने के लिए अनुबंध पर मुहर लगाएँ।",
      ],
    ],
    'concepts': [
      "एक त्रिभुज का परिमाप उसकी बाहरी सीमा की कुल लंबाई है, जिसकी गणना तीनों भुजाओं को जोड़कर की जाती है: P = a + b + c।",
      "यदि कुल परिमाप ज्ञात है, तो अज्ञात भुजा को एक बीजगणितीय चर के रूप में माना जा सकता है।",
      "कुल परिमाप से ज्ञात भुजाओं के योग को घटाकर, हम अज्ञात भुजा को अलग करके उसका मान निकालते हैं।",
      "अलेक्जेंड्रिया के हेरोन ने केवल भुजाओं की लंबाई का उपयोग करके क्षेत्रफल की गणना करने की एक विधि तैयार की, जिसमें 'अर्ध-परिमाप' नामक एक मूलभूत मीट्रिक की आवश्यकता होती है।",
      "अर्ध-परिमाप, जिसे 's' से दर्शाया जाता है, कुल परिमाप का ठीक आधा होता है: s = P/2।",
      "हेरोन का सूत्र अर्ध-परिमाप और प्रत्येक व्यक्तिगत भुजा के बीच के अंतर की गणना पर निर्भर करता है, जिससे तीन अलग-अलग कारक बनते हैं।",
      "हेरोन के सूत्र का मूल भाग अर्ध-परिमाप और तीन अंतरों के गुणनफल का वर्गमूल है: Area = √(s(s-a)(s-b)(s-c))।",
      "मैन्युअल गणना को सरल बनाने के लिए वर्गमूल के अंदर बड़ी संख्याओं को पूर्ण वर्गों में गुणनखंडित किया जा सकता है।",
      "पूर्ण वर्गों का वर्गमूल निकालने से अंदर केवल अप्रासंगिक घटक बचते हैं, जिन्हें दशमलव के रूप में अनुमानित किया जा सकता है।",
      "हेरोन का सूत्र भूमि सर्वेक्षण और वास्तुकला में एक शक्तिशाली उपकरण है, जो त्रिभुज की ऊंचाई जाने बिना क्षेत्रफल की गणना करने की अनुमति देता है।",
    ],
  },
};
