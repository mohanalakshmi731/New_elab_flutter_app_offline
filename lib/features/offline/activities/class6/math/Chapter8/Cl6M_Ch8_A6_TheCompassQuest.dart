// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'The Compass Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const Cl6M_Ch8_A6_TheCompassQuest(),
    ),
  );
}

// --- Data Models ---
class SimPoint {
  final String id;
  double x, y;
  final String label;
  SimPoint({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
  });
}

class SimLine {
  final SimPoint p1;
  final SimPoint p2;
  SimLine({required this.p1, required this.p2});
}

class SimArc {
  final double cx, cy, r;
  double sAng, eAng;
  final Color? color;
  SimArc({
    required this.cx,
    required this.cy,
    required this.r,
    required this.sAng,
    required this.eAng,
    this.color,
  });
}

class SimTempLine {
  double startX, startY, endX, endY;
  final SimPoint startPt;
  SimTempLine({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.startPt,
  });
}

class SimIntersection {
  final double x, y;
  bool matched;
  SimIntersection({required this.x, required this.y, this.matched = false});
}

class SimCompass {
  double x, y, r, angle;
  bool isPinned;
  String? pinId;
  SimArc? currentArc;
  SimCompass({
    this.x = -200,
    this.y = 150,
    this.r = 160,
    this.angle = -pi / 6,
    this.isPinned = false,
    this.pinId,
  });
}

class SimRuler {
  double x, y, width;
  double pxPerCm;
  bool active;
  SimRuler({
    this.x = -300,
    this.y = 250,
    this.width = 640,
    this.pxPerCm = 40,
    this.active = true,
  });
}

enum GeomTool { compass, line, point }

enum DragMode { none, moveCompass, resizeCompass, drawCompass, drawLine, pan }

// --- Main Lab Widget ---
class Cl6M_Ch8_A6_TheCompassQuest extends StatefulWidget {
  const Cl6M_Ch8_A6_TheCompassQuest({super.key});

  @override
  State<Cl6M_Ch8_A6_TheCompassQuest> createState() =>
      _Cl6M_Ch8_A6_TheCompassQuestState();
}

class _Cl6M_Ch8_A6_TheCompassQuestState
    extends State<Cl6M_Ch8_A6_TheCompassQuest>
    with TickerProviderStateMixin {
  // Config & State
  String _lang = 'en';
  bool _sidebarOpen = true;
  double _sidebarWidth = 350.0;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;

  // Camera
  double _zoom = 1.0;
  double _baseZoom = 1.0;
  double _panX = 0.0, _panY = 0.0;
  final GlobalKey _canvasKey = GlobalKey();

  // Engine State
  int _scenario = 1;
  int _step = 0;
  GeomTool _activeTool = GeomTool.compass;
  DragMode _dragMode = DragMode.none;
  double _prevAng = 0;
  Offset _panStart = Offset.zero;

  // Entities
  List<SimPoint> _points = [];
  List<SimLine> _lines = [];
  List<SimArc> _arcs = [];
  List<SimIntersection> _intersections = [];
  SimTempLine? _tempLine;
  SimCompass _compass = SimCompass();
  SimRuler _ruler = SimRuler();

  // Trackers
  bool _s5WrongE = false;

  // Animation & Audio
  late AnimationController _gameLoopController;
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

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _gameLoopController.addListener(() => setState(() {}));

    _loadScenario(1);
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

  // --- I18N ---
  String t(String key) =>
      _translations[_lang]?[key] ?? _translations['en']?[key] ?? key;

  void _toggleLanguage() {
    playClick();
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
  }

  // --- Game Math & Logic ---
  double _distPts(double x1, double y1, double x2, double y2) =>
      sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));

  List<Offset> _intersectCircles(
    double x1,
    double y1,
    double r1,
    double x2,
    double y2,
    double r2,
  ) {
    double d = _distPts(x1, y1, x2, y2);
    if (d > r1 + r2 || d < (r1 - r2).abs() || d == 0) return [];
    double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    double h = sqrt(r1 * r1 - a * a);
    double x3 = x1 + a * (x2 - x1) / d;
    double y3 = y1 + a * (y2 - y1) / d;
    double ix1 = x3 + h * (y2 - y1) / d;
    double iy1 = y3 - h * (x2 - x1) / d;
    double ix2 = x3 - h * (y2 - y1) / d;
    double iy2 = y3 + h * (x2 - x1) / d;
    return [Offset(ix1, iy1), Offset(ix2, iy2)];
  }

  String _getNextPointLabel() {
    var existing = _points.map((p) => p.label).toList();
    if (_scenario == 1) return 'A';
    if (_scenario == 2) return existing.contains('C') ? 'D' : 'C';
    if (_scenario == 3) return existing.contains('S') ? 'R' : 'S';
    if (_scenario == 4) return existing.contains('B') ? 'D' : 'B';
    if (_scenario == 5) return 'E';
    return 'P';
  }

  void _recalculateIntersections() {
    _intersections.clear();
    for (int i = 0; i < _arcs.length; i++) {
      for (int j = i + 1; j < _arcs.length; j++) {
        var a1 = _arcs[i];
        var a2 = _arcs[j];
        if (a1.cx == a2.cx && a1.cy == a2.cy) continue;

        List<Offset> pts = _intersectCircles(
          a1.cx,
          a1.cy,
          a1.r,
          a2.cx,
          a2.cy,
          a2.r,
        );
        for (var p in pts) {
          bool valid = false;
          int cm1 = (a1.r / 40).round();
          int cm2 = (a2.r / 40).round();

          if (_scenario == 1 && cm1 == 5 && cm2 == 5 && p.dy < 0) valid = true;
          if (_scenario == 2 && cm1 == 5 && cm2 == 5) valid = true;
          if (_scenario == 3 && cm1 == 7 && cm2 == 7) valid = true;
          if (_scenario == 4 && cm1 == 4 && cm2 == 4 && p.dx > 0) valid = true;
          if (_scenario == 4 && cm1 == 7 && cm2 == 7 && p.dx < 0) valid = true;
          if (_scenario == 5 && cm1 == 5 && cm2 == 5) {
            // 5.3 ~ 5 visually rounded
            bool isCA =
                ((a1.cx == 0 && a1.cy == 200 && a2.cx == 0 && a2.cy == -100) ||
                (a2.cx == 0 && a2.cy == 200 && a1.cx == 0 && a1.cy == -100));
            if (isCA && !_s5WrongE) {
              _s5WrongE = true;
              _checkStepLogic();
            }
            bool isCD =
                ((a1.cx == 0 && a1.cy == 200 && a2.cx == -150 && a2.cy == 50) ||
                (a2.cx == 0 && a2.cy == 200 && a1.cx == -150 && a1.cy == 50));
            if (isCD) valid = true;
          }

          if (valid) {
            bool alreadyPoint = _points.any(
              (ep) => _distPts(ep.x, ep.y, p.dx, p.dy) < 5,
            );
            if (!alreadyPoint)
              _intersections.add(SimIntersection(x: p.dx, y: p.dy));
          }
        }
      }
    }
  }

  void _checkStepLogic() {
    bool success = false;
    if (_scenario == 1) {
      if (_step == 0 && (_compass.r / 40).round() == 5) success = true;
      if (_step == 1 &&
          _arcs.any((a) => a.cx == -100 && (a.r / 40).round() == 5))
        success = true;
      if (_step == 2 &&
          _arcs.any((a) => a.cx == 100 && (a.r / 40).round() == 5))
        success = true;
      if (_step == 3 && _points.any((p) => p.label == 'A')) success = true;
      if (_step == 4 && _lines.length >= 2) {
        success = true;
        Future.delayed(const Duration(seconds: 1), _triggerSuccess);
      }
    }
    if (_scenario == 2) {
      if (_step == 0 && (_compass.r / 40).round() == 5) success = true;
      if (_step == 1 &&
          _arcs.any((a) => a.cx == -100 && (a.r / 40).round() == 5))
        success = true;
      if (_step == 2 &&
          _arcs.any((a) => a.cx == 100 && (a.r / 40).round() == 5))
        success = true;
      if (_step == 3 &&
          _points.any((p) => p.label == 'C') &&
          _points.any((p) => p.label == 'D'))
        success = true;
      if (_step == 4 && _lines.length >= 5) {
        success = true;
        Future.delayed(const Duration(seconds: 1), _triggerSuccess);
      }
    }
    if (_scenario == 3) {
      if (_step == 0 && _points.any((p) => p.label == 'Q')) success = true;
      if (_step == 1 && (_compass.r / 40).round() == 7) success = true;
      if (_step == 2 && _points.any((p) => p.label == 'S')) success = true;
      if (_step == 3 && _points.any((p) => p.label == 'R')) success = true;
      if (_step == 4 && _lines.length >= 5) {
        success = true;
        Future.delayed(const Duration(seconds: 1), _triggerSuccess);
      }
    }
    if (_scenario == 4) {
      if (_step == 0 && (_compass.r / 40).round() == 4) success = true;
      if (_step == 1 && _points.any((p) => p.label == 'B')) success = true;
      if (_step == 2 && (_compass.r / 40).round() == 7) success = true;
      if (_step == 3 && _points.any((p) => p.label == 'D')) success = true;
      if (_step == 4 && _lines.length >= 5) {
        success = true;
        Future.delayed(const Duration(seconds: 1), _triggerSuccess);
      }
    }
    if (_scenario == 5) {
      if (_step == 0 && (_compass.r).round() == 212)
        success = true; // 212 is hypot(150, 150)
      if (_step == 1 && _s5WrongE) success = true;
      if (_step == 2 && _intersections.isNotEmpty) success = true;
      if (_step == 3 && _lines.length >= 6) {
        success = true;
        Future.delayed(const Duration(seconds: 1), _triggerSuccess);
      }
    }

    if (success) {
      setState(() => _step++);
      playPageOpen();
    }
  }

  void _triggerSuccess() {
    setState(() {
      _step = 5;
      if (_scenario == 5) {
        _showSuccessPopup = true;
        playPageOpen();
      }
    });
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _points.clear();
      _lines.clear();
      _arcs.clear();
      _intersections.clear();
      _compass = SimCompass(x: -200, y: 150, r: 100, angle: -pi / 6);
      _ruler.active = true;
      _activeTool = GeomTool.compass;
      _showSuccessPopup = false;
      _s5WrongE = false;

      if (_scenario == 1) {
        _points.addAll([
          SimPoint(id: 'B', x: -100, y: 50, label: 'B'),
          SimPoint(id: 'C', x: 100, y: 50, label: 'C'),
        ]);
      } else if (_scenario == 2) {
        _points.addAll([
          SimPoint(id: 'A', x: -100, y: 50, label: 'A'),
          SimPoint(id: 'B', x: 100, y: 50, label: 'B'),
        ]);
        _lines.add(SimLine(p1: _points[0], p2: _points[1]));
        _ruler.active = false;
      } else if (_scenario == 3) {
        _points.add(SimPoint(id: 'P', x: -140, y: 50, label: 'P'));
      } else if (_scenario == 4) {
        _points.addAll([
          SimPoint(id: 'A', x: 0, y: -70, label: 'A'),
          SimPoint(id: 'C', x: 0, y: 170, label: 'C'),
        ]);
        _lines.add(SimLine(p1: _points[0], p2: _points[1]));
      } else if (_scenario == 5) {
        _points.addAll([
          SimPoint(id: 'A', x: 0, y: -100, label: 'A'),
          SimPoint(id: 'B', x: 150, y: 50, label: 'B'),
          SimPoint(id: 'C', x: 0, y: 200, label: 'C'),
          SimPoint(id: 'D', x: -150, y: 50, label: 'D'),
        ]);
        _lines.addAll([
          SimLine(p1: _points[0], p2: _points[1]),
          SimLine(p1: _points[1], p2: _points[2]),
          SimLine(p1: _points[2], p2: _points[3]),
          SimLine(p1: _points[3], p2: _points[0]),
        ]);
        _ruler.active = false;
      }

      _fitScreen();
    });
  }

  void _nextScenario() {
    playPageOpen();
    if (_scenario < 5) _loadScenario(_scenario + 1);
  }

  void _resetLab() {
    playError();
    setState(() {
      _showCurtain = true;
      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() {
          _lang = 'en';
          _loadScenario(1);
          _showCurtain = false;
        });
      });
    });
  }

  void _fitScreen() {
    if (_canvasKey.currentContext != null) {
      final size =
          (_canvasKey.currentContext!.findRenderObject() as RenderBox).size;
      double effWidth = size.width - 20;
      double effHeight = size.height - 60;
      _zoom = max(0.6, min(1.5, min(effWidth / 800, effHeight / 600)));
    } else {
      _zoom = 1.0;
    }
    _panX = 0;
    _panY = 0;
  }

  // --- Gesture Handling ---
  Offset _getWorldPt(Offset localPt, Size size) {
    double x = (localPt.dx - size.width / 2 - _panX) / _zoom;
    double y = (localPt.dy - size.height / 2 - _panY) / _zoom;
    return Offset(x, y);
  }

  // Point snapping utility
  void _tryPlacePoint(Offset worldPt) {
    try {
      var hitInt = _intersections.firstWhere(
        (i) => !i.matched && _distPts(i.x, i.y, worldPt.dx, worldPt.dy) < 50,
      );
      hitInt.matched = true;
      _points.add(
        SimPoint(
          id: 'P_${DateTime.now().millisecondsSinceEpoch}',
          x: hitInt.x,
          y: hitInt.y,
          label: _getNextPointLabel(),
        ),
      );
      playClick();
      _checkStepLogic();
    } catch (e) {
      // Intersection not hit, do nothing
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_canvasKey.currentContext == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPt = renderBox.globalToLocal(details.focalPoint);
    final worldPt = _getWorldPt(localPt, renderBox.size);

    _baseZoom = _zoom;

    if (_activeTool == GeomTool.compass) {
      double pencX = _compass.x + _compass.r * cos(_compass.angle);
      double pencY = _compass.y + _compass.r * sin(_compass.angle);
      double apexX = _compass.x + (pencX - _compass.x) / 2;
      double apexY = _compass.y - 120;
      double handleAng = _compass.angle + pi / 2;
      double hx = pencX + 30 * cos(handleAng);
      double hy = pencY + 30 * sin(handleAng);

      if (_distPts(worldPt.dx, worldPt.dy, hx, hy) < 50) {
        _dragMode = DragMode.drawCompass;
        _prevAng = _compass.angle;
        if (_compass.isPinned) {
          _compass.currentArc = SimArc(
            cx: _compass.x,
            cy: _compass.y,
            r: _compass.r,
            sAng: _compass.angle,
            eAng: _compass.angle,
          );
        }
        return;
      }
      if (_distPts(worldPt.dx, worldPt.dy, pencX, pencY) < 50) {
        _dragMode = DragMode.resizeCompass;
        return;
      }
      if (_distPts(worldPt.dx, worldPt.dy, apexX, apexY) < 60) {
        _dragMode = DragMode.moveCompass;
        return;
      }
    } else if (_activeTool == GeomTool.line) {
      try {
        var closePt = _points.firstWhere(
          (p) => _distPts(p.x, p.y, worldPt.dx, worldPt.dy) < 50,
        );
        _dragMode = DragMode.drawLine;
        _tempLine = SimTempLine(
          startX: closePt.x,
          startY: closePt.y,
          endX: worldPt.dx,
          endY: worldPt.dy,
          startPt: closePt,
        );
        return;
      } catch (e) {
        if (_scenario == 3 && _step == 0 && _points.isNotEmpty) {
          if (_distPts(_points[0].x, _points[0].y, worldPt.dx, worldPt.dy) <
              50) {
            _dragMode = DragMode.drawLine;
            _tempLine = SimTempLine(
              startX: _points[0].x,
              startY: _points[0].y,
              endX: worldPt.dx,
              endY: worldPt.dy,
              startPt: _points[0],
            );
            return;
          }
        }
      }
    } else if (_activeTool == GeomTool.point) {
      _tryPlacePoint(worldPt);
    }

    _dragMode = DragMode.pan;
    _panStart = Offset(localPt.dx - _panX, localPt.dy - _panY);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_canvasKey.currentContext == null) return;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPt = renderBox.globalToLocal(details.focalPoint);
    final worldPt = _getWorldPt(localPt, renderBox.size);

    if (_dragMode == DragMode.moveCompass) {
      _compass.x = worldPt.dx;
      _compass.y = worldPt.dy + 120;
      _compass.isPinned = false;
      _compass.pinId = null;

      try {
        var snap = _points.firstWhere(
          (p) => _distPts(p.x, p.y, _compass.x, _compass.y) < 40,
        );
        _compass.x = snap.x;
        _compass.y = snap.y;
        _compass.isPinned = true;
        _compass.pinId = snap.id;
      } catch (e) {
        if (_ruler.active) {
          double rZeroX = _ruler.x + 20;
          if (_distPts(_compass.x, _compass.y, rZeroX, _ruler.y) < 50) {
            _compass.x = rZeroX;
            _compass.y = _ruler.y;
            _compass.isPinned = true;
          }
        }
      }
    } else if (_dragMode == DragMode.resizeCompass) {
      double dx = worldPt.dx - _compass.x;
      double dy = worldPt.dy - _compass.y;
      _compass.r = max(40.0, sqrt(dx * dx + dy * dy));
      _compass.angle = atan2(dy, dx);

      if (_compass.isPinned && _compass.y == _ruler.y) {
        int cm = (_compass.r / 40).round();
        _compass.r = cm * 40.0;
        _compass.angle = 0;
      } else if (_compass.isPinned) {
        try {
          var snapToPt = _points.firstWhere(
            (p) =>
                p.id != _compass.pinId &&
                _distPts(p.x, p.y, worldPt.dx, worldPt.dy) < 40,
          );
          _compass.r = _distPts(_compass.x, _compass.y, snapToPt.x, snapToPt.y);
          _compass.angle = atan2(
            snapToPt.y - _compass.y,
            snapToPt.x - _compass.x,
          );
        } catch (e) {}
      }
    } else if (_dragMode == DragMode.drawCompass) {
      double dx = worldPt.dx - _compass.x;
      double dy = worldPt.dy - _compass.y;
      _compass.angle = atan2(dy, dx);

      if (_compass.currentArc != null) {
        var ca = _compass.currentArc!;
        double diff = _compass.angle - _prevAng;
        while (diff > pi) diff -= pi * 2;
        while (diff < -pi) diff += pi * 2;

        if (diff > 0)
          ca.eAng = max(ca.eAng, ca.eAng + diff);
        else
          ca.sAng = min(ca.sAng, ca.sAng + diff);

        _prevAng = _compass.angle;
      }
    } else if (_dragMode == DragMode.drawLine && _tempLine != null) {
      _tempLine!.endX = worldPt.dx;
      _tempLine!.endY = worldPt.dy;

      if (_scenario == 3 && _step == 0) {
        _tempLine!.endY = _tempLine!.startY;
        if (((worldPt.dx - _tempLine!.startX) - 280).abs() < 40) {
          _tempLine!.endX = _tempLine!.startX + 280;
        }
      } else {
        try {
          var snap = _points.firstWhere(
            (p) =>
                p.id != _tempLine!.startPt.id &&
                _distPts(p.x, p.y, worldPt.dx, worldPt.dy) < 40,
          );
          _tempLine!.endX = snap.x;
          _tempLine!.endY = snap.y;
        } catch (e) {}
      }
    } else if (_activeTool == GeomTool.point) {
      _tryPlacePoint(worldPt);
    } else if (_dragMode == DragMode.pan) {
      setState(() {
        if (details.scale != 1.0) {
          _zoom = max(0.4, min(3.0, _baseZoom * details.scale));
        }
        _panX = localPt.dx - _panStart.dx;
        _panY = localPt.dy - _panStart.dy;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_dragMode == DragMode.drawCompass && _compass.currentArc != null) {
      _arcs.add(
        SimArc(
          cx: _compass.currentArc!.cx,
          cy: _compass.currentArc!.cy,
          r: _compass.currentArc!.r,
          sAng: _compass.currentArc!.sAng,
          eAng: _compass.currentArc!.eAng,
        ),
      );
      _compass.currentArc = null;
      playClick();
      _recalculateIntersections();
      _checkStepLogic();
    } else if (_dragMode == DragMode.resizeCompass) {
      playClick();
      _checkStepLogic();
    } else if (_dragMode == DragMode.drawLine && _tempLine != null) {
      var sl = _tempLine!;
      if (_scenario == 3 && _step == 0) {
        if (sl.endX == sl.startX + 280 && sl.endY == sl.startY) {
          String qId = 'P_${DateTime.now().millisecondsSinceEpoch}';
          var qPt = SimPoint(id: qId, x: sl.endX, y: sl.endY, label: 'Q');
          _points.add(qPt);
          _lines.add(SimLine(p1: sl.startPt, p2: qPt));
          playClick();
          _checkStepLogic();
        } else {
          playError();
        }
      } else {
        try {
          var endPt = _points.firstWhere(
            (p) => p.id != sl.startPt.id && p.x == sl.endX && p.y == sl.endY,
          );
          _lines.add(SimLine(p1: sl.startPt, p2: endPt));
          playClick();
          _checkStepLogic();
        } catch (e) {
          playError();
        }
      }
      _tempLine = null;
    }
    _dragMode = DragMode.none;
  }

  // --- Widgets ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: (_) => SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersive,
      ), // Using onPanDown removes tap interference!
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              left: _sidebarOpen ? _sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildCanvasArea(),
            ),

            // Sidebar Area
            AnimatedPositioned(
              left: _sidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              top: 0,
              bottom: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildSidebar(),
            ),

            // Sidebar Resizer Handle
            if (_sidebarOpen)
              AnimatedPositioned(
                left: _sidebarWidth - 10,
                width: 20,
                top: 0,
                bottom: 0,
                duration: const Duration(milliseconds: 300),
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanUpdate: (details) {
                      setState(() {
                        _sidebarWidth += details.delta.dx;
                        if (_sidebarWidth < 350) _sidebarWidth = 350;
                        if (_sidebarWidth >
                            MediaQuery.of(context).size.width * 0.6) {
                          _sidebarWidth =
                              MediaQuery.of(context).size.width * 0.6;
                        }
                      });
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // Toggle Sidebar Button (Fixed Position overlaying everything)
            Positioned(
              left: 16,
              top: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
                foregroundColor: Colors.white,
                onPressed: () {
                  playClick();
                  setState(() {
                    _sidebarOpen = !_sidebarOpen;
                  });
                },
                child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
              ),
            ),

            // Success Popup
            if (_showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  alignment: Alignment.center,
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
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
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_scenario < 5) {
                              _nextScenario();
                            } else {
                              _resetLab();
                            }
                          },
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
                          icon: Icon(
                            _scenario < 5
                                ? Icons.arrow_forward
                                : Icons.restart_alt,
                            color: Colors.white,
                          ),
                          label: Text(
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

            // Curtain Entry Screen
            if (_showCurtain) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Stack(
      children: [
        // Main Canvas
        Positioned.fill(
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                setState(() {
                  double zoomChange = pointerSignal.scrollDelta.dy > 0
                      ? -0.1
                      : 0.1;
                  _zoom = max(0.4, min(3.0, _zoom + zoomChange));
                });
              }
            },
            child: GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: Container(
                key: _canvasKey,
                color: const Color(0xFF0F172A),
                child: CustomPaint(
                  painter: GeometryPainter(
                    zoom: _zoom,
                    panX: _panX,
                    panY: _panY,
                    points: _points,
                    lines: _lines,
                    arcs: _arcs,
                    tempLine: _tempLine,
                    intersections: _intersections,
                    compass: _compass,
                    ruler: _ruler,
                    activeTool: _activeTool,
                    time: DateTime.now().millisecondsSinceEpoch / 200,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Geometry Tools Palette (Lowered top padding so it never overlays fixed menu button)
        Positioned(
          left: 16,
          top: 80,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _toolButton(
                  Icons.explore,
                  "Compass",
                  () => setState(() => _activeTool = GeomTool.compass),
                  _activeTool == GeomTool.compass,
                ),
                _toolButton(
                  Icons.horizontal_rule,
                  "Line",
                  () => setState(() => _activeTool = GeomTool.line),
                  _activeTool == GeomTool.line,
                ),
                _toolButton(
                  Icons.radio_button_checked,
                  "Point",
                  () => setState(() => _activeTool = GeomTool.point),
                  _activeTool == GeomTool.point,
                ),
              ],
            ),
          ),
        ),

        // Zoom Controls Palette
        Positioned(
          right: 16,
          top: 80,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _toolButton(
                  Icons.zoom_in,
                  "Zoom In",
                  () => setState(() => _zoom = min(3.0, _zoom + 0.2)),
                  false,
                ),
                _toolButton(
                  Icons.zoom_out,
                  "Zoom Out",
                  () => setState(() => _zoom = max(0.4, _zoom - 0.2)),
                  false,
                ),
                _toolButton(Icons.fit_screen, "Fit Screen", () {
                  playClick();
                  setState(() => _fitScreen());
                }, false),
              ],
            ),
          ),
        ),

        // HUD Bottom Center
        if (_step < _getScenarioSteps(_scenario).length)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: const Border(
                    top: BorderSide(color: Color(0xFF6366F1), width: 4),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
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
                    Expanded(
                      child: Text(
                        _getScenarioSteps(_scenario)[_step]['task']!,
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

        // Next Scenario Canvas Button
        if (_step >= _getScenarioSteps(_scenario).length &&
            _scenario < 5 &&
            !_showSuccessPopup)
          Positioned(
            bottom: 24,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: _nextScenario,
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
              icon: const Text(
                'Next Scenario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              label: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _toolButton(
    IconData icon,
    String tip,
    VoidCallback onTap,
    bool active, {
    Color color = const Color(0xFF6366F1),
  }) {
    return IconButton(
      icon: Icon(icon),
      color: active ? color : Colors.white70,
      style: active
          ? IconButton.styleFrom(backgroundColor: color.withOpacity(0.2))
          : null,
      onPressed: () {
        onTap();
        playClick();
      },
      tooltip: tip,
    );
  }

  Widget _buildSidebar() {
    var steps = _getScenarioSteps(_scenario);
    return Container(
      width: _sidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white24, width: 1)),
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
                // Header (Padding adjusted to leave space for the fixed menu icon on the top-left)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 66, 16, 16),
                  color: const Color(0xFF0F172A).withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.explore,
                            color: Color(0xFF6366F1),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t('appTitle'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 44.0, top: 4.0),
                        child: Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 44.0),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _toggleLanguage,
                              icon: const Icon(Icons.language, size: 16),
                              label: Text(_lang.toUpperCase()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white12,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _resetLab,
                              icon: const Icon(
                                Icons.refresh,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              label: const Text('Reset'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white12,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content Region
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
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              items: [1, 2, 3, 4, 5]
                                  .map(
                                    (id) => DropdownMenuItem(
                                      value: id,
                                      child: Text(
                                        t('s${id}_title'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  playDropdown();
                                  _loadScenario(v);
                                }
                              },
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
                                    Icons.track_changes,
                                    color: Color(0xFFF43F5E),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t('learnLbl'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('s${_scenario}_obj'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Steps
                        ...List.generate(steps.length, (i) {
                          bool isActive = i == _step;
                          bool isCompleted = i < _step;
                          bool isFuture = i > _step;

                          Color bg = isActive
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : (isCompleted
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : Colors.transparent);
                          Color border = isActive
                              ? const Color(0xFF6366F1).withOpacity(0.5)
                              : (isCompleted
                                    ? const Color(0xFF10B981).withOpacity(0.3)
                                    : Colors.white12);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isCompleted)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF10B981),
                                  )
                                else
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFF6366F1)
                                          : Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Opacity(
                                    opacity: isFuture ? 0.4 : 1.0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          "Action: ${steps[i]['task']}",
                                          style: TextStyle(
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isActive
                                                ? const Color(0xFF818CF8)
                                                : Colors.white,
                                          ),
                                        ),
                                        if (isCompleted) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "Result: ${steps[i]['outcome']}",
                                              style: const TextStyle(
                                                color: Color(0xFFA7F3D0),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFF0F172A),
                  alignment: Alignment.center,
                  child: const Text(
                    '© ZeroScienceLab - Fall in love with math and Science',
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      color: const Color(0xFF0F172A),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 100, color: Color(0xFF6366F1)),
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
              style: const TextStyle(fontSize: 20, color: Colors.white60),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                curtainScreen();
                setState(() => _showCurtain = false);
              },
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
              icon: const Icon(Icons.explore, size: 28),
              label: Text(
                t('enterLab'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getScenarioSteps(int id) {
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= 5; i++) {
      String task = t('s${id}_step${i}_task');
      if (task != 's${id}_step${i}_task') {
        steps.add({'task': task, 'outcome': t('s${id}_step${i}_out')});
      }
    }
    return steps;
  }
}

// --- Custom Painter for Math Canvas ---
class GeometryPainter extends CustomPainter {
  final double zoom, panX, panY;
  final List<SimPoint> points;
  final List<SimLine> lines;
  final List<SimArc> arcs;
  final SimTempLine? tempLine;
  final List<SimIntersection> intersections;
  final SimCompass compass;
  final SimRuler ruler;
  final GeomTool activeTool;
  final double time;

  GeometryPainter({
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.points,
    required this.lines,
    required this.arcs,
    required this.tempLine,
    required this.intersections,
    required this.compass,
    required this.ruler,
    required this.activeTool,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Draw Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double i = -2000; i <= 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    // Draw Arcs
    for (var a in arcs) {
      final rect = Rect.fromCircle(center: Offset(a.cx, a.cy), radius: a.r);
      final paint = Paint()
        ..color = a.color ?? const Color(0xFF60A5FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      double sweep = a.eAng - a.sAng;
      canvas.drawArc(rect, a.sAng, sweep, false, paint);
    }

    if (compass.currentArc != null) {
      var a = compass.currentArc!;
      final rect = Rect.fromCircle(center: Offset(a.cx, a.cy), radius: a.r);
      final paint = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      double sweep = a.eAng - a.sAng;
      canvas.drawArc(rect, a.sAng, sweep, false, paint);
    }

    // Draw Lines
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var l in lines) {
      canvas.drawLine(
        Offset(l.p1.x, l.p1.y),
        Offset(l.p2.x, l.p2.y),
        linePaint,
      );
      double cx = (l.p1.x + l.p2.x) / 2;
      double cy = (l.p1.y + l.p2.y) / 2;
      int len = (sqrt(pow(l.p2.x - l.p1.x, 2) + pow(l.p2.y - l.p1.y, 2)) / 40)
          .round();
      if (len > 0 && len < 20) {
        _drawText(canvas, "$len cm", cx, cy - 15, const Color(0xFF94A3B8));
      }
    }

    // Draw Temp Line
    if (tempLine != null) {
      final tLinePaint = Paint()
        ..color = const Color(0xFF6366F1)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      _drawDashedLine(
        canvas,
        Offset(tempLine!.startX, tempLine!.startY),
        Offset(tempLine!.endX, tempLine!.endY),
        tLinePaint,
      );
    }

    // Draw Intersections (Glowing)
    final glowPaint = Paint()
      ..color = const Color(0xFFFACC15).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..style = PaintingStyle.fill;
    for (var i in intersections) {
      if (i.matched) continue;
      double pulse = 8 + sin(time) * 4;
      canvas.drawCircle(Offset(i.x, i.y), pulse, glowPaint);
      canvas.drawCircle(Offset(i.x, i.y), 3, dotPaint);
    }

    // Draw Points
    for (var p in points) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        6,
        Paint()
          ..color = (p.id == compass.pinId
              ? const Color(0xFFEF4444)
              : Colors.white),
      );
      _drawText(
        canvas,
        p.label,
        p.x + 15,
        p.y + 15,
        Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    }

    // Draw Ruler
    if (ruler.active) {
      final rulerRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(ruler.x, ruler.y, ruler.width, 50),
        const Radius.circular(8),
      );
      canvas.drawRRect(rulerRect, Paint()..color = const Color(0xFFFEF08A));
      canvas.drawRRect(
        rulerRect,
        Paint()
          ..color = const Color(0xFF854D0E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final rMarkPaint = Paint()
        ..color = const Color(0xFF854D0E)
        ..strokeWidth = 2;
      for (int i = 0; i <= 15; i++) {
        double tx = ruler.x + 20 + i * 40;
        canvas.drawLine(
          Offset(tx, ruler.y),
          Offset(tx, ruler.y + 20),
          rMarkPaint,
        );
        _drawText(
          canvas,
          "$i",
          tx,
          ruler.y + 30,
          const Color(0xFF854D0E),
          fontSize: 12,
          outline: false,
        );
        if (i < 15) {
          for (int j = 1; j < 10; j++) {
            double tickH = j == 5 ? 12 : 8;
            canvas.drawLine(
              Offset(tx + j * 4, ruler.y),
              Offset(tx + j * 4, ruler.y + tickH),
              Paint()
                ..color = const Color(0xFF854D0E)
                ..strokeWidth = 1,
            );
          }
        }
      }
    }

    // Draw Compass
    double pencX = compass.x + compass.r * cos(compass.angle);
    double pencY = compass.y + compass.r * sin(compass.angle);
    double apexX = compass.x + (pencX - compass.x) / 2;
    double apexY = compass.y - 120;

    final compLegs = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(compass.x, compass.y),
      Offset(apexX, apexY),
      compLegs,
    ); // Pin leg
    canvas.drawLine(
      Offset(pencX, pencY),
      Offset(apexX, apexY),
      compLegs,
    ); // Pencil leg

    canvas.drawCircle(
      Offset(apexX, apexY),
      10,
      Paint()..color = const Color(0xFF334155),
    ); // Hinge

    // Pin End
    final pinPath = Path()
      ..moveTo(compass.x, compass.y)
      ..lineTo(compass.x - 4, compass.y - 20)
      ..lineTo(compass.x + 4, compass.y - 20)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFF94A3B8));

    // Pencil End
    final pencilPath = Path()
      ..moveTo(pencX, pencY)
      ..lineTo(pencX - 6, pencY - 20)
      ..lineTo(pencX + 6, pencY - 20)
      ..close();
    canvas.drawPath(pencilPath, Paint()..color = const Color(0xFFFBBF24));
    final tipPath = Path()
      ..moveTo(pencX, pencY)
      ..lineTo(pencX - 2, pencY - 6)
      ..lineTo(pencX + 2, pencY - 6)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = const Color(0xFF3F3F46));

    if (activeTool == GeomTool.compass) {
      canvas.drawCircle(
        Offset(apexX, apexY),
        20,
        Paint()..color = const Color(0xFF6366F1).withOpacity(0.2),
      ); // Move handle
      canvas.drawCircle(
        Offset(pencX, pencY),
        15,
        Paint()..color = const Color(0xFFEF4444).withOpacity(0.2),
      ); // Resize handle

      double handleAng = compass.angle + pi / 2;
      double hx = pencX + 30 * cos(handleAng);
      double hy = pencY + 30 * sin(handleAng);
      canvas.drawCircle(
        Offset(hx, hy),
        15,
        Paint()..color = const Color(0xFF22C55E).withOpacity(0.3),
      ); // Draw handle
      _drawText(
        canvas,
        '✎',
        hx,
        hy,
        const Color(0xFF166534),
        outline: false,
        fontSize: 18,
      );

      _drawText(
        canvas,
        "R = ${(compass.r / 40).round()} cm",
        apexX,
        apexY - 30,
        Colors.white,
        fontSize: 14,
      );
    }

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    bool outline = true,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    if (outline) {
      final outlineStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF0F172A),
      );
      final outlineSpan = TextSpan(text: text, style: outlineStyle);
      final outlinePainter = TextPainter(
        text: outlineSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      outlinePainter.layout();
      outlinePainter.paint(
        canvas,
        Offset(x - outlinePainter.width / 2, y - outlinePainter.height / 2),
      );
    }

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 6;
    const int dashSpace = 6;
    double distance = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;

    double start = 0;
    while (start < distance) {
      double end = start + dashWidth;
      if (end > distance) end = distance;
      canvas.drawLine(
        Offset(p1.dx + dx * start, p1.dy + dy * start),
        Offset(p1.dx + dx * end, p1.dy + dy * end),
        paint,
      );
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- Translations Map ---
const Map<String, Map<String, String>> _translations = {
  'en': {
    'shutterTitle':
        "The Compass Quest: Finding Equidistant Points to Build a Rhombus",
    'appTitle': "The Compass Quest",
    'appSubtitle': "Class 6 • GEOMETRIC CONSTRUCTIONS",
    'enterLab': "Enter Simulation",
    'selectScenario': "SELECT SCENARIO",
    'stepLabel': "STEP",
    'learnLbl': "Objective:",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You have successfully constructed complex shapes using a compass and equidistant points!",

    's1_title': "1. The Mountain Peak",
    's1_obj':
        "To find a point equidistant from two base points forming an equilateral triangle.",
    's1_step1_task':
        "DRAG the compass pencil to the ruler to SET its radius to 5 cm.",
    's1_step1_out': "Compass radius is set to 5 cm.",
    's1_step2_task': "SNAP compass pin to point B and DRAW an arc.",
    's1_step2_out': "An arc is drawn from point B.",
    's1_step3_task':
        "SNAP compass pin to point C and DRAW an intersecting arc.",
    's1_step3_out': "The intersection point glows.",
    's1_step4_task':
        "Select the Point Tool and CLICK the glowing intersection to place point A.",
    's1_step4_out': "Point A is placed perfectly equidistant from B and C.",
    's1_step5_task': "Select the Line Tool. CONNECT A to B, and A to C.",
    's1_step5_out':
        "An equilateral triangle is formed because all sides are 5 cm.",

    's2_title': "2. The Diamond Finder",
    's2_obj':
        "To find two points equidistant from the ends of a segment to construct a complete rhombus.",
    's2_step1_task':
        "SNAP the compass pin to A and pencil to B to set its radius to the length of AB.",
    's2_step1_out': "Compass set to length AB.",
    's2_step2_task': "DRAW a large arc from center A.",
    's2_step2_out': "Arc drawn from A.",
    's2_step3_task':
        "DRAW a large arc from center B crossing the first one twice.",
    's2_step3_out': "Two intersection points glow.",
    's2_step4_task':
        "Use the Point Tool to place points C and D at the intersections.",
    's2_step4_out': "Points C and D placed.",
    's2_step5_task': "Use the Line Tool to CONNECT A-D, D-B, B-C, and C-A.",
    's2_step5_out': "A perfect rhombus is constructed.",

    's3_title': "3. The Architect's Plan",
    's3_obj': "Construct a rhombus with a specific side length of 7 cm.",
    's3_step1_task':
        "Use the Line Tool from point P to DRAW a line exactly 7 cm long to create Q.",
    's3_step1_out': "Line segment PQ (7 cm) created.",
    's3_step2_task': "SET compass radius to 7 cm using the ruler.",
    's3_step2_out': "Compass set to 7 cm.",
    's3_step3_task':
        "DRAW arcs from P and Q to find intersection S. Place point S.",
    's3_step3_out': "Point S placed 7 cm from P and Q.",
    's3_step4_task':
        "DRAW arcs from S and P to find intersection R. Place point R.",
    's3_step4_out': "Point R placed 7 cm from S and P.",
    's3_step5_task': "CONNECT P-Q, Q-S, S-R, and R-P.",
    's3_step5_out': "Rhombus PQSR with 7 cm sides constructed.",

    's4_title': "4. The Kite Challenge",
    's4_obj':
        "Construct a kite by using two different radii to find the equidistant points.",
    's4_step1_task': "SET compass to 4 cm using the ruler.",
    's4_step1_out': "Compass set to 4 cm.",
    's4_step2_task':
        "DRAW arcs from A and C. Place point B on the right side intersection.",
    's4_step2_out': "Point B placed 4 cm from A and C.",
    's4_step3_task': "SET compass to 7 cm using the ruler.",
    's4_step3_out': "Compass set to 7 cm.",
    's4_step4_task':
        "DRAW arcs from A and C. Place point D on the left side intersection.",
    's4_step4_out': "Point D placed 7 cm from A and C.",
    's4_step5_task': "CONNECT A-B, B-C, C-D, and D-A.",
    's4_step5_out':
        "A kite is formed because adjacent sides are equal, but not all sides are equal.",

    's5_title': "5. The Tiling Pattern",
    's5_obj': "Construct an identical, adjacent rhombus that shares a side.",
    's5_step1_task': "MEASURE the length of side CD with the compass.",
    's5_step1_out': "Compass set to the side length.",
    's5_step2_task': "DRAW arcs from C and A to find a point.",
    's5_step2_out': "This point would overlap the current rhombus. Try again.",
    's5_step3_task': "DRAW arcs from C and D to find the correct new vertex E.",
    's5_step3_out': "Correct intersection found.",
    's5_step4_task': "Place point E and CONNECT to form the new rhombus.",
    's5_step4_out': "A beautiful tiling pattern begins.",
  },
  'hi': {
    'shutterTitle': "कम्पास खोज: समचतुर्भुज बनाने के लिए समदूरस्थ बिंदु खोजना",
    'appTitle': "कम्पास खोज",
    'appSubtitle': "कक्षा 6 • ज्यामितीय रचनाएँ",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "उद्देश्य:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc':
        "आपने सफलतापूर्वक कम्पास का उपयोग करके जटिल आकृतियाँ बनाई हैं!",

    's1_title': "1. पर्वत शिखर",
    's1_obj':
        "समबाहु त्रिभुज बनाने के लिए दो आधार बिंदुओं से समदूरस्थ एक बिंदु खोजना।",
    's1_step1_task':
        "त्रिज्या को 5 सेमी पर सेट करने के लिए कम्पास पेंसिल को रूलर पर खींचें।",
    's1_step1_out': "कम्पास 5 सेमी पर सेट है।",
    's1_step2_task': "कम्पास पिन को B पर स्नैप करें और एक चाप (arc) खींचें।",
    's1_step2_out': "बिंदु B से एक चाप खींचा गया है।",
    's1_step3_task': "कम्पास पिन को C पर स्नैप करें और काटता हुआ चाप खींचें।",
    's1_step3_out': "प्रतिच्छेदन (intersection) बिंदु चमकता है।",
    's1_step4_task': "बिंदु टूल चुनें और चमकते बिंदु A को रखें।",
    's1_step4_out': "बिंदु A रखा गया।",
    's1_step5_task': "लाइन टूल चुनें। A को B से, और A को C से जोड़ें।",
    's1_step5_out': "समबाहु त्रिभुज बन गया।",

    's2_title': "2. डायमंड फाइंडर",
    's2_obj': "एक समचतुर्भुज (rhombus) बनाने के लिए समदूरस्थ दो बिंदु खोजना।",
    's2_step1_task': "कम्पास की त्रिज्या को AB की लंबाई के बराबर सेट करें।",
    's2_step1_out': "कम्पास AB लंबाई पर सेट है।",
    's2_step2_task': "A से एक बड़ा चाप खींचें।",
    's2_step2_out': "A से चाप खींचा गया।",
    's2_step3_task': "B से एक बड़ा चाप खींचें जो पहले वाले को काटे।",
    's2_step3_out': "दो प्रतिच्छेदन बिंदु चमकते हैं।",
    's2_step4_task': "प्रतिच्छेदनों पर बिंदु C और D रखें।",
    's2_step4_out': "बिंदु C और D रखे गए।",
    's2_step5_task': "लाइन टूल से सभी को जोड़ें।",
    's2_step5_out': "एक उत्तम समचतुर्भुज बन गया।",

    's3_title': "3. वास्तुकार की योजना",
    's3_obj': "7 सेमी भुजा वाला एक समचतुर्भुज बनाएँ।",
    's3_step1_task': "P से ठीक 7 सेमी लंबी रेखा PQ खींचें।",
    's3_step1_out': "रेखा PQ (7 सेमी) बन गई।",
    's3_step2_task': "कम्पास त्रिज्या को 7 सेमी पर सेट करें।",
    's3_step2_out': "कम्पास 7 सेमी पर सेट है।",
    's3_step3_task': "P और Q से चाप खींचकर S खोजें और रखें।",
    's3_step3_out': "बिंदु S रखा गया।",
    's3_step4_task': "S और P से चाप खींचकर R खोजें और रखें।",
    's3_step4_out': "बिंदु R रखा गया।",
    's3_step5_task': "सभी को जोड़ें।",
    's3_step5_out': "7 सेमी भुजाओं वाला समचतुर्भुज तैयार है।",

    's4_title': "4. पतंग चुनौती",
    's4_obj': "अलग-अलग त्रिज्याओं का उपयोग करके पतंग बनाएँ।",
    's4_step1_task': "कम्पास को 4 सेमी पर सेट करें।",
    's4_step1_out': "कम्पास 4 सेमी पर सेट।",
    's4_step2_task': "A और C से चाप खींचें। दाईं ओर बिंदु B रखें।",
    's4_step2_out': "बिंदु B रखा गया।",
    's4_step3_task': "कम्पास को 7 सेमी पर सेट करें।",
    's4_step3_out': "कम्पास 7 सेमी पर सेट।",
    's4_step4_task': "A और C से चाप खींचें। बाईं ओर बिंदु D रखें।",
    's4_step4_out': "बिंदु D रखा गया।",
    's4_step5_task': "आकृतियों को जोड़ें।",
    's4_step5_out': "एक पतंग बन गई है क्योंकि सभी भुजाएं समान नहीं हैं।",

    's5_title': "5. टाइलिंग पैटर्न",
    's5_obj': "एक समान, आसन्न समचतुर्भुज बनाएँ।",
    's5_step1_task': "कम्पास से भुजा CD को मापें।",
    's5_step1_out': "कम्पास भुजा की लंबाई पर सेट।",
    's5_step2_task': "C और A से चाप खींचें।",
    's5_step2_out': "यह गलत बिंदु है। फिर से प्रयास करें।",
    's5_step3_task': "सही नया शीर्ष E खोजने के लिए C और D से चाप खींचें।",
    's5_step3_out': "सही प्रतिच्छेदन मिला।",
    's5_step4_task': "बिंदु E रखें और नया समचतुर्भुज बनाने के लिए जोड़ें।",
    's5_step4_out': "एक सुंदर पैटर्न शुरू होता है।",
  },
};
