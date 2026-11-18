// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, avoid_unnecessary_containers

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Cube Constructor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFFEAB308),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const CubeConstructor(),
    ),
  );
}

// --- Data Models & 3D Math ---

class Vec3 {
  double x, y, z;
  Vec3(this.x, this.y, this.z);
  Vec3 clone() => Vec3(x, y, z);
}

class Face {
  List<Vec3> vertices;
  Color color;
  bool isWireframe;
  double avgZ = 0;
  Block? parentBlock;

  Face(this.vertices, this.color, {this.isWireframe = false, this.parentBlock});
}

class Block {
  String typeLabel;
  double w, h, d;
  Color color;
  Vec3 targetPos;

  Vec3 pos = Vec3(0, 0, 0);
  Vec3 rot = Vec3(0, 0, 0); // Rotation in radians (x, y, z)

  bool isAssembled = false;

  // Animation state for snapping
  Vec3 startPos = Vec3(0, 0, 0);
  Vec3 startRot = Vec3(0, 0, 0);
  double animProgress = 1.0;

  Block({
    required this.typeLabel,
    required this.w,
    required this.h,
    required this.d,
    required this.color,
    required this.targetPos,
  });

  void setRandomPosition() {
    double angle = math.Random().nextDouble() * math.pi * 2;
    double radius = 5 + math.Random().nextDouble() * 2;
    pos = Vec3(
      math.cos(angle) * radius,
      1 + math.Random().nextDouble() * 4,
      math.sin(angle) * radius,
    );
    rot = Vec3(
      math.Random().nextDouble() * math.pi,
      math.Random().nextDouble() * math.pi,
      math.Random().nextDouble() * math.pi,
    );
    isAssembled = false;
    animProgress = 1.0;
  }
}

class DrawnPolygon {
  Path path;
  Block block;
  DrawnPolygon(this.path, this.block);
}

// --- Main State ---

class CubeConstructor extends StatefulWidget {
  const CubeConstructor({super.key});
  @override
  State<CubeConstructor> createState() => _CubeConstructorState();
}

class _CubeConstructorState extends State<CubeConstructor>
    with TickerProviderStateMixin {
  // UI State
  bool showCurtain = true;
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;
  String lang = 'en';
  int scenario = 0;
  String? flashMessage;
  bool flashIsError = false;

  // Game/Phase State
  List<Block> pieces = [];
  int assembledCount = 0;
  bool isPhase3Validated = false;

  // Phase 1 specific
  String? activeCoeffSlot;
  Map<String, int?> coeffVals = {
    'c1': null,
    'c2': null,
    'c3': null,
    'c4': null,
  };

  // Phase 2 specific
  String? ansA;
  String? ansB;
  String? ansSide;

  // 3D Camera State
  double camDist = 25.0;
  double camPitch = 0.5;
  double camYaw = -0.7;
  Vec3 camTarget = Vec3(0, 0, 0);

  // Gesture State
  final GlobalKey _canvasKey = GlobalKey();
  double _startDist = 25.0;

  // Animation & Audio
  late AnimationController _gameLoop;
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Interaction Map from CustomPainter
  List<DrawnPolygon> _lastFramePolygons = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoop.addListener(_updateGameLogic);

    _buildPieces();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  // --- Audio Methods ---

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

  void _showFlash(String msg, {bool isError = false}) {
    if (isError) {
      playError();
    } else {
      playPageOpen();
    }

    setState(() {
      flashMessage = msg;
      flashIsError = isError;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && flashMessage == msg) {
        setState(() => flashMessage = null);
      }
    });
  }

  void _buildPieces() {
    pieces.clear();
    assembledCount = 0;

    const double a = 2.0;
    const double b = 1.2;
    const Color cA3 = Color(0xFFF97316);
    const Color cA2B = Color(0xFF3B82F6);
    const Color cAB2 = Color(0xFF0EA5E9);
    const Color cB3 = Color(0xFFEAB308);

    const double off = (a + b) / 2;

    void createPiece(
      double w,
      double h,
      double d,
      Color col,
      double tx,
      double ty,
      double tz,
      String type,
    ) {
      final block = Block(
        typeLabel: type,
        w: w,
        h: h,
        d: d,
        color: col,
        targetPos: Vec3(tx - off + w / 2, ty - off + h / 2, tz - off + d / 2),
      );
      block.setRandomPosition();
      pieces.add(block);
    }

    createPiece(a, a, a, cA3, 0, 0, 0, 'a³');
    createPiece(a, a, b, cA2B, 0, 0, a, 'a²b');
    createPiece(a, b, a, cA2B, 0, a, 0, 'a²b');
    createPiece(b, a, a, cA2B, a, 0, 0, 'a²b');
    createPiece(a, b, b, cAB2, 0, a, a, 'ab²');
    createPiece(b, a, b, cAB2, a, 0, a, 'ab²');
    createPiece(b, b, a, cAB2, a, a, 0, 'ab²');
    createPiece(b, b, b, cB3, a, a, a, 'b³');
  }

  void _updateGameLogic() {
    double dt = 0.016; // Approx 60fps
    double time = DateTime.now().millisecondsSinceEpoch * 0.001;

    bool needsRepaint = false;
    for (int i = 0; i < pieces.length; i++) {
      var p = pieces[i];
      if (!p.isAssembled && p.animProgress == 1.0) {
        // Float animation
        p.pos.y += math.sin(time * 2 + i) * 0.005;
        p.rot.x += 0.005;
        p.rot.y += 0.005;
        needsRepaint = true;
      } else if (p.animProgress < 1.0) {
        // Snapping animation
        p.animProgress += dt * 2.5; // duration ~400ms
        if (p.animProgress > 1.0) p.animProgress = 1.0;

        double t = p.animProgress;
        double ease = t < 1 ? 1 - math.pow(1 - t, 3).toDouble() : 1;

        p.pos.x = p.startPos.x + (p.targetPos.x - p.startPos.x) * ease;
        p.pos.y = p.startPos.y + (p.targetPos.y - p.startPos.y) * ease;
        p.pos.z = p.startPos.z + (p.targetPos.z - p.startPos.z) * ease;

        p.rot.x = p.startRot.x * (1 - ease);
        p.rot.y = p.startRot.y * (1 - ease);
        p.rot.z = p.startRot.z * (1 - ease);
        needsRepaint = true;
      }
    }
    if (needsRepaint) setState(() {});
  }

  void _snapPiece(Block obj) {
    if (obj.isAssembled) return;
    playClick();
    obj.isAssembled = true;
    assembledCount++;
    obj.startPos = obj.pos.clone();
    obj.startRot = obj.rot.clone();
    obj.animProgress = 0.0;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (scenario != 0) return;

    RenderBox box = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(event.position);

    // Hit test starting from the frontmost polygons
    for (var poly in _lastFramePolygons.reversed) {
      if (poly.path.contains(localPos)) {
        if (!poly.block.isAssembled) {
          _snapPiece(poly.block);
          break;
        }
      }
    }
  }

  void _loadScenario(int idx, {bool retainState = false}) {
    if (idx != scenario) playDropdown();
    setState(() {
      scenario = idx;
      isPhase3Validated = false;
      if (idx == 0) {
        if (!retainState && assembledCount < 8) _buildPieces();
      } else if (idx == 1) {
        if (assembledCount < 8) {
          for (var p in pieces) {
            p.isAssembled = true;
            p.pos = p.targetPos.clone();
            p.rot = Vec3(0, 0, 0);
          }
          assembledCount = 8;
        }
        if (!retainState) {
          activeCoeffSlot = null;
          coeffVals = {'c1': null, 'c2': null, 'c3': null, 'c4': null};
        }
      } else if (idx == 2) {
        if (!retainState) {
          ansA = null;
          ansB = null;
          ansSide = null;
        }
      }
    });
  }

  void _validate() {
    var d = dict[lang]!;
    if (scenario == 0) {
      if (assembledCount == 8) {
        _showFlash(d['msg-build-success']!);
        Future.delayed(const Duration(seconds: 2), () => _loadScenario(1));
      } else {
        _showFlash(d['msg-build-err']!, isError: true);
      }
    } else if (scenario == 1) {
      if (coeffVals['c1'] == 1 &&
          coeffVals['c2'] == 3 &&
          coeffVals['c3'] == 3 &&
          coeffVals['c4'] == 1) {
        _showFlash(d['msg-tally-success']!);
        Future.delayed(const Duration(seconds: 2), () => _loadScenario(2));
      } else {
        _showFlash(d['msg-tally-err']!, isError: true);
      }
    } else if (scenario == 2) {
      if (ansA == 'p' && ansB == '2q' && ansSide == 'p+2q') {
        _showFlash(d['msg-side-success']!);
        setState(() {
          isPhase3Validated = true;
        });
      } else {
        _showFlash(d['msg-side-err']!, isError: true);
      }
    }
  }

  // Dictionary
  final Map<String, Map<String, String>> dict = {
    'en': {
      "app-title": "Cube Constructor",
      "subtitle": "Class 9 • Exploring Algebraic Identities",
      "enter-lab": "Enter Lab",
      "scen-0": "Scenario 1: Decompose the Cube",
      "scen-1": "Scenario 2: Tally 1-3-3-1",
      "scen-2": "Scenario 3: Find the Side (Ex. 13)",
      "phase0-title": "Build the Cube",
      "phase1-title": "Tally 1-3-3-1",
      "phase2-title": "Find the Side",
      "phase0-miss":
          "Click the floating parts to snap them into the main assembly.",
      "phase1-miss": "Select the correct coefficients based on the built cube.",
      "phase2-miss": "Match terms to find a and b.",
      "desc-0": "Decompose a cube of edge (a+b) into its 8 parts.",
      "desc-1":
          "Observe the assembled cube and count the identical pieces to find the coefficients.",
      "desc-2":
          "Use the identity backwards to find the side of a cube given its volume.",
      "msg-build-success": "✔ Cube Successfully Built!",
      "msg-build-err": "Please assemble all 8 parts of the cube first.",
      "msg-tally-success": "✔ Correct! The coefficients are 1-3-3-1.",
      "msg-tally-err":
          "Incorrect. Count the number of identical pieces carefully.",
      "msg-side-success": "🎉 Brilliant! You mastered the identity!",
      "msg-side-err": "Check your mapping. If b³ = 8q³, what is b?",
      "validate": "Validate Model",
      "restart": "Restart Lab",
      "step1": "Observe floating solid pieces.",
      "step2": "Tap each piece to snap it into the assembly.",
      "step3": "Notice the volumes: 1 large, 1 small, 6 mixed.",
    },
    'hi': {
      "app-title": "घन निर्माता",
      "subtitle": "कक्षा 9 • बीजीय सर्वसमिकाएँ",
      "enter-lab": "लैब में प्रवेश करें",
      "scen-0": "परिदृश्य 1: घन को विघटित करें",
      "scen-1": "परिदृश्य 2: 1-3-3-1 का मिलान करें",
      "scen-2": "परिदृश्य 3: भुजा ज्ञात करें",
      "phase0-title": "घन बनाएँ",
      "phase1-title": "1-3-3-1 का मिलान करें",
      "phase2-title": "भुजा ज्ञात करें",
      "phase0-miss": "तैरते हुए भागों को जोड़ने के लिए क्लिक करें।",
      "phase1-miss": "निर्मित घन के आधार पर सही गुणांक चुनें।",
      "phase2-miss": "a और b खोजने के लिए पदों का मिलान करें।",
      "desc-0": "(a+b) किनारे वाले घन को उसके 8 भागों में विघटित करें।",
      "desc-1": "समान टुकड़ों की गणना करके गुणांक खोजें।",
      "desc-2":
          "आयतन दिए जाने पर घन की भुजा ज्ञात करने के लिए सर्वसमिका का विपरीत उपयोग करें।",
      "msg-build-success": "✔ घन सफलतापूर्वक बन गया!",
      "msg-build-err": "कृपया पहले घन के सभी 8 भागों को इकट्ठा करें।",
      "msg-tally-success": "✔ सही! गुणांक 1-3-3-1 हैं।",
      "msg-tally-err": "गलत। समान टुकड़ों की संख्या को ध्यान से गिनें।",
      "msg-side-success":
          "🎉 बहुत बढ़िया! आपने सर्वसमिका में महारत हासिल कर ली है!",
      "msg-side-err": "अपने मिलान की जाँच करें। यदि b³ = 8q³ है, तो b क्या है?",
      "validate": "मॉडल मान्य करें",
      "restart": "पुनः आरंभ करें",
      "step1": "तैरते हुए ठोस टुकड़ों का निरीक्षण करें।",
      "step2": "जोड़ने के लिए प्रत्येक टुकड़े पर टैप करें।",
      "step3": "आयतन पर ध्यान दें: 1 बड़ा, 1 छोटा, 6 मिश्रित।",
    },
  };

  @override
  Widget build(BuildContext context) {
    var d = dict[lang]!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Listener(
                onPointerDown:
                    _handlePointerDown, // Raw listener bypasses gesture drag conflicts
                child: GestureDetector(
                  onScaleStart: (details) {
                    _startDist = camDist;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      if (details.scale != 1.0) {
                        // Pinch / Pan Mode
                        camDist = (_startDist / details.scale).clamp(
                          10.0,
                          60.0,
                        );
                        camTarget.x -= details.focalPointDelta.dx * 0.05;
                        camTarget.z -= details.focalPointDelta.dy * 0.05;
                      } else {
                        // Orbit Mode
                        camYaw += details.focalPointDelta.dx * 0.01;
                        camPitch += details.focalPointDelta.dy * 0.01;
                        // Clamp pitch to avoid gimbal lock
                        camPitch = camPitch.clamp(
                          -math.pi / 2 + 0.1,
                          math.pi / 2 - 0.1,
                        );
                      }
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF4C0519)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CustomPaint(
                      key: _canvasKey,
                      painter: Canvas3DPainter(
                        pieces: pieces,
                        camDist: camDist,
                        camPitch: camPitch,
                        camYaw: camYaw,
                        camTarget: camTarget,
                        onPolygonsDrawn: (polys) => _lastFramePolygons = polys,
                      ),
                      child: Container(), // Fill space
                    ),
                  ),
                ),
              ),
            ),

            // 2. HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: sidebarOpen ? sidebarWidth : 0,
              right: 0,
              bottom: 20,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  // Let touches pass through the HUD text
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      // Pre-calculated 0.85 opacity of 0xFF0F172A to remain a valid const
                      color: const Color(0xD90F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d['phase$scenario-title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['phase$scenario-miss']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 30,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == scenario
                                    ? const Color(0xFFEAB308)
                                    : (i < scenario
                                          ? Colors.green
                                          : Colors.white24),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Sidebar (Animated Positioned - completely scrollable)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: sidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              64,
                              16,
                              20,
                            ), // Left padding avoids menu overlap
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4, right: 12),
                                  child: Icon(
                                    Icons.view_in_ar,
                                    size: 32,
                                    color: Color(0xFFEAB308),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['app-title']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEAB308),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        d['subtitle']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              playClick();
                                              setState(
                                                () => lang = lang == 'en'
                                                    ? 'hi'
                                                    : 'en',
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                lang.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () {
                                              playPageOpen();
                                              setState(() {
                                                showCurtain = true;
                                                _buildPieces();
                                              });
                                              _loadScenario(0);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              child: const Icon(
                                                Icons.refresh,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Body
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Scenario Dropdown
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFFEAB308),
                                        ),
                                        items: [0, 1, 2]
                                            .map(
                                              (i) => DropdownMenuItem(
                                                value: i,
                                                child: Text(
                                                  d['scen-$i']!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) => _loadScenario(v!),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Dynamic Content
                                  _buildSidebarContent(d),
                                  const SizedBox(height: 30),

                                  // Action Button (pushes to bottom space if needed)
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    icon: Icon(
                                      scenario == 2 && isPhase3Validated
                                          ? Icons.restart_alt
                                          : Icons.check_circle,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      scenario == 2 && isPhase3Validated
                                          ? d['restart']!
                                          : d['validate']!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEAB308),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      playClick();
                                      if (scenario == 2 && isPhase3Validated) {
                                        setState(() => showCurtain = true);
                                        _loadScenario(0);
                                      } else {
                                        _validate();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "© ZeroScienceLab - Fall in love with math and Science",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Menu Toggle (Fixed top left)
            Positioned(
              left: 10,
              top: 15,
              child: IconButton(
                icon: Icon(
                  sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  playClick();
                  setState(() => sidebarOpen = !sidebarOpen);
                },
              ),
            ),

            // 5. Sidebar Draggable Handle
            if (sidebarOpen)
              Positioned(
                left: sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        sidebarWidth += details.delta.dx;
                        if (sidebarWidth < 300) sidebarWidth = 300;
                        if (sidebarWidth >
                            MediaQuery.of(context).size.width * 0.8) {
                          sidebarWidth =
                              MediaQuery.of(context).size.width * 0.8;
                        }
                      });
                    },
                    child: Container(
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Curtain Screen
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              top: showCurtain ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF020617),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.view_in_ar,
                        size: 64,
                        color: Color(0xFFEAB308),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        d['app-title']!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d['subtitle']!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.rocket_launch,
                          color: Colors.black,
                        ),
                        label: Text(
                          d['enter-lab']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAB308),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                        ),
                        onPressed: () {
                          curtainScreen();
                          setState(() => showCurtain = false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Flash Message
            if (flashMessage != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: sidebarOpen ? sidebarWidth : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: flashIsError
                            ? Colors.red.withOpacity(0.9)
                            : Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        flashMessage!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent(Map<String, String> d) {
    if (scenario == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MISSION OBJECTIVE",
            style: TextStyle(
              color: Color(0xFFEAB308),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            d['desc-0']!,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _stepRow(d['step1']!),
          _stepRow(d['step2']!),
          _stepRow(d['step3']!),
        ],
      );
    } else if (scenario == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MISSION OBJECTIVE",
            style: TextStyle(
              color: Color(0xFFEAB308),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            d['desc-1']!,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "(a+b)³ =",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _coeffSlot('c1', 'a³'),
                    _coeffSlot('c2', 'a²b'),
                    _coeffSlot('c3', 'ab²'),
                    _coeffSlot('c4', 'b³'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1, 2, 3]
                      .map(
                        (v) => GestureDetector(
                          onTap: () {
                            if (activeCoeffSlot != null) {
                              playClick();
                              setState(() => coeffVals[activeCoeffSlot!] = v);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "$v",
                              style: const TextStyle(
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
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MISSION OBJECTIVE",
            style: TextStyle(
              color: Color(0xFFEAB308),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            d['desc-2']!,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "V = p³ + 6p²q + 12pq² + 8q³",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "If a³ = p³, then a = ?",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    'p',
                    '2q',
                    'p²',
                  ].map((v) => _mcqBtn('ansA', v, ansA == v)).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  "If b³ = 8q³, then b = ?",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    '8q',
                    '2q',
                    '4q',
                  ].map((v) => _mcqBtn('ansB', v, ansB == v)).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  "So side (a+b) = ?",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    'p+q',
                    'p+2q',
                  ].map((v) => _mcqBtn('ansSide', v, ansSide == v)).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _stepRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFEAB308), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coeffSlot(String slotKey, String suffix) {
    bool active = activeCoeffSlot == slotKey;
    String val = coeffVals[slotKey] != null ? "${coeffVals[slotKey]}" : "?";
    return Expanded(
      child: GestureDetector(
        onTap: () {
          playClick();
          setState(() => activeCoeffSlot = slotKey);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            // Pre-calculated 0.2 opacity of 0xFFEAB308 to remain a valid const
            color: active ? const Color(0x33EAB308) : Colors.transparent,
            border: Border.all(
              color: active ? const Color(0xFFEAB308) : Colors.white24,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              "$val $suffix",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mcqBtn(String group, String val, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          playClick();
          setState(() {
            if (group == 'ansA') ansA = val;
            if (group == 'ansB') ansB = val;
            if (group == 'ansSide') ansSide = val;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            // Pre-calculated 0.2 opacity of 0xFFEAB308 to remain a valid const
            color: isSelected ? const Color(0x33EAB308) : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFFEAB308) : Colors.white24,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              val,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3D Projection Painter ---

class Canvas3DPainter extends CustomPainter {
  final List<Block> pieces;
  final double camDist;
  final double camPitch;
  final double camYaw;
  final Vec3 camTarget;
  final Function(List<DrawnPolygon>) onPolygonsDrawn;

  Canvas3DPainter({
    required this.pieces,
    required this.camDist,
    required this.camPitch,
    required this.camYaw,
    required this.camTarget,
    required this.onPolygonsDrawn,
  });

  Vec3 project(Vec3 v, double w, double h) {
    double tx = v.x - camTarget.x;
    double ty = v.y - camTarget.y;
    double tz = v.z - camTarget.z;

    double rx = tx * math.cos(camYaw) - tz * math.sin(camYaw);
    double rz = tx * math.sin(camYaw) + tz * math.cos(camYaw);
    double ry = ty;

    double px = rx;
    double py = ry * math.cos(camPitch) - rz * math.sin(camPitch);
    double pz = ry * math.sin(camPitch) + rz * math.cos(camPitch);

    pz += camDist;
    double fov = 400.0;
    if (pz <= 0.1) pz = 0.1;

    double sx = (px / pz) * fov + w / 2;
    double sy = -(py / pz) * fov + h / 2;

    return Vec3(sx, sy, pz);
  }

  Vec3 applyBlockTransform(Vec3 v, Block b) {
    double x = v.x, y = v.y, z = v.z;

    // Rotate block
    double rx = x, ry = y, rz = z;
    if (b.rot.x != 0 || b.rot.y != 0 || b.rot.z != 0) {
      // X
      double t = ry * math.cos(b.rot.x) - rz * math.sin(b.rot.x);
      rz = ry * math.sin(b.rot.x) + rz * math.cos(b.rot.x);
      ry = t;
      // Y
      t = rx * math.cos(b.rot.y) + rz * math.sin(b.rot.y);
      rz = -rx * math.sin(b.rot.y) + rz * math.cos(b.rot.y);
      rx = t;
      // Z
      t = rx * math.cos(b.rot.z) - ry * math.sin(b.rot.z);
      ry = rx * math.sin(b.rot.z) + ry * math.cos(b.rot.z);
      rx = t;
    }

    // Translate block
    return Vec3(rx + b.pos.x, ry + b.pos.y, rz + b.pos.z);
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<Face> facesToDraw = [];

    // 1. Grid Base
    for (int i = -5; i <= 5; i++) {
      facesToDraw.add(
        Face(
          [Vec3(i.toDouble(), -0.25, -5), Vec3(i.toDouble(), -0.25, 5)],
          const Color(0xFF334155),
          isWireframe: true,
        ),
      );
      facesToDraw.add(
        Face(
          [Vec3(-5, -0.25, i.toDouble()), Vec3(5, -0.25, i.toDouble())],
          const Color(0xFF334155),
          isWireframe: true,
        ),
      );
    }

    // 2. Blocks
    for (var b in pieces) {
      double hw = b.w / 2;
      double hh = b.h / 2;
      double hd = b.d / 2;

      // Local corners
      Vec3 c0 = Vec3(-hw, -hh, hd); // front bot left
      Vec3 c1 = Vec3(hw, -hh, hd); // front bot right
      Vec3 c2 = Vec3(hw, hh, hd); // front top right
      Vec3 c3 = Vec3(-hw, hh, hd); // front top left
      Vec3 c4 = Vec3(-hw, -hh, -hd); // back bot left
      Vec3 c5 = Vec3(hw, -hh, -hd); // back bot right
      Vec3 c6 = Vec3(hw, hh, -hd); // back top right
      Vec3 c7 = Vec3(-hw, hh, -hd); // back top left

      // Transform corners to world
      List<Vec3> wc = [
        c0,
        c1,
        c2,
        c3,
        c4,
        c5,
        c6,
        c7,
      ].map((c) => applyBlockTransform(c, b)).toList();

      // Add 6 faces
      Color darken(Color c, double amt) => Color.fromARGB(
        255,
        (c.red * amt).toInt(),
        (c.green * amt).toInt(),
        (c.blue * amt).toInt(),
      );

      facesToDraw.add(
        Face([wc[0], wc[1], wc[2], wc[3]], b.color, parentBlock: b),
      ); // Front
      facesToDraw.add(
        Face(
          [wc[5], wc[4], wc[7], wc[6]],
          darken(b.color, 0.8),
          parentBlock: b,
        ),
      ); // Back
      facesToDraw.add(
        Face(
          [wc[3], wc[2], wc[6], wc[7]],
          darken(b.color, 1.2),
          parentBlock: b,
        ),
      ); // Top
      facesToDraw.add(
        Face(
          [wc[4], wc[5], wc[1], wc[0]],
          darken(b.color, 0.6),
          parentBlock: b,
        ),
      ); // Bottom
      facesToDraw.add(
        Face(
          [wc[1], wc[5], wc[6], wc[2]],
          darken(b.color, 0.9),
          parentBlock: b,
        ),
      ); // Right
      facesToDraw.add(
        Face(
          [wc[4], wc[0], wc[3], wc[7]],
          darken(b.color, 0.9),
          parentBlock: b,
        ),
      ); // Left
    }

    // 3. Project to 2D & calculate depth
    for (var f in facesToDraw) {
      double sumZ = 0;
      for (int i = 0; i < f.vertices.length; i++) {
        f.vertices[i] = project(f.vertices[i], size.width, size.height);
        sumZ += f.vertices[i].z;
      }
      f.avgZ = sumZ / f.vertices.length;
    }

    // 4. Sort faces by depth (Painter's Algorithm - furthest first)
    facesToDraw.sort((a, b) => b.avgZ.compareTo(a.avgZ));

    // 5. Draw
    List<DrawnPolygon> drawnBlocks = [];
    final paintFill = Paint()..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var f in facesToDraw) {
      if (f.avgZ < 0) continue; // Behind camera

      Path path = Path();
      path.moveTo(f.vertices[0].x, f.vertices[0].y);
      for (int i = 1; i < f.vertices.length; i++) {
        path.lineTo(f.vertices[i].x, f.vertices[i].y);
      }
      if (!f.isWireframe) path.close();

      if (f.isWireframe) {
        paintStroke.color = f.color;
        canvas.drawPath(path, paintStroke);
      } else {
        // Backface culling (simple 2D normal check for convex faces)
        double crossProd =
            (f.vertices[1].x - f.vertices[0].x) *
                (f.vertices[2].y - f.vertices[1].y) -
            (f.vertices[1].y - f.vertices[0].y) *
                (f.vertices[2].x - f.vertices[1].x);

        if (crossProd > 0) {
          paintFill.color = f.color;
          canvas.drawPath(path, paintFill);

          paintStroke.color = Colors.white.withOpacity(0.3);
          canvas.drawPath(path, paintStroke);

          if (f.parentBlock != null) {
            drawnBlocks.add(DrawnPolygon(path, f.parentBlock!));
          }
        }
      }
    }

    // Callback to update interaction hit areas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onPolygonsDrawn(drawnBlocks);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
