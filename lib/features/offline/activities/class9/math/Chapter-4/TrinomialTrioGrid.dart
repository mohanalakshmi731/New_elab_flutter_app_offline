// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrinomialTrioGrid());
}

// --- I18N DICTIONARY (No Telugu, per user directives) ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'title': 'Trinomial Trio (a+b+c)²',
    'subtitle': 'Class 9 • Exploring Algebraic Identities',
    'enter_lab': 'Enter Lab',
    'scenario': 'SCENARIO',
    'sc1': '1: Build the Squares (a², b², c²)',
    'sc2': '2: Build the Rectangles (2ab, 2bc, 2ca)',
    'sc3': '3: Assemble & Prove (a+b+c)²',
    'objective': 'MISSION OBJECTIVE',
    'obj1': 'Construct the three squares a², b², and c² on the main diagonal.',
    'obj2': 'Complete the grid by placing the cross-rectangles symmetrically.',
    'obj3':
        'Assemble all pieces to prove the identity. Drag each block to its place.',
    'steps': 'PROCEDURAL STEPS',
    'step1_1': 'Identify the main diagonal of the grid.',
    'step1_2': 'Place the a² square.',
    'step1_3': 'Place the b² square.',
    'step1_4': 'Place the c² square.',
    'step2_1': 'Place the two ab rectangles.',
    'step2_2': 'Place the two bc rectangles.',
    'step2_3': 'Place the two ca rectangles.',
    'step3_1': 'Drag the squares onto the diagonal.',
    'step3_2': 'Drag the rectangles to complete the grid.',
    'step3_3': 'Observe the assembled (a+b+c)² square.',
    'validate': 'VALIDATE MODEL',
    'restart': 'RESTART ACTIVITY',
    'hud1': 'Place the squares a², b², c² on the diagonal.',
    'hud2': 'Place the rectangles 2ab, 2bc, 2ca.',
    'hud3': 'Drag blocks into the outline to complete (a+b+c)²',
    'variables': 'VARIABLES',
    'action': 'CURRENT ACTION',
    'footer': '© ZEROSCIENCELAB | Fall in Love with Math and Science',
  },
  'hi': {
    'title': 'त्रिपद त्रयी (a+b+c)²',
    'subtitle': 'कक्षा 9 • बीजीय सर्वसमिकाओं की खोज',
    'enter_lab': 'लैब में प्रवेश करें',
    'scenario': 'परिदृश्य',
    'sc1': '1: वर्ग बनाएं (a², b², c²)',
    'sc2': '2: आयत बनाएं (2ab, 2bc, 2ca)',
    'sc3': '3: इकट्ठा करें और सिद्ध करें (a+b+c)²',
    'objective': 'मिशन उद्देश्य',
    'obj1': 'मुख्य विकर्ण पर तीन वर्ग a², b², और c² बनाएं।',
    'obj2': 'सममित रूप से क्रॉस-आयत रखकर ग्रिड को पूरा करें।',
    'obj3': 'पहचान साबित करने के लिए सभी टुकड़ों को इकट्ठा करें।',
    'steps': 'प्रक्रियात्मक चरण',
    'step1_1': 'ग्रिड के मुख्य विकर्ण को पहचानें।',
    'step1_2': 'a² वर्ग रखें।',
    'step1_3': 'b² वर्ग रखें।',
    'step1_4': 'c² वर्ग रखें।',
    'step2_1': 'दो ab आयत रखें।',
    'step2_2': 'दो bc आयत रखें।',
    'step2_3': 'दो ca आयत रखें।',
    'step3_1': 'वर्गों को विकर्ण पर खींचें।',
    'step3_2': 'ग्रिड को पूरा करने के लिए आयतों को खींचें।',
    'step3_3': 'इकट्ठे किए गए (a+b+c)² वर्ग का निरीक्षण करें।',
    'validate': 'मॉडल सत्यापित करें',
    'restart': 'गतिविधि पुनः आरंभ करें',
    'hud1': 'वर्गों a², b², c² को विकर्ण पर रखें।',
    'hud2': 'आयत 2ab, 2bc, 2ca रखें।',
    'hud3': 'ब्लॉकों को खींचकर (a+b+c)² पूरा करें',
    'variables': 'चर',
    'action': 'वर्तमान क्रिया',
    'footer': '© ZEROSCIENCELAB | गणित और विज्ञान से प्यार करें',
  },
};

// --- DATA MODELS ---
class BlockData {
  final String id;
  final String label;
  final double w;
  final double h;
  final Color color;
  final double targetX;
  final double targetY;

  double x;
  double y;
  bool isPlaced;

  BlockData({
    required this.id,
    required this.label,
    required this.w,
    required this.h,
    required this.color,
    required this.targetX,
    required this.targetY,
    required this.x,
    required this.y,
    this.isPlaced = false,
  });
}

class TrinomialTrioGrid extends StatefulWidget {
  const TrinomialTrioGrid({super.key});

  @override
  State<TrinomialTrioGrid> createState() => _TrinomialTrioGridState();
}

class _TrinomialTrioGridState extends State<TrinomialTrioGrid>
    with TickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _gameLoopController;

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';
  int _scenario = 1;
  int _completedSteps = 0;

  // Viewport/Camera parameters
  double _scale = 40.0;
  double _initialScale = 40.0;
  Offset _panOffset = Offset.zero;

  // Simulation Variables
  final double varA = 3.0;
  final double varB = 2.0;
  final double varC = 1.0;

  final List<BlockData> _blocks = [];
  BlockData? _draggedBlock;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoopController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

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

  void _enterLab() {
    playPageOpen();
    setState(() {
      _showCurtain = false;
      _loadScenario(1);
    });
  }

  void _loadScenario(int sc) {
    _scenario = sc;
    _completedSteps = sc == 1 ? 1 : 0;
    _panOffset = Offset.zero;
    _scale = 40.0;

    // Grid Layout Math
    double gap = 0.2;
    double tA = varA, tB = varB, tC = varC;
    double totalSize = tA + tB + tC + gap * 2;
    double startX = -totalSize / 2;
    double startY = -totalSize / 2;

    List<BlockData> config = [
      BlockData(
        id: 'a2',
        label: 'a²',
        w: tA,
        h: tA,
        color: Colors.blue,
        targetX: startX,
        targetY: startY,
        x: 0,
        y: 0,
      ),
      BlockData(
        id: 'ab1',
        label: 'ab',
        w: tB,
        h: tA,
        color: Colors.cyan,
        targetX: startX + tA + gap,
        targetY: startY,
        x: 0,
        y: 0,
      ),
      BlockData(
        id: 'ca1',
        label: 'ca',
        w: tC,
        h: tA,
        color: Colors.purple,
        targetX: startX + tA + tB + gap * 2,
        targetY: startY,
        x: 0,
        y: 0,
      ),

      BlockData(
        id: 'ab2',
        label: 'ab',
        w: tA,
        h: tB,
        color: Colors.cyan,
        targetX: startX,
        targetY: startY + tA + gap,
        x: 0,
        y: 0,
      ),
      BlockData(
        id: 'b2',
        label: 'b²',
        w: tB,
        h: tB,
        color: Colors.green,
        targetX: startX + tA + gap,
        targetY: startY + tA + gap,
        x: 0,
        y: 0,
      ),
      BlockData(
        id: 'bc1',
        label: 'bc',
        w: tC,
        h: tB,
        color: Colors.lightGreen,
        targetX: startX + tA + tB + gap * 2,
        targetY: startY + tA + gap,
        x: 0,
        y: 0,
      ),

      BlockData(
        id: 'ca2',
        label: 'ca',
        w: tA,
        h: tC,
        color: Colors.purple,
        targetX: startX,
        targetY: startY + tA + tB + gap * 2,
        x: 0,
        y: 0,
      ),
      BlockData(
        id: 'bc2',
        label: 'bc',
        w: tB,
        h: tC,
        color: Colors.lightGreen,
        targetX: startX + tA + gap,
        targetY: startY + tA + tB + gap * 2,
        x: 0,
        y: 0,
      ),
      BlockData(
        id: 'c2',
        label: 'c²',
        w: tC,
        h: tC,
        color: Colors.orange,
        targetX: startX + tA + tB + gap * 2,
        targetY: startY + tA + tB + gap * 2,
        x: 0,
        y: 0,
      ),
    ];

    _blocks.clear();
    final random = Random();

    bool isSquare(String id) => ['a2', 'b2', 'c2'].contains(id);

    for (var b in config) {
      if (_scenario == 1) {
        if (isSquare(b.id)) {
          b.x = b.targetX + (random.nextDouble() * 4 - 2);
          b.y = b.targetY + (random.nextDouble() * 4 - 2) + 5;
          _blocks.add(b);
        }
      } else if (_scenario == 2) {
        if (!isSquare(b.id)) {
          b.x = b.targetX + (random.nextDouble() * 4 - 2);
          b.y = b.targetY + (random.nextDouble() * 4 - 2) + 5;
          _blocks.add(b);
        } else {
          b.x = b.targetX;
          b.y = b.targetY;
          b.isPlaced = true;
          _blocks.add(b);
        }
      } else {
        b.x = (random.nextDouble() * 8 - 4);
        b.y = (random.nextDouble() * 8 - 4) + 6;
        _blocks.add(b);
      }
    }
  }

  void _checkProgress() {
    setState(() {
      if (_scenario == 1) {
        bool a = _blocks.any((b) => b.id == 'a2' && b.isPlaced);
        bool b = _blocks.any((b) => b.id == 'b2' && b.isPlaced);
        bool c = _blocks.any((b) => b.id == 'c2' && b.isPlaced);
        
        if (a && b && c) {
          _completedSteps = 4;
        } else if (a && b) {
          _completedSteps = 3;
        } else if (a) {
          _completedSteps = 2;
        } else {
          _completedSteps = 1;
        }
      } else if (_scenario == 2) {
        int ab = _blocks.where((b) => b.id.startsWith('ab') && b.isPlaced).length;
        int bc = _blocks.where((b) => b.id.startsWith('bc') && b.isPlaced).length;
        int ca = _blocks.where((b) => b.id.startsWith('ca') && b.isPlaced).length;
        
        if (ab == 2 && bc == 2 && ca == 2) {
          _completedSteps = 3;
        } else if (ab == 2 && bc == 2) {
          _completedSteps = 2;
        } else if (ab == 2) {
          _completedSteps = 1;
        } else {
          _completedSteps = 0;
        }
      } else {
        int squaresPlaced = _blocks.where((b) => ['a2', 'b2', 'c2'].contains(b.id) && b.isPlaced).length;
        int rectsPlaced = _blocks.where((b) => !['a2', 'b2', 'c2'].contains(b.id) && b.isPlaced).length;
        
        _completedSteps = 0;
        if (squaresPlaced == 3) _completedSteps = 1;
        if (squaresPlaced == 3 && rectsPlaced == 6) _completedSteps = 3;
      }
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (_canvasKey.currentContext == null) return;

    // Only handle tapping for instantly placing blocks in Scenarios 1 & 2
    if (_scenario == 3) return;

    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localFocal = box.globalToLocal(details.globalPosition);

    final Size size = box.size;
    final double centerScreenX = size.width / 2 + _panOffset.dx;
    final double centerScreenY = size.height / 2 + _panOffset.dy;

    final double worldX = (localFocal.dx - centerScreenX) / _scale;
    final double worldY = (localFocal.dy - centerScreenY) / _scale;

    // Hit test blocks from top to bottom
    for (int i = _blocks.length - 1; i >= 0; i--) {
      final b = _blocks[i];
      if (b.isPlaced) continue;

      if (worldX >= b.x &&
          worldX <= b.x + b.w &&
          worldY >= b.y &&
          worldY <= b.y + b.h) {
        playClick();
        setState(() {
          b.x = b.targetX;
          b.y = b.targetY;
          b.isPlaced = true;
        });
        _checkProgress();
        return;
      }
    }
    
    // Tap outside blocks
    playError();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_canvasKey.currentContext == null) return;

    _initialScale = _scale;

    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localFocal = box.globalToLocal(details.focalPoint);

    final Size size = box.size;
    final double centerScreenX = size.width / 2 + _panOffset.dx;
    final double centerScreenY = size.height / 2 + _panOffset.dy;

    final double worldX = (localFocal.dx - centerScreenX) / _scale;
    final double worldY = (localFocal.dy - centerScreenY) / _scale;

    // Only process picking up blocks in Scenario 3 (Drag and Drop)
    if (_scenario == 3) {
      for (int i = _blocks.length - 1; i >= 0; i--) {
        final b = _blocks[i];
        if (b.isPlaced) continue;

        if (worldX >= b.x &&
            worldX <= b.x + b.w &&
            worldY >= b.y &&
            worldY <= b.y + b.h) {
          _draggedBlock = b;
          // Bring to front visually
          _blocks.removeAt(i);
          _blocks.add(b);
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedBlock != null && _scenario == 3) {
      // Drag Block Logic
      final RenderBox box =
          _canvasKey.currentContext!.findRenderObject() as RenderBox;
      final Offset localFocal = box.globalToLocal(details.focalPoint);
      final Size size = box.size;
      final double centerScreenX = size.width / 2 + _panOffset.dx;
      final double centerScreenY = size.height / 2 + _panOffset.dy;

      setState(() {
        _draggedBlock!.x =
            (localFocal.dx - centerScreenX) / _scale - _draggedBlock!.w / 2;
        _draggedBlock!.y =
            (localFocal.dy - centerScreenY) / _scale - _draggedBlock!.h / 2;
      });
    } else {
      // Smooth Pan & Zoom Logic
      setState(() {
        _panOffset += details.focalPointDelta;
        if (details.scale != 1.0) {
          _scale = (_initialScale * details.scale).clamp(10.0, 100.0);
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_draggedBlock != null && _scenario == 3) {
      double dx = _draggedBlock!.x - _draggedBlock!.targetX;
      double dy = _draggedBlock!.y - _draggedBlock!.targetY;
      double dist = sqrt(dx * dx + dy * dy);

      if (dist < 1.0) {
        playClick();
        setState(() {
          _draggedBlock!.x = _draggedBlock!.targetX;
          _draggedBlock!.y = _draggedBlock!.targetY;
          _draggedBlock!.isPlaced = true;
        });
        _checkProgress();
      } else {
        playError();
      }
      _draggedBlock = null;
    }
  }

  String t(String key) => i18n[_lang]![key] ?? key;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    _sidebarWidth = _sidebarWidth.clamp(300.0, max(300.0, screenWidth * 0.7));

    return MaterialApp(
      title: 'Trinomial Trio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Inter',
      ),
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Scaffold(
          body: Stack(
            children: [
              // 1. Canvas Area
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? _sidebarWidth : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF4C0519)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: GestureDetector(
                    key: _canvasKey,
                    onTapDown: _handleTapDown,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onScaleEnd: _handleScaleEnd,
                    child: AnimatedBuilder(
                      animation: _gameLoopController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: TrinomialPainter(
                            blocks: _blocks,
                            scale: _scale,
                            panOffset: _panOffset,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 2. Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? 0 : -_sidebarWidth,
                top: 0,
                bottom: 0,
                width: _sidebarWidth,
                child: Container(
                  color: const Color(0xFF1E293B),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: 80.0,
                            left: 24.0,
                            right: 24.0,
                            bottom: 24.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Section with Activity Icon
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: Icon(
                                      Icons.grid_on,
                                      color: Colors.amber,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t('title'),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t('subtitle'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Language Toggle and Reset placed below subtitle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: ['en', 'hi'].map((l) {
                                        bool active = _lang == l;
                                        return GestureDetector(
                                          onTap: () {
                                            if (!active) {
                                              playDropdown();
                                              setState(() => _lang = l);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: active
                                                  ? Colors.amber
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              l.toUpperCase(),
                                              style: TextStyle(
                                                color: active
                                                    ? Colors.black
                                                    : Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      playDropdown();
                                      // Reset to Curtain Screen
                                      setState(() {
                                        _showCurtain = true;
                                        _loadScenario(1);
                                      });
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),
                              Text(
                                t('scenario'),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _scenario,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF0F172A),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text(t('sc1')),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Text(t('sc2')),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Text(t('sc3')),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null && val != _scenario) {
                                        playDropdown();
                                        setState(() => _loadScenario(val));
                                      }
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.track_changes,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t('objective'),
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('obj$_scenario'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.list_alt,
                                          color: Colors.white54,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t('steps'),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStep(0, t('step${_scenario}_1')),
                                    _buildStep(1, t('step${_scenario}_2')),
                                    _buildStep(2, t('step${_scenario}_3')),
                                    if (_scenario == 1)
                                      _buildStep(3, t('step${_scenario}_4')),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _completedSteps >=
                                                (_scenario == 1 ? 4 : 3)
                                            ? Colors.amber
                                            : Colors.white12,
                                    foregroundColor:
                                        _completedSteps >=
                                                (_scenario == 1 ? 4 : 3)
                                            ? Colors.black
                                            : Colors.white54,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      _completedSteps >=
                                              (_scenario == 1 ? 4 : 3)
                                          ? () {
                                              if (_scenario < 3) {
                                                playPageOpen();
                                                setState(
                                                  () => _loadScenario(_scenario + 1),
                                                );
                                              } else {
                                                curtainScreen();
                                                // Reset to Curtain Screen
                                                setState(() {
                                                  _showCurtain = true;
                                                  _loadScenario(1);
                                                });
                                              }
                                            }
                                          : () { playError(); },
                                  child: Text(
                                    _scenario == 3 && _completedSteps >= 3
                                        ? t('restart')
                                        : t('validate'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                              Center(
                                child: Text(
                                  t('footer'),
                                  style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Border & Drag Handle (Resizer)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: (details) {
                          setState(() {
                            _sidebarWidth += details.delta.dx;
                          });
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeLeftRight,
                          child: Container(
                            width: 8,
                            color: Colors.black26,
                            child: Center(
                              child: Container(
                                height: 40,
                                width: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Menu Button
              Positioned(
                left: 16,
                top: 16,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Icon(
                      _isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 4. Bottom HUD
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? _sidebarWidth + 24 : 24,
                right: 24,
                bottom: 24,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t('variables'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'a = ${varA.toInt()}  ',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'b = ${varB.toInt()}  ',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'c = ${varC.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.white12,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t('action'),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t('hud$_scenario'),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Curtain Screen Overlay
              if (_showCurtain)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF020617),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.grid_on,
                            size: 80,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('title'),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('subtitle'),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),
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
                              elevation: 10,
                            ),
                            onPressed: _enterLab,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              t('enter_lab'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index, String text) {
    bool isCompleted = _completedSteps > index;
    bool isActive = _completedSteps == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? Colors.green
                    : (isActive ? Colors.amber : Colors.white30),
                width: 2,
              ),
              boxShadow: isActive
                  ? [const BoxShadow(color: Colors.amber, blurRadius: 4)]
                  : [],
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isCompleted
                    ? Colors.white54
                    : (isActive ? Colors.white : Colors.white70),
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrinomialPainter extends CustomPainter {
  final List<BlockData> blocks;
  final double scale;
  final Offset panOffset;

  TrinomialPainter({
    required this.blocks,
    required this.scale,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2 + panOffset.dx,
      size.height / 2 + panOffset.dy,
    );

    // Draw Grid Background lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw Target Zones (Ghosts)
    final Paint ghostPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final Paint ghostBorder = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var b in blocks) {
      final targetRect = Rect.fromLTWH(
        center.dx + b.targetX * scale,
        center.dy + b.targetY * scale,
        b.w * scale,
        b.h * scale,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetRect, const Radius.circular(4)),
        ghostPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetRect, const Radius.circular(4)),
        ghostBorder,
      );
    }

    // Draw Blocks
    for (var b in blocks) {
      final rect = Rect.fromLTWH(
        center.dx + b.x * scale,
        center.dy + b.y * scale,
        b.w * scale,
        b.h * scale,
      );

      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.shift(const Offset(4, 4)),
          const Radius.circular(8),
        ),
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Block Fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = b.color
          ..style = PaintingStyle.fill,
      );

      // Block Highlight (3D feel)
      final borderRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      );
      canvas.drawRRect(
        borderRect,
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Text Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: b.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: (scale * 0.4).clamp(12.0, 36.0),
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrinomialPainter oldDelegate) => true;
}
