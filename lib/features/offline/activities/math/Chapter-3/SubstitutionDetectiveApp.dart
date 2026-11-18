// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- DATA MODELS ---

class CaseData {
  final String id;
  final String clue1;
  final String clue2;
  final List<String> eq1Pool;
  final List<String> eq1Target;
  final List<String> eq2Pool;
  final List<String> eq2Target;
  final String isolation;
  final String isoTerm;
  final String isoRes;
  final double m1;
  final double c1;
  final double m2;
  final double c2;
  final double solX;
  final double solY;
  final List<String> labels;

  CaseData({
    required this.id,
    required this.clue1,
    required this.clue2,
    required this.eq1Pool,
    required this.eq1Target,
    required this.eq2Pool,
    required this.eq2Target,
    required this.isolation,
    required this.isoTerm,
    required this.isoRes,
    required this.m1,
    required this.c1,
    required this.m2,
    required this.c2,
    required this.solX,
    required this.solY,
    required this.labels,
  });
}

final List<CaseData> cases = [
  CaseData(
    id: "age",
    clue1: "7 years ago, x was 7 times (y-7).",
    clue2: "3 years later, x will be 3 times (y+3).",
    eq1Pool: ["(x-7)", "(y-7)", "7"],
    eq1Target: ["(x-7)", "=", "7", "×", "(y-7)"],
    eq2Pool: ["(x+3)", "(y+3)", "3"],
    eq2Target: ["(x+3)", "=", "3", "×", "(y+3)"],
    isolation: "x - 3y = 6",
    isoTerm: "- 3y",
    isoRes: "x = 6 + 3y",
    m1: 7,
    c1: -42,
    m2: 3,
    c2: 6,
    solX: 42,
    solY: 12,
    labels: ["Aftab Age", "Daughter Age"],
  ),
  CaseData(
    id: "rectangle",
    clue1: "Length (x) is width (y) plus 4.",
    clue2: "x plus y is 10.",
    eq1Pool: ["x", "y", "4"],
    eq1Target: ["x", "=", "y", "+", "4"],
    eq2Pool: ["x", "y", "10"],
    eq2Target: ["x", "+", "y", "=", "10"],
    isolation: "x = y + 4",
    isoTerm: "0",
    isoRes: "x = 4 + y",
    m1: 1,
    c1: 4,
    m2: -1,
    c2: 10,
    solX: 7,
    solY: 3,
    labels: ["Length", "Width"],
  ),
];

// --- LOCALIZATION ---

const Map<String, Map<String, String>> i18n = {
  "en": {
    "app_title": "THE SUBSTITUTION DETECTIVE",
    "tagline": "ALGEBRAIC DECRYPTION UNIT",
    "init_btn": "ACCESS TERMINAL",
    "header_title": "The Substitution Detective",
    "header_subtitle": "CLASS 10 • ALGEBRAIC METHODS",
    "nav_context": "Why to Learn?",
    "nav_lab": "Explore",
    "nav_report": "Outcomes",
    "hud_status": "Status",
    "btn_next": "Continue",
    "msg_step1_desc":
        "Tap the terms below and place them in the correct boxes to build the 1st equation.",
    "msg_step2_desc":
        "Tap the terms below and place them in the correct boxes to build the 2nd equation.",
    "msg_step3_desc":
        "Tap the highlighted term to isolate the variable 'x' on one side.",
    "active_mission": "ACTIVE MISSION",
    "mission_title": "MISSION OBJECTIVE",
    "step_prefix": "Step",
    "evidence_1": "Evidence 1",
    "evidence_2": "Evidence 2",
    "isolation_chamber": "ISOLATION CHAMBER",
    "already_isolated": "Variable x is already isolated in:\n",
    "isolate_x": "Isolate x in: ",
    "btn_verify": "VERIFY",
    "btn_cont_sub": "Continue to Substitution",
    "final_result": "FINAL RESULT",
    "btn_new_case": "Open New Case",
    "case_solved": "CASE SOLVED!",
    "age_clue1": "7 years ago, x was 7 times (y-7).",
    "age_clue2": "3 years later, x will be 3 times (y+3).",
    "age_l1": "Aftab Age",
    "age_l2": "Daughter Age",
    "rectangle_clue1": "Length (x) is width (y) plus 4.",
    "rectangle_clue2": "x plus y is 10.",
    "rectangle_l1": "Length",
    "rectangle_l2": "Width",
  },
  "hi": {
    "app_title": "प्रतिस्थापन जासूस",
    "tagline": "बीजगणितीय डिक्रिप्शन",
    "init_btn": "टर्मिनल एक्सेस करें",
    "header_title": "प्रतिस्थापन जासूस",
    "header_subtitle": "कक्षा 10 • बीजगणितीय विधियाँ",
    "nav_context": "क्यों सीखें?",
    "nav_lab": "अन्वेषण",
    "nav_report": "निष्कर्ष",
    "hud_status": "स्थिति",
    "btn_next": "आगे बढ़ें",
    "msg_step1_desc":
        "पहला समीकरण बनाने के लिए नीचे दिए गए पदों पर टैप करें और उन्हें सही बॉक्स में रखें।",
    "msg_step2_desc":
        "दूसरा समीकरण बनाने के लिए नीचे दिए गए पदों पर टैप करें और उन्हें सही बॉक्स में रखें।",
    "msg_step3_desc":
        "चर 'x' को एक तरफ अलग करने के लिए हाइलाइट किए गए पद पर टैप करें।",
    "active_mission": "सक्रिय मिशन",
    "mission_title": "मिशन उद्देश्य",
    "step_prefix": "चरण",
    "evidence_1": "साक्ष्य 1",
    "evidence_2": "साक्ष्य 2",
    "isolation_chamber": "पृथक्करण कक्ष",
    "already_isolated": "चर x पहले से ही अलग है:\n",
    "isolate_x": "x को अलग करें: ",
    "btn_verify": "सत्यापित करें",
    "btn_cont_sub": "प्रतिस्थापन के लिए आगे बढ़ें",
    "final_result": "अंतिम परिणाम",
    "btn_new_case": "नया केस खोलें",
    "case_solved": "केस हल हो गया!",
    "age_clue1": "7 साल पहले, x (y-7) का 7 गुना था।",
    "age_clue2": "3 साल बाद, x (y+3) का 3 गुना होगा।",
    "age_l1": "आफताब की आयु",
    "age_l2": "बेटी की आयु",
    "rectangle_clue1": "लंबाई (x) चौड़ाई (y) से 4 अधिक है।",
    "rectangle_clue2": "x और y का योग 10 है।",
    "rectangle_l1": "लंबाई",
    "rectangle_l2": "चौड़ाई",
  },
};

// --- APP ROOT ---

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SubstitutionDetectiveApp(),
    ),
  );
}

// --- STATE MANAGEMENT & MAIN SCREEN ---

class SubstitutionDetectiveApp extends StatefulWidget {
  const SubstitutionDetectiveApp({super.key});

  @override
  State<SubstitutionDetectiveApp> createState() =>
      _SubstitutionDetectiveAppState();
}

class _SubstitutionDetectiveAppState extends State<SubstitutionDetectiveApp>
    with TickerProviderStateMixin {
  bool _showCurtain = true;
  String _lang = 'en';
  bool _isMenuOpen = true;

  CaseData? _currentCase;
  int _step = 1;

  // Interactive Puzzle State
  String? _selectedTerm;
  List<String?> _eq1Filled = [];
  List<String?> _eq2Filled = [];
  bool _isolationAnimated = false;

  // Animations
  late AnimationController _graphAnimController;
  late AnimationController _panAnimController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;

  // Scroll Controller
  final ScrollController _hudScrollController = ScrollController();

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();
    _currentCase = cases[Random().nextInt(cases.length)];
    _initPuzzleState();

    _graphAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _panAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _graphAnimController.addListener(() => setState(() {}));
    _panAnimController.addListener(() => setState(() {}));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initPuzzleState() {
    if (_currentCase != null) {
      _eq1Filled = List.filled(
        _currentCase!.eq1Target.where((e) => !_isOperator(e)).length,
        null,
      );
      _eq2Filled = List.filled(
        _currentCase!.eq2Target.where((e) => !_isOperator(e)).length,
        null,
      );
    }
    _isolationAnimated = false;
    _selectedTerm = null;
  }

  @override
  void dispose() {
    _graphAnimController.dispose();
    _panAnimController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _hudScrollController.dispose();

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

  String getT(String key) => i18n[_lang]?[key] ?? i18n['en']![key] ?? key;

  bool _isOperator(String s) => ["=", "+", "-", "×"].contains(s);

  void _handleTermSelect(String term) {
    _playSound('click');
    setState(() {
      if (_selectedTerm == term) {
        _selectedTerm = null;
      } else {
        _selectedTerm = term;
      }
    });
  }

  void _handleSlotTap(int index, bool isEq1, String expected) {
    if (_selectedTerm == null) return;

    if (_selectedTerm == expected) {
      _playSound('success');
      setState(() {
        if (isEq1) {
          _eq1Filled[index] = _selectedTerm;
        } else {
          _eq2Filled[index] = _selectedTerm;
        }
        _selectedTerm = null;
      });
      _checkStepCompletion(isEq1);
    } else {
      _playSound('error');
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
      setState(() {
        _selectedTerm = null;
      });
    }
  }

  void _checkStepCompletion(bool isEq1) {
    if (isEq1 && !_eq1Filled.contains(null) && _step == 1) {
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() => _step = 2),
      );
    } else if (!isEq1 && !_eq2Filled.contains(null) && _step == 2) {
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() => _step = 3),
      );
    }
  }

  void _runIsolationAnimation() {
    if (_currentCase?.isoTerm == "0") {
      _playSound('success');
      setState(() => _isolationAnimated = true);
      return;
    }

    _playSound('click');
    setState(() {
      _isolationAnimated = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _playSound('success');
    });
  }

  void _showFinalResult() {
    _playSound('success');
    setState(() {
      _step = 4;
      _graphAnimController.forward(from: 0);
      _panAnimController.forward(from: 0);
    });
    _celebrationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _celebrationController.reverse();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double panelWidth = screenWidth * 0.4;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // Core Layout: 40% Panel / 60% Canvas
            Positioned.fill(
              child: Row(
                children: [
                  // LEFT PANEL (Animated)
                  if (!_showCurtain)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _isMenuOpen ? panelWidth : 0,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.centerLeft,
                          minWidth: panelWidth,
                          maxWidth: panelWidth,
                          child: _buildSidePanel(),
                        ),
                      ),
                    ),

                  // RIGHT CANVAS (60% or 100% if curtain is up)
                  Expanded(
                    child: ClipRect(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF0F172A),
                              Color(0xFF020617),
                              Colors.black,
                            ],
                            radius: 1.5,
                          ),
                        ),
                        child: InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(2000.0),
                          minScale: 0.1,
                          maxScale: 5.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: DetectiveGraphPainter(
                              caseData: _currentCase,
                              progress: _graphAnimController.value,
                              panProgress: _panAnimController.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Mission Card (Visible when sidebar is collapsed)
            if (!_isMenuOpen && !_showCurtain)
              Positioned(top: 80, left: 20, child: _buildFloatingMissionCard()),

            // Bottom-Left Floating Menu Button
            if (!_showCurtain)
              Positioned(
                top: 24,
                left: 24,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 8,
                  onPressed: () {
                    _playSound('click');
                    setState(() => _isMenuOpen = !_isMenuOpen);
                  },
                  child: Icon(
                    _isMenuOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),

            // Celebration Overlay
            IgnorePointer(
              ignoring: true,
              child: FadeTransition(
                opacity: _celebrationController,
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: Text(
                    getT('case_solved'),
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      shadows: [Shadow(color: Colors.green, blurRadius: 20)],
                    ),
                  ),
                ),
              ),
            ),

            // Initial Curtain
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.privacy_tip,
                        size: 80,
                        color: Color(0xFF60A5FA),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        getT('app_title'),
                        style: const TextStyle(
                          fontSize: 45,
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
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          _playSound('shutter');
                          setState(() => _showCurtain = false);
                        },
                        icon: const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                        ),
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

  // --- UI BUILDERS ---

  Widget _buildSidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // Header Section
                            Container(
                              padding: const EdgeInsets.only(
                                top: 80,
                                left: 16,
                                right: 16,
                                bottom: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getT('header_title'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              getT('header_subtitle'),
                                              style: const TextStyle(
                                                color: Color(0xFF93C5FD),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                letterSpacing: 1.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildLangToggles(),
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
                                            _initPuzzleState();
                                            _graphAnimController.reset();
                                            _panAnimController.reset();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Content Section
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 20,
                                bottom: 50,
                              ),
                              child: _buildExploreTab(),
                            ),
                          ],
                        ),
                      ),

                      // Footer Section pinned to the bottom of the sidebar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF020617),
                          border: Border(
                            top: BorderSide(color: Color(0xFF334155)),
                          ),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildLangToggles() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['en', 'hi'].map((l) {
          bool isActive = _lang == l;
          return InkWell(
            onTap: () {
              _playSound('click');
              setState(() => _lang = l);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.toUpperCase(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // FLOATING MISSION CARD (Active only when sidebar is closed)
  Widget _buildFloatingMissionCard() {
    if (_currentCase == null) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 90,
        maxWidth: 300, // Adjusted width for scrollbar comfort
      ),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(sin(_shakeController.value * pi * 4) * 8, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.85),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 15),
                    ],
                  ),
                  child: Scrollbar(
                    controller: _hudScrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    thickness: 6,
                    child: SingleChildScrollView(
                      controller: _hudScrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.gps_fixed,
                                    color: Colors.blueAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    getT('active_mission'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${getT('step_prefix')} $_step/4",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _step / 4.0,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Displaying only the current step to save space
                          if (_step == 1)
                            _buildEvidenceStep(
                              1,
                              getT('evidence_1'),
                              getT('${_currentCase!.id}_clue1'),
                              _currentCase!.eq1Pool,
                              _currentCase!.eq1Target,
                              _eq1Filled,
                            ),
                          if (_step == 2)
                            _buildEvidenceStep(
                              2,
                              getT('evidence_2'),
                              getT('${_currentCase!.id}_clue2'),
                              _currentCase!.eq2Pool,
                              _currentCase!.eq2Target,
                              _eq2Filled,
                            ),
                          if (_step == 3) _buildIsolationStep(),
                          if (_step >= 4) _buildFinalStep(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreTab() {
    if (_currentCase == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeController.value * pi * 4) * 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment,
                        color: Colors.blueAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getT('mission_title'),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${getT('step_prefix')} $_step/4",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _step / 4.0,
                backgroundColor: Colors.white10,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 24),
              if (_step >= 1)
                _buildEvidenceStep(
                  1,
                  getT('evidence_1'),
                  getT('${_currentCase!.id}_clue1'),
                  _currentCase!.eq1Pool,
                  _currentCase!.eq1Target,
                  _eq1Filled,
                ),
              if (_step >= 2)
                _buildEvidenceStep(
                  2,
                  getT('evidence_2'),
                  getT('${_currentCase!.id}_clue2'),
                  _currentCase!.eq2Pool,
                  _currentCase!.eq2Target,
                  _eq2Filled,
                ),
              if (_step >= 3) _buildIsolationStep(),
              if (_step >= 4) _buildFinalStep(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvidenceStep(
    int stepNum,
    String title,
    String clue,
    List<String> pool,
    List<String> target,
    List<String?> filledList,
  ) {
    bool isComplete = _step > stepNum;

    return Opacity(
      opacity: isComplete ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '"$clue"',
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // User step instruction
            Text(
              stepNum == 1 ? getT('msg_step1_desc') : getT('msg_step2_desc'),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            if (!isComplete) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: pool.map((term) => _buildPoolTerm(term)).toList(),
              ),
              const SizedBox(height: 20),
            ],
            Wrap(
              spacing: 5,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _buildTargetSlots(target, filledList, stepNum == 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolTerm(String term) {
    bool isSelected = _selectedTerm == term;
    return GestureDetector(
      onTap: () => _handleTermSelect(term),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.blue, blurRadius: 10)]
              : null,
        ),
        child: Text(
          term,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTargetSlots(
    List<String> targetTemplate,
    List<String?> filledList,
    bool isEq1,
  ) {
    List<Widget> widgets = [];
    int slotIndex = 0;

    for (String item in targetTemplate) {
      if (_isOperator(item)) {
        widgets.add(
          Text(
            item,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        int currentIndex = slotIndex;
        bool isFilled = filledList[currentIndex] != null;
        bool isTargetActive = _selectedTerm != null && !isFilled;

        widgets.add(
          GestureDetector(
            onTap: () {
              if (!isFilled) _handleSlotTap(currentIndex, isEq1, item);
            },
            child: Container(
              width: 60,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFilled
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : (isTargetActive
                          ? Colors.purple.withOpacity(0.4)
                          : Colors.black26),
                border: Border.all(
                  color: isFilled
                      ? const Color(0xFF10B981)
                      : (isTargetActive ? Colors.purpleAccent : Colors.white30),
                  width: isTargetActive || isFilled ? 2 : 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isFilled ? filledList[currentIndex]! : "?",
                style: TextStyle(
                  color: isFilled ? Colors.white : Colors.white54,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
        slotIndex++;
      }
    }
    return widgets;
  }

  Widget _buildIsolationStep() {
    bool isComplete = _step > 3;

    return Opacity(
      opacity: isComplete ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              getT('isolation_chamber'),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _currentCase!.isoTerm == "0"
                  ? "${getT('already_isolated')}${_currentCase!.isolation}"
                  : "${getT('isolate_x')}${_currentCase!.isolation}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 5),
            // User step instruction
            Text(
              getT('msg_step3_desc'),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _isolationAnimated ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "x ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isolationAnimated && _currentCase!.isoTerm != "0")
                          GestureDetector(
                            onTap: _runIsolationAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                border: Border.all(color: Colors.redAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _currentCase!.isoTerm,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        const Text(
                          " = ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isolationAnimated && _currentCase!.isoTerm == "0")
                          GestureDetector(
                            onTap: _runIsolationAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2),
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                getT('btn_verify'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          )
                        else if (!_isolationAnimated)
                          const Text(
                            "...",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 24,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_isolationAnimated)
                    AnimatedOpacity(
                      opacity: _isolationAnimated ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _currentCase!.isoRes,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 24,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_isolationAnimated && !isComplete)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: _showFinalResult,
                child: Text(
                  getT('btn_cont_sub'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalStep() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            getT('final_result'),
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        getT('${_currentCase!.id}_l1'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _currentCase!.solX.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: Colors.pinkAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        getT('${_currentCase!.id}_l2'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _currentCase!.solY.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade700,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              _playSound('click');
              setState(() {
                _step = 1;
                _currentCase = cases[(_currentCase == cases[0]) ? 1 : 0];
                _initPuzzleState();
                _graphAnimController.reset();
                _panAnimController.reset();
              });
            },
            child: Text(
              getT('btn_new_case'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ISOMETRIC 3D GRAPH PAINTER ---

class DetectiveGraphPainter extends CustomPainter {
  final CaseData? caseData;
  final double progress; // For line drawing
  final double panProgress; // For zooming to intersection

  DetectiveGraphPainter({
    required this.caseData,
    required this.progress,
    required this.panProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamic scaling: starts at a solid base and zooms in nicely towards the end
    double baseScale = 5.0;
    double scale = baseScale + (panProgress * 5.0);

    // Center the graph on the screen, bumped down slightly to avoid UI overlap
    double cx = size.width / 2;
    double cy = size.height / 2 + 50;

    canvas.save();
    canvas.translate(cx, cy);

    // Pseudo-Isometric Transform
    canvas.scale(1, 0.5);
    canvas.rotate(pi / 4);
    canvas.scale(scale, -scale); // Standard cartesian (Y up)

    if (caseData != null && panProgress > 0) {
      // Pan smoothly so the mathematical solution point (solX, solY) is perfectly centered
      double panX = -caseData!.solX * panProgress;
      double panY = -caseData!.solY * panProgress;
      canvas.translate(panX, panY);
    }

    // Draw Grid (span wider to handle large zoom/pans gracefully)
    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1 / scale;
    for (double i = -200; i <= 200; i += 10) {
      canvas.drawLine(Offset(i, -200), Offset(i, 200), gridPaint);
      canvas.drawLine(Offset(-200, i), Offset(200, i), gridPaint);
    }

    // Draw Axes (faded to be subtle)
    Paint xAxisPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.5)
      ..strokeWidth = 3 / scale;
    Paint yAxisPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.5)
      ..strokeWidth = 3 / scale;
    canvas.drawLine(const Offset(-200, 0), const Offset(200, 0), xAxisPaint);
    canvas.drawLine(const Offset(0, -200), const Offset(0, 200), yAxisPaint);

    if (caseData != null && progress > 0) {
      // Draw the intersecting lines
      _drawDetectiveLine(
        canvas,
        caseData!.m1,
        caseData!.c1,
        caseData!.solY,
        const Color(0xFF3B82F6),
        progress,
        scale,
      );
      _drawDetectiveLine(
        canvas,
        caseData!.m2,
        caseData!.c2,
        caseData!.solY,
        const Color(0xFF10B981),
        progress,
        scale,
      );

      // Draw glowing Intersection point & pulsing rings if complete
      if (progress > 0.9) {
        double markerOpacity = ((progress - 0.9) * 10).clamp(0.0, 1.0);

        Paint markerPaint = Paint()
          ..color = Colors.white.withOpacity(markerOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(caseData!.solX, caseData!.solY),
          4.0 / scale,
          markerPaint,
        );

        Paint ringPaint = Paint()
          ..color = Colors.white.withOpacity(0.8 * markerOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / scale;
        canvas.drawCircle(
          Offset(caseData!.solX, caseData!.solY),
          8.0 / scale,
          ringPaint,
        );

        Paint pulsePaint = Paint()
          ..color = Colors.cyanAccent.withOpacity(
            (1.0 - panProgress) * 0.5 * markerOpacity,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 / scale;
        canvas.drawCircle(
          Offset(caseData!.solX, caseData!.solY),
          (12.0 + panProgress * 10) / scale,
          pulsePaint,
        );

        // Draw Coordinates Text
        canvas.save();
        // Move to the exact intersection point
        canvas.translate(caseData!.solX, caseData!.solY);
        // Reverse the 3D isometric transformations so the text faces the screen normally
        canvas.scale(1 / scale, -1 / scale);
        canvas.rotate(-pi / 4);
        canvas.scale(1, 2.0);

        final textSpan = TextSpan(
          text: '(${caseData!.solX.toInt()}, ${caseData!.solY.toInt()})',
          style: TextStyle(
            color: Colors.white.withOpacity(markerOpacity),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: 'monospace',
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(markerOpacity),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        // Paint the text slightly offset from the center of the glowing dot
        textPainter.paint(canvas, const Offset(15, -30));
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _drawDetectiveLine(
    Canvas canvas,
    double m,
    double c,
    double solY,
    Color color,
    double progress,
    double scale,
  ) {
    // Generate endpoints perfectly centered around the exact mathematical solution
    // This forces the two animated lines to meet precisely in the middle of their paths
    double y1 = solY - 60;
    double y2 = solY + 60;
    Offset p1 = Offset(m * y1 + c, y1);
    Offset p2 = Offset(m * y2 + c, y2);

    // Animate drawing from p1 to p2
    Offset currentP2 = Offset(
      p1.dx + (p2.dx - p1.dx) * progress,
      p1.dy + (p2.dy - p1.dy) * progress,
    );

    Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3 / scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p1, currentP2, linePaint);
  }

  @override
  bool shouldRepaint(covariant DetectiveGraphPainter oldDelegate) {
    return caseData != oldDelegate.caseData ||
        progress != oldDelegate.progress ||
        panProgress != oldDelegate.panProgress;
  }
}
