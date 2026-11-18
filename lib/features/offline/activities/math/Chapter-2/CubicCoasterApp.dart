// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';

// --- DATA MODELS ---

class Track {
  final int id;
  final String eqn;
  final int zeroes;
  final List<double> roots;
  final double Function(double) formula;
  final String proof;
  final String analogy;
  final String hintIcon;

  const Track({
    required this.id,
    required this.eqn,
    required this.zeroes,
    required this.roots,
    required this.formula,
    required this.proof,
    required this.analogy,
    required this.hintIcon,
  });
}

final List<Track> tracks = [
  Track(
    id: 0,
    eqn: "y = x³ - 4x",
    zeroes: 3,
    roots: [-2.0, 0.0, 2.0],
    formula: (x) => math.pow(x, 3).toDouble() - 4 * x,
    proof: "y = x³ - 4x\n0 = x(x² - 4)\n0 = x(x-2)(x+2)\nx = 0, 2, -2",
    analogy:
        "Imagine a roller coaster crossing sea level. It dives underwater, rises to the sky, and dives again. Each splash is a zero!",
    hintIcon: "🌊",
  ),
  Track(
    id: 1,
    eqn: "y = x³ - 3x + 2",
    zeroes: 2,
    roots: [-2.0, 1.0],
    formula: (x) => math.pow(x, 3).toDouble() - 3 * x + 2,
    proof:
        "y = x³ - 3x + 2\n0 = (x-1)(x²+x-2)\n0 = (x-1)(x-1)(x+2)\n0 = (x-1)²(x+2)",
    analogy:
        "Here, the coaster just touches the water surface at one point (kissing the wave) and dives deep at another point.",
    hintIcon: "🐬",
  ),
  Track(
    id: 2,
    eqn: "y = x³ + 1",
    zeroes: 1,
    roots: [-1.0],
    formula: (x) => math.pow(x, 3).toDouble() + 1,
    proof: "y = x³ + 1\n0 = (x+1)(x²-x+1)\nx = -1\n(x²-x+1 has no real roots)",
    analogy:
        "This slide only has one safe landing spot. The rest of the track is strictly soaring upwards!",
    hintIcon: "🚀",
  ),
  Track(
    id: 3,
    eqn: "y = x³",
    zeroes: 1,
    roots: [0.0],
    formula: (x) => math.pow(x, 3).toDouble(),
    proof: "y = x³\n0 = x · x · x\nx = 0",
    analogy:
        "The classic inflection. The coaster flattens out completely at the center station before climbing again.",
    hintIcon: "🎢",
  ),
  Track(
    id: 4,
    eqn: "y = x³ - x",
    zeroes: 3,
    roots: [-1.0, 0.0, 1.0],
    formula: (x) => math.pow(x, 3).toDouble() - x,
    proof: "y = x³ - x\n0 = x(x² - 1)\n0 = x(x-1)(x+1)\nx = 0, 1, -1",
    analogy:
        "A rapid succession of waves! The coaster dips and rises quickly near the center.",
    hintIcon: "〰️",
  ),
  Track(
    id: 5,
    eqn: "y = x³ - 3x - 2",
    zeroes: 2,
    roots: [-1.0, 2.0],
    formula: (x) => math.pow(x, 3).toDouble() - 3 * x - 2,
    proof: "y = x³ - 3x - 2\n0 = (x+1)²(x-2)\nx = -1 (touch), 2 (cross)",
    analogy:
        "The coaster touches the ground at -1, loops back up, and finally dives underground at 2.",
    hintIcon: "⤵️",
  ),
];

// --- LOCALIZATION ---

const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE CUBIC COASTER',
    'tagline': 'ZEROES OF CUBIC POLYNOMIALS • CLASS 10',
    'init_btn': 'ENTER THEME PARK',
    'header_title': 'The Cubic Coaster',
    'header_subtitle': 'CLASS 10 • POLYNOMIALS',
    'lbl_progress': 'Ride Progress',
    'hud_status': 'System Status',
    'mission_title': 'MISSION OBJECTIVE',
    'mission_desc':
        'Identify the Zeroes of the Cubic Polynomials by finding where the coaster track intersects the X-axis.',
    'lbl_select_track': 'Select Track Design',
    'btn_load': 'Point the Coordinates',
    'lbl_calc_guide': 'Calculation Guide',
    'msg_calc_step': 'To find the zeroes, put y = 0 and solve:',
    'msg_click_hint': 'Tap on the Red Line where the curve crosses it!',
    'lbl_found': 'FOUND',
    'btn_build': 'BUILD COASTER',
    'msg_launch': 'Track Ready. Prepare for Launch.',
    'btn_launch': 'LAUNCH COASTER',
    'msg_count': 'How many times did the coaster cross the Horizon (X-axis)?',
  },
  'hi': {
    'app_title': 'क्यूबिक कोस्टर',
    'tagline': 'त्रिघात बहुपद के शून्यक • कक्षा 10',
    'init_btn': 'थीम पार्क में प्रवेश करें',
    'header_title': 'क्यूबिक कोस्टर',
    'header_subtitle': 'कक्षा 10 • बहुपद',
    'lbl_progress': 'सवारी प्रगति',
    'hud_status': 'सिस्टम स्थिति',
    'mission_title': 'मिशन उद्देश्य',
    'mission_desc':
        'क्यूबिक बहुपद के शून्यक खोजें और देखें कि कोस्टर ट्रैक X-अक्ष को कहाँ काटता है।',
    'lbl_select_track': 'ट्रैक डिज़ाइन चुनें',
    'btn_load': 'निर्देशांक अंकित करें',
    'lbl_calc_guide': 'गणना गाइड',
    'msg_calc_step': 'शून्यक खोजने के लिए, y = 0 रखें और हल करें:',
    'msg_click_hint': 'लाल रेखा पर टैप करें जहाँ वक्र इसे काटता है!',
    'lbl_found': 'मिला',
    'btn_build': 'कोस्टर बनाएं',
    'msg_launch': 'ट्रैक तैयार है। लॉन्च की तैयारी करें।',
    'btn_launch': 'कोस्टर लॉन्च करें',
    'msg_count': 'कोस्टर ने क्षितिज (X-अक्ष) को कितनी बार पार किया?',
  },
};

// --- MAIN SCREEN ---

class CubicCoasterApp extends StatefulWidget {
  const CubicCoasterApp({super.key});

  @override
  State<CubicCoasterApp> createState() => _CubicCoasterAppState();
}

class _CubicCoasterAppState extends State<CubicCoasterApp>
    with TickerProviderStateMixin {
  String _lang = 'en';

  // State Variables
  bool _isSidebarOpen = true;

  // Fixed colors
  final Color primaryColor = Colors.pink;
  final Color bgColor = const Color(0xFF0f0518);

  // App State
  int _appStep = 1; // 1: Select/Identify, 2: Launch, 3: Analysis
  int _selectedTrackId = 0;
  bool _isIdentifying = false;
  bool _isCoasterBuilt = false;
  List<double> _foundRoots = [];
  Offset? _missFlashPos;

  // Scroll Controller for floating window
  final ScrollController _floatingMissionCtrl = ScrollController();

  // Animations & Viewport
  late AnimationController _shutterAnim;
  late AnimationController _coasterAnim;
  late AnimationController _flashAnim;

  late TransformationController _transformCtrl;
  double _currentScale = 1.0;

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

  void _playSound(AudioPlayer player, String url) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void playClick() => _playSound(_clickPlayer, _clickUrl);
  void playSuccess() => _playSound(_successPlayer, _successUrl);
  void playError() => _playSound(_errorPlayer, _errorUrl);
  void playShutter() => _playSound(_fxPlayer, _shutterUrl);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _shutterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _coasterAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _flashAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _transformCtrl = TransformationController();
    _transformCtrl.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    setState(() {
      _currentScale = _transformCtrl.value.getMaxScaleOnAxis();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _transformCtrl.removeListener(_onTransformChanged);
    _transformCtrl.dispose();
    _shutterAnim.dispose();
    _coasterAnim.dispose();
    _flashAnim.dispose();
    _floatingMissionCtrl.dispose();

    // Dispose Audio players
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  String t(String key) => i18n[_lang]?[key] ?? key;

  void _startExperience() {
    playShutter();
    _shutterAnim.forward();
  }

  void _onGraphTap(TapDownDetails details, Size size) {
    if (!_isIdentifying || _isCoasterBuilt) return;

    final track = tracks[_selectedTrackId];

    final double graphWidth = 8.0;
    final double graphHeight = 24.0;

    // InteractiveViewer automatically applies the inverse transformation to PointerEvents,
    // meaning localPosition inherently accounts for pan and scale.
    final xGraph =
        ((details.localPosition.dx / size.width) * graphWidth) -
        (graphWidth / 2);
    final yGraph =
        -(((details.localPosition.dy / size.height) * graphHeight) -
            (graphHeight / 2));

    bool hit = false;

    // Scale-invariant hit tolerances (e.g. keeping visual hit targets identical at heavy zoom)
    final double toleranceX = 0.4 / _currentScale;
    final double toleranceY = 1.5 / _currentScale;

    for (double root in track.roots) {
      if ((xGraph - root).abs() < toleranceX && yGraph.abs() < toleranceY) {
        if (!_foundRoots.contains(root)) {
          playClick();
          setState(() {
            _foundRoots.add(root);
          });
        }
        hit = true;
        break;
      }
    }

    if (!hit) {
      playError();
      setState(() {
        _missFlashPos = details.localPosition;
      });
      _flashAnim.forward(from: 0);
    }
  }

  void _showProofModal(bool success, int answer) {
    if (success) {
      playSuccess();
    } else {
      playError();
    }

    final track = tracks[_selectedTrackId];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            color: const Color(0xFF1e293b).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: success ? Colors.cyan : Colors.red,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          // Wrap the entire content (including header and button) in the scrollbar
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        success ? Icons.lightbulb : Icons.error,
                        color: success ? Colors.yellow : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        success ? "INSIGHT UNLOCKED" : "INCORRECT",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (!success)
                    Text(
                      "You selected $answer, but the correct number of zeroes is ${track.zeroes}.",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (!success) const SizedBox(height: 24),
                  const Text(
                    "MATHEMATICAL PROOF",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      track.proof,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "REAL WORLD ANALOGY",
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    track.analogy,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Footer Action (Now flows with the document)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? Colors.cyan : Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      playClick();
                      Navigator.of(ctx).pop();
                      setState(() {
                        _appStep = 1;
                        _isIdentifying = false;
                        _isCoasterBuilt = false;
                        _foundRoots.clear();
                        _transformCtrl.value =
                            Matrix4.identity(); // Reset camera view
                      });
                    },
                    child: const Text(
                      "PROCEED",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(children: [_buildMainApp(), _buildIntroScreen()]),
      ),
    );
  }

  Widget _buildIntroScreen() {
    return AnimatedBuilder(
      animation: _shutterAnim,
      builder: (context, child) {
        return Positioned(
          top: -MediaQuery.of(context).size.height * _shutterAnim.value,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height,
          child: Container(
            color: const Color(0xFF0f0518),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.train, size: 80, color: Colors.pink),
                  const SizedBox(height: 20),
                  Text(
                    t('app_title'),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    t('tagline'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.pink,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.confirmation_num),
                    label: Text(
                      t('init_btn'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 10,
                      shadowColor: Colors.pinkAccent,
                    ),
                    onPressed: _startExperience,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainApp() {
    return Stack(
      children: [
        // Background Row Structure
        Row(
          children: [
            if (_isSidebarOpen) _buildSidePanelContainer(),
            Expanded(child: _buildCanvasArea()),
          ],
        ),

        // Floating Mission Card (shown when sidebar is closed)
        if (!_isSidebarOpen)
          Positioned(top: 70, left: 16, child: _buildFloatingMissionCard()),

        // Floating Menu Toggle Button (top Left)
        Positioned(top: 16, left: 16, child: _buildFloatingMenuButton()),

        // Note: The 'System Status' HUD from the top center has been deliberately removed as requested.
      ],
    );
  }

  Widget _buildFloatingMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isSidebarOpen ? Icons.close : Icons.menu,
          color: Colors.white,
        ),
        tooltip: 'Toggle Sidebar',
        onPressed: () {
          playClick();
          setState(() => _isSidebarOpen = !_isSidebarOpen);
        },
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 100,
      ),
      child: Container(
        width: 300, // Slightly increased width to fit scrollbar cleanly
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.5)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Scrollbar(
          controller: _floatingMissionCtrl,
          thumbVisibility: true,
          radius: const Radius.circular(8),
          thickness: 6,
          child: SingleChildScrollView(
            controller: _floatingMissionCtrl,
            padding: const EdgeInsets.only(
              left: 20,
              right: 28,
              top: 20,
              bottom: 20,
            ),
            child: _buildStepContent(tracks[_selectedTrackId]),
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanelContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4, // 40% Width
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a).withOpacity(0.95),
        border: Border(
          right: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSidePanelHeader(),
            _buildMissionInfo(),
            Container(
              color: Colors.black26,
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(tracks[_selectedTrackId]),
            ),
            const SizedBox(height: 80), // Prevent hiding behind Floating Menu
            // Sidebar Footer inside scroll
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
    );
  }

  Widget _buildSidePanelHeader() {
    return Padding(
      // Padding left set to 70 to avoid overlaying the Top-Left menu button
      padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('header_title'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          Text(
            t('header_subtitle'),
            style: TextStyle(
              fontSize: 10,
              color: primaryColor,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade900.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade700),
                ),
                child: Row(
                  children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                color: Colors.redAccent,
                tooltip: 'Restart Lab',
                onPressed: () {
                  playClick();
                  playShutter();
                  _shutterAnim.reverse();
                  setState(() {
                    _appStep = 1;
                    _isIdentifying = false;
                    _isCoasterBuilt = false;
                    _foundRoots.clear();
                    _missFlashPos = null;
                    _selectedTrackId = 0; // Reset track to default
                    _coasterAnim.reset(); // Stop ongoing coaster
                    _flashAnim.reset(); // Stop ongoing flash
                    _transformCtrl.value =
                        Matrix4.identity(); // Reset camera view
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
        ],
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    bool isActive = _lang == code;
    return GestureDetector(
      onTap: () {
        playClick();
        setState(() => _lang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildMissionInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('lbl_progress'),
                style: TextStyle(
                  fontSize: 10,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Track ${_selectedTrackId + 1}/6",
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_selectedTrackId + 1) / 6,
            backgroundColor: Colors.white10,
            color: primaryColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.2), Colors.black26],
              ),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.track_changes, color: primaryColor, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('mission_title'),
                        style: TextStyle(
                          fontSize: 10,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('mission_desc'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(Track track) {
    if (_appStep == 1 && !_isIdentifying) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('lbl_select_track'),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedTrackId,
                dropdownColor: const Color(0xFF1e293b),
                isExpanded: true,
                items: tracks
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          t.eqn,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    playClick();
                    setState(() {
                      _selectedTrackId = v;
                      _transformCtrl.value =
                          Matrix4.identity(); // Reset camera view for new track
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              playClick();
              setState(() {
                _isIdentifying = true;
                _foundRoots.clear();
              });
            },
            child: Text(
              t('btn_load'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else if (_appStep == 1 && _isIdentifying) {
      bool allFound = _foundRoots.length == track.roots.length;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate, color: Colors.cyan, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      t('lbl_calc_guide'),
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t('msg_calc_step'),
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    track.proof.split('\n').take(2).join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t('msg_click_hint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_foundRoots.length}/${track.roots.length}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
          Text(
            t('lbl_found'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: allFound ? primaryColor : Colors.white10,
              foregroundColor: allFound ? Colors.white : Colors.white54,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: allFound
                ? () {
                    playClick();
                    setState(() {
                      _isCoasterBuilt = true;
                      _appStep = 2;
                    });
                  }
                : null,
            child: Text(
              t('btn_build'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else if (_appStep == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('msg_launch'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              playClick();
              _coasterAnim.forward(from: 0).then((_) {
                setState(() => _appStep = 3);
              });
            },
            child: Text(
              t('btn_launch'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      );
    } else if (_appStep == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t('msg_count'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3]
                .map(
                  (val) => InkWell(
                    onTap: () {
                      bool correct = val == track.zeroes;
                      _showProofModal(correct, val);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        val.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildCanvasArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: InteractiveViewer(
            transformationController: _transformCtrl,
            boundaryMargin: const EdgeInsets.all(
              2000,
            ), // Gives ample room for panning outside center bounds
            minScale: 0.1, // Zoom extremely far out
            maxScale: 10.0, // Zoom extremely deep in
            child: GestureDetector(
              onTapDown: (details) => _onGraphTap(
                details,
                Size(constraints.maxWidth, constraints.maxHeight),
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_coasterAnim, _flashAnim]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CoasterPainter(
                      track: tracks[_selectedTrackId],
                      isIdentifying: _isIdentifying,
                      isBuilt: _isCoasterBuilt,
                      foundRoots: _foundRoots,
                      coasterProgress: _coasterAnim.value,
                      missFlashPos: _missFlashPos,
                      flashValue: _flashAnim.value,
                      primaryColor: primaryColor,
                      currentScale: _currentScale,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- CUSTOM PAINTER (THE GRAPH) ---

class CoasterPainter extends CustomPainter {
  final Track track;
  final bool isIdentifying;
  final bool isBuilt;
  final List<double> foundRoots;
  final double coasterProgress;
  final Offset? missFlashPos;
  final double flashValue;
  final Color primaryColor;
  final double currentScale;

  CoasterPainter({
    required this.track,
    required this.isIdentifying,
    required this.isBuilt,
    required this.foundRoots,
    required this.coasterProgress,
    required this.missFlashPos,
    required this.flashValue,
    required this.primaryColor,
    required this.currentScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define Graph Base Bounds
    final double graphWidth = 8.0;
    final double graphHeight = 24.0;

    // Helper mapping function
    Offset map(double x, double y) {
      double sx = size.width / 2 + (x / graphWidth) * size.width;
      double sy = size.height / 2 - (y / graphHeight) * size.height;
      return Offset(sx, sy);
    }

    // 1. Draw Grid
    // We scale the stroke widths inversely by the current viewer scale so they always
    // remain consistently thick, giving the illusion of a true vector zoom.
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1 / currentScale;

    // Expanding the range so panning around reveals more grid lines
    for (int i = -20; i <= 20; i++) {
      canvas.drawLine(map(i.toDouble(), -50), map(i.toDouble(), 50), gridPaint);
    }
    for (int i = -50; i <= 50; i += 2) {
      canvas.drawLine(map(-20, i.toDouble()), map(20, i.toDouble()), gridPaint);
    }

    // 2. Draw Axes
    final xAxisPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2 / currentScale;
    final yAxisPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2 / currentScale;
    canvas.drawLine(map(-20, 0), map(20, 0), xAxisPaint);
    canvas.drawLine(map(0, -50), map(0, 50), yAxisPaint);

    // Axis Labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final double fontSize = 10 / currentScale;

    for (int i = -20; i <= 20; i++) {
      if (i == 0) continue;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(color: Colors.redAccent, fontSize: fontSize),
      );
      textPainter.layout();
      Offset pos = map(i.toDouble(), 0);
      textPainter.paint(
        canvas,
        pos + Offset(-textPainter.width / 2, 4 / currentScale),
      );
    }

    for (int i = -50; i <= 50; i += 2) {
      if (i == 0) continue;
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(color: Colors.blueAccent, fontSize: fontSize),
      );
      textPainter.layout();
      Offset pos = map(0, i.toDouble());
      textPainter.paint(
        canvas,
        pos + Offset(4 / currentScale, -textPainter.height / 2),
      );
    }

    // 3. Draw Track
    if (isBuilt) {
      final trackPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 / currentScale
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      bool first = true;
      for (double x = -10; x <= 10; x += 0.1) {
        double y = track.formula(x);
        Offset pt = map(x, y);
        if (first) {
          path.moveTo(pt.dx, pt.dy);
          first = false;
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, trackPaint);
    }

    // 4. Draw Found Roots
    final rootPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    final rootBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 / currentScale;
    for (double root in foundRoots) {
      Offset pos = map(root, 0);
      canvas.drawCircle(pos, 8 / currentScale, rootPaint);
      canvas.drawCircle(pos, 8 / currentScale, rootBorder);
    }

    // 5. Draw Coaster Animation
    if (isBuilt && coasterProgress > 0) {
      double coasterX = -4 + (coasterProgress * 8); // Move from -4 to 4
      double coasterY = track.formula(coasterX);
      Offset coasterPos = map(coasterX, coasterY);

      final cartPaint = Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.fill;
      final cartGlow = Paint()
        ..color = Colors.yellowAccent.withOpacity(0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 / currentScale);

      canvas.drawCircle(coasterPos, 12 / currentScale, cartGlow);
      canvas.drawCircle(coasterPos, 6 / currentScale, cartPaint);
    }

    // 6. Draw Miss Flash
    if (missFlashPos != null && flashValue > 0 && flashValue < 1) {
      double radius = (10 + (flashValue * 30)) / currentScale;
      double opacity = 1 - flashValue;
      final missPaint = Paint()
        ..color = Colors.red.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 / currentScale;
      canvas.drawCircle(missFlashPos!, radius, missPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CoasterPainter oldDelegate) {
    return oldDelegate.isIdentifying != isIdentifying ||
        oldDelegate.isBuilt != isBuilt ||
        oldDelegate.foundRoots.length != foundRoots.length ||
        oldDelegate.coasterProgress != coasterProgress ||
        oldDelegate.flashValue != flashValue ||
        oldDelegate.track.id != track.id ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.currentScale != currentScale;
  }
}
