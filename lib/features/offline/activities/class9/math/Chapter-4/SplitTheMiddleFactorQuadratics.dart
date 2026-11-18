// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers package

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Split the Middle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFEAB308), // Yellow 500
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
        fontFamily: 'Segoe UI',
      ),
      home: const SplitTheMiddleFactorQuadratics(),
    ),
  );
}

// --- LOCALIZATION ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'curtain_title': 'Split the Middle:\nFactor Quadratics',
    'curtain_subtitle': 'Class 9: Exploring Algebraic Identities',
    'btn_enter': 'Enter Lab',
    'header_title': 'Split the Middle: Factor Quadratics',
    'header_subtitle': 'Class 9 • Exploring Algebraic Identities',
    'hud_guide': 'Guide',
    'lbl_scenario': 'Scenario',
    'lbl_mission': 'Mission Objective',
    'lbl_steps': 'Procedural Steps',
    'btn_validate': 'Validate Model',
    'btn_restart': 'Restart Lab',
    'step_1': 'Observe the quadratic equation.',
    'step_2':
        'Select the pair that multiplies to the constant AND adds to the middle coefficient.',
    'step_3':
        'Drag the correct pair into the glowing target zone to factorise.',
    'hud_start': 'Observe the quadratic equation.',
    'hud_drag': 'Drag the pair to the target zone.',
    'msg_correct': 'Correct! You successfully split the middle term.',
    'msg_wrong':
        'Incorrect. The numbers must MULTIPLY to the constant AND ADD to the middle coefficient.',
    'msg_empty': 'Please drag a factor pair into the target zone first.',
    'mission_desc':
        'Factor x² + px + q by finding the pair (m, n) with m × n = q and m + n = p, splitting the middle term, then grouping into (x+m)(x+n).',
    'scenario_1': 'Scenario 1: x² + 7x + 12',
    'scenario_2': 'Scenario 2: x² + 11x + 30 (Trap)',
    'scenario_3': 'Scenario 3: x² - 5x + 6 (Negatives)',
  },
  'hi': {
    'curtain_title': 'मध्य पद को विभाजित करें:\nद्विघात गुणनखंड',
    'curtain_subtitle': 'कक्षा 9: बीजीय सर्वसमिकाओं की खोज',
    'btn_enter': 'लैब में प्रवेश करें',
    'header_title': 'मध्य पद को विभाजित करें: द्विघात गुणनखंड',
    'header_subtitle': 'कक्षा 9 • बीजीय सर्वसमिकाओं की खोज',
    'hud_guide': 'मार्गदर्शक',
    'lbl_scenario': 'परिदृश्य',
    'lbl_mission': 'मिशन का उद्देश्य',
    'lbl_steps': 'प्रक्रियात्मक चरण',
    'btn_validate': 'मॉडल सत्यापित करें',
    'btn_restart': 'लैब को फिर से शुरू करें',
    'step_1': 'द्विघात समीकरण का निरीक्षण करें।',
    'step_2':
        'उस युग्म का चयन करें जो स्थिरांक से गुणा होता है और मध्य गुणांक में जुड़ता है।',
    'step_3': 'गुणनखंड पूरा करने के लिए युग्म को लक्ष्य क्षेत्र में खींचें।',
    'hud_start': 'द्विघात समीकरण का निरीक्षण करें।',
    'hud_drag': 'युग्म को लक्ष्य क्षेत्र में खींचें।',
    'msg_correct': 'सही! आपने सफलतापूर्वक मध्य पद को विभाजित किया।',
    'msg_wrong':
        'गलत। संख्याओं को स्थिरांक से गुणा करना चाहिए और मध्य गुणांक में जोड़ना चाहिए।',
    'msg_empty': 'कृपया पहले लक्ष्य क्षेत्र में एक गुणनखंड युग्म खींचें।',
    'mission_desc':
        'x² + px + q का गुणनखंड करें (m, n) युग्म ज्ञात करके जहाँ m × n = q और m + n = p, मध्य पद को विभाजित करें, फिर (x+m)(x+n) में समूहीकृत करें।',
    'scenario_1': 'परिदृश्य 1: x² + 7x + 12',
    'scenario_2': 'परिदृश्य 2: x² + 11x + 30 (जाल)',
    'scenario_3': 'परिदृश्य 3: x² - 5x + 6 (नकारात्मक)',
  },
  'te': {
    'curtain_title': 'మధ్య పదాన్ని విభజించడం:\nవర్గ సమీకరణాల కారణాంకాలు',
    'curtain_subtitle': 'తరగతి 9: బీజీయ సర్వసమీకరణాల అన్వేషణ',
    'btn_enter': 'ల్యాబ్‌లోకి ప్రవేశించండి',
    'header_title': 'మధ్య పదాన్ని విభజించడం: వర్గ సమీకరణాల కారణాంకాలు',
    'header_subtitle': 'తరగతి 9 • బీజీయ సర్వసమీకరణాల అన్వేషణ',
    'hud_guide': 'మార్గదర్శి',
    'lbl_scenario': 'దృశ్యం',
    'lbl_mission': 'మిషన్ లక్ష్యం',
    'lbl_steps': 'ప్రక్రియాత్మక దశలు',
    'btn_validate': 'నమూనాను ధృవీకరించండి',
    'btn_restart': 'ల్యాబ్‌ని పునఃప్రారంభించండి',
    'step_1': 'వర్గ సమీకరణాన్ని గమనించండి.',
    'step_2':
        'స్థిరాంకంతో గుణించబడే మరియు మధ్య గుణకానికి జోడించబడే జతను ఎంచుకోండి.',
    'step_3': 'కారణాంకాలను పూర్తి చేయడానికి జతను లక్ష్య ప్రాంతానికి లాగండి.',
    'hud_start': 'వర్గ సమీకరణాన్ని గమనించండి.',
    'hud_drag': 'జతను లక్ష్య ప్రాంతానికి లాగండి.',
    'msg_correct': 'సరైనది! మీరు విజయవంతంగా మధ్య పదాన్ని విభజించారు.',
    'msg_wrong':
        'తప్పు. సంఖ్యలు స్థిరాంకంతో గుణించాలి మరియు మధ్య గుణకానికి జోడించాలి.',
    'msg_empty': 'దయచేసి ముందుగా లక్ష్య ప్రాంతంలోకి ఒక కారణాంక జతను లాగండి.',
    'mission_desc':
        'x² + px + q ని (m, n) జతను కనుగొనడం ద్వారా కారణాంకాలుగా విభజించండి m × n = q మరియు m + n = p, మధ్య పదాన్ని విభజించి, ఆపై (x+m)(x+n) గా సమూహపరచండి.',
    'scenario_1': 'దృశ్యం 1: x² + 7x + 12',
    'scenario_2': 'దృశ్యం 2: x² + 11x + 30 (ఉచ్చు)',
    'scenario_3': 'దృశ్యం 3: x² - 5x + 6 (ప్రతికూల)',
  },
};

// --- DATA MODELS ---
class ScenarioData {
  final String equation;
  final List<int> correctPair;
  final List<List<int>> options;
  final String solution;

  ScenarioData({
    required this.equation,
    required this.correctPair,
    required this.options,
    required this.solution,
  });
}

final List<ScenarioData> scenarios = [
  ScenarioData(
    equation: "x² + 7x + 12",
    correctPair: [3, 4],
    options: [
      [1, 12],
      [2, 6],
      [3, 4],
    ],
    solution: "(x+3)(x+4)",
  ),
  ScenarioData(
    equation: "x² + 11x + 30",
    correctPair: [5, 6],
    options: [
      [2, 15],
      [3, 10],
      [5, 6],
    ],
    solution: "(x+5)(x+6)",
  ),
  ScenarioData(
    equation: "x² - 5x + 6",
    correctPair: [-2, -3],
    options: [
      [2, 3],
      [-1, -6],
      [-2, -3],
    ],
    solution: "(x-2)(x-3)",
  ),
];

class Stone {
  Offset position;
  final Offset originalPosition;
  final List<int> pair;
  final bool isCorrect;
  bool inZone = false;
  Color color = const Color(0xFF3B82F6); // Blue 500
  double phaseOffset;

  Stone({
    required this.position,
    required this.originalPosition,
    required this.pair,
    required this.isCorrect,
    required this.phaseOffset,
  });
}

// --- MAIN WIDGET ---
class SplitTheMiddleFactorQuadratics extends StatefulWidget {
  const SplitTheMiddleFactorQuadratics({super.key});

  @override
  State<SplitTheMiddleFactorQuadratics> createState() =>
      _SplitTheMiddleFactorQuadraticsState();
}

class _SplitTheMiddleFactorQuadraticsState
    extends State<SplitTheMiddleFactorQuadratics>
    with TickerProviderStateMixin {
  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // UI State
  bool _showCurtain = true;
  String _currentLang = 'en';
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0; // Updated sidebar width to 350
  bool _isDraggingSidebar = false;

  // Game State
  int _currentScenarioIndex = 0;
  int _currentStep = 1;
  String _hudMessage = '';
  Color _hudColor = Colors.transparent;
  Color _hudBorderColor = Colors.white24;
  Color _hudTextColor = Colors.white;
  bool _isCompletedAll = false;

  // Canvas / Engine State
  final GlobalKey _canvasKey = GlobalKey();
  Offset _cameraOffset = Offset.zero;
  double _cameraScale = 1.0;

  final List<Stone> _stones = [];
  final Offset _dropZonePos = const Offset(0, 50);
  final double _dropZoneRadius = 100.0;

  Stone? _draggedStone;
  late AnimationController _gameLoopController;

  // --- AUDIO METHODS ---
  Future<void> playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(
        AssetSource(
          'audio/class9/tap.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> playPageOpen() async {
    try {
      await _pagePlayer.stop();
      await _pagePlayer.play(
        AssetSource(
          'audio/class9/page_open.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> playDropdown() async {
    try {
      await _dropdownPlayer.stop();
      await _dropdownPlayer.play(
        AssetSource(
          'audio/class9/dropdown.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> playError() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(
        AssetSource(
          'audio/class9/error_tone.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> curtainScreen() async {
    try {
      await _pagePlayer.stop();
      await _pagePlayer.play(
        AssetSource(
          'audio/class9/shutter.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Enforce orientation and immersive mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _hudMessage = i18n[_currentLang]!['hud_start']!;

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _loadScenario(0);
    curtainScreen(); // Trigger curtain entry tone
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    // Revert settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _enterLab() {
    playPageOpen();
    setState(() {
      _showCurtain = false;
    });
  }

  void _setLanguage(String lang) {
    playClick();
    setState(() {
      _currentLang = lang;
      if (_currentStep == 1) {
        _hudMessage = i18n[_currentLang]!['hud_start']!;
      } else {
        _hudMessage = i18n[_currentLang]!['hud_drag']!;
      }
    });
  }

  void _loadScenario(int index) {
    playDropdown();
    setState(() {
      _currentScenarioIndex = index;
      _isCompletedAll = false;
      _currentStep = 1;
      _hudMessage = i18n[_currentLang]!['hud_start']!;
      _hudColor = Colors.transparent;
      _hudBorderColor = Colors.white24;
      _hudTextColor = Colors.white;

      _cameraOffset = Offset.zero;
      _cameraScale = 1.0;

      final data = scenarios[_currentScenarioIndex];
      _stones.clear();

      final List<Offset> startPositions = [
        const Offset(-250, -150),
        const Offset(0, -200),
        const Offset(250, -150),
      ];

      for (int i = 0; i < data.options.length; i++) {
        final pair = data.options[i];
        final isCorrect =
            (pair[0] == data.correctPair[0] &&
                pair[1] == data.correctPair[1]) ||
            (pair[0] == data.correctPair[1] && pair[1] == data.correctPair[0]);
        _stones.add(
          Stone(
            position: startPositions[i],
            originalPosition: startPositions[i],
            pair: pair,
            isCorrect: isCorrect,
            phaseOffset: i * (math.pi / 1.5),
          ),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _currentStep == 1) {
        setState(() {
          _currentStep = 2;
        });
      }
    });
  }

  void _updateHUD(String msg, {bool isError = false, bool isSuccess = false}) {
    setState(() {
      _hudMessage = msg;
      if (isError) {
        _hudColor = const Color(0xCC7F1D1D); // Red-900 transparent
        _hudBorderColor = const Color(0xFFEF4444); // Red-500
        _hudTextColor = Colors.white;
      } else if (isSuccess) {
        _hudColor = const Color(0xCC14532D); // Green-900 transparent
        _hudBorderColor = const Color(0xFF22C55E); // Green-500
        _hudTextColor = Colors.white;
      } else {
        _hudColor = Colors.transparent;
        _hudBorderColor = Colors.white24;
        _hudTextColor = Colors.white;
      }
    });
  }

  void _validate() {
    Stone? inZoneStone;
    for (var s in _stones) {
      if (s.inZone) {
        inZoneStone = s;
        break;
      }
    }

    if (inZoneStone == null) {
      playError();
      _updateHUD(i18n[_currentLang]!['msg_empty']!, isError: true);
      return;
    }

    if (inZoneStone.isCorrect) {
      playPageOpen();
      _updateHUD(i18n[_currentLang]!['msg_correct']!, isSuccess: true);
      setState(() {
        inZoneStone!.color = const Color(0xFF22C55E); // Green
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        if (_currentScenarioIndex < scenarios.length - 1) {
          _loadScenario(_currentScenarioIndex + 1);
        } else {
          setState(() {
            _isCompletedAll = true;
            _updateHUD(
              "Excellent! You've completed all scenarios.",
              isSuccess: true,
            );
          });
        }
      });
    } else {
      playError();
      _updateHUD(i18n[_currentLang]!['msg_wrong']!, isError: true);
      setState(() {
        inZoneStone!.color = const Color(0xFFEF4444); // Red
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          inZoneStone!.color = const Color(0xFF3B82F6); // Blue
        });
      });
    }
  }

  // --- GESTURE HANDLING ---
  Offset _screenToWorld(Offset screenPos, Size canvasSize) {
    // Canvas center is 0,0 in world space
    final centerOffset = Offset(canvasSize.width / 2, canvasSize.height / 2);
    return (screenPos - centerOffset - _cameraOffset) / _cameraScale;
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_canvasKey.currentContext == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.focalPoint);
    final worldPos = _screenToWorld(localPos, renderBox.size);

    _draggedStone = null;

    // Hit test backwards (top-most first)
    for (int i = _stones.length - 1; i >= 0; i--) {
      final stone = _stones[i];
      // Stone radius approx 60 units in world space
      if ((worldPos - stone.position).distance <= 60) {
        _draggedStone = stone;
        stone.inZone = false; // detach
        playClick(); // Sound effect on dragging stone
        if (_currentStep == 2) {
          setState(() {
            _currentStep = 3;
            _hudMessage = i18n[_currentLang]!['hud_drag']!;
          });
        }
        break;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_canvasKey.currentContext == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;

    if (_draggedStone != null) {
      // Dragging a stone
      final localPos = renderBox.globalToLocal(details.focalPoint);
      setState(() {
        _draggedStone!.position = _screenToWorld(localPos, renderBox.size);
      });
    } else {
      // Panning / Zooming
      setState(() {
        _cameraOffset += details.focalPointDelta;
        _cameraScale = (_cameraScale * details.scale).clamp(0.5, 3.0);
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggedStone != null) {
      // Check drop zone proximity
      if ((_draggedStone!.position - _dropZonePos).distance < _dropZoneRadius) {
        setState(() {
          playClick(); // Snap sound
          _draggedStone!.position = _dropZonePos;
          _draggedStone!.inZone = true;
          // Scatters other stones in zone
          for (var s in _stones) {
            if (s != _draggedStone && s.inZone) {
              s.position = s.originalPosition;
              s.inZone = false;
            }
          }
        });
      }
      _draggedStone = null;
    }
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCurtain() {
    return AnimatedOpacity(
      opacity: _showCurtain ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: _showCurtain
          ? Container(
              color: const Color(0xFF020617), // Slate 950
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAB308),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calculate,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                      Text(
                        i18n[_currentLang]!['curtain_title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEAB308),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        i18n[_currentLang]!['curtain_subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: _enterLab,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: const Color(0xFFEAB308).withOpacity(0.5),
                        ),
                        child: Text(
                          i18n[_currentLang]!['btn_enter']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // Slate 800
        border: Border(right: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 64,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calculate, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n[_currentLang]!['header_title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          i18n[_currentLang]!['header_subtitle']!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEAB308),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Lang Toggle & Reset below subtitle
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _langButton('en', 'EN'),
                                  _langButton('hi', 'HI'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                playClick();
                                curtainScreen();
                                setState(() {
                                  _showCurtain = true;
                                  _isSidebarOpen =
                                      true; // Optional: ensure sidebar opens on reset
                                });
                                _loadScenario(0);
                              },
                              tooltip: 'Reset',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Content inner body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n[_currentLang]!['lbl_scenario']!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _currentScenarioIndex,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF0F172A),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ), // Fixed Dropdown Text Visibility
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white54,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(i18n[_currentLang]!['scenario_1']!),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(i18n[_currentLang]!['scenario_2']!),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(i18n[_currentLang]!['scenario_3']!),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _loadScenario(val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mission Objective
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Color(0xFFEAB308),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              i18n[_currentLang]!['lbl_mission']!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEAB308),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          i18n[_currentLang]!['mission_desc']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Steps
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_list_numbered,
                              color: Color(0xFFEAB308),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              i18n[_currentLang]!['lbl_steps']!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEAB308),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStep(1, i18n[_currentLang]!['step_1']!),
                        _buildStep(2, i18n[_currentLang]!['step_2']!),
                        _buildStep(3, i18n[_currentLang]!['step_3']!),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Validate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCompletedAll
                          ? () {
                              playClick();
                              curtainScreen();
                              setState(() {
                                _showCurtain = true;
                                _isSidebarOpen = true;
                              });
                              _loadScenario(0);
                            }
                          : _validate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompletedAll
                            ? Colors.blue
                            : const Color(0xFFEAB308),
                        foregroundColor: _isCompletedAll
                            ? Colors.white
                            : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      icon: Icon(
                        _isCompletedAll ? Icons.refresh : Icons.check_circle,
                        size: 24,
                      ),
                      label: Text(
                        _isCompletedAll
                            ? i18n[_currentLang]!['btn_restart']!
                            : i18n[_currentLang]!['btn_validate']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ), // Added padding to avoid collision with footer
                ],
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
                color: Colors.black12,
              ),
              child: const Text(
                '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langButton(String langCode, String label) {
    bool isActive = _currentLang == langCode;
    return GestureDetector(
      onTap: () => _setLanguage(langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEAB308) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int stepNum, String text) {
    bool isCompleted = _currentStep > stepNum;
    bool isActive = _currentStep == stepNum;

    Color circleColor = isCompleted
        ? const Color(0xFF22C55E)
        : isActive
        ? const Color(0xFFEAB308)
        : Colors.white12;
    Color textColor = isCompleted || isActive ? Colors.black : Colors.white;
    double opacity = (isActive || isCompleted) ? 1.0 : 0.4;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: isCompleted || isActive
                    ? null
                    : Border.all(color: Colors.white24),
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : Text(
                      stepNum.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed the root GestureDetector(onTap: ...) that previously captured taps and delayed the dragging event.
    return Scaffold(
      body: Stack(
        children: [
          // --- CANVAS AREA ---
          AnimatedPositioned(
            duration: _isDraggingSidebar
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? _sidebarWidth : 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF0F172A), // Slate 900
              child: Stack(
                children: [
                  // Grid and Simulation Canvas
                  Positioned.fill(
                    child: GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: AnimatedBuilder(
                        animation: _gameLoopController,
                        builder: (context, child) {
                          return CustomPaint(
                            key: _canvasKey,
                            painter: LabPainter(
                              stones: _stones,
                              cameraOffset: _cameraOffset,
                              cameraScale: _cameraScale,
                              time:
                                  _gameLoopController.value *
                                  math.pi *
                                  2 *
                                  5, // 5 loops
                              dropZonePos: _dropZonePos,
                              dropZoneRadius: _dropZoneRadius,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Equation Overlay
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 20),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            scenarios[_currentScenarioIndex].equation,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          if (_isCompletedAll ||
                              (_stones.any(
                                (s) =>
                                    s.inZone &&
                                    s.isCorrect &&
                                    s.color.toARGB32() == 0xFF22C55E,
                              )))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                scenarios[_currentScenarioIndex].solution,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // HUD Overlay
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 32,
                        left: 16,
                        right: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _hudColor == Colors.transparent
                            ? Colors.black54
                            : _hudColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _hudBorderColor),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 20),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _hudColor == Colors.transparent
                                ? Icons.info_outline
                                : (_hudColor.toARGB32() == 0xCC14532D
                                      ? Icons.check_circle
                                      : Icons.error_outline),
                            color: _hudColor == Colors.transparent
                                ? const Color(0xFFEAB308)
                                : _hudBorderColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _hudMessage,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _hudTextColor,
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
          ),

          // --- SIDEBAR ---
          AnimatedPositioned(
            duration: _isDraggingSidebar
                ? Duration.zero
                : const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -_sidebarWidth,
            top: 0,
            bottom: 0,
            width: _sidebarWidth,
            child: _buildSidebar(),
          ),

          // --- SIDEBAR RESIZER (Drag Handle) ---
          if (_isSidebarOpen)
            AnimatedPositioned(
              duration: _isDraggingSidebar
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              left: _sidebarWidth - 10,
              top: 0,
              bottom: 0,
              width: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() {
                      _isDraggingSidebar = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _sidebarWidth += details.delta.dx;
                      if (_sidebarWidth < 300) _sidebarWidth = 300;
                      if (_sidebarWidth >
                          MediaQuery.of(context).size.width * 0.6) {
                        _sidebarWidth = MediaQuery.of(context).size.width * 0.6;
                      }
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _isDraggingSidebar = false;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // --- MENU TOGGLE BUTTON ---
          Positioned(
            top: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  playClick();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // --- CURTAIN SCREEN ---
          if (_showCurtain) _buildCurtain(),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class LabPainter extends CustomPainter {
  final List<Stone> stones;
  final Offset cameraOffset;
  final double cameraScale;
  final double time;
  final Offset dropZonePos;
  final double dropZoneRadius;

  LabPainter({
    required this.stones,
    required this.cameraOffset,
    required this.cameraScale,
    required this.time,
    required this.dropZonePos,
    required this.dropZoneRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerOffset = Offset(size.width / 2, size.height / 2);

    // Draw Grid Background
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double gridSize = 40.0 * cameraScale;
    final double startX = (cameraOffset.dx % gridSize) - gridSize;
    final double startY = (cameraOffset.dy % gridSize) - gridSize;

    for (double x = startX; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = startY; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Transform to World Space for entities
    canvas.save();
    canvas.translate(
      centerOffset.dx + cameraOffset.dx,
      centerOffset.dy + cameraOffset.dy,
    );
    canvas.scale(cameraScale);

    // Draw Drop Zone
    final Paint ringPaint = Paint()
      ..color = stones.any((s) => s.inZone)
          ? const Color(0xFFEAB308).withOpacity(0.8)
          : Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Paint glowPaint = Paint()
      ..color = stones.any((s) => s.inZone)
          ? const Color(0xFFEAB308).withOpacity(0.2)
          : Colors.transparent
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(dropZonePos, dropZoneRadius, glowPaint);
    canvas.drawCircle(dropZonePos, dropZoneRadius, ringPaint);

    // Draw Stones
    for (var stone in stones) {
      // Calculate Bobbing effect
      double bobY = stone.inZone
          ? 0
          : math.sin(time + stone.phaseOffset) * 10.0;
      Offset renderPos = Offset(stone.position.dx, stone.position.dy + bobY);

      // Shadow
      final Paint shadowPaint = Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(stone.position.dx, stone.position.dy + 30),
            width: 130,
            height: 70,
          ),
          const Radius.circular(35),
        ),
        shadowPaint,
      );

      // Stone Body
      final Paint stonePaint = Paint()
        ..color = stone.color
        ..style = PaintingStyle.fill;

      final Paint stoneBorder = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final RRect stoneRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: renderPos, width: 140, height: 80),
        const Radius.circular(40),
      );

      canvas.drawRRect(stoneRect, stonePaint);
      canvas.drawRRect(stoneRect, stoneBorder);

      // Highlight/Glass effect on stone
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      final Path highlightPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(renderPos.dx, renderPos.dy - 20),
              width: 120,
              height: 35,
            ),
            const Radius.circular(20),
          ),
        );
      canvas.drawPath(highlightPath, highlightPaint);

      // Text
      final String textStr = "(${stone.pair[0]}, ${stone.pair[1]})";
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: textStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          renderPos.dx - textPainter.width / 2,
          renderPos.dy - textPainter.height / 2,
        ),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) {
    return true; // Repaint continuously for animation
  }
}
