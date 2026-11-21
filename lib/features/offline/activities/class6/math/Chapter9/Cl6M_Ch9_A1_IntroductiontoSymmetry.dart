// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Cl6M_Ch9_A1_IntroductiontoSymmetry());
}

class Cl6M_Ch9_A1_IntroductiontoSymmetry extends StatefulWidget {
  const Cl6M_Ch9_A1_IntroductiontoSymmetry({super.key});

  @override
  State<Cl6M_Ch9_A1_IntroductiontoSymmetry> createState() =>
      _Cl6M_Ch9_A1_IntroductiontoSymmetryState();
}

// --- DATA ENTITIES ---

class Splat {
  final double x;
  final double y;
  final double r;
  final Color c;
  Splat({required this.x, required this.y, required this.r, required this.c});
}

class AppState extends ChangeNotifier {
  String lang = 'en';
  List<String> langs = ['en', 'hi'];

  int scenario = 1;
  int step = 0;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  bool animating = false;

  // Scenario 1
  String s1Shape = 'butterfly';
  double s1LineX = 150.0;
  bool s1DragLine = false;
  double s1Folded = 0.0; // 0.0 to 1.0

  // Scenario 2
  List<Splat> s2Splats = [];
  Color s2Color = const Color(0xFF6366F1);
  double s2Folded = 0.0; // 0.0 to 2.0

  // Scenario 3
  int s3FoldLevel = 0;
  bool s3IsCut = false;
  int s3UnfoldLevel = 0;
  bool s3DragCut = false;

  // Scenario 4
  int s4LinesFound = 0;
  Map<String, bool> s4PlacedLines = {
    'v': false,
    'h': false,
    'd1': false,
    'd2': false,
  };
  String? s4ActiveDrag;

  // Scenario 5
  double s5Angle = 0.0;
  List<int> s5FoundAngles = [];
  bool s5DragBlade = false;

  double activeDragX = 0.0;
  double activeDragY = 0.0;

  void toggleLanguage() {
    int idx = langs.indexOf(lang);
    lang = langs[(idx + 1) % langs.length];
    notifyListeners();
  }

  void reset() {
    zoom = 1.0;
    panX = 0.0;
    panY = 0.0;
    loadScenario(1);
  }

  void loadScenario(int id) {
    scenario = id;
    step = 0;
    animating = false;

    if (scenario == 1) {
      s1Shape = 'butterfly';
      s1LineX = 150.0;
      s1Folded = 0.0;
    }
    if (scenario == 2) {
      s2Splats.clear();
      s2Folded = 0.0;
    }
    if (scenario == 3) {
      s3FoldLevel = 0;
      s3IsCut = false;
      s3UnfoldLevel = 0;
      s3DragCut = false;
    }
    if (scenario == 4) {
      s4LinesFound = 0;
      s4PlacedLines = {'v': false, 'h': false, 'd1': false, 'd2': false};
      s4ActiveDrag = null;
    }
    if (scenario == 5) {
      s5Angle = 0.0;
      s5FoundAngles.clear();
      s5DragBlade = false;
    }

    panX = 0;
    panY = 0;
    zoom = 1.0;
    notifyListeners();
  }

  void advanceStep() {
    step++;
    notifyListeners();
  }
}

class _Cl6M_Ch9_A1_IntroductiontoSymmetryState
    extends State<Cl6M_Ch9_A1_IntroductiontoSymmetry>
    with SingleTickerProviderStateMixin {
  final AppState state = AppState();
  late AnimationController _gameLoop;

  final GlobalKey _canvasKey = GlobalKey();

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;

  bool _showSuccessPopup = false;

  bool _isInteractingWithObject = false;
  double _baseZoom = 1.0;

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
      duration: const Duration(days: 365),
    )..addListener(_tick);
    _gameLoop.repeat();

    state.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    state.dispose();
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
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  // --- END AUDIO METHODS ---

  void _tick() {
    if (state.animating) {
      if (state.scenario == 1 && state.s1Folded < 1.0) {
        state.s1Folded += 0.05;
        if (state.s1Folded >= 1.0) {
          state.s1Folded = 1.0;
          state.animating = false;

          if (state.step == 1) {
            state.advanceStep();
            Future.delayed(const Duration(milliseconds: 1000), () {
              state.s1Shape = 'house';
              state.s1Folded = 0;
              state.s1LineX = -150;
            });
          } else if (state.step == 2) {
            state.advanceStep();
            Future.delayed(
              const Duration(milliseconds: 1000),
              _checkScenarioSuccess,
            );
          }
        }
      } else if (state.scenario == 2 && state.s2Folded < 2.0) {
        state.s2Folded += 0.05;
        if (state.s2Folded >= 2.0) {
          state.s2Folded = 2.0;
          state.animating = false;
          if (state.step == 2) state.advanceStep();
          Future.delayed(
            const Duration(milliseconds: 1500),
            _checkScenarioSuccess,
          );
        }
      } else if (state.scenario == 3 && state.s3IsCut && state.step == 2) {
        // Managed via Future.delayed in interaction
      }
      state.notifyListeners();
    }
  }

  void _checkScenarioSuccess() {
    int maxSteps = (state.scenario <= 3) ? 4 : (state.scenario == 4 ? 2 : 3);
    state.step = maxSteps;
    playPageOpen();
    if (state.scenario == 5) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() => _showSuccessPopup = true);
      });
    } else {
      setState(() => _showSuccessPopup = true);
    }
  }

  String t(String key) => Translations.get(state.lang, key);

  void _handleCurtainEnter() {
    curtainScreen();
    setState(() => _showCurtain = false);
  }

  // ---- Interaction Handling ----
  Offset _getWorldCoord(Offset localPos, Size size) {
    return Offset(
      (localPos.dx - (size.width / 2) - state.panX) / state.zoom,
      (localPos.dy - (size.height / 2) - state.panY) / state.zoom,
    );
  }

  bool _hitTestCircle(Offset worldPt, Offset center, double radius) {
    return (worldPt - center).distance <= radius;
  }

  bool _hitTestBox(Offset worldPt, Rect rect) {
    return rect.contains(worldPt);
  }

  void _onPointerDown(PointerDownEvent event) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(event.position);
    final Size size = box.size;
    final worldPt = _getWorldCoord(localPos, size);

    _isInteractingWithObject = false;

    if (state.scenario == 1 && !state.animating && state.s1Folded == 0) {
      if (_hitTestBox(
        worldPt,
        Rect.fromLTWH(state.s1LineX - 30, -230, 60, 460),
      )) {
        state.s1DragLine = true;
        _isInteractingWithObject = true;
      }
    } else if (state.scenario == 2 && !state.animating) {
      if (state.step < 2) {
        final colors = [
          const Color(0xFFEF4444),
          const Color(0xFF3B82F6),
          const Color(0xFF22C55E),
        ];
        for (int i = 0; i < colors.length; i++) {
          if (_hitTestCircle(worldPt, Offset(-250, -160 + i * 60.0), 20)) {
            state.s2Color = colors[i];
            _isInteractingWithObject = true;
            break;
          }
        }
        if (!_isInteractingWithObject &&
            _hitTestBox(worldPt, const Rect.fromLTWH(-200, -250, 200, 500))) {
          state.s2Splats.add(
            Splat(
              x: worldPt.dx,
              y: worldPt.dy,
              r: 15.0 + math.Random().nextDouble() * 15,
              c: state.s2Color,
            ),
          );
          _isInteractingWithObject = true;
          if (state.step == 0) {
            state.advanceStep();
          } else if (state.step == 1 && state.s2Splats.length >= 3) {
            state.advanceStep();
          }
        }
      } else if (state.step == 2) {
        if (_hitTestBox(worldPt, const Rect.fromLTWH(150, -30, 160, 60))) {
          if (!state.animating) {
            state.animating = true;
            _isInteractingWithObject = true;
          }
        }
      }
    } else if (state.scenario == 3 && !state.animating) {
      if (state.step == 0) {
        if (state.s3FoldLevel == 0 &&
            _hitTestBox(worldPt, const Rect.fromLTWH(-100, 200, 200, 50))) {
          state.s3FoldLevel = 1;
          _isInteractingWithObject = true;
        } else if (state.s3FoldLevel == 1 &&
            _hitTestBox(worldPt, const Rect.fromLTWH(50, 200, 200, 50))) {
          state.s3FoldLevel = 2;
          state.advanceStep();
          _isInteractingWithObject = true;
        }
      } else if (state.step == 1 && !state.s3IsCut) {
        state.activeDragX = worldPt.dx;
        state.activeDragY = worldPt.dy;
        state.s3DragCut = true;
        _isInteractingWithObject = true;
      } else if (state.step == 2 && state.s3IsCut) {
        if (_hitTestBox(worldPt, const Rect.fromLTWH(50, 200, 200, 50))) {
          state.animating = true;
          _isInteractingWithObject = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            state.s3UnfoldLevel = 1;
          });
          Future.delayed(const Duration(milliseconds: 800), () {
            state.s3UnfoldLevel = 2;
            state.animating = false;
            state.advanceStep();
            Future.delayed(
              const Duration(milliseconds: 1000),
              _checkScenarioSuccess,
            );
          });
        }
      }
    } else if (state.scenario == 4 && !state.animating) {
      List<Map<String, dynamic>> tools = [
        {
          'id': 'v',
          'pos': const Offset(-150, 280),
          'placed': state.s4PlacedLines['v'],
        },
        {
          'id': 'h',
          'pos': const Offset(-50, 280),
          'placed': state.s4PlacedLines['h'],
        },
        {
          'id': 'd1',
          'pos': const Offset(50, 280),
          'placed': state.s4PlacedLines['d1'],
        },
        {
          'id': 'd2',
          'pos': const Offset(150, 280),
          'placed': state.s4PlacedLines['d2'],
        },
      ];
      for (var t in tools) {
        if (!t['placed'] && _hitTestCircle(worldPt, t['pos'], 30)) {
          state.s4ActiveDrag = t['id'];
          state.activeDragX = worldPt.dx;
          state.activeDragY = worldPt.dy;
          _isInteractingWithObject = true;
          break;
        }
      }
    } else if (state.scenario == 5 && !state.animating) {
      state.s5DragBlade = true;
      _isInteractingWithObject = true;
    }

    if (_isInteractingWithObject) {
      playClick();
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = state.zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Size size = box.size;
    final localPos = box.globalToLocal(details.focalPoint);
    final worldPt = _getWorldCoord(localPos, size);

    if (details.pointerCount >= 2) {
      _isInteractingWithObject = false;
      state.s1DragLine = false;
      state.s3DragCut = false;
      state.s4ActiveDrag = null;
      state.s5DragBlade = false;

      state.zoom = math.max(0.4, math.min(4.0, _baseZoom * details.scale));
      state.panX += details.focalPointDelta.dx;
      state.panY += details.focalPointDelta.dy;
      state.notifyListeners();
      return;
    }

    if (_isInteractingWithObject) {
      if (state.s1DragLine) {
        state.s1LineX = math.max(-200.0, math.min(200.0, worldPt.dx));
        if (state.scenario == 1 &&
            state.step == 0 &&
            (state.s1LineX - 150).abs() > 20) {
          state.advanceStep();
        }
        if (state.s1LineX.abs() < 15) {
          state.s1LineX = 0;
          state.s1DragLine = false;
          if (state.scenario == 1 && state.step == 0) state.advanceStep();
          if (!state.animating) {
            state.animating = true;
          }
        }
      } else if (state.s3DragCut) {
        state.activeDragX = worldPt.dx;
        state.activeDragY = worldPt.dy;
        if (worldPt.dx < 20 && worldPt.dy < 20) {
          state.s3IsCut = true;
          state.s3DragCut = false;
          state.advanceStep();
        }
      } else if (state.s4ActiveDrag != null) {
        state.activeDragX = worldPt.dx;
        state.activeDragY = worldPt.dy;
      } else if (state.s5DragBlade) {
        double oldAngle = state.s5Angle;
        state.s5Angle = math.atan2(worldPt.dy, worldPt.dx);
        if (state.scenario == 5 &&
            state.step == 0 &&
            (state.s5Angle - oldAngle).abs() > 0.05) {
          state.advanceStep();
        }

        double deg = state.s5Angle * (180 / math.pi);
        if (deg < 0) deg += 360;
        List<int> snapAngles = [90, 180, 270, 360];
        for (int snapA in snapAngles) {
          int target = snapA == 360 ? 0 : snapA;
          double diff = (deg - snapA).abs();
          if (diff < 10 || diff > 350) {
            state.s5Angle = target * (math.pi / 180);
            if (!state.s5FoundAngles.contains(snapA)) {
              state.s5FoundAngles.add(snapA);
              if (state.step == 1 && snapA == 90) state.advanceStep();
              if (state.s5FoundAngles.length == 4) {
                state.advanceStep();
                Future.delayed(
                  const Duration(milliseconds: 1000),
                  _checkScenarioSuccess,
                );
              }
            }
          }
        }
      }
      state.notifyListeners();
    } else {
      // Pan canvas
      state.panX += details.focalPointDelta.dx;
      state.panY += details.focalPointDelta.dy;
      state.notifyListeners();
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (state.s4ActiveDrag != null) {
      if (_hitTestCircle(
        Offset(state.activeDragX, state.activeDragY),
        Offset.zero,
        50,
      )) {
        state.s4PlacedLines[state.s4ActiveDrag!] = true;
        state.s4LinesFound++;
        playClick(); // Play positive click upon correct drop
        if (state.step == 0) state.advanceStep();
        if (state.s4LinesFound == 4) {
          state.advanceStep();
          Future.delayed(
            const Duration(milliseconds: 1000),
            _checkScenarioSuccess,
          );
        }
      } else {
        playError(); // Play error thud when dropped in the wrong spot
      }
      state.s4ActiveDrag = null;
    }
    state.s1DragLine = false;
    state.s3DragCut = false;
    state.s5DragBlade = false;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxSidebarWidth = screenSize.width * 0.6;
    final double minSidebarWidth = 300.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Scaffold(
          body: Stack(
            children: [
              // --- Canvas Area ---
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                right: 0,
                left: _sidebarOpen ? _sidebarWidth : 0,
                child: Stack(
                  children: [
                    Container(color: const Color(0xFF0F172A)),
                    Listener(
                      onPointerDown: _onPointerDown,
                      child: GestureDetector(
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onScaleEnd: _onScaleEnd,
                        child: RepaintBoundary(
                          key: _canvasKey,
                          child: CustomPaint(
                            painter: SimulationPainter(state: state),
                            child: Container(),
                          ),
                        ),
                      ),
                    ),

                    // HUD Overlay
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _getHudText().isNotEmpty ? 1.0 : 0.0,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 600),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: const Border(
                                top: BorderSide(color: Colors.indigo, width: 4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Text(
                                    _getHudText(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Success/Next Scenario Popup
                    if (_showSuccessPopup)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Container(
                                width: 400,
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.indigo.withOpacity(0.5),
                                    width: 2,
                                  ),
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
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.flag,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      t('summaryTitle'),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.scenario < 5
                                          ? t('finalDesc')
                                          : t('finalDesc'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: state.scenario < 5
                                            ? Colors.indigo
                                            : Colors.orange,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        state.scenario < 5
                                            ? Icons.arrow_forward
                                            : Icons.refresh,
                                        size: 24,
                                      ),
                                      label: Text(
                                        state.scenario < 5
                                            ? t('nextScenario')
                                            : t('finishLab'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        playPageOpen();
                                        setState(
                                          () => _showSuccessPopup = false,
                                        );
                                        if (state.scenario < 5) {
                                          state.loadScenario(
                                            state.scenario + 1,
                                          );
                                        } else {
                                          state.reset();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // --- Sidebar (Animated Positioned) ---
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: 0,
                left: _sidebarOpen ? 0 : -_sidebarWidth,
                width: _sidebarWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 64,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Activity Icon and Title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.extension,
                                    color: Colors.indigoAccent,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t('appTitle'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t('appSubtitle'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Language Toggle and Reset Button below subtitle
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      playClick();
                                      state.toggleLanguage();
                                    },
                                    icon: const Icon(Icons.language, size: 16),
                                    label: Text(state.lang.toUpperCase()),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      playError(); // Soft thud sound for reset
                                      state.reset();
                                      _showCurtain = true;
                                    },
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Reset'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(
                                        0.2,
                                      ),
                                      foregroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 40, color: Colors.white10),

                              Text(
                                t('selectScenario').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: state.scenario,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    items: [1, 2, 3, 4, 5]
                                        .map(
                                          (id) => DropdownMenuItem(
                                            value: id,
                                            child: Text(
                                              t('s${id}_title'),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        playDropdown();
                                        state.loadScenario(val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.track_changes,
                                          color: Colors.pinkAccent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t('learnLbl'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t('s${state.scenario}_obj'),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.4,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSteps(),

                              const SizedBox(height: 32),
                              // Footer at the bottom of the scroll view
                              const Center(
                                child: Text(
                                  '© ZeroScienceLab | Fall in love with math and Science',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Resizer Handle
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _sidebarWidth += details.delta.dx;
                            _sidebarWidth = math.max(
                              minSidebarWidth,
                              math.min(maxSidebarWidth, _sidebarWidth),
                            );
                          });
                        },
                        child: Container(
                          width: 10,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Floating Menu Button ---
              Positioned(
                top: 16,
                left: 16,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.zero,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF1E293B),
                    child: Icon(
                      _sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      playClick();
                      setState(() => _sidebarOpen = !_sidebarOpen);
                    },
                  ),
                ),
              ),

              // --- Curtain Screen ---
              if (_showCurtain)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_mosaic,
                              size: 80,
                              color: Colors.indigoAccent,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              t('shutterTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 50),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 10,
                                shadowColor: Colors.indigoAccent.withOpacity(
                                  0.5,
                                ),
                              ),
                              icon: const Icon(
                                Icons.play_circle_fill,
                                size: 30,
                              ),
                              label: Text(
                                t('enterLab'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _handleCurtainEnter,
                            ),
                          ],
                        ),
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

  Widget _buildSteps() {
    int maxSteps = (state.scenario <= 3) ? 4 : (state.scenario == 4 ? 2 : 3);
    List<Widget> children = [];

    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < state.step;
      bool isActive = i == state.step;
      bool isFuture = i > state.step;

      Color bgColor = isActive
          ? Colors.indigo.withOpacity(0.1)
          : (isCompleted ? Colors.green.withOpacity(0.05) : Colors.black12);
      Color borderColor = isActive
          ? Colors.indigo.withOpacity(0.5)
          : (isCompleted ? Colors.green.withOpacity(0.3) : Colors.white10);

      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.indigo : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('stepLabel')} ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('s${state.scenario}_step${i + 1}_task'),
                      style: TextStyle(
                        color: isFuture ? Colors.white54 : Colors.white,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          t('s${state.scenario}_step${i + 1}_out'),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: children);
  }

  String _getHudText() {
    int maxSteps = (state.scenario <= 3) ? 4 : (state.scenario == 4 ? 2 : 3);
    if (state.step < maxSteps) {
      return t('s${state.scenario}_hud${state.step + 1}');
    }
    return '';
  }
}

// --- CUSTOM PAINTER ENGINE ---

class SimulationPainter extends CustomPainter {
  final AppState state;
  SimulationPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      _renderS1(canvas);
    } else if (state.scenario == 2)
      _renderS2(canvas);
    else if (state.scenario == 3)
      _renderS3(canvas);
    else if (state.scenario == 4)
      _renderS4(canvas);
    else if (state.scenario == 5)
      _renderS5(canvas);

    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    // 1. Draw Normal Side (Left)
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(-1000, -1000, state.s1LineX, 1000));
    if (state.s1Shape == 'butterfly') {
      _drawButterfly(canvas, state.s1Folded);
    } else {
      _drawHouse(canvas, state.s1Folded);
    }
    canvas.restore();

    // 2. Draw Dimmed Side (Right)
    if (state.s1Folded == 0.0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(state.s1LineX, -1000, 1000, 1000));
      canvas.saveLayer(
        Rect.fromLTRB(-1000, -1000, 1000, 1000),
        Paint()..color = Colors.white.withOpacity(0.4),
      );
      if (state.s1Shape == 'butterfly') {
        _drawButterfly(canvas, 0);
      } else {
        _drawHouse(canvas, 0);
      }
      canvas.restore();
      canvas.restore();
    }

    // Draw Magic Line
    _drawDashedLine(
      canvas,
      Offset(state.s1LineX, -200),
      Offset(state.s1LineX, 200),
      Paint()
        ..color = Colors.lightBlueAccent
        ..strokeWidth = 6,
      [8, 8],
    );

    // Handles
    final handlePaint = Paint()
      ..color = Colors.lightBlue.shade100
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(state.s1LineX, -200), 15, handlePaint);
    canvas.drawCircle(Offset(state.s1LineX, -200), 15, strokePaint);
    canvas.drawCircle(Offset(state.s1LineX, 200), 15, handlePaint);
    canvas.drawCircle(Offset(state.s1LineX, 200), 15, strokePaint);

    _drawText(canvas, "DRAG", Offset(state.s1LineX, 230), Colors.white, 16);
  }

  void _renderS2(Canvas canvas) {
    double pw = 400, ph = 500;

    // Base Paper Left
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(-pw / 2, -ph / 2, pw / 2, ph));
    canvas.drawRect(
      Rect.fromLTWH(-pw / 2, -ph / 2, pw / 2, ph),
      Paint()..color = Colors.white,
    );

    for (var splat in state.s2Splats) {
      final p = Paint()..color = splat.c;
      canvas.drawCircle(Offset(splat.x, splat.y), splat.r, p);
      canvas.drawCircle(Offset(splat.x - 15, splat.y - 20), splat.r * 0.3, p);
      canvas.drawCircle(Offset(splat.x + 20, splat.y + 10), splat.r * 0.4, p);
    }
    canvas.restore();

    // Right Paper Animated
    canvas.save();
    if (state.s2Folded < 1.0) {
      canvas.scale(1.0 - (state.s2Folded * 2), 1.0);
    } else {
      canvas.scale(-1.0 + ((state.s2Folded - 1.0) * 2), 1.0);
    }

    canvas.clipRect(Rect.fromLTWH(0, -ph / 2, pw / 2, ph));
    canvas.drawRect(
      Rect.fromLTWH(0, -ph / 2, pw / 2, ph),
      Paint()..color = const Color(0xFFF1F5F9),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -ph / 2, pw / 2, ph),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (state.s2Folded > 1.0) {
      double opacity = state.s2Folded - 1.0;
      canvas.saveLayer(
        Rect.fromLTWH(0, -ph / 2, pw / 2, ph),
        Paint()..color = Colors.white.withOpacity(opacity),
      );
      for (var splat in state.s2Splats) {
        final p = Paint()..color = splat.c;
        double mirX = splat.x.abs();
        canvas.drawCircle(Offset(mirX, splat.y), splat.r, p);
        canvas.drawCircle(Offset(mirX + 15, splat.y - 20), splat.r * 0.3, p);
        canvas.drawCircle(Offset(mirX - 20, splat.y + 10), splat.r * 0.4, p);
      }
      canvas.restore();
    }
    canvas.restore();

    // Fold Line
    _drawDashedLine(
      canvas,
      Offset(0, -ph / 2),
      Offset(0, ph / 2),
      Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 4,
      [8, 8],
    );

    // UI Tools
    if (state.step < 2) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-280, -200, 60, 200),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF334155),
      );
      final colors = [
        const Color(0xFFEF4444),
        const Color(0xFF3B82F6),
        const Color(0xFF22C55E),
      ];
      for (int i = 0; i < colors.length; i++) {
        Offset cCenter = Offset(-250, -160 + i * 60.0);
        canvas.drawCircle(cCenter, 20, Paint()..color = colors[i]);
        if (state.s2Color == colors[i]) {
          canvas.drawCircle(
            cCenter,
            20,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4,
          );
        }
      }
    }

    if (state.step == 2 && !state.animating) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(150, -30, 160, 60),
          const Radius.circular(30),
        ),
        Paint()..color = const Color(0xFF8B5CF6),
      );
      _drawText(canvas, "Fold & Press", const Offset(230, 0), Colors.white, 18);
    }
  }

  void _renderS3(Canvas canvas) {
    double size = 300;
    final pFill = Paint()..color = Colors.white;
    final pStroke = Paint()
      ..color = Colors.blueGrey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    if (state.s3FoldLevel == 0) {
      canvas.drawRect(Rect.fromLTWH(-size / 2, -size / 2, size, size), pFill);
      canvas.drawRect(Rect.fromLTWH(-size / 2, -size / 2, size, size), pStroke);
      _drawDashedLine(
        canvas,
        Offset(0, -size / 2),
        Offset(0, size / 2),
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 2,
        [8, 8],
      );
    } else if (state.s3FoldLevel == 1) {
      canvas.drawRect(Rect.fromLTWH(0, -size / 2, size / 2, size), pFill);
      canvas.drawRect(Rect.fromLTWH(0, -size / 2, size / 2, size), pStroke);
      _drawDashedLine(
        canvas,
        Offset(0, 0),
        Offset(size / 2, 0),
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 2,
        [8, 8],
      );
    } else if (state.s3FoldLevel == 2 && state.s3UnfoldLevel == 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size / 2, size / 2), pFill);
      canvas.drawRect(Rect.fromLTWH(0, 0, size / 2, size / 2), pStroke);
      if (!state.s3IsCut) {
        _drawDashedLine(
          canvas,
          const Offset(40, 0),
          const Offset(0, 40),
          Paint()
            ..color = Colors.pinkAccent
            ..strokeWidth = 4,
          [6, 6],
        );
        if (state.step == 1) {
          _drawText(
            canvas,
            "Cut Here",
            const Offset(60, 60),
            Colors.pinkAccent,
            16,
          );
        }
      }
    }

    if (state.s3IsCut) {
      Path path = Path();
      if (state.s3UnfoldLevel == 0) {
        path.moveTo(40, 0);
        path.lineTo(size / 2, 0);
        path.lineTo(size / 2, size / 2);
        path.lineTo(0, size / 2);
        path.lineTo(0, 40);
        path.close();
      } else if (state.s3UnfoldLevel == 1) {
        path.moveTo(40, 0);
        path.lineTo(size / 2, 0);
        path.lineTo(size / 2, size / 2);
        path.lineTo(0, size / 2);
        path.lineTo(0, 40);
        path.lineTo(0, -size / 2);
        path.lineTo(size / 2, -size / 2);
        path.lineTo(size / 2, 0);
        path.close();
      } else if (state.s3UnfoldLevel == 2) {
        path.moveTo(40, 0);
        path.lineTo(size / 2, 0);
        path.lineTo(size / 2, size / 2);
        path.lineTo(-size / 2, size / 2);
        path.lineTo(-size / 2, -size / 2);
        path.lineTo(size / 2, -size / 2);
        path.lineTo(size / 2, 0);
        // inner hole
        path.moveTo(40, 0);
        path.lineTo(0, 40);
        path.lineTo(-40, 0);
        path.lineTo(0, -40);
        path.close();
        path.fillType = PathFillType.evenOdd;
      }
      canvas.drawPath(path, pFill);
      canvas.drawPath(path, pStroke);
      if (state.s3UnfoldLevel == 1) {
        _drawDashedLine(
          canvas,
          const Offset(0, 0),
          Offset(size / 2, 0),
          Paint()
            ..color = Colors.grey.shade400
            ..strokeWidth = 2,
          [8, 8],
        );
      }
      if (state.s3UnfoldLevel == 2) {
        _drawDashedLine(
          canvas,
          Offset(0, -size / 2),
          Offset(0, size / 2),
          Paint()
            ..color = Colors.grey.shade400
            ..strokeWidth = 2,
          [8, 8],
        );
        _drawDashedLine(
          canvas,
          Offset(-size / 2, 0),
          Offset(size / 2, 0),
          Paint()
            ..color = Colors.grey.shade400
            ..strokeWidth = 2,
          [8, 8],
        );
      }
    }

    // UI Overlay logic
    if (state.step == 0) {
      if (state.s3FoldLevel == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-100, 200, 200, 50),
            const Radius.circular(25),
          ),
          Paint()..color = Colors.blue,
        );
        _drawText(
          canvas,
          "Fold Vertically",
          const Offset(0, 225),
          Colors.white,
          16,
        );
      } else if (state.s3FoldLevel == 1) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(50, 200, 200, 50),
            const Radius.circular(25),
          ),
          Paint()..color = Colors.blue,
        );
        _drawText(
          canvas,
          "Fold Horizontally",
          const Offset(150, 225),
          Colors.white,
          16,
        );
      }
    } else if (state.step == 2) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(50, 200, 200, 50),
          const Radius.circular(25),
        ),
        Paint()..color = const Color(0xFF8B5CF6),
      );
      _drawText(canvas, "Unfold", const Offset(150, 225), Colors.white, 16);
    }

    if (state.step == 1 && !state.s3IsCut) {
      _drawText(
        canvas,
        "✂️ DRAG TO CUT",
        Offset(
          state.activeDragX == 0 ? 20 : state.activeDragX,
          state.activeDragY == 0 ? 20 : state.activeDragY,
        ),
        Colors.white,
        24,
      );
    }
  }

  void _renderS4(Canvas canvas) {
    _drawRangoli(canvas);

    final pPlaced = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 6;
    if (state.s4PlacedLines['v']!) {
      canvas.drawLine(const Offset(0, -200), const Offset(0, 200), pPlaced);
    }
    if (state.s4PlacedLines['h']!) {
      canvas.drawLine(const Offset(-200, 0), const Offset(200, 0), pPlaced);
    }
    if (state.s4PlacedLines['d1']!) {
      canvas.drawLine(
        const Offset(-150, -150),
        const Offset(150, 150),
        pPlaced,
      );
    }
    if (state.s4PlacedLines['d2']!) {
      canvas.drawLine(
        const Offset(-150, 150),
        const Offset(150, -150),
        pPlaced,
      );
    }

    // Toolbox
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-250, 220, 500, 100),
        const Radius.circular(15),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    _drawText(
      canvas,
      "Lines Found: ${state.s4LinesFound} / 4",
      const Offset(0, 245),
      Colors.white,
      16,
    );

    List<Map<String, dynamic>> tools = [
      {
        'id': 'v',
        'x': -150.0,
        'y': 280.0,
        'r': 0.0,
        'placed': state.s4PlacedLines['v'],
      },
      {
        'id': 'h',
        'x': -50.0,
        'y': 280.0,
        'r': math.pi / 2,
        'placed': state.s4PlacedLines['h'],
      },
      {
        'id': 'd1',
        'x': 50.0,
        'y': 280.0,
        'r': math.pi / 4,
        'placed': state.s4PlacedLines['d1'],
      },
      {
        'id': 'd2',
        'x': 150.0,
        'y': 280.0,
        'r': -math.pi / 4,
        'placed': state.s4PlacedLines['d2'],
      },
    ];

    for (var t in tools) {
      if (!t['placed']) {
        canvas.save();
        canvas.translate(t['x'], t['y']);
        canvas.rotate(t['r']);
        canvas.drawLine(
          const Offset(0, -25),
          const Offset(0, 25),
          Paint()
            ..color = Colors.lightBlueAccent
            ..strokeWidth = 6,
        );
        canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.white);
        canvas.restore();
      }
    }

    if (state.s4ActiveDrag != null) {
      var dragT = tools.firstWhere(
        (element) => element['id'] == state.s4ActiveDrag,
      );
      canvas.save();
      canvas.translate(state.activeDragX, state.activeDragY);
      canvas.rotate(dragT['r']);
      canvas.drawLine(
        const Offset(0, -100),
        const Offset(0, 100),
        Paint()
          ..color = Colors.lightBlueAccent
          ..strokeWidth = 6,
      );
      canvas.restore();
    }
  }

  void _renderS5(Canvas canvas) {
    canvas.saveLayer(
      Rect.fromLTWH(-500, -500, 1000, 1000),
      Paint()..color = Colors.white.withOpacity(0.2),
    );
    _drawWindmill(canvas, 0);
    canvas.restore();

    _drawWindmill(canvas, state.s5Angle);

    int deg = (state.s5Angle * (180 / math.pi)).round();
    if (deg < 0) deg += 360;
    if (deg == 360) deg = 0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, 200, 120, 50),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white,
    );
    _drawText(canvas, "$deg°", const Offset(0, 225), Colors.black87, 24, true);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(200, -100, 160, 200),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    _drawText(
      canvas,
      "Angles Found:",
      const Offset(280, -70),
      Colors.white,
      16,
    );

    List<int> checks = [90, 180, 270, 360];
    for (int i = 0; i < checks.length; i++) {
      bool found = state.s5FoundAngles.contains(checks[i]);
      _drawText(
        canvas,
        "${checks[i]}°",
        Offset(280, -30 + i * 30.0),
        found ? Colors.greenAccent : Colors.white30,
        18,
        true,
      );
    }
  }

  // --- DRAWING PRIMITIVES ---

  void _drawButterfly(Canvas canvas, double foldProgress) {
    canvas.save();

    // Left Wing
    final pWing = Paint()..color = const Color(0xFFF43F5E);
    final pStroke = Paint()
      ..color = const Color(0xFF881337)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    Path leftWing = Path()
      ..moveTo(0, -50)
      ..cubicTo(-150, -150, -200, 0, -50, 20)
      ..cubicTo(-150, 50, -100, 150, 0, 100)
      ..close();
    canvas.drawPath(leftWing, pWing);
    canvas.drawPath(leftWing, pStroke);

    canvas.drawCircle(
      const Offset(-80, -40),
      20,
      Paint()..color = Colors.yellowAccent,
    );
    canvas.drawCircle(
      const Offset(-50, 70),
      15,
      Paint()..color = Colors.yellowAccent,
    );

    // Right Wing
    canvas.save();
    canvas.scale(1 - (foldProgress * 2), 1);
    Path rightWing = Path()
      ..moveTo(0, -50)
      ..cubicTo(150, -150, 200, 0, 50, 20)
      ..cubicTo(150, 50, 100, 150, 0, 100)
      ..close();
    canvas.drawPath(rightWing, pWing);
    canvas.drawPath(rightWing, pStroke);
    canvas.drawCircle(
      const Offset(80, -40),
      20,
      Paint()..color = Colors.yellowAccent,
    );
    canvas.drawCircle(
      const Offset(50, 70),
      15,
      Paint()..color = Colors.yellowAccent,
    );
    canvas.restore();

    // Body
    final pBody = Paint()..color = const Color(0xFF1E293B);
    canvas.drawOval(const Rect.fromLTWH(-15, -60, 30, 160), pBody); // Body
    canvas.drawCircle(const Offset(0, -70), 20, pBody); // Head

    // Antennae
    final pAntenna = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(
      Path()
        ..moveTo(-5, -85)
        ..quadraticBezierTo(-20, -120, -40, -100),
      pAntenna,
    );
    canvas.drawPath(
      Path()
        ..moveTo(5, -85)
        ..quadraticBezierTo(20, -120, 40, -100),
      pAntenna,
    );

    canvas.restore();
  }

  void _drawHouse(Canvas canvas, double foldProgress) {
    canvas.save();

    final pFill = Paint()..color = const Color(0xFFCBD5E1);
    final pStroke = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final pWin = Paint()..color = const Color(0xFF38BDF8);

    // Left Side
    Path leftSide = Path()
      ..moveTo(0, -50)
      ..lineTo(-120, 50)
      ..lineTo(-100, 50)
      ..lineTo(-100, 150)
      ..lineTo(0, 150)
      ..close();
    canvas.drawPath(leftSide, pFill);
    canvas.drawPath(leftSide, pStroke);
    canvas.drawRect(const Rect.fromLTWH(-70, 70, 40, 40), pWin);
    canvas.drawRect(const Rect.fromLTWH(-70, 70, 40, 40), pStroke);

    // Right Side
    canvas.save();
    canvas.scale(1 - (foldProgress * 2), 1);
    Path rightSide = Path()
      ..moveTo(0, -50)
      ..lineTo(120, 50)
      ..lineTo(100, 50)
      ..lineTo(100, 150)
      ..lineTo(0, 150)
      ..close();
    canvas.drawPath(rightSide, pFill);
    canvas.drawPath(rightSide, pStroke);
    canvas.drawRect(const Rect.fromLTWH(30, 70, 40, 40), pWin);
    canvas.drawRect(const Rect.fromLTWH(30, 70, 40, 40), pStroke);
    canvas.restore();

    // Door
    final pDoor = Paint()..color = const Color(0xFFB45309);
    canvas.drawRect(const Rect.fromLTWH(-25, 100, 25, 50), pDoor);
    canvas.drawRect(const Rect.fromLTWH(-25, 100, 25, 50), pStroke);
    canvas.save();
    canvas.scale(1 - (foldProgress * 2), 1);
    canvas.drawRect(const Rect.fromLTWH(0, 100, 25, 50), pDoor);
    canvas.drawRect(const Rect.fromLTWH(0, 100, 25, 50), pStroke);
    canvas.restore();

    canvas.restore();
  }

  void _drawRangoli(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 150, Paint()..color = Colors.yellowAccent);
    canvas.drawCircle(
      Offset.zero,
      150,
      Paint()
        ..color = Colors.brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 4);
      Paint p = Paint()
        ..color = i % 2 == 0 ? Colors.pinkAccent : Colors.lightBlueAccent;
      Path petal = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(50, -50, 0, -140)
        ..quadraticBezierTo(-50, -50, 0, 0);
      canvas.drawPath(petal, p);
      canvas.drawPath(
        petal,
        Paint()
          ..color = Colors.brown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 40, Paint()..color = Colors.green);
    canvas.drawCircle(
      Offset.zero,
      40,
      Paint()
        ..color = Colors.brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawWindmill(Canvas canvas, double angle) {
    canvas.save();
    canvas.rotate(angle);
    List<Color> colors = [
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.yellowAccent,
      Colors.green,
    ];
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 2);
      Path blade = Path()
        ..moveTo(0, 0)
        ..lineTo(-40, -120)
        ..lineTo(40, -120)
        ..close();
      canvas.drawPath(blade, Paint()..color = colors[i]);
      canvas.drawPath(
        blade,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 15, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset.zero,
      15,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    double fontSize, [
    bool monospace = false,
  ]) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: monospace ? 'monospace' : 'Plus Jakarta Sans',
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    List<double> dashArray,
  ) {
    double distance = (p2 - p1).distance;
    double dashLen = dashArray[0];
    double gapLen = dashArray[1];
    double step = dashLen + gapLen;
    Offset dir = (p2 - p1) / distance;
    for (double i = 0; i < distance; i += step) {
      double end = math.min(i + dashLen, distance);
      canvas.drawLine(p1 + dir * i, p1 + dir * end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) => true;
}

// --- TRANSLATIONS (I18N) ---

class Translations {
  static final Map<String, Map<String, String>> _dict = {
    'en': {
      'shutterTitle': "Introduction to Symmetry and Pattern Recognition",
      'appTitle': "Introduction to Symmetry",
      'appSubtitle': "Class 6 • GEOMETRY",
      'enterLab': "Enter Simulation",
      'settings': "Settings",
      'selectScenario': "Select Scenario",
      'stepLabel': "STEP",
      'learnLbl': "Objective / Learning:",
      'summaryTitle': "Goal Reached!",
      'finishLab': "Finish Lab",
      'nextScenario': "Next Scenario",
      'finalDesc':
          "You have successfully explored line and rotational symmetry using interactive models!",

      's1_title': "1. The Magic Mirror Line",
      's1_obj':
          "To understand the concept of a line of symmetry by finding the 'mirror line' that perfectly divides a shape into two identical halves.",
      's1_step1_task':
          "DRAG the glowing vertical line left and right across the butterfly.",
      's1_step1_out':
          "The line divides the space. One side is clear, the other is dimmed.",
      's1_step2_task':
          "Position the line EXACTLY in the middle of the butterfly's body.",
      's1_step2_out':
          "It snaps! The wings fold perfectly, showing line symmetry.",
      's1_step3_task': "Now, DRAG the line to find the symmetry of the house.",
      's1_step3_out': "The vertical line perfectly divides the house.",
      's1_step4_task': "Observe the result.",
      's1_step4_out':
          "A line of symmetry means folding creates a perfect mirror image.",
      's1_hud1': "Drag the line across the butterfly.",
      's1_hud2': "Find the exact center.",
      's1_hud3': "Find the symmetry line for the house.",
      's1_hud4': "Observe line symmetry.",

      's2_title': "2. The Inkblot Creator",
      's2_obj':
          "To create a symmetrical figure and understand that the fold line becomes the line of symmetry.",
      's2_step1_task':
          "CLICK a color, then CLICK anywhere on the LEFT half of the paper to drop an ink splat.",
      's2_step1_out': "An ink splat appears on the left.",
      's2_step2_task': "Add TWO MORE ink splats to the left side.",
      's2_step2_out': "You have created a unique pattern on one half.",
      's2_step3_task': "CLICK the 'Fold & Press' button.",
      's2_step3_out': "The paper folds, mirroring the ink.",
      's2_step4_task': "Observe the unfolded result.",
      's2_step4_out':
          "The fold line is the line of symmetry. The left and right are mirror images.",
      's2_hud1': "Click a color, then click the left side.",
      's2_hud2': "Add two more splats.",
      's2_hud3': "Click Fold & Press.",
      's2_hud4': "Observe the symmetrical inkblot.",

      's3_title': "3. The Perfect Cut",
      's3_obj':
          "To discover how folding and cutting can create complex shapes with multiple lines of symmetry.",
      's3_step1_task':
          "CLICK 'Fold Vertically', then CLICK 'Fold Horizontally'.",
      's3_step1_out':
          "The paper is folded into a small square (one-quarter size).",
      's3_step2_task':
          "DRAG the scissors along the dotted line at the corner to cut it.",
      's3_step2_out': "The corner is cut off.",
      's3_step3_task': "CLICK the 'Unfold' button to see your creation.",
      's3_step3_out': "The paper unfolds to reveal a shape in the center.",
      's3_step4_task': "Observe the lines of symmetry.",
      's3_step4_out':
          "One cut created a shape with TWO lines of symmetry (the fold lines).",
      's3_hud1': "Click the Fold buttons.",
      's3_hud2': "Drag scissors along the dotted line.",
      's3_hud3': "Click Unfold.",
      's3_hud4': "Observe multiple lines of symmetry.",

      's4_title': "4. The Rangoli Puzzle",
      's4_obj':
          "To apply the concept of line symmetry to identify all lines of symmetry in a complex pattern.",
      's4_step1_task':
          "DRAG the line tools from the bottom onto the Rangoli to find axes of symmetry.",
      's4_step1_out': "You found the first line of symmetry.",
      's4_step2_task':
          "Find ALL 4 lines of symmetry (Vertical, Horizontal, 2 Diagonals).",
      's4_step2_out':
          "You correctly placed all 4 lines! The Rangoli is highly symmetrical.",
      's4_hud1': "Drag line tools onto the center.",
      's4_hud2': "Find all 4 lines.",

      's5_title': "5. The Windmill Spinner",
      's5_obj':
          "To discover and identify angles of rotational symmetry by rotating an object.",
      's5_step1_task': "DRAG the handle on the pinwheel to rotate it.",
      's5_step1_out': "The pinwheel spins freely.",
      's5_step2_task':
          "Spin until the pinwheel perfectly matches its ghost image at 90°.",
      's5_step2_out': "It snaps into place at 90°.",
      's5_step3_task': "Keep rotating to find ALL angles (180°, 270°, 360°).",
      's5_step3_out': "You found all angles! This is Rotational Symmetry.",
      's5_hud1': "Drag the blade handle to spin.",
      's5_hud2': "Match the ghost image at 90°.",
      's5_hud3': "Find all 4 matching angles.",
    },
    'hi': {
      'shutterTitle': "सममिति और पैटर्न की पहचान",
      'appTitle': "सममिति का परिचय",
      'appSubtitle': "कक्षा 6 • ज्यामिति",
      'enterLab': "सिमुलेशन दर्ज करें",
      'settings': "सेटिंग्स",
      'selectScenario': "परिदृश्य चुनें",
      'stepLabel': "चरण",
      'learnLbl': "उद्देश्य:",
      'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'finishLab': "समाप्त करें",
      'nextScenario': "अगला परिदृश्य",
      'finalDesc':
          "आपने इंटरैक्टिव मॉडल का उपयोग करके सममिति का सफलतापूर्वक पता लगाया है!",

      's1_title': "1. मैजिक मिरर लाइन",
      's1_obj':
          "एक आकार को दो समान हिस्सों में विभाजित करने वाली 'दर्पण रेखा' को खोजकर सममिति रेखा को समझना।",
      's1_step1_task': "तितली के पार चमकती रेखा को बाएँ और दाएँ खींचें।",
      's1_step1_out':
          "रेखा स्थान को विभाजित करती है। एक तरफ स्पष्ट है, दूसरी तरफ धुंधली है।",
      's1_step2_task': "तितली के शरीर के बिल्कुल बीच में रेखा रखें।",
      's1_step2_out': "पंख पूरी तरह से मुड़ जाते हैं, जो सममिति दिखाता है।",
      's1_step3_task': "अब, घर की सममिति खोजने के लिए रेखा को खींचें।",
      's1_step3_out': "ऊर्ध्वाधर रेखा घर को पूरी तरह से विभाजित करती है।",
      's1_step4_task': "परिणाम देखें।",
      's1_step4_out':
          "सममिति रेखा का मतलब है कि मोड़ने पर एक आदर्श दर्पण छवि बनती है।",
      's1_hud1': "तितली पर रेखा खींचें।",
      's1_hud2': "बिल्कुल केंद्र खोजें।",
      's1_hud3': "घर के लिए सममिति रेखा खोजें।",
      's1_hud4': "सममिति का निरीक्षण करें।",

      's2_title': "2. इंकब्लॉट निर्माता",
      's2_obj':
          "एक सममित आकृति बनाना और यह समझना कि तह रेखा सममिति रेखा बन जाती है।",
      's2_step1_task': "रंग चुनें, फिर बाईं ओर इंक गिराएं।",
      's2_step1_out': "बाईं ओर एक स्याही का धब्बा दिखाई देता है।",
      's2_step2_task': "बाईं ओर दो और इंक गिराएं।",
      's2_step2_out': "आपने एक अनूठा पैटर्न बनाया है।",
      's2_step3_task': "'फ़ोल्ड और प्रेस' बटन पर क्लिक करें।",
      's2_step3_out': "कागज मुड़ता है और इंक को प्रतिबिंबित करता है।",
      's2_step4_task': "परिणाम देखें।",
      's2_step4_out': "तह रेखा सममिति रेखा है। दायां और बायां दर्पण चित्र हैं।",
      's2_hud1': "रंग चुनें, फिर बाईं ओर क्लिक करें।",
      's2_hud2': "दो और धब्बे जोड़ें।",
      's2_hud3': "फ़ोल्ड और प्रेस पर क्लिक करें।",
      's2_hud4': "सममित धब्बे का निरीक्षण करें।",

      's3_title': "3. सही कट",
      's3_obj':
          "यह खोजना कि कागज मोड़ने और काटने से कई सममिति रेखाओं वाली आकृतियां कैसे बनती हैं।",
      's3_step1_task':
          "'ऊर्ध्वाधर मोड़ें' पर क्लिक करें, फिर 'क्षैतिज मोड़ें' पर क्लिक करें।",
      's3_step1_out': "कागज एक छोटे वर्ग में मुड़ा है।",
      's3_step2_task': "कोने को काटने के लिए बिंदीदार रेखा पर कैंची खींचें।",
      's3_step2_out': "कोना कट गया है।",
      's3_step3_task': "कागज खोलने के लिए 'अनफोल्ड' पर क्लिक करें।",
      's3_step3_out': "कागज केंद्र में एक आकृति दिखाता है।",
      's3_step4_task': "सममिति रेखाएं देखें।",
      's3_step4_out': "एक कट ने दो सममिति रेखाओं वाली आकृति बनाई।",
      's3_hud1': "मोड़ने वाले बटन पर क्लिक करें।",
      's3_hud2': "बिंदीदार रेखा पर कैंची खींचें।",
      's3_hud3': "अनफोल्ड पर क्लिक करें।",
      's3_hud4': "कई सममिति रेखाएं देखें।",

      's4_title': "4. रंगोली पहेली",
      's4_obj':
          "जटिल पैटर्न में सममिति की सभी रेखाओं को पहचानने के लिए सममिति की अवधारणा लागू करना।",
      's4_step1_task': "नीचे से रंगोली पर रेखा उपकरणों को खींचें।",
      's4_step1_out': "आपको पहली सममिति रेखा मिली।",
      's4_step2_task':
          "सभी 4 सममिति रेखाएं खोजें (ऊर्ध्वाधर, क्षैतिज, 2 विकर्ण)।",
      's4_step2_out': "आपने सभी 4 रेखाएं सही ढंग से रखीं!",
      's4_hud1': "रेखा उपकरणों को केंद्र में खींचें।",
      's4_hud2': "सभी 4 रेखाएं खोजें।",

      's5_title': "5. पवनचक्की स्पिनर",
      's5_obj':
          "किसी वस्तु को घुमाकर घूर्णी सममिति के कोणों की खोज और पहचान करना।",
      's5_step1_task': "घुमाने के लिए हैंडल खींचें।",
      's5_step1_out': "पवनचक्की घूमती है।",
      's5_step2_task': "90° पर भूत छवि से मेल खाने तक घुमाएं।",
      's5_step2_out': "यह 90° पर स्नैप होता है।",
      's5_step3_task':
          "सभी कोणों (180°, 270°, 360°) को खोजने के लिए घुमाते रहें।",
      's5_step3_out': "आपको सभी कोण मिल गए! यह घूर्णी सममिति है।",
      's5_hud1': "घुमाने के लिए ब्लेड हैंडल को खींचें।",
      's5_hud2': "90° వద్ద నీడతో సరిపోల్చండి.",
      's5_hud3': "सभी 4 कोण खोजें।",
    },
  };

  static String get(String lang, String key) {
    if (_dict.containsKey(lang) && _dict[lang]!.containsKey(key)) {
      return _dict[lang]![key]!;
    }
    return _dict['en']![key] ?? key;
  }
}
