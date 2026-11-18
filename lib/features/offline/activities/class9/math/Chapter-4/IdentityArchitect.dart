// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Identity Architect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const IdentityArchitect(),
    ),
  );
}

// ---------------------------------------------------------
// 1. DATA MODELS & LOCALIZATION
// ---------------------------------------------------------

class GameBlock {
  double x, y;
  final double w, h;
  final Color color;
  final String label;
  bool isInspected;
  bool isError;
  bool isSuccess;

  GameBlock({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.color,
    required this.label,
    this.isInspected = false,
    this.isError = false,
    this.isSuccess = false,
  });
}

const Map<String, Map<String, String>> i18n = {
  'en': {
    'lab_title': 'Identity Architect: (a+b)²',
    'lab_subtitle': 'Class 9 • Exploring Algebraic Identities',
    'btn_enter': 'Enter Lab',
    'btn_reset': 'Reset',
    'lbl_objective': 'Mission Objective',
    'lbl_steps': 'Procedural Steps',
    'lbl_conclusion': 'Conclusion',
    'btn_validate': 'Validate Model',
    'btn_next': 'Next Scenario',
    'btn_restart': 'Restart Activity',
    'hud_indep': 'Independent Variables',
    'hud_dep': 'Dependent Area',
    'scen_1_title': 'Scenario 1: Understanding Areas',
    'scen_2_title': 'Scenario 2: Building the Square',
    'scen_1_obj':
        'Identify the areas of the given individual geometric shapes representing parts of the identity.',
    'scen_1_step1':
        'Observe the blue square. It has side length a. Tap it to view its area.',
    'scen_1_step2':
        'Observe the green square. It has side length b. Tap it to view its area.',
    'scen_1_step3':
        'Observe the two purple rectangles. They have sides a and b.',
    'scen_1_conc': 'The areas are a², b², and two of ab.',
    'scen_2_obj':
        'Construct a large square of side (a+b) by dragging the individual shapes together.',
    'scen_2_step1': 'Drag the blue square (a²) to the top-left of the grid.',
    'scen_2_step2': 'Drag the two purple rectangles (ab) adjacent to it.',
    'scen_2_step3':
        'Drag the green square (b²) into the remaining corner to complete the large square.',
    'scen_2_conc':
        'The total area (a+b)² is exactly equal to the sum of individual areas: a² + 2ab + b².',
    'msg_success': 'Great job! Model validated correctly.',
    'msg_error': 'Not quite right. Please check the steps and try again.',
  },
  'hi': {
    'lab_title': 'पहचान वास्तुकार: (a+b)²',
    'lab_subtitle': 'कक्षा 9 • बीजीय सर्वसमिकाओं की खोज',
    'btn_enter': 'प्रयोगशाला में प्रवेश करें',
    'btn_reset': 'रीसेट',
    'lbl_objective': 'मिशन का उद्देश्य',
    'lbl_steps': 'प्रक्रियात्मक चरण',
    'lbl_conclusion': 'निष्कर्ष',
    'btn_validate': 'मॉडल मान्य करें',
    'btn_next': 'अगला परिदृश्य',
    'btn_restart': 'गतिविधि पुनः आरंभ करें',
    'hud_indep': 'स्वतंत्र चर',
    'hud_dep': 'आश्रित क्षेत्रफल',
    'scen_1_title': 'परिदृश्य 1: क्षेत्रों को समझना',
    'scen_2_title': 'परिदृश्य 2: वर्ग बनाना',
    'scen_1_obj':
        'सर्वसमिका के भागों का प्रतिनिधित्व करने वाले दिए गए व्यक्तिगत ज्यामितीय आकृतियों के क्षेत्रफलों की पहचान करें।',
    'scen_1_step1':
        'नीले वर्ग का निरीक्षण करें। इसकी भुजा की लंबाई a है। इसका क्षेत्रफल देखने के लिए इसे टैप करें।',
    'scen_1_step2':
        'हरे वर्ग का निरीक्षण करें। इसकी भुजा की लंबाई b है। इसका क्षेत्रफल देखने के लिए इसे टैप करें।',
    'scen_1_step3': 'दो बैंगनी आयतों का निरीक्षण करें। उनकी भुजाएँ a और b हैं।',
    'scen_1_conc': 'क्षेत्रफल a², b², और दो ab हैं।',
    'scen_2_obj':
        'व्यक्तिगत आकृतियों को एक साथ खींचकर भुजा (a+b) का एक बड़ा वर्ग बनाएँ।',
    'scen_2_step1': 'नीले वर्ग (a²) को ग्रिड के ऊपर-बाएँ ओर खींचें।',
    'scen_2_step2': 'दो बैंगनी आयतों (ab) को इसके समीप खींचें।',
    'scen_2_step3':
        'बड़े वर्ग को पूरा करने के लिए हरे वर्ग (b²) को शेष कोने में खींचें।',
    'scen_2_conc':
        'कुल क्षेत्रफल (a+b)² ठीक व्यक्तिगत क्षेत्रफलों के योग के बराबर है: a² + 2ab + b²।',
    'msg_success': 'बहुत बढ़िया! मॉडल सही ढंग से मान्य किया गया।',
    'msg_error':
        'बिल्कुल सही नहीं। कृपया चरणों की जाँच करें और पुनः प्रयास करें।',
  },
};

// ---------------------------------------------------------
// 2. MAIN STATEFUL WIDGET
// ---------------------------------------------------------

class IdentityArchitect extends StatefulWidget {
  const IdentityArchitect({super.key});

  @override
  State<IdentityArchitect> createState() => _IdentityArchitectState();
}

class _IdentityArchitectState extends State<IdentityArchitect>
    with SingleTickerProviderStateMixin {
  // Game Loop
  late AnimationController _gameLoopController;

  // Layout & Resizer State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 300.0;
  bool _isSidebarWidthInitialized = true;
  final double _minSidebarWidth = 300.0;
  bool _isResizing =
      false; // Add state to prevent animation glitch during resizing

  // Canvas Interactions
  final GlobalKey _canvasKey = GlobalKey();
  Offset _cameraPan = Offset.zero;
  double _cameraZoom = 40.0; // 40 pixels per mathematical unit
  Offset? _lastFocalPoint;
  double? _lastZoom;
  GameBlock? _draggingBlock;
  Offset _dragOffset = Offset.zero;
  bool _canDragBlocks = false;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Activity State
  String _lang = 'en';
  int _currentScenario = 0; // 0 = Areas, 1 = Square
  final double a = 3.0;
  final double b = 2.0;

  List<GameBlock> _blocks = [];
  String? _activeChipId;
  String? _activeChipVal;
  final Map<String, bool> _solvedChips = {};

  bool _showConclusion = false;
  String _toastMessage = '';
  bool _toastSuccess = true;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();

    // Enforce Landscape & ImmersiveSticky to prevent layout jumps
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start Game Loop (RequestAnimationFrame alternative)
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loadScenario(0);
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();

    // Revert Orientation & UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  // --- AUDIO METHODS ---
  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class9/tap.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class9/page_open.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class9/dropdown.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class9/error_tone.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class9/shutter.mp3',
      ),
    );
  }
  // ---------------------

  void _showToastMsg(bool isSuccess, String msg) {
    setState(() {
      _toastSuccess = isSuccess;
      _toastMessage = msg;
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _restartActivity() {
    _loadScenario(0);
    setState(() {
      _showCurtain = true;
      _sidebarOpen = true;
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _showConclusion = false;
      _solvedChips.clear();
      _activeChipId = null;
      _activeChipVal = null;
      _canDragBlocks = (index != 0); // Allow dragging only in Scenario 2

      _cameraPan = Offset.zero;
      _cameraZoom = 40.0;

      if (index == 0) {
        _blocks = [
          GameBlock(x: -5, y: -4, w: a, h: a, color: Colors.blue, label: 'a²'),
          GameBlock(x: 4, y: 3, w: b, h: b, color: Colors.green, label: 'b²'),
          GameBlock(x: 4, y: -4, w: a, h: b, color: Colors.purple, label: 'ab'),
          GameBlock(x: -5, y: 3, w: b, h: a, color: Colors.purple, label: 'ab'),
        ];
      } else {
        _blocks = [
          GameBlock(
            x: -3,
            y: -3,
            w: a,
            h: a,
            color: Colors.blue,
            label: 'a²',
            isInspected: true,
          ),
          GameBlock(
            x: 3,
            y: 3,
            w: b,
            h: b,
            color: Colors.green,
            label: 'b²',
            isInspected: true,
          ),
          GameBlock(
            x: 3,
            y: -2,
            w: a,
            h: b,
            color: Colors.purple,
            label: 'ab',
            isInspected: true,
          ),
          GameBlock(
            x: -2,
            y: 3,
            w: b,
            h: a,
            color: Colors.purple,
            label: 'ab',
            isInspected: true,
          ),
        ];
      }
    });
  }

  void _validate({bool showToastOnFail = true}) {
    bool isSuccess = false;

    if (_currentScenario == 0) {
      isSuccess = _blocks.every((b) => b.isInspected);
    } else {
      double minX = double.infinity, minY = double.infinity;
      double maxX = -double.infinity, maxY = -double.infinity;
      for (var b in _blocks) {
        minX = min(minX, b.x);
        minY = min(minY, b.y);
        maxX = max(maxX, b.x + b.w);
        maxY = max(maxY, b.y + b.h);
      }
      double bw = (maxX - minX).abs();
      double bh = (maxY - minY).abs();

      if ((bw - (a + b)).abs() < 0.1 && (bh - (a + b)).abs() < 0.1) {
        isSuccess = true;
      }
    }

    if (isSuccess) {
      playPageOpen();
      _showToastMsg(true, i18n[_lang]!['msg_success']!);
      setState(() {
        _showConclusion = true;
        for (var b in _blocks) {
          b.isSuccess = true;
        }
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            for (var b in _blocks) {
              b.isSuccess = false;
            }
          });
        }
      });
    } else {
      if (showToastOnFail) {
        playError();
        _showToastMsg(false, i18n[_lang]!['msg_error']!);
      }
    }
  }

  Offset _screenToWorld(Offset screenPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(screenPos);

    final center = Offset(box.size.width / 2, box.size.height / 2);
    final offsetFromCenter = localPos - center;
    final worldPos = (offsetFromCenter / _cameraZoom) + _cameraPan;
    return worldPos;
  }

  void _checkHitTest(Offset globalPos) {
    final worldPos = _screenToWorld(globalPos);

    for (int i = _blocks.length - 1; i >= 0; i--) {
      final b = _blocks[i];
      if (worldPos.dx >= b.x &&
          worldPos.dx <= b.x + b.w &&
          worldPos.dy >= b.y &&
          worldPos.dy <= b.y + b.h) {
        if (_currentScenario == 0) {
          // Logic for Scenario 1 (Matching Areas)
          if (_activeChipVal != null && !b.isInspected) {
            if (b.label == _activeChipVal) {
              playPageOpen();
              setState(() {
                b.isInspected = true;
                b.isSuccess = true;
                _solvedChips[_activeChipId!] = true;
                _activeChipId = null;
                _activeChipVal = null;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => b.isSuccess = false);
              });

              if (_blocks.every((bk) => bk.isInspected)) {
                Future.delayed(const Duration(milliseconds: 800), _validate);
              }
            } else {
              playError();
              setState(() => b.isError = true);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => b.isError = false);
              });
            }
          }
        } else if (_canDragBlocks) {
          // Logic for Scenario 2 (Dragging)
          _draggingBlock = b;
          _dragOffset = Offset(worldPos.dx - b.x, worldPos.dy - b.y);
          // Move block to end of list to render on top
          setState(() {
            _blocks.removeAt(i);
            _blocks.add(b);
          });
        }
        return; // Stop checking after first hit
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (_showCurtain) return;

    // Tap is heavily preferred for Scenario 1 matches
    if (_currentScenario == 0) {
      _checkHitTest(details.globalPosition);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_showCurtain) return;

    _lastFocalPoint = details.localFocalPoint;
    _lastZoom = _cameraZoom;

    // Scale Start triggers dragging for Scenario 2
    if (details.pointerCount == 1 && _currentScenario != 0) {
      _checkHitTest(details.focalPoint);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_showCurtain) return;

    // Isolate block dragging logic - immediately return to prevent accidental camera pans
    if (_draggingBlock != null) {
      if (details.pointerCount == 1) {
        final worldPos = _screenToWorld(details.focalPoint);
        setState(() {
          _draggingBlock!.x = worldPos.dx - _dragOffset.dx;
          _draggingBlock!.y = worldPos.dy - _dragOffset.dy;
        });
      }
      return;
    }

    // Camera Panning & Zooming
    if (_lastFocalPoint != null) {
      final delta = details.localFocalPoint - _lastFocalPoint!;

      setState(() {
        _cameraPan -= delta / _cameraZoom;

        if (details.scale != 1.0 && _lastZoom != null) {
          _cameraZoom = (_lastZoom! * details.scale).clamp(10.0, 150.0);
        }
      });
      _lastFocalPoint = details.localFocalPoint;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
    _lastZoom = null;

    if (_draggingBlock != null) {
      playDropdown(); // Use this as the snap sound
      setState(() {
        // Snap to nearest 0.5 logical grid coordinate
        _draggingBlock!.x = (_draggingBlock!.x * 2).round() / 2.0;
        _draggingBlock!.y = (_draggingBlock!.y * 2).round() / 2.0;
        _draggingBlock = null;
      });
      if (_currentScenario == 1) _validate(showToastOnFail: false);
    }
  }

  String _t(String key) => i18n[_lang]![key] ?? key;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (!_isSidebarWidthInitialized) {
      _sidebarWidth = screenWidth * 0.30;
      if (_sidebarWidth < _minSidebarWidth) {
        _sidebarWidth = _minSidebarWidth;
      }
      _isSidebarWidthInitialized = true;
    }

    // CRUCIAL FIX: Disable animation durations whenever any interaction is occurring (resizing).
    // This stops the implicit animation engine from lagging behind the cursor when resizing the sidebar.
    final animDuration = _isResizing
        ? Duration.zero
        : const Duration(milliseconds: 300);

    // Removed the root GestureDetector entirely. Since we use `immersiveSticky`, the OS handles hiding the system UI automatically.
    // Spamming `setEnabledSystemUIMode` on every touch was causing massive system-level window redraws.
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents layout glitches if OS keyboard/tray pops up
      body: Stack(
        children: [
          // ==========================================
          // CANVAS AREA
          // ==========================================
          AnimatedPositioned(
            key: const ValueKey('canvas_area'),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: 0,
            left: _sidebarOpen ? _sidebarWidth : 0,
            child: GestureDetector(
              key: _canvasKey,
              onTapDown: _handleTapDown,
              onTap:
                  () {}, // Ensures onTapDown registers cleanly in gesture arena
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: Container(
                color: const Color(0xFF0F172A), // Dark Canvas
                child: AnimatedBuilder(
                  animation: _gameLoopController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: WorldCanvasPainter(
                        blocks: _blocks,
                        cameraPan: _cameraPan,
                        zoom: _cameraZoom,
                        scenario: _currentScenario,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Canvas HUD Toolbar (Bottom Area)
          AnimatedPositioned(
            key: const ValueKey('canvas_hud'),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            bottom: 24,
            left: _sidebarOpen ? _sidebarWidth + 24 : 24,
            right: 24,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _t('hud_indep'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'a = 3',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'b = 2',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: 1,
                        height: 32,
                        color: Colors.white24,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _t('hud_dep'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _showConclusion ? '(a+b)² = 25' : '(a+b)² = ?',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Match UI (Scenario 1)
          if (_currentScenario == 0 && !_showCurtain)
            AnimatedPositioned(
              key: const ValueKey('match_ui'),
              duration: animDuration,
              curve: Curves.easeOutCubic,
              top: 24,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Identify the Components",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        "Select a value, then tap the correct shape.",
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildChip('c1', 'a²'),
                          _buildChip('c2', 'b²'),
                          _buildChip('c3', 'ab'),
                          _buildChip('c4', 'ab'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Toast Message
          if (_showToast)
            AnimatedPositioned(
              key: const ValueKey('toast_msg'),
              duration: animDuration,
              curve: Curves.easeOutCubic,
              top: 100,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _toastSuccess
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _toastSuccess ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _toastMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ==========================================
          // FULLY SCROLLABLE SIDEBAR
          // ==========================================
          AnimatedPositioned(
            key: const ValueKey('sidebar'),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: _sidebarOpen ? 0 : -_sidebarWidth,
            width: _sidebarWidth,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Dark Sidebar
                border: Border(
                  right: BorderSide(color: Colors.amber, width: 2),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        72,
                        24,
                        24,
                      ), // 72 to account for the top-left menu button
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity Title & Icon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.architecture,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _t('lab_title'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _t('lab_subtitle'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white54,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Language Toggle & Reset Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    _buildLangBtn('EN', 'en'),
                                    _buildLangBtn('HI', 'hi'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.redAccent,
                                ),
                                tooltip: _t('btn_reset'),
                                onPressed: () {
                                  playClick();
                                  _restartActivity();
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 32),

                          // Scenario Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                dropdownColor: const Color(0xFF0F172A),
                                value: _currentScenario,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.amber,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text(
                                      _t('scen_1_title'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text(
                                      _t('scen_2_title'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    playDropdown();
                                    _loadScenario(val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Objective
                          Row(
                            children: [
                              const Icon(
                                Icons.track_changes,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _t('lbl_objective').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _t(
                              _currentScenario == 0
                                  ? 'scen_1_obj'
                                  : 'scen_2_obj',
                            ),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),

                          // Steps
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.format_list_numbered,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _t('lbl_steps').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildStepText(
                                  "1. ",
                                  _t(
                                    _currentScenario == 0
                                        ? 'scen_1_step1'
                                        : 'scen_2_step1',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildStepText(
                                  "2. ",
                                  _t(
                                    _currentScenario == 0
                                        ? 'scen_1_step2'
                                        : 'scen_2_step2',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildStepText(
                                  "3. ",
                                  _t(
                                    _currentScenario == 0
                                        ? 'scen_1_step3'
                                        : 'scen_2_step3',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Conclusion
                          if (_showConclusion)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb,
                                        color: Colors.greenAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _t('lbl_conclusion').toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _t(
                                      _currentScenario == 0
                                          ? 'scen_1_conc'
                                          : 'scen_2_conc',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Validate Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: Colors.amber.withValues(alpha: 0.5),
                            ),
                            onPressed: () {
                              playClick();
                              if (_showConclusion) {
                                if (_currentScenario == 0) {
                                  _loadScenario(1);
                                } else {
                                  _restartActivity();
                                }
                              } else {
                                _validate();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showConclusion
                                      ? (_currentScenario == 0
                                            ? Icons.arrow_forward
                                            : Icons.refresh)
                                      : Icons.check_circle,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showConclusion
                                      ? (_currentScenario == 0
                                            ? _t('btn_next')
                                            : _t('btn_restart'))
                                      : _t('btn_validate'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white10)),
                    ),
                    child: const Text(
                      '© ZeroScienceLab - Fall in love with math and Science',
                      style: TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sidebar Resizer Handle
          AnimatedPositioned(
            key: const ValueKey('sidebar_resizer'),
            duration: animDuration,
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: _sidebarOpen
                ? _sidebarWidth - 10
                : -20, // slightly overlapping
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) => setState(() => _isResizing = true),
              onPanUpdate: (details) {
                if (!_sidebarOpen) return;
                setState(() {
                  _sidebarWidth += details.delta.dx;
                  if (_sidebarWidth < _minSidebarWidth) {
                    _sidebarWidth = _minSidebarWidth;
                  }
                  if (_sidebarWidth > screenWidth * 0.7) {
                    _sidebarWidth = screenWidth * 0.7; // Max 70% width
                  }
                });
              },
              onPanEnd: (_) => setState(() => _isResizing = false),
              onPanCancel: () => setState(() => _isResizing = false),
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // CURTAIN SCREEN
          // ==========================================
          if (_showCurtain)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.architecture,
                            color: Colors.amber,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _t('lab_title'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _t('lab_subtitle'),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 64),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: () {
                            curtainScreen();
                            setState(() {
                              _showCurtain = false;
                              _sidebarOpen =
                                  true; // Always open sidebar when entering
                            });
                          },
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(
                            _t('btn_enter'),
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
              ),
            ),

          // ==========================================
          // FIXED MENU BUTTON (Top Left - Highest Z-Index)
          // ==========================================
          if (!_showCurtain)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                onPressed: () {
                  playClick();
                  setState(() {
                    _sidebarOpen = !_sidebarOpen;
                  });
                },
                child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepText(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          num,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLangBtn(String label, String code) {
    bool isActive = _lang == code;
    return GestureDetector(
      onTap: () {
        playClick();
        setState(() => _lang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String id, String val) {
    bool isSolved = _solvedChips[id] == true;
    bool isActive = _activeChipId == id;

    return GestureDetector(
      onTap: () {
        if (isSolved) return;
        playClick();
        setState(() {
          _activeChipId = id;
          _activeChipVal = val;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSolved
              ? Colors.transparent
              : (isActive
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.black45),
          border: Border.all(
            color: isSolved
                ? Colors.green
                : (isActive ? Colors.amber : Colors.white24),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          val,
          style: TextStyle(
            color: isSolved
                ? Colors.green
                : (isActive ? Colors.amber : Colors.white),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: isSolved ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. CANVAS PAINTER (Native 2D Rendering)
// ---------------------------------------------------------

class WorldCanvasPainter extends CustomPainter {
  final List<GameBlock> blocks;
  final Offset cameraPan;
  final double zoom;
  final int scenario;

  WorldCanvasPainter({
    required this.blocks,
    required this.cameraPan,
    required this.zoom,
    required this.scenario,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Transform Canvas for Camera
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(zoom);
    canvas.translate(-cameraPan.dx, -cameraPan.dy);

    // 1. Draw Grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 / zoom; // Keeps lines 1 pixel thin regardless of zoom

    final mainAxisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 / zoom;

    const int gridSize = 20;
    for (int i = -gridSize; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(i.toDouble(), -gridSize.toDouble()),
        Offset(i.toDouble(), gridSize.toDouble()),
        i == 0 ? mainAxisPaint : gridPaint,
      );
      canvas.drawLine(
        Offset(-gridSize.toDouble(), i.toDouble()),
        Offset(gridSize.toDouble(), i.toDouble()),
        i == 0 ? mainAxisPaint : gridPaint,
      );
    }

    // 2. Draw Blocks
    for (var b in blocks) {
      final rect = Rect.fromLTWH(b.x, b.y, b.w, b.h);

      // Shadow
      final shadowPaint = Paint()
        ..color = Colors.black45
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 / zoom);
      canvas.drawRect(rect.translate(2 / zoom, 4 / zoom), shadowPaint);

      // Block Fill
      Color fillColor = b.color;
      if (b.isSuccess) {
        fillColor = Colors.greenAccent;
      } else if (b.isError) {
        fillColor = Colors.redAccent;
      } else if (scenario == 0 && !b.isInspected) {
        // Slightly dim if not inspected in S1
        fillColor = fillColor.withValues(alpha: 0.5);
      }

      final fillPaint = Paint()..color = fillColor;
      canvas.drawRect(rect, fillPaint);

      // Block Border
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 / zoom;
      canvas.drawRect(rect, borderPaint);

      // 3. Draw Labels (Only if inspected in S1 or always in S2)
      if (scenario != 0 || b.isInspected) {
        final textSpan = TextSpan(
          text: b.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 / zoom, // Scale font with zoom
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 4 / zoom,
                offset: Offset(1 / zoom, 1 / zoom),
              ),
            ],
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(
          b.x + b.w / 2 - textPainter.width / 2,
          b.y + b.h / 2 - textPainter.height / 2,
        );

        // Reverse scale fix for super sharp text could be applied, but direct scaling works cleanly here.
        textPainter.paint(canvas, textOffset);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WorldCanvasPainter oldDelegate) {
    // The AnimationController ensures we repaint every frame anyway,
    // but typically we'd compare state.
    return true;
  }
}
