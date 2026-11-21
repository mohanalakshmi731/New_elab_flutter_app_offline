// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, non_constant_identifier_names, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Shape Shifter Workshop',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const Cl6M_Ch6_A4_TheShapeShiftersWorkshop(),
    ),
  );
}

class Cl6M_Ch6_A4_TheShapeShiftersWorkshop extends StatefulWidget {
  const Cl6M_Ch6_A4_TheShapeShiftersWorkshop({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch6_A4_TheShapeShiftersWorkshop> createState() =>
      _Cl6M_Ch6_A4_TheShapeShiftersWorkshopState();
}

class _Cl6M_Ch6_A4_TheShapeShiftersWorkshopState
    extends State<Cl6M_Ch6_A4_TheShapeShiftersWorkshop>
    with SingleTickerProviderStateMixin {
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _lang = 'en';

  int _scenario = 1;
  int _step = 0;

  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;
  double _initialZoom = 1.0;

  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _gameLoop;
  final SimState _sim = SimState();

  String? _draggedEntity;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _sim.reset(1);
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

  // AUDIO METHODS
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

  String t(String key) {
    return _translations[_lang]?[key] ?? _translations['en']![key] ?? key;
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      _sim.reset(id);
      _sim.showSuccess = false;
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _checkScenarioSuccess() {
    setState(() {
      _step = _getScenarioSteps(_scenario).length;
      _sim.showSuccess = true;
    });
  }

  // Separated simple taps from drag/scale gestures to guarantee instant clicks without dragging
  void _handleTapUp(TapUpDetails details) {
    if (_sim.showSuccess) return;

    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(details.globalPosition);
    double worldX = (local.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (local.dy - box.size.height / 2 - _panY) / _zoom;
    Offset pt = Offset(worldX, worldY);

    setState(() {
      if (_scenario == 1 && _sim.s1_padA && _sim.s1_padB && _step == 3) {
        if (Rect.fromLTWH(50, 310, 360, 40).contains(pt)) {
          _sim.s1_calc = true;
          playPageOpen();
          _advanceStep();
          _checkScenarioSuccess();
        }
      } else if (_scenario == 2) {
        double wx = _sim.s2_wallPad ? 100 : _sim.s2_wallPos.dx;
        double wy = _sim.s2_wallPad ? -110 : _sim.s2_wallPos.dy;
        if (_sim.s2_wallPad &&
            !_sim.s2_windowExtracted &&
            Rect.fromLTWH(wx + 105, wy + 60, 90, 60).contains(pt)) {
          _sim.s2_showSubtract = true;
          playClick();
        } else if (_sim.s2_showSubtract &&
            !_sim.s2_windowExtracted &&
            Rect.fromLTWH(wx + 105, wy + 130, 110, 30).contains(pt)) {
          _sim.s2_windowExtracted = true;
          playClick();
          if (_step == 1) _advanceStep();
        } else if (_sim.s2_wallPad && _sim.s2_windowPad && _step == 3) {
          if (Rect.fromLTWH(70, 220, 360, 40).contains(pt)) {
            _sim.s2_calc = true;
            playPageOpen();
            _advanceStep();
            _checkScenarioSuccess();
          }
        }
      } else if (_scenario == 3) {
        if (!_sim.s3_bed && Rect.fromLTWH(-300, -150, 120, 150).contains(pt)) {
          _sim.s3_bed = true;
          playClick();
          if (_step == 0) _advanceStep();
        } else if (!_sim.s3_kit &&
            Rect.fromLTWH(-300, 0, 120, 90).contains(pt)) {
          _sim.s3_kit = true;
          playClick();
          if (_step == 1) _advanceStep();
        } else if (!_sim.s3_hall &&
            Rect.fromLTWH(-180, -150, 180, 240).contains(pt)) {
          _sim.s3_hall = true;
          playClick();
          if (_step == 2) _advanceStep();
        } else if (_sim.s3_bed && _sim.s3_kit && _sim.s3_hall && _step == 3) {
          if (Rect.fromLTWH(120, 40, 300, 40).contains(pt)) {
            _sim.s3_calc = true;
            playPageOpen();
            _advanceStep();
            _checkScenarioSuccess();
          }
        }
      } else if (_scenario == 4) {
        if (_sim.s4_pieces.where((p) => p.onPad).length == 5 && _step == 2) {
          if (Rect.fromLTWH(120, 210, 310, 40).contains(pt)) {
            _sim.s4_calc = true;
            playPageOpen();
            _advanceStep();
            _checkScenarioSuccess();
          }
        }
      } else if (_scenario == 5) {
        if (_step == 1 || _step == 2) {
          bool clickedArea = false;
          if (_sim.s5_selectedPiece != null) {
            var target = SimState.tTargets[_sim.s5_selectedPiece!];
            double rx = 150 + target!.tx;
            double ry = target.ty - 60;
            List<int> vals = [1, 2, 4];
            for (int i = 0; i < 3; i++) {
              if (Rect.fromCenter(
                center: Offset(rx - 40 + i * 40, ry),
                width: 30,
                height: 30,
              ).contains(pt)) {
                _sim.s5_tangrams
                        .firstWhere((t) => t.id == _sim.s5_selectedPiece)
                        .userArea =
                    vals[i];
                clickedArea = true;
                playClick();
                if (_step == 1 &&
                    _sim.s5_tangrams.every((t) => t.userArea != null)) {
                  _advanceStep();
                }
              }
            }
          }
          bool clickedPiece = false;
          if (!clickedArea) {
            for (var t in _sim.s5_tangrams) {
              if (t.placed && t.id != 5 && t.id != 6) {
                var tg = SimState.tTargets[t.id]!;
                if (Rect.fromCenter(
                  center: Offset(150 + tg.tx, tg.ty),
                  width: 80,
                  height: 80,
                ).contains(pt)) {
                  _sim.s5_selectedPiece = t.id;
                  clickedPiece = true;
                  playClick();
                  break;
                }
              }
            }
          }
          if (!clickedArea && !clickedPiece && _step == 2) {
            if (Rect.fromLTWH(-280, 140, 160, 40).contains(pt)) {
              bool correct = _sim.s5_tangrams.every(
                (t) => t.userArea == t.targetArea,
              );
              if (correct) {
                _sim.s5_selectedPiece = null;
                _sim.s5_calc = true;
                playPageOpen();
                _advanceStep();
                _checkScenarioSuccess();
              } else {
                playError();
              }
            }
          }
        }
      }
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_sim.showSuccess) return;

    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(details.focalPoint);
    double worldX = (local.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (local.dy - box.size.height / 2 - _panY) / _zoom;
    Offset pt = Offset(worldX, worldY);

    _draggedEntity = null;
    _initialZoom = _zoom;

    setState(() {
      if (_scenario == 1) {
        if (!_sim.s1_isCut) {
          if (Rect.fromCenter(
            center: _sim.s1_toolPos,
            width: 60,
            height: 60,
          ).contains(pt)) {
            _draggedEntity = 's1Tool';
          }
        } else {
          if (!_sim.s1_padA &&
              Rect.fromLTWH(
                _sim.s1_rectAPos.dx,
                _sim.s1_rectAPos.dy,
                90,
                300,
              ).contains(pt)) {
            _draggedEntity = 's1A';
          }
          if (!_sim.s1_padB &&
              Rect.fromLTWH(
                _sim.s1_rectBPos.dx,
                _sim.s1_rectBPos.dy,
                240,
                120,
              ).contains(pt)) {
            _draggedEntity = 's1B';
          }
        }
      } else if (_scenario == 2) {
        double wx = _sim.s2_wallPad ? 100 : _sim.s2_wallPos.dx;
        double wy = _sim.s2_wallPad ? -110 : _sim.s2_wallPos.dy;

        if (!_sim.s2_wallPad && Rect.fromLTWH(wx, wy, 300, 180).contains(pt)) {
          _draggedEntity = 's2Wall';
        }

        double winX = _sim.s2_windowPad
            ? 155
            : (_sim.s2_windowExtracted ? _sim.s2_winPos.dx : wx + 105);
        double winY = _sim.s2_windowPad
            ? -50
            : (_sim.s2_windowExtracted ? _sim.s2_winPos.dy : wy + 60);
        if (_sim.s2_windowExtracted &&
            !_sim.s2_windowPad &&
            Rect.fromLTWH(winX, winY, 90, 60).contains(pt)) {
          _draggedEntity = 's2Win';
        }
      } else if (_scenario == 4) {
        bool allCut = _sim.s4_cuts.every((c) => c);
        if (!allCut) {
          if (Rect.fromCenter(
            center: _sim.s4_toolPos,
            width: 60,
            height: 60,
          ).contains(pt)) {
            _draggedEntity = 's4Tool';
          }
        } else {
          for (int i = 0; i < _sim.s4_pieces.length; i++) {
            var p = _sim.s4_pieces[i];
            if (!p.onPad &&
                Rect.fromLTWH(p.pos.dx, p.pos.dy, 80, 80).contains(pt)) {
              _draggedEntity = 's4p_$i';
              break;
            }
          }
        }
      } else if (_scenario == 5) {
        if (_step == 0) {
          for (var t in _sim.s5_tangrams) {
            if (!t.placed &&
                Rect.fromCenter(
                  center: t.pos,
                  width: 80,
                  height: 80,
                ).contains(pt)) {
              _draggedEntity = 's5t_${t.id}';
              break;
            }
          }
        }
      }
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_sim.showSuccess) return;

    if (details.pointerCount == 1) {
      if (_draggedEntity != null) {
        RenderBox box =
            _canvasKey.currentContext!.findRenderObject() as RenderBox;
        Offset local = box.globalToLocal(details.focalPoint);
        double worldX = (local.dx - box.size.width / 2 - _panX) / _zoom;
        double worldY = (local.dy - box.size.height / 2 - _panY) / _zoom;

        setState(() {
          if (_draggedEntity == 's1Tool') {
            _sim.s1_toolPos = Offset(_sim.s1_toolPos.dx, worldY);
            if (_sim.s1_toolPos.dy > 80) {
              _sim.s1_isCut = true;
              _draggedEntity = null;
              playClick();
              if (_step == 0) _advanceStep();
            }
          } else if (_draggedEntity == 's1A') {
            _sim.s1_rectAPos = Offset(worldX - 45, worldY - 150);
          } else if (_draggedEntity == 's1B') {
            _sim.s1_rectBPos = Offset(worldX - 120, worldY - 60);
          } else if (_draggedEntity == 's2Wall') {
            _sim.s2_wallPos = Offset(worldX - 150, worldY - 90);
          } else if (_draggedEntity == 's2Win') {
            _sim.s2_winPos = Offset(worldX - 45, worldY - 30);
          } else if (_draggedEntity == 's4Tool') {
            _sim.s4_toolPos = Offset(worldX, worldY);
            List<Offset> seams = const [
              Offset(-250, -90),
              Offset(-250, -10),
              Offset(-290, -50),
              Offset(-210, -50),
            ];
            for (int i = 0; i < 4; i++) {
              if (!_sim.s4_cuts[i] &&
                  (Offset(worldX, worldY) - seams[i]).distance < 30) {
                _sim.s4_cuts[i] = true;
                playClick();
                _sim.s4_pieces[i + 1].cut = true;
                if (i == 0) _sim.s4_pieces[i + 1].pos += const Offset(0, -10);
                if (i == 1) _sim.s4_pieces[i + 1].pos += const Offset(0, 10);
                if (i == 2) _sim.s4_pieces[i + 1].pos += const Offset(-10, 0);
                if (i == 3) _sim.s4_pieces[i + 1].pos += const Offset(10, 0);
                if (_sim.s4_cuts.every((c) => c) && _step == 0) {
                  _advanceStep();
                  _draggedEntity = null;
                }
              }
            }
          } else if (_draggedEntity!.startsWith('s4p_')) {
            int id = int.parse(_draggedEntity!.split('_')[1]);
            _sim.s4_pieces[id].pos = Offset(worldX - 40, worldY - 40);
          } else if (_draggedEntity!.startsWith('s5t_')) {
            int id = int.parse(_draggedEntity!.split('_')[1]);
            _sim.s5_tangrams.firstWhere((t) => t.id == id).pos = Offset(
              worldX,
              worldY,
            );
          }
        });
      } else {
        setState(() {
          _panX += details.focalPointDelta.dx;
          _panY += details.focalPointDelta.dy;
        });
      }
    } else if (details.pointerCount >= 2 && _draggedEntity == null) {
      setState(() {
        _zoom = (_initialZoom * details.scale).clamp(0.4, 2.5);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_draggedEntity != null) {
      setState(() {
        if (_draggedEntity == 's1A') {
          if (Rect.fromLTWH(30, -180, 400, 380).contains(
            Offset(_sim.s1_rectAPos.dx + 45, _sim.s1_rectAPos.dy + 150),
          )) {
            _sim.s1_padA = true;
            playClick();
            if (_step == 1) _advanceStep();
          } else {
            playError();
          }
        } else if (_draggedEntity == 's1B') {
          if (Rect.fromLTWH(30, -180, 400, 380).contains(
            Offset(_sim.s1_rectBPos.dx + 120, _sim.s1_rectBPos.dy + 60),
          )) {
            _sim.s1_padB = true;
            playClick();
            if (_step == 2) _advanceStep();
          } else {
            playError();
          }
        } else if (_draggedEntity == 's2Wall') {
          if (Rect.fromLTWH(50, -150, 400, 260).contains(
            Offset(_sim.s2_wallPos.dx + 150, _sim.s2_wallPos.dy + 90),
          )) {
            _sim.s2_wallPad = true;
            playClick();
            if (_step == 0) _advanceStep();
          } else {
            playError();
          }
        } else if (_draggedEntity == 's2Win') {
          if (Rect.fromLTWH(
            50,
            -150,
            400,
            260,
          ).contains(Offset(_sim.s2_winPos.dx + 45, _sim.s2_winPos.dy + 30))) {
            _sim.s2_windowPad = true;
            playClick();
            if (_step == 2) _advanceStep();
          } else {
            playError();
          }
        } else if (_draggedEntity!.startsWith('s4p_')) {
          int id = int.parse(_draggedEntity!.split('_')[1]);
          var p = _sim.s4_pieces[id];
          if (Rect.fromLTWH(
            100,
            -200,
            350,
            300,
          ).contains(Offset(p.pos.dx + 40, p.pos.dy + 40))) {
            p.onPad = true;
            playClick();
            int count = _sim.s4_pieces.where((x) => x.onPad).length;
            p.pos = Offset(
              100 + 20 + ((count - 1) % 3) * 100,
              -200 + 20 + ((count - 1) ~/ 3) * 100,
            );
            if (count == 5 && _step == 1) _advanceStep();
          } else {
            playError();
          }
        } else if (_draggedEntity!.startsWith('s5t_')) {
          int id = int.parse(_draggedEntity!.split('_')[1]);
          var t = _sim.s5_tangrams.firstWhere((x) => x.id == id);
          var tg = SimState.tTargets[id]!;
          Offset target = Offset(150 + tg.tx, tg.ty);
          if ((t.pos - target).distance < 50) {
            t.placed = true;
            playClick();
            if (_sim.s5_tangrams.every((x) => x.placed) && _step == 0) {
              _advanceStep();
              _sim.s5_selectedPiece = 0;
            }
          } else {
            playError();
          }
        }
        _draggedEntity = null;
      });
    }
  }

  List<Map<String, String>> _getScenarioSteps(int id) {
    int count = id == 4 || id == 5 ? 3 : 4;
    List<Map<String, String>> s = [];
    for (int i = 1; i <= count; i++) {
      s.add({
        'hud': t('s${id}_hud$i'),
        'task': t('s${id}_step${i}_task'),
        'out': t('s${id}_step${i}_out'),
      });
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(color: const Color(0xFF0F172A)),

            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _gameLoop,
                  builder: (context, child) {
                    return CustomPaint(
                      key: _canvasKey,
                      painter: WorkshopPainter(
                        _sim,
                        _scenario,
                        _step,
                        _panX,
                        _panY,
                        _zoom,
                        t,
                        _gameLoop.value,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: _handleTapUp,
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,
                        onScaleEnd: _handleScaleEnd,
                        child: Container(color: Colors.transparent),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Left Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 2),
                  ),
                ),
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  _buildSidebarHeader(),
                                  Expanded(child: _buildSidebarContent()),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    width: double.infinity,
                                    color: Colors.black26,
                                    child: const Text(
                                      "© ZeroScienceLab - Fall in love with math and Science",
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
                        );
                      },
                    ),
                    // Canvas Adjuster Handle
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 20,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _sidebarWidth = (_sidebarWidth + details.delta.dx)
                                .clamp(
                                  300.0,
                                  MediaQuery.of(context).size.width * 0.6,
                                );
                          });
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeLeftRight,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 4,
                              height: 40,
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: Colors.white54,
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

            // Menu Button Fixed at Top Left!
            Positioned(
              left: 16,
              top: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF6366F1),
                onPressed: () {
                  playClick();
                  setState(() => _sidebarOpen = !_sidebarOpen);
                },
                child: Icon(
                  _sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              bottom: 24,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      (_step < _getScenarioSteps(_scenario).length &&
                          !_sim.showSuccess)
                      ? 1.0
                      : 0.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                          top: BorderSide(color: Color(0xFF6366F1), width: 4),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info, color: Color(0xFF6366F1)),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _getScenarioSteps(_scenario).isEmpty
                                  ? ""
                                  : (_step < _getScenarioSteps(_scenario).length
                                        ? _getScenarioSteps(
                                            _scenario,
                                          )[_step]['hud']!
                                        : ""),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
            ),

            // Success Popup Overlay
            if (_sim.showSuccess)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 450,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
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
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _scenario < 5
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFFF59E0B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              playPageOpen();
                              if (_scenario < 5) {
                                _loadScenario(_scenario + 1);
                              } else {
                                _loadScenario(1);
                              }
                            },
                            child: Text(
                              _scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
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

            // Curtain Overlay
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
                            Icons.extension,
                            size: 100,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('shutterTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white54,
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
                            ),
                            onPressed: () {
                              curtainScreen();
                              setState(() => _showCurtain = false);
                            },
                            icon: const Icon(Icons.play_circle_fill, size: 28),
                            label: Text(
                              t('enterLab'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      // Added Top Padding here so the fixed Menu button won't block the sidebar header text
      padding: const EdgeInsets.only(left: 16, right: 16, top: 72, bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.extension, color: Color(0xFF6366F1), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('appTitle'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('appSubtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(
                  Icons.language,
                  color: Colors.white70,
                  size: 18,
                ),
                label: Text(
                  _lang == 'en' ? 'EN' : 'HI',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  playDropdown();
                  setState(() {
                    _lang = _lang == 'en' ? 'hi' : 'en';
                  });
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  padding: const EdgeInsets.all(8),
                ),
                icon: Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    Text(
                      t('resetBtn'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  playPageOpen();
                  _loadScenario(_scenario);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    final steps = _getScenarioSteps(_scenario);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('selectScenario').toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _scenario,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(t('s${i + 1}_title')),
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
                      Icons.track_changes,
                      color: Color(0xFFF43F5E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t('objective'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t('s${_scenario}_obj'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(steps.length, (i) {
            bool isCompleted = i < _step;
            bool isCurrent = i == _step;
            Color bgColor = isCompleted
                ? const Color(0xFF064E3B)
                : (isCurrent
                      ? const Color(0xFF312E81)
                      : Colors.white.withOpacity(0.05));
            Color borderColor = isCompleted
                ? const Color(0xFF10B981)
                : (isCurrent ? const Color(0xFF6366F1) : Colors.transparent);
            Color iconColor = isCompleted
                ? const Color(0xFF10B981)
                : (isCurrent ? Colors.white : Colors.white38);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isCompleted
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 28,
                        )
                      : Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF6366F1)
                                : Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${i + 1}",
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${t('stepLabel')} ${i + 1}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i]['task']!,
                          style: TextStyle(
                            color: isCurrent || isCompleted
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              steps[i]['out']!,
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SimState {
  bool showSuccess = false;

  // S1
  bool s1_isCut = false;
  bool s1_padA = false;
  bool s1_padB = false;
  bool s1_calc = false;
  Offset s1_toolPos = const Offset(-160, -130);
  Offset s1_rectAPos = const Offset(-250, -100);
  Offset s1_rectBPos = const Offset(-160, 80);

  // S2
  bool s2_wallPad = false;
  bool s2_windowExtracted = false;
  bool s2_windowPad = false;
  bool s2_showSubtract = false;
  bool s2_calc = false;
  Offset s2_wallPos = const Offset(-250, -100);
  Offset s2_winPos = const Offset(-145, -40);

  // S3
  bool s3_bed = false;
  bool s3_kit = false;
  bool s3_hall = false;
  bool s3_calc = false;

  // S4
  List<bool> s4_cuts = [false, false, false, false];
  List<ParkPiece> s4_pieces = [];
  Offset s4_toolPos = const Offset(-410, 30);
  bool s4_calc = false;

  // S5
  List<TangramPiece> s5_tangrams = [];
  int? s5_selectedPiece;
  bool s5_calc = false;

  static const Map<int, TargetTransform> tTargets = {
    0: TargetTransform(-40, -20, 45),
    1: TargetTransform(40, -20, -45),
    2: TargetTransform(0, 80, 0),
    3: TargetTransform(0, -100, 0),
    4: TargetTransform(100, 40, 90),
    5: TargetTransform(-40, -140, -45),
    6: TargetTransform(40, -140, 45),
  };

  void reset(int scenario) {
    if (scenario == 1) {
      s1_isCut = false;
      s1_padA = false;
      s1_padB = false;
      s1_calc = false;
      s1_toolPos = const Offset(-120, -130);
      s1_rectAPos = const Offset(-250, -100);
      s1_rectBPos = const Offset(-160, 80);
    } else if (scenario == 2) {
      s2_wallPad = false;
      s2_windowExtracted = false;
      s2_windowPad = false;
      s2_showSubtract = false;
      s2_calc = false;
      s2_wallPos = const Offset(-250, -100);
      s2_winPos = const Offset(-145, -40);
    } else if (scenario == 3) {
      s3_bed = false;
      s3_kit = false;
      s3_hall = false;
      s3_calc = false;
    } else if (scenario == 4) {
      s4_cuts = [false, false, false, false];
      s4_calc = false;
      s4_toolPos = const Offset(-410, 30);
      s4_pieces = [
        ParkPiece(0, const Offset(-290, -90), true),
        ParkPiece(1, const Offset(-290, -170), false),
        ParkPiece(2, const Offset(-290, -10), false),
        ParkPiece(3, const Offset(-370, -90), false),
        ParkPiece(4, const Offset(-210, -90), false),
      ];
    } else if (scenario == 5) {
      s5_selectedPiece = null;
      s5_calc = false;
      s5_tangrams = [
        TangramPiece(
          0,
          _relPts([0, 0, 4, 0, 2, 2]),
          const Color(0xFFEF4444),
          4,
          const Offset(-300, -150),
          0,
        ),
        TangramPiece(
          1,
          _relPts([0, 0, 0, 4, 2, 2]),
          const Color(0xFF3B82F6),
          4,
          const Offset(-180, -150),
          0,
        ),
        TangramPiece(
          2,
          _relPts([4, 4, 2, 4, 2, 2]),
          const Color(0xFFFACC15),
          2,
          const Offset(-60, -150),
          0,
        ),
        TangramPiece(
          3,
          _relPts([2, 2, 3, 1, 4, 2, 3, 3]),
          const Color(0xFFA855F7),
          2,
          const Offset(-300, -30),
          0,
        ),
        TangramPiece(
          4,
          _relPts([0, 4, 2, 4, 3, 3, 1, 3]),
          const Color(0xFF22C55E),
          2,
          const Offset(-180, -30),
          0,
        ),
        TangramPiece(
          5,
          _relPts([4, 0, 4, 2, 3, 1]),
          const Color(0xFFF97316),
          1,
          const Offset(-60, -30),
          0,
        ),
        TangramPiece(
          6,
          _relPts([2, 4, 2, 2, 1, 3]),
          const Color(0xFFEC4899),
          1,
          const Offset(-300, 90),
          0,
        ),
      ];
    }
  }

  List<Offset> _relPts(List<double> coords) {
    double cx = 0, cy = 0;
    List<Offset> pts = [];
    for (int i = 0; i < coords.length; i += 2) {
      Offset p = Offset(coords[i] * 40, coords[i + 1] * 40);
      pts.add(p);
      cx += p.dx;
      cy += p.dy;
    }
    cx /= pts.length;
    cy /= pts.length;
    return pts.map((p) => Offset(p.dx - cx, p.dy - cy)).toList();
  }
}

class ParkPiece {
  final int id;
  Offset pos;
  bool cut;
  bool onPad = false;
  ParkPiece(this.id, this.pos, this.cut);
}

class TargetTransform {
  final double tx, ty, rot;
  const TargetTransform(this.tx, this.ty, this.rot);
}

class TangramPiece {
  final int id;
  final List<Offset> pts;
  final Color col;
  final int targetArea;
  Offset pos;
  double rot;
  bool placed = false;
  int? userArea;
  TangramPiece(
    this.id,
    this.pts,
    this.col,
    this.targetArea,
    this.pos,
    this.rot,
  );

  Path get path {
    Path p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      p.lineTo(pts[i].dx, pts[i].dy);
    }
    p.close();
    return p;
  }
}

class WorkshopPainter extends CustomPainter {
  final SimState sim;
  final int scenario;
  final int step;
  final double panX, panY, zoom;
  final String Function(String) t;
  final double time;

  WorkshopPainter(
    this.sim,
    this.scenario,
    this.step,
    this.panX,
    this.panY,
    this.zoom,
    this.t,
    this.time,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    if (scenario == 1) {
      _renderS1(canvas);
    } else if (scenario == 2) {
      _renderS2(canvas);
    } else if (scenario == 3) {
      _renderS3(canvas);
    } else if (scenario == 4) {
      _renderS4(canvas);
    } else if (scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    _drawAnalysisPad(canvas, const Rect.fromLTWH(30, -180, 400, 380));
    List<String> vals = [];
    if (sim.s1_padA) vals.add('30');
    if (sim.s1_padB) vals.add('32');
    _drawTotalAreaBox(
      canvas,
      const Rect.fromLTWH(30, 220, 400, 140),
      vals,
      62,
      sim.s1_padA && sim.s1_padB,
      sim.s1_calc,
    );

    if (sim.s1_calc) {
      _drawGridRect(
        canvas,
        const Rect.fromLTWH(-200, -100, 90, 300),
        const Color(0xFF86EFAC),
        '',
      );
      _drawGridRect(
        canvas,
        const Rect.fromLTWH(-110, 80, 240, 120),
        const Color(0xFF86EFAC),
        '',
      );
      _drawText(
        canvas,
        "62 sq units",
        const Offset(-20, 0),
        fontSize: 24,
        color: const Color(0xFF0F172A),
      );
      return;
    }

    double rxA = sim.s1_padA ? 60 : sim.s1_rectAPos.dx;
    double ryA = sim.s1_padA ? -140 : sim.s1_rectAPos.dy;
    double rxB = sim.s1_padB ? 170 : sim.s1_rectBPos.dx;
    double ryB = sim.s1_padB ? 40 : sim.s1_rectBPos.dy;

    if (sim.s1_padA) {
      _drawGridRect(
        canvas,
        Rect.fromLTWH(rxA, ryA, 90, 300),
        const Color(0xFF86EFAC),
        '3x10\n=30',
      );
    } else {
      _drawRect(
        canvas,
        Rect.fromLTWH(rxA, ryA, 90, 300),
        const Color(0xFF4ADE80),
        stroke: const Color(0xFF0F172A),
      );
      if (step >= 1) {
        _drawText(canvas, "3", Offset(rxA + 45, ryA - 15));
        _drawText(canvas, "10", Offset(rxA - 15, ryA + 150));
      }
    }

    if (sim.s1_padB) {
      _drawGridRect(
        canvas,
        Rect.fromLTWH(rxB, ryB, 240, 120),
        const Color(0xFF86EFAC),
        '8x4\n=32',
      );
    } else {
      _drawRect(
        canvas,
        Rect.fromLTWH(rxB, ryB, 240, 120),
        const Color(0xFF4ADE80),
        stroke: const Color(0xFF0F172A),
      );
      if (step >= 1) {
        _drawText(canvas, "8", Offset(rxB + 120, ryB - 15));
        _drawText(canvas, "4", Offset(rxB + 255, ryB + 60));
      }
    }

    if (!sim.s1_isCut) {
      _drawDashedLine(
        canvas,
        const Offset(-160, -100),
        const Offset(-160, 80),
        const Color(0xFF0F172A),
      );
      _drawLaserLine(
        canvas,
        const Offset(-160, -100),
        Offset(-160, sim.s1_toolPos.dy),
      );
      _drawLaserIcon(canvas, sim.s1_toolPos);
    }
  }

  void _renderS2(Canvas canvas) {
    _drawAnalysisPad(canvas, const Rect.fromLTWH(50, -150, 400, 260));
    List<String> vals = [];
    if (sim.s2_wallPad) vals.add('60');
    if (sim.s2_windowPad) vals.add('- 6');
    _drawTotalAreaBox(
      canvas,
      const Rect.fromLTWH(50, 130, 400, 140),
      vals,
      54,
      sim.s2_wallPad && sim.s2_windowPad,
      sim.s2_calc,
    );

    if (sim.s2_calc) {
      _drawGridRect(
        canvas,
        const Rect.fromLTWH(-200, -50, 300, 180),
        const Color(0xFF93C5FD),
        '',
      );
      _drawRect(
        canvas,
        const Rect.fromLTWH(-95, 10, 90, 60),
        const Color(0xFF0F172A),
        stroke: const Color(0xFF0F172A),
      );
      _drawText(canvas, "54 sq units", const Offset(-50, -80), fontSize: 24);
      return;
    }

    double wx = sim.s2_wallPad ? 100 : sim.s2_wallPos.dx;
    double wy = sim.s2_wallPad ? -110 : sim.s2_wallPos.dy;

    if (sim.s2_wallPad) {
      _drawGridRect(
        canvas,
        Rect.fromLTWH(wx, wy, 300, 180),
        const Color(0xFF93C5FD),
        '10x6\n=60',
      );
    } else {
      _drawRect(
        canvas,
        Rect.fromLTWH(wx, wy, 300, 180),
        const Color(0xFFBFDBFE),
        stroke: const Color(0xFF0F172A),
      );
    }

    if (sim.s2_windowExtracted) {
      _drawRect(
        canvas,
        Rect.fromLTWH(wx + 105, wy + 60, 90, 60),
        const Color(0xFF0F172A),
        stroke: const Color(0xFF0F172A),
      );
    }

    double winX = sim.s2_windowPad
        ? 155
        : (sim.s2_windowExtracted ? sim.s2_winPos.dx : wx + 105);
    double winY = sim.s2_windowPad
        ? -50
        : (sim.s2_windowExtracted ? sim.s2_winPos.dy : wy + 60);

    if (!sim.s2_windowExtracted || sim.s2_windowPad || step >= 2) {
      if (sim.s2_windowPad) {
        _drawGridRect(
          canvas,
          Rect.fromLTWH(winX, winY, 90, 60),
          const Color(0x80EF4444),
          '3x2\n=6',
        );
      } else {
        _drawRect(
          canvas,
          Rect.fromLTWH(winX, winY, 90, 60),
          const Color(0xFFCBD5E1),
          stroke: const Color(0xFF0F172A),
        );
        if (sim.s2_wallPad && !sim.s2_windowExtracted) {
          _drawText(
            canvas,
            "Window",
            Offset(winX + 45, winY + 30),
            color: const Color(0xFF0F172A),
          );
        }
      }
    }

    if (sim.s2_showSubtract && !sim.s2_windowExtracted) {
      _drawRect(
        canvas,
        Rect.fromLTWH(wx + 105, wy + 130, 110, 30),
        const Color(0xFFEF4444),
        radius: 8,
      );
      _drawText(canvas, "Subtract", Offset(wx + 160, wy + 145), fontSize: 14);
    }
  }

  void _renderS3(Canvas canvas) {
    _drawRect(
      canvas,
      const Rect.fromLTWH(-300, -150, 300, 360),
      const Color(0xFFFFFFFF),
      stroke: const Color(0xFF1E3A8A),
      strokeWidth: 4,
      radius: 0,
    );

    void dRoom(Rect r, String name, bool c, Color col, String calc) {
      _drawRect(
        canvas,
        r,
        c ? col : const Color(0xFFF1F5F9),
        stroke: const Color(0xFF1E3A8A),
        strokeWidth: 3,
        radius: 0,
      );
      _drawText(
        canvas,
        name,
        Offset(r.left + r.width / 2, r.top + r.height / 2 - 10),
        color: const Color(0xFF0F172A),
      );
      if (c) {
        _drawText(
          canvas,
          calc,
          Offset(r.left + r.width / 2, r.top + r.height / 2 + 15),
          fontSize: 14,
          color: const Color(0xFF0F172A),
        );
      }
    }

    dRoom(
      const Rect.fromLTWH(-300, -150, 120, 150),
      "Bedroom",
      sim.s3_bed,
      const Color(0xFFFCA5A5),
      "4x5 = 20",
    );
    dRoom(
      const Rect.fromLTWH(-300, 0, 120, 90),
      "Kitchen",
      sim.s3_kit,
      const Color(0xFFFCD34D),
      "4x3 = 12",
    );
    dRoom(
      const Rect.fromLTWH(-180, -150, 180, 240),
      "Hall",
      sim.s3_hall,
      const Color(0xFF86EFAC),
      "6x8 = 48",
    );

    List<String> vals = [];
    if (sim.s3_bed) vals.add('20');
    if (sim.s3_kit) vals.add('12');
    if (sim.s3_hall) vals.add('48');
    _drawTotalAreaBox(
      canvas,
      const Rect.fromLTWH(100, -50, 340, 140),
      vals,
      80,
      sim.s3_bed && sim.s3_kit && sim.s3_hall,
      sim.s3_calc,
    );
  }

  void _renderS4(Canvas canvas) {
    _drawAnalysisPad(canvas, const Rect.fromLTWH(100, -200, 350, 300));
    _drawRect(
      canvas,
      const Rect.fromLTWH(100, 120, 350, 140),
      const Color(0xFF0F172A),
      stroke: const Color(0xFF475569),
    );
    int c = sim.s4_pieces.where((p) => p.onPad).length;
    _drawText(
      canvas,
      "Pieces Analyzed: $c / 5",
      const Offset(275, 150),
      fontSize: 18,
    );

    if (c == 5 && !sim.s4_calc) {
      _drawRect(
        canvas,
        const Rect.fromLTWH(120, 210, 310, 40),
        const Color(0xFF6366F1),
        radius: 20,
      );
      _drawText(
        canvas,
        "Check My Answer",
        const Offset(275, 230),
        fontSize: 16,
      );
    }
    if (sim.s4_calc) {
      _drawText(
        canvas,
        "Total Area = 20 sq units",
        const Offset(275, 200),
        fontSize: 20,
        color: const Color(0xFF22C55E),
      );
    }

    for (var p in sim.s4_pieces) {
      if (p.onPad) {
        _drawGridRect(
          canvas,
          Rect.fromLTWH(p.pos.dx, p.pos.dy, 80, 80),
          const Color(0xFFFDE047),
          '2x2',
          40,
        );
      } else {
        _drawRect(
          canvas,
          Rect.fromLTWH(p.pos.dx, p.pos.dy, 80, 80),
          const Color(0xFFFEF08A),
          stroke: const Color(0xFFCA8A04),
        );
      }
    }

    if (!sim.s4_cuts.every((x) => x)) {
      List<Offset> sA = const [
        Offset(-290, -90),
        Offset(-290, -10),
        Offset(-290, -50),
        Offset(-210, -50),
      ];
      List<Offset> sB = const [
        Offset(-210, -90),
        Offset(-210, -10),
        Offset(-290, 30),
        Offset(-210, 30),
      ];
      for (int i = 0; i < 4; i++) {
        if (!sim.s4_cuts[i]) {
          _drawDashedLine(
            canvas,
            sA[i],
            sB[i] == const Offset(-290, 30) ? const Offset(-290, -50) : sB[i],
            const Color(0xFFEF4444),
          );
        }
      }
      _drawLaserIcon(canvas, sim.s4_toolPos);
    }
  }

  void _renderS5(Canvas canvas) {
    for (var tg in SimState.tTargets.entries) {
      var shape = sim.s5_tangrams.firstWhere((t) => t.id == tg.key);
      if (!shape.placed) {
        canvas.save();
        canvas.translate(150 + tg.value.tx, tg.value.ty);
        canvas.rotate(tg.value.rot * pi / 180);
        canvas.drawPath(
          shape.path,
          Paint()
            ..color = const Color(0x1A000000)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          shape.path,
          Paint()
            ..color = const Color(0xFF0F172A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.restore();
      }
    }

    for (var t in sim.s5_tangrams) {
      double rx = t.placed ? 150 + SimState.tTargets[t.id]!.tx : t.pos.dx;
      double ry = t.placed ? SimState.tTargets[t.id]!.ty : t.pos.dy;
      double rot = t.placed ? SimState.tTargets[t.id]!.rot : 0;

      canvas.save();
      canvas.translate(rx, ry);
      canvas.rotate(rot * pi / 180);
      canvas.drawPath(
        t.path,
        Paint()
          ..color = t.col
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        t.path,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      if (t.userArea != null) {
        canvas.rotate(-rot * pi / 180);
        _drawText(
          canvas,
          "${t.userArea}",
          Offset.zero,
          fontSize: 20,
          color: Colors.white,
          isOutlined: true,
        );
      }
      canvas.restore();
    }

    if ((step == 1 || step == 2) && sim.s5_selectedPiece != null) {
      var t = sim.s5_tangrams.firstWhere((x) => x.id == sim.s5_selectedPiece);
      double rx = 150 + SimState.tTargets[t.id]!.tx;
      double ry = SimState.tTargets[t.id]!.ty - 60;
      _drawRect(
        canvas,
        Rect.fromCenter(center: Offset(rx, ry), width: 120, height: 40),
        const Color(0xFFF8FAFC),
        radius: 20,
      );
      List<int> vals = [1, 2, 4];
      for (int i = 0; i < 3; i++) {
        double bx = rx - 40 + i * 40;
        _drawRect(
          canvas,
          Rect.fromCenter(center: Offset(bx, ry), width: 30, height: 30),
          t.userArea == vals[i]
              ? const Color(0xFF22C55E)
              : const Color(0xFFE2E8F0),
          radius: 15,
        );
        _drawText(
          canvas,
          "${vals[i]}",
          Offset(bx, ry),
          fontSize: 14,
          color: const Color(0xFF0F172A),
        );
      }
    }

    if (step >= 1 && sim.s5_tangrams.every((t) => t.userArea != null)) {
      _drawRect(
        canvas,
        const Rect.fromLTWH(-300, 100, 200, 120),
        const Color(0xFF0F172A),
        stroke: const Color(0xFF475569),
      );
      if (!sim.s5_calc) {
        _drawRect(
          canvas,
          const Rect.fromLTWH(-280, 140, 160, 40),
          const Color(0xFF6366F1),
          radius: 20,
        );
        _drawText(
          canvas,
          "Calculate Total Area",
          const Offset(-200, 160),
          fontSize: 12,
        );
      } else {
        _drawText(
          canvas,
          "Total = 16",
          const Offset(-200, 160),
          fontSize: 24,
          color: const Color(0xFF22C55E),
        );
      }
    }
  }

  void _drawRect(
    Canvas canvas,
    Rect r,
    Color fill, {
    Color? stroke,
    double radius = 8,
    double strokeWidth = 2,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(radius)),
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    if (stroke != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(radius)),
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _drawGridRect(
    Canvas canvas,
    Rect r,
    Color fill,
    String text, [
    double gridU = 30,
  ]) {
    _drawRect(
      canvas,
      r,
      fill,
      stroke: const Color(0xFF0F172A),
      radius: 0,
      strokeWidth: 3,
    );
    Paint p = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;
    for (double i = gridU; i < r.width; i += gridU) {
      canvas.drawLine(
        Offset(r.left + i, r.top),
        Offset(r.left + i, r.bottom),
        p,
      );
    }
    for (double j = gridU; j < r.height; j += gridU) {
      canvas.drawLine(Offset(r.left, r.top + j), Offset(r.right, r.top + j), p);
    }
    if (text.isNotEmpty) {
      _drawRect(
        canvas,
        Rect.fromCenter(center: r.center, width: 80, height: 40),
        Colors.white.withOpacity(0.8),
        stroke: const Color(0xFF0F172A),
        radius: 4,
      );
      _drawText(canvas, text, r.center, color: const Color(0xFF0F172A));
    }
  }

  void _drawAnalysisPad(Canvas canvas, Rect r) {
    _drawRect(
      canvas,
      r,
      const Color(0xFF334155),
      stroke: const Color(0xFF0F172A),
      strokeWidth: 4,
      radius: 12,
    );
    Paint p = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = 10; i < r.width; i += 20) {
      canvas.drawLine(
        Offset(r.left + i, r.top),
        Offset(r.left + i, r.bottom),
        p,
      );
    }
    for (double j = 10; j < r.height; j += 20) {
      canvas.drawLine(Offset(r.left, r.top + j), Offset(r.right, r.top + j), p);
    }
    _drawRect(
      canvas,
      Rect.fromCenter(
        center: Offset(r.center.dx, r.top),
        width: 160,
        height: 30,
      ),
      const Color(0xFF1E293B),
      stroke: const Color(0xFF0F172A),
      radius: 4,
    );
    _drawText(canvas, "ANALYSIS PAD", Offset(r.center.dx, r.top), fontSize: 12);
  }

  void _drawTotalAreaBox(
    Canvas canvas,
    Rect r,
    List<String> vals,
    int res,
    bool ready,
    bool clicked,
  ) {
    _drawRect(
      canvas,
      r,
      const Color(0xFF0F172A),
      stroke: const Color(0xFF475569),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(r.left, r.top, r.width, 40),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    _drawText(
      canvas,
      "TOTAL AREA",
      Offset(r.center.dx, r.top + 20),
      fontSize: 16,
      color: const Color(0xFF94A3B8),
    );

    String eq = vals.join(" + ");
    if (clicked) eq += " = $res";

    if (ready && !clicked) {
      _drawText(
        canvas,
        eq.isEmpty ? "?" : eq,
        Offset(r.center.dx, r.top + 65),
        fontSize: 24,
      );
      _drawRect(
        canvas,
        Rect.fromLTWH(r.left + 20, r.bottom - 50, r.width - 40, 40),
        const Color(0xFF6366F1),
        radius: 20,
      );
      _drawText(
        canvas,
        "CALCULATE",
        Offset(r.center.dx, r.bottom - 30),
        fontSize: 16,
      );
    } else {
      _drawText(
        canvas,
        eq.isEmpty ? "?" : eq,
        Offset(r.center.dx, r.center.dy + 10),
        fontSize: 24,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    double fontSize = 16,
    Color color = Colors.white,
    bool isOutlined = false,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    if (isOutlined) {
      TextPainter outline = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = const Color(0xFF0F172A),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      outline.layout();
      outline.paint(
        canvas,
        pos - Offset(outline.width / 2, outline.height / 2),
      );
    }
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    double dist = (p2 - p1).distance;
    double dash = 8;
    double gap = 8;
    double current = 0;
    while (current < dist) {
      canvas.drawLine(
        p1 + (p2 - p1) * (current / dist),
        p1 + (p2 - p1) * ((current + dash) / dist).clamp(0, 1.0),
        p,
      );
      current += dash + gap;
    }
  }

  void _drawLaserLine(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..strokeWidth = 3,
    );
  }

  void _drawLaserIcon(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    Path p = Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: 30, height: 30));
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF6366F1)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(canvas, "⚡", Offset.zero, fontSize: 16);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WorkshopPainter oldDelegate) => true;
}

const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle':
        "The Shape Shifter's Workshop: Decomposing and Composing Shapes",
    'appTitle': "The Shape Shifter's Workshop",
    'appSubtitle': "Class 6 • Area and Perimeter",
    'enterLab': "Enter Workshop",
    'resetBtn': "Reset Lab",
    'selectScenario': "Select Scenario",
    'objective': "Objective:",
    'stepLabel': "STEP",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully decomposed and composed complex shapes to find their area!",

    's1_title': "1. The L-Shaped Lawn",
    's1_obj':
        "Find the area of an L-shaped lawn by decomposing it into two rectangles.",
    's1_step1_task':
        "DRAG the 'Laser Cutter' along the dotted line to slice the lawn into two pieces.",
    's1_step1_out': "The shape is split into two rectangles.",
    's1_step2_task':
        "DRAG the taller rectangle (Part A) onto the Analysis Pad.",
    's1_step2_out': "Part A is 3x10. Area = 30 sq units.",
    's1_step3_task': "DRAG the wider rectangle (Part B) onto the Analysis Pad.",
    's1_step3_out': "Part B is 8x4. Area = 32 sq units.",
    's1_step4_task': "CLICK the 'Calculate' button in the Total Area box.",
    's1_step4_out': "Adding parts gives total area: 62 sq units.",
    's1_hud1': "Slice the L-shaped lawn with the Laser Cutter.",
    's1_hud2': "Drag Part A to the Analysis Pad.",
    's1_hud3': "Drag Part B to the Analysis Pad.",
    's1_hud4': "Click Calculate.",

    's2_title': "2. The Window Wall",
    's2_obj':
        "Find the paintable area of a wall by subtracting the area of a window.",
    's2_step1_task': "DRAG the entire wall onto the 'Analysis Pad'.",
    's2_step1_out': "Total Wall Area = 10x6 = 60 sq units.",
    's2_step2_task': "CLICK the window, then CLICK the 'Subtract' button.",
    's2_step2_out': "The window is punched out.",
    's2_step3_task': "DRAG the isolated window to the Analysis Pad.",
    's2_step3_out': "Window Area = 3x2 = 6 sq units.",
    's2_step4_task': "CLICK the 'Calculate' button in the Total Area box.",
    's2_step4_out': "The paintable area is 60 - 6 = 54 sq units.",
    's2_hud1': "Drag the entire wall to the Analysis Pad.",
    's2_hud2': "Click the window, then Subtract.",
    's2_hud3': "Drag window to the Pad.",
    's2_hud4': "Click Calculate.",

    's3_title': "3. Blueprint Breakdown",
    's3_obj':
        "Find the total living area by composing the areas of individual rooms.",
    's3_step1_task': "CLICK on the Bedroom to analyze its area.",
    's3_step1_out': "Bedroom Area = 4x5 = 20 sq m.",
    's3_step2_task': "CLICK on the Kitchen to analyze its area.",
    's3_step2_out': "Kitchen Area = 4x3 = 12 sq m.",
    's3_step3_task': "CLICK on the Hall to analyze its area.",
    's3_step3_out': "Hall Area = 6x8 = 48 sq m.",
    's3_step4_task': "CLICK the 'Calculate' button.",
    's3_step4_out': "Total House Area = 20 + 12 + 48 = 80 sq m.",
    's3_hud1': "Click the Bedroom.",
    's3_hud2': "Click the Kitchen.",
    's3_hud3': "Click the Hall.",
    's3_hud4': "Click Calculate.",

    's4_title': "4. Community Park Puzzle",
    's4_obj': "Find the total area of a plus-sign-shaped park.",
    's4_step1_task':
        "DRAG the Laser Cutter over the dotted lines to decompose the park.",
    's4_step1_out': "Park successfully decomposed.",
    's4_step2_task': "DRAG each of the 5 sections to the Analysis Pad.",
    's4_step2_out': "All parts analyzed.",
    's4_step3_task': "CLICK the 'Check My Answer' button.",
    's4_step3_out': "Total area calculated correctly!",
    's4_hud1': "Cut the park into rectangles using the Laser Cutter.",
    's4_hud2': "Analyze the area of ALL 5 sections on the pad.",
    's4_hud3': "Check your answer.",

    's5_title': "5. The Tangram Challenge",
    's5_obj': "Create a shape using tangram pieces and determine its area.",
    's5_step1_task': "DRAG the 7 tangram pieces to fill the cat silhouette.",
    's5_step1_out': "Cat assembled successfully.",
    's5_step2_task': "Click each piece to assign its relative area.",
    's5_step2_out': "Areas assigned correctly.",
    's5_step3_task': "CLICK 'Calculate' to find the total area.",
    's5_step3_out': "Total relative area is 16 square units.",
    's5_hud1': "Assemble the tangram pieces into a cat.",
    's5_hud2': "Set the area for each piece.",
    's5_hud3': "Calculate Total Area.",
  },
  'hi': {
    'shutterTitle': "आकार बदलने वाले की कार्यशाला: क्षेत्रफल खोजना",
    'appTitle': "आकार बदलने वाले की कार्यशाला",
    'appSubtitle': "कक्षा 6 • क्षेत्रफल",
    'enterLab': "कार्यशाला में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'resetBtn': "रीसेट करें",
    'objective': "उद्देश्य:",
    'stepLabel': "चरण",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने जटिल आकृतियों का क्षेत्रफल ज्ञात करना सफलतापूर्वक सीख लिया है!",

    's1_title': "1. एल-आकार का लॉन",
    's1_obj':
        "एल-आकार के लॉन को दो आयतों में विभाजित करके उसका क्षेत्रफल ज्ञात करें।",
    's1_step1_task': "लॉन को काटने के लिए लेजर कटर को बिंदीदार रेखा पर खींचें।",
    's1_step1_out':
        "आकृति सफलतापूर्वक दो आयताकार आकृतियों में विभाजित हो गई है।",
    's1_step2_task': "लंबे आयत (भाग ए) को विश्लेषण पैड पर खींचें।",
    's1_step2_out': "भाग ए 3x10 है। क्षेत्रफल = 30 वर्ग इकाइयाँ।",
    's1_step3_task': "चौड़े आयत (भाग बी) को विश्लेषण पैड पर खींचें।",
    's1_step3_out': "भाग बी 8x4 है। क्षेत्रफल = 32 वर्ग इकाइयाँ।",
    's1_step4_task': "कुल क्षेत्रफल बॉक्स में 'गणना करें' बटन पर क्लिक करें।",
    's1_step4_out': "कुल क्षेत्रफल प्राप्त होता है: 62 वर्ग इकाइयाँ।",
    's1_hud1': "लेजर कटर से लॉन को काटें।",
    's1_hud2': "भाग ए को पैड पर लाएं।",
    's1_hud3': "भाग बी को पैड पर लाएं।",
    's1_hud4': "गणना पर क्लिक करें।",

    's2_title': "2. खिड़की वाली दीवार",
    's2_obj': "खिड़की के क्षेत्रफल को घटाकर दीवार का क्षेत्रफल ज्ञात करें।",
    's2_step1_task': "पूरी दीवार को विश्लेषण पैड पर खींचें।",
    's2_step1_out': "कुल दीवार क्षेत्रफल = 60 वर्ग इकाइयाँ।",
    's2_step2_task': "खिड़की पर क्लिक करें, फिर घटाएं बटन पर क्लिक करें।",
    's2_step2_out': "खिड़की बाहर निकल गई है।",
    's2_step3_task': "अलग की गई खिड़की को विश्लेषण पैड पर खींचें।",
    's2_step3_out': "खिड़की क्षेत्रफल = 6 वर्ग इकाइयाँ।",
    's2_step4_task': "गणना करें बटन पर क्लिक करें।",
    's2_step4_out': "पेंट करने योग्य क्षेत्रफल 60 - 6 = 54 वर्ग इकाइयाँ है।",
    's2_hud1': "दीवार को पैड पर लाएं।",
    's2_hud2': "खिड़की पर क्लिक करें, फिर घटाएं।",
    's2_hud3': "खिड़की को पैड पर लाएं।",
    's2_hud4': "गणना पर क्लिक करें।",

    's3_title': "3. ब्लूप्रिंट विश्लेषण",
    's3_obj':
        "अलग-अलग कमरों के क्षेत्रफल को जोड़कर कुल रहने का क्षेत्रफल ज्ञात करें।",
    's3_step1_task': "बेडरूम पर क्लिक करें।",
    's3_step1_out': "बेडरूम क्षेत्रफल = 20 वर्ग मीटर।",
    's3_step2_task': "रसोई पर क्लिक करें।",
    's3_step2_out': "रसोई क्षेत्रफल = 12 वर्ग मीटर।",
    's3_step3_task': "हॉल पर क्लिक करें।",
    's3_step3_out': "हॉल क्षेत्रफल = 48 वर्ग मीटर।",
    's3_step4_task': "गणना करें बटन पर क्लिक करें।",
    's3_step4_out': "कुल घर का क्षेत्रफल = 80 वर्ग मीटर।",
    's3_hud1': "बेडरूम पर क्लिक करें।",
    's3_hud2': "रसोई पर क्लिक करें।",
    's3_hud3': "हॉल पर क्लिक करें।",
    's3_hud4': "गणना पर क्लिक करें।",

    's4_title': "4. कम्युनिटी पार्क पहेली",
    's4_obj': "प्लस-आकार के पार्क का कुल क्षेत्रफल ज्ञात करें।",
    's4_step1_task': "पार्क को आयतों में विभाजित करने के लिए लेजर कटर खींचें।",
    's4_step1_out': "पार्क सफलतापूर्वक विभाजित।",
    's4_step2_task': "सभी 5 वर्गों को विश्लेषण पैड पर खींचें।",
    's4_step2_out': "सभी भागों का विश्लेषण किया गया।",
    's4_step3_task': "अपना उत्तर जांचें बटन पर क्लिक करें।",
    's4_step3_out': "कुल क्षेत्रफल की सही गणना की गई!",
    's4_hud1': "पार्क को आयतों में काटें।",
    's4_hud2': "पैड पर सभी 5 अनुभागों का विश्लेषण करें।",
    's4_hud3': "अपना उत्तर जांचें।",

    's5_title': "5. टैंग्राम चुनौती",
    's5_obj':
        "टैंग्राम टुकड़ों का उपयोग करके एक आकृति बनाएं और उसका क्षेत्रफल निर्धारित करें।",
    's5_step1_task': "बिल्ली को भरने के लिए टैंग्राम टुकड़ों को खींचें।",
    's5_step1_out': "बिल्ली सफलतापूर्वक बन गई।",
    's5_step2_task':
        "क्षेत्रफल निर्धारित करने के लिए प्रत्येक टुकड़े पर क्लिक करें।",
    's5_step2_out': "क्षेत्रफल सौंपा गया।",
    's5_step3_task': "गणना करें पर क्लिक करें।",
    's5_step3_out': "कुल क्षेत्रफल 16 वर्ग इकाइयाँ है।",
    's5_hud1': "टुकड़ों को बिल्ली में इकट्ठा करें।",
    's5_hud2': "प्रत्येक टुकड़े के लिए क्षेत्रफल सेट करें।",
    's5_hud3': "कुल क्षेत्रफल की गणना करें।",
  },
};
