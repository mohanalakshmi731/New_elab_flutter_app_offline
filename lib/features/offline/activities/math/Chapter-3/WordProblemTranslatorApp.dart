// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- DATA MODELS ---

class Scenario {
  final String id;
  final List<String> eq1Pool;
  final List<String> eq1Target;
  final List<String> eq2Pool;
  final List<String> eq2Target;
  final int a1, b1, c1;
  final int a2, b2, c2;
  final double solX;
  final double solY;

  Scenario({
    required this.id,
    required this.eq1Pool,
    required this.eq1Target,
    required this.eq2Pool,
    required this.eq2Target,
    required this.a1,
    required this.b1,
    required this.c1,
    required this.a2,
    required this.b2,
    required this.c2,
    required this.solX,
    required this.solY,
  });
}

final List<Scenario> scenarios = [
  Scenario(
    id: "fraction",
    eq1Pool: ["11x", "9y", "+", "-", "=", "-4", "4"],
    eq1Target: ["11x", "-", "9y", "=", "-4"],
    eq2Pool: ["6x", "5y", "+", "-", "=", "-3", "3"],
    eq2Target: ["6x", "-", "5y", "=", "-3"],
    a1: 11,
    b1: -9,
    c1: -4,
    a2: 6,
    b2: -5,
    c2: -3,
    solX: 7,
    solY: 9,
  ),
  Scenario(
    id: "ages",
    eq1Pool: ["x", "3y", "+", "-", "=", "-10", "10"],
    eq1Target: ["x", "-", "3y", "=", "-10"],
    eq2Pool: ["x", "2y", "+", "-", "=", "10", "-10"],
    eq2Target: ["x", "-", "2y", "=", "10"],
    a1: 1,
    b1: -3,
    c1: -10,
    a2: 1,
    b2: -2,
    c2: 10,
    solX: 50,
    solY: 20,
  ),
  Scenario(
    id: "library",
    eq1Pool: ["x", "4y", "7y", "+", "-", "=", "27"],
    eq1Target: ["x", "+", "4y", "=", "27"],
    eq2Pool: ["x", "2y", "5y", "+", "-", "=", "21"],
    eq2Target: ["x", "+", "2y", "=", "21"],
    a1: 1,
    b1: 4,
    c1: 27,
    a2: 1,
    b2: 2,
    c2: 21,
    solX: 15,
    solY: 3,
  ),
];

// --- LOCALIZATION ---

const Map<String, Map<String, String>> i18n = {
  "en": {
    "app_title": "THE TRANSLATOR",
    "tagline": "WORD PROBLEM PARSER UNIT",
    "init_btn": "INITIALIZE SYSTEM",
    "header_title": "The Word Problem Translator",
    "header_subtitle": "CLASS 10 • ALGEBRAIC METHODS",
    "nav_context": "Why to Learn?",
    "nav_lab": "Terminal",
    "nav_report": "Outcomes",
    "btn_next": "Next Scenario",
    "hint_p1":
        "Hint: Review the scenario details and tap to confirm the variable definitions.",
    "hint_p2":
        "Hint: Tap a term from the pool, then tap the correct empty slot to build the equation.",
    "hint_p4":
        "Hint: Observe the generated graph. The intersection point represents our mathematical solution.",
    "active_terminal": "ACTIVE TERMINAL",
    "phase_prefix": "Phase",
    "decoded": "DECODED!",
    "select_data_stream": "Select Data Stream:",
    "phase_1_title": "PHASE 1: VARIABLE EXTRACTION",
    "btn_vars_confirmed": "VARS CONFIRMED",
    "phase_2_title": "PHASE 2: TRANSLATE COND 1",
    "phase_3_title": "PHASE 3: TRANSLATE COND 2",
    "phase_4_title": "PHASE 4: SYSTEM SOLVED",
    "btn_parse_next": "PARSE NEXT SCENARIO",
    // Scenarios
    "fraction_title": "The Broken Fraction",
    "fraction_desc":
        "A mysterious fraction needs decoding based on two strict alterations.",
    "fraction_varX": "x = Numerator",
    "fraction_varY": "y = Denominator",
    "fraction_cond1":
        "It becomes 9/11 if 2 is added to both numerator and denominator.",
    "fraction_cond2": "If 3 is added to both, it becomes 5/6.",
    "ages_title": "The Timeline Shift",
    "ages_desc":
        "Calculate the present ages of two targets using historical and future data.",
    "ages_varX": "x = Nuri's Age",
    "ages_varY": "y = Sonu's Age",
    "ages_cond1": "Five years ago, Nuri was thrice as old as Sonu.",
    "ages_cond2": "Ten years later, Nuri will be twice as old as Sonu.",
    "library_title": "The Lending Library",
    "library_desc":
        "A library has a fixed charge for the first 3 days and an additional charge per day thereafter.",
    "library_varX": "x = Fixed Charge (3 days)",
    "library_varY": "y = Charge per extra day",
    "library_cond1":
        "Saritha paid ₹27 for a book kept for 7 days (3 fixed + 4 extra).",
    "library_cond2":
        "Susy paid ₹21 for a book kept for 5 days (3 fixed + 2 extra).",
  },
  "hi": {
    "app_title": "अनुवादक",
    "tagline": "शब्द समस्या पार्सर इकाई",
    "init_btn": "सिस्टम प्रारंभ करें",
    "header_title": "शब्द समस्या अनुवादक",
    "header_subtitle": "कक्षा 10 • बीजगणितीय विधियाँ",
    "nav_context": "क्यों सीखें?",
    "nav_lab": "टर्मिनल",
    "nav_report": "निष्कर्ष",
    "btn_next": "अगला परिदृश्य",
    "hint_p1":
        "संकेत: परिदृश्य विवरण की समीक्षा करें और चर परिभाषाओं की पुष्टि करने के लिए टैप करें।",
    "hint_p2":
        "संकेत: पूल से एक पद पर टैप करें, फिर समीकरण बनाने के लिए सही खाली स्लॉट पर टैप करें।",
    "hint_p4":
        "संकेत: उत्पन्न ग्राफ का निरीक्षण करें। प्रतिच्छेदन बिंदु हमारे समाधान का प्रतिनिधित्व करता है।",
    "active_terminal": "सक्रिय टर्मिनल",
    "phase_prefix": "चरण",
    "decoded": "डिकोड किया गया!",
    "select_data_stream": "डेटा स्ट्रीम चुनें:",
    "phase_1_title": "चरण 1: चर निष्कर्षण",
    "btn_vars_confirmed": "चर की पुष्टि की गई",
    "phase_2_title": "चरण 2: शर्त 1 का अनुवाद करें",
    "phase_3_title": "चरण 3: शर्त 2 का अनुवाद करें",
    "phase_4_title": "चरण 4: प्रणाली हल",
    "btn_parse_next": "अगले परिदृश्य का विश्लेषण करें",
    // Scenarios
    "fraction_title": "टूटा हुआ अंश",
    "fraction_desc":
        "दो सख्त परिवर्तनों के आधार पर एक रहस्यमय भिन्न को डिकोड करने की आवश्यकता है।",
    "fraction_varX": "x = अंश",
    "fraction_varY": "y = हर",
    "fraction_cond1":
        "यदि अंश और हर दोनों में 2 जोड़ा जाए तो यह 9/11 हो जाता है।",
    "fraction_cond2": "यदि दोनों में 3 जोड़ा जाए, तो यह 5/6 हो जाता है।",
    "ages_title": "समयरेखा बदलाव",
    "ages_desc":
        "ऐतिहासिक और भविष्य के डेटा का उपयोग करके दो लक्ष्यों की वर्तमान आयु की गणना करें।",
    "ages_varX": "x = नूरी की आयु",
    "ages_varY": "y = सोनू की आयु",
    "ages_cond1": "पांच साल पहले नूरी की उम्र सोनू की उम्र की तीन गुनी थी।",
    "ages_cond2": "दस वर्ष बाद, नूरी की आयु सोनू की आयु की दोगुनी होगी।",
    "library_title": "उधार पुस्तकालय",
    "library_desc":
        "एक पुस्तकालय में पहले 3 दिनों के लिए एक निश्चित शुल्क है और उसके बाद प्रति दिन एक अतिरिक्त शुल्क है।",
    "library_varX": "x = निश्चित शुल्क (3 दिन)",
    "library_varY": "y = अतिरिक्त दिन का शुल्क",
    "library_cond1":
        "सरिता ने 7 दिनों (3 निश्चित + 4 अतिरिक्त) के लिए रखी गई एक किताब के लिए ₹27 का भुगतान किया।",
    "library_cond2":
        "सूसी ने 5 दिनों (3 निश्चित + 2 अतिरिक्त) के लिए रखी गई एक पुस्तक के लिए ₹21 का भुगतान किया।",
  },
};

// --- STATE MANAGEMENT & MAIN SCREEN ---

class WordProblemTranslatorApp extends StatefulWidget {
  const WordProblemTranslatorApp({super.key});

  @override
  State<WordProblemTranslatorApp> createState() =>
      _WordProblemTranslatorAppState();
}

class _WordProblemTranslatorAppState extends State<WordProblemTranslatorApp>
    with TickerProviderStateMixin {
  bool _showCurtain = true;
  String _lang = 'en';
  bool _isMenuOpen = true;

  Scenario? _currentScenario;
  int _step = 1; // 1 to 4

  // Interactive Lab State
  String? _selectedTerm;
  List<String?> _eq1Filled = [];
  List<String?> _eq2Filled = [];

  // Controllers
  final ScrollController _hudScrollController = ScrollController();

  // Animations
  late AnimationController _graphAnimController;
  late AnimationController _panAnimController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;

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
    _currentScenario = scenarios[0];
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

  bool _isOperator(String s) => ["=", "+", "-", "×"].contains(s);

  void _initPuzzleState() {
    if (_currentScenario != null) {
      _eq1Filled = List.generate(_currentScenario!.eq1Target.length, (i) {
        String term = _currentScenario!.eq1Target[i];
        return _isOperator(term) ? term : null;
      });
      _eq2Filled = List.generate(_currentScenario!.eq2Target.length, (i) {
        String term = _currentScenario!.eq2Target[i];
        return _isOperator(term) ? term : null;
      });
    }
    _selectedTerm = null;
    _step = 1;
  }

  @override
  void dispose() {
    _graphAnimController.dispose();
    _panAnimController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _hudScrollController.dispose();

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
      if (type == 'click' || type == 'scan') {
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

  void _loadScenario(Scenario sc) {
    _playSound('click');
    setState(() {
      _currentScenario = sc;
      _initPuzzleState();
      _graphAnimController.reset();
      _panAnimController.reset();
    });
  }

  void _handleTermSelect(String term) {
    _playSound('click');
    setState(() {
      if (_selectedTerm == term) {
        _selectedTerm = null; // deselect
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
    if (isEq1 && !_eq1Filled.contains(null) && _step == 2) {
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() => _step = 3),
      );
    } else if (!isEq1 && !_eq2Filled.contains(null) && _step == 3) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _playSound('scan');
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
      });
    }
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
                              Color(0xFF06111C),
                              Colors.black,
                            ],
                            radius: 1.5,
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 0.2,
                              maxScale: 6.0,
                              boundaryMargin: const EdgeInsets.all(
                                double.infinity,
                              ),
                              child: CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: TranslatorGraphPainter(
                                  scenario: _currentScenario,
                                  progress: _graphAnimController.value,
                                  panProgress: _panAnimController.value,
                                  step: _step,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Mission Card (Visible when sidebar is collapsed)
            if (!_isMenuOpen && !_showCurtain)
              Positioned(top: 80, left: 24, child: _buildFloatingMissionCard()),

            // Bottom-Left Floating Menu Button
            if (!_showCurtain)
              Positioned(
                top: 24,
                left: 24,
                child: FloatingActionButton(
                  backgroundColor: Colors.teal,
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
                    getT('decoded'),
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                      shadows: [Shadow(color: Colors.teal, blurRadius: 30)],
                    ),
                  ),
                ),
              ),
            ),

            // Initial Curtain
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF06111C),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.code,
                        size: 80,
                        color: Colors.tealAccent,
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
                          color: Colors.teal,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
                        icon: const Icon(Icons.terminal, color: Colors.white),
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

  Widget _buildStepHint(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.1),
        border: const Border(
          left: BorderSide(color: Colors.tealAccent, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.tealAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          int stepNum = index + 1;
          bool isActive = _step == stepNum;
          bool isPast = _step > stepNum;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.tealAccent
                        : (isPast ? Colors.teal.shade800 : Colors.black45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? Colors.white
                          : (isPast ? Colors.tealAccent : Colors.white24),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            const BoxShadow(
                              color: Colors.tealAccent,
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: isPast
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
                if (stepNum < 4)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isPast ? Colors.tealAccent : Colors.white10,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1B2D).withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.teal.withOpacity(0.2))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Expanding Content
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
                                  color: Colors.teal.withOpacity(0.2),
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
                                              fontSize: 18,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            getT('header_subtitle'),
                                            style: const TextStyle(
                                              color: Colors.tealAccent,
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

                          // Connected Level Nodes Progress Bar
                          _buildProgressBar(),

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

                    // Pinned Footer Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF020617),
                        border: Border(
                          top: BorderSide(color: Color(0xFF1E293B)),
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
                color: isActive ? Colors.teal : Colors.transparent,
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
    if (_currentScenario == null) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 80,
        maxWidth: 300,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1B2D).withOpacity(0.85),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20),
              ],
            ),
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
                          Icons.terminal,
                          color: Colors.tealAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          getT('active_terminal'),
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${getT('phase_prefix')} $_step/4",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProgressBar(),
                const SizedBox(height: 20),
                Flexible(
                  child: Scrollbar(
                    controller: _hudScrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    thickness: 6,
                    child: SingleChildScrollView(
                      controller: _hudScrollController,
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildExploreTab(),
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

  Widget _buildExploreTab() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeController.value * pi * 4) * 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scenario Selector (Only in Phase 1)
              if (_step == 1) ...[
                Text(
                  getT('select_data_stream'),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ...scenarios.map(
                  (sc) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _loadScenario(sc),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _currentScenario == sc
                              ? Colors.teal.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: _currentScenario == sc
                                ? Colors.teal
                                : Colors.white10,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          getT('${sc.id}_title'),
                          style: TextStyle(
                            color: _currentScenario == sc
                                ? Colors.tealAccent
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Interactive Steps Content
              if (_step >= 1) _buildStep1_Vars(),
              if (_step >= 2)
                _buildStep2_Eq(
                  1,
                  getT('${_currentScenario!.id}_cond1'),
                  _currentScenario!.eq1Pool,
                  _currentScenario!.eq1Target,
                  _eq1Filled,
                ),
              if (_step >= 3)
                _buildStep2_Eq(
                  2,
                  getT('${_currentScenario!.id}_cond2'),
                  _currentScenario!.eq2Pool,
                  _currentScenario!.eq2Target,
                  _eq2Filled,
                ),
              if (_step >= 4) _buildStep4_Solved(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1_Vars() {
    bool isComplete = _step > 1;
    return Opacity(
      opacity: isComplete ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1B2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getT('phase_1_title'),
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 15),
            if (!isComplete) _buildStepHint(getT('hint_p1')),
            Text(
              getT('${_currentScenario!.id}_desc'),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyan.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getT('${_currentScenario!.id}_varX'),
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(width: 1, height: 20, color: Colors.white24),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      getT('${_currentScenario!.id}_varY'),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isComplete) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  _playSound('click');
                  setState(() => _step = 2);
                },
                child: Text(
                  getT('btn_vars_confirmed'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep2_Eq(
    int eqNum,
    String cond,
    List<String> pool,
    List<String> target,
    List<String?> filledList,
  ) {
    bool isComplete = _step > (eqNum + 1);

    return Opacity(
      opacity: isComplete ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1B2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.teal.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              eqNum == 1 ? getT('phase_2_title') : getT('phase_3_title'),
              style: const TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 15),
            if (!isComplete) _buildStepHint(getT('hint_p2')),
            Text(
              '"$cond"',
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (!isComplete) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: pool.map((term) => _buildPoolTerm(term)).toList(),
              ),
              const SizedBox(height: 20),
            ],

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                spacing: 5,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _buildTargetSlots(target, filledList, eqNum == 1),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white.withOpacity(0.1),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.tealAccent, blurRadius: 10)]
              : null,
        ),
        child: Text(
          term,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 16,
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

    for (int i = 0; i < targetTemplate.length; i++) {
      String expected = targetTemplate[i];
      bool isOperator = ["=", "+", "-", "×"].contains(expected);
      bool isFilled = filledList[i] != null;

      if (isOperator) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              expected,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        bool isTargetActive = _selectedTerm != null && !isFilled;
        widgets.add(
          GestureDetector(
            onTap: () {
              if (!isFilled) _handleSlotTap(i, isEq1, expected);
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 50),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFilled
                    ? Colors.transparent
                    : (isTargetActive
                          ? Colors.teal.withOpacity(0.3)
                          : Colors.black26),
                border: Border(
                  bottom: BorderSide(
                    color: isFilled
                        ? Colors.tealAccent
                        : (isTargetActive ? Colors.tealAccent : Colors.white30),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                isFilled ? filledList[i]! : "?",
                style: TextStyle(
                  color: isFilled ? Colors.tealAccent : Colors.white54,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildStep4_Solved() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            getT('phase_4_title'),
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          _buildStepHint(getT('hint_p4')),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildResultBox("x =", _currentScenario!.solX)),
              const SizedBox(width: 10),
              Expanded(child: _buildResultBox("y =", _currentScenario!.solY)),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              _playSound('click');
              setState(() {
                _step = 1;
                int nextIdx =
                    (scenarios.indexOf(_currentScenario!) + 1) %
                    scenarios.length;
                _currentScenario = scenarios[nextIdx];
                _initPuzzleState();
                _graphAnimController.reset();
                _panAnimController.reset();
              });
            },
            child: Text(
              getT('btn_parse_next'),
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

  Widget _buildResultBox(String label, double val) {
    String valStr = val == val.toInt()
        ? val.toInt().toString()
        : val.toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyanAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valStr,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// --- ISOMETRIC 3D GRAPH PAINTER ---

class TranslatorGraphPainter extends CustomPainter {
  final Scenario? scenario;
  final double progress; // Draw lines
  final double panProgress; // Zoom to impact
  final int step;

  TranslatorGraphPainter({
    required this.scenario,
    required this.progress,
    required this.panProgress,
    required this.step,
  });

  void drawLabel(
    Canvas canvas,
    String text,
    Offset pos,
    double scale,
    Color color,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(1 / scale, -1 / scale); // Reverse the math scale
    canvas.rotate(-pi / 4); // Reverse isometric rotation
    canvas.scale(1, 2.0); // Reverse isometric Y squash

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw centered
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    double baseScale = 6.0;
    double scale = baseScale + (panProgress * 15.0);
    double cx = size.width / 2;
    double cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // Isometric Transform
    canvas.scale(1, 0.5);
    canvas.rotate(pi / 4);
    canvas.scale(scale, -scale); // Standard cartesian (Y up)

    // Pan smoothly toward solution after transform
    if (scenario != null && panProgress > 0) {
      canvas.translate(
        -scenario!.solX * panProgress,
        -scenario!.solY * panProgress,
      );
    }

    // Determine dynamic grid step based on the magnitude of the solution
    double gridStep = 5;
    if (scenario != null) {
      double m = max(scenario!.solX.abs(), scenario!.solY.abs());
      if (m > 30)
        gridStep = 10;
      else if (m > 10)
        gridStep = 5;
      else
        gridStep = 2;
    }

    // Draw Floor (Grid) - Expanded bounding box to allow InteractiveViewer panning
    Paint gridPaint = Paint()
      ..color = Colors.teal.withOpacity(0.15)
      ..strokeWidth = 1 / scale;

    double gridBounds = 150;

    for (double i = -gridBounds; i <= gridBounds; i += gridStep) {
      canvas.drawLine(Offset(i, -gridBounds), Offset(i, gridBounds), gridPaint);
      canvas.drawLine(Offset(-gridBounds, i), Offset(gridBounds, i), gridPaint);

      // Draw numerical labels along the axes
      if (i != 0 && i % (gridStep * 2) == 0) {
        drawLabel(
          canvas,
          i.toInt().toString(),
          Offset(i, -gridStep),
          scale,
          Colors.tealAccent.withOpacity(0.5),
        );
        drawLabel(
          canvas,
          i.toInt().toString(),
          Offset(-gridStep, i),
          scale,
          Colors.cyanAccent.withOpacity(0.5),
        );
      }
    }

    // Axes
    Paint xAxisPaint = Paint()
      ..color = Colors.tealAccent.withOpacity(0.8)
      ..strokeWidth = 2 / scale;
    Paint yAxisPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..strokeWidth = 2 / scale;

    canvas.drawLine(Offset(-gridBounds, 0), Offset(gridBounds, 0), xAxisPaint);
    canvas.drawLine(Offset(0, -gridBounds), Offset(0, gridBounds), yAxisPaint);

    // Axis Labels
    drawLabel(
      canvas,
      "X",
      Offset(gridBounds + gridStep, 0),
      scale,
      Colors.tealAccent,
    );
    drawLabel(
      canvas,
      "Y",
      Offset(0, gridBounds + gridStep),
      scale,
      Colors.cyanAccent,
    );

    if (scenario != null && progress > 0 && step >= 4) {
      // Draw Line 1
      _drawEqLine(
        canvas,
        scenario!.a1,
        scenario!.b1,
        scenario!.c1,
        const Color(0xFF00E5FF),
        progress,
        scale,
      ); // Cyan

      // Draw Line 2
      _drawEqLine(
        canvas,
        scenario!.a2,
        scenario!.b2,
        scenario!.c2,
        const Color(0xFF1DE9B6),
        progress,
        scale,
      ); // Teal

      // Draw Solution Point
      if (progress > 0.8) {
        double markerOpacity = ((progress - 0.8) * 5).clamp(0.0, 1.0);

        Paint markerPaint = Paint()
          ..color = Colors.white.withOpacity(markerOpacity)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

        canvas.drawCircle(
          Offset(scenario!.solX, scenario!.solY),
          (1.5 / scale) * 4,
          markerPaint,
        );

        Paint corePaint = Paint()
          ..color = Colors.white.withOpacity(markerOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(scenario!.solX, scenario!.solY),
          (1.5 / scale) * 1.5,
          corePaint,
        );

        // Scanner ring
        Paint ringPaint = Paint()
          ..color = Colors.tealAccent.withOpacity(0.8 * markerOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / scale;
        double scanRadius = (1.5 / scale) * 10 * (0.5 + 0.5 * panProgress);
        canvas.drawCircle(
          Offset(scenario!.solX, scenario!.solY),
          scanRadius,
          ringPaint,
        );

        // Target brackets
        double r = scanRadius + (2 / scale);
        Path brackets = Path()
          ..moveTo(scenario!.solX - r, scenario!.solY - r / 2)
          ..lineTo(scenario!.solX - r, scenario!.solY - r)
          ..lineTo(scenario!.solX - r / 2, scenario!.solY - r)
          ..moveTo(scenario!.solX + r, scenario!.solY - r / 2)
          ..lineTo(scenario!.solX + r, scenario!.solY - r)
          ..lineTo(scenario!.solX + r / 2, scenario!.solY - r)
          ..moveTo(scenario!.solX - r, scenario!.solY + r / 2)
          ..lineTo(scenario!.solX - r, scenario!.solY + r)
          ..lineTo(scenario!.solX - r / 2, scenario!.solY + r)
          ..moveTo(scenario!.solX + r, scenario!.solY + r / 2)
          ..lineTo(scenario!.solX + r, scenario!.solY + r)
          ..lineTo(scenario!.solX + r / 2, scenario!.solY + r);

        Paint bracketPaint = Paint()
          ..color = Colors.cyanAccent.withOpacity(markerOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / scale;
        canvas.drawPath(brackets, bracketPaint);

        // Visual Guide Drop Lines
        Paint guidePaint = Paint()
          ..color = Colors.white.withOpacity(0.3 * markerOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / scale;
        canvas.drawLine(
          Offset(scenario!.solX, scenario!.solY),
          Offset(scenario!.solX, 0),
          guidePaint,
        );
        canvas.drawLine(
          Offset(scenario!.solX, scenario!.solY),
          Offset(0, scenario!.solY),
          guidePaint,
        );

        // Coordinate text label
        canvas.save();
        canvas.translate(scenario!.solX, scenario!.solY);
        canvas.scale(1 / scale, -1 / scale);
        canvas.rotate(-pi / 4);
        canvas.scale(1, 2.0);

        final textSpan = TextSpan(
          text: '(${scenario!.solX.toInt()}, ${scenario!.solY.toInt()})',
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
        textPainter.paint(canvas, const Offset(15, -30));
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _drawEqLine(
    Canvas canvas,
    int a,
    int b,
    int c,
    Color color,
    double progress,
    double scale,
  ) {
    if (a == 0 && b == 0) return;

    double bounds = 5000; // Big enough for infinite lines
    Offset p1, p2;

    // Use mathematically correct line rendering logic `y = (c - ax) / b` or `x = (c - by) / a`
    if (b.abs() > a.abs()) {
      double x1 = -bounds;
      double y1 = (c - a * x1) / b;
      double x2 = bounds;
      double y2 = (c - a * x2) / b;
      p1 = Offset(x1, y1);
      p2 = Offset(x2, y2);
    } else {
      double y1 = -bounds;
      double x1 = (c - b * y1) / a;
      double y2 = bounds;
      double x2 = (c - b * y2) / a;
      p1 = Offset(x1, y1);
      p2 = Offset(x2, y2);
    }

    Offset currentP2 = Offset(
      p1.dx + (p2.dx - p1.dx) * progress,
      p1.dy + (p2.dy - p1.dy) * progress,
    );

    Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3 / scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, currentP2, linePaint);
  }

  @override
  bool shouldRepaint(covariant TranslatorGraphPainter oldDelegate) {
    return scenario != oldDelegate.scenario ||
        progress != oldDelegate.progress ||
        panProgress != oldDelegate.panProgress ||
        step != oldDelegate.step;
  }
}
