// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

// --- DATA & I18N ---

class Level {
  final int id;
  final String type;
  final String latex;
  final String tool;
  final String? finalLatex;
  final bool isQuad;

  Level({
    required this.id,
    required this.type,
    required this.latex,
    required this.tool,
    this.finalLatex,
    required this.isQuad,
  });
}

final List<Level> levelsData = [
  Level(
    id: 1,
    type: "calibration",
    latex: "ax² + bx + c = 0",
    tool: "scanner",
    isQuad: true,
  ),
  Level(
    id: 2,
    type: "std",
    latex: "x² - 5x + 6 = 0",
    tool: "scanner",
    isQuad: true,
  ),
  Level(
    id: 3,
    type: "expand",
    latex: "x(x+1) + 8 = (x+2)(x-2)",
    tool: "hammer",
    finalLatex: "x² + x + 8 = x² - 4\n=> x + 12 = 0",
    isQuad: false,
  ),
  Level(
    id: 4,
    type: "expand2",
    latex: "(x - 2)² + 1 = 2x - 3",
    tool: "hammer",
    finalLatex: "x² - 4x + 5 = 2x - 3\n=> x² - 6x + 8 = 0",
    isQuad: true,
  ),
];

const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'QUADRATIC IDENTIFIER',
    'tagline': 'EQUATION CLASSIFICATION UNIT',
    'init_btn': 'BOOT SYSTEM',
    'header_title': 'Quadratic Identifier',
    'header_subtitle': 'CLASS 10 • QUADRATIC EQUATIONS',
    'btn_keep': 'KEEP\n(Quadratic)',
    'btn_recycle': 'RECYCLE\n(Not Quadratic)',
    'btn_restart': 'RESTART',
    'hint_scan':
        'Hint: Use the Scanner to analyze the structure of this equation.',
    'hint_hammer':
        'Hint: Use the Hammer to expand and simplify the equation first.',
    'hint_classify':
        'Hint: Does the simplified equation have a highest power of 2 (x²)?',
    'msg_correct': 'CORRECT CLASSIFICATION!',
    'msg_wrong': 'ERROR: INCORRECT CLASSIFICATION',
    'hud_title': 'ACTIVE MISSION',
    'activate': 'ACTIVATE',
    'lbl_level': 'LEVEL',
    'lbl_step': 'STEP',
    'scanner': 'SCANNER',
    'hammer': 'HAMMER',
  },
  'hi': {
    'app_title': 'द्विघात पहचानकर्ता',
    'tagline': 'समीकरण वर्गीकरण इकाई',
    'init_btn': 'सिस्टम बूट करें',
    'header_title': 'द्विघात पहचानकर्ता',
    'header_subtitle': 'कक्षा 10 • द्विघात समीकरण',
    'btn_keep': 'रखें\n(द्विघात)',
    'btn_recycle': 'रीसायकल\n(द्विघात नहीं)',
    'btn_restart': 'पुनः प्रारंभ',
    'hint_scan':
        'संकेत: इस समीकरण की संरचना का विश्लेषण करने के लिए स्कैनर का उपयोग करें।',
    'hint_hammer':
        'संकेत: पहले समीकरण का विस्तार और सरलीकरण करने के लिए हथौड़े का उपयोग करें।',
    'hint_classify': 'संकेत: क्या सरलीकृत समीकरण की उच्चतम घात 2 (x²) है?',
    'msg_correct': 'सही वर्गीकरण!',
    'msg_wrong': 'त्रुटि: गलत वर्गीकरण',
    'hud_title': 'सक्रिय मिशन',
    'activate': 'सक्रिय करें',
    'lbl_level': 'स्तर',
    'lbl_step': 'चरण',
    'scanner': 'स्कैनर',
    'hammer': 'हथौड़ा',
  },
};

// --- MAIN SCREEN ---

class QuadraticApp extends StatefulWidget {
  const QuadraticApp({super.key});

  @override
  State<QuadraticApp> createState() => _QuadraticAppState();
}

class _QuadraticAppState extends State<QuadraticApp>
    with TickerProviderStateMixin {
  bool _introVisible = true;
  String _lang = 'en';
  bool _isPanelOpen = true;

  int _currentLevelIdx = 0;
  int _step = 1; // 1: Tool Phase, 2: Classification Phase

  // Overlay State
  bool _isOverlayActive = false;
  bool _overlayIsSuccess = false;

  // Controllers
  final ScrollController _hudScrollController = ScrollController();
  late AnimationController _toolAnimController;
  late AnimationController _shakeController;

  // Dedicated audio players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();
    _toolAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _toolAnimController.dispose();
    _shakeController.dispose();
    _hudScrollController.dispose();

    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String type) async {
    if (type == 'click') HapticFeedback.selectionClick();
    if (type == 'success') HapticFeedback.heavyImpact();
    if (type == 'error') HapticFeedback.vibrate();

    try {
      if (type == 'click' || type == 'tool') {
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

  void _activateTool() {
    _playSound('tool');
    Level lvl = levelsData[_currentLevelIdx];

    if (lvl.tool == 'hammer') {
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    }

    _toolAnimController.forward(from: 0).then((_) {
      setState(() {
        _step = 2; // Move to classification
      });
    });
  }

  void _classify(bool userChoice) {
    Level lvl = levelsData[_currentLevelIdx];
    bool isCorrect = (userChoice == lvl.isQuad);

    if (isCorrect) {
      _playSound('success');
      setState(() {
        _overlayIsSuccess = true;
        _isOverlayActive = true;
      });
    } else {
      _playSound('error');
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
      setState(() {
        _overlayIsSuccess = false;
        _isOverlayActive = true;
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isOverlayActive = false);
        if (isCorrect) {
          if (_currentLevelIdx < levelsData.length - 1) {
            setState(() {
              _currentLevelIdx++;
              _step = 1;
            });
          } else {
            // Finished all levels
            setState(() {
              _introVisible = true;
              _currentLevelIdx = 0;
              _step = 1;
            });
          }
        }
      }
    });
  }

  void _restart() {
    _playSound('click');
    setState(() {
      _introVisible = true;
      _currentLevelIdx = 0;
      _step = 1;
      _isOverlayActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double panelWidth = sw * 0.40; // 40% Sidebar

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // 1. Background Visuals
            Positioned.fill(
              child: CustomPaint(painter: PerspectiveGridPainter()),
            ),

            // 2. Main Interface Elements
            if (!_introVisible) ...[
              // 40% Side Panel
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isPanelOpen ? 0 : -panelWidth,
                top: 0,
                bottom: 0,
                width: panelWidth,
                child: _buildSidePanel(),
              ),

              // Floating HUD (Visible when Sidebar is closed)
              if (!_isPanelOpen)
                Positioned(top: 16, left: 16, child: _buildFloatingHUD()),

              // Menu Toggle Button
              Positioned(
                top: 16,
                left: 16,
                child: _buildFloatingIconBtn(
                  icon: _isPanelOpen ? Icons.close : Icons.menu,
                  onTap: () {
                    _playSound('click');
                    setState(() => _isPanelOpen = !_isPanelOpen);
                  },
                ),
              ),
            ],

            // 3. Overlay for Success / Error messages
            // This is placed AT THE END of the Stack (before intro) so it always renders ON TOP of everything
            if (_isOverlayActive)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _overlayIsSuccess ? Icons.check_circle : Icons.error,
                        color: _overlayIsSuccess
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _overlayIsSuccess
                            ? getT('msg_correct')
                            : getT('msg_wrong'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: _overlayIsSuccess
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          shadows: [
                            Shadow(
                              color: _overlayIsSuccess
                                  ? Colors.green
                                  : Colors.red,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 4. Curtain Raiser (Highest Z-Index when visible)
            if (_introVisible) _buildIntroScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroScreen() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Colors.tealAccent,
              ),
              const SizedBox(height: 24),
              Text(
                getT('app_title'),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withOpacity(0.5)),
                ),
                child: Text(
                  getT('tagline'),
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  _playSound('shutter');
                  setState(() => _introVisible = false);
                },
                icon: const Icon(Icons.power_settings_new, color: Colors.white),
                label: Text(
                  getT('init_btn'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 10,
                  shadowColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStepHint(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withOpacity(0.1),
        border: const Border(
          left: BorderSide(color: Colors.cyanAccent, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.cyanAccent,
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

  // SHARED MISSION CONTENT: Used perfectly by BOTH Sidebar and Floating HUD
  Widget _buildActiveMissionContent() {
    Level lvl = levelsData[_currentLevelIdx];

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(math.sin(_shakeController.value * math.pi * 4) * 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getT('lbl_level')} ${_currentLevelIdx + 1}/${levelsData.length}",
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "${getT('lbl_step')} $_step/2",
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentLevelIdx + (_step / 2)) / levelsData.length,
                backgroundColor: Colors.white10,
                color: Colors.tealAccent,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 20),

              // Tool Phase
              if (_step == 1) ...[
                _buildStepHint(
                  lvl.tool == 'scanner'
                      ? getT('hint_scan')
                      : getT('hint_hammer'),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      lvl.latex,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _activateTool,
                  icon: Icon(
                    lvl.tool == 'scanner'
                        ? Icons.qr_code_scanner
                        : Icons.hardware,
                    color: Colors.white,
                  ),
                  label: Text(
                    "${getT('activate')} ${getT(lvl.tool)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lvl.tool == 'scanner'
                        ? Colors.blueAccent
                        : Colors.orangeAccent.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],

              // Classification Phase
              if (_step == 2) ...[
                _buildStepHint(getT('hint_classify')),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.tealAccent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      lvl.finalLatex ?? lvl.latex,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _classify(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          getT('btn_keep'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _classify(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          getT('btn_recycle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // FLOATING HUD
  Widget _buildFloatingHUD() {
    return Container(
      width: 320,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location,
                  color: Colors.tealAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  getT('hud_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Body wrapper to prevent any buttons from missing
          Flexible(
            child: Scrollbar(
              controller: _hudScrollController,
              thumbVisibility: true,
              radius: const Radius.circular(8),
              thickness: 6,
              child: SingleChildScrollView(
                controller: _hudScrollController,
                padding: const EdgeInsets.all(16),
                child: _buildActiveMissionContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SIDEBAR PANEL
  Widget _buildSidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
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
                    // Main Expanded Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 70,
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getT('header_title'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            getT('header_subtitle'),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.tealAccent,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
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
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Row(
                                        children: [
                                          _buildLangBtn('EN', 'en'),
                                          _buildLangBtn('HI', 'hi'),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _restart,
                                      icon: const Icon(Icons.refresh, size: 14),
                                      label: Text(
                                        getT('btn_restart'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white10,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 1),

                          // Mission Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildActiveMissionContent(),
                          ),
                        ],
                      ),
                    ),

                    // Pinned Footer
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
    );
  }

  Widget _buildLangBtn(String label, String code) {
    bool isActive = _lang == code;
    return GestureDetector(
      onTap: () {
        _playSound('click');
        setState(() => _lang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Custom Painter for 3D Perspective Grid Background
// ----------------------------------------------------
class PerspectiveGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final centerY = size.height * 0.7;

    // Draw vanishing lines
    for (int i = -20; i <= 20; i++) {
      double startX = size.width / 2 + (i * 40);
      double endX = size.width / 2 + (i * 200);
      canvas.drawLine(
        Offset(startX, centerY - 500),
        Offset(endX, size.height + 500),
        paint,
      );
    }

    // Draw horizontal perspective lines
    for (int i = 0; i < 20; i++) {
      double y = centerY + math.pow(i, 2) * 1.5;
      if (y > size.height + 500) break;
      canvas.drawLine(Offset(-1000, y), Offset(size.width + 1000, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
