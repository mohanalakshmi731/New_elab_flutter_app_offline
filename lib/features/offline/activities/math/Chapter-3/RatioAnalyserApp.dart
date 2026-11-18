// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RatioAnalyserApp(),
    ),
  );
}

// --- DATA MODELS ---

class SystemData {
  final String eq1Str;
  final String eq2Str;
  final int a1;
  final int b1;
  final int c1;
  final int a2;
  final int b2;
  final int c2;
  final double rA;
  final double rB;
  final double rC;
  final String type; // unique, nosol, infinite

  SystemData({
    required this.eq1Str,
    required this.eq2Str,
    required this.a1,
    required this.b1,
    required this.c1,
    required this.a2,
    required this.b2,
    required this.c2,
    required this.rA,
    required this.rB,
    required this.rC,
    required this.type,
  });
}

// --- LOCALIZATION ---

const Map<String, Map<String, String>> i18n = {
  "en": {
    "app_title": "THE RATIO ANALYSER",
    "tagline": "CONSISTENCY CHECK SYSTEM",
    "init_btn": "INITIALIZE LAB",
    "header_title": "The Ratio Analyser",
    "header_subtitle": "CLASS 10 • PAIR OF LINEAR EQUATIONS",
    "nav_lab": "Explore",
    "s1_title": "Awaiting Data Stream",
    "s1_desc": "Initialize satellite uplink to receive linear equation pair.",
    "s1_btn": "Incoming Stream",
    "s2_title": "Coefficient Extraction",
    "s2_sys": "System A Data",
    "s2_drop": "Fill Matrix",
    "s2_instr":
        "Tap a number to select it, then tap the correct matrix box to place it.",
    "s3_input": "Input Ratio",
    "s3_pull": "Tap to Process",
    "s3_output": "Simplified Output (Enter Decimal)",
    "btn_cont": "Continue",
    "logic_gate": "Logic Gate",
    "path_int": "Intersecting",
    "path_chk": "Check Next",
    "path_par": "Parallel",
    "path_coi": "Coincident",
    "s8_title": "Analyst Dashboard",
    "s8_desc": "Based on the logic path, classify this system.",
    "opt_unique": "Unique Solution",
    "opt_unique_d": "Lines Intersect at one point",
    "opt_none": "No Solution",
    "opt_none_d": "Lines are Parallel",
    "opt_inf": "Infinitely Many Solutions",
    "opt_inf_d": "Lines are Coincident",
    "s9_ver": "Classification Verified",
    "s9_holo": "Generate holographic projection to confirm.",
    "s9_btn": "Generate Graphic Proof",
    "s10_btn": "Request New Data Stream",
    "mission_title": "MISSION OBJECTIVE",
    "step_prefix": "Step",
    "msg_correct": "Correct!",
    "msg_incorrect_matrix": "Incorrect Matrix!",
    "processor_a": "Processor A (a₁/a₂)",
    "processor_b": "Processor B (b₁/b₂)",
    "processor_c": "Processor C (c₁/c₂)",
    "btn_check": "CHECK",
    "btn_proceed": "PROCEED",
    "lbl_prev": "Prev",
    "msg_celebration": "CORRECT!",
    "lbl_l1": "L1: ",
    "lbl_l2": "L2: ",
  },
  "hi": {
    "app_title": "अनुपात विश्लेषक",
    "tagline": "संगति जाँच प्रणाली",
    "init_btn": "लैब शुरू करें",
    "header_title": "अनुपात विश्लेषक",
    "header_subtitle": "कक्षा 10 • रैखिक समीकरण युग्म",
    "nav_lab": "अन्वेषण",
    "s1_title": "डेटा स्ट्रीम की प्रतीक्षा",
    "s1_desc": "समीकरण प्राप्त करने के लिए उपग्रह अपलिंक शुरू करें।",
    "s1_btn": "इनकमिंग स्ट्रीम",
    "s2_title": "गुणांक निष्कर्षण",
    "s2_sys": "सिस्टम डेटा",
    "s2_drop": "मैट्रिक्स भरें",
    "s2_instr":
        "चयन करने के लिए एक संख्या पर टैप करें, फिर इसे रखने के लिए सही मैट्रिक्स बॉक्स पर टैप करें।",
    "s3_input": "इनपुट अनुपात",
    "s3_pull": "प्रक्रिया के लिए टैप करें",
    "s3_output": "सरल आउटपुट (दशमलव)",
    "btn_cont": "जारी रखें",
    "logic_gate": "लॉजिक गेट",
    "path_int": "प्रतिच्छेदी",
    "path_chk": "अगला जाँचें",
    "path_par": "समांतर",
    "path_coi": "संपाती",
    "s8_title": "विश्लेषक डैशबोर्ड",
    "s8_desc": "लॉजिक पथ के आधार पर वर्गीकरण करें।",
    "opt_unique": "अद्वितीय हल",
    "opt_unique_d": "रेखाएँ एक बिंदु पर मिलती हैं",
    "opt_none": "कोई हल नहीं",
    "opt_none_d": "रेखाएँ समांतर हैं",
    "opt_inf": "अनंत हल",
    "opt_inf_d": "रेखाएँ संपाती हैं",
    "s9_ver": "वर्गीकरण सत्यापित",
    "s9_holo": "पुष्टि के लिए होलोग्राफिक प्रक्षेपण बनाएं।",
    "s9_btn": "ग्राफिक प्रमाण बनाएं",
    "s10_btn": "नई डेटा स्ट्रीम का अनुरोध करें",
    "mission_title": "मिशन उद्देश्य",
    "step_prefix": "चरण",
    "msg_correct": "सही!",
    "msg_incorrect_matrix": "गलत मैट्रिक्स!",
    "processor_a": "प्रोसेसर A (a₁/a₂)",
    "processor_b": "प्रोसेसर B (b₁/b₂)",
    "processor_c": "प्रोसेसर C (c₁/c₂)",
    "btn_check": "जाँचें",
    "btn_proceed": "आगे बढ़ें",
    "lbl_prev": "पिछला",
    "msg_celebration": "सही!",
    "lbl_l1": "L1: ",
    "lbl_l2": "L2: ",
  },
};

// --- STATE MANAGEMENT & MAIN SCREEN ---

class RatioAnalyserApp extends StatefulWidget {
  const RatioAnalyserApp({super.key});

  @override
  State<RatioAnalyserApp> createState() => _RatioAnalyserAppState();
}

class _RatioAnalyserAppState extends State<RatioAnalyserApp>
    with TickerProviderStateMixin {
  bool _showCurtain = true;
  String _lang = 'en';
  String _activeTab = 'explore';
  bool _isMenuOpen = true;
  SystemData? _sys;
  int _step = 1;

  // Viewport Zoom & Pan variables
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _previousZoom = 1.0;

  // Tap & Drop State
  double? _selectedVal;
  Map<String, double?> _slots = {
    'a1': null,
    'b1': null,
    'c1': null,
    'a2': null,
    'b2': null,
    'c2': null,
  };
  String _dropFeedback = "";
  Color _feedbackColor = Colors.transparent;

  // Processor State
  bool _processorActive = false;
  double _currentRatioTarget = 0.0;
  bool _ratioCorrect = false;
  final TextEditingController _ratioController = TextEditingController();

  // Logic Gate State
  String? _logicChoice;
  bool _logicCorrect = false;

  // Animations
  late AnimationController _beamController;
  late AnimationController _shakeController;
  late AnimationController _graphController;
  late AnimationController _celebrationController;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();
    _beamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _graphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _beamController.dispose();
    _shakeController.dispose();
    _graphController.dispose();
    _celebrationController.dispose();
    _ratioController.dispose();

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
    if (type == 'scan') HapticFeedback.mediumImpact();

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

  void _generateSystem() {
    final rand = Random();
    List<String> types = ["unique", "nosol", "infinite"];
    String type = types[rand.nextInt(3)];

    int a1 = rand.nextInt(5) + 1;
    int b1 = rand.nextInt(13) - 6;
    if (b1 == 0) b1 = 1;
    int c1 = rand.nextInt(31) - 15;

    int a2, b2, c2;
    if (type == "unique") {
      a2 = rand.nextInt(5) + 1;
      do {
        b2 = rand.nextInt(13) - 6;
        if (b2 == 0) b2 = 1;
      } while (a1 * b2 == a2 * b1);
      c2 = rand.nextInt(31) - 15;
    } else {
      int k =
          (rand.nextBool() ? 1 : -1) *
          (rand.nextInt(2) + 2); // Multiplier 2, -2, 3, -3
      a2 = a1 * k;
      b2 = b1 * k;
      if (type == "infinite") {
        c2 = c1 * k;
      } else {
        do {
          c2 = rand.nextInt(41) - 20;
          if (c2 == 0) c2 = 1;
        } while (c2 == c1 * k);
      }
    }

    setState(() {
      _sys = SystemData(
        eq1Str: "",
        eq2Str: "", // Formatted directly in UI
        a1: a1,
        b1: b1,
        c1: c1,
        a2: a2,
        b2: b2,
        c2: c2,
        rA: a1 / a2,
        rB: b1 / b2,
        rC: c2 != 0 ? c1 / c2 : 0.0,
        type: type,
      );
      _selectedVal = null; // Clear tap selection on reset
      _slots = {
        'a1': null,
        'b1': null,
        'c1': null,
        'a2': null,
        'b2': null,
        'c2': null,
      };
      _step = 2;
      _resetView();
    });
    _playSound('scan');
  }

  void _handleTapDrop(String key, double val, double expected) {
    if ((val - expected).abs() < 0.001) {
      _playSound('click');
      setState(() {
        _slots[key] = val;
        _selectedVal = null; // Reset selection on success
        _dropFeedback = getT('msg_correct');
        _feedbackColor = Colors.greenAccent;
      });
      if (!_slots.values.contains(null)) {
        Future.delayed(
          const Duration(milliseconds: 800),
          () => _setupProcessor(3),
        );
      }
    } else {
      _playSound('error');
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
      setState(() {
        _selectedVal = null; // Force user to re-select
        _dropFeedback = getT('msg_incorrect_matrix');
        _feedbackColor = Colors.redAccent;
      });
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _dropFeedback = "");
    });
  }

  void _setupProcessor(int step) {
    setState(() {
      _step = step;
      _processorActive = false;
      _ratioCorrect = false;
      _ratioController.clear();
      if (step == 3) {
        _currentRatioTarget = _sys!.rA;
      } else if (step == 4) {
        _currentRatioTarget = _sys!.rB;
      } else if (step == 6) {
        _currentRatioTarget = _sys!.rC;
      }
    });
  }

  void _activateProcessor() {
    _playSound('scan');
    setState(() => _processorActive = true);
    _beamController.forward(from: 0).then((_) => _beamController.reverse());
  }

  void _checkRatio() {
    double? val = double.tryParse(_ratioController.text);
    if (val != null && (val - _currentRatioTarget).abs() < 0.03) {
      _playSound('success');
      setState(() => _ratioCorrect = true);
    } else {
      _playSound('error');
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
      _ratioController.clear();
    }
  }

  void _setupLogic(int step) {
    setState(() {
      _step = step;
      _logicChoice = null;
      _logicCorrect = false;
    });
  }

  void _validateLogic(String choice) {
    bool isEqual = _step == 5
        ? (_sys!.rA - _sys!.rB).abs() < 0.01
        : (_sys!.rB - _sys!.rC).abs() < 0.01;

    bool userCorrect =
        (choice == 'eq' && isEqual) || (choice == 'neq' && !isEqual);

    if (userCorrect) {
      _playSound('success');
      setState(() {
        _logicChoice = choice;
        _logicCorrect = true;
      });
    } else {
      _playSound('error');
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    }
  }

  void _classifySystem(String choice) {
    if (_sys!.type == choice) {
      _playSound('success');
      _celebrationController.forward().then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _celebrationController.reverse();
            setState(() => _step = 9);
          }
        });
      });
    } else {
      _playSound('error');
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    }
  }

  void _generateGraph() {
    _playSound('scan');
    setState(() {
      _step = 10;
      _resetView();
      _graphController.forward(from: 0);
    });
  }

  // Zoom Control Functions
  void _zoomIn() => setState(() => _zoom = (_zoom * 1.3).clamp(0.2, 5.0));
  void _zoomOut() => setState(() => _zoom = (_zoom / 1.3).clamp(0.2, 5.0));
  void _resetView() => setState(() {
    _zoom = 1.0;
    _panOffset = Offset.zero;
  });

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
                      // Added ClipRect to prevent CustomPaint bleed into sidebar
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: (details) {
                            _lastFocalPoint = details.focalPoint;
                            _previousZoom = _zoom;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              _zoom = (_previousZoom * details.scale).clamp(
                                0.2,
                                5.0,
                              );
                              _panOffset +=
                                  details.focalPoint - _lastFocalPoint;
                              _lastFocalPoint = details.focalPoint;
                            });
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFF1E1B4B),
                                  Color(0xFF020617),
                                  Colors.black,
                                ],
                                radius: 1.5,
                              ),
                            ),
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: IsometricGraphPainter(
                                system: _sys,
                                progress: _graphController.value,
                                zoom: _zoom,
                                panOffset: _panOffset,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Mission Card (Shown when menu is collapsed)
            if (!_showCurtain && !_isMenuOpen && _activeTab == 'explore')
              Positioned(top: 70, left: 24, child: _buildFloatingMissionCard()),

            // Bottom-Left Floating Menu Button
            if (!_showCurtain)
              Positioned(top: 20, left: 24, child: _buildFloatingMenu()),

            // Celebration Overlay
            IgnorePointer(
              ignoring: true,
              child: FadeTransition(
                opacity: _celebrationController,
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: Text(
                    getT('msg_celebration'),
                    style: const TextStyle(
                      fontSize: 70,
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
                        Icons.balance,
                        size: 80,
                        color: Color(0xFFA78BFA),
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
                      ),
                      const SizedBox(height: 10),
                      Text(
                        getT('tagline'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFC7D2FE),
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
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
                          Icons.power_settings_new,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            Container(
                              padding: const EdgeInsets.only(
                                top: 70,
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
                                  const SizedBox(height: 4),
                                  Text(
                                    getT('header_subtitle'),
                                    style: const TextStyle(
                                      color: Color(0xFFA5B4FC),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
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
                                            _sys = null;
                                            _resetView();
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
                                bottom: 40,
                              ),
                              child: _buildTabContent(),
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
                color: isActive ? const Color(0xFF8B5CF6) : Colors.transparent,
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

  Widget _buildFloatingMissionCard() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 80,
        maxWidth: 280, // Fixed optimal width
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              spreadRadius: 2,
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
                Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      color: Color(0xFFA78BFA),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      getT('mission_title'),
                      style: const TextStyle(
                        color: Color(0xFFA78BFA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${getT('step_prefix')} $_step/10",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _step / 10.0,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        sin(_shakeController.value * pi * 4) * 8,
                        0,
                      ),
                      child: _buildWorkflowStep(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF7C3AED),
      elevation: 8,
      onPressed: () {
        _playSound('click');
        setState(() => _isMenuOpen = !_isMenuOpen);
      },
      child: Icon(
        _isMenuOpen ? Icons.menu_open : Icons.menu,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'explore':
        return _buildExploreTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildExploreTab() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeController.value * pi * 4) * 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min, // Allows the Column to hug contents
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment,
                        color: Color(0xFFA78BFA),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getT('mission_title'),
                        style: const TextStyle(
                          color: Color(0xFFA78BFA),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${getT('step_prefix')} $_step/10",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _step / 10.0,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 24),
              _buildWorkflowStep(),
            ],
          ),
        );
      },
    );
  }

  // --- WORKFLOW STEPS ---

  Widget _buildWorkflowStep() {
    if (_step == 1) return _buildStep1();
    if (_step == 2) return _buildStep2();
    if (_step == 3 || _step == 4 || _step == 6) return _buildProcessorStep();
    if (_step == 5 || _step == 7) return _buildLogicStep();
    if (_step == 8) return _buildAnalystStep();
    if (_step == 9) return _buildVerificationStep();
    if (_step == 10) return _buildFinalStep();
    return const SizedBox();
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.satellite_alt, size: 60, color: Colors.blueGrey),
        const SizedBox(height: 20),
        Text(
          getT('s1_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          getT('s1_desc'),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.all(20),
          ),
          onPressed: _generateSystem,
          icon: const Icon(Icons.download, color: Colors.white),
          label: Text(
            getT('s1_btn'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          getT('s2_title'),
          style: const TextStyle(
            color: Color(0xFFA78BFA),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Text(
                getT('s2_instr'),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              _buildTapEquation(getT('lbl_l1'), _sys!.a1, _sys!.b1, _sys!.c1),
              const SizedBox(height: 10),
              _buildTapEquation(getT('lbl_l2'), _sys!.a2, _sys!.b2, _sys!.c2),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Text(
                getT('s2_drop'),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    "a",
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "b",
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "c",
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDropZone('a1', _sys!.a1.toDouble()),
                  _buildDropZone('b1', _sys!.b1.toDouble()),
                  _buildDropZone('c1', _sys!.c1.toDouble()),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDropZone('a2', _sys!.a2.toDouble()),
                  _buildDropZone('b2', _sys!.b2.toDouble()),
                  _buildDropZone('c2', _sys!.c2.toDouble()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _dropFeedback,
          style: TextStyle(
            color: _feedbackColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTapEquation(String prefix, int a, int b, int c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
        _buildTapItem(a.toDouble(), "${a}x"),
        _buildTapItem(b.toDouble(), b >= 0 ? "+${b}y" : "${b}y"),
        _buildTapItem(c.toDouble(), c >= 0 ? "+$c" : "$c"),
        const Text(
          " = 0",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildTapItem(double val, String display) {
    bool isSelected = _selectedVal == val;
    return GestureDetector(
      onTap: () {
        _playSound('click');
        setState(() {
          if (_selectedVal == val) {
            _selectedVal = null; // Unselect if tapped again
          } else {
            _selectedVal = val;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.pinkAccent.withOpacity(0.4)
              : const Color(0xFF8B5CF6).withOpacity(0.2),
          border: Border.all(
            color: isSelected
                ? Colors.pinkAccent
                : const Color(0xFF8B5CF6).withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone(String key, double expected) {
    bool filled = _slots[key] != null;
    bool isTargetActive = _selectedVal != null && !filled;

    return GestureDetector(
      onTap: () {
        if (!filled && _selectedVal != null) {
          _handleTapDrop(key, _selectedVal!, expected);
        }
      },
      child: Container(
        width: 50,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled
              ? Colors.green.withOpacity(0.2)
              : (isTargetActive
                    ? Colors.purple.withOpacity(0.4)
                    : Colors.black45),
          border: Border.all(
            color: filled
                ? Colors.green
                : (isTargetActive ? Colors.purpleAccent : Colors.white24),
            width: isTargetActive || filled ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          filled ? _slots[key]!.toInt().toString() : "",
          style: TextStyle(
            color: filled ? Colors.greenAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildProcessorStep() {
    String type = _step == 3
        ? getT('processor_a')
        : _step == 4
        ? getT('processor_b')
        : getT('processor_c');
    int num = _step == 3
        ? _sys!.a1
        : _step == 4
        ? _sys!.b1
        : _sys!.c1;
    int den = _step == 3
        ? _sys!.a2
        : _step == 4
        ? _sys!.b2
        : _sys!.c2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          type,
          style: const TextStyle(
            color: Color(0xFFA78BFA),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          getT('s3_input'),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          "$num / $den",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 30),

        if (!_processorActive) ...[
          InkWell(
            onTap: _activateProcessor,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 4),
              ),
              child: const Icon(
                Icons.power_settings_new,
                color: Colors.white54,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            getT('s3_pull'),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ] else ...[
          Text(
            getT('s3_output'),
            style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (!_ratioCorrect) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _ratioController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "0.0",
                      hintStyle: const TextStyle(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _checkRatio,
                  child: Text(
                    getT('btn_check'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              _currentRatioTarget.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                shadows: [Shadow(color: Colors.green, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                _playSound('click');
                _setupLogic(
                  _step == 3
                      ? 4
                      : _step == 4
                      ? 5
                      : _step == 6
                      ? 7
                      : 8,
                );
              },
              child: Text(
                getT('btn_cont'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildLogicStep() {
    String label1 = _step == 5 ? "a₁/a₂" : getT('lbl_prev');
    String label2 = _step == 5 ? "b₁/b₂" : "c₁/c₂";
    String val1 = _step == 5 ? _sys!.rA.toStringAsFixed(2) : "(=)";
    String val2 = _step == 5
        ? _sys!.rB.toStringAsFixed(2)
        : _sys!.rC.toStringAsFixed(2);

    String txtUnequal = _step == 5 ? getT('path_int') : getT('path_par');
    String txtEqual = _step == 5 ? getT('path_chk') : getT('path_coi');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          getT('logic_gate'),
          style: const TextStyle(
            color: Color(0xFFA78BFA),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogicBox(label1, val1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.compare_arrows,
                color: Colors.white54,
                size: 24,
              ),
            ),
            _buildLogicBox(label2, val2),
          ],
        ),
        const SizedBox(height: 40),
        if (!_logicCorrect) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLogicBtn(
                "≠",
                Colors.redAccent,
                () => _validateLogic('neq'),
              ),
              _buildLogicBtn(
                "=",
                Colors.greenAccent,
                () => _validateLogic('eq'),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _logicChoice == 'eq'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _logicChoice == 'eq' ? Colors.green : Colors.redAccent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _logicChoice == 'eq' ? "=" : "≠",
                  style: TextStyle(
                    color: _logicChoice == 'eq'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _logicChoice == 'eq' ? txtEqual : txtUnequal,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              _playSound('click');
              _logicChoice == 'eq' && _step == 5
                  ? _setupProcessor(6)
                  : setState(() => _step = 8);
            },
            child: Text(
              getT('btn_proceed'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogicBox(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogicBtn(String symbol, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalystStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          getT('s8_title'),
          style: const TextStyle(
            color: Color(0xFFA78BFA),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          getT('s8_desc'),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 30),
        _buildClassifyBtn('unique', getT('opt_unique'), getT('opt_unique_d')),
        _buildClassifyBtn('nosol', getT('opt_none'), getT('opt_none_d')),
        _buildClassifyBtn('infinite', getT('opt_inf'), getT('opt_inf_d')),
      ],
    );
  }

  Widget _buildClassifyBtn(String type, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black26,
          side: const BorderSide(color: Colors.white10),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () => _classifySystem(type),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              desc,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                getT('s9_ver'),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          getT('s9_holo'),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            padding: const EdgeInsets.all(20),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _generateGraph,
          icon: const Icon(Icons.hub, color: Colors.white),
          label: Text(
            getT('s9_btn'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.all(20),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            _playSound('click');
            setState(() => _step = 1);
            _graphController.reset();
            _resetView();
          },
          icon: const Icon(Icons.satellite_alt, color: Colors.white),
          label: Text(
            getT('s10_btn'),
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

// --- ISOMETRIC 3D GRAPH PAINTER ---

class IsometricGraphPainter extends CustomPainter {
  final SystemData? system;
  final double progress;
  final double zoom;
  final Offset panOffset;

  IsometricGraphPainter({
    required this.system,
    required this.progress,
    required this.zoom,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The canvas is now contained in the 60% right panel width, so center is true center
    double cx = size.width / 2;
    double cy = size.height / 2;
    double scale =
        (size.height / 30) * zoom; // Map 30 units to half screen and apply Zoom

    canvas.save();
    // Pan offset applied to translation
    canvas.translate(cx + panOffset.dx, cy + panOffset.dy);

    // Pseudo-Isometric Transform: Rotate X, Rotate Z equivalent
    canvas.scale(1, 0.5); // Flatten Y
    canvas.rotate(pi / 4); // Rotate 45 deg
    canvas.scale(scale, -scale); // Standard cartesian (Y up)

    // Draw Grid extended bounds for panning unconditionally
    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1 / scale;
    for (double i = -200; i <= 200; i += 2) {
      canvas.drawLine(Offset(i, -200), Offset(i, 200), gridPaint);
      canvas.drawLine(Offset(-200, i), Offset(200, i), gridPaint);
    }

    // Axes unconditionally
    Paint xAxisPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2 / scale;
    Paint yAxisPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2 / scale;
    canvas.drawLine(const Offset(-200, 0), const Offset(200, 0), xAxisPaint);
    canvas.drawLine(const Offset(0, -200), const Offset(0, 200), yAxisPaint);

    if (system != null && progress > 0) {
      // Draw Lines
      _drawLine(
        canvas,
        system!.a1,
        system!.b1,
        system!.c1,
        const Color(0xFF22D3EE),
        progress,
        scale,
        0,
      );
      double offset = system!.type == 'infinite' ? 0.2 : 0;
      _drawLine(
        canvas,
        system!.a2,
        system!.b2,
        system!.c2,
        const Color(0xFFD946EF),
        progress,
        scale,
        offset,
      );

      // Intersection logic for unique systems
      if (system!.type == 'unique' && progress > 0.8) {
        double det = (system!.a1 * system!.b2 - system!.a2 * system!.b1)
            .toDouble();
        if (det != 0) {
          double x = (system!.b1 * system!.c2 - system!.b2 * system!.c1) / det;
          double y = (system!.c1 * system!.a2 - system!.c2 * system!.a1) / det;

          // Animate marker appearance
          double markerProgress = (progress - 0.8) / 0.2;
          Paint markerPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(x, y),
            (0.5 / scale) * markerProgress * 15,
            markerPaint,
          );

          // Draw Dashed Guides
          Paint guidePaint = Paint()
            ..color = Colors.yellow
            ..strokeWidth = 1 / scale
            ..style = PaintingStyle.stroke;
          canvas.drawLine(Offset(x, y), Offset(x, 0), guidePaint); // Guide to X
          canvas.drawLine(Offset(x, y), Offset(0, y), guidePaint); // Guide to Y
        }
      }
    }

    canvas.restore();
  }

  void _drawLine(
    Canvas canvas,
    int a,
    int b,
    int c,
    Color color,
    double progress,
    double scale,
    double offset,
  ) {
    if (a == 0 && b == 0) return;

    List<Offset> points = [];
    double bounds = 200; // Expanded bounds for panning support

    if (b != 0) {
      double y1 = (-c - a * -bounds) / b;
      if (y1 >= -bounds && y1 <= bounds) points.add(Offset(-bounds, y1));

      double y2 = (-c - a * bounds) / b;
      if (y2 >= -bounds && y2 <= bounds) points.add(Offset(bounds, y2));
    }

    if (a != 0) {
      double x1 = (-c - b * -bounds) / a;
      if (x1 >= -bounds && x1 <= bounds) points.add(Offset(x1, -bounds));

      double x2 = (-c - b * bounds) / a;
      if (x2 >= -bounds && x2 <= bounds) points.add(Offset(x2, bounds));
    }

    if (points.length >= 2) {
      Offset p1 = points[0];
      Offset p2 = points[1];

      // Shift slightly for overlapping visual
      p1 = Offset(p1.dx + offset, p1.dy + offset);
      p2 = Offset(p2.dx + offset, p2.dy + offset);

      // Animate drawing
      Offset currentP2 = Offset(
        p1.dx + (p2.dx - p1.dx) * progress,
        p1.dy + (p2.dy - p1.dy) * progress,
      );

      Paint linePaint = Paint()
        ..color = color
        ..strokeWidth = 3 / scale
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p1, currentP2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant IsometricGraphPainter oldDelegate) {
    return system != oldDelegate.system ||
        progress != oldDelegate.progress ||
        zoom != oldDelegate.zoom ||
        panOffset != oldDelegate.panOffset;
  }
}
