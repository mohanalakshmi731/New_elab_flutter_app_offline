// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'The Shape Architect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Plus Jakarta Sans',
        primaryColor: const Color(0xFF6366F1),
      ),
      home: const Cl6M_Ch8_A2_TheShapeArchitect(),
    ),
  );
}

class Cl6M_Ch8_A2_TheShapeArchitect extends StatefulWidget {
  const Cl6M_Ch8_A2_TheShapeArchitect({super.key});

  @override
  State<Cl6M_Ch8_A2_TheShapeArchitect> createState() =>
      _Cl6M_Ch8_A2_TheShapeArchitectState();
}

class _Cl6M_Ch8_A2_TheShapeArchitectState
    extends State<Cl6M_Ch8_A2_TheShapeArchitect>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  final GlobalKey _canvasKey = GlobalKey();

  // Layout State
  bool _isSidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _showCurtain = true;
  bool _curtainLifted = false;
  bool _showSuccessPopup = false;

  // App State
  String _lang = 'en';
  int _scenario = 1;
  int _step = 0;

  // Camera & Touch State
  Offset _panOffset = Offset.zero;
  double _zoom = 1.0;
  final Map<int, Offset> _touches = {};
  double _baseZoom = 1.0;
  double _startDistance = 1.0;

  // Interaction State
  String? _activeDragId;
  Offset _dragWorldPos = Offset.zero;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // Scenario 1 Data
  List<Map<String, dynamic>> s1Shapes = [];
  Map<String, dynamic> s1Lights = {'opp': false, 'all': false, 'ang': 'off'};
  String s1BinText = '';

  // Scenario 2 Data
  List<Map<String, dynamic>> s2Sticks = [];
  bool s2TriedWrong = false;

  // Scenario 3 Data
  List<Map<String, dynamic>> s3Sticks = [];
  int s3Count = 1;

  // Scenario 4 Data
  List<Map<String, dynamic>> s4Shapes = [];

  // Scenario 5 Data
  List<Map<String, dynamic>> s5Tiles = [];
  int s5Mode = 3;
  bool s5Error = false;

  bool _animating = false;

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
      setState(() {});
    });

    _initScenario(1);
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

  void _initScenario(int id) {
    _animating = false;
    _activeDragId = null;
    _scenario = id;
    _step = 0;
    _panOffset = Offset.zero;
    _zoom = 1.0;
    _touches.clear();

    if (id == 1) {
      s1Shapes = [
        {
          'id': 'rect',
          'type': 'rect',
          'x': -350.0,
          'y': -100.0,
          'placed': false,
        },
        {
          'id': 'square',
          'type': 'square',
          'x': -350.0,
          'y': 20.0,
          'placed': false,
        },
        {
          'id': 'para',
          'type': 'para',
          'x': -350.0,
          'y': 140.0,
          'placed': false,
        },
      ];
      s1Lights = {'opp': false, 'all': false, 'ang': 'off'};
      s1BinText = '';
    } else if (id == 2) {
      s2Sticks = [
        {'id': 'r1', 'c': 'red', 'len': 200.0, 'placed': false, 'slot': null},
        {'id': 'r2', 'c': 'red', 'len': 200.0, 'placed': false, 'slot': null},
        {'id': 'b1', 'c': 'blue', 'len': 100.0, 'placed': false, 'slot': null},
        {'id': 'b2', 'c': 'blue', 'len': 100.0, 'placed': false, 'slot': null},
      ];
      s2TriedWrong = false;
    } else if (id == 3) {
      s3Count = 1;
      s3Sticks = [
        {'id': 'p1', 'placed': false, 'slot': null},
      ];
    } else if (id == 4) {
      s4Shapes = [
        {
          'id': 's1',
          'type': 'rect',
          'w': 120.0,
          'h': 60.0,
          'rot': 15.0,
          'x': -250.0,
          'y': -150.0,
          'trueRect': true,
          'inZone': false,
          'scanned': false,
        },
        {
          'id': 's2',
          'type': 'square',
          'w': 80.0,
          'h': 80.0,
          'rot': -25.0,
          'x': -100.0,
          'y': -150.0,
          'trueRect': true,
          'inZone': false,
          'scanned': false,
        },
        {
          'id': 's3',
          'type': 'para',
          'w': 100.0,
          'h': 60.0,
          'rot': 10.0,
          'x': -250.0,
          'y': 0.0,
          'trueRect': false,
          'inZone': false,
          'scanned': false,
        },
        {
          'id': 's4',
          'type': 'rhombus',
          'w': 80.0,
          'h': 80.0,
          'rot': 45.0,
          'x': -100.0,
          'y': 0.0,
          'trueRect': false,
          'inZone': false,
          'scanned': false,
        },
        {
          'id': 's5',
          'type': 'trap',
          'w': 100.0,
          'h': 60.0,
          'rot': -10.0,
          'x': -180.0,
          'y': 150.0,
          'trueRect': false,
          'inZone': false,
          'scanned': false,
        },
      ];
    } else if (id == 5) {
      s5Mode = 3;
      s5Tiles = [];
      s5Error = false;
    }
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
  }

  void _nextScenario() {
    playPageOpen();
    setState(() {
      _showSuccessPopup = false;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scenario < 5) {
        _initScenario(_scenario + 1);
      }
    });
  }

  void _showFinalPopup() {
    playPageOpen();
    setState(() {
      _showSuccessPopup = true;
    });
  }

  Offset _getWorldOffset(Offset screenPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;
    return (screenPos - Offset(size.width / 2, size.height / 2) - _panOffset) /
        _zoom;
  }

  bool _hitTest(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  // Raw Pointer Events for highly responsive touch interaction
  void _onPointerDown(PointerDownEvent event) {
    if (_animating) return;
    _touches[event.pointer] = event.localPosition;

    if (_touches.length == 1) {
      Offset pt = _getWorldOffset(event.localPosition);
      _activeDragId = null;

      if (_scenario == 1) {
        if (_step == 3 && _hitTest(-100, 220, 200, 50, pt)) {
          playClick();
          _advanceStep();
          Future.delayed(const Duration(milliseconds: 500), _showFinalPopup);
          return;
        }
        for (var sh in s1Shapes.reversed) {
          if (!sh['placed'] &&
              _hitTest(
                (sh['x'] as num).toDouble() - 60,
                (sh['y'] as num).toDouble() - 60,
                120,
                120,
                pt,
              )) {
            _activeDragId = 's1_${sh['id']}';
            _dragWorldPos = pt;
            playClick();
            return;
          }
        }
      } else if (_scenario == 2) {
        double tbY(String id) =>
            {'r1': -70.0, 'r2': -30.0, 'b1': 40.0, 'b2': 80.0}[id]!;
        for (var st in s2Sticks) {
          if (!st['placed'] &&
              _hitTest(-365, tbY(st['id']) - 20, 120, 40, pt)) {
            _activeDragId = 's2_${st['id']}';
            _dragWorldPos = pt;
            playClick();
            return;
          }
        }
      } else if (_scenario == 3) {
        if (_step >= 1 && _hitTest(-350, -40, 90, 40, pt) && s3Count < 4) {
          playClick();
          s3Count++;
          s3Sticks.add({'id': 'p$s3Count', 'placed': false, 'slot': null});
          if (s3Count == 4 && _step == 1) _advanceStep();
          return;
        }
        var unplaced = s3Sticks.where((s) => !s['placed']).toList();
        if (unplaced.isNotEmpty) {
          for (var st in unplaced) {
            int idx = s3Sticks.indexOf(st);
            double cx = -305;
            double cy = _step >= 1 ? 10.0 + idx * 25 : 120.0 + idx * 25;
            // Larger hit area for easier grabbing
            if (_hitTest(cx - 60, cy - 20, 120, 40, pt)) {
              _activeDragId = 's3_${st['id']}';
              _dragWorldPos = pt;
              playClick();
              return;
            }
          }
        }
      } else if (_scenario == 4) {
        if (_step == 3 && _hitTest(180, 180, 140, 50, pt)) {
          playClick();
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _showFinalPopup);
          return;
        }
        if (_hitTest(-360, -200, 40, 40, pt)) {
          _activeDragId = 'tool_ruler';
          _dragWorldPos = pt;
          playClick();
          return;
        }
        if (_hitTest(-240, -200, 40, 40, pt)) {
          _activeDragId = 'tool_angle';
          _dragWorldPos = pt;
          playClick();
          return;
        }

        for (var sh in s4Shapes) {
          if (!sh['inZone'] &&
              _hitTest(
                (sh['x'] as num).toDouble() - 60,
                (sh['y'] as num).toDouble() - 60,
                120,
                120,
                pt,
              )) {
            _activeDragId = 's4_${sh['id']}';
            _dragWorldPos = pt;
            playClick();
            return;
          }
        }
      } else if (_scenario == 5) {
        if (_hitTest(-360, -40, 80, 40, pt)) {
          playClick();
          setState(() => s5Mode = 3);
          _activeDragId = 's5_tile';
          _dragWorldPos = pt;
          return;
        }
        if (_hitTest(-360, 20, 80, 40, pt)) {
          playClick();
          setState(() => s5Mode = 2);
          if (_step <= 1) {
            _step = 1;
            _advanceStep();
          }
          _activeDragId = 's5_tile';
          _dragWorldPos = pt;
          return;
        }

        if (_hitTest(-380, -100, 120, 200, pt)) {
          _activeDragId = 's5_tile';
          _dragWorldPos = pt;
          playClick();
          return;
        }

        for (int i = s5Tiles.length - 1; i >= 0; i--) {
          var t = s5Tiles[i];
          double tSize = (t['size'] as num).toDouble();
          if (_hitTest(
            -120 + (t['c'] as num).toDouble() * 30.0,
            -100 + (t['r'] as num).toDouble() * 30.0,
            tSize * 30.0,
            tSize * 30.0,
            pt,
          )) {
            s5Tiles.removeAt(i);
            _activeDragId = 's5_tile';
            s5Mode = (t['size'] as num).toInt();
            _dragWorldPos = pt;
            playClick();
            return;
          }
        }
      }

      // Default to pan
      _activeDragId = 'pan';
    } else if (_touches.length == 2) {
      // Start Zooming
      _activeDragId = 'zoom';
      var points = _touches.values.toList();
      _startDistance = (points[0] - points[1]).distance;
      _baseZoom = _zoom;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_touches.containsKey(event.pointer)) return;
    _touches[event.pointer] = event.localPosition;

    if (_touches.length == 1) {
      if (_activeDragId == 'pan') {
        setState(() {
          _panOffset += event.delta;
        });
      } else if (_activeDragId != null && _activeDragId != 'zoom') {
        setState(() {
          _dragWorldPos = _getWorldOffset(event.localPosition);
        });
      }
    } else if (_touches.length == 2 && _activeDragId == 'zoom') {
      var points = _touches.values.toList();
      double currentDistance = (points[0] - points[1]).distance;
      if (_startDistance > 0) {
        setState(() {
          _zoom = (_baseZoom * (currentDistance / _startDistance)).clamp(
            0.2,
            5.0,
          );
        });
      }
    }
  }

  void _onPointerUp(PointerEvent event) {
    _touches.remove(event.pointer);

    if (_touches.isEmpty) {
      if (_activeDragId != null &&
          _activeDragId != 'pan' &&
          _activeDragId != 'zoom') {
        _handleDrop(_dragWorldPos);
      }
      _activeDragId = null;
    } else if (_touches.length == 1) {
      // Return to pan if one finger is lifted during a zoom
      _activeDragId = 'pan';
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        double zoomChange = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
        _zoom = (_zoom * zoomChange).clamp(0.2, 5.0);
      });
    }
  }

  void _handleDrop(Offset pt) {
    if (_activeDragId == null) return;

    if (_activeDragId!.startsWith('s1_')) {
      String id = _activeDragId!.split('_')[1];
      var shape = s1Shapes.firstWhere((s) => s['id'] == id);
      if (_hitTest(-120, -100, 240, 240, pt)) {
        shape['placed'] = true;
        _animating = true;
        playPageOpen();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            if (shape['type'] == 'rect') {
              s1Lights = {'opp': true, 'all': false, 'ang': 'green'};
            }
            if (shape['type'] == 'square') {
              s1Lights = {'opp': true, 'all': true, 'ang': 'green'};
            }
            if (shape['type'] == 'para') {
              s1Lights = {'opp': true, 'all': false, 'ang': 'red'};
            }
          });

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!mounted) return;
            setState(() {
              s1BinText = shape['type'] == 'para'
                  ? 'REJECTED'
                  : shape['type'].toString().toUpperCase();
              _animating = false;
            });
            if (shape['type'] == 'para') {
              playError();
            } else {
              playPageOpen();
            }

            if (_step == 0 && shape['type'] == 'rect') _advanceStep();
            if (_step == 1 && shape['type'] == 'square') _advanceStep();
            if (_step == 2 && shape['type'] == 'para') _advanceStep();
          });
        });
      } else {
        playError();
      }
    } else if (_activeDragId!.startsWith('s2_')) {
      String id = _activeDragId!.split('_')[1];
      var st = s2Sticks.firstWhere((s) => s['id'] == id);
      Map<String, dynamic> slots = {
        'bottom': {'x': 0.0, 'y': 50.0, 'req': 'red'},
        'right': {'x': 100.0, 'y': 0.0, 'req': 'blue'},
        'top': {'x': 0.0, 'y': -50.0, 'req': 'red'},
        'left': {'x': -100.0, 'y': 0.0, 'req': 'blue'},
      };

      String? droppedSlot;
      double minDist = 120;
      slots.forEach((key, val) {
        double dist =
            (pt -
                    Offset(
                      (val['x'] as num).toDouble(),
                      (val['y'] as num).toDouble(),
                    ))
                .distance;
        if (dist < minDist &&
            !s2Sticks.any((x) => x['slot'] == key && x['placed'])) {
          minDist = dist;
          droppedSlot = key;
        }
      });

      if (droppedSlot != null) {
        if (slots[droppedSlot]['req'] == st['c']) {
          playPageOpen();
          setState(() {
            st['slot'] = droppedSlot;
            st['placed'] = true;
            s2TriedWrong = false;
          });
          var placedKeys = s2Sticks
              .where((x) => x['placed'])
              .map((x) => x['slot'])
              .toList();
          if (_step == 0 && placedKeys.contains('bottom')) _advanceStep();
          if (_step == 1 && placedKeys.contains('right')) _advanceStep();
          if (_step == 3 && placedKeys.length == 4) {
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _showFinalPopup);
          }
        } else {
          playError();
          setState(() => s2TriedWrong = true);
          if (_step == 2 && st['c'] == 'blue' && droppedSlot == 'top') {
            _advanceStep();
          }
        }
      } else {
        playError();
      }
    } else if (_activeDragId!.startsWith('s3_')) {
      String id = _activeDragId!.split('_')[1];
      var st = s3Sticks.firstWhere((s) => s['id'] == id);

      if (_step == 0) {
        if (_hitTest(-380, -100, 150, 200, pt)) {
          playPageOpen();
          _advanceStep();
          return;
        } else {
          playError();
          return;
        }
      }

      if (_step < 2) {
        playError();
        return;
      }

      Map<String, Offset> slots = {
        'bottom': const Offset(0, 75),
        'right': const Offset(75, 0),
        'top': const Offset(0, -75),
        'left': const Offset(-75, 0),
      };

      String? droppedSlot;
      double minDist = 120;
      slots.forEach((key, val) {
        double dist = (pt - val).distance;
        if (dist < minDist &&
            !s3Sticks.any((x) => x['slot'] == key && x['placed'])) {
          minDist = dist;
          droppedSlot = key;
        }
      });

      if (droppedSlot != null) {
        playPageOpen();
        setState(() {
          st['slot'] = droppedSlot;
          st['placed'] = true;
        });
        if (_step == 2 && s3Sticks.any((x) => x['placed'])) _advanceStep();
        if (_step == 3 && s3Sticks.where((x) => x['placed']).length == 4) {
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _showFinalPopup);
        }
      } else {
        playError();
      }
    } else if (_activeDragId!.startsWith('tool_')) {
      bool matched = false;
      for (var sh in s4Shapes) {
        if (_hitTest(
          (sh['x'] as num).toDouble() - 60,
          (sh['y'] as num).toDouble() - 60,
          120,
          120,
          pt,
        )) {
          matched = true;
          playPageOpen();
          setState(() => sh['scanned'] = true);
          if (_step == 0) _advanceStep();
          if (s4Shapes.every((s) => s['scanned']) && _step == 1) _advanceStep();
          break;
        }
      }
      if (!matched) playError();
    } else if (_activeDragId!.startsWith('s4_')) {
      String id = _activeDragId!.split('_')[1];
      var shape = s4Shapes.firstWhere((s) => s['id'] == id);
      if (_hitTest(150, -150, 200, 300, pt)) {
        if (shape['trueRect']) {
          playPageOpen();
          setState(() => shape['inZone'] = true);
          if (_step == 2 && s4Shapes.where((s) => s['inZone']).length == 2) {
            _advanceStep();
          }
        } else {
          playError();
        }
      } else {
        playError();
      }
    } else if (_activeDragId == 's5_tile') {
      if (_hitTest(200, 20, 100, 80, pt)) {
        playClick(); // Dropped in trash
      } else if (_hitTest(-380, -100, 120, 200, pt)) {
        playClick(); // Dropped back in dispenser safely without error
      } else {
        double tSize = 30;
        int c = ((pt.dx - (-120) - (s5Mode * tSize) / 2) / tSize).round();
        int r = ((pt.dy - (-100) - (s5Mode * tSize) / 2) / tSize).round();

        if (c >= 0 && r >= 0 && c + s5Mode <= 8 && r + s5Mode <= 6) {
          bool overlap = false;
          for (var t in s5Tiles) {
            int tc = (t['c'] as num).toInt();
            int tr = (t['r'] as num).toInt();
            int ts = (t['size'] as num).toInt();
            if (!(c >= tc + ts ||
                c + s5Mode <= tc ||
                r >= tr + ts ||
                r + s5Mode <= tr)) {
              overlap = true;
            }
          }
          if (!overlap) {
            playPageOpen();
            setState(() {
              s5Tiles.add({'c': c, 'r': r, 'size': s5Mode});
              s5Error = false;
            });

            if (_step == 0 && s5Mode == 3) {
              _advanceStep();
            } else if (_step < 3 && s5Mode == 2) {
              _step = 2;
              _advanceStep();
            }

            int totalArea = s5Tiles.fold(
              0,
              (sum, t) =>
                  sum +
                  ((t['size'] as num).toInt() * (t['size'] as num).toInt()),
            );
            if (totalArea == 48) {
              _step = 3;
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _showFinalPopup);
            }
          } else {
            playError();
            setState(() => s5Error = true);
          }
        } else {
          playError();
          setState(() => s5Error = true);
        }
      }
    }
  }

  // TRANSLATIONS
  final Map<String, Map<String, String>> tMap = {
    'en': {
      'shutterTitle':
          "The Shape Architect: Properties of Squares and Rectangles",
      'appTitle': "The Shape Architect",
      'appSubtitle': "Class 6 • BUILDING FOUNDATIONS",
      'enterLab': "Enter Simulation",
      'selectScenario': "Select Scenario",
      'stepLabel': "STEP",
      'learnLbl': "Objective:",
      'outcomeLbl': "Outcome:",
      'summaryTitle': "Goal Reached!",
      'finishLab': "Finish Lab",
      'nextScenario': "Next Scenario",
      'finalDesc':
          "You have successfully explored the properties of Squares and Rectangles!",
      's1_title': "1. The Property-Checking Machine",
      's1_obj':
          "Visually identify the core properties of squares and rectangles using a sorting machine.",
      's1_hud1': "Drag the RECTANGLE from the belt to the scanner.",
      's1_step1_task': "DRAG the rectangle into the Shape Checker machine.",
      's1_step1_out':
          "Rectangle accepted. Opposite sides are equal, all angles 90°.",
      's1_hud2': "Drag the SQUARE from the belt to the scanner.",
      's1_step2_task': "DRAG the square into the Shape Checker machine.",
      's1_step2_out':
          "Square accepted. All sides equal, opposite sides equal, all angles 90°.",
      's1_hud3': "Drag the PARALLELOGRAM from the belt to the scanner.",
      's1_step3_task': "DRAG the parallelogram into the Shape Checker machine.",
      's1_step3_out': "Parallelogram rejected. Angles are not 90°.",
      's1_hud4': "Review the properties of the shapes.",
      's1_step4_task': "Review the summary of the properties.",
      's1_step4_out':
          "A square is a special rectangle where all sides are equal!",
      's2_title': "2. The Rectangle Blueprint",
      's2_obj':
          "Construct a rectangle by understanding that its opposite sides must be equal.",
      's2_hud1': "Drag a long red stick to the base of the blueprint.",
      's2_step1_task':
          "DRAG one long red stick to the bottom edge of the blueprint.",
      's2_step1_out': "Base placed. Opposite side must be equal.",
      's2_hud2':
          "Drag a short blue stick to the right edge to form a 90° angle.",
      's2_step2_task': "DRAG a short blue stick to the right edge.",
      's2_step2_out': "Snaps at a 90° angle.",
      's2_hud3': "Try putting a short blue stick at the top edge.",
      's2_step3_task': "DRAG the other short blue stick to the top edge.",
      's2_step3_out':
          "Rejected! Opposite sides must be equal. Top needs a long red stick.",
      's2_hud4': "Complete the rectangle correctly.",
      's2_step4_task':
          "DRAG the long red stick to the top, and short blue to the left.",
      's2_step4_out':
          "Rectangle Complete! Opposite pairs of sides are equal and angles are 90°.",
      's3_title': "3. The Perfect Square",
      's3_obj':
          "Construct a square by understanding that all its sides must be equal.",
      's3_hud1': "Drag the purple stick into the Duplicator.",
      's3_step1_task': "DRAG the purple stick into the Duplicator.",
      's3_step1_out': "Stick duplicated. We need 4 equal sticks for a square.",
      's3_hud2': "Click the duplicator until you have 4 sticks.",
      's3_step2_task': "CLICK the Duplicator to create 4 total sticks.",
      's3_step2_out': "Four identical sticks are ready.",
      's3_hud3': "Assemble the sticks into a square.",
      's3_step3_task':
          "DRAG the 4 sticks onto the blueprint to form a closed shape.",
      's3_step3_out': "Sticks snap at 90° angles.",
      's3_hud4': "Complete the square.",
      's3_step4_task': "Place the final stick.",
      's3_step4_out':
          "Square Complete! All four sides are equal and all angles are 90°.",
      's4_title': "4. The Tilted Tile Test",
      's4_obj':
          "Identify squares and rectangles even when rotated, using measurement tools.",
      's4_hud1':
          "Drag a tool (Ruler or Angle Checker) onto a shape to inspect it.",
      's4_step1_task':
          "DRAG the Ruler or Angle Checker onto any shape to measure it.",
      's4_step1_out': "Tools reveal side lengths and corner angles.",
      's4_hud2': "Measure all shapes to find the true rectangles.",
      's4_step2_task': "Inspect the shapes. Look for 90° corners.",
      's4_step2_out': "Shapes without 90° corners are not rectangles.",
      's4_hud3': "Drag the TRUE rectangles into the 'Rectangle Zone'.",
      's4_step3_task':
          "DRAG the true rectangle and true square into the Rectangle Zone.",
      's4_step3_out':
          "Only shapes with opposite sides equal AND all angles 90° are accepted.",
      's4_hud4': "Confirm your selection.",
      's4_step4_task':
          "Once both correct tiles are in the zone, CLICK the 'Check' button.",
      's4_step4_out':
          "Correct! A shape is a rectangle if opposite sides are equal and angles are 90°, no matter the tilt.",
      's5_title': "5. The Floor Plan Puzzle",
      's5_obj':
          "Apply properties of squares to solve a spatial puzzle on an 8x6 grid.",
      's5_hud1': "Drag a 3x3 tile onto the 8x6 floor plan.",
      's5_step1_task': "DRAG a 3x3 tile and try to fit it on the floor plan.",
      's5_step1_out':
          "A 3x3 tile won't fit perfectly. 8 is not a multiple of 3.",
      's5_hud2':
          "Drag the 3x3 tile to the Trash, then click the Dispenser to switch sizes.",
      's5_step2_task':
          "DRAG the 3x3 tile to the Trash Bin. CLICK the dispenser to switch to 2x2.",
      's5_step2_out': "Switched to 2x2 tiles.",
      's5_hud3': "Fill the floor plan with 2x2 tiles.",
      's5_step3_task': "DRAG 2x2 tiles to fill the floor plan.",
      's5_step3_out': "2x2 tiles fit perfectly.",
      's5_hud4': "Complete the floor plan.",
      's5_step4_task': "Fill all 12 spots on the grid.",
      's5_step4_out':
          "Puzzle Solved! The 8x6 rectangle is perfectly filled with 2x2 squares.",
    },
    'hi': {
      'shutterTitle': "आकार वास्तुकार: वर्गों और आयतों के गुण",
      'appTitle': "आकार वास्तुकार",
      'appSubtitle': "कक्षा 6 • नींव का निर्माण",
      'enterLab': "सिमुलेशन दर्ज करें",
      'selectScenario': "परिदृश्य चुनें",
      'stepLabel': "चरण",
      'learnLbl': "उद्देश्य:",
      'outcomeLbl': "परिणाम:",
      'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'finishLab': "प्रयोगशाला समाप्त करें",
      'nextScenario': "अगला परिदृश्य",
      'finalDesc':
          "आपने वर्गों और आयतों के गुणों का सफलतापूर्वक पता लगा लिया है!",
      's1_title': "1. गुण-जांच मशीन",
      's1_obj':
          "छँटाई मशीन का उपयोग करके वर्गों और आयतों के मुख्य गुणों को दृष्टिगत रूप से पहचानें।",
      's1_hud1': "आयत को बेल्ट से स्कैनर तक खींचें।",
      's1_step1_task': "आयत को मशीन में खींचें।",
      's1_step1_out': "आयत स्वीकृत। सम्मुख भुजाएँ बराबर हैं, सभी कोण 90° हैं।",
      's1_hud2': "वर्ग को बेल्ट से स्कैनर तक खींचें।",
      's1_step2_task': "वर्ग को मशीन में खींचें।",
      's1_step2_out': "वर्ग स्वीकृत। सभी भुजाएँ और कोण (90°) बराबर हैं।",
      's1_hud3': "समांतर चतुर्भुज को स्कैनर तक खींचें।",
      's1_step3_task': "समांतर चतुर्भुज को मशीन में खींचें।",
      's1_step3_out': "अस्वीकृत। कोण 90° नहीं हैं।",
      's1_hud4': "आकृतियों के गुणों की समीक्षा करें।",
      's1_step4_task': "सारांश की समीक्षा करें।",
      's1_step4_out':
          "एक वर्ग एक विशेष आयत है जिसकी सभी भुजाएँ बराबर होती हैं!",
      's2_title': "2. आयत का खाका",
      's2_obj':
          "यह समझते हुए कि इसकी सम्मुख भुजाएँ बराबर होनी चाहिए, एक आयत बनाएँ।",
      's2_hud1': "एक लंबी लाल छड़ी को निचले किनारे पर खींचें।",
      's2_step1_task': "निचले किनारे पर एक लंबी लाल छड़ी खींचें।",
      's2_step1_out': "आधार रखा गया। सम्मुख भुजा बराबर होनी चाहिए।",
      's2_hud2': "एक छोटी नीली छड़ी को दाहिने किनारे पर खींचें।",
      's2_step2_task': "एक छोटी नीली छड़ी को दाहिने किनारे पर खींचें।",
      's2_step2_out': "90° के कोण पर जुड़ता है।",
      's2_hud3': "ऊपरी किनारे पर एक छोटी नीली छड़ी रखने का प्रयास करें।",
      's2_step3_task': "दूसरी छोटी नीली छड़ी को ऊपरी किनारे पर खींचें।",
      's2_step3_out': "अस्वीकृत! सम्मुख भुजाएँ बराबर होनी चाहिए।",
      's2_hud4': "आयत को सही ढंग से पूरा करें।",
      's2_step4_task': "लंबी लाल छड़ी को ऊपर और छोटी नीली को बाईं ओर खींचें।",
      's2_step4_out': "पूरा हुआ! सम्मुख भुजाएँ बराबर हैं और कोण 90° हैं।",
      's3_title': "3. पूर्ण वर्ग",
      's3_obj':
          "यह समझते हुए कि इसकी सभी भुजाएँ बराबर होनी चाहिए, एक वर्ग बनाएँ।",
      's3_hud1': "बैंगनी छड़ी को डुप्लीकेटर में खींचें।",
      's3_step1_task': "बैंगनी छड़ी को डुप्लीकेटर में खींचें।",
      's3_step1_out': "वर्ग के लिए 4 बराबर छड़ियों की आवश्यकता है।",
      's3_hud2': "4 छड़ें बनाने के लिए डुप्लीकेटर पर क्लिक करें।",
      's3_step2_task': "डुप्लीकेटर पर क्लिक करें।",
      's3_step2_out': "चार समान छड़ें तैयार हैं।",
      's3_hud3': "छड़ियों को एक वर्ग में इकट्ठा करें।",
      's3_step3_task': "4 छड़ियों को खाके पर खींचें।",
      's3_step3_out': "छड़ें 90° कोणों पर जुड़ती हैं।",
      's3_hud4': "वर्ग को पूरा करें।",
      's3_step4_task': "अंतिम छड़ी रखें।",
      's3_step4_out': "वर्ग पूरा हुआ! चारों भुजाएँ और कोण (90°) बराबर हैं।",
      's4_title': "4. झुका हुआ टाइल परीक्षण",
      's4_obj':
          "माप उपकरणों का उपयोग करके घुमाए जाने पर भी वर्गों और आयतों की पहचान करें।",
      's4_hud1': "उपकरण को आकृति पर खींचें।",
      's4_step1_task': "मापने के लिए उपकरण खींचें।",
      's4_step1_out': "उपकरण भुजाओं की लंबाई और कोणों को प्रकट करते हैं।",
      's4_hud2': "सच्चे आयतों को खोजने के लिए आकृतियों को मापें।",
      's4_step2_task': "आकृतियों का निरीक्षण करें। 90° के कोनों को देखें।",
      's4_step2_out': "90° कोनों के बिना आकृतियाँ आयत नहीं हैं।",
      's4_hud3': "सच्चे आयतों को 'आयत क्षेत्र' में खींचें।",
      's4_step3_task': "सच्चे आयतों को क्षेत्र में खींचें।",
      's4_step3_out':
          "केवल सम्मुख भुजाएँ बराबर और 90° वाले स्वीकार किए जाते हैं।",
      's4_hud4': "अपने चयन की पुष्टि करें।",
      's4_step4_task': "जांचें बटन पर क्लिक करें।",
      's4_step4_out': "सही! आयत के गुण झुकाव के साथ नहीं बदलते।",
      's5_title': "5. फर्श योजना पहेली",
      's5_obj':
          "8x6 ग्रिड पर एक स्थानिक पहेली को हल करने के लिए वर्गों के गुणों को लागू करें।",
      's5_hud1': "8x6 फर्श योजना पर 3x3 टाइल खींचें।",
      's5_step1_task': "3x3 टाइल को फर्श योजना पर फिट करने का प्रयास करें।",
      's5_step1_out': "3x3 टाइल फिट नहीं होगी। 8, 3 का गुणज नहीं है।",
      's5_hud2': "3x3 टाइल को कूड़ेदान में खींचें, आकार बदलें।",
      's5_step2_task': "3x3 को कूड़ेदान में डालें। 2x2 में बदलें।",
      's5_step2_out': "2x2 टाइलों में बदल दिया गया।",
      's5_hud3': "फर्श योजना को 2x2 टाइलों से भरें।",
      's5_step3_task': "2x2 टाइलें खींचें।",
      's5_step3_out': "2x2 टाइलें पूरी तरह से फिट होती हैं।",
      's5_hud4': "फर्श योजना पूरी करें।",
      's5_step4_task': "ग्रिड भरें।",
      's5_step4_out': "पहेली हल हो गई! 8x6 आयत 2x2 वर्गों से भरा है।",
    },
  };

  String t(String key) => tMap[_lang]?[key] ?? tMap['en']?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    int displayStep = min(_step, 3);
    String hudKey = 's${_scenario}_hud${displayStep + 1}';
    String hudText = t(hudKey);
    if (hudText == hudKey) hudText = ''; // prevent raw keys from showing
    bool showHud = _step < 4 && hudText.isNotEmpty;

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
              top: 0,
              bottom: 0,
              right: 0,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                onPointerSignal: _onPointerSignal,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: ClipRect(
                    child: CustomPaint(
                      key: _canvasKey,
                      painter: SimulationPainter(
                        scenario: _scenario,
                        step: _step,
                        pan: _panOffset,
                        zoom: _zoom,
                        s1Shapes: s1Shapes,
                        s1Lights: s1Lights,
                        s1BinText: s1BinText,
                        s2Sticks: s2Sticks,
                        s2TriedWrong: s2TriedWrong,
                        s3Sticks: s3Sticks,
                        s3Count: s3Count,
                        s4Shapes: s4Shapes,
                        s5Tiles: s5Tiles,
                        s5Mode: s5Mode,
                        s5Error: s5Error,
                        activeDragId: _activeDragId,
                        dragPos: _dragWorldPos,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ),

            // HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: 10,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: showHud ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            hudText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.architecture,
                                    color: Color(0xFF818CF8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t('appTitle'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF334155),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.language, size: 16),
                                  label: Text(
                                    _lang.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    playClick();
                                    setState(
                                      () => _lang = _lang == 'en' ? 'hi' : 'en',
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF334155),
                                  ),
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    playClick();
                                    _initScenario(1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Body
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                border: Border.all(color: Colors.white24),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  items: List.generate(
                                    5,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text(
                                        t('s${i + 1}_title'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      playDropdown();
                                      _initScenario(val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155).withOpacity(0.4),
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
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    t('s${_scenario}_obj'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...List.generate(4, (i) {
                              bool isComplete = i < _step;
                              bool isCurrent = i == _step;
                              if (t(
                                    's${_scenario}_step${i + 1}_task',
                                  ).isEmpty ||
                                  t(
                                    's${_scenario}_step${i + 1}_task',
                                  ).contains('s$_scenario')) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFF6366F1).withOpacity(0.1)
                                      : (isComplete
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.05)
                                            : const Color(
                                                0xFF0F172A,
                                              ).withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrent
                                        ? const Color(
                                            0xFF6366F1,
                                          ).withOpacity(0.5)
                                        : (isComplete
                                              ? const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.3)
                                              : Colors.white10),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isComplete)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF10B981),
                                      )
                                    else
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? const Color(0xFF6366F1)
                                              : Colors.white10,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isCurrent
                                                ? Colors.white
                                                : Colors.white54,
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
                                            '${t("stepLabel")} ${i + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            t(
                                              's${_scenario}_step${i + 1}_task',
                                            ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isCurrent || isComplete
                                                  ? Colors.white
                                                  : Colors.white54,
                                              fontWeight: isCurrent
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (isComplete) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                t(
                                                  's${_scenario}_step${i + 1}_out',
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF6EE7B7),
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
                      ),

                      // Footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        color: const Color(0xFF020617),
                        child: const Text(
                          '© ZeroScienceLab - Fall in love with math and Science',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SIDEBAR RESIZER (Drag Handle)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? _sidebarWidth - 10 : -20,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    if (_sidebarWidth < 350) _sidebarWidth = 350;
                    if (_sidebarWidth >
                        MediaQuery.of(context).size.width * 0.6) {
                      _sidebarWidth = MediaQuery.of(context).size.width * 0.6;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    width: 20,
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
              ),
            ),

            // MENU BUTTON
            Positioned(
              top: 16,
              left: 16,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton(
                  key: ValueKey(_isSidebarOpen),
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.8),
                  child: Icon(
                    _isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    playClick();
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                ),
              ),
            ),

            // SUCCESS POPUP
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flag_circle,
                          size: 80,
                          color: Color(0xFF10B981),
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
                        const SizedBox(height: 12),
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
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _scenario < 5
                              ? _nextScenario
                              : () {
                                  playClick();
                                  setState(() => _showSuccessPopup = false);
                                  _initScenario(1);
                                },
                          child: Text(
                            _scenario < 5 ? t('nextScenario') : t('finishLab'),
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

            // CURTAIN
            if (_showCurtain)
              AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOutCubic,
                top: _curtainLifted ? -MediaQuery.of(context).size.height : 0,
                bottom: _curtainLifted ? MediaQuery.of(context).size.height : 0,
                left: 0,
                right: 0,
                onEnd: () {
                  if (_curtainLifted) {
                    setState(() => _showCurtain = false);
                  }
                },
                child: Container(
                  color: const Color(0xFF0F172A),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.architecture,
                        size: 100,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t('shutterTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 48),
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
                        ),
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 24,
                          color: Colors.white,
                        ),
                        label: Text(
                          t('enterLab'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          curtainScreen();
                          setState(() {
                            _curtainLifted = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SimulationPainter extends CustomPainter {
  final int scenario, step;
  final Offset pan;
  final double zoom;

  final List<Map<String, dynamic>> s1Shapes;
  final Map<String, dynamic> s1Lights;
  final String s1BinText;

  final List<Map<String, dynamic>> s2Sticks;
  final bool s2TriedWrong;

  final List<Map<String, dynamic>> s3Sticks;
  final int s3Count;

  final List<Map<String, dynamic>> s4Shapes;

  final List<Map<String, dynamic>> s5Tiles;
  final int s5Mode;
  final bool s5Error;

  final String? activeDragId;
  final Offset dragPos;

  SimulationPainter({
    required this.scenario,
    required this.step,
    required this.pan,
    required this.zoom,
    required this.s1Shapes,
    required this.s1Lights,
    required this.s1BinText,
    required this.s2Sticks,
    required this.s2TriedWrong,
    required this.s3Sticks,
    required this.s3Count,
    required this.s4Shapes,
    required this.s5Tiles,
    required this.s5Mode,
    required this.s5Error,
    this.activeDragId,
    required this.dragPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      _renderScenario1(canvas);
    } else if (scenario == 2) {
      _renderScenario2(canvas);
    } else if (scenario == 3) {
      _renderScenario3(canvas);
    } else if (scenario == 4) {
      _renderScenario4(canvas);
    } else if (scenario == 5) {
      _renderScenario5(canvas);
    }

    canvas.restore();
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
    double sw = 2,
  ]) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, [
    FontWeight weight = FontWeight.bold,
    TextAlign align = TextAlign.center,
  ]) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        x - (align == TextAlign.center ? tp.width / 2 : 0),
        y - tp.height / 2,
      ),
    );
  }

  void _drawShape(
    Canvas canvas,
    String type,
    double x,
    double y, [
    double rot = 0,
  ]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rot * pi / 180);

    Path path = Path();
    if (type == 'rect') {
      path.addPolygon(const [
        Offset(-50, -30),
        Offset(50, -30),
        Offset(50, 30),
        Offset(-50, 30),
      ], true);
    } else if (type == 'square') {
      path.addPolygon(const [
        Offset(-40, -40),
        Offset(40, -40),
        Offset(40, 40),
        Offset(-40, 40),
      ], true);
    } else if (type == 'para') {
      path.addPolygon(const [
        Offset(-50, -30),
        Offset(60, -30),
        Offset(30, 30),
        Offset(-80, 30),
      ], true);
    } else if (type == 'rhombus') {
      path.addPolygon(const [
        Offset(0, -50),
        Offset(40, 0),
        Offset(0, 50),
        Offset(-40, 0),
      ], true);
    } else if (type == 'trap') {
      path.addPolygon(const [
        Offset(-30, -30),
        Offset(30, -30),
        Offset(50, 30),
        Offset(-50, 30),
      ], true);
    }
    canvas.drawPath(path, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _drawStick(
    Canvas canvas,
    double x,
    double y,
    double len,
    String colorStr,
    bool isVert,
  ) {
    Color col = colorStr == 'red'
        ? Colors.redAccent
        : colorStr == 'blue'
        ? Colors.blueAccent
        : Colors.purpleAccent;
    canvas.save();
    canvas.translate(x, y);
    if (isVert) {
      _drawRoundedRect(
        canvas,
        -10,
        -len / 2,
        20,
        len,
        10,
        col,
        const Color(0xFF0F172A),
        3,
      );
    } else {
      _drawRoundedRect(
        canvas,
        -len / 2,
        -10,
        len,
        20,
        10,
        col,
        const Color(0xFF0F172A),
        3,
      );
    }
    canvas.restore();
  }

  void _drawBlueprintGrid(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -200,
      -150,
      400,
      300,
      0,
      const Color(0xFFE0F2FE),
      const Color(0xFF0EA5E9),
      4,
    );
    Paint gridPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withOpacity(0.3)
      ..strokeWidth = 1;
    for (double i = -180; i < 200; i += 20) {
      canvas.drawLine(Offset(i, -150), Offset(i, 150), gridPaint);
    }
    for (double j = -130; j < 150; j += 20) {
      canvas.drawLine(Offset(-200, j), Offset(200, j), gridPaint);
    }
  }

  // --- SCENARIO 1 ---
  void _renderScenario1(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      -400,
      -200,
      100,
      400,
      8,
      const Color(0xFF334155),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "CONVEYOR", -350, -220, 16, Colors.white54);

    double mx = 0, my = -100;
    _drawRoundedRect(
      canvas,
      mx - 120,
      my,
      240,
      240,
      16,
      const Color(0xFF1E293B),
      const Color(0xFF0F172A),
      6,
    );
    _drawRoundedRect(
      canvas,
      mx - 90,
      my + 30,
      180,
      120,
      8,
      const Color(0xFF0F172A),
      const Color(0xFF475569),
      4,
    );

    double lw = 200, lh = 30;
    Color cOpp = s1Lights['opp'] ? Colors.green : const Color(0xFF475569);
    Color cAll = s1Lights['all'] ? Colors.green : const Color(0xFF475569);
    Color cAng = s1Lights['ang'] == 'red'
        ? Colors.red
        : s1Lights['ang'] == 'green'
        ? Colors.green
        : const Color(0xFF475569);

    _drawRoundedRect(
      canvas,
      mx - 100,
      my + 170,
      lw,
      lh,
      4,
      cOpp,
      const Color(0xFF0F172A),
    );
    _drawText(canvas, "Opposite Sides Equal", mx, my + 185, 12, Colors.white);
    _drawRoundedRect(
      canvas,
      mx - 100,
      my + 210,
      lw,
      lh,
      4,
      cAll,
      const Color(0xFF0F172A),
    );
    _drawText(canvas, "All Sides Equal", mx, my + 225, 12, Colors.white);
    _drawRoundedRect(
      canvas,
      mx - 100,
      my + 250,
      lw,
      lh,
      4,
      cAng,
      const Color(0xFF0F172A),
    );
    _drawText(canvas, "All Angles 90°", mx, my + 265, 12, Colors.white);

    _drawRoundedRect(
      canvas,
      200,
      -100,
      150,
      200,
      8,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "SORT BIN", 275, -120, 16, Colors.white54);
    if (s1BinText.isNotEmpty) {
      _drawText(
        canvas,
        s1BinText,
        275,
        0,
        18,
        s1Lights['ang'] == 'red' ? Colors.red : Colors.green,
      );
    }

    for (var sh in s1Shapes) {
      if (sh['placed']) continue;
      double cx = (sh['x'] as num).toDouble();
      double cy = (sh['y'] as num).toDouble();
      if (activeDragId == 's1_${sh['id']}') {
        cx = dragPos.dx;
        cy = dragPos.dy;
      }
      _drawShape(canvas, sh['type'], cx, cy);
    }

    if (step == 3) {
      _drawRoundedRect(
        canvas,
        -100,
        220,
        200,
        50,
        25,
        const Color(0xFF6366F1),
        const Color(0xFF0F172A),
        4,
      );
      _drawText(canvas, "Show Summary", 0, 245, 16, Colors.white);
    }
  }

  // --- SCENARIO 2 ---
  void _renderScenario2(Canvas canvas) {
    _drawBlueprintGrid(canvas);

    Map<String, dynamic> slots = {
      'bottom': {'x': 0.0, 'y': 50.0, 'isVert': false},
      'right': {'x': 100.0, 'y': 0.0, 'isVert': true},
      'top': {'x': 0.0, 'y': -50.0, 'isVert': false},
      'left': {'x': -100.0, 'y': 0.0, 'isVert': true},
    };

    _drawRoundedRect(
      canvas,
      -380,
      -150,
      150,
      300,
      8,
      const Color(0xFFF1F5F9),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "TOOLBOX", -305, -130, 16, const Color(0xFF0F172A));

    Map<String, Offset> tbPos = {
      'r1': const Offset(-305, -70),
      'r2': const Offset(-305, -30),
      'b1': const Offset(-305, 40),
      'b2': const Offset(-305, 80),
    };

    for (var st in s2Sticks) {
      double cx = 0, cy = 0;
      double dLen = (st['len'] as num).toDouble();
      bool isV = false;

      if (st['slot'] != null) {
        cx = (slots[st['slot']]['x'] as num).toDouble();
        cy = (slots[st['slot']]['y'] as num).toDouble();
        isV = slots[st['slot']]['isVert'];
      } else if (activeDragId == 's2_${st['id']}') {
        cx = dragPos.dx;
        cy = dragPos.dy;
      } else {
        cx = tbPos[st['id']]!.dx;
        cy = tbPos[st['id']]!.dy;
        dLen *= 0.6;
      }
      _drawStick(canvas, cx, cy, dLen, st['c'], isV);
    }

    if (s2TriedWrong) {
      _drawText(
        canvas,
        "Mismatch! Use Correct Stick",
        0,
        -130,
        16,
        Colors.redAccent,
      );
    }

    if (step == 4) {
      Paint p = Paint()..color = Colors.green;
      canvas.drawRect(const Rect.fromLTWH(85, 35, 15, 15), p);
      canvas.drawRect(const Rect.fromLTWH(-100, 35, 15, 15), p);
      canvas.drawRect(const Rect.fromLTWH(85, -50, 15, 15), p);
      canvas.drawRect(const Rect.fromLTWH(-100, -50, 15, 15), p);
    }
  }

  // --- SCENARIO 3 ---
  void _renderScenario3(Canvas canvas) {
    _drawBlueprintGrid(canvas);

    _drawRoundedRect(
      canvas,
      -380,
      -100,
      150,
      200,
      8,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "DUPLICATOR", -305, -70, 16, const Color(0xFF0F172A));

    bool cloneAct = step >= 1 && s3Count < 4;
    _drawRoundedRect(
      canvas,
      -350,
      -40,
      90,
      40,
      8,
      cloneAct ? Colors.purple : const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      "CLONE",
      -305,
      -20,
      14,
      cloneAct ? Colors.white : const Color(0xFF475569),
    );

    _drawRoundedRect(
      canvas,
      -340,
      20,
      70,
      30,
      4,
      const Color(0xFF1E293B),
      Colors.transparent,
      0,
    );
    _drawText(canvas, "$s3Count / 4", -305, 35, 16, Colors.greenAccent);

    Map<String, dynamic> slots = {
      'bottom': {'x': 0.0, 'y': 75.0, 'isVert': false},
      'right': {'x': 75.0, 'y': 0.0, 'isVert': true},
      'top': {'x': 0.0, 'y': -75.0, 'isVert': false},
      'left': {'x': -75.0, 'y': 0.0, 'isVert': true},
    };

    for (int i = 0; i < s3Sticks.length; i++) {
      var st = s3Sticks[i];
      double cx = 0, cy = 0, dLen = 150;
      bool isV = false;
      if (st['slot'] != null) {
        cx = (slots[st['slot']]['x'] as num).toDouble();
        cy = (slots[st['slot']]['y'] as num).toDouble();
        isV = slots[st['slot']]['isVert'];
      } else if (activeDragId == 's3_${st['id']}') {
        cx = dragPos.dx;
        cy = dragPos.dy;
      } else {
        cx = -305;
        // Position visually inside the duplicator under clone button when step >= 1
        cy = step >= 1 ? 10.0 + i * 25 : 120.0 + i * 25;
        dLen = 100;
      }
      _drawStick(canvas, cx, cy, dLen, 'purple', isV);
    }
  }

  // --- SCENARIO 4 ---
  void _renderScenario4(Canvas canvas) {
    _drawRoundedRect(
      canvas,
      150,
      -150,
      200,
      300,
      12,
      const Color(0xFFF1F5F9),
      Colors.blueAccent,
      4,
    );
    _drawText(canvas, "RECTANGLE ZONE", 250, -170, 16, Colors.white54);

    _drawRoundedRect(
      canvas,
      -380,
      -240,
      200,
      80,
      8,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      "TOOLS (Drag onto shapes)",
      -280,
      -220,
      14,
      const Color(0xFF0F172A),
    );

    _drawRoundedRect(
      canvas,
      -360,
      -200,
      40,
      40,
      4,
      const Color(0xFFE2E8F0),
      const Color(0xFF0F172A),
    );
    _drawText(canvas, "Ruler", -340, -150, 12, Colors.white);

    _drawRoundedRect(
      canvas,
      -240,
      -200,
      40,
      40,
      4,
      const Color(0xFFE2E8F0),
      const Color(0xFF0F172A),
    );
    _drawText(canvas, "Angle", -220, -150, 12, Colors.white);

    for (var sh in s4Shapes) {
      double cx = (sh['x'] as num).toDouble();
      double cy = (sh['y'] as num).toDouble();
      double rot = (sh['rot'] as num).toDouble();

      if (activeDragId == 's4_${sh['id']}') {
        cx = dragPos.dx;
        cy = dragPos.dy;
      } else if (sh['inZone']) {
        int idx = s4Shapes.where((s) => s['inZone']).toList().indexOf(sh);
        cx = 250;
        cy = -60.0 + idx * 120;
        rot = 0.0;
      }

      _drawShape(canvas, sh['type'], cx, cy, rot);

      if (sh['scanned'] && !sh['inZone']) {
        _drawRoundedRect(
          canvas,
          cx - 40,
          cy - 15,
          80,
          30,
          4,
          Colors.white.withOpacity(0.9),
          const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          sh['trueRect'] ? "90°, Opp=" : "Not 90°",
          cx,
          cy,
          12,
          sh['trueRect'] ? Colors.green[800]! : Colors.red[800]!,
        );
      }
    }

    if (activeDragId == 'tool_ruler' || activeDragId == 'tool_angle') {
      _drawRoundedRect(
        canvas,
        dragPos.dx - 20,
        dragPos.dy - 20,
        40,
        40,
        4,
        const Color(0xFFCBD5E1),
        const Color(0xFF0F172A),
      );
    }

    if (step == 3 && s4Shapes.where((s) => s['inZone']).length == 2) {
      _drawRoundedRect(
        canvas,
        180,
        180,
        140,
        50,
        25,
        Colors.green,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(canvas, "CHECK", 250, 205, 18, Colors.white);
    }
  }

  // --- SCENARIO 5 ---
  void _renderScenario5(Canvas canvas) {
    double gW = 8 * 30, gH = 6 * 30, gX = -120, gY = -100;
    _drawRoundedRect(
      canvas,
      gX,
      gY,
      gW,
      gH,
      0,
      Colors.white,
      const Color(0xFF0F172A),
      4,
    );

    Paint pLine = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(gX + i * 30, gY),
        Offset(gX + i * 30, gY + gH),
        pLine,
      );
    }
    for (int j = 1; j < 6; j++) {
      canvas.drawLine(
        Offset(gX, gY + j * 30),
        Offset(gX + gW, gY + j * 30),
        pLine,
      );
    }

    _drawRoundedRect(
      canvas,
      -380,
      -100,
      120,
      200,
      8,
      const Color(0xFFF8FAFC),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(canvas, "DISPENSER", -320, -70, 14, const Color(0xFF0F172A));

    _drawRoundedRect(
      canvas,
      -360,
      -40,
      80,
      40,
      8,
      s5Mode == 3 ? Colors.blueAccent : const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "3x3 Tile",
      -320,
      -20,
      14,
      s5Mode == 3 ? Colors.white : const Color(0xFF0F172A),
    );

    _drawRoundedRect(
      canvas,
      -360,
      20,
      80,
      40,
      8,
      s5Mode == 2 ? Colors.blueAccent : const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      "2x2 Tile",
      -320,
      40,
      14,
      s5Mode == 2 ? Colors.white : const Color(0xFF0F172A),
    );

    _drawRoundedRect(
      canvas,
      200,
      20,
      100,
      80,
      8,
      const Color(0xFFFEE2E2),
      Colors.redAccent,
      3,
    );
    _drawText(canvas, "TRASH", 250, 60, 16, Colors.redAccent);

    for (var t in s5Tiles) {
      double ts = (t['size'] as num).toDouble() * 30.0;
      _drawRoundedRect(
        canvas,
        gX + (t['c'] as num).toDouble() * 30.0,
        gY + (t['r'] as num).toDouble() * 30.0,
        ts,
        ts,
        0,
        t['size'] == 3 ? Colors.red[300]!.withOpacity(0.8) : Colors.blue[400]!,
        const Color(0xFF0F172A),
        2,
      );
    }

    if (activeDragId == 's5_tile') {
      double ts = s5Mode * 30.0;
      _drawRoundedRect(
        canvas,
        dragPos.dx - ts / 2,
        dragPos.dy - ts / 2,
        ts,
        ts,
        0,
        Colors.blue.withOpacity(0.5),
        const Color(0xFF0F172A),
        2,
      );
    }

    if (s5Error) {
      _drawText(
        canvas,
        "Gaps/Overlaps! Try a different size.",
        gX + gW / 2,
        gY - 30,
        16,
        Colors.redAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
