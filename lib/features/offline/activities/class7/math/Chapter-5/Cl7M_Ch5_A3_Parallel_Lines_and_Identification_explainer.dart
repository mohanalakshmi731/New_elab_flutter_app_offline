// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Parallel Lines & Transversals',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF020617),
      ),
      debugShowCheckedModeBanner: false,
      home: const ParallelLinesLab(),
    ),
  );
}

class ParallelLinesLab extends StatefulWidget {
  const ParallelLinesLab({super.key});

  @override
  State<ParallelLinesLab> createState() => _ParallelLinesLabState();
}

class _ParallelLinesLabState extends State<ParallelLinesLab>
    with TickerProviderStateMixin {
  // Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';

  bool _isSidebarOpen = true;
  String _currentLang = 'en';
  int _scenario = 1;
  int _step = 0;

  bool _showSummary = false;
  bool _showSuccess = false;
  final Set<int> _completedScenarios = {};
  bool _actionValidated = false;

  // Draggable Modal Positions
  Offset? _summaryModalPos;
  Offset? _successModalPos;

  // Canvas Panning & Zooming
  double _canvasZoom = 1.0;
  double _baseZoom = 1.0;
  Offset _canvasPan = Offset.zero;
  Offset _basePan = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

  // Shutter State
  bool _shutterOpen = false;
  bool _shutterActive = true;

  // --- Mapped States ---
  String? _activeDragType;
  Map<String, dynamic> _dragData = {};

  // S1 State
  double _s1Tilt = 30.0;
  double _s1MAngle = 20.0;
  bool _s1Matched = false;
  double? _s1InitialMatchedTilt;
  bool _s1MovedM = false;

  // S2 State
  double _s2Tilt = 30.0;
  Offset _s2Tracer = Offset.zero;
  bool _s2TracerMatched = false;
  bool _s2TransMoved = false;

  // S3 State
  final double _s3Tilt = 20.0;
  List<Map<String, dynamic>> _s3Angles = [
    {'id': 1, 'matched': false},
    {'id': 2, 'matched': false},
    {'id': 3, 'matched': false},
    {'id': 4, 'matched': true},
    {'id': 5, 'matched': false},
    {'id': 6, 'matched': false},
    {'id': 7, 'matched': false},
    {'id': 8, 'matched': false},
  ];
  int? _s3TargetAngle = 2;
  bool _s3Animating = false;
  double _s3AnimProgress = 0.0;

  // S4 State
  double _s4BotAngle = -25.0;
  Offset _s4Pro = const Offset(250, 200);
  bool _s4ProSnapped = false;
  bool _s4TrainRunning = false;
  Offset _s4TrainPos = const Offset(-400, -100);
  double _s4TrainRot = 0.0;

  // S5 State
  double _s5AltAngle = 50.0;
  bool _s5LaserRunning = false;
  double _s5LaserProgress = 0.0;
  bool _s5LaserHit = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _clickPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    super.dispose();
  }

  void _playSound(AudioPlayer player, String url) async {
    try {
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _loadScenario(int id) {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _scenario = id;
      _step = 0;
      _showSummary = false;
      _actionValidated = false;
      _activeDragType = null;
      _canvasZoom = 1.0;
      _canvasPan = Offset.zero;

      if (id == 1) {
        _s1Tilt = 30.0;
        _s1MAngle = 20.0;
        _s1Matched = false;
        _s1MovedM = false;
        _s1InitialMatchedTilt = null;
      }
      if (id == 2) {
        _s2Tilt = 30.0;
        _s2TracerMatched = false;
        _s2TransMoved = false;
        _s2Tracer = Offset(
          tan(30 * pi / 180) * 150,
          -150,
        ); // Set to top intersection
      }
      if (id == 3) {
        _s3Angles = [
          {'id': 1, 'matched': false},
          {'id': 2, 'matched': false},
          {'id': 3, 'matched': false},
          {'id': 4, 'matched': true},
          {'id': 5, 'matched': false},
          {'id': 6, 'matched': false},
          {'id': 7, 'matched': false},
          {'id': 8, 'matched': false},
        ];
        _s3TargetAngle = 2;
        _s3Animating = false;
      }
      if (id == 4) {
        _s4BotAngle = -25.0;
        _s4Pro = const Offset(250, 200);
        _s4ProSnapped = false;
        _s4TrainRunning = false;
        _s4TrainPos = const Offset(-400, -100);
        _s4TrainRot = 0;
      }
      if (id == 5) {
        _s5AltAngle = 50.0;
        _s5LaserRunning = false;
        _s5LaserProgress = 0.0;
        _s5LaserHit = false;
      }
    });
  }

  void _markStepComplete([int delay = 1500]) {
    if (_actionValidated) return;
    _actionValidated = true;
    _playSound(_successPlayer, _successUrl);

    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _step++;
        _actionValidated = false;

        int maxSteps = _getScenarioSteps(_scenario).length;
        if (_step >= maxSteps) {
          _step = maxSteps - 1;
          _showSummary = true;
          _summaryModalPos = null;
          _completedScenarios.add(_scenario);
          if (_completedScenarios.length == 5) {
            _showSuccess = true;
            _successModalPos = null;
          }
        }
      });
    });
  }

  void _masterReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      _showSuccess = false;
      _showSummary = false;
      _completedScenarios.clear();
      _shutterOpen = false;
      _shutterActive = true;
      _currentLang = 'en';
      _loadScenario(1);
    });
  }

  String t(String key) {
    return _translations[_currentLang]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  final Color _bg = const Color(0xFF020617);
  final Color _text = const Color(0xFFf8fafc);
  final Color _panel = const Color(0xFF1E293B).withOpacity(0.85);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final sidebarWidth = sw * 0.35;
    final contentWidth = sw - (_isSidebarOpen ? sidebarWidth : 0);

    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Center Canvas Activity
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Stack(
                  children: [
                    // Canvas Area
                    Positioned.fill(
                      child: Builder(
                        builder: (context) {
                          return _buildCanvasArea(contentWidth, sh);
                        },
                      ),
                    ),

                    // Active Step Info (when sidebar closed) - Floating on TOP
                    if (!_isSidebarOpen)
                      Positioned(
                        top: 80,
                        left: 16,
                        width: 280,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${_step + 1}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${t('stepLabel')} ${_step + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getScenarioSteps(_scenario)[_step]['text'] ??
                                    '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Floating Center Info HUD
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.indigo.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            _getScenarioSteps(_scenario)[_step]['hud'] ?? '',
                            style: TextStyle(
                              color: _text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Left Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: _panel,
                  border: Border(
                    right: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: _buildSidebarContent(),
              ),
            ),

            // Menu Icon
            Positioned(
              top: 16,
              left: 16, // Fixed position, won't slide with sidebar
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound(_clickPlayer, _clickUrl);
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // Draggable Modals
            if (_showSummary) _buildSummaryModal(sw, sh),
            if (_showSuccess) _buildSuccessModal(sw, sh),

            // Shutter Screen
            if (_shutterActive) _buildShutterScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
      top: _shutterOpen ? -MediaQuery.of(context).size.height : 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height,
      child: Container(
        color: const Color(0xFF020617),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.architecture,
                  size: 50,
                  color: Color(0xFF020617),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t('appTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t('appSubtitle'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.science, color: Colors.black),
                label: Text(
                  t('enterLab'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                onPressed: () {
                  _playSound(_shutterPlayer, _shutterUrl);
                  setState(() => _shutterOpen = true);
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    if (mounted) setState(() => _shutterActive = false);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.architecture,
                      color: Colors.amber,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('appTitle'),
                            style: TextStyle(
                              color: _text,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('appSubtitle'),
                            style: TextStyle(
                              color: _text.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Language and Reset Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.language, size: 16),
                        label: FittedBox(
                          child: Text(_currentLang.toUpperCase()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                        onPressed: () {
                          _playSound(_clickPlayer, _clickUrl);
                          setState(() {
                            if (_currentLang == 'en') {
                              _currentLang = 'hi';
                            } else {
                              _currentLang = 'en';
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        label: FittedBox(child: Text(t('resetLab'))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                        onPressed: _masterReset,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(color: _text.withOpacity(0.1), height: 1),
                ),

                Text(
                  t('selectScenario'),
                  style: TextStyle(
                    color: _text.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _text.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _scenario,
                      isExpanded: true,
                      dropdownColor: _panel,
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      items:
                          [1, 2, 3, 4, 5]
                              .map(
                                (id) => DropdownMenuItem(
                                  value: id,
                                  child: Text(
                                    t('scen${id}Title'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v != null) _loadScenario(v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Theory (Observation Notes)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _text.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book, color: _text, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            t('theory'),
                            style: TextStyle(
                              color: _text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('missionObj'),
                        style: TextStyle(
                          color: _text,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('s${_scenario}Obj'),
                        style: TextStyle(
                          color: _text.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Steps (Discoveries)
                Row(
                  children: [
                    Icon(Icons.list_alt, color: _text, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t('procSteps'),
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildStepsList(),

                // Scenario Completed Indicator
                if (_completedScenarios.contains(_scenario))
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('scenarioCompletedText'),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Footer (Not Translated)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    style: TextStyle(
                      color: _text.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStepsList() {
    final steps = _getScenarioSteps(_scenario);
    return List.generate(steps.length, (index) {
      bool isPast = index < _step;
      bool isActive = index == _step;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isActive
                  ? Colors.amber.withOpacity(0.9)
                  : (isPast ? Colors.white10 : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.amber : _text.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPast)
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 24,
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? Colors.indigo : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.indigo : _text.withOpacity(0.5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : _text,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t('stepLabel')} ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black87 : _text.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps[index]['text']!,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isActive
                              ? Colors.black
                              : (isPast ? _text.withOpacity(0.5) : _text),
                      decoration: isPast ? TextDecoration.lineThrough : null,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- CANVAS INTERACTION & SCALING LOGIC ---
  Offset _getTopIntersection(double tiltDeg) {
    double rad = tiltDeg * pi / 180;
    return Offset(tan(rad) * 150, -150);
  }

  Offset _getBotIntersection(double tiltDeg) {
    double rad = tiltDeg * pi / 180;
    return Offset(-tan(rad) * 150, 150);
  }

  Offset _getCanvasPos(Offset localPos, double baseScale, double w, double h) {
    double x =
        (localPos.dx - w / 2 - _canvasPan.dx) / (baseScale * _canvasZoom);
    double y =
        (localPos.dy - h / 2 - _canvasPan.dy) / (baseScale * _canvasZoom);
    return Offset(x, y);
  }

  Widget _buildCanvasArea(double w, double h) {
    final baseScale = min(w / 1000, h / 1000);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) {
        _baseZoom = _canvasZoom;
        _basePan = _canvasPan;
        _startFocalPoint = details.localFocalPoint;
        Offset pt = _getCanvasPos(details.localFocalPoint, baseScale, w, h);
        _handleInteractionStart(pt);
      },
      onScaleUpdate: (details) {
        if (_activeDragType != null && _activeDragType != 'canvas') {
          Offset pt = _getCanvasPos(details.localFocalPoint, baseScale, w, h);
          _handleInteractionUpdateAbsolute(pt);
        } else {
          setState(() {
            _canvasZoom = (_baseZoom * details.scale).clamp(0.2, 3.0);
            _canvasPan =
                _basePan + (details.localFocalPoint - _startFocalPoint);
          });
        }
      },
      onScaleEnd: (details) {
        _handleInteractionEnd();
      },
      onTapUp: (details) {
        Offset pt = _getCanvasPos(details.localPosition, baseScale, w, h);
        _handleInteractionTap(pt);
      },
      child: ClipRect(
        child: CustomPaint(
          size: Size(w, h),
          painter: MasterPainter(
            baseScale: baseScale,
            canvasZoom: _canvasZoom,
            canvasPan: _canvasPan,
            scenario: _scenario,
            step: _step,
            s1Tilt: _s1Tilt,
            s1MAngle: _s1MAngle,
            s1Matched: _s1Matched,
            s1MovedM: _s1MovedM,
            s2Tilt: _s2Tilt,
            s2Tracer: _s2Tracer,
            s2TracerMatched: _s2TracerMatched,
            s3Tilt: _s3Tilt,
            s3Angles: _s3Angles,
            s3AnimProgress: _s3AnimProgress,
            s3Animating: _s3Animating,
            s4BotAngle: _s4BotAngle,
            s4Pro: _s4Pro,
            s4ProSnapped: _s4ProSnapped,
            s4TrainPos: _s4TrainPos,
            s4TrainRot: _s4TrainRot,
            s5AltAngle: _s5AltAngle,
            s5LaserProgress: _s5LaserProgress,
            s5LaserHit: _s5LaserHit,
            s5LaserRunning: _s5LaserRunning,
          ),
        ),
      ),
    );
  }

  void _handleInteractionTap(Offset pt) {
    if (_actionValidated) return;

    if (_scenario == 3 && !_s3Animating) {
      double tAngle = -90 + _s3Tilt;
      Offset intTop = _getTopIntersection(_s3Tilt);
      Offset intBot = _getBotIntersection(_s3Tilt);

      Map<int, Map<String, dynamic>> angleDefs = {
        1: {'start': 180.0, 'end': tAngle, 'c': intTop},
        2: {'start': tAngle, 'end': 0.0, 'c': intTop},
        4: {'start': tAngle + 180.0, 'end': 180.0, 'c': intTop},
        3: {'start': 0.0, 'end': tAngle + 180.0, 'c': intTop},
        5: {'start': 180.0, 'end': tAngle, 'c': intBot},
        6: {'start': tAngle, 'end': 0.0, 'c': intBot},
        7: {'start': tAngle + 180.0, 'end': 180.0, 'c': intBot},
        8: {'start': 0.0, 'end': tAngle + 180.0, 'c': intBot},
      };

      for (var entry in angleDefs.entries) {
        int id = entry.key;
        var def = entry.value;
        Offset center = def['c'];

        double dx = pt.dx - center.dx;
        double dy = pt.dy - center.dy;
        double dist = sqrt(dx * dx + dy * dy);

        if (dist <= 80) {
          double angleDeg = atan2(dy, dx) * 180 / pi;
          if (angleDeg < 0) angleDeg += 360;

          double s = def['start'] % 360;
          if (s < 0) s += 360;
          double e = def['end'] % 360;
          if (e < 0) e += 360;

          bool inside = false;
          if (s < e) {
            inside = angleDeg >= s && angleDeg <= e;
          } else {
            inside = angleDeg >= s || angleDeg <= e;
          }

          if (inside) {
            _handleS3AngleClick(id);
            return;
          }
        }
      }
    } else if (_scenario == 4) {
      if (Rect.fromLTWH(-60, 275, 120, 50).contains(pt) &&
          _step >= 2 &&
          !_s4TrainRunning) {
        _runS4Train();
      }
    } else if (_scenario == 5) {
      if (Rect.fromLTWH(-100, 275, 200, 50).contains(pt) &&
          (_step == 0 || _step == 2) &&
          !_s5LaserRunning) {
        _runS5Laser();
      }
    }
  }

  void _handleS3AngleClick(int id) {
    if (_s3TargetAngle == id) {
      setState(() {
        _s3Angles.firstWhere((a) => a['id'] == id)['matched'] = true;
      });
      _playSound(_clickPlayer, _clickUrl);

      if (_step == 0) {
        _s3TargetAngle = 6;
        _markStepComplete(1500);
      } else if (_step == 1) {
        _s3TargetAngle = null;
        _markStepComplete(1000);
        _runS3Animation();
      }
    } else {
      var a = _s3Angles.firstWhere((a) => a['id'] == id);
      if (!a['matched']) {
        _playSound(_errorPlayer, _errorUrl);
      }
    }
  }

  void _runS3Animation() {
    setState(() => _s3Animating = true);
    _playSound(_clickPlayer, _clickUrl);

    int startTime = DateTime.now().millisecondsSinceEpoch;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      double progress = (now - startTime) / 3000.0;
      if (progress >= 1.0) {
        timer.cancel();
        setState(() {
          _s3Animating = false;
          _s3AnimProgress = 0.0;
        });
      } else {
        setState(() {
          _s3AnimProgress = Curves.easeInOutCubic.transform(progress);
        });
      }
    });
  }

  void _runS4Train() {
    setState(() {
      _s4TrainRunning = true;
      _s4TrainPos = const Offset(-400, -100);
    });
    _playSound(_clickPlayer, _clickUrl);

    bool isParallel = _s4BotAngle.abs() < 2;
    int startTime = DateTime.now().millisecondsSinceEpoch;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      double progress = (now - startTime) / 3000.0;
      if (progress >= 1.0) progress = 1.0;

      double px, py, rot;
      if (progress < 0.33) {
        double p = progress / 0.33;
        px = -400 + p * 373;
        py = -100;
        rot = 0;
      } else if (progress < 0.66) {
        double p = (progress - 0.33) / 0.33;
        px = -27 + p * 54;
        py = -100 + p * 200;
        rot = 75;
      } else {
        double p = (progress - 0.66) / 0.34;
        if (isParallel) {
          px = 27 + p * 400;
          py = 100;
          rot = 0;
        } else {
          px = 27 + p * 200;
          py = 100 + p * 200;
          rot = 75 + p * 90;
        }
      }

      setState(() {
        _s4TrainPos = Offset(px, py);
        _s4TrainRot = rot;
      });

      if (progress >= 1.0) {
        timer.cancel();
        if (isParallel) {
          _playSound(_successPlayer, _successUrl);
          if (_step == 2) _markStepComplete(1500);
          setState(() => _s4TrainRunning = false);
        } else {
          _playSound(_errorPlayer, _errorUrl);
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _s4TrainRunning = false;
                _s4TrainPos = const Offset(-400, -100);
                _s4TrainRot = 0;
              });
            }
          });
        }
      }
    });
  }

  void _runS5Laser() {
    setState(() {
      _s5LaserRunning = true;
      _s5LaserProgress = 0.0;
      _s5LaserHit = false;
    });
    _playSound(_clickPlayer, _clickUrl);

    bool isParallel = (_s5AltAngle - 110).abs() < 2;
    int startTime = DateTime.now().millisecondsSinceEpoch;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      int now = DateTime.now().millisecondsSinceEpoch;
      double progress = (now - startTime) / 600.0;
      if (progress >= 1.0) progress = 1.0;

      setState(() {
        _s5LaserProgress = progress;
      });

      if (progress >= 1.0) {
        timer.cancel();
        if (isParallel) {
          setState(() {
            _s5LaserHit = true;
          });
          _playSound(_successPlayer, _successUrl);
          if (_step == 2 || _step == 0) _markStepComplete(1500);
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _s5LaserHit = false;
                _s5LaserRunning = false;
              });
            }
          });
        } else {
          _playSound(_errorPlayer, _errorUrl);
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _s5LaserRunning = false;
              });
            }
          });
          if (_step == 0) _markStepComplete(1000);
        }
      }
    });
  }

  void _handleInteractionStart(Offset pt) {
    if (_actionValidated) return;
    _activeDragType = null;
    _dragData.clear();

    if (_scenario == 1) {
      if (_step <= 1) {
        double rad = _s1MAngle * pi / 180;
        Offset intBot = _getBotIntersection(_s1Tilt);
        double hX = intBot.dx + 250 * cos(rad);
        double hY = intBot.dy + 250 * sin(rad);

        if (sqrt(pow(pt.dx - hX, 2) + pow(pt.dy - hY, 2)) < 50) {
          _activeDragType = 's1_m';
          _dragData = {'cX': intBot.dx, 'cY': intBot.dy};
          _playSound(_clickPlayer, _clickUrl);
          setState(() => _s1MovedM = true);
          return;
        }
      }
      if (_step == 2) {
        double tiltRad = _s1Tilt * pi / 180;
        double hX = 300 * sin(tiltRad);
        double hY = -300 * cos(tiltRad);
        if (sqrt(pow(pt.dx - hX, 2) + pow(pt.dy - hY, 2)) < 50) {
          _activeDragType = 's1_t';
          _s1InitialMatchedTilt = _s1Tilt;
          _playSound(_clickPlayer, _clickUrl);
          return;
        }
      }
    } else if (_scenario == 2) {
      if (sqrt(
            pow(pt.dx - (_s2Tracer.dx + 40), 2) +
                pow(pt.dy - (_s2Tracer.dy - 30), 2),
          ) <
          60) {
        _activeDragType = 's2_tracer';
        _dragData = {
          'offsetX': _s2Tracer.dx - pt.dx,
          'offsetY': _s2Tracer.dy - pt.dy,
        };
        setState(() => _s2TracerMatched = false);
        _playSound(_clickPlayer, _clickUrl);
        if (_step == 0) _markStepComplete(100);
        return;
      }
      if (_step == 2) {
        double tiltRad = _s2Tilt * pi / 180;
        double hX = 300 * sin(tiltRad);
        double hY = -300 * cos(tiltRad);
        if (sqrt(pow(pt.dx - hX, 2) + pow(pt.dy - hY, 2)) < 60) {
          _activeDragType = 's2_t';
          _playSound(_clickPlayer, _clickUrl);
          return;
        }
      }
    } else if (_scenario == 4) {
      if (_step == 0 &&
          sqrt(pow(pt.dx - _s4Pro.dx, 2) + pow(pt.dy - _s4Pro.dy, 2)) < 80) {
        _activeDragType = 's4_pro';
        _dragData = {
          'offsetX': _s4Pro.dx - pt.dx,
          'offsetY': _s4Pro.dy - pt.dy,
        };
        _playSound(_clickPlayer, _clickUrl);
        return;
      }
      if (_step == 1 && _s4ProSnapped) {
        double rad = _s4BotAngle * pi / 180;
        double hX = 27 + cos(rad) * 200;
        double hY = 100 + sin(rad) * 200;
        if (sqrt(pow(pt.dx - hX, 2) + pow(pt.dy - hY, 2)) < 60) {
          _activeDragType = 's4_rail';
          _dragData = {'cX': 27.0, 'cY': 100.0};
          _playSound(_clickPlayer, _clickUrl);
          return;
        }
      }
    } else if (_scenario == 5) {
      if (_step == 1) {
        double alphaOut = 110 - _s5AltAngle;
        double hRad = alphaOut * pi / 180;
        double hX = 120 + 100 * cos(hRad);
        double hY = 100 + 100 * sin(hRad);
        if (sqrt(pow(pt.dx - hX, 2) + pow(pt.dy - hY, 2)) < 60) {
          _activeDragType = 's5_m2';
          _dragData = {'cX': 120.0, 'cY': 100.0};
          _playSound(_clickPlayer, _clickUrl);
          return;
        }
      }
    }

    _activeDragType = 'canvas';
  }

  void _handleInteractionUpdateAbsolute(Offset pt) {
    setState(() {
      if (_activeDragType == 's1_m') {
        if (_s1Matched && _step > 1) return;
        double angleRad = atan2(
          pt.dy - _dragData['cY'],
          pt.dx - _dragData['cX'],
        );
        double angleDeg = angleRad * 180 / pi;
        if (angleDeg > 45) angleDeg = 45;
        if (angleDeg < -45) angleDeg = -45;

        if (angleDeg.abs() < 3) {
          angleDeg = 0;
          if (!_s1Matched) {
            _s1Matched = true;
            _playSound(_successPlayer, _successUrl);
            if (_step == 1) _markStepComplete(1500);
          }
        } else {
          _s1Matched = false;
        }
        _s1MAngle = angleDeg;
      } else if (_activeDragType == 's1_t' || _activeDragType == 's2_t') {
        double angleRad = atan2(pt.dy, pt.dx);
        double tilt = angleRad * 180 / pi + 90;
        if (tilt > 50) tilt = 50;
        if (tilt < -50) tilt = -50;

        if (_activeDragType == 's1_t') {
          _s1Tilt = tilt;
          if (_step == 2 &&
              _s1InitialMatchedTilt != null &&
              (_s1Tilt - _s1InitialMatchedTilt!).abs() > 15) {
            _markStepComplete(2000);
          }
        } else {
          _s2Tilt = tilt;
          _s2TracerMatched = false;
          if (_step == 2) _s2TransMoved = true;
        }
      } else if (_activeDragType == 's2_tracer') {
        _s2Tracer = Offset(
          pt.dx + _dragData['offsetX'],
          pt.dy + _dragData['offsetY'],
        );
      } else if (_activeDragType == 's4_pro') {
        _s4Pro = Offset(
          pt.dx + _dragData['offsetX'],
          pt.dy + _dragData['offsetY'],
        );
      } else if (_activeDragType == 's4_rail') {
        double angleRad = atan2(
          pt.dy - _dragData['cY'],
          pt.dx - _dragData['cX'],
        );
        double angleDeg = angleRad * 180 / pi;
        if (angleDeg > 45) angleDeg = 45;
        if (angleDeg < -45) angleDeg = -45;
        if (angleDeg.abs() < 3) {
          angleDeg = 0;
          if (_step == 1 && _s4BotAngle != 0) {
            _playSound(_successPlayer, _successUrl);
            _markStepComplete(1000);
          }
        }
        _s4BotAngle = angleDeg;
      } else if (_activeDragType == 's5_m2') {
        double angleRad = atan2(
          pt.dy - _dragData['cY'],
          pt.dx - _dragData['cX'],
        );
        double angleDeg = angleRad * 180 / pi;
        double altAngle = 110 - angleDeg;
        if (altAngle < 50) altAngle = 50;
        if (altAngle > 170) altAngle = 170;
        if ((altAngle - 110).abs() < 4) {
          altAngle = 110;
          if (_step == 1 && _s5AltAngle != 110) {
            _playSound(_successPlayer, _successUrl);
            _markStepComplete(1000);
          }
        }
        _s5AltAngle = altAngle;
      }
    });
  }

  void _handleInteractionEnd() {
    if (_activeDragType == null) return;

    setState(() {
      if (_activeDragType == 's1_m' && _step == 0 && _s1MovedM) {
        _markStepComplete(100);
      } else if (_activeDragType == 's2_tracer') {
        Offset intBot = _getBotIntersection(_s2Tilt);
        if (sqrt(
              pow(_s2Tracer.dx - intBot.dx, 2) +
                  pow(_s2Tracer.dy - intBot.dy, 2),
            ) <
            60) {
          _s2Tracer = intBot;
          _s2TracerMatched = true;
          _playSound(_successPlayer, _successUrl);
          if (_step == 1) {
            _markStepComplete(1500);
          } else if (_step == 2 && _s2TransMoved) {
            _markStepComplete(1500);
          }
        } else {
          _playSound(_errorPlayer, _errorUrl);
        }
      } else if (_activeDragType == 's4_pro') {
        if (sqrt(pow(_s4Pro.dx - (-27), 2) + pow(_s4Pro.dy - (-100), 2)) < 60) {
          _s4Pro = const Offset(-27, -100);
          _s4ProSnapped = true;
          _playSound(_successPlayer, _successUrl);
          if (_step == 0) _markStepComplete(1000);
        } else {
          _s4Pro = const Offset(250, 200);
          _playSound(_errorPlayer, _errorUrl);
        }
      }

      if (_activeDragType != 'canvas') {
        _playSound(_clickPlayer, _clickUrl);
      }
    });
    _activeDragType = null;
  }

  // --- DRAGGABLE MODALS ---
  Widget _buildSummaryModal(double sw, double sh) {
    _summaryModalPos ??= Offset(sw / 2 - 200, sh / 2 - 150);

    return Positioned(
      left: _summaryModalPos!.dx,
      top: _summaryModalPos!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _summaryModalPos = _summaryModalPos! + details.delta;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
            constraints: BoxConstraints(maxHeight: sh * 0.8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.amber,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t('labSummary'),
                            style: TextStyle(
                              color: _text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: _text),
                        onPressed: () {
                          _playSound(_clickPlayer, _clickUrl);
                          setState(() => _showSummary = false);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getScenarioSteps(_scenario).last['summary'] ?? '',
                      style: TextStyle(
                        color: _text,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
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

  Widget _buildSuccessModal(double sw, double sh) {
    _successModalPos ??= Offset(sw / 2 - 200, sh / 2 - 180);

    return Positioned(
      left: _successModalPos!.dx,
      top: _successModalPos!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _successModalPos = _successModalPos! + details.delta;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
            constraints: BoxConstraints(maxHeight: sh * 0.9),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    t('allCompletedTitle'),
                    style: TextStyle(
                      color: _text,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('allCompletedText'),
                    style: TextStyle(
                      color: _text.withOpacity(0.8),
                      fontSize: 14,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      t('restartLab'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _masterReset,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- DATA / TRANSLATIONS ---
  List<Map<String, String>> _getScenarioSteps(int id) {
    if (id == 1) {
      return [
        {'hud': t('s1_1_hud'), 'text': t('s1_1_txt')},
        {'hud': t('s1_2_hud'), 'text': t('s1_2_txt')},
        {'hud': t('s1_3_hud'), 'text': t('s1_3_txt'), 'summary': t('s1_4_sum')},
      ];
    }
    if (id == 2) {
      return [
        {'hud': t('s2_1_hud'), 'text': t('s2_1_txt')},
        {'hud': t('s2_2_hud'), 'text': t('s2_2_txt')},
        {'hud': t('s2_3_hud'), 'text': t('s2_3_txt'), 'summary': t('s2_4_sum')},
      ];
    }
    if (id == 3) {
      return [
        {'hud': t('s3_1_hud'), 'text': t('s3_1_txt')},
        {'hud': t('s3_2_hud'), 'text': t('s3_2_txt'), 'summary': t('s3_3_sum')},
      ];
    }
    if (id == 4) {
      return [
        {'hud': t('s4_1_hud'), 'text': t('s4_1_txt')},
        {'hud': t('s4_2_hud'), 'text': t('s4_2_txt')},
        {'hud': t('s4_3_hud'), 'text': t('s4_3_txt'), 'summary': t('s4_4_sum')},
      ];
    }
    if (id == 5) {
      return [
        {'hud': t('s5_1_hud'), 'text': t('s5_1_txt')},
        {'hud': t('s5_2_hud'), 'text': t('s5_2_txt')},
        {'hud': t('s5_3_hud'), 'text': t('s5_3_txt'), 'summary': t('s5_4_sum')},
      ];
    }
    return [];
  }

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': "Transversal Detective",
      'appSubtitle': "Class 7 • PARALLEL AND INTERSECTING LINES",
      'enterLab': "Enter Lab",
      'resetLab': "Master Reset",
      'selectScenario': "Select Scenario",
      'procSteps': "Discoveries",
      'theory': "Observation Notes",
      'missionObj': "Mission Objective:",
      'stepLabel': "STEP",
      'labSummary': "Lab Summary",
      'allCompletedTitle': "Master of Transversals!",
      'allCompletedText':
          "You have successfully completed all challenges and proved the parallel code!",
      'restartLab': "Restart Lab",
      'scenarioCompletedText': "Scenario Completed!",
      'scen1Title': "1. The Angle Matcher",
      's1Obj':
          "To visually discover that lines become parallel when their corresponding angles are equal.",
      's1_1_hud': "DRAG the rotation handle on line 'm'.",
      's1_1_txt':
          "Observe the two blue lines, 'l' and 'm', and the yellow transversal line 't'. Notice the two angles highlighted in purple. They are in 'corresponding positions'.",
      's1_2_hud':
          "Rotate line 'm' until the two purple angles are exactly equal.",
      's1_2_txt':
          "Notice what happens when the two angles have the exact same measurement. The lines snap into a special relationship.",
      's1_3_hud': "DRAG the handle on transversal 't' to change its tilt.",
      's1_3_txt':
          "Observe how changing the transversal's tilt affects the corresponding angles. Do they remain equal?",
      's1_4_sum':
          "A Core Rule of Geometry!\nYou've successfully proved that when the corresponding angles are equal, the lines are perfectly parallel. No matter the angle of the transversal, this rule always holds true!",
      'scen2Title': "2. The Parallel Line Tracer",
      's2Obj':
          "To confirm that for a pair of parallel lines, the corresponding angles are always equal.",
      's2_1_hud': "DRAG the Tracing Tool down along the transversal.",
      's2_1_txt':
          "Here are two lines that are already parallel. A special 'Tracing Tool' is placed over the top angle. DRAG it down.",
      's2_2_hud': "Does it fit perfectly?",
      's2_2_txt':
          "Place the Tracing Tool exactly over the corresponding angle on the bottom line. Does it fit perfectly?",
      's2_3_hud': "First DRAG transversal, then DRAG Tracing Tool to compare.",
      's2_3_txt':
          "First, CLICK and DRAG the transversal to a new position, then DRAG the Tracing Tool to compare the new angles.",
      's2_4_sum':
          "Verification Complete!\nIf two lines are parallel, their corresponding angles will ALWAYS be equal, no matter how the transversal cuts them.",
      'scen3Title': "3. The Alternate Angle Connection",
      's3Obj':
          "To understand why alternate interior angles are equal by relating them to corresponding and vertically opposite angles.",
      's3_1_hud': "CLICK on the angle vertically opposite to the green angle.",
      's3_1_txt':
          "We have two parallel lines. An angle is highlighted in green. This is an 'interior' angle. First, CLICK on its vertically opposite angle.",
      's3_2_hud': "CLICK on the corresponding angle at the other intersection.",
      's3_2_txt':
          "Great! Vertically opposite angles are always equal. Now, the new green angle (∠2) has a corresponding angle at the other intersection. CLICK on its corresponding angle.",
      's3_3_sum':
          "Alternate Interior Angles\nLook at the path you made! These are called Alternate Interior Angles, and they are always equal when lines are parallel.",
      'scen4Title': "4. The Railway Fixer",
      's4Obj':
          "Apply the knowledge of corresponding angles to fix a pair of crooked railway tracks.",
      's4_1_hud': "DRAG Protractor and DROP it on the top intersection.",
      's4_1_txt':
          "This railway track is broken! The top rail is fixed, but the bottom is crooked. DRAG the 'Digital Protractor' to the top intersection to measure the angle.",
      's4_2_hud': "Rotate bottom rail until its angle also becomes 75°.",
      's4_2_txt':
          "You measured 75°. Now, DRAG the handle on the bottom rail to rotate it until its corresponding angle also becomes 75°.",
      's4_3_hud': "CLICK the 'Go' button.",
      's4_3_txt':
          "The angles match! Let's see if the train can pass safely. CLICK the 'Go' button.",
      's4_4_sum':
          "Engineering Success!\nBy ensuring the corresponding angles were equal, you guaranteed the tracks were perfectly parallel. The train passed safely!",
      'scen5Title': "5. The Laser Grid Puzzle",
      's5Obj':
          "Apply the property of alternate interior angles to align a laser beam through a maze.",
      's5_1_hud': "CLICK the 'Activate Laser' button to see the current path.",
      's5_1_txt':
          "Your mission is to guide the laser to the target. The incoming and outgoing laser paths must be parallel. The first mirror's angle is 110°. CLICK 'Activate Laser'.",
      's5_2_hud': "Rotate second mirror until its angle becomes 110°.",
      's5_2_txt':
          "The laser missed! For the paths to be parallel, the alternate interior angles must be equal. DRAG the second mirror to rotate it to 110°.",
      's5_3_hud': "CLICK 'Activate Laser' to hit the target!",
      's5_3_txt':
          "The angles are equal! The laser paths should now be parallel. CLICK 'Activate Laser' to hit the target!",
      's5_4_sum':
          "Puzzle Solved!\nYou used Alternate Interior Angles to align the mirrors perfectly. The incoming and outgoing beams are parallel.",
    },
    'hi': {
      'appTitle': "तिर्यक रेखा जासूस",
      'appSubtitle': "कक्षा 7 • समांतर और प्रतिच्छेदी रेखाएं",
      'enterLab': "प्रवेश करें",
      'resetLab': "मास्टर रीसेट",
      'selectScenario': "परिदृश्य चुनें",
      'procSteps': "खोज",
      'theory': "अवलोकन नोट्स",
      'missionObj': "उद्देश्य:",
      'stepLabel': "चरण",
      'labSummary': "सारांश",
      'allCompletedTitle': "महारत हासिल!",
      'allCompletedText':
          "आपने समांतर रेखाओं और उनके कोणों के कोड को सफलतापूर्वक क्रैक कर लिया है!",
      'restartLab': "लैब रीस्टार्ट करें",
      'scenarioCompletedText': "परिदृश्य पूरा हुआ!",
      'scen1Title': "1. कोण मिलान",
      's1Obj':
          "यह देखने के लिए कि जब उनके संगत कोण समान होते हैं तो रेखाएँ समानांतर हो जाती हैं।",
      's1_1_hud': "घुमाने के लिए रेखा 'm' पर हैंडल खींचें।",
      's1_1_txt':
          "दो नीली रेखाएं 'l' और 'm', और पीली तिर्यक रेखा 't' का निरीक्षण करें। बैंगनी रंग में हाइलाइट किए गए दो कोणों पर ध्यान दें।",
      's1_2_hud': "दो बैंगनी कोणों को बराबर करें।",
      's1_2_txt':
          "ध्यान दें कि क्या होता है जब दोनों कोणों का माप बिल्कुल समान होता है। रेखाएँ एक विशेष संबंध में जुड़ जाती हैं।",
      's1_3_hud': "झुकाव बदलने के लिए तिर्यक रेखा 't' को खींचें।",
      's1_3_txt':
          "निरीक्षण करें कि तिर्यक रेखा का झुकाव बदलने से संगत कोण कैसे प्रभावित होते हैं।",
      's1_4_sum':
          "ज्यामिति का एक मूल नियम!\nजब संगत कोण समान होते हैं, तो रेखाएँ समानांतर होती हैं।",
      'scen2Title': "2. समानांतर रेखा ट्रेसर",
      's2Obj':
          "यह पुष्टि करने के लिए कि समांतर रेखाओं की एक जोड़ी के लिए, संगत कोण हमेशा समान होते हैं।",
      's2_1_hud': "ट्रेसिंग टूल को तिर्यक रेखा के साथ नीचे खींचें।",
      's2_1_txt':
          "यहाँ दो रेखाएँ हैं जो पहले से ही समानांतर हैं। शीर्ष कोण पर एक 'ट्रेसिंग टूल' रखा गया है। ट्रेसिंग टूल को तिर्यक रेखा के साथ नीचे खींचें।",
      's2_2_hud': "क्या यह पूरी तरह से फिट बैठता है?",
      's2_2_txt':
          "ट्रेसिंग टूल को नीचे की रेखा पर संगत कोण के ठीक ऊपर रखें। क्या यह पूरी तरह से फिट बैठता है?",
      's2_3_hud': "पहले तिर्यक रेखा को खींचें, फिर ट्रेसिंग टूल को खींचें।",
      's2_3_txt':
          "अब, इसे फिर से आज़माएँ। पहले, तिर्यक रेखा को खींचें। फिर तुलना करने के लिए ट्रेसिंग टूल को खींचें।",
      's2_4_sum':
          "सत्यापन पूर्ण\nयदि दो रेखाएँ समानांतर हैं, तो उनके संगत कोण हमेशा समान होंगे।",
      'scen3Title': "3. एकांतर कोण संबंध",
      's3Obj':
          "संगत और शीर्षाभिमुख कोणों से संबंधित करके यह समझना कि एकांतर अंतः कोण समान क्यों होते हैं।",
      's3_1_hud': "हरे कोण के शीर्षाभिमुख कोण पर क्लिक करें।",
      's3_1_txt':
          "एक आंतरिक कोण हरे रंग में हाइलाइट किया गया है। आइए इसे इसके शीर्षाभिमुख कोण से जोड़ें।",
      's3_2_hud': "दूसरे प्रतिच्छेदन पर नए हरे कोण के संगत कोण पर क्लिक करें।",
      's3_2_txt':
          "शीर्षाभिमुख कोण हमेशा समान होते हैं। अब, आइए इस नए हाइलाइट किए गए कोण के संगत कोण का पता लगाएं।",
      's3_3_sum':
          "एकांतर अंतः कोण\nएकांतर अंतः कोण हमेशा समान होते हैं जब रेखाएँ समानांतर होती हैं।",
      'scen4Title': "4. रेलवे फिक्सर",
      's4Obj':
          "टेढ़े रेलवे ट्रैक को ठीक करने के लिए संगत कोणों का ज्ञान लागू करें।",
      's4_1_hud': "कोण मापने के लिए प्रोट्रैक्टर को खींचें।",
      's4_1_txt':
          "शीर्ष रेल तय है, लेकिन नीचे की रेल टेढ़ी है। 'डिजिटल प्रोट्रैक्टर' को शीर्ष प्रतिच्छेदन पर खींचें और छोड़ें।",
      's4_2_hud': "नीचे की रेल पर हैंडल को 75° तक खींचें।",
      's4_2_txt':
          "आपने 75° मापा है। अब, नीचे की रेल पर हैंडल को तब तक खींचें जब तक कि उसका संगत कोण 75° न हो जाए।",
      's4_3_hud': "ट्रेन का परीक्षण करने के लिए 'Go' पर क्लिक करें।",
      's4_3_txt':
          "कोण मेल खाते हैं, इसलिए ट्रैक समानांतर होने चाहिए। 'Go' बटन पर क्लिक करें।",
      's4_4_sum':
          "इंजीनियरिंग सफलता!\nसंगत कोणों को समान सुनिश्चित करके, आपने पटरियों को पूरी तरह से समानांतर बनाया।",
      'scen5Title': "5. लेजर ग्रिड पहेली",
      's5Obj':
          "लेजर बीम को संरेखित करने के लिए एकांतर अंतः कोणों की संपत्ति लागू करें।",
      's5_1_hud': "वर्तमान पथ देखने के लिए 'Activate Laser' पर क्लिक करें।",
      's5_1_txt':
          "आपका मिशन लेजर को लक्ष्य तक ले जाना है। आने वाले लेजर और जाने वाले लेजर पथ समानांतर होने चाहिए। पहले दर्पण का कोण 110° है।",
      's5_2_hud': "दूसरे दर्पण को 110° तक खींचें।",
      's5_2_txt':
          "लेजर चूक गया! पथों के समानांतर होने के लिए, एकांतर अंतः कोण समान होने चाहिए। पहला कोण 110° है। दूसरे दर्पण को तब तक खींचें जब तक उसका कोण भी 110° न हो जाए।",
      's5_3_hud': "लक्ष्य को हिट करने के लिए 'Activate Laser' पर क्लिक करें!",
      's5_3_txt':
          "कोण समान हैं! लेजर पथ अब समानांतर होने चाहिए। लक्ष्य को हिट करने के लिए 'Activate Laser' पर क्लिक करें!",
      's5_4_sum':
          "पहेली हल!\nआपने दर्पणों को पूरी तरह से संरेखित करने के लिए एकांतर अंतः कोणों का उपयोग किया है।",
    },
    'te': {
      'appTitle': "తిర్యగ్రేఖ డిటెక్టివ్",
      'appSubtitle': "7వ తరగతి • సమాంతర మరియు ఖండించుకునే రేఖలు",
      'enterLab': "ల్యాబ్‌లోకి ప్రవేశించండి",
      'resetLab': "మొత్తం రీసెట్",
      'selectScenario': "సన్నివేశాన్ని ఎంచుకోండి",
      'procSteps': "కనుగొన్నవి",
      'theory': "పరిశీలనలు",
      'missionObj': "లక్ష్యం:",
      'stepLabel': "దశ",
      'labSummary': "సారాంశం",
      'allCompletedTitle': "లంబత్వంలో మాస్టర్!",
      'allCompletedText': "మీరు కోణాల నియమాలను విజయవంతంగా నేర్చుకున్నారు!",
      'restartLab': "ల్యాబ్‌ను పునఃప్రారంభించండి",
      'scenarioCompletedText': "సన్నివేశం పూర్తయింది!",
      'scen1Title': "1. కోణం మ్యాచర్",
      's1Obj':
          "సదృశ్య కోణాలు సమానంగా ఉన్నప్పుడు రేఖలు సమాంతరంగా మారతాయని దృశ్యమానంగా కనుగొనడం.",
      's1_1_hud': "దానిని తిప్పడానికి రేఖ 'm' పై హ్యాండిల్‌ను లాగండి.",
      's1_1_txt':
          "'l' మరియు 'm' అనే రెండు నీలి రేఖలను మరియు 't' అనే పసుపు తిర్యగ్రేఖను పరిశీలించండి. ఊదా రంగులో ఉన్న రెండు కోణాలను గమనించండి.",
      's1_2_hud': "రెండు ఊదా కోణాలను సమానంగా చేయండి.",
      's1_2_txt':
          "రెండు కోణాలు ఒకే కొలతను కలిగి ఉన్నప్పుడు ఏమి జరుగుతుందో గమనించండి. రేఖలు ఒక ప్రత్యేక సంబంధంలోకి వస్తాయి.",
      's1_3_hud': "వంపుని మార్చడానికి తిర్యగ్రేఖ 't' ని లాగండి.",
      's1_3_txt':
          "తిర్యగ్రేఖ వంపును మార్చడం ద్వారా సదృశ్య కోణాలు ఎలా ప్రభావితమవుతాయో గమనించండి.",
      's1_4_sum':
          "ఒక ప్రధాన నియమం!\nసదృశ్య కోణాలు సమానంగా ఉన్నప్పుడు, రేఖలు సమాంతరంగా ఉంటాయని మీరు నిరూపించారు.",
      'scen2Title': "2. సమాంతర రేఖ ట్రేసర్",
      's2Obj':
          "సమాంతర రేఖల జతకి, సదృశ్య కోణాలు ఎల్లప్పుడూ సమానంగా ఉంటాయని నిర్ధారించడానికి.",
      's2_1_hud': "ట్రేసింగ్ టూల్‌ను తిర్యగ్రేఖ వెంబడి క్రిందికి లాగండి.",
      's2_1_txt':
          "రెండు స్థిర సమాంతర రేఖలు మరియు తిర్యగ్రేఖను గమనించండి. పై కోణంపై 'ట్రేసింగ్ టూల్' ఉంచబడింది. దాన్ని క్రిందికి లాగండి.",
      's2_2_hud': "సరిగ్గా సరిపోయిందా?",
      's2_2_txt':
          "దిగువ రేఖపై సదృశ్య కోణంపై ట్రేసింగ్ టూల్‌ను ఖచ్చితంగా ఉంచండి. సరిగ్గా సరిపోయిందా?",
      's2_3_hud': "తిర్యగ్రేఖ కోణం మార్చి, మళ్లీ సరిపోలుతున్నాయో లేదో చూద్దాం.",
      's2_3_txt':
          "మళ్లీ ప్రయత్నించండి. మొదట, తిర్యగ్రేఖను లాగండి. ఆపై పోల్చడానికి ట్రేసింగ్ టూల్‌ను లాగండి.",
      's2_4_sum':
          "ధృవీకరణ పూర్తయింది\nరెండు రేఖలు సమాంతరంగా ఉంటే, వాటి సదృశ్య కోణాలు ఎల్లప్పుడూ సమానంగా ఉంటాయి.",
      'scen3Title': "3. ఏకాంతర కోణం కనెక్షన్",
      's3Obj': "ఏకాంతర అంతర కోణాలు ఎందుకు సమానంగా ఉంటాయో అర్థం చేసుకోవడానికి.",
      's3_1_hud':
          "హైలైట్ చేసిన ఆకుపచ్చ కోణానికి శీర్షాభిముఖంగా ఉన్న కోణంపై క్లిక్ చేయండి.",
      's3_1_txt':
          "ఒక అంతర కోణం ఆకుపచ్చ రంగులో హైలైట్ చేయబడింది. దాన్ని దాని శీర్షాభిముఖ కోణంతో సంబంధం చేద్దాం.",
      's3_2_hud': "కొత్త ఆకుపచ్చ కోణానికి సదృశ్య కోణంపై క్లిక్ చేయండి.",
      's3_2_txt':
          "శీర్షాభిముఖ కోణాలు ఎల్లప్పుడూ సమానంగా ఉంటాయి. ఇప్పుడు, సదృశ్య కోణాన్ని కనుగొందాం.",
      's3_3_sum':
          "ఏకాంతర అంతర కోణాలు\nరేఖలు సమాంతరంగా ఉన్నప్పుడు ఏకాంతర అంతర కోణాలు ఎల్లప్పుడూ సమానంగా ఉంటాయి.",
      'scen4Title': "4. రైల్వే ఫిక్సర్",
      's4Obj':
          "వంకర రైల్వే ట్రాక్‌ను పరిష్కరించడానికి కోణాల జ్ఞానాన్ని వర్తించండి.",
      's4_1_hud': "కోణాన్ని కొలవడానికి ప్రొట్రాక్టర్‌ను లాగండి.",
      's4_1_txt':
          "పై రైలు స్థిరంగా ఉంది, దిగువ రైలు వంకరగా ఉంది. 'డిజిటల్ ప్రొట్రాక్టర్'ని పై ఖండన వద్దకు లాగండి.",
      's4_2_hud': "కోణం 75°కి సరిపోయే వరకు దిగువ రైలుపై హ్యాండిల్‌ను లాగండి.",
      's4_2_txt':
          "మీరు 75° కొలిచారు. ఇప్పుడు, సదృశ్య కోణం 75° అయ్యే వరకు దిగువ రైలును తిప్పండి.",
      's4_3_hud': "రైలును పరీక్షించడానికి 'Go' క్లిక్ చేయండి.",
      's4_3_txt':
          "కోణాలు సరిపోలుతున్నాయి, కాబట్టి ట్రాక్‌లు సమాంతరంగా ఉండాలి. 'Go' క్లిక్ చేయండి.",
      's4_4_sum':
          "ఇంజనీరింగ్ విజయం!\nసదృశ్య కోణాలను సమానంగా ఉండేలా చూసుకోవడం ద్వారా, ట్రాక్‌లు సమాంతరంగా ఉన్నాయని మీరు హామీ ఇచ్చారు.",
      'scen5Title': "5. లేజర్ గ్రిడ్ పజిల్",
      's5Obj':
          "లేజర్ బీమ్‌ను సమలేఖనం చేయడానికి ఏకాంతర అంతర కోణాల లక్షణాన్ని వర్తించండి.",
      's5_1_hud':
          "ప్రస్తుత మార్గాన్ని చూడటానికి 'Activate Laser' క్లిక్ చేయండి.",
      's5_1_txt':
          "మీ లక్ష్యం లేజర్‌ను టార్గెట్‌కు మార్గనిర్దేశం చేయడం. వచ్చే లేజర్ మరియు వెళ్ళే లేజర్ మార్గాలు సమాంతరంగా ఉండాలి. మొదటి అద్దం కోణం 110°.",
      's5_2_hud': "రెండవ అద్దాన్ని 110°కి లాగండి.",
      's5_2_txt':
          "లేజర్ తప్పిపోయింది! ఏకాంతర అంతర కోణాలు సమానంగా ఉండాలి. మొదటి కోణం 110°. రెండవ అద్దాన్ని 110°కి తిప్పండి.",
      's5_3_hud': "లక్ష్యాన్ని కొట్టడానికి 'Activate Laser' క్లిక్ చేయండి!",
      's5_3_txt':
          "కోణాలు సమానం! లేజర్ మార్గాలు ఇప్పుడు సమాంతరంగా ఉండాలి. 'Activate Laser' క్లిక్ చేయండి!",
      's5_4_sum':
          "పజిల్ పరిష్కరించబడింది!\nఅద్దాలను సమలేఖనం చేయడానికి మీరు ఏకాంతర అంతర కోణాలను ఉపయోగించారు.",
    },
  };
}

// --- MAIN CANVAS PAINTER ---
class MasterPainter extends CustomPainter {
  final double baseScale;
  final double canvasZoom;
  final Offset canvasPan;
  final int scenario, step;

  final double s1Tilt, s1MAngle;
  final bool s1Matched, s1MovedM;

  final double s2Tilt;
  final Offset s2Tracer;
  final bool s2TracerMatched;

  final double s3Tilt;
  final List<Map<String, dynamic>> s3Angles;
  final double s3AnimProgress;
  final bool s3Animating;

  final double s4BotAngle;
  final Offset s4Pro;
  final bool s4ProSnapped;
  final Offset s4TrainPos;
  final double s4TrainRot;

  final double s5AltAngle;
  final double s5LaserProgress;
  final bool s5LaserHit;
  final bool s5LaserRunning;

  MasterPainter({
    required this.baseScale,
    required this.canvasZoom,
    required this.canvasPan,
    required this.scenario,
    required this.step,
    required this.s1Tilt,
    required this.s1MAngle,
    required this.s1Matched,
    required this.s1MovedM,
    required this.s2Tilt,
    required this.s2Tracer,
    required this.s2TracerMatched,
    required this.s3Tilt,
    required this.s3Angles,
    required this.s3AnimProgress,
    required this.s3Animating,
    required this.s4BotAngle,
    required this.s4Pro,
    required this.s4ProSnapped,
    required this.s4TrainPos,
    required this.s4TrainRot,
    required this.s5AltAngle,
    required this.s5LaserProgress,
    required this.s5LaserHit,
    required this.s5LaserRunning,
  });

  Offset _getTopIntersection(double tiltDeg) {
    return Offset(tan(tiltDeg * pi / 180) * 150, -150);
  }

  Offset _getBotIntersection(double tiltDeg) {
    return Offset(-tan(tiltDeg * pi / 180) * 150, 150);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      size.width / 2 + canvasPan.dx,
      size.height / 2 + canvasPan.dy,
    );
    canvas.scale(baseScale * canvasZoom);

    // Background Grid
    final gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1;
    for (double i = -500; i <= 500; i += 50) {
      canvas.drawLine(Offset(i, -500), Offset(i, 500), gridPaint);
      canvas.drawLine(Offset(-500, i), Offset(500, i), gridPaint);
    }

    if (scenario == 1) {
      _paintS1(canvas);
    } else if (scenario == 2) {
      _paintS2(canvas);
    } else if (scenario == 3) {
      _paintS3(canvas);
    } else if (scenario == 4) {
      _paintS4(canvas);
    } else if (scenario == 5) {
      _paintS5(canvas);
    }

    canvas.restore();
  }

  void _paintArrow(Canvas canvas, Offset p, bool matched) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    final path =
        Path()
          ..moveTo(-12, -12)
          ..lineTo(16, 0)
          ..lineTo(-12, 12)
          ..lineTo(0, 0)
          ..close();
    canvas.drawPath(
      path,
      Paint()..color = matched ? Colors.green : Colors.transparent,
    );
    canvas.restore();
  }

  void _paintS1(Canvas canvas) {
    Offset intTop = _getTopIntersection(s1Tilt);
    Offset intBot = _getBotIntersection(s1Tilt);
    double tAngle = -90 + s1Tilt;

    final linePaint =
        Paint()
          ..color = s1Matched ? Colors.green : const Color(0xFF3b82f6)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    // Transversal
    canvas.save();
    canvas.rotate(s1Tilt * pi / 180);
    canvas.drawLine(
      const Offset(0, -350),
      const Offset(0, 350),
      Paint()
        ..color = Colors.amber
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      "t",
      const Offset(-25, -320),
      fontSize: 28,
      color: Colors.amber,
      fontStyle: FontStyle.italic,
    );
    if (step >= 2) {
      canvas.translate(0, -300);
      canvas.drawCircle(Offset.zero, 24, Paint()..color = Colors.amber);
      canvas.drawCircle(
        Offset.zero,
        24,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    canvas.restore();

    // Line l (top)
    canvas.save();
    canvas.translate(intTop.dx, intTop.dy);
    canvas.drawLine(const Offset(-400, 0), const Offset(400, 0), linePaint);
    _drawText(
      canvas,
      "l",
      const Offset(380, -20),
      fontSize: 28,
      color: linePaint.color,
      fontStyle: FontStyle.italic,
    );
    _paintArrow(canvas, const Offset(200, 0), s1Matched);
    _paintArrow(canvas, const Offset(-200, 0), s1Matched);

    // Top Angle Arc
    _drawArcSector(
      canvas,
      0,
      0,
      80,
      tAngle,
      0,
      s1Matched
          ? Colors.green.withOpacity(0.35)
          : Colors.purple.withOpacity(0.35),
      "${(90 - s1Tilt).round()}°",
      s1Matched ? Colors.green : Colors.purple,
    );
    canvas.restore();

    // Line m (bot)
    canvas.save();
    canvas.translate(intBot.dx, intBot.dy);
    canvas.rotate(s1MAngle * pi / 180);
    canvas.drawLine(const Offset(-400, 0), const Offset(400, 0), linePaint);
    _drawText(
      canvas,
      "m",
      const Offset(380, -20),
      fontSize: 28,
      color: linePaint.color,
      fontStyle: FontStyle.italic,
    );
    _paintArrow(canvas, const Offset(200, 0), s1Matched);
    _paintArrow(canvas, const Offset(-200, 0), s1Matched);

    // Bot Angle Arc
    _drawArcSector(
      canvas,
      0,
      0,
      80,
      tAngle - s1MAngle,
      0,
      s1Matched
          ? Colors.green.withOpacity(0.35)
          : Colors.purple.withOpacity(0.35),
      "${((90 - s1Tilt) - s1MAngle).abs().round()}°",
      s1Matched ? Colors.green : Colors.purple,
    );

    // Handle M
    canvas.translate(250, 0);
    if (step == 0 && !s1MovedM) {
      canvas.drawCircle(
        Offset.zero,
        20,
        Paint()..color = Colors.indigo.withOpacity(0.3),
      );
    }
    canvas.drawCircle(
      Offset.zero,
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _paintS2(Canvas canvas) {
    Offset intTop = _getTopIntersection(s2Tilt);
    Offset intBot = _getBotIntersection(s2Tilt);
    double tAngle = -90 + s2Tilt;

    final linePaint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    // Base Angles
    _drawArcSector(
      canvas,
      intTop.dx,
      intTop.dy,
      80,
      tAngle,
      0,
      Colors.white.withOpacity(0.05),
      "${(90 - s2Tilt).round()}°",
      Colors.white.withOpacity(0.1),
      textColor: Colors.blueGrey[300],
    );
    _drawArcSector(
      canvas,
      intBot.dx,
      intBot.dy,
      80,
      tAngle,
      0,
      Colors.white.withOpacity(0.05),
      "${(90 - s2Tilt).round()}°",
      Colors.white.withOpacity(0.1),
      textColor: Colors.blueGrey[300],
    );

    // Lines l, m
    canvas.drawLine(
      const Offset(-400, -150),
      const Offset(400, -150),
      linePaint,
    );
    _drawText(
      canvas,
      "l",
      const Offset(380, -170),
      fontSize: 28,
      color: Colors.blue,
      fontStyle: FontStyle.italic,
    );
    _paintArrow(canvas, const Offset(200, -150), true);

    canvas.drawLine(const Offset(-400, 150), const Offset(400, 150), linePaint);
    _drawText(
      canvas,
      "m",
      const Offset(380, 130),
      fontSize: 28,
      color: Colors.blue,
      fontStyle: FontStyle.italic,
    );
    _paintArrow(canvas, const Offset(200, 150), true);

    // Transversal
    canvas.save();
    canvas.rotate(s2Tilt * pi / 180);
    canvas.drawLine(
      const Offset(0, -350),
      const Offset(0, 350),
      Paint()
        ..color = Colors.amber
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    _drawText(
      canvas,
      "t",
      const Offset(-25, -320),
      fontSize: 28,
      color: Colors.amber,
      fontStyle: FontStyle.italic,
    );
    if (step >= 2) {
      canvas.translate(0, -300);
      canvas.drawCircle(Offset.zero, 24, Paint()..color = Colors.amber);
      canvas.drawCircle(
        Offset.zero,
        24,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    canvas.restore();

    // Dropzone
    if (step <= 1 && !s2TracerMatched) {
      canvas.drawCircle(
        intBot,
        40,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Tracer Tool
    canvas.save();
    canvas.translate(s2Tracer.dx, s2Tracer.dy);
    final path =
        Path()
          ..moveTo(0, 0)
          ..lineTo(80, 0);
    double diff = -tAngle;
    if (diff < 0) diff += 360;
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: 80),
      0,
      -diff * pi / 180,
      false,
    );
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color =
            s2TracerMatched
                ? Colors.green.withOpacity(0.6)
                : Colors.indigo.withOpacity(0.4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = s2TracerMatched ? Colors.green : Colors.indigo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.translate(40, -30);
    canvas.drawCircle(Offset.zero, 16, Paint()..color = Colors.black);
    canvas.drawCircle(
      Offset.zero,
      16,
      Paint()
        ..color = Colors.indigo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _paintS3(Canvas canvas) {
    Offset intTop = _getTopIntersection(s3Tilt);
    Offset intBot = _getBotIntersection(s3Tilt);
    double tAngle = -90 + s3Tilt;

    final linePaint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    // Lines l, m
    canvas.drawLine(
      const Offset(-400, -150),
      const Offset(400, -150),
      linePaint,
    );
    _paintArrow(canvas, const Offset(200, -150), true);
    canvas.drawLine(const Offset(-400, 150), const Offset(400, 150), linePaint);
    _paintArrow(canvas, const Offset(200, 150), true);

    // Transversal
    canvas.save();
    canvas.rotate(s3Tilt * pi / 180);
    canvas.drawLine(
      const Offset(0, -350),
      const Offset(0, 350),
      Paint()
        ..color = Colors.amber
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    Map<int, Map<String, dynamic>> angleDefs = {
      1: {'start': 180.0, 'end': tAngle, 'c': intTop},
      2: {'start': tAngle, 'end': 0.0, 'c': intTop},
      4: {'start': tAngle + 180.0, 'end': 180.0, 'c': intTop},
      3: {'start': 0.0, 'end': tAngle + 180.0, 'c': intTop},
      5: {'start': 180.0, 'end': tAngle, 'c': intBot},
      6: {'start': tAngle, 'end': 0.0, 'c': intBot},
      7: {'start': tAngle + 180.0, 'end': 180.0, 'c': intBot},
      8: {'start': 0.0, 'end': tAngle + 180.0, 'c': intBot},
    };

    for (var a in s3Angles) {
      var def = angleDefs[a['id']];
      if (def != null) {
        _drawArcSector(
          canvas,
          def['c'].dx,
          def['c'].dy,
          80,
          def['start'],
          def['end'],
          a['matched'] ? Colors.green.withOpacity(0.4) : Colors.transparent,
          a['matched'] ? "∠${a['id']}" : "",
          a['matched'] ? Colors.green : Colors.transparent,
          strokeW: 3,
        );
      }
    }

    // Animation Layer
    if (s3Animating) {
      canvas.save();
      var def = angleDefs[4]!;
      double dx = intBot.dx - intTop.dx;
      double dy = intBot.dy - intTop.dy;
      double tx = dx * s3AnimProgress;
      double ty = dy * s3AnimProgress;

      canvas.translate(intTop.dx + tx, intTop.dy + ty);
      // Flipped and scaled logic
      double scale = 1.0 + sin(s3AnimProgress * pi) * 0.1;
      canvas.scale(scale);
      canvas.rotate(s3AnimProgress * pi); // 180 deg flip

      _drawArcSector(
        canvas,
        0,
        0,
        80,
        def['start'],
        def['end'],
        Colors.purple.withOpacity(0.7),
        "",
        Colors.purple,
        strokeW: 3,
      );
      canvas.restore();
    }
  }

  void _paintS4(Canvas canvas) {
    // Train (if behind)
    canvas.save();
    canvas.translate(s4TrainPos.dx, s4TrainPos.dy);
    canvas.rotate(s4TrainRot * pi / 180);
    _drawTrain(canvas);
    canvas.restore();

    // Top Rail
    canvas.save();
    canvas.translate(0, -100);
    canvas.drawLine(
      const Offset(-500, 0),
      const Offset(500, 0),
      Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 12,
    );
    canvas.drawLine(
      const Offset(-500, 0),
      const Offset(500, 0),
      Paint()
        ..color = Colors.blueGrey.shade300
        ..strokeWidth = 6,
    );
    // Top Angle Arc 75°
    _drawArcSector(
      canvas,
      -27,
      0,
      40,
      0,
      75,
      Colors.white.withOpacity(0.1),
      "",
      Colors.amber,
      strokeW: 2,
    );
    canvas.restore();

    // Bottom Rail
    canvas.save();
    canvas.translate(27, 100);
    canvas.rotate(s4BotAngle * pi / 180);
    canvas.drawLine(
      const Offset(-500, 0),
      const Offset(500, 0),
      Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 12,
    );
    canvas.drawLine(
      const Offset(-500, 0),
      const Offset(500, 0),
      Paint()
        ..color = Colors.blueGrey.shade300
        ..strokeWidth = 6,
    );
    canvas.restore();

    // Transversal Rail
    canvas.drawLine(
      const Offset(-54, -200),
      const Offset(54, 200),
      Paint()
        ..color = Colors.brown.shade700
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawLine(
      const Offset(-54, -200),
      const Offset(54, 200),
      Paint()
        ..color = Colors.brown.shade500
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.square,
    );

    // Dynamic Bot Angle Arc
    if (s4ProSnapped) {
      canvas.save();
      canvas.translate(27, 100);
      bool parallel = s4BotAngle.abs() < 2;
      _drawArcSector(
        canvas,
        0,
        0,
        60,
        s4BotAngle,
        75,
        parallel
            ? Colors.green.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        "${(75 - s4BotAngle).round()}°",
        parallel ? Colors.green : Colors.amber,
        strokeW: 3,
      );
      canvas.restore();
    }

    // Bot Handle
    canvas.save();
    canvas.translate(27, 100);
    canvas.rotate(s4BotAngle * pi / 180);
    canvas.translate(200, 0);
    canvas.drawCircle(Offset.zero, 24, Paint()..color = Colors.blue);
    canvas.drawCircle(
      Offset.zero,
      24,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();

    // Protractor
    canvas.save();
    canvas.translate(s4Pro.dx, s4Pro.dy);
    final pPath =
        Path()
          ..moveTo(-100, 0)
          ..arcTo(
            Rect.fromCircle(center: Offset.zero, radius: 100),
            pi,
            pi,
            false,
          )
          ..close();
    canvas.drawPath(pPath, Paint()..color = Colors.white.withOpacity(0.15));
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      const Offset(-100, 0),
      const Offset(100, 0),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset.zero, 5, Paint()..color = Colors.red);
    _drawText(
      canvas,
      s4ProSnapped ? "75°" : "?",
      const Offset(0, -40),
      fontSize: 20,
      color: s4ProSnapped ? Colors.green : Colors.white,
      fontWeight: FontWeight.bold,
    );
    canvas.restore();

    // Go Btn
    if (step >= 2) {
      canvas.save();
      canvas.translate(0, 275);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-60, 0, 120, 50),
          const Radius.circular(25),
        ),
        Paint()..color = Colors.green,
      );
      _drawText(
        canvas,
        "GO!",
        const Offset(0, 25),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );
      canvas.restore();
    }
  }

  void _drawTrain(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -30, 80, 50),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.red.shade600,
    );
    canvas.drawRect(
      const Rect.fromLTWH(20, -45, 15, 15),
      Paint()..color = Colors.blueGrey,
    );
    canvas.drawCircle(
      const Offset(-20, 20),
      10,
      Paint()..color = Colors.blueGrey.shade800,
    );
    canvas.drawCircle(
      const Offset(20, 20),
      10,
      Paint()..color = Colors.blueGrey.shade800,
    );
    canvas.drawRect(
      const Rect.fromLTWH(-30, -15, 20, 15),
      Paint()..color = Colors.blue.shade200,
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, -15, 20, 15),
      Paint()..color = Colors.blue.shade200,
    );
  }

  void _paintS5(Canvas canvas) {
    // Parallel lines
    canvas.drawLine(
      const Offset(-500, -100),
      const Offset(500, -100),
      Paint()
        ..color = Colors.blueGrey.shade200
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(-500, 100),
      const Offset(500, 100),
      Paint()
        ..color = Colors.blueGrey.shade200
        ..strokeWidth = 2,
    );
    // Transversal
    canvas.drawLine(
      const Offset(-120, -100),
      const Offset(120, 100),
      Paint()
        ..color = Colors.blueGrey.shade400
        ..strokeWidth = 2,
    );

    // Emitter
    canvas.save();
    canvas.translate(-400, -100);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -20, 60, 40),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.blueGrey.shade700,
    );
    final emP =
        Path()
          ..moveTo(30, -10)
          ..lineTo(45, 0)
          ..lineTo(30, 10)
          ..close();
    canvas.drawPath(emP, Paint()..color = Colors.red);
    canvas.restore();

    // Target
    canvas.save();
    canvas.translate(350, 100);
    canvas.drawCircle(
      Offset.zero,
      40,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.red);
    if (s5LaserHit) {
      canvas.drawCircle(Offset.zero, 30, Paint()..color = Colors.yellow);
      canvas.drawCircle(Offset.zero, 15, Paint()..color = Colors.white);
    }
    canvas.restore();

    // M1 Fixed
    canvas.save();
    canvas.translate(-120, -100);
    canvas.rotate(19.9 * pi / 180); // To visually reflect 110 properly
    canvas.drawLine(
      const Offset(-40, 0),
      const Offset(40, 0),
      Paint()
        ..color = Colors.blueGrey.shade300
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(-38, 0),
      const Offset(38, 0),
      Paint()
        ..color = Colors.blueGrey.shade100
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    _drawArcSector(
      canvas,
      -120,
      -100,
      50,
      39.8,
      180,
      Colors.blue.withOpacity(0.2),
      "110°",
      Colors.blue,
      strokeW: 2,
    );

    // M2 Rotatable
    double alphaOut = 110 - s5AltAngle;
    double normalAngle =
        (219.8 + (alphaOut < 0 ? 360 + alphaOut : alphaOut)) / 2;
    double mirrorRot = normalAngle + 90;

    canvas.save();
    canvas.translate(120, 100);
    canvas.rotate(mirrorRot * pi / 180);
    canvas.drawLine(
      const Offset(-40, 0),
      const Offset(40, 0),
      Paint()
        ..color = Colors.blueGrey.shade300
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(-38, 0),
      const Offset(38, 0),
      Paint()
        ..color = Colors.blueGrey.shade100
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    double endAngle = alphaOut < 0 ? 360 + alphaOut : alphaOut;
    bool parallel = (s5AltAngle - 110).abs() < 2;
    _drawArcSector(
      canvas,
      120,
      100,
      50,
      219.8,
      endAngle,
      parallel ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
      "${s5AltAngle.round()}°",
      parallel ? Colors.green : Colors.blue,
      strokeW: 2,
    );

    if (step >= 1) {
      canvas.save();
      canvas.translate(120, 100);
      canvas.rotate(alphaOut * pi / 180);
      canvas.translate(100, 0);
      canvas.drawCircle(Offset.zero, 24, Paint()..color = Colors.blue);
      canvas.drawCircle(
        Offset.zero,
        24,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.restore();
    }

    // Laser Beam
    if (s5LaserProgress > 0) {
      List<Offset> pts = [
        const Offset(-370, -100),
        const Offset(-120, -100),
        const Offset(120, 100),
      ];
      if (parallel) {
        pts.add(const Offset(350, 100));
      } else {
        double outRad = alphaOut * pi / 180;
        pts.add(Offset(120 + cos(outRad) * 300, 100 + sin(outRad) * 300));
      }

      double totalLen = 0;
      List<double> lens = [];
      for (int i = 0; i < pts.length - 1; i++) {
        double l = (pts[i + 1] - pts[i]).distance;
        lens.add(l);
        totalLen += l;
      }

      double drawDist = totalLen * s5LaserProgress;
      Path p = Path()..moveTo(pts[0].dx, pts[0].dy);
      double curD = 0;
      for (int i = 0; i < pts.length - 1; i++) {
        if (drawDist > curD + lens[i]) {
          p.lineTo(pts[i + 1].dx, pts[i + 1].dy);
          curD += lens[i];
        } else {
          double rem = drawDist - curD;
          double frac = rem / lens[i];
          double px = pts[i].dx + (pts[i + 1].dx - pts[i].dx) * frac;
          double py = pts[i].dy + (pts[i + 1].dy - pts[i].dy) * frac;
          p.lineTo(px, py);
          break;
        }
      }
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke,
      );
    }

    // Activate Btn
    if (step == 0 || step == 2) {
      canvas.save();
      canvas.translate(0, 275);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-100, 0, 200, 50),
          const Radius.circular(25),
        ),
        Paint()..color = Colors.red,
      );
      _drawText(
        canvas,
        "ACTIVATE LASER",
        const Offset(0, 25),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );
      canvas.restore();
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    double fontSize = 14,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawArcSector(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    double startAngleDeg,
    double endAngleDeg,
    Color color,
    String text,
    Color strokeColor, {
    double strokeW = 2,
    Color? textColor,
  }) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    double startRad = startAngleDeg * pi / 180;

    // Calculate sweep
    double diff = endAngleDeg - startAngleDeg;
    while (diff < 0) {
      diff += 360;
    }
    while (diff >= 360) {
      diff -= 360;
    }
    double sweepRad = diff * pi / 180;

    canvas.drawArc(
      rect,
      startRad,
      sweepRad,
      true,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawArc(
      rect,
      startRad,
      sweepRad,
      true,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    double midAngleDeg = startAngleDeg + diff / 2;
    double textR = radius + 25;
    double tx = cx + textR * cos(midAngleDeg * pi / 180);
    double ty = cy + textR * sin(midAngleDeg * pi / 180);
    _drawText(
      canvas,
      text,
      Offset(tx, ty),
      fontSize: 18,
      color: textColor ?? strokeColor,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  bool shouldRepaint(covariant MasterPainter oldDelegate) => true;
}
