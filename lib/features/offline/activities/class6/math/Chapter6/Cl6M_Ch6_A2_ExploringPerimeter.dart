// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Exploring Perimeter',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1320),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch6_A2_ExploringPerimeter(),
    ),
  );
}

// --- DATA MODELS ---

class PointTile {
  int x;
  int y;
  PointTile(this.x, this.y);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointTile &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class DragOrigin {
  final String type; // 'inv', 'grid', 's1_node'
  final int? originalX;
  final int? originalY;
  DragOrigin(this.type, {this.originalX, this.originalY});
}

// --- MAIN SCREEN ---

class Cl6M_Ch6_A2_ExploringPerimeter extends StatefulWidget {
  const Cl6M_Ch6_A2_ExploringPerimeter({super.key});

  @override
  State<Cl6M_Ch6_A2_ExploringPerimeter> createState() =>
      _Cl6M_Ch6_A2_ExploringPerimeterState();
}

class _Cl6M_Ch6_A2_ExploringPerimeterState
    extends State<Cl6M_Ch6_A2_ExploringPerimeter>
    with TickerProviderStateMixin {
  // --- SYSTEM & LAYOUT STATE ---
  bool _isCurtainUp = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  String _currentLang = 'en';

  // --- AUDIO ENGINE ---
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playSound(String type) async {
    try {
      String url = '';
      switch (type) {
        case 'enter':
          url = 'audio/class6/math/click.mp3';
          break;
        case 'tick':
          url = 'audio/class6/math/click.mp3';
          break;
        case 'snap':
          url = 'audio/class6/math/click.mp3';
          break;
        case 'success':
          url = 'audio/class6/math/success.mp3';
          break;
        case 'error':
          url = 'audio/class6/math/error.mp3';
          break;
        case 'pop':
          url = 'audio/class6/math/mixkit_1114.mp3';
          break;
      }
      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  // --- LAB STATE ---
  int _scenario = 1;
  int _step = 0;
  bool _showSuccessPopup = false;

  // View state
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  bool _isPanMode = false;
  double _initialZoom = 1.0;
  final GlobalKey _canvasKey = GlobalKey();

  // Sim state
  final int _gridSize = 45;
  int _s1w = 4;
  int _s1h = 4;
  List<PointTile> _tiles = [];
  int _invCount = 0;
  int _maxPerimeter = 0;
  int _minPerimeter = 9999;

  // Drag State
  String? _activeDragType;
  DragOrigin? _dragOrigin;
  Offset _dragWorldPos = Offset.zero;

  // Render Loop
  late AnimationController _gameLoop;
  double _measuringTapeOffset = 0.0;

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
    _gameLoop.addListener(() {
      setState(() {
        _measuringTapeOffset -= 1.0;
        if (_measuringTapeOffset <= -20) _measuringTapeOffset = 0;
      });
    });

    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- LOGIC HELPERS ---

  Map<String, dynamic> _getPerimeterData(List<PointTile> tiles) {
    Map<String, int> edgeMap = {};
    for (var t in tiles) {
      List<String> edges = [
        '${t.x},${t.y}-${t.x + 1},${t.y}', // top
        '${t.x + 1},${t.y}-${t.x + 1},${t.y + 1}', // right
        '${t.x},${t.y + 1}-${t.x + 1},${t.y + 1}', // bottom
        '${t.x},${t.y}-${t.x},${t.y + 1}', // left
      ];
      for (var e in edges) {
        edgeMap[e] = (edgeMap[e] ?? 0) + 1;
      }
    }
    List<String> boundary = [];
    int perimeter = 0;
    edgeMap.forEach((e, count) {
      if (count == 1) {
        perimeter++;
        boundary.add(e);
      }
    });
    return {'perimeter': perimeter, 'boundary': boundary};
  }

  Map<String, bool> _checkIsConnectedAndRectangular(List<PointTile> tiles) {
    if (tiles.isEmpty) return {'connected': false, 'rect': false};
    int minX = 9999, maxX = -9999, minY = 9999, maxY = -9999;
    Set<String> tileSet = {};
    for (var t in tiles) {
      minX = math.min(minX, t.x);
      maxX = math.max(maxX, t.x);
      minY = math.min(minY, t.y);
      maxY = math.max(maxY, t.y);
      tileSet.add('${t.x},${t.y}');
    }
    int w = maxX - minX + 1;
    int h = maxY - minY + 1;
    bool isRect = (w * h == tiles.length);

    // DFS
    Set<String> visited = {};
    List<PointTile> stack = [tiles[0]];
    visited.add('${tiles[0].x},${tiles[0].y}');
    while (stack.isNotEmpty) {
      var cur = stack.removeLast();
      List<PointTile> neighbors = [
        PointTile(cur.x + 1, cur.y),
        PointTile(cur.x - 1, cur.y),
        PointTile(cur.x, cur.y + 1),
        PointTile(cur.x, cur.y - 1),
      ];
      for (var n in neighbors) {
        String k = '${n.x},${n.y}';
        if (tileSet.contains(k) && !visited.contains(k)) {
          visited.add(k);
          stack.add(n);
        }
      }
    }
    return {'connected': visited.length == tiles.length, 'rect': isRect};
  }

  bool _isValidPlacement(int gx, int gy) {
    if (_tiles.any((t) => t.x == gx && t.y == gy)) return false; // Overlap
    if (_tiles.isNotEmpty) {
      bool touches = _tiles.any(
        (t) =>
            ((t.x - gx).abs() == 1 && t.y == gy) ||
            ((t.y - gy).abs() == 1 && t.x == gx),
      );
      if (!touches) return false;
    }
    if (_scenario == 3) {
      if (_step == 1 && gx == 3 && gy == 2) {
        return false; // Prevent early inlet fill
      }
      if (_step == 2 && (gx != 3 || gy != 2)) {
        return false; // Must ONLY fill inlet
      }
    }
    return true;
  }

  // --- ACTIONS ---

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _activeDragType = null;
      _showSuccessPopup = false;
      _pan = Offset.zero;
      _zoom = 1.0;

      if (_scenario == 1) {
        _s1w = 4;
        _s1h = 4;
      } else if (_scenario == 2) {
        _tiles = [PointTile(3, 3)];
        _invCount = 2;
      } else if (_scenario == 3) {
        _tiles = [
          PointTile(2, 2),
          PointTile(2, 3),
          PointTile(3, 3),
          PointTile(4, 3),
          PointTile(4, 2),
        ];
        _invCount = 1;
      } else if (_scenario == 4) {
        _tiles = [];
        _invCount = 12;
        _maxPerimeter = 0;
      } else if (_scenario == 5) {
        _tiles = [];
        _invCount = 12;
        _minPerimeter = 9999;
      }
    });
    _playSound('pop');
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
    _playSound('success');
    _checkAutoSuccess();
  }

  void _checkAutoSuccess() {
    int maxSteps = _getScenarioConfig(_scenario)['steps'].length;
    if ((_scenario == 1 && _step == 2) ||
        (_scenario == 2 && _step == 2) ||
        (_scenario == 4 && _step == 1) ||
        (_scenario == 5 && _step == 1)) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _step = maxSteps;
            _showFinalPopup();
          });
        }
      });
    } else if (_scenario == 3 && _step == 3) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _step = maxSteps;
          });
        }
      });
    }
  }

  void _showFinalPopup() {
    setState(() {
      _showSuccessPopup = true;
    });
    _playSound('success');
  }

  void _handleReset() {
    _playSound('error');
    setState(() {
      _isCurtainUp = false;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _isPanMode = false;
          _loadScenario(1);
          setState(() {
            _isCurtainUp = true;
          });
        }
      });
    });
  }

  // --- GESTURES & HIT TESTING ---

  Offset _getWorldPos(Offset localPos) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    Size size = box.size;
    double cx = size.width / 2 + _pan.dx;
    double cy = size.height / 2 + _pan.dy;
    return Offset((localPos.dx - cx) / _zoom, (localPos.dy - cy) / _zoom);
  }

  bool _hitTestBox(Rect bounds, Offset pt) {
    return bounds.contains(pt);
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    double dx = pt.dx - cx;
    double dy = pt.dy - cy;
    return (dx * dx + dy * dy) <= r * r;
  }

  // Handlers for Tap events directly hitting UI buttons
  void _onTapUp(TapUpDetails details) {
    Offset pt = _getWorldPos(details.localPosition);

    if (_scenario == 1) {
      double u = 45;
      double offsetX = -150;
      double offsetY = -100;
      if (_step == 2 &&
          _hitTestBox(
            Rect.fromLTWH(offsetX + 8 * u + 20, offsetY, 100, 40),
            pt,
          )) {
        setState(() {
          _s1w = 4;
          _s1h = 4;
        });
        _playSound('pop');
        return;
      }
    } else {
      double u = _gridSize.toDouble();
      int cols = _scenario > 3 ? 15 : 12;
      int rows = _scenario > 3 ? 9 : 8;
      double offsetX = -(cols * u) / 2;
      double offsetY = -(rows * u) / 2 - 40;
      double pnlX = offsetX + (cols * u) / 2 - 120;
      double pnlY = offsetY - 70;

      if (_scenario == 2 &&
          _step == 1 &&
          _hitTestBox(Rect.fromLTWH(pnlX + 260, pnlY + 5, 120, 40), pt)) {
        _advanceStep();
        return;
      }
      if (_scenario == 3) {
        if (_step == 0 &&
            _hitTestBox(Rect.fromLTWH(pnlX + 260, pnlY + 5, 120, 40), pt)) {
          _advanceStep();
          return;
        }
        if (_step == 2 &&
            _invCount == 0 &&
            _hitTestBox(Rect.fromLTWH(pnlX - 100, pnlY + 5, 80, 40), pt)) {
          setState(() {
            _tiles.removeLast();
            _invCount = 1;
          });
          _playSound('pop');
          return;
        }
        if (_step == 3 &&
            _hitTestBox(Rect.fromLTWH(pnlX + 260, pnlY + 5, 120, 40), pt)) {
          _advanceStep();
          _checkAutoSuccess();
          return;
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    Offset pt = _getWorldPos(details.localFocalPoint);
    _isPanMode = false;
    _activeDragType = null;
    _initialZoom = _zoom;

    if (details.pointerCount > 1) {
      _isPanMode = true;
      return;
    }

    if (_scenario == 1) {
      if (_step < 3) {
        double u = 45;
        double offsetX = -150;
        double offsetY = -100;
        if (_hitTestCircle(offsetX + _s1w * u, offsetY + _s1h * u, 25, pt)) {
          _activeDragType = 's1_node';
          _dragWorldPos = pt;
          _playSound('tick');
          return;
        }
      }
    } else {
      double u = _gridSize.toDouble();
      int cols = _scenario > 3 ? 15 : 12;
      int rows = _scenario > 3 ? 9 : 8;
      double offsetX = -(cols * u) / 2;
      double offsetY = -(rows * u) / 2 - 40;

      // Inventory Hit
      if (_invCount > 0) {
        bool isActive = true;
        if (_scenario == 2 && _step == 1) isActive = false;
        if (_scenario == 3 && (_step == 0 || _step == 3 || _step == 4)) {
          isActive = false;
        }

        double boxY = offsetY + (rows * u) + 30;
        if (_hitTestBox(Rect.fromLTWH(-150, boxY, 90, 90), pt)) {
          if (!isActive) {
            _playSound('error');
            return;
          }
          _activeDragType = 'tile';
          _dragOrigin = DragOrigin('inv');
          _dragWorldPos = pt;
          _playSound('tick');
          return;
        }
      }

      // Grid Tile Hit (S4/S5)
      if (_scenario > 3) {
        for (int i = 0; i < _tiles.length; i++) {
          var t = _tiles[i];
          if (_hitTestBox(
            Rect.fromLTWH(offsetX + t.x * u, offsetY + t.y * u, u, u),
            pt,
          )) {
            setState(() {
              _tiles.removeAt(i);
              _activeDragType = 'tile';
              _dragOrigin = DragOrigin('grid', originalX: t.x, originalY: t.y);
              _dragWorldPos = pt;
            });
            _playSound('tick');
            return;
          }
        }
      }
    }

    // If nothing draggable is hit, default to pan/zoom mode
    _isPanMode = true;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_activeDragType != null) {
      Offset pt = _getWorldPos(details.localFocalPoint);
      setState(() {
        _dragWorldPos = pt;
        if (_activeDragType == 's1_node') {
          double u = 45;
          double offsetX = -150;
          int targetW = ((pt.dx - offsetX) / u).round();
          targetW = targetW.clamp(1, 7);
          if (_s1w != targetW) {
            _s1w = targetW;
            _s1h = 8 - targetW;
            _playSound('tick');
          }
        }
      });
      return;
    }

    if (_isPanMode) {
      setState(() {
        // Correctly accumulate the drag delta on the pan offset
        _pan += details.focalPointDelta;

        if (details.scale != 1.0) {
          _zoom = (_initialZoom * details.scale).clamp(0.4, 3.0);
        }
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_activeDragType == 's1_node') {
      if (_step == 0) {
        _advanceStep();
      } else if (_step == 1 && _s1w == 5 && _s1h == 3) {
        _advanceStep();
      } else if (_step == 2 && _s1w == 4 && _s1h == 4) {
        _advanceStep();
        _checkAutoSuccess();
      }
      setState(() {
        _activeDragType = null;
      });
      _playSound('snap');
      return;
    }

    if (_activeDragType == 'tile') {
      double u = _gridSize.toDouble();
      int cols = _scenario > 3 ? 15 : 12;
      int rows = _scenario > 3 ? 9 : 8;
      double offsetX = -(cols * u) / 2;
      double offsetY = -(rows * u) / 2 - 40;

      int gridX = ((_dragWorldPos.dx - offsetX - u / 2) / u).round();
      int gridY = ((_dragWorldPos.dy - offsetY - u / 2) / u).round();

      if (_isValidPlacement(gridX, gridY)) {
        setState(() {
          _tiles.add(PointTile(gridX, gridY));
          if (_dragOrigin?.type == 'inv') _invCount--;
        });
        _playSound('snap');

        int p = _getPerimeterData(_tiles)['perimeter'] as int;

        if (_scenario == 2) {
          if (_step == 0 && _tiles.length == 2) _advanceStep();
          if (_step == 2 && _tiles.length == 3) {
            _advanceStep();
            _checkAutoSuccess();
          }
        }
        if (_scenario == 3) {
          if (_step == 1 && p == 14) _advanceStep();
          if (_step == 2 && p == 10) _advanceStep();
        }
        if (_scenario == 4 && _tiles.length == 12) {
          var check = _checkIsConnectedAndRectangular(_tiles);
          if (check['connected'] == true && check['rect'] == true) {
            setState(() {
              _maxPerimeter = math.max(_maxPerimeter, p);
            });
            if (p == 26) {
              _advanceStep();
              _checkAutoSuccess();
            }
          }
        }
        if (_scenario == 5 && _tiles.length == 12) {
          var check = _checkIsConnectedAndRectangular(_tiles);
          if (check['connected'] == true && check['rect'] == true) {
            setState(() {
              _minPerimeter = math.min(_minPerimeter, p);
            });
            if (p == 14) {
              _advanceStep();
              _checkAutoSuccess();
            }
          }
        }
      } else {
        _playSound('error');
        if (_dragOrigin?.type == 'grid') {
          setState(() {
            _tiles.add(
              PointTile(_dragOrigin!.originalX!, _dragOrigin!.originalY!),
            );
          });
        }
      }
      setState(() {
        _activeDragType = null;
      });
    }

    _isPanMode = false;
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: _buildCanvasArea(),
            ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // Resizer Handle (Right edge of sidebar)
            if (_isSidebarOpen)
              Positioned(
                left: _sidebarWidth - 10,
                top: 0,
                bottom: 0,
                width: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        _sidebarWidth += details.delta.dx;
                        _sidebarWidth = _sidebarWidth.clamp(
                          300.0,
                          MediaQuery.of(context).size.width * 0.6,
                        );
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.white24, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Floating Menu Button (Always pinned top left)
            Positioned(
              top: 16,
              left: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                    _playSound('tick');
                  },
                ),
              ),
            ),

            // Success Overlay
            if (_showSuccessPopup) _buildSuccessPopup(),

            // Curtain Screen
            if (!_isCurtainUp) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      color: const Color(
        0xFF0B1320,
      ), // Forces the complete background to dark theme
      child: Stack(
        children: [
          // Interactive Canvas
          Positioned.fill(
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              onTapUp: _onTapUp, // Captures quick button clicks natively
              child: ClipRect(
                child: CustomPaint(
                  key: _canvasKey,
                  painter: LabPainter(
                    scenario: _scenario,
                    step: _step,
                    zoom: _zoom,
                    pan: _pan,
                    s1w: _s1w,
                    s1h: _s1h,
                    tiles: _tiles,
                    invCount: _invCount,
                    maxPerimeter: _maxPerimeter,
                    minPerimeter: _minPerimeter,
                    activeDragType: _activeDragType,
                    dragWorldPos: _dragWorldPos,
                    measuringTapeOffset: _measuringTapeOffset,
                    langData: _i18n[_currentLang]!,
                  ),
                ),
              ),
            ),
          ),

          // Instruction HUD (Bottom Center)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _step < _getScenarioConfig(_scenario)['steps'].length
                      ? 1.0
                      : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(
                        top: BorderSide(color: Colors.indigoAccent, width: 4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
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
                            _step <
                                    _getScenarioConfig(
                                      _scenario,
                                    )['steps'].length
                                ? _getScenarioConfig(
                                    _scenario,
                                  )['steps'][_step]['hud']!
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
    );
  }

  Widget _buildSidebar() {
    var lang = _i18n[_currentLang]!;
    var config = _getScenarioConfig(_scenario);

    return Container(
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Completely Scrollable Content (Header + Body)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.only(
                      top: 66,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.extension,
                            color: Colors.indigoAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['appTitle']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang['appSubtitle']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Language Toggle & Reset Controls Below Subtitle
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _currentLang = _currentLang == 'en'
                                            ? 'hi'
                                            : 'en';
                                      });
                                      _playSound('pop');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _currentLang.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: _handleReset,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.refresh,
                                        color: Colors.redAccent,
                                        size: 16,
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

                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang['selectScenario']!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _scenario,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              items: [1, 2, 3, 4, 5]
                                  .map(
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(lang['s${i}_title']!),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) _loadScenario(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Objective Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.5),
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
                                    color: Colors.pinkAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    lang['learnLbl']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                config['objective'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.4,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Steps List
                        ...List.generate(
                          config['steps'].length,
                          (i) => _buildStepItem(i, config['steps'][i], lang),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF020617),
            alignment: Alignment.center,
            child: const Text(
              '© ZEROSCIENCELAB | Fall in Love with Math and Science',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int index,
    Map<String, String> step,
    Map<String, String> lang,
  ) {
    bool isPast = index < _step;
    bool isCurrent = index == _step;
    bool isFuture = index > _step;

    Color bgColor = isCurrent
        ? Colors.indigo.withOpacity(0.15)
        : (isPast ? const Color(0xFF0F172A) : Colors.transparent);
    Color borderColor = isCurrent
        ? Colors.indigoAccent
        : (isPast ? Colors.white12 : Colors.transparent);
    double opacity = isFuture ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isPast
                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.indigoAccent : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lang['stepLabel']!} ${index + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['task']!,
                    style: TextStyle(
                      color: isCurrent ? Colors.indigoAccent : Colors.white70,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  if (isPast) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: '${lang['learnLbl']!} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: step['outcome']),
                          ],
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

  Widget _buildCurtain() {
    var lang = _i18n[_currentLang]!;
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.extension, size: 80, color: Colors.indigoAccent),
            const SizedBox(height: 24),
            Text(
              lang['shutterTitle']!,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              lang['appSubtitle']!,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.indigoAccent.withOpacity(0.5),
              ),
              onPressed: () {
                _playSound('enter');
                setState(() {
                  _isCurtainUp = true;
                });
              },
              icon: const Icon(Icons.play_circle_fill, size: 28),
              label: Text(
                lang['enterLab']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    var lang = _i18n[_currentLang]!;
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: 400,
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
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.greenAccent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lang['summaryTitle']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang['finalDesc']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _scenario < 5
                        ? Colors.indigoAccent
                        : Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_scenario < 5) {
                      _loadScenario(_scenario + 1);
                    } else {
                      _handleReset();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _scenario < 5
                            ? lang['nextScenario']!
                            : lang['finishLab']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(_scenario < 5 ? Icons.arrow_forward : Icons.check),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- LOCALIZATION DATA ---
  Map<String, dynamic> _getScenarioConfig(int id) {
    var lang = _i18n[_currentLang]!;
    int numSteps = [0, 4, 4, 5, 1, 1][id];
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': lang['s${id}_hud$i'] ?? '',
        'task': lang['s${id}_step${i}_task'] ?? '',
        'outcome': lang['s${id}_step${i}_out'] ?? '',
      });
    }
    return {
      'title': lang['s${id}_title'],
      'objective': lang['s${id}_obj'],
      'steps': steps,
    };
  }

  final Map<String, Map<String, String>> _i18n = {
    'en': {
      'shutterTitle': "Exploring Perimeter Changes",
      'appTitle': "Exploring Perimeter",
      'appSubtitle': "Class 6 • SHAPE MANIPULATION",
      'enterLab': "Enter Simulation",
      'selectScenario': "Select Scenario",
      'stepLabel': "STEP",
      'learnLbl': "Objective:",
      'summaryTitle': "Goal Reached!",
      'finishLab': "Finish Lab",
      'nextScenario': "Next Scenario",
      'finalDesc':
          "You have successfully explored perimeter changes using interactive shapes!",
      'lbl_drag': "DRAG",
      'lbl_reset': "RESET",
      'lbl_continue': "CONTINUE",
      'lbl_perimeter': "Perimeter",
      'lbl_units': "units",
      'lbl_max_p': "Largest Perimeter So Far",
      'lbl_min_p': "Smallest Perimeter So Far",
      'lbl_rect_err': "Must be a complete, connected rectangular shape!",

      's1_title': "1. The Magic Wire",
      's1_obj':
          "Understand that a fixed perimeter can be used to create different shapes.",
      's1_step1_task':
          "A glowing blue wire has a length of 16 units. DRAG the corner points.",
      's1_step1_out': "The wire changes shape, but the perimeter is always 16.",
      's1_step2_task':
          "DRAG the corner points and SNAP them onto the corners of the 5x3 rectangular outline.",
      's1_step2_out': "The same 16-unit wire forms a 5x3 rectangle.",
      's1_step3_task':
          "DRAG the corner points and SNAP them onto the 4x4 square outline.",
      's1_step3_out': "The same 16-unit wire forms a 4x4 square.",
      's1_step4_task': "Observe the conclusion.",
      's1_step4_out': "Shapes with the same perimeter can look very different!",
      's1hud1': "Drag the glowing node to change the rectangle's shape.",
      's1hud2': "Drag the node to match the 5x3 outline.",
      's1hud3': "Drag the node to match the 4x4 outline.",
      's1hud4': "Observe the conclusion.",

      's2_title': "2. The Growing Worm",
      's2_obj':
          "Observe how adding a square to a simple shape increases its perimeter.",
      's2_step1_task':
          "DRAG a new square from the inventory panel and SNAP it to any side of the first square.",
      's2_step1_out': "The perimeter changes from 4 to 6.",
      's2_step2_task': "Observe the calculation. Click CONTINUE when ready.",
      's2_step2_out': "Old Perimeter + 2 (New Sides) = New Perimeter.",
      's2_step3_task':
          "DRAG a third square from the inventory and SNAP it to the end of the shape.",
      's2_step3_out': "The perimeter grows to 8.",
      's2_step4_task': "Observe the pattern.",
      's2_step4_out':
          "Every time you add a square to the end of a line, the perimeter grows by 2 units!",
      's2_hud1':
          "Drag a square from the bottom inventory and snap it to the edge.",
      's2_hud2': "Observe the perimeter change and click Continue.",
      's2_hud3': "Drag a 3rd square and snap it to the end.",
      's2_hud4': "Observe the pattern.",

      's3_title': "3. The Shrinking Lake",
      's3_obj':
          "Discover that adding a square can decrease the perimeter if it fills an inner corner.",
      's3_step1_task':
          "Observe the perimeter of the U-shaped figure. Click CONTINUE.",
      's3_step1_out': "The starting perimeter is 12 units.",
      's3_step2_task':
          "DRAG a new square and SNAP it to one of the outer ends of the U-shape.",
      's3_step2_out': "The perimeter increased to 14.",
      's3_step3_task':
          "CLICK the 'Reset' button. Now, DRAG the new square and SNAP it into the 'inner corner' (inlet).",
      's3_step3_out': "The perimeter decreased to 10.",
      's3_step4_task': "Observe the calculation. Click CONTINUE.",
      's3_step4_out':
          "You covered 3 sides and only added 1 new one. The perimeter decreased by 2!",
      's3_step5_task': "Conclusion.",
      's3_step5_out':
          "By filling in an 'inlet', you made the boundary shorter. Adding a piece can make the perimeter smaller!",
      's3_hud1': "Observe the U-shape's perimeter (12). Click Continue.",
      's3_hud2': "Drag the tile to an outer end (top left or top right).",
      's3_hud3': "Click Reset, then drag the tile into the middle 'inlet'.",
      's3_hud4': "Observe the perimeter decrease.",
      's3_hud5': "Read the conclusion.",

      's4_title': "4. The Biggest Fence",
      's4_obj':
          "Discover that for a fixed area (12 tiles), a long, thin shape maximizes the perimeter.",
      's4_step1_task':
          "You have 12 tiles. DRAG and snap them to build a single, connected rectangular shape with the LARGEST perimeter.",
      's4_step1_out':
          "You discovered the 1x12 arrangement gives the highest perimeter (26).",
      's4_hud1':
          "Place all 12 tiles to form a perfect rectangle with the max perimeter.",

      's5_title': "5. The Smallest Fence",
      's5_obj':
          "Discover that for a fixed area (12 tiles), a compact, square-like shape minimizes the perimeter.",
      's5_step1_task':
          "You have 12 tiles. DRAG and snap them to build a single, connected rectangular shape with the SMALLEST perimeter.",
      's5_step1_out':
          "You discovered the 3x4 arrangement gives the lowest perimeter (14).",
      's5_hud1':
          "Place all 12 tiles to form a perfect rectangle with the minimum perimeter.",
    },
    'hi': {
      'shutterTitle': "परिमाप में परिवर्तन",
      'appTitle': "परिमाप की खोज",
      'appSubtitle': "कक्षा 6 • आकार हेरफेर",
      'enterLab': "सिमुलेशन दर्ज करें",
      'selectScenario': "परिदृश्य चुनें",
      'stepLabel': "चरण",
      'learnLbl': "उद्देश्य:",
      'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'finishLab': "समाप्त करें",
      'nextScenario': "अगला परिदृश्य",
      'finalDesc':
          "आपने इंटरैक्टिव आकृतियों का उपयोग करके परिमाप में परिवर्तन का सफलतापूर्वक पता लगाया है!",
      'lbl_drag': "खींचें",
      'lbl_reset': "रीसेट",
      'lbl_continue': "जारी रखें",
      'lbl_perimeter': "परिमाप",
      'lbl_units': "इकाई",
      'lbl_max_p': "अब तक का सबसे बड़ा परिमाप",
      'lbl_min_p': "अब तक का सबसे छोटा परिमाप",
      'lbl_rect_err': "एक पूर्ण, जुड़ा हुआ आयताकार आकार होना चाहिए!",

      's1_title': "1. जादुई तार",
      's1_obj':
          "समझें कि एक निश्चित परिमाप का उपयोग विभिन्न आकृतियाँ बनाने के लिए किया जा सकता है।",
      's1_step1_task':
          "एक चमकते नीले तार की लंबाई 16 इकाई है। कोने के बिंदुओं को खींचें।",
      's1_step1_out': "तार का आकार बदलता है, लेकिन परिमाप हमेशा 16 रहता है।",
      's1_step2_task':
          "कोने के बिंदुओं को 5x3 आयताकार रूपरेखा पर खींचें और स्नैप करें।",
      's1_step2_out': "वही 16-इकाई तार 5x3 का आयत बनाता है।",
      's1_step3_task':
          "कोने के बिंदुओं को 4x4 वर्गाकार रूपरेखा पर खींचें और स्नैप करें।",
      's1_step3_out': "वही 16-इकाई तार 4x4 का वर्ग बनाता है।",
      's1_step4_task': "निष्कर्ष देखें।",
      's1_step4_out': "समान परिमाप वाली आकृतियाँ बहुत अलग दिख सकती हैं!",
      's1hud1': "आयत का आकार बदलने के लिए चमकते नोड को खींचें।",
      's1hud2': "5x3 रूपरेखा से मेल खाने के लिए नोड को खींचें।",
      's1hud3': "4x4 रूपरेखा से मेल खाने के लिए नोड को खींचें।",
      's1hud4': "निष्कर्ष देखें।",

      's2_title': "2. बढ़ता हुआ कीड़ा",
      's2_obj':
          "देखें कि एक सरल आकार में वर्ग जोड़ने से इसका परिमाप कैसे बढ़ता है।",
      's2_step1_task':
          "इन्वेंट्री से एक नया वर्ग खींचें और इसे पहले वर्ग के किसी भी तरफ स्नैप करें।",
      's2_step1_out': "परिमाप 4 से 6 हो जाता है।",
      's2_step2_task': "गणना देखें। तैयार होने पर 'जारी रखें' पर क्लिक करें।",
      's2_step2_out': "पुराना परिमाप + 2 (नई भुजाएँ) = नया परिमाप।",
      's2_step3_task':
          "इन्वेंट्री से तीसरा वर्ग खींचें और इसे आकार के अंत में स्नैप करें।",
      's2_step3_out': "परिमाप 8 तक बढ़ जाता है।",
      's2_step4_task': "पैटर्न देखें।",
      's2_step4_out':
          "हर बार जब आप एक पंक्ति के अंत में एक वर्ग जोड़ते हैं, परिमाप 2 इकाई बढ़ जाता है!",
      's2_hud1':
          "नीचे इन्वेंट्री से एक वर्ग खींचें और उसे किनारे पर स्नैप करें।",
      's2_hud2': "परिमाप परिवर्तन देखें और जारी रखें पर क्लिक करें।",
      's2_hud3': "तीसरा वर्ग खींचें और इसे अंत में स्नैप करें।",
      's2_hud4': "पैटर्न देखें।",

      's3_title': "3. सिकुड़ती झील",
      's3_obj':
          "पता लगाएं कि वर्ग जोड़ने से परिमाप कम हो सकता है यदि वह एक भीतरी कोने को भरता है।",
      's3_step1_task':
          "U-आकार की आकृति का परिमाप देखें। 'जारी रखें' पर क्लिक करें।",
      's3_step1_out': "शुरुआती परिमाप 12 इकाई है।",
      's3_step2_task':
          "एक नया वर्ग खींचें और इसे U-आकार के बाहरी सिरों में से एक पर स्नैप करें।",
      's3_step2_out': "परिमाप बढ़कर 14 हो गया।",
      's3_step3_task':
          "'रीसेट' बटन पर क्लिक करें। अब, नया वर्ग खींचें और इसे 'भीतरी कोने' (इनलेट) में स्नैप करें।",
      's3_step3_out': "परिमाप घटकर 10 हो गया।",
      's3_step4_task': "गणना देखें। 'जारी रखें' पर क्लिक करें।",
      's3_step4_out':
          "आपने 3 भुजाओं को कवर किया और केवल 1 नई भुजा जोड़ी। परिमाप 2 से कम हो गया!",
      's3_step5_task': "निष्कर्ष।",
      's3_step5_out':
          "एक 'इनलेट' भरकर, आपने सीमा को छोटा कर दिया। एक टुकड़ा जोड़ने से परिमाप छोटा हो सकता है!",
      's3_hud1': "U-आकार का परिमाप (12) देखें। जारी रखें पर क्लिक करें।",
      's3_hud2': "टाइल को बाहरी सिरे पर खींचें।",
      's3_hud3': "रीसेट पर क्लिक करें, फिर टाइल को बीच 'इनलेट' में खींचें।",
      's3_hud4': "परिमाप में कमी देखें।",
      's3_hud5': "निष्कर्ष पढ़ें।",

      's4_title': "4. सबसे बड़ी बाड़",
      's4_obj':
          "डिस्कवर करें कि एक निश्चित क्षेत्र के लिए, एक लंबा, पतला आकार परिमाप को अधिकतम करता है।",
      's4_step1_task':
          "आपके पास 12 टाइलें हैं। सबसे बड़े परिमाप वाला आयताकार आकार बनाने के लिए उन्हें खींचें।",
      's4_step1_out': "1x12 व्यवस्था उच्चतम परिमाप (26) देती है।",
      's4_hud1': "अधिकतम परिमाप के साथ एक आयत बनाने के लिए सभी 12 टाइलें रखें।",

      's5_title': "5. सबसे छोटी बाड़",
      's5_obj':
          "डिस्कवर करें कि एक निश्चित क्षेत्र के लिए, एक वर्गाकार आकार परिमाप को कम करता है।",
      's5_step1_task':
          "आपके पास 12 टाइलें हैं। सबसे छोटे परिमाप वाला आयताकार आकार बनाने के लिए उन्हें खींचें।",
      's5_step1_out': "3x4 व्यवस्था सबसे कम परिमाप (14) देती है।",
      's5_hud1':
          "न्यूनतम परिमाप के साथ एक आयत बनाने के लिए सभी 12 टाइलें रखें।",
    },
  };
}

// --- CUSTOM PAINTER ---

class LabPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final Offset pan;
  final int s1w;
  final int s1h;
  final List<PointTile> tiles;
  final int invCount;
  final int maxPerimeter;
  final int minPerimeter;
  final String? activeDragType;
  final Offset dragWorldPos;
  final double measuringTapeOffset;
  final Map<String, String> langData;

  LabPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.pan,
    required this.s1w,
    required this.s1h,
    required this.tiles,
    required this.invCount,
    required this.maxPerimeter,
    required this.minPerimeter,
    required this.activeDragType,
    required this.dragWorldPos,
    required this.measuringTapeOffset,
    required this.langData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderScenario1(canvas);
    } else {
      _renderScenario2to5(canvas);
    }

    canvas.restore();
  }

  void _renderScenario1(Canvas canvas) {
    double u = 45;
    double offsetX = -150;
    double offsetY = -100;

    // Grid
    Paint gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    for (int i = 0; i <= 8; i++) {
      canvas.drawLine(
        Offset(offsetX + i * u, offsetY),
        Offset(offsetX + i * u, offsetY + 8 * u),
        gridPaint,
      );
    }
    for (int j = 0; j <= 8; j++) {
      canvas.drawLine(
        Offset(offsetX, offsetY + j * u),
        Offset(offsetX + 8 * u, offsetY + j * u),
        gridPaint,
      );
    }

    // Target Outlines
    if (step == 1) {
      _drawDashedRect(
        canvas,
        Rect.fromLTWH(offsetX, offsetY, 5 * u, 3 * u),
        Colors.white30,
      );
      _drawText(
        canvas,
        "5 x 3",
        Offset(offsetX + 2.5 * u, offsetY + 1.5 * u),
        fontSize: 24,
        color: Colors.white30,
      );
    } else if (step == 2) {
      _drawDashedRect(
        canvas,
        Rect.fromLTWH(offsetX, offsetY, 4 * u, 4 * u),
        Colors.white30,
      );
      _drawText(
        canvas,
        "4 x 4",
        Offset(offsetX + 2 * u, offsetY + 2 * u),
        fontSize: 24,
        color: Colors.white30,
      );
    }

    // Wire Rectangle
    Paint wireFill = Paint()
      ..color = Colors.blueAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    Paint wireStroke = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    Rect wRect = Rect.fromLTWH(offsetX, offsetY, s1w * u, s1h * u);
    canvas.drawRect(wRect, wireFill);
    canvas.drawRect(wRect, wireStroke);

    // Nodes
    List<Offset> pts = [
      Offset(0, 0),
      Offset(s1w.toDouble(), 0),
      Offset(0, s1h.toDouble()),
      Offset(s1w.toDouble(), s1h.toDouble()),
    ];
    for (int i = 0; i < pts.length; i++) {
      double px = offsetX + pts[i].dx * u;
      double py = offsetY + pts[i].dy * u;

      if (i == 3) {
        // Pulse
        double pulseRadius =
            18 + math.sin(DateTime.now().millisecondsSinceEpoch / 150) * 3;
        canvas.drawCircle(
          Offset(px, py),
          pulseRadius,
          Paint()
            ..color = Colors.amber.withOpacity(0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      Color nodeColor = (i == 3 && activeDragType == 's1_node')
          ? Colors.amber
          : Colors.white;
      canvas.drawCircle(Offset(px, py), 12, Paint()..color = nodeColor);
      canvas.drawCircle(
        Offset(px, py),
        12,
        Paint()
          ..color = Colors.blue[700]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // HUD Perimeter
    _drawPanel(
      canvas,
      Rect.fromLTWH(offsetX + 4 * u - 100, offsetY - 60, 200, 45),
      color: Colors.white,
    );
    _drawText(
      canvas,
      "${langData['lbl_perimeter']}: 16 ${langData['lbl_units']}",
      Offset(offsetX + 4 * u, offsetY - 38),
      color: Colors.blue[700]!,
      fontSize: 18,
    );

    if (step == 2) {
      _drawPanel(
        canvas,
        Rect.fromLTWH(offsetX + 8 * u + 20, offsetY, 100, 40),
        color: Colors.redAccent,
      );
      _drawText(
        canvas,
        langData['lbl_reset']!,
        Offset(offsetX + 8 * u + 70, offsetY + 20),
        color: Colors.white,
        fontSize: 14,
      );
    }
  }

  void _renderScenario2to5(Canvas canvas) {
    double u = 45;
    int cols = scenario > 3 ? 15 : 12;
    int rows = scenario > 3 ? 9 : 8;

    // Bounds for new styled grid layout
    double gridW = cols * u;
    double gridH = rows * u;
    double offsetX = -gridW / 2;
    double offsetY = -gridH / 2 - 40;

    // Draw bounded grid (slate box styled exactly like image)
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, gridW, gridH),
      Paint()..color = const Color(0xFF1E293B),
    );

    Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(
        Offset(offsetX + i * u, offsetY),
        Offset(offsetX + i * u, offsetY + gridH),
        gridPaint,
      );
    }
    for (int j = 0; j <= rows; j++) {
      canvas.drawLine(
        Offset(offsetX, offsetY + j * u),
        Offset(offsetX + gridW, offsetY + j * u),
        gridPaint,
      );
    }

    // Grid Tiles
    for (var t in tiles) {
      _drawSquareTile(
        canvas,
        offsetX + t.x * u,
        offsetY + t.y * u,
        u,
        const Color(0xFF6366F1),
      );
    }

    // Highlights
    if (scenario == 3 && step == 1 && activeDragType == null && invCount == 1) {
      _drawHighlightTile(
        canvas,
        offsetX + 2 * u,
        offsetY + 1 * u,
        u,
        Colors.green,
      );
      _drawHighlightTile(
        canvas,
        offsetX + 4 * u,
        offsetY + 1 * u,
        u,
        Colors.green,
      );
    }
    if (scenario == 3 && step == 2 && activeDragType == null && invCount == 1) {
      _drawHighlightTile(
        canvas,
        offsetX + 3 * u,
        offsetY + 2 * u,
        u,
        Colors.amber,
      );
    }

    // Perimeter Tape
    var pData = _getPerimeterDataFromPainter(tiles);
    if (pData['perimeter'] as int > 0) {
      _drawMeasuringTape(
        canvas,
        pData['boundary'] as List<String>,
        u,
        offsetX,
        offsetY,
      );
    }

    // Dragging Tile
    if (activeDragType == 'tile') {
      _drawSquareTile(
        canvas,
        dragWorldPos.dx - u / 2,
        dragWorldPos.dy - u / 2,
        u,
        const Color(0xFF6366F1).withOpacity(0.8),
      );

      // Snap Preview
      int gridX = ((dragWorldPos.dx - offsetX - u / 2) / u).round();
      int gridY = ((dragWorldPos.dy - offsetY - u / 2) / u).round();
      bool valid = _isValidPlacementLogic(gridX, gridY);
      canvas.drawRect(
        Rect.fromLTWH(offsetX + gridX * u, offsetY + gridY * u, u, u),
        Paint()
          ..color = valid ? Colors.green : Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Modern Bottom Layout exactly like the provided image
    double boxY = offsetY + gridH + 30;

    // Inventory/Drag Box (Left)
    Rect invRect = Rect.fromLTWH(-150, boxY, 90, 90);
    if (invCount > 0) {
      bool isActive =
          !(scenario == 2 && step == 1) &&
          !(scenario == 3 && (step == 0 || step == 3 || step == 4));
      canvas.saveLayer(
        null,
        Paint()..color = Colors.white.withOpacity(isActive ? 1.0 : 0.5),
      );
      _drawPanel(
        canvas,
        invRect,
        color: Colors.white,
        borderColor: Colors.transparent,
      );
      _drawSquareTile(
        canvas,
        invRect.left + 25,
        invRect.top + 15,
        40,
        Colors.grey.withOpacity(0.1),
        borderColor: Colors.grey.withOpacity(0.2),
      );
      _drawText(
        canvas,
        "DRAG",
        Offset(invRect.left + 45, invRect.top + 70),
        color: const Color(0xFF6366F1),
        fontSize: 14,
      );
      canvas.restore();
    }

    // Tiles Used Box (Center)
    Rect tilesRect = Rect.fromLTWH(-40, boxY, 90, 90);
    _drawPanel(
      canvas,
      tilesRect,
      color: Colors.white,
      borderColor: Colors.transparent,
    );
    _drawText(
      canvas,
      "Tiles Used:\n",
      Offset(tilesRect.left + 45, tilesRect.top + 25),
      color: Colors.blueGrey,
      fontSize: 12,
    );
    _drawText(
      canvas,
      "${tiles.length}",
      Offset(tilesRect.left + 45, tilesRect.top + 60),
      color: const Color(0xFF6366F1),
      fontSize: 28,
    );

    // Dynamic Perimeter Stats Box (Right)
    Rect perimRect = Rect.fromLTWH(70, boxY, 110, 90);
    _drawPanel(
      canvas,
      perimRect,
      color: Colors.white,
      borderColor: Colors.transparent,
    );
    if (scenario == 4) {
      _drawText(
        canvas,
        "Max: $maxPerimeter",
        Offset(perimRect.left + 55, perimRect.top + 20),
        color: Colors.blueGrey,
        fontSize: 10,
      );
    } else if (scenario == 5) {
      String val = minPerimeter == 9999 ? '--' : minPerimeter.toString();
      _drawText(
        canvas,
        "Min: $val",
        Offset(perimRect.left + 55, perimRect.top + 20),
        color: Colors.blueGrey,
        fontSize: 10,
      );
    } else {
      _drawText(
        canvas,
        "Perimeter",
        Offset(perimRect.left + 55, perimRect.top + 25),
        color: Colors.blueGrey,
        fontSize: 14,
      );
    }
    _drawText(
      canvas,
      "${pData['perimeter']}",
      Offset(perimRect.left + 55, perimRect.top + 65),
      color: const Color(0xFF6366F1),
      fontSize: 28,
    );

    // S2/S3 specific floating popups and buttons (Moved slightly to float cleanly above bottom elements)
    double pnlX = offsetX + (cols * u) / 2 - 120;
    double pnlY = offsetY - 70;
    Rect bubble = Rect.fromLTWH(-150, offsetY - 80, 300, 50);

    if (scenario == 2 && step == 1) {
      _drawSpeechBubble(
        canvas,
        "4 - 1 (covered) + 3 (new) = 6",
        bubble,
        pointTo: 'bottom',
      );
      _drawPanel(
        canvas,
        Rect.fromLTWH(pnlX + 260, pnlY + 5, 120, 40),
        color: Colors.blueAccent,
        borderColor: const Color(0xFF0F172A),
      );
      _drawText(
        canvas,
        langData['lbl_continue']!,
        Offset(pnlX + 320, pnlY + 25),
        color: Colors.white,
        fontSize: 14,
      );
    }
    if (scenario == 3) {
      if (step == 0) {
        _drawPanel(
          canvas,
          Rect.fromLTWH(pnlX + 260, pnlY + 5, 120, 40),
          color: Colors.blueAccent,
          borderColor: const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          langData['lbl_continue']!,
          Offset(pnlX + 320, pnlY + 25),
          color: Colors.white,
          fontSize: 14,
        );
      }
      if (step == 2 && invCount == 0) {
        _drawPanel(
          canvas,
          Rect.fromLTWH(pnlX - 100, pnlY + 5, 80, 40),
          color: Colors.redAccent,
          borderColor: const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          langData['lbl_reset']!,
          Offset(pnlX - 60, pnlY + 25),
          color: Colors.white,
          fontSize: 14,
        );
      }
      if (step == 3) {
        _drawSpeechBubble(
          canvas,
          "14 - 3 (covered) + 1 (new) = 10",
          bubble,
          pointTo: 'bottom',
        );
        _drawPanel(
          canvas,
          Rect.fromLTWH(pnlX + 260, pnlY + 5, 120, 40),
          color: Colors.blueAccent,
          borderColor: const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          langData['lbl_continue']!,
          Offset(pnlX + 320, pnlY + 25),
          color: Colors.white,
          fontSize: 14,
        );
      }
    }

    if ((scenario == 4 || scenario == 5) &&
        tiles.length == 12 &&
        activeDragType == null) {
      bool isRect = _checkRectHelper();
      if (!isRect) {
        _drawSpeechBubble(
          canvas,
          langData['lbl_rect_err']!,
          Rect.fromLTWH(-150, offsetY - 80, 300, 40),
          pointTo: 'bottom',
          bgColor: Colors.red[100]!,
          txtColor: Colors.red[900]!,
        );
      }
    }
  }

  // --- DRAWING UTILITIES ---

  void _drawSquareTile(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color fill, {
    Color borderColor = const Color(0xFF0F172A),
  }) {
    Rect rect = Rect.fromLTWH(x, y, size, size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 4, y + 4, size - 8, size - 8),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white30,
    );
  }

  void _drawHighlightTile(
    Canvas canvas,
    double x,
    double y,
    double size,
    Color color,
  ) {
    Rect rect = Rect.fromLTWH(x + 4, y + 4, size - 8, size - 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = color.withOpacity(0.3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawPanel(
    Canvas canvas,
    Rect rect, {
    required Color color,
    Color borderColor = const Color(0xFF0F172A),
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = color,
    );
    if (borderColor != Colors.transparent) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 16,
    Color color = Colors.black,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawSpeechBubble(
    Canvas canvas,
    String text,
    Rect bounds, {
    String pointTo = 'top',
    Color bgColor = const Color(0xFFFEF08A),
    Color txtColor = const Color(0xFF0F172A),
  }) {
    _drawPanel(canvas, bounds, color: bgColor, borderColor: Colors.transparent);
    Path arrow = Path();
    if (pointTo == 'top') {
      arrow.moveTo(bounds.left + 60, bounds.top + 3);
      arrow.lineTo(bounds.left + 70, bounds.top - 20);
      arrow.lineTo(bounds.left + 80, bounds.top + 3);
    } else if (pointTo == 'bottom') {
      arrow.moveTo(bounds.left + 60, bounds.bottom - 3);
      arrow.lineTo(bounds.left + 70, bounds.bottom + 20);
      arrow.lineTo(bounds.left + 80, bounds.bottom - 3);
    }
    canvas.drawPath(arrow, Paint()..color = bgColor);
    _drawText(
      canvas,
      text,
      Offset(bounds.left + bounds.width / 2, bounds.top + bounds.height / 2),
      color: txtColor,
      fontSize: 16,
    );
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Color color) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    double dash = 8, gap = 8;
    // Top
    for (double x = rect.left; x < rect.right; x += dash + gap) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(math.min(x + dash, rect.right), rect.top),
        paint,
      );
    }
    // Bottom
    for (double x = rect.left; x < rect.right; x += dash + gap) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(math.min(x + dash, rect.right), rect.bottom),
        paint,
      );
    }
    // Left
    for (double y = rect.top; y < rect.bottom; y += dash + gap) {
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.left, math.min(y + dash, rect.bottom)),
        paint,
      );
    }
    // Right
    for (double y = rect.top; y < rect.bottom; y += dash + gap) {
      canvas.drawLine(
        Offset(rect.right, y),
        Offset(rect.right, math.min(y + dash, rect.bottom)),
        paint,
      );
    }
  }

  void _drawMeasuringTape(
    Canvas canvas,
    List<String> boundary,
    double u,
    double offsetX,
    double offsetY,
  ) {
    Path path = Path();
    for (var edgeStr in boundary) {
      var parts = edgeStr.split('-');
      var p1 = parts[0].split(',');
      var p2 = parts[1].split(',');
      double x1 = offsetX + int.parse(p1[0]) * u;
      double y1 = offsetY + int.parse(p1[1]) * u;
      double x2 = offsetX + int.parse(p2[0]) * u;
      double y2 = offsetY + int.parse(p2[1]) * u;
      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
    }

    // Yellow Base
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeJoin = StrokeJoin.miter,
    );

    // Black dashes (Simulating offset using a custom drawing logic)
    Paint dashPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.miter;
    for (var edgeStr in boundary) {
      var parts = edgeStr.split('-');
      var p1 = parts[0].split(',');
      var p2 = parts[1].split(',');
      double x1 = offsetX + int.parse(p1[0]) * u;
      double y1 = offsetY + int.parse(p1[1]) * u;
      double x2 = offsetX + int.parse(p2[0]) * u;
      double y2 = offsetY + int.parse(p2[1]) * u;

      double dx = x2 - x1;
      double dy = y2 - y1;
      double len = math.sqrt(dx * dx + dy * dy);
      double ux = dx / len;
      double uy = dy / len;

      double dashLen = 10;
      double gapLen = 10;
      double cycle = dashLen + gapLen;
      double startOffset = measuringTapeOffset % cycle;
      if (startOffset < 0) startOffset += cycle;

      for (double d = -startOffset; d < len; d += cycle) {
        if (d + dashLen < 0) continue;
        double s = math.max(0.0, d);
        double e = math.min(len, d + dashLen);
        if (s < e) {
          canvas.drawLine(
            Offset(x1 + s * ux, y1 + s * uy),
            Offset(x1 + e * ux, y1 + e * uy),
            dashPaint,
          );
        }
      }
    }
  }

  // Logic replicas inside painter for quick checks
  Map<String, dynamic> _getPerimeterDataFromPainter(List<PointTile> tList) {
    Map<String, int> edgeMap = {};
    for (var t in tList) {
      List<String> edges = [
        '${t.x},${t.y}-${t.x + 1},${t.y}',
        '${t.x + 1},${t.y}-${t.x + 1},${t.y + 1}',
        '${t.x},${t.y + 1}-${t.x + 1},${t.y + 1}',
        '${t.x},${t.y}-${t.x},${t.y + 1}',
      ];
      for (var e in edges) {
        edgeMap[e] = (edgeMap[e] ?? 0) + 1;
      }
    }
    List<String> boundary = [];
    int perimeter = 0;
    edgeMap.forEach((e, count) {
      if (count == 1) {
        perimeter++;
        boundary.add(e);
      }
    });
    return {'perimeter': perimeter, 'boundary': boundary};
  }

  bool _isValidPlacementLogic(int gx, int gy) {
    if (tiles.any((t) => t.x == gx && t.y == gy)) return false;
    if (tiles.isNotEmpty) {
      if (!tiles.any(
        (t) =>
            ((t.x - gx).abs() == 1 && t.y == gy) ||
            ((t.y - gy).abs() == 1 && t.x == gx),
      )) {
        return false;
      }
    }
    if (scenario == 3) {
      if (step == 1 && gx == 3 && gy == 2) return false;
      if (step == 2 && (gx != 3 || gy != 2)) return false;
    }
    return true;
  }

  bool _checkRectHelper() {
    if (tiles.isEmpty) return false;
    int minX = 9999, maxX = -9999, minY = 9999, maxY = -9999;
    for (var t in tiles) {
      minX = math.min(minX, t.x);
      maxX = math.max(maxX, t.x);
      minY = math.min(minY, t.y);
      maxY = math.max(maxY, t.y);
    }
    return ((maxX - minX + 1) * (maxY - minY + 1)) == tiles.length;
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true; // Animates continuously
}
