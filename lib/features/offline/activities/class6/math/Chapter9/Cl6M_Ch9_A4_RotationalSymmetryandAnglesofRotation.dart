// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Rotational Symmetry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark slate
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotation(),
    ),
  );
}

// --- Data Models ---

class DragItem {
  final String id;
  final String type;
  final String source;
  final int index;
  DragItem({
    required this.id,
    required this.type,
    required this.source,
    this.index = -1,
  });
}

class BeltItem {
  final String id;
  final String type;
  double x;
  double y;
  String state; // 'belt', 'inspection', 'bin'
  BeltItem({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.state = 'belt',
  });
}

class ScenarioStep {
  final String hud;
  final String task;
  final String outcome;
  ScenarioStep({required this.hud, required this.task, required this.outcome});
}

class ScenarioConfig {
  final String title;
  final String objective;
  final List<ScenarioStep> steps;
  ScenarioConfig({
    required this.title,
    required this.objective,
    required this.steps,
  });
}

// --- Main Screen ---

class Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotation extends StatefulWidget {
  const Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotation({super.key});

  @override
  State<Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotation> createState() =>
      _Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotationState();
}

class _Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotationState
    extends State<Cl6M_Ch9_A4_RotationalSymmetryandAnglesofRotation>
    with TickerProviderStateMixin {
  // App State
  String _lang = 'en';
  bool _isCurtainUp = false;
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;

  // Canvas / Viewport State
  final GlobalKey _canvasKey = GlobalKey();
  double _zoom = 1.0;
  double _panX = 0;
  double _panY = 0;
  bool _isPanningCanvas = false;
  double _initialZoom = 1.0;

  // Game State
  int _scenario = 1;
  int _step = 0;

  DragItem? _dragItem;
  double _dragX = 0;
  double _dragY = 0;
  bool _shapePlaced = false;
  bool _pinPlaced = false;

  double _rotAngle = 0;
  double _accumulatedRot = 0;
  double _lastRotAngle = 0;
  int _orderCount = 0;
  List<bool> _matchesFound = List.filled(12, false);
  bool _manualRotActive = false;
  bool _isChecking = false;

  double _errorFlash = 0;
  double _successFlash = 0;
  int _lastBinTarget = -1;

  List<String?> _s4Slots = List.filled(5, null);

  List<BeltItem> _s5BeltItems = [];
  String? _s5InspectionItem;
  int _s5Score = 0;

  late AnimationController _ticker;

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _ticker.addListener(() {
      if (_successFlash > 0) _successFlash -= 2;
      if (_errorFlash > 0) _errorFlash -= 2;
      setState(() {});
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
    _ticker.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  // --- Audio Methods ---

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

  // --- App Logic ---

  String t(String key) {
    return _translations[_lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  void _toggleLanguage() {
    playClick();
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _dragItem = null;
      _shapePlaced = false;
      _pinPlaced = false;
      _rotAngle = 0;
      _accumulatedRot = 0;
      _lastRotAngle = 0;
      _orderCount = 0;
      _matchesFound = List.filled(12, false);
      _manualRotActive = false;
      _isChecking = false;
      _errorFlash = 0;
      _successFlash = 0;
      _s4Slots.fillRange(0, 5, null);

      _s5BeltItems = [
        BeltItem(id: '1', type: 'parallelogram', x: -300, y: -200),
        BeltItem(id: '2', type: 'eq_triangle', x: -100, y: -200),
        BeltItem(id: '3', type: 'kite', x: 100, y: -200),
        BeltItem(id: '4', type: 'pentagon', x: 300, y: -200),
      ];
      _s5InspectionItem = null;
      _s5Score = 0;

      // Reset view based on scenario
      _zoom = 1.0;
      _panX = (_scenario <= 4) ? -100 : 0;
      _panY = (_scenario == 5) ? 50 : 0;
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
    if (_step == _getScenarioConfig(_scenario).steps.length) {
      if (_scenario == 5) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          playPageOpen();
          _showFinalPopup();
        });
      }
    }
  }

  void _completeScenario() {
    playPageOpen();
    setState(() {
      _manualRotActive = false;
      _rotAngle = 0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _step = _getScenarioConfig(_scenario).steps.length;
        });
      }
    });
  }

  void _showFinalPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            t('summaryTitle'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 80),
            const SizedBox(height: 16),
            Text(
              t('finalDesc'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.flag, color: Colors.white),
            label: Text(
              t('finishLab'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onPressed: () {
              playClick();
              Navigator.pop(context);
              _loadScenario(1);
              setState(() {
                _isCurtainUp = false;
              });
            },
          ),
        ],
      ),
    );
  }

  // --- Interaction Logic ---

  void _onScaleStart(ScaleStartDetails details) {
    if (_isChecking) return;

    _initialZoom = _zoom; // Capture initial zoom for smooth scaling

    RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localPt = box.globalToLocal(details.focalPoint);
    double worldX = (localPt.dx - (box.size.width / 2) - _panX) / _zoom;
    double worldY = (localPt.dy - (box.size.height / 2) - _panY) / _zoom;

    _isPanningCanvas = false;

    // Scenario 1, 2, 3 interactions
    if (_scenario <= 3) {
      String shapeKey = _scenario == 1
          ? 'square'
          : (_scenario == 2 ? 'rectangle' : 'pinwheel');
      double px = 250, py = -130;

      // Rotation Handle
      if (_pinPlaced &&
          ((_scenario == 1 && _step >= 2) ||
              (_scenario == 2 && _step >= 1) ||
              (_scenario == 3 && _step >= 1))) {
        double handleX = -50 + 160 * sin(_rotAngle);
        double handleY = 0 - 160 * cos(_rotAngle);
        if (sqrt(pow(worldX - handleX, 2) + pow(worldY - handleY, 2)) < 40) {
          _manualRotActive = true;
          _lastRotAngle = atan2(worldX - (-50), -(worldY - 0));
          return;
        }
      }

      // Pick up from Palette ONLY.
      // Picking up from hub is deliberately disabled to lock items once correctly placed.
      if (!_shapePlaced &&
          _step == 0 &&
          sqrt(pow(worldX - (px + 80), 2) + pow(worldY - (py + 110), 2)) < 40) {
        setState(() {
          _dragItem = DragItem(id: shapeKey, type: shapeKey, source: 'palette');
          _dragX = worldX;
          _dragY = worldY;
        });
        playClick();
        return;
      }
      if (_shapePlaced &&
          !_pinPlaced &&
          ((_scenario == 1 && _step == 1) ||
              (_scenario == 2 && _step == 0) ||
              (_scenario == 3 && _step == 0)) &&
          sqrt(pow(worldX - (px + 80), 2) + pow(worldY - (py + 200), 2)) < 40) {
        setState(() {
          _dragItem = DragItem(id: 'pin', type: 'pin', source: 'palette');
          _dragX = worldX;
          _dragY = worldY;
        });
        playClick();
        return;
      }
    }
    // Scenario 4 interactions
    else if (_scenario == 4) {
      if (_step == 0 &&
          worldX > 250 &&
          worldX < 410 &&
          worldY > -130 &&
          worldY < 130) {
        setState(() {
          _dragItem = DragItem(
            id: 'star_point',
            type: 'star_point',
            source: 'palette',
          );
          _dragX = worldX;
          _dragY = worldY;
        });
        playClick();
        return;
      }
      if (_step == 0) {
        for (int i = 0; i < 5; i++) {
          if (_s4Slots[i] != null) {
            double sx = -100 + 90 * sin(i * (2 * pi) / 5);
            double sy = 0 - 90 * cos(i * (2 * pi) / 5);
            if (sqrt(pow(worldX - sx, 2) + pow(worldY - sy, 2)) < 40) {
              setState(() {
                _dragItem = DragItem(
                  id: 'star_point',
                  type: 'star_point',
                  source: 'hub',
                  index: i,
                );
                _dragX = worldX;
                _dragY = worldY;
              });
              playClick();
              return;
            }
          }
        }
      }
    }
    // Scenario 5 interactions
    else if (_scenario == 5) {
      if (_manualRotActive) return;

      if (_s5InspectionItem != null) {
        double handleX = 0 + 100 * sin(_rotAngle);
        double handleY = 50 - 100 * cos(_rotAngle);
        if (sqrt(pow(worldX - handleX, 2) + pow(worldY - handleY, 2)) < 40) {
          _manualRotActive = true;
          _lastRotAngle = atan2(worldX - 0, -(worldY - 50));
          return;
        }
      }

      if (_s5InspectionItem != null &&
          worldX > -80 &&
          worldX < 80 &&
          worldY > -30 &&
          worldY < 130) {
        setState(() {
          _dragItem = DragItem(
            id: _s5InspectionItem!,
            type: 'inspection',
            source: 'inspection',
          );
          _s5InspectionItem = null;
          _dragX = worldX;
          _dragY = worldY;
        });
        playClick();
        return;
      }

      for (int i = 0; i < _s5BeltItems.length; i++) {
        var item = _s5BeltItems[i];
        if (item.state == 'belt' &&
            worldX > item.x - 50 &&
            worldX < item.x + 50 &&
            worldY > item.y - 50 &&
            worldY < item.y + 50) {
          setState(() {
            _dragItem = DragItem(id: item.id, type: item.type, source: 'belt');
            _dragX = worldX;
            _dragY = worldY;
          });
          playClick();
          return;
        }
      }
    }

    // If nothing hit, we start panning the canvas natively
    _isPanningCanvas = true;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isChecking) return;

    // Handle smooth dragging of items
    if (_dragItem != null) {
      RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      Offset localPt = box.globalToLocal(details.focalPoint);
      double worldX = (localPt.dx - (box.size.width / 2) - _panX) / _zoom;
      double worldY = (localPt.dy - (box.size.height / 2) - _panY) / _zoom;

      setState(() {
        _dragX = worldX;
        _dragY = worldY;
      });
      return;
    }

    // Handle manual rotation manipulation
    if (_manualRotActive) {
      RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      Offset localPt = box.globalToLocal(details.focalPoint);
      double worldX = (localPt.dx - (box.size.width / 2) - _panX) / _zoom;
      double worldY = (localPt.dy - (box.size.height / 2) - _panY) / _zoom;

      double cx = -50, cy = 0;
      if (_scenario == 5) {
        cx = 0;
        cy = 50;
      }

      double currentAngle = atan2(worldX - cx, -(worldY - cy));
      double diff = currentAngle - _lastRotAngle;
      if (diff > pi) diff -= 2 * pi;
      if (diff < -pi) diff += 2 * pi;

      setState(() {
        _rotAngle += diff;
        _accumulatedRot += diff.abs();
        _lastRotAngle = currentAngle;

        double angleDeg = (_rotAngle * 180 / pi) % 360;
        if (angleDeg < 0) angleDeg += 360;

        if (_scenario <= 3) {
          double stepAng = 360 / 4;
          int zone = (angleDeg / stepAng).round();
          if (zone == 4) zone = 0;
          double remainder = (angleDeg - zone * stepAng).abs();

          if (remainder < 5 && diff.abs() > 0.01) {
            if (_scenario == 2) {
              if (zone == 1 || zone == 3) {
                if (!_matchesFound[zone]) {
                  _matchesFound[zone] = true;
                  _errorFlash = 40;
                  playError();
                  if (_step == 1 && zone == 1) {
                    Future.delayed(
                      const Duration(milliseconds: 1000),
                      _advanceStep,
                    );
                  }
                }
              } else if (zone == 2 || zone == 0) {
                if (!_matchesFound[zone] && _accumulatedRot.abs() > pi / 4) {
                  _matchesFound[zone] = true;
                  _orderCount++;
                  _successFlash = 40;
                  playClick();
                  if (zone == 0 && _orderCount >= 2 && _step == 2) {
                    _completeScenario();
                  }
                }
              }
            } else {
              if (!_matchesFound[zone] && _accumulatedRot.abs() > pi / 4) {
                _matchesFound[zone] = true;
                _orderCount++;
                _successFlash = 40;
                playClick();

                // Syncs Step 3 instructions to Step 4 after reaching the first 90 degree mark.
                if (_scenario == 1 && _step == 2 && zone == 1) {
                  Future.delayed(
                    const Duration(milliseconds: 1000),
                    _advanceStep,
                  );
                }

                if (zone == 0 &&
                    _orderCount >= 4 &&
                    ((_scenario == 1 && _step == 3) ||
                        (_scenario == 3 && _step == 1))) {
                  _completeScenario();
                }
              }
            }
          }
        } else if (_scenario == 5 && _s5InspectionItem != null) {
          var item = _s5BeltItems.firstWhere((b) => b.id == _s5InspectionItem);
          int order = _getShapeOrder(item.type);
          double stepAng = 360 / order;
          int zone = (angleDeg / stepAng).round();
          if (zone == order) zone = 0;
          double remainder = (angleDeg - zone * stepAng).abs();

          if (remainder < 5 && diff.abs() > 0.01 && !_matchesFound[zone]) {
            _matchesFound[zone] = true;
            _orderCount++;
            _successFlash = 20;
            playClick();
          }
        }
      });
      return;
    }

    // Handle smooth, seamless pan and zoom natively tracking the focal point
    if (_isPanningCanvas || details.pointerCount >= 2) {
      RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          // Track 1:1 finger movement for panning
          _panX += details.focalPointDelta.dx;
          _panY += details.focalPointDelta.dy;

          // Perform mathematical focal-point zoom (scale toward the pinch center)
          if (details.scale != 1.0) {
            double newZoom = (_initialZoom * details.scale).clamp(0.3, 4.0);
            if (newZoom != _zoom) {
              Offset localFocal = box.globalToLocal(details.focalPoint);
              double dx = localFocal.dx - (box.size.width / 2);
              double dy = localFocal.dy - (box.size.height / 2);

              double zoomRatio = newZoom / _zoom;
              _panX = dx - (dx - _panX) * zoomRatio;
              _panY = dy - (dy - _panY) * zoomRatio;
              _zoom = newZoom;
            }
          }
        });
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_manualRotActive) {
      setState(() {
        _manualRotActive = false;
      });
      return;
    }

    if (_dragItem != null) {
      bool dropped = false;

      setState(() {
        if (_scenario <= 3) {
          if (_dragItem!.type != 'pin' &&
              sqrt(pow(_dragX - (-50), 2) + pow(_dragY - 0, 2)) < 50) {
            _shapePlaced = true;
            dropped = true;
            playClick();
            if (_scenario == 1 && _step == 0) _advanceStep();
            if (_scenario == 2 && _step == 0 && _pinPlaced) _advanceStep();
            if (_scenario == 3 && _step == 0 && _pinPlaced) _advanceStep();
          } else if (_dragItem!.type == 'pin' &&
              sqrt(pow(_dragX - (-50), 2) + pow(_dragY - 0, 2)) < 30) {
            _pinPlaced = true;
            _rotAngle = 0;
            _accumulatedRot = 0;
            _orderCount = 0;
            _matchesFound.fillRange(0, 12, false);
            dropped = true;
            playClick();
            if (_scenario == 1 && _step == 1) _advanceStep();
            if (_scenario == 2 && _step == 0 && _shapePlaced) _advanceStep();
            if (_scenario == 3 && _step == 0 && _shapePlaced) _advanceStep();
          }
        } else if (_scenario == 4) {
          for (int i = 0; i < 5; i++) {
            double sx = -100 + 90 * sin(i * (2 * pi) / 5);
            double sy = 0 - 90 * cos(i * (2 * pi) / 5);
            if (sqrt(pow(_dragX - sx, 2) + pow(_dragY - sy, 2)) < 40) {
              if (_s4Slots[i] == null) {
                if (_dragItem!.source == 'hub')
                  _s4Slots[_dragItem!.index] = null;
                _s4Slots[i] = 'star_point';
                dropped = true;
                playClick();
                if (_s4Slots.every((v) => v != null) && _step == 0)
                  _advanceStep();
              }
              break;
            }
          }
          if (!dropped && _dragItem!.source == 'hub')
            _s4Slots[_dragItem!.index] = null;
        } else if (_scenario == 5) {
          int targetBin = -1;
          List<double> binXs = [-250, 0, 250];
          for (int i = 0; i < 3; i++) {
            if (_dragX > binXs[i] - 100 &&
                _dragX < binXs[i] + 100 &&
                _dragY > 200 &&
                _dragY < 300)
              targetBin = i;
          }

          if (targetBin != -1) {
            var item = _s5BeltItems.firstWhere((b) => b.id == _dragItem!.id);
            int expectedBin = _getShapeBin(item.type);
            if (targetBin == expectedBin) {
              item.state = 'bin';
              _s5Score++;
              dropped = true;
              playClick();
              if (_s5Score == 4) {
                _advanceStep();
                Future.delayed(const Duration(milliseconds: 1000), () {
                  _advanceStep();
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    playPageOpen();
                    _showFinalPopup();
                  });
                });
              }
            } else {
              _errorFlash = 20;
              _lastBinTarget = targetBin;
              playError();
            }
          } else if (_dragX > -120 &&
              _dragX < 120 &&
              _dragY > -70 &&
              _dragY < 170) {
            if (_s5InspectionItem != null) {
              _s5BeltItems.firstWhere((b) => b.id == _s5InspectionItem).state =
                  'belt';
            }
            _s5InspectionItem = _dragItem!.id;
            _rotAngle = 0;
            _accumulatedRot = 0;
            _orderCount = 0;
            _matchesFound.fillRange(0, 12, false);
            dropped = true;
            playClick();
            if (_step == 0) _advanceStep();
          }
          if (!dropped && _dragItem!.source == 'inspection')
            _s5InspectionItem = _dragItem!.id;
        }

        _dragItem = null;
      });
    }
  }

  void _triggerCheckSymmetry() async {
    if (_isChecking || _scenario != 4 || _step != 1) return;
    playClick();
    setState(() {
      _isChecking = true;
      _rotAngle = 0;
      _orderCount = 0;
    });

    double stepAng = (2 * pi) / 5;
    double nextSnap = stepAng;

    AnimationController testCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    Animation<double> rotAnim = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: testCtrl, curve: Curves.easeInOutCubic));

    testCtrl.addListener(() {
      setState(() {
        _rotAngle = rotAnim.value;
        if (_rotAngle >= nextSnap - 0.05 && nextSnap <= 2 * pi) {
          _orderCount++;
          _successFlash = 20;
          nextSnap += stepAng;
        }
      });
    });

    await testCtrl.forward();
    testCtrl.dispose();

    setState(() {
      _rotAngle = 0;
      _isChecking = false;
    });
    playPageOpen();
    _advanceStep();

    // Advance to completion after 5 seconds of observation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _scenario == 4 && _step == 2) {
        _advanceStep();
      }
    });
  }

  // Helpers
  int _getShapeOrder(String type) {
    if (type == 'parallelogram') return 2;
    if (type == 'eq_triangle') return 3;
    if (type == 'kite') return 1;
    if (type == 'pentagon') return 5;
    return 1;
  }

  int _getShapeBin(String type) {
    if (type == 'parallelogram') return 0;
    if (type == 'eq_triangle') return 1;
    return 2; // kite, pentagon -> other
  }

  ScenarioConfig _getScenarioConfig(int id) {
    int numSteps = (id == 1 || id == 2) ? 4 : 3;
    List<ScenarioStep> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add(
        ScenarioStep(
          hud: t('s${id}_hud$i'),
          task: t('s${id}_step${i}_task'),
          outcome: t('s${id}_step${i}_out'),
        ),
      );
    }
    return ScenarioConfig(
      title: t('s${id}_title'),
      objective: t('s${id}_obj'),
      steps: steps,
    );
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    ScenarioConfig cfg = _getScenarioConfig(_scenario);
    String currentHud = (_step < cfg.steps.length) ? cfg.steps[_step].hud : "";

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              // GestureDetector handles pure Drag/Pan/Scale natively without tapping interference
              child: GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: CustomPaint(
                  key: _canvasKey,
                  painter: SymmetryPainter(
                    zoom: _zoom,
                    panX: _panX,
                    panY: _panY,
                    scenario: _scenario,
                    step: _step,
                    shapePlaced: _shapePlaced,
                    pinPlaced: _pinPlaced,
                    rotAngle: _rotAngle,
                    orderCount: _orderCount,
                    dragItem: _dragItem,
                    dragX: _dragX,
                    dragY: _dragY,
                    manualRotActive: _manualRotActive,
                    isChecking: _isChecking,
                    successFlash: _successFlash,
                    errorFlash: _errorFlash,
                    s4Slots: _s4Slots,
                    s5BeltItems: _s5BeltItems,
                    s5InspectionItem: _s5InspectionItem,
                    s5Score: _s5Score,
                    time: DateTime.now().millisecondsSinceEpoch,
                    lastBinTarget: _lastBinTarget,
                    t: t,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // 2. Right Edge HUD & Check/Next Buttons
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentHud.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              currentHud,
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
                  const SizedBox(height: 16),
                  if (_scenario == 4 && _step == 1)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        t('checkBtn'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _triggerCheckSymmetry,
                    ),
                  if (_step == cfg.steps.length && _scenario < 5)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                      ),
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: Text(
                        t('nextScenario'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        playPageOpen();
                        _loadScenario(_scenario + 1);
                      },
                    ),
                ],
              ),
            ),

            // 3. Sidebar - Completely Scrollable
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              top: 0,
              bottom: 0,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white12, width: 2),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)],
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Modified Header Layout
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 64, 16, 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.science,
                                      color: Color(0xFF6366F1),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t('appTitle'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: Text(
                                    t('appSubtitle'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 18),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              color: Colors.white70,
                                            ),
                                            Text(
                                              _lang.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onPressed: _toggleLanguage,
                                        tooltip: 'Toggle Language',
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          playClick();
                                          _loadScenario(1);
                                          setState(() {
                                            _isCurtainUp = false;
                                          });
                                        },
                                        tooltip: 'Reset Lab',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Sidebar Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('selectScenario'),
                                    style: const TextStyle(
                                      fontSize: 11,
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
                                        value: _scenario,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: List.generate(
                                          5,
                                          (index) => DropdownMenuItem(
                                            value: index + 1,
                                            child: Text(
                                              t('s${index + 1}_title'),
                                              overflow: TextOverflow.ellipsis,
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
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0F172A,
                                      ).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.flag,
                                              color: Colors.pinkAccent,
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
                                          cfg.objective,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...List.generate(cfg.steps.length, (index) {
                                    bool isCompleted = index < _step;
                                    bool isActive = index == _step;
                                    Color bgColor = isActive
                                        ? const Color(
                                            0xFF6366F1,
                                          ).withOpacity(0.15)
                                        : (isCompleted
                                              ? const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.1)
                                              : Colors.transparent);
                                    Color borderColor = isActive
                                        ? const Color(0xFF6366F1)
                                        : (isCompleted
                                              ? const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.5)
                                              : Colors.white12);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor),
                                        boxShadow: isActive
                                            ? [
                                                const BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (isCompleted)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF10B981),
                                              size: 24,
                                            )
                                          else
                                            Container(
                                              width: 24,
                                              height: 24,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? const Color(0xFF6366F1)
                                                    : Colors.white12,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: isActive
                                                      ? Colors.white
                                                      : Colors.white54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${t('stepLabel')} ${index + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  cfg.steps[index].task,
                                                  style: TextStyle(
                                                    color: isActive
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (isCompleted) ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF10B981,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      cfg.steps[index].outcome,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF34D399,
                                                        ),
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
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            color: const Color(0xFF020617),
                            child: const Text(
                              '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
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

            // 4. Sidebar Resizer Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: _sidebarOpen ? _sidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                      300.0,
                      MediaQuery.of(context).size.width * 0.5,
                    );
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
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

            // 5. Fixed Sidebar Menu Toggle at Top Left
            Positioned(
              left: 16,
              top: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF6366F1),
                onPressed: () {
                  playClick();
                  setState(() {
                    _sidebarOpen = !_sidebarOpen;
                  });
                },
                child: Icon(
                  _sidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // 6. Curtain Screen
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              top: _isCurtainUp ? -MediaQuery.of(context).size.height : 0,
              left: 0,
              right: 0,
              bottom: _isCurtainUp ? MediaQuery.of(context).size.height : 0,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cyclone,
                        color: Color(0xFF6366F1),
                        size: 100,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t('shutterTitle'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 40),
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
                        onPressed: () {
                          curtainScreen();
                          setState(() {
                            _isCurtainUp = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Painter ---

class SymmetryPainter extends CustomPainter {
  final double zoom, panX, panY;
  final int scenario, step;
  final bool shapePlaced, pinPlaced;
  final double rotAngle;
  final int orderCount;
  final DragItem? dragItem;
  final double dragX, dragY;
  final bool manualRotActive, isChecking;
  final double successFlash, errorFlash;
  final List<String?> s4Slots;
  final List<BeltItem> s5BeltItems;
  final String? s5InspectionItem;
  final int s5Score;
  final int time;
  final int lastBinTarget;
  final Function(String) t;

  SymmetryPainter({
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.scenario,
    required this.step,
    required this.shapePlaced,
    required this.pinPlaced,
    required this.rotAngle,
    required this.orderCount,
    required this.dragItem,
    required this.dragX,
    required this.dragY,
    required this.manualRotActive,
    required this.isChecking,
    required this.successFlash,
    required this.errorFlash,
    required this.s4Slots,
    required this.s5BeltItems,
    required this.s5InspectionItem,
    required this.s5Score,
    required this.time,
    required this.lastBinTarget,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Background Grid
    Paint bgPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Offset.zero & size, bgPaint);

    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    Paint gridLine = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double i = -1500; i <= 1500; i += 100) {
      canvas.drawLine(Offset(i, -1500), Offset(i, 1500), gridLine);
      canvas.drawLine(Offset(-1500, i), Offset(1500, i), gridLine);
    }

    if (scenario <= 3)
      _drawScenarios123(canvas);
    else if (scenario == 4)
      _drawScenario4(canvas);
    else if (scenario == 5)
      _drawScenario5(canvas);

    canvas.restore();
  }

  void _drawShape(Canvas canvas, String id, {bool asGhost = false}) {
    Paint fill = Paint()..style = PaintingStyle.fill;
    Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    Path path = Path();

    if (id == 'square' || id == 'rectangle') {
      fill.color = asGhost ? const Color(0xFF334155) : const Color(0xFF3B82F6);
      stroke.color = asGhost
          ? const Color(0xFF475569)
          : const Color(0xFF1D4ED8);
      Rect rect = id == 'square'
          ? const Rect.fromLTWH(-70, -70, 140, 140)
          : const Rect.fromLTWH(-100, -50, 200, 100);
      if (asGhost) {
        _drawDashedRect(canvas, rect, stroke);
      } else {
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, stroke);
      }
    } else if (id == 'pinwheel') {
      fill.color = asGhost ? const Color(0xFF334155) : const Color(0xFF10B981);
      stroke.color = asGhost
          ? const Color(0xFF475569)
          : const Color(0xFF047857);
      stroke.strokeWidth = 3;
      for (int i = 0; i < 4; i++) {
        canvas.save();
        canvas.rotate(i * pi / 2);
        path.reset();
        path.moveTo(0, 0);
        path.lineTo(-20, -80);
        path.lineTo(40, -80);
        path.close();
        if (asGhost) {
          _drawDashedPath(canvas, path, stroke);
        } else {
          canvas.drawPath(path, fill);
          canvas.drawPath(path, stroke);
        }
        canvas.restore();
      }
    } else if (id == 'star_point') {
      fill.color = const Color(0xFFEF4444);
      stroke.color = const Color(0xFFB91C1C);
      stroke.strokeWidth = 2;
      path.moveTo(0, -30);
      path.lineTo(30, 40);
      path.lineTo(-30, 40);
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    } else if (id == 'parallelogram') {
      fill.color = const Color(0xFF8B5CF6);
      stroke.color = const Color(0xFF4338CA);
      stroke.strokeWidth = 3;
      path.moveTo(-60, -40);
      path.lineTo(40, -40);
      path.lineTo(60, 40);
      path.lineTo(-40, 40);
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    } else if (id == 'eq_triangle') {
      fill.color = const Color(0xFF14B8A6);
      stroke.color = const Color(0xFF047857);
      stroke.strokeWidth = 3;
      path.moveTo(0, -60);
      path.lineTo(52, 30);
      path.lineTo(-52, 30);
      path.close();
      if (asGhost) {
        _drawDashedPath(canvas, path, stroke..color = const Color(0xFF475569));
      } else {
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      }
    } else if (id == 'kite') {
      fill.color = const Color(0xFFF43F5E);
      stroke.color = const Color(0xFFBE123C);
      stroke.strokeWidth = 3;
      path.moveTo(0, -60);
      path.lineTo(30, -10);
      path.lineTo(0, 60);
      path.lineTo(-30, -10);
      path.close();
      if (asGhost) {
        _drawDashedPath(canvas, path, stroke..color = const Color(0xFF475569));
      } else {
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      }
    } else if (id == 'pentagon') {
      fill.color = const Color(0xFFEAB308);
      stroke.color = const Color(0xFFA16207);
      stroke.strokeWidth = 3;
      for (int i = 0; i < 5; i++) {
        double a = i * pi * 0.4 - pi / 2;
        if (i == 0)
          path.moveTo(50 * cos(a), 50 * sin(a));
        else
          path.lineTo(50 * cos(a), 50 * sin(a));
      }
      path.close();
      if (asGhost) {
        _drawDashedPath(canvas, path, stroke..color = const Color(0xFF475569));
      } else {
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      }
    } else if (id == 'pin') {
      fill.color = const Color(0xFFEF4444);
      canvas.drawCircle(const Offset(0, -15), 10, fill);
      stroke.color = const Color(0xFFCBD5E1);
      stroke.strokeWidth = 3;
      canvas.drawLine(const Offset(0, -5), const Offset(0, 15), stroke);
    }
  }

  void _drawScenarios123(Canvas canvas) {
    String shapeKey = scenario == 1
        ? 'square'
        : (scenario == 2 ? 'rectangle' : 'pinwheel');
    double px = 250, py = -130;

    // Palette
    _drawPalette(canvas, px, py, [
      if (!shapePlaced ||
          (dragItem != null &&
              dragItem!.type == shapeKey &&
              dragItem!.source == 'palette'))
        {'id': shapeKey, 'x': px + 80, 'y': py + 110, 'scale': 0.5},
      if (!pinPlaced ||
          (dragItem != null &&
              dragItem!.type == 'pin' &&
              dragItem!.source == 'palette'))
        {'id': 'pin', 'x': px + 80, 'y': py + 200, 'scale': 1.5},
    ]);

    // Center Hub
    canvas.save();
    canvas.translate(-50, 0);

    _drawShape(canvas, shapeKey, asGhost: true);

    if (shapePlaced && !(dragItem != null && dragItem!.source == 'hub_shape')) {
      canvas.save();
      if (rotAngle > 0) {
        if (successFlash > 0)
          canvas.drawShadow(
            Path()..addRect(const Rect.fromLTWH(-70, -70, 140, 140)),
            const Color(0xFF22C55E),
            successFlash,
            false,
          );
        else if (errorFlash > 0)
          canvas.drawShadow(
            Path()..addRect(const Rect.fromLTWH(-70, -70, 140, 140)),
            const Color(0xFFEF4444),
            errorFlash,
            false,
          );
      }
      canvas.rotate(rotAngle);
      _drawShape(canvas, shapeKey);
      canvas.restore();
    }

    if (shapePlaced && !pinPlaced && step == 1) {
      canvas.drawCircle(
        Offset.zero,
        15,
        Paint()
          ..color = const Color(0x4D22C55E)
          ..style = PaintingStyle.fill,
      );
      _drawDashedCircle(
        canvas,
        Offset.zero,
        15,
        Paint()
          ..color = const Color(0xFF22C55E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (pinPlaced && !(dragItem != null && dragItem!.source == 'hub_pin')) {
      _drawShape(canvas, 'pin');

      // Protractor
      canvas.save();
      Paint proStroke = Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(
        const Rect.fromLTWH(-160, -160, 320, 320),
        -pi / 2,
        rotAngle,
        false,
        proStroke,
      );

      int angleDeg = (rotAngle * 180 / pi).round();
      _drawRoundedRect(
        canvas,
        -40,
        -230,
        80,
        40,
        8,
        const Color(0xFF1E293B),
        const Color(0xFF475569),
      );
      _drawText(
        canvas,
        '$angleDeg°',
        0,
        -210,
        fontSize: 20,
        color: Colors.white,
      );
      canvas.restore();

      // Rotation Handle
      canvas.save();
      canvas.rotate(rotAngle);
      canvas.translate(0, -160);
      bool isHover = manualRotActive;
      canvas.drawCircle(
        Offset.zero,
        25,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        Offset.zero,
        25,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = isHover ? const Color(0xFF6366F1) : const Color(0xFF475569),
      );
      canvas.drawArc(
        const Rect.fromLTWH(-12, -12, 24, 24),
        -pi / 2,
        pi * 0.8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = isHover ? const Color(0xFF6366F1) : const Color(0xFF475569),
      );
      canvas.restore();
    }

    if ((scenario == 1 && step >= 4) ||
        (scenario == 2 && step >= 4) ||
        (scenario == 3 && step >= 3)) {
      canvas.save();
      canvas.translate(0, 220);
      _drawRoundedRect(
        canvas,
        -200,
        -50,
        400,
        100,
        12,
        const Color(0xFF0F172A),
        const Color(0xFF475569),
      );
      String txt = scenario == 1
          ? t('s1_step4_out')
          : (scenario == 2 ? t('s2_step4_out') : t('s3_step3_out'));
      _drawText(
        canvas,
        txt,
        0,
        0,
        fontSize: 14,
        color: const Color(0xFFCBD5E1),
        maxWidth: 360,
      );
      canvas.restore();
    }
    canvas.restore();

    if (pinPlaced) {
      _drawOrderCounter(canvas, 330, 0, orderCount);
    }

    _drawDragItem(canvas);
  }

  void _drawScenario4(Canvas canvas) {
    double px = 250, py = -130;
    _drawPalette(canvas, px, py, [
      {'id': 'star_point', 'x': px + 80, 'y': py + 130, 'scale': 1.5},
    ]);

    canvas.save();
    canvas.translate(-100, 0);

    canvas.drawCircle(
      Offset.zero,
      100,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset.zero,
      100,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      Offset.zero,
      30,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill,
    );

    canvas.rotate(rotAngle);
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate(i * (2 * pi) / 5);
      canvas.translate(0, -90);

      if (s4Slots[i] == null) {
        Path p = Path()
          ..moveTo(0, -20)
          ..lineTo(20, 30)
          ..lineTo(-20, 30)
          ..close();
        canvas.drawPath(
          p,
          Paint()
            ..color = const Color(0xFF0F172A)
            ..style = PaintingStyle.fill,
        );
        _drawDashedPath(
          canvas,
          p,
          Paint()
            ..color = const Color(0xFF334155)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else {
        if (!(dragItem != null &&
            dragItem!.source == 'hub' &&
            dragItem!.index == i)) {
          canvas.translate(0, 10);
          _drawShape(canvas, 'star_point');
        }
      }
      canvas.restore();
    }
    canvas.restore();

    if (step >= 1) _drawOrderCounter(canvas, px + 80, py + 330, orderCount);

    if (step >= 2) {
      _drawRoundedRect(
        canvas,
        -300,
        150,
        400,
        80,
        12,
        const Color(0xFF0F172A),
        const Color(0xFF475569),
      );
      _drawText(
        canvas,
        t('s4_step3_out'),
        -100,
        190,
        fontSize: 14,
        color: const Color(0xFFCBD5E1),
        maxWidth: 360,
      );
    }

    _drawDragItem(canvas);
  }

  void _drawScenario5(Canvas canvas) {
    // Belt
    canvas.save();
    canvas.translate(0, -200);
    canvas.drawRect(
      const Rect.fromLTWH(-450, -50, 900, 100),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-450, -40, 900, 80),
      Paint()..color = const Color(0xFF0F172A),
    );
    double dashOffset = (time / 20) % 40;
    _drawDashedLine(
      canvas,
      const Offset(-450, 0),
      const Offset(450, 0),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 4,
      dashOffset,
    );
    _drawText(
      canvas,
      "SHAPE CONVEYOR",
      -350,
      -65,
      fontSize: 16,
      color: Colors.white,
      isBold: true,
    );
    canvas.restore();

    // Center Pad
    canvas.save();
    canvas.translate(0, 50);
    _drawRoundedRect(
      canvas,
      -120,
      -120,
      240,
      240,
      20,
      const Color(0xFF1E293B),
      const Color(0xFF475569),
      4,
    );
    canvas.drawCircle(
      Offset.zero,
      80,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawText(
      canvas,
      "TESTING PAD",
      0,
      -90,
      fontSize: 16,
      color: const Color(0xFF94A3B8),
      isBold: true,
    );

    if (s5InspectionItem != null && dragItem == null) {
      var item = s5BeltItems.firstWhere((b) => b.id == s5InspectionItem);
      _drawShape(canvas, item.type, asGhost: true);

      canvas.save();
      canvas.rotate(rotAngle);
      _drawShape(canvas, item.type);
      canvas.restore();

      canvas.save();
      canvas.rotate(rotAngle);
      canvas.translate(0, -100);
      canvas.drawCircle(
        Offset.zero,
        20,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        Offset.zero,
        20,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = manualRotActive
              ? const Color(0xFF6366F1)
              : const Color(0xFF475569),
      );
      canvas.restore();

      _drawRoundedRect(
        canvas,
        80,
        60,
        40,
        40,
        6,
        const Color(0xFF0F172A),
        const Color(0xFF475569),
      );
      _drawText(
        canvas,
        orderCount.toString(),
        100,
        80,
        fontSize: 24,
        color: const Color(0xFF22C55E),
        isBold: true,
      );
    } else if (dragItem == null && s5BeltItems.any((i) => i.state != 'bin')) {
      _drawText(
        canvas,
        t('lbl_bins'),
        0,
        0,
        fontSize: 14,
        color: const Color(0xFF475569),
      );
    }
    canvas.restore();

    // Bins
    List<Map<String, dynamic>> bins = [
      {'x': -250.0, 'label': "Order 2"},
      {'x': 0.0, 'label': "Order 3"},
      {'x': 250.0, 'label': "Other"},
    ];
    for (int i = 0; i < 3; i++) {
      var b = bins[i];
      canvas.save();
      canvas.translate(b['x'], 250);
      _drawRoundedRect(
        canvas,
        -90,
        -50,
        180,
        100,
        12,
        const Color(0xFF020617),
        const Color(0xFF334155),
        4,
      );
      _drawRoundedRect(
        canvas,
        -70,
        -30,
        140,
        60,
        8,
        const Color(0xFF0F172A),
        const Color(0xFF1E293B),
        2,
      );
      _drawRoundedRect(
        canvas,
        -50,
        20,
        100,
        40,
        8,
        const Color(0xFF6366F1),
        const Color(0xFF4F46E5),
        2,
      );
      _drawText(
        canvas,
        b['label'],
        0,
        40,
        fontSize: 16,
        color: Colors.white,
        isBold: true,
      );

      if (errorFlash > 0 && lastBinTarget == i) {
        canvas.drawRect(
          const Rect.fromLTWH(-90, -50, 180, 100),
          Paint()
            ..color = const Color(0xFFEF4444)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6,
        );
      }
      canvas.restore();
    }

    // Score
    canvas.save();
    canvas.translate(-400, 0);
    _drawText(
      canvas,
      "SCORE",
      0,
      0,
      fontSize: 16,
      color: const Color(0xFF94A3B8),
      isBold: true,
    );
    _drawRoundedRect(
      canvas,
      -40,
      15,
      80,
      50,
      8,
      const Color(0xFF0F172A),
      const Color(0xFF475569),
    );
    _drawText(
      canvas,
      "$s5Score/4",
      0,
      40,
      fontSize: 24,
      color: const Color(0xFF6366F1),
      isBold: true,
    );
    canvas.restore();

    // Belt Items
    for (var item in s5BeltItems) {
      if (item.state == 'belt' &&
          !(dragItem != null && dragItem!.id == item.id)) {
        canvas.save();
        canvas.translate(item.x, item.y);
        canvas.scale(0.8, 0.8);
        _drawShape(canvas, item.type);
        canvas.restore();
      }
    }

    if (dragItem != null) {
      var item = s5BeltItems.firstWhere(
        (b) => b.id == dragItem!.id,
        orElse: () => BeltItem(id: '', type: '', x: 0, y: 0),
      );
      if (item.id.isNotEmpty) {
        canvas.save();
        canvas.translate(dragX, dragY);
        canvas.scale(0.9, 0.9);
        _drawShape(canvas, item.type);
        canvas.restore();
      }
    }
  }

  void _drawPalette(
    Canvas canvas,
    double px,
    double py,
    List<Map<String, dynamic>> items,
  ) {
    _drawRoundedRect(
      canvas,
      px,
      py,
      160,
      260,
      12,
      const Color(0xFF0F172A),
      const Color(0xFF475569),
      3,
    );
    _drawText(
      canvas,
      t('lbl_palette'),
      px + 80,
      py + 25,
      fontSize: 16,
      color: const Color(0xFFCBD5E1),
      isBold: true,
    );
    canvas.drawLine(
      Offset(px + 20, py + 45),
      Offset(px + 140, py + 45),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 2,
    );

    for (var item in items) {
      canvas.save();
      canvas.translate(item['x'], item['y']);
      canvas.scale(item['scale'], item['scale']);
      _drawShape(canvas, item['id']);
      canvas.restore();
    }
  }

  void _drawOrderCounter(Canvas canvas, double x, double y, int count) {
    canvas.save();
    canvas.translate(x, y);
    _drawText(
      canvas,
      t('lbl_order_counter'),
      0,
      -50,
      fontSize: 16,
      color: const Color(0xFFCBD5E1),
      isBold: true,
    );
    _drawRoundedRect(
      canvas,
      -50,
      -35,
      100,
      70,
      8,
      const Color(0xFF020617),
      const Color(0xFF334155),
      2,
    );
    _drawText(
      canvas,
      count.toString(),
      0,
      0,
      fontSize: 44,
      color: const Color(0xFF22C55E),
      isBold: true,
    );
    canvas.restore();
  }

  void _drawDragItem(Canvas canvas) {
    if (dragItem != null) {
      canvas.save();
      canvas.translate(dragX, dragY);
      if (dragItem!.type == 'pin')
        canvas.scale(1.5, 1.5);
      else if (dragItem!.source == 'palette' && scenario <= 3)
        canvas.scale(0.5, 0.5);
      else if (dragItem!.source == 'palette' && scenario == 4)
        canvas.scale(1.5, 1.5);
      _drawShape(canvas, dragItem!.type);
      canvas.restore();
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke, [
    double sw = 1,
  ]) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    double offset,
  ) {
    double dashWidth = 20, dashSpace = 20;
    double dist = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / dist;
    double dy = (p2.dy - p1.dy) / dist;
    double currentDist = offset;

    while (currentDist < dist) {
      if (currentDist < 0) currentDist = 0;
      double endDist = currentDist + dashWidth;
      if (endDist > dist) endDist = dist;
      canvas.drawLine(
        Offset(p1.dx + dx * currentDist, p1.dy + dy * currentDist),
        Offset(p1.dx + dx * endDist, p1.dy + dy * endDist),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    Path p = Path()..addRect(rect);
    _drawDashedPath(canvas, p, paint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    Path p = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    _drawDashedPath(canvas, p, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    PathMetrics pathMetrics = path.computeMetrics();
    Path dashedPath = Path();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + 8),
          Offset.zero,
        );
        distance += 16; // 8 dash + 8 space
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 14,
    Color color = Colors.white,
    bool isBold = false,
    double maxWidth = double.infinity,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Roboto',
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant SymmetryPainter oldDelegate) => true;
}

// --- Translations Map ---
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle': "Rotational Symmetry: The Spin Test",
    'appTitle': "Rotational Symmetry",
    'appSubtitle': "Class 6 • SYMMETRY",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Objective:",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'checkBtn': "Test Spin",
    'finalDesc':
        "You've successfully mastered finding the order of rotational symmetry for different 2D shapes!",
    'lbl_palette': "Shapes Palette",
    'lbl_order_counter': "Order of Rotation",
    'lbl_bins': "Drop Shapes Here",

    's1_title': "1. The Perfect Square Spin (Order 4)",
    's1_obj':
        "To understand the basic mechanics of rotational symmetry using a simple square.",
    's1_step1_task':
        "DRAG the solid square and DROP it perfectly onto its grey outline.",
    's1_step1_out': "Square placed successfully.",
    's1_step2_task':
        "DRAG the 'pin' icon and DROP it onto the exact centre of the square.",
    's1_step2_out': "Pin placed at the center of rotation.",
    's1_step3_task':
        "CLICK and DRAG the rotation handle clockwise. Watch the protractor.",
    's1_step3_out': "Square flashes green at every 90° turn.",
    's1_step4_task':
        "Continue rotating to complete a 360° turn and read the summary.",
    's1_step4_out':
        "Success! The square has rotational symmetry of Order 4. It looks the same at 90°, 180°, 270°, and 360°.",
    's1_hud1': "Drag the solid square onto the dashed outline.",
    's1_hud2': "Drag the red pin onto the center dot.",
    's1_hud3': "Drag the handle to spin the square.",
    's1_hud4': "Review the summary.",

    's2_title': "2. The Tricky Rectangle (Order 2)",
    's2_obj':
        "To discover that not all four-sided shapes have the same rotational symmetry.",
    's2_step1_task':
        "DRAG the solid rectangle to its outline, then DRAG the pin to the centre.",
    's2_step1_out': "Rectangle and pin are placed.",
    's2_step2_task': "DRAG the rotation handle. Observe what happens at 90°.",
    's2_step2_out': "At 90°, the rectangle doesn't fit its outline.",
    's2_step3_task': "Continue rotating to a full 360° turn.",
    's2_step3_out': "Rectangle matches only at 180° and 360°.",
    's2_step4_task': "Read the summary.",
    's2_step4_out':
        "Well done! A rectangle has rotational symmetry of Order 2 (180° and 360°).",
    's2_hud1': "Place the rectangle and then the pin.",
    's2_hud2': "Spin the rectangle slowly and watch the 90° mark.",
    's2_hud3': "Spin all the way to 360°.",
    's2_hud4': "Review the summary.",

    's3_title': "3. The Pinwheel Puzzle (Order 4)",
    's3_obj':
        "To apply the concept of rotational symmetry to a more complex shape.",
    's3_step1_task':
        "DRAG the pinwheel and the pin to their correct positions.",
    's3_step1_out': "Pinwheel and pin are ready.",
    's3_step2_task': "ROTATE the pinwheel a full 360° and observe the counter.",
    's3_step2_out': "Pinwheel matches 4 times.",
    's3_step3_task': "Read the summary.",
    's3_step3_out':
        "Excellent! This pinwheel has rotational symmetry of Order 4.",
    's3_hud1': "Place the pinwheel and the pin.",
    's3_hud2': "Spin the pinwheel a full circle.",
    's3_hud3': "Review the summary.",

    's4_title': "4. Build-a-Star Workshop (Order 5)",
    's4_obj':
        "To construct a shape that has a specific order of rotational symmetry (Order 5).",
    's4_step1_task':
        "DRAG 5 identical triangles from the palette and DROP them into the 5 slots on the hub.",
    's4_step1_out': "All 5 slots filled. Test button active.",
    's4_step2_task':
        "CLICK the 'Test Spin' button below to check your creation.",
    's4_step2_out': "Star spins and matches 5 times.",
    's4_step3_task': "Observe the result.",
    's4_step3_out':
        "Perfect! You built a star with Order 5. The smallest angle of rotation is 360° ÷ 5 = 72°.",
    's4_hud1': "Place 5 identical star points into the slots.",
    's4_hud2': "Click 'Test Spin' at the bottom.",
    's4_hud3': "Review the summary.",

    's5_title': "5. The Symmetry Sorter",
    's5_obj':
        "To identify the order of rotational symmetry for various shapes and categorize them.",
    's5_step1_task':
        "DRAG a shape from the conveyor belt to the central Inspection Pad.",
    's5_step1_out': "Shape is pinned for testing.",
    's5_step2_task':
        "SPIN the shape to find its order of symmetry, then DRAG it to the correct Bin.",
    's5_step2_out': "Shape sorted correctly.",
    's5_step3_task': "Sort the remaining shapes correctly.",
    's5_step3_out': "All shapes sorted!",
    's5_hud1': "Drag a shape to the center to test it.",
    's5_hud2': "Spin to test, then drag to a bin.",
    's5_hud3': "Keep sorting the remaining shapes.",
  },
  'hi': {
    'shutterTitle': "घूर्णी समरूपता: स्पिन टेस्ट",
    'appTitle': "घूर्णी समरूपता",
    'appSubtitle': "कक्षा 6 • समरूपता",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'checkBtn': "टेस्ट स्पिन",
    'finalDesc':
        "आपने सफलतापूर्वक विभिन्न 2D आकृतियों के लिए घूर्णी समरूपता के क्रम को खोजना सीख लिया है!",
    'lbl_palette': "आकार पैलेट",
    'lbl_order_counter': "रोटेशन का क्रम",
    'lbl_bins': "आकृतियों को यहाँ छोड़ें",

    's1_title': "1. परफेक्ट स्क्वायर स्पिन (क्रम 4)",
    's1_obj':
        "एक साधारण वर्ग का उपयोग करके घूर्णी समरूपता के मूल यांत्रिकी को समझना।",
    's1_step1_task':
        "ठोस वर्ग को खींचें और उसे इसके ग्रे आउटलाइन पर पूरी तरह से छोड़ दें।",
    's1_step1_out': "वर्ग सफलतापूर्वक रखा गया।",
    's1_step2_task':
        "'पिन' आइकन को खींचें और उसे वर्ग के ठीक केंद्र पर छोड़ दें।",
    's1_step2_out': "पिन रोटेशन के केंद्र में रखा गया।",
    's1_step3_task': "रोटेशन हैंडल को क्लिक करें और दक्षिणावर्त खींचें।",
    's1_step3_out': "वर्ग हर 90° मोड़ पर हरा चमकता है।",
    's1_step4_task': "360° मोड़ पूरा करने के लिए घुमाते रहें और सारांश पढ़ें।",
    's1_step4_out': "सफलता! वर्ग में घूर्णी समरूपता का क्रम 4 है।",
    's1_hud1': "ठोस वर्ग को धराशायी आउटलाइन पर खींचें।",
    's1_hud2': "लाल पिन को केंद्र बिंदु पर खींचें।",
    's1_hud3': "वर्ग को घुमाने के लिए हैंडल को खींचें।",
    's1_hud4': "सारांश की समीक्षा करें।",

    's2_title': "2. ट्रिकी आयत (क्रम 2)",
    's2_obj':
        "यह खोजना कि सभी चार-तरफा आकृतियों में समान घूर्णी समरूपता नहीं होती है।",
    's2_step1_task':
        "ठोस आयत को उसके आउटलाइन पर खींचें, फिर पिन को केंद्र पर खींचें।",
    's2_step1_out': "आयत और पिन रखे गए हैं।",
    's2_step2_task':
        "रोटेशन हैंडल को खींचें। ध्यान से देखें कि 90° पर क्या होता है।",
    's2_step2_out': "90° पर, आयत अपनी रूपरेखा में फिट नहीं होता है।",
    's2_step3_task': "पूर्ण 360° मोड़ तक घुमाते रहें।",
    's2_step3_out': "आयत केवल 180° और 360° पर मेल खाता है।",
    's2_step4_task': "सारांश पढ़ें।",
    's2_step4_out':
        "बहुत बढ़िया! आयत में क्रम 2 (180° और 360°) की घूर्णी समरूपता है।",
    's2_hud1': "आयत और फिर पिन रखें।",
    's2_hud2': "आयत को धीरे-धीरे घुमाएं और 90° चिह्न देखें।",
    's2_hud3': "360° तक पूरा घुमाएं।",
    's2_hud4': "सारांश की समीक्षा करें।",

    's3_title': "3. पिनव्हील पहेली (क्रम 4)",
    's3_obj': "एक अधिक जटिल आकार में घूर्णी समरूपता की अवधारणा को लागू करना।",
    's3_step1_task': "पिनव्हील और पिन को उनके सही स्थान पर खींचें।",
    's3_step1_out': "पिनव्हील और पिन तैयार हैं।",
    's3_step2_task': "पिनव्हील को पूरा 360° घुमाएं और काउंटर देखें।",
    's3_step2_out': "पिनव्हील 4 बार मेल खाता है।",
    's3_step3_task': "सारांश पढ़ें।",
    's3_step3_out': "उत्कृष्ट! इस पिनव्हील में घूर्णी समरूपता का क्रम 4 है।",
    's3_hud1': "पिनव्हील और पिन रखें।",
    's3_hud2': "पिनव्हील को एक पूरा चक्कर घुमाएं।",
    's3_hud3': "सारांश की समीक्षा करें।",

    's4_title': "4. बिल्ड-ए-स्टार वर्कशॉप (क्रम 5)",
    's4_obj':
        "एक ऐसे आकार का निर्माण जिसका घूर्णी समरूपता का एक विशिष्ट क्रम (क्रम 5) हो।",
    's4_step1_task':
        "पैलेट से 5 समान त्रिकोणों को खींचें और उन्हें हब पर 5 स्लॉट में छोड़ दें।",
    's4_step1_out': "सभी 5 स्लॉट भर गए। टेस्ट बटन सक्रिय है।",
    's4_step2_task':
        "अपनी रचना की जांच करने के लिए नीचे 'टेस्ट स्पिन' बटन पर क्लिक करें।",
    's4_step2_out': "तारा घूमता है और 5 बार मेल खाता है।",
    's4_step3_task': "परिणाम देखें।",
    's4_step3_out': "परफेक्ट! आपने क्रम 5 वाला तारा बनाया।",
    's4_hud1': "5 समान तारा बिंदुओं को स्लॉट में रखें।",
    's4_hud2': "नीचे 'टेस्ट स्पिन' पर क्लिक करें।",
    's4_hud3': "सारांश की समीक्षा करें।",

    's5_title': "5. सिमिट्री सॉर्टर",
    's5_obj':
        "विभिन्न आकृतियों के लिए घूर्णी समरूपता के क्रम की पहचान करना और उन्हें वर्गीकृत करना।",
    's5_step1_task':
        "कन्वेयर बेल्ट से एक आकार को केंद्रीय निरीक्षण पैड पर खींचें।",
    's5_step1_out': "परीक्षण के लिए आकार को पिन किया गया है।",
    's5_step2_task':
        "आकार के समरूपता का क्रम खोजने के लिए उसे घुमाएं, फिर उसे सही बिन में खींचें।",
    's5_step2_out': "आकार को सही ढंग से क्रमबद्ध किया गया।",
    's5_step3_task': "शेष आकृतियों को सही ढंग से क्रमबद्ध करें।",
    's5_step3_out': "सभी आकृतियों को क्रमबद्ध कर दिया गया!",
    's5_hud1': "परीक्षण करने के लिए एक आकार को केंद्र में खींचें।",
    's5_hud2': "परीक्षण करने के लिए घुमाएं, फिर एक डिब्बे में खींचें।",
    's5_hud3': "शेष आकृतियों को छांटते रहें।",
  },
};
