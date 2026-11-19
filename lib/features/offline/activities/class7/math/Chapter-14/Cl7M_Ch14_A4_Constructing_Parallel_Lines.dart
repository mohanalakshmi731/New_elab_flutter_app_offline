// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ConstructingParallelLines(),
  ));
}

class ConstructingParallelLines extends StatefulWidget {
  const ConstructingParallelLines({Key? key}) : super(key: key);

  @override
  State<ConstructingParallelLines> createState() => _ConstructingParallelLinesState();
}

class _ConstructingParallelLinesState extends State<ConstructingParallelLines> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showShutter = true;
  String _currentLang = 'en';
  int _currentScenario = 0;
  
  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3'; 
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  // Canvas State
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;
  
  // Tools & Entities
  String? _activeTool;
  List<GeoPoint> _points = [];
  List<GeoLine> _lines = [];
  List<GeoArc> _arcs = [];
  CompassTool? _compass;
  RulerTool? _ruler;
  GeoArc? _tempArc;
  
  // Dragging State
  dynamic _draggedEntity;
  String _dragPart = '';
  Offset? _dragStartPos;
  double _prevAngle = 0.0;

  // Logic State Variables
  int _currentStep = 0;
  bool _scenarioCompleted = false;
  double _savedRadius1 = 0;
  double _savedRadius2 = 0;
  String _s3FirstArc = '';

  String _hudMessage = '';
  Color _hudColor = Colors.white; 
  Timer? _hintTimer;

  String _toastMessage = '';
  double _toastOpacity = 0.0;
  Timer? _toastTimer;

  late AnimationController _pulseController;
  Offset _floatingStepPos = const Offset(20, 80);

  @override
  void initState() {
    super.initState();
    // Enforce Landscape Orientation and Immersive Mode per user request
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScenario(_currentScenario);
    });
  }

  @override
  void dispose() {
    // Revert Orientation and System UI per user request
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _fitToScreen() {
    if (!mounted) return;
    double minX = -400, maxX = 400, minY = -300, maxY = 300;

    double paddingX = 120;
    double paddingY = 120;
    double contentW = math.max(maxX - minX, 100);
    double contentH = math.max(maxY - minY, 100);
    
    final size = MediaQuery.sizeOf(context);
    // 30% left sidebar width
    double sidebarW = _isSidebarOpen ? size.width * 0.3 : 0;
    
    double canvasW = size.width - sidebarW;
    double canvasH = size.height;

    double usableW = math.max(canvasW - paddingX, 100);
    double usableH = math.max(canvasH - paddingY, 100);
    
    double targetScale = math.min(usableW / contentW, usableH / contentH).clamp(0.1, 1.5);
    double centerX = (minX + maxX) / 2;
    double centerY = (minY + maxY) / 2;
    
    setState(() {
      _scale = targetScale;
      _panOffset = Offset(-centerX * targetScale, -centerY * targetScale);
    });
  }

  void _playSound(String type) {
    try {
      switch (type) {
        case 'click':
        case 'draw':
        case 'snap':
          _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'pop':
          _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'shutter':
          _shutterPlayer.play(AssetSource(_shutterUrl));
          break;
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  void _showHint(String msg) {
    _hintTimer?.cancel();
    setState(() {
      _hudMessage = msg;
      _hudColor = Colors.redAccent;
    });
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hudColor = Colors.white;
          _updateHUD(); 
        });
      }
    });
  }

  void _showToast(String msg) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = msg;
      _toastOpacity = 1.0;
    });
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toastOpacity = 0.0);
    });
  }

  void _cycleLanguage() {
    _playSound('click');
    setState(() {
      if (_currentLang == 'en') _currentLang = 'hi';
      else _currentLang = 'en';
      _updateHUD();
    });
  }

  void _resetLab() {
    _playSound('pop');
    setState(() {
      _currentLang = 'en';
      _showShutter = true;
      _loadScenario(0);
    });
  }

  void _loadScenario(int index) {
    _currentScenario = index;
    _currentStep = 0;
    
    _scenarioCompleted = false;
    _activeTool = null;
    _compass = null;
    _ruler = null;
    _points.clear();
    _lines.clear();
    _arcs.clear();
    _hudColor = Colors.white;
    _savedRadius1 = 0;
    _savedRadius2 = 0;
    _s3FirstArc = '';

    if (index == 0 || index == 1) {
      // 0: Corresponding Angle, 1: Alternate Angle
      _points.add(GeoPoint(id: 'P', x: 0, y: -100, label: 'P', color: Colors.amber, glow: true));
      _points.add(GeoPoint(id: 'A', x: -150, y: 100, label: 'A', color: Colors.amber, glow: true));
      _lines.add(GeoLine(id: 'm', p1: const Offset(-400, 100), p2: const Offset(400, 100), width: 4));
    } else if (index == 2) {
      // 2: Ladder Rung (Perpendicular Method)
      _points.add(GeoPoint(id: 'P', x: 0, y: -100, label: 'P', color: Colors.amber, glow: true));
      _lines.add(GeoLine(id: 'm', p1: const Offset(-400, 100), p2: const Offset(400, 100), width: 4));
    }
    
    _fitToScreen();
    _updateHUD();
  }

  void _updateHUD() {
    if (_scenarioCompleted) {
      _hudMessage = _currentLang == 'hi' 
        ? "सफलता! समानांतर रेखाएं बनाई गईं।" 
        : "Success! Parallel Lines Created.";
      return;
    }
    
    final stepsList = _i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List;
    if (_currentStep >= stepsList.length) return;
    _hudMessage = stepsList[_currentStep]['hud'];
  }

  void _selectTool(String tool) {
    _playSound('click');
    setState(() {
      _activeTool = tool;
      if (tool == 'compass') {
        double initR = (_currentScenario == 2 && _currentStep == 0) ? 220 : 80;
        _compass ??= CompassTool(x: 0, y: -200, radius: initR, angle: math.pi / 4, isLocked: false);
        _ruler = null;
      } else if (tool == 'ruler') {
        _ruler ??= RulerTool(x1: -50, y1: -200, x2: 50, y2: -200);
        _compass = null;
      }
    });
  }

  void _toggleCompassLock() {
    if (_compass != null) {
      _playSound('click');
      setState(() {
        _compass!.isLocked = !_compass!.isLocked;
        if (_compass!.isLocked) {
           _showToast("Radius Locked at ${_compass!.radius.toStringAsFixed(1)}");
           _evaluateScenarioState(); 
        } else {
           _showToast("Compass Unlocked. Drag pencil to measure.");
        }
      });
    }
  }

  // Identifies when measuring mode is active
  bool _isMeasureStep() {
    if (_currentScenario == 0 && _currentStep == 3) return true;
    if (_currentScenario == 1 && _currentStep == 3) return true;
    return false;
  }

  // Mathematical Intersections
  List<Offset> _intersectLineSegmentCircle(Offset p1, Offset p2, Offset cpt, double r) {
    double dx = p2.dx - p1.dx; double dy = p2.dy - p1.dy;
    double a = dx * dx + dy * dy;
    if (a <= 0.000001) return [];
    double b = 2 * (dx * (p1.dx - cpt.dx) + dy * (p1.dy - cpt.dy));
    double c = math.pow(p1.dx - cpt.dx, 2).toDouble() + math.pow(p1.dy - cpt.dy, 2).toDouble() - r * r;
    double det = b * b - 4 * a * c;
    if (det < 0) return [];
    
    double t1 = (-b + math.sqrt(det)) / (2 * a);
    double t2 = (-b - math.sqrt(det)) / (2 * a);
    List<Offset> pts = [];
    if (t1 >= -10 && t1 <= 10) pts.add(Offset(p1.dx + t1 * dx, p1.dy + t1 * dy)); // Extended bounds
    if (t2 >= -10 && t2 <= 10 && t2 != t1) pts.add(Offset(p1.dx + t2 * dx, p1.dy + t2 * dy));
    return pts;
  }

  List<Offset> _intersectCircleCircle(Offset c1, double r1, Offset c2, double r2) {
    double dx = c2.dx - c1.dx; double dy = c2.dy - c1.dy;
    double d = math.sqrt(dx * dx + dy * dy);
    if (d > r1 + r2 || d < (r1 - r2).abs() || d == 0) return [];
    double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    double h = math.sqrt(math.max(0, r1 * r1 - a * a));
    double px = c1.dx + a * (dx / d); double py = c1.dy + a * (dy / d);
    return [
      Offset(px + h * (dy / d), py - h * (dx / d)),
      Offset(px - h * (dy / d), py + h * (dx / d))
    ];
  }

  // Interaction Handlers
  void _onScaleStart(ScaleStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);
    final Offset worldPos = _screenToWorld(localPos);

    _draggedEntity = null;
    _dragPart = '';

    if (_compass != null) {
      if ((worldPos - Offset(_compass!.x, _compass!.y)).distance < 40) {
        _draggedEntity = _compass; _dragPart = 'pivot'; _dragStartPos = worldPos; return;
      }
      
      Offset pencilPos = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
      if ((worldPos - pencilPos).distance < 40) {
        _draggedEntity = _compass; 
        _dragPart = 'pencil'; 
        _prevAngle = _compass!.angle;
        
        if (_compass!.isLocked && !_isMeasureStep()) {
           _tempArc = GeoArc(x: _compass!.x, y: _compass!.y, radius: _compass!.radius, startAngle: _compass!.angle, sweepAngle: 0);
        } else {
           _tempArc = null; 
        }
        return;
      }
      
      if (!_compass!.isLocked) {
         Offset resizeHandle = Offset(_compass!.x + (_compass!.radius/2) * math.cos(_compass!.angle), _compass!.y + (_compass!.radius/2) * math.sin(_compass!.angle));
         if ((worldPos - resizeHandle).distance < 40) {
            _draggedEntity = _compass; _dragPart = 'resize'; _dragStartPos = worldPos; return;
         }
      }
    }

    if (_ruler != null) {
      if ((worldPos - Offset(_ruler!.x1, _ruler!.y1)).distance < 40) { _draggedEntity = _ruler; _dragPart = 'p1'; return; }
      if ((worldPos - Offset(_ruler!.x2, _ruler!.y2)).distance < 40) { _draggedEntity = _ruler; _dragPart = 'p2'; return; }
      Offset mid = Offset((_ruler!.x1 + _ruler!.x2) / 2, (_ruler!.y1 + _ruler!.y2) / 2);
      if ((worldPos - mid).distance < 40) { _draggedEntity = _ruler; _dragPart = 'body'; _dragStartPos = worldPos; return; }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      setState(() { _scale = (_scale * details.scale).clamp(0.5, 3.0); _panOffset += details.focalPointDelta; });
      return;
    }
    if (_draggedEntity == null) {
      setState(() => _panOffset += details.focalPointDelta);
      return;
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.focalPoint);
    final Offset worldPos = _screenToWorld(localPos);

    setState(() {
      if (_draggedEntity is CompassTool) {
        if (_dragPart == 'pivot') {
          _compass!.x = worldPos.dx; _compass!.y = worldPos.dy;
          if (_tempArc != null) { _tempArc!.x = worldPos.dx; _tempArc!.y = worldPos.dy; }
        } else if (_dragPart == 'resize') {
          double dist = (worldPos - Offset(_compass!.x, _compass!.y)).distance;
          _compass!.radius = math.max(20.0, dist * 2);
        } else if (_dragPart == 'pencil') {
          if (_compass!.isLocked && !_isMeasureStep()) {
             double newAngle = math.atan2(worldPos.dy - _compass!.y, worldPos.dx - _compass!.x);
             _compass!.angle = newAngle;
             if (_tempArc != null) {
                double delta = newAngle - _prevAngle;
                while (delta > math.pi) delta -= 2 * math.pi;
                while (delta < -math.pi) delta += 2 * math.pi;
                if (_tempArc!.sweepAngle.abs() + delta.abs() < math.pi * 2.5) _tempArc!.sweepAngle += delta;
             }
             _prevAngle = newAngle;
          } else {
             _compass!.radius = math.max(10.0, (worldPos - Offset(_compass!.x, _compass!.y)).distance);
             _compass!.angle = math.atan2(worldPos.dy - _compass!.y, worldPos.dx - _compass!.x);
          }
        }
      } else if (_draggedEntity is RulerTool) {
        if (_dragPart == 'p1') { _ruler!.x1 = worldPos.dx; _ruler!.y1 = worldPos.dy; } 
        else if (_dragPart == 'p2') { _ruler!.x2 = worldPos.dx; _ruler!.y2 = worldPos.dy; } 
        else if (_dragPart == 'body') {
          Offset delta = worldPos - _dragStartPos!;
          _ruler!.x1 += delta.dx; _ruler!.y1 += delta.dy; _ruler!.x2 += delta.dx; _ruler!.y2 += delta.dy;
          _dragStartPos = worldPos;
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggedEntity == null) return;
    bool snapped = false;

    setState(() {
      if (_draggedEntity is CompassTool) {
        if (_dragPart == 'pivot') {
          for (var p in _points) {
            if ((Offset(_compass!.x, _compass!.y) - Offset(p.x, p.y)).distance < 30) {
              _compass!.x = p.x; _compass!.y = p.y; snapped = true; break;
            }
          }
          if (snapped) _playSound('snap'); else _playSound('error');
          _evaluateScenarioState();
        } else if (_dragPart == 'resize') {
          _playSound('pop');
        } else if (_dragPart == 'pencil') {
          if (_compass!.isLocked && _tempArc != null) {
            if (_tempArc!.sweepAngle.abs() > 0.2) { 
              _arcs.add(_tempArc!);
              _playSound('draw');
              _validateArcDrawing(); 
            } else {
              _playSound('error');
              _showHint("Sweep a larger arc.");
            }
            _tempArc = null;
          } else if (!_compass!.isLocked) {
            Offset pencilPos = Offset(_compass!.x + _compass!.radius * math.cos(_compass!.angle), _compass!.y + _compass!.radius * math.sin(_compass!.angle));
            for (var p in _points) {
               if ((pencilPos - p.toOffset()).distance < 30 && (p.x - _compass!.x).abs() > 2) {
                  _compass!.radius = (p.toOffset() - Offset(_compass!.x, _compass!.y)).distance;
                  _compass!.angle = math.atan2(p.y - _compass!.y, p.x - _compass!.x);
                  if (_isMeasureStep()) _compass!.isLocked = true;
                  snapped = true; break;
               }
            }
            if (snapped) _playSound('snap');
            _evaluateScenarioState();
          }
        }
      } else if (_draggedEntity is RulerTool) {
        for (var p in _points) {
          if (_dragPart == 'p1' || _dragPart == 'body') {
            if ((Offset(_ruler!.x1, _ruler!.y1) - Offset(p.x, p.y)).distance < 40) { _ruler!.x1 = p.x; _ruler!.y1 = p.y; snapped = true; }
          }
          if (_dragPart == 'p2' || _dragPart == 'body') {
            if ((Offset(_ruler!.x2, _ruler!.y2) - Offset(p.x, p.y)).distance < 40) { _ruler!.x2 = p.x; _ruler!.y2 = p.y; snapped = true; }
          }
        }
        if (snapped) { _playSound('snap'); _evaluateScenarioState(); }
      }
      _draggedEntity = null;
    });
  }

  void _addPointIfNew(String id, Offset pt, Color c, [double ox=0, double oy=-20]) {
    if (!_points.any((p) => p.id == id)) {
       _points.add(GeoPoint(id: id, x: pt.dx, y: pt.dy, label: id, color: c, offsetX: ox, offsetY: oy));
       _playSound('success');
    }
  }

  void _validateArcDrawing() {
    if (_compass == null || _scenarioCompleted) return;
    Offset cPt = Offset(_compass!.x, _compass!.y);
    double r = _compass!.radius;
    bool foundSomething = false;

    if (_currentScenario == 0 || _currentScenario == 1) {
      if (_currentStep == 1 && _points.any((p)=>p.id=='A') && (cPt - _points.firstWhere((p)=>p.id=='A').toOffset()).distance < 10) {
        var l = _lines.firstWhere((line)=>line.id=='l');
        var m = _lines.firstWhere((line)=>line.id=='m');
        var intsL = _intersectLineSegmentCircle(l.p1, l.p2, cPt, r);
        var intsM = _intersectLineSegmentCircle(m.p1, m.p2, cPt, r);
        
        Offset? cOpt, dOpt;
        if (_currentScenario == 0) {
           cOpt = intsL.where((pt) => pt.dy < cPt.dy).firstOrNull;
           dOpt = intsM.where((pt) => pt.dx > cPt.dx).firstOrNull;
        } else {
           cOpt = intsL.where((pt) => pt.dy < cPt.dy).firstOrNull;
           dOpt = intsM.where((pt) => pt.dx < cPt.dx).firstOrNull; // Left side for alternate
        }
        
        if (cOpt != null && dOpt != null) {
          _addPointIfNew('C', cOpt, Colors.indigoAccent, -20, 0);
          _addPointIfNew('D', dOpt, Colors.indigoAccent, 20, 20);
          _savedRadius1 = r; _compass!.isLocked = true; foundSomething = true;
          _advanceStep();
        } else { _showHint("Ensure your arc crosses BOTH lines."); }
      }
      else if (_currentStep == 2 && _points.any((p)=>p.id=='P') && (cPt - _points.firstWhere((p)=>p.id=='P').toOffset()).distance < 10) {
        var l = _lines.firstWhere((line)=>line.id=='l');
        var intsL = _intersectLineSegmentCircle(l.p1, l.p2, cPt, r);
        Offset? eOpt;
        if (_currentScenario == 0) eOpt = intsL.where((pt) => pt.dy < cPt.dy).firstOrNull;
        else eOpt = intsL.where((pt) => pt.dy > cPt.dy).firstOrNull; // Opposite side for alternate
        
        if (eOpt != null) {
          _addPointIfNew('E', eOpt, Colors.indigoAccent, -20, -10);
          _compass!.isLocked = false; foundSomething = true;
          _advanceStep();
        } else { _showHint("Draw arc crossing the transversal line."); }
      }
      else if (_currentStep == 4 && _points.any((p)=>p.id=='E') && (cPt - _points.firstWhere((p)=>p.id=='E').toOffset()).distance < 10) {
        GeoPoint pNode = _points.firstWhere((p)=>p.id=='P');
        var ints = _intersectCircleCircle(pNode.toOffset(), _savedRadius1, cPt, _savedRadius2);
        Offset? fOpt = ints.where((pt) => pt.dx > pNode.x).firstOrNull;
        
        if (fOpt != null) {
          fOpt = Offset(fOpt.dx, pNode.y); // Force parallel visual
          _addPointIfNew('F', fOpt, Colors.green, 20, 20);
          _compass = null; _selectTool('ruler'); foundSomething = true;
          _advanceStep();
        } else { _showHint("Arc missed the intersection area."); }
      }
    } 
    else if (_currentScenario == 2) {
      GeoPoint pNode = _points.firstWhere((p)=>p.id=='P');
      if (_currentStep == 0 && (cPt - pNode.toOffset()).distance < 10) {
        if (r > 200) {
          var m = _lines.firstWhere((line)=>line.id=='m');
          var ints = _intersectLineSegmentCircle(m.p1, m.p2, cPt, r);
          if (ints.length == 2) {
            _addPointIfNew('A', ints[0], Colors.lightBlue, -15, 20);
            _addPointIfNew('B', ints[1], Colors.lightBlue, 15, 20);
            foundSomething = true; _advanceStep();
          } else { _showHint("Make sure arc crosses line m twice."); }
        } else { _showHint("Radius too small. Use handle to stretch past line m."); }
      }
      else if (_currentStep == 1) {
        bool drawnA = _points.any((p)=>p.id=='A') && (cPt - _points.firstWhere((p)=>p.id=='A').toOffset()).distance < 10;
        bool drawnB = _points.any((p)=>p.id=='B') && (cPt - _points.firstWhere((p)=>p.id=='B').toOffset()).distance < 10;
        if (drawnA || drawnB) {
          GeoPoint aNode = _points.firstWhere((p)=>p.id=='A'); GeoPoint bNode = _points.firstWhere((p)=>p.id=='B');
          if (r > (aNode.toOffset() - bNode.toOffset()).distance / 2 + 20) {
             _savedRadius1 = r; _compass!.isLocked = true; _s3FirstArc = drawnA ? 'A' : 'B';
             foundSomething = true; _advanceStep();
          } else { _showHint("Radius must be MORE than half of AB. Stretch it out!"); }
        } else { _showHint("Start by snapping compass to A or B."); }
      }
      else if (_currentStep == 2) {
        bool drawnA = _points.any((p)=>p.id=='A') && (cPt - _points.firstWhere((p)=>p.id=='A').toOffset()).distance < 10;
        bool drawnB = _points.any((p)=>p.id=='B') && (cPt - _points.firstWhere((p)=>p.id=='B').toOffset()).distance < 10;
        if ((_s3FirstArc == 'A' && drawnB) || (_s3FirstArc == 'B' && drawnA)) {
          if ((r - _savedRadius1).abs() < 15) {
             GeoPoint aNode = _points.firstWhere((p)=>p.id=='A'); GeoPoint bNode = _points.firstWhere((p)=>p.id=='B');
             var ints = _intersectCircleCircle(aNode.toOffset(), r, bNode.toOffset(), r);
             Offset? qOpt = ints.where((pt) => pt.dy > 100).firstOrNull; // Below m
             if (qOpt != null) {
               _addPointIfNew('Q', qOpt, Colors.lightBlue, 0, 20);
               _compass = null; _selectTool('ruler'); foundSomething = true; 
               _s3FirstArc = '';
               _advanceStep();
             } else { 
               _showHint("Arcs didn't intersect. Try again with wider radius.");
               _arcs.removeLast(); // removes first arc of this phase
               _compass!.isLocked = false; 
               _s3FirstArc = '';
               setState(() => _currentStep--);
               _updateHUD();
             }
          } else { _showHint("Must use the exact SAME radius as previous step."); }
        } else { _showHint("Draw second arc from the opposite point."); }
      }
      else if (_currentStep == 4 && (cPt - pNode.toOffset()).distance < 10) {
        var t = _lines.firstWhere((line)=>line.id=='t');
        var ints = _intersectLineSegmentCircle(t.p1, t.p2, cPt, r);
        if (ints.length >= 2) { // Changed to >= 2 to safely accommodate extended lines
          _addPointIfNew('C', ints[0], Colors.orange, -20, 0);
          _addPointIfNew('D', ints[1], Colors.orange, -20, 0);
          foundSomething = true; _advanceStep();
        } else { _showHint("Arc must cross vertical line t twice."); }
      }
      else if (_currentStep == 5) {
        bool drawnC = _points.any((p)=>p.id=='C') && (cPt - _points.firstWhere((p)=>p.id=='C').toOffset()).distance < 10;
        bool drawnD = _points.any((p)=>p.id=='D') && (cPt - _points.firstWhere((p)=>p.id=='D').toOffset()).distance < 10;
        if (drawnC || drawnD) {
          GeoPoint cNode = _points.firstWhere((p)=>p.id=='C'); GeoPoint dNode = _points.firstWhere((p)=>p.id=='D');
          if (_s3FirstArc == '') { // re-used variable for 2nd part
             if (r > (cNode.toOffset() - dNode.toOffset()).distance / 2 + 20) {
                _savedRadius2 = r; _compass!.isLocked = true; _s3FirstArc = drawnC ? 'C' : 'D';
                foundSomething = true; _playSound('success');
             } else { _showHint("Radius must be MORE than half of CD. Stretch it wider!"); }
          } else {
             if ((_s3FirstArc == 'C' && drawnD) || (_s3FirstArc == 'D' && drawnC)) {
                if ((r - _savedRadius2).abs() < 15) {
                   var ints = _intersectCircleCircle(cNode.toOffset(), r, dNode.toOffset(), r);
                   Offset? rOpt = ints.where((pt) => pt.dx > pNode.x + 10 || pt.dx < pNode.x - 10).firstOrNull;
                   if (rOpt != null) {
                     _addPointIfNew('R', rOpt, Colors.green, 20, -20);
                     _compass = null; _selectTool('ruler'); foundSomething = true; 
                     _s3FirstArc = '';
                     _advanceStep();
                   } else {
                     _showHint("Arcs didn't intersect. Try again with a wider radius.");
                     _arcs.removeLast(); // Removes first arc of this phase
                     _compass!.isLocked = false;
                     _s3FirstArc = '';
                   }
                } else { _showHint("Must use the exact SAME radius as previous arc."); }
             } else { _showHint("Draw second arc from the opposite point."); }
          }
        } else { _showHint("Snap compass to C or D and draw an arc."); }
      }
    }

    if (!foundSomething) {
       _arcs.removeLast(); _playSound('error'); 
    }
  }

  void _evaluateScenarioState() {
    if (_scenarioCompleted || _compass == null && _ruler == null) return;

    if ((_currentScenario == 0 || _currentScenario == 1) && _currentStep == 3) {
      if (_compass!.isLocked && _points.any((p)=>p.id=='C') && _points.any((p)=>p.id=='D')) {
         GeoPoint cNode = _points.firstWhere((p)=>p.id=='C'); GeoPoint dNode = _points.firstWhere((p)=>p.id=='D');
         double dist = (cNode.toOffset() - dNode.toOffset()).distance;
         if ((_compass!.radius - dist).abs() < 15 && ((_compass!.x - cNode.x).abs() < 20 || (_compass!.x - dNode.x).abs() < 20)) {
            _savedRadius2 = _compass!.radius; _advanceStep();
         }
      }
    }
  }

  void _advanceStep() {
    final stepsList = _i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List;
    if (_currentStep < stepsList.length - 1) {
      _playSound('success');
      setState(() {
        _currentStep++;
        _updateHUD();
      });
    } else {
      _playSound('success');
      setState(() => _updateHUD());
    }
  }

  void _drawAction(String actionType) {
    if (_ruler == null) return;
    bool success = false;
    Offset? target1, target2;
    String newLineId = '';
    Color lineColor = Colors.green;
    
    GeoPoint? pNode = _points.where((p) => p.id == 'P').firstOrNull;
    
    if (actionType == 'transversal') {
      GeoPoint? aNode = _points.where((p) => p.id == 'A').firstOrNull;
      if (pNode != null && aNode != null) { target1 = pNode.toOffset(); target2 = aNode.toOffset(); newLineId = 'l'; lineColor = Colors.lightBlue; }
    } else if (actionType == 'line') {
      if (_currentScenario == 0 || _currentScenario == 1) {
        GeoPoint? fNode = _points.where((p) => p.id == 'F').firstOrNull;
        if (pNode != null && fNode != null) { target1 = pNode.toOffset(); target2 = fNode.toOffset(); newLineId = 'n'; }
      } else if (_currentScenario == 2) {
        if (_currentStep == 3) {
          GeoPoint? qNode = _points.where((p) => p.id == 'Q').firstOrNull;
          if (pNode != null && qNode != null) { target1 = pNode.toOffset(); target2 = qNode.toOffset(); newLineId = 't'; lineColor = Colors.lightBlue; }
        } else if (_currentStep == 6) {
          GeoPoint? rNode = _points.where((p) => p.id == 'R').firstOrNull;
          if (pNode != null && rNode != null) { target1 = pNode.toOffset(); target2 = rNode.toOffset(); newLineId = 'n'; }
        }
      }
    }

    if (target1 != null && target2 != null) {
      success = ((_ruler!.x1 - target1.dx).abs() < 40 && (_ruler!.x2 - target2.dx).abs() < 40) ||
                ((_ruler!.x2 - target1.dx).abs() < 40 && (_ruler!.x1 - target2.dx).abs() < 40);
      
      if (!success) { _playSound('error'); _showHint("Align the ruler correctly with the glowing points!"); return; }
    }

    _playSound('draw');
    setState(() {
      double dx = _ruler!.x2 - _ruler!.x1; double dy = _ruler!.y2 - _ruler!.y1;
      double len = math.sqrt(dx*dx + dy*dy);
      if (len > 0) { dx /= len; dy /= len; }
      
      _lines.add(GeoLine(id: newLineId, p1: Offset(target1!.dx - dx*1000, target1.dy - dy*1000), p2: Offset(target1.dx + dx*1000, target1.dy + dy*1000), color: lineColor, width: 4));
      _ruler = null;
      
      if (actionType == 'line' && (_currentScenario < 2 || _currentStep == 6)) {
        _scenarioCompleted = true; _playSound('success'); _updateHUD();
      } else {
        _advanceStep(); _selectTool('compass');
      }
    });
  }

  Offset _screenToWorld(Offset screenPos) {
    final Size size = MediaQuery.of(context).size;
    final double sidebarW = _isSidebarOpen ? size.width * 0.3 : 0;
    final double canvasWidth = size.width - sidebarW;
    
    double cx = screenPos.dx - sidebarW - canvasWidth / 2 - _panOffset.dx;
    double cy = screenPos.dy - size.height / 2 - _panOffset.dy;
    return Offset(cx / _scale, cy / _scale);
  }

  List<TextSpan> _parseBoldText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    for (var match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: const TextStyle(fontWeight: FontWeight.normal)));
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) spans.add(TextSpan(text: text.substring(lastMatchEnd), style: const TextStyle(fontWeight: FontWeight.normal)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // 30% left sidebar width per user request
    double sidebarWidth = screenWidth * 0.3;

    // Check action buttons conditions
    bool showTransversalBtn = ((_currentScenario == 0 || _currentScenario == 1) && _currentStep == 0 && _ruler != null);
    bool showLineBtn = false;
    if (_ruler != null && !_scenarioCompleted) {
      if ((_currentScenario == 0 || _currentScenario == 1) && _currentStep == 5) showLineBtn = true;
      if (_currentScenario == 2 && (_currentStep == 3 || _currentStep == 6)) showLineBtn = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Center Responsive Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)])
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: ClipRect(
                        child: CustomPaint(
                          painter: CanvasPainter(
                            currentScenario: _currentScenario,
                            currentStep: _currentStep,
                            scale: _scale,
                            panOffset: _panOffset,
                            points: _points,
                            lines: _lines,
                            arcs: _arcs,
                            tempArc: _tempArc,
                            compass: _compass,
                            ruler: _ruler,
                            pulseValue: _pulseController.value,
                            scenarioCompleted: _scenarioCompleted,
                          ),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),

            // Canvas Tools Layer (Top Right)
            if (!_showShutter && !_scenarioCompleted)
              Positioned(
                top: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToolBtn(Icons.architecture, 'compass', _activeTool == 'compass'),
                          _buildToolBtn(Icons.straighten, 'ruler', _activeTool == 'ruler'),
                        ],
                      ),
                    ),
                    if (_activeTool == 'compass' && _compass != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Radius: ${_compass!.radius.toStringAsFixed(1)}", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: _toggleCompassLock,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _compass!.isLocked ? Colors.redAccent : Colors.green,
                                  shape: BoxShape.circle
                                ),
                                child: Icon(_compass!.isLocked ? Icons.lock : Icons.lock_open, color: Colors.white, size: 16),
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),

            // Mini HUD Toast Notifications
            Positioned(
              top: 30,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _toastOpacity,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)]
                      ),
                      child: Text(_toastMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),

            // Canvas Action Buttons
            if (!_showShutter && !_scenarioCompleted)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0, 
                right: 0, 
                bottom: 120,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (showTransversalBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _drawAction('transversal'); },
                          icon: const Icon(Icons.line_axis), label: Text(_i18n[_currentLang]!['btnDrawTransversal'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      if (showLineBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _drawAction('line'); },
                          icon: const Icon(Icons.straighten), label: Text(_i18n[_currentLang]!['btnDrawLine'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),

            // Scrollable HUD Message Overlay / Success Popup
            if (!_showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isSidebarOpen ? sidebarWidth : 0, 
                right: 0, 
                bottom: 20,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 500, maxHeight: 100),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: SingleChildScrollView(
                      child: _scenarioCompleted 
                         ? Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                 const Icon(Icons.check_circle, color: Colors.green, size: 24), const SizedBox(width: 8),
                                 Text(_hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                               ]),
                               const SizedBox(height: 8),
                               Text(_i18n[_currentLang]!['scenarios'][_currentScenario]['successDesc'] ?? "Angle copied successfully!", textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                             ],
                           )
                         : Text(_hudMessage, textAlign: TextAlign.center, style: TextStyle(color: _hudColor == Colors.white ? Colors.black87 : _hudColor, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),

            // Left Sidebar (Scrollable, 30% width)
            AnimatedPositioned(
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: Border(right: BorderSide(color: Colors.indigo.withOpacity(0.3))),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(5,0))]
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Header section
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 74, 20, 20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _i18n[_currentLang]!['title'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigoAccent, height: 1.2)
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _i18n[_currentLang]!['subtitle'],
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(color: Color(0xFF0F172A), border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _cycleLanguage,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 32, padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigoAccent.withOpacity(0.5))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language, color: Colors.indigoAccent, size: 16), const SizedBox(width: 8), Text(_currentLang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))]),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _resetLab, icon: const Icon(Icons.refresh, size: 14), label: const Text("Reset", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32)),
                          )
                        ],
                      ),
                    ),
                    
                    // Scenario Dropdown section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _i18n[_currentLang]!['selectScenario'].toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            isExpanded: true, dropdownColor: const Color(0xFF1E293B), value: _currentScenario,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: List.generate(3, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Text(_i18n[_currentLang]!['scenarios'][index]['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                _playSound('click');
                                setState(() => _loadScenario(val));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Mission Objective
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo.withOpacity(0.3))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_i18n[_currentLang]!['missionObj'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                          const SizedBox(height: 4),
                          Text(_i18n[_currentLang]!['scenarios'][_currentScenario]['objective'], style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
                        ]
                      )
                    ),
                    
                    // Steps List
                    ...(_i18n[_currentLang]!['scenarios'][_currentScenario]['steps'] as List).asMap().entries.map((entry) {
                      int idx = entry.key;
                      var step = entry.value;
                      bool isCurrent = idx == _currentStep && !_scenarioCompleted;
                      bool isPast = idx < _currentStep || _scenarioCompleted;
                      
                      if (!isCurrent && !isPast) return const SizedBox.shrink();

                      return Opacity(
                        opacity: isCurrent ? 1.0 : 0.4,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20), padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: isCurrent ? Colors.indigoAccent : Colors.white24, width: isCurrent ? 2 : 1),
                            borderRadius: BorderRadius.circular(8), color: isCurrent ? Colors.indigo.withOpacity(0.1) : const Color(0xFF0F172A)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 8), 
                                child: Icon(isCurrent ? Icons.adjust : Icons.check_circle, color: isCurrent ? Colors.indigoAccent : Colors.green, size: 16)
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white70, height: 1.4),
                                    children: _parseBoldText(step['text'])
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                    
                    // Footer requested by user
                    Container(
                      padding: const EdgeInsets.all(12), color: Colors.black26, width: double.infinity, 
                      child: const Text("© ZeroScienceLab - Fall in love with math and Science", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))
                    )
                  ],
                ),
              ),
            ),

            // Top-Left Menu Icon - Z-Index Front
            Positioned(
              top: 16,
              left: 16, // Fixed position, won't slide with sidebar
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('click');
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // Floating Active Step (shown on canvas when sidebar is closed)
            if (!_isSidebarOpen && !_showShutter && !_scenarioCompleted)
              Positioned(
                left: _floatingStepPos.dx, top: _floatingStepPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _floatingStepPos = Offset(
                        (_floatingStepPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 280),
                        (_floatingStepPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 150)
                      );
                    });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigoAccent),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("STEP ${_currentStep + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                            const Icon(Icons.drag_indicator, color: Colors.white54, size: 16)
                          ],
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                            children: _parseBoldText(_i18n[_currentLang]!['scenarios'][_currentScenario]['steps'][_currentStep]['text'])
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ),

            // Shutter Screen
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              top: _showShutter ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.architecture, color: Colors.indigoAccent, size: 80),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _i18n[_currentLang]!['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _i18n[_currentLang]!['subtitle'],
                        style: const TextStyle(color: Colors.indigo, fontSize: 18),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          _playSound('shutter'); 
                          setState(() => _showShutter = false);
                        },
                        icon: const Icon(Icons.play_circle, size: 28),
                        label: Text(
                          _i18n[_currentLang]!['enterLab'],
                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
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

  Widget _buildToolBtn(IconData icon, String toolId, bool isActive) {
    return GestureDetector(
      onTap: () => _selectTool(toolId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: 48, height: 48, 
        decoration: BoxDecoration(
          color: isActive ? Colors.indigo : Colors.white10, 
          shape: BoxShape.circle, 
          boxShadow: isActive ? [const BoxShadow(color: Colors.indigoAccent, blurRadius: 10)] : []
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // Exact HTML Localization Implementation
  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'title': "Virtual Lab: The Art of Parallel Line Construction",
      'subtitle': "Class 7 • CONSTRUCTIONS AND TILINGS",
      'selectScenario': "Select Scenario",
      'missionObj': "Mission Objective",
      'btnDrawTransversal': "DRAW TRANSVERSAL",
      'btnDrawLine': "DRAW LINE",
      'enterLab': "Enter Virtual Lab",
      'scenarios': [
        {
          'title': "1. The First Track: A Guided Construction",
          'objective': "To learn the fundamental steps of constructing a parallel line by copying a corresponding angle with guided assistance.",
          'successDesc': "Angle copied successfully! SSS Congruence Applied via Triangles!",
          'steps': [
            {'text': "A line 'm' and a point 'P' outside it are shown. **DRAG** the virtual Ruler. Snap it to point 'P' and 'A' to draw a transversal line 'l'.", 'hud': "Drag ruler and snap to points P and A."},
            {'text': "**DRAG** the Compass tool. CLICK on intersection 'A' to set the pivot. **DRAW** an arc that cuts both line 'm' and transversal 'l' (points 'C' and 'D').", 'hud': "Drag compass pivot to A and draw a wide arc."},
            {'text': "The compass radius is locked. **DRAG** the compass to point 'P'. **DRAW** an identical arc that cuts the transversal 'l' at 'E'.", 'hud': "Drag compass pivot to P and draw an identical arc."},
            {'text': "The compass radius is now unlocked. **DRAG** the compass to 'C'. **ADJUST** the pencil to snap exactly to 'D'. This measures the angle's opening.", 'hud': "Measure opening: Snap pivot to C, stretch pencil to D."},
            {'text': "**DRAG** the compass pivot to point 'E'. **DRAW** a small arc to intersect the previous arc. Label this 'F'.", 'hud': "Drag compass pivot to E. Draw small intersecting arc to find point F."},
            {'text': "**DRAG** the Ruler. CONNECT point 'P' and point 'F' to draw a new line 'n'.", 'hud': "Use Ruler to connect P and F, then DRAW LINE."}
          ]
        },
        {
          'title': "2. The Z-Angle Shortcut",
          'objective': "To construct a parallel line using the alternate interior angles method and observe the 'Z' pattern.",
          'successDesc': "Alternate Angles Copied! Z-Pattern Completed!",
          'steps': [
            {'text': "You are given line 'm' and point 'P'. **DRAG** the Ruler to points P and A. **DRAW** a transversal 'l'.", 'hud': "Drag ruler and snap to points P and A."},
            {'text': "**DRAG** the Compass to point 'A'. **DRAW** an arc that cuts line 'm' at 'D' and transversal 'l' at 'C'.", 'hud': "Drag compass pivot to A and draw an arc."},
            {'text': "With the same radius, **DRAG** the compass to point 'P'. **DRAW** an identical arc, but on the *opposite* side.", 'hud': "Drag compass pivot to P. Draw arc on the OPPOSITE side."},
            {'text': "**DRAG** the compass pivot to point 'D'. **ADJUST** the radius to match the distance to point 'C'.", 'hud': "Measure opening: Snap pivot to D, stretch pencil to C."},
            {'text': "**DRAG** the compass pivot to point 'E'. **DRAW** an arc to intersect the arc from Step 3, creating point 'F'.", 'hud': "Drag compass pivot to E. Draw arc to find point F."},
            {'text': "**DRAG** the Ruler and CONNECT points 'P' and 'F' to draw line 'n'.", 'hud': "Use Ruler to connect P and F, then DRAW LINE."}
          ]
        },
        {
          'title': "3. The Ladder Rung (Perpendicular Method)",
          'objective': "To construct a parallel line by creating two lines perpendicular to the same line.",
          'successDesc': "Ladder complete! Two lines perpendicular to the same line are parallel.",
          'steps': [
            {'text': "Construct a line perpendicular to 'm'. **DRAG** the Compass to 'P' and **DRAW** a large arc intersecting 'm' at 'A' and 'B'.", 'hud': "Snap compass to P. Stretch >200, then draw arc crossing m."},
            {'text': "Find the perpendicular bisector of AB. **DRAG** the Compass to 'A' (or 'B'). Set radius > half of AB and **DRAW** an arc.", 'hud': "Snap compass to A or B. Stretch > half AB, draw arc."},
            {'text': "With the *same radius*, **DRAG** the compass to the other point and **DRAW** another arc that intersects the first at 'Q'.", 'hud': "Snap compass to the other point and draw an intersecting arc."},
            {'text': "**DRAG** the Ruler and CONNECT points 'P' and 'Q' to draw perpendicular line 't'.", 'hud': "Use Ruler to connect P and Q, then DRAW LINE."},
            {'text': "Construct a line perpendicular to 't' at 'P'. **DRAG** Compass to 'P'. **DRAW** an arc crossing 't' at 'C' and 'D'.", 'hud': "Snap compass to P. Shrink radius, draw arc crossing t."},
            {'text': "Construct the perpendicular bisector of CD. **DRAW** intersecting arcs from 'C' and 'D' to create point 'R'.", 'hud': "Draw an arc from C or D, then an intersecting arc from the other."},
            {'text': "**DRAG** the Ruler and CONNECT points 'P' and 'R' to draw your new line 'n'.", 'hud': "Use Ruler to connect P and R, then DRAW LINE."}
          ]
        }
      ]
    },
    'hi': {
      'title': "वर्चुअल लैब: समानांतर रेखा निर्माण की कला",
      'subtitle': "कक्षा 7 • संरचनाएं और टिलिंग",
      'selectScenario': "परिदृश्य चुनें",
      'missionObj': "मिशन का उद्देश्य",
      'btnDrawTransversal': "तिर्यक रेखा खींचें",
      'btnDrawLine': "रेखा खींचें",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'scenarios': [
        {
          'title': "1. पहला ट्रैक: एक निर्देशित निर्माण",
          'objective': "निर्देशित सहायता के साथ संगत कोण की प्रतिलिपि बनाकर समानांतर रेखा बनाने के मूलभूत चरण सीखें।",
          'successDesc': "कोण सफलतापूर्वक कॉपी किया गया! त्रिभुजों के माध्यम से SSS सर्वांगसमता लागू!",
          'steps': [
            {'text': "एक रेखा 'm' और बिंदु 'P' दिखाया गया है। टूलबॉक्स से वर्चुअल रूलर खींचें। तिर्यक रेखा 'l' खींचने के लिए इसे 'P' और 'A' पर स्नैप करें।", 'hud': "रूलर खींचें और P और A बिंदुओं पर स्नैप करें।"},
            {'text': "प्रकार (Compass) टूल खींचें। 'A' पर पिवट सेट करें। एक चाप **खींचें** जो 'm' और 'l' दोनों को काटता हो ('C' और 'D')।", 'hud': "प्रकार पिवट को A पर खींचें और एक चाप खींचें।"},
            {'text': "त्रिज्या लॉक है। प्रकार को 'P' पर **खींचें**। एक समान चाप **खींचें** जो एक नए बिंदु 'E' पर 'l' को काटता हो।", 'hud': "प्रकार पिवट को P पर खींचें और वही चाप खींचें।"},
            {'text': "त्रिज्या अनलॉक हो गई है। प्रकार को 'C' पर **खींचें**। प्रकार की त्रिज्या समायोजित करें ताकि पेंसिल 'D' पर स्नैप हो जाए।", 'hud': "खुलने को मापें: पिवट को C पर स्नैप करें, पेंसिल को D तक खींचें।"},
            {'text': "प्रकार पिवट को 'E' पर **खींचें**। पिछले चाप को काटने के लिए एक छोटा चाप **खींचें** ('F')।", 'hud': "प्रकार पिवट को E पर खींचें। बिंदु F खोजने के लिए चाप खींचें।"},
            {'text': "रूलर **खींचें**। एक नई रेखा 'n' खींचने के लिए बिंदु 'P' और 'F' को जोड़ें।", 'hud': "P और F को जोड़ने के लिए रूलर का उपयोग करें, फिर 'रेखा खींचें'।"}
          ]
        },
        {
          'title': "2. Z-कोण शॉर्टकट",
          'objective': "एकांतर अंतःकोण विधि का उपयोग करके समानांतर रेखा बनाना और 'Z' पैटर्न का निरीक्षण करना।",
          'successDesc': "एकांतर कोण कॉपी किए गए! Z-पैटर्न पूरा हुआ!",
          'steps': [
            {'text': "आपको रेखा 'm' और बिंदु 'P' दी गई है। रूलर खींचें और इसे P और A पर संरेखित करें। एक तिर्यक 'l' **खींचें**।", 'hud': "रूलर खींचें और P और A बिंदुओं पर स्नैप करें।"},
            {'text': "प्रकार को बिंदु 'A' पर **खींचें**। एक चाप **खींचें** जो 'm' को 'D' पर और 'l' को 'C' पर काटता हो।", 'hud': "प्रकार पिवट को A पर खींचें और एक चाप खींचें।"},
            {'text': "उसी त्रिज्या के साथ, प्रकार को बिंदु 'P' पर **खींचें**। एक समान चाप खींचें, लेकिन तिर्यक के *विपरीत* तरफ।", 'hud': "प्रकार पिवट को P पर खींचें। विपरीत दिशा में चाप खींचें।"},
            {'text': "प्रकार पिवट को बिंदु 'D' पर **खींचें**। बिंदु 'C' तक की दूरी से मेल खाने के लिए त्रिज्या समायोजित करें।", 'hud': "खुलने को मापें: पिवट को D पर स्नैप करें, पेंसिल को C तक खींचें।"},
            {'text': "प्रकार पिवट को बिंदु 'E' पर **खींचें**। चरण 3 के चाप को काटने के लिए एक चाप खींचें ('F')।", 'hud': "प्रकार पिवट को E पर खींचें। बिंदु F खोजने के लिए चाप खींचें।"},
            {'text': "रूलर खींचें और रेखा 'n' खींचने के लिए 'P' और 'F' को जोड़ें।", 'hud': "P और F को जोड़ने के लिए रूलर का उपयोग करें, फिर 'रेखा खींचें'।"}
          ]
        },
        {
          'title': "3. सीढ़ी का डंडा",
          'objective': "एक ही रेखा पर दो लंबवत रेखाएं बनाकर समानांतर रेखा बनाना।",
          'successDesc': "सीढ़ी पूरी हुई! एक ही रेखा के लंबवत दो रेखाएं समानांतर होती हैं।",
          'steps': [
            {'text': "'m' पर लंबवत रेखा बनाएं। प्रकार को 'P' पर **खींचें** और एक बड़ा चाप **खींचें** जो 'm' को 'A' और 'B' पर काटता हो।", 'hud': "प्रकार को P पर स्नैप करें। >200 खींचें, चाप खींचें।"},
            {'text': "AB का लंब समद्विभाजक खोजें। प्रकार को 'A' पर **खींचें**। त्रिज्या > आधा AB सेट करें और चाप **खींचें**।", 'hud': "प्रकार को A या B पर स्नैप करें। त्रिज्या > आधा AB, चाप खींचें।"},
            {'text': "*उसी त्रिज्या* के साथ, प्रकार को दूसरे बिंदु पर **खींचें** और एक और चाप **खींचें** जो 'Q' पर काटता हो।", 'hud': "प्रकार को दूसरे बिंदु पर स्नैप करें और प्रतिच्छेदी चाप खींचें।"},
            {'text': "रूलर **खींचें** और लंबवत रेखा 't' खींचने के लिए 'P' और 'Q' को जोड़ें।", 'hud': "P और Q को जोड़ने के लिए रूलर का उपयोग करें, फिर 'रेखा खींचें'।"},
            {'text': "बिंदु 'P' पर 't' के लंबवत रेखा बनाएं। प्रकार को 'P' पर **खींचें**। चाप खींचकर 'C' और 'D' बनाएं।", 'hud': "प्रकार को P पर स्नैप करें। त्रिज्या कम करें, चाप खींचें।"},
            {'text': "CD का लंब समद्विभाजक बनाएं। नया बिंदु 'R' बनाने के लिए 'C' और 'D' से प्रतिच्छेदी चाप **खींचें**।", 'hud': "C या D से एक चाप खींचें, फिर दूसरे से एक प्रतिच्छेदी चाप।"},
            {'text': "रूलर **खींचें** और नई रेखा 'n' खींचने के लिए 'P' और 'R' को जोड़ें।", 'hud': "P और R को जोड़ने के लिए रूलर का उपयोग करें, फिर 'रेखा खींचें'।"}
          ]
        }
      ]
    }
  };
}

// Geometry Classes
class GeoPoint {
  String id; double x; double y; String label; Color color; bool glow; double offsetX; double offsetY;
  GeoPoint({required this.id, required this.x, required this.y, this.label = '', this.color = Colors.blue, this.glow = false, this.offsetX = 0, this.offsetY = -25});
  Offset toOffset() => Offset(x, y);
}
class GeoLine {
  String id; Offset p1; Offset p2; Color color; double width;
  GeoLine({required this.id, required this.p1, required this.p2, this.color = Colors.white70, this.width = 3});
}
class GeoArc {
  double x; double y; double radius; double startAngle; double sweepAngle; Color color;
  GeoArc({required this.x, required this.y, required this.radius, required this.startAngle, required this.sweepAngle, this.color = Colors.blue});
}
class CompassTool {
  double x; double y; double radius; double angle; bool isLocked;
  CompassTool({required this.x, required this.y, required this.radius, required this.angle, this.isLocked = false});
}
class RulerTool {
  double x1; double y1; double x2; double y2;
  RulerTool({required this.x1, required this.y1, required this.x2, required this.y2});
}

// Native Canvas Painter rendering full geometric lab logic
class CanvasPainter extends CustomPainter {
  final int currentScenario;
  final int currentStep;
  final double scale;
  final Offset panOffset;
  final List<GeoPoint> points;
  final List<GeoLine> lines;
  final List<GeoArc> arcs;
  final GeoArc? tempArc;
  final CompassTool? compass;
  final RulerTool? ruler;
  final double pulseValue;
  final bool scenarioCompleted;

  CanvasPainter({
    required this.currentScenario,
    required this.currentStep,
    required this.scale,
    required this.panOffset,
    required this.points,
    required this.lines,
    required this.arcs,
    this.tempArc,
    this.compass,
    this.ruler,
    required this.pulseValue,
    required this.scenarioCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);
    canvas.scale(scale, scale);

    // Grid Background
    Paint gridPaint = Paint()..color = Colors.indigoAccent.withOpacity(0.05)..strokeWidth = 1;
    for (double i = -1000; i <= 1000; i += 40) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), gridPaint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), gridPaint);
    }

    // Draw Lines
    for (var l in lines) {
      if (l.width > 0) {
         canvas.drawLine(l.p1, l.p2, Paint()..color = l.color..strokeWidth = l.width..strokeCap = StrokeCap.round);
      }
    }

    // Scenario 3 Specific Visual Additions (Right-Angle Boxes)
    if (currentScenario == 2) {
       if (currentStep >= 4 || scenarioCompleted) {
          Paint boxPaint = Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.fill;
          if (scenarioCompleted) boxPaint.color = Colors.green.withOpacity(0.4 + 0.4 * pulseValue);
          Paint boxStroke = Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 2;
          Rect rect = const Rect.fromLTRB(0, 80, 20, 100);
          canvas.drawRect(rect, boxPaint);
          canvas.drawRect(rect, boxStroke);
       }
       if (scenarioCompleted) {
          Paint boxPaint = Paint()..color = Colors.green.withOpacity(0.4 + 0.4 * pulseValue)..style = PaintingStyle.fill;
          Paint boxStroke = Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 2;
          Rect rect = const Rect.fromLTRB(0, -120, 20, -100);
          canvas.drawRect(rect, boxPaint);
          canvas.drawRect(rect, boxStroke);
       }
    }

    // Draw Arcs
    for (var a in arcs) {
      Paint arcPaint = Paint()..color = a.color..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: Offset(a.x, a.y), radius: a.radius), a.startAngle, a.sweepAngle, false, arcPaint);
      Paint fillPaint = Paint()..color = a.color.withOpacity(0.1)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: Offset(a.x, a.y), radius: a.radius), a.startAngle, a.sweepAngle, true, fillPaint);
    }

    // Draw Temp Arc (Live preview)
    if (tempArc != null) {
      Paint arcPaint = Paint()..color = tempArc!.color.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: Offset(tempArc!.x, tempArc!.y), radius: tempArc!.radius), tempArc!.startAngle, tempArc!.sweepAngle, false, arcPaint);
      Paint fillPaint = Paint()..color = tempArc!.color.withOpacity(0.1)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: Offset(tempArc!.x, tempArc!.y), radius: tempArc!.radius), tempArc!.startAngle, tempArc!.sweepAngle, true, fillPaint);
    }

    // Success Glow Effects
    if (scenarioCompleted) {
      Paint parallelGlow = Paint()
          ..color = Colors.greenAccent.withOpacity(0.4 + (0.2 * pulseValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      var drawnLine = lines.where((l) => l.id == 'n').firstOrNull;
      var givenLine = lines.where((l) => l.id == 'm').firstOrNull;
      
      if (drawnLine != null) canvas.drawLine(drawnLine.p1, drawnLine.p2, parallelGlow);
      if (givenLine != null) canvas.drawLine(givenLine.p1, givenLine.p2, parallelGlow);

      // Scenario 2: Alternate "Z" shape glow
      if (currentScenario == 1) {
         GeoPoint? dNode = points.where((p)=>p.id=='D').firstOrNull;
         GeoPoint? aNode = points.where((p)=>p.id=='A').firstOrNull;
         GeoPoint? pNode = points.where((p)=>p.id=='P').firstOrNull;
         GeoPoint? fNode = points.where((p)=>p.id=='F').firstOrNull;
         if (dNode != null && aNode != null && pNode != null && fNode != null) {
            Path zPath = Path()
               ..moveTo(dNode.x, dNode.y)
               ..lineTo(aNode.x, aNode.y)
               ..lineTo(pNode.x, pNode.y)
               ..lineTo(fNode.x, fNode.y);
            
            Paint zGlow = Paint()
               ..color = Colors.amber.withOpacity(0.6 + 0.4 * pulseValue)
               ..style = PaintingStyle.stroke
               ..strokeWidth = 8
               ..strokeJoin = StrokeJoin.round
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
            canvas.drawPath(zPath, zGlow);

            Paint zStroke = Paint()
               ..color = Colors.amberAccent
               ..style = PaintingStyle.stroke
               ..strokeWidth = 4
               ..strokeJoin = StrokeJoin.round;
            canvas.drawPath(zPath, zStroke);
         }
      }
    }

    // Draw Points
    for (var p in points) {
      if (p.glow) {
        canvas.drawCircle(Offset(p.x, p.y), 15, Paint()..color = p.color.withOpacity(0.4 * pulseValue)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      }
      canvas.drawCircle(Offset(p.x, p.y), 6, Paint()..color = p.color);
      canvas.drawCircle(Offset(p.x, p.y), 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      
      if (p.label.isNotEmpty) {
        TextPainter tp = TextPainter(
          text: TextSpan(text: p.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.x + p.offsetX, p.y + p.offsetY));
      }
    }

    // Draw Ruler
    if (ruler != null) {
      canvas.save();
      double dx = ruler!.x2 - ruler!.x1; double dy = ruler!.y2 - ruler!.y1;
      double dist = math.sqrt(dx*dx + dy*dy); double angle = math.atan2(dy, dx);
      canvas.translate(ruler!.x1, ruler!.y1); canvas.rotate(angle);
      
      Paint rulerPaint = Paint()..color = Colors.indigoAccent.withOpacity(0.3)..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, -20, dist, 40), const Radius.circular(6)), rulerPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, -20, dist, 40), const Radius.circular(6)), Paint()..color=Colors.indigoAccent..style=PaintingStyle.stroke..strokeWidth=2);
      
      Paint tickPaint = Paint()..color = Colors.white;
      for(double i=10; i<dist-10; i+=10) { canvas.drawRect(Rect.fromLTWH(i, -20, 2, i%50==0 ? 15 : 8), tickPaint); }
      
      canvas.drawCircle(const Offset(0, 0), 10, Paint()..color=Colors.indigo); canvas.drawCircle(Offset(dist, 0), 10, Paint()..color=Colors.indigo);
      canvas.drawCircle(const Offset(0, 0), 4, Paint()..color=Colors.white); canvas.drawCircle(Offset(dist, 0), 4, Paint()..color=Colors.white);
      canvas.restore();
    }

    // Draw Compass
    if (compass != null) {
      canvas.save();
      canvas.translate(compass!.x, compass!.y);
      canvas.rotate(compass!.angle);
      
      double r = math.max(10.0, compass!.radius);
      double L = math.max(140.0, r * 1.2 + 20);
      double hx = r / 2; double hy = -math.sqrt(L * L - hx * hx);

      Paint metalPaint = Paint()..color = Colors.grey[400]!..strokeWidth = 4..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(0, 0), Offset(hx, hy), metalPaint);
      canvas.drawLine(Offset(r, 0), Offset(hx, hy), metalPaint);
      
      canvas.drawCircle(Offset(hx, hy), 8, Paint()..color = Colors.grey[700]!);
      canvas.drawCircle(Offset(hx, hy), 4, Paint()..color = Colors.grey[300]!);
      canvas.drawLine(Offset(hx, hy), Offset(hx, hy - 25), Paint()..color=Colors.grey[700]!..strokeWidth=6);
      
      canvas.drawCircle(const Offset(0, 0), 12, Paint()..color = Colors.indigoAccent);
      Path needle = Path()..moveTo(-2, -8)..lineTo(2, -8)..lineTo(0, 8)..close();
      canvas.drawPath(needle, Paint()..color = Colors.grey[300]!);

      canvas.translate(r, 0);
      canvas.drawCircle(const Offset(0, 0), 12, Paint()..color = Colors.indigoAccent);
      
      canvas.save();
      canvas.rotate(-math.pi/2 - math.atan2(hy, hx - r));
      Path pencilTip = Path()..moveTo(-4, -15)..lineTo(4, -15)..lineTo(0, 0)..close();
      canvas.drawPath(pencilTip, Paint()..color = Colors.orange);
      canvas.drawRect(const Rect.fromLTWH(-4, -35, 8, 20), Paint()..color = Colors.grey[700]!);
      Path lead = Path()..moveTo(-2, -5)..lineTo(2, -5)..lineTo(0, 0)..close();
      canvas.drawPath(lead, Paint()..color = Colors.black87);
      canvas.restore();
      
      canvas.restore();

      // UI Indicators
      if (compass!.isLocked) {
        Paint lockedPaint = Paint()..color = Colors.green.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawCircle(Offset(compass!.x, compass!.y), compass!.radius, lockedPaint);
      } else {
        // Unlocked mode handle
        double handleX = compass!.x + (compass!.radius/2) * math.cos(compass!.angle);
        double handleY = compass!.y + (compass!.radius/2) * math.sin(compass!.angle);
        canvas.drawCircle(Offset(handleX, handleY), 16, Paint()..color = Colors.lightBlue);
        canvas.drawCircle(Offset(handleX, handleY), 16, Paint()..color = Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
        
        TextPainter tp = TextPainter(text: const TextSpan(text: "↔", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(handleX - tp.width/2, handleY - tp.height/2));
        
        Paint measurePaint = Paint()..color = Colors.redAccent.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawCircle(Offset(compass!.x, compass!.y), compass!.radius, measurePaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}