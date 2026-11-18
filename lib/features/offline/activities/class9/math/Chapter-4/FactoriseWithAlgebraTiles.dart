// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const FactoriseWithAlgebraTiles(),
    ),
  );
}

// --- MODELS ---

class TileModel {
  double x, y;
  final double width;
  final double height;
  final String type;
  final Color color;
  final double area;
  bool isRotated;

  TileModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    required this.color,
    required this.area,
    this.isRotated = false,
  });

  Rect getBounds() {
    double w = isRotated ? height : width;
    double h = isRotated ? width : height;
    return Rect.fromCenter(center: Offset(x, y), width: w, height: h);
  }
}

class Scenario {
  final int id;
  final String expr;
  final String factors;
  final int x2Count;
  final int xCount;
  final int oneCount;
  final bool solved;

  Scenario({
    required this.id,
    required this.expr,
    required this.factors,
    required this.x2Count,
    required this.xCount,
    required this.oneCount,
    this.solved = false,
  });
}

// --- MAIN SCREEN ---

class FactoriseWithAlgebraTiles extends StatefulWidget {
  const FactoriseWithAlgebraTiles({super.key});

  @override
  State<FactoriseWithAlgebraTiles> createState() =>
      _FactoriseWithAlgebraTilesState();
}

class _FactoriseWithAlgebraTilesState extends State<FactoriseWithAlgebraTiles>
    with SingleTickerProviderStateMixin {
  // Constants & Unit logic
  static const double unit = 40.0;

  // State
  bool _showCurtain = true;
  bool _showSuccess = false;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';
  int _currentScenarioIdx = 0;

  // Camera / Canvas state
  Offset _panOffset = Offset.zero;
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  final GlobalKey _canvasKey = GlobalKey();

  // Interaction
  TileModel? _draggedTile;
  Offset _dragOffset = Offset.zero;
  final List<TileModel> _tiles = [];
  int _lastTapTime = 0; // Used for instant drag vs double-tap detection

  // Animation
  late AnimationController _ticker;

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

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

  final List<Scenario> _scenarios = [
    Scenario(
      id: 0,
      expr: "x² + 5x + 6",
      factors: "(x + 2)(x + 3)",
      x2Count: 1,
      xCount: 5,
      oneCount: 6,
      solved: true,
    ),
    Scenario(
      id: 1,
      expr: "x² + 4x + 4",
      factors: "(x + 2)²",
      x2Count: 1,
      xCount: 4,
      oneCount: 4,
      solved: false,
    ),
    Scenario(
      id: 2,
      expr: "2x² + 7x + 3",
      factors: "(2x + 1)(x + 3)",
      x2Count: 2,
      xCount: 7,
      oneCount: 3,
      solved: false,
    ),
  ];

  // i18n
  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'shutterTitle': 'Factorise with Algebra Tiles',
      'shutterSubtitle': 'Class 9 • Exploring Algebraic Identities',
      'enterLab': 'Enter Lab',
      'scenario0': 'Scenario 1 (Solved)',
      'scenario1': 'Scenario 2 (Practice)',
      'scenario2': 'Scenario 3 (Challenge)',
      'missionObjective': 'Mission Objective',
      'action': 'Arrange into a rectangle',
      'tip': 'Tip: Double-tap to rotate x-tiles',
      'validateBtn': 'Validate Model',
      'awesome': 'Awesome!',
      'successMsg': 'You\'ve successfully factorised the expression.',
      'nextBtn': 'Next Step',
      'finishBtn': 'Restart Lab',
      'errorMsg': 'Tiles do not form a solid rectangle. Try rearranging.',
      'overlapMsg': 'Tiles are overlapping! Please separate them.',
      'scenarios': [
        {
          'desc': 'Factorise the quadratic expression x² + 5x + 6.',
          'steps': [
            'We need 1 blue x² tile, 5 green x tiles, and 6 yellow 1 tiles.',
            'Arrange these tiles to form a perfect solid rectangle.',
            'The length and width of the resulting rectangle will represent the factors.',
          ],
        },
        {
          'desc': 'Factorise the quadratic expression x² + 4x + 4.',
          'steps': [
            'Take 1 blue x² tile, 4 green x tiles, and 4 yellow 1 tiles.',
            'Arrange them to form a square (a special type of rectangle).',
            'What are the dimensions?',
          ],
        },
        {
          'desc': 'Factorise the quadratic expression 2x² + 7x + 3.',
          'steps': [
            'This is a harder challenge! You have 2 x² tiles.',
            'Use 7 x tiles and 3 1 tiles.',
            'Form a solid rectangle to find the binomial factors.',
          ],
        },
      ],
    },
    'hi': {
      'shutterTitle': 'बीजगणित टाइल्स के साथ गुणनखंडन',
      'shutterSubtitle': 'कक्षा 9 • बीजीय सर्वसमिकाओं की खोज',
      'enterLab': 'लैब में प्रवेश करें',
      'scenario0': 'परिदृश्य 1 (हल किया हुआ)',
      'scenario1': 'परिदृश्य 2 (अभ्यास)',
      'scenario2': 'परिदृश्य 3 (चुनौती)',
      'missionObjective': 'मिशन का उद्देश्य',
      'action': 'एक आयत में व्यवस्थित करें',
      'tip': 'सुझाव: x-टाइल्स को घुमाने के लिए डबल-टैप करें',
      'validateBtn': 'मॉडल मान्य करें',
      'awesome': 'बहुत बढ़िया!',
      'successMsg': 'बधाई हो! मॉडल एक पूर्ण आयत बनाता है।',
      'nextBtn': 'अगली चुनौती',
      'finishBtn': 'लैब रीस्टार्ट करें',
      'errorMsg': 'टाइल्स एक ठोस आयत नहीं बनाती हैं।',
      'overlapMsg': 'टाइल्स ओवरलैप हो रही हैं! कृपया उन्हें अलग करें।',
      'scenarios': [
        {
          'desc': 'द्विघात व्यंजक x² + 5x + 6 का गुणनखंडन करें।',
          'steps': [
            'हमें 1 नीली x² टाइल, 5 हरी x टाइलें, और 6 पीली 1 टाइलें चाहिए।',
            'एक पूर्ण ठोस आयत बनाने के लिए इन टाइल्स को व्यवस्थित करें।',
            'परिणामी आयत की लंबाई और चौड़ाई गुणनखंडों का प्रतिनिधित्व करेगी।',
          ],
        },
        {
          'desc': 'द्विघात व्यंजक x² + 4x + 4 का गुणनखंडन करें।',
          'steps': [
            '1 नीली x² टाइल, 4 हरी x टाइलें, और 4 पीली 1 टाइलें लें।',
            'उन्हें एक वर्ग बनाने के लिए व्यवस्थित करें।',
            'आयाम क्या हैं?',
          ],
        },
        {
          'desc': 'द्विघात व्यंजक 2x² + 7x + 3 का गुणनखंडन करें।',
          'steps': [
            'यह एक कठिन चुनौती है! आपके पास 2 x² टाइलें हैं।',
            '7 x टाइलें और 3 1 टाइलें का उपयोग करें।',
            'द्विपद गुणनखंड खोजने के लिए एक ठोस आयत बनाएं।',
          ],
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _sidebarWidth = MediaQuery.of(context).size.width * 0.35;
        if (_sidebarWidth < 320) _sidebarWidth = 320;
      });
      _loadScenario(0);
    });
  }

  @override
  void dispose() {
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    _ticker.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _t(String key) => _i18n[_lang]![key];

  void _loadScenario(int idx) {
    setState(() {
      _currentScenarioIdx = idx;
      _showSuccess = false;
      _panOffset = Offset(
        MediaQuery.of(context).size.width * 0.4,
        MediaQuery.of(context).size.height * 0.5,
      );
      _zoom = 1.0;
      _baseZoom = 1.0;
      _spawnTiles(_scenarios[idx]);
    });
  }

  void _spawnTiles(Scenario s) {
    _tiles.clear();
    double startX = -100;
    double startY = -150;

    // x2 tiles
    for (int i = 0; i < s.x2Count; i++) {
      _tiles.add(
        TileModel(
          x: startX,
          y: startY,
          width: 3 * unit,
          height: 3 * unit,
          type: 'x2',
          color: Colors.blue,
          area: 9 * unit * unit,
        ),
      );
      startX += (3 * unit) + 10;
      if (startX > 100) {
        startX = -100;
        startY += (3 * unit) + 10;
      }
    }
    // x tiles
    for (int i = 0; i < s.xCount; i++) {
      _tiles.add(
        TileModel(
          x: startX,
          y: startY,
          width: 3 * unit,
          height: unit,
          type: 'x',
          color: Colors.green,
          area: 3 * unit * unit,
        ),
      );
      startX += (3 * unit) + 10;
      if (startX > 100) {
        startX = -100;
        startY += (3 * unit) + 10;
      }
    }
    // 1 tiles
    for (int i = 0; i < s.oneCount; i++) {
      _tiles.add(
        TileModel(
          x: startX,
          y: startY,
          width: unit,
          height: unit,
          type: '1',
          color: Colors.yellow,
          area: unit * unit,
        ),
      );
      startX += unit + 10;
      if (startX > 100) {
        startX = -100;
        startY += unit + 10;
      }
    }

    if (s.solved) _autoSolve();
    for (var t in _tiles) {
      _snapToGrid(t);
    }
  }

  void _autoSolve() {
    var x2 = _tiles.where((t) => t.type == 'x2').toList();
    var x = _tiles.where((t) => t.type == 'x').toList();
    var one = _tiles.where((t) => t.type == '1').toList();

    if (x2.isNotEmpty) {
      x2[0].x = 0;
      x2[0].y = 0;

      x[0].x = 2 * unit;
      x[0].y = 0;
      x[1].x = 3 * unit;
      x[1].y = 0;

      x[2].isRotated = true;
      x[2].x = 0;
      x[2].y = 2 * unit;
      x[3].isRotated = true;
      x[3].x = 0;
      x[3].y = 3 * unit;
      x[4].isRotated = true;
      x[4].x = 0;
      x[4].y = 4 * unit;

      one[0].x = 2 * unit;
      one[0].y = 2 * unit;
      one[1].x = 3 * unit;
      one[1].y = 2 * unit;
      one[2].x = 2 * unit;
      one[2].y = 3 * unit;
      one[3].x = 3 * unit;
      one[3].y = 3 * unit;
      one[4].x = 2 * unit;
      one[4].y = 4 * unit;
      one[5].x = 3 * unit;
      one[5].y = 4 * unit;
    }
  }

  void _snapToGrid(TileModel t) {
    double halfUnit = unit / 2;
    double w = t.isRotated ? t.height : t.width;
    double h = t.isRotated ? t.width : t.height;

    double offsetX = (w / unit).round() % 2 == 0 ? halfUnit : 0;
    double offsetY = (h / unit).round() % 2 == 0 ? halfUnit : 0;

    t.x = ((t.x - offsetX) / halfUnit).round() * halfUnit + offsetX;
    t.y = ((t.y - offsetY) / halfUnit).round() * halfUnit + offsetY;
  }

  // --- GESTURES (Canvas Coordinate Mapping) ---

  Offset _screenToWorld(Offset screenPos) {
    return (screenPos - _panOffset) / _zoom;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localFocal = renderBox.globalToLocal(details.focalPoint);
    final Offset worldFocal = _screenToWorld(localFocal);

    _baseZoom = _zoom;
    _draggedTile = null;

    // Double tap detection (manual to prevent drag delay slop)
    int now = DateTime.now().millisecondsSinceEpoch;
    bool isDoubleTap = (now - _lastTapTime) < 300;
    _lastTapTime = now;

    // Check hit test (reverse order for top-most)
    for (int i = _tiles.length - 1; i >= 0; i--) {
      if (_tiles[i].getBounds().contains(worldFocal)) {
        if (isDoubleTap && _tiles[i].type == 'x') {
          playClick();
          setState(() {
            _tiles[i].isRotated = !_tiles[i].isRotated;
            _snapToGrid(_tiles[i]);
          });
          return; // Skip drag if rotated
        }

        playClick();
        _draggedTile = _tiles[i];
        _dragOffset = worldFocal - Offset(_tiles[i].x, _tiles[i].y);
        // Move to top
        _tiles.removeAt(i);
        _tiles.add(_draggedTile!);
        break;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedTile != null) {
      // Dragging a tile instantly
      final RenderBox renderBox =
          _canvasKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localFocal = renderBox.globalToLocal(details.focalPoint);
      Offset worldFocal = _screenToWorld(localFocal);

      setState(() {
        _draggedTile!.x = worldFocal.dx - _dragOffset.dx;
        _draggedTile!.y = worldFocal.dy - _dragOffset.dy;
      });
    } else {
      // Smooth Pan and Zoom
      setState(() {
        _panOffset += details.focalPointDelta;
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.5, 3.0);
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_draggedTile != null) {
      setState(() {
        _snapToGrid(_draggedTile!);
        _draggedTile = null;
      });
    }
  }

  // --- VALIDATION ---

  bool _checkOverlap() {
    for (int i = 0; i < _tiles.length; i++) {
      for (int j = i + 1; j < _tiles.length; j++) {
        Rect r1 = _tiles[i].getBounds().deflate(
          2.0,
        ); // deflate to prevent borderline false positive
        Rect r2 = _tiles[j].getBounds().deflate(2.0);
        if (r1.overlaps(r2)) return true;
      }
    }
    return false;
  }

  void _validateModel() {
    if (_tiles.isEmpty) return;

    if (_checkOverlap()) {
      playError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('overlapMsg')), backgroundColor: Colors.red),
      );
      return;
    }

    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    double totalArea = 0;

    for (var t in _tiles) {
      Rect b = t.getBounds();
      if (b.left < minX) minX = b.left;
      if (b.right > maxX) maxX = b.right;
      if (b.top < minY) minY = b.top;
      if (b.bottom > maxY) maxY = b.bottom;
      totalArea += t.area;
    }

    double bbWidth = maxX - minX;
    double bbHeight = maxY - minY;
    double bbArea = bbWidth * bbHeight;

    if ((bbArea - totalArea).abs() < 1.0) {
      playPageOpen();
      setState(() => _showSuccess = true);
    } else {
      playError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('errorMsg')), backgroundColor: Colors.red),
      );
    }
  }

  // --- BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildCanvasArea(),
            ),

            // 2. Sidebar (Completely scrollable)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // 3. Floating Menu Toggle (Always Visible)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
                child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
              ),
            ),

            // 4. Success Modal
            if (_showSuccess) _buildSuccessModal(),

            // 5. Curtain Screen
            if (_showCurtain) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF4C0519),
          ], // Deep navy to dark maroon
        ),
      ),
      child: Stack(
        children: [
          // Grid & Painter
          Positioned.fill(
            child: GestureDetector(
              key: _canvasKey,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              // Removed onDoubleTap to avoid gesture competition slop/delay
              child: CustomPaint(
                painter: AlgebraPainter(
                  tiles: _tiles,
                  panOffset: _panOffset,
                  zoom: _zoom,
                  repaint: _ticker,
                ),
              ),
            ),
          ),

          // HUD Floating Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorLegend(Colors.blue, "x²"),
                  const SizedBox(width: 16),
                  _colorLegend(Colors.green, "x"),
                  const SizedBox(width: 16),
                  _colorLegend(Colors.yellow, "1"),
                  const SizedBox(width: 24),
                  Container(width: 1, height: 24, color: Colors.white24),
                  const SizedBox(width: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t('action'),
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _t('tip'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorLegend(Color c, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    var scenarioData = _i18n[_lang]!['scenarios'][_currentScenarioIdx];

    return Row(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF1E293B),
            // The ENTIRE sidebar contents are now wrapped in SingleChildScrollView
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 56,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title & Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('shutterTitle'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t('shutterSubtitle'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Language & Reset Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: ['en', 'hi']
                              .map(
                                (l) => GestureDetector(
                                  onTap: () {
                                    playClick();
                                    setState(() => _lang = l);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _lang == l
                                          ? Colors.amber
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l.toUpperCase(),
                                      style: TextStyle(
                                        color: _lang == l
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          playClick();
                          setState(() {
                            _showCurtain = true;
                          });
                          _loadScenario(0);
                        },
                        tooltip: 'Reset',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Scenario Dropdown
                  Text(
                    "SELECT SCENARIO",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _currentScenarioIdx,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        items: List.generate(
                          3,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(
                              _t('scenario$i'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            playDropdown();
                            _loadScenario(val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Objective Content
                  Text(
                    _t('missionObjective'),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scenarioData['desc'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ...List.generate(scenarioData['steps'].length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${i + 1}. ",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              scenarioData['steps'][i],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Validate Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      playClick();
                      _validateModel();
                    },
                    child: Text(
                      _t('validateBtn'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  const Center(
                    child: Text(
                      "© ZeroScienceLab - Fall in love with math and Science",
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Resizer Handle & Border Line
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sidebarWidth += details.delta.dx;
              double maxW = MediaQuery.of(context).size.width * 0.7;
              if (_sidebarWidth < 300) _sidebarWidth = 300;
              if (_sidebarWidth > maxW) _sidebarWidth = maxW;
            });
          },
          child: Container(
            width: 12,
            color: const Color(0xFF1E293B),
            child: Center(
              child: Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Container(width: 1, color: Colors.white12), // Right Border Line
      ],
    );
  }

  Widget _buildCurtain() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF020617),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Colors.black,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _t('shutterTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _t('shutterSubtitle'),
                  style: const TextStyle(color: Colors.white70, fontSize: 20),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    curtainScreen();
                    setState(() => _showCurtain = false);
                  },
                  icon: const Icon(Icons.science, size: 28),
                  label: Text(
                    _t('enterLab'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSuccessModal() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          // Added SingleChildScrollView here to make the popup scrollable if the screen is small
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              margin: const EdgeInsets.symmetric(
                vertical: 24,
              ), // margin prevents flush edges
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _t('awesome'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('successMsg'),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Factors",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scenarios[_currentScenarioIdx].factors,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      playClick();
                      if (_currentScenarioIdx < _scenarios.length - 1) {
                        _loadScenario(_currentScenarioIdx + 1);
                      } else {
                        setState(() {
                          _showCurtain = true;
                        });
                        _loadScenario(0);
                      }
                    },
                    child: Text(
                      _currentScenarioIdx < _scenarios.length - 1
                          ? _t('nextBtn')
                          : _t('finishBtn'),
                      style: const TextStyle(
                        fontSize: 18,
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
    );
  }
}

// --- CANVAS PAINTER ---

class AlgebraPainter extends CustomPainter {
  final List<TileModel> tiles;
  final Offset panOffset;
  final double zoom;

  AlgebraPainter({
    required this.tiles,
    required this.panOffset,
    required this.zoom,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoom);

    // Draw Grid
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;

    double gridSpan = 2000;
    for (
      double i = -gridSpan;
      i <= gridSpan;
      i += _FactoriseWithAlgebraTilesState.unit
    ) {
      canvas.drawLine(Offset(i, -gridSpan), Offset(i, gridSpan), gridPaint);
      canvas.drawLine(Offset(-gridSpan, i), Offset(gridSpan, i), gridPaint);
    }

    // Draw Tiles
    for (var tile in tiles) {
      Rect rect = tile.getBounds();

      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(2, 4), const Radius.circular(4)),
        Paint()..color = Colors.black45,
      );

      // Tile Body
      final fillPaint = Paint()
        ..color = tile.color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        fillPaint,
      );

      // Tile Border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / zoom;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AlgebraPainter oldDelegate) => true;
}
