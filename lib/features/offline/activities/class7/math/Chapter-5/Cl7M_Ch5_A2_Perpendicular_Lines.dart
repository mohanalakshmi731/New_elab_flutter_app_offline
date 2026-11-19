// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, prefer_final_fields

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Perpendicular Lines',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF020617),
      ),
      debugShowCheckedModeBanner: false,
      home: const PerpendicularLinesLab(),
    ),
  );
}

class PerpendicularLinesLab extends StatefulWidget {
  const PerpendicularLinesLab({super.key});

  @override
  State<PerpendicularLinesLab> createState() => _PerpendicularLinesLabState();
}

class _PerpendicularLinesLabState extends State<PerpendicularLinesLab>
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

  // S1
  double _s1Angle = 30.0;
  bool _s1Snapped = false;

  // S2
  final Map<String, Map<String, dynamic>> _s2Buildings = {
    'house': {
      'x': -350.0,
      'y': -150.0,
      'startX': -350.0,
      'startY': -150.0,
      'tx': -150.0,
      'ty': -50.0,
      'placed': false,
      'icon': '🏠',
      'color': const Color(0xFFEC4899),
      'name': 'House',
    },
    'school': {
      'x': -350.0,
      'y': -50.0,
      'startX': -350.0,
      'startY': -50.0,
      'tx': 0.0,
      'ty': -50.0,
      'placed': false,
      'icon': '🏫',
      'color': const Color(0xFF3B82F6),
      'name': 'School',
    },
    'shop': {
      'x': -350.0,
      'y': 50.0,
      'startX': -350.0,
      'startY': 50.0,
      'tx': 150.0,
      'ty': -50.0,
      'placed': false,
      'icon': '🏪',
      'color': const Color(0xFFF59E0B),
      'name': 'Shop',
    },
  };
  final List<Map<String, dynamic>> _s2Roads = [];
  Map<String, dynamic>? _s2ActiveRoad;

  // S3
  bool _s3SsActive = false,
      _s3SsPlaced = false,
      _s3SsAligned = false,
      _s3LineDrawn = false,
      _s3Tracing = false;
  double _s3SsX = -290.0, _s3SsY = 0.0, _s3SsStartX = -290.0, _s3SsStartY = 0.0;
  double _s3PenX = -290.0,
      _s3PenY = -50.0,
      _s3PenStartX = -290.0,
      _s3PenStartY = -50.0;
  double _s3DrawnLineEndY = 0.0;

  // S4
  final List<String> _s4Sequence = [];
  bool _s4Running = false;
  double _s4RobotX = -100.0, _s4RobotY = 100.0, _s4RobotDir = 0.0;

  // S5
  final List<Map<String, dynamic>> _s5Pieces = [
    {
      'id': 'p1',
      'type': 'long',
      'w': 260.0,
      'h': 20.0,
      'cx': -250.0,
      'cy': -150.0,
      'initCx': -250.0,
      'initCy': -150.0,
      'rot': 90,
      'locked': false,
      'error': false,
    },
    {
      'id': 'p2',
      'type': 'long',
      'w': 260.0,
      'h': 20.0,
      'cx': 250.0,
      'cy': 150.0,
      'initCx': 250.0,
      'initCy': 150.0,
      'rot': 0,
      'locked': false,
      'error': false,
    },
    {
      'id': 'p3',
      'type': 'short',
      'w': 200.0,
      'h': 20.0,
      'cx': -250.0,
      'cy': 150.0,
      'initCx': -250.0,
      'initCy': 150.0,
      'rot': 0,
      'locked': false,
      'error': false,
    },
    {
      'id': 'p4',
      'type': 'short',
      'w': 200.0,
      'h': 20.0,
      'cx': 250.0,
      'cy': -150.0,
      'initCx': 250.0,
      'initCy': -150.0,
      'rot': 90,
      'locked': false,
      'error': false,
    },
  ];
  final List<Map<String, dynamic>> _s5Slots = [
    {
      'id': 'top',
      'tx': 0.0,
      'ty': -100.0,
      'tr': 0,
      'type': 'long',
      'filledBy': null,
    },
    {
      'id': 'bottom',
      'tx': 0.0,
      'ty': 100.0,
      'tr': 0,
      'type': 'long',
      'filledBy': null,
    },
    {
      'id': 'left',
      'tx': -140.0,
      'ty': 0.0,
      'tr': 90,
      'type': 'short',
      'filledBy': null,
    },
    {
      'id': 'right',
      'tx': 140.0,
      'ty': 0.0,
      'tr': 90,
      'type': 'short',
      'filledBy': null,
    },
  ];
  final Map<String, bool> _s5Corners = {
    'tl': false,
    'tr': false,
    'bl': false,
    'br': false,
  };

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
        _s1Angle = 30.0;
        _s1Snapped = false;
      }
      if (id == 2) {
        _s2Buildings.forEach((k, b) {
          b['x'] = b['startX'];
          b['y'] = b['startY'];
          b['placed'] = false;
        });
        _s2Roads.clear();
        _s2ActiveRoad = null;
      }
      if (id == 3) {
        _s3SsActive = false;
        _s3SsPlaced = false;
        _s3SsAligned = false;
        _s3LineDrawn = false;
        _s3Tracing = false;
        _s3SsX = -290;
        _s3SsY = 0;
        _s3PenX = -290;
        _s3PenY = -50;
      }
      if (id == 4) {
        _s4Sequence.clear();
        _s4Running = false;
        _s4RobotX = -100;
        _s4RobotY = 100;
        _s4RobotDir = 0;
      }
      if (id == 5) {
        for (var p in _s5Pieces) {
          p['cx'] = p['initCx'];
          p['cy'] = p['initCy'];
          p['locked'] = false;
          p['error'] = false;
          p['rot'] = p['type'] == 'long' ? 90 : 0;
        }
        for (var s in _s5Slots) {
          s['filledBy'] = null;
        }
        _s5Corners.forEach((k, v) => _s5Corners[k] = false);
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
          _summaryModalPos = null; // Reset position to center initially
          _completedScenarios.add(_scenario);
          if (_completedScenarios.length == 5) {
            _showSuccess = true;
            _successModalPos = null;
          }
        }
        // Auto-complete the final conceptual step for Scenario 1 after a brief pause
        else if (_scenario == 1 && _step == 3) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _scenario == 1 && _step == 3 && !_showSummary) {
              _markStepComplete(0);
            }
          });
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
    final sidebarWidth = sw * 0.38;
    final contentWidth = sw - (_isSidebarOpen ? sidebarWidth : 0);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
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
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Builder(
                      builder: (context) {
                        return _buildCanvasArea(contentWidth, sh);
                      },
                    ),
                  ),

                  // Active Step Info (when sidebar closed) floats on top
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
                              _getScenarioSteps(_scenario)[_step]['text'] ?? '',
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
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
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

          // Menu Icon (Top Left floating)
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
              color: Colors.white,
              onPressed: () {
                _playSound(_clickPlayer, _clickUrl);
                setState(() => _isSidebarOpen = !_isSidebarOpen);
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 66, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.architecture, color: Colors.amber, size: 32),
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
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('appSubtitle'),
                      style: TextStyle(
                        color: _text.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language and Reset Buttons underneath Title
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.language, size: 16),
                label: Text(_currentLang.toUpperCase()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
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
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: Colors.redAccent,
                ),
                label: Text(t('resetLab')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                onPressed: _masterReset,
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
                  fontSize: 16,
                ),
                items:
                    [1, 2, 3, 4, 5]
                        .map(
                          (id) => DropdownMenuItem(
                            value: id,
                            child: Text(t('scen${id}Title')),
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

          // Theory
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

          // Steps
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

          const SizedBox(height: 40),

          // Footer (Not Translated as Requested)
          Center(
            child: Text(
              "© ZEROSCIENCELAB | Fall in Love with Math and Science",
              style: TextStyle(
                color: _text.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
  Offset _getCanvasPos(Offset localPos, double baseScale, double w, double h) {
    double x =
        (localPos.dx - w / 2 - _canvasPan.dx) / (baseScale * _canvasZoom);
    double y =
        (localPos.dy - h / 2 - _canvasPan.dy) / (baseScale * _canvasZoom);
    return Offset(x, y);
  }

  Widget _buildCanvasArea(double w, double h) {
    final baseScale = min(w / 800, h / 800);

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
            _canvasZoom = (_baseZoom * details.scale).clamp(0.5, 5.0);
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
            s1Angle: _s1Angle,
            s1Snapped: _s1Snapped,
            s2Buildings: _s2Buildings,
            s2Roads: _s2Roads,
            s2ActiveRoad: _s2ActiveRoad,
            s3SsActive: _s3SsActive,
            s3SsPlaced: _s3SsPlaced,
            s3SsAligned: _s3SsAligned,
            s3SsX: _s3SsX,
            s3SsY: _s3SsY,
            s3PenX: _s3PenX,
            s3PenY: _s3PenY,
            s3LineDrawn: _s3LineDrawn,
            s3Tracing: _s3Tracing,
            s3DrawnLineEndY: _s3DrawnLineEndY,
            s4Sequence: _s4Sequence,
            s4RobotX: _s4RobotX,
            s4RobotY: _s4RobotY,
            s4RobotDir: _s4RobotDir,
            s5Pieces: _s5Pieces,
            s5Corners: _s5Corners,
          ),
        ),
      ),
    );
  }

  void _handleInteractionTap(Offset pt) {
    if (_actionValidated) return;

    if (_scenario == 4) {
      if (Rect.fromLTWH(-270, 250, 80, 40).contains(pt)) {
        if (_s4Sequence.length < 5 && !_s4Running) {
          _playSound(_clickPlayer, _clickUrl);
          setState(() {
            _s4Sequence.add('F');
          });
          if (_step == 0) _markStepComplete(200);
        }
        return;
      }
      if (Rect.fromLTWH(-170, 250, 80, 40).contains(pt)) {
        if (_s4Sequence.length < 5 && !_s4Running) {
          _playSound(_clickPlayer, _clickUrl);
          setState(() {
            _s4Sequence.add('R');
          });
        }
        return;
      }
      if (Rect.fromLTWH(60, 295, 80, 40).contains(pt)) {
        _runS4Robot();
        return;
      }
      for (int i = 0; i < _s4Sequence.length; i++) {
        double bx = -40.0 + (i * 70);
        if (Rect.fromLTWH(bx - 30, 250, 60, 40).contains(pt)) {
          if (!_s4Running) {
            _playSound(_errorPlayer, _errorUrl);
            setState(() {
              _s4Sequence.removeAt(i);
            });
          }
          return;
        }
      }
    } else if (_scenario == 5) {
      // Rotation logic for pieces on tap
      for (int i = 0; i < _s5Pieces.length; i++) {
        var p = _s5Pieces[i];
        if (p['locked']) continue;
        bool isHoriz = (p['rot'] % 180 == 0);
        double dx = (pt.dx - p['cx']).abs();
        double dy = (pt.dy - p['cy']).abs();

        // Generous hitbox for easy tapping
        bool hit =
            isHoriz
                ? (dx < p['w'] / 2 + 20 && dy < p['h'] / 2 + 20)
                : (dx < p['h'] / 2 + 20 && dy < p['w'] / 2 + 20);

        if (hit) {
          _playSound(_clickPlayer, _clickUrl);
          setState(() {
            p['rot'] = (p['rot'] as int) + 90;
          });
          return;
        }
      }
    }
  }

  void _handleInteractionStart(Offset pt) {
    if (_actionValidated) return;
    _activeDragType = null;
    _dragData.clear();

    if (_scenario == 1 && (_step >= 0 && _step <= 2) && !_s1Snapped) {
      double rad = -_s1Angle * pi / 180;
      double hx = 240 * cos(rad);
      double hy = 240 * sin(rad);
      if (sqrt(pow(pt.dx - hx, 2) + pow(pt.dy - hy, 2)) < 60) {
        _activeDragType = 's1_handle';
        if (_step == 0) _markStepComplete(200);
        return;
      }
    } else if (_scenario == 2) {
      for (var key in _s2Buildings.keys) {
        var b = _s2Buildings[key]!;
        if (!b['placed'] &&
            sqrt(pow(pt.dx - b['x'], 2) + pow(pt.dy - b['y'], 2)) < 50) {
          _activeDragType = 's2_building';
          _dragData = {
            'id': key,
            'offsetX': b['x'] - pt.dx,
            'offsetY': b['y'] - pt.dy,
          };
          _playSound(_clickPlayer, _clickUrl);
          return;
        }
      }

      // Palette road tool (center around -320, 150)
      if (sqrt(pow(pt.dx - -320, 2) + pow(pt.dy - 150, 2)) < 60) {
        Map<String, dynamic>? sourceB;
        for (var k in _s2Buildings.keys) {
          if (_s2Buildings[k]!['placed'] &&
              !_s2Roads.any((r) => r['bId'] == k)) {
            sourceB = _s2Buildings[k];
            break;
          }
        }
        if (sourceB != null) {
          _activeDragType = 's2_road_draw';
          _dragData = {
            'sourceB': sourceB,
            'sx': sourceB['x'],
            'sy': sourceB['y'] + 30,
          };
          setState(() {
            _s2ActiveRoad = {
              'sx': sourceB!['x'],
              'sy': sourceB['y'] + 30,
              'ex': pt.dx,
              'ey': pt.dy,
              'valid': false,
            };
          });
        } else {
          _activeDragType = 's2_road_draw';
          _dragData = {'sourceB': null, 'sx': pt.dx, 'sy': pt.dy};
          setState(() {
            _s2ActiveRoad = {
              'sx': pt.dx,
              'sy': pt.dy,
              'ex': pt.dx,
              'ey': pt.dy,
              'valid': false,
            };
          });
        }
        _playSound(_clickPlayer, _clickUrl);
        if (_step == 1) _markStepComplete(200);
        return;
      }

      for (var key in _s2Buildings.keys) {
        var b = _s2Buildings[key]!;
        if (b['placed'] &&
            sqrt(pow(pt.dx - b['x'], 2) + pow(pt.dy - b['y'], 2)) < 50) {
          if (!_s2Roads.any((r) => r['bId'] == key)) {
            _activeDragType = 's2_road_draw';
            _dragData = {'sourceB': b, 'sx': b['x'], 'sy': b['y'] + 30};
            setState(() {
              _s2ActiveRoad = {
                'sx': b['x'],
                'sy': b['y'] + 30,
                'ex': pt.dx,
                'ey': pt.dy,
                'valid': false,
              };
            });
            _playSound(_clickPlayer, _clickUrl);
            if (_step == 1 && b['name'] == 'House') _markStepComplete(200);
            return;
          }
        }
      }
    } else if (_scenario == 3) {
      if (!_s3SsActive &&
          sqrt(pow(pt.dx - -290, 2) + pow(pt.dy - -110, 2)) < 60) {
        setState(() {
          _s3SsActive = true;
          _s3SsX = pt.dx;
          _s3SsY = pt.dy;
        });
        _activeDragType = 's3_ss';
        _dragData = {'offsetX': 0.0, 'offsetY': 0.0};
        _playSound(_clickPlayer, _clickUrl);
        return;
      }
      if (_s3SsActive &&
          sqrt(pow(pt.dx - (_s3SsX + 75), 2) + pow(pt.dy - (_s3SsY - 75), 2)) <
              120 &&
          !_s3LineDrawn) {
        _activeDragType = 's3_ss';
        _dragData = {'offsetX': _s3SsX - pt.dx, 'offsetY': _s3SsY - pt.dy};
        _playSound(_clickPlayer, _clickUrl);
        return;
      }
      if (!_s3Tracing &&
          sqrt(pow(pt.dx - _s3PenX, 2) + pow(pt.dy - _s3PenY, 2)) < 80) {
        _activeDragType = 's3_pen';
        _dragData = {'offsetX': _s3PenX - pt.dx, 'offsetY': _s3PenY - pt.dy};
        _playSound(_clickPlayer, _clickUrl);
        return;
      }
    } else if (_scenario == 5) {
      for (int i = 0; i < _s5Pieces.length; i++) {
        var p = _s5Pieces[i];
        if (p['locked']) continue;
        bool isHoriz = (p['rot'] % 180 == 0);
        double dx = (pt.dx - p['cx']).abs();
        double dy = (pt.dy - p['cy']).abs();
        bool hit =
            isHoriz
                ? (dx < p['w'] / 2 + 20 && dy < p['h'] / 2 + 20)
                : (dx < p['h'] / 2 + 20 && dy < p['w'] / 2 + 20);

        if (hit) {
          _activeDragType = 's5_piece';
          _dragData = {
            'idx': i,
            'startX': pt.dx,
            'startY': pt.dy,
            'initCx': p['cx'],
            'initCy': p['cy'],
            'moved': false,
          };
          return;
        }
      }
    }

    _activeDragType = 'canvas';
  }

  void _handleInteractionUpdateAbsolute(Offset pt) {
    setState(() {
      if (_activeDragType == 's1_handle') {
        double angle = atan2(-pt.dy, pt.dx) * 180 / pi;
        if (angle < 0) angle += 360;
        double norm = angle % 180;
        if (norm < 10) norm = 10;
        if (norm > 170) norm = 170;

        if ((norm - 90).abs() < 6) {
          norm = 90;
          if (!_s1Snapped) {
            _s1Snapped = true;
            _playSound(_clickPlayer, _clickUrl);
          }
        } else {
          _s1Snapped = false;
        }
        _s1Angle = norm;
        if (_step == 1 && (_s1Angle - 90).abs() <= 15) {
          _markStepComplete(500);
        }
      } else if (_activeDragType == 's2_building') {
        var b = _s2Buildings[_dragData['id']]!;
        b['x'] = pt.dx + _dragData['offsetX'];
        b['y'] = pt.dy + _dragData['offsetY'];
      } else if (_activeDragType == 's2_road_draw') {
        if (_s2ActiveRoad != null) {
          _s2ActiveRoad!['ex'] = pt.dx;
          _s2ActiveRoad!['ey'] = pt.dy;
          var b = _dragData['sourceB'];
          if (b == null) {
            var closest = _s2Buildings.values.firstWhere(
              (bld) =>
                  bld['placed'] &&
                  sqrt(pow(pt.dx - bld['x'], 2) + pow(pt.dy - bld['y'], 2)) <
                      50,
              orElse: () => <String, dynamic>{},
            );
            if (closest.isNotEmpty) {
              _dragData['sourceB'] = closest;
              _dragData['sx'] = closest['x'];
              _dragData['sy'] = closest['y'] + 30;
              _s2ActiveRoad!['sx'] = closest['x'];
              _s2ActiveRoad!['sy'] = closest['y'] + 30;
              b = closest;
            }
          }
          if (b != null) {
            bool nearAvenue = (pt.dy - 100).abs() < 40;
            double dx = (pt.dx - b['x']).abs();
            double dy = pt.dy - (b['y'] + 30);
            bool isVertical = dx < 30 && dy > 10;
            if (nearAvenue && isVertical) {
              _s2ActiveRoad!['ex'] = b['x'];
              _s2ActiveRoad!['ey'] = 100.0;
              _s2ActiveRoad!['valid'] = true;
            } else {
              _s2ActiveRoad!['valid'] = false;
            }
          } else {
            _s2ActiveRoad!['valid'] = false;
          }
        }
      } else if (_activeDragType == 's3_ss') {
        if (_s3SsPlaced) {
          _s3SsX = pt.dx + _dragData['offsetX'];
          _s3SsY = 80;
          if (_s3SsX.abs() < 25) {
            _s3SsX = 0;
            if (!_s3SsAligned) {
              _s3SsAligned = true;
              _playSound(_successPlayer, _successUrl);
              if (_step == 1) _markStepComplete(1000);
            }
          } else {
            _s3SsAligned = false;
          }
        } else {
          _s3SsX = pt.dx + _dragData['offsetX'];
          _s3SsY = pt.dy + _dragData['offsetY'];
        }
      } else if (_activeDragType == 's3_pen') {
        _s3PenX = pt.dx + _dragData['offsetX'];
        _s3PenY = pt.dy + _dragData['offsetY'];

        if (_s3SsAligned &&
            _s3PenX.abs() < 50 &&
            _s3PenY > 20 &&
            _s3PenY < 150) {
          _s3PenX = 0;
          double tipY = _s3PenY - 45;
          if (tipY < 0) tipY = 0;
          if (tipY > 80) tipY = 80;
          _s3DrawnLineEndY = tipY;
        }
      } else if (_activeDragType == 's5_piece') {
        if (sqrt(
              pow(pt.dx - _dragData['startX'], 2) +
                  pow(pt.dy - _dragData['startY'], 2),
            ) >
            5) {
          _dragData['moved'] = true;
        }
        var p = _s5Pieces[_dragData['idx']];
        p['cx'] = _dragData['initCx'] + (pt.dx - _dragData['startX']);
        p['cy'] = _dragData['initCy'] + (pt.dy - _dragData['startY']);
      }
    });
  }

  void _handleInteractionEnd() {
    if (_activeDragType == null) return;

    setState(() {
      if (_activeDragType == 's1_handle') {
        if (_s1Snapped && _step == 2) {
          _markStepComplete();
        }
      } else if (_activeDragType == 's2_building') {
        var b = _s2Buildings[_dragData['id']]!;
        if ((b['x'] - b['tx']).abs() < 50 && (b['y'] - b['ty']).abs() < 50) {
          b['x'] = b['tx'];
          b['y'] = b['ty'];
          b['placed'] = true;
          _playSound(_clickPlayer, _clickUrl);
          if (_step == 0 && _dragData['id'] == 'house') _markStepComplete(1000);
        } else {
          b['x'] = b['startX'];
          b['y'] = b['startY'];
          _playSound(_errorPlayer, _errorUrl);
        }
      } else if (_activeDragType == 's2_road_draw') {
        if (_s2ActiveRoad != null && _s2ActiveRoad!['valid']) {
          _s2Roads.add({
            'bId': _dragData['sourceB']['name'].toLowerCase(),
            'sx': _s2ActiveRoad!['sx'],
            'sy': _s2ActiveRoad!['sy'],
            'ex': _s2ActiveRoad!['ex'],
            'ey': _s2ActiveRoad!['ey'],
          });
          _playSound(_successPlayer, _successUrl);
          if (_step == 2 && _dragData['sourceB']['name'] == 'House') {
            _markStepComplete(1000);
          }
          if (_step == 3 && _s2Roads.length == 3) _markStepComplete(1500);
        } else {
          _playSound(_errorPlayer, _errorUrl);
        }
        _s2ActiveRoad = null;
      } else if (_activeDragType == 's3_ss') {
        if (!_s3SsPlaced) {
          if (_s3SsY > 0 && _s3SsY < 150) {
            _s3SsY = 80;
            _s3SsPlaced = true;
            _playSound(_clickPlayer, _clickUrl);
            if (_step == 0) _markStepComplete(1000);
          } else {
            _s3SsActive = false;
            _s3SsX = _s3SsStartX;
            _s3SsY = _s3SsStartY;
            _playSound(_errorPlayer, _errorUrl);
          }
        }
      } else if (_activeDragType == 's3_pen') {
        double tipY = _s3PenY - 45;
        if (_s3SsAligned && _s3PenX.abs() < 40 && tipY >= 60) {
          _s3LineDrawn = true;
          _s3DrawnLineEndY = 80;
          _playSound(_successPlayer, _successUrl);
          _markStepComplete(500);
        } else if (_s3SsAligned &&
            _s3PenX.abs() < 120 &&
            tipY > -100 &&
            tipY < 50) {
          _s3Tracing = true;
          _s3PenX = 0;
          _s3PenY = 45;
          Future.delayed(const Duration(milliseconds: 50), () {
            if (!mounted) return;
            setState(() {
              _s3PenY = 125;
              _s3DrawnLineEndY = 80;
            });
            _playSound(_clickPlayer, _clickUrl);
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (!mounted) return;
              setState(() {
                _s3Tracing = false;
                _s3LineDrawn = true;
              });
              _markStepComplete(500);
            });
          });
        } else {
          _s3PenX = _s3PenStartX;
          _s3PenY = _s3PenStartY;
          if (!_s3LineDrawn) _s3DrawnLineEndY = 0;
          _playSound(_errorPlayer, _errorUrl);
        }
      } else if (_activeDragType == 's5_piece') {
        var p = _s5Pieces[_dragData['idx']];
        if (_dragData['moved'] == true) {
          Map<String, dynamic>? bestSlot;
          double minDist = 60;
          for (var slot in _s5Slots) {
            if (slot['type'] == p['type'] && slot['filledBy'] == null) {
              double d = sqrt(
                pow(p['cx'] - slot['tx'], 2) + pow(p['cy'] - slot['ty'], 2),
              );
              if (d < minDist) {
                minDist = d;
                bestSlot = slot;
              }
            }
          }

          if (bestSlot != null) {
            if (p['rot'] % 180 == bestSlot['tr'] % 180) {
              p['cx'] = bestSlot['tx'];
              p['cy'] = bestSlot['ty'];
              p['locked'] = true;
              bestSlot['filledBy'] = p['id'];
              _playSound(_successPlayer, _successUrl);
              if (_step == 0) _markStepComplete(1000);
              _checkS5Corners();
            } else {
              p['error'] = true;
              _playSound(_errorPlayer, _errorUrl);
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) setState(() => p['error'] = false);
              });
            }
          }
        }
      }

      _activeDragType = null;
    });
  }

  void _checkS5Corners() {
    Map<String, bool> slots = {};
    for (var s in _s5Slots) {
      slots[s['id']] = s['filledBy'] != null;
    }

    if (slots['top']! && slots['left']!) _s5Corners['tl'] = true;
    if (slots['top']! && slots['right']!) _s5Corners['tr'] = true;
    if (slots['bottom']! && slots['left']!) _s5Corners['bl'] = true;
    if (slots['bottom']! && slots['right']!) _s5Corners['br'] = true;

    if ((_s5Corners['tl']! ||
            _s5Corners['tr']! ||
            _s5Corners['bl']! ||
            _s5Corners['br']!) &&
        _step == 1) {
      _markStepComplete(1000);
    }
    if (_s5Corners['tl']! &&
        _s5Corners['tr']! &&
        _s5Corners['bl']! &&
        _s5Corners['br']!) {
      if (_step == 2) _markStepComplete(2500);
    }
  }

  void _runS4Robot() async {
    if (_s4Sequence.isEmpty || _s4Running) return;
    setState(() {
      _s4Running = true;
      _s4RobotX = -100;
      _s4RobotY = 100;
      _s4RobotDir = 0;
    });
    _playSound(_clickPlayer, _clickUrl);

    for (int i = 0; i < _s4Sequence.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      setState(() {
        String cmd = _s4Sequence[i];
        if (cmd == 'F') {
          double nx = _s4RobotX, ny = _s4RobotY;
          if (_s4RobotDir == 0) {
            ny -= 100;
          } else if (_s4RobotDir == 90) {
            nx += 100;
          } else if (_s4RobotDir == 180) {
            ny += 100;
          } else if (_s4RobotDir == 270) {
            nx -= 100;
          }

          if (nx < -150 ||
              nx > 150 ||
              ny < -150 ||
              ny > 150 ||
              (nx == 0 && ny == 0) ||
              (nx == 100 && ny == 0) ||
              (nx == 0 && ny == 100) ||
              (nx == 100 && ny == 100)) {
            _playSound(_errorPlayer, _errorUrl);
            _s4Running = false;
          } else {
            _s4RobotX = nx;
            _s4RobotY = ny;
          }
        } else if (cmd == 'R') {
          _s4RobotDir = (_s4RobotDir + 90) % 360;
        }
        _playSound(_clickPlayer, _clickUrl);
      });
      if (!_s4Running) break;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      if (_s4Running && _s4RobotX == 100 && _s4RobotY == -100) {
        _playSound(_successPlayer, _successUrl);
        if (_step <= 1) _markStepComplete(1500);
      } else {
        if (_s4Running) {
          _playSound(_errorPlayer, _errorUrl);
        }
        _s4Running = false;
        _s4RobotX = -100;
        _s4RobotY = 100;
        _s4RobotDir = 0;
      }
    });
  }

  // --- DRAGGABLE MODALS ---
  Widget _buildSummaryModal(double sw, double sh) {
    _summaryModalPos ??= Offset(
      sw / 2 - 200,
      sh / 2 - 150,
    ); // Initial center pos

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
    );
  }

  Widget _buildSuccessModal(double sw, double sh) {
    _successModalPos ??= Offset(
      sw / 2 - 200,
      sh / 2 - 180,
    ); // Initial center pos

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
    );
  }

  // --- DATA / TRANSLATIONS ---
  List<Map<String, String>> _getScenarioSteps(int id) {
    if (id == 1) {
      return [
        {'hud': t('s1_1_hud'), 'text': t('s1_1_txt')},
        {'hud': t('s1_2_hud'), 'text': t('s1_2_txt')},
        {'hud': t('s1_3_hud'), 'text': t('s1_3_txt')},
        {'hud': t('s1_4_hud'), 'text': t('s1_4_txt'), 'summary': t('s1_4_sum')},
      ];
    }
    if (id == 2) {
      return [
        {'hud': t('s2_1_hud'), 'text': t('s2_1_txt')},
        {'hud': t('s2_2_hud'), 'text': t('s2_2_txt')},
        {'hud': t('s2_3_hud'), 'text': t('s2_3_txt')},
        {'hud': t('s2_4_hud'), 'text': t('s2_4_txt'), 'summary': t('s2_4_sum')},
      ];
    }
    if (id == 3) {
      return [
        {'hud': t('s3_1_hud'), 'text': t('s3_1_txt')},
        {'hud': t('s3_2_hud'), 'text': t('s3_2_txt')},
        {'hud': t('s3_3_hud'), 'text': t('s3_3_txt')},
        {'hud': t('s3_4_hud'), 'text': t('s3_4_txt'), 'summary': t('s3_4_sum')},
      ];
    }
    if (id == 4) {
      return [
        {'hud': t('s4_1_hud'), 'text': t('s4_1_txt')},
        {'hud': t('s4_2_hud'), 'text': t('s4_2_txt'), 'summary': t('s4_2_sum')},
      ];
    }
    if (id == 5) {
      return [
        {'hud': t('s5_1_hud'), 'text': t('s5_1_txt')},
        {'hud': t('s5_2_hud'), 'text': t('s5_2_txt')},
        {'hud': t('s5_3_hud'), 'text': t('s5_3_txt'), 'summary': t('s5_3_sum')},
      ];
    }
    return [];
  }

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': "Perpendicular Lines",
      'appSubtitle': "Class 7 • PARALLEL AND INTERSECTING LINES",
      'enterLab': "Enter Lab",
      'toggleLang': "Toggle Language",
      'resetLab': "Master Reset",
      'settingsBtn': "Settings",
      'selectScenario': "Select Scenario",
      'theory': "Theory",
      'missionObj': "Mission Objective:",
      'procSteps': "Procedural Steps",
      'stepLabel': "STEP",
      'labSummary': "Lab Summary",
      'allCompletedTitle': "Master of Perpendicularity!",
      'allCompletedText':
          "You have successfully mastered perpendicular lines across all dimensions and applications!",
      'restartLab': "Restart Lab",
      'scenarioCompletedText': "Scenario Completed!",
      'scen1Title': "1. The Angle Balancer",
      's1Obj':
          "Discover the unique property of perpendicular lines by manipulating intersecting lines until all four angles become equal.",
      's1_1_hud': "Drag line 'm' to rotate it.",
      's1_1_txt':
          "A horizontal line 'l' is fixed on the screen. A second line 'm' intersects it, pivoted at the center. CLICK and DRAG the end of line 'm' to rotate it.",
      's1_2_hud': "Make all four angles equal.",
      's1_2_txt':
          "As you rotate line 'm', observe the four angle measurements changing in real-time. Try to make all four angles show the same number.",
      's1_3_hud': "Snap to 90°",
      's1_3_txt': "Adjust line 'm' until it snaps into place.",
      's1_4_hud': "Concept Unlocked!",
      's1_4_txt':
          "When intersecting lines form four equal angles, each angle is a 90° right angle. These lines are called PERPENDICULAR lines.",
      's1_4_sum':
          "Perpendicularity\nWhen two lines intersect to form four equal angles, each angle is precisely 90°. These are called Perpendicular Lines, indicated by square symbols.",
      'scen2Title': "2. The City Planner",
      's2Obj':
          "Apply the concept of perpendicularity to a real-world context by building a city grid.",
      's2_1_hud': "Drag the House to the grid.",
      's2_1_txt':
          "You see a main avenue running horizontally. On the left, there is a palette of building icons. DRAG the house and DROP it north of the avenue.",
      's2_2_hud': "Drag a road segment to connect.",
      's2_2_txt':
          "Now, DRAG a road segment from the palette to connect the house to the main avenue.",
      's2_3_hud': "Release to place it perfectly.",
      's2_3_txt':
          "When the road segment snaps into the correct position (90°), RELEASE the mouse button to place it.",
      's2_4_hud': "Connect School and Shop.",
      's2_4_txt':
          "Connect the school and the shop to the main avenue with perpendicular roads to complete the city.",
      's2_4_sum':
          "Real-world Application\nCity planners use perpendicular streets to organize layouts securely and logically. Perpendicular intersections ensure maximum stability and navigation efficiency.",
      'scen3Title': "3. The Carpenter's Guide",
      's3Obj':
          "To use a virtual tool (a set square) to construct a line perpendicular to a given line segment.",
      's3_1_hud': "Drag the set square to the plank.",
      's3_1_txt':
          "A wooden plank is shown on a workbench. DRAG the set square from the toolbox and DROP it onto the plank.",
      's3_2_hud': "Slide to align with the target dot.",
      's3_2_txt':
          "SLIDE the set square along the bottom edge of the plank until its vertical edge aligns with the marked dot.",
      's3_3_hud': "Drag the pencil to draw a line.",
      's3_3_txt':
          "DRAG the pencil from the toolbox and DRAW a line along the vertical edge of the set square.",
      's3_4_hud': "Square forms 90° angle.",
      's3_4_txt':
          "Tools like set squares help us draw perfect perpendicular lines. The two edges of the square always form a 90° angle.",
      's3_4_sum':
          "Practical Tools\nA set square provides a rigid 90° corner, ensuring that lines drawn along its adjacent edges are always perpendicular to each other.",
      'scen4Title': "4. The Robot Navigator",
      's4Obj':
          "To guide a robot through a maze to a target by using only forward movements and 90-degree turns.",
      's4_1_hud': "Add blocks to sequence.",
      's4_1_txt':
          "Your robot needs to reach the goal. CLICK the command blocks to add them to the sequence (Max 5). You must use Forward and Turn 90° Right.",
      's4_2_hud': "Click RUN to test path.",
      's4_2_txt':
          "Once you have built your command sequence, CLICK the 'Run' button to test your path.",
      's4_2_sum':
          "Navigation\nNavigating grid-based systems relies entirely on perpendicular (90°) turns to switch axes between horizontal and vertical movement.",
      'scen5Title': "5. The Frame Maker",
      's5Obj':
          "To assemble a rectangular picture frame, understanding that its corners must be perpendicular.",
      's5_1_hud': "Drag pieces to arrange.",
      's5_1_txt':
          "You have four pieces of a wooden frame. DRAG the pieces onto the canvas near the target guide.",
      's5_2_hud': "Click to rotate 90°, Drag to snap.",
      's5_2_txt':
          "Connect the corners. CLICK a piece to rotate it 90°. A corner will lock and turn green if it forms a perfect 90° angle.",
      's5_3_hud': "Complete all 4 corners.",
      's5_3_txt':
          "Continue rotating and connecting pieces until all four corners are locked and the frame is complete.",
      's5_3_sum':
          "Geometry in Design\nA rectangle by definition requires four 90° angles. Ensuring perpendicularity at each corner guarantees a perfect shape.",
    },
    'hi': {
      'appTitle': "लंबवत रेखाएं",
      'appSubtitle': "कक्षा 7 • समांतर और प्रतिच्छेदी रेखाएं",
      'enterLab': "प्रयोगशाला में प्रवेश करें",
      'toggleLang': "भाषा बदलें",
      'resetLab': "मास्टर रीसेट",
      'settingsBtn': "सेटिंग्स",
      'selectScenario': "परिदृश्य चुनें",
      'theory': "सिद्धांत",
      'missionObj': "मिशन उद्देश्य:",
      'procSteps': "प्रक्रियात्मक कदम",
      'stepLabel': "चरण",
      'labSummary': "प्रयोगशाला सारांश",
      'allCompletedTitle': "लंबवतता के मास्टर!",
      'allCompletedText':
          "आपने सभी आयामों और अनुप्रयोगों में लंबवत रेखाओं में सफलतापूर्वक महारत हासिल कर ली है!",
      'restartLab': "लैब रीस्टार्ट करें",
      'scenarioCompletedText': "परिदृश्य पूरा हुआ!",
      'scen1Title': "1. कोण संतुलन",
      's1Obj':
          "प्रतिच्छेदी रेखाओं में हेरफेर करके लंबवत रेखाओं की अनूठी संपत्ति की खोज करें जब तक कि सभी चार कोण बराबर न हो जाएं।",
      's1_1_hud': "घुमाने के लिए रेखा 'm' को खींचें।",
      's1_1_txt':
          "एक क्षैतिज रेखा 'l' स्क्रीन पर स्थिर है। एक दूसरी रेखा 'm' इसे काटती है, और केंद्र पर धुरी है। घुमाने के लिए रेखा 'm' के सिरे को क्लिक करें और खींचें।",
      's1_2_hud': "सभी चार कोणों को बराबर करें।",
      's1_2_txt':
          "जैसे ही आप रेखा 'm' को घुमाते हैं, वास्तविक समय में बदलते चार कोण मापों का निरीक्षण करें। सभी चार कोणों को समान संख्या दिखाने का प्रयास करें।",
      's1_3_hud': "90° पर स्नैप करें",
      's1_3_txt':
          "रेखा 'm' को तब तक समायोजित करें जब तक कि वह अपनी जगह पर स्नैप न हो जाए।",
      's1_4_hud': "अवधारणा अनलॉक हो गई!",
      's1_4_txt':
          "जब प्रतिच्छेदी रेखाएं चार समान कोण बनाती हैं, तो प्रत्येक कोण 90° का समकोण होता है। इन रेखाओं को लंबवत रेखाएं कहा जाता है।",
      's1_4_sum':
          "लंबवतता\nजब दो रेखाएं चार समान कोण बनाने के लिए प्रतिच्छेद करती हैं, तो प्रत्येक कोण ठीक 90° होता है। इन्हें लंबवत रेखाएं कहा जाता है, जिन्हें वर्ग प्रतीकों द्वारा इंगित किया जाता है।",
      'scen2Title': "2. नगर योजनाकार",
      's2Obj':
          "सिटी ग्रिड बनाकर वास्तविक दुनिया के संदर्भ में लंबवतता की अवधारणा को लागू करें।",
      's2_1_hud': "घर को ग्रिड पर खींचें।",
      's2_1_txt':
          "आप क्षैतिज रूप से चल रहे एक मुख्य मार्ग को देखते हैं। बाईं ओर, भवन आइकनों का एक पैलेट है। घर को खींचें और उसे एवेन्यू के उत्तर में छोड़ दें।",
      's2_2_hud': "सड़क के एक हिस्से को खींचें।",
      's2_2_txt':
          "अब, घर को मुख्य मार्ग से जोड़ने के लिए पैलेट से सड़क का एक हिस्सा खींचें।",
      's2_3_hud': "इसे पूरी तरह से रखने के लिए छोड़ दें।",
      's2_3_txt':
          "जब सड़क सही स्थिति (90°) में स्नैप हो जाए, तो इसे रखने के लिए माउस बटन छोड़ दें।",
      's2_4_hud': "स्कूल और दुकान को जोड़ें।",
      's2_4_txt':
          "शहर को पूरा करने के लिए स्कूल और दुकान को लंबवत सड़कों के साथ मुख्य मार्ग से जोड़ें।",
      's2_4_sum':
          "वास्तविक दुनिया का अनुप्रयोग\nनगर योजनाकार लेआउट को सुरक्षित और तार्किक रूप से व्यवस्थित करने के लिए लंबवत सड़कों का उपयोग करते हैं। लंबवत चौराहे अधिकतम स्थिरता और नेविगेशन दक्षता सुनिश्चित करते हैं।",
      'scen3Title': "3. बढ़ई का गाइड",
      's3Obj':
          "एक दिए गए रेखा खंड के लंबवत एक रेखा खींचने के लिए एक आभासी उपकरण (सेट स्क्वायर) का उपयोग करें।",
      's3_1_hud': "सेट स्क्वायर को तख्ते पर खींचें।",
      's3_1_txt':
          "कार्यक्षेत्र पर एक लकड़ी का तख्ता दिखाया गया है। टूलबॉक्स से सेट स्क्वायर खींचें और इसे तख्ते पर छोड़ दें।",
      's3_2_hud': "लक्ष्य बिंदु के साथ संरेखित करने के लिए स्लाइड करें।",
      's3_2_txt':
          "तख्ते के निचले किनारे के साथ सेट स्क्वायर को तब तक स्लाइड करें जब तक कि उसका ऊर्ध्वाधर किनारा चिह्नित बिंदु के साथ संरेखित न हो जाए।",
      's3_3_hud': "रेखा खींचने के लिए पेंसिल खींचें।",
      's3_3_txt':
          "टूलबॉक्स से पेंसिल खींचें और सेट स्क्वायर के ऊर्ध्वाधर किनारे के साथ एक रेखा खींचें।",
      's3_4_hud': "स्क्वायर 90° कोण बनाता है।",
      's3_4_txt':
          "सेट स्क्वायर जैसे उपकरण हमें एकदम सही लंबवत रेखाएं खींचने में मदद करते हैं। वर्ग के दो किनारे हमेशा 90° का कोण बनाते हैं।",
      's3_4_sum':
          "व्यावहारिक उपकरण\nएक सेट स्क्वायर एक कठोर 90° कोना प्रदान करता है, यह सुनिश्चित करता है कि इसके आसन्न किनारों के साथ खींची गई रेखाएं हमेशा एक-दूसरे के लंबवत हों।",
      'scen4Title': "4. रोबोट नेविगेटर",
      's4Obj':
          "केवल आगे की हरकतों और 90-डिग्री मोड़ का उपयोग करके एक भूलभुलैया के माध्यम से रोबोट को लक्ष्य तक मार्गदर्शन करें।",
      's4_1_hud': "अनुक्रम में ब्लॉक जोड़ें।",
      's4_1_txt':
          "आपके रोबोट को लक्ष्य तक पहुंचने की आवश्यकता है। उन्हें अनुक्रम में जोड़ने के लिए कमांड ब्लॉक पर क्लिक करें (अधिकतम 5)। आपको फॉरवर्ड और टर्न 90° राइट का उपयोग करना होगा।",
      's4_2_hud': "परीक्षण के लिए रन क्लिक करें।",
      's4_2_txt':
          "एक बार जब आप अपना कमांड अनुक्रम बना लेते हैं, तो अपने पथ का परीक्षण करने के लिए 'रन' बटन पर क्लिक करें।",
      's4_2_sum':
          "नेविगेशन\nक्षैतिज और ऊर्ध्वाधर आंदोलन के बीच कुल्हाड़ियों को स्विच करने के लिए ग्रिड-आधारित प्रणालियों को नेविगेट करना पूरी तरह से लंबवत (90°) मोड़ पर निर्भर करता है।",
      'scen5Title': "5. फ्रेम मेकर",
      's5Obj':
          "एक आयताकार चित्र फ्रेम को इकट्ठा करने के लिए, यह समझना कि इसके कोने लंबवत होने चाहिए।",
      's5_1_hud': "टुकड़ों को खींचकर व्यवस्थित करें।",
      's5_1_txt':
          "आपके पास लकड़ी के फ्रेम के चार टुकड़े हैं। लक्ष्य गाइड के पास कैनवास पर टुकड़ों को खींचें।",
      's5_2_hud': "घुमाने के लिए क्लिक करें, स्नैप करने के लिए खींचें।",
      's5_2_txt':
          "कोनों को कनेक्ट करें। इसे 90° घुमाने के लिए एक टुकड़े पर क्लिक करें। 90° कोण बनने पर एक कोना लॉक हो जाएगा और हरा हो जाएगा।",
      's5_3_hud': "सभी 4 कोने पूरे करें।",
      's5_3_txt':
          "जब तक चारों कोने लॉक न हो जाएं और फ्रेम पूरा न हो जाए, तब तक टुकड़ों को घुमाना और जोड़ना जारी रखें।",
      's5_3_sum':
          "डिजाइन में ज्यामिति\nपरिभाषा के अनुसार एक आयत में चार 90° कोणों की आवश्यकता होती है। प्रत्येक कोने पर लंबवतता सुनिश्चित करना एक सही आकार की गारंटी देता है।",
    },
  };
}

// --- MAIN CANVAS PAINTER ---
class MasterPainter extends CustomPainter {
  final double baseScale;
  final double canvasZoom;
  final Offset canvasPan;
  final int scenario, step;
  final double s1Angle;
  final bool s1Snapped;
  final Map<String, Map<String, dynamic>> s2Buildings;
  final List<Map<String, dynamic>> s2Roads;
  final Map<String, dynamic>? s2ActiveRoad;
  final bool s3SsActive, s3SsPlaced, s3SsAligned, s3LineDrawn, s3Tracing;
  final double s3SsX, s3SsY, s3PenX, s3PenY, s3DrawnLineEndY;
  final List<String> s4Sequence;
  final double s4RobotX, s4RobotY, s4RobotDir;
  final List<Map<String, dynamic>> s5Pieces;
  final Map<String, bool> s5Corners;

  MasterPainter({
    required this.baseScale,
    required this.canvasZoom,
    required this.canvasPan,
    required this.scenario,
    required this.step,
    required this.s1Angle,
    required this.s1Snapped,
    required this.s2Buildings,
    required this.s2Roads,
    required this.s2ActiveRoad,
    required this.s3SsActive,
    required this.s3SsPlaced,
    required this.s3SsAligned,
    required this.s3SsX,
    required this.s3SsY,
    required this.s3PenX,
    required this.s3PenY,
    required this.s3LineDrawn,
    required this.s3Tracing,
    required this.s3DrawnLineEndY,
    required this.s4Sequence,
    required this.s4RobotX,
    required this.s4RobotY,
    required this.s4RobotDir,
    required this.s5Pieces,
    required this.s5Corners,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      size.width / 2 + canvasPan.dx,
      size.height / 2 + canvasPan.dy,
    );
    canvas.scale(baseScale * canvasZoom);

    final gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1;
    for (double i = -400; i <= 400; i += 40) {
      canvas.drawLine(Offset(i, -400), Offset(i, 400), gridPaint);
      canvas.drawLine(Offset(-400, i), Offset(400, i), gridPaint);
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

  void _paintS1(Canvas canvas) {
    final paintLine =
        Paint()
          ..color = s1Snapped ? const Color(0xFF22C55E) : Colors.white
          ..strokeWidth = 4;

    // Line l
    canvas.drawLine(const Offset(-300, 0), const Offset(300, 0), paintLine);
    _drawText(
      canvas,
      "l",
      const Offset(280, -15),
      fontSize: 22,
      fontStyle: FontStyle.italic,
    );

    if (s1Snapped) {
      final sqPaint =
          Paint()
            ..color = const Color(0xFF22C55E)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke;
      final fillPaint =
          Paint()
            ..color = const Color(0xFF22C55E).withOpacity(0.2)
            ..style = PaintingStyle.fill;
      double s = 20;
      canvas.drawRect(Rect.fromLTRB(0, -s, s, 0), fillPaint);
      canvas.drawRect(Rect.fromLTRB(0, -s, s, 0), sqPaint);
      canvas.drawRect(Rect.fromLTRB(-s, -s, 0, 0), fillPaint);
      canvas.drawRect(Rect.fromLTRB(-s, -s, 0, 0), sqPaint);
      canvas.drawRect(Rect.fromLTRB(-s, 0, 0, s), fillPaint);
      canvas.drawRect(Rect.fromLTRB(-s, 0, 0, s), sqPaint);
      canvas.drawRect(Rect.fromLTRB(0, 0, s, s), fillPaint);
      canvas.drawRect(Rect.fromLTRB(0, 0, s, s), sqPaint);
    } else {
      double r = 100;
      _drawArcSector(
        canvas,
        0,
        0,
        r,
        0,
        s1Angle,
        const Color(0xFF3B82F6).withOpacity(0.3),
        "${s1Angle.round()}°",
      );
      _drawArcSector(
        canvas,
        0,
        0,
        r,
        s1Angle,
        180,
        const Color(0xFF10B981).withOpacity(0.3),
        "${(180 - s1Angle).round()}°",
      );
      _drawArcSector(
        canvas,
        0,
        0,
        r,
        180,
        180 + s1Angle,
        const Color(0xFFEAB308).withOpacity(0.3),
        "${s1Angle.round()}°",
      );
      _drawArcSector(
        canvas,
        0,
        0,
        r,
        180 + s1Angle,
        360,
        const Color(0xFFEF4444).withOpacity(0.3),
        "${(180 - s1Angle).round()}°",
      );
    }

    // Line m
    canvas.save();
    canvas.rotate(-s1Angle * pi / 180);
    canvas.drawLine(const Offset(-300, 0), const Offset(300, 0), paintLine);
    _drawText(
      canvas,
      "m",
      const Offset(280, -15),
      fontSize: 22,
      fontStyle: FontStyle.italic,
    );

    // Handle
    canvas.drawCircle(
      const Offset(240, 0),
      18,
      Paint()..color = const Color(0xFF6366F1),
    );
    canvas.drawCircle(
      const Offset(240, 0),
      18,
      Paint()
        ..color = const Color(0xFF020617)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.restore();

    canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.white);
  }

  void _paintS2(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-600, 80, 1200, 40),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawLine(
      const Offset(-600, 100),
      const Offset(600, 100),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 2,
    );

    // Palette
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-380, -300, 120, 600),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    _drawText(
      canvas,
      "PALETTE",
      const Offset(-320, -260),
      fontSize: 14,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.bold,
    );

    // Road Tool
    canvas.drawRect(
      const Rect.fromLTWH(-332, 120, 24, 60),
      Paint()..color = const Color(0xFF6366F1),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-325, 124, 10, 52),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    _drawText(
      canvas,
      "Road",
      const Offset(-320, 195),
      fontSize: 12,
      color: const Color(0xFFE2E8F0),
    );

    // Targets
    final targetPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    if (step == 0 && !s2Buildings['house']!['placed']) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-180, -80, 60, 60),
          const Radius.circular(10),
        ),
        targetPaint,
      );
    }
    if (step == 3 && !s2Buildings['school']!['placed']) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-30, -80, 60, 60),
          const Radius.circular(10),
        ),
        targetPaint,
      );
    }
    if (step == 3 && !s2Buildings['shop']!['placed']) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(120, -80, 60, 60),
          const Radius.circular(10),
        ),
        targetPaint,
      );
    }

    // Roads
    for (var r in s2Roads) {
      canvas.drawLine(
        Offset(r['sx'], r['sy']),
        Offset(r['ex'], r['ey']),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 16,
      );
      canvas.drawLine(
        Offset(r['sx'], r['sy']),
        Offset(r['ex'], r['ey']),
        Paint()
          ..color = const Color(0xFFFCD34D)
          ..strokeWidth = 2,
      );

      final sqPaint =
          Paint()
            ..color = const Color(0xFF22C55E)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke;
      final fillPaint =
          Paint()
            ..color = const Color(0xFF22C55E).withOpacity(0.2)
            ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTRB(r['ex'], r['ey'] - 15, r['ex'] + 15, r['ey']),
        fillPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(r['ex'], r['ey'] - 15, r['ex'] + 15, r['ey']),
        sqPaint,
      );
    }

    if (s2ActiveRoad != null) {
      canvas.drawLine(
        Offset(s2ActiveRoad!['sx'], s2ActiveRoad!['sy']),
        Offset(s2ActiveRoad!['ex'], s2ActiveRoad!['ey']),
        Paint()
          ..color =
              s2ActiveRoad!['valid']
                  ? const Color(0x9922C55E)
                  : const Color(0x99EF4444)
          ..strokeWidth = 16,
      );
    }

    // Buildings
    for (var b in s2Buildings.values) {
      canvas.save();
      canvas.translate(b['x'], b['y']);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-30, -30, 60, 60),
          const Radius.circular(10),
        ),
        Paint()..color = b['color'],
      );
      _drawText(canvas, b['icon'], const Offset(0, 0), fontSize: 30);
      _drawText(
        canvas,
        b['name'],
        const Offset(0, 45),
        fontSize: 12,
        color: Colors.white,
      );
      canvas.restore();
    }
  }

  void _paintS3(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-400, -200, 800, 600),
      Paint()..color = const Color(0xFF451A03),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-300, 0, 600, 80),
      Paint()..color = const Color(0xFFB45309),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-300, 0, 600, 80),
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      const Offset(0, 80),
      6,
      Paint()..color = const Color(0xFFFCD34D),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-340, -180, 100, 200),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-340, -180, 100, 200),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      "TOOLS",
      const Offset(-290, -150),
      fontSize: 12,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.bold,
    );

    if (s3LineDrawn || s3Tracing) {
      canvas.drawLine(
        const Offset(0, 0),
        Offset(0, s3DrawnLineEndY),
        Paint()
          ..color = const Color(0xFF1E293B)
          ..strokeWidth = 4,
      );
      if (s3LineDrawn) {
        final path =
            Path()
              ..moveTo(15, 80)
              ..lineTo(15, 65)
              ..lineTo(0, 65);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF22C55E)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }
    }

    if (!s3SsActive) {
      canvas.save();
      canvas.translate(-310, -130);
      final p1 =
          Path()
            ..moveTo(20.3, 21.7)
            ..lineTo(3.7, 5.1)
            ..lineTo(5.1, 3.7)
            ..lineTo(21.7, 20.3)
            ..close();
      canvas.drawPath(p1, Paint()..color = const Color(0xFF6366F1));
      canvas.restore();
    }

    if (!s3Tracing) {
      canvas.save();
      canvas.translate(s3PenX, s3PenY);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -30, 8, 60),
        Paint()..color = const Color(0xFFF59E0B),
      );
      final tip =
          Path()
            ..moveTo(-4, -30)
            ..lineTo(4, -30)
            ..lineTo(0, -45)
            ..close();
      canvas.drawPath(tip, Paint()..color = const Color(0xFFFCA5A5));
      final lead =
          Path()
            ..moveTo(-1, -40)
            ..lineTo(1, -40)
            ..lineTo(0, -45)
            ..close();
      canvas.drawPath(lead, Paint()..color = const Color(0xFF1E293B));
      canvas.restore();
    } else {
      canvas.save();
      canvas.translate(s3PenX, s3PenY);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -30, 8, 60),
        Paint()..color = const Color(0xFFF59E0B),
      );
      final tip =
          Path()
            ..moveTo(-4, -30)
            ..lineTo(4, -30)
            ..lineTo(0, -45)
            ..close();
      canvas.drawPath(tip, Paint()..color = const Color(0xFFFCA5A5));
      final lead =
          Path()
            ..moveTo(-1, -40)
            ..lineTo(1, -40)
            ..lineTo(0, -45)
            ..close();
      canvas.drawPath(lead, Paint()..color = const Color(0xFF1E293B));
      canvas.restore();
    }

    if (s3SsActive) {
      canvas.save();
      canvas.translate(s3SsX, s3SsY);
      double op1 = s3LineDrawn ? 0.2 : 0.8;
      double op2 = s3LineDrawn ? 0.1 : 0.6;
      final ss1 =
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, -150)
            ..lineTo(150, 0)
            ..close();
      canvas.drawPath(
        ss1,
        Paint()..color = const Color(0xFF6366F1).withOpacity(op1),
      );
      canvas.drawPath(
        ss1,
        Paint()
          ..color = const Color(0xFF4F46E5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final ss2 =
          Path()
            ..moveTo(20, -15)
            ..lineTo(20, -100)
            ..lineTo(100, -15)
            ..close();
      canvas.drawPath(
        ss2,
        Paint()..color = const Color(0xFF0F172A).withOpacity(op2),
      );

      if (step == 3) {
        final cPath =
            Path()
              ..moveTo(15, 0)
              ..lineTo(15, -15)
              ..lineTo(0, -15);
        canvas.drawPath(
          cPath,
          Paint()
            ..color = const Color(0xFF22C55E)
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke,
        );
      }
      canvas.restore();
    }
  }

  void _paintS4(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-150, -150, 300, 300),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-150, -150, 300, 300),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final lineP =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 2;
    canvas.drawLine(const Offset(-50, -150), const Offset(-50, 150), lineP);
    canvas.drawLine(const Offset(50, -150), const Offset(50, 150), lineP);
    canvas.drawLine(const Offset(-150, -50), const Offset(150, -50), lineP);
    canvas.drawLine(const Offset(-150, 50), const Offset(150, 50), lineP);

    final wallP = Paint()..color = const Color(0xFF475569);
    final wallS =
        Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    void drawWall(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), wallP);
      canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), wallS);
    }

    drawWall(-50, -50);
    drawWall(50, -50);
    drawWall(-50, 50);
    drawWall(50, 50);

    canvas.drawRect(
      const Rect.fromLTWH(-150, 50, 100, 100),
      Paint()..color = const Color(0xFF3B82F6).withOpacity(0.3),
    );
    _drawText(
      canvas,
      "START",
      const Offset(-100, 100),
      fontSize: 14,
      color: const Color(0xFF3B82F6),
      fontWeight: FontWeight.bold,
    );

    canvas.drawRect(
      const Rect.fromLTWH(50, -150, 100, 100),
      Paint()..color = const Color(0xFF22C55E).withOpacity(0.3),
    );
    _drawText(
      canvas,
      "GOAL",
      const Offset(100, -100),
      fontSize: 14,
      color: const Color(0xFF22C55E),
      fontWeight: FontWeight.bold,
    );

    canvas.save();
    canvas.translate(s4RobotX, s4RobotY);
    canvas.rotate(s4RobotDir * pi / 180);
    final robP =
        Path()
          ..moveTo(19, 7)
          ..lineTo(17, 7)
          ..lineTo(17, 5)
          ..arcToPoint(
            const Offset(15, 3),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(9, 3)
          ..arcToPoint(
            const Offset(7, 5),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(7, 7)
          ..lineTo(5, 7)
          ..arcToPoint(
            const Offset(3, 9),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(3, 15)
          ..arcToPoint(
            const Offset(5, 17),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(7, 17)
          ..lineTo(7, 19)
          ..arcToPoint(
            const Offset(9, 21),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(15, 21)
          ..arcToPoint(
            const Offset(17, 19),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(17, 17)
          ..lineTo(19, 17)
          ..arcToPoint(
            const Offset(21, 15),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..lineTo(21, 9)
          ..arcToPoint(
            const Offset(19, 7),
            radius: const Radius.circular(2),
            clockwise: false,
          )
          ..close();
    canvas.translate(-12, -12);
    canvas.drawPath(robP, Paint()..color = const Color(0xFF6366F1));
    canvas.drawCircle(
      const Offset(12, 12),
      2,
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.drawLine(
      const Offset(12, 12),
      const Offset(12, 5),
      Paint()
        ..color = const Color(0xFFEF4444)
        ..strokeWidth = 2,
    );
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-300, 200, 600, 150),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-300, 200, 600, 150),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke,
    );

    _drawText(
      canvas,
      "BLOCKS",
      const Offset(-180, 230),
      fontSize: 14,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.bold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-270, 250, 80, 40),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF3B82F6),
    );
    _drawText(
      canvas,
      "↑ FWD",
      const Offset(-230, 270),
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-170, 250, 80, 40),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFEAB308),
    );
    _drawText(
      canvas,
      "↱ 90°",
      const Offset(-130, 270),
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    _drawText(
      canvas,
      "SEQUENCE",
      const Offset(100, 230),
      fontSize: 14,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < 5; i++) {
      double bx = -40.0 + (i * 70);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx - 30, 250, 60, 40),
          const Radius.circular(5),
        ),
        Paint()..color = Colors.white.withOpacity(0.05),
      );
      if (i < s4Sequence.length) {
        String cmd = s4Sequence[i];
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx - 30, 250, 60, 40),
            const Radius.circular(5),
          ),
          Paint()
            ..color =
                cmd == 'F' ? const Color(0xFF3B82F6) : const Color(0xFFEAB308),
        );
        _drawText(
          canvas,
          cmd == 'F' ? "↑ FWD" : "↱ 90°",
          Offset(bx, 270),
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 295, 80, 40),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF22C55E),
    );
    _drawText(
      canvas,
      "RUN",
      const Offset(100, 315),
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  void _paintS5(Canvas canvas) {
    if (s5Corners['tl']! &&
        s5Corners['tr']! &&
        s5Corners['bl']! &&
        s5Corners['br']!) {
      canvas.drawRect(
        const Rect.fromLTWH(-130, -90, 260, 180),
        Paint()..color = const Color(0xFF38BDF8),
      );
      canvas.drawCircle(
        const Offset(-50, -30),
        30,
        Paint()..color = const Color(0xFFFDE047),
      );
      final mountP =
          Path()
            ..moveTo(-130, 90)
            ..lineTo(-40, 0)
            ..lineTo(30, 70)
            ..lineTo(80, 20)
            ..lineTo(130, 90)
            ..close();
      canvas.drawPath(mountP, Paint()..color = const Color(0xFF10B981));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-80, -20, 160, 40),
          const Radius.circular(20),
        ),
        Paint()..color = Colors.black54,
      );
      _drawText(
        canvas,
        "FRAME COMPLETE!",
        const Offset(0, 0),
        fontSize: 16,
        color: const Color(0xFF4ADE80),
        fontWeight: FontWeight.bold,
      );
    }

    // Guides
    canvas.drawRect(
      const Rect.fromLTWH(-150, -110, 300, 220),
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var p in s5Pieces) {
      canvas.save();
      canvas.translate(p['cx'], p['cy']);
      canvas.rotate(p['rot'] * pi / 180);

      final rect = Rect.fromLTWH(-p['w'] / 2, -p['h'] / 2, p['w'], p['h']);
      canvas.drawRect(rect, Paint()..color = const Color(0xFFB45309));
      canvas.drawRect(
        rect,
        Paint()
          ..color =
              p['error'] ? const Color(0xFFEF4444) : const Color(0xFF78350F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      canvas.drawLine(
        Offset(-p['w'] / 2 + 10, 0),
        Offset(p['w'] / 2 - 10, 0),
        Paint()
          ..color = const Color(0xFF92400E)
          ..strokeWidth = 2,
      );
      canvas.restore();
    }

    final cornerPaint =
        Paint()
          ..color = const Color(0xFF22C55E)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    final cornerFill =
        Paint()
          ..color = const Color(0xFF22C55E).withOpacity(0.3)
          ..style = PaintingStyle.fill;

    void drawCorner(
      double tx,
      double ty,
      double l1x,
      double l1y,
      double l2x,
      double l2y,
    ) {
      canvas.save();
      canvas.translate(tx, ty);
      final p =
          Path()
            ..moveTo(l1x, l1y)
            ..lineTo(0, 0)
            ..lineTo(l2x, l2y);
      canvas.drawPath(p, cornerFill);
      canvas.drawPath(p, cornerPaint);
      canvas.restore();
    }

    if (s5Corners['tl']!) drawCorner(-130, -90, 0, 15, 15, 0);
    if (s5Corners['tr']!) drawCorner(130, -90, 0, 15, -15, 0);
    if (s5Corners['bl']!) drawCorner(-130, 90, 0, -15, 15, 0);
    if (s5Corners['br']!) drawCorner(130, 90, 0, -15, -15, 0);
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
  ) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawArc(
      rect,
      startAngleDeg * pi / 180,
      (endAngleDeg - startAngleDeg) * pi / 180,
      true,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawArc(
      rect,
      startAngleDeg * pi / 180,
      (endAngleDeg - startAngleDeg) * pi / 180,
      true,
      Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    double midAngleDeg = startAngleDeg + (endAngleDeg - startAngleDeg) / 2;
    double textR = radius * 0.6;
    double tx = cx + textR * cos(midAngleDeg * pi / 180);
    double ty = cy + textR * sin(midAngleDeg * pi / 180);
    _drawText(
      canvas,
      text,
      Offset(tx, ty),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  bool shouldRepaint(covariant MasterPainter oldDelegate) => true;
}
