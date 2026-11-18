// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DivisionMazeApp(),
    ),
  );
}

// --- DATA MODELS ---
class Mission {
  final int id;
  final String dividend;
  final String divisor;
  final String q1;
  final String q1Wrong;
  final String mult;
  final String multWrong;
  final String rem1;
  final String rem1Wrong;
  final String finalQ;
  final String finalR;

  Mission({
    required this.id,
    required this.dividend,
    required this.divisor,
    required this.q1,
    required this.q1Wrong,
    required this.mult,
    required this.multWrong,
    required this.rem1,
    required this.rem1Wrong,
    required this.finalQ,
    required this.finalR,
  });
}

final List<Mission> missions = [
  Mission(
    id: 0,
    dividend: "2x^2 + 3x + 1",
    divisor: "x + 2",
    q1: "2x",
    q1Wrong: "x",
    mult: "2x^2 + 4x",
    multWrong: "2x^2 + 2x",
    rem1: "-x + 1",
    rem1Wrong: "x + 1",
    finalQ: "2x - 1",
    finalR: "3",
  ),
  Mission(
    id: 1,
    dividend: "3x^3 + x^2 + 2x + 5",
    divisor: "x^2 + 2x + 1",
    q1: "3x",
    q1Wrong: "3x^2",
    mult: "3x^3 + 6x^2 + 3x",
    multWrong: "3x^3 + 3x^2 + 3x",
    rem1: "-5x^2 - x + 5",
    rem1Wrong: "5x^2 + x + 5",
    finalQ: "3x - 5",
    finalR: "9x + 10",
  ),
  Mission(
    id: 2,
    dividend: "x^3 - 3x^2 + 5x - 3",
    divisor: "x^2 - 2",
    q1: "x",
    q1Wrong: "x^2",
    mult: "x^3 - 2x",
    multWrong: "x^3 - 2",
    rem1: "-3x^2 + 7x - 3",
    rem1Wrong: "-3x^2 + 3x - 3",
    finalQ: "x - 3",
    finalR: "7x - 9",
  ),
  Mission(
    id: 3,
    dividend: "-x^3 + 3x^2 - 3x + 5",
    divisor: "-x^2 + x - 1",
    q1: "x",
    q1Wrong: "-x",
    mult: "-x^3 + x^2 - x",
    multWrong: "-x^3 - x^2 + x",
    rem1: "2x^2 - 2x + 5",
    rem1Wrong: "-2x^2 + 2x + 5",
    finalQ: "x - 2",
    finalR: "3",
  ),
  Mission(
    id: 4,
    dividend: "x^4 - 5x + 6",
    divisor: "-x^2 + 2",
    q1: "-x^2",
    q1Wrong: "x^2",
    mult: "x^4 - 2x^2",
    multWrong: "x^4 + 2x^2",
    rem1: "2x^2 - 5x + 6",
    rem1Wrong: "-2x^2 - 5x + 6",
    finalQ: "-x^2 - 2",
    finalR: "-5x + 10",
  ),
];

// --- LOCALIZATION ---

const Map<String, Map<String, String>> i18n = {
  "en": {
    "app_title": "THE DIVISION MAZE",
    "tagline": "DIVISION ALGORITHM FOR POLYNOMIALS • CLASS 10",
    "init_btn": "ENTER MAZE",
    "btn_start_lab": "Start Maze",
    "btn_restart": "Reset Maze",
    "lbl_progress": "Maze Progress",
    "hud_status": "Runner Status",
    "lbl_select_mission": "Select Division Problem",
    "btn_load": "START MISSION",
    "msg_step1": "Find 1st Term of Quotient",
    "msg_step2": "Multiply Divisor by Quotient Term",
    "msg_step3": "Subtract to find Remainder",
    "msg_success": "MAZE CLEARED",
    "btn_next": "Next Mission",
    "obj_title": "MISSION OBJECTIVE",
    "obj_desc":
        "Navigate the maze by solving polynomial division steps. Calculate quotient terms, multiply, and subtract correctly to disable the energy gates and find the remainder to escape.",
  },
  "hi": {
    "app_title": "विभाजन भूलभुलैया",
    "tagline": "बहुपदों के लिए विभाजन एल्गोरिथम • कक्षा 10",
    "init_btn": "भूलभुलैया में प्रवेश करें",
    "btn_start_lab": "भूलभुलैया शुरू करें",
    "btn_restart": "रीसेट करें",
    "lbl_progress": "भूलभुलैया प्रगति",
    "hud_status": "रनर स्थिति",
    "lbl_select_mission": "विभाजन समस्या चुनें",
    "btn_load": "मिशन शुरू करें",
    "msg_step1": "भागफल का पहला पद ज्ञात करें",
    "msg_step2": "भाजक को भागफल पद से गुणा करें",
    "msg_step3": "शेषफल ज्ञात करने के लिए घटाएं",
    "msg_success": "भूलभुलैया साफ़",
    "btn_next": "अगला मिशन",
    "obj_title": "मिशन उद्देश्य",
    "obj_desc":
        "बहुपद विभाजन के चरणों को हल करके भूलभुलैया को पार करें। ऊर्जा द्वारों को निष्क्रिय करने और बचने के लिए शेषफल खोजने के लिए भागफल पदों, गुणा और घटाव की सही गणना करें।",
  },
};

// Math string formatting helper (Replaces KaTeX for pure native rendering)
String fMath(String input) {
  return input
      .replaceAll('^2', '²')
      .replaceAll('^3', '³')
      .replaceAll('^4', '⁴')
      .replaceAll('^5', '⁵');
}

// --- STATE MANAGEMENT & MAIN SCREEN ---

class DivisionMazeApp extends StatefulWidget {
  const DivisionMazeApp({super.key});

  @override
  State<DivisionMazeApp> createState() => _DivisionMazeAppState();
}

class _DivisionMazeAppState extends State<DivisionMazeApp>
    with TickerProviderStateMixin {
  String _getStepTitle() {
    switch (_step) {
      case 1:
        return getT('lbl_select_mission');
      case 2:
        return getT('msg_step1');
      case 3:
        return getT('msg_step2');
      case 4:
        return getT('msg_step3');
      case 5:
        return getT('msg_success');
      default:
        return '';
    }
  }

  bool _showCurtain = true;
  String _lang = 'en';
  bool _sidebarOpen = true;
  Mission? _currentMission;
  int _step = 1;
  List<String> _currentOptions = ['', ''];
  int _correctIndex = 0;

  late AnimationController _runnerAnimController;
  late Animation<double> _runnerZAnimation;
  late AnimationController _celebrationController;
  late AnimationController _shakeController;
  double _currentRunnerZ = 10.0;

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

  @override
  void initState() {
    super.initState();
    _runnerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _runnerZAnimation = Tween<double>(
      begin: 10.0,
      end: 10.0,
    ).animate(_runnerAnimController);

    _runnerAnimController.addListener(() {
      setState(() {
        _currentRunnerZ = _runnerZAnimation.value;
      });
    });

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _runnerAnimController.dispose();
    _celebrationController.dispose();
    _shakeController.dispose();

    // Dispose Audio players
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _playSound(String type) async {
    // Keep haptic feedback
    if (type == 'click') HapticFeedback.selectionClick();
    if (type == 'success') HapticFeedback.heavyImpact();
    if (type == 'error') HapticFeedback.vibrate();

    try {
      if (type == 'click') {
        await _clickPlayer.stop();
        await _clickPlayer.play(AssetSource(_clickUrl));
      } else if (type == 'success') {
        await _successPlayer.stop();
        await _successPlayer.play(AssetSource(_successUrl));
      } else if (type == 'error') {
        await _errorPlayer.stop();
        await _errorPlayer.play(AssetSource(_errorUrl));
      } else if (type == 'shutter') {
        await _fxPlayer.stop();
        await _fxPlayer.play(AssetSource(_shutterUrl));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _generateOptions(String correct, String wrong) {
    _correctIndex = Random().nextInt(2);
    if (_correctIndex == 0) {
      _currentOptions = [correct, wrong];
    } else {
      _currentOptions = [wrong, correct];
    }
  }

  void _executeStep(int stepVal) {
    if (stepVal != 1) _playSound('click');
    setState(() {
      _step = stepVal;
      if (stepVal == 1) {
        _currentMission ??= missions[0];
        _currentRunnerZ = 10.0;
        _runnerZAnimation = Tween<double>(
          begin: 10.0,
          end: 10.0,
        ).animate(_runnerAnimController);
      } else if (stepVal == 2) {
        _generateOptions(_currentMission!.q1, _currentMission!.q1Wrong);
      } else if (stepVal == 3) {
        _generateOptions(_currentMission!.mult, _currentMission!.multWrong);
      } else if (stepVal == 4) {
        _generateOptions(_currentMission!.rem1, _currentMission!.rem1Wrong);
      } else if (stepVal == 5) {
        _celebrationController.forward().then((value) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _celebrationController.reverse();
          });
        });
      }
    });
  }

  void _checkAnswer(int selectedIndex) {
    if (selectedIndex == _correctIndex) {
      _playSound('success');

      // Calculate target Z based on step
      double startZ = _currentRunnerZ;
      double endZ = startZ - 10.0;

      _runnerZAnimation = Tween<double>(begin: startZ, end: endZ).animate(
        CurvedAnimation(parent: _runnerAnimController, curve: Curves.easeInOut),
      );

      _runnerAnimController.forward(from: 0).then((_) {
        _executeStep(_step + 1);
      });
    } else {
      _playSound('error');
      // Shake animation
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    }
  }

  String getT(String key) {
    return i18n[_lang]?[key] ?? i18n['en']![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth * 0.40; // 40% exactly

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Layer 0: Background Canvas (Maze Painter) with pan & zoom
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF050B14),
                      Colors.black,
                    ],
                    radius: 1.5,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 2.5,
                      boundaryMargin: const EdgeInsets.all(200),
                      child: Transform.translate(
                        offset: Offset(
                          sin(_shakeController.value * pi * 4) * 10,
                          0,
                        ),
                        child: CustomPaint(
                          painter: MazePainter(
                            runnerZ: _currentRunnerZ,
                            themeColor: const Color(0xFF3B82F6),
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Layer 1: Left Side Panel (38% Width)
            if (!_showCurtain)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _sidebarOpen ? 0 : -panelWidth,
                top: 0,
                bottom: 0,
                width: panelWidth,
                child: _buildSidePanel(panelWidth),
              ),

            // Layer 2: Floating mission card when sidebar is closed (right side)
            if (!_sidebarOpen && !_showCurtain)
              Positioned(top: 70, left: 20, child: _buildFloatingMissionCard()),

            // Layer 4: Floating Menu Button (top-Left Corner)
            if (!_showCurtain)
              Positioned(
                top: 20,
                left: 20,
                child: FloatingActionButton(
                  heroTag: 'menuBtn',
                  backgroundColor: const Color(0xFF3B82F6),
                  elevation: 4,
                  onPressed: () {
                    _playSound('click');
                    setState(() {
                      _sidebarOpen = !_sidebarOpen;
                    });
                  },
                  child: Icon(
                    _sidebarOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),

            // Layer 5: Celebration Overlay
            IgnorePointer(
              ignoring: true,
              child: FadeTransition(
                opacity: _celebrationController,
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "ESCAPED!",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.white54, blurRadius: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          border: Border.all(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          _currentMission != null
                              ? "Q = ${fMath(_currentMission!.finalQ)}\nR = ${fMath(_currentMission!.finalR)}"
                              : "",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Layer 6: Intro Curtain
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF050B14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.extension,
                        size: 80,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        getT('app_title'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        getT('tagline'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF93C5FD),
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          _playSound(
                            'shutter',
                          ); // Use specific shutter sound here
                          setState(() {
                            _showCurtain = false;
                            _executeStep(1); // Auto initialize to step 1
                          });
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: Text(
                          getT('init_btn'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSidePanel(double width) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.9),
            border: Border(
              right: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 70,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Controls Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getT('app_title'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getT('tagline'),
                                    style: const TextStyle(
                                      color: Color(0xFF60A5FA),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Language Toggles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: ['en', 'hi'].map((l) {
                                  bool active = _lang == l;
                                  return InkWell(
                                    onTap: () {
                                      _playSound('click');
                                      setState(() => _lang = l);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? const Color(0xFF3B82F6)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l.toUpperCase(),
                                        style: TextStyle(
                                          color: active
                                              ? Colors.white
                                              : Colors.white54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.power_settings_new,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(() {
                                  _showCurtain = true;
                                  _step = 1;
                                  _currentMission = null;
                                  _sidebarOpen = true; // reset to open state
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Main Content Area (Explore Tab)
                        _buildExploreTab(),
                      ],
                    ),
                  ),

                  // Footer at the end of the scrollable content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF020617),
                      border: Border(top: BorderSide(color: Color(0xFF334155))),
                    ),
                    child: const Text(
                      "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
                Expanded(
                  child: Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  "Step $_step/5",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_step == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Mission>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _currentMission ?? missions[0],
                    items: missions
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              "(${fMath(m.dividend)}) ÷ (${fMath(m.divisor)})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      _playSound('click');
                      setState(() => _currentMission = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.all(15),
                      ),
                      onPressed: () => _executeStep(2),
                      child: Text(
                        getT('btn_load'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              _buildLabControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.my_location, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getT('obj_title'),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      getT('obj_desc'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getT('lbl_progress'),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Step $_step/5",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _step / 5.0,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
        const SizedBox(height: 24),
        _buildLabControls(),
      ],
    );
  }

  Widget _buildLabControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_step == 1) _buildStep1Controls(),
          if (_step == 2) _buildStep2Controls(),
          if (_step == 3) _buildStep3Controls(),
          if (_step == 4) _buildStep4Controls(),
          if (_step == 5) _buildStep5Controls(),
        ],
      ),
    );
  }

  Widget _buildStep1Controls() {
    return Column(
      children: [
        Text(
          getT('lbl_select_mission'),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<Mission>(
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          value: _currentMission ?? missions[0],
          items: missions
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    "(${fMath(m.dividend)}) ÷ (${fMath(m.divisor)})",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            _playSound('click');
            setState(() => _currentMission = val);
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.all(15),
            ),
            onPressed: () => _executeStep(2),
            child: Text(
              getT('btn_load'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Controls() {
    return Column(
      children: [
        Text(
          getT('msg_step1'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "(${fMath(_currentMission!.dividend)}) ÷ (${fMath(_currentMission!.divisor)})",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildAnswerBtn(_currentOptions[0], 0)),
            const SizedBox(width: 10),
            Expanded(child: _buildAnswerBtn(_currentOptions[1], 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Controls() {
    return Column(
      children: [
        Text(
          getT('msg_step2'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "(${fMath(_currentMission!.divisor)}) × (${fMath(_currentMission!.q1)})",
            style: const TextStyle(
              color: Colors.yellowAccent,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildAnswerBtn(_currentOptions[0], 0)),
            const SizedBox(width: 10),
            Expanded(child: _buildAnswerBtn(_currentOptions[1], 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4Controls() {
    return Column(
      children: [
        Text(
          getT('msg_step3'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "(${fMath(_currentMission!.dividend)}) - (${fMath(_currentMission!.mult)})",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildAnswerBtn(_currentOptions[0], 0)),
            const SizedBox(width: 10),
            Expanded(child: _buildAnswerBtn(_currentOptions[1], 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerBtn(String text, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: () => _checkAnswer(index),
      child: Text(
        fMath(text),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildStep5Controls() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        const SizedBox(height: 15),
        Text(
          getT('msg_success'),
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            padding: const EdgeInsets.all(15),
          ),
          onPressed: () {
            _playSound('click');
            int nextId = (_currentMission!.id + 1) % missions.length;
            setState(() {
              _currentMission = missions[nextId];
            });
            _executeStep(1);
          },
          child: Text(
            getT('btn_next'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// --- PSEUDO-3D MAZE PAINTER ---

class MazePainter extends CustomPainter {
  final double runnerZ;
  final Color themeColor;

  MazePainter({required this.runnerZ, required this.themeColor});

  // Perspective Projection Logic mimicking Three.js PerspectiveCamera
  Offset project(double x, double y, double z, Size size) {
    double fov = 400; // Focal length scale
    double zCam = 20; // Camera Z position
    double yCam = 10; // Camera Y position

    double zDist = zCam - z;
    if (zDist < 0.1) zDist = 0.1; // Prevent division by zero

    double px = (x / zDist) * fov + size.width / 2;
    double py = -((y - yCam) / zDist) * fov + size.height / 2;
    return Offset(px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Grid
    Paint gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;
    for (double i = -30; i <= 30; i += 2) {
      canvas.drawLine(
        project(i, -0.5, -30, size),
        project(i, -0.5, 30, size),
        gridPaint,
      );
      canvas.drawLine(
        project(-30, -0.5, i, size),
        project(30, -0.5, i, size),
        gridPaint,
      );
    }

    // Prepare objects to be drawn in Z-order (Painters Algorithm)
    List<Map<String, dynamic>> drawQueue = [
      {'type': 'gate', 'z': -20.0, 'label': 'EXIT'},
      {'type': 'gate', 'z': -10.0, 'label': 'GATE 2'},
      {'type': 'gate', 'z': 0.0, 'label': 'GATE 1'},
      {'type': 'runner', 'z': runnerZ, 'label': ''},
    ];

    // Sort by Z ascending (smallest Z drawn first)
    drawQueue.sort((a, b) => a['z'].compareTo(b['z']));

    for (var obj in drawQueue) {
      if (obj['type'] == 'gate') {
        _drawGate(canvas, size, obj['z'], obj['label']);
      } else if (obj['type'] == 'runner') {
        _drawRunner(canvas, size, obj['z']);
      }
    }
  }

  void _drawGate(Canvas canvas, Size size, double gz, String label) {
    // Determine scale based on depth for stroke widths
    double depthScale = 400 / (20 - gz);
    if (depthScale < 0) depthScale = 0;

    // Pillars (Approximated 3D boxes as thick lines)
    Paint pillarPaint = Paint()
      ..color = themeColor
      ..strokeWidth = depthScale * 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      project(-4, -0.5, gz, size),
      project(-4, 6, gz, size),
      pillarPaint,
    );
    canvas.drawLine(
      project(4, -0.5, gz, size),
      project(4, 6, gz, size),
      pillarPaint,
    );

    // Energy Field
    Paint fieldPaint = Paint()
      ..color = themeColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    Path fieldPath = Path()
      ..moveTo(project(-4, -0.5, gz, size).dx, project(-4, -0.5, gz, size).dy)
      ..lineTo(project(-4, 6, gz, size).dx, project(-4, 6, gz, size).dy)
      ..lineTo(project(4, 6, gz, size).dx, project(4, 6, gz, size).dy)
      ..lineTo(project(4, -0.5, gz, size).dx, project(4, -0.5, gz, size).dy)
      ..close();
    canvas.drawPath(fieldPath, fieldPaint);

    // Gate Label Text
    Offset textPos = project(0, 7.5, gz, size);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: depthScale * 0.8,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black45,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        textPos.dx - textPainter.width / 2,
        textPos.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawRunner(Canvas canvas, Size size, double rz) {
    Offset center = project(0, 1, rz, size);
    double radius = 400 / (20 - rz); // Scale radius based on depth
    if (radius < 0) radius = 0;

    Paint runnerPaint = Paint()..color = const Color(0xFF8B5CF6); // Violet
    canvas.drawCircle(center, radius, runnerPaint);

    // Glow effect
    Paint glowPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 1.5, glowPaint);
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) {
    return runnerZ != oldDelegate.runnerZ ||
        themeColor != oldDelegate.themeColor;
  }
}
