// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl8MCh10A1DirectProportionLab(),
    ),
  );
}

class AppColors {
  static const Color bgBase = Color(0xFF061024);
  static const Color bgPrimary = Color(0xFF0F172A);
  static const Color bgSecondary = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFF97316); // Orange
  static const Color accentHover = Color(0xFFEA580C);
  static const Color borderColor = Color(0x4DF97316); // Orange with opacity
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFACC15);
  static const Color xCol = Color(0xFFFB923C);
  static const Color yCol = Color(0xFF38BDF8);
}

class PhaseConfig {
  final int scn;
  final String kind;
  final int base;
  final int k;
  final int fMin;
  final int fMax;
  final int targetY;
  final String xLab;
  final String yLab;
  final List<int> xs;
  final int xMax;
  final int yMax;
  final int x1;
  final int y1;
  final int x2;

  PhaseConfig({
    required this.scn,
    required this.kind,
    this.base = 0,
    this.k = 0,
    this.fMin = 1,
    this.fMax = 8,
    this.targetY = 0,
    this.xLab = '',
    this.yLab = '',
    this.xs = const [],
    this.xMax = 0,
    this.yMax = 0,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
  });
}

class WorkData {
  int factor = 1;
  Set<int> seenFactors = {1};
  List<int> ys = [0, 0, 0, 0];
  int val = 0;
}

class Cl8MCh10A1DirectProportionLab extends StatefulWidget {
  const Cl8MCh10A1DirectProportionLab({super.key});

  @override
  State<Cl8MCh10A1DirectProportionLab> createState() =>
      _Cl8MCh10A1DirectProportionLabState();
}

class _Cl8MCh10A1DirectProportionLabState
    extends State<Cl8MCh10A1DirectProportionLab>
    with TickerProviderStateMixin {
  late AnimationController _gameLoop;

  late AudioPlayer _clickPlayer;
  late AudioPlayer _pagePlayer;
  late AudioPlayer _dropdownPlayer;

  bool _showShutter = true;
  bool _isSidebarOpen = true;
  bool _isDraggingSidebar = false;
  double _sidebarWidth = 300.0;
  String _curLang = 'en';

  int _activeScenario = 0;
  List<WorkData> _work = [];
  List<bool> _submitted = [];
  List<bool> _correct = [];

  // Canvas Pan & Zoom State
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoomScale = 1.0;

  final GlobalKey _canvasKey = GlobalKey();
  int _draggingPointIndex = -1;

  final List<PhaseConfig> _phases = [
    PhaseConfig(
      scn: 0,
      kind: 'scale',
      base: 2,
      k: 3,
      fMin: 1,
      fMax: 8,
      targetY: 24,
      xLab: 'Cups of flour',
      yLab: 'Rotis',
    ),
    PhaseConfig(
      scn: 1,
      kind: 'plot',
      k: 2,
      xs: [1, 2, 3, 4],
      xMax: 5,
      yMax: 10,
      xLab: 'Children',
      yLab: 'Cookies',
    ),
    PhaseConfig(
      scn: 2,
      kind: 'solve',
      k: 7,
      x1: 5,
      y1: 35,
      x2: 8,
      targetY: 56,
      xLab: 'Pens',
      yLab: 'Cost (₹)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _clickPlayer = AudioPlayer();
    _pagePlayer = AudioPlayer();
    _dropdownPlayer = AudioPlayer();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _resetData();

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _gameLoop.repeat();
    _gameLoop.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _gameLoop.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _resetData() {
    _work = [WorkData(), WorkData(), WorkData()];
    _submitted = [false, false, false];
    _correct = [false, false, false];
    _activeScenario = 0;
    _panOffset = Offset.zero;
    _zoomScale = 1.0;
    _showShutter = true;
  }

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class8/mixkit_2073.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class8/gotitem.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class8/mixkit_1491.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class8/mixkit_946.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class8/mixkit_2574.mp3',
      ),
    );
  }

  final Map<String, Map<String, String>> _text = {
    "en": {
      "app_title": "Direct Proportion Lab",
      "app_subtitle": "Class 8 • Proportional Reasoning-2",
      "start_mission": "Start Mission",
      "nav_prev": "Prev",
      "nav_next": "Next",
      "nav_submit": "Submit",
      "nav_report": "Report",
      "sidebar_title": "Teacher Board",
      "ui_scenario": "Scenario",
      "ui_objective": "Mission Objective",
      "ui_sequence": "Instruction Sequence",
      "ui_learnt": "Learnt Conclusion",
      "ui_hints": "Hints / Evidence",
      "scen_1": "S1 · Scale the recipe",
      "scen_2": "S2 · Plot the straight line",
      "scen_3": "S3 · Find the missing cost",
      "mission_desc":
          "Explore direct proportion: scale a quantity keeping y ÷ x = k constant, plot the points to see the straight line through the origin, and solve a missing value with the constant of proportionality.",
      "learnt_desc":
          "If y ÷ x = k for a pair of quantities, they are in direct proportion and their graph is a straight line through the origin.",
      "hint_0":
          "Base recipe: 2 cups → 6 rotis, so k = 3. Each extra factor adds 2 cups and 6 rotis.",
      "hint_1":
          "At x = 1 the point should sit at y = 2. Double x means double y: x=2 → y=4. All points must satisfy y ÷ x = 2.",
      "hint_2":
          "5 pens cost ₹35, so 1 pen = 35 ÷ 5 = ₹7. For 8 pens multiply: 8 × 7.",
    },
    "hi": {
      "app_title": "प्रत्यक्ष अनुपात प्रयोगशाला",
      "app_subtitle": "कक्षा 8 • आनुपातिक तर्क-2",
      "start_mission": "मिशन शुरू करें",
      "nav_prev": "पिछला",
      "nav_next": "अगला",
      "nav_submit": "सबमिट",
      "nav_report": "रिपोर्ट",
      "sidebar_title": "शिक्षक बोर्ड",
      "ui_scenario": "परिदृश्य",
      "ui_objective": "मिशन का उद्देश्य",
      "ui_sequence": "निर्देश क्रम",
      "ui_learnt": "सीखा गया निष्कर्ष",
      "ui_hints": "संकेत / साक्ष्य",
      "scen_1": "S1 · नुस्खा स्केल करें",
      "scen_2": "S2 · सीधी रेखा प्लॉट करें",
      "scen_3": "S3 · अज्ञात लागत ज्ञात करें",
      "mission_desc":
          "प्रत्यक्ष अनुपात का अन्वेषण करें: y ÷ x = k को स्थिर रखते हुए एक मात्रा को स्केल करें, मूल बिंदु से गुजरने वाली सीधी रेखा देखने के लिए बिंदुओं को प्लॉट करें...",
      "learnt_desc":
          "यदि दो मात्राओं के लिए y ÷ x = k है, तो वे प्रत्यक्ष अनुपात में हैं और उनका ग्राफ़ मूल बिंदु से गुजरने वाली एक सीधी रेखा है।",
      "hint_0": "आधार नुस्खा: 2 कप → 6 रोटियां, इसलिए k = 3.",
      "hint_1": "x = 1 पर बिंदु y = 2 पर बैठना चाहिए।",
      "hint_2": "5 पेन की कीमत ₹35 है, इसलिए 1 पेन = 35 ÷ 5 = ₹7.",
    },
  };

  String t(String key) {
    return _text[_curLang]?[key] ?? _text['en']![key] ?? key;
  }

  bool _isPhaseCorrectNow() {
    PhaseConfig p = _phases[_activeScenario];
    WorkData w = _work[_activeScenario];
    if (p.kind == 'scale') {
      int x = p.base * w.factor;
      int y = p.k * x;
      return y == p.targetY && (y / x == p.k);
    }
    if (p.kind == 'plot') {
      for (int i = 0; i < p.xs.length; i++) {
        if (w.ys[i] != p.k * p.xs[i]) return false;
      }
      return true;
    }
    if (p.kind == 'solve') {
      return w.val == p.targetY && (w.val / p.x2 == p.k);
    }
    return false;
  }

  void _submitStep() {
    bool ok = _isPhaseCorrectNow();
    if (ok) {
      playPageOpen();
    } else {
      playError();
    }
    setState(() {
      _submitted[_activeScenario] = true;
      _correct[_activeScenario] = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    _sidebarWidth = _sidebarWidth.clamp(250.0, screenW * 0.6);
    double actualSidebarW = _sidebarWidth;
    double mainAreaLeftOffset = _isSidebarOpen ? actualSidebarW : 0;
    int animDuration = _isDraggingSidebar ? 0 : 300;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Stack(
          children: [
            // Main Canvas Area
            AnimatedPositioned(
              duration: Duration(milliseconds: animDuration),
              curve: Curves.easeInOut,
              left: mainAreaLeftOffset,
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildMainArea(),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: Duration(milliseconds: animDuration),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -actualSidebarW,
              top: 0,
              bottom: 0,
              width: actualSidebarW,
              child: _buildSidebar(),
            ),

            // Sidebar Resize Handle
            if (_isSidebarOpen)
              AnimatedPositioned(
                duration: Duration(milliseconds: animDuration),
                curve: Curves.easeInOut,
                left: actualSidebarW - 4,
                top: 0,
                bottom: 0,
                width: 8,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (_) =>
                        setState(() => _isDraggingSidebar = true),
                    onHorizontalDragEnd: (_) =>
                        setState(() => _isDraggingSidebar = false),
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sidebarWidth += details.delta.dx;
                        _sidebarWidth = _sidebarWidth.clamp(
                          250.0,
                          screenW * 0.6,
                        );
                      });
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // Floating Menu Button
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.bgSecondary,
                foregroundColor: AppColors.accent,
                child: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  playClick();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
              ),
            ),

            // Curtain Screen
            if (_showShutter) _buildShutterScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Positioned.fill(
      child: Container(
        color: AppColors.bgBase,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.borderColor,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_graph,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t('app_title'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t('app_subtitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    curtainScreen();
                    setState(() => _showShutter = false);
                  },
                  child: Text(
                    t('start_mission'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          right: BorderSide(color: AppColors.borderColor, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 80,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Title with Icon
            Row(
              children: [
                const Icon(Icons.science, color: AppColors.accent, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('app_title'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              t('app_subtitle'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Language & Reset Controls
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgSecondary,
                    side: const BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(
                    Icons.language,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  label: Text(
                    _curLang.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    playClick();
                    setState(() {
                      _curLang = _curLang == 'en' ? 'hi' : 'en';
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                  tooltip: "Reset",
                  onPressed: () {
                    playClick();
                    setState(() => _resetData());
                  },
                ),
              ],
            ),
            const Divider(color: AppColors.borderColor, height: 32),

            _buildSidebarCard(
              t('ui_scenario'),
              DropdownButton<int>(
                value: _activeScenario,
                isExpanded: true,
                dropdownColor: AppColors.bgSecondary,
                underline: const SizedBox(),
                items: [0, 1, 2]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          t('scen_${e + 1}'),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    playDropdown();
                    setState(() {
                      _activeScenario = v;
                      _panOffset = Offset.zero;
                      _zoomScale = 1.0;
                    });
                  }
                },
              ),
            ),

            _buildSidebarCard(
              t('ui_objective'),
              Text(
                t('mission_desc'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            _buildSidebarCard(
              t('ui_hints'),
              Text(
                t('hint_$_activeScenario'),
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildHUD(),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                "© ZeroScienceLab - Fall in love with math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildMainArea() {
    PhaseConfig p = _phases[_activeScenario];

    return Column(
      children: [
        // Controls specific to scenario
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bgPrimary,
          child: _buildScenarioControls(p),
        ),

        // Interactive Canvas
        Expanded(
          child: GestureDetector(
            onScaleStart: (details) {
              _previousZoomScale = _zoomScale;

              if (p.kind == 'plot' && !_correct[_activeScenario]) {
                // Check if tapping near a point to drag it
                RenderBox? box =
                    _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  Offset localFocal = box.globalToLocal(details.focalPoint);
                  // Convert touch to world coords
                  double worldX =
                      ((localFocal.dx - _panOffset.dx) / _zoomScale -
                          GraphConfig.ox) /
                      GraphConfig.px;

                  // Find nearest x column
                  for (int i = 0; i < p.xs.length; i++) {
                    if ((worldX - p.xs[i]).abs() < 1.0) {
                      _draggingPointIndex = i;
                      playClick();
                      break;
                    }
                  }
                }
              }
            },
            onScaleUpdate: (details) {
              if (_draggingPointIndex != -1 &&
                  p.kind == 'plot' &&
                  !_correct[_activeScenario]) {
                // Dragging a point
                RenderBox? box =
                    _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  WorkData w = _work[_activeScenario];
                  Offset localFocal = box.globalToLocal(details.focalPoint);

                  // Map inverse Y
                  double worldY =
                      (GraphConfig.oy -
                          (localFocal.dy - _panOffset.dy) / _zoomScale) /
                      GraphConfig.py;
                  int snappedY = worldY.round().clamp(0, p.yMax);

                  if (w.ys[_draggingPointIndex] != snappedY) {
                    playDropdown();
                    setState(() {
                      w.ys[_draggingPointIndex] = snappedY;
                    });
                  }
                }
              } else {
                // Panning & Zooming
                RenderBox? box =
                    _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  Offset localFocal = box.globalToLocal(details.focalPoint);
                  setState(() {
                    double newZoomScale = (_previousZoomScale * details.scale)
                        .clamp(0.5, 4.0);

                    // Adjust pan to zoom around the focal point
                    _panOffset =
                        localFocal -
                        (localFocal - _panOffset) * (newZoomScale / _zoomScale);
                    _zoomScale = newZoomScale;

                    // Apply panning
                    _panOffset += details.focalPointDelta;
                  });
                }
              }
            },
            onScaleEnd: (details) {
              if (_draggingPointIndex != -1) playClick();
              _draggingPointIndex = -1;
            },
            child: ClipRect(
              child: CustomPaint(
                key: _canvasKey,
                painter: ActivityPainter(
                  phase: p,
                  work: _work[_activeScenario],
                  isCorrect: _correct[_activeScenario],
                  panOffset: _panOffset,
                  zoomScale: _zoomScale,
                ),
                child: Container(), // Fills available space
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioControls(PhaseConfig p) {
    WorkData w = _work[_activeScenario];
    if (p.kind == 'scale') {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Scaling factor: ${w.factor}",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: w.factor.toDouble(),
                  min: p.fMin.toDouble(),
                  max: p.fMax.toDouble(),
                  divisions: p.fMax - p.fMin,
                  activeColor: AppColors.accent,
                  onChanged: _correct[_activeScenario]
                      ? null
                      : (val) {
                          int newVal = val.toInt();
                          if (w.factor != newVal) {
                            playDropdown();
                            setState(() {
                              w.factor = newVal;
                              w.seenFactors.add(w.factor);
                            });
                          }
                        },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "y ÷ x = ${(p.k * p.base * w.factor) / (p.base * w.factor)}",
              style: const TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    } else if (p.kind == 'plot') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(p.xs.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                Text(
                  "x=${p.xs[i]}",
                  style: const TextStyle(
                    color: AppColors.xCol,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _correct[_activeScenario]
                          ? null
                          : () {
                              if (w.ys[i] > 0) {
                                playDropdown();
                                setState(() => w.ys[i]--);
                              }
                            },
                    ),
                    Text(
                      "${w.ys[i]}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _correct[_activeScenario]
                          ? null
                          : () {
                              if (w.ys[i] < p.yMax) {
                                playDropdown();
                                setState(() => w.ys[i]++);
                              }
                            },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unknown value y: ${w.val}",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: w.val.toDouble(),
                  min: 0,
                  max: 80,
                  divisions: 80,
                  activeColor: AppColors.accent,
                  onChanged: _correct[_activeScenario]
                      ? null
                      : (val) {
                          int newVal = val.toInt();
                          if (w.val != newVal) {
                            playDropdown();
                            setState(() => w.val = newVal);
                          }
                        },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Target: y=${p.targetY}",
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildHUD() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _hudBtn(
                  Icons.arrow_back,
                  t('nav_prev'),
                  _activeScenario > 0
                      ? () {
                          playClick();
                          setState(() => _activeScenario--);
                        }
                      : null,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _hudBtn(
                  Icons.arrow_forward,
                  t('nav_next'),
                  _correct[_activeScenario] && _activeScenario < 2
                      ? () {
                          playClick();
                          setState(() => _activeScenario++);
                        }
                      : null,
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _hudBtn(
            Icons.check_circle,
            t('nav_submit'),
            _correct[_activeScenario] ? null : _submitStep,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _hudBtn(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    required bool isPrimary,
  }) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.accent : AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(20),
            border: isPrimary ? null : Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphConfig {
  static const double ox = 100.0; // Origin X
  static const double oy = 400.0; // Origin Y
  static const double px = 50.0; // Pixels per X unit
  static const double py = 30.0; // Pixels per Y unit
}

class ActivityPainter extends CustomPainter {
  final PhaseConfig phase;
  final WorkData work;
  final bool isCorrect;
  final Offset panOffset;
  final double zoomScale;

  ActivityPainter({
    required this.phase,
    required this.work,
    required this.isCorrect,
    required this.panOffset,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Apply pan & zoom
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoomScale);

    // Draw background grid lines (world space) and coordinate labels
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (int i = 0; i <= 20; i++) {
      double x = GraphConfig.ox + i * GraphConfig.px;
      canvas.drawLine(Offset(x, -1500), Offset(x, 800), gridPaint);
      if (i > 0) {
        _drawText(canvas, "$i", Offset(x, GraphConfig.oy + 5), Colors.white70);
      }
    }
    for (int j = 0; j <= 50; j++) {
      double y = GraphConfig.oy - j * GraphConfig.py;
      canvas.drawLine(Offset(0, y), Offset(1500, y), gridPaint);
      if (j > 0) {
        _drawText(
          canvas,
          "$j",
          Offset(GraphConfig.ox - 20, y - 8),
          Colors.white70,
        );
      }
    }

    // Draw Axes
    final axisPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    canvas.drawLine(
      const Offset(GraphConfig.ox, -1500),
      const Offset(GraphConfig.ox, 800),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(0, GraphConfig.oy),
      const Offset(1500, GraphConfig.oy),
      axisPaint,
    );

    // Origin label
    _drawText(
      canvas,
      "0",
      const Offset(GraphConfig.ox - 15, GraphConfig.oy + 5),
      Colors.white70,
    );

    // Specific Rendering based on Scenario
    if (phase.kind == 'scale') {
      _drawScaleScenario(canvas);
    } else if (phase.kind == 'plot') {
      _drawPlotScenario(canvas);
    } else if (phase.kind == 'solve') {
      _drawSolveScenario(canvas);
    }

    canvas.restore();
  }

  void _drawScaleScenario(Canvas canvas) {
    int x = phase.base * work.factor;
    int y = phase.k * x;

    final paint = Paint()
      ..color = AppColors.yCol
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    double px = GraphConfig.ox + x * GraphConfig.px;
    double py = GraphConfig.oy - y * GraphConfig.py;

    // Draw bar or point representation
    canvas.drawLine(
      Offset(px, GraphConfig.oy),
      Offset(px, py),
      paint..color = AppColors.yCol.withValues(alpha: 0.5),
    );
    canvas.drawCircle(Offset(px, py), 12, paint..color = AppColors.yCol);

    _drawText(canvas, "($x, $y)", Offset(px, py - 25), AppColors.warning);
  }

  void _drawPlotScenario(Canvas canvas) {
    // Draw target line if correct
    if (isCorrect) {
      final linePaint = Paint()
        ..color = AppColors.success
        ..strokeWidth = 2;
      double endX = GraphConfig.ox + phase.xs.last * GraphConfig.px;
      double endY = GraphConfig.oy - (phase.k * phase.xs.last) * GraphConfig.py;
      canvas.drawLine(
        const Offset(GraphConfig.ox, GraphConfig.oy),
        Offset(endX, endY),
        linePaint,
      );
    }

    final pointPaint = Paint()..color = AppColors.yCol;
    final linePaint = Paint()
      ..color = AppColors.yCol.withValues(alpha: 0.4)
      ..strokeWidth = 2;

    for (int i = 0; i < phase.xs.length; i++) {
      double cx = GraphConfig.ox + phase.xs[i] * GraphConfig.px;
      double cy = GraphConfig.oy - work.ys[i] * GraphConfig.py;

      canvas.drawLine(Offset(cx, GraphConfig.oy), Offset(cx, cy), linePaint);
      canvas.drawCircle(Offset(cx, cy), 14, pointPaint);

      _drawText(
        canvas,
        "(${phase.xs[i]}, ${work.ys[i]})",
        Offset(cx, cy - 25),
        AppColors.textPrimary,
      );
    }
  }

  void _drawSolveScenario(Canvas canvas) {
    final linePaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 2;
    double endX = GraphConfig.ox + phase.x2 * GraphConfig.px;
    double endY = GraphConfig.oy - phase.targetY * GraphConfig.py;

    if (isCorrect) {
      canvas.drawLine(
        const Offset(GraphConfig.ox, GraphConfig.oy),
        Offset(endX, endY),
        linePaint,
      );
    }

    // Draw Known Point
    double kx = GraphConfig.ox + phase.x1 * GraphConfig.px;
    double ky = GraphConfig.oy - phase.y1 * GraphConfig.py;
    canvas.drawCircle(Offset(kx, ky), 8, Paint()..color = AppColors.yCol);
    _drawText(
      canvas,
      "(${phase.x1}, ${phase.y1})",
      Offset(kx, ky - 20),
      AppColors.yCol,
    );

    // Draw Unknown Point (Interactive)
    double ux = GraphConfig.ox + phase.x2 * GraphConfig.px;
    double uy = GraphConfig.oy - work.val * GraphConfig.py;

    canvas.drawLine(
      Offset(ux, GraphConfig.oy),
      Offset(ux, uy),
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.4)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(ux, uy), 12, Paint()..color = AppColors.accent);
    _drawText(
      canvas,
      "(${phase.x2}, ${work.val})",
      Offset(ux, uy - 25),
      AppColors.accent,
    );
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant ActivityPainter oldDelegate) {
    return true; // Simple approach to ensure smooth animation and updates
  }
}
