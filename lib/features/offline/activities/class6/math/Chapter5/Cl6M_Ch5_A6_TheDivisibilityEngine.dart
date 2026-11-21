// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    runApp(
      MaterialApp(
        title: 'The Divisibility Engine',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6366F1),
            secondary: Color(0xFF10B981),
            surface: Color(0xFF1E293B),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans'),
          ),
        ),
        home: const Cl6M_Ch5_A6_TheDivisibilityEngine(),
      ),
    );
  });
}

class Cl6M_Ch5_A6_TheDivisibilityEngine extends StatefulWidget {
  const Cl6M_Ch5_A6_TheDivisibilityEngine({super.key});

  @override
  State<Cl6M_Ch5_A6_TheDivisibilityEngine> createState() =>
      _Cl6M_Ch5_A6_TheDivisibilityEngineState();
}

class _Cl6M_Ch5_A6_TheDivisibilityEngineState
    extends State<Cl6M_Ch5_A6_TheDivisibilityEngine>
    with TickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // App & Sidebar State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';

  // Game/Simulation State
  final EngineState _state = EngineState();

  // Animation & Rendering Loop
  late Ticker _gameLoopTicker;
  DateTime _lastTick = DateTime.now();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Replaces requestAnimationFrame to drive the game loop
    _gameLoopTicker = createTicker((elapsed) {
      _updateAnimations();
      setState(() {}); // Trigger render
    });
    _gameLoopTicker.start();

    _loadScenario(1);
  }

  @override
  void dispose() {
    _gameLoopTicker.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();

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
  // ---------------------

  void _updateAnimations() {
    if (!_state.animating) return;

    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    if (_state.animDuration > 0) {
      _state.animProgress += dt / _state.animDuration;
      if (_state.animProgress >= 1.0) {
        _state.animProgress = 1.0;
        _state.animating = false;
        _onAnimationComplete();
      }
    }
  }

  void _startAnimation(double duration) {
    _state.animating = true;
    _state.animProgress = 0.0;
    _state.animDuration = duration;
    _lastTick = DateTime.now();
  }

  void _onAnimationComplete() {
    if (_state.scenario == 1) {
      if (_state.s1AnimObj?['type'] == 'accept') {
        playPageOpen(); // Block sorted successfully
        _state.s1Sorted.add({
          'num': _state.s1Blocks[_state.s1Index],
          'machine': _state.s1AnimObj!['targetX'] == -150.0 ? 10 : 5,
        });
        _state.s1Index++;
      } else {
        playError(); // Block rejected by machine
        if (_state.s1Blocks[_state.s1Index] == 72 &&
            _state.s1AnimObj?['targetX'] == 150.0) {
          _state.s1Index++;
        }
      }

      if (_state.step == 0 && _state.s1Index == 1) _advanceStep();
      if (_state.step == 1 &&
          _state.s1Blocks[_state.s1Index] == 72 &&
          _state.s1AnimObj?['targetX'] == -150.0) {
        _advanceStep();
      }
      if (_state.step == 1 && _state.s1Index > 1) _advanceStep();
      if (_state.step == 2 && _state.s1Index >= 5) {
        _advanceStep();
        _checkScenarioSuccess();
      }
      _state.s1AnimObj = null;
    } else if (_state.scenario == 2) {
      if (_state.s2Blocks[_state.s2Index] % 2 == 0) {
        playPageOpen();
      } else {
        playError();
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _state.s2Index++;
          if (_state.step == 0 && _state.s2Index == 1) _advanceStep();
          if (_state.step == 1 && _state.s2Index == 2) _advanceStep();
          if (_state.step == 2 && _state.s2Index >= 4) {
            _advanceStep();
            _checkScenarioSuccess();
          }
        });
      });
    } else if (_state.scenario == 3) {
      if (_state.s3Blocks[_state.s3Index] % 4 == 0) {
        playPageOpen();
      } else {
        playError();
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _state.s3Index++;
          if (_state.step == 0 && _state.s3Index == 1) _advanceStep();
          if (_state.step == 1 && _state.s3Index == 2) _advanceStep();
          if (_state.step == 2 && _state.s3Index >= 4) {
            _advanceStep();
            _checkScenarioSuccess();
          }
        });
      });
    } else if (_state.scenario == 4) {
      if (_state.s4AnimStatus == 'success') {
        _state.s4Index++;
        _state.s4Toggles = {2: false, 4: false, 5: false, 10: false};
        if (_state.s4Index <= 3) _advanceStep();
        if (_state.s4Index >= 4) _checkScenarioSuccess();
      }
    }
  }

  void _advanceStep() {
    _state.step++;
  }

  void _checkScenarioSuccess() {
    final conf = _getScenarioConfig(_state.scenario);
    _state.step = conf['steps'].length;
    if (_state.scenario == 5) {
      _state.labCompleted = true;
    }
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _state.scenario = id;
      _state.step = 0;
      _state.animating = false;
      _state.labCompleted = false;

      _state.s1Index = 0;
      _state.s1Sorted.clear();
      _state.s1AnimObj = null;

      _state.s2Index = 0;
      _state.s3Index = 0;

      _state.s4Index = 0;
      _state.s4Toggles = {2: false, 4: false, 5: false, 10: false};

      _state.s5Inputs = ["", "", ""];
      _state.s5ActiveSlot = 0;
      _state.s5Unlocked = false;

      _toolFitScreen();
    });
  }

  void _toolFitScreen() {
    _state.zoom = 1.0;
    _state.panX = 0;
    _state.panY = 0;
  }

  void _handleReset() {
    setState(() {
      _showCurtain = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _loadScenario(1);
    });
  }

  Offset _getCanvasFocalPoint(Offset globalFocalPoint) {
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalFocalPoint);
  }

  Offset _screenToWorld(Offset screenPt) {
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    double cx = renderBox.size.width / 2;
    double cy = renderBox.size.height / 2;
    double worldX = (screenPt.dx - cx - _state.panX) / _state.zoom;
    double worldY = (screenPt.dy - cy - _state.panY) / _state.zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _onTapDown(TapDownDetails details) {
    if (_state.animating) return;
    Offset localFocal = _getCanvasFocalPoint(details.globalPosition);
    Offset worldPt = _screenToWorld(localFocal);

    if (_state.scenario == 2) {
      if (_hitTestBox(-70, 180, 140, 50, worldPt)) {
        _triggerAction('s2_activate');
      }
    } else if (_state.scenario == 4) {
      if (_hitTestBox(-60, 50, 120, 50, worldPt)) {
        _triggerAction('s4_send');
      } else if (_hitTestBox(-240, -190, 80, 80, worldPt)) {
        _triggerAction('s4_toggle', 2);
      } else if (_hitTestBox(160, -190, 80, 80, worldPt)) {
        _triggerAction('s4_toggle', 4);
      } else if (_hitTestBox(-240, 110, 80, 80, worldPt)) {
        _triggerAction('s4_toggle', 5);
      } else if (_hitTestBox(160, 110, 80, 80, worldPt)) {
        _triggerAction('s4_toggle', 10);
      }
    } else if (_state.scenario == 5) {
      if (!_state.s5Unlocked) {
        double rx = 100, ry = -200, kx = rx + 40, ky = ry + 310;
        List<String> keys = [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          'C',
          '0',
          'E',
        ];
        for (int i = 0; i < keys.length; i++) {
          int col = i % 3;
          int row = i ~/ 3;
          if (_hitTestBox(kx + col * 70, ky + row * 40, 60, 30, worldPt)) {
            _triggerAction('s5_key', keys[i]);
            break;
          }
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_state.animating) return;
    Offset localFocal = _getCanvasFocalPoint(details.focalPoint);
    Offset worldPt = _screenToWorld(localFocal);

    _state.lastPanFocal = localFocal;
    _state.baseZoom = _state.zoom;

    if (details.pointerCount >= 2) {
      _state.isPanning = true;
    } else {
      bool objectHit = false;

      if (_state.scenario == 1) {
        if (_state.s1Index < _state.s1Blocks.length) {
          if (_hitTestBox(-385, 95, 70, 70, worldPt)) {
            playClick();
            _state.activeDragEntity = 's1_block';
            _state.dragX = worldPt.dx;
            _state.dragY = worldPt.dy;
            objectHit = true;
          }
        }
      } else if (_state.scenario == 3) {
        if (_state.s3Index < _state.s3Blocks.length) {
          if (_hitTestBox(-435, 15, 70, 70, worldPt)) {
            playClick();
            _state.activeDragEntity = 's3_block';
            _state.dragX = worldPt.dx;
            _state.dragY = worldPt.dy;
            objectHit = true;
          }
        }
      }

      if (!objectHit) {
        _state.isPanning = true;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_state.activeDragEntity != null) {
      Offset localFocal = _getCanvasFocalPoint(details.focalPoint);
      Offset worldPt = _screenToWorld(localFocal);
      _state.dragX = worldPt.dx;
      _state.dragY = worldPt.dy;
    } else if (_state.isPanning) {
      Offset localFocal = _getCanvasFocalPoint(details.focalPoint);
      Offset delta = localFocal - _state.lastPanFocal;
      _state.panX += delta.dx;
      _state.panY += delta.dy;
      _state.lastPanFocal = localFocal;

      if (details.scale != 1.0) {
        _state.zoom = (_state.baseZoom * details.scale).clamp(0.4, 3.0);
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _state.isPanning = false;

    if (_state.activeDragEntity != null) {
      Offset dropPt = Offset(_state.dragX, _state.dragY);

      if (_state.activeDragEntity == 's1_block') {
        int num = _state.s1Blocks[_state.s1Index];
        bool dropped10 = _hitTestBox(-230, -170, 160, 200, dropPt);
        bool dropped5 = _hitTestBox(70, -170, 160, 200, dropPt);

        if (dropped10 || dropped5) {
          playClick();
          double targetX = dropped10 ? -150 : 150;
          String type = '';
          if (dropped10) {
            type = num % 10 == 0 ? 'accept' : 'reject10';
          } else {
            type = num % 5 == 0 ? 'accept' : 'reject5';
          }

          _state.s1AnimObj = {
            'block': num,
            'startX': _state.dragX,
            'startY': _state.dragY,
            'targetX': targetX,
            'targetY': -30.0,
            'type': type,
          };
          _startAnimation(0.5);
        } else {
          playError();
        }
      } else if (_state.activeDragEntity == 's3_block') {
        if (_hitTestBox(-300, -50, 600, 200, dropPt)) {
          playClick();
          _startAnimation(2.5);
        } else {
          playError();
        }
      }
      _state.activeDragEntity = null;
    }
  }

  void _triggerAction(String action, [dynamic param]) {
    if (_state.animating) return;

    if (action == 's2_activate') {
      playClick();
      _startAnimation(2.5);
    } else if (action == 's4_toggle') {
      playClick();
      _state.s4Toggles[param] = !_state.s4Toggles[param]!;
    } else if (action == 's4_send') {
      int num = _state.s4Blocks[_state.s4Index];
      bool correct =
          _state.s4Toggles[2] == (num % 2 == 0) &&
          _state.s4Toggles[4] == (num % 4 == 0) &&
          _state.s4Toggles[5] == (num % 5 == 0) &&
          _state.s4Toggles[10] == (num % 10 == 0);

      _state.s4AnimStatus = correct ? 'success' : 'error';
      if (correct) {
        playPageOpen();
      } else {
        playError();
      }
      _startAnimation(0.5);
    } else if (action == 's5_key') {
      if (_state.s5Unlocked) return;
      int slot = _state.s5ActiveSlot;
      String p = param.toString();

      if (p == 'C') {
        playClick();
        _state.s5Inputs[slot] = "";
        return;
      }
      if (p == 'E') {
        String val = _state.s5Inputs[slot];
        bool isValid = false;
        if (slot == 0) {
          if (val.length == 4 && val.endsWith('5')) isValid = true;
        } else if (slot == 1) {
          if (val.length == 2 &&
              int.tryParse(val) != null &&
              int.parse(val) % 4 == 0) {
            isValid = true;
          }
        } else if (slot == 2) {
          if (val.length == 4 &&
              int.tryParse(val) != null &&
              int.parse(val) % 2 == 0) {
            isValid = true;
          }
        }

        if (isValid) {
          playPageOpen();
          _state.s5ActiveSlot++;
          if (_state.scenario == 5 && _state.s5ActiveSlot <= 2) _advanceStep();
          if (_state.s5ActiveSlot > 2) {
            _state.s5Unlocked = true;
            _advanceStep();
            Future.delayed(
              const Duration(milliseconds: 1000),
              _checkScenarioSuccess,
            );
          }
        } else {
          playError();
          _state.s5Inputs[slot] = "";
        }
        return;
      }

      playClick();
      int limit = (slot == 1) ? 2 : 4;
      if (_state.s5Inputs[slot].length < limit) {
        _state.s5Inputs[slot] += p;
      }
    }
  }

  String t(String key) {
    return _translations[_lang]?[key] ?? key;
  }

  Map<String, dynamic> _getScenarioConfig(int id) {
    int numSteps = (id == 5) ? 3 : 4;
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${id}_hud$i'),
        'task': t('s${id}_step${i}_task'),
        'outcome': t('s${id}_step${i}_out'),
      });
    }
    return {
      'title': t('s${id}_title'),
      'objective': t('s${id}_obj'),
      'steps': steps,
    };
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarActualWidth = min(
      screenWidth * 0.6,
      max(250.0, _sidebarWidth),
    );

    // Using GestureDetector prevents gesture stealing and reliably keeps immersive mode
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? sidebarActualWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: ClipRect(
                    child: CustomPaint(
                      key: _canvasKey,
                      painter: EnginePainter(
                        state: _state,
                        lang: _lang,
                        translations: _translations,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ),

            // HUD (FLEXIBLE)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _sidebarOpen ? sidebarActualWidth : 0,
              right: 0,
              bottom: 40,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      (_state.step <
                              _getScenarioConfig(
                                _state.scenario,
                              )['steps'].length &&
                          !_showCurtain)
                      ? 1.0
                      : 0.0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xF00F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6366F1), width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF818CF8),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _state.step <
                                      _getScenarioConfig(
                                        _state.scenario,
                                      )['steps'].length
                                  ? _getScenarioConfig(
                                      _state.scenario,
                                    )['steps'][_state.step]['hud']
                                  : '',
                              style: const TextStyle(
                                fontSize: 16,
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
              ),
            ),

            // SUCCESS HUD & NEXT BUTTON
            if (_state.step >=
                    _getScenarioConfig(_state.scenario)['steps'].length &&
                !_showCurtain &&
                !_state.labCompleted)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _sidebarOpen ? sidebarActualWidth : 0,
                right: 24,
                bottom: 24,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      playClick();
                      if (_state.scenario < 5) {
                        _loadScenario(_state.scenario + 1);
                      }
                    },
                    icon: const Text(''), // Workaround to put icon on right
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t('nextScenario'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

            // LAB COMPLETED POPUP
            if (_state.labCompleted)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flag_circle,
                            color: Color(0xFF10B981),
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              playClick();
                              _handleReset();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
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
              ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _sidebarOpen ? 0 : -sidebarActualWidth,
              top: 0,
              bottom: 0,
              width: sidebarActualWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xEE1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Entirely scrollable Sidebar Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 60,
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Icon + Titles
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.alt_route,
                                    color: Color(0xFF6366F1),
                                    size: 30,
                                  ),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t('appSubtitle'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white54,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Controls: Language Toggle and Reset Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white12,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      playClick();
                                      setState(
                                        () =>
                                            _lang = _lang == 'en' ? 'en' : 'hi',
                                      );
                                    },
                                    icon: const Icon(Icons.translate, size: 18),
                                    label: Text(
                                      _lang == 'en' ? 'EN' : 'HI',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(
                                        color: Colors.white12,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      playClick();
                                      _handleReset();
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Divider(color: Colors.white12, height: 1),
                            ),

                            Text(
                              t('selectScenario').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF0F172A),
                                  value: _state.scenario,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onChanged: (val) {
                                    if (val != null && val != _state.scenario) {
                                      playDropdown();
                                      _loadScenario(val);
                                    }
                                  },
                                  items: [1, 2, 3, 4, 5]
                                      .map(
                                        (id) => DropdownMenuItem(
                                          value: id,
                                          child: Text(t('s${id}_title')),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location,
                                        color: Color(0xFFF43F5E),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('learnLbl'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getScenarioConfig(
                                      _state.scenario,
                                    )['objective'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ..._buildSteps(),
                          ],
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: const Color(0xFF020617),
                      child: const Text(
                        '© ZeroScienceLab | Fall in Love with Math and Science',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SIDEBAR RESIZER HANDLE
            if (_sidebarOpen)
              Positioned(
                left: sidebarActualWidth - 10,
                top: 60,
                bottom: 0,
                width: 20,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sidebarWidth += details.delta.dx;
                      _sidebarWidth = max(
                        250.0,
                        min(_sidebarWidth, screenWidth * 0.6),
                      );
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // MENU BUTTON (Fixed Top Left)
            Positioned(
              left: 10,
              top: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 4,
                child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  playClick();
                  setState(() => _sidebarOpen = !_sidebarOpen);
                },
              ),
            ),

            // CURTAIN SCREEN
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF6366F1),
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.sort,
                                  size: 60,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                t('shutterTitle'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('appSubtitle'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white54,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 48),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 10,
                                ),
                                onPressed: () {
                                  curtainScreen();
                                  setState(() => _showCurtain = false);
                                },
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                label: Text(
                                  t('enterLab'),
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    final conf = _getScenarioConfig(_state.scenario);
    List<dynamic> steps = conf['steps'];
    List<Widget> widgets = [];

    for (int i = 0; i < steps.length; i++) {
      bool isPast = i < _state.step;
      bool isCurrent = i == _state.step && _state.step < steps.length;
      bool isFuture = i > _state.step;

      Color bgColor = isCurrent
          ? const Color(0x336366F1)
          : (isPast ? const Color(0x1110B981) : const Color(0x11FFFFFF));
      Color borderColor = isCurrent
          ? const Color(0xFF6366F1)
          : (isPast ? const Color(0xFF10B981) : Colors.transparent);

      widgets.add(
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
              isPast
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 28,
                    )
                  : Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF6366F1)
                            : Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i]['task'],
                      style: TextStyle(
                        color: isFuture ? Colors.white38 : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x2210B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          steps[i]['outcome'],
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}

// --- STATE MANAGER ---
class EngineState {
  int scenario = 1;
  int step = 0;

  double zoom = 1.0;
  double baseZoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;
  bool isPanning = false;
  Offset lastPanFocal = Offset.zero;

  bool animating = false;
  double animProgress = 0.0;
  double animDuration = 1.0;
  bool labCompleted = false;

  String? activeDragEntity;
  double dragX = 0;
  double dragY = 0;

  // S1
  List<int> s1Blocks = [40, 72, 65, 90, 115];
  int s1Index = 0;
  List<Map<String, dynamic>> s1Sorted = [];
  Map<String, dynamic>? s1AnimObj;

  // S2
  List<int> s2Blocks = [14, 27, 38, 59];
  int s2Index = 0;

  // S3
  List<int> s3Blocks = [324, 518, 936, 250];
  int s3Index = 0;

  // S4
  List<int> s4Blocks = [70, 88, 125, 340];
  int s4Index = 0;
  Map<int, bool> s4Toggles = {2: false, 4: false, 5: false, 10: false};
  String s4AnimStatus = '';

  // S5
  List<String> s5Inputs = ["", "", ""];
  int s5ActiveSlot = 0;
  bool s5Unlocked = false;
}

// --- CUSTOM PAINTER ---
class EnginePainter extends CustomPainter {
  final EngineState state;
  final String lang;
  final Map<String, Map<String, String>> translations;

  EnginePainter({
    required this.state,
    required this.lang,
    required this.translations,
  });

  String t(String key) => translations[lang]?[key] ?? key;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    if (state.scenario == 1) {
      _renderScenario1(canvas);
    } else if (state.scenario == 2) {
      _renderScenario2(canvas);
    } else if (state.scenario == 3) {
      _renderScenario3(canvas);
    } else if (state.scenario == 4) {
      _renderScenario4(canvas);
    } else if (state.scenario == 5) {
      _renderScenario5(canvas);
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill, [
    Color stroke = Colors.transparent,
    double strokeWidth = 0,
  ]) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && strokeWidth > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    FontWeight weight = FontWeight.bold,
    String family = 'monospace',
    TextAlign align = TextAlign.center,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: weight,
        fontFamily: family,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    textPainter.layout();
    double dx = align == TextAlign.center ? x - textPainter.width / 2 : x;
    double dy = y - textPainter.height / 2;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width,
  ) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawNumberBlock(
    Canvas canvas,
    double x,
    double y,
    int num, [
    bool isDragging = false,
  ]) {
    canvas.save();
    canvas.translate(x, y);
    if (isDragging) {
      canvas.scale(1.1, 1.1);
      // Shadow approximation
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-35, -25, 70, 70),
          const Radius.circular(8),
        ),
        Paint()
          ..color = Colors.black45
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    _drawRoundedRect(
      canvas,
      -35,
      -35,
      70,
      70,
      8,
      const Color(0xFFF59E0B),
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(canvas, -28, -28, 56, 56, 4, const Color(0xFFFBBF24));
    _drawText(canvas, num.toString(), 0, 0, 32, const Color(0xFF0F172A));
    canvas.restore();
  }

  void _drawConveyorBelt(Canvas canvas, double x, double y, double width) {
    _drawRoundedRect(
      canvas,
      x,
      y - 20,
      width,
      40,
      20,
      const Color(0xFF475569),
      const Color(0xFF0F172A),
      4,
    );
    _drawRoundedRect(
      canvas,
      x + 15,
      y - 10,
      width - 30,
      20,
      10,
      const Color(0xFF1E293B),
    );
    for (double i = 30; i < width - 20; i += 40) {
      canvas.drawCircle(
        Offset(x + i, y),
        6,
        Paint()..color = const Color(0xFF94A3B8),
      );
    }
  }

  void _drawSorterMachine(Canvas canvas, double x, double y, int type) {
    Color color = type == 10
        ? const Color(0xFF3B82F6)
        : const Color(0xFF10B981);
    String title = type == 10 ? '10-SORTER' : '5-SORTER';

    _drawRoundedRect(
      canvas,
      x - 80,
      y - 120,
      160,
      200,
      16,
      color,
      const Color(0xFF0F172A),
      5,
    );
    _drawRoundedRect(
      canvas,
      x - 70,
      y - 110,
      140,
      40,
      8,
      const Color(0xFF0F172A),
    );
    _drawText(canvas, title, x, y - 90, 18, Colors.white, family: 'sans-serif');

    if (type == 10) {
      _drawRoundedRect(
        canvas,
        x - 25,
        y - 30,
        50,
        70,
        25,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, '0', x, y + 5, 40, const Color(0xFF475569));
    } else {
      _drawRoundedRect(
        canvas,
        x - 50,
        y - 30,
        40,
        60,
        20,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, '0', x - 30, y, 30, const Color(0xFF475569));
      _drawRoundedRect(
        canvas,
        x + 10,
        y - 30,
        40,
        60,
        20,
        const Color(0xFF1E293B),
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, '5', x + 30, y, 30, const Color(0xFF475569));
    }
  }

  void _renderScenario1(Canvas canvas) {
    _drawConveyorBelt(canvas, -400, 150, 800);

    if (state.animating && state.s1AnimObj?['type'] == 'reject10') {
      double p = state.animProgress;
      if ((p * 10).floor() % 2 == 0) {
        // Red flash for 10
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-230, -170, 160, 200),
            const Radius.circular(16),
          ),
          Paint()
            ..color = Colors.red
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 20),
        );
      }
    }

    _drawSorterMachine(canvas, -150, -50, 10);
    _drawSorterMachine(canvas, 150, -50, 5);

    // Bins
    _drawRoundedRect(
      canvas,
      -200,
      80,
      100,
      60,
      10,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(
      canvas,
      100,
      80,
      100,
      60,
      10,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      3,
    );

    int count10 = 0, count5 = 0;
    for (var item in state.s1Sorted) {
      double bx = item['machine'] == 10 ? -150 : 150;
      double by = 110 - ((item['machine'] == 10 ? count10++ : count5++) * 12);
      canvas.save();
      canvas.translate(bx, by);
      canvas.scale(0.6, 0.6);
      _drawNumberBlock(canvas, 0, 0, item['num']);
      canvas.restore();
    }

    if (state.s1Index < state.s1Blocks.length) {
      int num = state.s1Blocks[state.s1Index];
      if (!state.animating && state.activeDragEntity != 's1_block') {
        _drawNumberBlock(canvas, -350, 130, num);
      }
    }

    if (state.activeDragEntity == 's1_block') {
      _drawNumberBlock(
        canvas,
        state.dragX,
        state.dragY,
        state.s1Blocks[state.s1Index],
        true,
      );
    }

    if (state.animating && state.s1AnimObj != null) {
      var a = state.s1AnimObj!;
      double t = state.animProgress;
      double cx = a['startX'] + (a['targetX'] - a['startX']) * t;
      double cy = a['startY'] + (a['targetY'] - a['startY']) * t;
      _drawNumberBlock(canvas, cx, cy, a['block']);
    }
  }

  void _renderScenario2(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -250,
      -150,
      500,
      300,
      20,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      5,
    );
    _drawRoundedRect(canvas, -230, -130, 460, 260, 15, const Color(0xFF1E293B));
    _drawText(
      canvas,
      "PAIRING MACHINE",
      0,
      -160,
      24,
      Colors.white,
      family: 'sans-serif',
    );

    if (state.s2Index < state.s2Blocks.length) {
      int num = state.s2Blocks[state.s2Index];
      if (!state.animating) {
        _drawNumberBlock(canvas, 0, 0, num);
        _drawRoundedRect(
          canvas,
          -70,
          180,
          140,
          50,
          25,
          const Color(0xFF3B82F6),
          const Color(0xFF0F172A),
          4,
        );
        _drawText(
          canvas,
          "ACTIVATE",
          0,
          205,
          18,
          Colors.white,
          family: 'sans-serif',
        );
      } else {
        double p = state.animProgress;
        if (p < 0.2) {
          _drawNumberBlock(canvas, 0, 0, num);
          // White flash
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-40, -40, 80, 80),
              const Radius.circular(10),
            ),
            Paint()..color = Colors.white.withOpacity(p / 0.2),
          );
        } else {
          double t = (p - 0.2) / 0.8;
          int pairs = num ~/ 2;
          int leftover = num % 2;

          int totalSlots = pairs + leftover;
          int slotsPerRow = 14;
          int totalRows = (totalSlots / slotsPerRow).ceil();

          for (int i = 0; i < num; i++) {
            bool isLeftover = (i == num - 1 && leftover == 1);
            int slotIndex = isLeftover ? pairs : i ~/ 2;
            int orbInPair = isLeftover ? 1 : i % 2;

            int r = slotIndex ~/ slotsPerRow;
            int c = slotIndex % slotsPerRow;

            int slotsInThisRow = min(totalSlots - r * slotsPerRow, slotsPerRow);
            double rowWidth = slotsInThisRow * 30.0;

            double targetX = -rowWidth / 2 + c * 30.0 + 15;
            double rowStartY = -(totalRows * 50) / 2 + 25 + r * 50.0;
            double targetY =
                rowStartY + (isLeftover ? 0 : (orbInPair == 0 ? -14 : 14));

            double cx = 0 + (targetX - 0) * t;
            double cy = 0 + (targetY - 0) * t;

            Color orbColor = isLeftover ? Colors.redAccent : Colors.blueAccent;
            canvas.drawCircle(Offset(cx, cy), 10, Paint()..color = orbColor);
            canvas.drawCircle(
              Offset(cx, cy),
              10,
              Paint()
                ..color = const Color(0xFF0F172A)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2,
            );
          }
        }
      }
    }
  }

  void _renderScenario3(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -300,
      -50,
      600,
      200,
      20,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      5,
    );
    _drawText(
      canvas,
      "QUAD-PACKAGING MACHINE",
      0,
      -80,
      24,
      Colors.white,
      family: 'sans-serif',
    );

    if (state.s3Index < state.s3Blocks.length) {
      int num = state.s3Blocks[state.s3Index];
      if (state.activeDragEntity == 's3_block') {
        _drawNumberBlock(canvas, state.dragX, state.dragY, num, true);
      } else if (!state.animating) {
        _drawNumberBlock(canvas, -400, 50, num);
      }

      if (state.animating) {
        double p = state.animProgress;
        if (p < 0.3) {
          double cx = -400 + (400) * (p / 0.3);
          _drawNumberBlock(canvas, cx, 50, num);
        } else if (p < 0.6) {
          _drawNumberBlock(canvas, 0, 50, num);
          double lp = (p - 0.3) / 0.3;
          _drawLine(
            canvas,
            100,
            -100 + (150 * lp),
            150,
            -150 + (200 * lp),
            const Color(0xFF94A3B8),
            6,
          );
          canvas.drawCircle(
            const Offset(30, 50),
            45,
            Paint()..color = Colors.white.withOpacity(0.4),
          );
          canvas.drawCircle(
            const Offset(30, 50),
            45,
            Paint()
              ..color = const Color(0xFF94A3B8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6,
          );
        } else {
          int lastTwo = num % 100;
          int groups = lastTwo ~/ 4;
          double animT = (p - 0.6) / 0.4;

          for (int i = 0; i < lastTwo; i++) {
            int g = i ~/ 4;
            int idx = i % 4;
            int col = g % 6;
            int row = g ~/ 6;

            double gx = -250 + col * 80.0;
            double gy = -20 + row * 80.0;

            bool isLeftover = (i >= groups * 4);
            if (isLeftover) {
              gx = 200 + (i - groups * 4) * 20.0;
              gy = 100;
            } else {
              gx += (idx % 2) * 20;
              gy += (idx ~/ 2) * 20;
            }

            double cx = 30 + (gx - 30) * animT;
            double cy = 50 + (gy - 50) * animT;

            Color color = isLeftover ? Colors.redAccent : Colors.amberAccent;
            _drawRoundedRect(
              canvas,
              cx,
              cy,
              18,
              18,
              2,
              color,
              const Color(0xFF0F172A),
              2,
            );
          }
        }
      }
    }
  }

  void _drawGate(Canvas canvas, double x, double y, int num, bool isActive) {
    Color color = isActive ? const Color(0xFF22C55E) : const Color(0xFF64748B);
    _drawRoundedRect(
      canvas,
      x - 40,
      y - 40,
      80,
      80,
      40,
      color,
      const Color(0xFF0F172A),
      4,
    );
    _drawRoundedRect(
      canvas,
      x - 30,
      y - 30,
      60,
      60,
      30,
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      num.toString(),
      x,
      y + 2,
      24,
      Colors.white,
      family: 'sans-serif',
    );
  }

  void _renderScenario4(Canvas canvas) {
    _drawGate(canvas, -200, -150, 2, state.s4Toggles[2]!);
    _drawGate(canvas, 200, -150, 4, state.s4Toggles[4]!);
    _drawGate(canvas, -200, 150, 5, state.s4Toggles[5]!);
    _drawGate(canvas, 200, 150, 10, state.s4Toggles[10]!);

    if (state.s4Index < state.s4Blocks.length) {
      int num = state.s4Blocks[state.s4Index];
      if (state.animating) {
        double p = state.animProgress;
        if (state.s4AnimStatus == 'success') {
          canvas.saveLayer(
            null,
            Paint()..color = Colors.white.withOpacity(1 - p),
          );
          _drawNumberBlock(canvas, 0, -50, num);
          canvas.restore();

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-50, -100, 100, 100),
              const Radius.circular(50),
            ),
            Paint()
              ..color = Colors.green
              ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 20),
          );
        } else {
          double offset = sin(p * pi * 10) * 10;
          _drawNumberBlock(canvas, offset, -50, num);
        }
      } else {
        _drawNumberBlock(canvas, 0, -50, num);
        _drawRoundedRect(
          canvas,
          -60,
          50,
          120,
          50,
          8,
          const Color(0xFF3B82F6),
          const Color(0xFF0F172A),
          3,
        );
        _drawText(
          canvas,
          t('s4_send'),
          0,
          75,
          18,
          Colors.white,
          family: 'sans-serif',
        );
      }
    }
  }

  void _renderScenario5(Canvas canvas) {
    canvas.save();
    canvas.translate(-250, 0);
    if (state.s5Unlocked) {
      canvas.scale(1.05, 1.05);
      canvas.translate(-20, 0);
    }

    canvas.drawCircle(
      const Offset(0, 0),
      250,
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawCircle(
      const Offset(0, 0),
      250,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawCircle(
      const Offset(0, 0),
      200,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * pi / 4 + (state.s5Unlocked ? pi / 4 : 0));
      _drawLine(canvas, -150, 0, 150, 0, const Color(0xFF94A3B8), 15);
      canvas.restore();
    }
    canvas.drawCircle(
      const Offset(0, 0),
      50,
      Paint()..color = const Color(0xFF1E293B),
    );

    if (state.s5Unlocked) {
      _drawRoundedRect(
        canvas,
        -100,
        -30,
        200,
        60,
        10,
        const Color(0xFF22C55E),
        const Color(0xFF0F172A),
        4,
      );
      _drawText(
        canvas,
        t('s5_unlocked'),
        0,
        0,
        18,
        Colors.white,
        family: 'sans-serif',
      );
    }
    canvas.restore();

    double rx = 100, ry = -200;
    _drawRoundedRect(
      canvas,
      rx,
      ry,
      350,
      400,
      10,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      5,
    );
    _drawRoundedRect(
      canvas,
      rx + 20,
      ry + 20,
      310,
      120,
      5,
      const Color(0xFF020617),
      const Color(0xFF38BDF8),
      2,
    );
    _drawText(
      canvas,
      t('s5_clues'),
      rx + 175,
      ry + 40,
      16,
      const Color(0xFF38BDF8),
      family: 'sans-serif',
    );

    List<String> clues = [t('s5_c1'), t('s5_c2'), t('s5_c3')];
    for (int i = 0; i < clues.length; i++) {
      Color color = (state.s5ActiveSlot > i)
          ? const Color(0xFF4ADE80)
          : (state.s5ActiveSlot == i
                ? const Color(0xFFFACC15)
                : const Color(0xFF475569));
      _drawText(
        canvas,
        clues[i],
        rx + 175,
        ry + 70 + i * 22,
        13,
        color,
        family: 'sans-serif',
      );
    }

    for (int i = 0; i < 3; i++) {
      double sy = ry + 160 + i * 40.0;
      Color color = (state.s5ActiveSlot > i)
          ? const Color(0xFF22C55E)
          : (state.s5ActiveSlot == i
                ? const Color(0xFFFACC15)
                : const Color(0xFF334155));
      _drawRoundedRect(
        canvas,
        rx + 20,
        sy,
        310,
        30,
        4,
        color,
        const Color(0xFF0F172A),
        2,
      );
      String text = state.s5Inputs[i].isEmpty ? "_" : state.s5Inputs[i];
      _drawText(canvas, text, rx + 175, sy + 15, 18, const Color(0xFF0F172A));
    }

    if (!state.s5Unlocked) {
      double kx = rx + 40, ky = ry + 310;
      List<String> keys = [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'C',
        '0',
        'E',
      ];
      for (int i = 0; i < keys.length; i++) {
        int col = i % 3;
        int row = i ~/ 3;
        Color color = keys[i] == 'C'
            ? const Color(0xFFEF4444)
            : (keys[i] == 'E'
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFCBD5E1));
        _drawRoundedRect(
          canvas,
          kx + col * 70,
          ky + row * 40,
          60,
          30,
          4,
          color,
          const Color(0xFF0F172A),
          2,
        );
        _drawText(
          canvas,
          keys[i],
          kx + col * 70 + 30,
          ky + row * 40 + 15,
          16,
          const Color(0xFF0F172A),
          family: 'sans-serif',
        );
      }
    }
  }

  @override
  bool shouldRepaint(EnginePainter oldDelegate) => true; // Game loop running
}

// --- TRANSLATIONS MAP ---
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "The Divisibility Engine: A Sorting Factory Adventure",
    'appTitle': "The Divisibility Engine",
    'appSubtitle': "Class 6 • DISCOVERING DIVISIBILITY RULES",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Mission:",
    'summaryTitle': "Goal Reached!",
    'nextScenario': "Next Scenario",
    'finishLab': "Finish Lab",
    'finalDesc':
        "You have successfully explored divisibility rules in the factory!",

    's1_title': "1. The Last Digit Sorter",
    's1_obj':
        "Visually discover the divisibility rules for 10 and 5 by observing which numbers are successfully sorted by checking only the final digit.",
    's1_step1_task':
        "DRAG the Number Block '40' and DROP it onto the '10-Sorter' machine.",
    's1_step1_out':
        "The machine accepts '40'. The last digit '0' perfectly matches the slot.",
    's1_step2_task':
        "DRAG the Number Block '72' and DROP it onto the '10-Sorter' machine.",
    's1_step2_out':
        "The machine rejects '72'. Its last digit '2' cannot pass through the '0' slot.",
    's1_step3_task':
        "Test the remaining blocks (65, 90, 115) with the '10-Sorter'. Then, drag any rejected blocks to the '5-Sorter'.",
    's1_step3_out':
        "The '5-Sorter' accepts 65 and 115 (ends in 5), but still rejects 72.",
    's1_step4_task': "Observe the summary.",
    's1_step4_out':
        "Learning: A number is divisible by 10 if it ends in 0. It is divisible by 5 if it ends in 0 or 5.",
    's1_hud1': "Drag block '40' to the 10-Sorter.",
    's1_hud2': "Drag block '72' to the 10-Sorter.",
    's1_hud3': "Sort all blocks into 10-Sorter or 5-Sorter.",
    's1_hud4': "Observe the divisibility rules for 5 and 10.",

    's2_title': "2. The Pairing Machine",
    's2_obj':
        "Understand the divisibility rule for 2 by physically pairing up units that represent different numbers.",
    's2_step1_task': "TAP the 'Activate' button for Block '14'.",
    's2_step1_out':
        "14 orbs form 7 perfect pairs with no leftovers. It is divisible by 2.",
    's2_step2_task': "TAP the 'Activate' button for Block '27'.",
    's2_step2_out':
        "27 orbs form pairs, but 1 is left over. It is NOT divisible by 2.",
    's2_step3_task': "Test the remaining blocks (38, 59) by tapping Activate.",
    's2_step3_out':
        "Even ending numbers pair perfectly. Odd ending numbers have leftovers.",
    's2_step4_task': "Observe the summary.",
    's2_step4_out':
        "Learning: A number is divisible by 2 if its last digit is even (0, 2, 4, 6, 8).",
    's2_hud1': "Tap Activate to test number 14.",
    's2_hud2': "Tap Activate to test number 27.",
    's2_hud3': "Test blocks 38 and 59.",
    's2_hud4': "Observe the divisibility rule for 2.",

    's3_title': "3. Quad-Packaging Machine",
    's3_obj':
        "Discover the divisibility rule for 4 by observing a machine that only inspects the number formed by the last two digits.",
    's3_step1_task':
        "DRAG the Number Block '324' onto the Quad-Packaging Machine.",
    's3_step1_out':
        "The lens focuses on '24'. 24 cubes are perfectly packaged into 6 groups of 4. Divisible by 4!",
    's3_step2_task': "DRAG the Number Block '518' onto the machine.",
    's3_step2_out':
        "The lens focuses on '18'. 18 cubes leave 2 leftovers. NOT divisible by 4.",
    's3_step3_task': "Test the blocks '936' and '250'.",
    's3_step3_out':
        "936 is accepted ('36' is div by 4). 250 is rejected ('50' is not div by 4).",
    's3_step4_task': "Observe the summary.",
    's3_step4_out':
        "Learning: A number is divisible by 4 if the number formed by its last two digits is divisible by 4.",
    's3_hud1': "Drag block 324 to the machine.",
    's3_hud2': "Drag block 518 to the machine.",
    's3_hud3': "Test blocks 936 and 250.",
    's3_hud4': "Observe the divisibility rule for 4.",

    's4_title': "4. Factory Foreman's Challenge",
    's4_obj':
        "Apply the learned divisibility rules for 2, 4, 5, and 10 to correctly sort a mixed batch of Number Blocks.",
    's4_step1_task':
        "Analyze block '70'. Tap the correct gates (2,4,5,10) it is divisible by, then tap SEND.",
    's4_step1_out': "70 is divisible by 2, 5, and 10.",
    's4_step2_task': "Sort block '88'.",
    's4_step2_out': "88 is divisible by 2 and 4.",
    's4_step3_task': "Sort block '125'.",
    's4_step3_out': "125 is divisible by 5 only.",
    's4_step4_task': "Sort block '340'.",
    's4_step4_out': "340 is divisible by 2, 4, 5, and 10. Great job!",
    's4_hud1': "Toggle correct gates for 70, then SEND.",
    's4_hud2': "Toggle correct gates for 88, then SEND.",
    's4_hud3': "Toggle correct gates for 125, then SEND.",
    's4_hud4': "Toggle correct gates for 340, then SEND.",
    's4_send': "SEND",

    's5_title': "5. The Code Breaker",
    's5_obj':
        "Use divisibility rules as logical constraints to deduce a sequence to open a vault.",
    's5_step1_task':
        "Read Clue 1: 'A 4-digit number divisible by 5, but NOT 10'. Enter any valid number using the keypad.",
    's5_step1_out': "Accepted! The number must end in exactly 5.",
    's5_step2_task':
        "Read Clue 2: 'A 2-digit number divisible by 4'. Enter any valid number.",
    's5_step2_out': "Accepted! E.g., 24, 36, etc.",
    's5_step3_task':
        "Read Clue 3: 'A 4-digit number divisible by 2'. Enter any valid number.",
    's5_step3_out':
        "Accepted! The number must end in an even digit. Vault unlocked!",
    's5_hud1': "Type a 4-digit number ending in 5.",
    's5_hud2': "Type a 2-digit multiple of 4.",
    's5_hud3': "Type any 4-digit even number.",
    's5_clues': "VAULT CLUES",
    's5_c1': "1: 4-digit, div by 5, NOT 10",
    's5_c2': "2: 2-digit, div by 4",
    's5_c3': "3: 4-digit, div by 2 (Even)",
    's5_unlocked': "VAULT UNLOCKED",
  },
  'hi': {
    'shutterTitle': "विभाज्यता इंजन: छँटाई कारखाने का रोमांच",
    'appTitle': "विभाज्यता इंजन",
    'appSubtitle': "कक्षा 6 • विभाज्यता नियमों की खोज",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "मिशन:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'nextScenario': "अगला परिदृश्य",
    'finishLab': "समाप्त करें",
    'finalDesc':
        "आपने कारखाने में विभाज्यता नियमों का सफलतापूर्वक पता लगाया है!",

    's1_title': "1. अंतिम अंक सॉर्टर",
    's1_obj':
        "केवल अंतिम अंक की जाँच करके 10 और 5 के विभाज्यता नियमों की खोज करें।",
    's1_step1_task': "ब्लॉक '40' को खींचें और '10-Sorter' पर छोड़ें।",
    's1_step1_out': "मशीन '40' को स्वीकार करती है। अंतिम अंक '0' है।",
    's1_step2_task': "ब्लॉक '72' को खींचें और '10-Sorter' पर छोड़ें।",
    's1_step2_out': "मशीन '72' को अस्वीकार करती है। अंतिम अंक '2' है।",
    's1_step3_task':
        "शेष ब्लॉकों का परीक्षण करें और अस्वीकृत ब्लॉकों को '5-Sorter' पर डालें।",
    's1_step3_out': "5-Sorter 65 और 115 को स्वीकार करता है, लेकिन 72 को नहीं।",
    's1_step4_task': "सारांश देखें।",
    's1_step4_out':
        "सीख: यदि अंतिम अंक 0 है तो वह 10 से विभाज्य है। यदि 0 या 5 है तो 5 से।",
    's1_hud1': "ब्लॉक 40 को 10-Sorter पर खींचें।",
    's1_hud2': "ब्लॉक 72 को 10-Sorter पर खींचें।",
    's1_hud3': "सभी ब्लॉकों को सॉर्ट करें।",
    's1_hud4': "नियमों का निरीक्षण करें।",

    's2_title': "2. पेयरिंग मशीन",
    's2_obj':
        "विभिन्न संख्याओं का प्रतिनिधित्व करने वाली इकाइयों को जोड़कर 2 के लिए विभाज्यता नियम को समझें।",
    's2_step1_task': "ब्लॉक '14' के लिए 'एक्टिवेट' बटन पर टैप करें।",
    's2_step1_out': "14 से 7 पूर्ण जोड़े बनते हैं। यह 2 से विभाज्य है।",
    's2_step2_task': "ब्लॉक '27' के लिए 'एक्टिवेट' पर टैप करें।",
    's2_step2_out': "27 जोड़े बनाता है, लेकिन 1 बच जाता है।",
    's2_step3_task': "38 और 59 का परीक्षण करें।",
    's2_step3_out': "सम संख्याएं पूरी तरह से जुड़ती हैं।",
    's2_step4_task': "सारांश देखें।",
    's2_step4_out': "सीख: 2 से विभाज्य होने के लिए अंतिम अंक सम होना चाहिए।",
    's2_hud1': "14 का परीक्षण करने के लिए एक्टिवेट पर टैप करें।",
    's2_hud2': "27 का परीक्षण करने के लिए एक्टिवेट पर टैप करें।",
    's2_hud3': "38 और 59 का परीक्षण करें।",
    's2_hud4': "2 के नियम का निरीक्षण करें।",

    's3_title': "3. क्वाड-पैकेजिंग मशीन",
    's3_obj':
        "केवल अंतिम दो अंकों द्वारा बनी संख्या का निरीक्षण करके 4 के विभाज्यता नियम की खोज करें।",
    's3_step1_task': "'324' को मशीन पर खींचें।",
    's3_step1_out': "लेंस '24' पर केंद्रित है। 4 के 6 समूह। 4 से विभाज्य!",
    's3_step2_task': "'518' को मशीन पर खींचें।",
    's3_step2_out': "लेंस '18' पर केंद्रित है। 2 बच गए। 4 से विभाज्य नहीं।",
    's3_step3_task': "'936' और '250' का परीक्षण करें।",
    's3_step3_out': "936 स्वीकार किया गया। 250 अस्वीकार किया गया।",
    's3_step4_task': "सारांश देखें।",
    's3_step4_out':
        "सीख: यदि अंतिम दो अंक 4 से विभाज्य हैं, तो संख्या 4 से विभाज्य है।",
    's3_hud1': "ब्लॉक 324 को मशीन पर खींचें।",
    's3_hud2': "ब्लॉक 518 को मशीन पर खींचें।",
    's3_hud3': "936 और 250 का परीक्षण करें।",
    's3_hud4': "4 के नियम का निरीक्षण करें।",

    's4_title': "4. फोरमैन की चुनौती",
    's4_obj':
        "मिश्रित ब्लॉकों को सही ढंग से क्रमबद्ध करने के लिए नियमों को लागू करें।",
    's4_step1_task':
        "'70' का विश्लेषण करें। सही गेट चुनें और SEND पर टैप करें।",
    's4_step1_out': "70, 2, 5 और 10 से विभाज्य है।",
    's4_step2_task': "'88' को सॉर्ट करें।",
    's4_step2_out': "88, 2 और 4 से विभाज्य है।",
    's4_step3_task': "'125' को सॉर्ट करें।",
    's4_step3_out': "125 केवल 5 से विभाज्य है।",
    's4_step4_task': "'340' को सॉर्ट करें।",
    's4_step4_out': "340, 2, 4, 5 और 10 से विभाज्य है। बहुत बढ़िया!",
    's4_hud1': "70 के लिए सही गेट चुनें, फिर SEND करें।",
    's4_hud2': "88 के लिए सही गेट चुनें, फिर SEND करें।",
    's4_hud3': "125 के लिए सही गेट चुनें, फिर SEND करें।",
    's4_hud4': "340 के लिए सही गेट चुनें, फिर SEND करें।",
    's4_send': "भेजें",

    's5_title': "5. कोड ब्रेकर",
    's5_obj': "तिजोरी खोलने के लिए सुरागों का उपयोग करें।",
    's5_step1_task':
        "सुराग 1: '4-अंकीय, 5 से विभाज्य, 10 से नहीं'। कीपैड का उपयोग करें।",
    's5_step1_out': "स्वीकृत! अंतिम अंक 5 होना चाहिए।",
    's5_step2_task': "सुराग 2: '2-अंकीय, 4 से विभाज्य'।",
    's5_step2_out': "स्वीकृत!",
    's5_step3_task': "सुराग 3: '4-अंकीय सम संख्या'।",
    's5_step3_out': "स्वीकृत! तिजोरी खुल गई!",
    's5_hud1': "5 पर समाप्त होने वाला 4-अंकीय नंबर टाइप करें।",
    's5_hud2': "4 का गुणज 2-अंकीय नंबर टाइप करें।",
    's5_hud3': "कोई भी 4-अंकीय सम संख्या टाइप करें।",
    's5_clues': "सुराग",
    's5_c1': "1: 4-अंकीय, 5 से विभाज्य, 10 से नहीं",
    's5_c2': "2: 2-अंकीय, 4 से विभाज्य",
    's5_c3': "3: 4-अंकीय, सम",
    's5_unlocked': "तिजोरी खुल गई",
  },
};
